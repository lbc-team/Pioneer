# Solana MEV: 介绍

*注：Solana 上的 MEV 格局正在迅速变化。本页面将定期更新新进展。*

## 要点

本文旨在提供对 Solana 上 MEV 运作方式的基本理解。简而言之：

- Solana 上的 MEV 并未消失。
- 并非所有的 MEV 都是不好的。
- 在 DEX 流动性场所结构中，不仅仅是 AMM，盈利的抢先交易是可能的。
- Solana 的连续区块生产和缺乏协议内存池改变了链的默认行为和社会动态。
- 其他人可能会分叉或以其他方式复制 Jito 的协议外存储池，以提取更多的 MEV，但从技术和社会角度来看都很困难。
- 许多验证者支持决定移除 Jito 内存池，放弃三明治交易收入，而选择 Solana 的长期增长和健康。

## 介绍

在[权益证明网络](https://www.helius.dev/blog/proof-of-history-proof-of-stake-proof-of-work-explained#what’s-proof-of-stake)中，当你被分配为某个区块的领导者时，你有权利确定你所分配的区块的内容。最大可提取价值（MEV）指的是从给定区块中添加、删除或重新排序交易中获得的任何价值。

随着 Solana 上的活动和普遍兴趣的增加，MEV 正在成为一个[越来越受关注的话题](https://x.com/aajxbt/status/1765512478316793865?s=20) 。2024 年 1 月 10 日，一名搜索者向验证者打赏了 890 SOL，这是 Jito 历史上最大的小费之一：

![img](https://img.learnblockchain.cn/attachments/migrate/1.png)

[来源](https://explorer.jito.wtf/bundle/7d2f02a0542fd3950d90c9bd8ca84d233e28f0298d9f002c7e3cc0959b72b24f)

截至 2024 年 3 月 12 日的一周内，Solana 验证者因在 Solana 上的区块空间中获得 Jito 小费而赚取了超过 700 万美元。今天，超过 50%的 Solana 交易是失败的套利交易（垃圾邮件），由于交易成本非常低，这些交易具有正期望值。交易者通过长期进行这些类型的交易来获利。

## Solana 的 MEV 结构

### 概述

[Solana 上的 MEV](https://www.umbraresearch.xyz/writings/mev-on-solana) 与其他链看起来不同，对搜索者有很强的激励，使其运行自己的节点和/或与高抵押节点集成和共同定位，以获取链的最新视图（因为 Solana 对延迟敏感）。这是由于 Solana 的连续状态更新和抵押权重机制，例如 [Turbine](https://www.helius.dev/blog/turbine-block-propagation-on-solana)（用于读取更新状态）和抵押权重的 QoS（用于写入新状态）。

最显著的区别之一是 Solana 没有像以太坊等其他链上常见的传统内存池。

Solana 的连续区块生产，没有任何附加的或协议外的拍卖/机制，减少了某些类型的 MEV（特别是抢先交易）的表面积。

### MEV 交易

MEV 机会出现在不同的类别中。以下是当今 Solana 上存在的一些常见类型的 MEV 交易：

- **NFT 铸造**：NFT 铸造的 MEV 发生在参与者试图在公共铸造活动中获得稀有或有价值的非同质化代币（NFT）时（既包括“蓝筹” NFT，也包括长尾 NFT）。
  NFT 铸造活动的性质表现为突然增加，x-1 区块没有 NFT MEV 机会，而 x 区块有一个大的 MEV 机会。这里的区块 x 指的是铸造开始的区块。
  这些 NFT 铸造/IDO 机制是导致 Solana 在 2021/2022 年暂时停止区块生产的大规模拥堵的第一批来源之一。
- **清算**：当借款人未能维持其贷款所需的[抵押率](https://www.investopedia.com/terms/c/collateralization.asp)时，他们的头寸就有资格进行清算。搜索者扫描区块链以寻找这种未充分抵押的头寸，并执行清算以偿还部分或全部债务，并获得部分抵押作为奖励。
  清算发生在利用代币和 NFT 作为抵押品的协议中。清算对于协议保持健康并且对于更广泛的生态系统都是有益的。
- **套利**：套利涉及利用同一资产在不同市场或平台上的价格差异。这些套利机会存在于链内、链间以及中心化交易所和去中心化交易所之间。
  链内套利目前是唯一保证原子性的套利形式，因为两条腿都在同一链上执行，由于链内套利需要额外的信任假设。
  套利保持价格稳定，只要它不导致有毒订单流量的增加。

### Jito

[Jito](https://www.jito.wtf/) 是一个用于部分区块的协议外区块空间拍卖，不同于 MEV-boost，后者构建完整的区块（Jito 和 mev-geth 在精神上相似，但在实现上有很大不同）。Jito 提供了一组名为 [bundles](https://jito-labs.gitbook.io/mev/searcher-resources/bundles) 的交易的离线包含保证。bundles 被顺序执行并具有原子性——要么全部执行，要么全部不执行。搜索者提交具有保证的 bundles，如果他们赢得拍卖并支付最低的 10,000 lamports 小费，则可以在链上执行。Jito 小费存在于协议外，并且与协议内的 [priority fees](https://www.helius.dev/blog/priority-fees-understanding-solanas-transaction-fee-mechanics) 是分开的。

这种方法的目标是通过在链下运行拍卖，仅通过一个保证捆绑将拍卖的唯一赢家发布到区块中，从而减少垃圾信息并提高Solana的计算资源效率。
搜索者可以使用 bundle 来实现以下一个或两个属性：快速、有保证的包含和出价进行抢先/反抢先机会。
这一点尤其重要，因为网络的大部分计算资源目前都被不成功的交易所消耗。

### 内存池

与以太坊不同，Solana 没有原生的协议内存池。Jito 的[现已弃用的](https://x.com/jito_labs/status/1766228889888514501?s=20)内存池服务有效地创建了一个[规范的协议外内存池](https://twitter.com/dubbel06/status/1766337915448099294) ，因为约 65% 的验证者运行 Jito-Solana 客户端（而不是原生的 Solana-Labs 客户端）。

在运行时，交易将驻留在 Jito 的伪内存池中 200 毫秒。在此期间，搜索者可以对抢先/反抢先待处理交易的机会进行出价，支付最高费用的 bundles 将被转发给验证者执行。
三明治交易占据了 MEV 收入的相当大一部分，以小费支付给验证者为度量。

![img](https://img.learnblockchain.cn/attachments/migrate/2.png)

[Jito 的内存池服务（使三明治交易成为可能）于 3 月 8 日关闭](https://explorer.jito.wtf/)

没有人喜欢谈论三明治交易（尤其是在以太坊上），因为它对最终交易者造成了严重的负面外部性影响——这些用户以最糟糕的价格成交。据 EigenPhi 称，仅在过去 30 天内，就有约 2400 万美元的利润来自于以太坊上的三明治交易。
当用户设置最大滑点（在发送交易之前同意某个值周围的变化量）时，他们几乎总是以那个价格成交。
换句话说，用户的预期滑点几乎总是等于他们的最大滑点，如果订单被成交。
Jito 搜索者仍然可以提交其他类型的 MEV 交易捆绑，这些交易不依赖于 MempoolStream，例如套利和清算交易（这需要观察区块中的交易，并在下一个 Jito 拍卖中抓住机会）。

### 供应链

供应链的当前以太坊区块构建供应链如下所示：

![img](https://img.learnblockchain.cn/attachments/migrate/3.png)

[Flashbots](https://docs.flashbots.net/flashbots-mev-boost/introduction)

对于运行 Jito-Solana 客户端的验证者，Solana 的区块构建供应链如下所示：

![img](https://img.learnblockchain.cn/attachments/migrate/4.jpeg)

- **传入交易**：交易待执行的当前预定状态。这可以来自 RPC、其他验证者、私人订单流或其他来源。
- **中继器**：Solana 上的中继器与以太坊不同。在以太坊上，中继器是连接区块构建者和提议者的受信任实体（构建者信任中继器不修改他们的区块）。
  在 Solana 上，中继器负责中继传入交易，执行有限的 TPU 操作，如数据包去重和签名验证。中继器将数据包转发到区块引擎和验证者。
  在以太坊上等效物是不必要的，因为以太坊有内存池，而 Solana 没有。

中继器逻辑是[开源的](https://github.com/jito-foundation/jito-relayer/tree/master) ，允许任何人运行自己的中继器（Jito 作为公共产品运行中继器的实例）。其他已知的 Solana 网络参与者也运行自己的中继器。

- **区块引擎**：区块引擎模拟交易组合并运行链下区块空间拍卖。MEV 最大化的捆绑交易然后转发给运行 Jito-Solana 客户端的领导者。
- **搜索者**：搜索者通过将自己的交易插入到给定区块中来寻求利用价格差异和其他机会。他们可以利用 Jito 的 [ShredStream](https://jito-labs.gitbook.io/mev/searcher-services/shredstream)（以及先前的 MempoolStream）等来源或者获取他们自己的最新信息。
- **验证者**：验证者构建和生成区块。Jito-Solana 区块在前 80%的区块中，调度程序保留 3M CUs 用于通过 Jito 路由的交易。

这些参与方不一定是独立实体，因为实体可以是垂直整合的。如前所述，验证者对其区块拥有完全的权限。
验证者们可以通过插入、重新排序和审查给定区块的交易来寻找经济机会，当他们是领导者时。

搜索者也可以通过 RPC 方法（标准的协议内路由）提交交易，无论领导者是否运行 Jito-Solana。由于 Solana 的相对[低费用](https://www.helius.dev/blog/solana-fees-in-theory-and-practice)和调度程序的不确定性，垃圾邮件式的交易仍然是捕获 MEV 机会的常见方法。某些 MEV 机会可能存在的时间比预期的长，大约为一到十个区块。

### 参与者之间的 MEV 分配

虽然 Solana 能够加快交易执行速度并减少某些类型的 MEV 的可能性，但它可能会加剧潜在的由延迟驱动的集中化，验证者和搜索者寻求共同定位他们的基础设施以获得竞争优势。
我们远未达到任何竞争性、稳定的均衡状态，基础设施和相关机制正在迅速变化。

‍

![img](https://img.learnblockchain.cn/attachments/migrate/5.png)

https://x.com/aeyakovenko/status/1741298436035776681?s=20

在一个区块时间低于 200 毫秒的世界中，这为具有基础设施和专业知识优化系统的复杂参与者提供了比较优势（可以从高频交易中获得许多经验教训）。
到目前为止，以太坊已偏离了这种均衡状态，创造了超协议解决方案，以使搜索者有竞争力的机会（至少在以太坊当前的用户体验、价格、寡头式区块构建制度和额外的超协议信任假设方面）。

## 减少 MEV 的表面积

通用超协议机制正在进入协议，以减少链上的 MEV 表面积。这些机制包括：

1. **RFQ 系统**：[RFQ（询价）系统](https://messari.io/report/hashflow-certainty-in-execution) （例如 [Hashflow](https://www.hashflow.com/)）已经开始进入 Solana，并且在生态系统中越来越受欢迎（跨生态系统的累积交易量超过 100 亿美元）。
   订单由专业市场制造商（Wintermute、Jump Crypto、GSR、LedgerPrime）履行，而不是通过链上 AMM 或订单簿，基于签名的定价允许进行链下计算。
   这有效地将所有价格发现转移到链下，只有填充的转账交易会落在链上。
2. **MEV 保护的 RPC 端点**：这些端点允许用户从其订单流中获得部分收益。搜索者出价以回溯您的交易，并出价相关的回扣，这些回扣将支付给用户（减去任何费用）。
   这些端点通常是通过信任运行端点的对手方来管理，以确保没有前置交易或夹击发生。

MEV 的减轻/重新分配机制存在于用户从其订单流中捕获一些价值到将价格发现拍卖和相关机制转移到链下的某种组合中。
这些机制涉及加密属性之间的权衡，如抗审查、可审计性和无信任性。

## 结论

本文介绍了 Solana 上 MEV 供应链的主要参与者及其最新发展。此外，本文还介绍了 Solana 上常见的 MEV 形式和 MEV 交易的解剖。

已经投入了大量资源来研究和研究不同的 MEV 减轻/重新分配机制的影响。以太坊已经在基础设施上投入了大量资源，导致了 [Flashbots](https://www.flashbots.net/) 的出现，该项目旨在提供对 MEV 机会的民主化访问，但也对链上带来了其他设计和可以说是负面的外部性。

Solana 有机会探索 MEV 和区块生产供应链前沿的新模型。

‍

感谢 [Dubbel06](https://twitter.com/dubbel06)（Overclock）、[Lucas](https://twitter.com/buffalu__)（Jito）和 [Eugene](https://twitter.com/0xShitTrader)（Ellipsis）的反馈和审阅。
