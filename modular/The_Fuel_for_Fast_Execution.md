> * 原文链接： https://rainandcoffee.substack.com/p/the-fuel-for-fast-execution
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# Fuel: 专注模块化的执行层

> 本文接收了什么是模块化执行层，Fuel  如何通过 UTXO 的设计来实现快速平行的执行层。



## 序言

Fuel 是我们遇到的最有趣的执行环境，我们（Maven11）很荣幸成为Fuel的支持者。Fuel 将自己定位为模块化未来的最快执行层，大多数区块链现在都意识到他们必须朝着这个方向发展，以提供全球使用所需的扩展性。此外，由于不复制 EVM，它充分利用了模块化为开发人员提供的灵活性。在本文中，我们将介绍Fuel的独特之处，以及他们如何努力为用户、开发者和区块生产者提供最佳体验。如果你有兴趣在Fuel上进行开发，请随时联系我们，我们很乐意听到你的意见。

## 执行层简介

在我们的[上一篇](https://learnblockchain.cn/article/6141)中，我们详细讨论了 Celestia 的独特功能。我们还谈到了各种模块协议及其架构。因此，在这一篇文章中，我们将探讨一种不同类型的模块化协议。这不是一个用于构建网络的模块化数据可用层，而是一个模块化执行层。

那么什么是执行层呢？执行层是纯粹处理交易执行的链，同时将区块链的其他功能委托给其他链，如共识/数据可用性和结算层。执行层的一个例子是目前以太坊上的 Rollup 执行，如：Arbitrum 和 ZKSync。那么他们与结算层有什么不同呢？结算层也是一个执行环境，但其上有信任最小化的桥接合约， Rollup 使用这些合约来实现统一的流动性。这些 Rollup 项目也向结算层发送它们的各种证明和区块头，结算层则充当 Rollup 项目的“真相来源”。

如果你不确定什么是Rollup，那么让我们来快速分解一下。Rollup是一种在主 L1（大多数情况下是以太坊）链外运行的扩容解决方案。这种解决方案在链外执行交易，这意味着它不必争夺宝贵的区块空间。执行交易后，它将向 L1 发送一批交易数据或执行证明，并在 L1 进行结算。正因为如此，第二层扩容解决方案同样由第一层安全性提供保护，因为DA层或结算层充当了 Rollup 的真相来源。

![img](https://img.learnblockchain.cn/2023/07/18/25859.jpeg)



> 以太坊上的乐观和ZK Rollup

Rollups 主要有两种不同的类型（然而也有其他类型的Rollups）。这两种是ZK rollups 和 Optimistic rollups。**Optimistic rollups**默认交易是有效的（因此被称为Optimistic）。但是，如果出现恶意或错误的交易，则会生成欺诈证明并发送到L1，以便将其回滚，同时交易提出者会被惩罚。**零知识（ZK） Rollup **也在链外运行复杂计算，通过一个电路提供有效性证明（snarks、starks、plonks、kimchi等）。该有效性证明被发布到L1，以显示 Rollup 正确执行了交易，而不实际发布交易数据本身。

### 模块化执行层

既然我们已经明白了什么是执行层，以及当前各种 Rollup 扩容解决方案是如何工作的，让我们来看看什么是[模块化执行层](https://twitter.com/fuellabs_/status/1518963774627008512)。Fuel 将模块化执行层定义为**为模块化区块链堆栈设计的可验证计算系统**。到底这是什么意思呢？这意味着 Fuel 是一个区块链执行环境，能够利用模块化区块链实现数据可用性。此外，这句话中的可验证计算指的是可证明欺诈或有效性证明。

![img](https://img.learnblockchain.cn/2023/07/18/48869.jpeg)



>  请注意，DA 见证（attestation）指的是DA发送到结算层上的合约的证明 - 如通过 Gravity 桥的Celestiums，或启用了ICS的链的IBC。

那么，**为什么 Fuel 和许多其他公司一样，正在摒弃单体区块链（monolithic）设计原则呢**？



在单体区块链严重拥堵时，L2s 或 Rollup 交易成本会上升到离谱的程度。最近发生的例子之一是 Yuga Labs 出售 Otherside 土地期间，由于必须在单体链上结算交易，L2s 的交易成本甚至飙升至两位数。这只是 Fuel 希望摆脱单体区块链设计的原因之一，在单体区块链设计中，共识、数据可用性和执行是结合在一起的。Fuel 希望提供的执行层可基于以 Rollup 为中心的路线图的以太坊和其他模块化协议（如Celestia）的数据可用性和共识来实现。由于不受单体区块链的阻碍，Fuel 能够在执行层实现专业化，从而极大地提高执行能力。Fuel 的突出之处在于，Fuel正在通过自己独特的虚拟机、交易设计和特定领域的语言，努力提供快速的吞吐量和复杂的智能合约。他们通过优化区块链的未来来实现这一点，在未来，数据可用性能力不再是瓶颈。

##  Fuel

如前所述，Fuel 一直是以太坊的二层协议，但同时也将自己定位为未来模块化的执行层。Fuel的战略是提供高吞吐量的以太坊式可组合智能合约交易，以成为首选之地。

他们仍然是一个乐观 Rollup 项目。然而，与现有的乐观 Rollup 相比，Fuel有一个非常独特的设计。这种独特性来自于 Fuel 基于 UTXO 的设计，这种设计允许并行交易执行，我们稍后将对此进行更深入的探讨。Fuel还将实现运营节点接受非 ETH 代币作为费用的能力，如果节点愿意接受的话。这是通过允许节点建立非主要mempools来实现的，在mempools中，费用是以节点希望接收的代币支付的。

![img](https://img.learnblockchain.cn/2023/07/18/72007.jpeg)

> 不同的 mempool 由 Fue l节点运营，Fuel 节点可以选择接受最终用户支付的各种代币作为费用

让我们深入分析一下 Fuel 是如何运作的。

## 乐观 Rollup

Rollup 的工作方式是允许任何人在链外构建区块，然后将其作为calldata提交给以太坊（calldata严重缺乏，因此开发了blob交易，并最终转向分片）。这是通过一个 Rollup 合约来实现的，该合约会跟踪以太坊上 Rollup 的区块头。在乐观 Rollup 的情况下，可以提交欺诈证明并回滚链，销毁质押的金额并奖励欺诈证明人。

现在，让我们来看看 Rollup 节点是如何在链外以及与以太坊共生下运行的情况。

![img](https://img.learnblockchain.cn/2023/07/18/97908.png)

>  Fuel 运营节点

Rollup 用户将交易发送到 Fuel 节点，这是连接 Rollup 端点的 dApps 自动完成。然后，客户端/序列器会将交易合并成一个Fuel区块，然后发送到以太坊，由以太坊确认该区块。客户端还处理来自以太坊的存款，这就是我之前所说的桥接合约，它实现了 Rollup 和以太坊之间的统一流动性。

**那么Fuel的欺诈证明是如何确保没有恶意行为的呢？**

一旦欺诈证明被提交给 Rollup 合约，它就需要被验证，以检查其格式是否正确。这样做是为了确保证明不是恶意发送的。因为如果是这样的话，一个有效的区块可能会因为不合法的欺诈证明而被撤销。证明验证器合约验证欺诈证明的格式是否正确和有效，如果是，则对其进行处理，以删除违规的 Rollup 块。

这种方案是独一无二的，因为它不需要状态序列化。这是在每次交易或区块之后计算状态的[默克尔根](https://learnblockchain.cn/tags/%E9%BB%98%E5%85%8B%E5%B0%94%E6%A0%91)（我们在上一篇文章中介绍过）。由于Fuel使用了UTXOs，这意味着交易不需要按顺序执行。这是因为你可以在最后简单地检查计算的每一个输入是否是之前未使用的和唯一的。因此，交易可以一次性完成，无需排序。

## 基于UTXO的交易和账户设计

UTXO代表未花费的交易输出，是比特币使用的交易数据模型。UTXO代表一个账户允许另一个账户使用的N个币/代币数量。UTXO使用公钥来识别和转账持有的所有权。UTXO地址由一个公钥格式化，该公钥有一个相关的私钥，允许在该特定账户中使用。这样就可以拥有原子数量的代币或状态，并可由花费者控制。

![img](https://img.learnblockchain.cn/2023/07/18/4534.png)

> 比特币的UTXO模型

在简化模型中，每个UTXO有两个字段：1. 币的数量，2. 定义所有者的脚本哈希。合约UTXO有四个字段：1. Coin数量，2. 合约ID，3. 合约代码哈希 4. 存储根--这与普通的基于账户的合约非常相似。

请记住，与非合约UTXO不同，合约没有类似于以太坊合约的定义所有者。由于每个合约UTXO除了其UTXO ID外，还通过其合约ID进行唯一标识，因此每个合约都可以在单个区块中多次使用，只需通过合约ID进行引用即可。

使用UTXO的原因是，它可以实现一种令人难以置信的强大功能，即并行交易执行。这是因为交易没有相互依赖性，因此可以相互并行执行。虽然以前也尝试过这种方法，但它依赖于用户在交易执行完毕后进行签名，这就造成了争用。然而，通过不强迫用户签署交易的影响，可以实现更精简的执行。由于UTXO交易的原子性定义了交易的每个状态区域，它允许Fuel上的节点确定哪些交易没有相互依赖性，从而并行执行它们。

由于没有其他乐观Layer2使用基于UTXO的交易系统，这显然让Fuel变得极为独特。但这也是它们的优势所在，因为它允许并行的交易验证，与基于账户的 Rollup 相比，这应该会提高可扩展性。

那么，为什么使用基于UTXO的交易系统能够提供如此惊人的可扩展性呢？这是因为每笔交易可以花费和处理多个输入和输出。

![img](https://img.learnblockchain.cn/2023/07/18/91687.png)



>  由于使用了基于UTXO的交易模型，每个交易中都可有多个输入和输出

因此，它允许Fuel进行原子多用户交易，这为 Fuel 之上的dApp开启了一个充满可能性的新世界。在Fuel上，基于UTXO的系统中的每个输入只产生和消耗一次，这意味着 Rollup 链的状态存储为键值。

由于使用UTXO ID计算状态元素是确定性和无状态的，因此一旦被消耗，它也允许长链和预签名交易的"树"。

![img](https://img.learnblockchain.cn/2023/07/18/81500.jpeg)



> 预签名交易的 "树"，能够进入不同的ID

由于状态数据库只需要检查是否存在消耗的元素，因此它允许用户和交易之间有趣的可能性和交互。

就像比特币一样，你有原子数量的 X币/代币/状态，而不是账户，这些原子数量的X币/代币/状态由花费者控制。这些状态元素可以代表不同的资产，如ETH和ERC-20代币。此外，由于Fuel的各种消费条件，你可以创建[ HTLC](https://en.bitcoin.it/wiki/Hash_Time_Locked_Contracts) 输出（允许一种加密货币在另一个区块链上交易一定数量的加密货币），例如这将允许Fuel和以太坊之间可即时提款。这是通过LP来实现的，LP可以为想要快速取款的用户提供流动性，当然需要收取一定的费用。然而，如果他们在执行取款之前完全验证Fuel区块，那么系统风险为零。

因此，总结一下为什么基于UTXO的设计与众不同：

1. 并行交易验证

2. 独特的欺诈证明，无需状态序列化

## 安全性

区块链的安全性可以定义为攻击网络历史的成本。在大多数情况下，使攻击网络的成本过高是确保网络安全的关键--加密经济安全。



而在 layer2 ，例如Fuel， Rollup 还必须是无信任的，具有状态有效性和状态安全性。以太坊上的大多数 Rollup 都是这种情况，因为它们继承了以太坊本身的安全性，因此是信任最小化的。此外，还有传说中的 "去中心化"，通常可以用运行一个完整节点的成本来衡量（如果成本过高，将导致网络的去中心化不稳定）。这通常也是我们不增加区块大小的原因。最后，它必须是无权限的，才能参与到Rollup的生态系统中，这就是以太坊上的Rollup桥接合约所能实现的。

![img](https://img.learnblockchain.cn/2023/07/18/85103.jpeg)



> 底层安全由第一层提供，该层提供数据可用性等。

## Fuel 的三大支柱

Fuel 的路线图和概念是一个专注于未来的执行层--一个模块化的未来。这体现在他们专注于为以太坊和其他DA解决方案提供最好的执行层。Fuel设计的三大支柱是

1. 并行交易执行

2. Fuel虚拟机（FuelVM）

3. 卓越的开发者体验（使用 Sway 和 Forc ）

#### 并行处理（执行）

并行交易处理由 Solana 大力推广，通过 Sealevel 运行时，Solana 将传入的交易分类，在多个内核上并行运行，这意味着它们不会影响虚拟机内存中的相同状态。这是因为 Solana 交易描述了交易执行时将读取或写入的所有状态--类似于UTXOs--从而实现了并行处理。Solana 与以太坊一样，基于账户。然而，与以太坊不同的是，每个节点确保多次访问的账户仅在一个队列中按顺序列出。

那么，像Fuel这样的 Rollup 如何从中受益呢？因为它能够通过使用UTXO模型并行执行交易。因此，Fuel能够使用CPU的更多线程和内核，而在单线程区块链中，这些线程和内核通常是闲置的。因此，与以太坊上的其他 Rollup 相比，Fuel能够提供更多的计算和交易吞吐量。

#### FuelVM

FuelVM 是 Fuel 上的虚拟机，用于通过 Sway 语言构建各种应用程序和智能合约，我们稍后会详细介绍。在FuelVM中，交易通过UTXOs发生，如前所述。输入被销毁，输出被创建。虚拟机基本上是一个状态计算机，允许智能合约相互交互。它还规定了改变每个Fuel区块状态的规则。如果你对FuelVM的工作原理感兴趣，并想在Fuel上开始构建，你可以查看[ GitHub](https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/main.md)，这里有你作为开发者需要的所有信息。

#### Sway 编程语言

Sway 是在 Fuel 基础上构建智能合约和应用程序的语言。它在很大程度上基于Rust语言，Rust语言在构建区块链应用程序方面已经非常流行（主要用于Cosmos生态系统以及Solana和Near）。Sway 针对通过FuelVM使用进行了优化，并拥有一个名为 Forc（Fuel Orchestrator，发音为 "fork"）的工具链。Forc提供了开发人员可以在FuelVM中使用的工具和命令。你可以将Forc与作为Rust构建系统的Cargo进行比较。这意味着Rust开发者可以非常容易地学习Sway，并开始在Fuel之上进行构建。Sway还有一个vscode插件，因此上手非常容易。此外，Rust（Sway是其DSL）年复一年地被开发者评为[最受喜爱的编程语言](https://insights.stackoverflow.com/survey/2020#technology-most-loved-dreaded-and-wanted-languages-loved)，同时也是[使用最多的编程语言](https://www.tiobe.com/tiobe-index/)之一。

![img](https://img.learnblockchain.cn/2023/07/18/11360.jpeg)



## L2代币经济学

为了更好地理解Fuel是如何试图改变当前 Rollup 交易的工作方式，看看他们对 Rollup 交易代币经济学的看法是非常重要的。 Rollup 的代币经济学工作方式显然有很大不同，因为你仍然依赖以太坊进行结算，获得统一的流动性和继承安全性。Fuel已经讨论了三个主要的代币模型，这些模型应该避免用于rollups（但对于其他系统，如侧链，可能是好的）。它们是

1. PoS (Proof-of-Stake) 模式，验证者可以审查新的rollup 区块，由于继承的是以太坊的安全性，所以不需要这种模式。很多rollup正试图通过链外DA（如ZKSync）走这条路线。

2. 需要使用原生代币支付费用的模式，从而将其与以太坊绑定。然而， Rollup 节点本身仍然需要持有以太坊来结算。这为使用该协议的用户增加了更多的用户体验障碍。Obscuro 就是这样一个例子。

3. 治理代币提供对 Rollup 合约的控制，这可能会受到加密经济攻击。

那么，Fuel 认为什么模式是未来的方向？

 Rollup 的区块空间是有限的资源，就像在以太坊上一样。然而，Rollup上的区块空间与以太坊上的区块空间有很大不同。执行层空间像以太坊的一样是稀缺的，但它是独立于以太坊而存在的，同时也仍于以太坊相关，因为依赖于底层的数据可用性。Fuel认为未来这种执行能力可以被代币化，但代币不会为最终用户带来更高的费用或摩擦。那么，如何将区块空间代币化呢？

你可以[将区块空间的稀缺性代币化](https://fuel-labs.ghost.io/token-model-layer-2-block-production/)，让代币持有者有权作为区块生产者收取费用。这就将代币需求转移到了区块生产者身上，而区块生产者则需要能够在未来的区块空间上收取费用。通过这种方式，最终用户可以使用区块生产者想要收取费用的任何代币，如本文前面所述。此外，通过把收费权进行稀缺性代币化的模式，可以分散区块生产。 Rollup 的节点运营商将以代币为纽带，获得生产区块的权利，并向最终用户收取费用，这就为代币创造了一个市场--但并不要求最终用户使用特定的代币。因此代币被用于选择领导者，有权生产区块并收取相关费用。但到目前为止，大多数公司都决定采用前面讨论过的三种模式。

#### MEV 捕获

区块空间价值的获取也与MEV有很大关系，这也是中心化区块生产商的一个巨大问题。然而，通过转向代币模式，就像所描述的那样，你能够分散运营节点及其领导者的选择。这意味着像这样的代币模式也能够在某种程度上 "代币化" MEV，这是代币持有者有权要求的价值的一部分。通过代币化区块空间的未来现金流，该协议也代币化了该区块空间内执行顺序的未来现金流。

其他加密货币也在其协议中就最小化 MEV 进行着令人着迷的研究。例如，来自Optimism的Karl Floesch曾在[这里](https://ethresear.ch/t/mev-auction-auctioning-transaction-ordering-rights-as-a-solution-to-miner-extractable-value/6788/5)讨论过MEV的拍卖，同样基本上允许你将其代币化。Arbitrum和Chainlink正在探索一种公平排序服务([FSS](https://blog.chain.link/arbitrum-and-chainlink-fair-sequencing-services/))，它可以提高交易排序的公平性和可预测性。

### 模块化世界中的Fuel

在模块化世界中，原本单体区块链的大部分功能被分离到多个链中，这为优化这些层的各个部分创造了可能性。这就是Celestia通过优化数据可用性所做的事情，也是Fuel通过优化模块化范式中的执行层所做的事情。这也是各层能够创建优化节点的原因，无论是全节点、轻节点还是桥节点。这些节点能够针对其特定用途进行优化，从而极大地提高各层的能力。

我曾在不同的文章和主题中广泛讨论过状态臃肿的问题，以及如何通过模块化构建来缓解这一问题。这就是使用独立的无状态数据可用性层所带来的巨大帮助。因此，Fuel试图超越单体区块链设计原则的限制。

除此之外，交易设计也非常独特，因为 Fuel 使用了UTXO。但这也是Fuel如此吸引我的原因之一。



Fuel 不是为以太坊当前的环境而构建，而是为模块化的自主未来构建引擎。这使他们有别于目前所有的公司。正如我在文章开头提到的，如果你有兴趣在Fuel上构建，学习Sway或类似的东西，我们很乐意与你交流。

[在Twitter上关注Maven11](https://twitter.com/Maven11Capital)， [在Twitter上关注Fuel](https://twitter.com/fuellabs_)

### 参考资料

https://fuel-labs.ghost.io/introducing-fuel-the-fastest-modular-execution-layer/

https://docs.fuel.sh/v1.1.0/Introduction/Welcome.html

https://github.com/fuellabs

https://forum.celestia.org/t/accounts-strict-access-lists-and-utxos/37

https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/main.md

https://fuel-labs.ghost.io/token-model-layer-2-block-production/

[https://docs.fuel.sh/v1.1.0/Concepts/Fundamentals/Transaction%20Architecture.html](https://docs.fuel.sh/v1.1.0/Concepts/Fundamentals/Transaction Architecture.html)

[https://docs.fuel.sh/v1.1.0/Concepts/Fundamentals/Block%20Architecture.html](https://docs.fuel.sh/v1.1.0/Concepts/Fundamentals/Block Architecture.html)

[https://docs.fuel.sh/v1.1.0/Concepts/Fundamentals/Security%20Analysis.html#commondefinitions](https://docs.fuel.sh/v1.1.0/Concepts/Fundamentals/Security Analysis.html#commondefinitions)

https://fuellabs.github.io/sway/latest/

https://fuel.network/blog

---

本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来 DeCert 码一个未来， 支持每一位开发者构建自己的可信履历。
