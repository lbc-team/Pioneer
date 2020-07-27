
# Contract factories and clones

## How to deploy contracts within contracts as easily and gas-efficient as possible


The [factory design pattern](https://en.wikipedia.org/wiki/Factory_method_pattern) is a pretty common pattern used in programming. The idea is simple, instead of creating objects directly, you have an object (the factory) that creates objects for you. In the case of Solidity, an object is a smart contract and so a factory will deploy new contracts for you.


## Why factories


Let's first discuss when and why you would want a factory. In fact, let's first see when you would **not** want one:

* You deploy your contracts once to the main-net and then never again.

Okay, that was easy. Obviously there's no point for a factory if you were to use it only once. Now what about multiple deployments?

* You want to keep track of all deployed contracts.
* You want to save gas on deployments.
* You want a simple way for users or yourself to deploy contracts.

![](https://img.learnblockchain.cn/2020/07/27/15958322619544.jpg)


## The normal factory

In the most simplest form, your factory is just a contract that has a function which deploys your actually used contract. Let's have a look for a modified [MetaCoin](https://www.trufflesuite.com/boxes/metacoin).

```
// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

import "./MetaCoin.sol";

contract MetaCoinFactory {
    MetaCoin[] public metaCoinAddresses;
    event MetaCoinCreated(MetaCoin metaCoin);

    address private metaCoinOwner;

    constructor(address _metaCoinOwner ) public {
        metaCoinOwner = _metaCoinOwner ;
    }

    function createMetaCoin(uint256 initialBalance) external {
        MetaCoin metaCoin = new MetaCoin(metaCoinOwner, initialBalance);

        metaCoinAddresses.push(metaCoin);
        emit MetaCoinCreated(metaCoin);
    }

    function getMetaCoins() external view returns (MetaCoin[] memory) {
        return metaCoinAddresses;
    }
}
```


As you can see, our `createMetaCoin` function deploys new `MetaCoins` for us. You can store variables for the deployment inside the factory (as we did with `owner`) or pass them to the deployment function (as we did with `initialBalance`).

We also keep a list of all deployed contracts which you can access via `getMetaCoins()`. You may want to add more functionality for managing deployed contracts like finding a specific MetaCoin contract, disabling a MetaCoin and such. Those are all good reasons for having a factory.

But here is one potential problem: [high gas costs](https://ethereum.stackexchange.com/q/84764/33305). And that's where we can use cloning...

![](https://img.learnblockchain.cn/2020/07/27/15958323231518.jpg)


## The clone factory


If you always deploy the same kind of contract, it's unnecessarily wasting gas costs for the bytecode. Any contract will have almost identical bytecode, so we don't have to store all bytecode again and again for each deployment.

#### **How it works**

It's possible thanks to [DELEGATECALL](https://eips.ethereum.org/EIPS/eip-7) opcode. We deploy our `MetaCoin` contract only once. This will be the implementation contract. Now instead of deploying new `MetaCoin` contracts every time, we deploy a new contract that simply delegates all calls to the implementation contract. Remember how `DELEGATECALL` functions: It calls the function of the implementation contract with the context of its own state. So each contract will have its own state and simply uses the implementation contract as library.

#### **How to use it**

There's a great [CloneFactory](https://github.com/optionality/clone-factory) package available. Unfortunately, it's a bit outdated, so if you want to use it with the latest Solidity compiler, you'll have to copy the source code and change the `pragma` setting. Is it safe? It should be, but use at your own risk or better get an audit (which you should do anyways).

1. You cannot clone contracts with constructor variables, so our first step will be creating a new contract `MetaCoinClonable` and we will be moving all deployment variables towards a new `initialize` function.

2. Then we can simply inherit from `CloneFactory`.
3. Use `createClone` to deploy a new contract.
4. Call `initialize` to pass the previous constructor variables.


```
// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CloneFactory.sol";
import "./MetaCoinClonable.sol";

contract MetaCoinCloneFactory is CloneFactory, Ownable {
    MetaCoinClonable[] public metaCoinAddresses;
    event MetaCoinCreated(MetaCoinClonable metaCoin);

    address public libraryAddress;
    address private metaCoinOwner;

    constructor(address _metaCoinOwner) public {
        metaCoinOwner = _metaCoinOwner;
    }

    function setLibraryAddress(address _libraryAddress) external onlyOwner {
        libraryAddress = _libraryAddress;
    }

    function createMetaCoin(uint256 initialBalance) external {
        MetaCoinClonable metaCoin = MetaCoinClonable(
            createClone(libraryAddress)
        );
        metaCoin.initialize(metaCoinOwner, initialBalance);

        metaCoinAddresses.push(metaCoin);
        emit MetaCoinCreated(metaCoin);
    }

    function getMetaCoins() external view returns (MetaCoinClonable[] memory) {
        return metaCoinAddresses;
    }
}
```

You'll first deploy a single MetaCoin implementation contract. Then pass its address via `setLibraryAddress`. That's it.

**Are previously deployed contracts affected by setting new library addresses?**

No, that only affects future deployments. If you wanted old contracts to be changed, you have to make them [upgradable](https://hackernoon.com/how-to-make-smart-contracts-upgradable-2612e771d5a2).

**What if the library address contract self-destructs?**

All previously deployed contracts would stop working, so make sure this cannot happen.

**Any downsides?**

Not much, but I wouldn't use it for high-volume contracts without proper audit. And Etherscan verification [doesn't work yet](https://www.reddit.com/r/etherscan/comments/9uzw8i/eip1167_clonefactory_support/), they added [proxy support](https://medium.com/etherscan-blog/and-finally-proxy-contract-support-on-etherscan-693e3da0714b), so maybe it does work now? It might be more tricky, if you have done it successfully, let me know. However, it's not quite as important to do it for security reasons as the clones are very simple in their functionality and it will be more important to have a verified library contract. But of course you loose the simple contract interaction on Etherscan.


## Comparison


Let's see the difference in gas costs. Even our small `MetaCoin` contract deployments are already more than 50% cheaper. The difference is only getting bigger the larger your contracts are. If your contracts get larger, clone factory deployments won't change much in costs, but regular factory deployments become more and more expensive.

```
·-------------------------------------------|----------------------------|-------------|----------------------------·
|   Solc version: 0.6.11+commit.5ef660b1    ·  Optimizer enabled: true   ·  Runs: 200  ·  Block limit: 6721975 gas  │
············································|····························|·············|·····························
|  Methods                                                                                                          │
·························|··················|··············|·············|·············|··············|··············
|  Contract              ·  Method          ·  Min         ·  Max        ·  Avg        ·  # calls     ·  eur (avg)  │
·························|··················|··············|·············|·············|··············|··············
|  MetaCoinCloneFactory  ·  createMetaCoin  ·       94539  ·     109527  ·      95039  ·          30  ·      0.68   │
·························|··················|··············|·············|·············|··············|··············
|  MetaCoinFactory       ·  createMetaCoin  ·      208441  ·     212653  ·     212513  ·          30  ·      1.53   │
·-------------------------------------------|--------------|-------------|-------------|--------------|-------------·
```


Now go and save on some gas with cloning. Gas costs are particularly high again at the moment, so I hope this will be useful for you.

Have you tried the `CloneFactory` before? Can you think of other reasons why use it or not use it? Let me know in the comments.

原文链接：https://soliditydeveloper.com/clonefactory

