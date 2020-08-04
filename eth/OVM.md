> **Update:** This article describes what we now call OGS or Optimistic Game Semantics. For an in-depth exploration of OGS check out [the paper](https://plasma.group/optimistic-game-semantics.pdf)! For up-to-date information on the OVM, visit [Optimism.io](http://optimism.io) ❤️

# Introducing the OVM

## A Correct-by-Construction Approach to Layer 2

In this post we describe the Optimistic Virtual Machine (OVM): a virtual machine designed to support all layer 2 (L2) protocols. Its generality comes from a reframing of L2 as an “optimistic” fork choice rule layered on top of Ethereum. The formalization borrows heavily from [CBC Casper research](https://github.com/cbc-casper/cbc-casper-paper/blob/master/cbc-casper-paper-draft.pdf), and describes *layer 2 as a direct extension to layer 1 consensus*. This implies a possible unification of all “layer 2 scalability” constructions (Lightning, Plasma, etc) under a single theory and virtual machine: the OVM.

**This post will:**

1. Introduce the language of the OVM.
2. Describe how a class of L2 applications can be compiled end-to-end using a universal dispute contract.

# Part 1: Describing L2 With a Unified Language

Layer 1 (L1) gives us a trusted, but expensive, virtual machine (VM). Layer 2 provides an interface for efficiently using the expensive L1 VM — instead of transactions directly updating the L1 state, we use off-chain data to guarantee what *will* happen to L1 state. We call this guarantee an “optimistic decision.”

> **Three steps to making an optimistic decision:**
> 
> 1\. Look at L1, and figure out what could possibly happen in the future.
> 2\. Look at off-chain messages and what they guarantee if used in L1.
> 3\. Restrict our expectation of future L1 state based on those guarantees.

We will soon describe this process as part of the OVM’s [state transition function](https://en.wikipedia.org/wiki/Transition_system). However, first let’s build intuition for what we mean by “restrict expectation of future L1 state” with a few key concepts.

## 🔑 Concept 1: The Ethereum Futures Cone

One can imagine future Ethereum states as an infinite expanse which contains everything that could ever happen to the blockchain. Every transaction that could be signed, every [DAO that could be hacked](https://www.businessinsider.com/dao-hacked-ethereum-crashing-in-value-tens-of-millions-allegedly-stolen-2016-6) — all possible futures. To avoid cliché this post will not mention the word: “quantum.”

However, even in the face of infinite futures we can still **restrict possible futures** based on the Ethereum Virtual Machine’s rules. For example, in the EVM, if 5 ETH has been burned to the address `0x000…`, we know that all future Ethereum blocks will still have 5 ETH burned. This parallels CBC’s future protocol states (great illustrations by Barnabé Monnot [here](/@barnabe/partially-explained-casper-cbc-specs-86d055fd0628)!).

We can visualize the process of gradually restricting possible futures as an infinitely large “cone” of possibilities that shrinks every time we mine & finalize a new block.

![111](https://img.learnblockchain.cn/2020/08/04/111.gif)
<center>*Animation of the Ethereum futures cone. If Alice Burns 5 ETH, she knows it’s burned in all possible future blocks.*</center>

> Note that in L1 all restrictions of possible future states are done by mining and forming consensus around (finalizing) a new block — a process which produces an irreversible state transition within the EVM.

## 🔑 Concept 2: Local Information

L2 extends the consensus protocol with local information (eg. off-chain messages). For example, a signed channel update, or an inclusion proof for a plasma block.
![222](https://img.learnblockchain.cn/2020/08/04/222.gif)
<center>*Off-chain message passing… Vizzzualized!*</center>

The OVM uses this local information to make *optimistic decisions —*we call a new decision an OVM state transition. But first, the OVM must define assumptions which it uses to derive possible future Ethereum states.

## 🔑 Concept 3: Local Assumptions

OVM programs define assumptions which, based on local information, determines what Ethereum states are possible. This can be expressed as a function `satisfies_assumptions(assumptions, ethereum_state, local_information) => true/false`. If `satisfies_assumptions(...)` returns true then the `ethereum_state` is possible based on these particular `assumptions`, and our `local_information`.

In many L2 solutions, this takes the form of a “dispute liveness assumption.” For example, participants in a channel assume that they will dispute any malicious withdrawal. So, we return false for any Ethereum state which contains a malicious, undisputed withdrawal.

![](https://img.learnblockchain.cn/2020/08/04/15965239742316.jpg)
<center>*Two forks, one where `satisfies_assumptions(…)` returns true, the other in which it returns false based on the “dispute liveness assumption.”*</center>



## 🔑 Concept 4: Optimistic Decisions

With our local assumptions eliminating impossible futures, we may finally make “optimistic decisions” about the future. The following would be a common optimistic decision in a payment channel:

> **Optimistically Decide Balance (with our 3 step process defined above)**:
> 
> 1\. Look at L1 and determine that Alice is in a payment channel with Bob.
> 2\. Look at off-chain messages determine that: a) Alice has the highest signed nonce, sending her 5 ETH; b) Alice may withdraw her 5 ETH after a dispute period; and c) Alice can respond to any invalid withdrawals based on her “dispute liveness assumption.”
> 3\. Restrict our expectation of future L1 state to ONLY states in which Alice has been sent 5 ETH.
> 
> **Alice may now optimistically decide she will eventually have *at least* 5 ETH in all future states of Ethereum.** — without an on-chain transaction to boot!

## The Last 🔑: The Optimistic Futures Cone

Remember that the “Ethereum futures cone” was only restricted by finalizing blocks — an entirely retrospective process. In the last section we reviewed an optimistic approach which restricts futures based on *local* *information* and *local assumptions* about the future — a prospective process. These two approaches may be “layered” on top of one-another to get the best of both worlds: the security of blockchain consensus, plus the speed, efficiency, & privacy of local message transfer.

We can visualize this hybrid process with a futures cone that not only restricts future Ethereum states after each block, but also restricts future states between blocks based on local information. Deciding on a new restriction is considered a “state transition” in the OVM.

![333](https://img.learnblockchain.cn/2020/08/04/333.gif)
<center>*Alice’s Optimistic Futures Cone “narrows” when she receives new off-chain messages.*</center>

## A Unified Language

The above concepts may be used as the basis of a shared language and execution model for layer 2\. This includes:

- Zero Confirmation Transactions
- The Lightning Network
- Cross-shard state schemes
- Plasma, Channels, Truebit
…and more — all within a shared notation.

In part 2 of this post, we will expand upon this language and show how the correct-by-construction approach motivates a specific OVM runtime. Based on first-order logic, it supports existing L2 designs —including [those for ETH2](https://ethresear.ch/t/layer-2-state-schemes/5691).

But first, if you’re weird like us and want to see some fancy maths, the following is a formalization of the key concepts we just reviewed:

![](https://img.learnblockchain.cn/2020/08/04/15965242209098.jpg)

# A Step Further: Building an OVM Runtime

Excited by the realization that L2 can be described in a unified language, we soon found ourselves asking: how do we make this useful? Can we create a generic L2 runtime environment, supporting different L2 designs?

It turns out, for a broad class of OVM programs, we can. The trick is to build a dispute contract which interprets the same mathematic expressions the OVM is based on. This enables a high-level language written in predicate logic.

# The Universal Dispute Contract

To do this, we create an arbitration contract handling user-submitted “claims”–expressions which evaluate to true/false. For example, **“the preimage to hash X does NOT exist.”**

Disputes involve counter-claims which logically contradict. For example, **“the preimage to hash X DOES exist”** would contradict the first claim. This generalizes L2 “challenges”: at the end of the day, all disputes are logical contradictions (they can’t both be true).

After a dispute timeout, the contract can decide true for an unchallenged claim. However, if a contradiction is shown, it needs to make a choice. The logic of decisions about true/false statements is called [predicate calculus](https://en.wikipedia.org/wiki/First-order_logic).

# Predicates 2.0

In developing [generalized plasma](/plasma-group/towards-a-general-purpose-plasma-f1cc4d49c1f4), we realized that pluggable “predicate contracts” enabled custom optimistic execution. What we now understand is that a pluggable system of predicates isn’t generalized plasma — *it’s generalized layer 2*. In this light, a plasma contract is just a composition of predicates.

Predicate contracts are the logical “evaluators” — deciding true or false on inputs. Critically, they can decide based on other predicates. This means a small set of interacting predicates can arbitrate a vast number of L2 systems.

## Example Predicates

Let’s go over some example predicates used in first-order logic.

**`NOT`**
This predicate performs a logical negation: `NOT(aPredicate, anInput)`. It can be contradicted by claiming `aPredicate(anInput)`.

**`AND`**
This predicate is the logical AND operator, taking the form `AND(predicate1, input1, predicate2, input2)` . It can be contradicted by either `NOT(predicate1, input1)` or `NOT(predicate2, input2)` .

**`WITNESS_EXISTS`**
This predicate claims some witness data exists: `WITNESS_EXISTS(verifier, parameters)` . It is a [fundamental building block](https://twitter.com/VitalikButerin/status/1046498306958995456) blockchains give to L2 systems using a liveness assumption. It decides true only if it receives some `witness` such that `verifier.verify(parameters, witness)` returns `true`.

**`UNIVERSAL_QUANTIFIER`**
This predicate represents [universal quantification](https://en.wikipedia.org/wiki/Universal_quantification) (“for all”) based on some [quantifier](https://en.wikipedia.org/wiki/Quantifier_(logic)) (“such that”)— `UNIVERSAL_QUANTIFIER(aQuantifier, aPredicate)` . It contradicts with `NOT(aPredicate, someInput)` if and only if `aQuantifier.quantify(someInput)` returns `true`.

## Composing a State Channel

A class of widely-understood layer 2 systems is state channels, so let’s compose a state channel with predicates. Withdrawing from a state channel is like claiming the following: **“For all state updates with a higher nonce than this** `**withdrawn_update**`**, there does not exist a unanimous signature by all channel participants.”**

To the universal dispute contract, then, we would claim the following:

`UNIVERSAL_QUANTIFIER(HAS_HIGHER_NONCE_QUANTIFIER(withdrawn_update), NOT(WITNESS_EXISTS(VERIFY_MULTISIG, withdrawn_update.participants)))`

For Math folks, this might look more familiar as the following expression:

![](https://img.learnblockchain.cn/2020/08/04/15965249250289.jpg)
Thus, state channels can be built by composing four simple predicates.

# An Optimistic Future

With very few predicates, this universal dispute contract can arbitrate many L2 systems: plasma flavors, state channels, optimistic cross-shard state schemes, Truebit, and so on. The predicate runtime provides a shared platform for each approach — enabling improved developer tooling. <mark>It effectively **cuts the work of L2 developers in half** because the predicate expressions are interpreted both on-chain and off-chain.</mark>

Beyond the predicate runtime, the OVM has broader implications:

1. **Communication** — Mathematical models for previously bespoke concepts.
2. **Interoperability** — Shared memory for all optimistic execution.
3. **Security** — Formal proofs for L2 & the predicate runtime.

Stay tuned for our paper detailing the OVM and the predicate runtime. In the meantime, you can further satiate your appetite with [early drafts of the contracts](https://hackmd.io/@aTTDQ4GiRVyyce6trnsfpg/S1yGmXVxB).

Please tweet questions @plasma_group, or better yet join in the discussion at the [plasma.build forum](https://plasma.build/)–onwards!

原文链接：https://medium.com/plasma-group/introducing-the-ovm-db253287af50作者：[Ethereum Optimism](https://medium.com/@optimismPBC)