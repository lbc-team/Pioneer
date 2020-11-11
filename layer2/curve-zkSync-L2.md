> * 链接：https://medium.com/matter-labs/curve-zksync-l2-ethereums-first-user-defined-zk-rollup-smart-contract-5a72c496b350
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# Curve + zkSync L2：以太坊的第一个用户定义的ZK Rollup 智能合约！



>  欢迎来到 zincSync智能合约测试网Zinc Alef。



![Zinc Alef](https://img.learnblockchain.cn/2020/10/23/16034192591139.jpg)



Curve和Matter Labs团队很高兴宣布以安全且去中心化的方式向以太坊扩展迈出了一大步：今天，我们和Curve Finance一起发布了第一个常驻dapp的zkSync L2智能合约测试网。



**>>** [**演示 demo!**](https://zksync.curve.fi/) **<<**

[在 Zinc 上的Curve合约](https://github.com/matter-labs/curve-zinc)

[Zinc 文档](https://zinc.zksync.io/)



## 为什么选择ZK Rollup ？

扩展性是以太坊一个迫切的需求 - 隧道尽头有一个亮灯。 Vitalik Buterin [刚刚宣布 Rollup 是现阶段扩展以太坊的“唯一选择”](https://www.trustnodes.com/2020/10/05/ethereum-rollups-are-the-only-choice-for-scalability-says-vitalik-buterin)， 突出显示了其[独特的无需信任安全保证](/ matter-labs/evaluating-ethereum-l2-scaling-solutions-a-comparison-framework-b6b2f410f955) 。

ZK Rollup (ZKR)是现有的两种 [Rollup](https://learnblockchain.cn/tags/Rollup) 版本之一，另一种是 [Optimistic  Rollup (简写：OR)](https://learnblockchain.cn/tags/Optimistic%20Rollup)。两种方法都有其取舍([参见详细比较](https://learnblockchain.cn/article/738))。这是主要的实际差异：

**安全** - 即使使用单个验证者，ZK Rollup 也非常安全，因为它们依靠纯数学，而不是进行持续的经济激励活动来确保资金安全。除了密码学假设外，ZKR与基础L1 一样安全。这对于处理资产总值高的协议尤其重要。与ZKR相比， Optimistic  Rollup 具有强大的反网络效应：其安全性与锁定价值成比例地降低。实际上，需要控制资本上限(数千万美元的范围内)，才能安全地放如在单个Optimistic  Rollup中，才能保持对[对L1的高度合理攻击的抵抗](https://ethresear.ch/t/nearly-zero-cost-attack-scenario-on-optimistic-rollup/6336). 只要以太坊仍然是PoW链，就无法缓解。

**最终确定性**。 ZK Rollup 的最终确定性时间(分钟)短，因此支持资本快速退回到L1（L1：第一层，即以太坊自身网络）。 相反， Optimistic  Rollup [被迫在快速退出和资本效率退出之间进行选择](https://medium.com/starkware/the-optimistic-rollup-dilemma-c8fc470ca10c)，但不能两者兼有。大多数研究人员认为，OR至少需要一个星期的争议延迟时间。这对于与L1上的合约(至少将在最初)继续在生态系统中发挥重要作用的合约的互操作性非常重要。

**可编程性**  - 通过 Optimistic  Rollup 支持完全的EVM兼容性更加容易。通常认为OR方法是将现有以太坊智能合约引入L2 （L2 ：二层网络）的唯一可行方法。但是，这种情况即将改变。

## ZK Rollup 中的智能合约？

直到最近，在ZK Rollup 中支持任意用户定义的智能合约还是一项极富挑战性的任务。但是这些天来，在零知识证明领域中事情发展很快。 2020年带来了几项突破，最终使之成为可能：Matter Labs引入了Zinc编程语言和对SNARK友好的Zinc VM，并实现了[以太坊的递归PLONK证明验证](https://medium.com/matter-labs/zksync-v1-1-reddit-edition-recursion-up-to-3-000-tps-subscriptions-and-more-fea668b5b0ff)。这些技术的结合将推动zkSync上的实现智能合约。

## Zinc VM如何工作？

合约以Zinc编程语言编写并编译。编译器输出是双重的：

1. Zinc虚拟机的字节码。
2. 合约的SNARK验证密钥。

Zinc VM字节码+验证密钥可以完全无许可的方式部署到zkSync网络。合约将在L2 中被分配一个新地址。每当用户与该合约进行交互时，zkSync的验证程序将执行Zinc VM操作码并产生对交易有效性的零知识证明 – 友好的SNARK Zinc VM的特殊设计使其成为可能。然后将由 Rollup 块电路针对已部署的验证密钥来递归验证该证明。然后，以太坊上的zkSync智能合约验证区块证明，以授权状态转换，所有交易状态转换可以在一个区块快速的验证。

因此，zkSync上的Zinc智能合约继承了有效性证明的严格安全保证。



## 如何为zkSync编写智能合约？

目前，必须使用Zinc编程语言编写Zinc VM的智能合约。查看最新版本的[Zinc Book](https://zinc.zksync.io)，你将找到完整的入门指南和完整的开发人员参考。我们期待你在[Zinc Gitter聊天室](https://gitter.im/matter-labs/zinc)中提出的问题和反馈。

Zinc 目前处于封闭开发Beta版。如果你有兴趣为你的项目尝试，请[与我们联系](https://zksync.io/contact.html).

## Zinc与 Solidity/Vyper有何不同？我可以移植现有的源代码吗？

Zinc遵循简化的Rust语法，但它借鉴了Solidity的所有智能合约元素和结构体。任何有经验的Solidity/Vyper开发人员都可以在几天之内了解到它。

由于Zinc在结构体上与Solidity相同，因此可以轻松地将现有的Solidity代码转换为Zinc。主要的挑战是Zinc目前尚未完全图灵完备。这意味着：禁止递归和无限循环(有限循环是 OK 的)。

第二受欢迎的ETH智能合约语言Vyper也不是图灵完备的。因此，今天任何Vyper程序都可以同构转换为Zinc。这正是zkSync上Curve的工作方式：Matter Labs帮助Curve团队将现有的Curve合约重写为Zinc版本。它几乎逐行与原始来源相同。

尽管Zinc本身不是图灵完备的，但实际上任何在 Solidity 可以完成的工作而只需进行很少的修改即可在Zinc中完成，部分是因为大多数Defi应用程序的代码很少需要循环或递归，部分是因为图灵完整组件可以通过利用交易级别的递归来重新实现，即合约通过外部调用来调用自己的公共方法(在zkSync中仍然可以实现)。

此外我们还有更多的好消息：Matter Labs正在努力在不久的将来使Zinc 图灵完备。在此之前，我们很乐意为你的团队提供支持，以使现有的Solidity代码可移植。请[联系](https://zksync.io/contact.html).

## 可组合性如何？

zkSync L2网络中的所有合约都将能够以与以太坊主网上完全相同的方式原子地互相调用。

## 如何管理用户密钥？

在[Gitcoin赞助第7轮](https://gitcoin.co/blog/gitcoin-grants-round-7/)，zkSync被直接集成到结帐流程中，这需要信任Gitcoin网站。在此Demo中，zkSync私钥永远不会离开[connect.zksync.dev](https://connect.zksync.dev)的范围。这种类型的集成类似于Web2世界中的单点登录身份验证方案，该方案广泛用于Google/Apple/Facebook登录。这实际上意味着zkSync现在可以与任何以太坊钱包和任何数量的完全不受信任的dapp结合使用。

即使zkSync网站被黑，我们的方法也需要通过以太坊钱包另外签名每条消息的方式进行2 次验证。目前，该签名已由我们的服务器验证，尽管递归PLONK证明现在使我们可以将其直接集成到我们的ZKP电路中，而无需太多开销。

同时，我们正在与其他团队合作开发通用的以太坊L2签名标准，这将使围绕L2合约进行交互的用户体验更加令人愉悦。

## Zinc Alef 的局限性是什么？

测试网功能齐全，你可以编写智能合约，将它们部署到测试网，在本地测试它们，并生成智能合约执行的零知识证明。每笔交易都将导致zkSync测试网上的进行真实通证转移，这将反映在区块浏览器和钱包中。

但是，在此阶段，Zinc VM尚未集成到zkSync 核心中。 Zinc编程语言中的一些重要功能也可能会丢失。我们将根据社区的要求优先开发功能。




------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。