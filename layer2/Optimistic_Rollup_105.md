原文链接：https://research.paradigm.xyz/rollups

# (Almost) Everything you need to know about Optimistic Rollup

One of the biggest challenges in the Ethereum ecosystem is having low latency and high throughput under tight resource constraints (e.g. CPU, bandwidth, memory, disk space).

The decentralization of a system is determined by the ability of the weakest node in the network to verify the rules of the system. A high-performance protocol that can be run on low-resource hardware is called “scalable”.

In this post, we dive into the principles of modern “Layer 2 solutions”, their corresponding security model, and how they can solve Ethereum’s scalability issues.

This blogpost is targeted at “crypto-curious” individuals interested in learning more about cutting-edge Ethereum scaling techniques as well as developing a motivation on how to build and architect such systems.

*Throughout the post, important keywords or concepts are highlighted in bold, as they are words/jargon you will encounter throughout your journey in crypto. The topic is complicated. If you find yourself confused, keep reading, it’ll all make sense in the end.*

## Blockchain Resource Requirements

Three factors impact the resource requirements of running a node in a decentralized network such as Bitcoin and Ethereum [1]:

- **Bandwidth**: The cost of downloading and broadcasting any blockchain-related data
- **Compute**: The cost of running computations inside scripts or smart contracts
- **Storage**: The cost of storing transaction data for indexing purposes, and the cost of storing “state” in order to continue processing new blocks of transactions [2].

Performance is measured in 2 ways:

- **Throughput**: The number of transactions the system can process per second.
- **Latency**: The time it takes for a transaction to be processed.

The desired property of emerging crypto-networks such as Bitcoin and Ethereum is decentralization. **But what makes a network decentralized?**

- **Low Trust**: This is the property which allows any individual to verify that there will never be more than 21m bitcoin, or that their bitcoin is not counterfeited. Individuals who run node software independently compute the latest state and verify that all rules were followed in the process
- **Low Cost**: If the node software is expensive to operate, individuals will rely on trusted third parties to verify the state. High costs imply high trust requirements, which is what we wanted to avoid in the first place.

Another desired property is **scalability**: **The ability to scale throughput and latency superlinearly to the cost of running the system.** This definition is great, but doesn’t incorporate “trust”. Hence, we specify **“decentralized scalability”: achieving scalability without meaningfully increasing the system’s trust assumptions.**

Zooming in, Ethereum’s runtime environment is the Ethereum Virtual Machine (EVM). Transactions that run through the EVM perform various operations at different costs (e.g. a store operation costs more than an addition). The unit of computation in a transaction is called “gas”, and the system is parameterized to process at most 12.5m gas per block, where a block of transactions gets produced on average every 12.5 seconds. As a result, **Ethereum’s latency is 12.5 seconds and its throughput is 1m gas per second.**

A question you may ask is: What does 1m gas per second buy you?

- ~47 “simple transfer” transactions per second. These transactions cost 21000 gas and are the simplest type of transaction, transferring ETH from A to B.
- ~16 ERC20 token transfers per second. These involve more storage operations than ETH transfers, and as a result cost ~60k gas each.
- ~10 Uniswap asset trades per second. The average cost of a token to token trade is [about](https://github.com/Uniswap/uniswap-v2-periphery/blob/master/test/UniswapV2Router01.spec.ts#L369-L374) 102k gas.
- …pick your favorite transaction’s gas cost and divide 1m with it *(12.5m / 12.5 / gas)*

Notice how as a transaction’s execution complexity increases, the system’s throughput decreases to very low values. There’s room for improvement!

**Solution 1: Use an intermediary**

We could use a trusted third party to facilitate all our transactions. That way, we’d get very high throughput and probably sub-second latency, which is great! That would not change any system-wide parameter, but we’d be opting in into a trust model unilaterally set by the third party. They may choose to censor us or even seize our assets, which is not desired.

**Solution 2: Make blocks bigger and more frequent**

We can reduce the latency by reducing the time between 2 blocks, and we can increase throughput by increasing the block gas limit. This change would make the cost to operate a node higher, preventing individuals from running nodes (e.g. happening with EOS, Solana, Ripple etc.).

In solution 1, the trust is increased. In solution 2, the cost is increased. That eliminates both of them as scalability options.

## Rediscovering Optimistic Rollup from first principles

*In the following section we assume the reader is familiar with [hashes](https://blockgeeks.com/guides/what-is-hashing/) and [merkle trees](https://media.consensys.net/ever-wonder-how-merkle-trees-work-c2f8b7100ed3).*

With our learnings so far, let’s simulate a socratic dialogue with the goal of discovering a protocol that can increase Ethereum’s effective throughput without increasing the burden for users and node operators.

*Q. So…we want to scale Ethereum without meaningfully changing the trust & cost assumptions. How do we go about that?*

A: We want to lower the requirements of existing operations in terms of their costs on the system (see three resources types above). In order to understand why that is not trivial to do, we need to first look at Ethereum’s architecture:

**Every node in Ethereum currently stores and executes every transaction submitted to it by users**. During execution, a transaction is [run through the EVM](https://github.com/ethereum/go-ethereum/blob/45cb1a580abad0d4e8caa1c8b7dfacd5ef3d27bc/core/vm/evm.go#L273), and it [interacts](https://github.com/ethereum/go-ethereum/blob/45cb1a580abad0d4e8caa1c8b7dfacd5ef3d27bc/core/state_transition.go#L219-L273) with the EVM’s state (e.g. storage, balances etc.) - which is expensive. Common smart contract [optimization](https://medium.com/coinmonks/8-ways-of-reducing-the-gas-consumption-of-your-smart-contracts-9a506b339c0a) techniques center around minimizing the number of interactions with the state, but they only provide small constant factor improvements.

*Q: Are you saying there’s a way to transact without touching the state, and thereby keeping the resource cost low?*

A: At the limit, could we move all execution off-chain and keep some data on-chain. _We can do that by introducing a third party, called the **sequencer**. They are responsible for storing and executing user-submitted transactions locally. In order to maintain liveness of the system, sequencers are expected to periodically submit a merkle root of the transactions they receive and the resulting state roots on Ethereum. This is a step towards the right direction because **we store only O(1) data in Ethereum’s state for O(N) off-chain transactions**.

*Q: So we achieve scaling by having the sequencer compute everything off-chain and only publish merkle roots?*

A: Yes.

*Q: OK so once you’re in, the sequencer guarantees that your transfers are cheap. How would deposits and withdrawals work?*

A: A user will enter the system by depositing on Ethereum, followed by the sequencer crediting the user with the corresponding amount. A user will withdraw back to Ethereum by making a transaction that says “I want to withdraw 3 ETH, my account currently has >3 ETH and here’s the proof for it”. Even though the L1 does not have the actual user state,** the user proves that they have sufficient funds at the current state by showing a merkle proof** referencing the state roots published by the sequencer.

*Q: We established that a user needs a merkle proof to withdraw their funds. How does the user get the data to construct the merkle proof?*

A: They can ask the sequencer to provide them with the data!

*Q: But what if the sequencer is temporarily or permanently unavailable?*

A: The sequencer may either be malicious, or simply be offline because of a technical issue, which would cause performance degradation (or worse, theft!). So we must also demand that **the sequencer submits the full transaction data on-chain to be stored, but not to be executed**. The objective here is to get **data availability**. Given that all the data is permanently stored on Ethereum, even if the sequencer disappears, a new sequencer may retrieve all the Layer 2-related data from Ethereum, reconstruct the latest L2 state and continue from where their predecessor left off.

Q: *So if the sequencer is online but refuses to provide me with the merkle proof data, I can download it from Ethereum?*

A: Yes, you can either sync an Ethereum node [yourself](https://docs.ethhub.io/using-ethereum/running-an-ethereum-node/), or connect to [one of the many](https://ethereum.org/en/developers/docs/nodes-and-clients/nodes-as-a-service/) hosted node services.

*Q: So something I still don’t understand…How can you store something on Ethereum without executing it? Doesn’t every transaction go through the EVM?*

A: Say you submitted 10 transactions transferring ETH from A to B. Executing each transaction would perform the following actions: Increment A’s nonce, decrease A’s balance and increase B’s balance. That’s quite a few writes and reads from the [world state](https://medium.com/cybermiles/diving-into-ethereums-world-state-c893102030ed). Instead, you can send an encoding of all transactions to a smart contract’s `publish(bytes _transactions) public { }` function. Notice that the function’s body is empty!. This means that **the published transaction data is not interpreted, executed and no state access is made anywhere; it’s just stored in the historical logs of the blockchain** (which is cheap to write to).

*Q: Can we trust the sequencer? What if they publish an invalid state transition?*

A: Anytime the sequencer publishes a batch of state transitions there is a **“dispute period”** during which any party can publish a **“fraud proof”** which indicates that one of the state transitions was invalid. This is proven by replaying the transaction which caused the state transition onchain and comparing the resulting state root with the one that was published by the sequencer. If the state roots do not match, then the fraud proof is successful and the state transition is cancelled. If there were more state transitions after the invalid one, they also get cancelled. **Transactions which are older than the dispute period cannot be disputed anymore and are considered final.**

*Q: Hold on! You said earlier, it’s not scaling if it a) increases the cost, or b) introduces new trust assumptions. In the scheme you describe here, don’t we additionally assume that there is always someone around to report fraud??*

A: Correct. We assume that there are entities called **“verifiers”** who are responsible for watching for fraud, and if there’s a mismatch between Layer 1 and Layer 2 state they publish a fraud proof. We also assume that verifiers are able to reliably get their fraud proofs included in Ethereum within the dispute period deadline. We consider the existence of a verifier a “weak” assumption. Imagine, if there’s applications with thousands of users, you only need 1 person to run a verifier. That doesn’t sound too unrealistic! On the other hand, changing the trust model of Ethereum or increasing the cost for operating an Ethereum node is a “strong” assumption change which we don’t want to do. This is what we meant by “meaningfully change the underlying system’s assumptions” when we defined decentralized scalability.

*Q: I agree that someone will run a verifier, because many parties have a vested interest in the success of this new solution. But surely, that also depends on how much it costs to actually do it. So what are the resource requirements for running a verifier and a sequencer?*

A: Sequencers and Verifiers must run an Ethereum full node (*not an archive node)*, a full L2 node, to produce the L2 state. Verifiers run software that’s responsible for creating fraud proofs, and sequencers run software that’s responsible for bundling user transactions and publishing them.

*Q: Is that it?*

A: Yes! Congratulations! You’ve rediscovered **Optimistic Rollup** [3], the most anticipated scaling solution of the 2019-2021 era. This is for a good reason, as it is the final artifact of a multi year long research process in the Ethereum community, which you experienced in a short dialogue.

## Incentives in Optimistic Rollup

Layer 2 scaling is based on the fact that we try to minimize the number of executed on-chain transactions. We use fraud proofs to cancel any invalid state transitions which may happen. Since a fraud proof is an on-chain transaction, we also want to minimize the amount of fraud proofs that get issued on Ethereum. In the ideal scenario, fraud never happens, and as a result fraud proofs never get issued.

We disincentivize fraud by introducing a **[fidelity bond](https://en.wikipedia.org/wiki/Fidelity_bond#:~:text=A fidelity bond is a,dishonest acts of its employees.)**. In order for a user to become a sequencer, they must first post a bond on Ethereum, which they will forfeit if fraud is proven. In order to incentivize individuals to look for fraud, the sequencer’s bond is slashed and distributed to verifiers.

### Fidelity Bonds and Dispute Periods

There’s 2 parameters to be tuned when designing the incentives for a fraud proof:

- **Fidelity Bond Size:** The amount which must be posted by the sequencer that gets distributed to verifiers. The bigger this is, the bigger the incentive to be a verifier and the smaller the incentive to commit fraud as a sequencer.
- **Dispute Period Duration:** The time window during which a fraud proof can be published, after which an L2 transaction is considered safe on L1. A long dispute period provides better security guarantees against censorship attacks. A shorter dispute period creates a nice user experience for users withdrawing from the L2 back to L1 because they do not need to wait long before they can re-use their funds on L1.

In our opinion, there’s no correct static value for either of these parameters. Maybe 10 ETH bonds and 1 day dispute period is enough. Maybe 1 ETH and 7 days are enough. The real answer is that it depends on the incentive to be a verifier (which depends on the cost to run one) and how easy it is to get a fraud proof published (which depends on L1 congestion). Both of these should be tunable, either manually or automatically. As an honorary mention, [EIP1559](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1559.md) introduces a new `BASEFEE` opcode to Ethereum which can be used to estimate on-chain congestion, and as a result programmatically tune the duration of the dispute period.

It’s important to get the implementation of this punishment mechanism right, otherwise it could be exploited in practice. Here is an example of a naive implementation that would not work:

1. Alice posts a 1 ETH bond, allowing her to be a sequencer in the system
2. Alice publishes a fraudulent state update
3. Bob notices that and publishes a dispute. If successful, this should grant the 1 ETH from Alice’s bond to Bob and cancel the fraudulent state update
4. Alice notices the dispute and publishes a dispute as well (disputing herself!)
5. Alice receives her 1 ETH, effectively paying no penalty even though she tried to commit fraud.

Alice can mount this attack reliably by “frontrunning”, i.e. broadcasting an identical transaction as Bob’s but with a higher gas price, causing Alice’s transaction to be executed before Bob’s. This means that Alice can consistently try to cheat with minimal costs (just the Ethereum transaction fees).

Fixing that is simple: **Instead of granting the full bond to the disputer, X% of it gets burned instead**. In the above example, if we burned 50% Alice would receive 0.5 ETH back instead, which would be a sufficient disincentive to not try cheating in Step 2. Of course, this bond burning reduces the incentive to run a verifier (since the payout becomes smaller), so the bond post-burn should be a big-enough incentive for verifiers instead.

## Popular Optimistic Rollup criticisms and our responses

Now that we have gone through the building blocks of an Optimistic Rollup, let’s explore and address the most popular criticisms against that mechanism.

### Long withdrawal/dispute periods are fatal for adoption and composability

We mentioned above that long dispute periods are great for security. There seems to be an inherent trade off here: Long dispute periods are bad for OR adoption, since any user that wants to withdraw their funds from OR needs to wait, say, 7 days until their funds are withdrawn. Small dispute periods are great for a smooth user experience, but then you are risking the case where fraud happens and no dispute gets included in time.

We do not consider this to be a problem. Due to this potentially large withdrawal delay, we expect market makers to jump in and offer faster withdrawal services. This is possible because someone who validates the L2 state can correctly judge if a withdrawal is fraudulent or not, and hence “buy” it at a small discount for their services. Example:

Actors:

- Alice: has 5 ETH on L2.
- Bob: has 4.95 ETH on L1 in a “market maker” smart contract and is running a verifier on the L2

Steps:

1. Alice lets Bob know that she wants a “fast” withdrawal, offering him a 0.05 ETH fee
2. Alice initiates a withdrawal to Bob’s “market maker” smart contract
3. 2 things can happen:
   1. Bob checks that the withdrawal is valid on his L2 verifier and approves the fast withdrawal. This transfers 4.95 ETH to Alice’s L1 address *instantly*. Bob will be able to claim the 5 ETH after the withdrawal period is over, netting a nice profit.
   2. Bob’s verifier alerts him that this transaction is not valid. Bob disputes the state transition caused by that transaction, canceling it *and* earning the sequencer’s bond for allowing the malicious transaction to happen.

Alice either was honest and got her funds out instantly, or she was dishonest and got punished. We expect the fees paid to these market makers to compress over time, if there’s demand for this service, making the procedure completely invisible to users eventually.

**The most important implication of this feature is that it enables composability with L1 contracts without having to wait for the full dispute period.**

*Note that this technique was first described in [“Simple Fast Withdrawals”](https://ethresear.ch/t/simple-fast-withdrawals/2128).*

### Miners can be bribed to censor withdrawals, breaking OR’s safety

In [“Nearly-zero cost attack scenario on Optimistic Rollup”](https://ethresear.ch/t/nearly-zero-cost-attack-scenario-on-optimistic-rollup/6336) it is argued that miner incentives are such that it’s trivial for a sequencer to collude with Ethereum miners to censor any dispute transaction. This of course would be fatal for any optimistic system, given the reliance on disputes for safety.

We disagree with the argument of this post. We posit that the honest side will always be willing to bribe the miner, with as much or more than the malicious side. In addition, miners incur an additional cost each time they deviate from “honest” behavior by helping the malicious side win. Such behavior would undermine the value of Ethereum, which potentially adds an additional cost for miners to engage in it

In fact, this [exact scenario has been studied in academic literature](https://arxiv.org/pdf/2002.10736.pdf), proving that **“the threat of this kind of counterattack induces a subgame perfect equilibrium in which no attack occurs in the first place”.**

*We’d like to thank Hasu for bringing this paper’s proof to our attention.*

### Verifier’s Dilemma creates disincentives for operating a verifier, breaking OR’s safety

Ed Felten has authored a [great analysis](https://medium.com/offchainlabs/the-cheater-checking-problem-why-the-verifiers-dilemma-is-harder-than-you-think-9c7156505ca1) and [workaround](https://medium.com/offchainlabs/cheater-checking-how-attention-challenges-solve-the-verifiers-dilemma-681a92d9948e) to the Verifier’s Dilemma, which we summarize below:

1. If the system’s incentives work as intended, nobody will cheat
2. If nobody cheats, then there’s no point in running a verifier because you make no money from operating it
3. Since nobody runs a verifier, there’s eventually an opportunity for a sequencer to cheat
4. The sequencer cheats, the system no longer functions as intended

It sounds like this is very important, and almost paradoxical! More verifiers reduce the expected payout for an individual verifier, assuming the size of the rewards’ is fixed. In addition, more verifiers seemingly reduce the size of the pie since there’s less fraud happening, further exacerbating the issue. In a follow-up analysis, Felten additionally provides a method to work around the verifier’s dilemma.

I’d like to take the opposite side here and say that the verifier’s dilemma is not as important as critics say. In practice, there are non-monetary incentives to be a verifier. For example, if you are a large app building on a rollup, or if you are a token holder, since if the system were to fail your app would no longer work or your token value would be reduced. In addition to that, the demand for fast withdrawals creates an incentive for market making verifiers to exist (as we saw in the previous section), independently of fraud happening. To make that point more concrete, Bitcoin provides no incentives to store the entire blockchain history or provide your local data to your peers, but people do it altruistically anyway.

Even if running a verifier in a vacuum is not incentive compatible, it keeps the system safe which is the most important thing for entities invested in the system’s success. As a result, we claim that **there is no need to design mechanisms to work around the Verifier’s Dilemma in Optimistic Layer 2 systems**.

## Conclusion

In line with the title of the post, we analyzed one of the technologies that will matter for Ethereum in 2021: Optimistic Rollup.

Summarizing its benefits: OR is an extension to Ethereum which carries over Ethereum’s security, composability and developer moats, while improving performance and not meaningfully impacting cost or trust requirements for Ethereum users. We explore the incentive structures which make Optimistic Rollups work, and provided responses to common criticisms.

We want to emphasize that the maximum OR performance is bound by the data you can publish on L1. As a result, there’s merit in 1) Compressing the data you publish as much as possible (e.g. via [BLS signature aggregation](https://eprint.iacr.org/2018/483.pdf)), 2) Having a large and cheap data layer (e.g. [ETH2](https://ethresear.ch/t/phase-one-and-done-eth2-as-a-data-availability-engine/5269))

For complementary reading, we recommend Buterin’s [An Incomplete Guide to Rollups](https://vitalik.ca/general/2021/01/05/rollup.html) and [Trust Models](https://vitalik.ca/general/2020/08/20/trust.html). We also recommend investigating OR’s close cousin, ZK Rollup, being built by our friends at [StarkWare](https://starkware.co/). Finally, there are other ways to get decentralized scalability, namely, [sharding](https://eth.wiki/sharding/Sharding-FAQs) and [state channels](https://statechannels.org/) each with their own upsides and downsides.

In a follow-up post, we will publish an in-depth mechanism and codebase analysis of the company which invented the first EVM-compatible optimistic rollup: [Optimism](https://optimism.io/).

We’d like to thank Hasu, Patrick McCorry, Liam Horne, Ben Jones, Kobi Gurkan and Dave White for providing valuable feedback when writing this post.

