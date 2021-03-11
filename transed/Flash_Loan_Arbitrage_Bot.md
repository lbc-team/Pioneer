> * 原文：https://blog.infura.io/build-a-flash-loan-arbitrage-bot-on-infura-part-i/ 来自：由Pedro Bergamini和Coogan Brennan
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
>



# 在Infura上建立闪电贷套利机器人 #1



**在套利系列的第一部分中，会先解释闪电贷和闪电兑背后的基本概念。在第二部分中，将展示如何构建自己的交易机器人，机器人在Infura上运行，使用闪电贷观察套利机会并执行获利**。

## 关于套利

套利交易其实与闪电贷或区块链无关，当相同的两个资产在两个不同的交易所拥有不同的兑换价格时，就存在这样的套利交易。

例如，让我们看一下两个交易所：[Uniswap](http://uniswap.exchange/)和[Sushiswap](https://sushiswapclassic.org/). Sushiswap是Fork 自 Uniswap，它们运行着相同的合约代码。虽然它们是两个不同的交易所，但我们可以使用相同的代码执行相同的交易。另外，由于Sushiswap是较新的交易所，因此可能为它编写的机器人更少。

套利的工作原理是：一枚以太币在Uniswap中价值80 Dai，而在Sushiswap中则价值100 Dai。我们在Uniswap上购买1 ETH，然后立即在Sushiswap上出售，以赚取20 Da的利润i(减去 gas 和费用)。这是典型的获利套利交易。

## 闪电贷与闪电兑（**Flash Loan vs Flash Swap**）



![img](https://img.learnblockchain.cn/pics/20210121204826.png)



闪电贷和闪电兑是来源于区块链的概念。上图显示了两者之间的一些关键区别。让我们补充下要点。



在[Aave协议](https://aave.com/flash-loans/) 上的**闪电贷**收取0.09％的费用， 它至少需要进行三个操作：

1. 向Aave借钱； 

2. 在一个去中心化的交易所进行交易；

3. 在另一个去中心化交易所进行套利交易以实现利润，并偿还同一资产。 如果你借出Dai，则需要偿还Dai。

   

**闪电兑**则允许交易者先接收资产并在其他地方使用资产，再支付使用的资产。

 在[Uniswap](https://uniswap.org/docs/v2/core-concepts/flash-swaps/)上进行闪电兑时，尚无固定费用，但收取[兑换费 0.3%](https://uniswap.org/docs/v2/advanced-topics/fees)。与闪电贷相比，这可以看作是“免费”贷款，因为交易费是从交易订单中扣除的，不必单独付款。最后一点区别：我们可以偿还闪电兑中的任何资产。如果我们使用闪电兑用ETH购买Dai，我们可以用Dai或ETH偿还兑换。这使我们可以执行更复杂的操作。



闪电兑和闪电贷均采用“乐观转账”，这是我们稍后将介绍的一种引人入胜的技术。



## 闪电贷和合约

要理解闪电贷，需要了解以太坊交易性质。所有以太坊交易均源自外部拥有的帐户(EOA)，这是一个由人操作的以太坊地址。以太坊交易可以从一个EOA转到另一个EOA，就像你付钱给朋友一样。以太坊交易也可以从EOA转到合约中执行代码。该合约可以调用另一个合约，依此类推，直到你的交易费（gas）用完为止。

>  注意：如果你不熟悉以太坊的交易，请查看 [以太坊的账户，合约和交易类型的介绍](https://kctheservant.medium.com/transactions-in-ethereum-e85a73068f74).

稍后我们将看到，闪电贷在其执行过程中需要多个函数调用，而这在EOA中是不可能完成的。相反，我们将部署包含多步骤流程的合约。我们从EOA 发起交易到Aave合约进行套利，但我们提供的部署合约的地址。另外还需要提供足够ETH以支付交易的 gas 成本，由于交易的复杂性，这可能会非常昂贵。 (请记住，交易的成本取决于需要多少计算量)。

![img](https://img.learnblockchain.cn/pics/20210121204834.png)

## 乐观转账

闪电贷和闪电兑均采用称为“乐观转账”的技术。这项非凡的DeFi创新技术使用户可以进行无抵押贷款或兑换，只要用户在交易结束前偿还所需的资金。为了更好地理解这种想法，让我们来看一些代码。

[这是Aave(V1)的LendingPool.sol合约代码](https://github.com/aave/aave-protocol/blob/master/contracts/lendingpool/LendingPool.sol#L843)。查看`flashLoan`函数，特别是以下方法：

![img](https://img.learnblockchain.cn/pics/20210121204839.png)

在877行中，我们可以看到合约**先“乐观地”将资金转账到用户的合约中**，它不检查用户合约的余额以查看他们是否有足够的资产，仅仅是仅仅是转账到合约而已。



怎么能这样？用户是否会”携款潜逃“？如果交易就这样结束，那么将是一个严重的问题。但是正如你所看到的，代码并没有结束。用户合约是否”留着这些代币"还取决于接下来的几行是能收成功执行。



乐观转账后，在第881行，我们看到Aave合约使用乐观转账金额和用户传入的参数去调用用户合约。为了达成交易成功执行，这些参数的 内容用户可以任意指定。现在，交易流暂时从Aave合约暂停了，并移至用户合约，用户合约将执行其套利逻辑。



在第884行，用户合约已经执行完了其代码，现在交易流返回到Aave合约，代码中有一条` require`语句，它从检查从用户的合约中提取的费用。乐观转账到此结束，如果用户合约确实完成了这笔套利交易，Aave合约将能够扣除费用。如果没有完成，则此` require`语句将失败，这意味着整个交易都将失败。



让我们看一下Uniswap如何实现其乐观转账。下面代码来自UniswapV2Pair.sol合约，需要关注`swap`函数：

![img](https://img.learnblockchain.cn/pics/20210121204845.png)

乐观转账发生在第170-171行，这是通过 _safeTransfer 函数来完成的。Uniswap甚至把乐观转账注释了出来，以便更好地识别（[顺便说一句，Uniswap为他们协议准备了很棒的文档和教育资料！](https://uniswap.org/docs/v2/)）。下一行是Uniswap合约，它用转账余额去调用用户合约（即进行闪电兑）。

同样，交易流会在Uniswap合约上暂时暂停，转到用户合约上执行。一旦在用户合约上执行完毕，交易流就会回到Uniswap合约上。然后，Uniswap合约检查新的余额，并尝试获取兑换费用（180-181行）。



如果用户的套利合约未能转入相应的金额，182行的 `require`语句就会失败，整个交易就会还原。这就是乐观转账的关键，它完全取决于用户合约套利交易在交易前转入相应的资金。如果不成功，交易就无效，会恢复到代币转账前的状态。然而，如果成功了，乐观转账就会被保留，用户就会获得他们的利润。

------

## 小结

套利、合约调用和乐观转账共同创造了一个令人印象深刻的新工具。这是一个建立在公共区块链创新之上的创新。这两种创新相互组合，创造了一个真正强大而独特的机制。

在接下来的第二部分，理论将与实践相结合。我们将通过实际构建一个套利机器人。你可以预览代码[这里](https://github.com/pedrobergamini/flashloaner-contract)。

敬请关注！



------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。