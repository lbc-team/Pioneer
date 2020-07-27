# Ethereum Smart Contracts in L2: **Optimistic Rollup**



This post outlines optimistic rollup: a construction which enables autonomous smart contracts on layer 2 (L2) using the [OVM](https://medium.com/plasma-group/introducing-the-ovm-db253287af50). The construction borrows heavily from both plasma and zkRollup designs, and builds on [shadow chains](https://blog.ethereum.org/2014/09/17/scalability-part-1-building-top/) as described by Vitalik. **This construction resembles plasma but trades off some scalability to enable running fully general (eg. Solidity) smart contracts in layer 2, secured by layer 1.** Scalability is proportional to the bandwidth of data availability oracles which include Eth1, Eth2, or even [Bitcoin Cash or ETC](https://ethresear.ch/t/bitcoin-cash-a-short-term-data-availability-layer-for-ethereum/5735) — providing a near term scalable EVM-like chain in layer 2.

![1_qk6yWTozTxMfZXZILtvpAQ](https://img.learnblockchain.cn/pics/20200727225147.png)



# Quick Overview

Let’s start with some intuitions for how optimistic rollup works end to end on mainnet Ethereum, then dive in deep.

The following is a chronicle of the life of an optimistic rollup smart contract… named Fred:

1. Developer writes a Solidity contract named Fred. Hello Fred!
2. Developer sends transaction off-chain to a bonded **aggregator** (a layer 2 block producer) which deploys the contract.
   — Anyone with a bond may become an aggregator.
   — There are multiple aggregators on the same chain.
   — Fees are paid however the aggregator wants (account abstraction / meta transactions).
   — Developer gets an instant guarantee that the transaction will be included or else the aggregator loses their bond.
3. Aggregator locally applies the transaction & computes the new state root.
4. Aggregator submits an Ethereum transaction (paying gas) which contains the transaction & state root (an optimistic rollup block).
5. If **anyone** downloads the block & finds that it is invalid, they may prove the invalidity with `verify_state_transition(prev_state, block, witness)` which:
   — Slashes the malicious aggregator & any aggregator who built on top of the invalid block.
   — Rewards the prover with a portion of the aggregator’s bond.
6. Fred the smart contract is safe, happy & secure knowing her deployment transaction is now a part of every valid future optimistic rollup state. Plus Fred can be sent mainnet ERC20’s deposited into L2! Yay!

That’s it! The behavior of users & smart contracts should be very similar to what we see today on Ethereum mainnet, except, it scales! Now let’s explore how this whole thing is possible.

# Optimistic Rollup In Depth

To begin let’s define what it means to create a permissionless smart contract platform like Ethereum. There are three properties we must satisfy to build one of these lovely state machines:

1. **Available head state** — Any relevant party can download the current head state.
2. **Valid head state** — The head state is valid (eg. no invalid state transitions).
3. **Live head state** — Any interested party can submit transactions which transition the head state.

You’ll notice that Ethereum layer 1 satisfies these three properties because we believe 1) miners do not mine on unavailable blocks, 2) miners do not mine on invalid blocks[*](https://eprint.iacr.org/2015/702.pdf); and 3) not all miners will censor transactions. However, it doesn’t currently scale.

On the other hand, under some similar security assumptions, optimistic rollup can provide all three guarantees at scale. To understand the construction & security assumptions we’ll go over each property we’d like to ensure individually.

# #1: Available head state

Optimistic rollup uses classic rollup techniques ([outlined here](https://ethresear.ch/t/on-chain-scaling-to-potentially-500-tx-sec-through-mass-tx-validation/3477)) to ensure data availability of the current state. The technique is simple — block producers (called aggregators) pass all blocks which include transactions & state roots through calldata (ie. the input to an Ethereum function) on Ethereum mainnet. The calldata block is then merklized & a single 32 byte state root is stored. For reference, calldata is 2,000 gas per 32 bytes while storage is 20,000 gas. Additionally, the gas cost of calldata will be reduced by almost 5x in the [Istanbul hard fork](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1679.md).

Notably, we can use data availability oracles other than the Ethereum mainnet including [Bitcoin Cash](https://ethresear.ch/t/bitcoin-cash-a-short-term-data-availability-layer-for-ethereum/5735) and Eth2. With Eth2 phase 1 all shards can serve as data availability oracles, scaling TPS linearly in the number of shards. This is enough throughput that we will hit other scalability bottlenecks before we run out of available data, for example state computation.

## Security Assumptions

Here we assume honest majority on Ethereum mainnet. In addition, if we use Eth2, ETC, or Bitcoin Cash, we similarly inherit their honest majority assumptions.

> Under these assumptions, using a trusted availability oracle to publish all transactions we can ensure that anyone can compute the current head state, satisfying property #1.

# #2: Valid head state

The next property we need to ensure is a valid head state. In zkRollup we use zero-knowledge proofs to ensure validity. While this is a great solution in the long term, for now it is not possible to create efficient zkProofs for arbitrary state transitions. However, there’s still hope for a general purpose EVM-style state machine! We can use a cryptoeconomic validity game similar to plasma / truebit.

## Cryptoeconomic Validity Game

At a high level the block submission & validity game is as follows:

1. Aggregators post a security deposit to start producing blocks.
2. Each block contains `[access_list, transactions, post_state_root]`.
3. All blocks are committed to a `ROLLUP_CHAIN` contract by a bonded aggregator on a first come first serve basis (or round robin if desired).
4. **Anyone** may prove a block invalid, **winning a portion of the aggregator’s security deposit**.

To prove a block invalid you must prove one of the three following properties:

```
1. INVALID_BLOCK: The committed block is *invalid*. 
   This is calculated with `is_valid_transition(prev_state, block, witness) => boolean`
2. SKIPPED_VALID_BLOCK: The committed block "skipped" a valid block.
3. INVALID_PARENT: The committed block's parent is invalid.
```

These three state transition validity conditions can be visualized as:

![1_cv_RR7vxY0BW89QKr7mRsA](https://img.learnblockchain.cn/pics/20200727225247.png)



There are a few interesting properties that fall out of this state validity game:

1. **Pluggable validity checkers**: We can define different validity checkers for `is_valid_transition(…)` allowing us to use different VMs to run smart contracts including EVM and WASM.
2. **Only one valid chain**: Blocks are submitted to Ethereum which gives us a total ordering of transactions & blocks. This enables us to deterministically decide the “head” block, and thereby require aggregators to prune invalid blocks before submitting a new block.
3. **Sharded validation**: This validity game can be played out at an individual UTXO basis. Instead of invalidating full blocks, we partially invalidate them — similar to Plasma Cash. Note that this **does not** require proving all invalid transitions up front for a single block. Partial block invalidation means we can validate only UTXOs for contracts we care about to secure our state. To learn more about how UTXOs enable parallelism [check out this Cryptoeconomics.study video](https://www.youtube.com/watch?v=-xoCoZGJ9AQ)!

## A Note on Watchtowers

One challenge to adoption of L2 has been the added complexity of [watchtowers](https://blockonomi.com/watchtowers-bitcoin-lightning-network/). Users contracting watchtowers adds yet another entity to manage to an already complex system. Thankfully, watchtowers are naturally incentivized by the optimistic rollup cryptoeconomic validity game! All data is available & therefore anyone running a full node stands to gain the security bond of **all** aggregators who build on their invalid chain. This risk incentivizes aggregators to be watchtowers, validating the chain they are building on — mitigating the verifiers dilemma.

## A Note on Plasma

Many plasma constructions also rely on cryptoeconomic validity games; however, in plasma autonomous smart contract state enforcement is impossible without zkProofs or a [fisherman’s game](https://github.com/ethereum/research/wiki/A-note-on-data-availability-and-erasure-coding#what-is-the-data-availability-problem) during a data withholding attack (the data availability problem). Thankfully rollup gets around the data availability problem by posting the minimal information needed to compute state transitions on-chain. Still, plasma is critical if we want to scale up to transactions per second in the hundreds of thousands (and more) — a long term necessity but not a requirement in the medium term for many smart contracts.

## Security Assumptions

1. This cryptoeconomic validity game works with **a single honest or even rational verifier** assumption. We can say it is a “rational” verifier as opposed to “honest” because they may be economically incentivized with challenge games.
2. Additionally we assume the mainnet is **live**, meaning it is not censoring all incoming transactions attempting to prove invalidity. Note that the aggregator unbonding period is in some sense the liveness assumption on the mainnet (eg. if we require a 1 month unbonding period, then invalidity must be proven within that month to forfeit that bond).

> Under these assumptions, all invalid blocks / state transitions will be discarded leaving us with a *single* valid head state, satisfying property #2.

# #3: Live Head State

The final property we must satisfy is liveness, often known as censorship resistance. The key insights which ensures this are:

1. Anyone with a bond size above `MINIMUM_BOND_SIZE` may become an aggregator for the same rollup chain.
2. Because honest aggregators may prune invalid blocks, the chain **does not halt** in the event of an invalid block.

With these two properties we’ve already got liveness! Honest aggregators may always submit blocks which fork around invalid blocks & so even if there’s just one non-censoring aggregator your transaction will eventually get through — similar to mainnet.

## A Note on Liveness vs Instant Confirmations

One property we really want is instant confirmations. This way we can give users sub-second feedback that their transaction will be processed. We can achieve this by designating short-lived aggregator monopolies on blocks. The downside is that it trades off censorship resistance because now a single party can censor for some period of time. Would love to hear about any research on this tradeoff!

## Security Assumptions

With two security assumptions we get liveness:

1. There exists a non-censoring aggregator.
2. Mainnet Ethereum is not censoring.

> Under these assumptions, the optimistic rollup chain will be able to progress & mutate the head state based on any valid user transactions, satisfying property #3.

> Now all three properties are satisfied & we’ve got a permissionless smart contract platform in Ethereum L2!

# Scalability Metrics

The following estimates are **purely based on data availability**. In practice other bottlenecks could be hit, one being state calculation. However, this does provide a useful upper bound.

## **ERC20 Transfers with ETH1 Data availability**

Calculations are based on [this little call-data calculation python script](https://gist.github.com/karlfloersch/1bf6ab7871f41e3a5a921c0a007ad5c6).

Note that these ERC20 transfers are calldata optimized. Additionally note that the nice thing about Optimistic Rollup is we aren’t limited to ERC20 transfers!

**ECDSA Signature**
~100 TPS without EIP 2028
~450 TPS with EIP 2028 (coming in October 2019)

**BLS Signature / SNARK-ed Signatures**
~400 TPS without EIP 2028
~2000 TPS with EIP 2028 (coming in October 2019)

## With external availability oracles (eg. ETH2, Bitcoin Cash)

***~linear in relation to the amount of throughput the availability oracle can handle.\***

*That’s a lot more than 2000 TPS!*

# Optimistic Rollup vs Plasma

Optimistic Rollup shares much in common with Plasma. Both use aggregators to commit to blocks on mainnet with a cryptoeconomic validity game ensuring safety. The sole divergence is whether or not we have an availability receipt ensuring block availability.



![1_XM9jBBbYE20kFC7PIngipA](https://img.learnblockchain.cn/pics/20200727225426.png)

The similarities between the two solutions allows for lots of shared infrastructure & code between the two constructions. In a mature layer 2 ecosystem it’s likely that we will see rollup, plasma, and state channels all working together in the same client (a smart wallet). Oh, have I mentioned the [OVM](https://medium.com/plasma-group/introducing-the-ovm-db253287af50)? 😁

# Yay Optimistic Rollup 🎉

Optimistic Rollup occupies a nice niche in the space of layer 2 constructions. It trades off some scalability for general purpose smart contracts, simplicity, & security. Plus being able to run secure smart contracts means that it can even be used to adjudicate other layer 2 solutions like plasma and state channels!

> Call it “the layer 1 of layer 2s.”

Anyway, enough research — time to implement a robust, comprehensive, and user friendly Ethereum layer 2! 😍

------

*Special thanks to Vitalik Buterin for working through these ideas with me and for coming up with much of this.*

*Additionally, thank you Ben Jones for much of this and Jinglan Wang, Kevin Ho & Jesse Walden for edits.*

**Update**: Shout out to the great and related work by John Adler in his article on Merged Consensus which can be compared to optimistic rollups — Check it out [here](https://ethresear.ch/t/minimal-viable-merged-consensus/5617)! Plus [this proposal](https://ethresear.ch/t/multi-threaded-data-availability-on-eth-1/5899) to improve Eth1’s ability to act as a data availability oracle — more tps!

[Plasma Group Blog](https://medium.com/plasma-group?source=post_sidebar--------------------------post_sidebar-)



#### Thanks to Vitalik Buterin and Jesse Walden.



From: https://medium.com/plasma-group/ethereum-smart-contracts-in-l2-optimistic-rollup-2c1cef2ec537

Athor: [Karl Floersch](https://medium.com/@karl_dot_tech?source=post_page-----2c1cef2ec537----------------------)