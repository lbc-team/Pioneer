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

默认情况下，智能合约是不可变的，这意味着它们一旦部署就不能被任何人删除或更新。智能合约的开发人员也可以（在合约代码中）支持可更新性（*例如*这个*人为控制*的地址可以在未来重写合约）。但是，此类更新操作必须在部署（*发布到以太坊上*）之前， 就包含在智能合约的代码中。如果在部署时，代码不包含可更新性，那么任何人都无法修改智能合约。开发人员也可以将更新权限转移到没有相应私钥的以太坊地址，从而撤销合约的更新能力。这个特殊的地址被称为“零地址”。一旦更新能力被撤销，它就不能被重新获取，且合约不能再被改变。


与传统金融不同，以太坊的记录是完全透明的：任何人都可以下载和查看其用户账户的余额和交易历史。尽管用户地址是假名的，但如果将真实世界的身份链接到用户地址，就可以追踪该用户的完整财务历史。以太坊的透明度对于可审计性很重要（*例如*验证记录更新是否有效）。然而，这种透明度也让用户难以保护自己的个人信息。默认情况下，今天的偶然交易记录（*例如*在机场支付 Wi-Fi 费用）直接通向早期的交易记录，其中可能包括同一用户很久以前进行的任何私密、泄露或敏感交易。

在智能合约可能支持的许多不同应用中，它们还可以为用户提供一种方法，使得用户在与金融系统交互时重新获得他们期望的隐私。这种隐私的核心是使用智能合约来打破公共链。 否则这些记录会将您今天的交易与您过去进行的每笔交易联系起来。


## 3. Tornado Cash: A smart contract application

Tornado Cash 是一个为以太坊用户提供隐私保护的开源软件项目。与许多此类项目一样，该名称不是指法律实体，而是指由不同的贡献者团体开发多年的几个开源软件库。这些贡献者发布了Tornado Cash。 作为以太坊区块链上的智能合约集合，Tornado Cash是通用的。


正如我们将解释的那样，其中一些智能合约已获得 OFAC 的批准。然而，Tornado Cash 隐私工具的核心构成了 OFAC 批准的地址的一个子集：Tornado Cash“池”。每个 Tornado 现金池都是部署到以太坊的智能合约。与其他智能合约一样，池合约通过特定操作扩展了以太坊的功能，以太坊的任何用户都可以根据 Tornado Cash 合约代码中定义的规则执行特定的操作。

本节将介绍这些池的工作原理。我们将描述使这些池能够自主运行的关键创新：应用了被称为“零知识密码学”的隐私保护数学。

随后的部分将描述 OFAC 批准的具体地址，以及它们的作用。最后的附录将列出所有被批准的合同及其显着特征。

### Tornado Cash Core Contracts: Pools

Tornado Cash池是一组智能合约，用户使用它，就能在以太坊上进行私下交易。当用户调用合约时，池将自动执行“存款”或“取款”。用户因此可以从一个地址存入代币，然后将这些相同的代币提取到不同的地址。至关重要的是，即使这些存款和取款在以太坊上公开发生，存款地址和取款地址之间的任何公开的联系都会被切断。用户因此提取和使用他们的资金，不用担心他们的整个交易历史会被暴露给第三方。

为了支持存款和取款操作，这些智能合约编码了严格的规则。这些规则自动应用于存款和取款操作，以维护所有 Tornado Cash 池都有的一个非常重要的属性：**用户只能提取他们最初存入的特定(数量)的代币。**

此属性会自动在所有池上强制执行，并且该属性确保 Tornado Cash 池完全*非托管*。也就是说，即使操作需要通过池进行， 存入并随后提取代币的用户保持对代币的完全所有权和控制权。在任何时候，用户都不需要将其代币的控制权交给其他人。

Tornado Cash池的一个关键原则是，用户的隐私性在很大程度上来自于许多其他用户同时使用该池。如果池子只有一个用户，那么用户的存款地址和提款地址之间的链接即使被切断，也很明显：简单的推理后，我们就可以清楚地知道提取的代币来自哪里。相反，池被许多用户同时使用。多人使用的池可以想象成是银行的保管箱室。任何人都可以去保管箱房间，选择一个带锁的盒子里存放贵重物品。 假设锁是正常的，那么只有拿着钥匙的人才能取回这些贵重物品。

当然，这么做可能会也可能不会增强隐私。如果只看到一个人进出房间，那么我们就知道那个房间里的任何贵重物品都是他们的。另一方面，如果很多人经常进出房间，那么我们就无法知道谁控制了哪些箱子里的哪些贵重物品。通过保证用户只能提取他们最初存入的代币这一特性，许多用户可以同时使用这些池，并确保没有其他人会拿到他们的代币。

传统上，保证（每个用户只能提取自己的代币）将由 *托管* 服务提供：例如保险箱示例中的银行，或一组在其他常见加密货币安排中运行“混合服务”的人。像 Blender.io 这样的混合服务商，直接从他们的客户那里接受代币，聚合和混合它们，然后将资金返还给他们的客户（通常在这个过程中收取一些费用）。在中间聚合和混合阶段，相关资金完全由混合服务的运营商控制并混合。在混合过程的最后阶段，用户将收到资金， 这些资金直接来自于那些也使用该服务的无数其他用户。

相比之下，Tornado Cash 池没有托管运营商，用户只能提取他们最初存入的代币（而不是来自该服务的其他用户的混合代币）。之所以可能做到这样，是因为使用了一种可以保护隐私的数学工具，“[零知识密码学]（https://en.wikipedia.org/wiki/Zero-knowledge_proof）”。 零知识密码工具被包含在 Tornado Cash 的智能合约代码中，构成了存款和取款功能的基础。


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

 

