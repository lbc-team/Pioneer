> * 原文链接： https://forum.celestia.org/t/a-comparison-between-da-layers/899
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 模块化：比较数据可用性（DA）层



 Rollup 层是第 1 层扩容的一种解决方案。事实证明，Rollups 在扩展方面同样需要一些帮助。特别是，如果可以访问到更多的[数据可用性](https://docs.celestia.org/concepts/data-availability-faq/)， Rollup 可以获得更高的吞吐能力。

当然，现在有很多解决方案都旨在为 Rollup 提供可扩展的数据可用性，如 以太坊、Celestia、EigenLayer 和 Avail。下面是对它们在一些指标上的比较的简短而不完整的介绍。

## DA 层一览

![Celestia_DA 对比](https://img.learnblockchain.cn/2023/07/26/59311.jpeg)





### 出块时间

出块时间是指区块出块间隔的的时间长度。

![Celestia_Comparison_table_separated_block-time](https://img.learnblockchain.cn/2023/07/26/65533.jpeg)



#### Celestia、以太坊和 Avail

在这三个项目中，两个项目的区块时间都相差 8 秒：以太坊的区块时间为 12 秒，Celestia 的区块时间为 15 秒，Avail 的区块时间为 20 秒。它们之间的差距其实并不大，也不会产生重大影响。它们之间真正的差异，要看它们达到最终确定性所需的时间，就会更加明显。

#### EigenLayer

EigenLayer 是唯一一个不是区块链的项目--它是一套运行在以太坊上的智能合约。任何需要转发给 Rollup 合约的数据，如证明数据可用性的法定人数签名，都依赖于以太坊的区块时间和最终性。如果 Rollup 都依赖 EigenLayer 的话，那么它就不受以太坊区块时间的约束。

## 最终确定性和共识算法

最终确定性时间是指区块产生并被视为最终区块所需的时间。我们所说的最终性是指，如果被认为是最终确定性的交易被撤销，那么大量的质押将被销毁。共识协议处理最终确定性的方式各不相同。



![Celestia_Comparison_table_separated_7 (1)](https://img.learnblockchain.cn/2023/07/26/67122.jpeg)





#### 以太坊

以太坊使用[GHOST 和 Casper](https://ethereum.org/en/developers/docs/consensus-mechanisms/pos/gasper/#:~:text=Together%20these%20components%20form%20the,are%20syncing%20the%20canonical%20chain.)等协议组合来达成共识。GHOST 是以太坊的区块生产引擎，依赖于[概率最终确定性](https://smsunarto.com/blog/guide-to-finality)。为了提供更快的终结性，以太坊使用了最终确定性工具：[Casper](https://arxiv.org/pdf/1710.09437.pdf)。

Casper 提供经济性最终确定性保证，因此可以更快地完成交易。但是，以太坊使用 Casper 每 64 - 95 个slot才最终确定一个区块不会被撤销，这意味着以太坊区块的最终完成时间大约为 [12 - 15 分钟](https://notes.ethereum.org/@vbuterin/single_slot_finality)。反过来，这又会导致 Rollup 区块在向以太坊发布数据和承诺时，需要等待 12 - 15 分钟才能收到最终确定结果。

#### EigenLayer

由于 EigenLayer 是以太坊上的一组智能合约，因此它也继承了与以太坊相同的最终确定性时间（12 - 15 分钟），即任何需要转发给 Rollup 合约以证明数据可用性的数据的最终时间。同样，如果 Rollup 完全使用 EigenLayer，它的最终确定时间会更快，这取决于是否使用任何共识机制等。

#### Celestia

Celestia 的共识协议使用 [Tendermint ](https://docs.tendermint.com/v0.34/introduction/what-is-tendermint.html)，具有单slot最终确定性。也就是说，一旦一个区块通过了 Celestia 的共识，它就最终完成了。这意味着最终完成时间基本上与区块时间（15 秒）一样快。

#### Avail

Avail 与以太坊一样，使用[BABE 和 GRANDPA](https://wiki.polkadot.network/docs/learn-consensus)协议组合来实现最终性。BABE 是具有概率的最终确定性区块生产机制，而 GRANDPA 则是最终确定性工具。虽然 GRANDPA 可以在单个slot内最终确定区块，它也可以 [在给定回合内最终确定多个区块](https://polkadot.network/blog/polkadot-consensus-part-2-grandpa/)。Avail 的最终确定性为 20 秒，最坏的情况是多个区块。

## 数据可用性采样

在大多数区块链中，节点需要下载所有交易数据来验证数据的可用性。这带来的问题是，当区块大小增加时，节点需要验证的数据量也会同样增加。

[数据可用性抽样](https://celestia.org/glossary/data-availability-sampling/) 是一种允许轻节点只下载一小部分区块数据来验证数据可用性的技术。这为轻节点提供了安全保障，使它们可以验证出无效的区块（仅 DA 和共识），并允许区块链在不增加节点需求的情况下扩展数据可用性。



![Celestia_Comparison_table_separated_4](https://img.learnblockchain.cn/2023/07/26/20634.jpeg)







#### Celestia & Avail

Celestia 和 Avail 在发布时都将支持数据可用性采样轻节点。这意味着它们将能够通过更多的轻节点安全地增加区块大小，同时保持对用户验证链的低要求。

#### 以太坊

使用 [EIP 4844 4](https://www.eip4844.com/) 的以太坊将不包括数据可用性采样。EIP 4844 增加了区块大小（通过 Blob），并建立了一些技术基础来实现 danksharding，如 blob 交易和 kate 承诺。要验证 EIP 4844 实施后以太坊的数据可用性，用户仍必须运行完整节点并下载所有数据。

#### EigenLayer

虽然 EigenLayer 目前没有围绕 DAS 的官方计划，但有暗示称，DAS [未来可能成为 EigenLayer 轻客户端](https://twitter.com/sreeramkannan/status/1634235450071355397)的选项。有两个选项：

- 排序器  DAS：排序器 DAS 会增加排序器的开销，因为只有领导者才能为当前区块的所有轻客户端提供采样请求--除非实施某种共识机制，让非领导者也能提供采样请求。
- EigenLayer DAS：来自 EigenLayer 的 DAS 需要一个强大的 p2p 网络和额外的机制（如区块重构）来保证完全的安全性。

虽然 DAS 可能不会在 EigenLayer 推出时实施，但看起来它可能会在以后进入 EigenLayer。在此之前，验证 EigenLayer 链的 DA 需要一个完整的节点。

## 轻节点安全性

区块链依靠用户运行节点来抵御恶意攻击。

与完整节点相比，传统的轻客户端安全性假设较弱，因为它们只能验证区块头。轻客户端无法检测到无效区块是否是由大多数不诚实的区块生产者产生的。具有数据可用性采样功能的轻节点在安全性方面得到了提升，因为它们可以验证是否产生了无效区块--如果DA层只做共识和数据可用性的话。



![Celestia_Comparison_table_separated_5](https://img.learnblockchain.cn/2023/07/26/48273.jpeg)





#### Celestia & Avail

由于 Celestia 和 Avail 都将进行数据可用性采样，因此它们的轻节点将具有信任最小化的安全性。

#### 以太坊 和 EigenLayer

使用 EIP 4844 的以太坊没有数据可用性采样，因此其轻型客户端不具备信任最小化的安全性。由于以太坊也有智能合约环境，轻客户端也需要验证执行（通过欺诈或有效性证明），以避免依赖诚实的多数假设。

对于 EigenLayer 而言，除非有 DAS，否则轻客户端（如果支持的话）将依赖于质押节点的多数诚实。

## 编码证明方案

[擦除编码](https://github.com/ethereum/research/wiki/A-note-on-data-availability-and-erasure-coding) 是使数据可用性采样成为可能的重要机制。擦除编码通过生成额外的数据副本来扩展数据块。附加数据会产生冗余，为采样过程提供更强的安全保证。不过，节点可能会试图对数据进行错误编码，从而破坏网络。为了抵御这种攻击，节点需要一种方法来验证编码的正确性--这就是证明的作用所在。



![Celestia_Comparison_table_separated_6](https://img.learnblockchain.cn/2023/07/26/77056.jpeg)





#### 以太坊、EigenLayer 和 Avail

这三个项目都使用一种有效性证明方案来确保区块编码正确。其原理类似于 zk rollup 使用的[有效性证明](https://celestia.org/glossary/validity-proof/)。每次生成区块时，验证者必须生成[对数据的承诺](https://dankradfeist.de/ethereum/2020/06/16/kate-polynomial-commitments.html#:~:text=As%20a%20polynomial%20commitment%20scheme,equal%20to%20a%20claimed%20value.)，节点使用 kzg 证明来验证--证明区块编码正确。

不过，为 kzg 证明生成承诺需要区块生产者更多的计算开销。当区块较小时，生成承诺不会带来太多开销。随着区块的增大，为 kzg 证明生成承诺的负担就会大大增加。负责生成 kate 承诺的节点类型可能需要更高的硬件要求。

#### Celestia

Celestia 的独特之处在于它使用欺诈证明方案来检测错误编码的区块。这个想法与乐观 Rollup 所使用的[欺诈证明](https://celestia.org/glossary/state-transition-fraud-proof/)类似。Celestia 节点无需检查区块是否正确编码。它们默认情况下会认为它是正确的。这样做的好处是，区块生产者不需要进行昂贵的工作，就能为擦除编码生成承诺。



但是，轻节点确实需要等待一小段时间，然后才能确认一个区块是否被正确编码，并在它们看来最终完成编码。这段等待时间是为了让轻节点在区块编码错误的情况下收到全节点的欺诈证明。如果节点被“eclipsed”（即遭受网络攻击，无法正常与其他节点通信），导致无法收到欺诈证明，那么它就会将无效区块视为有效。然而，假设节点不会被“eclipsed”是节点实际验证区块链的前提，不论是否有欺诈证明的参与。



**欺诈证明和有效性证明编码方案的主要区别在于节点生成承诺的开销和轻节点的延迟之间的权衡。将来，如果有效性证明的权衡比欺诈证明更有吸引力，Celestia 就可以转换其编码证明方案**。




本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来 **DeCert** 码一个未来， 支持每一位开发者构建自己的可信履历。
