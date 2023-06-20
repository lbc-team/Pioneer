# rhinestone architecture

# Introduction

After many attempts to bring about smart accounts on Ethereum (incl. EIPs 2938, 3074 and 5003), we finally have ERC-4337 which standardises Account Abstraction via an alternative mempool without requiring protocol-level changes. Without going into too much detail about how ERC-4337 works (there are great explanations out there already), it has very loose requirements for the implementation of smart accounts. More specifically, the ERC only requires the smart account to have a function to validate a UserOperation and some way of executing that operation.

While this broad approach allows for a great deal of flexibility on the developer side, it also generates some challenges for both users and developers, which we will examine below. In order to tackle these challenges, we are working on a more opinionated implementation standard that builds on top of ERC-4337 and aims to standardise one aspect of smart account implementations: upgradeability. This paper explains the rationale behind creating this standard and the high-level architecture. As we have previously demonstrated a proof of concept for the modular smart account contracts, the focus of this paper is to explain the third required component of the standard we propose: the module registry.

# Challenges

### Developer understanding

Currently, the barriers to building a smart account are high. The code created by the ERC-4337 team in the [eth-infinitism repo](https://github.com/eth-infinitism/account-abstraction/) allows developers to have a base implementation to build on top of. But in order to build a smart account that has basic feature parity with existing smart accounts, they also need to build several standard features, such as recovery or session keys. On top of this, new developers need to gain a good understanding of the ERC-4337 infrastructure, such as how to send UserOperations to a bundler or how to integrate a paymaster into the transaction flow. These frictions will lead to less smart accounts being built than there could be and, more detrimentally, less developer time being spent on building novel features for smart accounts. Hence, the smart account landscape today looks very homogeneous, with a few common features that are shared between practically every smart account, but built from scratch over and over again.

### Security guarantees

When developers build novel smart account features they are still faced with costly smart contract audits, in which a large chunk of the auditor’s time may still be spent revisiting already deployed and audited code. And even after these costly audits, it’s possible that adoption is slow due to a lack of perceived security or reputational security. Incumbents already have a reputation for security derived from their existence over a long time, making it difficult for new players to forge their own path. These two factors (cost and lack of reputation) can disincentivise experimentation and slow innovation within the smart account space.

Another challenge with smart accounts today is secure upgradeability without unintended side effects. So far, a common way to handle upgradeability for smart accounts is to deploy them as proxy contracts. However, as [Yoav demonstrated](https://ethereum-magicians.org/t/erc-4337-account-abstraction-via-entry-point-contract-specification/7160/55) in the case of using a SafeProxy, a malicious agent could upgrade a smart account in a way that causes storage to break, in this case, leaving shadow signers of the multi-sig behind.

### Customization and vendor lock-in

Finally, users face a lack of feature customization and vendor lock-in. The former means that users’ exact preferences are often not directly met by smart account providers, who focus on building accounts with features that appeal to a broad audience. Even if a new smart account provider releases new features, users might be slow or deterred from switching due to the lack of compatibility between the different providers. This vendor lock-in entails high switching costs and thus even less demand for new smart account providers, especially when the improvement is gradual.

Together, these challenges paint the picture of a smart account ecosystem in which building novel features becomes ever costlier, as the set of “standard” features increases, and in which experimentation is further disincentivised as smart account switching costs rise and providers can build a moat around their security reputation.

# rhinestone

In order to solve the challenges raised above, we are working on a more opinionated implementation standard built on top of ERC-4337. It will aim to standardise the upgradeability of smart accounts in a way that makes them modular. This new standard aims to create a smart account ecosystem where the incentive to experiment and build novel features are high due to: 1) new tooling that speeds up development and security auditing processes and 2) significantly reduced friction for users to integrate these new features into their existing account.

This standard consists of three parts, the modular smart account implementation, feature modules for these smart accounts and a registry that regulates the addition and removal of modules from smart account.

![rhinestone architecture](https://img.learnblockchain.cn/attachments/2023/06/rfrlP81h64883a7048928.png)

rhinestone architecture

### Modular smart account implementation

To modularise an ERC-4337-compliant smart account, we have chosen to implement it by drawing inspiration from the Diamond Proxy Pattern (ERC-2535). This proxy pattern allows us to split the smart account into a contract that holds state and the code which remains unaltered through upgrades and an arbitrary number of stateless modules (called facets in ERC-2535) that only need to be deployed once. The stateful smart account holds a list of active modules in storage and is able to call these depending on when this is required. We are currently working on security testing and gas optimising this modular implementation and will be sharing more details once we are confident in the initial architecture of the modular implementation. A first proof of concept of this architecture can be found [here](https://github.com/kopy-kat/ethdenver-aa/tree/main/rhinestone-contracts), although these contracts should not be used in production.

### Modules

Modules are stateless smart contracts that only need to be deployed once but can be used simultaneously by an arbitrary amount of clients (smart accounts in this case). In this architecture, modules are mostly self-contained features, that are called depending on their categorisation. For example, some features concern validating a UserOperation, for example by using a novel cryptographic primitive, and will be called by the validation function on the smart account. In order for users to add or remove modules from their accounts, they simply need to call the respective function on their account without needing to redeploy an entirely new contract. Modules can also encompass security guards, instead of features, that allow the user to granularly define how modules can interact with the smart account. The implementation of modules is largely left up to the developer and for registries to decide, but we will be publishing a loose set of requirements that modules need to meet.

### Registry

Injecting arbitrary code (housed in modules) into a smart account obviously carries major security risks. Examples of harmful actions are storage overwrites, selfdestructing the account or simply draining the assets of the account. In order to make an ecosystem in which potentially adverse actors can deploy modules viable from a security perspective, this ecosystem needs to be regulated by some entity. Therefore, we propose a third party that facilitates the integration of modules into the smart account: the registry.

The aim of the registry is to operate a whitelist of modules that a user is allowed to add to their smart account. Apart from mandating this function, the specification for these registries will be intentionally very loose, in order to future-proof registries to adequately deal with both novel attack vectors and new feature opportunities that may arise from protocol-level changes in the future. Further, in order to ensure decentralisation, incentivise competition and give the user maximum choice, users are able to easily change which registry their smart accounts use. We envision an ecosystem in which there are multiple different smart account registries with different opinions on security considerations, decentralisation and incentive models. The important aspect is that users are able to freely and cheaply switch between these registries by simply changing a state variable in their smart accounts. Different registries may be governed by different sets of parties, from DAOs that vote on new modules to be added, to individuals or businesses that operate a registry. 

# Conclusion

In this paper we propose the high level architecture for a modular implementation of ERC-4337 compliant accounts. These accounts are modularised with inspiration drawn from ERC-2535, allowing the creation of an ecosystem in which developers build modules that users can add to or remove from their smart accounts. In order to facilitate the interaction between modules and smart accounts in a secure way, we propose the creation of registries, which essentially operate a whitelist of recognized modules. Users can switch between specific registries based on their desired security guarantees.



原文链接：https://mirror.xyz/konradkopp.eth/V6WjJzDGWfQeTIytmmFAVlug0_yC-W3BM6Q46SlvWGY