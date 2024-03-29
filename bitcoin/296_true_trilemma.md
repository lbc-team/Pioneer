# 比特币二层的真正三难困境



在确定和解决[比特币](https://learnblockchain.cn/tags/%E6%AF%94%E7%89%B9%E5%B8%81/)二层的可扩展性三难问题方面一直存在着挣扎。以往解决比特币可扩展性的尝试采用了一种狭隘的观点，只专注于利用 BTC。这种固执导致了将比特币可扩展性讨论局限于 BTC。然而，必须采取更广泛的立场，承认并考虑将比特币区块链作为第 2 层解决方案的基础。

比特币是理想的选择。它是最去中心化和安全的基础层。应该利用这个中立的基础层，用于各种链上金融活动，远远超出简单支付的范围。我们应该有远见，让用户在参与更高级的链上金融活动时能够依赖比特币的区块链安全。加密用户应该放心，知道他们的活动是由最中心化的基础层保护的。

比特币被设计得尽可能简单，尽可能安全，它以目前的形式完美地实现了其目标。在比特币之上出现的新层应该继承比特币的全部安全性，为链上金融创建一个可扩展和可编程的基础设施。



比特币的设计目标是尽可能简单，以尽可能安全，而它在当前形式下完美地实现了这一目标。新的层出现在比特币之上应该继承比特币的全部安全性，以创建一个可扩展和可编程的链上金融基础设施。

## 三难问题

![img](https://img.learnblockchain.cn/attachments/migrate/1701606684001)

> 区块链可扩展性三难问题(不可能三角)

区块链可扩展性三难问题(不可能三角)最初是针对第 1 层解决方案提出的，为了解释同时实现所有三个属性的内在紧张关系。我们可以重新解释每个方面，将其应用于比特币第二层解决方案。让我们为这些方面建立简单的定义，并深入探讨它们的细节。

**可扩展性（Scalability）：** 在二层（L2）的情境下，可扩展性应该指的是超越基础层的性能。对于比特币二层，理想的可扩展解决方案不仅应该处理比基础层更多的交易量，还应该支持更广泛的更具表现力的交易类型。

**安全性：** 对于第一层来定义安全性可能会很复杂，因为涉及到诸如代币经济学或共识机制等多方面的因素。然而，对于比特币二层，我们可以很容易地将安全性定义为从比特币继承的一系列属性的程度。这个程度是一个层依赖比特币提供安全性的程度。例如，一个二层可以将其区块哈希锚定到比特币的区块，同时将区块保存在链下，从而继承了比特币对重组的抵抗能力，但没有继承其活跃性（liveness）。定义一个层安全性的四个主要属性是：活跃性（数据可用性）、抗审查、抗重组和有效性。

**去中心化：** 同样，当讨论比特币二层的去中心化时，比特币二层的去中心化应该在很大程度上与基础层的去中心化相似。尽管衡量基础层去中心化的指标经常被误解，但关键焦点应该是验证区块链的的难易程度。对于比特币，重点应该放在节点而不是矿工上。虽然矿工负责生成区块，但验证这些区块的有效性是节点的责任。简单来说，节点执行共识和链规则，而不是区块生产者。对于第二层，我们可以应用相同的度量标准：验证第二层有多容易？这包括访问L2数据和验证数据。我们将更详细地探讨这一点。

## **比特币二层的可扩展性**

比特币二层的可扩展性是一个多方面的挑战。在最基本的层面上，我们希望一个层不仅能处理更多的交易，还能执行比基础层更广泛的金融操作。

可扩展性的第一个方面相对直接，指的是层的吞吐量，通常以每秒交易数（TPS）来衡量。然而，第二个方面需要更深入的研究。对于理想的比特币二层，我们设想的功能应该超出简单的支付交易。这可能包括借贷、交换或执行复杂的支付合约。

为了促进这样的高级操作，一个二层需要一个能够编程和执行这些功能的虚拟机（VM）。虽然对于可扩展性来说并非必需，但对此类 VM 进行编程的便利性是有利的，因为它可以加速二层内的开发活动。历史表明，许多具有复杂虚拟机的基础层和第二层都难以吸引大量的开发活动，这表明仅仅复杂性并不是成功的银弹。

以太坊虚拟机（[EVM](https://learnblockchain.cn/tags/EVM)）是迄今为止最受欢迎的区块链虚拟机，几个比特币二层已经采用了它或它的变体。然而，重要的是要注意，当集成到新层时，EVM 的兼容性程度是有所不同的。因此，必须认识到，并非所有 VM 实现都提供与原始实现相同的功能范围，有些提供完全等效，而另一些则仅提供功能子集。

了解这些区别对于评估比特币二层的可扩展性至关重要，因为它直接影响到可以在基础区块链之上安全有效地执行的金融活动的类型和范围。

## **比特币二层的安全性**

在可扩展性三难问题中，安全性的定义确实从最初的基础层概念有了很大的发展。对于基础层来说，安全性取决于各种因素，包括女巫保护机制、共识模型等。有四个关键属性定义了基础层的安全性：

1. 活跃性（数据可用性）：这涉及用户通过验证每个状态转换来访问整个区块链状态的能力。如果基础层的数据发布受到损害，例如，如果一个区块生产者创建一个区块并发布区块头，但隐瞒了交易数据，那么就无法实现活跃性。因此，没有人可以独立验证状态并维护区块链的运行。
2. 抗审查：这是用户将其交易包括在一个区块中的能力。多个区块生产者和节点可以传播交易，确保基础层的抗审查。
3. 抗重组：这是区块链对重组攻击的抵抗能力。虽然基础层可能会因网络延迟或不同的激励而经历暂时的重组，但这些通常会在短时间内解决。在比特币的情境中，一般认为一个区块一旦有六个后续区块添加到链上就被最终确认。尽管比特币的最终性是概率性的，但深度超过六个区块的重组极不可能。
4. 有效性：这是用户有效验证状态转换的能力。对于比特币，任何操作完整节点的人都可以通过处理相应的区块来验证从一个 [UTXO](https://learnblockchain.cn/tags/UTXO) 集到另一个集的转换，这个过程是确定性的。有效性与活跃性密切相关，因为数据必须在验证之前可用。

当讨论比特币二层（二层解决方案）的安全性时，我们将其定义为一个频谱，表示底层链的安全属性被继承的程度。
Layer 2 解决方案可以在不同程度上从基础层继承上述属性。例如，Layer 2 可能会在基础层验证其交易，但将交易数据保存在链下，从而继承了基础层的有效性，但没有活跃性。

由于比特币的可编程性有限，目前无法直接验证外部状态转换（例如 Layer 2 的状态转换）。然而，Layer 2 用户可以间接依赖比特币的安全模型进行验证，从而密切接近比比特币验证的安全保证。我们将进一步探讨这一概念。

## **比特币二层的去中心化**

去中心化涵盖了几个方面，与安全密切相关。去中心化意味着任何个人都可以无需许可加入网络，以访问区块链状态、验证状态转换、广播交易，并有可能生成区块。让我们分解这些组成部分，因为它们与去中心化的不同方面相关：

- 获取状态的可访问性（活跃性）：这与活跃性相关。去中心化网络应允许任何人检索区块链的当前状态，确保数据可用性。
- 验证状态转换的能力（有效性）：这涉及有效性。去中心化确保任何参与者都可以独立验证状态转换的正确性。
- 广播交易的自由（抗审查性）：这一方面与抗审查性相关，强调用户能够向网络提交其交易而不会面临被阻止或忽视的风险，从而确保免于审查的自由。
- 生成区块的能力：虽然这可以被视为抗审查性的一部分，但它有些不同，可以说是最不重要的方面。生成区块的能力并不那么重要，因为区块生成者并不决定区块链的规则。区块的生成实质上是编制符合已建立共识规则的一组交易。实际上，是节点而不是区块生成者来执行这些规则。

一个很有说服力的例子是 Marathon 在区块高度 809478 挖掘的比特币主网区块。尽管利用了相当大的哈希算力，但该区块被节点拒绝，因此未被添加到主链上。

这就引出了一个基本方程：

> **更多节点 = 更大的去中心化**

这就是为什么每个比特币二层都应该优先考虑运行节点的便利性。如果一个比特币二层需要的软件需要过多的内存、存储或带宽，它将天然地被较少验证，因此也将更少地去中心化。

理想情况下，比特币二层应直接集成到比特币网络中，允许用户在验证比特币网络本身之外以最少的额外努力来验证该层。这种方法促进了最大程度的去中心化，并利用了比特币基础层的安全性和已建立的信任。

# **比特币二层的三难问题**

![img](https://img.learnblockchain.cn/attachments/migrate/1701606694736)

> 比特币二层的真正三难问题

考虑到我们讨论过的所有定义，我们可以稍微修改原始的三难问题，使其与比特币二层兼容。虽然这些变化是微妙的，但根据所提供的解释，修订后的三难困境可能会更加易于理解。

现在，你可能会好奇现有或拟议的模型如何符合这一三难问题。让我们检查各种模型，并尝试相应地定位它们。

## 给比特币二层定位

在区块链三难困境的背景下，可以评估许多层，但为简洁起见，我们将只关注已知的、目前正在运行的 Layer 2 项目，这些项目不需要软分叉即可运行。

### **闪电网络**

闪电网络是比特币上最知名且广泛采用的二层，致力于实现近乎即时的支付。已经运行了近五年，其处理即时支付的能力超过了比特币基础层。这一优势源自其专为单一用例量身定制的架构。截至今天，闪电的功能仅限于点对点比特币交易，基本上是促进支付。尽管它增强了支付的吞吐量，但它并未扩展比特币的基础架构以包括额外的功能，这在很大程度上限制了其可扩展性潜力。

从安全性的角度来看，闪电网络在比特币之上以点对点方式运行。这意味着诸如活跃性、抗审查性和抵抗链重组等属性是在链下、在两方之间管理的。与比特币直接相关的唯一方面是交易的有效性，这是进行乐观验证的。闪电的点对点组件并未引入来自外部链的任何新的信任假设，这使我们可以将其视为对比特币最安全的二层之一。

就去中心化而言，闪电的点对点性质是有利的。每个参与者必须建立并维护自己独特的节点。这一要求确保了网络保持去中心化，因为节点是单独操作的，而不是集中控制的。

总之，闪电网络增强了比特币处理支付的能力，实现了几乎即时的结算时间，并由于其要求参与者运行独立节点的设计，保持了高度的去中心化。然而，虽然它利用比特币的安全基础设施进行最终结算，但它引入了链下网络独有的新安全考虑因素。此外，它的功能专门用于扩展支付交易，并没有扩展到其他类型的链上金融应用程序，这限制了其在更广泛的区块链金融领域的适用性。因此，闪电网络以其高度的去中心化实现了三难困境的一个方面，除了协议的实现复杂性外，在安全维度上处于有利地位。但是，它在可扩展性方面仍然受到限制。

### Liquid Network

Liquid 是由 Blockstream 开发的联合侧链，依赖于一组受信任的实体来管理其运营。其设计使其能够处理更多交易量，并提供比传统比特币交易更多的功能。在其现有框架内，Liquid 的可扩展性通常被视为令人满意的。

然而，在安全性方面，Liquid 与比特币有所不同。它作为一个独立网络运行，不与比特币区块链共享或继承安全特性。这种独立性意味着 Liquid 的运营者有能力隐瞒数据、发起链重组，并在 Liquid 网络内审查交易。这些潜在行为可能会阻碍用户对区块链的完全验证，引发对其去中心化的担忧，并质疑其去中心化的稳健性。

总之，Liquid 通过引入一个侧链来扩展比特币交易的方法与众不同，使其能够处理更多交易量，并提供比比特币主链更多的功能。然而，其安全模型与比特币有所不同，因为它是建立在一组受信任实体控制的联合结构之上。因此，虽然 Liquid 在满足三难问题的可扩展性属性方面表现出色，但由于其治理和安全模型带来的中心化风险，它在其他两个属性方面面临挑战。

### **Stacks**

Stacks 是一个采用转移证明（PoX）机制进行对抗女巫的侧链。它利用 Clarity 智能合约语言来实现比特币无法支持的更广泛的功能。此外，由于其更大的区块大小和减少的区块间隔，Stacks 具有比比特币更多的交易处理能力。

采用独特的共识机制，Stacks 独立于比特币网络运行。这意味着 Stacks 中新区块的生成和广播是在其自己的网络中管理的。就活跃性而言，Stacks 依赖于其自己的网络以保持持续的数据可用性。对于抗审查的过程也与比特币分开。用户通过 Stacks 生态系统内的节点将其交易发送给 Stacks 区块生产者，因此依赖于 Stacks 区块生产者的善意来包含其交易在区块中。虽然重组阻力在某种程度上与比特币有关，但目前对于关键的金融业务来说，最终确定的持续时间太长了。Stacks正在探索其即将到来的更新中的改进，通过每天将区块哈希锚定到比特币网络来缩短最终确定时间。

要参与网络验证，用户需要操作一个 Stacks 节点，这需要连接到与比特币不同的网络、下载区块并进行验证。由于需要单独的网络连接和自定义节点软件，参与网络的节点数量本质上是有限的，导致节点数量远低于比特币网络。

总之，Stacks 通过更大的区块大小和智能合约功能增强了区块链功能的可扩展性，从而实现了三难问题中的可扩展性方面。然而，它在去中心化和安全性方面面临挑战。Stacks 的安全性依赖于单独的共识机制和网络基础设施，引入了与比特币不同的信任假设。至于去中心化，用户需要运行 Stacks 节点的要求创建了一个独立的网络，其去中心化程度尚未完全评估。



### **Rootstock**

Rootstock（RSK）是一个通过合并挖矿将以太坊虚拟机（EVM）兼容性引入比特币的侧链。这种方法允许同时创建侧链和比特币区块，旨在提高网络的可扩展性，超越比特币本身提供的能力。

尽管具有可扩展性优势和 EVM 兼容性，Rootstock 的安全性与比特币有显著不同。值得注意的是，与 Stacks 不同，Rootstock 甚至没有抗重组（reorg）能力，导致完全独立的信任和安全假设。

与 Stacks 类似，Rootstock 在一个独立的网络上运行，并需要特定的软件供节点运营者验证其区块链。合并挖矿有助于提高算力，这对网络的安全性有益，但并不从根本上保证区块生产者的诚实。去中心化程度是区块链健壮性的关键因素，由独立节点的数量来衡量。由于与 Stacks 相同的原因，Rootstock 的节点数量本质上是有限的，导致节点数量远低于比特币网络。

简而言之，Rootstock 通过引入 EVM 兼容的智能合约功能增强了比特币的可扩展性。然而，它与比特币的安全模型有所不同，因为它没有继承比特币的任何安全特性。Rootstock 的安全性基于其自己的信任假设，与比特币无关。在去中心化方面，与 Stacks 一样，Rootstock 依赖于一组外部节点，为其去中心化属性设定了一个上限。因此，虽然 Rootstock 满足了三难问题中的可扩展性方面，但它在安全性和去中心化属性上都存在挑战。



###  **Chainway 主权 ZK Rollup**

Chainway 的主权 ZK Rollup 在区块链领域代表着一项重大创新，它是一个直接构建在比特币网络上的 EVM 兼容 ZK Rollup。它利用零知识证明，特别是 ZK-STARKs，进行交易验证和高效利用比特币的区块空间。Chainway 的 ZK Rollup 是符合比特币二层三难困境所有三个基本要素最高标准的解决方案。

EVM 等效设计使开发人员能够无缝过渡以部署应用程序，在利用强大的比特币网络的同时保留熟悉的以太坊环境。ZK 架构的优势在于能够即时处理数千笔交易，递归证明确保了区块链三难困境参数内的可扩展性。

Chainway ZK Rollup 引入了一种通过将证明雕刻铭文到比特币区块链上来验证状态变化的方法。这些铭文证明可以随后被提取和验证。这些证明输出了与先前证明的状态差异，提供了使用比特币网络检索完整区块链状态所需的所有必要信息。

区块空间证明确保了与比特币等价的抗审查性，因为用户可以自行将其交易铭文刻到比特币网络上。这种方法还确保了区块生产者不能由于 ZK 电路生成的限制而排除这些交易。

由于证明铭文在比特币区块链上，因此实现了抗重组性，从而将 Rollup 状态锚定到比特币区块。

任何运行比特币核心的人都可以验证 Rollup 的证明，最大程度地提高了验证过程中的去中心化。这一策略有效地将每个比特币节点转变为一个 Rollup 节点，大大提高了去中心化程度。

因此，Chainway 的主权[ ZK Rollup](https://learnblockchain.cn/tags/zkRollup) 似乎有效地解决了区块链三难问题，实现了可扩展性，同时没有牺牲安全性或去中心化。它确保了活跃性、抗审查性和重新组织抗性，利用了比特币的安全特性，并避免了对一个单独的依赖信任的网络的需求。



## **结论**

对比特币二层解决方案进行分类和评估并不简单。提出新的三难困境或比较可能会导致对可扩展性、安全性和去中心化很重要的细微差别的疏忽。在原始三难问题框架内，每个角代表了成功的 Layer 1 区块链必须同时实现的基本区块链属性，或者至少在它们之间取得平衡。通过在每个角的定义上进行微妙的扩展，我们有效地将核心三难问题应用到了比特币二层。

对原始三难问题的遵循确保我们不会将第 2 层项目限制在严格的“是或否”类别中，而是欣赏去中心化的光谱和对 Layer 2 进行分类的各种因素。保持这一已建立的框架不仅有助于更准确地评估比特币二层架构的现状，还将区块链属性的基本原则扩展到[ Layer 2](https://learnblockchain.cn/tags/Layer2) 范式中。

---

本翻译由 [DeCert.me](https://decert.me/) 协助支持， 在 DeCert 构建可信履历，为自己码一个未来。