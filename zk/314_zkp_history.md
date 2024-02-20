# 了解零知识证明历史 - 我们的主观观点



![我们对零知识证明历史的高度主观观点](https://img.learnblockchain.cn/attachments/migrate/1708436597399)

零知识、简洁、非交互式知识证明（zk-SNARKs）是一种强大的加密原语，允许一方，即证明者，说服另一方，即验证者，某个陈述是真实的，而不透露除了该陈述的有效性之外的任何其他信息。由于它们在可验证的私人计算、提供计算机程序执行正确性的证明以及帮助扩展区块链方面的应用，它们引起了广泛关注。我们认为 SNARKs 将对塑造我们的世界产生重大影响，正如我们在我们的[文章](https://blog.lambdaclass.com/transforming-the-future-with-zero-knowledge-proofs-fully-homomorphic-encryption-and-new-distributed-systems-algorithms/)中所描述的那样。SNARKs 作为不同类型的证明系统的总称，使用不同的多项式承诺方案（PCS）、算术化方案、交互式 Oracle 证明（IOP）或概率可检查证明（PCP）。然而，这些基本思想和概念可以追溯到 20 世纪 80 年代中期。在比特币和以太坊的引入后，开发工作显著加快，这证明了它们是一个令人兴奋且强大的用例，因为你可以通过使用零知识证明（通常称为此特定用例的有效性证明）来扩展它们。SNARKs 是区块链可扩展性的重要工具。正如 Ben-Sasson 所描述的，过去几年见证了[加密证明的寒武纪爆发](https://medium.com/starkware/cambrian-explosion-of-cryptographic-proofs-5740a41cdbd2?ref=blog.lambdaclass.com) 。每个证明系统都有优点和缺点，并且在设计时考虑了某些权衡。硬件的进步、更好的算法、新的论证和小工具导致了性能的提升和新系统的诞生。其中许多系统正在生产中使用，并且我们不断推动界限。我们是否会有一个适用于所有应用的通用证明系统，还是适用于不同需求的几个系统？我们认为一个证明系统将统治所有应用的可能性不大，因为：

1. 应用的多样性。
2. 我们有不同的约束类型（关于内存、验证时间、证明时间）。
3. 对鲁棒性的需求（如果一个证明系统被破解，我们仍然有其他系统）。

即使证明系统发生了很大变化，它们都具有一个重要特性：证明可以快速验证。通过具有验证证明并且可以轻松适应处理新的证明系统的层， 也解决了与更改基础层（如以太坊）相关的困难。

为了概述 SNARKs 的不同特征：

- 密码假设：抗碰撞哈希函数、椭圆曲线上的离散对数问题、指数知识。
- 透明 vs 可信设置。
- 证明者时间：线性 vs 超线性。
- 验证者时间：常数时间、对数、次线性、线性。
- 证明大小。
- 递归的便利性。
- 算术化方案。
- 一元 vs 多元多项式。

本文将探讨 SNARKs 的起源、一些基本构建模块以及不同证明系统的兴起（和衰落）。本文并不打算对证明系统进行详尽的分析。相反，我们专注于对我们当前产生影响的那些。当然，这些发展只有在这一领域的先驱们的伟大工作和思想的基础上才得以实现。

## 基础知识

正如我们所提到的，零知识证明并不是新鲜事物。定义、基础、重要定理甚至重要协议都是从 20 世纪 80 年代中期确立的。一些用于构建现代 SNARKs 的关键思想和协议是在 1990 年代提出的（sumcheck 协议），甚至在比特币出现之前（2007 年的 GKR）。当时采用的主要问题，主要是缺乏强大的用例（1990 年代互联网发展不如今日）以及所需的计算能力有关。

### 零知识证明：起源（1985/1989）

零知识证明领域在学术文献中首次出现是在 [Goldwasser, Micali and Rackoff](https://people.csail.mit.edu/silvio/Selected Scientific Papers/Proof Systems/The_Knowledge_Complexity_Of_Interactive_Proof_Systems.pdf?ref=blog.lambdaclass.com) 的论文中。有关起源的讨论，你可以参见[以下视频](https://www.youtube.com/watch?v=uchjTIlPzFo&ref=blog.lambdaclass.com) 。该论文引入了完备性、正确性和零知识的概念，并提供了二次剩余（quadratic residuosity）和二次非剩余（quadratic non-residuosity）的构造。

### Sumcheck 协议（1992）

[sumcheck 协议](https://blog.lambdaclass.com/have-you-checked-your-sums/)是由 [Lund, Fortnow, Karloff, and Nisan](https://dl.acm.org/doi/pdf/10.1145/146585.146605?ref=blog.lambdaclass.com) 于 1992 年提出的。它是简洁交互证明的最重要的构建模块之一。它帮助我们将多元多项式的求值之和的声明减少到在随机选择的点上的单个求值。

### Goldwasser-Kalai-Rothblum（GKR）（2007）

[GKR 协议](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/12/2008-DelegatingComputation.pdf?ref=blog.lambdaclass.com)是一种交互式协议，其证明者的运行时间与电路的门数成线性关系，而验证者的运行时间与电路的大小成次线性关系。在该协议中，证明者和验证者就深度为 d 的有限域上的扇形二通算术（an arithmetic circuit of fan-in-two）电路达成一致，其中层 d 对应于输入层，层 0 对应于输出层。协议从对电路输出的声明开始，将其减少为对前一层值的声明。通过递归，我们可以将其转换为对电路输入的声明，这可以轻松地进行检查。这些减少是通过 sumcheck 协议实现的。

### KZG 多项式承诺方案 （2010）

KZG 多项式承诺方案 （KZG polynomial commitment scheme 简称 PCS ）[Kate, Zaverucha, and Goldberg](https://www.iacr.org/archive/asiacrypt2010/6477178/6477178.pdf?ref=blog.lambdaclass.com)于 2010 年引入了使用双线性配对群的多项式承诺方案。该承诺由单个群元素组成，提交者可以有效地打开对多项式的任何正确评估的承诺。此外，由于批处理技术，可以对多个评估进行打开。KZG 承诺是 Pinocchio、Groth16 和 Plonk 等几种高效 SNARKs 提供了基本构建模块。它也是 [EIP-4844](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4844.md?ref=blog.lambdaclass.com) 的核心。有关批处理技术的直观理解，你可以参见我们关于 [Mina-Ethereum 桥](https://blog.lambdaclass.com/mina-to-ethereum-bridge/)的文章。

## 使用椭圆曲线的实用 SNARKs

2013 年出现了第一个实用的 SNARKs 构造。这些构造需要预处理步骤来生成证明和验证密钥，并且是程序/电路特定的。这些密钥可能相当大，并且取决于应保持未知的秘密参数；否则，它们可以伪造证明。将代码转换为可证明的内容需要将代码编译成一系列多项式约束系统。起初，这必须以手动编码方式完成，这是耗时且容易出错的。该领域的进展试图消除一些主要问题：

1. 有更高效的证明者。
2. 减少预处理的数量。
3. 具有通用而不是特定电路的设置。
4. 避免信任设置。
5. 开发使用高级语言描述电路的方法，而不是手动编写多项式约束。

### Pinocchio (2013) 

[Pinocchio](https://eprint.iacr.org/2013/279?ref=blog.lambdaclass.com) 是第一个实用的、可用的 zk-SNARK。SNARK 基于二次算术程序（QAP）。证明大小最初为 288 字节。Pinocchio 的工具链提供了从 C 代码到算术电路的编译器，进一步转换为 QAP。该协议要求验证者生成密钥，这些密钥是特定于电路的。它使用椭圆曲线配对来检查方程。证明生成和密钥设置的渐近性与计算大小成线性关系，验证时间与公共输入和输出的大小成线性关系。

### Groth 16 (2016) 

[Groth](https://eprint.iacr.org/2016/260.pdf?ref=blog.lambdaclass.com) 引入了一个[具有增强性能的新知识论证](https://blog.lambdaclass.com/groth16/) ，用于描述 R1CS 的问题。它具有最小的证明大小（仅三个群元素）和快速验证，涉及三个配对。它还涉及一个预处理步骤，以获得结构化参考字符串。其主要缺点是，它需要针对我们想要证明的每个程序进行不同的信任设置，这很不方便。Groth16 被 ZCash 使用。

### Bulletproofs & IPA (2016) 

KZG PCS 的一个弱点是它需要一个信任设置。[Bootle 等人](https://eprint.iacr.org/2016/263?ref=blog.lambdaclass.com) 引入了满足内积关系的 Pedersen 承诺开局的有效零知识论证系统。内积论证具有线性证明者，对数通信和交互，但具有线性时间验证。他们还开发了一个不需要信任设置的多项式承诺方案。使用这些想法的多项式承诺方案（PCS） 被 Halo 2 和 Kimchi 使用。

### Sonic、Marlin 和 Plonk (2019) 

[Sonic](https://eprint.iacr.org/2019/099?ref=blog.lambdaclass.com)、[Plonk](https://eprint.iacr.org/2019/953?ref=blog.lambdaclass.com) 和 [Marlin](https://eprint.iacr.org/2019/1047?ref=blog.lambdaclass.com) 解决了 Groth16 中我们所遇到的每个程序都需要信任设置的问题，通过引入通用和可更新的结构化参考字符串。Marlin 提供了基于 R1CS (Rank-1 Constraint System) 的证明系统，是 Aleo 的核心。

[Plonk](https://blog.lambdaclass.com/all-you-wanted-to-know-about-plonk/) 引入了一种新的算术方案（后来称为 Plonkish）和使用宏积（grand-product）检查来检查复制约束。Plonkish 还允许为某些操作引入专门的门，即所谓的定制门。几个项目都有 Plonk 的定制版本，包括 Aztec、ZK-Sync、Polygon ZKEVM、Mina 的 Kimchi、Plonky2、Halo 2 和 Scroll 等。

### Lookups (2018/2020)

Gabizon 和 Williamson 在 2020 年引入了 [plookup](https://eprint.iacr.org/2020/315?ref=blog.lambdaclass.com)，使用宏积检查来证明一个值包含在预先计算的值表中。尽管查找参数先前在 [Arya](https://eprint.iacr.org/2018/380?ref=blog.lambdaclass.com) 中提出，但该构造需要确定查找的多重性，这使得构造不够高效。[PlonkUp](https://eprint.iacr.org/2022/086?ref=blog.lambdaclass.com) 论文展示了如何将 plookup 参数引入 Plonk。这些查找参数的问题在于，它们迫使证明者为整个表支付费用，而与他的查找次数无关。这意味着大型表的成本相当大，人们已经付出了大量努力来减少证明者仅支付他使用的查找次数的成本。
Haböck 引入了 [LogUp](https://eprint.iacr.org/2022/1530?ref=blog.lambdaclass.com)，它使用对数导数将宏积（grand-product）检查转换为倒数的和。LogUp 对于 [Polygon ZKEVM](https://toposware.medium.com/beyond-limits-pushing-the-boundaries-of-zk-evm-9dd0c5ec9fca?ref=blog.lambdaclass.com) 中的性能至关重要，他们需要将整个表拆分为几个 STARK 模块。这些模块必须正确链接，跨表查找强制执行这一点。引入 [LogUp-GKR](https://eprint.iacr.org/2023/1284?ref=blog.lambdaclass.com) 使用 GKR 协议来提高 LogUp 的性能。[Caulk](https://eprint.iacr.org/2022/621?ref=blog.lambdaclass.com) 是第一个证明者时间与表大小亚线性的方案，使用预处理时间 O(NlogN) 和存储 O(N)，其中 N 是表大小。随后出现了几种其他方案，如 [Baloo](https://eprint.iacr.org/2022/1565?ref=blog.lambdaclass.com)、[flookup](https://eprint.iacr.org/2022/1447?ref=blog.lambdaclass.com)、[cq](https://eprint.iacr.org/2022/1763?ref=blog.lambdaclass.com) 和 [caulk+](https://eprint.iacr.org/2022/957?ref=blog.lambdaclass.com)。[Lasso](https://eprint.iacr.org/2023/1216?ref=blog.lambdaclass.com) 提出了几项改进，避免在表具有给定结构时对其进行提交。此外，Lasso 的证明者只为 lookup 操作访问的表条目付费。[Jolt](https://eprint.iacr.org/2023/1217?ref=blog.lambdaclass.com) 利用 Lasso 通过 lookups 证明虚拟机的执行情况。

### Spartan (2019)

[Spartan](https://eprint.iacr.org/2019/550?ref=blog.lambdaclass.com) 为使用 R1CS 描述的电路提供了一个 IOP ("Interactive Oracle Proof.")，利用多变量多项式的性质和 sumcheck 协议。使用合适的多项式承诺方案，它产生了一个线性时间证明的透明 SNARK。

### HyperPlonk (2022) 

[HyperPlonk](https://eprint.iacr.org/2022/1355.pdf?ref=blog.lambdaclass.com) 基于 Plonk 的思想，使用多变量多项式(multivariate polynomials)。它依赖于 sumcheck 协议而不是商来检查约束的执行。它还支持高次约束，而不会影响证明者的运行时间。由于它依赖于多变量多项式，因此无需进行 FFT，证明者的运行时间与电路大小成线性关系。HyperPlonk 引入了一种适用于较小字段的新置换 IOP，以及一种基于 sumcheck 的批量打开协议，这减少了证明者的工作、证明大小和验证者的时间。

### Folding schemes (2008/2021)

[Nova](https://eprint.iacr.org/2021/370?ref=blog.lambdaclass.com) 引入了折叠（Folding）方案的概念，这是一种实现增量可验证计算（IVC： incrementally verifiable computation）的新方法。IVC 的概念可以追溯到 [Valiant](https://https//iacr.org/archive/tcc2008/49480001/49480001.pdf?ref=blog.lambdaclass.com)，他展示了如何将长度为 k 的两个证明合并为长度为 k 的单个证明。这个想法是，我们可以通过递归地证明从第 i 步到第 I +1 步的执行是正确的，并验证一个证明，证明从第 i−1 步到第 i 步的转换是正确的，来证明任何长时间运行的计算。Nova 很好地处理统一计算；随后它被扩展以处理不同类型的电路，引入了 [Supernova](https://eprint.iacr.org/2022/1758?ref=blog.lambdaclass.com)。Nova 使用 R1CS 的一种放松版本，并在友好的椭圆曲线上工作。使用曲线的友好循环（例如 Pasta 曲线）来实现 IVC，也被用于 Pickles，Mina 的实现简洁状态的主要构建块。然而，折叠的概念与递归 SNARK 验证不同。

累加器的想法与批量证明的概念更深入地联系在一起。[Halo](https://eprint.iacr.org/2019/1021.pdf?ref=blog.lambdaclass.com) 引入了累加的概念作为递归证明组合的替代方案。[Protostar](https://eprint.iacr.org/2023/620?ref=blog.lambdaclass.com) 为 Plonk 提供了一种非统一的 IVC 方案，支持高次门和向量 lookups。

## 使用抗碰撞哈希函数

在 Pinocchio 开发的同时，有一些想法是生成电路/算术方案，可以证明虚拟机的执行正确性。即使开发虚拟机的算术化可能比为一些程序编写专用电路更复杂或不太高效，但它的优势在于可以通过展示在虚拟机中正确执行程序来证明任何复杂的程序。TinyRAM 中的想法随后通过 Cairo vm 的设计得到改进，并且随后的虚拟机（如 zk-evms 或通用目的 zkvms）也得到了改进。使用抗碰撞哈希函数消除了对可信设置或椭圆曲线操作的需求，但代价是证明变得更长。

### TinyRAM（2013）

在 [SNARKs for C](https://eprint.iacr.org/2013/507?ref=blog.lambdaclass.com) 中，他们开发了基于 PCP 的 SNARK，用于证明 C 程序的执行正确性，该程序被编译为 TinyRAM，即精简指令集计算机。

>  备注：PCP，  Probabilistically Checkable Proof 概率可检查证明， 验证者只需阅读证明中随机选择的一小部分内容，就能以很高的置信度检查证明的有效性。与验证者需要检查整个证明的传统证明系统不同，PCP 只需有限的随机性即可实现高效验证。

该计算机采用哈佛结构，具有字节级可寻址的随机存储器。利用非确定性，电路的大小与计算的大小几乎成线性关系，可以高效处理任意和数据相关的循环、控制流和内存访问。

### STARKs（2018）

[STARKs](https://eprint.iacr.org/2018/046?ref=blog.lambdaclass.com) 由 Ben Sasson 等人于 2018 年提出。它们实现了 $$ O(log^2n) $$  的证明大小，具有快速的证明者和验证者，不需要可信设置，并且被推测为后量子安全。它们首次被 Starkware/Starknet 使用，与 Cairo vm 一起。它的关键引入包括代数中间表示（AIR）和 [FRI 协议](https://blog.lambdaclass.com/how-to-code-fri-from-scratch/)（快速 Reed-Solomon 交互式 Oracle 接近证明 Fast Reed-Solomon Interactive Oracle Proof of Proximity ）。它也被其他项目使用（Polygon Miden、Risc0、Winterfell、Neptune），或者看到了一些组件的改编（ZK-Sync 的 Boojum、Plonky2、Starky）。

### Ligero（2017）

[Ligero](https://eprint.iacr.org/2022/1608?ref=blog.lambdaclass.com) 提出了一种证明系统，实现了证明大小为 O(√n) ，其中 n 是电路的大小。它将多项式系数排列成矩阵形式，并使用线性码。
[Brakedown](https://eprint.iacr.org/2021/1043?ref=blog.lambdaclass.com) 建立在 Ligero 的基础上，引入了领域无关多项式承诺方案的概念。

## 一些新的发展

在生产中使用不同的证明系统展示了每种方法的优点，并带动新的发展。例如，plonkish 算术化提供了一种简单的方法来包含自定义门和lookup arguments；FRI 已经显示出作为 PCS 的出色性能，通向了 Plonky。同样，在 AIR 中使用宏积检查（带来了预处理的随机化 AIR）改进了其性能并简化了内存访问参数。基于哈希函数的承诺因其在硬件中的速度或新的适用于 SNARK 的哈希函数的引入而变得流行。

### 新的多项式承诺方案（2023）

随着基于多变量多项式的高效 SNARKs 的出现，例如 Spartan 或 HyperPlonk，人们对适用于这种多项式的新承诺方案产生了更大的兴趣。[Binius](https://blog.lambdaclass.com/snarks-on-binary-fields-binius/)、[Zeromorph](https://eprint.iacr.org/2023/917?ref=blog.lambdaclass.com) 和 [Basefold](https://blog.lambdaclass.com/how-does-basefold-polynomial-commitment-scheme-generalize-fri/) 都提出了对多线性多项式进行承诺的新形式。Binius 的优势在于表示数据类型时没有额外开销（而许多证明系统至少使用 32 位字段元素来表示单个位），并且可以在二进制域上工作。该承诺方案采用了为领域无关而设计的 brakedown。Basefold 将 FRI 推广到除 Reed-Solomon 之外的码，带来了一个领域无关的 PCS。

> 注 领域无关：在领域无关的多项式承诺方案中，承诺过程不依赖于任何特定领域的特定属性。这意味着可以对任何代数结构的多项式做出承诺，如有限域、椭圆曲线，甚至整数环。

### 可定制的约束系统（2023）

[CCS](https://eprint.iacr.org/2023/552?ref=blog.lambdaclass.com) 泛化了 R1CS，同时捕捉了 R1CS、Plonkish 和 AIR 算术化，没有额外开销。使用 CCS 与 Spartan IOP 结合产生了 SuperSpartan，它支持高维约束，而且证明者不需要承担随着约束度量增加而扩展的加密成本。特别是，SuperSpartan 为 AIR 提供了一个线性时间证明的 SNARK。

## 结论

本文描述了自 20 世纪 80 年代中期以来 SNARKs 的进展。计算机科学、数学和硬件的进步，以及区块链的引入，导致了新的更高效的 SNARKs 的出现，为许多可能改变我们社会的应用打开了大门。研究人员和工程师根据他们的需求提出了对 SNARKs 的改进和适应，关注证明大小、内存使用、透明设置、后量子安全、证明时间和验证时间。虽然最初有两条主要线路（SNARKs vs STARKs），但两者之间的界限已经开始消失，试图结合不同证明系统的优势。例如，结合不同的算术化方案与新的多项式承诺方案。我们可以预期，新的证明系统将继续涌现，性能将会提高，对于一些需要一些时间来适应的系统来说，要跟上这些发展将会很困难，除非我们可以轻松地使用这些工具而无需改变一些核心基础设施。 

---

> 本翻译由 [DeCert.me](https://decert.me/) 协助支持， 在 DeCert 构建可信履历，为自己码一个未来。
