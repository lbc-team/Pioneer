# The Definitive Guide to Sequencing

Shared Sequencing gallops towards the narrative horizon, so it’s time for a thorough explainer on what it is, and why it exists. I’ll be confining this post to optimistic rollups, so all y’all ZK people can go ahead and preemptively prep your corrections to everything below. See y’all on the tweeter. I’ll also be saying “host chain” a lot when I mean host DA layer, so all y'all DA folks should prep the tweet threads too

## What is a Sequencer?

A Sequencer is a semi-trusted role in an optimistic rollup. While transactions may be ordered by the host chain itself, this is not always economical. Users must individually submit the host chain transaction corresponding to their rollup transaction, and pay the host chain costs for self-ordered transactions. With Ethereum gas semantics, for example, this imposes a 21,000 gas fee per transaction. The Sequencer solves these problems for the user by allowing rollup-only transactions to share a single host chain transaction.

The Sequencer supplements the host chain’s ordering by aggregating many user transactions off-chain, and committing them to the host chain as a set in a single transaction. The costs for this commitment are then amortized across all users' transactions in the set. The Sequencer may also compress the set, to further save host chain DA costs. Overall users that self-order will pay significantly more for transaction inclusion in the Rollup than users that rely on the Sequencer.

However, the Sequencer can exercise control over the ordering[1](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-1-117995233) of transactions in the set. The Sequencer may choose not to include a user transaction, thereby forcing the user to self-order, paying any host chain costs. The Sequencer can also extract MEV within the set, via standard reordering and insertion extraction methods. They effectively have priority write access to the Rollup. It is also worth noting here, that because the Sequencer can interact with contracts, only infallible transactions may be reliably forced via the on-chain mechanism. Fallible transactions likely fail when force-sequenced[2](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-2-117995233).



This makes the Sequencer a semi-trusted party for the rollup users. While the Sequencer cannot prevent the user from accessing the rollup, they can delay the user’s access, cause the user to bear extra costs, and extract value from the user’s transaction. Further constraining Sequencer behavior via decentralization is an [active](https://developer.arbitrum.io/sequencer) [topic](https://research.arbitrum.io/t/challenging-periods-reimagined-the-key-role-of-sequencer-decentralization/9189) of [research](https://community.optimism.io/docs/protocol/#decentralizing-the-sequencer).

![A sign that says "Will you marry me?" in block letters, next to a large bouquet of roses](https://img.learnblockchain.cn/attachments/2023/06/AE8J866e648ac6ed851cf.png)



Caught on film for the first time, a Proposer, updating an ORU’s bridge state. Photo by [Gift Habeshaw](https://unsplash.com/@gift_habeshaw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/proposal?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

### What’s the difference between Sequencing and Execution?

The Sequencer supplements the host chain ordering. It does not compute the state of the rollup, and in fact may choose to sequence invalid transactions. Rollup nodes must parse and sanitize the sequenced data, use that to derive the rollup’s valid history, and execute the history to produce the latest state. The Sequencer is completely uninvolved in this process. 

As my friend [Fred](https://twitter.com/0x66726564) keeps reminding me, though, once the transactions are sequenced, the outcome is deterministic. This means that all rollup nodes will arrive at the same result, based on the order the sequencer produces. Rollups have a single correct state, given a known history[3](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-3-117995233). Once nodes find this state, one or more **Proposers**[4](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-4-117995233) commit it to the host chain’s rollup contract.



In theory, any node may be the Proposer and no permission is required. Proposers commit a state to the host chain alongside a bond. They then forfeit the bond if a fraud proof invalidates the state. This rollup contract accepts the bonded attestation after the optimistic timer elapses, and user transactions included in the commitment may then be played onto the host chain. Other executing nodes keep the Proposer honest via the fraud game. We tend to call the nodes that execute and do not propose “rollup full nodes” or “**Verifiers**”. 

In other words, the state becomes final and immutable as soon as the sequence is committed to the host chain. Proposers calculate and report the finalized state[5](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-5-117995233) to the rollup contract, for the benefit of the rollup-to-host bridge. Proposers do not create that state; they merely compute it and attest to it. The rollup contract does not create or finalize the rollup; it merely learns the rollup state from the Proposers.



### Why separate Sequencing and Proposing?

Well, that’s a complex question. Fundamentally, we separate them because they are separate. I know, I know, that sounds tautological, but it took everyone a long time to realize it. The intellectual history of rollups winds and twists through years of plasma and state channels, and we all got kinda turned around. In the early days of Bitcoin-based proto-rollups, there was no Sequencer. Users simply posted their transactions to the host chain. After that, the design disappeared for years, eventually resurfacing with [Barry’s work](https://github.com/barryWhiteHat/roll_up). Between Barry and Celestia, rollup research focused on the rollup bridge’s interaction with the host chain. Nobody even realized we were building better Mastercoins until the “sovereign” rollup was rediscovered.

Provenance aside, Sequencers solve a specific problem: user transaction cost minimization. However, in doing so, they introduce a new problem: Sequencers can produce multiple /orderings of the same transactions at the same time. If sequencing were done entirely by the host chain, there would be a single canonical order but user transactions would be more expensive. We choose to use a Sequencer to improve user experience in our rollups.

Suppose there were many Sequencers, as there are multiple Proposers. Sequencers could submit conflicting sequences, and we now require a mechanism to “canonize” a specific sequenced batch on the host chain[6](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-6-117995233). We accomplish this in mainnet Rollups today by having a single, specific, known, semi-trusted Sequencer. Choosing a single Sequencer allows us to punt on solving this canonization issue until that Decentralized Sequencer research pulls through[7](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-7-117995233). Because we want multiple Proposers, but need a single Sequencer, we must separate those two roles.



Considering data-dependencies gives us another important distinction: a Proposer requires the sequence[8](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-8-117995233), but a Sequencer never requires the state. Proposers depend on the output of the Sequencer’s work, but the Sequencer never depends on the Proposers. Because the data dependency goes only one direction, it makes sense to draw a boundary between the roles, and to allow actors to specialize in a single role.



So to answer the original question, we separate Proposers and Sequencers because they’re separate. The Proposer works downstream from the Sequencer. Rollups vest trust and authority in the Sequencer, while the Proposer is merely a functionary.

### Sequencers, Proposers, and Validators in the wild

There are two commonly-used ORUs: Arbitrum and Optimism. I want to cover the major roles briefly in each of them, but there’s not really a whole lot to talk about here. I won’t link to code, just specs and docs, because I’m lazy and it’s boring. Optimism discussion will be limited to the (as-yet undeployed) Bedrock design.

**Arbitrum**

In addition to batching and compressing user transactions, the **Arbitrum** [Sequencer](https://developer.arbitrum.io/sequencer) runs a full node. Transactions are sent directly to the Sequencer, which creates a trusted **WebSocket feed** of transactions as they are sequenced[9](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-9-117995233). **Arbitrum** describes **this feed** as a source of [“soft” finality.](https://developer.arbitrum.io/inside-arbitrum-nitro/#how-the-sequencer-publishes-the-sequence) The Sequencer makes a promise with respect to the order, upon which users can generally rely. Nodes, MEV Searchers, or others can use this feed to pre-compute rollup states by applying transactions.



Periodically, the Sequencer publishes the sequenced, compressed transactions to the host chain. The host chain finalization of the sequence represents “hard” finality for the rollup. Once the host chain has finalized the sequence, it becomes an immutable part of the **Arbitrum** chain’s history. All transactions sequenced in it become final, and the resulting state becomes final.

Naturally, because the Sequencer sets the order, it has priority write access[10](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-10-117995233). The Sequencer can exercise control over the contents of the sequence, and thus over the ordering of transactions in the rollup history. Users may, of course, force inclusion of a transaction via **the [delayed inbox](https://developer.arbitrum.io/inside-arbitrum-nitro/#inboxes-fast-and-slow)** on the host chain. **Searchers already bend over backwards to minimize latency on the WebSocket transaction feed**, so it seems likely that they’ll form a robust MEV market for sequencing **Arbitrum** transactions.



There are **13 permissioned Arbitrum Proposers**. Each of these **stake host chain ETH** on a specific commitment **called an “[RBlock](https://developer.arbitrum.io/inside-arbitrum-nitro/#the-rollup-chain)” for “rollup block”.** Users may choose to rely on **some percentage of stake** in order to make finalization decisions about the rollup, without running a rollup full node. While **Arbtirum** Validators may identify fraud, **only members of the Proposer group** may challenge the validity of the commitment **via a fraud proof game**. Effectively, only **Proposers** may be full Validators.

![A photo of a small bronze statue of Justice in traditional garb, carrying a set of scales](https://img.learnblockchain.cn/attachments/2023/06/yMMmklCQ648ac6ed593f7.png)



Justice, like a Sequencer, is blind and has to carry a sword

**Optimism**

In addition to batching and compressing user transactions, the **Optimism** [Sequencer](https://community.optimism.io/docs/protocol/2-rollup-protocol/#block-production) runs a full node. Transactions are sent directly to the Sequencer, which creates a trusted **pre-finality [confirmation](https://help.optimism.io/hc/en-us/articles/4419573575835-How-soon-can-you-see-transactions-)** as they are sequenced[11](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-11-117995233). **Optimism** users may use **these** **confirmations** as a source of soft finality. The Sequencer makes a promise with respect to the order, upon which users can generally rely. Nodes, MEV Searchers, or others can use these confirmations to pre-compute rollup states by applying transactions.



Periodically, the Sequencer publishes the sequenced, compressed transactions to the host chain. The host chain finalization of the sequence represents “hard” finality for the rollup. Once the host chain has finalized the sequence, it becomes an immutable part of the **Optimism** chain’s history. All transactions sequenced in it become final, and the resulting state becomes final.

Naturally, because the Sequencer sets the order, it has priority write access[12](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-12-117995233). The Sequencer can exercise control over the contents of the sequence, and thus over the ordering of transactions in the rollup history. Users may, of course, force inclusion of a transaction via **[deposited transactions](https://github.com/ethereum-optimism/optimism/blob/develop/specs/glossary.md#deposited-transaction)** on the host chain. **As the originators of the MEV Auction concept**, it seems likely that a robust MEV market for sequencing **Optimism** transactions will form.



**Optimism** has **[1 permissioned Proposer](https://github.com/ethereum-optimism/optimism/blob/develop/specs/proposals.md#l2outputoracle-v100)**. This Proposer **signs** a specific commitment to the host chain, called a **“State Output” or “L2 Output Root”.** Users may choose to rely on **the Proposer** when making finalization decisions about the rollup, without running a rollup full node. While **Optimism** Validators may identify fraud, only **a single permissioned Challenge**r may challenge the validity of the commitment **via a signature**. **The Challenger may at any time [delete a L2 Output Root ](https://github.com/ethereum-optimism/optimism/blob/develop/specs/proposals.md#l2-output-oracle-smart-contract)** **[13](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-13-117995233)** **without a fraud proof.** Effectively, only **the permissioned Challenger** may be a full Validator.



**Summary**

Now that both major rollups have converged on a single design, it can get pretty confusing. They often use different names for the same concept, but don’t be fooled, their designs are almost identical. I bolded the key differences, in case you wanted a quick comparison.

![A child's hand placing a colorful block on top of a tower of other colorful blocks](https://img.learnblockchain.cn/attachments/2023/06/EIvUXhU7648ac6ed836df.png)



Pictured: block building. Photo by [La-Rel Easter](https://unsplash.com/@lastnameeaster?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/photos/KuCGlBXjH_o?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

## Shared Sequencing

Given our fresh perfect understanding of Sequencers, let’s move on to what I actually want to talk about: Shared Sequencers. What happens when rollups share the same Sequencer?

**What does it mean to be different rollups?**

Borrowing [a Ben’s definition](https://twitter.com/benafisch/status/1649144663096410112) we should think of a rollup as a state, a state-transition function, and (optionally) a proof system. A rollup has contracts and accounts, it has a VM that processes transactions to update those contracts and accounts, and non-sovereign rollups have a proof system to operate the enshrined bridge to the host chain. There are several designs for each component, and they can be mixed and matched to some extent. The DA-maximalist future may have cafeteria plan rollups, with a broad selection of self-serve components.

However, some components are more equal than others. In general, we should probably think of the state as the essence of the chain. Chains do not tend to alter their state. After all, Ethereum devs changed the VM many times, the consensus mechanism several times, but the state only once. The state makes the rollup, and the VM and the proving system exist to support it. It follows that different rollups have different states. They may share a proving system or a STF, but two rollups will never share the same state.

**Extraction, Lenses, & Filtering**

Rollups derive their state from the host chain history. In order to do this, each rollup must define an “**extraction**” function. The extraction function sorts the host chain history into rollup history, and non-rollup history. From there, the STF processes the rollup history to create the rollup state. In effect, the extraction function becomes a “lens” through which the rollups examine the host chain.

Rollups empower the Sequencer to choose the output of the next run of the extraction function. Knowing the design of the lens through which the rollup views the host, the Sequencer chooses what data the rollup nodes will see and process next, and therefore have some control over the operation of the STF, and the next state. The Sequencer creates these views of the host data cheaply and with minimal fuss.

After the Sequencer creates this view, the rollup nodes run a **filtration** function. Because the Sequencer is not necessarily aware of the state of the rollup it serves, it is permitted to include invalid transactions in its sequence. Upon extraction, rollup nodes then see these invalid transactions, and filter their view of the chain to remove them. Rather than erroring (as the host chain would) when given an invalid transaction, rollup nodes simply ignore it and carry on. An L1 must forbid junk in order to stay in consensus, while a rollup need not.

![A couple baristas pouring hot water through 4 stacked V60s with paper filters, into a carafe. This is a very silly way of making coffee](https://img.learnblockchain.cn/attachments/2023/06/bYFkfp6Y648ac6ed74d18.png)



Pictured: sequencing, extraction, and filtration. Photo by [Nathan Dumlao](https://unsplash.com/@nate_dumlao?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/photos/eksqjXTLpak?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

**Shared Sequencing**

A Shared Sequencer provides the inputs to the extraction function for two or more rollups. It therefore sets the new history for both, controlling the inputs to the STF[14](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-14-117995233). It can do this for each rollup individually, or both at the same time. When setting history individually, it works exactly the same as an unshared Sequencer.



However, when creating new history for both rollups at once, the shared Sequencer can exercise some extra power by atomically “linking” history on the two rollups to each other. The Sequencer produces sequences for each rollup simultaneously, and ensures that either both confirm or neither confirms. This allows the Sequencer to exercise control over both chains' histories, and therefore[15](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-15-117995233) some degree of control over the rollup’s next state.



**Atomic Inclusion (not Atomic Execution)**

At this point, I have to reiterate that the Sequencer can exercise significant discretion with respect to the sequence it produces. This means that while the user can use a shared Sequencer to make transactions on multiple rollups without interacting with the host chain at all, they cannot necessarily rely on the Sequencer to produce any specific relationship between those transactions. Shared Sequencer proponents envision a new structure where the user can specify atomicity of inclusion, i.e that the sequencer can be forced to sequence a set of transactions in multiple rollups at the same time via a shared forced-sequencing mechanism. This would allow users to ensure that either all of those atomic transactions are included in the rollup histories, or none.

This is not as good as it seems. Because only infallible transactions can be force-sequenced[16](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-16-117995233), only sets of infallible transactions guarantee atomic execution when atomically included. Yes, I just said a complicated and confusing thing, so lets break it down. As we said earlier, inclusion and execution are separate. A rollup filters out invalid transactions after inclusion, and before execution, via the filter function. Suppose the Sequencer takes the user’s atomic set, and causes one transaction to fail or become invalid. That transaction will be filtered after sequencing, and will not execute. This means that atomic inclusion is not sufficient to guarantee atomic execution, unless all transactions involved are infallible.



To make it very concrete, simple sends and withdrawals can be executed atomically, but anything fallible, like a swap, or a DeFi interaction, can’t be. Most high-value interactions contain 1 or more fallible transaction, unfortunately, so it seems difficult to make atomic inclusion useful. This effectively rules out cross-rollup DeFi composability via a shared Sequencer. The shared Sequencer is not a magic bullet. Users are locked into the asynchronous cross-chain model until the end of time.

**Atomic Execution via Rollup Composition**

Remember earlier, talking about how Sequencers provide trusted execution guarantees in advance of posting the sequence to the host chain? You could envision a shared Sequencer doing the same thing with respect to a multi-rollup system. The shared Sequencer could run full nodes of each rollup, and use those to determine whether transactions succeed. It could then promise[17](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-17-117995233) that it would not produce a sequence where atomic bundles do not all succeed.



This system would, of course, be trusted.You would rely on the Sequencer to not lie. You might be thinking right now “could we convert it to an untrusted system by constraining the Sequencer’s behavior?” And I’m happy/sad/confused to say the answer is “yes, but”. Yes, but the way we’d do that is composing the STFs of each rollup, to make a single STF that executes all component rollup transactions. I.e. we’d have to make all the VMs atomic between all the rollups. This is equivalent to making them the same rollup. So yes, we could achieve untrusted atomic execution. By combining multiple rollups into one. This might actually be a good idea[18](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-18-117995233), but I doubt it’s feasible



**Atomic Execution via Contingency Relationships**

I’ve written about this [elsewhere](https://prestwich.substack.com/p/contingency), but another credible option is to integrate explicit contingent relationships between transactions and/or rollup states. This would shift the burden of evaluating contingencies onto the Proposers, as they would have to calculate and propose state roots based on their beliefs about remote rollups. However, I think we can simplify this via repeated applications of the filter function. Supposing that contingency is explicit in a transaction & block, we could run the filter twice, once assuming the predicate state is valid, and once assuming the predicate state is invalid. This could be expanded to n predicate states, at the cost of 2^n evaluations of the filter function[19](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-19-117995233).



In this world, Proposers could attest to 2^n roots, with explicit contingency relationships on each root. E.g. instead of saying “the root is X” the proposer could attest to “the root is X contingent on remote rollup state A, and Y otherwise”. This way Proposers would not never to evaluate a remote rollup block. Instead, they would evaluate their own filter function and state multiple times, based on the assumed information from the other state. This is really cool, as it preserves the separation of rollups, while still allowing complex instant cross-rollup communications.

**Conclusion**

The Sequencer is the watchmaker God. She sets up the rollup history, and then watches it tick tick tick through to its fated state. Optimism is Arbitrum, but with 2-of-2 security instead of a 1-of-13. Nobody knows what a Sequencer does. Shared Sequencers can do atomic inclusion, but not atomic execution. There’s no way to leverage atomic inclusion into atomic execution without rollup composition or some other execution-time mechanism. All this hyperbole about shared Sequencing enabling seamless interoperability is junk science, although most people repeating it don’t know any better. Hope you like trust assumptions, because you’re in one.

[1](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-1-117995233)or non-ordering!

[2](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-2-117995233)This is important later!

[3](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-3-117995233)Which history is generated by the host chain and the Sequencer, of course.

[4](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-4-117995233)Not to be confused with host-chain Block Proposers. ORU Proposers submit a state root to the enshrined bridge. Host-chain Proposers propose a new host-chain block.

[5](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-5-117995233)Deterministically derived from the established sequence.

[6](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-6-117995233)Or have [total anarchy](https://vitalik.ca/general/2021/01/05/rollup.html), which sounds kinda cool, or a based rollup, which delegates sequencing to the host MEV supply chain.

[7](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-7-117995233)Thoughts and prayers 🙏

[8](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-8-117995233)They need the sequence in order to compute the new state.

[9](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-9-117995233)The Sequencer may lie in **this feed** without penalty.

[10](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-10-117995233)Similar to a miner, or a block proposer in modern PoS Ethereum.

[11](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-11-117995233)The Sequencer may lie in **these confirmations** without penalty.

[12](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-12-117995233)Similar to a miner, or a block proposer in modern PoS Ethereum.

[13](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-13-117995233)And, as a consequence, delete all successors to that root.

[14](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-14-117995233)Within certain constraints, e.g. forced inclusion.

[15](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-15-117995233)Because the extraction, filtration, and state-transaction functions must be deterministic, the state is deterministic, and known to the Sequencer before anyone else.

[16](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-16-117995233)Remember?? I said that’d be important later way back in footnote 2!

[17](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-17-117995233)Cross-its heart hope to die.

[18](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-18-117995233)Rollups inherently compete with each other for host resources, and cartelizing that competition would probably be net beneficial to everyone. Rollup mergers may be a thing in the future, and I think that’d be cool af

[19](https://prestwich.substack.com/p/the-definitive-guide-to-sequencing#footnote-anchor-19-117995233)So you probably want a small n. Like really small. Like, call it 5, but maybe 5’s too big? I dunno



原文链接：https://prestwich.substack.com/p/the-definitive-guide-to-sequencing