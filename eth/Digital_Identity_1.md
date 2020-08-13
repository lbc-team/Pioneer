# Demystifying Digital Identity (1/2)

Identity has been a long-standing challenge not just in decentralized technology but in online applications generally. Part of the challenge comes from a lack of clarity about what is meant by ‘identity’ and the many forms it can take in digital products, services and networks. This is a frequent source of confusion and frustration to builders, leading many to avoid tackling identity altogether or implementing short-term workarounds. Each can have massive consequences, as identity’s importance and complexity grow with both product usage and maturity.

This two-part series helps break down identity for your digital application, service or product, especially for decentralized architectures and an interoperable web. The aim is to make a nebulous topic concrete, a big problem approachable, and a difficult and frothy space easy to analyze.

**Part 1 breaks down the role of identity in digital products.** This includes:
-A clear definition and scope for digital identity
-The value it should bring to your product or service
-What to know about common identity workarounds (including key pairs, on-chain IDs, 0auth logins, and custom solutions)

**Part 2 shares what to demand from your identity infra**. This includes:
-The key standards that it should be built upon
-5 characteristics and capabilities it must support
-A flexible model that fits your stack
- Steps to future-proof your architecture in less than 1 day

Digital identity is a fast evolving space with a deep history of academic and practical contributions (some of which I’ve tried to reference), and so is not always approachable. My view is informed by helping build uPort and 3Box, participating in community standards, and co-authoring a book on the sociology of identity. This series is by no means a complete history or a full view of identity, but I hope it is helpful in making a critical piece of infrastructure easier to understand and build upon.

* * *

# What is Identity?

In the fields of sociology, psychology, and biology there is no accepted definition of *identity.* Academics in each range from strict category sets to fuzzy conceptions. Said famed psychologist Erik Erikson:

> The more one writes about [identity], the more the word becomes a term for something that is as unfathomable as it is all-pervasive.

Erikson would later coin the term “identity crisis.”

The nebulous nature of the definition of identity carries into the digital world. When technologists speak about identity, they may be referring to a wide range of challenges, or a spontaneous subset of challenges that matter to their use case.

![](https://img.learnblockchain.cn/2020/08/13/15972866368750.jpg)
<center>A partial set of discrete problems “identity solutions” may be targeting</center>

The facets of identity outlined in this diagram are not the same and the solutions to each vary greatly, however they are highly related. Understanding how these elements tie together under a common framework is critical to achieving success and can turn identity from a series of isolated pain points into one of the biggest simplifications and value-adds in your product architecture.

Whatever your goals and technical needs for identity, understanding should start at the human level — which is also where we often first go astray. For all of their imperfect definitions and disagreements, scholars nearly universally agree that, contrary to our instincts and vocabulary, ***identity is* *not* static, singular, or individual. Identity *is* dynamic, plural, and social.**

If we wish to build a truly connected, trusted, and usable Web3 that can scale to global usage, we should build on infrastructure that reflects this starting point. As we’ll see, a strong identity is not rigid, constant, and siloed but rather flexible, dynamic, and interoperable.

# The role of identity in your product

If you are building an app (or wallet, service, platform, network), you probably want users. Those users may be mainstream consumers, developers, organizations, and/or DAOs. Whatever user type you are serving, the goal is the same: to have others interact with your product and realize value from it. This means you want to:

* Eliminate friction in signups, authentication, and engagement
* Deliver the richest possible experience, with little extra work
* Focus on your core value-add, without building new or redundant infrastructure in-house
* Build with a simple, elegant user model that can grow with your needs over time

The solution to each of these goals hinges on how you manage users. How do they authenticate (login)? Can they engage with each other (chat/comment)? Can you deliver persistent and personalized experiences across time, devices, logins? Can you easily integrate with the many other products and platforms that users are on?

In traditional web applications this is often broken into Identification (related to account creation, KYC, etc.), Authentication (login, anti-fraud), and Authorization (permissions, sharing). This sequential approach will change with more flexible decentralized models. Identity touches everything that has to do with how you manage, secure, serve and interact with your userbase.

# Identity needs evolve with growth

> *The demands of managing a user base change quickly as your product grows.*

Your biggest “identity” pain point today may be populating your app with basic public **profile** information so users can recognize each other. Next month it may be **storing** **data** for user history and application state, such past or in-process transactions (like a shopping cart). Next quarter it could be basic **KYC**, and next year it could be **anti-sybil** protection. Each of these product requirements addresses a different “identity” problem with differing potential solutions.

* **Profiles:** Should I implement 0auth or an IPFS hash mapped to a key? But what if the user rotates keys or uses more than one key?
* **Data storage:** Should I store data in a Textile ThreadsDB? But how do I allow users to manage access control without adding more key types and friction?
* **KYC/Proof of human:** Should I use a service like Passbase or tech from Democracy Earth? How do I map this proof to existing users?
* **Anti-Sybil**: Should I use a service like BrightID or Idena? Then how do I map their graphs to my user base?

Implementing any of these solutions independently clearly has its own challenges, but your biggest pain point will arise from not using the correct identity infrastructure from the beginning to tie them all together in a future-proof way. A strong and flexible identity infrastructure can make each of these new needs natural extensions of previous ones, rather than new siloed challenges that need to be tackled independently and then later frankensteined together.

# Identity is the infrastructure that lets you effectively tie together any capabilities that relate to your users

Good identity infrastructure should make meeting your evolving user-related needs easy and painless. If you’ve ever used Okta or Rippling, you understand that this is what they try to do for enterprises. They aim to provide a single system of record for users and accounts, however they do this in a defined, limited, and controllable enterprise environment. In a more open and undefined environment — like Web3 — a good identity infrastructure needs to work in a permissionless and limitless context, in a predictable way.

This means your identity infrastructure must be both customizable enough to suit your own needs but flexible enough to work well with many other existing solutions. It should be extensible and interoperable across many different networks, accounts/keys, and use cases. It should work not just with the other tools and services you are using, but the others your users are using and others that you may need in the future. Not only will this make identity management easier, but it will allow each solution to build upon the others creating compounding value. For example, the KYC verification could leverage existing user profile information, and the anti-sybil tool could leverage the existing KYC (and any other) verifications.

Perhaps most importantly, the identity system should operate without reliance on a single organization, platform, or model. The identity infrastructure should be an open and shared protocol, and the identities themselves should be user-managed and self-sovereign.

# The problems of building without proper identity infrastructure

## 🔑 Single key pair identities

In the crypto world today, the default user “identity” tends to be a public blockchain account key. It’s logical why this might be the case: blockchain keys are already needed to manage assets so they’re widely possessed by users, and there are now many great wallets & SDKs for managing them. In reality, keys and the KMS solutions (wallets) to manage these keys are a fantastic way to *authenticate* into an application and execute on-chain transactions, however *single* *key pairs cannot be the user identity infrastructure for any product that wishes to scale to meaningful and persistent usage.*

Problems with using individual key pairs as identity:

* **Compromises privacy**: There is no chance of segregated or private activity, since all transactions by the same ‘identity’ must happen with the same public key.
* **Creates fragility**: When keys are used for signing and/or encrypting data, then all user data and history related to your product is lost when their key is lost or changed/rotated.
* **Creates silos**: Information can be accessed by that specific key only, with no chance of interoperability and composability across wallets and networks. This is counter to the vision of Web3.
* **Adds complexity**: Adding distributed databases and other user technology to your stack is difficult since they operate with different cryptographic identity and access control systems.
* **Foregoes network effects**: You have to bootstrap your own user network, profiles, and data from scratch rather than draw on existing data to easily onboard users and jump past a cold start.

Key pairs and wallets are a core part of the Web3 experience, but they should complement (and integrate tightly with) great identity infrastructure.

## 🔗 On-chain, network-specific identities

The limitations of relying on single key pairs for identities has been well understood in the blockchain ecosystem for years, leading to attempts at both smart contract based identities and network-specific identity standards. uPort pioneered approaches like Ethereum smart-contract based identity in 2016, [social recovery in 2017](/uport/making-uport-smart-contracts-smarter-part-2-introducing-identitymanager-af656ba7441b), and [EIP 1056](https://github.com/ethereum/EIPs/issues/1056) in 2018 (Joel Thorstensson, Pelle Braendgaard). Fabian Vogelsteller authored multiple versions of ERC-725, and many others have attempted to build multi-key identity models for Ethereum or other blockchain networks.

Problems with using on-chain, network-specific identifiers as identity:

* **Compromised privacy**: Using on-chain registries or smart contracts for storing identity information (such as ERC-725 or ERC-1056) is highly likely to compromise user privacy or control. PII should never go onto an immutable network or datastore.
* **Network lock-in**: Requiring creation of different identities for each network you or your users leverage leads to a terrible developer and user UX in a cross-chain world.
* **Technology lock-in**: More time, cost, and complexity to manage as new blockchains, technologies, and user patterns emerge.
* **Limited interoperability:** Inability to easily draw on data or identities from other networks.

While an improvement over using keys, identity standards built for a single network — and reliant on a single blockchain like Ethereum — lock us into new silos and a worse-than-web2 user experience. We are moving to a multi-chain future, with networks like Filecoin, Arweave, Flow, Near, Celo and Solana all coming online and adding value that complements what is being built on Ethereum. A better system needs to separate the identifier (or identity) from any specific network so it can be used with keys from across networks.

## 📩 0auth logins

Some applications may be fine to use centralized services for authentication in the short term. This can ease onboarding UX (especially before improved wallet SDKs). But this approach will not scale for apps that wish to deliver great and full Web3 experiences. Web2 logins are a viable authentication method, but not an identity solution.

Problems with using Oauth services as identity:

* **Backend complexity:** The need to build and maintain user tables to keep track of internal mappings between 0auth tokens, your internal user identity, your users’ blockchain account, and other user information like assets, transactions, and data.
* **Fragmented user data:** No association between the login method and other web3 experiences. This means that developers miss out on access to the open network effects and data history built around users’ keys as usage of other web3 products grows.
* **Reliance on third-party auth:** The authentication capability relies on a middleman service that sits between you and your users, adding both risk and complexity.
* **Expensive and bulky:** Web2 middleman services don’t scale for highly used, lightweight apps; cryptographic authentication is not just more secure, but far more efficient.

Web3 decentralized key management and authentication has come a long way since its early days and can now match 0auth in terms of user onboarding and UX. For great products in this space, c*heck out: Magic, Torus, Metamask, Portis/Shapeshift, Argent, Rainbow, and WalletConnect.*

## ⚒ Custom identity solutions

Recognizing the limitations of existing identity approaches, many applications or platforms have tried to create custom identity solutions that meet their needs. This is understandable and in some cases perceived to be more expedient. However most quickly find that there are reasons why identity has presented a difficult set of challenges not just in Web3, but since the dawn of the internet.

Problems with using custom identity solutions:

* **High risk:** Expensive and critical risks could easily arise by accidentally compromising user privacy, missing security vulnerabilities and fragility (e.g., key revocation), and meeting regulatory requirements (GDPR and right of users to delete data). Wading into this territory without a deep understanding of what has made identity challenging for decades is a big burden to take on. At best it adds massive complexity, and at worst it can permanently compromise the trust of your users and/or developers.
* **Tech fragility:** Custom solutions usually only function for a bespoke, specific, predefined use case. They don’t scale well to other new circumstances within your application, or use cases (and interoperability) beyond your app.
* **Ecosystem exclusion**: Custom solutions lock your users (and their identities) out of future identity-related advances developed by the broader community, such as better recovery options, new authentication providers, new databases, and services. To be easily usable, identity systems must “speak the same language’ in cryptography and schema, and custom solutions usually will not.

A few custom implementations may have been necessary in the interim while good decentralized identity solutions developed, but it’s critical to at least build on the core, lightweight standards that will ensure future-proof, lower risk, and more scalable identity capabilities over time.

# Identity as a unifying advantage

Web3 is a collective movement being built globally, across many different blockchains, distributed databases, and ecosystems. Identity is the most essential piece for interoperability across these various technologies and communities. While smart contract and asset interoperability is convenient, user adoption of Web3 tech depends on a persistent, rich and manageable UX across applications.

A world in which end-users need to juggle many keys and wallets (and keep track of which to use in every scenario) is a world in which users simply do not adopt Web3\. On the other hand, one of the biggest potential competitive advantages that the Web3 movement has over the Web2 status quo is *shared permissionless networks,* which allow developers to collectively build up and build upon existing network effects of users, data, and experiences faster than any siloed Web2 product.

> *Shared networks and network effects is the biggest GTM advantage that Web3 has over Web2\. Shared identity is the key to leveraging that.*

If Web3 identity systems silo users and their data resources by each individual blockchain or application, we are crippling ourselves since the movement becomes a collection of parts not the sum of them. Each of our products becomes locked into a smaller, less powerful, less attractive market and capability set.

Interoperable identity will let users move seamlessly across networks with all of their information, reputation, claims, data, and identity, and will let developers build not just with composable assets but with composable networks, users, and data, and services.

The key to making this a reality is a basic, shared, flexible identity standard that works on any stack, gives it new capabilities, and connects it to a growing ecosystem of others doing the same.

* * *

**Part two of the Demystifying Digital Identity series outlines the requirements of a successful identity standard, explores existing work, and helps you get started building.**

***CONTINUE READING:* **[*PART 2: ELEMENTS OF A GREAT IDENTITY SYSTEM*](/@dannyzuckerman/demystifying-digital-identity-2-75dd7dfee2f2)

原文链接：https://medium.com/3box/demystifying-digital-id-6ec413b129ac  作者：[Danny Zuckerman](https://medium.com/@dannyzuckerman)




