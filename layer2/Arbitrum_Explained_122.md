原文链接：https://tracer.finance/radar/arbitrum-in-under-10/

# Arbitrum Explained In 10 Minutes

A comprehensive and digestible technical summary of the Arbitrum network

![arbitrum-in-10.png](https://storage.googleapis.com/mycelium-bucket/arbitrum_in_10_227e2b19cf/arbitrum_in_10_227e2b19cf.png)

Arbitrum is a layer 2 scaling solution for Ethereum. Tracer will be deploying its Perpetual Swaps on [Arbitrum](https://arbitrum.io/) in the coming month. The following read will give you a thorough understanding of the mechanisms that power Arbitrum to give you more comfort and understanding when trading on Tracer in an L2 environment.

**UPDATE:** Tracer [Perpetual Pools](https://pools.tracer.finance/) is now live on Arbitrum One

## Architecture Summary

- As Arbitrum (L2) exists as a scalability solution for Ethereum (L1), the Arbitrum architecture naturally exists in part on L1 and in part on L2.
- The component of Arbitrum that exists on L1 is the EthBridge, which is a set of Ethereum contracts.
- The EthBridge is responsible for refereeing the Arbitrum Rollup protocol, as well as maintaining the inbox and outbox of the chain.
- The inbox and outbox of a chain is what allows users, L1 contracts, and full nodes to send their transactions to the chain as well as observing the outcome of those transactions.
- The Arbitrum Virtual Machine is the gateway between L1 and L2, and the function provided by the EthBridge.
- The AVM is what is capable of reading inputs, and executing computations on these inputs to produce outputs.
- ArbOS is run on top of the Arbitrum Virtual Machine, and is responsible for ensuring the execution of smart contracts on the Arbitrum chain.
- ArbOS exists completely on L2, and runs EVM contracts just like how they would be run on Ethereum.

![Layer 1 to Layer 2.](https://storage.googleapis.com/mycelium-bucket/diagram_1_9294177094/diagram_1_9294177094.png)

> A high level view of the Arbitrum architecture.

## The Rollup protocol

- The order of messages in the chain’s inbox determines the result of the transactions.
  - Subsequently, anyone who is watching the inbox is able to know the results of the transactions, simply by self-executing them.
- The Rollup protocol is responsible for confirming the results of transactions that have effectively already occurred.
- Users that participate in the protocol are called validators; if a validator stakes Eth into a deposit contract, they become a staker and can stake on blocks in the Rollup chain.
  - Both the roles of validator and staker are permissionless.
- In terms of security, only a single honest validator is required to force the correct execution of the chain.
  - This gives the rollup chain the same degree of trustlessness as the Ethereum main chain.
  - Arbitrum assumes the existence of at least one honest validator.
- The Rollup protocol acts upon the Rollup chain, which is a chain of rollup blocks existing separately to the Ethereum chain.
- It is the role of the validators to propose new blocks to be added to the chain.
- Every block that is proposed will eventually be confirmed or rejected by the protocol.
- Each block is made up of a number of fields, and apart from the block number field, the data given in each of these fields are assertions made by the block’s proposer which may or may not be correct.
  - If any of the asserted fields are incorrect, the protocol will eventually reject the block.
- Once a block is proposed it receives a deadline for confirmation.
- If a validator disagrees with the block, they should propose their own correct block which earns the honest validator some reward when they eventually end up in a fraud proof with the incorrect block.

## Staking

- For a staker to add a rollup block to the chain, they must place their stake on the block they are adding.
- Staking is permissionless, anyone can stake on any block where staking is possible.
- Once you are staked on a block you cannot withdraw your stake until that block has been confirmed.
- When you stake a block, you are confirming that a block is correct, AND every block in the chain between the most recent confirmed block and the block that you are staking is correct.
- If a block that you stake on is incorrect, or a block in the chain between the most recent confirmed block and the block that you are staking on is incorrect, you will forfeit your stake.
- If you are not staked on a block, you can stake on the most recent confirmed block.
- If you are staked on a rollup block, you can extend your stake up to any successor of the block you are staked on.
- The amount needed to stake is dynamic.
  - There is the base stake amount that is specified as a parameter in the Arbitrum chain, which will be used most of the time.
  - As a security measure to prevent an attacker slowing down the network despite losing their stake, the stake amount is multiplied by a factor that increases exponentially with respect to time, since the deadline for the first unresolved node passed.
  - This is to increase the cost of such an attack during the length of the attack.
  - This increase in stake is temporary and only occurs when the chain is making slow progress to confirm blocks.

## Challenge protocol

- When two stakers are staked on different blocks, where one block is not a successor of the other, there will be a particular block that they disagree on and a challenge will occur.
- Most of the challenge occurs on the Arbitrum chain and is refereed by a L1 contract.
- The challenge consists of an interactive, multi-round dissection game that occurs on L2, and a one-step proof that is executed on L1.
- The staker who proposed the disputed block is defending their assertion against a disagreeing staker.
- The defending staker is essentially claiming that by starting at the preceding block, after some N instructions are executed by the virtual machine, the preceding block state will have been advanced to the state given in their proposed block.
- The defending staker (Alice) will make the first move in the dissection game by dissecting the N instruction into K parts of size N/K.
  - Note that the subsections are not equal in size with respect to the number of steps, but rather equal in size with respect to the amount of Arbgas consumed.
  - Also note that each segment will naturally have a start-point and an end-point (this is trivial, but makes the next dot-point easier to understand).
- The opposing staker (Bob) will also dissect the set of instructions into K parts of size N/K, except one of Bob’s K segments will have a different end-point to Alice’s corresponding segment’s end-point.
  - This is essentially Bob identifying the segment with which he disagrees.
- Bob will then perform the same action as Alice’s initial step and dissect one of the segments into K subsegments of size N/K, and send this segment with identified subsegments back to Alice.
- Alice then performs the same action as Bob’s initial step and identifies a subsegment where she disagrees with its end-point.
- This dissection process continues until Alice and Bob have identified a single instruction on which they disagree.
- This instruction is sent to a L1 contract which executes it and decides the winner of the dispute.
- The loser of the dispute will have their stake confiscated, part of which will be burnt - to avoid an attacker hedging their bets - and the remainder of the stake will be given to the honest staker as a reward.
- During the whole dissection process, the L1 contract that is refereeing the game does not know any information about the instructions themselves, it is only checking that each player is following the rules of the dissection game.
- During the dispute, all other validators are able to determine for themselves the result of the dispute before the dispute is finalised; meaning that essentially a soft fork occurs and the validators can continue to submit rollup blocks on the correct chain.
- The challenge period has an imposed time limit of roughly one week per staker.
- Each staker must make all of their moves within their week allocation or they will lose the dispute.
  - Think of a chess clock.

![Multi-round](https://storage.googleapis.com/mycelium-bucket/diagram_2_5b56f13345/diagram_2_5b56f13345.png)

> A demonstration of the multi-round, interactive disection game played by two stakers during the challenge protocol. In reality, the disputed assertion will have many more instructions (rows with squiggles in it) and thus more rounds will be played but the principle is the same.

## Validators

- A validator is a node on the Arbitrum chain that has chosen to watch the activity of the Rollup protocol and advance the state of the chain.
  - Not all nodes act as validators.
- Offchain Labs expect validators to follow either an active, defensive, or watchtower strategy; although, this is not enforced by the protocol.
  - An ‘active validator’ is continuously working to advance the chain by proposing new blocks. Only one honest active validator is required per chain; increasing the number of active validators does not increase the efficiency of the chain.
  - A ‘defensive validator’ watches the Rollup protocol and acts only when they witness dishonest behaviour, at which point they will either propose a correct block - or if a correct block has already been proposed - they will stake on that block.
  - A ‘watch tower validator’ watches the Rollup protocol just like a defensive validator, but if they witness dishonest behaviour they don’t propose or stake on a correct block themselves, rather they simply alert other validators to do so.
- Offchain labs will run an active validator on their flagship Arbitrum chain.
- For most of the time, defensive and watchtower validators will not need to do anything, hence an attacker is never aware of how many defensive validators there are.
- Although anyone can be a validator, it is expected that the main parties who will choose to become one will be parties who have significant assets invested in the chain, or parties who are hired to be validators by those with significant investments.

## Full Nodes

- A full node on Arbitrum has the same role as a full node on Ethereum; they track the state of the chain and allow others to interact with the chain
- Due to a built-in AVM emulator, a full node is able to treat the chain as a matter of computing outputs from inputs, without any knowledge of the actual Rollup protocol.
- A full node can serve as an aggregator on the chain, further increasing cost efficiency for the users.
- Arbitrum includes the facility to collect fees from users to compensate the full node for the costs incurred while acting as an aggregator.
- Full nodes can also compress transactions to further decrease the L1 calldata cost.
  - The full node submits the compressed transaction to the chain’s inbox, where arbOS receives it and uncompresses the transaction.
- A full node will typically incorporate both compression and aggregation, i.e. it will submit a batch of compressed transactions to the chain’s inbox.

## Sequencer Mode

- When an Arbitrum chain is launched, there is the option to launch with a sequencer.
- A sequencer is a full node that has additional privileges for the ordering of transactions in the chain’s inbox.
- These privileges allow the sequencer to instantly guarantee the result of a transaction.
- When an Arbitrum chain is launched with a sequencer, the chain inbox is effectively split in two:
  - One inbox will operate as it normally would if there was no sequencer, i.e. nodes can send messages to the inbox which will be tagged with a block number and timestamp.
  - The second inbox will be controlled by the sequencer, and only the sequencer can send messages to this inbox
- When the sequencer sends messages to their inbox, they can specify the block number and timestamp with which to tag the message.
  - This includes block numbers and timestamps from the past, up to a specified delta_blocks, blocks in the past and delta_seconds, seconds in the past.
  - These delta values will typically correspond to roughly ten minutes of wall-clock time.
- Now when arbOS checks the inbox, it will receive the message with the lowest block number, which may be at the head of either the regular inbox or the sequencer inbox.
- The limit on how far back the sequencer can backdate blocks is tied to the number of confirmation blocks needed to achieve finality on Ethereum.
  - If x amount of blocks are needed to achieve finality on Ethereum, then the sequencer will backdate by x blocks so that it knows exactly which transactions will precede its current transaction.
- When sequencer mode is activated on an Arbitrum chain, transactions that are submitted to the sequencer will achieve finality x blocks faster than it would if there was no sequencer, but transactions that are submitted to the regular inbox will achieve finality x blocks slower than if there was no sequencer.
  - This is regarded as a positive trade-off due to the large practical difference when comparing instant and five minute finality with five minute and ten minute finality.
- However, a malicious sequencer is able to take advantage of these privileges to a certain extent.
  - A malicious sequencer is able to censor user’s transactions by simply not including them to the sequencer inbox, forcing the user to send the same transactions to the regular inbox after realising that they have been censored.
  - The sequencer would also have the power to frontrun user’s transactions.
- The initial Arbitrum chain will launch with a sequencer that is run by Offchain Labs.
- There has previously been some successful research into developing a decentralised fair sequencer algorithm by a team at Cornell Tech, and with some more work this will form the long term solution for Arbitrum.

![with and without a sequencer](https://storage.googleapis.com/mycelium-bucket/diagram_3_764350ae06/diagram_3_764350ae06.png)

> The difference in the chain’s inbox when the sequencer mode is enabled / disabled.

## ArbGas / Fees

- ArbGas operates similarly to Ethereum gas in that it is used to measure the cost of computation on the Arbitrum chain.
- However, there is no hard ArbGas limit imposed on an Arbitrum chain, and ArbGas can be consumed much faster than Ethereum gas.
- A key role of ArbGas is to provide a predictable measure of how long it would take to validate the result of a computation.
- Every rollup block includes a claim about the total amount of ArbGas consumed in the chain, meaning that the difference between the current block’s claim and the previous block’s claim should be a valid indicator of how much ArbGas is consumed in the current block.
- This way, a validator who is checking a block’s validity can set their gas limit to this amount, and if they run out of ArbGas before they reach the end of the block, they can be certain that they have identified an invalid block and successfully challenge it.
- Users are charged fees when they submit their transactions to the chain.
- If the user sends their transaction to an aggregator, a portion of the fees is automatically paid to that aggregator for costs they incurred.
- The remainder of the fees is sent to a network fee pool which is used to pay for services that ensure that the chain operates securely.
- Fees are charged for L2 transactions, L1 calldata, computation, and storage.
- Fees are paid in Eth.

## Summary

- Arbitrum is a L2 scalability solution developed by Offchain Labs: an optimistic rollup that uses a multi-round interactive challenge protocol.
- The flagship Arbitrum chain was released to developers on the 28th of May, and will be open to users once a quorum of projects has been reached.
- From the User’s point of view, interacting with the Arbitrum chain will be an identical experience to interacting with Ethereum.

Tracer will be deploying its Perpetual Swaps on Arbitrum Mainnet in the coming month, be sure not to miss it by following Tracer on [Twitter](https://twitter.com/TracerDAO) and joining the discussion on [Discord](https://discord.gg/kvJEwfvyrW).

For an even deeper dive on Arbitrum, see the [docs here](https://developer.offchainlabs.com/docs/inside_arbitrum).

*A technical analysis authored by [Nick Crow](https://twitter.com/crypto_crowy) of Lion’s Mane.*