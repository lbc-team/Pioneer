
# Ethereum's Maximum Contract Size Limit is Solved with the Diamond Standard

Ethereum contracts with too many functions and too much code will hit the maximum contract size limit of 24KB. For some kinds of contracts this is a real problem.

Some contract standards require many functions. For example [ERC1400 Security Token Standard](https://github.com/ethereum/eips/issues/1411) requires 27 functions and 13 events. [ERC-998 Composable Non-Fungible Token Standard](https://eips.ethereum.org/EIPS/eip-998) specifies 31 functions. With additional application specific code contracts that implement these standards can easily exceed the 24KB limit.

Even without implementing large standards some developers will want to develop large contracts in order to keep related code together under the same Ethereum address. Also it is easier and more flexible to access and modify contract storage if state and functions are kept together under the same Ethereum address.

### [](#what-to-do-about-it)What to do about it?

A [proposal](https://ethereum-magicians.org/t/removing-or-increasing-the-contract-size-limit/3045) was made to increase or remove the maximum contract size. But [Vitalik Buterin](https://twitter.com/VitalikButerin) opposed it for technical reasons and defended using "proxy contracts" and "delegatecall". Proxy contracts are contracts that can stay small by borrowing functions from other contracts using a low level operation called "delegatecall".

I think it is a good idea to standardize how to do this. How to create proxy contracts that simulate large contracts that can exceed the 24kb contract size limit.

That's why I created the [Diamond Standard](https://github.com/ethereum/EIPs/issues/2535), which does that. It standardizes how you can create a small contract that can utilize the code of any number of other contracts as if it is its own code.

A contract that implements the Diamond Standard is called a diamond. The "diamond" term is used to differentiate diamonds from regular contracts and proxy contracts that can only borrow code from a single contract. In addition the term "diamond" is used to conceptualize how a diamond works.

A real diamond has different sides called facets. It can be conceived that a diamond on Ethereum also has different sides. Each contract that a diamond borrows functions from is a different side or "facet".

The Diamond Standard extends the analogy to its "diamondCut" function which is used to add, replace, or remove facets and functions. This is analogous with giving a real diamond new facets by literally cutting it.

In addition the Diamond Standard provides 4 functions called "The Loupe" that return information about what facets and functions exist in a diamond. In the diamond industry a "loupe" is a small magnifying glass that is used to inspect diamonds.

The new terminology defined in the Diamond Standard is consistent with the analogy of real diamonds. This serves to define and differentiate diamonds from other kinds of contracts. Unfortunately the new terminology can be a barrier for some people learning the standard. But the new terminology is small and we have covered the new terminology in this article. The terms are: diamond, diamondCut, facet and loupe.

I recently wrote a more in depth article about diamonds which includes how to get started making one: [Understanding Diamonds on Ethereum](https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb)

I would be remiss if I didn't mention that the Diamond Standard includes a flexible and transparent method of creating upgradeable diamonds. Making diamonds upgradeable is optional but some people may want to create diamonds for that functionality.

### [](#the-diamond-standard-is-gaining-traction)The Diamond Standard is Gaining Traction

Last month [ConsenSys Diligence](https://diligence.consensys.net) conducted a public security audit of [Codefi's](https://codefi.consensys.net/) contracts. Consensys Diligence [recommended or suggested](https://diligence.consensys.net/audits/2020/06/codefi-erc1400-assessment/#diamond-standard) that Codefi use the Diamond Standard to solve the maximum contract size limit problem.

ERC-1155 Multi Token Standard [mentions](https://eips.ethereum.org/EIPS/eip-1155#upgrades) the Diamond Standard (EIP-2535) for upgrading contracts.

A number of individuals and companies have contacted me and told me they are using diamonds or are implementing diamonds for their systems. Here is some information from some of them who have publicly written about it:

[VolleyFire](http://joeyzacherl.com/2018/10/volleyfire-liquidity-provider-for-decentralized-exchanges/), a liquidity provider for decentralized exchanges is using diamonds.

Joey Zacherl, a developer at VolleyFire, released a Python tool called [Diamond Setter](https://github.com/lampshade9909/DiamondSetter) that is a contract manager for diamonds. Here is his blog post about it: [Diamond Setter, Ethereum smart contract manager](http://joeyzacherl.com/2020/06/diamond-setter-ethereum-smart-contract-manager/)

Ronan Sandford ([wighawag](https://twitter.com/wighawag)), a prominent smart contract developer and an author of the ERC-1155 standard, [announced](https://twitter.com/wighawag/status/1280992800545349644) he is working on adding support for diamonds to [buidler-deploy](https://github.com/wighawag/buidler-deploy#readme) to make it very easy to deploy/cut diamonds. buidler-deploy is a mechanism to deploy contracts to any network, keeping track of them and replicating the same environment for testing.

[Nayms](https://nayms.io/) is using diamonds in production. [Ram](https://twitter.com/hiddentao) wrote a blog post about their implementation: [Upgradeable smart contracts using the Diamond Standard](https://hiddentao.com/archives/2020/05/28/upgradeable-smart-contracts-using-diamond-standard)

The Diamond Standard got its first [popular Reddit post](https://www.reddit.com/r/ethereum/comments/gze6k3/a_diamond_is_a_set_of_contracts_that_can_access/).

If you want to learn more about diamonds read this article: [Understanding Diamonds on Ethereum](https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb).

### [](#join-the-discussion)Join the Discussion

I recently created a [Discord server](https://discord.gg/kQewPw2) for discussing diamonds and the Diamond Standard.

原文链接：https://dev.to/mudgen/ethereum-s-maximum-contract-size-limit-is-solved-with-the-diamond-standard-2189 作者：[Nick Mudge](https://dev.to/mudgen)