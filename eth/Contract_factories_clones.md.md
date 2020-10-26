> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 合约工厂和克隆

## 如何尽可能轻松，高效地在合约内部署合约


[工厂设计模式](https://en.wikipedia.org/wiki/Factory_method_pattern)是编程中非常常见的模式。这个想法很简单，你有一个对象(工厂)来为你创建对象，而不是直接创建对象。对于Solidity，对象是智能合约，因此工厂将为你部署新合约。


## Why factories(为什么要工厂)


首先，让我们讨论一下何时以及为什么要建立工厂。实际上，让我们首先看看你什么时候不想要一个:

* 你将合约部署一次到主网上，然后再也不部署。

好的，那很容易。显然，如果只使用一次工厂，那是没有意义的。现在如何进行多个部署？

* 你想跟踪所有已部署的合约。
* 你想节省部署费用。
* 你想要用户或你自己部署合约的简单方法。

![](https://img.learnblockchain.cn/2020/07/27/15958322619544.jpg)


## 普通工厂

在最简单的形式中，工厂只是具有功能的合约，该功能可以部署实际使用的合约。让我们来看看修改后的[MetaCoin](https://www.trufflesuite.com/boxes/metacoin).

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


如你所见，我们的`createMetaCoin`函数为我们部署了新的`MetaCoins`。你可以在工厂内部存储用于部署的变量(就像我们使用`owner`一样)，也可以将它们传递给部署函数(就像我们使用`initialBalance`一样)。

我们还将保留所有已部署合约的列表，你可以通过`getMetaCoins()`访问这些合约。你可能需要添加更多功能来管理已部署的合约，例如查找特定的MetaCoin合约，禁用MetaCoin等。这些都是有工厂的充分理由。

但这是一个潜在的问题:[高 gas 成本](https://ethereum.stackexchange.com/q/84764/33305).这就是我们可以使用克隆的地方...

![](https://img.learnblockchain.cn/2020/07/27/15958323231518.jpg)


## 克隆工厂


如果你始终部署相同类型的合约，那么不必要地浪费字节码的 gas 成本。任何合约都将具有几乎相同的字节码，因此我们不必为每个部署一次又一次地存储所有字节码。

#### **怎么运行的**

多亏了[DELEGATECALL](https://eips.ethereum.org/EIPS/eip-7)操作码。我们只部署一次`MetaCoin`合约。这将是执行合约。现在，我们不再部署新的`MetaCoin`合约，而是部署了一个新的合约，该合约将所有调用委托给实现合约。记住`DELEGATECALL`是如何起作用的:它以其自身状态的上下文调用实现协定的功能。因此，每个合约都将具有其自己的状态，并且仅将实现合约用作库。

#### **如何使用它**

有一个很棒的[CloneFactory]​​(https://github.com/optionality/clone-factory)包。不幸的是，它有点过时了，所以如果你想将其与最新的Solidity编译器一起使用，则必须复制源代码并更改`pragma`设置。安全吗？应当这样做，但使用后果自负，或者更好地进行审核(无论如何都应这样做)。

1. 你无法克隆带有构造函数变量的合约，因此我们的第一步将是创建一个新的合约`MetaCoinClonable`，并将所有部署变量移向一个新的`初始化`功能。

2. 然后我们可以简单地从`CloneFactory`继承。
3. 使用`createClone`来部署一个新合约。
4. 调用`initialize`以传递之前的构造函数变量。


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

你将首先部署单个MetaCoin实施合约。然后通过setLibraryAddress传递其地址。而已。

**Are 受设置新库地址影响的先前部署的合约？**

不，那只会影响将来的部署。如果你想更改旧合约，则必须使其成为[可升级](https://hackernoon.com/how-to-make-smart-contracts-upgradable-2612e771d5a2).

**What 图书馆地址合约是否会自毁？**

以前部署的所有合约都将停止工作，因此请确保不会发生这种情况。

**Any downsides?**(不利之处？**)

数量不多，但是如果没有适当的审核，我不会将其用于大批量合约。他们添加了[代理支持](https://medium.com/etherscan-blog/and-finally-proxy-contract-support-on-etherscan-693e3da0714b),，并且Etherscan验证[还行不通](https://www.reddit.com/r/etherscan/comments/9uzw8i/eip1167_clonefactory_support/),，所以也许现在行得通了吗？如果你成功完成此操作，可能会比较棘手，请告诉我。但是，出于安全原因，这样做并不是很重要，因为克隆的功能非常简单，拥有经过验证的库合约更为重要。但是，你当然会失去Etherscan上的简单合约交互。


## Comparison(比较方式)


让我们看看 gas 成本的差异。甚至我们的小型`MetaCoin`合约部署也已经便宜了50％以上。合约越大，区别就越大。如果你的合约越来越大，克隆工厂部署的成本不会有太大变化，但是常规工厂部署的成本会越来越高。

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


现在去克隆节省一些气体。目前， gas 成本再次非常高，所以我希望这对你有用。

你之前尝试过`CloneFactory`吗？你能想到使用或不使用它的其他原因吗？在评论中让我知道。

链接:https://soliditydeveloper.com/clonefactory

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。