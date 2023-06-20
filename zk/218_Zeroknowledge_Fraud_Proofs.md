# Zero-knowledge Fraud Proofs

![zkfp-banner.webp](https://img.learnblockchain.cn/attachments/2023/06/UN3pxZwA648ad470b1e08.webp)

## Introduction

When designing a rollup, one key design consideration is how to ensure security and trust while still increasing the scalability of the underlying Layer 1. For optimistic rollups, security is ensured in the form of fraud proofs: a proof that rollup-level execution was incorrect and that state must be reverted.

Unlike existing optimistic rollups, Layer N does not rely on replaying transactions on-chain for fraud proofs. Instead, Layer N utilizes a novel approach leveraging zero-knowledge proofs and RISC Zero’s zero-knowledge virtual machine.

## A primer on replay proofs

An optimistic rollup posts state updates to the underlying L1 along with the corresponding transactions that move the previous state to the updated state. Suppose we, as a verifier of the rollup, claim that the final state we observe posted to Ethereum is not valid (or, in other words, that the updated state does not correspond to the transactions the rollup posts to DA). From here, we submit a fraud proof, which, if accepted, results in a significant monetary reward.

The simplest approach for a fraud proof is for a smart contract to re-execute the transactions on Ethereum (the L1) and check if the resulting state is accurate, which we will call a “simple replay proof”.

If the block is large, this becomes quite expensive. However, there’s a nice observation we can make here: if the transactions don’t lead to the expected state, then at some point an instruction was executed incorrectly. An “interactive fraud proof” simply finds that instruction. To construct an interactive fraud proof, the verifier performs binary search through a series of challenges between the user and the operator, bisecting the search space in two at each step. Once the verifier points out the first incorrectly executed instruction, the smart contract re-executes it and sees if it was done properly. This clever technique is what Arbitrum calls dissection, which is essentially an extension to the replay proofs we introduced.

However, this raises an important question: how do we ensure the behavior of the on-chain execution and off-chain execution are exactly the same?

## Difficulties with Replay Proofs

The key constraint with both simple replay proofs and interactive proofs is that instructions must be able to be executed the same way on the base layer and on the rollup. In other words, both implementations need to use the same virtual machine (VM) and ensure that the behavior matches.

In the case of Optimism, their previous implementation was a lightly modified Ethereum Virtual Machine they call the Optimism Virtual Machine (OVM) based on Geth. More recently, they’ve developed an on-chain MIPS instruction emulator in Solidity to run the Minigeth interpreter, allowing them to simulate and verify EVM state transitions. Arbitrum uses a modified version of WASM instead, which they call WAVM[1](https://www.layern.com/blog/zkfp#user-content-fn-1). This design means Optimism and Arbitrum can support any language that targets MIPS and WASM respectively.

For both Optimism and Arbitrum however, this means that their respective VMs need to be implemented in Solidity in order for Ethereum to be able to simulate it. Not only that, but each implementation needs to have the exact same behavior. In the case of non-interactive proofs such as with Optimism, the gas cost is also significantly higher as we need to replay every transaction in the block.

## Enter RISC Zero

Instead of replaying all the transactions on-chain, all we need to do is to provide a proof that the state transition is incorrect. This is where the RISC Zero zkVM comes in, a general purpose zero-knowledge virtual machine[2](https://www.layern.com/blog/zkfp#user-content-fn-2).

With RISC Zero, any verifier is able to generate a succinct proof that they took the correct DA transactions corresponding to a particular block and applied it to the initial state. RISC Zero does this by porting Layer N’s execution environment into its zkVM and trustlessly producing a receipt of correct execution. In the case of a dispute, the verifier sends this proof to Layer N’s smart contract on Ethereum, which then checks whether the proof is valid. If the proof is valid and the output state claimed by the proof does not match the one posted on the L1, then there is fraud and we must revert the block.

Instead of WASM or EVM, we leverage RISC Zero by targeting the RISC-V instruction set, which is a common compilation target and thus supported by many programming languages. This enables a wider range of possibilities for the shape and compatibilities of future Layer N’s VMs.

Lastly, despite these benefits of zero-knowledge technology, full zero-knowledge rollups are currently limited by slow proving times and expensive compute. This is why Layer N takes a hybrid approach—only requiring a proof to be generated when there is the possibility of fraud. We call this approach zero-knowledge fraud proofs (ZKFPs).

## Beyond optimistic rollups

The requirement of giving users enough time to notice a fraud and submit a fraud proof imposes a lengthy withdrawal time (usually around 7 days) for current optimistic rollups: an inadequate requirement for a composable financial product[3](https://www.layern.com/blog/zkfp#user-content-fn-3). Although ZKFPs don’t completely solve this, they are able to drastically reduce withdrawal times due to their “one-shot” methodology. Rather than a lengthy back-and-forth bi-section protocol on ETH, ZKFPs allow for a single back-and-forth transaction to prove/disprove fraud.

Looking into the future, Layer N is committed to using the cutting edge for its rollup ecosystem. For example, with Bonsai[4](https://www.layern.com/blog/zkfp#user-content-fn-4), RISC Zero’s general-purpose zero-knowledge proving network, Layer N would be able to fully transition into a ZK-rollup, meaning cryptographic security guarantees and instantaneous withdrawals while keeping high performance. Since Bonsai allows any chain, protocol, or application to tap into its proving network, it is able to act as a secure off-chain execution and compute layer for a wide range of use cases.

In conclusion, Layer N, in collaboration with RISC Zero, is able to pioneer a new scaling methodology with fewer tradeoffs. As such, we are able to build the next generation of truly usable financial products and protocols.

## About Layer N

Layer N is a novel layer 2 network designed to hyper-scale decentralized finance on Ethereum. Layer N aims to provide performance and user experiences similar to modern financial networks, but fully on-chain and decentralized. Developers can build hyperperformant financial applications leveraging shared liquidity and seamless composability. Layer N is bringing the global financial system to Ethereum.

## About RISC Zero

RISC Zero is a startup building the RISC Zero zero-knowledge virtual machine (zkVM) as a major step towards improving the security and trustworthiness of distributed applications. RISC Zero zkVM bridges the gap between zero-knowledge proof (ZKP) research and widely-supported programming languages such as C++ and Rust.

## Footnotes

1. [https://developer.arbitrum.io/inside-arbitrum-nitro(opens in a new tab)](https://developer.arbitrum.io/inside-arbitrum-nitro) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-1)
2. [https://www.risczero.com/(opens in a new tab)](https://www.risczero.com/) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-2)
3. [https://vitalik.ca/general/2021/04/07/sharding.html(opens in a new tab)](https://vitalik.ca/general/2021/04/07/sharding.html) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-3)
4. [https://dev.bonsai.xyz/(opens in a new tab)](https://dev.bonsai.xyz/) [↩](https://www.layern.com/blog/zkfp#user-content-fnref-4)



原文链接：https://www.layern.com/blog/zkfp