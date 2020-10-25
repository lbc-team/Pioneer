
# Dynamic Value Arrays in Solidity
# Solidity中的动态值数组

 
Are dynamic value arrays more efficient than reference arrays in Solidity?
在Solidity中，动态值数组会比引用数组更有效吗？

![](https://img.learnblockchain.cn/2020/09/16/16002175729055.jpg)
<center>*Photo by *[*Nick Kwan*](https://unsplash.com/@snick_kwan?utm_source=medium&utm_medium=referral)* on *[*Unsplash*](https://unsplash.com/?utm_source=medium&utm_medium=referral)</center>

### Background
### 背景

During the development and testing of Datona Labs’ Solidity Smart-Data-Access-Contract (S-DAC) templates, we often need to handle data such as a small but unknown number of items such as user IDs. Ideally, these are stored in a small dynamic arrays of small values.

在开发和Datona Labs的测试密实度的智能数据获取合同(S-DAC)的模板，我们往往需要用处理小但数量的物品，如用户ID来处理数据。 理想情况下，将它们存储在较小值的小型动态数组中。

In the examples for this article, we investigate whether using Dynamic Value Arrays help us to do that more efficiently than Reference Arrays or similar solutions in Solidity.

### Discussion

Where we have a data comprising a known small number of small numbers, we can employ a Value Array in Solidity, as per [this](https://medium.com/@plaxion/value-arrays-in-solidity-32ca65135d5b) article by the author, in which we provide and measure Solidity Value Arrays. We concluded, amongst other things, that we can reduce my storage space and gas consumption using Value Arrays in many circumstances.

This conclusion was reached because Solidity runs on the Ethereum Virtual Machine (EVM) which has a very large [machine word](https://en.wikipedia.org/wiki/Word_%28computer_architecture%29) of 256bits (32bytes). This feature, combined with high gas consumption for reference array handling, encourages us to consider using Value Arrays.

However, if we are providing our own libraries for Fixed Value Array manipulation, let us determine whether it is feasible to provide Dynamic Value Arrays as well.

Let us compare Dynamic Value Arrays with Fixed Value Arrays and Solidity’s own fixed and dynamic arrays.

We shall also compare a struct containing a length and a fixed array, as well as a struct containing a Value Array.

### Possible Dynamic Value Arrays
### 可能的动态值数组

In Solidity, it is only possible to have dynamic *storage* arrays. *Memory* arrays have fixed size, and are not permitted to use *push()* in order to append additional elements.

在Solidity中，只能具有动态*存储*数组。 *内存*数组的大小是固定的，并且不允许使用push()来附加其他元素。

Since we are providing our own code for Dynamic Value Arrays in Solidity libraries, we can also provide *push() *(and *pop()*) to be used on both *storage* and *memory* arrays.

由于我们在Solidity库中用自己的代码来实现动态值数组，因此我们在*存储*和*内存*中可以提供push() 函数(和pop()函数)。

Dynamic Value Arrays will need to record and manipulate the current length of the array. In the following code, we have chosen to store the length in the top bits of the 256bit, 32byte machine word value.

动态值数组将需要记录和操纵数组的当前长度。 在下面的代码中，我们选择将长度存储在256位，32字节机器字值的高位中。

### Dynamic Value Arrays
### 动态值数组

These are Dynamic Value Arrays that match some of the Solidity available types:

这些是与Solidity某些可用类型匹配的动态值数组：

```
Dynamic Value Arrays
动态值数组

Type           Type Name   Description
类型            类型名称     描述

uint128[](1)   uint128d1   one 128bit element value
uint64[](3)    uint64d3    three 64bit element values
uint32[](7)    uint32d7    seven 32bit element values
uint16[](15)   uint16d15   fifteen 16bit element values
uint8[](31)    uint8d31    thirty-one 8bit element values
```

We propose the Type Name as shown above, which is used throughout this article, but you may find a preferable naming convention.

我们建议使用上面显示的类型名称，本文将使用它，也许您可能会发现更好的命名约定。

We will be looking at **uint8d31** in more detail, below.

我们将在下面更详细地聊下**uint8d31**。

### More Dynamic Value Arrays
### 更多动态值数组

Obviously, there more possible Value Arrays. Assuming that we are reserving the top bits of the 256bit value to hold the maximum dynamic array length, the number of bits in the X value multiplied by the number of Y elements must be less than or equal to 256 minus enough bits to hold the array length, L:

显然，还有更多可能的值数组。 假设我们保留256bit值的高位来记录最大动态数组长度，则X值代表的位数应乘以Y元素的数量必须小于或等于256减去足够的位数以容纳数组长度，L：

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

The array type needed is project specific. Additionally, multiple array types may be needed. For instance, **uint8d31** for user IDs and uint5d50 for roles.

所需的数组类型是根据项目而定的的。 此外，可能需要多种数组类型，例如，用于用户ID的uint8d31和用于角色的uint5d50。

Note the uint1d248 Value Array. That allows us to efficiently encode up to two-hundred and forty-eight 1bit element values, which represent booleans, into 1 EVM word. Compare that with Solidity’s bool[248] which consumes 248 times as much space in memory, and even 8 times as much space in storage.

注意uint1d248值数组。 这样一来，我们就可以将最多248个表示布尔值的1位元素值有效地编码为一个EVM字。 相比之下，Solidity的bool [248]消耗的内存空间是其248倍，甚至是存储空间的8倍。

### Dynamic Value Array Implementation
### 动态值数组实现

Here is a useful import file providing get and set functions for the Dynamic Value Array type uint8d31:

这是一个有用的导入文件，为动态值数组类型uint8d31提供get和set函数：

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

The *length() *function returns the current size of the Dynamic Value Array. You can alter the number of elements in the array using *setLength()* or *push().*

length() 函数返回动态值数组的当前大小。 可以使用setLength()或push()更改数组中元素的数量。

The *get()* and *set() *functions get and set a specific element, as per Fixed Value Arrays, except that only elements that are within the current size of the array may be accessed.

根据固定值数组， get()和set()函数获取并设置一个特定元素，只是只能访问该数组当前大小内的元素。

The *push()* function appends values up to the maximum size of the Dynamic Value Array. Simply define *pop() *as well, to provide an efficient small value stack.

push()函数将在数组最大大小范围内，添加元素到动态值数。 简单定义pop()函数来提供便利。

Let’s see a few simple, sunny day tests for the uint8d31 example library code:

让我们来看一下uint8d31示例库代码的一些简单的晴天测试：

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

### Struct Dynamic Arrays
### 结构动态数组

The advantage of using structs is that they are passed by reference to internal (not external) library functions, negating the requirement to assign the function return value from *setLength(), set()* and *push()*.

使用结构的优点是通过引用将它们传递给内部(而非外部)库函数，从而无需要求从setLength() ， set()和push()函数返回值。

Here is a struct containing 31 bytes of data in a fixed array and a length, and the associated library functions:

这是一个结构，其中包含31个字节的固定数组数据和一个长度，以及相关的库函数：


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

This code is similar to uint8d31, simply substituting *s.length *and* s.data[index] *where required, and not returning a value from* setLength(), set()* or *push()*.

此代码类似于uint8d31，仅在需要时替换s.length和s.data[index] ，而不从setLength() ， set()或push()返回值。


The Suint8u31 struct defined above appears to consume 256bits of address space. But in Solidity, each array comprises an additional 256bit value for the length of the array, even if it’s a fixed array, so we are expecting that the gas consumption of this solution is going to be higher than anticipated.

上面定义的Suint8u31结构占用了256位的地址空间。 但是在Solidity中，即使是固定数组，每个数组都为的长度增加了一个256位值，因此我们预计该解决方案的Gas消耗将比预期的高。

### Struct Dynamic Value Arrays
### 结构动态值数组

Here is a struct containing a Dynamic Value Array, and the associated library functions:
这是一个包含动态值数组和相关库函数的结构：

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

This code is very similar to uint8d31, simply substituting *s.va* for each occurrence of *va*, and not returning a value from *setLength(), set()* or *push()*.

此代码与uint8d31非常相似，每次只需将s.va替换为va，而不是使用setLength( )， set()或push() 返回值 。

Let’s measure the gas consumption, right after this enigmatic comfort break.
在这之后，我们来测量一下Gas消耗量。

![](https://img.learnblockchain.cn/2020/09/16/16002178523957.jpg)
<center>*Photo by the author*</center>

### Gas Consumption
### Gas消耗量

Having written the libraries and contracts, we measured the gas consumption using a technique described in [this](http:///coinmonks/gas-cost-of-solidity-library-functions-dbe0cedd4678) article by the author.

编写了库和合同后，我们使用作者在[Gas消耗](http:///coinmonks/gas-cost-of-solidity-library-functions-dbe0cedd4678) 描述的技术测量了Gas消耗。

Here are the legends for the charts given below:
以下是以下图表的图例：

```
Legend         Meaning

uint8[](32)    Solidity dynamic array of 32 uint8
uint8[32]      Solidity fixed array of 32 uint8
uint8a32       Fixed Value Array of 32 uint8 (other article)
uint8d31       Dynamic Value Array of <= 31 uint8 (this article)
suint8d31      Struct containing Dynamic Value Array of <= 31 uint8
suint8u31      Struct containing Solidity fixed array of <= 31 uint8
```

### uint8 arrays in EVM memory space
### EVM内存空间中的uint8数组

Here, we compare using dynamic uint8 arrays in EVM memory space:
在这里，我们比较了在EVM内存空间中使用动态uint8数组的情况：

![](https://img.learnblockchain.cn/2020/09/16/16002179136735.jpg)
<center>*Gas consumption of get and set on uint8 memory variables*</center>
<center>*在uint8内存变量上获取和设置的Gas消耗量*</center>

This chart shows that gas consumption for a handful of common operations on a Dynamic Value Array (uint8d31) only consumes a little more gas than a Fixed Value Array (uint8a32).

该图表显示，动态值数组(uint8d31)上的一些常用操作的Gas消耗量仅比固定值数组(uint8a32)多一些。

All other options consume significantly more gas, especially the struct containing a Solidity fixed array (last column).

所有其他选项消耗Gas明显更多，尤其是包含Solidity固定数组(最后一列)的结构。

This is how the gas consumption of individual operations compare:

这是各个操作的Gas消耗量对比情况：

![](https://img.learnblockchain.cn/2020/09/16/16002179498329.jpg)
<center>*Gas consumption of push, get and set on uint8 memory variables*</center>
<center>*在内存uint8变量上的push, get和set函数Gas消耗量*</center>

Note that *push()* is not permitted on Solidity memory arrays, even dynamic ones (the gold column for each type), but we did implement it for the dynamic data structures measured in this article.

请注意，Solidity内存数组，甚至动态数组(每种类型的黄金列push()都不允许push() ，但是我们确实在本文中测量的动态数据结构。

The take away from this is that, yet again, the Dynamic Value Array (uint8d31) only consumes a little more gas than a Fixed Value Array (uint8a32), and all other options consume (sometimes a lot) more gas.

从这里我们可以得出，与固定值数组(uint8a32)相比，动态值数组(uint8d31)仅多消耗一点Gas，而所有其他选项消耗(有时很多)的Gas。

### uint8 arrays in EVM storage space
### EVM存储空间中的uint8数组

Here, we compare using dynamic uint8 arrays in EVM storage space:

在这里，我们比较了在EVM存储空间中使用动态uint8数组的情况：

![](https://img.learnblockchain.cn/2020/09/16/16002179799918.jpg)
<center>*Gas consumption of push/set and get uint8 storage variables*</center>
<center>*push/set和get uint8存储变量的Gas量*</center>

Here, apart from the high gas consumption of the first and last columns, the picture is clear, and the selection less definitive.

在此，除了第一列和最后一列的高耗气量之外，其他的选择没有很大区别。

This is how the gas consumption of individual operations compare:
这是各个操作的Gas消耗量的比较：

![](https://img.learnblockchain.cn/2020/09/16/16002180267480.jpg)
<center>*Gas consumption of push, get and set on uint8 storage variables*</center>
<center>*push/set和get uint8存储变量的Gas量*</center>

The column to focus on is probably the rust column (right-most for each type), which tends to show typical usage after the storage space has been allocated, whereas the first *push() *or *set()* causes storage space to be allocated which consumes a lot of gas on the EVM.

要关注的列可能是rust列(每种类型的最右边)，在分配了存储空间后，它通常会显示典型用法，而第一个push()或set()会导致分配存储空间，在EVM上消耗大量气体。

Above, the Dynamic Value Array (uint8d31) consumes a little more gas than a Fixed Value Array (uint8a32), and all other options consume a little more gas.

上面，动态值数组(uint8d31)比固定值数组(uint8a32)消耗更多的气体，而其他其他选项消耗的Gas多了一点点。

### Parameters to sub-contracts and libraries

![](https://img.learnblockchain.cn/2020/09/16/16002180511266.jpg)
<center>*Gas consumption of passing a uint8 parameter to a sub-contract or library*</center>

Not surprisingly, the biggest gas consumption is providing an array parameter to a sub-contract or library function, and then getting the value back again.

毫无疑问，最大的Gas消耗是递交参数给子合约或者库函数并且获取返回值

Using a value instead clearly consumes far less gas.

用值代替显然可以消耗少得多的Gas。

### Other Possibilities
### 其他可能性

If you find Dynamic Value Arrays useful, you may also like to consider Fixed Value Arrays, Fixed Multi Value-Arrays, Value Queues, Value Stacks etcetera. And how would your algorithms (such as *Sort*) perform if they used Value Arrays instead of reference arrays?

如果发现动态值数组很有用，则可能还需要考虑固定值数组，固定多值数组，值队列，值堆栈等。 如果您的算法(例如Sort )使用值数组而不是引用数组，它们的性能如何？

### Conclusions
### 结论

We have provided and measured code for generic library code for uintX[](Y) small Dynamic Value Arrays.

我们已经提供并测试了uintX [](Y)小型动态值数组的通用库代码。

We *can* reduce our storage space and gas consumption using Dynamic Value Arrays compared with Solidity’s dynamic arrays.

与Solidity的动态数组相比，我们可以使用动态值数组来减少存储空间和Gas消耗。

Where your Solidity smart contracts use small dynamic arrays of small values (for user IDs, roles etcetera), then the use of Dynamic Value Arrays is likely to consume less gas.

如果您的Solidity智能合约使用较小值的小型动态数组(用于用户ID，角色等)，则使用动态值数组可能会消耗较少的Gas。

Where arrays are copied e.g. for sub-contracts or libraries, Dynamic Value Arrays will always consume vastly less gas.

在复制数组的地方(例如，对于子合约或库)，动态值数组将始终消耗少得多的Gas。

In other circumstances, continue to use dynamic reference arrays.

在其他情况下，请继续使用动态引用数组。

### Bio

Jules Goddard is Co-founder of Datona Labs, who provide smart contracts to protect your digital information from abuse.

Jules Goddard是Datona Labs的联合创始人，该公司提供智能合同来保护你的数字信息不被滥用。


原文链接：https://www.linkedin.com/pulse/dynamic-value-arrays-solidity-julian-goddard/
作者：[Julian Goddard](https://uk.linkedin.com/in/julian-goddard-66312049?trk=author_mini-profile_title)