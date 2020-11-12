> * 来源：https://bitquery.io/blog/thegraph-and-bitquery 




# The Graph vs Bitquery – Solving Blockchain Data Problems


Blockchains are “[Mirror of Erised](https://harrypotter.fandom.com/wiki/Mirror_of_Erised).” You will always find your interests in them.

Economist sees blockchains as economies. Technologist sees blockchains as platforms to build Decentralized applications. Entrepreneurs see them as a new way to monetize their products, and law enforcement agencies are looking for criminal activities in the blockchain.

Everyone is looking at blockchains in their way. However, without easy and reliable access to blockchain data, everyone is blind.


## Table of Contents 

* [Blockchain data problem](#Blockchain_data_problem "Blockchain data problem")
* [The Graph Overview](#The_Graph_Overview "The Graph Overview")
    * [Problem Addressed by The Graph](#Problem_Addressed_by_The_Graph "Problem Addressed by The Graph")
* [Bitquery Overview](#Bitquery_Overview "Bitquery Overview")
    * [Problem Addressed by Bitquery](#Problem_Addressed_by_Bitquery "Problem Addressed by Bitquery")
* [Common Things](#Common_Things "Common Things")
    * [GraphQL](#GraphQL "GraphQL")
    * [Removing Infrastructure Cost](#Removing_Infrastructure_Cost "Removing Infrastructure Cost")
* [The Graph Architecture](#The_Graph_Architecture "The Graph Architecture")
* [Bitquery Architecture](#Bitquery_Architecture "Bitquery Architecture")
* [Differences between The Graph and Bitquery](#Differences_between_The_Graph_and_Bitquery "Differences between The Graph and Bitquery")
    * [Blockchain Support](#Blockchain_Support "Blockchain Support")
    * [API Support](#API_Support "API Support")
    * [Ease of Use](#Ease_of_Use "Ease of Use")
    * [Decentralization](#Decentralization "Decentralization")
    * [Performace](#Performace "Performace")
    * [Open Source](#Open_Source "Open Source")
    * [Data Verifiability](#Data_Verifiability "Data Verifiability")
    * [Pricing](#Pricing "Pricing")
* [Conclusion](#Conclusion "Conclusion")


## Blockchain data problem

Blockchains emit millions of transactions and events every day. Therefore, to analyze blockchains for useful information, you need to extract, store, and index data and then provide an efficient way to access it. This creates two main problems:

* **Infrastructure cost **— Before developing an application, you need reliable access to blockchain data. For this, you need to invest in the infrastructure, which is costly and a barrier for developers and startups.
* **Actionable insights **— To drive blockchain data’s value, we need to add context. For example — Is a blockchain transaction is a standard transaction or a DEX trade. Is it normal DEX trade or an arbitrage? Meaningful blockchain data is helpful for businesses in providing actionable insights to solve real-world problems.

This article will look at similarities and differences between [The Graph](https://thegraph.com/) and [Bitquery](https://bitquery.io/).

## The Graph Overview

[The Graph](https://thegraph.com/) project is building a caching layer on top of [Ethereum](https://ethereum.org/) and [IPFS](https://ipfs.io/). Using The Graph project, anyone can create a GraphQL schema (Subgraph) and define blockchain data APIs according to their need. The Graph nodes use that schema to extract, and index that data and provide you simple GraphQL APIs to access it.

### Problem Addressed by The Graph

Developers building Decentralized applications (Dapps) have to depend on centralized servers to process and index their smart contract data for multiple reasons, such as creating APIs for third party services or providing more data to their Dapp users to enhance UX. However, this creates a risk of a single point of failure for Dapps. 

The Graph project address this problem by creating a decentralized network to access indexed smart contract data for Dapps and removing the need for centralized servers.

## Bitquery Overview

Bitquery is building a blockchain data engine, which provides simple access to data across multiple blockchains. Using [Bitquery’s GraphQL APIs](https://explorer.bitquery.io/graphql), you can access any type of blockchain data for more than 30 blockchains.

### Problem Addressed by Bitquery

Developers, analysts, businesses all need blockchain data for various reasons, such as analyzing the network, building applications, investigating crimes, etc. 
Bitquery provides unified APIs for access data across multiple blockchains to fulfill any blockchain data needs for various sectors such as Compliance, Gaming, Analytics, DEX trading, etc.

Our Unified schema allows developers to quickly scale to multiple blockchains and pull data from multiple chains in a single API.

## Common Things

### GraphQL

Both, The Graph and Bitquery use [GraphQL](https://graphql.org/) extensively and enable GraphQL APIs to provide freedom to end-users to query blockchain data flexibly. When it comes to blockchain data, read here why [GraphQL is better than Rest APIs](https://bitquery.io/blog/blockchain-graphql).

### Removing Infrastructure Cost

Both projects remove infrastructure costs for end-users and provide them with a model where they pay only for what they use.

## The Graph Architecture

The Graph embraces decentralization through an army of [Indexers and curators](https://thegraph.com/docs/introduction#how-the-graph-works).

Indexers run Graph nodes and store and index Subgraph data. And Curators help verify data integrity and signaling new useful subgraphs.

The Graph aims to become a decentralized caching layer to enable fast, secure, and verifiable access to Ethereum and IPFS data.

![](https://img.learnblockchain.cn/2020/11/12/16051649958441.jpg)


## Bitquery Architecture

Bitquery embraces performance and developer experience over decentralization. Our centralized servers process more than 200 terabytes of data from more than 30 blockchains.

We are focus on building tools to explore, analyze, and consume blockchain data easily for individuals and businesses.

![](https://img.learnblockchain.cn/2020/11/12/16051650690990.jpg)


## Differences between The Graph and Bitquery

There are considerable differences between The Graph and Bitquery. Let’ see some of the significant differences.

### Blockchain Support

The Graph only supports Etheruem and IPFS. However, Bitquery supports more than 20 blockchains and allows you to query any of them using GraphQL APIs.

### API Support

The Graph allows you to create your GraphQL schema(Subgraph) and deploy it on Graph nodes. Creating your schema enables developers to access any blockchain data as APIs.

Bitquery follows the Unified schema model, meaning it has a similar GraphQL schema for all blockchains it support. Currently, Bitquery extends this schema to enable broader support of [blockchain data APIs](https://bitquery.io/). However, we are building FlexiGraph, a tool that will allow anyone to extend our schema to enable more complex blockchain data queries.

### Ease of Use

With Bitquery, you only need to learn GraphQL and use our schema to query the blockchain. However, with The Graph, you also need to understand coding because you need to deploy your schema if the data you are looking not available through community schema.

### Decentralization

The Graph is a decentralized network of Graph nodes to index and curate Ethereum data. We think The Graph’s mission to decentralize blockchain data access a novel goal, and we appreciate it. However, Bitquery focuses on building APIs to enable the fastest, scalable multi-blockchain data access, coupled with useful query tooling.

### Performace

Bitquery’s technology stack is optimized for performance and reliability. Besides, our centralized architecture helps us optimizing latency and response rate and other performance metrics.

The Graph decentralization approach makes it a robust network for data access. However, The Graph is still working to achieve continuous performance delivery.

### Open Source

The Graph is a fully [open source project](https://github.com/graphprotocol). Developers can verify the codebase, fork it, or integrate it according to their needs.

We at Bitquery also embrace open source development and make our tools open source as much as we can. For example, our [Explorer’s front end](https://github.com/bitquery) is entirely open-source, but our backend is closed source.

However, we always revisit our technology on time and see if there is an opportunity to open source any module.

### Data Verifiability

Almost all the data on blockchains is financial data; therefore, data verifiability is very important. The Graph network has curators, who are responsible for verifying data accuracy.

At Bitquery, we have built automated systems to check data accuracy for our APIs.

### Pricing

The Graph project created the GRT token, which will drive the pricing on its network. However, The GRT token is not available to the public for now.

Bitquery is also at the open beta stage; therefore, pricing not yet open to the public. However, Bitquery and The Graph are used by many projects in production. Currently, both projects provide their APIs are free.

## Conclusion

Blockchain data is filled with rich information, waiting for analysts to find it. We embrace TheGraph project’s aims to decentralize the Ethereum and IPFS data access for application builders. However, we at Bitquery choose a different path and unlock the true potential of highly reliable multi-blockchain data for individuals and businesses.

We believe The Graph and Bitquery complement each other and address different needs in the blockchain data market with some apparent intersections. We aim to build a suite of products to easily explore, analyze, and consume blockchain data for individuals and businesses. And The Graph aims to build a decentralized network to enable reliable access to Ethereum and IPFS data.

Let us know what similarities and differences you see between The Graph and Bitquery in the comment section.

You might also be interested in:

* [Ethereum DEX GraphQL APIs with Examples](https://bitquery.io/blog/ethereum-dex-graphql-api)
* [How to get newly created Ethereum Tokens?](https://bitquery.io/blog/newly-created-etheruem-token)
* [How to investigate an Ethereum address?](https://bitquery.io/blog/investigate-ethereum-address)
* [API to get Ethereum Smart Contract Events](https://bitquery.io/blog/ethereum-events-api)
* [Simple APIs to get Latest Uniswap Pair Listing](https://bitquery.io/blog/uniswap-pool-api)
* [ETH2.0 Analytical Explorer, Widgets, and GraphQL APIs](https://bitquery.io/blog/eth2-explorer-api-widgets)
* [Analyzing Decentralized Exchange using Bitquery Blockchain Explorer](https://bitquery.io/blog/dex-blockchain-explorer)

#### About Bitquery

[**Bitquery**](https://bitquery.io/?source=blog&utm_medium=about_coinpath) is a set of software tools that parse, index, access, search, and use information across blockchain networks in a unified way. Our products are:

* **[Coinpath®](https://bitquery.io/products/coinpath?utm_source=blog) APIs** provide [blockchain money flow analysis](https://blog.bitquery.io/coinpath-blockchain-money-flow-apis) for more than 24 blockchains. With Coinpath’s APIs, you can monitor blockchain transactions, investigate crypto crimes such as bitcoin money laundering, and create crypto forensics tools. Read [this to get started with Coinpath®](https://blog.bitquery.io/coinpath-api-get-start).

* **[Digital Assets API](https://bitquery.io/products/digital_assets?utm_source=blog&utm_medium=about)** provides index information related to all major cryptocurrencies, coins, and tokens.

* **[DEX API](https://bitquery.io/products/dex?utm_source=blog&utm_medium=about)** provides real-time deposits and transactions, trades, and other related data on different DEX protocols like Uniswap, Kyber Network, Airswap, Matching Network, etc.

If you have any questions about our products, ask them on our [Telegram channel](https://t.me/Bloxy_info) or email us at [hello@bitquery.io](mailto:hello@bitquery.io). Also, subscribe to our newsletter below, we will keep you updated with the latest in the cryptocurrency world.


