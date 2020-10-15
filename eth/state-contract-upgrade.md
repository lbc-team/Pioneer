# The State of Smart Contract Upgrades

> * 原文链接：https://blog.openzeppelin.com/the-state-of-smart-contract-upgrades/  作者：[Santiago Palladino](https://blog.openzeppelin.com/author/palla/)> 
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[]()

![](https://img.learnblockchain.cn/2020/10/15/16027241822179.png)

**Report by Santiago Palladino, Lead Developer at OpenZeppelin **

A survey of the different Ethereum smart contract upgrade patterns and strategies from a technical viewpoint, plus a set of good practices and recommendations for upgrades management and governance.

### Contents

* [Upgrades Alternatives](#upgrades-alternatives)
    * [Parameters Configuration](#parameters-configuration)
    * [Contracts Registry](#contracts-registry)
    * [Strategy Pattern](#strategy-pattern)
    * [Pluggable Modules](#pluggable-modules)
* [Upgrade Patterns](#upgrade-patterns)
    * [Delegate Calls](#delegate-calls)
    * [Proxies and Implementations](#proxies-and-implementations)
    * [Upgrade Management Functions](#upgrade-management-functions)
    * [Selector Clashes and Transparent Proxies](#transparent-proxies)
    * [Universal upgradeable proxies](#universal-upgradeable-proxies)
    * [Proxy Storage Clashes and Unstructured Storage](#unstructured-storage)
    * [Storage Layout Compatibility with Append-Only and Eternal Storage](#eternal-storage)
    * [Implementation Contract Limitations and Initializers](#implementation-contract-limitations)
    * [Multiple Implementation Contracts with Diamonds](#diamonds)
    * [Simultaneous Upgrades with Beacons](#beacons)
    * [Non Upgradeable Proxies with EIP1167](#minimal-proxies)
    * [Abusing CREATE2 with Metamorphic Contracts](#metamorphic-contracts)
* [Upgrades Governance](#upgrades-governance)
    * [Externally Owned Accounts](#externally-owned-accounts)
    * [Multi-sig](#multi-sig)
    * [Timelocks](#timelocks)
    * [Pausable](#pausable)
    * [Escape Hatches](#escape-hatches)
    * [Commit-Reveal Upgrades](#commit-reveal-upgrades)
    * [Voting](#voting)
* [Conclusion](#conclusion)
* [References](#references)

## What is a Smart Contract Upgrade?

Smart contract upgrades are not a new concept for Ethereum developers. One of the oldest upgrade patterns can be traced back to a [gist by Nick Johnson](https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f) from May 2016 – 4 years ago at the time of this post, which is an eternity for a blockchain that is [5 years old](https://blog.ethereum.org/2020/07/30/ethereum-turns-5/).

Since then, there has been a lot of work and different implementations for smart contract upgrades. Upgrades have been used both as a safeguard for implementing a fix in the event of a vulnerability, as well as a means to iteratively develop a system by progressively adding new features.

However, there has also been a great deal of controversy around smart contract upgrades, due to the technical complexities they introduce and the fact that they can be a threat for true decentralization. In this post, we will cover both of these concerns. We will go through different upgrade implementations, reviewing some successful examples in the wild, and discuss the pros and cons of each of them. Then we will review some good practices for governance and management to mitigate the centralization risk of adding an upgrade option to a system.

Let’s start by defining what we mean by a smart contract upgrade:

> **What is a smart contract upgrade?**
> A smart contract upgrade is an action that can arbitrarily change the code executed in an address while preserving storage and balance.*

But before we go in-depth into upgrades, we will cover some strategies for altering a system without having to implement a full-blown upgrade, which can act as a simple complement to upgrades. Brace yourselves, for this is going to be a long post.

## Upgrades Alternatives

There are many strategies for modifying a system without requiring a full upgrade. An easy solution is to change the system through a migration: deploying a new set of contracts, copying the necessary state from the old contracts to the new one (which can sometimes be done trustlessly), and simply having the community start interacting with the new contracts by social convention.

The upgrade strategies listed in this section can be used to modify the system in predictable ways, unlike upgrades which are able to introduce new code with very few limitations. This allows for simpler controls to manage them, and a more predictable behaviour of the system in the face of a change. Let’s go into some of these strategies.

### Parameters Configuration

An option so trivial that I was doubtful to include it in this list is simply tuning a set of parameters in your contracts. A good example of this is [MakerDAO’s stability fee](https://cdp.makerdao.com/help/what-is-the-stability-fee), which is a numeric value injected in a contract that changes the behaviour of the system. This value is changed frequently, and the operation can be carried out with confidence since its implications are clear.

However, it’s important to understand how the system reacts to extreme values set in these parameters. Arbitrarily high or zero fees can drive a system to a halt, or even allow an attacker to steal all funds. It is often a good idea to hardcode in the contract a range of reasonable values for its parameters as a safeguard.

### Contracts Registry

Systems composed of multiple contracts may rely on a central contracts registry. Whenever contract A needs to interact with B, it first queries the registry to obtain the address of B. By having a mutable registry, an admin can just replace B with an alternative implementation B’, changing its behaviour. Early versions of [AAVE](https://github.com/aave/aave-protocol/blob/c6ac5919b04968147985ecd6e783063f740a979a/contracts/configuration/LendingPoolAddressesProvider.sol) used this pattern.

However, this mechanism does not preserve the state of B when switching to B’, which can be an issue if a manual migration is needed. Some versions of this pattern mitigate this by decoupling logic and storage contracts: state is kept in a contract that is left unchanged, and can only be modified by a contract with the business logic that can be changed as needed. We will go deeper into logic and storage separation later in this article.

Another drawback of this pattern is that it also introduces additional complexity for external clients who would also need to call into the registry before interacting with the system. This can be mitigated by adding an external facade with an immutable interface, which takes care of managing the registry lookup.

### Strategy Pattern

The good old [strategy pattern](https://en.wikipedia.org/wiki/Strategy_pattern) is an easy way for changing part of the code in a contract responsible for a specific feature. Instead of implementing a function in your contract to take care of a specific task, you call into a separate contract to take care of that – and by switching implementations of that contract, you can effectively switch between different *strategies*.

A good example of this is Compound, which has different [RateModel implementations](https://github.com/compound-finance/compound-protocol/blob/v2.3/contracts/InterestRateModel.sol) for calculating the interest rate, and its CToken contract [can switch between them](https://github.com/compound-finance/compound-protocol/blob/bcf0bc7b00e289f9b661a0ae934626e018188040/contracts/CToken.sol#L1358-L1366). This allows to easily roll out fixes or gas improvements on the rate calculation, knowing that the change is limited to that specific part of the system. Of course, a malicious rate model implementation could be set to always revert and halt the system, or provide an arbitrarily high interest rate to a specific account. Still, limiting the scope of changes in the system makes it easier to reason about them.

### Pluggable Modules

A more complex variant of the strategy pattern is that of pluggable modules, where each module can add new features to the contract. In this model, the main contract provides a set of core immutable features, and allows new modules to be registered. These modules add new functions to be called to the core contract. This pattern is most common in wallets, such as [Gnosis Safe](https://github.com/gnosis/safe-contracts/blob/v1.1.1/contracts/base/ModuleManager.sol#L35-L46) or [InstaDapp](https://github.com/InstaDApp/dsa-contracts/blob/master/contracts/account.sol). Users can choose to add new modules to their own wallets, and then each call into the wallet contract requests a specific function from a specific module to be executed.

Keep in mind that this pattern requires that the core contract is bug-free. Any errors on module management itself cannot be patched by adding new modules in this scheme. Also, depending on the implementation, new modules may have the right to run any code on behalf of the core contract via the use of DELEGATECALLs (explained below), so they should be carefully reviewed as well.

## Upgrade Patterns

After that not-so-brief introduction, it’s time to go into actual contract upgrade patterns. Most of these patterns depend on an EVM primitive, the DELEGATECALL opcode, so let’s start with a brief overview of how it works.

### Delegate Calls

In a regular [CALL](https://solidity.readthedocs.io/en/latest/introduction-to-smart-contracts.html#message-calls) from a contract A to a contract B, contract A sends a data payload to B. Contract B executes its code in response to this payload, potentially reading or writing from its own storage, and returns a response to A. While B executes its code, it can access information on the call itself, such as the `msg.sender`, which is set to A.

However, on a [DELEGATECALL](https://solidity.readthedocs.io/en/latest/introduction-to-smart-contracts.html#delegatecall-callcode-and-libraries), while the code executed is that of contract B, *execution happens in the context of contract A*. This means that any reads or writes to storage affect the storage of A, not B. Also, `msg.sender` is set to the address who had called A in the first place. All in all, this opcode allows a contract to execute code from another contract as if it were calling an internal function. This is what powers [Solidity external libraries](https://solidity.readthedocs.io/en/latest/contracts.html#libraries) under the hood.

*For more info on how DELEGATECALL works, check out this [Ethernaut level walkthrough](https://medium.com/coinmonks/ethernaut-lvl-6-walkthrough-how-to-abuse-the-delicate-delegatecall-466b26c429e4) by [Nicole Zhu](https://twitter.com/nczhu) that deals with delegation, the [Ethereum in-depth guide](https://blog.openzeppelin.com/ethereum-in-depth-part-1-968981e6f833/) by [Facundo Spagnuolo](https://twitter.com/facuspagnuolo), or the [Upgrades guide](https://docs.openzeppelin.com/learn/upgrading-smart-contracts#how-upgrades-work) from the OpenZeppelin documentation.*

### Proxies and Implementations

Delegate calls open the door to the [proxy pattern](https://eips.ethereum.org/EIPS/eip-897) and its many variants, first popularized in ZeppelinOS and AragonOS. I strongly recommend [this post](https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201) by Gnosis’ [Alan Lu](https://github.com/cag) if you want to go in-depth on delegate proxy contracts technical details.

At its most basic level, this pattern relies on a proxy contract and an implementation contract (also called logic contract, or delegate target). The proxy knows the implementation contract address, and [delegates all calls](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/proxy/Proxy.sol#L21-L41) it receives to it.

```
// Sample code, do not use in production!
contract Proxy {
    address implementation;
    fallback() external payable {
        return implementation.delegatecall.value(msg.value)(msg.data);
    }
}
```

Since the proxy uses a delegate call into the implementation, it is as if it were running the implementation’s code as its own. It modifies its own storage and balance, and preserves the original `msg.sender` of the call. Users always interact with the proxy, and are oblivious to the backing implementation contract.

![](https://img.learnblockchain.cn/2020/10/15/16027243505418.png)

Executing an upgrade is then straightforward. By changing the implementation address in the proxy, it is possible to change the code run upon every call to it, while the address the user interacts with is always the same. State is also preserved, since it is kept in the proxy’s storage, and not on that of the implementation contract.

![](https://img.learnblockchain.cn/2020/10/15/16027243710030.png)


This pattern has another advantage: a single implementation contract can serve multiple proxies. Since storage is kept in each proxy, the implementation contract is only used for its code. Each user can deploy their own proxy, and point to the same immutable implementation.

![](https://img.learnblockchain.cn/2020/10/15/16027243910345.png)

However, there is a piece missing: we need to define how the upgrade logic is implemented. And this decision opens up the door to different proxy variants.

### Upgrade Management Functions

Upgrading the contract is usually handled by a function that modifies the implementation contract. In some variants of the pattern, this function is coded into the Proxy directly, and restricted to be called only by an administrator.

```
// Sample code, do not use in production!
contract AdminUpgradeableProxy {
    address implementation;
    address admin;
    fallback() external payable {
        implementation.delegatecall.value(msg.value)(msg.data);
    }
    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}
```
This version usually also includes functions to transfer ownership of the proxy to a different address. Compound uses this pattern with [an extra twist](https://github.com/compound-finance/compound-protocol/blob/master/contracts/Unitroller.sol): the new implementation needs to *accept* the transfer, to prevent accidental upgrades to invalid contracts.

This pattern has the benefit that all logic related to upgrades is contained in the proxy, and the implementation contract does not need any special logic to act as a delegation target (except for a few exceptions, listed in [Implementation Contract Limitations and Initializers](#implementation-contract-limitations)). However, this pattern implemented as-is is subject to a vulnerability caused by function selector clashes.

### Selector Clashes and Transparent Proxies

All function calls in Ethereum are [identified by the first 4 bytes](https://www.4byte.directory/) of the data payload, which is known as the *function selector*. The selector is calculated from a hash of the function name and its signature. Now, 4 bytes is not a lot of entropy, which means that there is potential for clashing between two functions: two different functions with different names may end up having the same selector. If you happen to stumble upon such a case, the Solidity compiler will be smart enough to let you know, and refuse to compile a contract with two different functions with different names that have the same 4-byte identifier.

```
// This contract will not compile, as both functions have the same selector
contract Foo {
    function collate_propagate_storage(bytes16) external { }
    function burn(uint256) external { }
}
```



However, it is perfectly possible for an implementation contract to have a function that has the same 4-byte identifier as the proxy’s upgrade function. This could cause an admin to inadvertently upgrade a proxy to a random address while attempting to call a completely different function provided by the implementation. [This post](https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357) by [Patricio Palladino](https://twitter.com/alcuadrado) explains the vulnerability, and [Martin Abbatemarco](https://twitter.com/tinchoabbate) shows how it can be used for evil [here](https://forum.openzeppelin.com/t/beware-of-the-proxy-learn-how-to-exploit-function-clashing/1070).

This issue can be solved either by appropriate tooling while developing upgradeable smart contracts, or at the proxies themselves. In particular, if the proxy is set up such that the admin can only call upgrade management functions, and all other users can only call functions of the implementation contract, clashes are not possible.

```
// Sample code, do not use in production!
contract TransparentAdminUpgradeableProxy {
    address implementation;
    address admin;

    fallback() external payable {
        require(msg.sender != admin);
        implementation.delegatecall.value(msg.value)(msg.data);
    }

    function upgrade(address newImplementation) external {
        if (msg.sender != admin) fallback();
        implementation = newImplementation;
    }
}
```


This pattern is deemed the **transparent proxy contract** (not to be confused with [EIP1538](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1538.md)), and is well explained in [this post](https://blog.openzeppelin.com/the-transparent-proxy-pattern/). This is the pattern [used today](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/proxy/TransparentUpgradeableProxy.sol) by [OpenZeppelin Upgrades](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies) (formerly known as ZeppelinOS) and by extension, by several projects in the wild. It is often used in conjunction with the [ProxyAdmin contract](https://docs.openzeppelin.com/upgrades-plugins/proxies#transparent-proxies-and-function-clashes), to allow admin EOAs to still interact with their own contracts – since the admin can only manage the proxy.

Let’s see how this works in an example. Assume a proxy with an owner() getter and an upgradeTo() function that delegates calls to an ERC20 contract that has an owner() getter and a transfer() function. The following table covers all resulting scenarios:

| msg.sender | owner() | upgradeto() | transfer() |
|         ---|      ---|          ---|---       |
| Admin | returns proxy.owner() | upgrades proxy | reverts |
| Other account | returns erc20.owner() | reverts | sends erc20.transfer() |

[Hundreds](https://github.com/OpenZeppelin/openzeppelin-sdk/network/dependents?package_id=UGFja2FnZS00NjU2MTU0MTY%3D) [of](https://github.com/OpenZeppelin/openzeppelin-sdk/network/dependents?package_id=UGFja2FnZS01OTc0NzMwOQ%3D%3D) [projects](https://github.com/search?q=adminupgradeabilityproxy&type=Code) use this pattern for upgradeability, such as [dYdX](https://github.com/dydxprotocol/perpetual/blob/99962cc62caed2376596da357a13f5c3d0ea5e59/contracts/protocol/PerpetualProxy.sol), [PoolTogether](https://github.com/pooltogether/pooltogether-pool-contracts/tree/6b7eba5c610a61e4e44f8df95fdf3d1d2f1e0fa5/.openzeppelin), [USDC](https://github.com/centrehq/centre-tokens/tree/b42cf04b31639b8b05d53fea9995954d5f3659d9/contracts/upgradeability), [Paxos](https://github.com/paxosglobal/pax-contracts/tree/2650b8049f2f1fe53ebb3f5a0979241c4da9f1a5#upgradeability-proxy), [AZTEC](https://github.com/AztecProtocol/AZTEC/blob/cb78ba3ee32ad82234ac0fbed046333eb7f233cf/packages/protocol/contracts/AccountRegistry/AccountRegistryManager.sol#L62-L66), and [Unlock](https://github.com/unlock-protocol/unlock/blob/5d3ed7519e3fe3c75ef7220468d7a8ae716db194/smart-contracts/contracts/Unlock.sol#L30).

However, the transparent pattern has a downside: gas cost. Each call requires an additional read from storage to load the admin address, which [became more expensive after the Istanbul fork last year](https://forum.openzeppelin.com/t/openzeppelin-upgradeable-contracts-affected-by-istanbul-hardfork/1616). Furthermore, the contract itself is expensive to deploy compared to other proxies, at over 700k gas.

### Universal upgradeable proxies

As an alternative to transparent proxies, [EIP1822](https://eips.ethereum.org/EIPS/eip-1822) defines the universal upgradeable proxy standard, or **UUPS** for short. This standard uses the same delegate call pattern, but places upgrade logic in the implementation contract instead of the proxy itself.

Remember that, since the proxy uses delegate calls, the implementation contract always writes to the proxy’s storage instead of its own. And the implementation address itself is kept in the proxy’s storage. Nothing prevents the implementation from actually providing the logic for modifying the proxy’s implementation address. UUPS proposes that all implementation contracts extend from a base **proxiable** contract:

```
// Sample code, do not use in production!
contract UUPSProxy {
    address implementation;

    fallback() external payable {
        implementation.delegatecall.value(msg.value)(msg.data);
    }
}

abstract contract UUPSProxiable {
    address implementation;
    address admin;

    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}
```



This approach has several benefits. First of all, by having all functions defined on the implementation contract, it can count on the Solidity compiler to check for any function selector clashes. Furthermore, the proxy is much smaller in size, making deployments cheaper. It also requires one less read from storage in every call, adding less overhead.

This pattern has one main disadvantage: if the proxy is upgraded to an implementation that fails to implement the upgradeable functions, it becomes locked to that implementation and it is no longer possible to change it. Some developers prefer to keep upgradeable logic immutable to prevent these issues, and the best place to do that is in the proxy itself.

### Proxy Storage Clashes and Unstructured Storage

In all the proxy pattern variants, the proxy contract requires at least one state variable to hold the implementation contract address. By default, [Solidity stores variables](https://solidity.readthedocs.io/en/latest/internals/layout_in_storage.html) in the smart contract storage in order: the first variable declared goes to slot zero, the next to slot one, and so forth (mappings and dynamic-size arrays are exceptions to this rule). This means that, in the following proxy contract, the implementation will be saved to the storage slot zero.

```
// Sample code, do not use in production!
contract Proxy {
    address implementation;
}
```


Now, what happens if we use that proxy combined with the following seemingly innocuous implementation contract?

```
// Sample code, do not use in production!
contract Box {
    address public value;

    function setValue(address newValue) public {
        value = newValue;
    }
}
```


Following Solidity storage layout rules, any calls to `Box.setValue` made through the proxy will store the `newValue` in the storage slot zero. But keep in mind that, since we are using delegate calls, the storage affected will be that of the proxy, not the implementation contract. So calling into `Box.setValue` would accidentally overwrite the proxy implementation address – something we definitely do not want to happen.

The easiest way around this is to have `Box` declare a dummy first variable. This will push all variables of the contract one slot down, avoiding clashes.

```
// Sample code, do not use in production!
contract Box {
    address implementation_notUsedHere;
    address public value;

    function setValue(address newValue) public {
        value = newValue;
    }
}
```


While effective, this has the drawback of requiring all delegate target contracts to add this extra dummy variable. This limits reusability, since a vanilla contract cannot be used as an implementation contract. It is also prone to errors, since it’s easy to forget to add that extra variable in your contracts.

To avoid this issue, the [unstructured storage pattern](https://blog.openzeppelin.com/upgradeability-using-unstructured-storage/) was introduced. This pattern mimics how Solidity handles [mappings and dynamic-size arrays](https://solidity.readthedocs.io/en/latest/internals/layout_in_storage.html#mappings-and-dynamic-arrays): it stores the implementation address variable not in the first slots, but in an arbitrary slot in storage – `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc` to be precise. Given the addressable storage of a contract is 2^256 in size, chances of a clash are effectively zero.

```
// Sample code, do not use in production!
contract Proxy {
    fallback() external payable {
        address implementation = sload(0x360894...382bbc);
        implementation.delegatecall.value(msg.value)(msg.data);
    }
}
```



This way, the first slots of storage are used by the implementation contract business logic, and the proxy uses higher slots to avoid any clashes. For tooling purposes, the slots used by delegate call proxies have been standardized in [EIP1967](https://eips.ethereum.org/EIPS/eip-1967). This allows explorers such as [Etherscan](https://medium.com/etherscan-blog/and-finally-proxy-contract-support-on-etherscan-693e3da0714b) to easily identify these proxies (since any contract with an address-like value in that very specific slot will most likely be a proxy) and resolve the backing contract address.

This pattern effectively solves any storage clashing issues with the implementation contract, with no drawbacks except for the additional complexity in the proxy implementation.

### Storage Layout Compatibility with Append-Only and Eternal Storage

Contract upgrades introduce another challenge with regards to storage, in this case not between the proxy and the implementation, but between two different versions of the implementation. Let’s suppose we have the following implementation contract deployed behind a proxy:

```
contract OwnedBox {
    address owner;
    uint256 number;

    function setValue(uint256 newValue) public {
        require(msg.sender == owner);
        number = newValue;
    }
}
```




A few months later, a new developer comes along and introduces some changes to this contract. As part of the new changes, they decide to sort the state variables alphabetically (just because they want to), and upgrade the contract in production.

```
contract OwnedBox {
    uint256 number;
    address owner;
…
}
```


Keep in mind how the Solidity compiler decides to map variables to the contract storage: it is based on the order in which the variables are declared. This means that, after the upgrade, the value of “number” is now in the slot assigned to “owner”, and vice versa.

This shows a major limitation of smart contract upgrades: while it’s possible to arbitrarily change the code of a contract, only storage-compatible changes can be done to its state variables. Operations such as reordering variables, inserting new variables, changing the type of a variable, or even changing the inheritance chain of a contract can potentially break storage. The only safe change is to append state variables after any existing ones. The OpenZeppelin Upgrades [documentation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#modifying-your-contracts) includes a comprehensive list of forbidden operations, and the OpenZeppelin Upgrades Plugins will automatically check for them during upgrades.

A development practice to ensure that storage remains compatible across upgrades is to use **append-only** storage contracts. In this pattern, the storage is declared on a separate Solidity contract which is only modified to append new variables – never delete. The implementation contracts then extend from this storage contract to access storage.

```
// Sample code, do not use in production!
contract OwnedBoxStorage {
    address internal owner;
    uint256 internal number;
}

contract OwnedBox is OwnedBoxStorage {
    function setValue(uint256 newValue) public {
        require(msg.sender == owner);
        number = newValue;
    }
}
```



The storage contract can then be **extended** every time it’s needed to add a new state variable. Solidity guarantees that variables are laid out in storage depending on the order of the inheritance chain, so extending from the contract to add a new variable ensures that it will be appended after the existing ones. As an example, Compound [uses this pattern](https://github.com/compound-finance/compound-protocol/blob/v2.8.1/contracts/ComptrollerStorage.sol#L97) for changes to their Comptroller contract.

```
// Sample code, do not use in production!
contract OwnedBoxStorage {
    address internal owner;
    uint256 internal number;
}

contract OwnedBoxStorageV2 is OwnedBoxStorage {
    uint256 internal newNumber;
}
```


This approach has a major drawback though: all contracts in the inheritance chain must follow this pattern to prevent mixups. This includes contracts from external libraries that define their own state.

Append-only storage requires special care when dealing with base contracts in the inheritance chain. Let’s take the following example:

```
contract Base {
    uint256 base1;
    uint256 base2;
}

contract Child is Base {
    uint256 child1;
    uint256 child2;
}
```



The Solidity compiler will lay out these variables in subsequent storage slots in the order `base1`, `base2`, `child1`, `child2`. This means that, if we were to add a new state variable to `Base`, it would take the place of `child1`. This difficulties making any changes to extended contracts.

Still, there is a way around this problem: we can “reserve” space for future state variables in the base contract by declaring dummy variables. Declaring an unused variable in Solidity will not consume gas, but will push down the slot allocated for other variables in the contract. The upgrade-safe fork of OpenZeppelin Contracts [uses this pattern](https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/master/contracts/access/Ownable.sol#L78) in all contracts of the library.

A different pattern developed to address storage layout compatibility is the [eternal storage pattern](https://blog.openzeppelin.com/smart-contract-upgradeability-using-eternal-storage/). This pattern uses the same strategy as *unstructured storage*, but for all variables of the implementation contract. This means that the implementation contract never declares any variables of its own, but rather stores them in a mapping, which causes Solidity to save them in arbitrary positions of storage, based on their assigned names.

```
// Sample code, do not use in production!
contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
}

contract Box is EternalStorage {
    function setValue(uint256 newValue) public {
        uintStorage[‘value’] = newValue;
    }
}
```


As examples, [Hyperbridge](https://github.com/hyperbridge/protocol/blob/cf360f81ddf075b4ec17e798365cf81b97926238/packages/token/smart-contracts/ethereum/contracts/EternalStorage.sol) and [Polymath](https://github.com/PolymathNetwork/polymath-core/blob/v3.0.0/contracts/datastore/DataStoreStorage.sol) use this pattern for their respective protocol contracts. While it guarantees no issues during upgrades, it requires a major change in how all contracts are coded, incompatible with contracts that do not follow this convention, and produces far more awkward code. Using strings for identifying variables can also lead to errors due to typos, unless constants are used for the mapping keys.

There are also proposals to address this issue at the language level, such as allowing to [specify the location of a variable](https://github.com/ethereum/solidity/issues/597) (under discussion since May 2016), or having a contract allocate its variables in [slots computed from hashes of the variable names](https://github.com/ethereum/solidity/issues/8353) (as in eternal storage). Until these are implemented, the best options are still to heavily test upgrades, and complement them with automated tools to validate the changes introduced.

### Implementation Contract Limitations and Initializers

Even under the unstructured proxy pattern, there are some limitations to the contracts that can be used as implementation contracts. These limitations are detailed in the [OpenZeppelin Upgrades documentation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable), but the most impactful one is not being able to use constructors.

In Solidity, the contract constructor is not part of the contract runtime code that gets deployed. It is actually code sent along with the contract deployment, but that gets discarded after it is executed. Thus, once the implementation contract has been created, there is no way to invoke its constructor code anymore. This means that proxies cannot call into the constructor to initialize their state.

To work around this, constructors need to be changed into regular functions, usually called *initializers*. Since these are regular functions, they do get compiled into the contract, and can be delegate-called by the proxy to initialize it when it is deployed. However, since they are also regular functions, they need additional logic to ensure they can be called only once.

```
// Sample code, do not use in production!
contract OwnedBox {
    bool initialized;
    address owner;

    function initialize(address initialOwner) public {
        require(!initialized);
        initialized = true;
        owner = initialOwner;
    }
}
```


To facilitate this, OpenZeppelin Contracts includes a [base Initializable contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/proxy/Initializable.sol) that provides an `initializer` modifier that implements this pattern.

Note that this also requires that any smart contract library dependency used also follows this pattern. This has led OpenZeppelin to [maintain an upgrade-safe fork of the Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/) library, where constructors have been replaced by initializers, though we have been at work to remove [the need for it](https://forum.openzeppelin.com/t/planning-the-demise-of-openzeppelin-contracts-evil-twin/1724) in the near future.

Another practice is [not allowing the selfdestruct operation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#potentially-unsafe-operations) in implementation contracts. If a user [accidentally](https://github.com/openethereum/openethereum/issues/6995) calls into your implementation contract directly and happens to execute this function, the implementation contract will be destroyed, and all proxies will be left without their code, rendering them unusable. And if the logic for managing upgrades was located in the implementation contract and not in the proxy (as in UUPS), this would effectively [brick all proxies](https://blog.openzeppelin.com/parity-wallet-hack-reloaded/).

### Multiple Implementation Contracts with Diamonds

In all proxy variants we have explored so far, each proxy is backed by a single implementation contract. However, it is possible for a single proxy to delegate to more than one contract. First explored as [vtable upgradeability](https://github.com/OpenZeppelin/openzeppelin-labs/tree/master/upgradeability_with_vtable) in OpenZeppelin Labs, this pattern evolved until being standardized by [Nick Mudge](https://github.com/mudgen/) under the name of [Diamond Contract](https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb) in [EIP2535](https://eips.ethereum.org/EIPS/eip-2535), currently in use by projects such as [nayms](https://github.com/nayms/contracts/blob/master/contracts/base/DiamondProxy.sol).

In this version, instead of storing a single implementation address, the proxy stores a mapping from function selector to implementation address. When it receives a call, it looks up an internal mapping (akin to a [vtable used in dynamic dispatch](https://en.wikipedia.org/wiki/Virtual_method_table)) to retrieve what logic contract provides an implementation for the requested function.


```
// Sample code, do not use in production!
contract Proxy {
    mapping(bytes4 => address) implementations;
    fallback() external payable {
        address implementation = implementations[msg.sig];
        return implementation.delegatecall.value(msg.value)(msg.data);
    }
}
```


This pattern has a few advantages. To begin with, it allows going over the maximum contract size, by splitting its implementation into multiple contracts. It also allows for more granular upgrades, allowing to change only a particular function at a time.

![](https://img.learnblockchain.cn/2020/10/15/16027249726170.jpg)

However, this flexibility comes with its limitations. For one, having multiple implementation contracts writing to the proxy storage can lead to storage clashes between the different implementations. This is solved in the Diamond pattern by using a variant of unstructured storage, where each implementation’s storage is defined as a struct and [stored in an arbitrary storage position](https://medium.com/1milliondevs/new-storage-layout-for-proxy-contracts-and-diamonds-98d01d0eadb), to avoid clashes. Still, if different implementations need to access the same storage, they would need to extend from the same base storage contract, which needs to be kept in sync among all deployed implementations.

This pattern also makes code reuse within the same contract more difficult: auxiliary functions that are called from more than one implementation need to either be included in both (via inheritance), or be defined as a separate function in the vtable (which requires an external call instead of an internal one, requiring additional gas and permission checks). On the other hand, this forced split can help achieve good modularity and separation of concerns within the smart contract system.

### Simultaneous Upgrades with Beacons

While multiple implementation contracts per proxy is definitely interesting, let’s now discuss the opposite: multiple proxies per implementation. When we introduced the proxy pattern, we highlighted that a single logic contract can be used as the implementation for several proxies, since each proxy holds its own state. However, in this situation, if we found a bug in our implementation and deployed a fix, we would have to individually upgrade each of our proxies, which can be cumbersome (and expensive) if we have several of them deployed.

Enter the [beacon pattern](https://blog.dharma.io/why-smart-wallets-should-catch-your-interest/), first introduced by [0age](https://github.com/0age) in the [Dharma Smart Wallet](https://github.com/dharma-eng/dharma-smart-wallet/tree/master/contracts/upgradeability). In this pattern, each proxy holds the address not to its implementation contract, but to a *beacon* which, in turn, holds the address of the implementation. Whenever the proxy receives a call, it asks the beacon for the current implementation to use. All proxies that share a beacon can be upgraded in a single transaction by just changing the address stored in the beacon.

```
// Sample code, do not use in production!
contract Proxy {
    address immutable beacon;

    fallback() external payable {
        address implementation = beacon.implementation();
        return implementation.delegatecall.value(msg.value)(msg.data);
    }
}

contract Beacon is Ownable {
    address public implementation;

    function upgrade(address newImplementation) public onlyOwner {
        implementation = newImplementation;
    }
}
```



This pattern has another advantage: proxies no longer need to keep anything on their own storage, removing the need for unstructured storage altogether. Since proxies always point to the same beacon, the beacon address can be [stored in code instead of storage](https://solidity.ethereum.org/2020/05/13/immutable-keyword/), reducing gas costs. The beacon itself could also be designed to keep the implementation address in code instead of storage by implementing it as a [Metamorphic Contract](#metamorphic-contracts).

![](https://img.learnblockchain.cn/2020/10/15/16027250188401.jpg)



Note that it’s possible to combine both the traditional upgradeable proxy approach and the beacon approach, by allowing the beacon itself to be changed. This allows the owner of a proxy to *fork* to a different beacon. However, this leads to higher gas costs, both in execution and in deployment.

### Non Upgradeable Proxies with EIP1167

While they have no place in an article about upgrades, it wouldn’t be fair if we didn’t mention *non-upgradeable proxies* after dwelling so much on proxies. These proxies are known as **minimal proxies** and are standardized in [EIP1167](https://eips.ethereum.org/EIPS/eip-1167).

Why would we bother with proxies if not for upgrades? The answer is to reduce deployment costs, when multiple instances of a contract are needed. Deploying several copies of a large contract can be very expensive in terms of gas costs, so it’s more cost-effective to deploy a single copy to act as an implementation contract, and spawn multiple proxies backed by it. Now, if these proxies do not need to be upgraded, they do not need any storage or management functions, making them dead-simple:

```
// Sample code, do not use in production!
contract MinimalProxy {
    fallback() external payable {
        return IMPLEMENTATION_ADDRESS.delegatecall.value(msg.value)(msg.data);
    }
}
```



In fact, these proxies are so simple that they can be implemented in just the following 45 bytes of assembly. [Martín Abbatemarco](https://twitter.com/tinchoabbate) has written a great [deep dive on this code](https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/) if you want to understand how it works.

```
3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
```



### Abusing CREATE2 with Metamorphic Contracts

Now, to wrap up this section, let’s review one last pattern for upgrades, presented by [0age](https://github.com/0age) under the name of [Metamorphic Contracts](https://medium.com/@0age/the-promise-and-the-peril-of-metamorphic-contracts-9eb8b8413c5e). This pattern has a major difference with the ones reviewed so far: it preserves the contract address among upgrades, but not its state – which technically breaks the definition of upgradeability we gave at the beginning of this article. This significantly reduces the scenarios in which it can be deployed; however, it has some major advantages over the proxy patterns.

This pattern relies on the [CREATE2 opcode](https://blog.openzeppelin.com/getting-the-most-out-of-create2/) introduced in [EIP1014](https://eips.ethereum.org/EIPS/eip-1014). This opcode makes it possible to manage the address in which a contract will be deployed. When a contract is deployed using CREATE2, its address is determined by the contract deployment code, the sender, and a salt. The original motivation for this opcode was its usage in counterfactual instantiation, used in [generalized state channels](https://l4.ventures/papers/statechannels.pdf), but they were soon repurposed for upgradeability as well.

The trick lies in the fact that the deployment address is not calculated from the contract code, but from the contract *deployment* code. The deployment code is code that performs any necessary initializations (i.e. runs the constructor), and returns the contract code to be created (usually hardcoded in it). However, the deployment code may also fetch the contract code from somewhere else, such as a mutable registry. This allows different code to be deployed to the same address, by using the same factory contract and the same hash. Combine this with the [selfdestruct opcode](https://solidity.readthedocs.io/en/v0.7.0/introduction-to-smart-contracts.html#deactivate-and-self-destruct), that clears the contract code, and we have built ourselves a mechanism to change the code at an address.

Note that this approach does not require a proxy contract to be used, nor does it require the contract to change its constructor into an initializer. It would be the ideal upgradeability approach, if it were not for a major drawback: calling selfdestruct not only wipes out the contract code, but also its state. Furthermore, selfdestruct does not immediately clear the code – it only gets cleared at the end of the transaction. This means that an upgrade requires two transactions: one to delete the current contract, and another to create the new one. Any transaction that arrives to our contract in between those two would fail – effectively introducing a *downtime* for our upgrades.

Still, there are situations where metamorphic contracts are still useful. Contracts that contain only logic (similar to Solidity external libraries) are the most obvious candidates. Another use are contracts with little state that changes infrequently, such as beacons. In these cases, state can even be embedded into the code, making it cheaper to access it, and the contract can be “upgraded” whenever the state needs to be changed.

## Upgrades Governance

With the technical challenges of upgrades now behind us, it’s time to focus on governance. By governance, we refer to *how the decision of upgrading a smart contract is made*: from centrally and immediately by a single trusted party, or via a voting process among all stakeholders.

Governance is critical to upgrades. No matter how technically solid your upgrade solution is, without proper governance for your project, upgradeability is fundamentally flawed. The promise of smart contracts and ultimately blockchain technology is that of trustlessness, which falls apart the moment a developer can single-handedly change a system to rob all participants of their funds. Lack of proper governance schemes is what often leads to critics of upgradeability to [consider it a bug](https://medium.com/consensys-diligence/upgradeability-is-a-bug-dba0203152ce) in smart contract systems.

It’s important to mention that there is no universal solution to governance. Different systems will require different schemes. For example, a token vesting contract, where a granter provides tokens to a grantee over time, could be managed by just the agreement of the two parties involved. If they both concur in making a change to the rules of the vesting contract, they should be free to do so. But more complex systems will require more complex solutions. Let’s go through them.

### Externally Owned Accounts

Externally owned accounts (EOAs for short) are the most centralized option for managing upgrades. A single user with a single key has power over the entire system. Needless to say, this is far from ideal: not only does it put the fate of all users in a single party, but it’s also a security risk. If the keys of the EOA are compromised, the entire system is at risk.

Because of this, EOAs should only be acceptable during development. As soon as the system hits production on mainnet, it should be moved to the next step: a multi-sig wallet.

### Multi-sig

Multi-sig wallet contracts are contracts with multiple owners, that can execute arbitrary actions when a predefined number of owners are in agreement. The flow is simple: one of the owners proposes a new action to be executed, others sign in agreement, and when the threshold is reached, the action is sent from the contract.

Multi-sig wallets are usually set up to manage large funds on behalf of a team, but can also be set up as the administrator of a system. This way, any changes to the system, whether they are setting a new fee or changing the code of a contract, need to be greenlit by several owners. To further foster decentralization, these owners can belong to different teams, as long as they are trusted stakeholders of the system.

![](https://img.learnblockchain.cn/2020/10/15/16027250926944.jpg)


Note that a multi-sig can even be used by a single user, where additional keys represent additional devices that act as multi-factor authenticators. This makes multi-sigs a good option even for single-person teams, just for security purposes.

All in all, multi-sigs can go a long way in the path to progressive decentralization. However, most projects eventually go into a scheme where the control is passed on to the community through voting rights. But before going there, let’s explore other additions to the multi-sig approach.

### Timelocks

When we talk about *timelocks*, we are referring to enforcing a time delay to every change that affects the system. In a setup with multi-sig governance with timelocks, each proposal does not get executed immediately once the approval threshold is reached, but there is a time delay of a few hours or more typically days until it comes into effect. For instance, [dYdX](https://defiwatch.net/admin-key-config-and-opsec/project-reviews/dydx) implements this pattern via a [modified Gnosis MultisigWallet contract](https://etherscan.io/address/0xba2906b18b069b40c6d2cafd392e76ad479b1b53#code).

The purpose of timelocks is to allow the users to exit the system if they disagree with a proposed change, from a code upgrade to an increased protocol fee. Without this control in place, users need to trust not only the system but also its administrators, since they could enact any change at any time without prior warning.

However, timelocks introduce an issue. While they are a good practice before introducing a modification in the mechanics of the system, they are a problem when the change introduced is meant to fix a critical vulnerability. In these situations, we want to be able to deploy a fix without delay. But we cannot allow admins to bypass the timelock. So how do we manage in these situations?

### Pausable

We say a system is pausable when it can be set in a mode where all operations to it are frozen. For instance, an ERC20 can be instructed to pause and halt all transfers upon an emergency, safely preserving the balance of each account, as in the case of the [USDC token](https://github.com/centrehq/centre-tokens/blob/5013157edecbaf5da7fb9e3afa85992965077c88/contracts/v1/FiatTokenV1.sol#L272-L275).

A pausing switch is a good safeguard that gives you and your team time to react upon an issue and program an upgrade to fix the vulnerability at hand. This holds regardless of having a timelock set up or not. Keep in mind that when faced with a critical issue in a smart contract system, you cannot take your servers offline until you diagnose the problem. Your contracts are on the blockchain, and the blockchain keeps running no matter what you do.

The rights to pause a system are usually centralized. This allows trusted developers in the team to halt operations as soon as an issue is detected, preventing more harm to be done. However, pausing needs to be limited in time. You do not want to have someone who can unilaterally keep a system on hold at ransom by keeping it perpetually paused. The time the system can be kept in pause should be limited to a few hours or days.

Note that, if not implemented carefully, pausing can negate the effects of a timelock. The administrator team could pause the system while they roll out an unpopular (if not malicious) upgrade, keeping the users hostage and unable to exit before the change hits. This situation can be mitigated by introducing escape hatches.

### Escape Hatches

An *escape hatch* is a mechanism coded in the smart contracts that allow the users to exit the system, even while it’s paused. What it means to *exit the system* will vary depending on the system itself.

As an example, MakerDAO has an [emergency shutdown](https://blog.makerdao.com/introduction-to-emergency-shutdown-in-multi-collateral-dai/) mechanic that pauses the entire system, while allowing users to extract their assets. This shutdown can be enacted either by community vote (as most other changes in the system), or single-handedly by a trusted oracle. As another example, Dharma has a [minimal wallet implementation](https://github.com/dharma-eng/dharma-smart-wallet/blob/376c359209945470c841cbf5462b7d314ac40076/contracts/implementations/smart-wallet/AdharmaSmartWalletImplementation.sol#L9-L17) that provides access to an escape hatch, and can be rolled out in the event of a contingency.

Escape hatches are the last resource for a user to leave a system. However, they need to be carefully implemented: a bug in the escape hatch mechanism itself could render the system helpless while an attacker exploits it to drain its funds.

### Commit-Reveal Upgrades

An alternative to the mechanisms of pausing with escape hatches is to use *commit-reveal upgrades*. One of the issues of timelocked upgrades for fixing vulnerabilities is that it’s typically easy to reverse-engineer a fix to know the vulnerability it patches. This way, publishing a timelocked upgrade to be implemented in a few days is potentially signalling attackers that there is an issue to be exploited, and they are free to do so during that window of time.

Alternatively, developers of the system can push a “hidden” upgrade. They do not disclose the code of the upgrade but to a group of trusted security advisors who can publicly vouch for it, and they just create a proposal with a hash of the upgrade (commit phase). When the timelock period finishes, they actually publish (reveal phase) the upgrade and apply it immediately.

This mechanism is [under discussion in the MakerDAO community](https://forum.makerdao.com/t/mip15-dark-spell-mechanism/2578), under the name of “dark spells”, as every change proposal in the context of Maker is called a “spell”. Note that this mechanism only prevents from signalling the issue, but does not help if the vulnerability is already being exploited.

### Voting

The last step in the road of progressive decentralization is to grant your community voting rights to manage the governance of the system. This requires a way to represent voting power, which is usually done via a governance token, such as [MKR in MakerDAO](https://vote.makerdao.com/) or [COMP in Compound](https://compound.finance/governance). Token holders can then use their tokens to vote for or against changes to the system.

![](https://img.learnblockchain.cn/2020/10/15/16027251359356.png)

Many of the mechanisms listed above (pausing, escape hatches, and commit reveal) can be used in conjunction with voting as well. Note that voting inherently introduces a delay to executing changes, since setting up a proposal for voting usually requires it to stay open for several days to give time to all interested stakeholders to express their opinion. This means that a mechanism for rolling out critical fixes is usually needed in conjunction with voting.

## Conclusion

Upgrades are a powerful tool in smart contract systems, useful both for iterative development and for protecting users in the event of a vulnerability. Usage of upgrades has become widespread in mainstream projects in the past few years, with many patterns being used to work out the challenges – both technical and social – that arise from them.

At OpenZeppelin we believe upgrades to be an integral part of the toolset of a smart contract developer, and we continue to work on open source solutions to make them more accessible and secure to use, as well as including more patterns to the ones we already support.

Go to the [OpenZeppelin community forum](https://forum.openzeppelin.com/) to join the discussion about upgrades and more!

*Review and formatting by Andrew Coathup, diagrams by Agostina Blanco *

## References

1. [https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f](https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f)
2. [https://blog.openzeppelin.com/proxy-patterns/](https://blog.openzeppelin.com/proxy-patterns/)
3. [https://blog.openzeppelin.com/smart-contract-upgradeability-using-eternal-storage/](https://blog.openzeppelin.com/smart-contract-upgradeability-using-eternal-storage/)
4. [https://blog.openzeppelin.com/towards-frictionless-upgradeability/](https://blog.openzeppelin.com/towards-frictionless-upgradeability/)
5. [https://blog.openzeppelin.com/the-transparent-proxy-pattern/](https://blog.openzeppelin.com/the-transparent-proxy-pattern/)
6. [https://docs.openzeppelin.com/upgrades-plugins/](https://docs.openzeppelin.com/upgrades-plugins/)
7. [https://blog.indorse.io/ethereum-upgradeable-smart-contract-strategies-456350d0557c](https://blog.indorse.io/ethereum-upgradeable-smart-contract-strategies-456350d0557c)
8. [https://medium.com/coinmonks/summary-of-ethereum-upgradeable-smart-contract-r-d-part-2-2020-db141af915a0](https://medium.com/coinmonks/summary-of-ethereum-upgradeable-smart-contract-r-d-part-2-2020-db141af915a0)
9. [https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201](https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201)
10. [https://medium.com/@0age/the-promise-and-the-peril-of-metamorphic-contracts-9eb8b8413c5e](https://medium.com/@0age/the-promise-and-the-peril-of-metamorphic-contracts-9eb8b8413c5e)
11. [https://blog.dharma.io/why-smart-wallets-should-catch-your-interest/](https://blog.dharma.io/why-smart-wallets-should-catch-your-interest/)
12. [https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb](https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb)
13. [https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/](https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/)


