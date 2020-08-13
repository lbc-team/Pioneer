
# Demystifying Digital Identity (2/2)

*This is part two of a two-part series that helps break down identity for your digital application, service or product, especially for decentralized architectures and an interoperable web. The aim is to make a nebulous topic concrete, a big problem approachable, and a difficult and frothy space easy to analyze.*

[*Part 1*](/@dannyzuckerman/demystifying-digital-id-6ec413b129ac) *broke down the role of identity in digital products. We covered a social and technological definition for identity, the value it should bring to your product, and the pitfalls of incomplete identity solutions.*

* * *

# A powerful and flexible identity standard

Good identity infrastructure should make it easy for you to manage all of the user-related capabilities in your product, service, or ecosystem. Common workarounds (outlined in Part 1) usually fail at this. Frequently they don’t preserve privacy. Usually they are too fragile to accommodate additions or changes. And even the best implementations don’t have the proper underpinnings to support the interoperability needed to easily extend to new capabilities and use cases over time. A good identity infrastructure should work simply today and adapt easily to future product needs and opportunities.

![](https://img.learnblockchain.cn/2020/08/13/15972883181707.jpg)

A common standard for digital identity can provide a simple and vetted solution for an extremely wide range of identity-related requirements, guarantee resilience and trust, and unlock powerful interoperability and opportunity. It can give any application the ability to manage users in the way they need, while ‘speaking the same language’ as other applications, services and networks that they may want to leverage or serve in the future.

**This post shares a positive and concrete outline of:**
1\. The minimum requirement for interoperable identity: DIDs
2\. The 5 capabilities needed for a powerful identity system
3\. A flexible graph model for identity infrastructure
4\. Practical implementations, including easy steps you can take now

# The starting standard for identity

An identity system ties many related capabilities together. These anchor around *identifiers* for users and other entities that interact with your application or network. A standard model for these identifiers ensures that users, data, capabilities, and applications can work together even if they have different starting conditions or implementations. This decentralized standard is the necessary precondition to a flexible identity system.

## DIDs: the minimum requirement for interoperability

The [DID spec](https://www.w3.org/TR/did-core/) from the W3C is the widely-accepted standard for decentralized identifiers. It ensures identity systems can interoperate across many different networks and contexts. DIDs provide a common format for a globally-unique identifier that is an abstraction from any single key pair.

```
// Example of a 3ID DID methoddid:3:bafyreib5c5gwpwzxl4pcrl7qw4j6lvgg7ug4zdflnhg2eqvuiw7kv7fng4
```

Therefore unlike key pairs, DIDs can:

* Support multiple keys;
* Maintain identity persistence as keys are added, removed, or rotated;
* Resolve and communicate across various networks; and
* Control a DID document that expresses metadata, service endpoints, or other related information about the DID.

The DID spec was originally created by Respect Network (later acquired by Evernym) and presented at the Rebooting Web of Trust conference. It later moved to the [Decentralized Identity Foundation](https://identity.foundation/) (DIF), which was founded by uPort, Microsoft, Sovrin, Blockstack and many other companies with deep knowledge of identity and Web3\. These organizations had differing needs and approaches but were all committed to the vision of a shared and interoperable model for self-sovereign identity. The DID spec was created to ensure efforts complemented each other and any application using DIDs had access to the whole ecosystem of users and capabilities, and nobody was locked into a single siloed approach.

Any product, service, or platform with ambitions to build a true user base and a desire to participate in and benefit from the global Web3 movement should be using DIDs. DIDs are the necessary minimum identity requirement for any application, service, or platform that wishes to serve users in any way beyond impersonal, on-chain buy/sell/transfer transactions. There are many implementations that are easy to implement.

## DIDs alone are insufficient

Using a DID for identity means you can have interoperability in the future. It is the basic piece that should be built-in from the start. However, simply using DIDs does not give you cross-network interoperability or access to the full suite of user management and identity-related tools and patterns that are emerging and that will continue to emerge.

DIDs serve as the unique identifier for users and come with a bare minimum of information and capabilities required to be resilient, persistent, and interoperable. But this is not enough as many other capabilities and features used in your application may have their own “identity” needs beyond a basic user ID. For example:

* Databases with cryptographic access control need their own keys and key management
* DAOs and organizations need permissions delegation and membership links in a different way than users
* Different wallets, notification services, and verification services will have their own designs
* Users will bring various linked accounts, asset types, and preferences

![](https://img.learnblockchain.cn/2020/08/13/15972884996164.jpg)
<center>Conceptual representation of what a DID provides</center>

With a good decentralized identity system, all of these permutations should fit together seamlessly. Aggregating user management related features around the user’s identity turns an identity into the single API for the entire suite of user functionality. Each feature simply plugs in as a module that speaks to the others.

For example, you don’t want to tie together user IDs, notification services, profile data, and cryptographic accounts one by one, the way that user tables and one-off integrations are managed today. With this approach, time and complexity grows rapidly — as new capabilities grow linearly, integrations and mappings to manage grows geometrically (Metcalfe’s Law). Instead, you want to have each new feature or capability tie to a user’s DID, making it easy to upgrade, replace or configure as you go.

# The blueprint for a complete identity standard

DIDs form the basis for globally usable and interoperable *identifiers* but a true identity system and infrastructure must do much more than that.

> *A complete identity system builds upon the starting point of DIDs to make identity the easy, simple, and flexible integration point for all of an application’s user-related functionality.*

A practical and seamless identity system should give any DID the power to manage, route to, and control a flexible and powerful graph of information and services about the user — regardless of where the information was initially generated and where it’s currently stored or hosted. And it should do this with basically no action required by the user and very little effort required by developers.

## Five important properties of an interoperable identity standard

To provide the true promise of decentralized identity infrastructure, and do it in a practical way that meets you as a developer where you are, 5 core elements beyond DIDs and proprietary identity systems are needed:

***1\. Flexible, standard, DID-agnostic model (many networks → one identity)***

Identity is much more than just DIDs. The promise of DIDs was to eliminate identity provider lock-in, however most DID-based identity systems are opinionated and require that users use their specific DID method. A strong identity infrastructure provides a complete identity-based capability model that is DID-agnostic, flexible, permissionless, and works across the worldwide web. This lets it support users, organizations, IoT devices, and almost any use case wherever they come from in the future.

***2\. Chain-agnostic, multi-key authentication (many keys → one identity)***

For DIDs and their associated information to be interoperable across networks, wallets, and applications, they need to support a flexible multi-key authentication system that supports any key pair. A keychain model provides cross-chain interoperability while also adding resilience to the DID since the only way a user could lose control of a DID is if they simultaneously lose control of all their wallet keys at the same time.

***3\. Shared account metadata (e.g., portable profile and reputation)***

For DIDs to be usable in the context of applications, they need to support the storage of various kinds of public account metadata such as profiles, social connections, or verifiable claims. Identity infrastructure should provide a standard framework for storing this kind of information, which can also be extended to support any other kind of account metadata.

It encourages standardization where useful to all, but does not force it where diversity is needed; and it makes extensions, branches and versions easily discoverable and linkable.

***4\. User-centric routing to external resources (e.g., rich data ecosystem)***

A majority of data belonging to a DID is *not* account metadata, rather it’s the data generated as a user interacts with an application which may be stored anywhere on the internet, from servers to blockchains. This can be basic browsing data, user data, content, credentials about the user, reputation claims, or other game- or platform-specific data. This information is an important part of an identity, and in order for this data to be usable across applications, it needs to be associated to the DID to be discoverable by any application, regardless of where it exists and how it is stored.

**5\. O*n-chain account mappings (e.g., NFT or contract ownership)***

Since most decentralized applications built on blockchains currently require users to interact with their application using a key pair account that lives on that specific chain, applications need a way to lookup a user’s blockchain account and resolve it to a DID. This allows the application to query public metadata about the user’s account, which is actually associated with a DID. Account links should provide these on-chain to DID mappings that can work for accounts or contracts that live on *any* blockchain or network.

## A dynamic and interoperable identity graph

Together, these five capabilities call for infrastructure that lets applications, services, networks and users flexibly tie new identity-related information together. Rather than a single monolithic solution, what’s needed is reliable and distributed middleware for user-centric linking and routing of resources.

This is best achieved through a set of linked documents that together represent a complete identity as a graph of information. A graph that is globally available, distributed, censorship-resistant, and permissionless for any app, service or user.

![](https://img.learnblockchain.cn/2020/08/13/15972905943603.jpg)

<center>Diagram of [Ceramic’s Identity Standard](https://github.com/ceramicnetwork/CIP/issues/3) that supports any DID, network, auth keys, claims, profile and account metadata, and off-chain sources.</center>


This graph extends any DID with a standard yet flexible account model, portable metadata storage, multi-key and privacy preserving authentication, and links to external resources located anywhere on the internet. It gives DIDs the ability to link to external resources such as application data and trusted services such as notifications or backup, offering a simple user-centric routing system for all kinds of resources related to an identity. The same system can be used to manage access controls, privacy policies, or preferences related to these off-chain resources.

> With a flexible identity graph, users have the power to manage their identity and data with control and privacy, and apps have the power to tap into a rich ecosystem of identity data and capabilities without compromising their needs or stack.

This identity infrastructure paves the way to an ecosystem of linked and interoperable services and data. Identity infrastructure can make users, social graphs and services composable in the same way that blockchains make assets composable, and help Web3 products grow faster and easier together.

# Get started building with decentralized identity

## Implementations of interoperable identity

This identity model is being actively used by the Web3 community today. More and more projects are using DIDs (3ID, EthrDID, Ion), ensuring the most basic foundations of user-control and interoperability are met. A limited version of the linked graph model that extends DIDs with complete identity capabilities is in widespread use in the Ethereum ecosystem, via [3Box](http://3box.io). More than 700 apps and 22,000 users have decentralized identity, profiles and linked databases so far.

[Ceramic Network](https://github.com/ceramicnetwork/ceramic/blob/master/OVERVIEW.md) is being built to extend this DID-based identity graph capability to any network, key type, DID, resource type, or implementation. Ceramic is a permissionless network for storing verifiable, mutable, linked documents that is perfect for this graph of identity information. The [identity routing protocol (IRP)](https://github.com/ceramicnetwork/CIP/issues/3) is the first graph standard being built on Ceramic, with a testnet live now and a full implementation this fall.

Along with 3Box, many of the best projects in Web3 are contributing to make sure the IRP standard scales to their use case, goals and requirements. This includes wallets like Metamask and Magic, blockchains like Arweave and Filecoin, databases like OrbitDB, Sia and Textile, and communities and applications from across the space.

We’re adding new projects and perspectives every week, and would love to include yours. Real world identity is not static or rigid; it is dynamic, rich and full of many perspectives. Digital identity should be too.

![](https://img.learnblockchain.cn/2020/08/13/15972897669220.jpg)

## Get started today

You don’t have to make big changes all at once. There are simple steps you can take to ensure you are building on a strong identity foundation and are set to have identity be an advantage rather than pain-point as you grow.

* **Build DIDs into your application**, which takes at most ~1 day. You can use [3ID from 3Box](https://docs.3box.io/build/wallets), a lightweight IPFS-based DID that will be natively built into Ceramic.
* **Join us in the** [**Ceramic discord**](https://discord.gg/DM4BS98) to share your use case, give input to help shape the network and standards, or ask any questions you have. Or [join our mailing list](http://eepurl.com/gUDk-X).
* **Share or** [**discuss on twitter**](https://twitter.com/dazuck/status/1274020250896355329)with the global Web3 builder community. Our Web3 ecosystem will grow best if work together, and that starts with a solid foundation for interoperability.


原文链接：https://medium.com/3box/demystifying-digital-identity-2-75dd7dfee2f2  作者：https://medium.com/@dannyzuckerman






