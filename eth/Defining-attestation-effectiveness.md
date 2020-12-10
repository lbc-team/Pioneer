> * 来源：https://www.attestant.io/posts/defining-attestation-effectiveness/ 

# Defining Attestation Effectiveness

## Introduction

Attestant is a non-custodial Ethereum 2 staking service that provides the highest levels of security for customer funds whilst also utilizing advanced validating strategies to reap higher rewards than would be possible with more traditional validating infrastructures. One of the ways it measures this is by tracking the generation and inclusion of attestations of Attestant validators for the Ethereum 2 blockchain, which is a critical metric as the sooner an attestation is included on the blockchain, the higher its reward. This article takes a look at how Attestant calculates attestation effectiveness, both individually and on aggregate.

## Attestations

An attestation is a vote by a validator about the current state of the Ethereum 2 blockchain. Every active validator creates one attestation per epoch (~6.5 minutes), consisting of the elements shown below:

![Figure 1: Structure of an attestation](https://img.learnblockchain.cn/2020/12/10/16075726638187.jpg)

An interesting element is the chain head vote, which is a vote the validator makes about what it believes is the latest valid block in the chain at the time of attesting. The structure of a chain head vote is shown below:

![Figure 2: Structure of a chain head vote](https://img.learnblockchain.cn/2020/12/10/16075727007294.jpg)

Here, the slot defines *where* the validator believes the current chain head to be, and the hash defines *what* the validator believes it to be. The combination uniquely defines a point on the blockchain, and with enough votes the network reaches consensus about the state of the chain.

Although the data in each attestation is relatively small, it mounts up quickly with tens of thousands of validators. As this data will be stored forever in the chain, reducing it is important, and this is done through a process known as *aggregation*.

Aggregation takes multiple attestations that have all chosen to vote with the same committee, chain head vote, and finality vote, and merges them together in to a single *aggregate attestation*:

![Figure 3: Structure of an aggregate attestation](https://img.learnblockchain.cn/2020/12/10/16075767573865.jpg)


An aggregate attestation differs in two ways from a simple attestation. First, there are multiple validators listed. Second, the signature is an aggregate signature made from the signatures of the matching simple attestations. Aggregate attestations are very efficient to store, but introduce additional communications and computational burdens (more on this below).

If every validator was required to aggregate all attestations it would quickly overload the network with the number of communications required to pass every attestation to every validator. Equally, if aggregating were purely optional then validators will not bother to waste their own resources doing so. Instead, a subset of validators is chosen by the network to carry out aggregation duties[1](#fn1). It is in their interest to do a good job, as aggregate attestations with higher numbers of validators are more likely to be included in the blockchain so the validator is more likely to be rewarded.

Validators that carry out this aggregation process are known as *aggregators*.

## Attestation reward scale

Ethereum 2 uses the metric *inclusion distance* when calculating attestation rewards for validators. The inclusion distance of a slot is the difference between the slot in which an attestation is made and the lowest slot number of the block in which the attestation is included. For example, an attestation made in slot sss" role="presentation" style="font-size: 120%; position: relative;">s and included in the block at slot s+1s+1s+1" role="presentation" style="font-size: 120%; position: relative;">s+1 has an inclusion distance of 111" role="presentation" style="font-size: 120%; position: relative;">1. If instead the attestation was included in the block at slot s+5s+5s+5" role="presentation" style="font-size: 120%; position: relative;">s+5 the inclusion distance would be 555" role="presentation" style="font-size: 120%; position: relative;">5.

**The value of an attestation to the Ethereum 2 network is dependent on its inclusion distance, with a low inclusion distance being better than high. This is because the sooner the information is presented to the network, the more useful it is.**

To reflect the relative value of an attestation, the reward given to a validator for attesting is scaled according to the inclusion distance. Specifically, the reward is multiplied by 1d1d1d" role="presentation" style="font-size: 120%; position: relative;">\frac{1}{d}, where ddd" role="presentation" style="font-size: 120%; position: relative;">d is the inclusion distance.

![Figure 4: Attestation rewards as a function of inclusion distance](https://img.learnblockchain.cn/2020/12/10/16075767839189.jpg)


If the network is functioning perfectly, all attestations will be included with an inclusion distance of 1\. This results in attestations being maximally effective, and as such maximally rewarding. If an attestation is delayed, the reward to the validator is reduced accordingly.

## Attestation inclusion process

How are attestations included on the Ethereum 2 chain? The process is as follows[2](#fn2):

1. every attesting validator generates an attestation with the data it has available about the state of the chain;
2. the attestation is propagated around the Ethereum 2 network to relevant aggregators;
3. every relevant aggregator that receives the attestation aggregates it with other attestations that have the same claims;
4. the aggregated attestation is propagated around the Ethereum 2 network to all nodes; and
5. any validator that is proposing a block and has yet to see the aggregated attestation on the chain adds the aggregated attestation to the block.

Whenever an attestation has an inclusion distance greater than 1 it is important to understand why. There are a number of possible reasons:

### Attestation generation delay

A validator may have problems that result in delayed attestation generation. For example, it may have out-of-date information regarding the state of the chain, or the validator may be underpowered and take a significant amount of time to generate and sign the attestation. Regardless of the reason, a delayed attestation has a potential knock-on effect for the rest of the steps in the process.

### Attestation propagation delay

Once an attestation has been generated by a validator it needs to propagate across the network to the aggregators. The nature of this process means that early propagation is critical to ensure that it is received by an aggregator in time for integration into the aggregated attestation before broadcasting. Validators should attempt to ensure they are connected to enough varied peers to ensure fast propagation to aggregators.

### Aggregate generation delay

An aggregator can delay the attestation aggregation process. Most commonly this is because the node is already overloaded by generating attestations, but the speed of the aggregation algorithm can also cause significant delays when there is a large number of validators that need to be aggregated.

### Aggregate propagation delay

Similar to attestation propagation delay, the aggregation attestation needs to make its way around the network and can suffer the same delays.

### Block production failure

For an attestation to become part of the chain it needs to be included in a block. However, block production is not guaranteed. A block may not be produced because a validator is offline, or is out of sync with the rest of the network and so produces a block with invalid data that is rejected by the chain. Without a block there is no way to include the attestation in the chain at that slot, resulting in a higher than optimal inclusion distance.

Block production failure has a second impact, which is that it increases the total number of attestations that are eligible for inclusion in the next block that is produced. If there are more attestations available than can fit in a block the producer is likely to include the attestations that return the highest reward, which will be those with the lowest inclusion distance. This can result in attestations that miss their optimal block also missing subsequent blocks due to being less and less attractive to include.

The fact that block production is out of the validator’s control[3](#fn3) leads us to define the term *earliest inclusion slot*, where the earliest inclusion slot is the first slot greater than the attestation slot in which a valid block is produced. This takes in to account the fact that attestations cannot be included in blocks that do not exist, and is no reflection on the effectiveness of the validator.

### Malicious activity

Notwithstanding the above, it is possible for a malicious actor to refuse to include any given attestations in their aggregates, or to refuse to include attestations in their blocks. The former is mitigated by having multiple aggregators for each attestation group, and the latter by the cost of excluding an aggregated attestation. Ultimately, however, if the cost of excluding an attestation from a block is compensated for monetarily, or is considered to have a higher value politically, there is nothing an attesting validator can do to force inclusion by a block-producing validator.

## Calculating attestation effectiveness

Attestation effectiveness can be thought of as how useful an attestation is to the network, considering both block production and inclusion distance. It is formally defined as:

$\frac{earliest inclusion slot - attestation slot}{actual inclusion slot - attestation slot}$

and represented as a percentage value. Some sample effectiveness calculations follow:

| Attestation slot | Earliest inclusion slot | Actual inclusion slot | Calculation | Effectiveness |
| --: | --: | --: | --: | --: |
| 5 | 6 | 6 | $\frac{6-5}{6-5}$ | 100% |
| 5 | 6 | 7 | $\frac{6-5}{7-5}$| 50% |
| 5 | 6 | 8 | $\frac{6-5}{8-5}$ | 33.3% |
| 5 | 7 | 7 | $\frac{7-5}{7-5}$ | 100% |
| 5 | 7 | 8 | $\frac{7-5}{8-5}$ | 66.7% |
| 5 | 7 | 9 | $\frac{7-5}{9-5}$ | 50% |

An attestation that fails to be included with the maximum inclusion distance of 32 is considered to have an effectiveness of 0.

## Aggregate attestation effectiveness

Attestation effectiveness for a single attestation is interesting but not very useful by itself. Aggregating effectiveness over multiple attestations, both over time and multiple validators, gives a better view of the overall effectiveness of a group of validators. Aggregate effectiveness can be calculated as a simple average of individual attestation effectiveness, for example a 7-day trailing average across all validators in a given group.

## Conclusion

When Ethereum 2 launches, thousands of nodes will locate each other and begin proposing and attesting to blocks. As with all immature networks, there will be a lot to learn about how to make your nodes as effective as possible. One clear metric that can be used to track node efficiency is attestation effectiveness, as outlined here. Stakers looking to maximize their rewards can use attestation effectiveness as a way of understanding their overall performance.

Here at Attestant we track attestation effectiveness for all our validators and aggregate the data in our customer reports to provide clear metrics for performance. We are excited to share further metrics with you as we continue to expand our non-custodial Ethereum 2 staking service.




