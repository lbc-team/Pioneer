> * 原文： https://aragon.org/blog/snapshot  来自： Aragon Blog
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
#  Aragon的乐观投票：链外投票与链上执行方案



[乐观投票（Optimistic voting）](https://forum.aragon.org/t/simple-voting-relay-protocol-optimistic-vote-tallying/473)一段时间以来，它一直是Aragon社区中的热门话题。当我们开始研究该主题时，用户投票需要花费是几美分。而如今，随着以太坊的阻塞，用户投票的成本可能高达30美元。

幸运的是，我们[Balancer Labs](http://balancer.finance/)的朋友们推出自己的进行链下投票产品：[Snapshot](https://snapshot.page/).

Snapshot允许社区在链外进行代币持有人投票。投票结果是可验证的，并且投票过程是防篡改的([投票(votes)](https://ipfs.io/ipfs/QmVjaAoH7uJQ9bsGgeyRHCpAzHGcQ6prMXKctCK7xwhgbH)和[relayer 收据](https://ipfs.io/ipfs/QmYjQ1rYRaTfNBs4XNj3u7bWNyjvBCaPDRoggoSox3ripf)存储在IPFS中)。

Snapshot已迅速成为[Yearn](http://yearn.finance/)和[Aave](http://aave.com/)等知名社区的首选投票解决方案。但是，目前Snapshot的现状，投票过程仍然存在着“显著的中心化”问题。代币持有者可以根据偏好投票，但此投票“只是一个信号”。实际链上执行必须通过其他方式完成，例如依赖受信任的“多签”，由他们来检查投票结果并执行代币持有者的意愿。

从中心化和安全性的角度来看，这种方法“风险很大”，也可能使“多重签名”成员面临不希望的遇到的问题，例如对社区决策的法律责任。

而另一方面，所有投票都在链上进行，则更加安全和完全去中心化。但是，这又极其昂贵且缓慢。

>   直到今天，区块链投票的不得不进行这样权衡：要么使用高性能链下投票（具有更高的参与度），要么是使用昂贵但安全的链上投票。



Aragon 已经进行了广泛的研究，并建立了诸如Aragon 法庭，Aragon 代理和AragonOS 5的核心基础架构。我们很高兴地宣布“链外投票链上执行”解决方案。是的，鱼和熊掌可兼得，不需要进行权衡。

[乐观执行](https://medium.com/@deaneigenmann/optimistic-contracts-fb75efa7ca84)的基本概念就是不用在链上执行昂贵的计算，而是可以直接提交结果以及保证其正确性的适当抵押。如果有人发现错误的结果，他们可以提出挑战，挑战成功则可收获抵押品。

在这里，我们采用相同的概念，并使用[Aragon 法庭](https://aragon.org/court) 来评估提交结果是否正确。

该解决方案利用Aragon 法庭和[Aragon  代理](https://aragon.org/agent)，即将在Snapshot中提供（现在正在[在Rinkeby上运行](https://rinkeby.snapshot.page/#/dai/proposal/QmdBjGyAJr3qUaUquXVg9i4EPbd4y7pZ7Sik6aaqzCMxmP)！）这意味着Yearn，Aave，Balancer和其他社区将能够利用它。

>  “我对Aragon在Snapshot中添加链上执行感到非常兴奋，我认为许多社区将从中受益”- Balancer Fabien Marino

![img](https://img.learnblockchain.cn/pics/20210118092654.png)



## 乐观投票运作原理

通常，受信任社区成员的多重签名具有对协议或金库执行权力。当社区对一项决定进行投票时，多名签名者会检查投票结果并代表社区执行操作。

当社会资本和声誉受到威胁，实际上无法阻止多签成员执行非社区决定的事情。

使用乐观Snapshot，多签被DAO取代。 DAO的[代理](https://aragon.org/agent)拥有执行权。 Aragon Agent（代理）是一个链上使者，可以在以太坊上的任何执行操作（个人或多签可以做的事情，代理都可以完成）。代理扮演着DAO角色，用来完成，例如：更新协议参数，管理金库，甚至进行 DeFi乐高组合。

投票结束后，任何人都可以**将经投票的结果提交给链上的DAO**。 DAO 还拥有一个 “时间锁”  作为“争议延迟”，这是在在执行操作之前施加一个“时间锁定期”**。在该时间段内，**任何人都可以对投票结果提出异议，并将其提交给[Aragon 法庭](https://aragon.org/court) 。

如果有人提出的与通过投票的结果不符“恶意行为”，Aragon法庭**陪审员将对此作出裁定**，而提案人的质押金将被大幅削减。

如果没有人对行动提出异议，它将继续并等待**执行**。

由于恶意行为受到了严厉的惩罚，因此它们实际上是通过威慑而被过滤掉的，只将合法行为留在执行队列中。

该提议流程使成员在知道自己的行为是合法时，拥有更大的自治权可以代表组织采取行动。由于任何成员都可以对任何行动提出异议，因此不需要每个成员都主动监听或参与每个投票的链上执行。

这就是为什么我们将此称为“乐观投票”。

‍

![img](https://img.learnblockchain.cn/pics/20210118092701.png)

## 未来

此功能将作为[Aragon Agreements](https://aragon.org/agreements) 发布，《Aragon Agreements》允许DAO用简单的英语定义它们的含义，建立规则和习惯，并在不牺牲其成员代理利益的情况下保护自己免受恶意行为的侵害。如遇纠纷，可以将Aragon法院作为仲裁员。

我们为社区提供链外投票，同时帮助他们去中心化链上执行的权力而感到兴奋。

哦，我们刚刚向[向往的社区提交了一份提案](https://gov.yearn.finance/t/adopt-snapshot-aragon-for-binding-governance/5568)帮助他们使用乐观Snapshot构建其DAO。

非常感谢Balancer的Fabien在创纪录的时间内帮助实现了整合！

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。