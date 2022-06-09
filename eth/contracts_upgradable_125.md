原文链接：https://hackernoon.com/how-to-make-smart-contracts-upgradable-2612e771d5a2

# How to make smart contracts upgradable!

![1_75FbnguPLUrHrruR8Ee3JQ.jpg](https://img.learnblockchain.cn/attachments/2022/05/ulFftgUr6294338248350.jpg)

Smart contracts have evolved into being more than just basic contracts. Now we have whole ecosystems powered by Smart Contracts! No matter how careful we are or how well tested our code is, if we are creating a complex system, there is a good chance that we will need to update the logic to patch a bug, fix an exploit or add a necessary missing feature. Sometimes, we may even need to upgrade our smart contracts due to changes in EVM or newly found vulnerabilities.

Generally, developers can easily upgrade their software but blockchains are different as they are immutable. If we deploy a contract then it is out there with turning back no longer an option. However, if we use proper techniques, we can deploy a new contract at a different address and render the old contract useless. Following are some of the most common techniques for creating upgradable smart contracts.

### #Master-Slave contracts

Master-Slave technique is one of the most basic and easy to understand technique for making smart contracts upgradable. In this technique, we deploy a master contract along with all of the other contracts. The master contract stores the addresses of all other contracts and returns the required address whenever needed. The contracts act as slaves and fetch the latest address of other contracts from the master whenever they need to communicate with other contracts. To upgrade a smart contract, we just deploy it on the network and change the address in the master contract. Although this is far from the best way to develop upgradable contracts, It is the simplest. One of the many limitations of this method is that we can’t migrate the data or assets of the contract to a new contract easily.

### #Eternal Storage contracts

In this technique, we separate the logic and data contracts from each other. The data contract is supposed to be permanent and non-upgradable. The logic contract can be upgraded as many times as needed and the data contract is notified of the change. This is a fairly basic technique but has an obvious flaw. As the data contract is non-upgradable, any change required in the data structure or a bug / exploit in the data contract can render all the data useless. Another problem with this technique is that the logic contract will need to make an external call if it wants to access/manipulate data on the blockchain and external calls cost extra gas. This technique is usually combined with the Master-Slave technique to facilitate the inter contract communication.

### #Upgradable Storage Proxy Contracts

We can prevent paying for extra gas by making the eternal storage contracts act as a proxy to the logic contracts. The proxy contract, as well as the logic contract, will inherit the same storage contract so that their storage references align in the EVM. The proxy contract will have a fallback function that will delegate call the logic contract so that the logic contract can make changes in the storage of the proxy. The proxy contract will be eternal. This saves us the gas required for multiple calls to the storage contract as now, only one delegate call is needed no matter how many changes made in the data.

#### #There are three components of this technique

1. **Proxy contract**: It will act as eternal storage and delegate call the logic contract.
2. **Logic contract**: It will do all the processing of the data.
3. **Storage structure**: It contains the storage structure and is inherited by both proxy and logic contracts so that their storage pointers remain in sync on the blockchain.



![img](https://hackernoon.com/hn-images/1*8MeHhV-S4XH3gHyPd0VL4Q.png)





#### #Delegate Call

The core of this technique lies in the `DELEGATECALL` opcode provided by the EVM. `DELEGATECALL` is like a normal `CALL` except that the code at the target address is executed in the context of the calling contract (which invoked `DELEGATECALL`), and msg.sender and msg.value of the original call are preserved. Thus, when `DELEGATECALL` is used, the code at the target contract is executed, but the Storage, address, and balance of the calling contract are used. In other words, `DELEGATECALL` basically allows (delegates) target contract to do whatever it wants with the caller contract’s storage.

We will use this to our advantage and create a proxy contract that will `DELEGATECALL` the Logic contract so that we can keep the data safe in the proxy contract while freely changing the logic contract as we see fit.

#### #How to use upgradable storage proxy contracts?

Let’s dive into a bit more details. The first contract we will need is the storage structure. It will define all the storage variables we need and will be inherited by both Proxy and Implementation contract. It will look something like contract StorageStructure {address public implementation;address public owner;mapping (address => uint) internal points;uint internal totalPlayers;}

We will now need an implementation/logic contract. Let’s create a buggy implementation that does not increment the totalPlayers counter when new players are added.

contract ImplementationV1 is StorageStructure {modifier onlyOwner() {require (msg.sender == owner);_;}

```
function addPlayer(address \_player, uint \_points)   
    public onlyOwner   
{  
    require (points\[\_player\] == 0);  
    points\[\_player\] = \_points;  
}
```

function setPoints(address _player, uint _points)public onlyOwner{require (points[_player] != 0);points[_player] = _points;}}

Now, the most critical part, the proxy contract.

contract Proxy is StorageStructure {

```
modifier onlyOwner() {  
    require (msg.sender == owner);  
    \_;  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") constructor that sets the owner address  
 \*/  
constructor() public {  
    owner = msg.sender;  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Upgrades the implementation address  
 \* [@param](http://twitter.com/param "Twitter profile for @param") \_newImplementation address of the new implementation  
 \*/  
function upgradeTo(address \_newImplementation)   
    external onlyOwner   
{  
    require(implementation != \_newImplementation);  
    \_setImplementation(\_newImplementation);  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Fallback function allowing to perform a delegatecall   
 \* to the given implementation. This function will return   
 \* whatever the implementation call returns  
 \*/  
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
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Sets the address of the current implementation  
 \* [@param](http://twitter.com/param "Twitter profile for @param") \_newImp address of the new implementation  
 \*/  
function \_setImplementation(address \_newImp) internal {  
    implementation = \_newImp;  
}  


}
```
To make the contract work, we need to first deploy the Proxy and ImplementationV1 and then call `upgradeTo(address)` function of the Proxy contract while passing the address of our ImplementationV1 contract. We can now forget about the ImplementationV1 contract’s address and treat the Proxy contract’s address as our main address.

To upgrade the contract, we need to create a new implementation of the logic contract. It can be something along the lines of

```
contract ImplementationV2 is ImplementationV1 {


function addPlayer(address \_player, uint \_points)   
    public onlyOwner   
{  
    require (points\[\_player\] == 0);  
    points\[\_player\] = \_points;  
    totalPlayers++;  
}


}
```
> You should notice that this contract also inherits the StorageStructure contract, albeit, indirectly.

All implementations must inherit the StorageStructure contract and it shall not be changed after the proxy is deployed to avoid unintended overwrite of proxy’s storage.

To upgrade to the implementation, we deploy the ImplementationV2 contract on the network and then call `upgradeTo(address)` function of the Proxy contract while passing the address of the ImplementationV2 contract.

This technique makes it fairly easy to upgrade the logic of our contract but it still does not allow us to upgrade the storage structure of our contract. We can solve that problem by using unstructured proxy contracts.

### #Unstructured Upgradable Storage Proxy Contracts

This is one of the most advanced methods to make contracts upgradable. It works by saving the addresses of the implementation and the owner at fixed positions in the storage such that they won’t be overwritten by the data being fed by the implementation/logic contract. We can use the `sload` and `sstore` opcodes to directly read and write to specific storage slots referenced by fixed pointers.

This approach exploits the [layout of state variables in storage](https://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage) to avoid the fixed positions being overwritten by the logic contract. If we set the fixed position to something like `0x7` then it will get overwritten just after first 7 storage slots are used. To avoid this, we set the fixed storage position to something like `keccak256(“org.govblocks.implemenation.address”)`.

This eliminates the need for inheriting the StorageStructure contract in the proxy which means, we can now upgrade our storage structure as well. Upgrading storage structure is a tricky task though as we will need to make sure that our changes don’t cause the new storage layout to be misaligned with the previous storage layout.

#### #There are two components of this technique

1. Proxy Contract: It stores the address of the implementation contract at a fixed address and delegates calls to it.

2. Implementation contract: It is the main contract which holds the logic as well as the storage structure.

> You can even use your existing contracts with this technique as it does not require any change in your implementation contract.

```
The proxy contract will look something like contract UnstructuredProxy {

```
// Storage position of the address of the current implementation  
bytes32 private constant implementationPosition =   
    keccak256("org.govblocks.implementation.address");  
  
// Storage position of the owner of the contract  
bytes32 private constant proxyOwnerPosition =   
    keccak256("org.govblocks.proxy.owner");  
  
/\*\*  
\* [@dev](http://twitter.com/dev "Twitter profile for @dev") Throws if called by any account other than the owner.  
\*/  
modifier onlyProxyOwner() {  
    require (msg.sender == proxyOwner());  
    \_;  
}  
  
/\*\*  
\* [@dev](http://twitter.com/dev "Twitter profile for @dev") the constructor sets owner  
\*/  
constructor() public {  
    \_setUpgradeabilityOwner(msg.sender);  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Allows the current owner to transfer ownership  
 \* [@param](http://twitter.com/param "Twitter profile for @param") \_newOwner The address to transfer ownership to  
 \*/  
function transferProxyOwnership(address \_newOwner)   
    public onlyProxyOwner   
{  
    require(\_newOwner != address(0));  
    \_setUpgradeabilityOwner(\_newOwner);  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Allows the proxy owner to upgrade the implementation  
 \* [@param](http://twitter.com/param "Twitter profile for @param") \_implementation address of the new implementation  
 \*/  
function upgradeTo(address \_implementation)   
    public onlyProxyOwner  
{  
    \_upgradeTo(\_implementation);  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Tells the address of the current implementation  
 \* [@return](http://twitter.com/return "Twitter profile for @return") address of the current implementation  
 \*/  
function implementation() public view returns (address impl) {  
    bytes32 position = implementationPosition;  
    assembly {  
        impl := sload(position)  
    }  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Tells the address of the owner  
 \* [@return](http://twitter.com/return "Twitter profile for @return") the address of the owner  
 \*/  
function proxyOwner() public view returns (address owner) {  
    bytes32 position = proxyOwnerPosition;  
    assembly {  
        owner := sload(position)  
    }  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Sets the address of the current implementation  
 \* [@param](http://twitter.com/param "Twitter profile for @param") \_newImplementation address of the new implementation  
 \*/  
function \_setImplementation(address \_newImplementation)   
    internal   
{  
    bytes32 position = implementationPosition;  
    assembly {  
        sstore(position, \_newImplementation)  
    }  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Upgrades the implementation address  
 \* [@param](http://twitter.com/param "Twitter profile for @param") \_newImplementation address of the new implementation  
 \*/  
function \_upgradeTo(address \_newImplementation) internal {  
    address currentImplementation = implementation();  
    require(currentImplementation != \_newImplementation);  
    \_setImplementation(\_newImplementation);  
}  
  
/\*\*  
 \* [@dev](http://twitter.com/dev "Twitter profile for @dev") Sets the address of the owner  
 \*/  
function \_setUpgradeabilityOwner(address \_newProxyOwner)   
    internal   
{  
    bytes32 position = proxyOwnerPosition;  
    assembly {  
        sstore(position, \_newProxyOwner)  
    }  
}  
```

}

#### #How to use unstructured upgradable storage proxy contracts?

Using unstructured upgradable storage proxy contracts is fairly simple as this technique can work with almost all of the existing contracts. To use this technique, follow the below steps:

1. Deploy the proxy contract and the Implementation contract.
2. call `upgradeTo(address)` function of the Proxy contract while passing the address of the Implementation contract.

We can now forget about the Implementation contract’s address and treat the Proxy contract’s address as the main address.

To upgrade to a new Implementation contract, we just have to deploy the new implementation contract and call the `upgradeTo(address)` function of the Proxy contract while passing the address of the new Implementation contract. It’s as simple as that!

Let’s see an example of how this works. We will again use the same logic contracts as we used in upgradable storage proxy contracts but we won’t need the storage structure. So, our ImplementationV1 can look something like contract ImplementationV1 {address public owner;mapping (address => uint) internal points;

```
modifier onlyOwner() {  
    require (msg.sender == owner);  
    \_;  
}  
    
function initOwner() external {  
    require (owner == address(0));  
    owner = msg.sender;  
}  
  
function addPlayer(address \_player, uint \_points)   
    public onlyOwner   
{  
    require (points\[\_player\] == 0);  
    points\[\_player\] = \_points;  
}  
  
function setPoints(address \_player, uint \_points)   
    public onlyOwner   
{  
    require (points\[\_player\] != 0);  
    points\[\_player\] = \_points;  
}  
```

}

Next step would be to deploy this implementation and our proxy. Then, call `upgradeTo(address)` function of the Proxy contract while passing the address of the Implementation contract.

You may notice that totalPlayers variable is not even declared in this implementation. We can upgrade this implementation to one which has totalPlayers variable declared and used. The new implementation could look something like contract ImplementationV2 is ImplementationV1 {uint public totalPlayers;

```
function addPlayer(address \_player, uint \_points)   
    public onlyOwner   
{  
    require (points\[\_player\] == 0);  
    points\[\_player\] = \_points;  
    totalPlayers++;  
}  
```

}

To upgrade to this new implementation, all we have to do is deploy this contract on the network and, you guessed it right, call the `upgradeTo(address)` function of the Proxy contract while passing the address of our new Implementation contract. Now, our contract has evolved to keep a track of totalPlayers (new) while still being at the same address for the users.

This approach is extremely powerful but has a few limitations. One of the main concern is that the proxyOwner has too much power. Also, this approach alone is not enough for complex systems. A combination of Master-Slave and unstructured upgradable storage proxy contract is a more flexible approach for building a dApp with upgradable contracts and that’s exactly what we are using at [GovBlocks](https://govblocks.io/).

### #Conclusion

Unstructured Storage Proxy Contracts is one of the most advanced techniques out there to create upgradable smart contracts but it’s still not perfect. We, at GovBlocks, don’t want dApp owners to have unjustified control over the dApps. Afterall, they are Decentralized Applications! So, we decided to use a network-wide Authorizer in our proxy contracts rather than a simple proxyOwner. I will explain how we did this in a future article. Meanwhile, I recommend reading Nitika’s [argument against the use of onlyOwner](https://medium.com/@nitikagoel2505/strengthening-the-weakest-link-in-smart-contract-security-onlyowner-c390d0e452b4). You can also have a sneak peek of our [proxy contract on GitHub](https://github.com/somish/govblocks-protocol/blob/npm/contracts/proxy/GovernedUpgradeabilityProxy.sol).

I hope that this post will help you in creating upgradable smart contracts!

*Shoutout to Zepplin for* *[their work](https://github.com/zeppelinos/labs)* *on proxy techniques.*

