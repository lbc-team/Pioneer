# 以太坊浏览器的新选择:EthVM

> * 原文链接：https://medium.com/myetherwallet/introducing-mews-ethereum-blockchain-explorer-ethvm-beta-78e5b849e2fc 作者 [MyEtherWallet](https://medium.com/@myetherwallet?source=post_page-----78e5b849e2fc----------------------)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1417)

EthVM是一款来自MyEtherWallet开发的[开源](https://github.com/EthVM/EthVM)浏览器（基于 Kafka，使用 JavaScript 及 Vue.js 开发)，包含前端和数据后台处理。



![1_CiqU342Ieh02aML3cnYjCw](https://img.learnblockchain.cn/pics/20200901213749.png)



MyEtherWallet（以下简称MEW)自创建以来的五年中，已从简单的[以太坊钱包](https://learnblockchain.cn/course/10)成长为一个平台，可支持用户在以太坊上做的几乎所有事情-各种各样的钱包访问方法，所有[ERC20代币](https://learnblockchain.cn/article/977)，合同交互，兑换 ，DApps和DeFi。

加密货币最好的事情之一就是交易的透明度：任何人，任何地方，任何时间都可以验证其资金的状况。 对于以太坊而言，凭借其智能合约功能，此类信息的可用性尤为重要，我们认为是时候建立一个探索此数据的绝佳工具了。 我们很高兴推出[EthVM](https://www.ethvm.com/)Beta 浏览器，这是MEW的开源以太坊数据处理器和浏览器。



## EthVM有什么不同



有几个以太坊浏览器，其中最流行的是Etherscan和Ethplorer，但与它们不同的是，[EthVm](https://www.ethvm.com/)是一个开源浏览器。 为什么这很重要？ 因为它与开发人员和用户的协作更透明。 相信这将帮助我们发现以前区块链浏览器尚未解决的场景和解决方案。



对贡献和协作更加开放也意味着我们有机会使EthVM成为最用户友好的浏览器。 与所有其他MEW产品和服务一样，我们希望EthVM易于使用、易于理解并且容易适应每个用户的个性化需求。 用户可能会发现有用的一些功能：



- EthVM不会像Etherscan 那样将“内部交易”和代币交易从主交易列表中分离出来，因为这经常导致用户的余额混乱

- 方便的侧栏导航突出显示最常用的功能

- 可以按时间范围查看从一小时到一年各种交易图表

- 清晰的账号拥有的 ERC20 代币和 NFTs 代币

  ![1_g6oZwJi-8zAYnMPBmy4b4w](https://img.learnblockchain.cn/pics/20200901213943.png)



![1_awEvvvjaiaQBH75tsayOxg](https://img.learnblockchain.cn/pics/20200901214005.png)



## EthVM 涉及的技术



EthVM是一个开源[以太坊](https://www.ethereum.org/)区块链数据处理和分析引擎，同时也是一个客户端区块链浏览器，使用[SSPL许可](https://www.mongodb.com/licensing/server-side-public-license)（ GNU Affero许可v3的一个小变体），并且使用不同语言混合编写。



我们的核心基础架构基于语言：

- [TypeScript](https://www.typescriptlang.org/) (区块链浏览器)
- Javascript (API/数据处理)



使用了以下流行框架：

- [VueJs](https://vuejs.org/)
- [Apollo Graphql](https://www.apollographql.com/)
- [Serverless](https://www.serverless.com/)
- [DynamoDB](https://aws.amazon.com/dynamodb/)



[GitHub 地址](https://github.com/EthVM/EthVM)，我们的区块浏览器目前处于Beta版。 你可以在[www.ethvm.com](https://www.ethvm.com/)上进行实时检查，并在[此处](https://medium.com/myetherwallet/introducing-mews-ethereum)上了解有关它的更多信息。



## 共同创建最好的区块链浏览器



EthVM处于Beta测试阶段，这意味着它仍然有些粗糙，但现在正是你提供反馈并影响最终产品的形态和功能的最佳时机。



在接下来的几周中，随着我们为完整版本的EthVM做好准备，你的意见非常重要。 错误，界面故障，导航按钮，颜色和网站复制-告诉我们所有内容，以便我们进行修复和改进。



我们正在为你创建工具，因此请帮助我们实现你所需的功能！ 浏览下[EthVM](https://www.ethvm.com/)，看看你喜欢什么以及可以使用哪些改进； 写入[support@ethvm.com]（mailto：support@ethvm.com)以获得错误报告和功能请求，在[Twitter](https://twitter.com/Eth_VM)上标记EthVM，加入EthVM [subreddit] (https://www.reddit.com/r/ethvm/)，或在[Github](https://github.com/EthVM/EthVM)提交更新并做出贡献。

*本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。*

