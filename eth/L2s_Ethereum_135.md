原文链接：https://mirror.xyz/dcbuilder.eth/QX_ELJBQBm1Iq45ktPsz8pWLZN1C52DmEtH09boZuo0



![img](https://images.mirror-media.xyz/nft/57H-inFA9mITvSw2kfbtM.png)

# The ultimate guide to L2s on Ethereum

# Who am I?

I'm[ DCBuilder](https://twitter.com/DCbuild3r), a blockchain researcher at[ Moralis](https://moralis.io/), where I write about DeFi, NFTs, DAOs, L2s, MEV and other various topics pertaining to web3/crypto. I have been a front-end developer with an AI/ML background and have recently started the transition to full-stack blockchain development through an [EthernautDAO](https://twitter.com/EthernautDAO) mentorship with [Austin Griffith](https://twitter.com/austingriffith). I'm a fellow member of [Waifus Anonymous](https://waifusanonymous.com/) being an anime/manga enjoyoor and have a Kaneki (Tokyo Ghoul) pfp on Twitter.

# Introduction

**I**n this article, I’ll talk about L2s on Ethereum, the state of the current scaling ecosystem, and why I believe running L2s on top of Ethereum is the most economically and technically sustainable scaling solution long term.

Disclaimer: This article aggregates my thoughts, other people's resources, and miscellaneous technical information. It is not meant to be a concise summary of the ecosystem, but rather a more detailed and verbose overview of the current state and future feasibility of Ethereum L2 scalability.

To dive deeper, we need to get a few definitions and concepts out of the way.

# TL;DR

To summarize this massive guide I will keep a running list of important points about the technology and its future outlooks:

- Users won't ever interact with Ethereum mainnet as this will only serve as the data availability layer for L2s
- Web3 applications' UX will have all complexities abstracted away
- Modular blockchains are the most economically and technically viable long-term scaling design option
- Currently, Ethereum is the dominant blockchain in the modular domain, as it has very strong security which will greatly increase with the switch to PoS
- Validity proofs are better than fraud proofs long-term
- The Volition L2 infrastructure (Validium + zk-rollup) is emerging as the golden standard for zkVM-based L2s
- Ethereum is also scaling as an L1 with data sharding, verkle trees, statelessness, and other changes
- L2s are on-pace to build a shared cross-L2 communication framework which will enable them to have shared liquidity and smart contract composability
- L2s use ETH for gas but are incentivized to create DAO governance tokens to decentralize operations over time
- The application design space is growing now that builders have more bandwidth and less execution layer hurdles to work with 

## What is an L2?

An L2 (layer-two) is a type of scaling solution that has a separate execution layer (where code runs, i.e. EVM) that inherits the security guarantees and decentralization of the network it’s running on top of i.e., the L1, Ethereum in our case. This means that if the L2 were to go dark due to a bug, infrastructure exploits, or outage, the funds are safely secured by the L1 within a smart contract bridge.

The funds can be retrieved according to the latest state snapshot submitted onto the mainnet. The bridge of a true L2 is fully permissionless and decentralized so there's always a guarantee the funds are accessible once deposited by users. Several scaling approaches use distinct cryptographic proof mechanisms with different security and scalability tradeoffs which we will discuss further in this article.

## What are the main types of L2s?

There are two parameters that are used to categorize L2 scaling solutions. One is the type of cryptographic proof used, and the other is whether the data availability (DA) is off-chain or on-chain.

The two main types of proofs are:

- Validity Proofs - mathematical proofs that utilize zero-knowledge (ZK) cryptography in order to ensure the validity of a transaction
- Fraud Proofs - these proofs introduce a so-called Dispute Time Delay (DTD), once a proof is submitted in the L2, the validator has time in order to mark the proof as invalid; an invalid proof could have incorrect state transitions and thus result in penalizing the validator(s) involved; a rollback of the state to the latest valid snapshot will follow

What does it mean to have data on-chain or off-chain?

- on-chain: the state data - along with all of the execution calldata of all transactions (smart contract function calls, native token transfers, signatures) are put together into the cryptographic proof of a bundle/roll-up of transactions which makes all of the data accessible and verifiable on-chain.
- off-chain: the execution calldata and the state is handled and held off-chain by the L2. This makes it a less secure and decentralized option. However, it is much easier to bundle more transactions into the rollup, thus scaling much faster than on-chain calldata proofs.

![Scaling solution categorization](https://dcbuilder.mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2Fi0-CK5PlIlbVf-wSuNSGw.png&w=1920&q=90)

Scaling solution categorization

These are the main relevant properties that help distinguish different types of L2s. But, why L2s when we can scale layer 1? Why not use a cheaper chain like Solana, Fantom, Avalanche, or Binance smart chain? We'll answer that in the next section.

## Modular vs. monolithic infrastructures

In blockchain, there is a famous trilemma- that tries to optimize for 3 main factors: security, decentralization, and scalability. All three are very hard to achieve within the same system. Often two out of three are attained with a compromise on the third. In the case of Ethereum, we optimize for security and decentralization first, while working on scalability as a lower priority item. To be clear, scalability is not the main priority of core Ethereum developers.

Throughout 2021 we have seen Ethereum mainnet become increasingly congested through the growth of both the DeFi and NFTs. This has given the network an unprecedented demand for its blockspace. We can't simply change the number of transactions we can fit in a block by changing its gas limit because it would make nodes harder to operate as the hardware requirements would soar (decreasing decentralization) and if the blocks become too big it would destabilize consensus (decreasing security).

### Monolithic blockchains

Other chains have taken a different approach where they prioritize scalability first, security second, and decentralization last. Let's consider the Solana mainnet beta as an example. The network has one main client development team (Solana Labs), about 1000 validators (source: [SolanaBeach](https://solanabeach.io/)), and a different consensus mechanism called [Proof of History](https://medium.com/solana-labs/proof-of-history-a-clock-for-blockchain-cf47a61a9274) (PoH).

Solana has taken a distinctive path for scaling, which is of a monolithic blockchain. They plan on indefinitely scaling the validating nodes operating the network as increasing computing power becomes available. This approach makes the network less decentralized as the node validators are forced to keep buying better-performing hardware to constantly keep up. There are concerns about the rate of growth of computing power slowing down as we reach the limits we can fit inside a chip due to quantum tunneling. At some point, we'd require a new computing paradigm to come along or a large breakthrough in technology to make this approach sustainable. Thus, my conclusion is there are better long-term alternatives to blockchain scaling.

### Modular blockchains

The modular approach essentially consists of a primary network that prioritizes security and decentralization so that it can act as a data availability layer for L2s. If the primary network were to go down, all L2s would go down. However, if an L2 were to go down, all of the funds are safe and secured by the L1. This is the approach that Ethereum is taking as L2s will be the layer that will provide the most scalability. There are also efforts to scale the L1 through[ data sharding](https://vitalik.ca/general/2021/04/07/sharding.html),[ state expiry, and verkle trees](https://notes.ethereum.org/@vbuterin/verkle_and_state_expiry_proposal) along with various other improvements. However, these changes take considerably more time to implement as security and decentralization take precedence.

A key aspect of modular blockchains is that they can scale indefinitely without having to upgrade hardware at a fast pace. They can do this because they are technically and economically sustainable in contrast to monolithic architecture. The more elaborate argumentation for why a modular architecture is much more sustainable than a monolithic one can be found in[ this article](https://www.reddit.com/r/ethereum/comments/pkqqjc/why_rollups_data_shards_are_the_only_sustainable/) by[ @epolynya](https://twitter.com/epolynya) - Twitter ([u/Liberosist](https://www.reddit.com/user/Liberosist/posts/) - Reddit).

In essence, the sustainability of a blockchain breaks down into two requirements:

#### Technical sustainability

- Nodes need to be in sync
- Sync from the genesis of the blockchain in a reasonable amount of time
- Avoid state bloat getting out of hand

#### Economic sustainability

- The L1 ideally generates more revenue than the cost of operating the network (centralized L1s do not)
- Throughput can't be artificially increased because eventually, all centralized L1s will have to increase their fees

Rollups and data shards (rads) emerge as the only solution meeting these requirements, that's why a modular architecture is the only long-term feasible scaling approach.

For a more complete explanation of why rads are the only solution for long-term scaling read[ @epolynya's articles](https://polynya.medium.com/) in the 'Further reading' section.

## The current state of L2s and how users can benefit

We are scaling now, many solutions that were in the works for the past few years are already live, at least in a limited capacity, and many more are releasing improved versions and alpha releases of their L2s on mainnet in the near future. These scaling solutions fall into different categories according to the properties of their scaling approach as described in the 'Types of L2s' section.

### An incomplete list of L2s

### Optimistic rollups

- **Arbitrum**

[Arbitrum](https://arbitrum.io/) is an L2 built by the[ Offchain Labs](https://offchainlabs.com/) team. The network itself is called Arbitrum One and it utilizes optimistic rollups in order to scale Ethereum. Arbitrum One utilizes fraud proofs and has on-chain call data availability, meaning that all of the data of each transaction is fully sequenced, bundled, and submitted to mainnet. Since it utilizes fraud proofs, there is a dispute time delay (DTD) of about 7 days. Once the DTD passes, the state changes on the network can be considered valid and users can withdraw their available balances through the native bridge. There are other centralized bridges that we'll discuss later that allow you to bypass this fraud proof period by having cross-L2 liquidity pools.

Arbitrum One is currently the L2 Network that has[ the highest TVL](https://l2beat.com/projects/arbitrum/). A great website that allows us to inspect these metrics is[ L2Beat](https://l2beat.com/).

There are many protocols and applications that already support Arbitrum, including supporting infrastructure that makes the switch to using the Arbitrum layer 2 almost seamless. The only current issue with using L2s is that it needs to accrue more liquidity and innovative solutions like cross-L2 AMM structures like[ dAMM](https://medium.com/starkware/damm-decentralized-amm-59b329fb4cc3) (invented by Starkware and Loopring) and liquidity protocols like Connext and Hop need to get enough liquidity and become trustless enough to the point that all of these scaling solutions can share the same infrastructure so as to not cause ecosystem fragmentation.

For an overview of the Arbitrum ecosystem of applications, go to the[ Arbitrum Portal](https://portal.arbitrum.one/) page.

**Key tools:**

- Block explorer -[ Arbiscan](https://arbiscan.io/)
- Bridge -[ native Arbitrum bridge](https://bridge.arbitrum.io/) (withdraws incur DTD of approx. 7 days)
- Network RPC config -[ Chainlist](https://chainlist.org/) (search for Arbitrum One and add to MetaMask) / check whether your mobile wallet supports Arbitrum before bridging funds over (this could result in a permanent loss of funds) - personal recommendation:[ Rainbow wallet](https://rainbow.me/) (DISCLAIMER: doesn't[ yet](https://rainbow.me/learn/a-beginners-guide-to-layer-2-networks) support Arbitrum)
- AMM aggregator -[ 1inch](https://app.1inch.io/)

If using the Arbitrum bridge is confusing, check out the[ Arbitrum bridge tutorial](https://arbitrum.io/bridge-tutorial/). For bridging from other networks besides Ethereum checkout the L2 bridges section below (note that these bridges all have varying degrees of centralization).

**Arbitrum Nitro**

Arbitrum Nitro is an upgrade to the Arbitrum One L2 which replaces the custom-designed AVM (Arbitrum VM) with a Web Assembly (WASM) target that will take care of fraud proofs. This will also make the entire system more compatible with EVM. Another change is that EVM-emulator is being replaced by Geth which is the most run Ethereum client today. The ArbOS component is also modified to provide cross-chain communication, and a new and improved batching and compression system to minimize L1 costs.

This upgrade will be rolled out seamlessly so users won't have to do anything, the upgrade is estimated to increase execution speeds by 20-50x and considerably reduce transaction costs. For more information read [Offchain Labs' Medium post](https://medium.com/offchainlabs/arbitrum-nitro-sneak-preview-44550d9054f5).

**Future of Arbitrum**

Arbitrum is not only an optimistic rollup as the Offchain Labs team has announced that they will release other scalability solutions based on zk-proofs whilst also improving their Arbitrum One optimistic rollup L2. This is a good example of the trend of zk-ification where many projects are pivoting towards a zk future as the execution environment is much more flexible and arguably more scalable once the technical implementation of the zk-L2 is better researched and allows for generalized EVM computations.

- **Optimism**

[Optimism](https://www.optimism.io/) is a Public Benefit Corporation (PBC) that built Optimistic Ethereum (OE) which is an optimistic rollup L2 on Ethereum. In order to describe OE, I'll explain the similarities with Arbitrum and then talk about some key differences in their infrastructure. The detailed version of the comparison can be found in[ this thread](https://threadreaderapp.com/thread/1395812308451004419.html) by[ Kris Kaczor](https://twitter.com/krzKaczor).

**Similarities between Optimism and Arbitrum:**

- are rollups and store all txs on L1
- are optimistic since they use fraud proofs
- use sequencers for instant 'finality'
- have generic cross-chain messaging allowing the creation of advanced token bridges
- support EVM-related tooling, but need specialized extensions

**Differences:**

- different fraud proof verification mechanism
- Optimism OVM 2.0 is [EVM equivalent](https://medium.com/ethereum-optimism/introducing-evm-equivalence-5c2021deb306) vs. Arbitrum One (post-Nitro) EVM-compatible
- Optimism uses single round fraud proofs vs. Arbitrum multi-round FPs
- Optimism is still gated (private whitelist mainnet for previous applicants) vs. Arbitrum public mainnet (permissionless)

**Key tools:**

- Block explorer -[ Optimistic Etherscan](https://optimistic.etherscan.io/)
- Native bridge -[ Optimism Gateway](https://gateway.optimism.io/welcome)
- [User guide](https://community.optimism.io/docs/users/getting-started.html)
- Live applications[ portal](https://www.optimism.io/apps/all)
- Network RPC config -[ Chainlist](https://chainlist.org/) (search for Optimistic Ethereum)

**OVM 2.0**

OVM stands for Optimistic Virtual Machine and is the virtual machine that executes all transactions in the OE L2. The OVM is getting an upgrade on Nov 11th (has already been deployed to Kovan testnet).

Optimism is on a road to EVM equivalence and in order to achieve it they unveiled OVM 2.0 which will enable OE to be an equivalent compilation target to the EVM in all aspects. Developer tools like Dapptools (smart contract libraries and command-line tools - formal verification, symbolic execution, project management, etc), Hardhat, Solidity, Vyper, and all other tooling will work natively on OVM 2.0 without the developers of these tools having to worry about supporting fragmented codebases. This is the powerful “network effect” that everyone in the Ethereum community refers to. It is important to note that any competitor to the EVM has to rebuild all of these developer tools from the ground up.

You can read more about Optimism's journey to EVM equivalence on their[ blogpost](https://medium.com/ethereum-optimism/introducing-evm-equivalence-5c2021deb306).

**Retroactive public goods funding**

In my opinion, one of the most significant announcements that came from the Optimism team is they[ pledged to give away all their profits](https://medium.com/ethereum-optimism/retropgf-experiment-1-1-million-dollars-for-public-goods-f7e455cbdca) totaling over $1M USD to public goods and retroactively utilize quadratic voting. The Optimism team has also pledged to continue donating 100% of profits from the L2 sequencer to public goods moving[ forward](https://medium.com/ethereum-optimism/retroactive-public-goods-funding-33c9b7d00f0c). The profit is the difference between the generated transaction fee revenue and the cost that the L2 has to pay for submitting fraud proofs to the Ethereum mainnet. This sets a precedence for other L2s to follow in providing an altruistic outlook for the Ethereum community. 

**Future of OE**

Optimistic Ethereum has ambitious plans for the future, the roadmap is available on the[ Optimism specification](https://github.com/ethereum-optimism/optimistic-specs).

Taken from their[ spec](https://github.com/ethereum-optimism/optimistic-specs/blob/main/roadmap.md):

![img](https://dcbuilder.mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FwVqRsxloWkTOI1yo_k11b.png&w=3840&q=90)

The roadmap & abstractions are designed to enable independent development of each component. The 4 major components are:

- the optimistic mainnet deployment
- the fraud proof infrastructure
- stateless clients
- sharding

Each component will produce incremental and independent releases, each driving closer to unification and Optimistic Ethereum nirvana.

- **Boba Network**

[Boba](https://boba.network/) is an L2 Ethereum scaling & augmenting solution built by the[ Enya](https://enya.ai/) team as core contributors to the OMG Foundation. Boba is an Ethereum Layer 2 Optimistic Rollup scaling solution that reduces gas fees, improves transaction throughput, and extends the capabilities of smart contracts. Boba offers fast exits backed by community-driven liquidity pools (similar to other solutions like Connext or Hop protocol), shrinking the Optimistic Rollup exit period from seven days to only a few minutes, while giving LPs incentivized yield farming opportunities.

Boba started off as a fork of Optimism and they are one of the key contributors to the OVM (optimistic virtual machine). An interesting fact is that Boba deployed the OVM 2.0 sooner than Optimism which has the launch set for Nov 11th on Optimistic Ethereum. Even though Boba started off as a fork they do have a modular structure that enables them to swap the mechanism for submitting proofs to the mainnet, which allows for some upgradeability or zk-ification in the future. The team plans to completely rewrite the codebase for their upcoming v3 which is set to be rolled out on mainnet in the coming months. Boba's design also allows for smart contract extensibility and enables developers to build dapps that invoke code executed on web-scale infrastructure such as AWS Lambda, making it possible to use algorithms that are either too expensive or impossible to execute on-chain.

[$BOBA airdrop](https://boba.network/airdrop/) - governance token

**Resources:**

- [Block explorer](https://blockexplorer.boba.network/)
- [Boba Network Gateway](https://gateway.boba.network/) (bridge)
- [Developer portal](https://boba.network/developers/)
- **Metis**

[Metis](https://www.metis.io/) is an L2 scaling solution on Ethereum that utilizes a parallelized or sharded optimistic rollup architecture. In the Metis VMor MVM, there are so-called decentralized autonomous companies, DACs, that have separate computational and storage layers that can be custom tailored for the needs of the operators (ie. a DAO, dapp, protocol, etc). These DACs are the parallel execution layers of the optimistic rollup. DACs are fully interoperable and liquidity can flow in between them seamlessly thanks to their cross-layer communication protocol. Metis designed their scaling solution in a way where it could scale Ethereum horizontally without incurring significant spending in infrastructure according to their[ technical whitepaper](https://drive.google.com/file/d/1LS7CmKFt-FkfVXxSNu06hNgoZXxMzTC-/view).

I met up with the Metis DAO team by chance during Liscon and the way I understood the infrastructure is that it's meant to be a network that has different execution layers that are purpose-built for different groups that plan on scaling their operations (DAOs, dapps, etc) whilst preserving the security of Ethereum via fraud proof submission to mainnet. There could be some public DACs where common utilities like AMM liquidity for doing swaps that other DAC users could tap into when needed thanks to the cross-DAC native interoperability. It's a novel design and an interesting experiment.

### Zero-knowledge rollups

Zero-knowledge technology has been heralded as one of the greatest recent advancements in cryptography as it allows to give mathematical proofs to statements and conditions without revealing any of the information required to do so. Many smart people I've talked about ZKPs say that it's essentially mathematical magic as the proofs themselves are very complex and the mathematics can be quite hard to wrap your head around.

From Vitalik's post on[ Understanding rollups](https://vitalik.ca/general/2021/01/05/rollup.html): ZK rollups use validity proofs; every batch or roll-up includes a cryptographic proof called a[ ZK-(SNARK / STARK)](https://consensys.net/blog/blockchain-explained/zero-knowledge-proofs-starks-vs-snarks/) that is proved by a protocol like PLONK. After proving the post-state root is correct, the rollup publishes the proof to Ethereum mainnet. I'll leave more resources for learning about zero-knowledge cryptography in the 'Further reading' section.

One of the currently most sought-after goals in the ZK space is to create a zk-layer 2 solution that is fully EVM-compatible/equivalent. This is a very hard problem that has been one of the biggest hurdles that many teams are working hard to overcome. Many of the teams have announced solutions that do exactly this coming out in the near future.

Most currently available solutions in production only act as payment layer with limited functionality (Polygon Hermez, Aztec, ...) or have added functionality with their custom execution engine (VM) that's non-EVM compatible (StarkEx + Cairo, Loopring, zkSync 1.x + Zinc, etc).

## List of ZK-rollup L2 solutions

- **zkSync**

[ZkSync](https://zksync.io/) is a zero-knowledge rollup L2 network built by[ Matter Labs](https://matter-labs.io/). The currently available iteration of zkSync is not EVM-compatible and supports payment functionality, limited smart contracts in a low-level language called Zinc, NFT minting, and a few other functions. However, there is already a fully EVM-compatible version of zkSync live on the Rinkeby testnet and is expected to launch on mainnet in the coming months.

zkSync 1.x has been live since March of this year, providing services to platforms like Gitcoin, where users could pay for public good grants on the zkRollup for a small fraction of the cost of using mainnet Ethereum. Anyone can bridge funds to the rollup via the native bridge and use the network for payments using[ zkWallet](https://wallet.zksync.io/). The wallet also allows users to mint and receive NFTs on the network as well as send and receive payments. There are also partners of zkSync that support zkSync payments natively, like the aforementioned Gitcoin integration. Most of the applications will start supporting zkSync once the network is EVM compatible. This is because standard Solidity contract ABIs can be deployed on the network with minimal changes to the codebase. At current, all contracts on zkSync have to be written in the Zinc framework, which inhibits the network effect received from Ethereum mainnet.

Code: zkSync is fully open-source, so anyone can check the source code contributed to their[ GitHub repositories](https://github.com/matter-labs/zksync).

**zkSync 2.0**

zkSync 2.0 is the name of the network upgrade that brings zkEVM functionality and opens up the space network to Turing complete operations. It will fully support all the tooling that is used for writing smart contracts on Ethereum, whether it's core tooling like HardHat, ethers.js, Dapptools, OpenZeppelin, Solidity, Vyper, and others. Also, core infrastructure like TheGraph will be able to index data on-chain in order to create better blockchain data fetching infrastructure for building scalable decentralized applications.

A myriad of projects is already planning to deploy their newest versions of their protocols on zkSync 2.0. This includes protocols like Aave, Curve, Balancer, 1inch, Argent wallet, and various others. It will also be supported by bridges like Connext and Hop in order to have cross-L2 liquidity without having to bridge to Ethereum.

Many teams have simultaneously been pursuing the zkEVM as a piece of technology. The goal is to have full EVM compatibility/equivalence without compromising security in any way. The main goal is to have decentralized sequencer and validator infrastructure in place with full support for SNARKs (STARKs in the case of Starkware). zkSync's zkEVM was delayed from its first ambitious deployment date of August 2021 due to various engineering reasons detailed in[ this post](https://medium.com/matter-labs/zksync-2-0-developer-update-d25417f16446).

If you want to try out zkSync 2.0, there is a Uniswap v2 clone called[ UniSync](https://uni.zksync.io/#/) which you can try out on the Rinkeby Ethereum testnet. To learn more about the zkEVM, I suggest reading[ their community FAQ](https://zksync.io/zkevm/).

- **Starkware**

[StarkWare](https://starkware.co/) is a company that develops STARK-based solutions for the blockchain industry. Their products enable secure, trustless, and scalable solutions for blockchain applications.

One of the key contributions of StarkWare Industries Ltd. is its scientific research and technological advancements in the zero-knowledge blockchain computation field with the invention of STARKs (Scalable Transparent Arguments of Knowledge). These are a form of validity proof with a completely trustless setup that enables offloading all on-chain computation off-chain to a single off-chain STARK prover. Then, the prover must verify the integrity of those computations using an on-chain STARK Verifier.

One of the best learning hubs for STARKs is[ Starkware's STARK page](https://starkware.co/stark/), where you can read the academic papers that put the mathematical foundations and then dive deep into using STARKs with code examples alongside various other helpful resources. More resources for learning STARKs are available in the ‘Further reading' section.

To keep up to date with Starkware, follow[ their Medium blog](https://medium.com/starkware) and[ content page](https://starkware.co/content/).

- **StarkEx**

[StarkEx](https://starkware.co/starkex/) is an L2 scalability engine developed by Starkware that enables the execution of Cairo operations in a ZK environment. Its currently supported features are:

- *Volition*, a hybrid on-chain/off-chain data solution
- Self-Custody
- Fast Withdrawals
- ERC-721 & ERC-20 Support 
- L2 NFT Minting
- DeFi Pooling
- dAMM (distributed AMM)
- Real-Time Oracle Price Feed
- Tracking of Interest/Funding
- Data Availability: Rollup, Validium (more on this later)

**And other features coming soon:**

- Data Availability: Volition
- Unique Minting
- Interoperability with Sidechains

StarkEx generates validity proofs which ensure that all the off-chain computations were performed with integrity, the STARK proof generated then gets verified on-chain before getting committed to Ethereum mainnet.

For more information on how StarkEx works, visit the[ StarkEx page](https://starkware.co/starkex/).

- **dYdX**

dYdX is an on-chain derivatives platform that runs on top of a zk-rollup built by Starkware. The platform is completely rewritten in Cairo and lives on its own isolated L2 where users can easily bridge funds from Ethereum mainnet and start trading with low transaction fees. The entire orderbook is on the L2, and so users have a much better UX than on the L1 without compromising security nor decentralization as the rollup itself is permissionless and self-custodial with a trustless prover and verifier.

dYdX is a custom implementation of Starkware's StarkEx and is currently the zk-rollup L2 that secures the most TVL with an approximate $1B in value locked according to[ L2beat](https://l2beat.com/).

- **StarkNet**

[StarkNet](https://starkware.co/starknet/) is a permissionless decentralized ZK-Rollup on Ethereum. It supports Turing complete computations and will feature EVM compatibility out of the box via a Solidity to Cairo compiler, however, native Cairo code will be more performant. StarkNet will also feature a range of data-availability solutions, meaning that users will be able to switch between a zk-rollup and a validium on a per transaction basis (more on this in the validium/volition section).

Since the L1<->L2 communication and the STARK prover and verifier will be fully permissionless and decentralized, the network will have the same security guarantees as Ethereum mainnet, whilst massively scaling throughput and providing a great and seamless UX.

Starkware announced that they will be rolling out the StarkNet Alpha on mainnet by the end of November. They are taking an approach inspired by their optimistic rollup counterparts where initially the smart contracts deployed on the network will be permissioned, meaning that the Starkware team will have to approve the deployment of smart contracts manually. In[ their announcement](https://medium.com/starkware/starknet-alpha-is-coming-to-mainnet-b825829eaf32) they also announced that future releases of StarkNet won't be backward compatible with the alpha as they will restart the network state.

There are additional features that will be rolled out as part of the Alpha 1 and Alpha 2 which include:

- smart contract constructors
- a better testing framework
- block and tx hashes
- account and token contracts
- support for contract upgradeability and events
- [Warp](https://github.com/NethermindEth/warp): the Solidity to Cairo compiler developed by Nethermind
- Ethereum signatures
- StarkNet Full Nodes

Developers can already get started building for StarkNet by learning Cairo to write, compile and deploy smart contracts locally and on StarkNet alpha. To get started check out the[ Cairo and StarkNet documentation](https://www.cairo-lang.org/docs/).

There's also a lot of tooling and services being built around the StarkNet ecosystem (taken from the[ StarkNet Alpha announcement](https://medium.com/starkware/starknet-alpha-is-coming-to-mainnet-b825829eaf32)):

- [Voyage](https://voyager.online/): StarkNet Alpha block explorer
- Open Zeppelin is working on a[ Standard Contracts](https://github.com/OpenZeppelin/cairo-contracts/tree/main/contracts) implementation for StarkNet and also started working on a developer’s environment:[ Nile](https://github.com/martriay/nile).
- ShardLabs is working on a[ StarkNet HardHat plugin](https://github.com/Shard-Labs/starknet-hardhat-plugin) and on a better testing framework.
- The Erigon team is working on expanding their Ethereum Full Node to support StarkNet (codename: Fermion). They are working with us on designing the core mechanisms of StarkNet.
- Equilibrium is working on a StarkNet Full Node implementation in Rust,
- Cairo audit services: In the coming months, ABDK, ConsenSys Diligence, Peckshield, and Trail of Bits will be conducting Cairo audit**

**

- **Polygon Hermez**

Polygon Hermez is a permissionless decentralized ZK-rollup living on Ethereum. The Hermez zk-L2 and its team[ were acquired by and merged into the Polygon ecosystem](https://blog.hermez.io/polygon-hermez-merge/). Polygon has a PoS data availability layer, a plasma chain, and is also developing scaling solutions that utilize optimistic rollups, and various others.

The Polygon Hermez team also announced their plans for full EVM-support (zkEVM) in a[ Medium blog post](https://blog.hermez.io/introducing-hermez-zkevm/). They expect to launch a testnet by the end of Q4 2021, with a mainnet launch somewhere in Q2 2022.

![Polygon Hermez tentative release schedule](https://dcbuilder.mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FZNRNTVucdbT9unnIU73Qe.png&w=3840&q=90)

Polygon Hermez tentative release schedule

The Polygon Hermez protocol uses a very similar dynamic to the other zk-rollups mentioned above. It has an off-chain prover that validates transactions and generates a SNARK proof which gets submitted to the on-chain verifier; If the proof is valid, the new state gets committed and settled on Ethereum mainnet. For more details on the Polygon Hermez infrastructure, you can visit[ the documentation](https://docs.hermez.io/#/developers/protocol/hermez-protocol/protocol).

The Hermez team also has a[ whitepaper](https://hermez.io/hermez-whitepaper.pdf) detailing the long-term vision of the project. It is a bit outdated by now since the Polygon merger happened afterward, and the HEZ token doesn't exist anymore as there was a swap from HEZ to MATIC (1HEZ = 3.5MATIC) and HEZ was phased out entirely. Besides that and the fact that it is under Polygon's leadership, the goals remain the same. To bring massive scalability to the Ethereum ecosystem.

Currently, Polygon Hermez can be used by anyone, however, it is not EVM-compatible. It is mostly used as a payments platform within a zk-rollup environment. To use Polygon Hermez, connect to their[ web wallet UI](https://wallet.hermez.io/login) using MetaMask or WalletConnect and deposit funds into their L2, on top of which you can freely transact with other users for a[ fraction of the cost](https://l2fees.info/) of Ethereum mainnet.

#### Aztec Network

Aztec Network is a privacy-focused ZK-rollup L2 on Ethereum. The Aztec Network L2 allows for fast, cheap, DeFi compatible transactions in a completely private fashion without compromising Ethereum security and decentralization. Aztec is built on[ PLONK](https://vitalik.ca/general/2019/09/22/plonk.html) which is a universal standard for SNARK technology developed by them. Aztec 2.0 is the current iteration of the protocol and improved on various shortcomings of v1.

**Aztec protocol features:**

- Identity Privacy: With cryptographic anonymity, sender and recipient identities are hidden
- Balance Privacy: Transaction amounts are encrypted, making your crypto balances private
- Code Privacy: Network observers can’t even see which asset or service a transaction belongs to
- Scalable private access to DeFi (Uniswap, etc.)
- Gas-optimized version of the PLONK (currently TurboPLONK, future UltraPLONK) protocol
- Programmable Privacy with Noir — The private contract language

**As a user you can:**

- Deposit: Shield your tokens by depositing them in Aztec
- Private Payments: Encrypted balances & identities — for all tokens
- Multi-Device Recovery: Your assets are protected from lost keys
- Withdraw: Take your tokens anonymously back to Layer 1
- Escape Hatch: Even if all rollup providers go down, your exit’s guaranteed

The Aztec team built a private wallet application called[ zk.money](https://zk.money/), users can deposit funds onto the Aztec 2.0 zk-rollup, 'shield their assets', and transact on the network.

- **Loopring**

[Loopring](https://loopring.org/#/) protocol is an open-source zkRollup protocol. It is a collection of Ethereum smart contracts and ZK circuits which describe how to build highly-secure, highly-scalable orderbook-based DEXes, AMMs, and payment apps.

Recently they also added NFT minting and transferring functionality and there has been an[ announcement](https://medium.com/loopring-protocol/loopring-quarterly-update-2021-q3-bd083d94ca17) of an NFT marketplace coming out by the end of Q4 2021. The new additions to the L2 include:

- a redesigned UI/UX for their exchange
- multi-layer Loopring wallet (will go cross-L2 / cross-chain)
- Loopring block explorer (Loopring[ subgraph](https://thegraph.com/hosted-service/subgraph/loopring/loopring))

**Moving forward they also plan on adding:**

- NFT marketplace
- zkEVM
- dAMM
- multi-layer wallets + mobile
- exchange improvements

As I mentioned many times in this article, the zkEVM is a goal that almost every L2 out there is striving towards in one way or another as validity proofs have many advantages over fraud proofs over the long term in terms of security, scalability, and execution advantages L2s get from using one over the other. It is a trend that leads teams towards progressive zk-ification.

Here is a good article written by Loopring's CTO on[ how he views the future of L2s](https://medium.com/loopring-protocol/loopring-cto-steve-what-is-the-real-future-of-layer-2-networks-7257934212e4).

Another great innovation is the dAMM which is a joint collaboration between Starkware and Loopring to build a cross-L2 AMM in order to prevent fragmented liquidity.

The team is building on a lot of features for their exchange in order to improve the overall user experience and also to lower down costs, they also plan on expanding their wallet to other L2s like Arbitrum, zkSync 2.0, Optimism, and EVM-compatible L1s like BSC, Moonbeam and Acala (Polkadot parachains), Harmony and more.

The Loopring protocol works in a very similar way to other zk-rollups mentioned above, according to their[ About page](https://loopring.org/#/about):

"Loopring relayer (aka operator) is their implementation of the backend system that interacts with the protocol to make a zkRollup run. It hosts and updates the off-chain Merkle tree, creates rollup blocks, generates zkSNARK proofs of their validity, publishes data + proofs to Ethereum, and more. Our relayer has been highly optimized for its use case: from orderbook matching to proof generation. Note: in doing all of this, it can never, ever, access or freeze user funds - the protocol simply does not allow it."

"While Loopring protocol is agnostic to relayer (anyone can build & use their own relayer(s) to run their zkRollup/products), what is known as the canonical 'Loopring L2' (and the products atop) is serviced by the Loopring relayer. Loopring relayer API can be used by builders, users, and other applications that want to perform gas-free, high-speed trading and transfers on Ethereum, or otherwise read or write to our L2."

**Useful resources**

- [Loopring 3.8 design documentation](https://github.com/Loopring/protocols/blob/master/packages/loopring_v3/DESIGN.md)
- [Loopring Protocol v3 Code](https://github.com/Loopring/protocols/tree/release_loopring_3.6.2/packages/loopring_v3)

### Validium/Volition (offchain calldata)

In this section, we'll discuss a hybrid approach to scaling, one that doesn't put calldata on-chain and instead takes some compromises in security in order to increase scalability. This approach is no longer considered a 'true L2' where the definition is a scaling network that inherits the same security guarantees of the network it is built on top of.

**What is a Validium?**

A validium is a type of scaling solution that utilizes validity proofs but has off-chain data availability. It compromises Ethereum security, however is still much more secure than a sidechain since the state transitions have verified validity through the use of STARKs/SNARKs. Currently, validium based solutions only work for specialized use cases and are not universally compatible with execution targets like the EVM or WASM, however with recent progress by teams like Starkware and zkSync, this will be possible in the near future.

For a more in-depth comparison of zk-rollups and validium, read[ zkSync's comparison](https://medium.com/matter-labs/zkrollup-vs-validium-starkex-5614e38bc263).

**What is Volition?**

Volition is an architecture ([pioneered by Starkware](https://medium.com/starkware/volition-and-the-emerging-data-availability-spectrum-87e8bfa09bb)) that an L2 can adopt where the user can choose whether to use a validium or a zk-rollup on the L2 on a per transaction basis. This would allow the user to specify whether he wants to maximize decentralization and security or scalability within the same L2; this architecture is getting a lot of traction and is set to be an integral design decision for the Starknet and zkSync 2.0 L2s as well as other validity proof based solutions in the future.

- **Starkware**

Starkware has partnered with various projects to build a use case tailored validium running the StarkEx engine in order to provide massive scalability. For the projects looking for true L2 security guarantees, a volition model using the StarkEx engine is adopted.

- **ImmutableX**

[ImmutableX](https://www.immutable.com/) is an NFT layer-2 that utilizes a StarkEx volition infrastructure to provide massive scalability to NFTs. It does this by offering an open NFT marketplace, access for partnered projects to run their NFT games and applications on their network, and a cheap, fast, secure, and scalable user experience to NFT enthusiasts.

To start building on ImmutableX,[ contact them](https://www.immutable.com/contact) and check out[ their documentation](https://docs.x.immutable.com/docs).

- **Sorare**

[Sorare](https://sorare.com/) is a fantasy football game that utilizes a StarkEx Validium to scale their NFT game for the masses.

- **DeversiFi**

[DeversiFi](https://www.deversifi.com/) is a decentralized cryptocurrency exchange that runs on a custom StarkEx Validium L2.

- **zkPorter**

[zkPorter](https://medium.com/matter-labs/zkporter-a-breakthrough-in-l2-scaling-ed5e48842fbf) is zkSync's validium implementation which will be running side by side with zkSync 2.0 in a volition design. From the[ zkEVM FAQ](https://zksync.io/zkevm/#what-is-zkporter):

"zkPorter puts data availability—essential transaction data needed to reconstruct state—offchain rather than on Ethereum. Instead, data availability is secured using Proof of Stake by zkSync token stakers. This enables much higher scalability (tens of thousands TPS), and as a result, ultra-low transaction fees comparable with sidechains (in the range of a few cents)."

"The security of zkPorter is still better than any other L1 or sidechain. In the worst case, where a malicious actor controls both the sequencer and over ⅔ of the total stake, they can sign a valid state transition but withhold the data. In this case, the state is “frozen” and users will not be able to withdraw, but the attacker’s stake is frozen as well. Thus, there is no direct way for an attacker with a large stake to financially benefit from an exploit."

More information can be found in the[ zkPorter Medium post](https://medium.com/matter-labs/zkporter-a-breakthrough-in-l2-scaling-ed5e48842fbf).

### How can you benefit?

#### Users

Thanks to L2s users will finally be able to enjoy low fees using their favorite web3 applications, a much better UX emerges as transaction confirmations are almost instant (thanks to L2 sequencers), and help scale blockchains massively. This will make accessibility to immutable blockspace much more affordable and help democratize the network for new users through simple and intuitive applications that will abstract all complexities away.

**Alpha:** Many of these L2s, protocols launching on top, and applications providing services are on the path to progressive decentralization and part of this process usually involves retroactive token distribution to early adopters and contributors. If you contribute and use these projects now, it is quite likely for you to be eligible for a reward once (or if) the projects launch tokens.

#### Builders

Application developers, protocol designers, and everyone else that partakes in the building process will be able to build scalable decentralized applications that are mutually composable and interoperable (even across rollups).

Scaling does not only allow for more users which brings exponentially more value to a network (Metcalfe's law), but it also allows for more computationally expensive operations to be performed on-chain which will expand the application design space and make new web3 use cases economically and technically feasible.

Things like social tokens, decentralized social networks, and protocols (ie.[ Showtime](https://showtime.io/),[ Aave social graph protocol](https://decrypt.co/76278/defi-project-aave-to-release-ethereum-based-twitter-alternative-this-year), NFT games (running on L2s like ImmutableX), and much more are finally a possibility. Builders are slowly losing the shackles that have slowed them down, zk-rollups also allow for custom execution layers that don't need to be constrained by Solidity and the EVM.

#### Current drawbacks

Currently, liquidity is being fragmented across L2s and there are no straightforward ways to use cross-L2 AMMs at the time of writing this article. A lot of developer tooling does not work out of the box for dapp development on various L2s and so teams tooling teams need to build variations of their software in order to add support for various different scaling solutions. In the future this will be mitigated with either total EVM compatibility or ideally with EVM equivalence or a standard design spec which would make it so that zk/optimistic-rollups can share tooling seamlessly.

Parts of the technical infrastructure of currently deployed L2s like the sequencer or the bridge are centralized as solutions like Arbitrum and Optimism are in their beta phase (these guard rails will be lifted off once they are self-sufficient enough). L2s also break composability and interoperability and so there's no seamless way for communicating messages across different L2s nor calling smart contracts from other smart contracts in another L2.

There's also a lot to be done in terms of oracle infrastructure and quality data feeds. Chainlink is working on integration with all the L2s along with other oracle providers, however, for the infrastructure to be as robust as it is on Ethereum mainnet will take time and effort.

Another key issue in terms of the UX for L2s is fiat onramps. The vast majority of centralized exchanges currently do not support native withdrawals to L2s and so it is very cumbersome for someone that is not technically skilled to bridge funds to an L2 (especially if he/she has to pay Ethereum L1 fees). A current workaround is to use an exchange to withdraw to a sidechain like Polygon PoS which has sufficient liquidity in cross-chain (centralized) bridges like Hop or Connext.

But the point that we need to work most on, is the education of users. I've seen countless people complaining about the high gas fees on Ethereum and migrating to L1s that have a much cheaper transaction fee (ie. Avalanche, Solana, Fantom, Terra) at the expense of decentralization and security. As a fellow Ethereum community member, I'd like to ask for help in educating the masses about Ethereum scalability and how they can still be active in our ecosystem in an affordable way. We should also talk to different applications and protocols and submit proposals within their governance forums to create liquidity mining rewards for L2 liquidity and/or L2 liquidity bonding (a la OlympusDAO). This would make it much more seamless to migrate for users as liquidity is one of the biggest reasons why users are still using the L1, something which in my opinion won't be the case as the Ethereum mainnet will be a chain that will act as a data availability layer for L2s, never facing individual users.

## L2 liquidity

As I mentioned above, there are many valid concerns about fragmented liquidity across the Ethereum ecosystem as liquidity is not shared across L2s. In this section, I'll cover a few of the projects and liquidity models which are planning to tackle this very issue.

### Hop protocol

"[Hop](https://hop.exchange/) is a scalable rollup-to-rollup (also supports Polygon PoS and xDai) general non-custodial token bridge. It allows users to send tokens from one rollup or sidechain to another almost immediately without having to wait for the network's challenge period."

"It works by involving market makers (referred to as Bonder) who front the liquidity at the destination chain in exchange for a small fee."

"This credit is extended by the Bonder in the form of hTokens which are then swapped for their native token counterpart in an AMM."

"The end result allows users to seamlessly transfer tokens from one network to the next."

The Hop team also provides an[ SDK](https://docs.hop.exchange/js-sdk/getting-started) that enables developers to integrate Hop functionality into their decentralized applications.

- Source:[ Hop FAQ](https://help.hop.exchange/hc/en-us/articles/4405172445197-What-is-Hop-Protocol-)
- [Code](https://github.com/hop-protocol)

### Connext

[Connext](https://connext.network/) is a network of liquidity pools on different networks (L1s and L2s). Users swap values between these pools, similar to AMM DEXes like Uniswap.

Connext routers act as the backbone of the network, providing liquidity for user swaps and earning fees in return.

They created[ NXTP](https://github.com/connext/nxtp) which is a lightweight protocol for generalized xchain/xrollup transactions that retain the security properties of the underlying execution environment (i.e. it does not rely on any external validator set).

The Connext protocol can be accessed through the[ xPollinate](https://xpollinate.io/) UI.

- [Code](https://github.com/connext/nxtp)
- [Documentation](https://docs.connext.network/)

### Synapse protocol

"[Synapse](https://synapseprotocol.com/) is a cross-chain layer ∞ protocol powering frictionless interoperability between blockchains. By providing decentralized, permissionless transactions between any L1, sidechain, or L2 ecosystem, Synapse powers integral blockchain activities such as asset transfers, swaps, and generalized messaging with cross-chain functionality - and in so doing enables new primitives based off of its cross-chain architecture."

"The Synapse network is secured by cross-chain multi-party computation (MPC) validators operating with threshold signature schemes (TSS). The network is leaderless and maintains security by each validator running the same process upon receiving on-chain events on the various chains that the MPC validator group tracks. Once two-thirds of all validators have collectively signed the same transaction using their own individual key, the network achieves consensus and issues a transaction to the destination chain."

- [Source: Documentation](https://docs.synapseprotocol.com/)

### Celer cBridge

"[Celer cBridge](https://cbridge.celer.network/#/transfer) is a multi-chain network that enables instant, low-cost, and ANY-to-ANY value transfers within and across different layer-1 blockchains, such as Ethereum and Polkadot, and different layer-2 scaling solutions on top, such as Optimistic Rollup, ZK Rollup, and sidechains."

- [Source: Documentation](https://cbridge-docs.celer.network/#/FAQ)
- [Code](https://github.com/celer-network/)

### deBridge

"[deBridge](https://debridge.finance/) is a cross-chain interoperability and liquidity transfer protocol that allows truly decentralized transfer of arbitrary data and assets between various blockchains. The cross-chain intercommunication of deBridge smart contracts is powered by the network of independent oracles/validators which are elected by deBridge governance."

"The protocol enables transfers of assets between various blockchains via locking/unlocking of the asset on the native chain and issuing/burning the wrapped asset (deAsset) on secondary chains or L2s. Cross-chain communication between different blockchains is maintained by elected validators who run the deBridge node to perform validation of cross-chain transactions that pass between smart contracts of the deBridge protocol in different blockchains."

- [Source: Documentation](https://docs.debridge.finance/)
- [Code](https://github.com/debridge-finance/)

### dAMM

[dAMM](https://medium.com/loopring-protocol/damm-distributed-amm-98dcfa2b26dd) is a cross-L2 AMM design developed jointly by Loopring and Starkware.

![dAMM architecture](https://dcbuilder.mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FNyu8l0ekW2JerJ5auV8mv.png&w=3840&q=90)

dAMM architecture

dAMM enables:

- ZK-based L2s (e.g., DeversiFi, Loopring …) to asynchronously share liquidity — exposing LPs to more trades
- LPs to serve L1 AMM such as Uniswap while partaking in L2 trading => scaling without compromise
- dAMM harnesses the permissionless nature of L1, mitigating against liquidity fragmentation due to disparate L2s

### Tokemak

[Tokemak](https://www.tokemak.xyz/) is a liquidity routing protocol that is part of a new emerging wave of DeFi protocols colloquially addressed as DeFi 2.0 (or DeFi 2021).

"It can be thought of as a decentralized market-making platform and a liquidity router that disaggregates traditional liquidity provision and market making for DeFi. Sitting a "layer above" decentralized exchanges, Tokemak allows for control over where the liquidity flows, and also offers an easier, cheaper way for providing and sourcing liquidity."

Tokemak [announced](https://medium.com/tokemak/leaky-thoughts-with-s-d3f3e3ace7c) that they plan to target the liquidity fragmentation problem by creating a deep liquidity pool that could route liquidity to pools from cross-L2 bridges like Hop to solve current liquidity fragmentation issues.

#### Summary

Liquidity fragmentation across L2s is a problem that is already being addressed in various ways and by various different players. My personal speculation is that a model that contains a mix of the dAMM + Hop/Connext + Tokemak designs will emerge in order to abstract L2 liquidity fragmentation away in a form that will make it seem like it's completely unified.

# Resources

### Tools

These are tools I use on a daily basis to gauge the state of adoption of Ethereum L2s, how expensive transactions on them cost, and what is the L2 protocol revenue.

#### Dune Analytics

[Dune Analytics](https://dune.xyz/browse/dashboards) is a data analytics platform that allows anyone to easily aggregate and visualize blockchain data. On Dune you can create a data hub for your research project, article, DAO or any other project in the matter of hours. With regards to L2s, I use it to monitor how many funds are locked inside of L2 bridges. Relevant data dashboards:

- [Bridge Away dashboard](https://dune.xyz/eliasimos/Bridge-Away-(from-Ethereum)) created by [@eliasimos](https://twitter.com/eliasimos) provides an overview of how many funds are locked inside bridges into other L1s (Avalanche, BSC, Fantom, …), sidechains (Ronin, Polygon PoS) and also several L2s like (Arbitrum, Optimism, zkSync and Boba). It is also good to know where users are bridging to see where is capital escaping to know where Ethereum is lacking and how it can improve. If Ethereum provides a better UX, then much less capital will leave the network (especially new users).
- [⛽ Wallet Transaction & Gas Fees Dashboard](https://dune.xyz/kevdnlol/Transaction-Breakdown) by @kevdnlol in order to analyze the gas market on Ethereum.

#### L2BEAT

L2BEAT is the leading dashboard for looking at how much TVL is in Ethereum L2s. 

![L2BEAT L2 TVL](https://dcbuilder.mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FaIIQhodqkO_1IvlBWHPKG.png&w=3840&q=90)

L2BEAT L2 TVL

![L2BEAT project dashboard](https://dcbuilder.mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FvPaQJjYvuyT1Lo0g8M-Lr.png&w=3840&q=90)

L2BEAT project dashboard

One of the great features of L2beat is that they also feature the type of scaling technology used within the L2 and the purpose it is currently serving. They also have a [good FAQ](https://l2beat.com/faq/) page that I often reference for beginners just learning about L2s.

#### L2Fees

[L2Fees](https://l2fees.info/) is one of many great dashboards built by [David Mihal](https://twitter.com/dmihal), it shows how cheap it is to perform different actions on certain L2s compared to Ethereum mainnet.

![L2Fees comparison](https://dcbuilder.mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FRcP0uFNx25mRPbpOVqwTh.png&w=3840&q=90)

L2Fees comparison

#### CryptoFees

[CryptoFees](https://cryptofees.info/) is yet another data dashboard built by David, it shows how much revenue protocols earn from its users. L2 protocols also appear on this list; I use this dashboard to see how much revenue do L2s earn and what they do with it. Part of the revenue goes towards paying the fees for submitting zk-SNARK/STARK/fraud proofs to mainnet and the rest is what L2s can work with. In the case of Optimism, they donate all their proceeds to public goods, which is in my opinion the best way to spend protocol fees.

#### Nansen

[Nansen](https://www.nansen.ai/) is a blockchain analytics platform that enriches on-chain data with millions of wallets labels. It is a paid platform, and isn’t exactly cheap. However, it is very affordable for the amount of value it provides in return if used correctly. I personally use Nansen for identifying narratives within DeFi and NFTs, however I’ve recently started to use their wallet profiler feature on the smart contracts for L2s to see which entities are bridging to L2s and how fast. It shows a much clearer picture as many addresses and active players are labeled.

**Chainlist**

[Chainlist](https://chainlist.org/) is an application that contains the RPC configurations needed to use a certain network inside of Metamask or other web3 wallets. You can add different networks that are EVM compatible - L1s, sidechains, and also L2s. Relevant L2 networks available on Chainlist are Optimistic Ethereum mainnet, Arbitrum One, Boba Network, and others soon to come.

