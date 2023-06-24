# Zero-knowledge Fraud Proofs零知识欺诈证明

![zkfp-banner.webp](https://img.learnblockchain.cn/attachments/2023/06/UN3pxZwA648ad470b1e08.webp)

## 简介

When designing a rollup, one key design consideration is how to ensure security and trust while still increasing the scalability of the underlying Layer 1. For optimistic rollups, security is ensured in the form of fraud proofs: a proof that rollup-level execution was incorrect and that state must be reverted.
在设计 Rollup（聚合链）时，一个关键的设计考虑因素是如何在提高底层 Layer 1 的可扩展性的同时确保安全性和信任。对于乐观聚合链，安全性是通过欺诈证明来确保的：这是一种证明聚合链级别执行出现错误并且状态必须回滚的证据。

Unlike existing optimistic rollups, Layer N does not rely on replaying transactions on-chain for fraud proofs. Instead, Layer N utilizes a novel approach leveraging zero-knowledge proofs and RISC Zero’s zero-knowledge virtual machine.
与现有的乐观聚合链不同，Layer N 不依赖于在链上重放交易进行欺诈证明。相反，Layer N 利用了一种新颖的方法，利用了零知识证明和 RISC Zero 的零知识虚拟机。

## A primer on replay proofs重放证明简介

An optimistic rollup posts state updates to the underlying L1 along with the corresponding transactions that move the previous state to the updated state. Suppose we, as a verifier of the rollup, claim that the final state we observe posted to Ethereum is not valid (or, in other words, that the updated state does not correspond to the transactions the rollup posts to DA). From here, we submit a fraud proof, which, if accepted, results in a significant monetary reward.
乐观汇总向底层L1发布状态更新，以及将先前状态移动到更新状态的相应事务。假设我们作为汇总的验证器，声称我们观察到的发布到以太坊的最终状态是无效的（或者，换句话说，更新后的状态与汇总发布到DA的交易不对应）。从这里开始，我们提交一份欺诈证明，如果被接受，将获得可观的金钱奖励。

乐观聚合链会将状态更新以及将先前状态转移到更新状态的相应交易一起发布到底层的 L1。假设我们作为聚合链的验证者声称我们观察到发布到以太坊的最终状态无效（换句话说，更新的状态与聚合链发布到数据可用性层（DA）的交易不相符）。在这种情况下，我们会提交一份欺诈证明，如果被接受，将会获得显著的经济奖励。


The simplest approach for a fraud proof is for a smart contract to re-execute the transactions on Ethereum (the L1) and check if the resulting state is accurate, which we will call a “simple replay proof”.
防欺诈最简单的方法是智能合约在以太坊（L1）上重新执行交易，并检查结果是否准确，我们称之为“简单重放证明”。
对于欺诈证明来说，最简单的方法是让一个智能合约在以太坊（L1）上重新执行这些交易，并检查生成的状态是否准确，我们将其称为“简单的重放证明”。

If the block is large, this becomes quite expensive. However, there’s a nice observation we can make here: if the transactions don’t lead to the expected state, then at some point an instruction was executed incorrectly. An “interactive fraud proof” simply finds that instruction. To construct an interactive fraud proof, the verifier performs binary search through a series of challenges between the user and the operator, bisecting the search space in two at each step. Once the verifier points out the first incorrectly executed instruction, the smart contract re-executes it and sees if it was done properly. This clever technique is what Arbitrum calls dissection, which is essentially an extension to the replay proofs we introduced.
如果区块很大，这将变得相当昂贵。然而，我们可以在这里做出一个很好的观察：如果事务没有导致预期的状态，那么在某个时刻某个指令被错误地执行了。“交互式防欺诈”只是找到了这一指示。为了构建交互式防欺诈，验证者通过用户和操作员之间的一系列挑战进行二进制搜索，在每一步将搜索空间一分为二。一旦验证器指出第一条执行错误的指令，智能合约就会重新执行它，并查看它是否正确执行。这种巧妙的技术就是Arbitrum所说的解剖，本质上是我们引入的重放证明的扩展。
如果区块很大，这种方法将变得非常昂贵。然而，我们可以做出一个有趣的观察：如果交易不能导致预期的状态，那么在某个点上执行了错误的指令。一种“交互式欺诈证明”就是找到这个指令。为了构建一个交互式欺诈证明，验证者在用户和操作者之间进行一系列挑战的二分搜索，每一步都将搜索空间二等分。一旦验证者指出了第一个执行错误的指令，智能合约会重新执行它，并检查是否正确执行。这个巧妙的技术被Arbitrum称为解剖(dissection)，它本质上是对我们介绍的重放证明的扩展。

However, this raises an important question: how do we ensure the behavior of the on-chain execution and off-chain execution are exactly the same?
然而，这提出了一个重要的问题：我们如何确保链上执行和链下执行的行为完全相同？
然而，这引发了一个重要的问题：我们如何确保链上执行和链下执行的行为完全相同？

## Difficulties with Replay Proofs重放证明的难点   回放校对的困难

The key constraint with both simple replay proofs and interactive proofs is that instructions must be able to be executed the same way on the base layer and on the rollup. In other words, both implementations need to use the same virtual machine (VM) and ensure that the behavior matches.
简单重放证明和交互式证明的关键约束是指令必须能够在基本层和汇总层上以相同的方式执行。换句话说，两种实现都需要使用相同的虚拟机（VM），并确保行为匹配。
简单重放证明和交互证明都面临一个关键限制，即指令必须能够在基础层和Rollup上以相同的方式执行。换句话说，两种实现都需要使用相同的虚拟机（VM）并确保行为相匹配。

In the case of Optimism, their previous implementation was a lightly modified Ethereum Virtual Machine they call the Optimism Virtual Machine (OVM) based on Geth. More recently, they’ve developed an on-chain MIPS instruction emulator in Solidity to run the Minigeth interpreter, allowing them to simulate and verify EVM state transitions. Arbitrum uses a modified version of WASM instead, which they call WAVM[1](https://www.layern.com/blog/zkfp#user-content-fn-1). This design means Optimism and Arbitrum can support any language that targets MIPS and WASM respectively.
在乐观主义的情况下，他们之前的实现是一个经过轻微修改的以太坊虚拟机，他们称之为基于Geth的乐观主义虚拟机（OVM）。最近，他们在Solidity中开发了一个链上MIPS指令模拟器来运行Minigeth解释器，使他们能够模拟和验证EVM状态转换。Arbitrum使用了WASM的修改版本，他们称之为WAVM[1](https://www.layern.com/blog/zkfp#user-内容-fn-1）。这种设计意味着Optimism和Arbitrum可以分别支持任何针对MIPS和WASM的语言。
就Optimism而言，他们以Geth为基础，对以太坊虚拟机进行了轻微修改，称之为Optimism虚拟机（OVM）。最近，他们还开发了一个基于Solidity的链上MIPS指令模拟器，用于运行Minigeth解释器，从而可以模拟和验证EVM状态转换。而Arbitrum则使用了修改版的WASM，称之为WAVM。这种设计意味着Optimism和Arbitrum可以分别支持针对MIPS和WASM的任何编程语言。

For both Optimism and Arbitrum however, this means that their respective VMs need to be implemented in Solidity in order for Ethereum to be able to simulate it. Not only that, but each implementation needs to have the exact same behavior. In the case of non-interactive proofs such as with Optimism, the gas cost is also significantly higher as we need to replay every transaction in the block.
然而，对于Optimism和Arbitrum来说，这意味着它们各自的虚拟机需要在Solidity中实现，以便以太坊能够模拟它。不仅如此，每个实现都需要具有完全相同的行为。在非交互式证明的情况下，如乐观主义，天然气成本也明显更高，因为我们需要回放区块中的每一笔交易。
然而，对于Optimism和Arbitrum而言，这意味着它们各自的虚拟机需要在Solidity中实现，以便以太坊能够模拟它。不仅如此，每个实现还需要具有完全相同的行为。对于像Optimism这样的非交互式证明，燃料成本也显著较高，因为我们需要重放区块中的每个交易。

## Enter RISC Zero  引入RISC Zero  RISC Zero登场  输入RISC零

Instead of replaying all the transactions on-chain, all we need to do is to provide a proof that the state transition is incorrect. This is where the RISC Zero zkVM comes in, a general purpose zero-knowledge virtual machine[2](https://www.layern.com/blog/zkfp#user-content-fn-2).
我们所需要做的不是重放链上的所有事务，而是提供状态转换不正确的证据。这就是RISC Zero zkVM的用武之地，它是一种通用的零知识虚拟机[2](https://www.layern.com/blog/zkfp#user-内容-fn-2）。
与其在链上重放所有交易，我们只需要提供一个证明，证明状态转换是不正确的。这就是 RISC Zero zkVM 的用武之地，它是一个通用的零知识虚拟机。

With RISC Zero, any verifier is able to generate a succinct proof that they took the correct DA transactions corresponding to a particular block and applied it to the initial state. RISC Zero does this by porting Layer N’s execution environment into its zkVM and trustlessly producing a receipt of correct execution. In the case of a dispute, the verifier sends this proof to Layer N’s smart contract on Ethereum, which then checks whether the proof is valid. If the proof is valid and the output state claimed by the proof does not match the one posted on the L1, then there is fraud and we must revert the block.
使用RISC Zero，任何验证器都能够生成一个简洁的证据，证明他们采取了与特定块相对应的正确DA事务，并将其应用于初始状态。RISC Zero通过将第N层的执行环境移植到其zkVM中并可靠地生成正确执行的收据来实现这一点。在发生争议的情况下，验证器将此证明发送到以太坊上的第N层智能合约，然后由其检查该证明是否有效。如果证明是有效的，并且证明声称的输出状态与L1上发布的状态不匹配，则存在欺诈，我们必须恢复块。
通过RISC Zero，任何验证者都能够生成一个简洁的证明，证明他们获取了与特定区块对应的正确的DA交易，并将其应用于初始状态。RISC Zero通过将Layer N的执行环境移植到其zkVM中，并可信地产生正确执行的收据来实现这一点。在发生争议的情况下，验证者将此证明发送到Layer N在以太坊上的智能合约，然后智能合约会检查该证明是否有效。如果证明有效且证明所声称的输出状态与在L1上发布的状态不符，则存在欺诈行为，我们必须回滚该区块。

Instead of WASM or EVM, we leverage RISC Zero by targeting the RISC-V instruction set, which is a common compilation target and thus supported by many programming languages. This enables a wider range of possibilities for the shape and compatibilities of future Layer N’s VMs.
与WASM或EVM不同，我们通过瞄准RISC-V指令集来利用RISC Zero，RISC-V是一个常见的编译目标，因此受到许多编程语言的支持。这为未来第N层虚拟机的形状和兼容性提供了更广泛的可能性。
与使用WASM或EVM不同，我们通过针对RISC-V指令集来利用RISC Zero，RISC-V是一种常见的编译目标，因此得到许多编程语言的支持。这为未来Layer N的虚拟机的形态和兼容性提供了更广泛的可能性。

Lastly, despite these benefits of zero-knowledge technology, full zero-knowledge rollups are currently limited by slow proving times and expensive compute. This is why Layer N takes a hybrid approach—only requiring a proof to be generated when there is the possibility of fraud. We call this approach zero-knowledge fraud proofs (ZKFPs).
最后，尽管零知识技术有这些好处，但全零知识汇总目前受到缓慢的证明时间和昂贵的计算的限制。这就是为什么第N层采用混合方法，只需要在存在欺诈可能性时生成证据。我们称这种方法为零知识欺诈证明（ZKFP）。
最后，尽管零知识技术具有这些好处，但完全的零知识 Rollup 目前受到证明时间长和计算成本高的限制。这就是为什么 Layer N 采用混合方法——只在存在欺诈可能性时需要生成证明。我们将这种方法称为零知识欺诈证明（ZKFPs）。

## Beyond optimistic rollups  超越乐观的汇总  超越乐观 Rollup

The requirement of giving users enough time to notice a fraud and submit a fraud proof imposes a lengthy withdrawal time (usually around 7 days) for current optimistic rollups: an inadequate requirement for a composable financial product[3](https://www.layern.com/blog/zkfp#user-content-fn-3). Although ZKFPs don’t completely solve this, they are able to drastically reduce withdrawal times due to their “one-shot” methodology. Rather than a lengthy back-and-forth bi-section protocol on ETH, ZKFPs allow for a single back-and-forth transaction to prove/disprove fraud.
给用户足够的时间来通知欺诈行为并提交欺诈证明的要求为当前的乐观汇总带来了漫长的提款时间（通常约7天）：对可组合金融产品的要求不足[3](https://www.layern.com/blog/zkfp#user-内容-fn-3）。尽管ZKFP并不能完全解决这个问题，但由于其“一次性”方法，它们能够大幅减少退出时间。ZKFP不是ETH上冗长的来回双节协议，而是允许一次来回交易来证明/反驳欺诈。
对于当前的乐观 Rollup，为了给用户足够的时间发现欺诈并提交欺诈证明，需要较长的提款时间（通常约为7天），这对于可组合的金融产品来说是不充分的要求。虽然 ZKFPs 并不能完全解决这个问题，但它们能够显著缩短提款时间，这是由于它们采用了“一次性”的方法。与在以太坊上进行漫长的来回二分协议不同，ZKFPs 只需要进行一次来回交易来证明或证伪欺诈。

Looking into the future, Layer N is committed to using the cutting edge for its rollup ecosystem. For example, with Bonsai[4](https://www.layern.com/blog/zkfp#user-content-fn-4), RISC Zero’s general-purpose zero-knowledge proving network, Layer N would be able to fully transition into a ZK-rollup, meaning cryptographic security guarantees and instantaneous withdrawals while keeping high performance. Since Bonsai allows any chain, protocol, or application to tap into its proving network, it is able to act as a secure off-chain execution and compute layer for a wide range of use cases.
展望未来，Layer N致力于在其Rollup生态系统中使用尖端技术。例如，通过使用Bonsai，RISC Zero的通用零知识证明网络，Layer N将能够完全过渡到ZK-Rollup，这意味着具有密码学安全性保证和即时提款，同时保持高性能。由于Bonsai允许任何链、协议或应用程序连接到其证明网络，它能够作为一个安全的离链执行和计算层，适用于广泛的用例。

展望未来，Layer N致力于为其汇总生态系统使用尖端技术。例如，盆景[4](https://www.layern.com/blog/zkfp#user-content-fn-4），RISC Zero的通用零知识证明网络，第N层将能够完全过渡到ZK汇总，这意味着加密安全保证和即时提款，同时保持高性能。由于Bonsai允许任何链、协议或应用程序进入其证明网络，因此它能够在各种用例中充当安全的链外执行和计算层。

In conclusion, Layer N, in collaboration with RISC Zero, is able to pioneer a new scaling methodology with fewer tradeoffs. As such, we are able to build the next generation of truly usable financial products and protocols.
总之，第N层与RISC Zero合作，能够以较少的权衡开创一种新的扩展方法。因此，我们能够构建下一代真正可用的金融产品和协议。
总结来说，Layer N与RISC Zero的合作能够开创一种具有较少权衡的新型扩展方法。因此，我们能够构建下一代真正可用的金融产品和协议。

## About Layer N  关于Layer N

Layer N is a novel layer 2 network designed to hyper-scale decentralized finance on Ethereum. Layer N aims to provide performance and user experiences similar to modern financial networks, but fully on-chain and decentralized. Developers can build hyperperformant financial applications leveraging shared liquidity and seamless composability. Layer N is bringing the global financial system to Ethereum.
第N层是一种新型的第2层网络，旨在以太坊上实现超规模去中心化金融。第N层旨在提供类似于现代金融网络的性能和用户体验，但完全在链上和去中心化。开发人员可以利用共享的流动性和无缝的可组合性构建性能卓越的金融应用程序。第N层正在将全球金融体系带到以太坊。

Layer N是一个新颖的Layer 2网络，旨在将以太坊上的去中心化金融（DeFi）进行超大规模扩展。Layer N的目标是提供类似于现代金融网络的性能和用户体验，但完全基于链上和去中心化。开发人员可以构建超高性能的金融应用，利用共享流动性和无缝互操作性。Layer N正在将全球金融系统引入以太坊。

## About RISC Zero 关于RISC Zero

RISC Zero is a startup building the RISC Zero zero-knowledge virtual machine (zkVM) as a major step towards improving the security and trustworthiness of distributed applications. RISC Zero zkVM bridges the gap between zero-knowledge proof (ZKP) research and widely-supported programming languages such as C++ and Rust.
RISC Zero是一家初创公司，它构建了RISC Zero-知识虚拟机（zkVM），作为提高分布式应用程序安全性和可信度的重要一步。RISC Zero zkVM弥补了零知识证明（ZKP）研究与广泛支持的编程语言（如C++和Rust）之间的差距。

RISC Zero是一家初创公司，致力于构建RISC Zero零知识虚拟机（zkVM），以改善分布式应用程序的安全性和可信性。RISC Zero zkVM填补了零知识证明（ZKP）研究与广泛支持的编程语言（如C++和Rust）之间的差距。通过RISC Zero zkVM，开发者可以在具有广泛语言支持的环境中应用零知识证明技术，从而增强分布式应用程序的安全性和可靠性。

## Footnotes

1. [https://developer.arbitrum.io/inside-arbitrum-nitro(opens in a new tab)](https://developer.arbitrum.io/inside-arbitrum-nitro) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-1)
2. [https://www.risczero.com/(opens in a new tab)](https://www.risczero.com/) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-2)
3. [https://vitalik.ca/general/2021/04/07/sharding.html(opens in a new tab)](https://vitalik.ca/general/2021/04/07/sharding.html) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-3)
4. [https://dev.bonsai.xyz/(opens in a new tab)](https://dev.bonsai.xyz/) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-4)



原文链接：https://www.layern.com/blog/zkfp
