原文链接：https://www.coincenter.org/education/advanced-topics/how-does-tornado-cash-work/



# Tornado Cash 是如何工作的?

## 1. 引论

2022 年 8 月，美国财政部外国资产控制办公室 (OFAC) 对 Tornado Cash 进行了制裁，将 45 个以太坊地址添加到特别指定国民 (SDN) 受制裁人员名单中。

本文档旨在帮助读者了解 Tornado Cash 是什么、它是如何工作的，以及究竟是什么受到了制裁。但在我们深入介绍Tornado Cash 之前，让我们回顾一下围绕以太坊、智能合约和去中心化的几个关键概念。

## 2. 背景知识:什么是以太坊,谁在使用以太坊, 智能合约又是什么?

以太坊是一个合作运行的、全球的、透明的数据库。来自世界各地的参与者共同维护着以太坊地址的公共记录.这些记录指向了用户帐户信息和智能合约。当这些记录指向的内容(在以太坊上)运作时,很像现代台式计算机上用户帐户(译者注:类似以太坊用户地址)和软件(译者注:类似智能合约)的运行模式. 但是以太坊也有自己的不同之处, 包含如下：

- 合作运行：以太坊的基本运作来自于全球参与者的集体努力。任何一方都无法改变以太坊的运作方式。
- 公开访问：世界上任何地方的任何人都可以与以太坊、以太坊的用户及以太坊上的应用程序进行交互。
- 透明：世界上任何地方的任何人,都可以下载和查看以太坊数据库中的所有信息。

任何人都可以成为以太坊的用户。创建帐户很简单，你不需要电话号码、电子邮件或实际地址。相反，用户安装一个称为“钱包”的应用程序，它为该用户生成一个称为“地址”的唯一标识符和一个类似密码的数字，这个数字用于身份验证,被称为“私钥”。就像拥有多个电子邮件地址的人一样，以太坊的用户可以根据需要创建和使用任意数量的地址。然而，与电子邮件不同，以太坊的用户不是传统意义上的“客户”。他们是在开源软件上运行的全球计算系统的参与者，该系统在没有第三方监督的情况下运行。同样重要的是,由同一用户控制的以太坊地址不一定彼此公开关联,它们只是一组唯一的标识符,属于拥有相应私钥的用户。

通过共享地址，用户可以从世界上任何地方的任何人那里接收代币（*例如*加密资产，如 Ether）。与传统的支付服务不同，在以太坊上发送和接收代币不需要中介。相反，发送方广播他们转移代币的意图，使用相应的私钥对他们的消息进行数学签名，然后以太坊网络使用新余额共同更新发送方和接收方地址的全局记录。在此过程中，任何时候第三方都不会保管正在转移的代币。


除了发送和接收代币外，用户帐户还可以与智能合约进行交互，这些类似应用程序的智能合约扩展了以太坊的功能。当开发人员编写智能合约时，他们决定智能合约将支持哪些操作,以及这些操作必须遵循哪些规则。这些规则和操作使用特定代码编写，就如同上面描述的代币交易一样(被广播到整个以太坊上)。一旦将智能合约的代码添加到以太坊的记录中，合约就会获得一个唯一的地址(表示合约自身)，任何用户都可以与合约交互，以自动执行合约支持的规则和操作。

本质上，智能合约是任何人都可以部署到以太坊的开源应用程序。就像以太坊的其他部分一样，任何人都可以在任何地方查看和使用智能合约，而无需依赖中介。

人和智能合约都可以有自己的以太坊地址；关键区别在于，当一个人拥有地址时，他们拥有私钥可以控制发送到该地址的任何代币。他/她将最终决定是否以及何时使用这些代币进行何种交易。当智能合约有地址时，智能合约代码中编写的规则和操作将控制代币。它们可以是简单的规则（*例如*自动发回代币），也可以是更复杂的规则。可能会有包括人为操作和人为决定的规则（*例如*如果这些人为控制的地址中有五分之三发送签名消息表示他们同意，则发回代币）。然而，这些规则也可以完全和永久地不受任何人的控制。在这种情况下，发送到该地址的任何代币也将不受任何人控制, 除非合同根据规则又将代币发回给某个人。

![1.png](https://img.learnblockchain.cn/attachments/2022/09/Os7gFlId63184e742f01e.png)

By default, smart contracts are immutable, which means they cannot be removed or updated by anyone once deployed. It is possible for the smart contract’s developers to include (in the contract code) the ability to update functionality as a supported operation (*e.g.* this *human-controlled* address can rewrite the contract in the future)*.* However, such an operation must be included in the smart contract’s code prior to the smart contract’s deployment (*i.e.* publication to the Ethereum network). Without the inclusion of updatability prior to deployment, a smart contract cannot be modified by anyone. It is also possible to revoke the ability to update functionality by transferring the permissions for this ability to a placeholder Ethereum address for which there is no corresponding private key. This placeholder is known as “the zero address.” Once the ability to update a contract has been revoked, it cannot be reclaimed and the contract can no longer be changed.

Unlike traditional finance, Ethereum’s records are completely transparent: anyone can download and view the balances and transaction history of its user accounts. Although user addresses are pseudonymous, if a real-world identity is linked to a user address, it becomes possible to trace that user’s complete financial history. Ethereum’s transparency is important for auditability (*e.g.* verifying that updates to records are valid). However, this transparency also makes it difficult for users to protect their personal information. By default, a record of a casual transaction today (*e.g.* paying for Wi-Fi at the airport) leads directly to records of earlier transactions, which may include any intimate, revealing, or sensitive transactions made by the same user long ago.

Among the many different applications smart contracts may support, they may also provide an avenue for users to regain the privacy they expect when interacting with financial systems. Central to that privacy is the use of smart contracts to break the public chain of records that would otherwise link your transaction today to every transaction you’ve ever made in the past. Enter Tornado Cash.

## 3. Tornado Cash: A smart contract application

Tornado Cash is an open source software project that provides privacy protection for Ethereum’s users. Like many such projects, the name does not refer to a legal entity, but to several open source software libraries that have been developed over many years by a diverse group of contributors. These contributors have published and made Tornado Cash available for general use as a collection of smart contracts on the Ethereum blockchain.

As we will explain, some of these smart contracts have been sanctioned by OFAC. The core of Tornado Cash’s privacy tools, however, make up a subset of the addresses sanctioned by OFAC: the Tornado Cash “pools.” Each Tornado Cash pool is a smart contract deployed to Ethereum. Like other smart contracts, the pool contracts extend the functionality of Ethereum with specific operations that can be executed by any user of Ethereum according to the rules defined in the Tornado Cash contracts’ code.

This section will describe how these pools work. In particular, it will describe the key innovation that enables these pools to function autonomously: an application of privacy-preserving mathematics known as “zero-knowledge cryptography.”

Subsequent sections will describe the specific addresses sanctioned by OFAC, and what they do. An appendix at the end will list all of the sanctioned contracts and their salient features.

### Tornado Cash Core Contracts: Pools

Tornado Cash pools are smart contracts that enable users to transact privately on Ethereum. When prompted by a user, pools will automatically carry out one of two supported operations: “deposit” or “withdraw.” Together, these operations allow a user to deposit tokens from one address and later withdraw those same tokens to a different address. Crucially, even though these deposit and withdrawal events occur publicly on Ethereum’s transparent ledger, any public link between the deposit and withdrawal addresses is severed. The user is able to withdraw and use their funds without fear of exposing their entire financial history to third parties.

In support of the deposit and withdrawal operations, these smart contracts encode strict rules that further define its functionality. These rules are automatically applied to the deposit and withdrawal operations to maintain a very important property shared by all Tornado Cash pools: **users can only withdraw the specific tokens they originally deposited.**

This property is enforced automatically for all the pool’s operations, and ensures that Tornado Cash pools are entirely *non-custodial*. That is, a user who deposits and later withdraws tokens maintains total ownership and control over their tokens, even as they pass through the pool. At no point is the user required to relinquish control of their tokens to anyone.

A key principle of Tornado Cash pools is that a user’s privacy is derived in large part from the simultaneous usage of the pool by many other users. If the pool had only a single user, it wouldn’t matter that the link between the user’s deposit and withdrawal addresses was severed: simple inference would make it obvious where the withdrawn tokens came from. Instead, pools are used by many users simultaneously. Think of it like a bank’s safe deposit box room. Anyone can go and store valuables in a locked box in that room, and, assuming the locks are good, only the person with the key can ever get those valuables back. Security aside, however, this may or may not be privacy enhancing. If only one person is ever seen going into and out of the room, then we know any valuables in that room are theirs. If, on the other hand, many people frequently go into and out of the room, then we have no way of knowing who controls which valuables in which boxes. By guaranteeing the property that users can only withdraw tokens they originally deposited, many users can simultaneously use these pools with the assurance that no-one else will receive their tokens.

Traditionally, these assurances would be provided by a *custodial* service: a bank in the safe deposit box example, or a group of people running a “mixing service” in other common cryptocurrency arrangements. Mixing services like Blender.io directly accept tokens from their clients, aggregate and mix them, and then return the funds to their clients (often taking some fee in the process). During the intermediate aggregation and mixing stage, the funds in question are completely in the control of the operators of the mixing service and are commingled. At the final stage of the mixing process, a user would receive funds sourced directly from the myriad other users that also used the service.

In contrast, Tornado Cash pools have no custodial operator, and users only ever withdraw the tokens they originally deposited (rather than a mixture of tokens from the other users of the service). This is made possible because of important properties of the deposit and withdrawal operations, which are automatically carried out through the use of a privacy-preserving branch of mathematics called “[zero-knowledge cryptography.](https://en.wikipedia.org/wiki/Zero-knowledge_proof)” This zero-knowledge cryptography is included in Tornado Cash’s smart contract code, and forms the foundation on which the deposit and withdrawal operations function.

#### Zero-Knowledge Proofs

To recall an earlier point, Ethereum is transparent: anyone can view the transaction history and balance of any user account. Likewise, anyone can view the interaction history, balance, and code of a smart contract application. If a user prompts a smart contract to perform an operation, this interaction becomes a fact that is forever recorded in Ethereum’s public records and can be recalled and inspected by anyone. So how is it that a user can deposit into a Tornado Cash pool and later withdraw to a different address without creating an obvious link to anyone observing Ethereum’s public records?

The answer lies in *zero-knowledge proofs*. A zero-knowledge proof is a cryptographic method by which one party (the “prover”) can prove to another party (the “verifier”) that a given statement is true without the prover conveying any additional information apart from the fact that the statement is indeed true.

![2.png](https://img.learnblockchain.cn/attachments/2022/09/lhWvSUke63184e78d0115.png)

In the case of Tornado Cash, the “prover” is the user withdrawing tokens from the pool, while the “verifier” is one of the Tornado Cash pool contracts. When a user prompts the pool smart contract to withdraw their tokens, the user must supply the prompt with a zero-knowledge proof. The pool’s code automatically checks the input proof, only processing a withdrawal if the proof is found to be valid. Exactly what statement is being proven by the user and how they create that proof is slightly more complicated, and requires a bit more detail on the deposit process.

#### Pool Deposit Process

![3.png](https://img.learnblockchain.cn/attachments/2022/09/GwEnTYzn63184e7d089bb.png)

When a user wants to deposit tokens, they first generate a “deposit note” (a long sequence of digits known only to the user). This is done privately on the user’s own computer, and is never shared publicly. Next, the user prompts the Tornado Cash pool contract to process the deposit. Along with this prompt, the user supplies a hash (or encoded form) of their deposit note and the tokens for deposit. The pool smart contract automatically records the encoded note as a new entry in a public list of other users’ encoded notes. At this point, the depositing user has completed the first part of the process, and retains the deposit note, which acts as a receipt to withdraw the tokens later.

#### Pool Withdrawal Process

![4.png](https://img.learnblockchain.cn/attachments/2022/09/0u9Zwkjj63184e80a8d42.png)

When a user is ready to withdraw their tokens, they first split their deposit note in half. One side acts like a “secret,” and the other acts like a “lock.” After that, the user prompts the Tornado Cash smart contract to withdraw. Along with the prompt, the user supplies:

- A *hash* (or encoded form) of the “lock”
- A *zero-knowledge proof*, generated using the “secret” and the “lock”

The pool smart contract uses these inputs to automatically verify – that is, *prove* – the following:

1. That the zero-knowledge proof was generated using the “secret.” It is the exact same “secret” that corresponds to one of the existing encoded notes in the pool’s public list of encoded notes (*i.e.* proving that the tokens being withdrawn were previously deposited by someone)*.*
2. That the same proof also corresponds to the encoded form of the “lock” supplied with the proof (*i.e.* proving that the person who is withdrawing them must be the same person who deposited them)*.*
3. That the submitted “lock” has not been submitted previously (*i.e.* the deposit in question has not already been withdrawn)*.*

Assuming the proof is verified, the pool smart contract automatically:

1. Sends the user their tokens.
2. Records the encoded “lock” in a public list of other users’ encoded locks, ensuring the same tokens cannot be withdrawn again.

Crucially, the above operations are carried out while the following is never revealed: which specific encoded note the proof corresponds to (*i.e.* who, among all of Tornado Cash’s depositors, is now withdrawing).

#### Can Tornado Cash be removed or updated? If so, by whom?

As stated previously, for most readers, *Tornado Cash* is synonymous with a core subset of the Tornado Cash smart contracts: the Tornado Cash pools. The vast majority of these contracts are immutable. That is, they have no ability to be updated or removed by anyone. A complete list of sanctioned, immutable Tornado Cash pools can be found in [Appendix A](https://www.coincenter.org/education/advanced-topics/how-does-tornado-cash-work/#appendixa).

Note that many of these pools had, at one point, an “operator” role. The operator role was originally held by 0xDD4c…3384, aka *Gitcoin Grants: Tornado.cash*, another sanctioned address. This role afforded its holder two permissions:

- updateVerifier: Used to update the “verifier” used by the smart contract. In essence, this permission could be used to modify how the contract processed zero-knowledge proofs.
- changeOperator: Used to transfer the “operator” permission to another address, or revoke the “operator” permission entirely by transferring it to the zero address.

In May 2020, the updateVerifier permission was used in conjunction with the changeOperator permission as a final update to these Tornado Cash pools. This updated all pools’ zero-knowledge proof processors to their final version, which incorporated the contributions of over 1,100 community participants. Additionally, this update revoked the “operator” permission by using changeOperator to transfer the permission to the zero address. In effect, the update performed in May 2020 cemented the community’s preferences, and ensured no further changes could be made. Details on this process can be found [here](https://tornado-cash.medium.com/tornado-cash-is-finally-trustless-a6e119c1d1c2).

A handful of SDN-listed pools still have an “operator” permission. Of these, two belong to very old, now-unused versions of Tornado Cash. The remaining pools either have newer, immutable versions, or were used so little that they were likely overlooked during the May 2020 final update. Most of these remaining eight pools have never been used, and the ones that were used were only used once or twice within the past three years. A complete list of sanctioned, outdated Tornado Cash pools that retain the operator permission can be found in [Appendix C](https://www.coincenter.org/education/advanced-topics/how-does-tornado-cash-work/#appendixc).

### Tornado Cash Auxiliary Contracts & Controls

#### Governance and TORN Token

The pool smart contracts represent the core of the Tornado Cash application, which remains immutable and uncontrolled by any party. However, OFAC’s sanctions also include auxiliary smart contracts that provide coordination mechanisms for the continued maintenance and use of Tornado Cash by its community. Several of these contracts are unused today, belonging to older versions of Tornado Cash. A complete list of OFAC-sanctioned smart contracts that relate to Tornado Cash’s community maintenance can be found in Appendix B.

The SDN List includes two primary contracts still in use today:

- *Tornado Cash (Router)*: References a registry of up-to-date Tornado Cash pools, consistent with the current version of Tornado Cash. Users may *optionally* choose to interact with Tornado Cash pools via the Router contract, which ensures their deposit and withdrawal operations are processed using up-to-date code.
- *Tornado Cash (Relayer Registry)*: References a registry of operators providing relay-assisted withdrawal services to users of Tornado Cash. Users may *optionally* elect to process their withdrawals via a relayer, which may afford additional privacy.

Unlike the pool smart contracts, the Router and Relayer Registry support some updatable functionality. However, the permission to update these contracts is held not by a human, but by another smart contract. This smart contract, also known as *Tornado Cash: Governance*, defines the rules and operations that determine how the Router and Relayer Registry may be updated.

In short, *Tornado Cash: Governance* provides that updates to these smart contracts are processed at the behest of the community, which holds public votes to determine what updates should occur, and when. Any holder of TORN tokens may participate in these votes. TORN is [an ERC20-token built on Ethereum](https://www.coincenter.org/education/crypto-regulation-faq/what-does-it-mean-to-issue-a-token-on-top-of-ethereum/) that is expressly used by the community to vote on governance proposals. Any user of Ethereum may purchase TORN tokens and participate in this process.

Note that while this process allows the wider Ethereum community to participate in the development and maintenance of Tornado Cash, *no part of this process allows for the update or removal of Tornado Cash pool smart contracts.* Additionally, participating in the *Tornado Cash: Governance* process is *entirely optional*: users can use Tornado Cash pools without any involvement, oversight, or interaction with the *Tornado Cash: Governance* process.

Although *Tornado Cash: Governance* and the TORN token contract are parts of the Tornado Cash software ecosystem, neither was added to OFAC’s SDN List.

#### Relayers

As previously mentioned, “relayers” are independent operators that provide an *optional* service for Tornado Cash users.

By default, when users prompt the Tornado Cash pool contracts for withdrawal, the withdrawal account needs to already have Ether in order to pay the Ethereum network to process the smart contract’s operations. However, sending Ether to the withdrawal account prior to withdrawal might create a link between the user’s deposit and withdrawal accounts.

Relayers allow users to process withdrawals without needing to pre-fund their withdrawal accounts, which helps users maintain privacy when withdrawing.

![5.png](https://img.learnblockchain.cn/attachments/2022/09/iUbq7kab63184e85068f2.png)

Users select a relayer from a public *Relayer Registry*, another sanctioned Tornado Cash smart contract. The user then uses their withdrawal account to sign a transaction authorizing the relayer-assisted withdrawal. The user sends this transaction to their selected relayer, who processes the withdrawal on their behalf, earning a fee in the process. Note that even though they process withdrawals on behalf of users, relayers never have custody over users’ tokens; the smart contract ensures that withdrawn tokens are only ever sent to the user’s withdrawal account.

OFAC has not specifically added any relayer addresses to the SDN List, but it has added the smart contract that contains a registry of relayers to the list.

#### Compliance Tool

Tornado Cash was built to enable Ethereum’s users to reclaim their privacy. Rather than exposing their complete financial history, Tornado Cash gives users control over their personal information: both what is shared and with whom it is shared. However, maintaining privacy and preserving control over one’s personal information does not need to come at the expense of non-compliance with legal obligations.

To this end, the developers of Tornado Cash created the *Tornado Cash Compliance Tool*. Users supply the tool with the original “deposit note” generated during the pool deposit process to create a PDF report that provides proof of the original source of the tokens. Although the public link between a user’s deposit and withdrawal addresses was severed by the Tornado Cash pool contracts, the Compliance Tool allows users to selectively “undo” this severance to provide traceability to third parties.

![6.png](https://img.learnblockchain.cn/attachments/2022/09/nAxXHQDa63184e8bc1e71.png)

The Compliance Tool is not a smart contract. However, just like the other software described in this article, the Compliance Tool is also not a service provided by Tornado Cash developers; it is an open-source tool that can be used by anyone.

#### Other Tornado Cash Smart Contracts and Addresses

Finally, two of the sanctioned addresses are donation addresses. These addresses were used in the past to raise money in support of the development of the privacy software that powers Tornado Cash. While some person or entity does control tokens sent to these addresses, those tokens are not, to our knowledge, being mixed or re-routed for privacy purposes. They are merely a gift from the sender in support of software development efforts performed by the recipient. A complete list of donation addresses sanctioned by OFAC can be found in Appendix D.

In general, while a minority of the contracts listed by OFAC do retain elements of human control, none of them are critical to the basic operation of Tornado Cash’s privacy tools, and none of them take control of user tokens. The core privacy tools – the pool contracts – are outside of any individual or group’s control; they are simply widely distributed computer code that is executed by the Ethereum network according to strict and unalterable rules.

## Summary

In summary:

- The Tornado Cash smart contracts allow users to deposit and later withdraw their tokens to another address.
- Even though anyone can observe users deposit or withdraw tokens, they are not able to determine which withdrawals correspond to which deposits.
- These operations are defined as smart contract code and are carried out automatically without any intermediary or third party.
- Users retain control of their funds the whole time, and are only able to withdraw the tokens they originally deposit.
- No one controls the operation of these Tornado Cash smart contracts and no one has the ability to change their operation in the future.
- Some OFAC-identified addresses retain a level of human control. However, these addresses are not core to the operation of the privacy tools found at the immutable addresses and they can not exercise control over any user tokens.

 

