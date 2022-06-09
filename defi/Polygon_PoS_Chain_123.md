原文链接：https://finematics.com/polygon-commit-chain-explained/

# Polygon PoS Chain – A Commit Chain And Not A Sidechain?

视频链接：https://youtu.be/f7F67ZP9fsE

So what is a commit chain? How is it different from a sidechain? And what makes [Polygon](https://finematics.com/polygon-matic-explained/) Commit Chain a commit chain rather than a sidechain? We’ll answer all of these questions in this article. 

Let’s start with understanding what exactly a sidechain is. 

#### Sidechain 

A sidechain, in essence, is a separate blockchain that can be used as one of the ways of scaling a Layer 1 blockchain such as Ethereum or Bitcoin. As the name suggests, a sidechain runs in parallel or “on the side” of the main chain. 

Sidechains have their own consensus mechanisms usually in the form of Proof-Of-Stake, Delegated-Proof-Of-Stake or Proof-Of-Authority. 

Sidechains allow users to send their tokens from the main chain and receive them on the sidechain. Once the funds are transferred to the sidechain they can be used within the sidechain ecosystem. Similarly, users can withdraw their tokens from a sidechain back to the main chain. The whole process is called a 2-way peg or a 2-way bridge. Thing to note is that once the user tokens are on the sidechain then they are completely reliant on the consensus mechanism of the sidechain

Initially, all scaling solutions such as sidechains, Plasma and rollups were classified as Layer 2 solutions as they are built on top of Layer 1. 

![img](https://finematics.com/wp-content/uploads/2021/04/layer2-1024x505.png)

After a while, the Ethereum community started differentiating between scaling solutions fully secured by the Ethereum main chain – Layer 2 and other scaling options with their own consensus mechanisms – sidechains. At the moment, pretty much all scaling solutions are classified as either one or the other. 

When it comes to Polygon Commit Chain, it is worth differentiating it from a sidechain as it has a lot of extra features that rely on the security of the main Ethereum layer.

Let’s review them one by one. 

#### Permissionless Validators on Ethereum

Many sidechains use a consensus mechanism that limits the number of entities able to verify the chain. For example, in a Delegated-Proof-Of-Stake (DPoS) there are usually 21 validators who are chosen by the token holders and only these validators are able to validate the state of the blockchain. Similarly, in a Proof-Of-Authority (PoA) model the chain initiator chooses authorities to run the chain. This excludes most participants and creates a situation where only a selected few are responsible for making sure the transactions are validated correctly. 

In Polygon PoS Chain anyone can join the network and start validating the state of the blockchain. This is important as it allows any participants to become validators and check by themselves that all transactions are processed correctly. 

Validators on Polygon PoS Chain have to stake their MATIC tokens and run a full node. 

MATIC tokens are staked on the Ethereum main chain. This is also where the set of all validators is maintained. If a validator starts acting in a malicious way, for example, by double signing or having a significant downtime their stake is slashed. 

![img](https://finematics.com/wp-content/uploads/2021/04/heimdall-bor-1024x470.png)

This is also a good time to introduce 2 core components of the Polygon PoS Chain architecture – Heimdall Chain and Bor Chain.

#### Heimdall & Bor

Heimdall works in conjunction with the Stake Manager contract deployed on the Ethereum mainnet to coordinate validator selection and updating validators.

Since staking is actually done on the Ethereum smart contract, we don’t have to rely on validator honesty and instead inherit Ethereum chain security for this key part. Even if a majority of validators collude and start acting maliciously, the community can come together and redeploy the contracts on Ethereum to fork out, i.e. slash the malicious validators, and the chain can continue to operate as intended. 

Heimdall is also responsible for checkpointing – more on this later in the article. 

Bor is the block producer layer of the PoS Chain architecture that is responsible for aggregating transactions into blocks. 

Bor block producers are a subset of the validators that are periodically shuffled by the Heimdall validators. Block producers are selected to validate blocks only for a set number of blocks, also called “span”. After this time period, the selection process is triggered again. 

Let’s have a closer look at the process of selecting block producers

![img](https://finematics.com/wp-content/uploads/2021/04/example-1024x589.png)

1. Let’s suppose we have 3 validators in the pool, and they are Alice, Bill and Clara.
2. Alice staked 100 MATIC tokens whereas Bill and Clara staked 40 MATIC tokens each.
3. Validators are given slots according to their stake, as Alice has 100 MATIC tokens staked, and there are 10 tokens per slot (maintained by validator’s governance), Alice will get 5 slots in total. Similarly, Bill and Clara get 2 slots in total.
4. All the validators are given these slots [ A, A, A, A, A, B, B, C, C ]
5. Using the historical Ethereum blocks as a seed we shuffle this array.
6. After shuffling the slots using the seed we get this array [ A, B, A, A, C, B, A, A, C]
7. Now depending on Producer count(maintained by validator’s governance), we pop validators from the top, for eg if we want to select 5 producers we get the producer set as [ A, B, A, A, C]
8. Hence the producer set for the next span is defined as [ A: 3, B:1, C:1 ].
9. Using this validator set and Tendermint’s proposer selection algorithm we choose a producer for every sprint on Bor.

This model allows anyone to participate in securing the network with any amount of MATIC tokens. It also doesn’t sacrifice the speed of transaction as not all validators have to validate blocks all the time. 

Let’s go back to the other important function of Heimdall – checkpointing. 

#### Checkpointing 

Checkpoints are important as they provide **f**inality on the Ethereum chain.

Heimdall layer allows for aggregating blocks produced by Bor into a single Merkle root and periodically publishing it to the Ethereum main chain. This published state is also called a checkpoint hence the whole process is known as checkpointing. 

Checkpoint proposers are initially selected via Tendermint’s weighted round-robin algorithm. A further custom check is implemented based on the success of checkpoint submission. This allows Polygon PoS Chain to decouple from Tendermint proposer selection and provides it with abilities like selecting a proposer only when the checkpoint transaction on the Ethereum mainnet succeeds or submitting a checkpoint transaction for previous blocks if the checkpoint transaction failed. 

Submitting a checkpoint on Tendermint is a 2-phase commit process. A proposer, selected via the above-mentioned algorithm, sends a checkpoint with their address in the proposer field and all other proposers validate it.

The next proposer then sends an acknowledgement transaction to prove that the previous checkpoint transaction has succeeded on the Ethereum mainnet. Every Validator set change will be relayed by the validator node on Heimdall which is embedded onto the validator node. This allows Heimdall to remain in sync with the Polygon contract state on the Ethereum mainchain at all times.

The Polygon PoS Chain contract deployed on the main chain is considered to be the ultimate source of truth, and therefore all validation is done via querying the Ethereum main chain contract.

Checkpoints also provide “proof of burn” in the withdrawal of assets. 

Speaking about withdrawals, let’s have a look at another important element of the PoS chain – the two-way Ethereum Bridge.

#### Two-way Ethereum Bridge

Typical two-way bridges rely on a small set of authorities which are often not even staked, nor part of the sidechains’s validators set – basically bridges are often operated, i.e. controlled by several PoA signers. This is a significant security concern.,. 

![img](https://finematics.com/wp-content/uploads/2021/04/bridge-1024x588.png)

Polygon provides 2 separate ways for moving assets between Ethereum and Polygon – Plasma Bridge and the PoS Bridge.

Plasma Bridge provides increased security guarantees due to the Plasma exit mechanism. However, there is a 7-day withdrawal period associated with all exits/withdrawals caused by certain restrictions in the Plasma architecture. 

The PoS Bridge doesn’t have this restriction and it is secured by a robust set of validators that we discussed earlier in this article. The state of these validators is maintained on the Ethereum mainnet and they are secured by all the funds staked in the system – around $500M at the time of writing this article. To the best of our knowledge, the PoS bridge is the only bridge secured by the whole validator set of a bridged chain; bridges are normally secured by a small set of PoA signers, as already mentioned earlier. 

As we can see, Polygon PoS Chain offers a lot of extra security measures based on the Ethereum main chain and it is not just a mere sidechain. Perhaps, a commit chain is a better name for it. 

![img](https://finematics.com/wp-content/uploads/2021/04/polygon-sidechain-commit-chain-1024x544.png)

So what do you think about Polygon Commit Chain? Do you think it’s valuable to differentiate it from a sidechain?

If you enjoyed reading this article you can also check out Finematics on [Youtube](https://www.youtube.com/c/finematics) and [Twitter](https://twitter.com/finematics).