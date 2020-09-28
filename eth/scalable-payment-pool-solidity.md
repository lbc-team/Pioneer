
# Scalable Payment Pools in Solidity

## Paying a lot of people without paying a lot of gas

An interesting problem I’ve been working on lately: payment pools. For those new to my blog, I’m an Ethereum developer at [Cardstack](http://cardstack.com/), and I routinely post about fun challenges we are solving.

At Cardstack we are building an application framework for decentralized applications (dApps) that puts user experience first. A key to that is building out our [Tally Protocol](/cardstack/the-tally-protocol-scaling-ethereum-with-untapped-gpu-power-d949a441c082), which we feel is going to revolutionize the scalability of the blockchain.

One of the aspects of Tally is building a mechanism to distribute token payments and royalties from application users to application owners and software developers, as well as to reward *analytic miners* that contribute GPU cycles to calculate the payments and royalties for each payment cycle.

The means by which *analytic miners* determine the allocation of tokens, reach consensus of the solution, and write the solution on-chain will be described in another really fascinating up-coming post — stay tuned!

For now, I’m going to focus more upon the disbursements of the payments from the payment pool.

Payment pools are a general mechanism that can be used to model a **one-to-many** or **many-to-many payment channel**. The idea is that tokens can be deposited into a pool from various sources, and then based on “rules”—implemented on-chain or off-chain—the tokens in the pool can be disbursed to many recipients. Essentially, our approach has the ability to aggregate large numbers of micro-payments into a single settlement, saving a lot of gas.

Consider a Spotify-like scenario, where royalties are paid to musicians each time someone listens to a song. A streaming service could fund a payment pool for their musicians with a large sum of tokens. Then as people stream music, those streaming usage logs are aggregated over each payment cycle, and the aggregated payment amounts are fed to the payment pool to disburse the royalties among the musicians in a way that uses less gas than if an on-chain transaction was issued for each time someone listened to a song.

* * *

# First Take: Array-Based Payment Pool

Our initial conception of this on-chain payment pool smart contract was pretty straightforward.

The idea was that the payment pool smart contract would receive ERC-20 tokens from various token collection smart contracts, and *analytic miners* would determine the allocation of tokens within the payment pool by analyzing signed application usage logs and other on-chain signals of application usage. The *analytic miners* would reach a consensus on payout amounts from the payment pool and submit the payout to the payment pool as an array of payees’ addresses and an array of their payment amounts which would be written into a ledger that the payment pool administers.

The most obvious drawback to this solution is the fact the payment pool is dealing with an unbounded array of payees and their payment amounts, meaning this kind of transaction could run into the block gas limit. That would require the payment pool function to monitor its gas budget while keeping track of its progress through the list of payees, so that it could pick up where it left off in a subsequent transaction if it exceeded its gas budget.

We did a little experimentation, and we were able to iterate though around 200 payees before we exceeded our gas budget when the transaction was using the block gas limit as the gas limit for the transaction. At today’s ETH exchange rate, with a gas prices of 30 *gwei* and a block gas limit of around 8,000,000, that means about ＄260 USD in gas fees in order to process a payee list of around 200 recipients. Basically we would be paying a little more than ＄1/payee in gas fees.

Clearly, this approach does not scale. Back to the drawing board…

* * *

# Enter: Merkle Trees

In our search for a better approach, we became inspired by [this Ethereum research post](https://ethresear.ch/t/pooled-payments-scaling-solution-for-one-to-many-transactions/590).

The idea is that instead of having the payment pool administrate a ledger of the payees and their payment amounts, we could build a Merkle tree that holds the payees and their payment amounts, and have the payees withdraw their payment amounts by having them submit the Merkle proof for their particular payment. The Merkle proof then becomes a key that only works for the payee that unlocks the payee’s tokens within the payment pool.

The beauty of the Merkle tree approach is that we only need to write a 32 byte Merkle root to the payment pool, and that there is no upper boundary on the number of payees that can live in the Merkle tree. Regardless of how many payees are represented by the Merkle tree we only ever need to write a 32 byte Merkle root for the tree: the gas fees can be reasonably measured in pennies for an unbounded number of payees.

As many of us know: a [Merkle tree](https://blog.ethereum.org/2015/11/15/merkling-in-ethereum/) is a novel binary tree structure that allows us to easily and cheaply confirm if a node actually exists in the tree. Merkle trees form the substrate upon with Ethereum is built, and facilitate the ability for an Ethereum node to validate blocks without needing the full history of the blockchain.

The most important aspects of Merkle trees are that:

1. Each node is the hash of the sum of the node’s childrens’ hashes
2. The root node contains a hash that is effected by every single node in the tree
3. We can confirm if a node exists in the tree by adding together the hash of a node and its “great-aunts & uncles” to see if they match the root node.

![](https://img.learnblockchain.cn/2020/09/28/16012644579903.jpg)
<center>By Azaghal (Own work) [CC0], via [Wikimedia Commons](https://commons.wikimedia.org/wiki/File%3AHash_Tree.svg)</center>


Effectively, we put the data that we care about in the leaf nodes of the Merkle tree. There are many code libraries available that can do this, where you supply the library with an array, and the library will sort the array, and build the Merkle tree structure with the supplied sorted array forming the leaf nodes of the Merkle tree. The library can provide the root of the Merkle tree as well as provide the *proof* for any node, where the *proof* is a list of the node’s hashed great-aunts & uncles that when added up with the hash of the node will equal the Merkle root.

The way that we can verify a node actually exists in a Merkle tree is to add the node with its proof and see if that result is equal to the root node. It turns out there is actually a [Solidity library](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/MerkleProof.sol) to do exactly this (thanks to Open Zeppelin)!

![](https://img.learnblockchain.cn/2020/09/28/16012645229342.jpg)
<center>In this example, we can confirm that L2 exists in the tree by adding **hash(L2)** to the hash **A** and the hash **B** and confirm that the hash of the sum is the **root node**’s hash.</center>


* * *


# Merkle Tree Payment Pool

Okay, so how can we leverage a Merkle tree in our payment pool?

This approach leverages an approach that requires both on-chain and off-chain mechanisms. In order to generate the Merkle tree, we can use an off-chain process (e.g. NodeJS module) to construct a Merkle tree from a list of payees and their payment amounts. In this approach, each node is a string concatenation of the payee’s address and their payment amount.

Consider the following payee list:

![](https://img.learnblockchain.cn/2020/09/28/16012645735048.jpg)

We can convert this list to an array that looks like this:

![](https://img.learnblockchain.cn/2020/09/28/16012645932286.jpg)

Then we can build a Merkle tree from this list, and the contract owner can submit the Merkle root to the payment pool contract. As well as, we can publish the leaf nodes and their proofs in a place where payees can get access to this data (e.g. IPFS).

So that a list that looks like this is made available:

![](https://img.learnblockchain.cn/2020/09/28/16012646094709.jpg)
<center>(note that these are not the actual Merkle proofs for these nodes, but some random hex to convey the idea)</center>


A payee could then invoke a function on the payment pool contract with the amount and proof as the parameters of the function in order to withdraw their tokens.

The idea is that the `paymentPool.withdraw()` function would reconstruct the leaf node from the `msg.sender` and the token amount. The withdraw function could then hash that leaf node and add the hashed leaf node to the proof (which is the hex representation of the hashes that make up the proof). If the hash of the sum of the hashed leaf node and the provided proof equal the Merkle root that was submitted by the contract owner, then the `paymentPool.withdraw()` function can permit the token transfer from the payment pool to the `msg.sender`.

Additionally, we’ll need to keep track of the withdrawals for each of the payees, so that the `msg.sender` cannot issue duplicate `paymentPool.withdraw()` function calls.

So—this approach is a good start. We have unlocked the ability to pay as many payees as we want from the payment pool without having to incur massive gas fees, and moreover, it means we can decouple our gas fee used to specify the payees from the amount of payees that can withdraw from the payment pool. The payee’s proof basically acts like a key that only works for transactions initiated from each payee’s address that can be used to unlock that payee’s tokens from the pool.

But we still have a few challenges.

1. What if the payee wants to only withdraw a partial amount of the tokens that are due to them?
2. How can we represent the amount of tokens that are available for the address/proof pair on-chain?
3. What about multiple payment cycles? Can we use old proofs when the Merkle root is updated?


* * *


# Making It Even Better

To address the challenges mentioned above, we added metadata into the proof for each payee, and we introduced the idea of “payment cycles” to the payment pool.

## Payment Cycles

Within the payment pool smart contract we keep track of the payment cycle delineated by the submission of each Merkle root. The submission of a Merkle root to the payment pool by the contract owner signifies the end of the current payment cycle, and a new payment cycle begins.

Within the payment pool smart contract we maintain a mapping property that maps the payment cycle number to the Merkle root that governs that payment pool for that payment cycle. This way, when the `paymentPool.withdraw()` function is called with a proof, if we know the payment cycle the proof was generated against, we can validate the proof against the correct Merkle root.

This allows payees to use old proofs to claim their payments. It does mean, however, that a proof is tied to a particular amount of tokens. You cannot claim more tokens than the amount of tokens used in the generation of the leaf node’s hash for the proof that is supplied.

As long as the payment pool is keeping track of how many tokens have been withdrawn for each payee, we can make sure to deduct from the cumulative amount of tokens that are allocated to the payee, the amount of tokens that they have already withdrawn to arrive at the amount of tokens available for a given proof/address pair.

## Proof Metadata

Another challenge to overcome is how to withdraw a token amount that is less than the amount of tokens used to create the proof. Additionally, how can we make it easier for the user to associate the proof to a particular payment cycle, so that the correct Merkle root can be used to validate the withdrawal request?

For these challenges we have introduced the idea of attaching metadata to the proof itself. What this means is that we can incorporate into the proof both the payment cycle number and the *cumulative* amount of tokens owed to the payee that was used to generate the payee’s payment leaf node in the Merkle tree. As a result, the payee invokes the `paymentPool.withdraw()` function with an amount up to, but not exceeding the amount of tokens available for the proof, as well as the proof itself.

Simple, right? The payee is calling `paymentPool.withdraw()` with the number of tokens they want and a special key that works just for them to unlock those tokens from the payment pool.

So here’s how that works: as I mentioned above, the proof is really just an array of the great-aunt & uncle hashes that has been serialized into a hexadecimal format. To include metadata in the proof, what we do is simply add a couple extra items to that proof array as part of the code library that we use to retrieve a proof for a node in the Merkle tree.

Specifically, we are adding the payment cycle number that corresponds to the Merkle root (we can get that by calling `paymentPool.numPaymentCycles()` on the paymentPool smart contract before the Merkle root is submitted to the contract) and we are adding the cumulative amount of tokens the payee is allowed to withdraw. Within the `paymentPool.withdraw()` function what we do is we strip the metadata off of the proof so that the `paymentPool.withdraw()` function knows the payment cycle the proof pertains to, as well as the amount of tokens that is part of the leaf node in the Merkle tree for this payee.

This allows the `paymentPool.withdraw()` function to look up the correct Merkle root for the proof, as well as to construct the leaf node hash for the payment correctly by using the `msg.sender` and the amount of tokens that appeared within the proof metadata. Now the amount that appears in the `paymentPool.withdraw(amount, proof)` is the amount of tokens that the payee wishes to withdraw from the overall amount of tokens that the proof entitles the payee to receive.

![](https://img.learnblockchain.cn/2020/09/28/16012646815076.jpg)
<center>Figure: Cardstack’s approach of payment pool via metadata-proof Merkle Trees</center>

This approach also allows us to provide an on-chain function that anyone can use to see the amount of tokens that are available for any given proof provided that the requestor knows the address of the payee that goes along with the proof.

## Important Considerations

I’ve mentioned a couple times in this solution that the Merkle tree needs to keep track of the cumulative amount of tokens, meaning that the list of payees and their amounts can only ever grow over time — we should not ever see that a payee’s cumulative amount be less in a subsequent payment cycle.

Why is that? This is a nuance of this particular approach: the Merkle trees we build for each payment cycle need to reflect the cumulative payment amounts for the payees, and a mapping of payment withdrawals should be maintained in the payment pool, the difference of which is the amount that the payee can be allowed to withdraw for any valid proof that they provide (and obviously not permitting a withdrawal when the difference is negative).

If the cumulative payment amounts in subsequent payment cycles actually decreased, that means math to calculate the amount of tokens available for the proof, the difference between the amount already withdrawn and the cumulative total in the proof’s metadata will be incorrect, and negatively penalize available balance of subsequent proofs for the payee, such that they wont be able to withdraw all of their tokens.

This solution is heavily reliant on off-chain techniques — specifically, posting the payee’s proofs in a place that they can be easily discovered (IPFS is probably the most obvious place). Likely you’ll want to also post the amount of tokens that the payee received for the payment cycle, and perhaps even provide links to a dApp that can display the balance available for the proof in the payment pool.

Additionally it is worth noting that in this solution (and all the solutions mentioned in this post) do not address how to make sure that the payment pool is fully funded so that the withdrawals made by the payees can continue un-impeded. In the code samples we provide, we do ensure that the payment pool has enough funds before attempting to perform a transfer of tokens to the payee when they invoke the `paymentPool.withdraw()` function. One conceivable approach here would be to emit payment pool token balance warning events when the payment pool balance drops below a particular threshold.

# What’s Next

Feel tree to play with this solution, improve it, and use it in your own contracts. You can find the code (both the contracts and the javascript library that we use to build the proof and the metadata) in our [GitHub repo](https://github.com/cardstack/merkle-tree-payment-pool). The README file and tests included in the repo demonstrate at a code level how to leverage this approach. We’d love to hear your thoughts on this approach.

Moving forward, we at Cardstack plan to use this approach as a means to facilitate payments for our exciting new [Tally Protocol](/cardstack/the-tally-protocol-scaling-ethereum-with-untapped-gpu-power-d949a441c082). One of the main themes around the Tally Protocol is building an approach to scale the blockchain. Leveraging a Merkle tree based payment pool is a big part of that overall approach. Although, we have even bigger ideas around how we can scale the blockchain embedded at the heart of the Tally Protocol. Stay tuned for more!

原文链接：https://medium.com/cardstack/scalable-payment-pools-in-solidity-d97e45fc7c5c
作者：[Hassan Abdel-Rahman](https://medium.com/@habdelra?source=post_page-----d97e45fc7c5c--------------------------------)
