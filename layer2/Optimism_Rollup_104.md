原文链接：https://research.paradigm.xyz/optimism

# How does Optimism's Rollup really work?

At Paradigm, we work very closely with the companies in our portfolio. That work includes diving deep with them in their protocol design and implementation.

We [recently talked](https://research.paradigm.xyz/rollups) about the mechanics of Optimistic Rollup (OR), the dominant solution for scaling Ethereum while preserving its flourishing developer ecosystem. In this post, we do a deep dive on [Optimism](https://research.paradigm.xyz/optimism.io), the company which invented the first EVM-compatible Optimistic Rollup protocol *(Disclosure: Paradigm is an investor in Optimism)*.

This article is for everyone who is familiar with Optimistic Rollup as a mechanism and wants to learn how Optimism’s solution works, and evaluate the proposed system’s performance and security.

We explain the motivation behind each design decision and then proceed to dissect Optimism’s system, along with links to the corresponding code for each analyzed component.

# Table of Contents

1. [The importance of software reuse in Optimism](https://research.paradigm.xyz/optimism#the-importance-of-software-reuse-in-optimism)
2. [The Optimistic Virtual Machine](https://research.paradigm.xyz/optimism#the-optimistic-virtual-machine)
3. [Optimistic Solidity](https://research.paradigm.xyz/optimism#optimistic-solidity)
4. [Optimistic Geth](https://research.paradigm.xyz/optimism#optimistic-geth)
5. The Optimistic Rollup
   1. [Data Availability batches](https://research.paradigm.xyz/optimism#data-availability-batches)
   2. [State Commitments](https://research.paradigm.xyz/optimism#state-commitments)
   3. [Fraud Proofs](https://research.paradigm.xyz/optimism#fraud-proofs)
   4. [Incentives & Bonds](https://research.paradigm.xyz/optimism#incentives--bonds)
   5. [Nuisance Gas](https://research.paradigm.xyz/optimism#nuisance-gas)
6. [Review & Conclusion](https://research.paradigm.xyz/optimism#review--conclusion)
7. Appendix
   1. [OVM Opcodes](https://research.paradigm.xyz/optimism#ovm-opcodes)
   2. [L1 to L2 Interoperability](https://research.paradigm.xyz/optimism#l1-to-l2-interoperability)
   3. [Account Abstraction](https://research.paradigm.xyz/optimism#account-abstraction)

# The importance of software reuse in Optimism

Ethereum has developed a moat around its developer ecosystem. The developer stack is comprised of:

- [Solidity](https://docs.soliditylang.org/en/v0.8.0/) / [Vyper](https://vyper.readthedocs.io/en/stable/): The 2 main smart contract programming languages which have large toolchains (e.g. [Ethers](https://github.com/ethers-io/ethers.js/), [Hardhat](https://github.com/nomiclabs/hardhat), [dapp](http://dapp.tools/), [slither](https://github.com/crytic/slither)) built around them.
- Ethereum Virtual Machine: The most popular blockchain virtual machine to date, the internals of which are understood much better than any alternative blockchain VM.
- [Go-ethereum](https://github.com/ethereum/go-ethereum): The dominant Ethereum protocol implementation which makes up for >75% of the network’s nodes. It is extensively tested, fuzzed (even finding bugs in [golang itself](https://github.com/golang/go/issues/42553)!) and as many would call it: “[lindy](https://en.wikipedia.org/wiki/Lindy_effect)”.

Since Optimism is targeting Ethereum as its Layer 1, it would be nice if we could reuse all of the existing tooling, with little/no modifications necessary. This would improve developer experience as devs wouldn’t need to learn a new technology stack. The above DevEx argument has been laid out multiple times, but I’d like to emphasize another implication of software reuse: security.

Blockchain security is critical. You cannot afford to get things wrong when you are handling other people’s money. **By performing “surgery” on the existing tooling, instead of re-inventing the wheel, we can preserve most of the security properties the software had before our intervention.** Auditing then becomes a simple matter of inspecting the difference from the original, instead of re-inspecting a codebase that’s potentially 100k+ lines of code.

As a result, Optimism has created “optimistic” variants of each piece of the stack. We will now go through them one by one:

# The Optimistic Virtual Machine

Optimistic Rollups rely on using fraud proofs to prevent invalid state transitions from happening. This requires executing an Optimism transaction on Ethereum. In simple terms, if there was a dispute about the result of a transaction that e.g. modified Alice’s ETH balance, Alice would try to replay that exact transaction on Ethereum to demonstrate the correct result there[1](https://research.paradigm.xyz/optimism#fn:1). However, certain EVM opcodes would not behave the same on L1 and L2 if they rely on system-wide parameters which change all the time such as loading or storing state, or getting the current timestamp.

As a result, the first step towards resolving a dispute about L2 on L1 is a mechanism which guarantees that it’s possible to reproduce any “context” that existed at the time the L2 transaction was executed on L1 (ideally without too much overhead).

**Goal: A sandboxed environment which guarantees deterministic smart contract execution between L1 and L2.**

Optimism’s solution is the [Optimistic Virtual Machine](https://medium.com/ethereum-optimism/ovm-deep-dive-a300d1085f52). The OVM is implemented by replacing context-dependent EVM opcodes with their OVM counterparts.

A simple example would be:

1. A L2 transaction calls the `TIMESTAMP` opcode, returning e.g. 1610889676
2. An hour later, the transaction (for any reason) has to be replayed on Ethereum L1 during a dispute
3. If that transaction were to be executed normally in the EVM, the `TIMESTAMP` opcode would return 1610889676 + 3600. We don’t want that!
4. In the OVM, the `TIMESTAMP` opcode is replaced with `ovmTIMESTAMP` which would show the correct value, at the time the transaction was executed on L2

All context-dependent EVM opcodes have an `ovm{OPCODE}` counterpart in the core OVM smart contract, the [`ExecutionManager`](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L197-L754). Contract execution starts via the EM’s main entrypoint, the [`run` function](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L135-L140). These opcodes are also modified to have a pluggable [state database](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L148-L150) to interact with, for reasons we’ll dive into in the Fraud Proofs section.

Certain opcodes which do not “make sense” in the OVM are disallowed via Optimism’s [`SafetyChecker`](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_SafetyChecker.sol#L20-L27), a smart contract which effectively acts as a static analyzer returning 1 or 0, depending on if the contract is “OVM-safe”.

We refer you to the appendix for a complete explanation of each modified/banned opcode.

Optimism’s Rollup looks like this:

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/GBTJpBPD62b3cc43a4cec.png)

Figure 1: The Optimistic Virtual Machine

The area marked with a question mark will be covered in the Fraud Proofs section, but before that, we must cover some additional ground.

# Optimistic Solidity

Now that we have our sandbox, the OVM, we need to make our smart contracts compile to OVM bytecode. Here are some of our options:

- Create a new smart contract language that compiles down to OVM: A new smart contract language is an easy to dismiss idea since it requires re-doing everything from scratch, and we’ve already agreed we don’t do that here.
- Transpile EVM bytecode to OVM bytecode: was [tried](https://github.com/ethereum-optimism/optimism-monorepo/blob/2ca62fb41be6ef69b0c07a1bd5502ac425aaf341/packages/solc-transpiler/src/compiler.ts#L420-L496) but abandoned due to complexity.
- Support Solidity and Vyper by modifying their compilers to produce OVM bytecode.

The currently used approach is the 3rd. Optimism forked solc and [changed ~500 lines](https://github.com/ethereum-optimism/solidity/compare/27d51765c0623c9f6aef7c00214e9fe705c331b1...develop-0.6) (with [a little help](https://twitter.com/jinglanW/status/1310718738417811459)).

The Solidity compiler works by converting the Solidity to Yul then into EVM Instructions and finally into bytecode. The change made by Optimism is simple yet elegant: For each opcode, after compiling to EVM assembly, try to “rewrite” it in its ovm variant if needed (or throw an error if it’s banned).

This is a bit contrived to explain, so let’s use an example by comparing the EVM and OVM bytecodes of this simple contract:

![Kitten](https://img.learnblockchain.cn/attachments/2022/06/oXFq3gKx62b3cc8a05446.png)

```
$ solc C.sol --bin-runtime --optimize --optimize-runs 200
6080604052348015600f57600080fd5b506004361060285760003560e01c8063c298557814602d575b600080fd5b60336035565b005b60008054600101905556fea264697066735822122001fa42ea2b3ac80487c9556a210c5bbbbc1b849ea597dd6c99fafbc988e2a9a164736f6c634300060c0033
```

We can [disassemble](https://github.com/daejunpark/evm-disassembler) this code and dive into the opcodes[2](https://research.paradigm.xyz/optimism#fn:14) to see what’s going on (Program Counter in brackets):

```
...
[025] 35 CALLDATALOAD
...
[030] 63 PUSH4 0xc2985578 // id("foo()")
[035] 14 EQ
[036] 60 PUSH1 0x2d // int: 45
[038] 57 JUMPI // jump to PC 45
...
[045] 60 PUSH1 0x33
[047] 60 PUSH1 0x35 // int: 53
[049] 56 JUMP // jump  to PC 53
...
[053] 60 PUSH1 0x00
[055] 80 DUP1
[056] 54 SLOAD // load the 0th storage slot
[057] 60 PUSH1 0x01
[059] 01 ADD // add 1 to it
[060] 90 SWAP1
[061] 55 SSTORE // store it back
[062] 56 JUMP
...
```

What this assembly says is that if there’s a match between the calldata and the function selector of `foo()`[3](https://research.paradigm.xyz/optimism#fn:2), then `SLOAD` the storage variable at `0x00`, add `0x01` to it and `SSTORE` it back. Sounds about right!

How does this look in OVM[4](https://research.paradigm.xyz/optimism#fn:3)?

```
$ osolc C.sol --bin-runtime --optimize --optimize-runs 200
60806040523480156100195760008061001661006e565b50505b50600436106100345760003560e01c8063c298557814610042575b60008061003f61006e565b50505b61004a61004c565b005b6001600080828261005b6100d9565b019250508190610069610134565b505050565b632a2a7adb598160e01b8152600481016020815285602082015260005b868110156100a657808601518282016040015260200161008b565b506020828760640184336000905af158601d01573d60011458600c01573d6000803e3d621234565260ea61109c52505050565b6303daa959598160e01b8152836004820152602081602483336000905af158601d01573d60011458600c01573d6000803e3d621234565260ea61109c528051935060005b60408110156100695760008282015260200161011d565b6322bd64c0598160e01b8152836004820152846024820152600081604483336000905af158601d01573d60011458600c01573d6000803e3d621234565260ea61109c5260008152602061011d56
```

This is much bigger, let’s disassemble it again and see what changed:

```
...
[036] 35 CALLDATALOAD
...
[041] 63 PUSH4 0xc2985578 // id("foo()")
[046] 14 EQ
[047] 61 PUSH2 0x0042
[050] 57 JUMPI // jump to PC 66
...
[066] 61 PUSH2 0x004a
[069] 61 PUSH2 0x004c // int: 76
[072] 56 JUMP // jump to PC 76
```

Matching the function selector is the same with before, let’s look at what happens afterwards:

```
...
[076] 60 PUSH1 0x01 // Push 1 to the stack (to be used for the addition later)
[078] 60 PUSH1 0x00
[080] 80 DUP1
[081] 82 DUP3
[082] 82 DUP3
[083] 61 PUSH2 0x005b
[086] 61 PUSH2 0x00d9 (int: 217)
[089] 56 JUMP // jump to PC 217
...
[217] 63 PUSH4 0x03daa959       // <---|  id("ovmSLOAD(bytes32)")
[222] 59 MSIZE                  //     |                                       
[223] 81 DUP2                   //     |                                       
[224] 60 PUSH1 0xe0             //     |                                       
[226] 1b SHL                    //     |                                       
[227] 81 DUP2                   //     |                                       
[228] 52 MSTORE                 //     |                                       
[229] 83 DUP4                   //     |                                       
[230] 60 PUSH1 0x04             //     | CALL to the CALLER's ovmSLOAD
[232] 82 DUP3                   //     |                                       
[233] 01 ADD                    //     |                                       
[234] 52 MSTORE                 //     |                                       
[235] 60 PUSH1 0x20             //     |                                       
[237] 81 DUP2                   //     |  
[238] 60 PUSH1 0x24             //     |                                     
[240] 83 DUP4                   //     |                                       
[241] 33 CALLER                 //     |                                       
[242] 60 PUSH1 0x00             //     |                                       
[244] 90 SWAP1                  //     |                                       
[245] 5a GAS                    //     |                                       
[246] f1 CALL                   // <---|

[247] 58 PC                     // <---|  
[248] 60 PUSH1 0x1d             //     |                                       
[250] 01 ADD                    //     |                                       
[251] 57 JUMPI                  //     |                                       
[252] 3d RETURNDATASIZE         //     |                                       
[253] 60 PUSH1 0x01             //     |                                       
[255] 14 EQ                     //     |                                       
[256] 58 PC                     //     |                                       
[257] 60 PUSH1 0x0c             //     |                                       
[259] 01 ADD                    //     |                                       
[260] 57 JUMPI                  //     |  Handle the returned data             
[261] 3d RETURNDATASIZE         //     |                                       
[262] 60 PUSH1 0x00             //     |                                       
[264] 80 DUP1                   //     |                                       
[265] 3e RETURNDATACOPY         //     |                                       
[266] 3d RETURNDATASIZE         //     |                                       
[267] 62 PUSH3 0x123456         //     |                                       
[271] 52 MSTORE                 //     |                                       
[272] 60 PUSH1 0xea             //     |                                       
[274] 61 PUSH2 0x109c           //     |                                       
[277] 52 MSTORE                 // <---|                                                            
```

There’s a lot going on here. The gist of it however is that instead of doing an `SLOAD`, the bytecode builds up the stack to make a `CALL`. The receiver of the call is pushed to the stack via the `CALLER` opcode. Every call comes from the EM, so in practice, `CALLER` is an efficient way to call the EM. The data of the call starts with the selector for `ovmSLOAD(bytes32)`, followed by its arguments (in this case, just a 32 bytes word). After that, the returned data is handled and added into memory.

Moving on:

```
...
[297] 82 DUP3
[298] 01 ADD // Adds the 3rd item on the stack to the ovmSLOAD value
[299] 52 MSTORE
[308] 63 PUSH4 0x22bd64c0  // <---| id("ovmSSTORE(bytes32,bytes32)")
[313] 59 MSIZE             //     |                                                           
[314] 81 DUP2              //     |                                                            
[315] 60 PUSH1 0xe0        //     |                                                                  
[317] 1b SHL               //     |                                                           
[318] 81 DUP2              //     |                                                            
[319] 52 MSTORE            //     |                                                              
[320] 83 DUP4              //     |                                                            
[321] 60 PUSH1 0x04        //     |                                                                  
[323] 82 DUP3              //     |                                                            
[324] 01 ADD               //     |  CALL to the CALLER's ovmSSTORE
[325] 52 MSTORE            //     |  (RETURNDATA handling is omited
[326] 84 DUP5              //     |   because it is identical to ovmSSLOAD)
[327] 60 PUSH1 0x24        //     |                                                                  
[329] 82 DUP3              //     |                                                            
[330] 01 ADD               //     |                                                           
[331] 52 MSTORE            //     |                                                              
[332] 60 PUSH1 0x00        //     |                                                                  
[334] 81 DUP2              //     |                                                            
[335] 60 PUSH1 0x44        //     |                                                                  
[337] 83 DUP4              //     |                                                            
[338] 33 CALLER            //     |                                                              
[339] 60 PUSH1 0x00        //     |                                                                  
[341] 90 SWAP1             //     |                                                             
[342] 5a GAS               //     |                                                           
[343] f1 CALL              // <---|                                                            
...
```

Similarly to how `SLOAD` was rewired to an external call to `ovmSLOAD`, `SSTORE` is rewired to make an external call to `ovmSSTORE`. The call’s data is different because `ovmSSTORE` requires 2 arguments, the storage slot and the value being stored. Here’s a side by side comparison:

| ovmSLOAD                  | ovmSSTORE                 |
| ------------------------- | ------------------------- |
| [217] 63 PUSH4 0x03daa959 | [308] 63 PUSH4 0x22bd64c0 |
| [222] 59 MSIZE            | [313] 59 MSIZE            |
| [223] 81 DUP2             | [314] 81 DUP2             |
| [224] 60 PUSH1 0xe0       | [315] 60 PUSH1 0xe0       |
| [226] 1b SHL              | [317] 1b SHL              |
| [227] 81 DUP2             | [318] 81 DUP2             |
| [228] 52 MSTORE           | [319] 52 MSTORE           |
| [229] 83 DUP4             | [320] 83 DUP4             |
| [230] 60 PUSH1 0x04       | [321] 60 PUSH1 0x04       |
| [232] 82 DUP3             | [323] 82 DUP3             |
| [233] 01 ADD              | [324] 01 ADD              |
| [234] 52 MSTORE           | [325] 52 MSTORE           |
| [235] 60 PUSH1 0x20       | [326] 84 DUP5             |
| [237] 81 DUP2             | [327] 60 PUSH1 0x24       |
| [238] 60 PUSH1 0x24       | [329] 82 DUP3             |
| [240] 83 DUP4             | [330] 01 ADD              |
| [241] 33 CALLER           | [331] 52 MSTORE           |
| [242] 60 PUSH1 0x00       | [332] 60 PUSH1 0x00       |
| [244] 90 SWAP1            | [334] 81 DUP2             |
| [245] 5a GAS              | [335] 60 PUSH1 0x44       |
| [246] f1 CALL             | [337] 83 DUP4             |
|                           | [338] 33 CALLER           |
|                           | [339] 60 PUSH1 0x00       |
|                           | [341] 90 SWAP1            |
|                           | [342] 5a GAS              |
|                           | [343] f1 CALL             |


Effectively, **instead of making an `SLOAD` and then a `SSTORE`, we’re making a call to the Execution Manager’s `ovmSLOAD` and then its `ovmSSTORE` methods.**

Comparing the EVM vs OVM execution (we only show the `SLOAD` part of the execution), we can see the virtualization happening via the Execution Manager. This functionality is implemented [here](https://github.com/ethereum-optimism/solidity/blob/416121951c95b2af1120f39a0c89fe1479deeca4/libyul/backends/evm/EVMDialect.cpp#L117-L150) and [here](https://github.com/ethereum-optimism/solidity/blob/df005f39493525b43f1153dff8da5910a2b83e34/libsolidity/codegen/CompilerContext.cpp#L64-L367).

| EVM                                                          | OVM                                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![alt_text](https://img.learnblockchain.cn/attachments/2022/06/mASu6MTS62b3cd0555e13.png) | ![alt_text](https://img.learnblockchain.cn/attachments/2022/06/LwLE1RrF62b3cd093d6fe.png) |

Figure 2: EVM vs OVM execution

There’s a “gotcha” of this virtualization technique:

The contract size limit gets hit faster: Normally, Ethereum contracts can be up to 24KB in bytecode size[5](https://research.paradigm.xyz/optimism#fn:4). A contract compiled with the Optimistic Solidity Compiler ends up bigger than it was, meaning that contracts near the 24KB limit must be refactored so that their OVM size still fits in the 24KB limit since they need to be executable on Ethereum mainnet (e.g. by making external calls to libraries instead of inlining the library bytecode.) The contract size limit remains the same as OVM contracts must be deployable on Ethereum.

# Optimistic Geth

The most popular implementation of Ethereum is go-ethereum (aka geth). Let’s see how a transaction typically gets executed in go-ethereum.

On each [block](https://github.com/ethereum/go-ethereum/blob/7770e41cb5fcc386a7d2329d1187174839122f24/core/blockchain.go#L1889), the state processor’s [`Process`](https://github.com/ethereum/go-ethereum/blob/7770e41cb5fcc386a7d2329d1187174839122f24/core/state_processor.go#L58) is called which calls [`ApplyTransaction`](https://github.com/ethereum/go-ethereum/blob/6487c002f6b47e08cb9814f16712c6789b313a97/core/state_processor.go#L88) on each transaction. Internally, transactions are converted to [messages](https://github.com/ethereum/go-ethereum/blob/6487c002f6b47e08cb9814f16712c6789b313a97/core/types/transaction.go#L227-L246)[6](https://research.paradigm.xyz/optimism#fn:5), messages get applied on the current state, and the newly produced state is finally stored back in the database.

This core data flow remains the same on Optimistic Geth, with some modifications to make transactions “OVM friendly”:

**Modification 1: OVM Messages via the Sequencer Entrypoint**

Transactions get converted to [OVM Messages](https://github.com/ethereum-optimism/go-ethereum/blob/f8b6a248713a2636a491d1727dc4d62c2c8bfa49/core/state_processor.go#L93-L97). Since messages are stripped of their signature, [the message data is modded](https://github.com/ethereum-optimism/go-ethereum/blob/e3c17388429335dfe5d6af1993e624c16c5df881/core/state_transition_ovm.go#L68-L118) to include the transaction signature (along with the rest of the original transaction’s fields). The `to` field gets replaced with the “[sequencer entrypoint](https://github.com/ethereum-optimism/contracts-v2/blob/c1851bac8114e1e600a98d143b977c5a026ba20e/contracts/optimistic-ethereum/OVM/precompiles/OVM_SequencerEntrypoint.sol#L28-L87)” contract’s address. This is done in order to have a compact transaction format, since it will be published to Ethereum, and we’ve established that the better our compression, the better our scaling benefits.

**Modification 2: OVM sandboxing via the Execution Manager**

In order to run transactions through the OVM sandbox, they _must _be sent to the Execution Manager’s `run `function. Instead of requiring that users submit only transactions which match that restriction, all messages are [modded](https://github.com/ethereum-optimism/go-ethereum/blob/e3c17388429335dfe5d6af1993e624c16c5df881/core/state_transition.go#L207-L214) to be sent to the Execution Manager internally. What happens here is simple: The message’s `to` field is replaced by the Execution Manager’s address, and the message’s original data is [packed as arguments to run](https://github.com/ethereum-optimism/go-ethereum/blob/e3c17388429335dfe5d6af1993e624c16c5df881/core/state_transition_ovm.go#L37-L54).

As this might be a bit unintuitive, we’ve put together a repository to give a concrete example: https://github.com/gakonst/optimism-tx-format.

**Modification 3: Intercept calls to the State Manager**

The StateManager is a special contract which..doesn’t exist on Optimistic Geth[7](https://research.paradigm.xyz/optimism#fn:6). It only gets deployed during fraud proofs. The careful reader will notice that when the arguments are packed to make the `run` call, Optimism’s geth also packs a hardcoded State Manager address. That’s what ends up getting used as the final destination of any `ovmSSTORE` or `ovmSLOAD` (or similar) calls. When running on L2, any messages targeting the State Manager contract get [intercepted](https://github.com/ethereum-optimism/go-ethereum/blob/f2e33654675e71b3eda4bd2ad2d07efb5aa65a42/core/vm/evm.go#L80-L88), and they are wired to [directly talk to Geth’s StateDB (or do nothing)](https://github.com/ethereum-optimism/go-ethereum/blob/f2e33654675e71b3eda4bd2ad2d07efb5aa65a42/core/vm/ovm_state_manager.go).

To people looking for overall code changes, the best way to do this is by searching for *[UsingOVM](https://github.com/ethereum-optimism/go-ethereum/search?q=UsingOVM)* and by comparing the [diff from geth 1.9.10](https://github.com/ethereum-optimism/go-ethereum/compare/58cf5686eab9019cc01e202e846a6bbc70a3301d...master).

**Modification 4: Epoch-based batches instead of blocks**

The OVM does not have blocks, it just maintains an ordered list of transactions. Because of this, there is no notion of a block gas limit; instead, the overall gas consumption is rate limited based on time segments, called epochs[8](https://research.paradigm.xyz/optimism#fn:7). Before a transaction is executed, there’s a [check](https://github.com/ethereum-optimism/contracts-v2/blob/aad70cd7a85ddeb9fbeb90b51429864792aa9757/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L158-L159) to see if a new epoch needs to be started, and after execution its gas consumption is [added](https://github.com/ethereum-optimism/contracts-v2/blob/aad70cd7a85ddeb9fbeb90b51429864792aa9757/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1596-L1623) on the cumulative gas used for that epoch. There is a separate gas limit per epoch for sequencer submitted transactions and “L1 to L2” transactions. Any transactions [exceeding the gas limit](https://github.com/ethereum-optimism/contracts-v2/blob/aad70cd7a85ddeb9fbeb90b51429864792aa9757/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1552-L1594) for an epoch [return early.](https://github.com/ethereum-optimism/contracts-v2/blob/aad70cd7a85ddeb9fbeb90b51429864792aa9757/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L161-L165) This implies that an operator can post several transactions with varying timestamps in one on-chain batch ([timestamps are defined by the sequencer](https://github.com/ethereum-optimism/go-ethereum/blob/42c15d285804ce4bd77309dfdb1842c860d5c0f1/miner/worker.go#L867-L879), with some restrictions which we explain in the “Data Availability Batches” section).

**Modification 5: Rollup Sync Service**

The [sync service](https://github.com/ethereum-optimism/go-ethereum/blob/master/rollup/sync_service.go) is a new process that runs [alongside](https://github.com/ethereum-optimism/go-ethereum/blob/c01384ba625fb1714cbfe6a1824ebc991f4c3b7d/eth/backend.go#L212-L215) “normal” geth operations. It is responsible for [monitoring](https://github.com/ethereum-optimism/go-ethereum/blob/master/rollup/sync_service.go#L647-L676) Ethereum logs, [processing](https://github.com/ethereum-optimism/go-ethereum/blob/master/rollup/sync_service.go#L999-L1022) them, and [injecting](https://github.com/ethereum-optimism/go-ethereum/blob/master/rollup/sync_service.go#L943) the corresponding L2 transactions to be applied in the L2 state via [geth’s worker](https://github.com/ethereum-optimism/go-ethereum/blob/42c15d285804ce4bd77309dfdb1842c860d5c0f1/miner/worker.go#L213).

# The Optimistic Rollup

Optimism’s rollup is a rollup using:

- The OVM as its runtime / state transition function
- Optimistic Geth as the L2 client with a single sequencer
- Solidity smart contracts deployed on Ethereum for:
  - data availability
  - dispute resolution and fraud proofs[9](https://research.paradigm.xyz/optimism#fn:8) In this section, we dive into the smart contracts which implement the data availability layer and explore the fraud proof flow end-to-end.

## Data Availability Batches

As we saw before, transaction data is compressed and then sent to the Sequencer Entrypoint contract on L2. The sequencer then is responsible for “rolling up” these transactions in a “batch” and publishing the data on Ethereum, providing data availability so that even if the sequencer disappears, a new sequencer can be launched to continue from where things were left off.

The smart contract that lives on Ethereum which implements that logic is called the [Canonical Transaction Chain](https://github.com/ethereum-optimism/contracts-v2/blob/3ce74d9f56b6e5df9af5485294da0e1e3c6db660/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L22) (CTC). The Canonical Transaction Chain is an append-only log representing the “official history” (all transactions, and in what order) of the rollup chain. Transactions are submitted to the CTC either by the sequencer, a prioritized party who can insert transactions into the chain, or via a first-in-first-out queue which feeds into the CTC. To preserve L1’s censorship resistance guarantees, anybody can submit transactions to this queue, forcing them to be included into the CTC after a delay.

The CTC provides data availability for L2 transactions published per batch. A batch can be created in 2 ways:

- Every few seconds, the sequencer is expected to check for new transactions which they received, roll them up in a batch, along with any additional metadata required. They then publish that data on Ethereum via [`appendSequencerBatch`](https://github.com/ethereum-optimism/contracts-v2/blob/3ce74d9f56b6e5df9af5485294da0e1e3c6db660/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L340). This is automatically done by the [batch submitter](https://github.com/ethereum-optimism/batch-submitter/) service.
- When the sequencer censors its users (i.e. doesn’t include their submitted transactions in a batch) or when users want to make a transaction from L1 to L2, users are expected to call [`enqueue`](https://github.com/ethereum-optimism/contracts-v2/blob/3ce74d9f56b6e5df9af5485294da0e1e3c6db660/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L213) and [`appendQueueBatch`](https://github.com/ethereum-optimism/contracts-v2/blob/3ce74d9f56b6e5df9af5485294da0e1e3c6db660/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L290), which “force” include their transactions in the CTC.

An edge case here is the following: If the sequencer has broadcast a batch, a user could force include a transaction which touches state that conflicts with the batch, potentially invalidating some of the batch’s transactions. In order to avoid that, [a time delay is introduced](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L311-L314), after which batches can be appended to the queue by non-sequencer accounts. Another way to think about this, is that the sequencer is given a “grace period” to include transactions via `appendSequencerBatch`, else users will `appendQueueBatch`.

Given that transactions are mostly expected to be submitted via the sequencer, it’s worth diving into the batch structure and the execution flow:

You may notice that `appendSequencerBatch` takes no arguments. Batches are submitted in a tightly packed format, whereas using ABI encoding and decoding would be much less efficient. It uses inline assembly to slice the calldata and unpack it in the expected format.

A batch is made up of:

- Header
- Batch contexts (>=1, *note: this context is not the same as the message/transaction/global context we mentioned in the OVM section above)*
- Transactions (>=1)

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/wozIAb8x62b3cd6fe2525.png)

Figure 3: Compact batch format

The batch’s header specifies the number of contexts, so a serialized batch would look like the concatenation of `[header, context1, context2, …, tx1, tx2, ... ]`

The function proceeds to do [2 things](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L399-L428):

1. Verify that all context-related invariants apply
2. Create a merkle tree out of the published transaction data

If context verification passes, then the batch is converted to an [OVM Chain Batch Header](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/libraries/codec/Lib_OVMCodec.sol#L65-L71), which is then [stored](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L759-L783) in the CTC.

The stored header contains the batch’s merkle root, meaning that proving a transaction was included is a simple matter of providing a merkle proof that verifies against the stored merkle root in the CTC.

A natural question here would be: This seems too complex! Why are contexts required?

Contexts are necessary for a sequencer to know if an enqueued transaction should be executed before or after a sequenced transaction. Let’s see an example:

At time T1, the sequencer has received 2 transactions which they will include in their batch. At T2 (>T1) a user also [enqueue](https://github.com/ethereum-optimism/contracts-v2/blob/3ce74d9f56b6e5df9af5485294da0e1e3c6db660/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L213)’s a transaction, adding it to the [L1 to L2 transaction queue](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol#L271-L284) (but not adding it to a batch!). At T2 the sequencer receives 1 more transaction and 2 more transactions are enqueued as well. In other words, the pending transactions’ batch looks something like:

   ```
[(sequencer, T1), (sequencer, T1), (queue, T2), (sequencer, T2), (queue, T3), (queue, T4)]
   ```

In order to maintain timestamp (and block number) information while also keeping the serialization format compact, we use “contexts”, bundles of shared information between sequencer & queued transactions. Contexts must have strictly increasing block number and timestamp. Within a context, all sequencer transactions share the same block number and timestamp. For “queue transactions”, the timestamp and block number[ are set to whatever they were at the time of the enqueue call](https://github.com/ethereum-optimism/go-ethereum/blob/af6480b2e27d273b444f6912a3da20f8795eb9d8/rollup/sync_service.go#L1035-L1052). In this case, the contexts for that batch of transactions would be:

```
[{ numSequencedTransactions: 2, numSubsequentQueueTransactions: 1, timestamp: T1}, {numSequencedTransactions: 1, numSubsequentQueueTransactions: 2, timestamp: T2}]
```

## State Commitments

In Ethereum, every transaction causes a modification to the state, and the global state root. Proving that an account owns some ETH at a certain block is done by providing the state root at the block and a merkle proof proving that the account’s state matches the claimed value. Since each block contains multiple transactions, and we only have access to the state root, that means we can only make claims about the state after the entire block has been executed.

*A little history:*

Prior to [EIP98](https://github.com/ethereum/EIPs/issues/98) and the Byzantium hard fork, Ethereum transactions produced intermediate[ state roots after each execution](https://github.com/ethereum-optimism/go-ethereum/blob/f8b6a248713a2636a491d1727dc4d62c2c8bfa49/core/state_processor.go#L110-L116), which were provided to the user via the transaction receipt. The TL;DR is that removing this improves performance (with a small caveat), so it was quickly adopted. Additional motivation given in [EIP PR658](https://github.com/ethereum/EIPs/pull/658) settled it: The receipt’s `PostState` field indicating the state root corresponding to the post-tx execution state was [replaced](https://github.com/ethereum-optimism/go-ethereum/blob/f8b6a248713a2636a491d1727dc4d62c2c8bfa49/core/types/receipt.go#L82) with a boolean Status field, indicating the transaction’s success status.

As it turns out, the caveat was not trivial. EIP98’s rationale section writes:

> This change DOES mean that if a miner creates a block where one state transition is processed incorrectly, then it is impossible to make a fraud proof specific to that transaction; instead, the fraud proof must consist of the entire block.

The implication of this change, is that if a block has 1000 transactions and you have detected fraud at the 988th transaction, you’d need to run 987 transactions on top of the previous block’s state before actually executing the transaction you are interested in, and that would make a fraud proof obviously very inefficient. Ethereum doesn’t have fraud proofs natively, so that’s OK!

Fraud proofs on Optimism on the other hand are critical. Earlier, we mentioned that Optimism does not have blocks. That was a small lie: Optimism has blocks, but each block has 1 transaction each, let’s call these “microblocks”[10](https://research.paradigm.xyz/optimism#fn:9). Since each microblock contains 1 transaction, each block’s state root is actually the state root produced by a single transaction. Hooray! We have re-introduced intermediate state roots without having to make any breaking change to the protocol. This of course currently has a constant size performance overhead since microblocks are still technically blocks and contain additional information that’s redundant, but this redundancy can be removed in the future (e.g. make all microblocks have 0x0 as a blockhash and only populate the pruned fields in RPC calls for backwards compatibility)

We now can introduce the [State Commitment Chain](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/chain/OVM_StateCommitmentChain.sol) (SCC). The SCC contains a list of state roots, which, in the optimistic case, correspond to the result of applying each transaction in the CTC against the previous state. If this is not the case, then the fraud verification process allows the invalid state root, and all following it, to be deleted, so that the correct state root for those transactions may be proposed.

Contrary to the CTC, the SCC does not have any fancy packed representation of its data. Its purpose is simple: Given a list of state roots, it [merklizes them and saves](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/chain/OVM_StateCommitmentChain.sol#L303-L353) the merkle root of the intermediate state roots included in a batch for later use in fraud proofs via [`appendStateBatch`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/chain/OVM_StateCommitmentChain.sol#L119).

## Fraud Proofs

Now that we understand the fundamental concepts of the OVM along with the supporting functionality for anchoring its state on Ethereum, let’s dive into dispute resolution, aka fraud proofs.

The sequencer does 3 things:

1. Receives transactions from its users
2. Rolls up these transactions in a batch and publishes them in the Canonical Transaction Chain
3. Publishes the intermediate state roots produced by the transactions as a state batch in the State Commitment Chain.

If, for example, 8 transactions were published in the CTC, there would be 8 state roots published in the SCC, for each state transition S1 to S8.

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/K60HBiiu62b3cd9de6ac5.png) 

Figure 4: The state roots for each state transition caused by a transaction get published to the State Commitment Chain. Transaction data gets published as batches in the Canonical Transaction Chain.

However, if the sequencer is malicious, they could set their account balance to 10 million ETH in the state trie, an obviously illegal operation, making the state root invalid, along with all state roots that follow it. They’d do that by publishing data that looks like:

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/7jkStZXr62b3cdbf5f27a.png)

Figure 5: The sequencer publishes an invalid state root for T4. All state roots after it are also invalid, since a state root’s validity requires that its ancestor is also valid.

Are we doomed? We have to do something!

As we know, Optimistic Rollup assumes the existence of verifiers: For each transaction published by the sequencer, a verifier is responsible for downloading that transaction and applying it against their local state. If everything matches, they do nothing, but if there’s a mismatch there’s a problem! To resolve the problem, they’d try to re-execute T4 on Ethereum to produce S4. Then, any state root published after S4 would be pruned, since there’s no guarantee that it’d correspond to valid state:

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/WhdnaP5q62b3cddeea99f.png)

Figure 6: After a successful fraud proof, all invalid state roots are pruned.

From a high level, the fraud proof statement is “Using S3 as my starting state, I’d like to show that applying T4 on S3 results in S4 which is different from what the sequencer published (😈). As a result I’d like S4 and everything after it to be deleted.”

How is that implemented?

What you saw in Figure 1, was the OVM running in its “simple” execution mode, in L2. When running in L1 the OVM is in Fraud Proof Mode and a few more components of it get enabled (the Execution Manager and the Safety Checker are deployed on *both* L1 and L2):

- **Fraud Verifier**: Contract which coordinates the entire fraud proof verification process. It calls to the [State Transitioner Factory](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitionerFactory.sol#L34-L57) to [initialize a new fraud proof](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_FraudVerifier.sol#L127) and if the fraud proof was successful it [prunes](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_FraudVerifier.sol#L198) any batches which were published after the dispute point from the State Commitment Chain.
- **State Transitioner**: Gets deployed by the Fraud Verifier when a dispute is created with a pre-state root and the transaction being disputed. Its responsibility is to call out to the [Execution Manager](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L343)[11](https://research.paradigm.xyz/optimism#fn:10)[ and faithfully execute the transaction on-chain](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L343) according to the rules, to produce the correct post-state root for the disputed transaction. A successfully executed fraud proof will result in a [state root mismatch between the post-state root in the state transitioner and the one in the State Commitment Chain](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_FraudVerifier.sol#L192-L196). A state transitioner can be in any of the 3 following states: [`PRE EXECUTION, POST EXECUTION, COMPLETE`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L34-L38).
- **State Manager:** Any data provided by the users gets stored [here](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/execution/OVM_StateManager.sol#L14). This is an “ephemeral” state manager which is [deployed only for the fraud proof](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L90) and only contains information about the state that was touched by the disputed transaction.

The OVM running in fraud proof mode looks like:

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/VS5SNtW962b3ce087cd8d.png)

Figure 7: The OVM in Fraud Proof mode

Fraud proofs are broken down in a few steps:

### Step 1: Declare which state transition you’re disputing

1. The user calls the Fraud Verifier’s [`initializeFraudVerification`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_FraudVerifier.sol#L81), providing the pre-state root (and proof of its inclusion in the State Commitment Chain) and the transaction being disputed (and proof of its inclusion in the Transaction chain).
2. A State Transitioner contract is deployed via the State Transitioner Factory.
3. A State Manager contract is deployed via the State Manager Factory. It will not contain the entire L2 state, but will be populated with only the parts required by the transaction; you can think of it as a “partial state manager”.

The State Transitioner is now in the `PRE EXECUTION` phase.

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/iGSLxm1F62b3ce33dca92.png)

Figure 8: Initializing a fraud proof deploys a new State Transitioner and a State Manager, unique to the state root and transaction being disputed.

### Step 2: Upload all the transaction pre-state

If we try to directly execute the transaction being disputed, it will [immediately fail with an INVALID_STATE_ACCESS error](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1335-L1340), since none of the L2 state that it touches has been loaded on the freshly-deployed L1 State Manager from Step 1. The OVM sandbox will detect if the SM has not been populated with some touched state, and enforce that all the touched state needs is loaded first.

As an example, if a transaction being disputed was a simple ERC20 token transfer, the initial steps would be:

1. Deploy the ERC20 on L1[12](https://research.paradigm.xyz/optimism#fn:11): The contract bytecode of the L2 and L1 contracts must match to have identical execution between L1 and L2. We [guarantee](https://github.com/ethereum-optimism/optimism-ts-services/blob/2654c5de7a5b8a2111fca0c313b58e436e141bd5/src/services/fraud-prover.service.ts#L625-L629) that with a “magic” prefix to the bytecode which copies it into memory and stores it at the specified address.
2. Call [`proveContractState`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L173-L237): This will link together the L2 OVM contract with the freshly deployed L1 OVM contract (the contract is deployed and linked, but still has no storage loaded). Linking [means](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L222-L231) that the OVM address is used as the key in a mapping where the value is a structure containing the contract’s account state.
3. Call [`proveStorageSlot`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L245-L300): Standard ERC20 transfers reduce the sender’s balance by an amount, and increase the receiver’s balance by the same amount, typically stored in a mapping. This will upload the balances of both the receiver and the sender before the transaction was executed. For an ERC20, balances are typically stored in a mapping, so the key would be the `keccak256(slot + address)`, as per Solidity’s [storage layout](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#mappings-and-dynamic-arrays).

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/3WCkGIcn62b3ce5793230.png)

Figure 9: During the fraud proof pre-execution phase, all contract state that will get touched must be uploaded.

### Step 3: Once all pre-state has been provided, run the transaction

The user must then trigger the transaction’s execution by calling the State Transitioner’s [`applyTransaction`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L311-L346). In this step, the Execution Manager starts to execute the transaction using the fraud proof’s State Manager. After execution is done, the State Transitioner transitions to the `POST EXECUTION` phase.

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/1pUzG8Ll62b3ce7b36ec5.png)

Figure 10: When the L2 transaction gets executed on L1, it uses the State Manager which was deployed for the fraud proof and contains all the uploaded state from the pre-execution phase.

### Step 4: Provide the post-state

During execution on L1 (Step 3), the values in contract storage slots or account state (e.g. nonces) will change, which should cause a change in the State Transitioner’s post-state root. However, since the State Transitioner / State Manager pair do not know the entire L2 state, they cannot automatically calculate the new post-state root.

In order to avoid that, if the value of a storage slot or an account’s state changes, the storage slot or account gets marked as [“changed”](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/execution/OVM_StateManager.sol#L549-L570), and a counter for uncommitted [storage slots](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1384) or [accounts](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1306) is incremented. We require that for every item that was changed, that the user also provides a merkle proof from the L2 state, indicating that this was indeed the value that was observed. Each time a storage slot change is “committed”, [the contract account’s storage root is updated](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L418-L425). After all changed storage slots have been committed, the contract’s state is also committed, [updating the transitioner’s post-state root](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L379-L386). The counter is correspondingly decremented for each piece of post-state data that gets published.

It is thus expected that after the state changes for all contracts touched in the transaction have been committed, the resulting post-state root is the correct one.

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/lt2lZa8H62b3cea623896.png)

Figure 11: In the post execution phase, any state that was modified must be uploaded.

### Step 5: Complete the state transition & finalize the fraud proof

Completing the state transition is a simple matter of calling [`completeTransition`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L444), which requires that all accounts and storage slots from Step 4 have been committed (by checking that the counter for uncommitted state is equal to 0).

Finally, [`finalizeFraudVerification`](https://github.com/ethereum-optimism/contracts-v2/blob/0ad4dcfdef11ef87e278a8159de8414c8e329ba1/contracts/optimistic-ethereum/OVM/verification/OVM_FraudVerifier.sol#L147) is called on the Fraud Verifier contract which checks if the state transitioner is complete and if yes, it calls [`deleteStateBatch`](https://github.com/ethereum-optimism/contracts-v2/blob/f6069a881fbf6c35687a1676a73c67596b3ef4f9/contracts/optimistic-ethereum/OVM/chain/OVM_StateCommitmentChain.sol#L86) which proceeds to delete all state root batches after (including) the disputed transaction from the SCC. The CTC remains unchanged, so that the original transactions are re-executed in the same order.

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/uLJZmrFK62b3cece84b30.png)

Figure 12: Once the State Transitioner is complete, the fraud proof is finalized and the invalid state roots get removed from the state commitment chain.

## Incentives + Bonds

In order to keep the system open and permissionless, the SCC is designed to allow anybody to be a sequencer and publish a state batch. To avoid the SCC being spammed with junk data, we introduce 1 limitation:

The sequencer must be [marked as collateralized](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/chain/OVM_StateCommitmentChain.sol#L133-L137) by a new smart contract, the [bond manager](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/verification/OVM_BondManager.sol). You become collateralized by depositing a fixed amount, which you can withdraw with a 7 day delay.

However, after collateralizing, a malicious proposer could just repeatedly create fraudulent state roots, in hopes that nobody disputes them, so that they make bank. Ignoring the scenario of users socially coordinating an emigration from the rollup and the evil sequencer, the attack cost here is minimal.

The solution is very standard in L2 system design: If fraud is successfully proven, X% of the proposer’s bond gets burned[13](https://research.paradigm.xyz/optimism#fn:12) and the remaining (1-X)% gets distributed [proportionally](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/verification/OVM_BondManager.sol#L162-L187) to every user that provided data for Steps 2 and 4 of the fraud proof. The sequencer’s cost of defection is now much higher, and hopefully creates a sufficient incentive to prevent them from acting maliciously, assuming they act rationally[14](https://research.paradigm.xyz/optimism#fn:13). This also creates a nice incentive for users to submit data for the fraud proof, even if the state being disputed does not directly affect them.

## Nuisance Gas

There is a separate dimension of gas, called “nuisance gas”, which is used to bound the net gas cost of fraud proofs. In particular, witness data (e.g merkle proofs) for the fraud proof’s setup phase is not reflected in the L2 EVM gas cost table. `ovmOPCODES` have a separate cost in nuisance gas, which gets charged whenever a new [storage slot](https://github.com/ethereum-optimism/contracts-v2/blob/f6069a881fbf6c35687a1676a73c67596b3ef4f9/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1254-L1256) or [account](https://github.com/ethereum-optimism/contracts-v2/blob/f6069a881fbf6c35687a1676a73c67596b3ef4f9/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1182-L1187) is touched. If a message tries to use more nuisance gas than allowed in the message’s context, execution [reverts](https://github.com/ethereum-optimism/contracts-v2/blob/f6069a881fbf6c35687a1676a73c67596b3ef4f9/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1457-L1461).

## Recap

There’s a lot going on. The summary is that whenever there’s a state transition:

1. Somebody will dispute it if they disagree
2. they’ll publish all related state on Ethereum including a bunch of merkle proofs for each piece of state
3. They will re-execute the state transition on-chain
4. They will be rewarded for correctly disputing, the malicious sequencer will get slashed, and the invalid state roots will be pruned guaranteeing safety

This is all implemented in Optimism’s [Fraud Prover service](https://github.com/ethereum-optimism/optimism-ts-services/blob/master/src/services/fraud-prover.service.ts) which is packaged with an optimistic-geth instance in a [docker compose image](https://github.com/ethereum-optimism/verifier).

# Review & Conclusion

First of all:

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/CRQucKaO62b3cef2abe20.png)

You’ve made it! That was a long technical post with lots of references. I do not expect you to remember it all, but hopefully this post can serve as a reference while you evaluate Optimism and Optimistic Rollup solutions.

TL;DR: Optimism provides a throughput increasing solution for Ethereum, while maintaining full compatibility with existing tooling and re-using well tested and optimized software written by the Ethereum community. We are beyond excited for the future of Ethereum and the new use cases and companies that will be uniquely enabled by Optimism’s scalable infrastructure.

For any further questions or discussions Ethereum L2 scaling, Optimism or Optimistic Rollups please @ me on [Twitter](https://twitter.com/gakonst) or drop me an [email](mailto:georgios@paradigm.xyz).

We’d like to thank the Optimism team for diving with us and answering our questions, as well as Hasu, Liam Horne, Patrick McCorry, Kobi Gurkan, Ben Mayer and Sam Sun for providing valuable feedback when writing this post.

# Appendix

## OVM Opcodes

We proceed to break down each OVM opcode by category:

1. Expressing [execution context](https://github.com/ethereum-optimism/contracts-v2/blob/f6069a881fbf6c35687a1676a73c67596b3ef4f9/contracts/optimistic-ethereum/iOVM/execution/iOVM_ExecutionManager.sol#L44-L66) related information:

- Message Context: Who calls what ? Is it a state changing call? Is it a static call? Is it a contract creation call?
  - `CALLER`: Address of the caller
  - `ADDRESS`: Currently loaded contract address
- Transaction Context: Information about the transaction
  - `TIMESTAMP`: Block timestamp
  - `NUMBER`: Block number
  - `GASLIMIT`: Block gas limit
- Global Context: Chain-specific parameters
  - `CHAINID`: The Layer 2 chain’s chain id constant (420 for Optimism)

1. Contract Interactions: Each time there’s a message call to another contract, these opcodes are responsible for switching the context, making an external call and parsing revert information, if any:

- `CALL`: adjusts the message context (`ADDRESS` and `CALLER`) before making an external contract call
- `STATICCALL`: same as `CALL`, but sets the next message’s context to be static before making an external contract call
- `DELEGATECALL`: leaves the context unchanged and makes an external contract call

Each external call to a contract is also preceded by a [lookup to see if the contract’s state is loaded](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L961-L972), except for addresses `0x00-0x64`, which are reserved for precompiled contracts and do not require any lookups.

1. Contract Storage Access:

- `SSTORE`
- `SLOAD`

The EVM versions would call the `ADDRESS` opcode and would then store or load the appropriate storage slot. Since we’re in the OVM, these opcodes must be overwritten to instead call [`ovmADDRESS`](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L649) and also check if these storage slots are present in the state trie when [storing](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1229-L1246) and [loading data](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1203-L1220).

1. Contract Creation:

- `CREATE`
- `CREATE2`

Similarly, these opcodes are overridden to use [`ovmADDRESS`](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L364) for the deployer, adjusting the context to use the deployer as the `ovmCALLER` and the contract’s address as the [new context](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L904-L908)’s `ovmADDRESS`.

A noticeable difference is there’s an [existence check](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L366-L368) in an allowlist (deployed as a [precompile](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L868-L875)), which prevents unauthorized users from deploying contracts. This is added as part of Optimism’s [defense-in-depth approach](https://medium.com/ethereum-optimism/mainnet-soft-launch-7cacc0143cd5) towards a full production mainnet and will be removed once [arbitrary contract deployment](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/precompiles/OVM_DeployerWhitelist.sol#L190-L196) is [enabled](https://github.com/ethereum-optimism/contracts-v2/blob/2b99de2f63ba57bb28a038d2832105fceef9edee/contracts/optimistic-ethereum/OVM/precompiles/OVM_DeployerWhitelist.sol#L159-L166).

1. Contract code access:

- `EXTCODECOPY`: Currently, `ovmEXTCODECOPY` will return a minimum of 2 bytes even if the length input is 1. This limitation will be removed before mainnet release, although the compiler already truncates it to 1 byte on the contract side, so unless you are writing some custom inline assembly, it should not be an issue even now.
- `EXTCODESIZE`
- `EXTCODEHASH`

In addition, certain opcodes which “do not make sense” or cannot be made into safe counterparts have been blocked altogether:

- `SELFBALANCE`,`BALANCE`,`CALLVALUE`
  
  : For the purposes of the OVM, we have removed all notion of native ETH. OVM contracts do not have a direct`BALANCE`, and the`ovm*CALL`

   opcodes do not accept a value parameter. Instead, OVM contracts are expected to use a wrapped ETH ERC20 token (like the popular WETH9) on L2 instead.

  - The ETH ERC20 is not deployed yet and the sequencer currently accepts transactions with a 0 gasPrice.
  - Gas is paid via the ETH ERC20 with a transfer to the sequencer.
  
- `ORIGIN`: Scroll to the “Account Abstraction” section for more information.

- `SELFDESTRUCT`: Not yet implemented.

- `COINBASE`, `DIFFICULTY`, `GASPRICE`, `BLOCKHASH`: Not supported

The `ovmCREATE(2)` opcodes are responsible for doing this safety check [and revert otherwise](https://github.com/ethereum-optimism/contracts-v2/blob/f6069a881fbf6c35687a1676a73c67596b3ef4f9/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L749-L751).

## L1 to L2 interoperability

In order to support L1 <> L2 communication, Transactions (via the new `meta` field) and messages in optimistic-geth are augmented to include additional metadata, as seen below:

| geth                                                         | optimistic-geth                                              |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![alt_text](https://img.learnblockchain.cn/attachments/2022/06/2qttU0pT62b3cfc69e2c1.png) | ![alt_text](https://img.learnblockchain.cn/attachments/2022/06/YlSl6SD662b3cfca586ca.png) |

Figure 13: Geth vs Optimistic-Geth internal message format

Optimism allows asynchronous calls between L1 and L2 users or contracts. Practically, this means that a contract on L1 can make a call to a contract on L2 (and vice versa). This is implemented by deploying “bridge” contracts in both Ethereum and Optimism.

The sending chain’s contract calls [`sendMessage`](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/bridge/OVM_BaseCrossDomainMessenger.sol#L39) with the data it wants to pass over, and a relay calls `relayMessage` [[L1](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/bridge/OVM_L1CrossDomainMessenger.sol#L77-L83), [L2](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/bridge/OVM_L2CrossDomainMessenger.sol#L48)] on the receiving chain to actually relay the data.

| Sender (L1 & L2)                                             | Receiver (L1)                                                | Receiver (L2)                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![alt_text](https://img.learnblockchain.cn/attachments/2022/06/eCeuYJ0a62b3d00b6ff85.png) | ![alt_text](https://img.learnblockchain.cn/attachments/2022/06/0eKlN9kK62b3d00faa8d2.png) | ![alt_text](https://img.learnblockchain.cn/attachments/2022/06/KkpXTUJo62b3d013304b2.png) |

Figure 14: The L1 <> L2 contract interface is abstracted over arbitrary messages

Conveniently, all transactions from L1 to L2 get automatically relayed by the sequencer. This happens because the L1->L2 bridge calls [`enqueue`](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/bridge/OVM_L1CrossDomainMessenger.sol#L281-L284), queuing up the transaction for execution by the sequencer. In a way, the sequencer is an “always on” relay for L1 to L2 transactions, while L2 to L1 transactions need to be explicitly relayed by users. Whenever a message is sent, a `SentMessage(bytes32)` event is emitted, which can be used as a wake-up signal for [relay services](https://github.com/ethereum-optimism/optimism-ts-services/blob/master/src/services/message-relayer.service.ts).

Using the default bridge contracts by Optimism, requires that all L2 to L1 transactions are [at least 1 week old](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/bridge/OVM_L1CrossDomainMessenger.sol#L206), so that they are safe from fraud proofs. It could be the case that developers deploy their own bridge contracts with semi-trusted mechanisms that allow L2 to L1 transactions with a smaller time restrictment.

The simplest example of this mechanism would be [depositing an ERC20 on a L1 bridge contract](https://github.com/ethereum-optimism/optimism-tutorial/blob/dev-xdomain/contracts/L1_ERC20Adapter.sol) and [minting the equivalent token amount on L2](https://github.com/ethereum-optimism/optimism-tutorial/blob/dev-xdomain/contracts/L2_ERC20.sol).

![alt_text](https://img.learnblockchain.cn/attachments/2022/06/ZQP1JV8c62b3d04a28352.png)

Figure 15: End to end message flow for a L1 <> L2 deposit and withdrawal

As a developer integrating with Optimism’s messengers, it’s very easy: Just call `messenger.sendMessage` with the function and target address you want to call on L2. This wraps the message in a [`relayMessage`](https://github.com/ethereum-optimism/contracts-v2/blob/ad5e11860a2b1b25e886e5fdec46b1afb7a5372d/contracts/optimistic-ethereum/OVM/bridge/OVM_BaseCrossDomainMessenger.sol#L73-L92) call, targeting the L2 Cross Domain Messenger. That’s all! Same for L2 to L1. This is all enabled by the new `L1MessageSender`, `L1BlockNumber` and `L1Queue` fields in the message and transaction `meta`.

## Account Abstraction

**Overview**

The OVM implements a basic form of [account abstraction](https://docs.ethhub.io/ethereum-roadmap/ethereum-2.0/account-abstraction/). In effect, this means that the only type of account is a smart contract (no EOAs), and all user wallets are in fact smart contract wallets. This means that, at the most granular level, OVM transactions themselves do not have a signature field, and instead simply have a to address with a data payload. It is expected that the signature field will be included within the data (we covered that when we talked about the Sequencer Entrypoint contract!).

3 opcodes have been added in order to support account abstraction:

- `ovmCREATEEOA`
- `ovmGETNONCE`
- `ovmSETNONCE`

**Backwards Compatibility**

Developers need not be concerned with any of this when they start building their applications – Optimism has implemented a standard [ECDSA Contract Account](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol) which enables backwards compatibility with all existing Ethereum wallets out of the box. In particular, it contains a method [`execute(...)`](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol#L36) which behaves exactly like EOAs on L1: it recovers the signature based on standard L1 EIP155 transaction encoding, and increments its own nonce the same way as on L1.

The OVM also implements a new opcode, [`ovmCREATEEOA`](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L464), which enables anybody to deploy the `OVM_ECDSAContractAccount` to the correct address (i.e. what shows up on metamask and is used on L1). `ovmCREATEEOA` accepts two inputs, a hash and a signature, and recovers the signer of the hash. This must be a valid L1 EOA account, so an `OVM_ECDSAContractAccount` is deployed to that address.

This deployment is automatically handled by the sequencer[ the first time an account sends an OVM transaction](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/precompiles/OVM_SequencerEntrypoint.sol#L66-L67), so that users need not think about it at all. The sequencer also handles wrapping the user transaction with a call to [`execute(...)`](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/precompiles/OVM_SequencerEntrypoint.sol#L72-L80).

**`eth_sign` Compatibility**

For wallets which do not support custom chain IDs, the backwards-compatible transactions described above do not work. To account for this, the `OVM_ECDSAContractAccount` also allows for an alternate signing scheme which can be activated by the `eth_sign` and `eth_signTypedData` endpoints and follows a standard Solidity ABI-encoded format. The [`@eth-optimism/provider`](https://www.npmjs.com/package/@eth-optimism/provider) package implements a web3 provider which will use this encoding format. In order to support this, a `SignatureHashType` field was added to geth’s transaction and message types.

**Account Upgradeability**

Technically, the `ovmCREATEEOA` opcode deploys a proxy contract which [`ovmDELEGATECALLs`](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/accounts/OVM_ProxyEOA.sol#L31-L49) to a deployed implementation of `OVM_ECDSAContractAccount`. This proxy account can upgrade its implementation by calling its own [`upgrade(...)`](https://github.com/ethereum-optimism/contracts-v2/blob/master/contracts/optimistic-ethereum/OVM/accounts/OVM_ProxyEOA.sol#L56) method. This means that users can upgrade their smart contract accounts by sending a transaction with a to field of their own address and a data field which calls `upgrade(...)`.

Note that the sequencer does not recognize any wallet contracts other than the default at this time, so users should not upgrade their accounts until future releases.

Because of this, one restriction of the OVM is that there is no `tx.origin` (`ORIGIN` EVM opcode) equivalent in the OVM.

The big advantage of this, is that it future proofs the system. As we said, the long-term state of accounts would be to use BLS signatures which can be aggregated, resulting in more compact data and as a result more scalability. This feature allows accounts which have BLS-ready wallets to opt-in upgrade to a future `OVM_BLSContractAccount`, while other accounts remain in their “old” wallet without noticing a thing.

# Disclaimer

*This post is for general information purposes only. It does not constitute investment advice or a recommendation or solicitation to buy or sell any investment and should not be used in the evaluation of the merits of making any investment decision. It should not be relied upon for accounting, legal or tax advice or investment recommendations. This post reflects the current opinions of the authors and is not made on behalf of Paradigm or its affiliates and does not necessarily reflect the opinions of Paradigm, its affiliates or individuals associated with Paradigm. The opinions reflected herein are subject to change without being updated.*

