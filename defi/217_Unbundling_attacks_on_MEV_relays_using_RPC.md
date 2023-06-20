# Unbundling attacks on MEV relays using RPC

This post discloses a new unbundling attack on MEV relays, which is mitigated by changes in the [latest version of Lighthouse (v4.1.0)](https://github.com/sigp/lighthouse/releases/tag/v4.1.0).

Unbundling attacks were thrown into the spotlight by a high-profile exploit on 2 April 2023 which netted over $20M USD for the attacker. Before reading this post we recommend readers familiarise themselves with the [original Flashbots disclosure](https://collective.flashbots.net/t/post-mortem-april-3rd-2023-mev-boost-relay-incident-and-related-timing-issue), and [write-up by Francesco D'Amato and Mike Neuder](https://ethresear.ch/t/equivocation-attacks-in-mev-boost-and-epbs/15338).

## Attack sequence

Like other unbundling attacks the RPC unbundling attack relies on the block proposer being willing to *equivocate* and get slashed. This is only rational if the opportunity to profit by doing so exceeds the slashing penalty (usually ~1 ETH). As we saw in the case of the first unbundling attack, front-running sandwich transactions provides such an opportunity.

The attacker needs to have an active validator nominated to propose a block. The attack proceeds as follows:

1. The attacker [requests an execution payload](https://ethereum.github.io/builder-specs/#/Builder/getHeader) from a MEV relay (e.g. ultra sound). They create a valid block using the payload header and sign it. For simplicity let block0 refer to this block both with and without its full payload attached.
2. The attacker [publishes](https://ethereum.github.io/builder-specs/#/Builder/submitBlindedBlock) the signed $\rm {block0}$ to the relay.
3. The relay validates $\rm {block0}$, adds the full execution payload, and broadcasts it. There is no equivocation (yet) and the block is by all means legitimate.
4. The attacker creates an equivocating $\rm {block1}$ with transactions lifted from block0 which has just had its payload body revealed. The attacker uses unbundling of sandwich transactions to front-run sandwich bots, such that $\rm {block1}$ generates substantial profit for the attacker.
5. The attacker *does not* publish $\rm {block1}$ on gossip, but instead creates an attestation to it. This attestation could be a regular attestation, but it's better if it's an aggregate attestation that can be published to every node on the network.
6. The attacker flood publishes their attestation for $\rm {block1}$ to lots of peers. These peers don't know the block that the attestation refers to, so they will start trying to look it up on the consensus layer's peer-to-peer RPC (using BlocksByRoot).
7. The attacker quickly complies with the RPC requests from several nodes, putting block1 in the hands of many honest peers.
8. When the honest peers apply $\rm {block1}$ to fork choice using on_block it will receive the proposer boost instead of block0 (assuming it arrives before 4 seconds). This is because fork choice awards the proposer boost to the *last* block processed, regardless of equivocation. These peers will now see $\rm {block1}$ as the head.
9. Any validators that see $\rm {block1}$ as head and have not already attested (more on this later) will attest to $\rm {block1}$. If these attestations impart enough weight (>50% of committee weight) then block1 will beat $\rm {block0}$ and become permanently canonical.

The key to the attack is the ability of the attacker to bypass the gossip duplicate filter by using RPC. Once this filter is bypassed they can exploit the "latest block wins" behaviour of fork choice which would otherwise not be reachable via gossip.

## Requires a well-resourced attacker

In some ways the RPC unbundling attack is less severe than the original attack performed on April 2. It requires several coincidences as well as substantial infrastructure investment. Namely:

- In step (5) the attacker needs an attester in the same slot as their proposal, preferably an aggregator. The probability of a single validator being selected to attest to its own block is 1/32. The probability of being selected to aggregate is roughly 1/32 * 16/274 ≈ 0.18%, assuming a committee size of ~274 (560k validators/32/64), and 𝚃𝙰𝚁𝙶𝙴𝚃_𝙰𝙶𝙶𝚁𝙴𝙶𝙰𝚃𝙾𝚁𝚂_𝙿𝙴𝚁_𝙲𝙾𝙼𝙼𝙸𝚃𝚃𝙴𝙴=16TARGET_AGGREGATORS_PER_COMMITTEE=16

  . Given the infrequency of block proposals, a solo validator would be waiting a long time for the stars to align like this. An attacker would need to have a significant number of validators in order to have reasonable odds of pulling this off. The probability of having at least one aggregator among stvalidators given a block proposal is approximately:
$$
  P(aggregator\vert proposer)=1-(1-(1/32 \times 16/274))^n
$$
  

  To surpass a 50% probability the attacker would need $n=380$validators.

- In steps (6) and (7) the attacker needs a well-connected cluster of beacon nodes in order to disseminate the attestation and the block quickly. They need block1 to be processed before the 4 second proposer boost deadline on a 50% majority of nodes.

These requirements are higher than for the original attack but certainly not out of reach. In particular it's ironic that the 380 validators required would cost around $22.5M USD at time of writing, dangerously close to what the attacker extracted in their first attack 😳.

## Benefits of client diversity

Thankfully there are forces at work operating against the attacker, including [client diversity](https://clientdiversity.org/).

In step (6) I glossed over the differences in how consensus clients handle attestations to unknown blocks. The behaviour for different clients is shown below, with 🔴 indicating behaviour which enables the attack, and 🟢 indicating behaviour that mitigates it.

- 🔴 **Lighthouse**: immediately looks up the missing block (all versions) and applies it to fork choice (prior to v4.1.0).
- 🟢 **Prysm**: only looks up unknown blocks every 4s. The attacker's 𝚋𝚕𝚘𝚌𝚔𝟷block1 will never be eligible for proposer boost because it will be looked up too late, at 4 seconds into the slot.
- 🔴 **Teku**: same as Lighthouse.
- 🔴 **Nimbus**: same as Lighthouse.
- 🟢 **Lodestar**: does not (yet) use RPC to look up unknown blocks referenced by attestations.

Given that Prysm accounts for around 35% of the network, this provides a substantial impediment to the attacker reaching the 50% attestation weight required to enshrine 𝚋𝚕𝚘𝚌𝚔𝟷block1 as canonical.

There's also another client-specific behaviour which helps a little — the point in time at which attestations are sent. This depends on the validator client being used:

- 🔴 **Lighthouse VC**: attests at 4 seconds, will attest to 𝚋𝚕𝚘𝚌𝚔𝟷block1 if the beacon node has made it head.
- 🟠 **Prysm VC**: same as Lighthouse VC by default, but can be [configured to attest to the first block to arrive](https://docs.prylabs.network/docs/prysm-usage/parameters).
- 🟢 **Teku VC**: [attests to the first block to arrive and become head](https://docs.teku.consensys.net/reference/cli#validators-early-attestations-enabled), will attest to 𝚋𝚕𝚘𝚌𝚔𝟶block0 rather than the attacker's block.
- 🟠 **Nimbus VC**: [attests to the first block to arrive](https://github.com/status-im/nimbus-eth2/issues/4111) when running with BN and VC in a single process. In split mode (separate VC), attests at 4 seconds like Lighthouse.
- 🟢 **Lodestar VC**: same as Teku, with a delay before publishing.
- 🟢 **Vouch**: same as Teku.

If we assume that most users running the Teku BN also run the Teku VC (or Vouch), then this is another 10-17% of validators that will not support the attacker's block. Optimistically, together with Prysm and other Vouch validators this is >50% of the validator set, and probably enough to make the attack *very difficult* if not impossible to pull off.

## Specification ambiguity

Even if we think the attack is unlikely with the current composition of clients, it would still be beneficial to *fix* the underlying problems and provide a stronger guarantee.

In a sense the attack exploits two sources of ambiguity in the current consensus specs:

#### 1. No standardised handling of attestations to unknown blocks

From the [P2P gossip conditions for attestations](https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/p2p-interface.md#beacon_aggregate_and_proof):

> [IGNORE] The block being voted for (𝚊𝚐𝚐𝚛𝚎𝚐𝚊𝚝𝚎.𝚍𝚊𝚝𝚊.𝚋𝚎𝚊𝚌𝚘𝚗 _ 𝚋𝚕𝚘𝚌𝚔 _ 𝚛𝚘𝚘𝚝) has been seen (via both gossip and non-gossip sources) (a client MAY queue aggregates for processing once block is retrieved).

The *"MAY"* in this sentence means that the existing behaviours of all client implementations are compliant with the spec. This is arguably a good thing, as it gives clients freedom to choose an architecture that works for them, and to optimise around that.

Although the RPC unbundling vulnerability can be patched by specifying rules for importing RPC blocks (more on this later), these rules feel very ad-hoc and arbitrary. Therefore it is our opinion that mandating a fix like this in the spec would be overly prescriptive.

#### 2. Lax handling of equivocations in fork choice

The more interesting ambiguity in our opinion is the handling of equivocations in fork choice. As noted in step (8) of the attack sequence, the attacker's block is able to *override* the original proposal from the slot because it arrived later. The relevant part of [on_block](https://github.com/ethereum/consensus-specs/blob/v1.3.0/specs/phase0/fork-choice.md#on_block) is shown below:

```python
# Add proposer score boost if the block is timely
if get_current_slot(store) == block.slot and is_before_attesting_interval:
    store.proposer_boost_root = hash_tree_root(block)
```

As long as the block is from the current slot and arrives before the attesting interval (4 seconds), it is eligible for the boost. There is no check that an existing block for the same slot doesn't already have the boost, nor any mechanism to award the boost to multiple blocks.

This is a case where the spec is somewhat ambivalent as to *which* of several equivocating blocks becomes the head. From a network health perspective it doesn't really matter, as long as the malicious proposer gets slashed (they will). It's only in the consideration of downstream effects that it becomes desirable to "pick a winner", i.e. to choose the relay's block over the attacker's.

This is similar to [Undefined Behaviour](https://en.wikipedia.org/wiki/Undefined_behavior) in compiler design, where gaps in the specification combined with implementation details can result in surprising and sometimes damaging outcomes.

## Fixing fork choice

We believe it could be beneficial to modify the fork choice specification so that only the *first* block processed in a given slot is eligible for the proposer boost. Preferring the first block is intuitive, aligns with the eager attestation strategy, and would conclusively patch the RPC unbundling vulnerability. Unbundling would be reduced to a race to propagate, which current thinking suggests is the best we can hope for.

The one-line change to the specification would be:

```python
# Add proposer score boost if the block is timely
if store.proposer_boost_root == Root() and get_current_slot(store) == block.slot and is_before_attesting_interval:
    store.proposer_boost_root = hash_tree_root(block)
```

We plan to open a pull request to consensus-specs with this change so that it can be discussed, and possibly rolled out without a hard fork (pending further analysis).

Alternatively the attack could be mitigated along with other unbundling attacks by the *headlock* protocol described in [Francesco and Mike's write-up](https://ethresear.ch/t/equivocation-attacks-in-mev-boost-and-epbs/15338). There are also discussions of removing weight from equivocating blocks, in order to re-org them out and ensure the slot is skipped.

## The temporary mitigation

Modifying fork choice is a delicate procedure and not one that we wish to rush. Therefore in the days after the vulnerability was discovered on April 6 we devised a temporary mitigation based on the handling of RPC blocks, and implemented it in Lighthouse.

The mitigation changes how RPC blocks are handled after downloading. Rather than applying them immediately, Lighthouse first checks two additional conditions:

- Is the block arriving on time (before the 4 second deadline)?
- Has a block for the same slot already been seen on gossip?

If the answer to both of these questions is *yes*, then Lighthouse queues the block and reprocesses it 4 seconds later. This ensures that equivocating blocks that arrive over RPC never receive the proposer boost.

We discussed this patch with the other vulnerable clients (Teku and Nimbus) and collectively decided that it wouldn't be worth implementing outside Lighthouse. Firstly, because patching Lighthouse already covers a substantial portion of the validator set (~35%). Secondly because several validator clients already mitigate the vulnerability. Our hope is that Teku and Nimbus will be patched via the more comprehensive fork choice fix. In the meantime, no risk to users of either client or MEV relays/searchers is posed by their current behaviour.

## Timeline

- April 2: first unbundling vulnerability is exploited on mainnet.
- April 6: discovery of the RPC unbundling vulnerability by Michael Sproul in discussion with Potuz from Prysm.
- April 7: disclosure of RPC unbundling to Flashbots and ultra sound relays, letting them know that it exists but cannot be patched at the relay level.
- April 12: implementation of first patch in Lighthouse: [sigp/lighthouse#4179](https://github.com/sigp/lighthouse/pull/4179). Formation of a cross-client working group to discuss applying the patch to Teku, Nimbus and Lodestar.
- April 14: fixes to the first patch, by Paul Hauner: [sigp/lighthouse#4192](https://github.com/sigp/lighthouse/pull/4192).
- April 19: further fixes by Paul to prevent indefinite re-queueing of RPC blocks: [sigp/lighthouse#4208](https://github.com/sigp/lighthouse/pull/4208).
- April 20: release of [Lighthouse v4.1.0](https://github.com/sigp/lighthouse/releases/tag/v4.1.0) which includes the mitigation.
- May 1: large staking pools contacted and encouraged to update to Lighthouse v4.1.0.
- May 10: majority of Lighthouse validators observed to have updated to v4.1.0 based on block graffiti. Network no longer deemed vulnerable.
- May 11: responsible disclosure.

## Conclusion

We have disclosed a variant of the unbundling attack that exploits the handling of equivocating blocks received via RPC. This vulnerability is mitigated in Prysm, Teku, and the latest version of Lighthouse, and is no longer exploitable on mainnet.

We have plans to pursue a more comprehensive mitigation through a minor change to fork choice, which can hopefully be rolled out prior to Deneb.

Thanks to Potuz, Mike Neuder, DappLion, Jimmy Chen and Paul Hauner for reviewing this post, and Jim McDonald for input on Vouch's behaviour. Thanks to Age Manning for input on the likeliness of an attack performed via RPC, and the other client teams for their prompt attention.



原文链接：https://lighthouse-blog.sigmaprime.io/mev-unbundling-rpc.html