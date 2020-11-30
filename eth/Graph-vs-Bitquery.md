> * 来源：https://bitquery.io/blog/thegraph-and-bitquery 作者： BitQuery
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# The Graph 与 Bitquery 对比 – 解决区块链数据问题

区块链是“ [Erised镜子](https://harrypotter.fandom.com/wiki/Mirror_of_Erised)”，你可以始终在其中发现自己的兴趣。

> 译者注： Erised镜子：Erised 是 desire 的倒写，就像在镜子中一样，用来反映“人们内心最深切，最绝望的渴望” 

经济学家将区块链视为经济。技术专家将区块链视为构建去中心化应用程序的平台。企业家将其视为一种通过其产品获利的新方法，执法机构正在寻找区块链中的犯罪活动。

每个人都在以自己的方式看待区块链。但是，如果无法轻松，可靠地访问区块链数据，那么每个人都是盲目的。



## 区块链数据问题

区块链每天都会产生数百万笔交易和事件。因此，要分析区块链以获取有用的信息，你需要提取，存储和索引数据，然后提供一种有效的数据访问方式。这就产生了两个主要问题：

* **基础架构成本**：开发应用程序之前，你需要可靠地访问区块链数据。为此，你需要在基础架构上进行投资，这既昂贵又对开发人员和初创企业构成障碍。
* **可行动的洞察力**：为了提高区块链数据的价值，我们需要添加上下文。例如—区块链交易是标准交易还是DEX交易，是正常的DEX交易还是套利？有意义的区块链数据有助于企业提供可行动的洞察力来解决现实问题。

本文将研究[The Graph](https://thegraph.com/)和[Bitquery](https://bitquery.io/)之间的异同

## The Graph 概述

[The Graph](https://thegraph.com/)项目正在[Ethereum](https://ethereum.org/)和[IPFS](https://ipfs.io/)之上构建缓存层。使用The Graph项目，任何人都可以创建GraphQL schema(Subgraph)并根据他们的需要定义区块链数据API。 The Graph节点使用schema来提取数据并为其建立索引，并为你提供简单的GraphQL API进行访问。

> 关于 TheGraph 的使用，还可以阅读这篇文章：[使用 TheGraph 完善Web3 事件数据检索](https://learnblockchain.cn/article/1589)

### The Graph解决的问题

构建去中心化应用程序([Dapps](https://learnblockchain.cn/tags/DApp))的开发人员由于多种原因(例如为第三方服务创建API或向其Dapp用户提供更多数据以增强用户体验)，必须依赖中心化服务器来处理和索引其智能合约数据。但是，这会导致Dapps出现单点故障的风险。

The Graph项目通过创建一个去中心化的网络来为Dapps提供索引智能合约数据并消除了对中心化服务器的需求，从而解决了这个问题。

## Bitquery概述

Bitquery正在构建一个区块链数据引擎，通过该引擎可轻松访问多个区块链中的数据。使用[Bitquery的GraphQL API](https://explorer.bitquery.io/graphql),，你可以访问30多个区块链的任何类型的区块链数据。

### Bitquery解决的问题

开发人员、分析师、企业都出于各种原因需要区块链数据，例如分析网络、构建应用程序、调查犯罪等。
Bitquery给多个区块链提供了统一的数据访问API，以满足法规遵从性，游戏，分析，DEX交易等各个部门的任何区块链数据需求。

我们的统一schema允许开发人员快速扩展到多个区块链，并在单个API中从多个链中提取数据。

##  相同点

### GraphQL

Graph和Bitquery都广泛使用[GraphQL](https://graphql.org/)，并且使GraphQL API能够为最终用户提供自由灵活地查询区块链数据。关于区块链数据，请在此处阅读为什么[GraphQL比Rest API更好](https://bitquery.io/blog/blockchain-graphql).

### 降低基础设施成本

这两个项目都降低了最终用户的基础设施成本，并为他们提供了一个仅按使用量付费的模型。

## The Graph架构

The Graph包含通过[索引器（Indexers）和监护人（curator）](https://thegraph.com/docs/introduction#how-the-graph-works)进行去中心化。

索引器运行The  Graph节点并存储和索引Subgraph数据。监护人可帮助验证数据完整性并发信号通知新的有用 Subgraph。

The Graph旨在成为去中心化缓存层，以实现对以太坊和IPFS数据的快速，安全和可验证的访问。

![](https://img.learnblockchain.cn/2020/11/12/16051649958441.jpg)


## Bitquery架构

Bitquery在去中心化性方面追求性能和开发人员经验。Bitquery的中心化服务器处理来自30多个区块链的200 TB数据。

Bitquery专注于构建工具，以方便个人和企业探索、分析和使用区块链数据。

![](https://img.learnblockchain.cn/2020/11/12/16051650690990.jpg)

## The Graph和Bitquery之间的区别

The Graph和Bitquery之间有相当大的差异。让我们来看看一些明显的不同。

### 区块链支持

The Graph仅支持以太坊和IPFS。而 Bitquery 支持20多个区块链，并允许你使用GraphQL API查询其中的任何一个。

### API支持

The Graph允许你创建GraphQL schema(Subgraph)并将其部署在Graph节点上。通过创建schema 让开发人员可以将任何区块链数据作为API进行访问。

Bitquery遵循统一模式（schema）模型，这意味着它对所有支持的区块链都有类似的GraphQL模式。当前，Bitquery扩展了schema以实现对[blockchain数据API](https://bitquery.io/)的更广泛支持。但是，我们（Bitquery）正在构建FlexiGraph，该工具将允许任何人扩展Bitquery的schema以启用更复杂的区块链数据查询。

### 使用简单

使用Bitquery，你只需要学习GraphQL并使用Bitquery的模式来查询区块链。但是，对于The Graph，你还需要了解编码，因为如果你要查找的数据无法通过社区schema获得，则需要部署schema。

### 去中心化

The Graph是Graph节点的去中心化网络，Graph节点用于索引和管理以太坊数据。我们认为The Graph的去中心化区块链数据的使命目标新颖，我们对此表示赞赏。但是，Bitquery专注于构建API，以实现最快，可扩展的多区块链数据访问以及有用的查询工具。

### 性能

Bitquery的技术堆栈针对性能和可靠性进行了优化。此外，我们的中心化架构可帮助我们优化延迟和响应率以及其他性能指标。

The Graph去中心化方法使其成为用于数据访问的鲁棒网络。但是，The Graph仍在努力实现持续的性能交付。

### 开源的

The Graph是一个完全的[开源项目](https://github.com/graphprotocol)，开发人员可以根据需要验证代码库，对其进行分叉或集成。

我们Bitquery同样拥抱开源，并尽可能使我们的工具开源。例如，我们的[Explorer的前端](https://github.com/bitquery)完全是开源的，而我们的后端是闭源的。

但是，我们一直在重新审视我们的技术，机会成熟会开源任何模块。

### 数据可验证性

区块链上几乎所有数据都是金融数据。因此，数据可验证性非常重要。 The Graph网络的监护人负责验证数据的准确性。

在Bitquery中，我们建立了自动化系统来检查API的数据准确性。

### 定价

The Graph项目创建了GRT通证，该通证将驱动其网络上的定价。但是，GRT通证暂时不向公众开放。

Bitquery也处于公开测试阶段；因此，定价尚未向公众开放。但是，生产中的许多项目都使用Bitquery和The Graph。当前，这两个项目都提供免费的API。

##  结论

区块链数据充满了丰富的信息，等待分析师找到它。The Graph项目目标是为应用程序构建者去中心化访问以太坊和IPFS数据。但是，Bitquery中选择了一条不同的路径，为个人和企业释放了高度可靠的多区块链数据的真正潜力。

我们相信The Graph和Bitquery可以相互补充，并通过一些明显的交叉点来满足区块链数据市场的不同需求。我们旨在构建一套产品，以轻松探索，分析和使用个人和企业的区块链数据。 The Graph旨在建立一个去中心化的网络，以实现对以太坊和IPFS数据的可靠访问。



你也可能对此有兴趣：

* [以太坊DEX GraphQL API示例](https://bitquery.io/blog/ethereum-dex-graphql-api)
* [如何获取新创建的以太坊通证？](https://bitquery.io/blog/newly-created-etheruem-token)
* [如何研究以太坊地址？](https://bitquery.io/blog/investigate-ethereum-address)
* [用户获取以太坊智能合约事件的API](https://bitquery.io/blog/ethereum-events-api)
* [获取最新Uniswap交易对列表的API](https://bitquery.io/blog/uniswap-pool-api)
* [ETH2.0 Analytical Explorer、小部件和GraphQL API](https://bitquery.io/blog/eth2-explorer-api-widgets)
* [使用Bitquery Blockchain Explorer分析去中心化交易所](https://bitquery.io/blog/dex-blockchain-explorer)

#### 关于Bitquery

[**Bitquery**](https://bitquery.io/?source=blog&utm_medium=about_coinpath)是一组软件工具，它们以统一的方式跨区块链网络解析、索引、访问、搜索和使用信息。我们的产品有：

* **[Coinpath®](https://bitquery.io/products/coinpath?utm_source=blog) API**为超过24个区块链提供[区块链资金流分析](https://blog.bitquery.io/coinpath-blockchain-money-flow-apis)。借助Coinpath的API，你可以监控区块链交易，调查比特币洗钱等加密犯罪，并创建加密取证工具。阅读[此入门Coinpath®](https://blog.bitquery.io/coinpath-api-get-start).

* **[Digital Assets API](https://bitquery.io/products/digital_assets?utm_source=blog&utm_medium=about)**提供与所有主要加密货币，原生币（coin）和代币（token）有关的索引信息。

* **[DEX API](https://bitquery.io/products/dex?utm_source=blog&utm_medium=about)**提供有关不同DEX协议(如Uniswap，Kyber Network，Airswap，Matching Network等)的实时存款和交易，交易以及其他相关数据。

如果你对我们的产品有任何疑问，请在我们的[电讯频道](https://t.me/Bloxy_info)上提问，或通过[hello@bitquery.io](mailto：hello@bitquery.io)给我们发送电子邮件。另外，请订阅下面的新闻通讯，我们将为你提供最新的加密货币信息。


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。