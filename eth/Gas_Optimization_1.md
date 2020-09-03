
# Gas Optimization in Solidity Part I: Variables
![](https://img.learnblockchain.cn/2020/09/03/15991036968686.jpg)

*This article was written for Solidity 0.5.8*

Gas optimization is a challenge that is unique to developing Ethereum smart contracts. To be successful, we need to learn how Solidity handles our variables and functions under the hood.

Therefore we cover gas optimization in two parts.

In Part I we discuss variables by learning about variable packing and data type trade-offs.

In Part II we discuss functions by learning about visibility, reducing execution, and reducing bytecode.

Some of the techniques we cover will violate well known code patterns. Before optimizing, we should always consider the technical debt and maintenance costs we might incur.

# Optimizing variables

## Variable packing

Solidity contracts have contiguous 32 byte (256 bit) slots used for storage. When we arrange variables so multiple fit in a single slot, it is called variable packing.

Variable packing is like a game of Tetris. If a variable we are trying to pack exceeds the 32 byte limit of the current slot, it gets stored in a new one. We must figure out which variables fit together the best to minimize wasted space.

Because each storage slot costs gas, variable packing helps us optimize our gas usage by reducing the number of slots our contract requires.

Let’s look at an example:

```
uint128 a;
uint256 b;
uint128 c;
```

These variables are not packed. If `b` was packed with `a`, it would exceed the 32 byte limit so it is instead placed in a new storage slot. The same thing happens with `c` and `b`.

```
uint128 a;
uint128 c;
uint256 b;
```

These variables are packed. Because packing `c` with `a` does not exceed the 32 byte limit, they are stored in the same slot.

Keep variable packing in mind when choosing data types — a smaller version of a data type is only useful if it helps pack the variable in a storage slot. If a `uint128` does not pack, we might as well use a `uint256`.

**Data location**
Variable packing only occurs in storage — memory and call data does not get packed. You will not save space trying to pack function arguments or local variables.

**Reference data types**
Structs and arrays always begin in a new storage slot — however their contents can be packed normally. A `uint8` array will take up less space than an equal length `uint256` array.

It is more gas efficient to initialize a tightly packed struct with separate assignments instead of a single assignment. Separate assignments makes it easier for the optimizer to update all the variables at once.

Initialize structs like this:

```
Point storage p = Point()
p.x = 0;
p.y = 0;
```

Instead of:

```
Point storage p = Point(0, 0);
```

**Inheritance**
When we extend a contract, the variables in the child can be packed with the variables in the parent.

The order of variables is determined by [C3 linearization](https://en.wikipedia.org/wiki/C3_linearization). For most applications, all you need to know is that child variables come after parent variables.

## Data types

We have to manage trade-offs when selecting data types to optimize gas. Different situations can make the same data type cheap or expensive.

**Memory vs. Storage**
Performing operations on memory — or call data, which is similar to memory — is always cheaper than storage.

A common way to reduce the number of storage operations is manipulating a local memory variable before assigning it to a storage variable.

We see this often in loops:

```
uint256 return = 5; // assume 2 decimal places
uint256 totalReturn;

function updateTotalReturn(uint256 timesteps) external {
    uint256 r = totalReturn || 1;
    
    for (uint256 i = 0; i < timesteps; i++) {
        r = r * return;
    }
    totalReturn = r;
}
```

In `calculateReturn`, we use the local memory variable `r` to store intermediate values and assign the final value to our storage variable `totalReturn`.

**Fixed vs. Dynamic**
Fixed size variables are always cheaper than dynamic ones.

If we know how long an array should be, we specify a fixed size:

```
uint256[12] monthlyTransfers;
```

This same rule applies to strings. A `string` or `bytes` variable is dynamically sized; we should use a `byte32` if our string is short enough to fit.

If we absolutely need a dynamic array, it is best to structure our functions to be additive instead of subractive. Extending an array costs constant gas whereas truncating an array costs linear gas.

**Mapping vs. Array**
Most of the time it will be better to use a `mapping` instead of an array because of its cheaper operations.

However, an array can be the correct choice when using smaller data types. Array elements are packed like other storage variables and the reduced storage space can outweigh the cost of an array’s more expensive operations. This is most useful when working with large arrays.

## Other techniques

There are a few other techniques when working with variables that can help us optimize gas cost.

**Initialization**
Every variable assignment in Solidity costs gas. When initializing variables, we often waste gas by assigning default values that will never be used.

`uint256 value;` is cheaper than `uint256 value = 0;`.

**Require strings**
If we are adding message strings to require statements, we can make them cheaper by limiting the string length to 32 bytes.

**Unpacked variables**
The EVM operates on 32 bytes at a time, variables smaller than that get converted. If we are not saving gas by packing the variable, it is cheaper for us to use 32 byte data types such as `uint256`.

**Deletion**
Ethereum gives us a gas refund when we delete variables. Its purpose is an incentive to save space on the blockchain, we use it to reduce the gas cost of our transactions.

Deleting a variable refunds 15,000 gas up to a maximum of half the gas cost of the transaction. Deleting with the `delete` keyword is equivalent to assigning the initial value for the data type, such as `0` for integers.

**Storing data in events**
Data that does not need to be accessed on-chain can be stored in events to save gas.

While this technique can work, it is not recommended — events are not meant for data storage. If the data we need is stored in an event emitted a long time ago, retrieving it can be too time consuming because of the number of blocks we need to search.

# Optimizing functions

*Gas Optimization in Solidity Part II: Functions* coming soon…


原文链接：https://medium.com/coinmonks/gas-optimization-in-solidity-part-i-variables-9d5775e43dde
作者：[Will Shahda](https://medium.com/@ethdapp)

