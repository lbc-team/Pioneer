# Value Arrays in Solidity

This article discusses using Value Arrays as a way to reduce gas consumption in Solidity, the defacto smart contract language for the Ethereum blockchain.



## Background

During the development and testing of Datona Labs’ Solidity Smart-Data-Access-Contract (S-DAC) templates, we often need to use small arrays of small values. In the examples for this article, I investigate whether using Value Arrays will help me to do that more efficiently than Reference Arrays.

# Discussion

Solidity supports arrays in *memory* which can be wasteful of space (see [here](https://solidity.readthedocs.io/en/latest/types.html#arrays)), and in *storage* which consume a lot of gas to allocate and access. But Solidity also runs on the Ethereum Virtual Machine (EVM) which has a very large [machine word](https://en.wikipedia.org/wiki/Word_(computer_architecture)) of 256bits (32bytes). It is this latter feature that enables us to consider using Value Arrays. In languages with smaller word types e.g. 32bits (4bytes), Value Arrays are unlikely to be practical.

Can we reduce our storage space and gas consumption using Value Arrays?

## Value Arrays compared to Reference Arrays

### Reference Arrays

In Solidity, arrays are normally *reference types*. That means that a *pointer to the array* is used whenever the variable symbol is encountered in the program text, although there are several exceptions where a copy is made instead (see [here](https://solidity.readthedocs.io/en/latest/types.html#reference-types)). In the following code, a 10 element array of 8bit uints **users** is passed to the function *setUser*, which sets one of the elements in the users array:

```
contract TestReferenceArray {
    function test() public pure {
        uint8[10] memory users;
    
        setUser(users, 5, 123);
        require(users[5] == 123);
    }
    
    function setUser(uint8[10] memory users, uint index, uint8 ev) 
    public pure {
        users[index] = ev;
    }
}
```

After the function returns, the array element in **users** will have been changed.

### Value Arrays 

A Value Array is an array held in a *value type*. That means that the *value* is used whenever the variable symbol is encountered in the program text.

```
contract TestValueArray {
    function test() public pure {
        uint users;
    
        users = setUser(users, 5, 12345);
        require(users == ...);
    }
    
    function setUser(uint users, uint index, uint ev) public pure 
    returns (uint) {
        return ...;
    }
}
```

Note that after the function returns, the **users** argument to the function will be *unchanged* since it was passed by value — it is necessary to assign the function return value to the **users** variable in order to obtain the changed value.

## Solidity bytes32 Value Array

Solidity provides a partial Value Array in the bytesX (X = 1..32) types. These hold bytes which may be read individually using array-style access, for instance:

```
    ...
    bytes32 bs = "hello";
    byte b = bs[0];
    require(bs[0] == 'h');
    ...
```

But unfortunately, in [Solidity v0.7.1](https://solidity.readthedocs.io/en/latest/types.html#fixed-size-byte-arrays) we can’t write to the individual bytes using array-style access:

```
    ...
    bytes32 bs = "hello";
    bs[0] = 'c'; // unfortunately, this is NOT possible!
    ...
```

So firstly, let’s add that facility to the bytes32 type using Solidity’s helpful [*using library for type*](https://solidity.readthedocs.io/en/latest/contracts.html#using-for) in an import library file:

```
library bytes32lib {
    uint constant bits = 8;
    uint constant elements = 32;
    
    function set(bytes32 va, uint index, byte ev) internal pure 
    returns (bytes32) {
        require(index < elements);
        index = (elements - 1 - index) * bits;
        return bytes32((uint(va) & ~(0x0FF << index)) | 
                        (uint(uint8(ev)) << index));
    }
}
```

This library provides the function *set()* which enables the caller to set any byte in the bytes32 variable to any desired byte value. Depending upon your requirements, you may wish to generate similar libraries for the other bytesX types that you use.

### Sunny Day Testing

Let’s import that library and test it:

```
import "bytes32lib.sol";contract TestBytes32 {
    using bytes32lib for bytes32;
    
    function test1() public pure {
        bytes32 va = "hello";
        require(va[0] == 'h');
        // the replacement for this: va[0] = 'c';
        va = va.set(0, 'c');
        require(va[0] == 'c');
    }
}
```

Here, you can clearly see that the return value from the *set()* function is **assigned** back to the argument variable. If the assignment is absent, the variable will remain unchanged, as tested by require().

# Possible Fixed Value Arrays

In the Solidity machine word type, 256bits (32bytes), we can consider the following possible Value Arrays.

## Fixed Value Arrays

These are Fixed Value Arrays that match some of the Solidity available [types](https://solidity.readthedocs.io/en/latest/types.html#integers):

```
                         Fixed Value Arrays
Type         Type Name   Description
uint128[2]   uint128a2   two 128bit element values
uint64[4]    uint64a4    four 64bit element values
uint32[8]    uint32a8    eight 32bit element values
uint16[16]   uint16a16   sixteen 16bit element values
uint8[32]    uint8a32    thirty-two 8bit element values
```

I propose the Type Name as shown above, which is used throughout this article, but you may find a preferable naming convention.

## More Fixed Value Arrays

Actually, there are many more possible Value Arrays. We can also consider types that do not match Solidity’s available types, but may be useful for a particular solution. The number of bits in the X value multiplied by the number of Y elements must be less than or equal to 256:

```
                    More Fixed Value Arrays
Type         Type Name   Description
uintX[Y]     uintXaY     X * Y <= 256

uint10[25]   uint10a25   twenty-five 10bit element values

uint7[36]    uint7a36    thirty-six 7bit element values
uint6[42]    uint6a42    forty-two 6bit element values
uint5[51]    uint5a51    fifty-one 5bit element values
uint4[64]    uint4a64    sixty-four 4bit element values

uint1[256]   uint1a256   two-hundred & fifty-six 1bit element valuesetcetera
```

Of particular interest is the uint1a256 Value Array. That allows us to efficiently encode up to two-hundred and fifty-six 1bit element values, which represent booleans, into 1 EVM word. Compare that with Solidity’s bool[256] which consumes 256 times as much space in memory, and even 8 times as much space in storage.

## Even More Fixed Value Arrays

There are even more possible Value Arrays. The above are the most efficient Value Array types because they map efficiently onto bits in the EVM word. In the Value Array types above, X is always a number of bits. An alternative to the bitwise shifting technique being used here is to use multiplication and division as in arithmetic coding (see [here](https://en.wikipedia.org/wiki/Arithmetic_coding)), but that is beyond the scope of this article.



## Fixed Value Array Implementation

Here is a useful import file providing get and set functions for the Value Array type uint8a32:

```
// uint8a32.sollibrary uint8a32 { // provides the equivalent of uint8[32]
    uint constant bits = 8;
    uint constant elements = 32;
    
    // must ensure that bits * elements <= 256
   
    uint constant range = 1 << bits;
    uint constant max = range - 1;    
    // get function
    function get(uint va, uint index) internal pure returns (uint) {
        require(index < elements);
        return (va >> (bits * index)) & max;
    }
    
    // set function
    
    function set(uint va, uint index, uint ev) internal pure 
    returns (uint) {
        require(index < elements);
        require(value < range);
        index *= bits;
        return (va & ~(max << index)) | (ev << index);
    }
}
```

The *get()* function simply returns the appropriate value from the value array according to the index parameter. The *set()* function will remove the existing value and then set the given value into the returned value according to the index parameter.

As you can deduce, the other uintXaY Value Array types are available simply by copying the uint8a32 library code given above and then changing the **bits** and **elements** constants.

Storage space variables are [not permitted](https://solidity.readthedocs.io/en/latest/contracts.html#libraries) in Solidity library contracts.

### Sunny Day Testing

Let’s see a few simple, sunny day tests for the example library code above:

```
import "uint8a32.sol";

contract TestUint8a32 {
    using uint8a32 for uint;
    
    function test1() public {
        uint va;
        va = va.set(0, 0x12);
        require(va.get(0) == 0x12, "va[0] not 0x12");
        
        va = va.set(1, 0x34);
        require(va.get(1) == 0x34, "va[1] not 0x34");
       
        va = va.set(31, 0xF7);
        require(va.get(31) == 0xF7, "va[31] not 0xF7");
    }
}
```

The syntax for using the set() function is able to use variable dot notation due to the use of the compiler’s *using library for type* directive. However, where your smart contract requires multiple different Value Array types, that is not possible due to a namespace clash (only 1 function of a particular name may be used for each type), so the explicit library name dot notation must be used to access the functions instead:

```
import "uint8a32.sol";
import "uint16a16.sol";
contract MyContract {    uint users; // uint8a32
    uint roles; // uint16a16
    
    ...
    
    function setUser(uint n, uint user) private {
        // wanted to do this: users = users.set(n, user);
        users = uint8a32.set(users, n, user);
    }
    
    function setRole(uint n, uint role) private {
        // wanted to do this: roles = roles.set(n, role);
        roles = uint16a16.set(roles, n, role);
    }
    
    ...
}
```

It is also necessary to be vigilant about using the correct Value Array type on the correct variable.

Here is the same code, but with the data type incorporated into the variable name, in an attempt to address that issue:

```
import "uint8a32.sol";
import "uint16a16.sol";contract MyContract {    uint users_u8a32;
    uint roles_u16a16;
    
    ...
    function setUser(uint n, uint user) private {
        users_u8a32 = uint8a32.set(users_u8a32, n, user);
    }
    
    function setRole(uint n, uint role) private {
        roles_u16a16 = uint16a16.set(roles_u16a16, n, role);
    }
    ...
}
```

## Avoiding Assignment

It is actually possible to avoid using assignment of the return value from the set() function if we provide a function that takes a 1 element array. However, since this technique uses more memory, code and complexity, it negates the possible advantages of using Value Arrays.

**Here’s a final enigmatic picture before discussing gas consumption**.



# Gas Consumption

Having written the libraries and contracts, we measured the gas consumption using a technique described in [this](https://medium.com/coinmonks/gas-cost-of-solidity-library-functions-dbe0cedd4678) article by the author. Here are the results:

## bytes32 Value Array



![1_1rFIufB3Y9e6txiTnDpoKQ](https://img.learnblockchain.cn/pics/20200820105003.png)

> Gas consumption of get and set on memory and storage bytes32 variables

Not surprisingly, the memory gas consumption is negligible, whilst the storage gas consumption is huge — especially the first time the storage location is written with a non-zero value (large blue brick). Subsequent use of that storage location consumes far less gas.

## uint8a32 Value Array

Here, we compare using fixed uint8[] arrays with a uint8a32 Value Array in EVM memory space:

![1_JfZiUjlfmgDn32mQ81PmgA](https://img.learnblockchain.cn/pics/20200820105037.png)



> Gas consumption of get and set on uint8/byte memory variables

The surprising take away is that the uint8a32 Value Array consumes as litle as half the gas of the uint8[32] Solidity fixed array. In the case of uint8[16] and uint8[4], the associated gas consumption is correspondingly lower. This is because the Value Array code has to read and write the value in order to set an element value, whereas the uint8[] simply has to write the value.

This is how these compare in EVM storage space:



![1_TZiKYOx8k5fQKQIW943G7g](https://img.learnblockchain.cn/pics/20200820105111.png)



>  Gas consumption of get and set on uint8/byte storage variables

Here, each uint8a32 set() function consumes a few hundred fewer gas cycles compared to using uint8[Y]. The gas consumption of uint8[32], uint8[16] and uint8[4] are all the same because they use the same amount of EVM storage space, one 32byte slot.

## uint1a256 Value Array

Comparison of fixed bool[] arrays with a uint1a256 Value Array in EVM memory space:

![1_eypziNSbrSGT3xbCh0EYug](https://img.learnblockchain.cn/pics/20200820105136.png)



> Gas consumption of get and set on bool/1bit memory variables

It is clear that the gas consumption of allocating the bool arrays dominates.

The same comparison in EVM storage space:

![1_pqdUNkuGjqJd7UyejQxoIg](https://img.learnblockchain.cn/pics/20200820105204.png)



> Gas consumption of get and set on bool/1bit storage variables

The simplistic test touches 2 storage slots for bool[256] and bool[64], hence the similar gas consumption. Bool[32] and uint1a256 touch just one storage slot.

## Parameters to sub-contracts and libraries

![1_CClRdKPbYQUCcfuxBdULUw](https://img.learnblockchain.cn/pics/20200820105235.png)

> Gas consumption of passing a bool/1bit parameter to a sub-contract or library



Not surprisingly, the biggest gas consumption is providing an array parameter to a sub-contract or library function.

Using a single value instead of copying the array clearly consumes far less gas.

# Other Possibilities

If you find Fixed Value Arrays useful, you may also like to consider Fixed Multi Value-Arrays, Dynamic Value-Arrays, Value Queues, Value Stacks etcetera.

# Conclusions

I have provided and measured code for writing to Solidity bytes32 variables, and generic library code for uintX[Y] Value Arrays.

I have revealed other possibilities such as Fixed Multi-Value Arrays, Dynamic Value Arrays, Value Queues, Value Stacks etcetera.

Yes, we can reduce our storage space and gas consumption using Value Arrays.

Where your Solidity smart contracts use small arrays of small values (for user IDs, roles etcetera), then the use of Value Arrays is likely to consume less gas.

Where arrays are copied e.g. for sub-contracts or libraries, Value Arrays will always consume vastly less gas.

In other circumstances, continue to use reference arrays.





作者：[Julian Goddard](https://medium.com/@plaxion?source=post_page-----32ca65135d5b----------------------)

https://medium.com/coinmonks/value-arrays-in-solidity-32ca65135d5b