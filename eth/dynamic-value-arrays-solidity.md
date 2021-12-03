
> * 原文：[dynamic-value-arrays-solidity...](https://www.linkedin.com/pulse/dynamic-value-arrays-solidity-julian-goddard/)  作者：[Julian Goddard](https://uk.linkedin.com/in/julian-goddard-66312049?trk=author_mini-profile_title)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[aisiji](https://learnblockchain.cn/people/3291)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# Solidity 中的动态值数组

在 Solidity 中，动态值数组是否比引用数组效率更高？

![](https://img.learnblockchain.cn/2020/09/16/16002175729055.jpg)
<center>*Photo by *[*Nick Kwan*](https://unsplash.com/@snick_kwan?utm_source=medium&utm_medium=referral)* on *[*Unsplash*](https://unsplash.com/?utm_source=medium&utm_medium=referral)</center>

### 背景

在 Datona 实验室的 Solidity 智能数据访问合约（S-DAC）模板的开发和测试过程中，我们经常需要处理一些像用户ID这样小但未知的数据。理想情况下，这些数据存储在一个小数值的动态值数组中。

在这篇文章的例子中，我们研究了在 Solidity 中使用动态值数组是否比引用数组或类似解决方案在处理这些小数值时更高效。

### 论述

当我们有一个由已知的少量小数值组成的数据时，我们可以在 Solidity 中使用一个数值数组(Value Arrays)，在[这篇文章](https://medium.com/@plaxion/value-arrays-in-solidity-32ca65135d5b)中，我们提供并测量了 Solidity 数值数组。得出的结论是，在多数情况下使用数值数组都可以减少存储空间和gas消耗。

得出这个结论是因为Solidity在以太坊虚拟机(EVM)上运行时有256位（32字节）—— 非常大的[机器语言](https://en.wikipedia.org/wiki/Word_%28computer_architecture%29)。基于这个特点，再加上处理引用数组时的高gas消耗，让我们开始考虑使用数值数组。

我们可以为操作固定值数组提供自己的库，同样是否也可以为动态值数组提供呢。

让我们比较一下动态值数组与固定值数组以及 Solidity 自己的固定和动态数组。

我们也将比较两个结构体，一个结构体包含一个数组长度和一个固定数组，另一个结构体包含一个数值数组。

### 可能的动态值数组

在 Solidity 中，只有 *storage* 类型可能有动态数组。*memory* 类型的数组有固定大小，并且不允许使用`push()`来附加元素。

既然我们在 Solidity 库中为动态值数组提供了自己的代码，我们也能提供`push()`(和`pop()`)同时用于 *storage* 和 *memory* 数组。

动态值数组需要记录并操作数组的当前长度。在下面的代码中，我们将数组长度在存储在256位(32字节)机器语言值的最高位。

### 动态值数组

下面是一些与 Solidity 可用类型匹配的动态值数组:

```
Dynamic Value Arrays

Type           Type Name   Description

uint128[](1)   uint128d1   one 128bit element value
uint64[](3)    uint64d3    three 64bit element values
uint32[](7)    uint32d7    seven 32bit element values
uint16[](15)   uint16d15   fifteen 16bit element values
uint8[](31)    uint8d31    thirty-one 8bit element values
```

我们提出了如上所示的类型名称，它们在会本文中使用，但你可能会有一个更好的命名方式。

下面我们将详细地研究`uint8d31`。

### 更多动态值数组

很明显，有更多可能的数值数组。假设我们保留最高位的256位值来容纳最大的动态数组长度，X值的位数的值乘以Y元素的位数必须小于或者等于256减去足够位来容纳数组长度：

```
More Dynamic Value Arrays

Type           Type Name  Len  Description

uintX[](Y)     uintXdY     L   X * Y <= 256 - L
uint255[](1)   uint255d1   1   one 248bit element value
uint126[](2)   uint126a2   2   two 124bit element values
uint84[](3)    uint84d3    2   three 82bit element values
uint63[](4)    uint63d4    3   four 62bit element values
uint50[](5)    uint50d5    3   five 51bit element values
uint42[](6)    uint42d6    3   six 42bit element values
uint36[](7)    uint36d7    3   seven 36bit element values
uint31[](8)    uint31d8    4   eight 31bit element values
uint28[](9)    uint28d9    4   nine 28bit element values
uint25[](10)   uint25d10   4   ten 25bit element values
uint22[](11)   uint22d11   4   eleven 22bit element values
uint21[](12)   uint21d12   4   twelve 21bit element values
uint19[](13)   uint19d13   4   thirteen 19bit element values
uint18[](14)   uint18d14   4   fourteen 18bit element values
uint16[](15)   uint16d15   4   as above
uint15[](16)   uint15d16   5   sixteen 15bit element values
uint14[](17)   uint14d17   5   seventeen 14bit element values
uint13[](19)   uint13d19   5   nineteen 13bit element values
uint12[](20)   uint12d20   5   twenty 12bit element values
uint11[](22)   uint11d22   5   twenty-two 11bit element values
uint10[](25)   uint10d25   5   twenty-five 10bit element values
uint9[](27)    uint9d27    5   twenty-seven 9bit element values
uint8[](31)    uint8d31    5   as above
uint7[](35)    uint7d35    6   thirty-five 7bit element values
uint6[](41)    uint6d41    6   forty-one 6bit element values
uint5[](50)    uint5d50    6   fifty 5bit element values
uint4[](62)    uint4d62    6   sixty-two 4bit element values
uint3[](83)    uint3d83    7   eighty-three 3bit element values
uint2[](124)   uint2d124   7   one-hundred & twenty-four 2bit EVs
uint1[](248)   uint1d248   8   two-hundred & forty-eight 1bit EVs

```

不同的项目需要特定的数组类型，并且同一个项目可能需要多种数组类型。例如，`uint8d31`用于用户ID，`uint5d50`用于用户角色。

注意`uint1d248`数值数组。它让我们可以有效地将多达2048个1位的元素值（代表布尔）编码到1个 EVM 字中。与 Solidity 的 bool[248] 相比，它在内存中消耗的空间是 248 倍，在存储中是8倍。

### 动态值数组实现

下面是一个有用的导入文件，为动态值数组类型`uint8d31`提供了`get`和`set`函数:


```
// uint8d31.sol
library uint8d31 { // provides the equivalent of uint8[](31)
    uint constant bits = 8;
    uint constant elements = 31;
    uint constant lenBits = 5;
    // ensure that (bits * elements) <= (256 - lenBits)
    
    uint constant range = 1 << bits;
    uint constant max = range - 1;
    uint constant lenPos = 256 - lenBits;
    
    function length(uint va) internal pure returns (uint) {
        return va >> lenPos;
    }

    function setLength(uint va, uint len) internal pure returns
    (uint) {
        require(len <= elements);
        return (va & (uint(~0x0) >> lenBits)) | (len << lenPos);
    }

    function get(uint va, uint index) internal pure returns (uint) {
        require(index < (va >> lenPos));
        return (va >> (bits * index)) & max;
    }

    function set(uint va, uint index, uint value) internal pure 
    returns (uint) {
        require((index < (va >> lenPos)) && (value < range));
        index *= bits;
        return (va & ~(max << index)) | (value << index);
    }

    function push(uint va, uint value) internal pure returns (uint){
        uint len = va >> lenPos;
        require((len < elements) && (value < range));
        uint posBits = len * bits;
        va = (va & ~(max << posBits)) | (value << posBits);
        return (va & (uint(~0) >> lenBits)) | ((len + 1) << lenPos);
    }
}
```
`length()`函数返回动态值数组的当前大小。你可以使用`setLength()`或`push()`改变数组中的元素数量。

`get()`和`set()`函数会获取和设置一个特定的元素，就像固定值数组一样，不过只有在数组当前大小范围内的元素可以被访问。

`push()`函数会把值追加到动态值数组最大长度的位置。同样简单地定义了`pop()`，为了提供一个有效的小数值堆栈。

让我们看看`uint8d31`示例库代码的几个简单的晴天测试：


```
import "uint8d31.sol";

contract TestUint8d31 {
    using uint8d31 for uint;
    
    function test1() public pure {
        uint va;
        require(va.length() == 0, "length not 0");
        va = va.setLength(10);
        require(va.length() == 10, "length not 10");
    }
  
    function test2() public {
        uint va;
        va = va.push(0x12);
        require(va.get(0) == 0x12, "va[0] not 0x12");
        require(va.length() == 1, "length not 1");
        
        va = va.push(0x34);
        require(va.get(1) == 0x34, "va[1] not 0x34");
        require(va.length() == 2, "length not 2");
        
        va = va.setLength(31);
        require(va.length() == 31, "length not 31");
        va = va.set(30, 0x78);
        require(va.get(30) == 0x78, "va[30] not 0x78");
        require(va.length() == 31, "length not 31");
    }
}

```


### 结构体动态数组

使用结构体的好处是，它们通过引用传递给内部（而不是外部）库函数，忽视了指派函数从`setLength()`、`set()`和`push()`返回值的需求。

下面是一个结构体，包含在一个固定数组中的31字节的数据和数组长度，以及相关的库函数：

```
struct Suint8u31 { // struct representing uint8[](31)
    uint8[31] data;
    uint8 length;
}

// ------------

library Suint8u31lib {
    // constant declarations as per uint8d31
    
    function length(Suint8d31 memory s) internal pure returns (uint)
    {
        return s.length;
    }

    function setLength(Suint8d31 memory s, uint len) ...
    // other function definitions similar to uint8d31
}

```

这段代码与`uint8d31`相似，只是在需要的地方替换了`s.length`和`s.data[index]`，并且不会从`setLength()`、`set()`或`push()`返回值。

上面定义的`Suint8u31`结构体似乎消耗了256位的地址空间。但是在Solidity中，每个数组都包含一个额外的256位的当前数组长度值，即使固定数组也是这样，所以这个解决方案的 gas 消耗会比预期的要高。

### 结构体动态值数组

下面是一个包含动态值数组的结构体和相关的库函数：

```
struct Suint8d31 { // struct representing uint8[](31)
    uint va; // uint8d31 value array
}

// ------------

library Suint8d31lib {
    // as per uint8d31
    
    function length(Suint8d31 memory s) internal pure returns (uint)
    {
        return s.va >> lenPos;
    }

    function setLength(Suint8u31 memory s, uint len) ...
    // other function definitions similar to uint8d31
}
```

这段代码与`uint8d31`非常相似，只是在每次出现`va`时替换为`s.va`，并且不会从`setLength()`、`set()`或`push()`返回值。

在这样谜之舒适之后，我们来测量一下gas消耗。

![](https://img.learnblockchain.cn/2020/09/16/16002178523957.jpg)
<center>*Photo by the author*</center>

### gas消耗

在写完库和合约后，我们用[这篇文章](http:///coinmonks/gas-cost-of-solidity-library-functions-dbe0cedd4678)中讨论的技术来测量一下 gas 消耗。

下表是我们接下来要测量和对比的 uint8 数组：

```
Legend         Meaning

uint8[](32)    Solidity dynamic array of 32 uint8
uint8[32]      Solidity fixed array of 32 uint8
uint8a32       Fixed Value Array of 32 uint8 (other article)
uint8d31       Dynamic Value Array of <= 31 uint8 (this article)
suint8d31      Struct containing Dynamic Value Array of <= 31 uint8
suint8u31      Struct containing Solidity fixed array of <= 31 uint8
```

### EVM 内存空间里的 uint8 数组

在这里，我们比较了在 EVM 内存空间中使用动态`uint8`数组的 gas 消耗:

![](https://img.learnblockchain.cn/2020/09/16/16002179136735.jpg)
<center>*对 uint8 内存变量的 get 和 set 操作的 gas 消耗*</center>

这个图表显示，只做少量常规操作的gas消耗，动态值数组(`uint8d31`) 只比固定值数组(`uint8a32`)多一点点，差别不明显。

其他选项的 gas 消耗明显更多，特别是包含 Solidity 固定数组的结构体（最后一栏）。

下面是每种操作分开测量的 gas 消耗：

![](https://img.learnblockchain.cn/2020/09/16/16002179498329.jpg)
<center>*对 uint8 内存变量分别做 push，get 和 set 操作的 gas 消耗*</center>

请注意，在 Solidity 内存数组上`push()`是不允许的，即使动态数组也不可以，但在本文中为了测量动态数据结构的 gas 消耗，我们实现了它。

我们可以看到，跟上次一样，动态值数组（`uint8d31`）的 gas 消耗只比固定值数组（`uint8a32`）多一点，而其他项的消耗都更大（有时是很多）。

### EVM 存储空间里的 uint8 数组

下面，我们比较了在 EVM 存储空间中使用动态`uint8`数组的 gas 消耗:

![](https://img.learnblockchain.cn/2020/09/16/16002179799918.jpg)
<center>*对 uint8 存储变量做 push/set 和 get 操作的 gas 消耗*</center>

上图中除了第一列和最后一列的可以看到明显的高 gas 消耗外，其他列都没有明显差别。

下面是比较每种单独操作的 gas 消耗：

![](https://img.learnblockchain.cn/2020/09/16/16002180267480.jpg)
<center>*对 uint8 存储变量分别做 push，get和 set 操作的 gas 消耗*</center>

需要特别注意的是每个 uint8 数组的锈红色的柱状图(每个栏目的最右侧一栏)，它显示了存储空间被分配后的典型用法，而黄色或蓝色(每个栏目最左边的一栏)则显示了`push()`或`set()`分配存储空间的操作，这在 EVM 上消耗了大量 gas。

以上，动态值数组（`uint8d31`）比固定值数组（`uint8a32`）消耗的 gas 多一点，其他项消耗的 gas 都多一点。

### 向子合约和库传参数

![](https://img.learnblockchain.cn/2020/09/16/16002180511266.jpg)
<center>*向子合约或库传递一个uint8参数的gas消耗*</center>

很明显，最大的 gas 消耗是向子合约或库函数提供一个数组参数，并把值拿回来。

用一个值来代替，显然消耗的 gas 要少得多。

### 其他可行性

如果你觉得动态值数组很有用，你也可以考虑固定值数组、固定多值数组、值队列、值栈等等。如果你的算法（如*Sort*）使用值数组而不是引用数组，会有怎样的表现？

### 结论

我们已提供并测量了`uintX[](Y)`小动态值数组的通用库代码。

与 Solidity 的动态数组相比，我们可以通过使用动态值数组来减少存储空间和 gas 消耗。

如果你的 Solidity 智能合约用小数值的动态数组（用于用户ID、角色等），那么用动态值数组可能会消耗较少的 gas。

当数组被复制时，例如用于子合约或库，动态值数组将消耗大量的 gas。

其他情况下，继续使用动态引用数组。

### 个人简介
Jules Goddard 是 Datona 实验室的共建者，他提供了保护你的数字信息不被滥用的智能合约。

