# Gas Optimization in Solidity Part I: Variables
![](https://img.learnblockchain.cn/2020/09/03/15991036968686.jpg)

*This article was written for Solidity 0.5.8*
*本文基于Solidity 0.5.8版本*

Gas optimization is a challenge that is unique to developing Ethereum smart contracts. To be successful, we need to learn how Solidity handles our variables and functions under the hood.
gas优化是开发以太坊智能合约所面临的一个独特挑战。要想成功，我们需要学习solidity如何在幕后处理变量和函数。

Therefore we cover gas optimization in two parts.
因此我们将gas优化分为两部分

In Part I we discuss variables by learning about variable packing and data type trade-offs.
在第一部分中，我们通过学习如何权衡变量打包和数据类型。

In Part II we discuss functions by learning about visibility, reducing execution, and reducing bytecode.
在第二部分中，我们通过学习可见性、减少执行和减少字节码来优化gas。

Some of the techniques we cover will violate well known code patterns. Before optimizing, we should always consider the technical debt and maintenance costs we might incur.
我们所介绍的一些技术将可能违反众所周知的代码模式。在优化之前，我们应该始终考虑可能产生的技术债务和维护成本。

# Optimizing variables
# 优化变量

## Variable packing
## 变量打包

Solidity contracts have contiguous 32 byte (256 bit) slots used for storage. When we arrange variables so multiple fit in a single slot, it is called variable packing.

Solidity合同用连续32字节的插槽来储存。当我们在一个插槽中放置多个变量，它被称为变量包装。

Variable packing is like a game of Tetris. If a variable we are trying to pack exceeds the 32 byte limit of the current slot, it gets stored in a new one. We must figure out which variables fit together the best to minimize wasted space.

变量打包就像俄罗斯方块游戏。如果我们试图打包的变量超过当前槽的32字节限制，它将被存储在一个新的插槽中。我们必须找出哪些变量最适合放在一起，以最小化浪费的空间。

Because each storage slot costs gas, variable packing helps us optimize our gas usage by reducing the number of slots our contract requires.

因为使用每个插槽都需要消耗gas，变量打包通过减少合约要求插槽数量，帮助我们优化gas的使用。

Let’s look at an example:
我们来看个例子

```
uint128 a;
uint256 b;
uint128 c;
```

These variables are not packed. If `b` was packed with `a`, it would exceed the 32 byte limit so it is instead placed in a new storage slot. The same thing happens with `c` and `b`.

这些变量无法打包。如果`b`和`a`打包在一起，那么就会超过32字节的限制，所以会被放在新的一个储存插槽中。`c`和`b`打包也如此。

```
uint128 a;
uint128 c;
uint256 b;
```

These variables are packed. Because packing `c` with `a` does not exceed the 32 byte limit, they are stored in the same slot.

这些变量是可以被打包的。因为`c`和`a`打包之后不会超过32字节，他们可以被存放在一个插槽中。

Keep variable packing in mind when choosing data types — a smaller version of a data type is only useful if it helps pack the variable in a storage slot. If a `uint128` does not pack, we might as well use a `uint256`.

在选择数据类型时，留心变量打包，如果刚好可以与其他变量打包放入一个储存插槽中，那么使用一个小数据类型是不错的。如果`uint128`不能被打包，那么选择`uint256`

**Data location**
**数据位置**

Variable packing only occurs in storage — memory and call data does not get packed. You will not save space trying to pack function arguments or local variables.
变量打包只发生在存储中，内存或者调用数据是不会打包的。打包函数参数或者本地变量对节省空间是没有帮助的。

**Reference data types**
**引用数据类型**

Structs and arrays always begin in a new storage slot — however their contents can be packed normally. A `uint8` array will take up less space than an equal length `uint256` array.
结构和数组经常会被放在一个新的储存插槽中。但是他们的内部数据是可以正常打包的。一个`uint8`数组会比`uint256`数组占用更小的空间。

It is more gas efficient to initialize a tightly packed struct with separate assignments instead of a single assignment. Separate assignments makes it easier for the optimizer to update all the variables at once.
在初始化结构时，分开赋值比一次性赋值会更有效。分开赋值使得优化器一次性更新所有变量。

Initialize structs like this:
初始化结构如下：

```
Point storage p = Point()
p.x = 0;
p.y = 0;
```

Instead of:
而非如下：

```
Point storage p = Point(0, 0);
```

**Inheritance**
**继承**
When we extend a contract, the variables in the child can be packed with the variables in the parent.
当你扩展一个合约时，在子合约中的变量可以同母合约中的变量一起打包。

The order of variables is determined by [C3 linearization](https://en.wikipedia.org/wiki/C3_linearization). For most applications, all you need to know is that child variables come after parent variables.
变量的顺序是由[C3 linearization](https://en.wikipedia.org/wiki/C3_linearization)决定的。大部分的情况下，你只要知道子变量都在母变量之后。

## Data types
## 数据类型

We have to manage trade-offs when selecting data types to optimize gas. Different situations can make the same data type cheap or expensive.
在选择数据类型以优化gas时，我们必须权衡利弊。相同的数据类型在不同的情况会也会有便宜或昂贵之分。


**Memory vs. Storage**
**内存和存储**

Performing operations on memory — or call data, which is similar to memory — is always cheaper than storage.
在内存中进行运行或者调用数据（同内存中运行一样），都是比存储便宜的。

A common way to reduce the number of storage operations is manipulating a local memory variable before assigning it to a storage variable.
减少存储操作的一种常见方法是在分配给存储变量之前，对本地内存变量其进行操作。


We see this often in loops:
我们经常看到这样的循环：

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

在`calculateReturn`函数中，我们使用本地内存变量`r`用来存放中间变量，在最后将给过赋值给`totalReturn`。

**Fixed vs. Dynamic**
**固定和动态**
Fixed size variables are always cheaper than dynamic ones.
固定大小的变量一般比动态变量便宜

If we know how long an array should be, we specify a fixed size:
如果我们知道一个数组有多少元素，我们优先采用固定大小的方式：

```
uint256[12] monthlyTransfers;
```

This same rule applies to strings. A `string` or `bytes` variable is dynamically sized; we should use a `byte32` if our string is short enough to fit.
同样的道理也适用于字符型，一个`string`或者`bytes`变量是动态。如果一个字符很短，我们可以使用`byte32`

If we absolutely need a dynamic array, it is best to structure our functions to be additive instead of subractive. Extending an array costs constant gas whereas truncating an array costs linear gas.
如果我们必须需要一个动态数组，最好将函数设计成加，而不是减的。扩展数组消耗稳定Gas，而截断数组消耗线性gas。

**Mapping vs. Array**
**映射和数组**

Most of the time it will be better to use a `mapping` instead of an array because of its cheaper operations.
大多数的情况下，使用映射会优于数组。

However, an array can be the correct choice when using smaller data types. Array elements are packed like other storage variables and the reduced storage space can outweigh the cost of an array’s more expensive operations. This is most useful when working with large arrays.

但是，如果是使用较小的数据类型，数组是一个不错的选择。数组元素会像其他存储变量被打包，节省的存储空间可能会弥补更昂贵数组操作。这个方法在处理大型数组时很有用。

## Other techniques
## 其他方式

There are a few other techniques when working with variables that can help us optimize gas cost.
在处理变量时，还有一些其他技术可以帮助我们优化gas成本。

**Initialization**
**初始化**

Every variable assignment in Solidity costs gas. When initializing variables, we often waste gas by assigning default values that will never be used.
在Solidity中，每个变量的赋值都要消耗gas。在初始化变量时，我们经常会设置永远不会使用的默认值。

`uint256 value;` is cheaper than `uint256 value = 0;`.
`uint256 value;`比`uint256 value = 0;`更便宜。

**Require strings**
**Require字符串**

If we are adding message strings to require statements, we can make them cheaper by limiting the string length to 32 bytes.
如果你在require中增加语句，你可以通过限制字符串长度为32字节来降低gas消耗。

**Unpacked variables**
**不打包变量**
The EVM operates on 32 bytes at a time, variables smaller than that get converted. If we are not saving gas by packing the variable, it is cheaper for us to use 32 byte data types such as `uint256`.
以太坊虚拟机一次处理32字节，变量大小小于32字节的会被转化。如果你打包变量没有节省gas，那么直接使用`uint256`会更便宜。

**Deletion**
**删除**

Ethereum gives us a gas refund when we delete variables. Its purpose is an incentive to save space on the blockchain, we use it to reduce the gas cost of our transactions.
当我们删除变量时，以太坊会给我们退款。它的目的是为了鼓励节约区块链上的空间，我们用它来减少交易的gas成本。

Deleting a variable refunds 15,000 gas up to a maximum of half the gas cost of the transaction. Deleting with the `delete` keyword is equivalent to assigning the initial value for the data type, such as `0` for integers.

删除一个变量可以退15,000起，最高可达交易消耗gas的一半。使用“delete”关键字进行删除相当于为数据类型分配初始值，比如为整数分配“0”。

**Storing data in events**
Data that does not need to be accessed on-chain can be stored in events to save gas.
那些不需要在链上被访问的数据可以存放在事件中来达到节省gas的目的。

While this technique can work, it is not recommended — events are not meant for data storage. If the data we need is stored in an event emitted a long time ago, retrieving it can be too time consuming because of the number of blocks we need to search.
虽然可以这个操作，但不推荐使用——事件并不是用于数据存储。如果我们需要的数据存储在很久以前发出的事件中，由于需要搜索的块数量太多，获取这个数据可能会非常耗时。

# Optimizing functions
# 优化函数

*Gas Optimization in Solidity Part II: Functions* coming soon…


原文链接：https://medium.com/coinmonks/gas-optimization-in-solidity-part-i-variables-9d5775e43dde
作者：[Will Shahda](https://medium.com/@ethdapp)

