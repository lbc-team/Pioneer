原文链接：https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201

# Solidity DelegateProxy Contracts

*Note: This is going to be a pretty technical read. You should be familiar with at least fundamental Ethereum architecture and rudimentary Solidity development before reading this article.*

Deploying contracts on Ethereum can be really costly. For non-trivial contracts, the amount of gas required can reach into the millions. Factor in an average gas price of 20 GWei, and each contract you deploy may cost you upwards of tens to hundreds of dollars!

These deployment gas costs can bar some dApps from reaching a wider audience. Mitigation of these costs using monolithic smart contracts carries the risk of having to maintain a large monolithic smart contract. Splitting logic out into libraries may help, but depending on the problem domain, may not always be the right fit.

Furthermore, existing smart contracts may have flaws, or they might need updates to their logic. Proxies can enable contract logic to be updatable as well, so additional business requirements may be implemented after the initial deployment. Of course, this is a tradeoff: contract users would have to trust that the contract owner updates the contract in a way that does not violate user expectations. However, there are ways to reduce the amount of trust required from users during updates.

# Basic Contract Deployment Mechanics

Let’s imagine that we develop contracts for a blockchain kombucha company. Our business requires us to create smart contracts for every bottle of kombucha we sell, for *reasons*. Okay, so we just make up a `Kombucha` contract:

```
pragma solidity ^0.4.23;

contract Kombucha {
    event FilledKombucha(uint amountAdded, uint newFillAmount);
    event DrankKombucha(uint amountDrank, uint newFillAmount);    
    
    uint public fillAmount;
    uint public capacity;
    string public flavor;    
    
    constructor(string _flavor, uint _fillAmount, uint _capacity)
        public
    {
        require(_fillAmount <= _capacity && _capacity > 0);
        flavor = _flavor;
        fillAmount = _fillAmount;
        capacity = _capacity;
    }    
    
    function fill(uint amountToAdd) public {
        uint newAmount = fillAmount + amountToAdd;
        require(newAmount > fillAmount && newAmount <= capacity);
        fillAmount = newAmount;
        emit FilledKombucha(amountToAdd, newAmount);
    }    
    
    function drink(uint amountToDrink) public returns (bytes32) {
        uint newAmount = fillAmount - amountToDrink;
        require(newAmount < fillAmount);
        fillAmount = newAmount;
        emit DrankKombucha(amountToDrink, newAmount);        
        
        // this mess of hashes just here to pad out the bytecode
        return keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
            keccak256(keccak256(keccak256(keccak256(keccak256(
                amountToDrink
            ))))))))))))))))))))))))))))))))))))))))))))))))));
    }
}
```

We compile that contract with optimization enabled, and we deploy it with some parameters like “peach”, 100, 100… to find out that it consumes 552,034 gas in deployment. To make things worse, let’s say, in order to get the transaction to go through in a timely manner, we had to set a gas price of 20 GWei, and the price of Ether happens to be about $1000 that day. That means every `Kombucha` contract costs $11.04 to deploy. Oof, let’s try and make that better.

# Historical Proxy Patterns

Because of the exorbitant gas costs of putting additional copies of the code onto the blockchain (not to mention the vast inefficiencies involved in doing so), the Ethereum developer community has been searching for methods of reducing deployment costs through deduplication of actual code deployed onto the chain. One approach is to use Solidity libraries to provide a location on chain where the bulk of the logic for objects exists, and have contracts essentially be a location for storing state with thin wrappers around library calls.

This is called [Library-Driven Development](https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736):

```
library KombuchaLib {
    event FilledKombucha(uint amountAdded, uint newFillAmount);
    event DrankKombucha(uint amountDrank, uint newFillAmount);    
    
    struct KombuchaStorage {
        uint fillAmount;
        uint capacity;
        string flavor;
    }    
    
    function init(
        KombuchaStorage storage self,
        string _flavor, uint _fillAmount, uint _capacity
    ) public {
        require(_fillAmount <= _capacity && _capacity > 0);
        self.flavor = _flavor;
        self.fillAmount = _fillAmount;
        self.capacity = _capacity;
    }    
    
    function fill(KombuchaStorage storage self, uint amountToAdd) 
public {
        uint newAmount = self.fillAmount + amountToAdd;
        require(newAmount > self.fillAmount && newAmount <= 
self.capacity);
        self.fillAmount = newAmount;
        emit FilledKombucha(amountToAdd, newAmount);
    }    
    
    // ... and etc. for all the other functions
}
```

…where the contracts wrap calls to the library:

```
contract Kombucha {
    using KombuchaLib for KombuchaLib.KombuchaStorage;    
    
    // we have to repeat the event declarations in the contract
    // in order for some client-side frameworks to detect them
    // (otherwise they won't show up in the contract ABI)
    event FilledKombucha(uint amountAdded, uint newFillAmount);
    event DrankKombucha(uint amountDrank, uint newFillAmount);    
    
    KombuchaLib.KombuchaStorage private self;    
    
    constructor(string _flavor, uint _fillAmount, uint _capacity) 
public {
        self.init(_flavor, _fillAmount, _capacity);
    }    
    
    function fill(uint amountToAdd) public {
        return self.fill(amountToAdd);
    }    
    
    // do same for drink(...) method    
    
    function fillAmount() public view returns (uint) {
        return self.fillAmount;
    }    
    
    // same for capacity and flavor accessors
}
```

With this approach, deploying the library costs 479,430 gas (~$9.59), and then deploying an instance of the `Kombucha` contract costs 358,431 gas (~$7.17). Since we only have to deploy the library once, we’ve saved 35% in deployment costs over the long run.

Okay, but can we do better? This method still produces a contract with quite a bit of redundancy. For one, the state of the contract has to be contained in a struct now. Both the state and method parameters have to be passed down into the linked library, and method declarations and events are repeated. This repetition is unavoidable for various technical reasons, and this means our contract code is more brittle now. Also, while the gas savings are great, the fact is that we are still deploying quite a bit of “wrapper” bytecode to the chain, since we essentially have to map the function signatures of the library calls to the function signatures of the `Kombucha` contract calls.

Well, turns out we *can* do better. By dropping down into assembly, we can implement a [generic proxy](http://martin.swende.se/blog/EVM-Assembly-trick.html):

```
contract ProxyData {
    address internal proxied;
}

contract Proxy is ProxyData {
    constructor(address _proxied) public {
        proxied = _proxied;
    }

    function () public payable {
        address addr = proxied;
        assembly {
            let freememstart := mload(0x40)
            calldatacopy(freememstart, 0, calldatasize())
            let success := delegatecall(not(0), addr, freememstart, 
calldatasize(), freememstart, 32)
            switch success
            case 0 { revert(freememstart, 32) }
            default { return(freememstart, 32) }
        }
    }
}
```

(Inheriting `proxied` from `ProxyData` may seem like unnecessary indirection right now, but it will come into play later, I promise.)

Creating this proxy only costs 111987 gas (~$2.24)! Not only that, but this contract is able to copy the logic of *any* conventionally written smart contract. Okay, so we’re done now, right? No… actually that was a bit optimistic, as we’ll soon see.

# Proxy-friendly Storage Layouts

We really should give the proxy a test spin before we declare victory. Let’s fire up [Remix](https://remix.ethereum.org/) and try this out on the conveniently embedded JS VM. We’ll first copy over the original `Kombucha` contract and this `Proxy` contract code into Remix. Then, we’ll create an instance of `Kombucha` with a few parameters (say… “peach”, 100, 100 again). Then, we’ll use the address of the created `Kombucha` instance as the `_proxied` parameter of the `Proxy` contract. Finally, let’s call the `fillAmount` accessor:

![img](https://img.learnblockchain.cn/attachments/2022/05/6twCNPjm6285ef05f2007.png)

Something weird is going on here

The generic proxy above seems to produce a nonsensical value when asked about its `fillAmount`. Why is that the case? The key to understanding that value is knowing about the [layout of state variables,](http://solidity.readthedocs.io/en/v0.4.21/miscellaneous.html#layout-of-state-variables-in-storage) and the fact that [delegatecalls](http://solidity.readthedocs.io/en/latest/introduction-to-smart-contracts.html#delegatecall-callcode-and-libraries) cause the original contract’s logic to be executed in the context of the proxy’s address, meaning its logic will assume that this proxy’s address has the same storage layout.

To sum up [storage layouts](http://solidity.readthedocs.io/en/v0.4.21/miscellaneous.html#layout-of-state-variables-in-storage): Solidity packs fixed-length state variables into 32-byte EVM words in their order of declaration starting at storage slot zero, while dynamic variables use slightly more complex rules for storage.

The generic proxy declares a single address of storage: `proxied`, whereas the `Kombucha` contract declares two `uint256`s and a `string`. Look at the `Proxy` and `Kombucha` columns in the following table:

![img](https://img.learnblockchain.cn/attachments/2022/05/u8WAPiQy6285ef3b759e7.png)

Storage layout for various contracts; H(n) is the Keccak256 hash of a big-endian 256-bit integer *n; flavor (contents) is actually displaced by about* 5.88e+76 slots after adding the state variable `proxied`

The `proxied` address and the `fillAmount` are forced to occupy the same storage slot, according to the rules of Solidity storage layout. This means that when we tried to access `fillAmount`, what was *actually* accessed was the `proxied` address, interpreted as a 256-bit unsigned integer. You may verify this by looking at the hexadecimal representation of the value returned and comparing that to the address of the original `Kombucha` contract instance:

(Using a Python shell to do hexadecimal conversion)
`>>> hex(539200072242722497324523172593427911613710757535)'0x5e72914535f202659083db3a02c984188fa26e9f'`

Ah, the weird `fillAmount` value and the `proxied` address match! That means we just have to add another storage variable at the beginning of `Kombucha` which is an address, and remember that in general, proxies and proxy targets have to have compatible storage layouts (compare the last column of the table above). One way to do that is by prepending the `proxied` address to the storage layout via inheritance:

```
// Modify the declaration of Kombucha this way
// to make it proxy-friendly
contract Kombucha is ProxyData {
    // rest of Kombucha contents...
}
```

Also, let’s think of this point in this discussion as **checkpoint one**.

# Proxy Storage Initialization

You may have noticed that the other storage variables are completely uninitialized for proxies. In the example above, the `capacity` variable of the proxy when the proxy is viewed as an instance of the `Kombucha` contract is zero, as that slot is not modified by the `Proxy` constructor.

But the `Kombucha` constructor *does not allow* the construction of a `Kombucha` instance with zero `capacity`, thanks to the following line:

```
require(_fillAmount <= _capacity && _capacity > 0);
// later, capacity is assigned the value of _capacity
```

In fact, according to this requirement, `fillAmount` wasn’t even supposed to be greater than `capacity`, let alone a casted proxy address value (though of course, we can address that by ensuring compatibility between the storage layouts for the `Proxy` and its target contracts). The point is that the state of the proxy is completely broken, so all of `Kombucha`’s functionality won’t work correctly on the proxy.

That’s pretty lame. We don’t want to limit the proxy to only those contracts that can start off of a completely uninitialized storage, but we also don’t want people arbitrarily changing, for example, the `flavor` and `capacity` of different `Kombucha` instances, especially if it was a business requirement and you wrote the constructor for `Kombucha` the way you did for a good reason.

## Additional Proxy Initialization Method Approach

One way to allow the generic proxy to be applied to contracts which expect a non-empty initial state is to add an `init` method to the contract:

```
contract Kombucha is ProxyData {
    // original declarations...    
    
    constructor(string _flavor, uint _fillAmount, uint _capacity) 
public {
        init(_flavor, _fillAmount, _capacity);
    }    
    
    function init(string _flavor, uint _fillAmount, uint _capacity) 
public {
        require(capacity == 0 && _fillAmount <= _capacity && _capacity 
> 0);
        flavor = _flavor;
        fillAmount = _fillAmount;
        capacity = _capacity;
    }    
    
    // and the rest of Kombucha...
}
```

First, notice that the `init` method is called in the constructor, and is indeed the only method called in the constructor here. Second, note that the implementation of `init` is *almost* identical to the original constructor’s implementation. The difference occurs in this line:

```
require(capacity == 0 && _fillAmount <= _capacity && _capacity > 0);
```

We require that the storage variable `capacity` is unset here because we need to ensure that the `init` method is executed *only once* and *only when the contract is uninitialized*.

For the `Kombucha` contract, the check on the `capacity` storage variable is enough to enforce those expected `init` method properties because there’s no way of unsetting the `capacity` variable after its been set, but in general, different contracts require different ways of enforcing initialization behavior.

Also, there is no access control on the initialization method, and indeed, somebody can call the `init` method before you do if you just directly proxy a `Kombucha` instance. Implementing access control on initialization would require you to either hardcode your address into the `init` method or to extend the proxy constructor, since otherwise, you would have to somehow initialize a storage variable to describe the address for which access is granted. There is a way around this though, and we will come back to this initialization approach later in the article.

Finally, I’d like to mention that the bytecode deployed using this `init` pattern is heavier than the bytecode deployed in the original `Kombucha` because the initialization method is part of the contract code! Normally, constructor logic is executed once to set up the initial contract state, and then that logic is *never deployed*. By moving that logic to `init`, we also have to deploy that logic so that it can be called through the proxy to setup state.

We’ll refer to the system state now as **checkpoint init**.

## Proxy Subclasses and [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) with Multiple Inheritance

Let’s return to **checkpoint one** now. We will try and move the constructor code out of the base class into a proxy subclass so that we can avoid:

- deploying the base class with the extra initialization method
- modifying the original contract to make sure state initialization only occurs once and only on an uninitialized state
- risking having initialization on an uninitialized contract state hijacked by an unauthorized party (though this will be solved on the initialization method based approach soon)

We will accomplish this simply by moving the contract constructor code into the proxy. In order to do this successfully, however, the proxy contract will need to be aware of the way contract storage is laid out. This can be expressed by splitting the contract data out into a separate mixin contract:

```
contract KombuchaData is ProxyData {
    event FilledKombucha(uint amountAdded, uint newFillAmount);
    event DrankKombucha(uint amountDrank, uint newFillAmount);
    
    uint public fillAmount;
    uint public capacity;
    string public flavor;
}
```

Then, moving the contract constructor into the proxy is straightforward:

```
contract KombuchaProxy is Proxy, KombuchaData {
    function KombuchaProxy(address proxied, string _flavor, uint 
_fillAmount, uint _capacity)
        public
        Proxy(proxied)
    {
        // the body is identical to our original constructor!
        require(_fillAmount <= _capacity && _capacity > 0);
        flavor = _flavor;
        fillAmount = _fillAmount;
        capacity = _capacity;
    }
}

contract Kombucha is KombuchaData {    
    // this is just all the methods of the original Kombucha:
    // drink and fill
}
```

The order in which parent contracts are declared on the child contracts determines how their storages are laid out, and both the proxy and the implementation contracts have to be aware of the `Kombucha` contract storage layout. We use inheritance so that storage variables only have to be declared once, and they are automatically laid out accordingly for both full and proxy instances:

![img](https://img.learnblockchain.cn/attachments/2022/05/y6fazNr56285f1c782123.png)

Note that the `KombuchaProxy` constructor also has to specify how to construct the `Proxy` it is subclassing, so in fact, the constructor has an additional parameter: the address of a full instance of `Kombucha`. Other than accounting for this extra parameter in the proxy constructor and having to separate state variables and type declarations out into a data mixin contract, the code remains essentially the same as the original.

Also, note that `KombuchaProxy` does not include `ProxyData` twice because Solidity only copies code from each parent contract in a contract’s ancestry at most *once* into a contract, so using this will not unalign the storage layout. We will be using this fact throughout the rest of this article.

We can test this setup by constructing a full `Kombucha` instance (which takes no arguments now), constructing a `KombuchaProxy` instance with the address of the full `Kombucha` instance’s address as the first argument, and finally viewing the proxy as if it was `Kombucha`:

![img](https://img.learnblockchain.cn/attachments/2022/05/cNzCi5yx6285f1ff1efb7.png)

It works!

However, the `KombuchaProxy` instance still contains unnecessary code, namely, the accessors generated for the inherited public state variables declared in `KombuchaData`:

![img](https://img.learnblockchain.cn/attachments/2022/05/6Isua91D6285f25a8f030.png)

All we should need is the fallback on the proxy

Unfortunately, this is not so nicely factored away:

```
contract KombuchaHeader {
    event FilledKombucha(uint amountAdded, uint newFillAmount);
    event DrankKombucha(uint amountDrank, uint newFillAmount);
}

contract KombuchaDataInternal is ProxyData, KombuchaHeader {
    uint internal fillAmount;
    uint internal capacity;
    string internal flavor;
}

contract KombuchaData is ProxyData, KombuchaHeader {
    uint public fillAmount;
    uint public capacity;
    string public flavor;
}

contract KombuchaProxy is Proxy, KombuchaDataInternal {
    // ...
}

contract Kombucha is KombuchaData {
    // ...
}
```

We can deduplicate type and event declarations as well as modifier definitions by pulling them out into a common header mixin like `KombuchaHeader`, but that’s as far as we can factor. We can’t avoid repeating the declaration of state variables that have accessors, so internal and public versions of the variable declarations have to be repeated in separate mixins.

Let’s call this point of the discussion **checkpoint subclass**. Taking this setup out for a test spin makes this happen:

![img](https://img.learnblockchain.cn/attachments/2022/05/efVfrK7Y6285f2d4da50d.png)

Wait, I said I wanted peach flavored

Why would taking the code for the accessors out of the proxy instance cause the `flavor` accessor to start failing?

# Byzantium Hard Fork and EIP 211

Look carefully in the generic proxy code and you’ll find some 32s floating around in the assembly section. If you took a detour earlier and read [Swende’s commentary](http://martin.swende.se/blog/EVM-Assembly-trick.html) on the generic proxy, or if you happen to know the arguments for the delegatecall, return, and/or revert opcodes, you will find that the 32 corresponds to the size in bytes of the data copied from the delegatecall result and returned/reverted. This means that our generic proxy can’t handle return data larger than 32-bytes.

In particular, [strings are encoded as an EVM 32-byte word of its length followed by its contents zero-right-padded to 32-bytes](https://solidity.readthedocs.io/en/develop/abi-spec.html#formal-specification-of-the-encoding). Moreover, since it is a dynamic return type, [the offset of the string is output in its slot](https://solidity.readthedocs.io/en/develop/abi-spec.html#use-of-dynamic-types), meaning the first two words are, in order, a uint256(32) for the offset and a uint256 containing the string length. However, all that the proxy passes is the 32-byte word containing the string offset in the return data, but *not* the length and contents of the string.

We can test this theory further by upping the return size in the proxy to 74-bytes:

```
// inside of the Proxy assembly {} section:

let success := delegatecall(not(0), addr, freememstart, calldatasize(), freememstart, 74)
switch success
case 0 { revert(freememstart, 74) }
default { return(freememstart, 74) }
```

And then supplying “supercalifragilisticexpialidocious” as the flavor:

![img](https://img.learnblockchain.cn/attachments/2022/05/KkICOygf6285f37b17bda.png)

Our proxy passed along the 32-byte offset value, and then the 32-byte string length value, but stopped 10 bytes into the actual string contents, giving us “supercalif”. We can resolve this by continuing to bump up the hard-coded return data size in the proxy, but this only makes the proxy more and more expensive as the parameter increases. Also, without the ability to handle different return sizes, our proxies will never be able to act as a generic stand-in for their proxied contracts.

Luckily, there is something that can address this: [EIP 211](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-211.md). Basically, this proposal extends the existing EVM instruction set with two new opcodes: `returndatacopy` and `returndatasize`. It has been accepted and incorporated into the main network since the Byzantium hard fork. We can now pass along dynamically sized return values in our proxy like so:

```
// inside of the Proxy assembly {} section:

let success := delegatecall(not(0), addr, freememstart, 
calldatasize(), freememstart, 0)
returndatacopy(freememstart, 0, returndatasize())
switch success
case 0 { revert(freememstart, returndatasize()) }
default { return(freememstart, returndatasize()) }
```

With this change, you’ll be able to pass that supercalifragilisticexpialidocious flavor alo	ng with the proxy:

![img](https://img.learnblockchain.cn/attachments/2022/05/LDZyKJoe6285f3fb549c1.png)

All in all, this proxy costs 302,979 gas (~$6.06) to deploy, saving 45% of deployment costs over time, for a relatively simple contract at that. For larger more complex contracts, this proxy would save even more gas!

All of our generic proxies from this point forward in this article will use this dynamic return mechanism.

# Proxy Factories

Both the initialization method and the multiple inheritance approaches to proxying existing contracts add additional requirements to the construction of proxies, but proxies should behave practically identically to their proxied objects. Factories can hide that implementation detail behind a facade, providing users with a consistent interface for creating something functionally equivalent to `Kombucha` instances.

Let’s draft up a `Kombucha` factory for our original `Kombucha`:

```
contract KombuchaFactory {
    function createKombucha(string flavor, uint fillAmount, uint 
capacity)
        public
        returns (Kombucha)
    {
        return new Kombucha(flavor, fillAmount, capacity);
    }
}
```

This factory method right now is functionally equivalent to just a constructor call, but it costs about as much as constructing a full `Kombucha` instance because, well, it *is* constructing a full `Kombucha` instance. Actually, the factory `createKombucha` transaction costs 432,694 gas, which is about 120K ($2.40) less gas than via the constructor directly! This is a consequence of the `Kombucha` code being loaded from the factory, and not being sent as part of the transaction data.

Let’s make a factory, but this time, let’s say `Kombucha` is proxy-friendly and has a correctly written `init` method — that is, let’s use **checkpoint init**. Instead of creating full `Kombucha` instances, we want the factory to create `Proxy` instances referring to a master `Kombucha` copy:

```
contract KombuchaFactory {
    Kombucha private masterCopy;    
    
    constructor(Kombucha _masterCopy) public {
        masterCopy = _masterCopy;
    }    
    
    function createKombucha(string flavor, uint fillAmount, uint 
capacity)
        public
        returns (Kombucha kombucha)
    {
        kombucha = Kombucha(new Proxy(masterCopy));
        kombucha.init(flavor, fillAmount, capacity);
    }
}
```

Since we are able to initialize the proxy storage in the same transaction that we create the proxy in, we guarantee that instances created by the factory method are initialized properly, without any risk of another user intervening in the initialization step. Moreover, our proxy-producing factory is a drop-in replacement for the full instance factory, and the cost of creating new `Kombucha` instances will be drastically cut with the use of this proxy-producing factory.

Similarly, over in **checkpoint subclass**, we can tidy up the interface to the multiple inheritance approach to proxying for the same effect:

```
contract KombuchaFactory {
    Kombucha private masterCopy;    
    
    constructor(Kombucha _masterCopy) public {
        masterCopy = _masterCopy;
    }    
    
    function createKombucha(string flavor, uint fillAmount, uint 
capacity)
        public
        returns (Kombucha)
    {
        return Kombucha(new KombuchaProxy(masterCopy, flavor, 
fillAmount, capacity));
    }
}
```

Similarly to earlier, the factory pattern reduces the cost of creating instances even more because the `KombuchaProxy` bytecode does not need to be sent as transaction data: it is copied from the factory. This puts the gas cost per instance at 208063, or about $4.16. This is almost as cheap as this’ll get.

## A Note about Transaction Costs

I don’t want to give the impression that proxies somehow magically save gas in all circumstances: there is a tradeoff. While proxies may create immense savings in terms of code duplication on the chain, it loses gas in each call to the proxy because of the `delegatecall` indirection. For example, normally a call to `drink` 30 units on a `Kombucha` instance would take 32,369 gas, but if that call was proxied, the transaction would require 33,559 gas (~$0.02 difference). If those calls are made thousands of times, the cost of using the contract can overshadow costs in its creation.

Proxying helps most in situations where you need many instances of a contract: for example an instance per user, or when creating many instances of a contract type in transactions.

# Logic Updates

Fundamentally, a proxy outsources its functionality to a contract containing the logic it’s supposed to emulate. In the examples we’ve explored above, that contract is defined by an address present in the storage of the proxy which the contract actually has access to, meaning the proxied contract can actually alter the address to point somewhere else! This was hinted at earlier with the `fillAmount` accessor returning the integer value of the `proxied` address, and in fact, we could have changed `proxied` with a call to `drink` when the storage layout wasn’t fixed!

Let’s imagine a scenario in which we have our `Kombucha` contract deployed. Sometime later, maybe we will want to update our `Kombucha` contract so that it is by default capped, and it must be uncapped before it can be filled or drunk. Also, we’ll toss in an extra `keccak256` into the return value of `drink` for good measure (for more *reasons*, obviously).

We will continue this discussion from **checkpoint subclass**, but the following can apply (with some modifications) to the initialization method approach to proxying as well.

## Updating the Proxied Address

First, we want to be able to update `proxied` in some way. We shouldn’t allow just anybody to do this operation, so let’s restrict it to an owner of the contract. The contract, then, would somehow need to know its owner, and have semantics for dealing with the owner vs. non-owners. Let’s express this concept with an `Ownable` contract:

```
contract OwnableData {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address internal owner;

    constructor(address _owner)
        public
    {
        owner = _owner;
    }
}

contract Ownable is OwnableData {
    function setOwner(address newOwner)
        public
        onlyOwner
    {
        owner = newOwner;
    }
}
```

There are two ways of going about updating a proxy’s logic. One way is to extend `Proxy` to be updatable:

```
contract UpdatableProxyData is ProxyData, OwnableData {}

contract UpdatableProxyShared is ProxyData, Ownable {
    function updateProxied(address newProxied)
        public
        onlyOwner
    {
        proxied = newProxied;
    }
}

contract UpdatableProxy is Proxy, UpdatableProxyShared {
    constructor(address proxied, address owner)
        public
        Proxy(proxied)
        OwnableData(owner)
    {}
}

contract UpdatableProxyImplementation is UpdatableProxyShared {
    constructor() public OwnableData(0) {}
}
```

`UpdatableProxyImplementation` is extraneous in this case where we put updating logic on the proxy, but will be applicable in the case where we put updating logic on the proxied implementation instance.

`UpdatableProxyData` and `UpdatableProxy` can be nearly drop-in replacements for their non-updatable counterparts:

```
contract KombuchaDataInternal is UpdatableProxyData, KombuchaHeader { 
... }

contract KombuchaData is UpdatableProxyData, KombuchaHeader { ... }

contract KombuchaProxy is UpdatableProxy, KombuchaDataInternal {
    function KombuchaProxy(address proxied, address owner, string 
_flavor, uint _fillAmount, uint _capacity)
        public
        UpdatableProxy(proxied, owner)
    {
        // ...
    }
}
```

Note that now, the `KombuchaProxy` constructor needs an `owner` to be specified. Also, with this approach, the logic to update `proxied` resides inside the proxy itself and cannot be swapped out:

![img](https://img.learnblockchain.cn/attachments/2022/05/FCVUhVC16285f57096169.png)

This additional logic would also be deployed alongside the proxy, which would make instances of the proxy heavier, and would essentially determine the upgrading process from the start. However, this way also guarantees that as long as there is a valid owner, there will be an update mechanism for the proxied logic.

The other approach is to put the updating logic in the proxied contract:

```
contract KombuchaDataInternal is UpdatableProxyData, KombuchaHeader { 
... }

contract KombuchaData is UpdatableProxyData, KombuchaHeader { ... }

contract KombuchaProxy is Proxy, KombuchaDataInternal {
    function KombuchaProxy(address proxied, address owner, string 
_flavor, uint _fillAmount, uint _capacity)
        public
        Proxy(proxied) OwnableData(owner)
    {
        // ...
    }
}

contract Kombucha is UpdatableProxyImplementation, KombuchaData {
    // ...
}
```

With this method, we can just use the generic `Proxy` as the underlying implementation for `KombuchaProxy`, as the update functionality is contained in `Kombucha` itself, through `UpdatableProxyImplementation`:

![img](https://img.learnblockchain.cn/attachments/2022/05/yfs6ziSB6285f5e8d57d5.png)

Since the updating logic is in the proxied contract, we can also change the update procedures/policy per update. For example, we can decide that a version is final and simply ensure all code from that version does not affect `proxied` in the final update.

For the rest of this article, we will mostly assume the use of the second approach here where we place the updating logic in the proxied implementation contract and *not* the proxy, but the rest of the discussion should apply similarly to the first approach.

## Authoring an Update

Let’s recall the scenario we are trying to handle. We want to update Kombucha so that:

> it is by default capped, and it must be uncapped before it can be filled or drunk. Also, we’ll toss in an extra `keccak256` into the return value of `drink` for good measure (for more *reasons*, obviously).

Normally, we might write the updated `Kombucha` contract as follows:

```
contract Kombucha2 is Kombucha {
    bool public capped;
    
    constructor(string flavor, uint fillAmount, uint capacity)
        public
        Kombucha(flavor, fillAmount, capacity)
    {
        capped = true;
    }    
    
    function uncap() public {
        require(capped);
        capped = false;
    }
    
    function fill(uint amountToAdd) public {
        require(!capped);
        super.fill(amountToAdd);
    }    
    
    function drink(uint amountToDrink) public returns (bytes32) {
        require(!capped);
        return keccak256(super.drink(amountToDrink));
    }
}
```

Before, we might’ve told our customers that from now on, use this new `Kombucha2` instead of `Kombucha`, and if they need to hold on to their old `Kombucha` instance, then they’re out of luck.

Of course since this section is about updatable proxies, we’re going to make it so that they *don’t* have to do that.

Let’s adapt the vanilla update for the multiple inheritance approach to proxies. We will see how normal inheritance might be adapted for this new case:

```
contract Kombucha2DataInternal is KombuchaDataInternal {
    bool internal capped;
}

contract Kombucha2Data is KombuchaData {
    bool public capped;
}

contract Kombucha2Proxy is KombuchaProxy, Kombucha2DataInternal {
    function Kombucha2Proxy(address proxied, address owner, string 
flavor, uint fillAmount, uint capacity)
        public
        KombuchaProxy(proxied, owner, flavor, fillAmount, capacity)
    {
        capped = true;
    }
}

contract Kombucha2 is Kombucha, Kombucha2Data {
    // updated contract methods, NOT variables and constructor...
    // i.e. uncap, fill, and drink from above
}
```

This works fine enough on its own, but what happens when we update an existing `Kombucha` instance to use `Kombucha2`?

![img](https://img.learnblockchain.cn/attachments/2022/05/1rjxJmkX6285f64a7c131.png)

Trying to upgrade an existing Kombucha-like instance to that new Kombucha2 logic

It turns out that the update didn’t exactly work as we’ve expected:

![img](https://img.learnblockchain.cn/attachments/2022/05/cvLo6ces6285f674b39a1.png)

We’ve introduced `capped` in the update, but our business requires that variable to start off as *true* after the update. How can we ensure that when we update the contracts, the contract state adjusts itself accordingly?

## Storage State Migration

The problem of maintaining the correctness of an application’s state after a change to the application’s logic is similar to another problem in traditional applications: database migrations. Let’s adapt their methods. We need a way to migrate storage state during an update.

First we will modify `updateProxied` to take an `Update` instead of the new implementation address:

```
interface Update {
    function implementationBefore() external view returns (address);
    function implementationAfter() external view returns (address);
    function migrateData() external;
}

contract UpdatableProxyShared is ProxyData, Ownable(0) {
    function updateProxied(Update update)
        public
        onlyOwner
    {
        require(update.implementationBefore() == proxied);
        proxied = update;
        Update(this).migrateData();
        proxied = update.implementationAfter();
    }
}
```

Then, we realize the update as follows:

```
contract Kombucha2Update is
    KombuchaDataInternal,
    Kombucha2DataInternal,
    Update
{
    Kombucha internal kombucha;
    Kombucha2 internal kombucha2;    
    
    constructor(Kombucha _kombucha, Kombucha2 _kombucha2)
        public
        OwnableData(0)
    {
        kombucha = _kombucha;
        kombucha2 = _kombucha2;
    }    
    
    function implementationBefore() external view returns (address)
    {
        return kombucha;
    }
    
    function implementationAfter() external view returns (address) {
        return kombucha2;
    }
    
    function migrateData() external {
        capped = true;
    }
}
```

To see the mechanics of updating, let’s set up an instance of `Kombucha`, create a `KombuchaProxy` which we own, and view it as `Kombucha`, as before. Then, we’ll create the `Kombucha2` to which the proxy will refer:

![img](https://img.learnblockchain.cn/attachments/2022/05/nhK81WGa6285f7179b9d9.png)

Pretty standard setup, but let’s now view our proxy as a `Kombucha2`:

![img](https://img.learnblockchain.cn/attachments/2022/05/ztsj1pqM6285f7416e91d.png)

The `capped` accessor errors if we try to use it because the proxied `Kombucha` contract does not support that request. Let’s create an instance of `Kombucha2Update` using the addresses of the original logic-bearing contracts:

![img](https://img.learnblockchain.cn/attachments/2022/05/mbl1tOww6285f794a23bd.png)

The `Kombucha2Update` contract is designed to be storage-aligned with both `Kombucha` and `Kombucha2`. In this case, `Kombucha2` has a storage layout which contains the entirety of `Kombucha`’s storage layout (so the declaration of `KombuchaDataInternal` in the `Kombucha2Update` contract’s superclass list was extraneous), but in general, storage schema changes may be tricky to implement. You can see the way that the update accommodates both storage layouts via its header:

```
contract Kombucha2Update is ProxyData, OwnableData(0), 
KombuchaDataInternal, Kombucha2DataInternal, Update { ... }
```

We will be using data at two storage locations during the update: the update and the proxy. The *update* storage contains the addresses of the `implementationBefore` (`Kombucha`) and the `implementationAfter` (`Kombucha2`), which is why we construct the update instance with these parameters. The *proxy* storage contains the data which is to be migrated. Finally, code at the *update* describes how storage should be migrated from a `Kombucha` compatible dataset to a `Kombucha2` compatible dataset. This is why, in the modified `updateProxied` method, we ask the update directly for the `implementationBefore` and `implementationAfter`, but we proxy the call to `migrateData`:

```
require(update.implementationBefore() == proxied);
proxied = update;
Update(this).migrateData();
proxied = update.implementationAfter();
```

Doing this allows us to update `Kombucha` to `Kombucha2`, ensuring that `capped` is set and that `migrateData` is called only at the time of the update to set `capped` to *true*:

![img](https://img.learnblockchain.cn/attachments/2022/05/Jv8vPULN6285f7c6e550e.png)

We’ve successfully updated the proxy to use Kombucha2!

## Programmable Update Policies

Currently, our update policy relies on the trustworthiness of an owner, as this owner would be able to update the logic of the contract at any moment. However, in scenarios where a proxy instance is meant to be widely used by many different parties, handing a single authority the power to alter this proxy instance’s implementation on a whim may be too risky. A method of reducing the trust required of an entity in such a role may be desirable.

For example, perhaps it is desired that a kombucha contract proxy instance which everybody uses is updated to an address telegraphed at least a couple of months in advance, so any users of that instance may have time to prepare themselves for the event the `Kombucha` implementation is swapped out for the `Kombucha2` implementation.

Here is one way to implement this policy:

```
contract TimedUpdatableProxyDataInternal is UpdatableProxyData {
    uint internal updateAllowedStartTime;
    Update internal plannedUpdate;
}

contract TimedUpdatableProxyData is UpdatableProxyData {
    uint public updateAllowedStartTime;
    Update public plannedUpdate;
}

contract TimedUpdatableProxyShared is UpdatableProxyShared, 
TimedUpdatableProxyData {
    function planUpdate(Update update)
        public
        onlyOwner
    {
        plannedUpdate = update;
        updateAllowedStartTime = now + 30 seconds;
    }    
    
    function updateProxied(Update update)
        public
    {
        require(
            updateAllowedStartTime != 0 &&
            now >= updateAllowedStartTime &&
            update == plannedUpdate
        );        
        
        super.updateProxied(update);        
        
        updateAllowedStartTime = 0;
        plannedUpdate = Update(0);
    }
}

contract TimedUpdatableProxy is UpdatableProxy, 
TimedUpdatableProxyShared {
    constructor(address proxied, address owner)
        public
        UpdatableProxy(proxied, owner)
    {}
}

contract TimedUpdatableProxyImplementation is 
TimedUpdatableProxyShared {
    constructor() public OwnableData(0) {}
}
```

These are drop-in replacements for their `UpdatableProxy` counterparts. (Also, the update delay has been set to 30 seconds to avoid waiting forever for testing purposes). While the update is planned, the actual update contract is available on the chain for anyone to inspect, and `updateProxied` will not work unless the supplied update matches the planned update and the delay has passed.

Like the plain updatable contract, this extended update policy may be placed on either proxies or implementations, with similar implications, and this is just an example of what can be done.

# Further Notes

## Proxy Implementation Refinements

Solidity offers a [higher-level construct](https://ethereum.stackexchange.com/questions/37601/using-a-high-level-delegate-call-in-upgradable-contracts-since-byzantium) for performing delegatecalls than at the assembly level. The fallback function for the proxy may be written in the following way:

```
function() public payable {
    bool success = proxied.delegatecall(msg.data);
    assembly {
        let freememstart := mload(0x40)
        returndatacopy(freememstart, 0, returndatasize())
        switch success
        case 0 { revert(freememstart, returndatasize()) }
        default { return(freememstart, returndatasize()) }
    }
}
```

At the time of this writing, the assembly generated from the higher-level version of this code is a little more verbose, but it works, and for clarity, this may be the preferred approach in the future.

## EIP 897

You may be aware of [EIP 897](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-897.md), which deals exactly with the proxies discussed in this article. We can implement EIP 897 support on these proxies simply by adding the appropriate methods:

```
contract Proxy is ProxyData {
    // ...
    
    function implementation() public view returns (address) {
        return proxied;
    }    
    
    function proxyType() public pure returns (uint256) {
        return 1; // for "forwarding proxy"
                  // see EIP 897 for more details
    }
}

contract UpdatableProxy is Proxy, UpdatableProxyShared {
    // ...    
    
    function proxyType() public pure returns (uint256) {
        return 2; // for "upgradable proxy"
                  // again, see EIP 897
    }
}
```

## Removing the Extra Storage Slot

For simply forwarding proxies, there’s not actually any need to put the implementation address in storage, as it will not change, unlike upgradable proxies. This has been [hinted at](https://www.reddit.com/r/ethereum/comments/6c1jui/delegatecall_forwarders_how_to_save_5098_on/dhrb0pl/) before (e.g. having to replace `cafecafe…` with the appropriate address suggests that the code contains the implementation address directly), and now there is a whole [generic proxy factory](https://gist.github.com/GNSPS/ba7b88565c947cfd781d44cf469c2ddb) which creates proxy instances while swapping out the implementation address.

There’s a bit of a catch in that it requires the proxy bytecode to be directly loaded into memory for the contract creation call. However, this [may](https://github.com/ethereum/solidity/issues/3356) [change](https://github.com/ethereum/solidity/issues/3835) in the future and become directly supported by Solidity without such assembler tricks.

Another thing you may notice about these more [recent](https://gist.github.com/GNSPS/ba7b88565c947cfd781d44cf469c2ddb) [implementations](https://github.com/gnosis/safe-contracts/blob/master/contracts/ProxyFactory.sol) of proxy factories is the presence of a `bytes data` parameter. This makes these proxy factories a generalization of the init-based approached explored earlier, as the `data` is used as a subsequent message call to the newly created contract, and may be, for example, a message call to `init` with certain parameters!

Can we remove the requirements which are imposed by the `init` approach to proxy construction, but keep the generality of this proxy factory? Unfortunately, in order to keep a generic proxy factory, we’d have to deploy the construction code onto the chain somewhere anyway. That entails modifying the underlying generic forwarding proxy to behave something like in the following manner:

```
contract Proxy {
    address private constant constructorPlaceholder = 
0xCAfEcAfeCAfECaFeCaFecaFecaFECafECafeCaFe;
    address private constant implementationPlaceholder = 
0xf00Df00dF00dF00dF00DF00Df00df00df00Df00d;    

    constructor(bytes data) public {
        bool success = constructorPlaceholder.delegatecall(data);
        if(!success) revert();
    }    
    
    function() public payable {
        bool success = 
implementationPlaceholder.delegatecall(msg.data);
        assembly {
            let freememstart := mload(0x40)
            returndatacopy(freememstart, 0, returndatasize())
            switch success
            case 0 { revert(freememstart, returndatasize()) }
            default { return(freememstart, returndatasize()) }
        }
    }
}
```

We’d have to deploy code for initialization separately to the chain anyway, perhaps in this form:

```
contract KombuchaConstructor is KombuchaData {
    function init(string _flavor, uint _fillAmount, uint _capacity) 
public {
        require(_fillAmount <= _capacity && _capacity > 0);
        flavor = _flavor;
        fillAmount = _fillAmount;
        capacity = _capacity;
    }
}
```

Also, the generic proxy factory interface would not be ideal for use with client-side libraries at that point, requiring developers to especially format the constructor parameters `data` which is supposed to be dispatched through the factory to the constructor instance.

# Fin

![img](https://img.learnblockchain.cn/attachments/2022/05/Op6X5dwY6285f92c5a1d5.png)

Is Multiple Shadow Clone Jutsu actually an application of this proxy factory pattern?

To sum up, we can now make cheap copies of our contracts.

<iframe src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fmedia.giphy.com%2Fmedia%2FXHhxpH1Nvy2ek%2Fgiphy.mp4&amp;src_secure=1&amp;url=https%3A%2F%2Fgiphy.com%2Fgifs%2Fbeyonce-knowles-upgrade-u-XHhxpH1Nvy2ek&amp;image=https%3A%2F%2Fmedia.giphy.com%2Fmedia%2FXHhxpH1Nvy2ek%2Fgiphy.gif&amp;key=a19fcc184b9711e1b4764040d3dc5c07&amp;type=video%2Fmp4&amp;schema=giphy" allowfullscreen="" frameborder="0" height="281" width="500" title="Upgrade U Beyonce Knowles GIF - Find &amp; Share on GIPHY" class="fq aq as ag cf" scrolling="auto" style="box-sizing: inherit; height: 388.893px; top: 0px; left: 0px; width: 691.992px; position: absolute;"></iframe>


And we can upgrade them.

Thanks for sticking it through this article about delegate proxies, and happy coding!
