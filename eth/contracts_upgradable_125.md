原文链接：https://hackernoon.com/how-to-make-smart-contracts-upgradable-2612e771d5a2

# 写出可升级的智能合约！

![1_75FbnguPLUrHrruR8Ee3JQ.jpg](https://img.learnblockchain.cn/attachments/2022/05/ulFftgUr6294338248350.jpg)

​		随着其自身发展，智能合约已经远非一个基础的“合约”而已了。 现在我们用智能合约创造了一整个生态！但是无论我们编码如何小心，测试如何细致，如果我们的系统变得复杂起来，就免不了更新逻辑去打补丁修bug，抵御恶意攻击或者增加必要的特性。有时，我们甚至需要升级合约去应对EVM的改变或者新发现的漏洞。

​		一般来说，开发者升级自己的软件很容易，但是区块链不一样，因为它们是不可变的。合约一旦部署，就不能反悔了。然而通过一些技术，我们可以在新地址部署一个新合约并使老合约无效化。下面所讲就是写可升级合约的几个最普遍的技术。

### 主从合约(Master-Slave contracts)

​		主从合约是智能合约可升级化最基础和易懂的技术之一。这个方法就是在部署其他所有合约的同时，部署一个主合约( master contract )。主合约储存其他所有合约的地址，并在需要查询时返回他们。这些合约就是作为"从合约"(slave contract)，他们需要和其他合约交互时都要去主合约那里查询最新的合约地址。我们只需要把新的从合约部署上去然后在主合约上修改地址记录，既可以完成合约升级了。 这自然不是开发可升级合约的最佳方法，但确是最简单的。这种方法有很多限制，比如老合约的数据和账户很难迁移到新合约。

### 永久存储合约(Eternal Storage contracts)

​		这个技术就是我们人为把逻辑合约( logic contract )和数据合约( data contract)分开。 数据合约做成永久的，不可升级的。逻辑合约可能多次升级，而数据合约去响应它的变化。 这个相当基础的方案有一个明显缺陷， 就是在数据合约不可升级的情况下，一旦存储有个bug或被攻击会导致所有的数据都不可用了。这个技术的另一个问题就是逻辑合约想要获取或者操作数据需要额外的一层调用，也就是产生额外的gas费了。它通常和主从合约结合使用，以改善合约内部的通信。

### 可升级存储代理合约(Upgradable Storage Proxy Contracts)

​		我们可以通过让永久存储合约( eternal storage contracts )给逻辑合约做代理，以避免额外支出gas。代理合约(proxy contract)和逻辑合约继承自同一个存储合约，导致他们的存储在EVM中对齐。 代理合约的回退函数会委托调用逻辑合约，使得逻辑合约可以在代理中修改存储区。代理合约是永久的。 这使得我们省下了额外的gas，就算要多次修改存储区，也只有一次委托调用。

#### 该技术的三个组件：

1. **代理合约(Proxy contract)**: 它作为永久的存储合约并委托调用逻辑合约
2. **逻辑合约(Logic contract)**: 它会处理所有的数据
3. **存储结构(Storage structure)**: 它包含存储的结构，并被前两者同时继承，所以它们的存储指针在区块链上同步。



![img](https://hackernoon.com/hn-images/1*8MeHhV-S4XH3gHyPd0VL4Q.png)





#### 委托调用(Delegate Call)

​		这项技术依托于EVM的一个opcode:  `DELEGATECALL `，`DELEGATECALL`就像一个平常的`CALL`，不同点是`DELEGATECALL` 在目标地址调用时使用的是调用合约(就是调用`DELEGATECALL` 的合约)的上下文，同时保留原调用者的msg.sender和msg.value。因此使用`DELEGATECALL`的时候，代码是在目标合约执行，但是存储，地址和账户余额用的都是调用合约。换句话说`DELEGATECALL` 基本允许目标合约对调用者合约的存储区做任何事。

​		我们将利用这点优势，创造一个委托调用逻辑合约的代理合约，以使得自由更改逻辑合约的情况下保持代理合约里数据的安全。

#### 怎么使用可存储代理合约？

​		让我们深挖一点细节。我们需要创建的第一个合约是存储结构合约。它声明了所有的存储变量，又同时被代理合约和执行/逻辑合约继承。It will look something like 类似于这样

```solidity
contract StorageStructure {
	address public implementation;
	address public owner;
	mapping (address => uint) internal points;
	uint internal totalPlayers;
}
```

​		我们还需要一个执行/逻辑合约，我们创建一个简单的合约，新玩家加入时不增加totalPlayers计数。

```solidity
contract ImplementationV1 is StorageStructure {
	modifier onlyOwner() {
		require (msg.sender == owner);
		_;
	}

	function addPlayer(address _player, uint _points) public onlyOwner {  
    require (points[_player] == 0);  
    points[_player] = _points;  
	}

	function setPoints(address _player, uint _points) public onlyOwner {
		require (points[_player] != 0);
		points[_player] = _points;}
	}


```

下边是最重要的，代理合约

```solidity
contract Proxy is StorageStructure {

	modifier onlyOwner() {  
    require (msg.sender == owner);  
    _;  
	}  

/*  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") constructor that sets the owner address  
 */  
	constructor() public {  
    owner = msg.sender;  
	}  

/*
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Upgrades the implementation address  
 * [@param](http://twitter.com/param "Twitter profile for @param") \_newImplementation address of the new implementation  
 */  
	function upgradeTo(address _newImplementation) external onlyOwner {  
    require(implementation != _newImplementation);  
    _setImplementation(_newImplementation);  
	}  

/*  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Fallback function allowing to perform a delegatecall   
 * to the given implementation. This function will return   
 * whatever the implementation call returns  
 */  
function () payable public {  
    address impl = implementation;  
    require(impl != address(0));  
    assembly {  
        let ptr := mload(0x40)  
        calldatacopy(ptr, 0, calldatasize)  
        let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)  
        let size := returndatasize  
        returndatacopy(ptr, 0, size)  
          
        switch result  
        case 0 { revert(ptr, size) }  
        default { return(ptr, size) }  
    }  
}  

/*
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Sets the address of the current implementation  
 * [@param](http://twitter.com/param "Twitter profile for @param") \_newImp address of the new implementation  
 */  
	function _setImplementation(address _newImp) internal {  
    implementation = _newImp;  
	}  


}


```

​		为了让合约生效，我们需要先部署Proxy和ImplementationV1然后调用Proxy合约的`upgradeTo(address)` ，同时我们不再理会ImplementationV1的地址，现在我们忘掉ImplementationV1的合约地址然后把Proxy作为我们的主合约。

​		为了升级合约我们需要再创建一个逻辑合约的实现ImplementationV2，看起来是这样的：

```solidity
contract ImplementationV2 is ImplementationV1 {
	function addPlayer(address _player, uint _points) public onlyOwner   {  
    require (points[_player] == 0);  
    points[_player] = _points;  
    totalPlayers++;  
	}
}
```
> 你应该注意到这个合约依然继承了存储结构合约，尽管是间接继承。

​		所有的具体实现合约都必须继承自存储结构合约，并且在代理合约部署后不可更改，以避免代理合约的存储区的意外覆盖。

​		为了升级具体实现的合约，我们在网络上部署ImplementationV2然后调用`upgradeTo(address)`同时不再理会ImplementationV2的地址

 		这个技术使得升级我们合约的逻辑变得简单，但是这依然不允许我们升级合约的存储结构，我们将用非结构化代理合约解决这个问题。

### 非结构化可升级存储代理合约(Unstructured Upgradable Storage Proxy Contracts)

​		这是合约可升级化的最先进方法之一。它通过存储执行合约和保存在固定位置的所有者的地址来保证数据不被执行/逻辑合约覆盖。我们可以使用`sload`和`sstore`操作码根据固定指针来直接读/写特定存储槽。

​		这种方法利用了[状态变量在存储中的布局](https://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage)从而避免固定位置被逻辑合约覆盖。我们如果设置 `0x7` 为固定位置那么前七个存储槽被使用后它就会被覆盖。为了避免这种事，我们用`keccak256(“org.govblocks.implemenation.address”)`来设置固定位置。

​		这就消解了代理合约继承存储结构合约的必要性，也就是我们现在可以升级存储结构合约了，然后升级存储结构合约依然难办，我们需要确保修改后新的存储布局和老的匹配。

#### 该技术的两个组件：

1. 代理合约: 它在一个固定地址存储执行合约的地址，并对其委托调用。

2. 执行合约: 它作为主合约，保存所有的逻辑和数据结构。

> 你甚至可以将此技术运用到现在的合约上，而不对执行合约做任何改动。

代理合约类似这样：

```solidity
contract UnstructuredProxy {

// Storage position of the address of the current implementation  
bytes32 private constant implementationPosition =   
    keccak256("org.govblocks.implementation.address");  

// Storage position of the owner of the contract  
bytes32 private constant proxyOwnerPosition =   
    keccak256("org.govblocks.proxy.owner");  

/**  
* [@dev](http://twitter.com/dev "Twitter profile for @dev") Throws if called by any account other than the owner.  
*/  
modifier onlyProxyOwner() {  
    require (msg.sender == proxyOwner());  
    _;  
}  

/**  
* [@dev](http://twitter.com/dev "Twitter profile for @dev") the constructor sets owner  
*/  
constructor() public {  
    _setUpgradeabilityOwner(msg.sender);  
}  

/**  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Allows the current owner to transfer ownership  
 * [@param](http://twitter.com/param "Twitter profile for @param") _newOwner The address to transfer ownership to  
 */  
function transferProxyOwnership(address _newOwner)   
    public onlyProxyOwner   
{  
    require(_newOwner != address(0));  
    _setUpgradeabilityOwner(_newOwner);  
}  

/**  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Allows the proxy owner to upgrade the implementation  
 * [@param](http://twitter.com/param "Twitter profile for @param") \_implementation address of the new implementation  
 */  
function upgradeTo(address _implementation)   
    public onlyProxyOwner  
{  
    _upgradeTo(_implementation);  
}  

/**  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Tells the address of the current implementation  
 * [@return](http://twitter.com/return "Twitter profile for @return") address of the current implementation  
 */  
function implementation() public view returns (address impl) {  
    bytes32 position = implementationPosition;  
    assembly {  
        impl := sload(position)  
    }  
}  

/**  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Tells the address of the owner  
 * [@return](http://twitter.com/return "Twitter profile for @return") the address of the owner  
 */  
function proxyOwner() public view returns (address owner) {  
    bytes32 position = proxyOwnerPosition;  
    assembly {  
        owner := sload(position)  
    }  
}  

/**  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Sets the address of the current implementation  
 * [@param](http://twitter.com/param "Twitter profile for @param") \_newImplementation address of the new implementation  
 */  
function _setImplementation(address _newImplementation)   
    internal   
{  
    bytes32 position = implementationPosition;  
    assembly {  
        sstore(position, _newImplementation)  
    }  
}  

/**  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Upgrades the implementation address  
 * [@param](http://twitter.com/param "Twitter profile for @param") \_newImplementation address of the new implementation  
 */  
function _upgradeTo(address _newImplementation) internal {  
    address currentImplementation = implementation();  
    require(currentImplementation != _newImplementation);  
    _setImplementation(_newImplementation);  
}  

/**  
 * [@dev](http://twitter.com/dev "Twitter profile for @dev") Sets the address of the owner  
 */  
function _setUpgradeabilityOwner(address _newProxyOwner)   
    internal   
{  
    bytes32 position = proxyOwnerPosition;  
    assembly {  
        sstore(position, _newProxyOwner)  
    }  
}  

}
```

#### 如何使用非结构化可升级存储代理合约？

​		使用非结构化存储代理合约非常简单，他可以应用到几乎所有的现存合约。以下是步骤：

1. Deploy the proxy contract and the Implementation contract.部署代理合约和执行合约
2. 调用代理合约的`upgradeTo(address)`同时不再理会执行合约的地址。

​		我们现在可以忘掉执行合约的地址然后把代理合约的地址视为主地址。

​		为了升级一个执行合约，我们只需要部署一个新的执行合约然后调用代理合约的`upgradeTo(address)`同时不再理会执行合约的地址。就是这么简单！

​		让我们通过一个简单的例子看看它是如何生效的。我们将再次使用可升级存储代理合约那一节的逻辑合约，但是不需要继承存储结构合约。所以我们的ImplementationV1应该是这样的：

```
ImplementationV1 {
address public owner;
mapping (address => uint) internal points;

modifier onlyOwner() {  
    require (msg.sender == owner);  
    _;  
}  
    
function initOwner() external {  
    require (owner == address(0));  
    owner = msg.sender;  
}  

function addPlayer(address _player, uint _points)   
    public onlyOwner   
{  
    require (points[_player] == 0);  
    points[_player\] = _points;  
}  

function setPoints(address _player, uint _points)   
    public onlyOwner   
{  
    require (points[_player] != 0);  
    points[_player] = _points;  
}  


}


```

​		下一步就是部署执行合约和代理合约，然后调用代理合约的`upgradeTo(address)`同时不再理会执行合约的地址。

​		你可能注意要在这个执行合约里totalPlayers甚至没有声明。我们可以升级这个执行合约让他被声明并使用，这个新的执行合约看起来是这样的：

```solidity
contract ImplementationV2 is ImplementationV1 {
	uint public totalPlayers;
	function addPlayer(address _player, uint _points) public onlyOwner {  
    require (points[_player] == 0);  
    points[_player] = _points;  
    totalPlayers++;  
	}  
}
```

​		为了升级执行合约，我们只需要部署合约，调用代理合约的 `upgradeTo(address)`同时不再理会我们新代理合约的地址，现在我们的合约已经可以在相同的地址持续记录totalPlayers了。

​		这个方法很强但是也有局限性，最重要的是代理合约的owner权限太大了。同时这种方法对于复杂的系统是不够用的，主从合约和非结构化可升级存储代理合约结合更适合构建需要可升级合约的dApp，这也是我们在 [GovBlocks](https://govblocks.io/)里使用的方法。

### 总结

​		非结构化存储代理合约时最先进的合约可升级化技术之一，但是仍不完美。我们GovBlocks并不希望dApp所有者对d App有过多的控制权，毕竟他们是去中心化应用，所以我们决定在我们的代理合约中使用全网授权而非一个简单的proxyOwner。我会在下一篇文章里介绍我们是怎么做的。同时，我建议读者读一下Nitika的[论反对使用onlyOwner](https://medium.com/@nitikagoel2505/strengthening-the-weakest-link-in-smart-contract-security-onlyowner-c390d0e452b4) 。你也可以在github上看到我们的[代理合约](https://github.com/somish/govblocks-protocol/blob/npm/contracts/proxy/GovernedUpgradeabilityProxy.sol)。

​		希望这篇文章能帮您写出可升级的智能合约！

*Shoutout to Zepplin for* *[their work](https://github.com/zeppelinos/labs)* *on proxy techniques.*

