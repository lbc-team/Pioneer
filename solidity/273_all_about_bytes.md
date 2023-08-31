> * 原文链接： https://jeancvllr.medium.com/solidity-tutorial-all-about-bytes-9d88fdb22676
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 深入了解 Solidity  bytes



无论是使用固定大小的`bytesN`还是动态大小的`bytes`数组，bytes 都是Solidity的一个重要方面。我们将在本文中了解它们的区别、与固定大小数组 `bytesN` 相关的位操作，并使用它们执行一些通用方法，如连接。



## 1. Solidity中的字节数据布局

### 关于端（Endianness ）

在计算机中，术语 "端"（*endianness*）用来说明数据的低位字节的存储和排序方式。因此，它定义了计算机或机器存储的内部排序。

我们所说的**多字节数据类型**数据是指类型（如 uint、float、string等......），在计算机中，多字节数据类型有两种排序方式：**小端**格式或**大端**格式（其中格式=顺序）。

- 在**大端**格式下，多字节数据类型二进制表示的第一个字节先存储（**高位字节先保存**）。

- 使用**小端**格式时，先存储多字节数据类型二进制表示的最后一个字节。(英特尔 x86 计算机）

  如：值为 `0x01234567`（十六进制表示法）的变量，在两个格式下的存储是这样的：

![大端与小端存储 0x01234567 ](https://img.learnblockchain.cn/2023/08/24/72403.gif)

<p align="center">两种格式下的存储方式</p>



### Solidity 中的字节数据布局

以太坊和 EVM 是一种使用 [大端格式](https://github.com/ethereum/solidity-examples/issues/54) 的虚拟机。在 EVM 中，所有数据（无论其 Solidity 类型如何）都以大端格式存储在虚拟机内部。最重要的是，EVM 使用 32 字节的字来处理数据。

然而，根据其类型（`bytesN`、`uintN`、`address`等......），数据的布局有所不同。`数据如何布局 `**指的是**高阶位数据如何放置。

在以太坊和 Solidity 开发者社区中，这被称为填充规则：左填充与右填充。

以下是Solidity中使用的填充规则：

- 使用**右填充(right-padded)**类型： `string`, `bytes` 和 `bytesN`.
- 使用**左填充(left-padded)**类型：`intN` / `uintN` （有符号/无符号整数）、 `address` 和其他类型。

**注意**：你还会发现 "左对齐"或 "右对齐 "的说法。

为了更好地澄清和避免混淆：

> 左填充 = 右对齐
>
> 右填充 = 左对齐

例如，Solidity 中的 `string value = "abcd"` 字符串将被 EVM 填充为一个完整的 32 字节， 0 填充在右侧。

```
0x6162636400000000000000000000000000000000000000000000000000000000
```

相反，Solidity 中的数字 `uint256 value = 1_633_837_924`（= `0x61626364` 十六进制）被 EVM 填充为一个完整的 32 字节时。0 将被填充在左边：

```
0x0000000000000000000000000000000000000000000000000000000061626364
```

学习数据布局和填充规则对于了解如何在 Solidity 中处理不同的数据类型非常重要。尤其是在处理 `bytesN` 和它们的 `uintN` 相关类型时。例如，对于 `bytes1` 和 `uint8` 值，即使它们具有相同的位大小，其内部表示也是不同的。请看下面的代码片段。

```solidity
// 0x00000000…01
Uint8 a = 1;

// 0x01000000….
byte b = 1;
bytes1 c = 
```





本文主要讨论 `bytesN` 和 `bytes` 类型。Solidity 提供了两种字节类型：

- **固定大小的**字节数组：`bytesN`
- **动态大小的字节数组：** `bytes`，表示字节序列。

## 2. 固定大小的字节数组

可以使用关键字 `bytesX` 来定义变量，其中 `X` 代表字节数。`X` 可以从 1 到 32

`byte` 是 `bytes1` 的别名，因此存储的是单字节。

**如果可以将长度限制在一定的字节数，请务必使用 bytes1 至 bytes32 中的一个，因为它们更便宜。**

具有固定大小变量的字节可以在合约之间传递。

## 3. 动态调整字节数组大小

这是一种非常特殊的类型。基本上，`bytes`和 `string`是特殊的数组[(参见 Solidity 文档)](https://solidity.readthedocs.io/en/v0.5.10/types.html#bytes-and-strings-as-arrays)

### bytes

`bytes` 来表示任意长度的原始字节数据

在 Solidity 中，术语 `bytes` 表示字节动态数组。它是 `byte[]` 的简写。

在 Solidity 代码中，`bytes`被视为数组，因此它的长度可以为零，你也可以在它的末尾添加一个字节。

然而，`bytes`并不是一个值类型！

### string

> 若是任意长度的字符串（UTF-8）数据使用字符串。

```
bytes32 someString = "stringliteral";
```

该字符串常量量分配给 bytes32 类型时，将以原始字节形式解释。

但是，字符串不能在合约之间传递，因为它们不是固定大小的变量。



Solidity 本身没有字符串操作函数（除了 `concat`），但第三方字符串库可以使用。

## 4. Solidity 中的位运算

> 本节大部分内容基于以下作者的文章[Maksym](https://medium.com/u/7fd5bdfe59e7?source=post_page-----9d88fdb22676--------------------------------)
>

Solidity 支持基本的位操作（虽然缺少一些，如左移右移），幸好有算术相等。下面将介绍一些位操作的基本原理。

### 比较运算符

以下用于字节的比较运算符的值为 `bool` 值： `true` 或 `false` 。

```
<=, <, ==, !=, >=, >
```

### 位运算符

Solidity 中提供了以下位运算符： `&` (**与),** `|` **(或),** `^` **(异或)** 和 `~` **(非).**

为简单起见，我们将对两个变量使用 `bytes1` 数据类型（等于 `byte` ）：`a`和`b`。我们将在 Solidity 中使用它们的十六进制表示法来初始化它们。

```
bytes1 a = 0xb5; //  [10110101]
bytes1 b = 0x56; //  [01010110]
```

下表显示了它们的二进制格式。

![img](https://img.learnblockchain.cn/2023/08/24/62488.png)

>  **注：** 输入为白色背景，**结果将以黄色高亮显示**

**让我们来看看 :**

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

`&` (**与**) : 两个位都必须是 **1**（白色行），结果才为 true（1 => 黄色行）。

![img](https://img.learnblockchain.cn/2023/08/24/77377.png)

```
a & b; // Result: 0x14  [00010100]
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

`|` (**或**) : 至少有一个位必须为 **1** (白色行)，结果才为 true (**1 => 黄色行)**。

![img](https://img.learnblockchain.cn/2023/08/24/3420.png)

```
a | b; // Result: 0xf7  [11110111]
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

`^` (**XOR**) : **异或**

**XOR 运算常用于构建保护隐私的加密算法。一个例子是 DC 网**： [ 基于 Dining Cryptographer 问题.](https://en.wikipedia.org/wiki/Dining_cryptographers_problem)

这是两个输入之间的不同。其中一个输入必须为**1**，另一个输入必须为**0**，结果才为真。简单地说，`a[i] != b[i]`。

- 如果两个输入值相同（1 和 1，或 0 和 0），则结果为 false（0）。
- 如果两个输入值不同（1 和 0，或 0 和 1），则结果为 true (1)

![img](https://img.learnblockchain.cn/2023/08/24/81488.png)

```
a ^ b; // Result: 0xe3  [11100011]
```

一个有趣的特性是，如果你想知道原始 **b** 的值是多少，只需将结果与 **a** XOR 即可。从某种意义上说，**a** 是打开**b** 的钥匙。

```
0xe3 ^ a; // Result: 0x56 == b  [01010110]
```



- `~` (**取反**) : 按位取反

> **NB:** 否定与将输入与所有 **1**s 进行 XOR 处理相同。

这也被称为*反转操作。* 通过此操作，0 变为 1，1 变为 0。

![img](https://img.learnblockchain.cn/2023/08/24/67407.png)

```
a ^ 0xff; // Result: 0x4a  [01001010]
```

下面是 Solidity 的实现：

```solidity
function negate(bytes1 a) returns (bytes1) {
    return a ^ allOnes();
}

// Sets all bits to 1
function allOnes() returns (bytes1) { 
   // 0 - 1, since data type is unsigned, this results in all 1s. 
    return bytes1(-1);
}
```

### 移位操作符

> 来自 Solidity 文档： 移位运算符可以任何整数类型作为右操作数（但返回左操作数的类型），右操作数表示要移位的位数。负数移位会导致运行时异常。

**让我们看看 :**

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

`<< x` （左移 `x`位）

示例：将一个数字左移 3 位

![img](https://img.learnblockchain.cn/2023/08/24/95987.png)

```solidity
function leftShiftBinary(
    bytes32 a, 
    uint n
) public pure returns (bytes32) {
    return bytes32(uint(a) * 2 ** n);
}

// This function does the same than above using the << operators
function leftShiftBinary2(
    bytes32 a, 
    uint n
) public pure returns (bytes32) {
    return a << n;
}

// Normally, we should do the following according to the article,
// but explicit conversion is not allowed for bytes to uintvar n = 3; 
var aInt = uint8(a); // Converting bytes1 into 8 bit integer
var shifted = aInt * 2 ** n;
bytes1(shifted);     // Back to bytes. Result: 0xa8  [10101000]
```

`>>x` （ 右移`x` 位）

示例： 右移 2 位

![img](https://img.learnblockchain.cn/2023/08/24/70327.png)

```solidity
function rightShiftBinary(
    bytes32 a, 
    uint n
) public pure returns (bytes32) {
    return bytes32(uint(a) / 2 ** n);
}

// This function does the same than above using the >> operators
function rightShiftBinary2(
    bytes32 a, 
    uint n
) public pure returns (bytes32) {
    return a >> n;
}

// Normally, we should do the following according to the article,
// but explicit conversion is not allowed for bytes to uint
var n = 2; 
var aInt = uint8(a); // Converting bytes1 into 8 bit integer
var shifted = aInt / 2 ** n;
bytes1(shifted);     // Back to bytes. Result: 0x2d  [00101101]
```

### 索引访问（只读）

> 如果 `x` 是 `bytesI` 类型（其中 `I` 表示整数），那么 `x[k]` （满足 0 <= k < I ） 返回第 `k` 个字节。

所有 `bytesN` 类型都可以通过索引访问单个字节， 最高阶的字节位于索引 0。让我们举例说明：

```solidity
function accessByte(
     bytes32 _number_in_hex, 
     uint8 _index
) public pure returns (byte) {
     byte value = _arg[_index];
     return value;
}
```

![solidity bytes index](https://img.learnblockchain.cn/2023/08/24/61324.png)

>  在 Remix 中应该得到的结果

如果我们传递参数 `_number_in_hex = 0x61626364` 和 `_index = 2`，函数将返回 `0x63`，如截图所示。

### bytes 的成员

`.length` (只读) : 返回字节数组的固定长度

## 5. byte[] 与 bytes 

根据 Solidity 文档: `byte[]` 类型是一个字节数组，但由于填充规则，每个元素会浪费 31 个字节的空间（存储空间除外）。

最好使用 `bytes` 类型。

## 6. bytes 作为函数参数

固定长度的`bytes32`可用于函数参数，以在合约中传递数据或从合约中返回数据。

可变长度 `bytes` 也可以在函数参数中使用，但只能在内部使用（同一合约内部），因为接口（ABI）不支持可变长度类型。

## 7. 地址和 bytes20之间的转换

我们知道，以太坊中的地址是一个 20 字节的值（*如:* `0xa59b89aee4f944a04d8fc075967d616b937dd4a7`）。因此，可以用两种方式进行转换。

### `bytes20` 至 `address`

通过**显式转换**，你可以轻松地将 `bytes20 `类型的值转换为 `address`。这意味着你只需将`bytes20`值用括号`()`包起来，并在其前缀上`address`类型，如下所示：

```solidity
address public my_address;

// This function is really expensive the 1st time 
// it's called (21 000 gas). Why ?
function bytesToAddress(bytes20 input) public returns (address) {
    my_address = address(input);
    return my_address;
}
```

如果我们看一下运行此函数后 Remix 中的结果，就会发现从 `bytes20` 到 `address` 的显式转换已成功运行。此外，Solidity 编译器还将其转换成了一个具有有效校验和的地址！请注意输入中不同的大小写字母:

![solidity bytes20 转地址](https://img.learnblockchain.cn/2023/08/24/25150.png)

> 有关校验和的更多信息，请[阅读我们的文章 "关于地址的一切](https://jeancvllr.medium.com/solidity-tutorial-all-about-addresses-ffcdf7efc4e7) "或[参见 Vitalik Buterin 提出的 EIP55](https://github.com/以太坊/EIPs/blob/master/EIPS/eip-55.md)。

### `address` 至 `bytes20`

如果你想将`address`转换为`bytes20`类型并进行一些计算，也可以反过来做。

## 8. 字节的高级操作

### 获取前 N 位

在这种情况下，我们需要 2 个步骤 ：

1. 创建一个**掩码**，其中包含所需的**N**个**1**，以便过滤我们要检索的**a**中的部分。

2. 在a**和**掩码之间应用**AND**操作，这样：`a & mask`。

![获取前 N 位](https://img.learnblockchain.cn/2023/08/24/49616.png)

```solidity
function getFirstNBytes(
    bytes1 _x,
    uint8 _n
) public pure returns (bytes1) {
    require(2 ** _n < 255, “Overflow encountered ! “);
    bytes1 nOnes = bytes1(2 ** _n — 1);
    bytes1 mask = nOnes >> (8 — _n); // Total 8 bits
    return _x & mask;
}
```

### 获取后 N 位

有一种算术方法可以获取最后 N 位。我们可以使用模数法来实现。例如，如果想从**10345**中得到最后两位数，我们可以通过除以**100**（10²）并得到余数来轻松实现：

```solidity
10345 % 10 ** 2 = 45
```

二进制也是如此，不过这次我们得到的是 2 的倍数的模数：

```solidity
var n = 5;
var lastBits = uint8(a) % 2 ** n;
bytes1(lastBits); // Result: 0x15  [00010101]
```

下面是在 Solidity 中的实现:

```solidity
function getLastNBytes(
    byte _A, 
    uint8 _N
) public pure returns (bytes1) {
    require(2 ** _N < 255, “Overflow encountered ! ”);
    uint8 lastN = uint8(_A) % (2 ** _N);
    return byte(lastN);
}
```

### 字节打包

假设有 2 x 4 位值 `c` 和 `d`.

你想把这两个值打包成一个 8 位值。

![soldity 字节合并打包](https://img.learnblockchain.cn/2023/08/24/40909.png)

<p align="center">c 占用前 4 位，d 占用剩余的 4 位（也可以相反）</p>

注意： 下面的函数可以在 Remix 中使用，但有限制。

它基于上面的示例，只能将两个都是 2 字节的值连接成一个 4 字节的最终值。

为了实现更强的模块化，你可能需要其他方法，比如缩减一个`bytes`数组，并只指定字节数（**有难度**）。

```solidity
/// @dev 798 gas cost :)
function concatBytes(
    bytes2 _c, 
    bytes2 _d
) public pure returns (bytes4) {
    return (_c << 4) | _d;
}
```

## 9. 关于 Solidity 字节的警告

如果将 bytes 用作函数参数并成功编译合约，可能会出现一些令人迷惑的情况。对于任何从外部调用的函数，请务必使用固定长度类型。

## 参考引用

1. [小端与大端](https://thebittheories.com/little-endian-vs-big-endian-b4046c63e1f2)

2. [尾数](https://en.wikipedia.org/wiki/Endianness)

3. [位操作](https://medium.com/@imolfar/bitwise-operations-and-bit-manipulation-in-solidity-以太坊-1751f3d2e216)


本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
