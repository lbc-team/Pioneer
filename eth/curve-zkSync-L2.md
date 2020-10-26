> * 原文链接:https://medium.com/matter-labs/curve-zksync-l2-ethereums-first-user-defined-zk-rollup-smart-contract-5a72c496b350
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[]()
> * 本文永久链接：[learnblockchain.cn/article…]()



# Curve + zkSync L2: Ethereum’s first user-defined ZK rollup smart contract!



## Welcome to Zinc Alef, the zkSync smart contracts testnet.



![](https://img.learnblockchain.cn/2020/10/23/16034192591139.jpg)



Curve and Matter Labs teams are excited to announce a big step towards scaling Ethereum in a secure and decentralized way: today, we’re unveiling a zkSync L2 smart contracts testnet with Curve Finance as the first resident dapp.



## Why ZK rollup?

Scalability is a burning need — but there is a light at the end of the tunnel. Vitalik Buterin [just proclaimed rollups “the only choice” for scaling Ethereum](https://www.trustnodes.com/2020/10/05/ethereum-rollups-are-the-only-choice-for-scalability-says-vitalik-buterin), highlighting their [unique trustless security guarantees](/matter-labs/evaluating-ethereum-l2-scaling-solutions-a-comparison-framework-b6b2f410f955).

ZK rollup (ZKR) is one of the two existing rollup flavors, the other one being optimistic rollup (OR). Both approaches have their trade-offs ([see a detailed comparison](/matter-labs/optimistic-vs-zk-rollup-deep-dive-ea141e71e075)). Here are the major practical differences:

**Security**. ZK rollups are extremely secure even with a single validator, as they rely on pure math instead of ongoing economically incentivized activity to keep funds safe. Cryptographic assumptions aside, ZKRs are as secure as the underlying L1\. This is especially important for protocols that deal with a high total value of assets. In contrast to ZKRs, optimistic rollups possess a strong anti-network effect: their security decreases proportionally to the value locked. In fact, there is an effective cap on the capital size (in the range of $10s of millions) that can be securely placed into a single OR while keeping it resistant to a [highly plausible attack on L1](https://ethresear.ch/t/nearly-zero-cost-attack-scenario-on-optimistic-rollup/6336). This attack vector cannot be mitigated as long as Ethereum remains a PoW chain.

**Finality**. ZK rollups have short finality (minutes), and therefore support capital-efficient fast exits to L1\. In contrast, optimistic rollups [are forced to choose between fast and capital-efficient exits](/starkware/the-optimistic-rollup-dilemma-c8fc470ca10c), but cannot have both. Most researchers consider a dispute-delay time of at least one week necessary for ORs. This is important for interoperability with contracts on L1, which (will at least initially) continue to play a big role in the ecosystem.

**Programmability**. It is easier to support full EVM-compatibility with optimistic rollups. The OR approach was generally considered the only viable way to bring existing Ethereum smart contracts into L2\. However, this is about to change.

## Smart contracts in a ZK rollup?

Until recently, it was considered an extremely challenging task to support arbitrary user-defined smart contracts in a ZK rollup. But things move fast in zero-knowledge proof space these days. 2020 has brought several breakthroughs that finally made it possible: Matter Labs introduced the Zinc programming language and SNARK-friendly Zinc VM, and implemented [recursive PLONK proof verification for Ethereum](/matter-labs/zksync-v1-1-reddit-edition-recursion-up-to-3-000-tps-subscriptions-and-more-fea668b5b0ff). The combination of these technologies will power smart contracts on zkSync.


## How does Zinc VM work?

Contracts are written in Zinc programming language and compiled. The compiler output is twofold:

1. Bytecode for the Zinc Virtual Machine.
2. SNARK verification keys for this contract.

Zinc VM bytecode + verification keys can be deployed to the zkSync network in a fully permissionless manner. The contract will get assigned a new address inside L2\. Whenever users interact with this contract, validators of zkSync will execute the Zinc VM opcodes and produce a zero-knowledge proof of the validity of the transaction — a special design of SNARK-friendly Zinc VM makes this possible. The proof will then be recursively verified by the rollup block circuit against the deployed verification keys. The block proof is then verified by the zkSync smart contract on Ethereum to authorize state transition, which by transience verifies the entire contractual logic of all transactions in the block.

Thus, Zinc smart contracts on zkSync inherit the strict security guarantees of validity proofs.

## How to write smart contracts for zkSync?

At the moment, smart contracts for Zinc VM must be written in the Zinc programming language. Check out the new version of the [Zinc Book](https://zinc.zksync.io), you will find the complete getting started guide and full developer reference. We’re looking forward to your questions and feedback in the [Zinc Gitter chat room](https://gitter.im/matter-labs/zinc).

Zinc is currently in a closed development beta. If you are interested in trying it out for your project, please [talk to us](https://zksync.io/contact.html).

## How does Zinc differ from Solidity/Vyper? Can I port my existing source code?

Zinc follows simplified Rust syntax, but it borrows all smart-contract elements and structure from Solidity. It can be learned in a few days by any experienced Solidity/Vyper developer.

Since Zinc is structurally identical to Solidity, existing Solidity code can easily be translated into Zinc. The main challenge is that Zinc is currently non-Turing-complete. This means: recursion and unbounded loops are prohibited (bounded loops are fine).

Vyper, the second most popular ETH smart contract language, is non-Turing-complete too. Therefore any Vyper program can be isomorphically translated into Zinc today. This is exactly how the Curve on zkSync works: Matter Labs helped the Curve team to rewrite existing Curve contracts into a Zinc version. It is almost line-by-line identical to the original source.

Although Zinc itself is non-Turing complete, anything you can do in Solidity can in practice be achieved in Zinc with minimal modifications: in part because the code of most Defi apps rarely requires loops or recursion, and in part, because the Turing-complete components can be re-implemented by leveraging transaction-level recursion, i.e. contracts invoking their own public methods via external calls (this is still possible in zkSync).

But we have more good news: Matter Labs is working on making Zinc Turing-complete in the near future. And until then, we are happy to provide support for your team to make existing Solidity code portable. Please [reach out](https://zksync.io/contact.html).

## What about composability?

All contracts inside zkSync L2 network will be able to call each other atomically in exactly the same way as on Ethereum mainnet.

## How are the user keys managed?

During the [Gitcoin Grants Round 7](https://gitcoin.co/blog/gitcoin-grants-round-7/), zkSync was integrated directly into the checkout flow, which required trusting the Gitcoin website. In this demo, zkSync private keys never leave the scope of [connect.zksync.dev](https://connect.zksync.dev). This type of integration resembles the Single-Sign-On authentication scheme from the Web2 world, widely used with Google/Apple/Facebook logins. What this practically means is that zkSync can be used today in conjunction with any Ethereum wallet and any number of completely untrusted dapps.

Even if the zkSync website was hacked, our approach requires a 2-factor authentication by signing every message additionally by your Ethereum wallet. This signature is currently verified by our servers, although recursive PLONK proofs now make it possible for us to integrate it directly into our ZKP circuits without too much overhead.

In parallel, we are working together with other teams on the development of universal Ethereum signing standards for L2, which will make the UX around interacting with L2 contracts even more delightful.

## What are the limitations of Zinc Alef?

The testnet is fully functional. You can write smart contracts, deploy them to testnet, test them locally, and generate zero-knowledge proofs of smart contract execution. Every transaction will lead to real token transfers on the zkSync testnet, which will be reflected in the block explorer and wallets. You will need real testnet ERC20 tokens for your transactions.

However, at this stage, Zinc VM is not yet integrated into zkSync core. Some important functionality in the Zinc programming language can also be missing. We are prioritizing the feature development according to the requests from the community.


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。


