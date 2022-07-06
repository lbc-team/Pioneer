原文链接：https://www.symphonious.net/2021/01/10/exploring-eth2-attestation-rewards-and-validator-performance/

# Exploring Eth2: Attestation Rewards and Validator Performance

Through the beacon chain testnets people have been gradually developing better ways to evaluate how well their validators are working. Jim McDonald made a big leap forward [defining attestation effectiveness](https://www.attestant.io/posts/defining-attestation-effectiveness/) which focuses on the inclusion distance for attestations. That revealed [a bunch of opportunities for clients to improve the attestation inclusion distance](https://www.symphonious.net/2020/09/08/exploring-eth2-attestation-inclusion/) and attestation effectiveness scores improved quite dramatically until now scores are generally at or close to 100% pretty consistently.

But then [beaconcha.in](https://beaconcha.in/) added a view of how much was earned for each attestation. Suddenly people were left wondering why some of their “rewards” were negative even though the attestation was included quickly. It became obvious that inclusion distance was only one part of attestation rewards.

### How Attestation Rewards Work

There are four parts in total:

- Reward based on inclusion distance
- Reward or penalty for getting the source correct
- Reward or penalty for getting the target correct
- Reward or penalty for getting the head correct

It turns out that inclusion distance is the smaller of these components. Ben Edgington explains all the detail very well in [his annotated spec](https://benjaminion.xyz/eth2-annotated-spec/phase0/beacon-chain/#get_attestation_deltas). First we calculate the base reward, which is the component which factors in the validator’s effective balance (lower rewards if your effective balance is less than the maximum 32ETH) and the total staked ETH (reducing rewards as the number of validators increase).

Then for the source, target and head attestations, a reward or penalty is applied depending on whether the attestation gets them right. A missed attestation is penalised for all three. The penalty is 1 * base reward. The reward however factors in a protection against [discouragement attacks](https://github.com/ethereum/research/blob/master/papers/discouragement/discouragement.pdf) so is actually base reward * percentage of eth that attested correctly. This provides incentive for your validator to do whatever it can, like relaying gossip well, to help everyone stay in sync well.

Finally the inclusion distance reward is added. There’s no penalty associated with this, missed attestations just don’t get the reward. 1/8th of this reward is actually given to the block proposer as reward for including the attestation, so the maximum available reward for the attester is 7/8th of the base reward. So it winds up being (7/8 * base reward) / inclusion distance.

So inclusion distance is actually the smallest component of the reward – not only is it only 7/8th of base reward, there’s no penalty attached. The most important is actually getting source right as attestations with incorrect source can’t be included at all, resulting in a 3*base reward penalty. Fortunately getting source right is also the easiest because it’s back at the justified checkpoint so quite hard to get wrong.

### Evaluating Validators

If we’re trying to evaluate how well our validator is doing, these calculations add quite a lot of noise that makes it difficult. Especially if we want to know if our validator is doing better this week than it was last week. If you just look at the change in validator balance, how many block proposals you were randomly assigned dominates and even just looking at rewards for attestations is affected by the number of validators and how well other people are doing.

I’d propose that we really want to measure what percentage of available awards were earned. That gives us a nice simple percentage and is highly comparable across different validators and time periods.

The first step is to think in terms of the number of base rewards earned which eliminates variance from the validator’s balance and total eth staked. Then we can ignore the discouragement attack factor and say that each of source, target and head results in either plus or minus 1 base reward. Inclusion distance is up to 7/8th of a base reward, scaling with distance like normal. Like for attestation effectiveness, we’d ideally also use the optimal inclusion distance – only counting the distance from the first block after the attestation slot to avoid penalising the validator for empty slots they couldn’t control. In practice this doesn’t make a big difference on MainNet as there aren’t too many missed slots.

So each attestation duty can wind up scoring between -3 and +3.875 (3 and 7/8ths). For any missed attestation, the score is -3. For any included attestation, we calculate the 4 components of the score with:

Inclusion distance score: (0.875 / optimal_inclusion_distance)

Source score: 1 (must be correct)

Target and head scores: 1 if correct, -1 if incorrect

And to get a combined score, we need to add them together.

We can actually do this with the metrics available in Teku today:

```
(
  validator_performance_correct_head_block_count - (validator_performance_expected_attestations - validator_performance_correct_head_block_count) +
  
  validator_performance_correct_target_count - (validator_performance_expected_attestations - validator_performance_correct_target_count) +
  
  validator_performance_included_attestations - (validator_performance_expected_attestations - validator_performance_included_attestations) +
  
  (0.875 * validator_performance_included_attestations / validator_performance_inclusion_distance_average)
) / validator_performance_expected_attestations / 3.875
```

Which is essentially :

```
(
  (correct_head_count - incorrect_head_count + 
  correct_target_count - incorrect_target_count + 
  included_attestation_count - missed_attestation_count
  ) / expected_attestation_count +
  0.875 / inclusion_distance_average
) / 3.875
```

To give a score between 0 and 1 pretty closely approximating the percentage of possible attestation rewards that were earned. With the discouragement attack factor ignored, we are slightly overvaluing the source, target and head rewards but it’s very minimal. On MainNet currently they should be +0.99 when correct instead of +1 so doesn’t seem worth worrying about.

You can also calculate this fairly well for any validator using a [chaind](https://github.com/wealdtech/chaind) database with a [very long and slow SQL query](https://gist.github.com/ajsutton/92881c19ae2da8facc3bae6c6f1eb691).

### Evaluating the Results

Looking at the numbers for a bunch of validators on MainNet, generally validators are scoring in the high 90% range with scores over 99% being common but over anything more than a day it’s hard to find a validator with 100% which generally matches what we’d expect given the high participation rates of MainNet but knowing that some blocks do turn up late which will likely result in at least the head being wrong.

One key piece of randomness that’s still creeping into these scores though are that its significantly more likely to get the target wrong if you’re attesting to the first slot of the epoch – because then target and head are the same and those first blocks are tending to come quite late. There are spec changes coming which should solve this but it is still affecting results at the moment.

### What About Block Rewards?

For now I’m just looking at what percentage of blocks are successfully proposed when scheduled (should be 100%). There are a lot of factors that affect the maximum reward available for blocks – while blocks aren’t reaching the limit on number of attestations that can be included, I’d expect that all the variation in rewards comes down to luck. Definitely an area that could use some further research though.