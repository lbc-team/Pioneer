# Confirmation Rule for Ethereum

> A fast confirmation rule for Ethereum proof-of-stake, with latency under 1 minute in typical mainnet conditions!



![](https://img.learnblockchain.cn/attachments/2023/06/rLNgtnJv64883b6e93bdc.jpg)

Thanks to Roberto Saltini & Francesco D'Amato for review.
This work was conducted together with Francesco D'Amato, Roberto Saltini, Luca Zanolini, & Chenyi Zhang in an April 2023 workshop.

## Introduction

Before The Merge, Ethereum's users relied on a proof-of-work confirmation rule to determine the irreversiblity of blocks. Users had the ability to choose their desired trade-off between how fast blocks are confirmed, and the level of confidence of irreversibility. After The Merge, Ethereum's proof-of-stake protocol provides a strong finalization guarantee with a latency of 16 mins (avg.). The protocol lacked a fast confirmation rule - until now!

This post outlines a confirmation rule for Ethereum proof-of-stake. The rule hopes to deliver fast block confirmations to users who can tolerate weaker safety guarantees than finality.

In ideal conditions, this rule will confirm a new block immediately after its slot. In typical mainnet conditions, the rule should be able to confirm most new blocks in under a minute. Let's have a sneak peek at the outputs of the confirmation rule on mainnet data:

![img](https://img.learnblockchain.cn/attachments/2023/06/rn6n0eUK64883b7011260.png)**Plot generated using [this prototype](https://gist.github.com/adiasg/4150de36181fd0f4b2351bef7b138893?ref=adiasg.me) of the confirmation rule.**

The rule will tell us about the safety of blocks in the current epoch, so focus on the unshaded region to the right of the checkpoint block. The rule computes a $q$ value and a min. safe $q$  value for each block. If the $q$ values of all blocks in a chain is above their min. safe $q$ values, then the head block of that chain is confirmed. In fact, the difference between these values is a measure of the maximum adversarial tolerance that the block achieves. In the figure above, the current slot is `6337565`, and the latest confirmed block is at slot `6337564`.

### Disclaimer

**The confirmation rule is not a substitute for finality!** Finality provides the ultimate guarantee of the block always remaining in the canonical chain - users that seek such irreversibility should not use the confirmation rule for making decisions. The confirmation rule provides a heuristic ***to users who believe that network synchrony will hold for the near future***, about whether a particular block is going to remain in the canonical chain.

Before we go any further, let's compare the properties of the confirmation rule & finality:

| Property            | Confirmation                                                 | Finality                                                     |
| :------------------ | :----------------------------------------------------------- | :----------------------------------------------------------- |
| Description         | Heuristic to indicate whether the block will remain canonical under synchronous network conditions. | Ultimate guarantee of irreversibility, even under asynchrony. |
| When does it break? | A confirmed block can be reorged if the network does not remain synchronous. | A conflicting block can be finalized if more than 13rd of the validators commit a slashable action. |
| Type of safety      | No accountability -- a confirmed block can be reorged and no one is slashed, when network synchrony assumptions or adversarial assumptions are violated (e.g. an adversarial majority can always reorg without any slashing required). | Accountable safety -- at least 13rd of the validator set will be slashed if a conflicting block is finalized. |

------

**Note:** The rest of this post serves as an explainer of the academic paper posted [here](https://ethresear.ch/t/confirmation-rule-for-ethereum-pos/15454?ref=adiasg.me).

### Prerequisites

- An understanding of Ethereum's fork choice components:
  - LMD GHOST fork choice
  - FFG justification and finalization
  - Block tree filtering
    - FFG updates can cause blocks to be filtered out from the block tree. Such FFG updates can only happen when we cross epoch boundaries.
    - The rule assumes [this change](https://www.adiasg.me/confirmation-rule-for-ethereum/#proposed-change-to-block-tree-filtering) to the block tree filtering rule.
- The *chain of block $b$* is defined as all the ancestors of $b$, including itself.

### Assumptions

- The votes cast by honest validators in any particular slot are received by all validators by the end of that slot, i.e., the network is synchronous with latency `< 8 seconds`.
- The adversary controls less than 13rd of the network, i.e., adversarial fraction $\beta\leq\frac13$.

## LMD Safety

For a block $b$ and current slot $n$, we define:

- $P^n_b=\frac{honest support for block}{total honest weight}$ from committees of slot $b$.slot till slot $n$.
- isLMDConfirmed$(b,n)$ as $P^n_{b′}>\frac{1}{2(1−\beta)}$ for all $ b^′$ in the chain of $b$.

If isLMDConfirmed$(b,n)$, then:

1. all honest validators in slot $n+1$ will vote in support of $b$, and
2. if $b$ has not been filtered out of the block tree at slot $n+1$, then isLMDConfirmed$(b,n+1)$.

### Proof

First, let's show that all honest validators in slot $n+1$ will vote in support of $b$. Let's look at the fork choice of an honest validator at the end of slot $n$:

![lmd_safety](https://img.learnblockchain.cn/attachments/2023/06/9xPUTQ6f64883f3bc4308.png)

- It starts with the justified checkpoint $j$, that is an ancestor of $b$.
- For every block $b^′$ that descend from $j$ and are in $b$'s chain, we know that $P^n_{b′}>\frac{1}{2(1−\beta)}>1/2$. So, at each step of the LMD GHOST fork choice, we descend to a block in the chain of $b$.
- Therefore, $b$ is in the canonical chain of honest validators at the end of slot $n$. So, all honest validators in slot $n+1$ vote in support of $b$.

Next, let's show that isLMDConfirmed$(b,n+1)$. For any block $b$′ in the chain of $b$, we have:

- $p^n_{b'}=\frac{honest support for block b′}{total honest weight}$ from committees in slot $b$′.slot till slot $n$.
- $p^{n+1}_{b'}=\frac{honest support for block b′}{total honest weight} $from committees in slot $b$′.slot till slot $n+1$.

All honest validators in slot $n+1$ vote in support of $b$, so the numerator and denominator should grow by the same amount. However, we also need to consider the "latest message" aspect of LMD GHOST - only the latest message from a validator is considered in the fork choice. Let's see how the fraction $p^n_{b'}$ changes to become $p^{n+1}_{b'}$:

|                                               | Add                                                          | Remove                                                       |
| :-------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Numerator** - honest support for block $b$′ | add the number of honest votes from slot $n+1$ that vote for $b$, which is all the honest validators from slot $n+1$. | remove the number of validators from committees in slots between $b$′.slot and $n$ **who voted in support of �**, that re-appear in the committee at slot $n+1$. |
| **Denominator** - total honest weight         | add all the honest validators from slot $n+1$.               | remove the number of validators from committees in slots between $b$′.slot and $n$, that re-appear in the committee at slot $n+1$. |

We are adding the same amount to both the numerator & denominator, but removing a larger (or equal) amount from the denominator than the numerator. Hence, the fraction is growing (non-decreasing)! So, we have:

$p^{n+1}_{b'}≥p^n_{b'}>\frac{1}{2(1−\beta)}$ for all $b$′ in the chain of $b$ **implies** isLMDConfirmed$(b,n+1)$.

### Safety Indicator

The above sections show that an appropriate value for $p^n_b$ gives us some nice LMD safety properties. However, this value relies on the *honest support for a block*, which is something we cannot compute by observing the network! We need an observable ***safety indicator*** that indicates whether $p^n_b$ is in the appropriate range.

$q^n_b=\frac{support for block b}{total weight}$ from committees in slot $b$.slot till slot $n$

If $q^n_b>\frac12+\beta$, then $p^n_b>\frac{1}{2(1−\beta)}$. While the proof is quite straightforward, we omit it from the blog post version as it requires more notations that would decrease readability. The proof can be found in the paper as Lemma 3.

In practice, we can use the following rule:

**LMD Safety Rule**
$q^n_b>\frac12+\beta$ for all $b$′ in the chain of $b$ **implies** isLMDConfirmed$(b,n)$

## Combining LMD Safety with FFG Safety

The previous section shows that under certain conditions, a block remains in the chain *as long as it has not been filtered out of the block tree*. In this section, we identify the conditions which would ensure that the block does not get filtered out of the block tree.

**Notation:**

- $n$ is the current slot, and $e$ is the current epoch.
- $b$ is a block from the current epoch $e$.
- $j$ is the latest justified checkpoint block in the post-state of $b$.
- $c$ is the checkpoint block in $b$'s chain at epoch $e$.
- There are $S$ FFG votes from epoch $e$ in support of $c$.
- $W_f$ is the weight of validators yet to vote in epoch $e$, and $W_t$ is the total weight of all validators.

### Confirmation Rule

We define the confirmation rule, isConfirmed$(b,n)$, as follows:

**Confirmation Rule**

isConfirmed$(b,n)$

 if:

- the latest justified checkpoint in the post-state of $b$ is from epoch $e-1$, and
- isLMDConfirmed$(b,n)$, and
- $S+(1−\beta)W_f≥\frac23W_t$.

We will show that isConfirmed$(b,n)$ implies that $b$ will remain in the canonical chain.

**Note:** For brevity of proofs, the above rule does not account for a few nuances of the Ethereum protocol. The complete confirmation rule is described in the [appendix](https://www.adiasg.me/confirmation-rule-for-ethereum/#complete-confirmation-rule).

### Proof

**TL;DR Proof Strategy**
We prove by induction that every honest validator sees$b$ as canonical in every future slot, specifically:

- At the start of every epoch:
  - $b $ is not filtered out in this epoch.
  - $b$ will gather all honest votes from this epoch.
- At the end of every epoch:
  - There is no justified checkpoint from this epoch that conflicts with $b$.

------

**Epoch $e$**

![ffg_safety_1](https://img.learnblockchain.cn/attachments/2023/06/JEW539kz64883f438424a.png)

At slot $n$ in epoch $e$:

- There are $S$ FFG votes from epoch $e$ in support of $c$.

![ffg_safety_2](https://img.learnblockchain.cn/attachments/2023/06/4Ga5NZc764883f4561ee9.png)

At the end of epoch $e$:

- At least$ (1−\beta)W_f$ votes from epoch $e$ will be cast in support of $c$. So, the total FFG support for checkpoint $(c,e)$ will be $S+(1−\beta)W_f≥\frac23W_t$.

  . This means two things:

  - There will be enough votes to justify $(c,e)$, and
- There will be no justified checkpoint at epoch $e$ that conflicts with $(c,e)$.

------

**Epoch $e+1$**

At the start of epoch $e+1$:

- $b$ will not be filtered out, since:

  - There will have been no justified checkpoint that conflicts with $(c,e)$
  - $b$.state.current_justified_checkpoint.epoch$≥e−1=(e+1)−2$
  
- isLMDConfirmed$(b,first_slot_{e+1})$.

![ffg_safety_3](https://img.learnblockchain.cn/attachments/2023/06/SeY2q1ch64883f46c52ab.png)

At the end of epoch $e+1$:

- At least t$ (1−\beta)W_f$ votes from epoch $e+1$ will be cast in support of $b$. This means that there will be no justified checkpoint at epoch $e+1$ that conflicts with $b$.
- We also assume that there will be block $\widetilde b $, a descendant of $b$ from epoch $e$ or $e+1$ that will include the justifying votes for $(c,e)$.

**Note:** In practice, the existence of $\widetilde b $ means that honest validators will be able to include attestations that justify $(c,e)$ in a branch descending from $b$ by the end of epoch $e+1$. If the attacker is able to prevent this, then $b$ will get filtered out.
On a related note, the goal of the fork choice change that we propose is to decrease the possibility of this happening - earlier the deadline for the honest branch to have $\widetilde b$ was the end of epoch $e$, but this change pushes the deadline to the end of epoch $e+1$.

------

**Epoch $e+2$ & beyond**

At the start of epoch $e+2$:

- $b$will not be filtered out.

  - Case 1: The latest justified checkpoint is$(c,e)$

    - There will have been a block $\widetilde b$ that descends from $b$ and $\widetilde b$.state.current_justified_checkpoint.epoch=$c$.epoch=$(e+2)−2$. The branch descending from $b$ that contains $\widetilde b$ is viable, so $b$ will not be filtered out.

  - Case 2: The latest justified checkpoint is from an epoch larger than $e$

    - There will have been no justified checkpoint that conflicts with $b$, so the latest justified checkpoint must be a descendant of $b$. There must be a branch descending from the latest justified checkpoint that is not filtered out (by definition, the filter will return at least the latest justified checkpoint). Hence, $b$ will not be filtered out.

- $isLMDConfirmed(b,first$_ $slot_{e+2})$.

At the end of epoch $e+2$:

- At least $(1−\beta)W_t$ votes from epoch $e+2$ will be cast in support of $b$. This means that there is no justified checkpoint at epoch $e+2$ that conflicts with $b$.

The above logic can be extended to $e+2+k$ for $k≥0$ by induction.

## Appendix

### Complete Confirmation Rule

In order the provide a quick & simple explanation of the confirmation rule, the above sections ignore some aspects of the Ethereum protocol:

1. Empty Parent Slot

   - When checking LMD safety for a block $b$ whose parent block is from a slot <$b.slot−1$, we need to account for the votes from committees between the parent's slot and $b$'s slot. Votes from these committees influence the choice when LMD GHOST descends from $b$'s parent - e.g., if these committees vote for a sibling of $b$, LMD GHOST may choose the sibling over $b$.

   - We modify the definition of $p^n_b$ as follows:

     - $p^n_b=\frac{honest support for block b}{total honest weight}$ from committees in slot $b.parent.slot+1$ till slot $n$.
   - $q^n_b=\frac{support for block b}{total weight}$ from committees in slot $b$.parent.slot+1 till slot $n$.
   
2. Proposer Boost

   - Say the proposer boost weight is $W_p$.

   - The constraints on $p$ and $q$ for LMD safety change as follows:

     - The definition of isLMDConfirmed$(b,n)$ changes to:

       - for all $b$′ in the chain of $b$, $p^n_{b'}>\frac{1}{2(1−\beta)}(1+\frac{proposer boost weight}{total honest weight})$ from committees in slot $b$′.parent.slot+1 till slot $n$.

     - The practical LMD safety rule changes to:

**LMD Safety Rule**
$q^n_{b'}>\frac12(1+\frac{proposer boost weight}{total honest weight})+\beta$ for all $b$′ in the chain of $b$ **implies** isLMDConfirmed$(b,n)$

1. Equivocating Votes for $c$
   - In the [reasoning of FFG support for $c$](https://www.adiasg.me/confirmation-rule-for-ethereum/#combining-lmd-safety-with-ffg-safety), the earlier section does not account for the possibility of the adversary reducing the support for $c$ by equivocating. When an equivocating FFG vote is seen, the validator is slashed immediately, and their FFG votes are discarded from consideration.
   - Let's say that the adversary is willing to slash up to $\alpha≤\beta$ fraction of the total validator set.
   - Using equivocations, the adversary can reduce the support for $c$ in epoch $e$ by min4$(\alpha W_t,S,\beta(W_t−W_f)$. The adversary can equivocate the full extent of $\alpha W_t$, but not more than the adversarial votes for $c$ cast up til this point, i.e., min$(S,\beta(W_t−W_f)$.
   - This changes the confirmation rule to:

**Confirmation Rule**

isConfirmed$(b,n)$ if:

- the latest justified checkpoint in the post-state of $b$ is from epoch $e−1$, and
- isLMDConfirmed$(b,n)$, and
- $[S−min(S,\alpha W_t,\beta(W_t−W_f))]+(1−\beta)W_f≥\frac23W_t$.

### Block Tree Filtering

Ethereum's fork choice rule works as follows:

1. Start with the highest justified checkpoint$ (j,e)$
2. Apply a filter on the block tree, according to the processed FFG information
3. Apply LMD GHOST starting from $j$, and descending down the filtered block tree

FFG information is only processed at epoch boundaries, so the fork choice can change due to Rules 1 & 2 from the above only at epoch boundaries.

The block tree filtering rule is to allow only those branches that know about the justification of $(j,e)$. E.g., a branch that descends from$ (j,e)$ but does not contain enough votes to justify $ (j,e)$ is filtered out. Let's see this with an illustration:

![filter_1](https://img.learnblockchain.cn/attachments/2023/06/nbYlpCJo64883f47b4b64.png)

$j_1$ is the highest justified checkpoint block, and the branches of $b,c$, & $f$ contain enough votes to justify $j_1$. Here, the branches of $b,c$, &  $f$  compete on the basis of LMD GHOST.

![filter_2](https://img.learnblockchain.cn/attachments/2023/06/gYBMBGBO64883f494838e.png)

Later, $j_2$ is the new highest justified checkpoint block, and only block $d$ contains enough votes to justify $j_2$. By Rule 1, we start from $j_2$, thus removing the branch of $b$ from consideration. By Rule 2, we filter out the branch of $f$. So, the only remaining branch in the block tree is the one of $d$.

#### Proposed Change to Block Tree Filtering

We propose the following change to the fork choice's block tree filtering:
If $j$ is the highest justified checkpoint block, and the current epoch is $e$, then allow a branch with leaf block $b$ if the latest justified checkpoint in the post-state of $b$ is either $j$, or from an epoch ≥$e−2$

The changes are detailed in [this pull request to `consensus-specs`](https://github.com/ethereum/consensus-specs/pull/3339?ref=adiasg.me).



原文链接：https://www.adiasg.me/confirmation-rule-for-ethereum/