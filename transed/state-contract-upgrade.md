> * 原文链接：https://blog.openzeppelin.com/the-state-of-smart-contract-upgrades/ 作者：[圣地亚哥·帕拉迪诺](https://blog.openzeppelin.com/author/palla/)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
# 全面理解智能合约升级

![](https://img.learnblockchain.cn/2020/10/15/16027241822179.png)



> 译者推荐：这是我看到关于合约升级及治理写的最好的好文章，有点长，但读完必定有收获。原文来自 OpenZeppelin首席开发人员 Santiago Palladino 关于合约升级的报告，本文详细讨论了当前各种升级方式的原理、各自的优缺点，同时列举了采用相应方案的项目，以便大家进行代码级的参考。在最后一部分，作者还提出了多种配合升级的治理方案。



从技术角度对不同的以太坊智能合约升级模式和策略进行了调查，并提供了一套有关升级管理和治理的良好实践和建议。





## 什么是智能合约升级？

对于以太坊开发人员来说，智能合约升级并不是一个新概念。最早的升级模式之一可以追溯到2016年5月的[Nick Johnson的gist](https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f)，是在 4年前的时间，几乎覆盖了整个以太坊的历程（以太坊上线了[5年](https://blog.ethereum.org/2020/07/30/ethereum-turns-5/)）。

从那时起，智能合约升级工作进行了很多的探索、出现了各种不用的实现方式。升级既可以用作在出现漏洞时进行修复，也可以用作逐步添加新功能来迭代系统开发。

但是，由于智能合约升级带来的技术复杂性以及它们可能对真正的权力下放构成威胁，因此围绕智能合约升级也存在很多争议。在这篇文章中，我们将讨论这两个问题。我们将介绍不同的升级实现，并回顾一些成功的示例，并讨论每个示例的优缺点。然后，我们将回顾一些用于治理和管理的良好实践，以减轻向系统添加升级选项的中心化风险。

让我们首先定义智能合约升级的含义：

>  **什么是智能合约升级？**
> 智能合约升级是一种在保留存储和余额的同时，而又可以任意更改在地址中执行代码的操作。

但是在我们深入进行升级之前，我们将介绍一些无需实施全面升级即可更改系统的策略，这些策略可以作为升级的简单补充。

请坐稳了，这将是一个很长的文章。

## 升级替代方案

有许多策略可用于修改系统而无需完全升级。一个简单的解决方案是通过迁移来更改系统：部署一组新合约，将必要状态从旧合约复制到新合约(有时可以无信任地完成)，根据社区共识，让社区开始与新合约进行交互。

本节中列出的升级策略可用于以可预测的方式**修改系统**，这与升级不同（升级引入新代码几乎没有什么限制）。修改系统这是根据已有的规则来进行管理，在更改时系统的行为更加可预测。让我们研究其中一些策略。

### 参数的配置

简单地调整合约中的一组参数，可修改范围非常有限，以至于我怀疑是否将其包含在此列表中。一个很好的例子是[MakerDAO的稳定费率](https://cdp.makerdao.com/help/what-is-the-stability-fee),这是在合约中可设置的数值，它会改变系统的行为。该值经常更改，并且由于其含义很清楚，因此可以放心地执行操作。

但是，重要的是要了解系统对这些参数中设置的极值的反应。任意高昂的费用或零费用都可能导致系统停止运行，甚至使攻击者能够窃取所有资金。在合约中硬编码合理范围的参数值通常是一个好主意，并以此作为保障措施。

### 合约注册表

由多个合约组成的系统可能依赖合约注册中心。每当合约A需要与B进行交互时，它首先会查询注册表以获得B的地址。通过对注册表的修改，管理员可以将B替换为替代实现B&#39;，从而改变其行为。 [AAVE](https://github.com/aave/aave-protocol/blob/c6ac5919b04968147985ecd6e783063f740a979a/contracts/configuration/LendingPoolAddressesProvider.sol)的早期版本使用了这种模式。

但是，此机制在切换到B&#39;时不会保留B的状态，如果需要手动迁移，则可能会出现问题。此模式的某些版本通过将逻辑和存储合约解耦来缓解这种情况：状态保持在不变的存储合约中，并且只能根据需要更改的业务逻辑合约。我们将在本文后面部分深入探讨逻辑和存储合约分离。

这种模式的另一个缺点是，它也为外部客户端带来了额外的复杂性，这些外部客户端在与系统交互之前也需要调用注册表。可以通过添加具有不可变接口的外部包装接口来减轻这种情况，该包装接口负责管理注册表查找。

### 策略模式

[策略模式](https://en.wikipedia.org/wiki/Strategy_pattern)是更改合约中部分特定功能函数的代码的简便方法。替代在调用合约中实现函数来执行特定功能，而是通过调用单独的合约来处理该任务，通过切换该合约的实现，可以有效地在不同的“策略”之间进行切换。

 Compound 就是一个很好的例子，它具有不同的[RateModel实现](https://github.com/compound-finance/compound-protocol/blob/v2.3/contracts/InterestRateModel.sol)计算利率及其CToken合约[可以在它们之间切换](https://github.com/compound-finance/compound-protocol/blob/bcf0bc7b00e289f9b661a0ae934626e018188040/contracts/CToken.sol#L1358-L1366)。由于已知更改仅限于系统的特定部分，这可以轻松地推出修复程序或在费率计算上改进gas 消耗。当然，一个恶意利率模型实现可以设置为始终还原和停止系统，或为特定帐户提供任意高的利率。尽管如此，限制系统更改的范围仍使对这些更改的推理更加容易。

### 可插拔模块

策略模式的一个更复杂的变体是可插拔模块，其中每个模块都可以向合约添加新函数。在此模型中，主合约提供了一组核心不变的函数，并允许注册新模块。这些模块为核心合约增加了可调用的新函数。这种模式在钱包中最为常见，例如[Gnosis Safe](https://github.com/gnosis/safe-contracts/blob/v1.1.1/contracts/base/ModuleManager.sol#L35-L46)或[InstaDapp](https://github.com/InstaDApp/dsa-contracts/blob/master/contracts/account.sol)。用户可以选择将新模块添加到自己的电子钱包中，然后每次调用钱包合约时都要求从特定模块执行特定函数。

请记住，此模式要求核心合约没有漏洞。无法通过在此方案中添加新模块来修补管理模块本身上的任何漏洞。此外，根据实现方式的不同，新模块可能有权通过使用委托调用方式(DELEGATECALL，下面会进一步解释)代表核心合约运行任何代码，因此也应仔细检查它们。

## 升级模式

在前面不太简短的介绍之后，是时候进入实际的合约升级模式了。这些模式中的大多数都依赖于EVM原语(DELEGATECALL操作码)，因此让我们从其工作原理的简要概述开始。

### 委托调用

在常规的[CALL-消息调用](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-12)中，合约A向B发送payload数据（包含函数及参数信息）。合约B响应此payload数据执行其代码，可能会从其自己的存储中读取或写入数据，然后将响应返回给A。当B执行其代码时，它可以访问有关调用本身的信息，例如` msg.sender`设置为A。

但是，在[DELEGATECALL - 委托调用](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-13)，虽然执行的代码是合约B的代码，但是*执行发生在合约A*的上下文中。这意味着任何对存储的读取或写入都会影响A而不是B的存储。此外，` msg.sender`被设置为之前调用A的地址。总而言之，此操作码允许合约执行另一个合约中的代码，就像调用内部函数一样。这也是[Solidity能调用外部库](https://solidity.readthedocs.io/en/latest/contracts.html#libraries)的原因所在。

*有关DELEGATECALL工作原理的更多信息，请查看此[Ethernaut  Level walthrough](https://medium.com/coinmonks/ethernaut-lvl-6-walkthrough-how-to-abuse-the-delicate-delegatecall-466b26c429e4)来自[Nicole Zhu](https://twitter.com/nczhu)与委托有关的内容，[以太坊深度指南](https://blog.openzeppelin.com/ethereum-in-depth-part-1-968981e6f833/)由[Facundo Spagnuolo](https://twitter.com/facuspagnuolo),或[升级指南](https://docs.openzeppelin.com/learn/upgrading-smart-contracts#how-upgrades-work)，请参阅OpenZeppelin文档。*

### 代理与实现合约

委托调用打开了[代理模式](https://eips.ethereum.org/EIPS/eip-897)的大门，衍生出了许多变体，首先在ZeppelinOS和AragonOS中流行。如果你想深入了解委托代理合约的技术细节，我强烈建议阅读由Gnosis的[Alan Lu](https://github.com/cag)写的这篇[文章](https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201)。

在最基本的级别上，此模式依赖于代理合约和实现合约(也称为逻辑合约或委托目标)。代理知道实现合约的地址，并把收到的调用都[委托它执行](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/proxy/Proxy.sol#L21-L41)。

```javascript
// 示例代码，勿在产品中使用
contract Proxy {
    address implementation;
    fallback() external payable {
        return implementation.delegatecall.value(msg.value)(msg.data);
    }
}
```



由于代理在实现中使用了委托调用，因此就好像它自己在运行实现的代码一样。实现代码可以修改自己的存储和余额，并保留了调用的原始` msg.sender`。用户始终与代理进行交互，后面的实现合约对用户时不可见的。

![](https://img.learnblockchain.cn/2020/10/15/16027243505418.png)

这样便可以轻松执行升级。通过更改代理中的实现地址，可以更改每次调用代理时运行的代码，而用户与之交互的地址始终相同。状态也被保留，因为状态被保存在代理合约存储中，而不是在实现合约的存储中。

![](https://img.learnblockchain.cn/2020/10/15/16027243710030.png)


这种模式还有另一个优势：单个实现合约可以服务多个代理。由于存储保存在每个代理中，因此实现合约仅用于其代码。每个用户都可以部署自己的代理，并指向相同的不可变实现。

![](https://img.learnblockchain.cn/2020/10/15/16027243910345.png)

但是，这里缺少一些内容：我们需要定义如何实现升级逻辑。每种代理变体有着各自不同的升级逻辑。

### 管理升级函数

合约的升级通常由修改实现合约的函数来处理。在升级模式的某些变体中，代理合约中有管理实现的函数，并且仅限于由管理员调用。

```javascript
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


此版本通常还包含函数用来将代理的所有权转账到其他地址。 Compound 将这种模式与[额外的twist](https://github.com/compound-finance/compound-protocol/blob/master/contracts/Unitroller.sol)一起使用: 新的实现合约需要能*接受*转账，以防止意外升级到无效合约。

这种模式的好处是，与升级相关的所有逻辑都包含在代理中，并且实现合约不需要任何特殊逻辑即可充当委派目标(除[实现合约限制和初始化程序](#i实现合约限制和初始化)中列出的一些例外)。但是，这种实现模式容易受到函数选择器冲突导致的漏洞的攻击。

### 选择器冲突和透明代理

以太坊中的所有函数调用都由有效载荷payload[前4个字节来标识](https://www.4byte.directory/)，称为“[函数选择器](https://learnblockchain.cn/docs/solidity/abi-spec.html#function-selector)”。选择器是根据函数名称及其签名的哈希值计算得出的。然而，4字节不具有很多熵，这意味着两个函数之间可能会发生冲突：具有不同名称的两个不同函数最终可能具有相同的选择器。如果你偶然发现这种情况，Solidity编译器将足够聪明，可以让你知道，并且拒绝编译具有两个不同函数名称，但具有相同4字节标识符（[函数选择器](https://learnblockchain.cn/docs/solidity/abi-spec.html#function-selector)）的合约。

```javascript
// 这个合约无法通过编译，两个函数具有相同的函数选择器
contract Foo {
    function collate_propagate_storage(bytes16) external { }
    function burn(uint256) external { }
}
```



但是，对于实现合约而言，完全有可能具有与代理的升级函数具有相同的4字节标识符的函数。这可能会导致尝试调用实现合约时，管理员无意中将代理升级到随机地址（注：因为实现合约合约与升级函数4字节标识符相同）。 [这个帖子](https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357)由[Patricio Palladino](https://twitter.com/alcuadrado)解释了该漏洞，然后[Martin Abbatemarco](https://twitter.com/tinchoabbate)说明如何将其用于[做恶](https://forum.openzeppelin.com/t/beware-of-the-proxy-learn-how-to-exploit-function-clashing/1070).

这个问题可以通过开发用于可升级智能合约的适当工具解决，也可以通过代理本身解决。特别是，如果将代理设置为仅管理员能调用升级管理函数，而所有其他用户只能调用实现合约的函数，则不可能发生冲突。

```javascript
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



该模式被称为“透明代理合约”(请勿与[EIP1538](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1538.md)混淆)，在[这篇文章](https://blog.openzeppelin.com/the-transparent-proxy-pattern/)中有很好的解释。这是[OpenZeppelin升级](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies) (以前称为ZeppelinOS)[现在使用的](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/proxy/TransparentUpgradeableProxy.sol)模式。它通常与[ProxyAdmin合约](https://docs.openzeppelin.com/upgrades-plugins/proxies#transparent-proxies-and-function-clashes)结合使用，以允许管理员EOA与管理代理合约进行互动(管理员只能管理代理合约交互）。



让通过一个例子看看是怎么工作的。假定代理具有owner() 函数和upgradeTo()函数，该函数将调用委派给具有owner()和transfer()函数的ERC20合约。下表涵盖了所有导致的情况：

| msg.sender | owner()| upgradeto()| transfer()|
| --- | --- | --- | --- |
|管理员|返回proxy.owner()|升级代理|回退|
|其他帐户|返回erc20.owner()|回退|转发到 erc20.transfer()|

[数百个](https://github.com/OpenZeppelin/openzeppelin-sdk/network/dependents?package_id=UGFja2FnZS00NjU2MTU0MTY%3D) [项目](https://github.com/search?q=adminupgradeabilityproxy&type=Code)使用此模式进行升级，例如[dYdX](https://github.com/dydxprotocol/perpetual/blob/99962cc62caed2376596da357a13f5c3d0ea5e59/contracts/protocol/PerpetualProxy.sol), [PoolTogether](https://github.com/pooltogether/pooltogether-pool-contracts/tree/6b7eba5c610a61e4e44f8df95fdf3d1d2f1e0fa5/.openzeppelin), [USDC](https://github.com/centrehq/centre-tokens/tree/b42cf04b31639b8b05d53fea9995954d5f3659d9/contracts/upgradeability), [Paxos](https://github.com/paxosglobal/pax-contracts/tree/2650b8049f2f1fe53ebb3f5a0979241c4da9f1a5#upgradeability-proxy)，[AZTEC](https://github.com/AztecProtocol/AZTEC/blob/cb78ba3ee32ad82234ac0fbed046333eb7f233cf/packages/protocol/contracts/AccountRegistry/AccountRegistryManager.sol#L62-L66)和[Unlock](https://github.com/unlock-protocol/unlock/blob/5d3ed7519e3fe3c75ef7220468d7a8ae716db194/smart-contracts/contracts/Unlock.sol#L30)。

但是，透明代理模式有一个缺点： gas 成本。每个调用都需要额外的从存储中加载admin地址，这个操作[在去年的伊斯坦布尔分叉之后变得更加昂贵](https://forum.openzeppelin.com/t/openzeppelin-upgradeable-contracts-affected-by-istanbul-hardfork/1616)。此外，与其他代理相比，该合约本身的部署成本很高， gas 超过70万。

### 通用可升级代理

作为透明代理的替代，[EIP1822](https://eips.ethereum.org/EIPS/eip-1822)定义了通用的可升级代理标准，或简称为“ UUPS”。该标准使用相同的委托调用模式，但是将升级逻辑放在实现合约中，而不是在代理本身中。

请记住，由于代理使用委托调用，因此实现合约始终会写入代理的存储中，而不是写入自己的存储中。实现地址本身保留在代理的存储中。并且修改代理的实现地址的逻辑同样在实现逻辑中实现。 UUPS建议所有实现合约都应继承自基础的“可代理**proxiable**”合约：

```javascript
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



这种方法有几个好处。首先，通过在实现合约上定义所有函数，它可以依靠Solidity编译器检查任何函数选择器冲突。此外，代理的大小要小得多，从而使部署更便宜。在每次调用中，从存储中需要读取的内容更少，降低了开销。

这种模式有一个主要缺点：如果将代理升级到没有可升级函数的实现上，那就永久锁定在该实现上，无法再更改它。一些开发人员更喜欢保持可升级逻辑不变，以防止出现这些问题，而这样做的最佳方式是放在代理合约本身。

### 代理存储冲突和非结构化存储

在所有代理模式变体中，代理合约都需要至少一个状态变量来保存实现合约地址。默认情况下，[Solidity存储变量](https://learnblockchain.cn/docs/solidity/internals/layout_in_storage.html)在智能合约存储中的顺序是：声明的第一个变量移至插槽0，第二个变量移至插槽1，依此类推(映射和动态大小数组是此规则的例外)。这意味着，在以下代理合约中，实现合约地址将保存到存储插槽零。

```
// Sample code, do not use in production!
contract Proxy {
    address implementation;
}
```


现在，如果我们将该代理与以下看似无害的实现合约结合使用，会发生什么？

```
// Sample code, do not use in production!
contract Box {
    address public value;

    function setValue(address newValue) public {
        value = newValue;
    }
}
```


遵循Solidity存储布局规则，通过代理对Box.setValue的任何调用都会将newValue存储在存储插槽零中。但是请记住，由于我们正在使用委托调用，因此受影响的存储将是代理的存储，而不是实现合约。因此，调用`Box.setValue`会意外覆盖代理实现地址，我们绝对不希望发生这种情况。

解决此问题的最简单方法是让Box声明一个虚拟的第一个变量。这会将合约的所有变量向下推一格，从而避免冲突。

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


尽管有效，但它有一个缺点，即要求所有委托目标合约都添加此额外的虚拟变量。这限制了可重用性，因为普通合约不能用作实现合约。这也容易出错，因为很容易忘记在合约中添加该额外变量。

为避免此问题，[非结构化存储模式](https://blog.openzeppelin.com/upgradeability-using-unstructured-storage/)被引入。此模式模仿Solidity如何处理[映射和动态大小的数组](https://learnblockchain.cn/docs/solidity/internals/layout_in_storage.html#id2)：它不是将实现地址变量存储在第一个插槽中，而是存储在存储中的任意插槽中，确切地说是` 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`。由于合约的可寻址存储大小为2 ^ 256，因此发生冲突的机会实际上为零。

```
// Sample code, do not use in production!
contract Proxy {
    fallback() external payable {
        address implementation = sload(0x360894...382bbc);
        implementation.delegatecall.value(msg.value)(msg.data);
    }
}
```



这样，实现合约业务逻辑将使用存储的第一个插槽，而代理将使用更高的插槽以避免任何冲突。出于工具性目的，[EIP1967](https://eips.ethereum.org/EIPS/eip-1967)中已对委托调用代理所使用的插槽进行了标准化。这允许诸如[Etherscan](https://medium.com/etherscan-blog/and-finally-proxy-contract-support-on-etherscan-693e3da0714b)浏览器能轻松识别这些代理(因为在该特定插槽中具有类似地址值的任何合约很可能是代理)并解析出对应的合约的地址。

这种模式有效地解决了实现合约中的任何存储冲突问题，除了代理实现的额外复杂性外，没有任何缺点。

### 存储布局与追加存储和永久存储的兼容性

合约升级在存储方面带来了另一个挑战，在此案例中，不是在代理和实现之间，而是在实现的两个不同版本之间。假设我们在代理后面部署了以下实现合约：

```javascript
contract OwnedBox {
    address owner;
    uint256 number;

    function setValue(uint256 newValue) public {
        require(msg.sender == owner);
        number = newValue;
    }
}
```




几个月后，一个新的开发人员出现并对该合约进行了一些更改。作为新更改的一部分，他们决定按字母顺序对状态变量进行排列(只是因为他们想要)，并在生产中升级合约。

```javascript
contract OwnedBox {
    uint256 number;
    address owner;
    …
}
```


请记住，Solidity编译器是如何决定将变量映射到合约存储的：它基于声明变量的顺序。这意味着，升级后，“number”的值现在位于分配给“owner”的插槽中，反之亦然。

这显示了智能合约升级的主要局限性：尽管可以随意更改合约代码，但只能对其状态变量进行与存储兼容的更改。对变量进行重新排序，插入新变量，更改变量的类型，甚至更改合约的继承链之类的操作都可能破坏存储。唯一安全的更改是在任何现有变量之后追加状态变量。 OpenZeppelin升级[文档](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#modifying-your-contracts)包含禁止操作的完整列表，并且OpenZeppelin升级插件会在升级过程中自动检查它们。

确保存储在所有升级中保持兼容的一种开发实践是使用“仅追加”存储合约。在这种模式下，存储声明是在单独的Solidity存储合约上，这样就仅允许附加新变量，而不会删除变量。然后，实现合约继承此存储合约来进行存储访问。

```javascript
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



然后，每次需要添加新的状态变量时，都可以继承存储合约。 Solidity 确保变量可以根据继承链的顺序存储在存储中，因此在扩展合约添加新变量可确保将其附加到现有变量之后。例如，Compund [使用此模式](https://github.com/compound-finance/compound-protocol/blob/v2.8.1/contracts/ComptrollerStorage.sol#L97)来更改其Comptroller合约。

```javascript
// Sample code, do not use in production!
contract OwnedBoxStorage {
    address internal owner;
    uint256 internal number;
}

contract OwnedBoxStorageV2 is OwnedBoxStorage {
    uint256 internal newNumber;
}
```


但是，这种方法有一个主要缺点：继承链中的所有合约都必须遵循这种模式以防止混淆。这包括来自定义状态的外部库合约。

在处理继承链中的基类合约时，仅追加存储需要特别注意。让我们来看下面的例子：

```javascript
contract Base {
    uint256 base1;
    uint256 base2;
}

contract Child is Base {
    uint256 child1;
    uint256 child2;
}
```



Solidity编译器会将这些变量按以下顺序放置在存储插槽中：base1，base2，child1，child2。这意味着，如果我们要向`Base`添加一个新的状态变量，它将代替`child1`。

仍然有解决此问题的方法：通过声明伪变量，我们可以在基类合约中的为将来的状态变量“保留”空间。在Solidity中声明一个未使用的变量不会消耗 gas ，但会降低为合约中其他变量分配的位置。 OpenZeppelin Contracts的upgrade-safe分支在该库的所有合约中[使用此模式](https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/master/contracts/access/Ownable.sol#L78)。

为解决存储布局兼容性而开发的另一种模式是[外部存储模式](https://blog.openzeppelin.com/smart-contract-upgradeability-using-eternal-storage/)。该模式使用与*非结构化存储*相同的策略，但用于实现合约的所有变量。这意味着实现合约从不声明自己的任何变量，而是将其存储在映射中，这使Solidity根据其分配的名称将其保存在任意存储位置。

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


例如，[Hyperbridge](https://github.com/hyperbridge/protocol/blob/cf360f81ddf075b4ec17e798365cf81b97926238/packages/token/smart-contracts/ethereum/contracts/EternalStorage.sol)和[Polymath](https://github.com/PolymathNetwork/polymath-core/blob/v3.0.0/contracts/datastore/DataStoreStorage.sol)将这种模式用于各自的协议合约。尽管它保证在升级过程中不会出现问题，但它要求对所有合约的编码方式进行重大更改，与不遵循此约定的合约不兼容，并且会产生更加吝啬难懂的代码。除非常量用于映射键，否则使用字符串标识变量也可能导致由于拼写问题引起的错误。

也有一些建议可以在语言级别解决此问题，例如允许[指定变量的位置](https://github.com/ethereum/solidity/issues/597) (自2016年5月以来一直在讨论中)，或者让合约在[根据变量名称的哈希计算出的槽位中分配其变量](https://github.com/ethereum/solidity/issues/8353) (如在永久存储中)。在实施这些方法之前，最好的选择仍然是对升级进行大量测试，并用自动工具对它们进行补充，以验证引入的更改。

### 实现合约限制和初始化

即使在非结构化代理模式下，实现合约也有一些限制。 [OpenZeppelin升级文档](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable)中详细说明了这些限制，影响最大的的是不能使用构造函数。

在Solidity中，合约构造函数不属于要部署的合约运行时代码的一部分。它实际上是与合约部署一起发送的代码，但是在执行后会被丢弃。因此，一旦实现合约被创建，就无法再调用其构造函数代码。这意味着代理无法调用构造函数来初始化状态。

要解决此问题，需要将构造函数更改为常规函数，通常称为*initializers*。由于这些是常规函数，因此它们会编译到合约中，并且可以由代理进行委托调用以在部署合约时对其进行初始化。但是，由于它们也是常规函数，因此需要其他逻辑以确保只能被调用一次。

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


为方便起见，OpenZeppelin合约包含一个[基础可初始化合约](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/proxy/Initializable.sol)提供实现此模式的`initializer`修饰符。

请注意，这还要求任何依赖的智能合约库也必须遵循此模式。这也让OpenZeppelin 一直[维护合约upgrade-safe分支](https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/)库，其中的构造函数已被初始化函数替代，尽管我们一直在努力在不远的将来删除[对它的需要](https://forum.openzeppelin.com/t/planning-the-demise-of-openzeppelin-contracts-evil-twin/1724)。

另一种实践是[不允许自毁操作](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#potentially-unsafe-operations)。如果用户[偶然](https://github.com/openethereum/openethereum/issues/6995)直接调用你的实现合约并恰好执行此函数，该实现合约将被销毁，所有代理会保留但是没有了代码，从而无法使用。而且，如果用于管理升级的逻辑位于实现合约中而不位于代理中(如在UUPS中)，则实际上会[导致再也无法使用代理](https://blog.openzeppelin.com/parity-wallet-hack-reloaded/).

### 钻石标准下的多个实现合约

到目前为止，在我们探索的所有代理变体中，每个代理都有一个实现合约的支持。但是，单个代理可以委托多个合约。其首先在OpenZeppelin实验室的[vtable可升级性](https://github.com/OpenZeppelin/openzeppelin-labs/tree/master/upgradeability_with_vtable)中有过探讨，这种模式进化成了[Nick Mudge](https://github.com/mudgen/) 在[EIP2535](https://eips.ethereum.org/EIPS/eip-2535)提出的[钻石合约](https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb)标准，目前正由[nayms](https://github.com/nayms/contracts/blob/master/contracts/base/DiamondProxy.sol)等项目使用。

在此版本中，代理不存储单个实现地址，而是存储从函数选择器到实现地址的映射。收到调用时，它会查找内部映射(类似于[动态分配中使用的vtable](https://en.wikipedia.org/wiki/Virtual_method_table))检索哪个逻辑合约为请求的函数提供实现。


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


这种模式有一些优点。首先，它允许通过将其实现拆分为多个合约来突破最大合约规模限制（译者注： 合约大小有 24kb 限制）。它还允许进行更精细的升级，一次只能更改一个特定函数。

![](https://img.learnblockchain.cn/2020/10/15/16027249726170.jpg)

但是，这种灵活性有其局限性。一方面，多个实现合约都会写入代理存储，可能会导致不同实现之间的存储冲突。不过通过在钻石模式中使用非结构化存储变体解决了此问题，其中每个实现的存储都定义为结构体并[存储在任意存储位置](https://medium.com/1milliondevs/new-storage-layout-for-proxy-contracts-and-diamonds-98d01d0eadb)与避免冲突。但是，如果不同的实现需要访问相同的存储，则它们需要从相同的基类存储合约继承，这需要在所有已部署的实现合约之间保持一致。

这种模式还使在同一合约内的代码重用更加困难：在多个实现中调用的辅助函数需要包含在所有合约中(可通过继承来实现)，也必须在vtable中定义为单独的函数(要求是外部函数，而不是内部函数，以及需要进行额外的gas和许可检查)。

不过，这种强制拆分可以帮助实现智能合约系统中良好的模块化和关注点分离。

### 使用信标同时升级多个代理

虽然每个代理有多个实现合约确实很有趣，但现在让我们讨论相反的情况：每个实现有多个代理。当我们介绍代理模式时，我们强调了一个逻辑合约可以用作多个代理的实现，因为每个代理都拥有自己的状态。但是，在此案例中，如果我们发现实现中的漏洞并部署了修复程序，则我们将不得不单独升级每个代理，如果部署了多个代理，那么这将很麻烦(且昂贵)。

来到[信标样式](https://blog.dharma.io/why-smart-wallets-should-catch-your-interest/)吧，最早由[0age](https://github.com/0age)在[Dharma Smart Wallet](https://github.com/dharma-eng/dharma-smart-wallet/tree/master/contracts/upgradeability)中引入这种模式，每个代理合约保存的地址不是其实现合约的地址，而是一个*beacon*的地址，而由*beacon*保存了实现地址。每当代理收到调用时，它都会向信标请求当前使用的实现。只需更改存储在信标中的地址，即可在单个交易中升级共享信标的所有代理。

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



这种模式还有另一个优势：代理不需要在自己的存储中保留任何内容，从而完全不需要非结构化存储。由于代理总是指向相同的信标，因此信标地址可以[存储在代码中而不是存储中](https://solidity.ethereum.org/2020/05/13/immutable-keyword/)，降低了 gas 成本。信标本身也可以设计为通过[Create 2 变形合约](#将CREATE2与变形合约一起使用)来实现地址保存在代码中。

![](https://img.learnblockchain.cn/2020/10/15/16027250188401.jpg)



请注意，通过允许信标本身可以更改，可以将传统的可升级代理方法和信标方法结合起来。这允许代理的所有者“分叉”到另一个信标。但是，这导致执行和部署中的更高gas 成本。

### EIP1167的不可升级代理

尽管它们在有关升级的文章中没有位置，但是如果我们在代理上花了太多时间后没有提到“不可升级代理”，那将是不公平的。这些代理称为“最小代理”，并在[EIP1167](https://eips.ethereum.org/EIPS/eip-1167)中进行了标准化.

如果不进行升级，为什么还要麻烦代理？答案是当需要多个合约实例时减少部署成本。部署一个大型合约的多个副本 gas 成本方面可能会非常昂贵，因此部署单个副本作为实现合约，并多个代理的后端，会更具成本效益。现在，由于不需要升级这些代理，则它们不需要任何存储或管理函数，因此变得非常简单：

```javascript
// Sample code, do not use in production!
contract MinimalProxy {
    fallback() external payable {
        return IMPLEMENTATION_ADDRESS.delegatecall.value(msg.value)(msg.data);
    }
}
```



实际上，这些代理是如此简单，以至于它可以在下面的45个字节的汇编中实现。如果你想了解它是如何工作的， [马丁·阿贝特马科](https://twitter.com/tinchoabbate)已经写了一篇很棒的文章[深入研究此代码](https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/)。

```
3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
```



### 将CREATE2与变形合约一起使用

现在，结束本节，让我们回顾一下由[0age](https://github.com/0age)提出的最后一种升级模式提到的[变形合约](https://medium.com/@0age/the-promise-and-the-peril-of-metamorphic-contracts-9eb8b8413c5e)。

这种模式与到目前为止所讲述模式有很大的不同：它在升级期间保留了合约地址，但没有保留其状态，从技术上来说，这违反了本文开头给出的可升级性定义。这大大减少了可部署的场景。但是，与代理模式相比，它具有一些主要优势。

此模式依赖[CREATE2操作码](https://blog.openzeppelin.com/getting-the-most-out-of-create2/)，CREATE2在[EIP1014](https://eips.ethereum.org/EIPS/eip-1014)中引入。该操作码用来控制将要部署合约的地址。使用CREATE2部署合约时，其地址由合约部署代码、发送方和盐确定。此操作码的最初动机是其在反事实实例化中的使用，在[通用状态通道](https://l4.ventures/papers/statechannels.pdf)使用，但很快他们被使用可升级中。

诀窍在于，部署地址不是根据合约代码计算，而是根据合约*部署*的代码计算的。部署代码是执行任何必要初始化(即运行构造函数)后，返回的创建合约的代码(通常在其中有硬编码)。但是，部署代码也可以从其他地方(例如可变注册表)获取。这样可以通过使用相同的工厂合约和相同的哈希**将不同的代码部署到相同的地址**。将此与[selfdestruct操作码](https://solidity.readthedocs.io/en/v0.7.0/introduction-to-smart-contracts.html#deactivate-and-self-destruct)结合使用清除合约代码，并且我们已经建立了自己的机制来更改地址中的代码。

请注意，此方法不需要使用代理合约，也不需要合约将其构造函数更改为初始化函数。如果没有这个主要缺点，那将是理想的可升级性方法，这个缺点是调用selfdestruct不仅可以清除合约代码，还会清除合约状态。此外，selfdestruct不会立即清除代码-它只会在交易结束时清除。这意味着升级需要进行两笔交易：一笔是删除当前合约，另一笔是创建新合约。在这两笔交易之间，任何对我们合约的交易都将失败，实际上为为升级引入了“停机时间”。

但是，在某些情况下，变形合约仍然有用。仅包含逻辑的合约(类似于Solidity外部库)是最明显的候选对象。另一个用途是很少状态且变化很少的合约，例如信标。在这些情况下，状态甚至可以嵌入到代码中，从而使访问代码更便宜，并且只要需要更改状态，就可以“升级”合约。

## 升级治理

介绍完升级面临的技术挑战，现在该关注治理。通过治理，我们指的是**如何做出升级智能合约的决定**：是由单个受信方立即集中进行还是所有利益相关方通过投票过程进行。

治理对于升级至关重要。无论你的升级解决方案在技术上多么扎实，如果没有适当的项目治理，可升级性从根本上是有缺陷的。智能合约以及区块链技术最终的承诺就是去除信任，一旦开发人员可以单独更改系统以抢走所有参与者的资金，这种承诺就会瓦解。缺乏适当的治理方案通常会导致批评者将可升级性视为在智能合约系统中[漏洞](https://medium.com/consensys-diligence/upgradeability-is-a-bug-dba0203152ce)。

值得一提的是，没有通用的治理解决方案。不同的系统将需要不同的方案。例如，代币授予合约(授予者随时间推移向被授予者奖励代币)可以仅由所涉及协议的两方来管理。如果他们两方都同意对合约的规则进行更改，则他们就可以这样做。但是，更复杂的系统将需要更复杂的解决方案。让我们来看看。

### 外部所有者

具有外部所有者帐户(简称EOA)是管理升级的最中心化的方式。握有 关键key 的用户可以控制整个系统。毋庸置疑，这远非理想之举：这不仅使所有用户的命运依赖单点，而且还存在安全风险。如果EOA的密钥被泄露，则整个系统都将面临风险。

因此，EOA仅在开发期间才可以接受。一旦系统在主网上投入生产，就应将其转移到下一步：多签名钱包。

### 多签名钱包

多签名钱包合约是具有多个所有者的合约，当预定义数量的所有者达成协议时，它们可以执行任意操作。流程很简单：其中一个所有者提出要执行的新操作，其他所有者签署协议，并且在达到阈值时，从合约发送该操作。

通常设置多签名钱包来代表团队管理大笔资金，但也可以将其设置为系统管理员。这样，对系统的任何更改(无论是设置新费用还是更改合约代码)都需要由多个所有者批准。为了进一步促进权力下放，这些所有者可以属于不同的团队，只要他们是系统的值得信赖的利益相关者即可。

![](https://img.learnblockchain.cn/2020/10/15/16027250926944.jpg)


注意，单个用户其实也可以使用多签，其中附加key代表充当多因素身份验证器的附加设备。出于安全目的，即使对于单人团队，多签名也是一个不错的选择。

总而言之，多签在逐步分权的道路上大有帮助。然而，大多数项目最终都采用了一种方案：将控制权通过投票权转移给社区。但是在开始探讨投票之前，让我们探讨其他多签相关的方法。

###  时间锁（Timelocks）

当我们谈论时间锁*（timelocks）*时，我们指的是对影响系统的每个更改强制执行时间延迟。在具有时间锁的多签治理中，一旦达到批准阈值，每个提案都不会立即执行，而是要等待几小时或更长时间(通常是几天)才能执行生效。例如[dYdX](https://defiwatch.net/admin-key-config-and-opsec/project-reviews/dydx)通过[修改后的Gnosis MultisigWallet合约](https://etherscan.io/address/0xba2906b18b069b40c6d2cafd392e76ad479b1b53#code)实现此模式。

时间锁的目的是 如果用户不同意协议的改变（不管是代码升级还是增加协议费用）允许用户有时间退出系统。如果没有适当的控制，用户不仅需要信任系统，还需要信任管理员，因为他们可以随时在没有事先警告进行任何可能的更改。

但是，时间锁引入了一个问题。尽管在对系统的机制进行修改之前，这是一个很好的做法，但是当引入的修改用来修复关键漏洞时，它们是一个问题。在这些情况下，我们希望能够立即部署修补程序。但是我们不能允许管理员绕过时间锁。那么在这些情况下我们该如何处理？

### 可暂停

我们说系统是可暂停的，指的是可以将系统设置为冻结所有操作的模式。例如，可以指示ERC20在紧急情况下暂停和停止所有转账，安全地保留每个帐户的余额，例如[USDC代币](https://github.com/centrehq/centre-tokens/blob/5013157edecbaf5da7fb9e3afa85992965077c88/contracts/v1/FiatTokenV1.sol#L272-L275)。

暂停开关是一种很好的保障，它使你和你的团队有时间对问题做出反应并计划进行升级以修复当前的漏洞。无论是否设置了时间锁，此设置均有效。请记住，当遇到智能合约系统中的危险问题时，你是无法使服务下线的。合约位于区块链上，无论你做什么，区块链都将继续运行。

暂停系统的权利通常是中心化的。这样一来，团队中受信任的开发人员就可以在检测到问题后立即停止操作，从而避免造成更大的危害。但是，暂停的时间需要受到限制。你不希望有人可以通过永久暂停系统来单方面保持赎金。系统可以保持暂停的时间应限制为几个小时或几天。

请注意，如果执行不当，暂停可能会抵消时间锁定的影响。管理员团队可以在推进不受欢迎的(并非恶意)升级时暂停系统，从而使用户成为人质，并且在更改生效之前无法退出。通过引入逃生舱口可以缓解这种情况。

### 逃生舱口

“逃生舱口”是智能合约中编码的一种机制，即使暂停，该机制也允许用户退出系统。退出系统的含义取决于系统本身。

例如，MakerDAO具有[紧急关闭](https://blog.makerdao.com/introduction-to-emergency-shutdown-in-multi-collateral-dai/)机制，其暂停整个系统但又允许用户可提取资产。该关系可以通过社区投票(与系统中的大多数其他更改一样)来执行，也可以由受信任的预言机独自执行。再举一个例子，Dharma具有[最小钱包实现](https://github.com/dharma-eng/dharma-smart-wallet/blob/376c359209945470c841cbf5462b7d314ac40076/contracts/implementations/smart-wallet/AdharmaSmartWalletImplementation.sol#L9-L17)提供了逃生舱口功能，并且在发生紧急情况时可以推出。

逃生舱口是用户离开系统的最后办法。但是，需要仔细实现它们：逃生舱口机制本身中的漏洞可能使系统无能为力，而攻击者可能会利用它来耗尽其资金。

### 提交-披露 升级方式

伴有逃生舱口的暂停机制的替代方法是使用”提交-披露“升级。基于时间锁升级修复漏洞还有一个问题是，容易对修复程序进行反向工程以了解到其修补的漏洞。这样，将在几天内实施的升级发布可能会向攻击者某种信号，表明系统存在有待利用的问题，他们可以在这段时间内自由地行动。

或者，系统的开发人员可以推动“隐藏”升级。他们不公开升级的代码，而是向一群可以公开担保的受信任的安全顾问公开，他们只是创建带有升级哈希值的提案(提交阶段)。时间锁周期结束后，他们在实际发布(披露阶段)升级并立即应用它。

此机制[正在MakerDAO社区中讨论中](https://forum.makerdao.com/t/mip15-dark-spell-mechanism/2578)，在“黑暗咒语”的名称下，因为在Maker上下文中的每个更改建议都称为“咒语”。请注意，此机制仅阻止发出问题信号，如果已经利用此漏洞，则无济于事。

### 投票

渐进式权力下放道路的最后一步是授予社区投票权，以进行系统的管理。这需要一种表示投票权的方法，通常是通过管理代币来完成的，例如[MakerDAO中的MKR](https://vote.makerdao.com/)或[Compound的COMP ](https://compound.finance/governance)。代币持有者然后可以使用其代币投票赞成或反对对系统的更改。

![](https://img.learnblockchain.cn/2020/10/15/16027251359356.png)

上面列出的许多机制(暂停、逃生窗口、提交披露)都可以与投票结合使用。请注意，投票会天然地延迟执行更改，因为设置投票提案通常需要将提案保留几天的时间，以便有时间让所有感兴趣的利益相关者表达意见。这意味着通常需要在投票的同时有相应的漏铜修复的机制。

## 结论



升级是智能合约系统中的强大工具，既可用于迭代开发，又可在发生漏洞时保护用户。在过去的几年中，升级的使用已在主流项目中变得越来越普遍，并采用了许多模式来解决由此带来的技术和社会挑战。

在OpenZeppelin，我们相信升级将成为智能合约开发人员工具集不可或缺的一部分，并且我们将继续致力于开源解决方案，以使其更易于访问和使用，并为我们已经支持的模式提供更多模式。

欢迎转到[OpenZeppelin社区论坛](https://forum.openzeppelin.com/)加入有关升级等的讨论！



##  参考文献

1. [https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f](https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f)
2. [https://blog.openzeppelin.com/proxy-patterns/](https://blog.openzeppelin.com/proxy-patterns/)
3. [https://blog.openzeppelin.com/smart-contract-upgradeability-using-eternal-storage/](https://blog.openzeppelin.com/smart-contract-upgradeability-using-eternal-storage/)
4. [https://blog.openzeppelin.com/towards-frictionless-upgradeability/](https://blog.openzeppelin.com/towards-frictionless-upgradeability/)
5. [https://blog.openzeppelin.com/the-transparent-proxy-pattern/](https://blog.openzeppelin.com/the-transparent-proxy-pattern/)
6. [https://docs.openzeppelin.com/upgrades-plugins/](https://docs.openzeppelin.com/upgrades-plugins/)
7. [https://blog.indorse.io/ethereum-upgradeable-smart-contract-strategies-456350d0557c](https://blog.indorse.io/ethereum-upgradeable-smart-contract-strategies-456350d0557c)
8. [https://medium.com/coinmonks/summary-of-ethereum-upgradeable-smart-contract-rd-part-2-2020-db141af915a0](https://medium.com/coinmonks/summary-of-ethereum-upgradeable-smart-contract-r-d-part-2-2020-db141af915a0)
9. [https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201](https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201)
10. [https://medium.com/@0age/the-promise-and-the-peril-of-metamorphic-contracts-9eb8b8413c5e](https://medium.com/@0age/the-promise-and-the-peril-of-metamorphic-contracts-9eb8b8413c5e)
11. [https://blog.dharma.io/why-smart-wallets-should-catch-your-interest/](https://blog.dharma.io/why-smart-wallets-should-catch-your-interest/)
12. [https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb](https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb)
13. [https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/](https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/)



------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。