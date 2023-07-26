# A comparison between DA layers



Rollups emerged as a solution to scale layer 1s. As it turns out, rollups also need some help with scaling. In particular, rollups can gain higher throughput capacity with access to more [data availability](https://docs.celestia.org/concepts/data-availability-faq/).

Of course, there is now a broad spectrum of solutions that aim to provide scalable data availability for rollups, like Ethereum, Celestia, EigenLayer, and Avail. Here’s a brief and incomplete look at how they compare across a few metrics.

## DA layers at a glance



![Celestia_Comparison_table6](https://forum.celestia.org/uploads/default/original/1X/fdba73e519a479a45cd0ff0a19d1830d365a4d00.jpeg)





### Block times

Block times measure the length of time between each block.





![Celestia_Comparison_table_separated_block-time](https://forum.celestia.org/uploads/default/original/1X/c1f0042252aa32a16c6cb86c62d5a41e7ed6c78a.jpeg)



#### Celestia, Ethereum & Avail

Of the three projects, both have block times within eight seconds of each other: 12 second blocks for Ethereum, 15 second blocks for Celestia, and 20 second blocks for Avail. The difference between them really isn’t that large or significantly impactful. The real difference between them becomes much more noticeable when looking at how long they take to reach finality.

#### EigenLayer

EigenLayer is the only project that is not a blockchain - it is a set of smart contracts that live on Ethereum. Any data that needs to get forwarded to the rollup contracts, like signatures from the quorum proving data availability, rely on the block time and finality of Ethereum. If the rollup relies on EigenLayer for everything, then it isn’t bound by Ethereum block times.

## Finality and consensus algorithm

Time to finality is the time it takes for a block to get produced and considered final. By final, we mean that a large amount of stake will get burned if the transactions that were considered final are reverted. As it goes, consensus protocols approach finality differently.



![Celestia_Comparison_table_separated_7 (1)](https://forum.celestia.org/uploads/default/original/1X/e7f22f77de2926f0d55f6c448e0fccc3b6bd448f.jpeg)





#### Ethereum

Ethereum uses a combination of protocols to achieve consensus, [GHOST and Casper 1](https://ethereum.org/en/developers/docs/consensus-mechanisms/pos/gasper/#:~:text=Together these components form the,are syncing the canonical chain.). GHOST is Ethereum’s block production engine that relies on [probabilistic finality](https://smsunarto.com/blog/guide-to-finality). To provide faster finality, Ethereum makes use of a finality gadget: [Casper 3](https://arxiv.org/pdf/1710.09437.pdf).

Casper provides the guarantee of economic finality, so that transactions can be finalized much quicker. But, Ethereum uses Casper to only finalize blocks every 64 - 95 slots, which means finality for Ethereum blocks is roughly [12 - 15 minutes](https://notes.ethereum.org/@vbuterin/single_slot_finality). In turn, this causes rollups to wait 12 - 15 minutes before they receive finality on the data and commitments they publish to Ethereum.

#### EigenLayer

Since EigenLayer is a set of smart contracts on Ethereum, it also inherits the same finality time as Ethereum (12 - 15 minutes) for any data that needs to get forwarded to the rollup contracts to prove data availability. Again, if the rollup uses EigenLayer entirely, it can finalize much faster, depending on the use of any consensus mechanism, etc.

#### Celestia

Celestia uses [Tendermint 1](https://docs.tendermint.com/v0.34/introduction/what-is-tendermint.html) for its consensus protocol, which has single slot finality. That is, once a block passes Celestia’s consensus, it is finalized. This means finality is essentially as quick as the block time (15 seconds).

#### Avail

Avail, like Ethereum, uses a combination of protocols to achieve finality, [BABE and GRANDPA 2](https://wiki.polkadot.network/docs/learn-consensus). BABE is the block production mechanism with probabilistic finality and GRANDPA is the finality gadget. While GRANDPA can finalize blocks in a single slot, it may also [finalize multiple blocks in a given round 2](https://polkadot.network/blog/polkadot-consensus-part-2-grandpa/). At best Avail has a finality time of 20 seconds, and at worst multiple blocks.

## Data availability sampling

In most blockchains, nodes need to download all transaction data to verify data availability. The problem this creates is that when the block size gets increased, the amount of data nodes need to verify increases equally.

[Data availability sampling 1](https://celestia.org/glossary/data-availability-sampling/) is a technique that allows light nodes to verify data availability by only downloading a small portion of the block data. This provides security to light nodes so that they can verify invalid blocks (DA and consensus only), and allows a blockchain to scale data availability without equally increasing node requirements.



![Celestia_Comparison_table_separated_4](https://forum.celestia.org/uploads/default/original/1X/b3e1b2d61338ae4407c9ce4a107fc427d24e78fe.jpeg)





#### Celestia & Avail

Both Celestia and Avail will support data availability sampling light nodes at launch. This means they will be able to securely increase their block size with more light nodes, while maintaining low requirements for users to verify the chain.

#### Ethereum

Ethereum with [EIP 4844 4](https://www.eip4844.com/) will not include data availability sampling. EIP 4844 introduces a block size increase and sets up some of the technical foundations to implement danksharding, like blob transactions and kate commitments. To verify data availability of Ethereum with EIP 4844 implemented, users must still run full nodes and download all of the data.

#### EigenLayer

While there’s currently no official plans from EigenLayer around DAS, there have been hints that DAS [may become an option 3](https://twitter.com/sreeramkannan/status/1634235450071355397) for EigenLayer light clients in the future. There are two options:

- DAS from sequencer: DAS from the sequencer would increase the sequencers overhead because only the leader would be able to serve sample requests for all light clients for the current block - unless some consensus mechanism is implemented where non-leaders can provide sample requests.
- DAS from EigenLayer: DAS from EigenLayer would require a robust p2p network and additional mechanisms, like block reconstruction, to have full security.

While DAS may not be implemented upon launch, it looks like it could make it into EigenLayer later on. Until then, verifying DA for EigenLayer chains would require a full node.

## Light node security

Blockchains rely on users running nodes to defend against malicious attacks.

Traditional light clients have weaker security assumptions compared to full nodes because they only verify block headers. Light clients can’t detect if an invalid block is produced by a dishonest majority of block producers. Light nodes with data availability sampling get an upgrade in security because they can verify if invalid blocks are produced - if the DA layer only does consensus and data availability.



![Celestia_Comparison_table_separated_5](https://forum.celestia.org/uploads/default/original/1X/d96b4d90ca9bed5c284e0bd1dcce629bf6f81308.jpeg)





#### Celestia & Avail

Since Celestia and Avail will both have data availability sampling, their light nodes will have trust-minimized security.

#### Ethereum and EigenLayer

Ethereum with EIP 4844 will not have data availability sampling, so its light clients will not have trust-minimized security. Since Ethereum also has its smart contract environment, light clients would also need to verify execution (via fraud or validity proofs) to not rely on an honest majority assumption.

For EigenLayer, unless there is DAS, light clients, if they are supported, will rely on an honest majority of restaked nodes.

## Encoding proof scheme

[Erasure coding](https://github.com/ethereum/research/wiki/A-note-on-data-availability-and-erasure-coding) is an important mechanic that makes data availability sampling possible. Erasure coding extends a block by producing additional copies of the data. The additional data creates redundancy, giving stronger security guarantees for the sampling process. However, nodes may try to incorrectly encode data to disrupt the network. To defend against such an attack, nodes need a way to verify the correctness of the encoding - this is where the proofs come in.



![Celestia_Comparison_table_separated_6](https://forum.celestia.org/uploads/default/original/1X/9236fcd9cf960d3ce463958cde5cabb4b83db331.jpeg)





#### Ethereum, EigenLayer & Avail

All three projects use a type of validity proof scheme to ensure blocks are encoded correctly. The idea works similarly to [validity proofs 1](https://celestia.org/glossary/validity-proof/) used by zk rollups. Each time a block is produced, validators must produce [commitments to the data 1](https://dankradfeist.de/ethereum/2020/06/16/kate-polynomial-commitments.html#:~:text=As a polynomial commitment scheme,equal to a claimed value.) which nodes verify using a kzg proof - proving the block was encoded correctly.

Although, producing commitments for kzg proofs requires more computational overhead for block producers. Generating commitments doesn’t carry much overhead when blocks are small. As the blocks get larger, commitments for kzg proofs carry a much higher burden to generate. Node types that are responsible for generating kate commitments will likely require much higher hardware requirements.

#### Celestia

Celestia is unique because it uses a fraud proof scheme to detect incorrectly encoded blocks. The idea works similarly to [fraud proofs 1](https://celestia.org/glossary/state-transition-fraud-proof/) used by optimistic rollups. Celestia nodes don’t need to check if a block is correctly encoded. They assume it was correct by default. The benefit is that block producers don’t need to do expensive work to produce commitments for the erasure coding.

But, light nodes do have to wait for a short period before they can assume a block is correctly encoded, finalizing it in their view. The waiting period is for light nodes to receive a fraud proof from a full node if a block was incorrectly encoded. If a node was eclipsed, making it unable to receive a fraud proof, it would consider an invalid block as valid. However, not getting eclipsed is an assumption for nodes to actually verify a blockchain, regardless of fraud proofs.

The main difference between a fraud proof and validity proof encoding scheme is the tradeoff between node overhead for generating commitments and latency for light nodes. In the future, if the trade-off for validity proofs became more appealing than fraud proofs, Celestia could switch their encoding proof scheme.