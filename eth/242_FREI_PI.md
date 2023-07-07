> * 原文链接： https://www.nascent.xyz/idea/youre-writing-require-statements-wrong
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# DeFi 合约安全的新模式：关注协议不变性



在 DeFi 合约中，常见模式是`Checks-Effects-Interactions（检查-生效-交互）`模式， 不够好，它会让开发者忘记协议的核心不变性。

作者提出了一个新的模式：FREI-PI： `功能检查-生效-交互+协议不变性（Function Requirements-Effects-Interactions + Protocol Invariants ）`，让我们更多从协议角度确保协议的不变性（安全性）。



## 摘要

不要只为特定的函数写 `require`语句；为你的协议写 `require`语句。函数遵循`检查(requirements)-生效(Effects)-交互(INteractions)+协议不变性(Invariants)`或 `FREI-PI`模式可以帮助你的合约更加安全，因为它迫使开发人员除了关注函数级别的安全之外，还要关注协议级别的不变性。

## 动机

2023年3月，Euler Finance被黑客攻击，损失2亿美元。Euler Finance是一个借贷市场，用户可以存入抵押品并以其为抵押进行借款。它有一些独特的功能，实际上他们是一个可与Compound Finance和Aave媲美的借贷市场。

你可以阅读关于这个黑客的事后总结[这里](https://medium.com/@omniscia.io/euler-finance-incident-post-mortem-1ce077c28454)。它的主要内容是在一个特定的函数中缺少健康检查，允许用户打破借贷市场的基础不变性。

## 基础不变性（Fundamental Invariants）

大多数DeFi协议的核心都有一个不变性，即程序状态的一个属性，它被期望永远是真的。也可能有多个不变性，但一般来说，它们是围绕着一个核心思想建立的。这里是一些例子：

- 如在借贷市场中：用户不能采取任何行动，使任何账户处于不安全或更不安全的抵押品仓位（"更不安全"意味着它已经低于最低安全阈值，因此不能进一步提取）。
- AMM DEX 中：`x * y == k`，`x + y == k`，等等。
- 流动性挖矿抵押中： 用户应该只能提取他们存入的抵押代币数量。

Euler Finance 出错的地方不一定是他们增加了功能，没有写测试，或者没有遵循传统的最佳实践。他们对升级进行了审计，并有测试，但还是被漏掉了。核心问题是他们忘记了借贷市场的核心不变性（审计人员也是如此！）。

> 注：我不是要挑刺 Euler，他们是一个有才华的团队，但这是一个最近的案例。

## 问题的核心

你可能在想 "嗯，没错。这就是他们被黑的原因；他们忘了一个 `require` 语句"。是也不是。

但**为什么**他们会忘记require语句呢？

### `检查-生效-交互` 不够好

推荐给solidity开发者使用的一个常见模式是`Checks-Effects-Interactions（检查-生效-交互）`模式。它对于消除与[重入](https://learnblockchain.cn/tags/%E9%87%8D%E5%85%A5%E6%94%BB%E5%87%BB)有关的错误非常有用，而且通常会增加开发人员去执行输入验证的的数量。*但是*，它容易出现只见树木不见森林的问题。

它教给开发人员的是："首先我写我的require语句，然后我做生效，然后也许我做任何交互，然后我就安全了"。问题是，通常情况下，它变成了检查和效果的混合体--不错吧？交互仍然是最后的，所以重入性不是一个问题。但它迫使用户关注更具体的功能和个别的状态转换，而不是全局的、更广泛的背景。这就是说：

**仅仅是`检查-生效-交互`模式就会使开发者忘记他们协议的核心不变性**。

对于开发者来说，它仍然是一个出色的模式，但总是应该确保（服务于）协议的不变性（说真的，你还是应该使用CEI！）。

## 正确做法：FREI-PI模式

以dYdX的`SoloMargin`合约（[源码](https://github.com/dydxprotocol/solo/blob/0412e9457c113f663117fa6ce1048a06839ba388/contracts/protocol/impl/OperationImpl.sol)）中的这个片段为例，它是借贷市场和杠杆交易合约。这是一个很好的例子，我称之为 `功能检查-生效-交互+协议不变性（Function Requirements-Effects-Interactions + Protocol Invariants ）`模式，或FREI-PI模式。

因此，我相信这是早期借贷市场中唯一没有任何市场相关漏洞的借贷市场。Compound和Aave没有直接出现问题，但他们的分叉代码[有](https://rekt.news/agave-hundred-rekt/)关于过问题。而bZx则[被黑了多次](https://rekt.news/bzx-rekt/)。

检查下面的代码，注意以下的抽象概念：

1. 检查输入参数（`_verifyInputs`）。

2. 动作（数据转换，状态操作）

3. 检查最终状态（`_verifyFinalState`）。

```solidity
 function operate(
     Storage.State storage state,
     Account.Info[] memory accounts,
     Actions.ActionArgs[] memory actions
 )
     public
 {
     Events.logOperation();

     _verifyInputs(accounts, actions);

     (
         bool[] memory primaryAccounts,
         Cache.MarketCache memory cache
     ) = _runPreprocessing(
         state,
         accounts,
         actions
     );

     _runActions(
         state,
         accounts,
         actions,
         cache
     );

     _verifyFinalState(
         state,
         accounts,
         primaryAccounts,
         cache
     );
 }
```

仍然执行常用的 `Checks-Effects-Interactions`。值得注意的是，带有额外 `检查 `的 `检查-生效-交互 `并不等同于 `FREI-PI`--它们是相似的，但服务于根本不同的目标。因此，开发者应该认为它们是不同的：FREI-PI 作为一个更高的抽象，旨在实现协议安全，而CEI旨在实现功能安全。



这个合约的结构真的很有趣--用户可以在一连串的行动中执行他们想要的行动（存款、借款、交易、转让、清算等）。想存入3个不同的代币，提取第4个，并清算一个账户？这是一个单一的调用。

这就是FREI-PI的力量：用户可以在协议内做任何他们想做的事情，只要核心借贷市场的不变性在调用结束时成立：`一个用户不能采取任何行动，将任何账户置于不安全或更不安全的抵押品仓位`。对于这个合约，这是在`_verifyFinalState`中执行的，检查每个受影响账户的抵押情况，确保协议比交易开始时更好。

该函数中包括一些额外的不变性，这些不变性是对核心不变性的补充，有助于实现关闭市场等附属功能，但*真正*保持协议安全的是核心检查。

## 以实体为中心的FREI-PI

FREI-PI的另一个问题是以实体为中心的概念。以一个借贷市场和假定的核心不变性为例：

```
一个用户不能采取任何行动，将任何账户置于不安全或更不安全的抵押品仓位
```

从技术上讲，这不是唯一的不变性，但它是针对用户实体的（它仍然是核心协议不变性，通常用户不变性是核心协议不变性）。借贷市场通常也会有2个额外的实体：

1. 预言机

2. 管理/治理

每一个额外的不变性都会使协议更加难以保障，因此越少越好。这实际上就是Dan Elitzer在他那篇题为：[为什么DeFi 已坏以及如何修复它 #1 无预言机协议](https://learnblockchain.cn/article/6017) 文章中所说的（提示：这篇文章实际上并没有说预言机是问题所在）。

### 预言机

对于预言机，以1.3亿美元的[Cream Finance漏洞](https://rekt.news/cream-rekt-2/)为例。预言机实体的核心不变性：

```
预言机提供准确且(相对)实时的信息
```

事实证明，用FREI-PI在运行时验证预言机是很棘手的，但是可以做到，需要一些预先考虑。一般来说，Chainlink是一个很好的选择，可以[主要依靠](https://blog.chain.link/improving-and-decentralizing-chainlinks-feature-release-and-network-upgrade-process/?ref=blog.synthetix.io)，满足大部分的不变性。在极少数的操纵或意外情况下，有一些保障措施可能是有益的，这些保障措施可以减少灵活性，而有利于准确性（比如检查最后知道的值是否比当前值大百分数百）。同样，dYdX的`SoloMargin`系统在他们的DAI预言机方面做得很好， [这里是代码](https://github.com/dydxprotocol/solo/blob/0412e9457c113f663117fa6ce1048a06839ba388/contracts/external/oracles/DaiPriceOracle.sol#L289-L309)（如果你看不出来，我认为这是历史上写得最好的复杂智能合约系统）。

关于预言机评估的更多内容，以及突出Euler团队的能力，他们写了一篇关于计算[操纵Uniswap V3 TWAP预言机](https://github.com/euler-xyz/uni-v3-twap-manipulation/blob/master/cost-of-attack.pdf)价格的好文章。

### 管理/治理

为管理实体创建不变性是最棘手。这主要是由于他们的大部分作用是去改变现有的其他不变性。也就是说，如果你能避免使用管理角色，你应该这样做。

从根本上说，一个管理实体的核心不变性可能是：

```
管理员应该在当且仅当在其他的不变性或需要特意移除或修改不变性时才采取行动。
```

解读：管理员可以做一些应该结果不会破坏不变性的事情，*除非*他们为了保护用户的资金而大幅改变事情（例如：将资产转移到救援合约中是对不变性的移除）。管理员也应该被认为是一个用户，所以核心借贷市场的用户不变性也应该对他们成立（意味着他们不能对其他用户或协议进行攻击）。目前，一些管理员的行为不可能在运行时通过FREI-PI进行验证，但如果在其他地方有足够强大的不变性，希望大多数问题可以得到缓解。我说目前，因为人们可以想象使用zk证明系统可能会检查合约的整个状态（每个用户、每个预言机等）。



作为一个管理员破坏不变性的例子，以发生在2022年8月的[borked the cETH market](https://medium.com/chainlight/the-suspension-of-compound-finances-ceth-market-causes-and-solutions-b106c2e1c922)的 Compound 治理行动为例。从根本上说，这次升级破坏了Oracle的不变性：`Oracle`提供准确和(相对)实时的信息。由于功能的缺失，Oracle可以提供*不对*的信息。一个运行时的FREI-PI验证，检查受影响的Oracle能否提供实时信息，可以防止升级的发生这样的情况。这可以纳入`_setPriceOracle`，检查所有资产是否收到实时信息。FREI-PI对管理角色的好处是，管理角色对价格相对不敏感(或者至少应该是这样)，所以更多的Gas使用量不应该是个大问题。

### 复杂是危险的

因此，虽然最重要的不变性是协议的核心不变性，但也可以有一些以实体为中心的不变性，这些不变性必须为核心不变性所持有。但是，最简单（和最小）的不变性集可能是最安全的。简单就是好的一个光辉榜样是Uniswap ...

## 为什么Uniswap从来没有被黑过（大概）

AMMs 可以有任何 DeFi 原语中最简单的基本不变性：`tokenBalanceX * tokenBalanceY == k`（例如常量乘积模型）。Uniswap V2 中的每个函数都是围绕这个简单的不变性：

1. Mint：添加到`k`中

2. Burn：从`k`中减去

3. Swap：转移`x`和`y`，不动`k`。

4. Skim：重新调整`tokenBalanceX * tokenBalanceY`，使其等于`k`，移除多余的部分。

Uniswap V2的安全秘诀：核心是一个简单的不变性，所有功能都是为它服务的。唯一可以争论的其他实体是治理，它可以打开一个收费开关，这并不触及核心不变性，只是代币余额所有权的分配。他们的安全声明中的这种简单性是Uniswap从未被黑过的原因。简单其实并不是对Uniswap的智能合约的优秀开发者的轻视，相反需要出色的工程师来找到简单性。

## Gas问题

我的Twitter上已经充满了优化论者关于这些检查是不必要的和低效的恐怖和痛苦的尖叫声。关于这个问题有两点：

1. 你知道还有什么是低效的吗？不得不通过etherscan向~~[Laurence](https://twitter.com/functi0nZer0)~~朝鲜黑客发送信息，使用ETH转账，并威胁说FBI会介入。

2. 你可能已经从存储中加载了所有需要的数据，所以在调用结束时，只是对这些热数据加一点点 require 检查。你想让你的协议贵那么一点忽略不计的费用，还是让它死于非命？

如果成本过高，请重新考虑核心变量，并尝试简化。

## 这对我来说意味着什么？

作为一个开发者，要在开发过程中尽早地定义并表达出核心不变性。作为一个具体的建议：让自己写的第一个函数是`_verifyAfter`，在每次调用你的合约后验证你的不变性。把它放在你的合约中，并在那里进行部署。用更广泛的不变性测试来补充这个不变性（以及其他以实体为中心的不变性），这些测试在部署前就被检查过了（[Foundry guide](https://book.getfoundry.sh/forge/invariant-testing?highlight=invariant#invariant-testing)）。

瞬时存储开启了一些有趣的优化和改进，Nascent将对此进行实验--我建议你考虑如何将瞬时存储作为一种工具，以实现更好的跨调用上下文更安全。

在这篇文章中，没有花太多时间在 FREI-PI模式的介绍输入验证，但这也是非常重要的。定义输入的边界是一项具有挑战性的任务，以避免溢出和类似情况。可以考虑查看并关注我们的工具的进展：[pyrometer](https://github.com/nascentxyz/pyrometer)（目前处于测试阶段，请给我们一个星星）。它可以深入了解并帮助找到你可能没有进行输入验证的地方。

## 结论

在任何朗朗上口的缩写（FREI-PI）或模式名称之上，真正重要的一点是：

在你的协议的核心不变性中找到简单性。并拼命工作以确保它永远不会被破坏（或在它被破坏之前就被捕获）。

## 谢谢

非常感谢[@plotchy](https://twitter.com/plotchy)和[@Dan Elitzer](https://twitter.com/delitzer)在这方面的启发。感谢[@Matt Solomon](https://twitter.com/msolomon44)对本文的宝贵反馈和评论，以及对FREI-PI 建设的帮助。

感谢来自dYdX的[@Brendan Chou](https://twitter.com/B_Chou)和[@Antonio Juliano](https://twitter.com/AntonioMJuliano)编写的 "SoloMargin "保证金合约（以及在我探索solidity的早期给予的帮助）--该合约可能已经失效，但它以一种新的方式继续存在，并教会了我很多。

