> * 原文链接：  https://coinsbench.com/beginners-guide-to-yul-12a0a18095ef
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



#  Yul 入门指南

## 什么是Yul？

Yul 是一种中间编程语言，可以用来在智能合约中编写汇编语言。虽然我们经常看到Yul在智能合约中使用，但其实你可以完全用Yul来编写智能合约。了解Yul可以提升你的智能合约的水平，让你了解`solidity`中底层发生的事情，这反过来可以帮助节省用户的Gas费。我们可以通过以下语法在智能合约中标识 Yul。

```
assembly {
    // do stuff
  }
```

在本文中，我们将通过实例讨论使用Yul的基本知识，我鼓励你在remix中跟着实践。

## 变量赋值、运算和评估

我们需要讨论的第一个话题是简单的操作。Yul有`+`，`-`，`*`，`/`，`%`，`**`，`<`，`>`，和`=`。注意，`>=`和`<=`不包括在内，Yul没有这些操作。此外，评估不是等于真或假，而是分别等于1或0。说到这里，让我们开始学习一些Yul!

![img](https://img.learnblockchain.cn/2023/06/27/85721.png)

在继续之前，让我们快速看一下一个例子。

```solidity
function addOneAnTwo() external pure returns(uint256) {
    // We can access variables from solidity inside our Yul code
    uint256 ans;

    assembly {
        // Yul 中为变量赋值
        let one := 1
        let two := 2
        // 加法
        ans := add(one, two)
    }
    return ans;
}
```

## For 循环和 If 语句

为了学习这两个知识，让我们写一个函数，计算一个系列中多少个数字是偶数。

```solidity
function howManyEvens(uint256 startNum, uint256 endNum) external pure returns(uint256) {
 
    // the value we will return
    uint256 ans;
 
    assembly {
 
        // syntax for for loop
        for { let i := startNum } lt( i, add(endNum, 1)  ) { i := add(i,1) }
        {
            // if i == 0 skip this iteration
            if iszero(i) {
                continue
            }
 
            // checks if i % 2 == 0
            // we could of used iszero, but I wanted to show you eq()
            if  eq( mod( i, 2 ), 0 ) {
                ans := add(ans, 1)
            }
 
        }
 
    }
 
 
    return ans;
 
}
```

`if`语句的语法与solidity非常相似，但是，我们不需要用圆括号来包裹条件。对于`for`循环，注意我们在声明`i`和增加`i`时使用了括号，但在评估条件时没有使用括号。此外，我们使用了`continue`来跳过循环的一次迭代。我们也可以在Yul中使用`break`语句。

## 存储

在我们深入了解Yul的工作原理之前，我们需要很好的理解智能合约中的存储工作原理。存储是由一系列的槽组成的。一个智能合约有2²⁵⁶个槽位。在声明变量时，我们从槽0开始，然后从那里递增。每个槽的长度为256 比特（32字节），这就是`uint256`和`bytes32`的名字由来。所有的变量都被转换为十六进制。如果一个变量，例如`uint128`使用时，不会用整个槽来存储该变量。相反，它的左边是用0填充的。让我们看一个例子，以获得更好的理解。

```
// slot 0
uint256 var1 = 256;

// slot 1
address var2 = 0x9ACc1d6Aa9b846083E8a497A661853aaE07F0F00;

// slot 2
bytes32 var3 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

// slot 3
uint128 var4 = 1;
uint128 var5 = 2;
```

`var1`：由于`uint256`变量等于32字节，`var1`占据了整个0槽。下面是0号槽中存储的内容：  `0x00000000000000000000000000000000000000000000000000000000000000000000000000000100`。

`var2`：地址稍微复杂一些。由于它们只占用20个字节的存储空间，地址的左边被填充了0。下面是存储在槽1中的内容： `0x00000000000000009acc1d6aa9b846083e8a497a661853aae07f0f00`。

`var3`：这个看起来很简单，槽位2被`bytes32`变量的全部内容所消耗。 

`var4` & `var5`：还记得我提到的`uint128`被填充了0吗？那么，如果我们对变量进行排序，使它们的存储量之和小于32字节，我们就可以把它们一起放入一个槽中！这叫做变量打包！这就是所谓的变量打包，它可以为你节省Gas。让我们来看看3号槽中存储的内容： `0x0000000000000000000000000000000200000000000000000000000000000001`。 请注意，`0x000000000000000000000000000002` 和 `0x000000000000000000000000000001` 完全吻合同一个槽。这是因为它们都占用了16个字节（一半的槽）。 

现在是时候学习更多的 Yul 内容了!

![img](https://img.learnblockchain.cn/2023/06/27/38321.png)

让我们来看看另一个例子!

```solidity
function readAndWriteToStorage() external returns (uint256, uint256, uint256) {

      uint256 x;
      uint256 y;
      uint256 z;
      
      assembly  {
      
          // 获得 var5 的槽位置
          let slot := var5.slot
          
          // 获得 var5 的槽位偏移
          let offset := var5.offset
          
          // 赋值给 solidity 中的变量
          x := slot
          y := offset
          
          // 在槽0上保存 1 
          sstore(0,1)
          
          // 加载 槽0 的值赋值给 z 
          z := sload(0)
      }
      return (x, y, z);
}
```

`x` = 3. 这是有道理的，因为我们知道 var5 被装入槽3。
`y` = 16. 这也是合理的，因为我们知道`var4`占据了3号槽的一半。由于变量是从右到左打包的，我们得到字节16作为`var5`的起始索引。
`z` = 1. `sstore()`是将0号槽的值赋给1。然后，我们用 `sload() `将0号槽的值分配给z。

在我们继续之前，你应该把这个函数添加到你的remix文件中。它将帮助你看到每个存储槽正在存储的内容。

```solidity
// input is the storage slot that we want to read
function getValInHex(uint256 y) external view returns (bytes32) {
  // since Yul works with hex we want to return in bytes
  bytes32 x;
  
  assembly  {
    // assign value of slot y to x
    x := sload(y)
  }
 
  return x;
 
}
```

现在让我们来看看一些更复杂的数据结构吧

```solidity
// slot 4 & 5
uint128[4] var6 = [0,1,2,3];
```

当使用静态数组时，EVM 知道要为我们的数据分配多少个槽位。特别是这个数组，我们在每个槽中打包2个元素。所以如果你调用 `getValInHex(4)`，它将返回 `0x0000000000000000000000000000000100000000000000000000000000000000`。正如我们所期望的，从右到左读，我们看到的是值0和值1。槽5包含`0x0000000000000000000000000000000300000000000000000000000000000002`。

接下来我们要看一下动态数组。

```
// slot 6
uint256[] var7;
```



尝试调用`getValInHex(6)`。你会看到它返回 `0x00`。由于 EVM 不知道需要分配多少个存储槽，我们不能在这里存储数组。相反，当前存储槽（槽6）的keccak256 哈希值被用来作为数组的起始索引。从这里开始，我们需要做的就是添加所需元素的索引来检索值。

下面是一个代码例子，演示了如何查找动态数组的一个元素。

```solidity
function getValFromDynamicArray(uint256 targetIndex) external view returns (uint256) {
 
    // get the slot of the dynamic array
    uint256 slot;
 
    assembly {
        slot := var7.slot
    }
 
    // get hash of slot for start index
    bytes32 startIndex = keccak256(abi.encode(slot));
 
    uint256 ans;
 
    assembly {
        // 添加起始索引和目标索引以获得存储位置。然后加载相应的存储槽
        ans := sload( add(startIndex, targetIndex) )
    }
 
    return ans;
}
```

这里我们检索数组的槽，然后执行`add()`操作和`sload()`来获得我们想要的数组元素的值。

你可能会问，如何防止我们与另一个变量的槽发生碰撞？这是完全可能的，但是，由于2²⁵⁶是一个非常大的数字，所以可能性极小。

映射的行为类似于动态数组，只是我们将槽和键一起散列。

```
// slot 7
mapping(uint256 => uint256) var8;
```

为了演示，我设置了映射的值`var8[1] = 2`。现在让我们看一下如何获得映射的键值的例子：

```solidity
function getMappedValue(uint256 key) external view returns(uint256) {
 
    // get the slot of the mapping
    uint256 slot;
 
    assembly {
        slot := var8.slot
    }
 
    // hashs the key and uint256 value of slot
    bytes32 location = keccak256(abi.encode(key, slot));
 
 
    uint256 ans;
 
    // loads storage slot of location and returns ans
    assembly {
        ans := sload(location)
    }
 
    return ans;
 
}
```

正如你所看到的，这段代码看起来与我们从动态数组中找到一个元素时非常相似。主要的区别是我们把键和槽散列在一起。

我们关于存储部分的最后一部分是学习嵌套映射。在继续阅读之前，我鼓励你根据到目前为止所学到的知识，写出你自己的实现，即如何读取一个嵌套的Map值。

```
// slot 8
mapping(uint256 => mapping(uint256 => uint256)) var9;
```

在这个例子中，我设置了映射值`var9[0][1] = 2`。下面是代码，让我们开始行动吧!

```solidity
function getMappedValue(uint256 key1, uint256 key2) external view returns(uint256) {

    // get the slot of the mapping
    uint256 slot;
    assembly {
        slot := var9.slot
    }
    // hashs the key and uint256 value of slot
    bytes32 locationOfParentValue = keccak256(abi.encode(key1, slot));
    // hashs the parent key with the nested key
    bytes32 locationOfNestedValue = keccak256(abi.encode(key2, locationOfParentValue));

    uint256 ans;
    // loads storage slot of location and returns ans
    assembly {
        ans := sload(locationOfNestedValue)
    }

    return ans;

}
```

我们首先得到第一个键（0）的哈希值。然后我们用第二个键的哈希值（1）来计算。最后，我们从存储空间加载槽，得到我们的值。

恭喜你，你已经了解了Yul的存储部分!

## 读取和写入打包的变量

假设你想把`var5`改成4. 我们知道`var5`位于槽3，所以你可以尝试这样做：

```
function writeVar5(uint256 newVal) external {
 
    assembly {
        sstore(3, newVal)
    }
 
}
```

使用`getValInHex(3)`，我们看到槽3被改写为`0x0000000000000000000000000000000000000000000000000000000000000004`。这是一个问题，因为现在`var4`已经被改写成了0。在这一节中，我们将讨论如何读写打包的变量，但首先我们需要学习更多关于 Yul 语法的知识。

![img](https://img.learnblockchain.cn/2023/06/27/36002.png)

如果你对这些操作不熟悉，不要担心，我们即将用实例来讲解。

让我们从 `and() `开始。我们将取两个`bytes32`并尝试使用`and()` 操作，看看它的返回结果。

```solidity
function getAnd() external pure returns (bytes32) {
    
    bytes32 randVar = 0x0000000000000000000000009acc1d6aa9b846083e8a497a661853aae07f0f00;
    bytes32 mask = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    bytes32 ans;
    assembly {
        ans := and(mask, randVar)
    }
    return ans;
}
```

如果你看一下输出，我们看到`0x000000000000000000009acc1d6aa9b846083e8a497a661853aae07f0f00`。这是因为`and()`所做的是看两个输入的每一个位，并比较它们的值。如果两个位都是1（用二进制的方式考虑），那么我们就保持这个位的状态。否则它将被设置为0。

现在看一下`or()`的代码。

```solidity
function getOr() external pure returns (bytes32) {
 
    bytes32 randVar = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    bytes32 mask = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
 
    bytes32 ans;
 
    assembly {
 
        ans := or(mask, randVar)
 
    }
 
    return ans;
 
}
```

这一次的输出是 `0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff`， 这是因为它看的是否有一个位处于1 状态（（激活态））。让我们看看如果我们把掩码变量改为 `0x00ffffffffffffffffffffff0000000000000000000000000000000000000000 `会怎样。你可以看到输出变为 `0x00ffffffffffffffffffffff9acc1d6aa9b846083e8a497a661853aae07f0f00`。 注意第一个字节是`0x00`，因为两个输入第一个字节都没有 1 。

`xor()`有一点不同。它要求一个位是 1（激活态），另一个位是 0（非激活态），下面是一个代码演示：

```solidity
function getXor() external pure returns (bytes32) {
 
    bytes32 randVar = 0x00000000000000000000000000000000000000000000000000000000000000ff;
    bytes32 mask =    0xffffffffffffffffffffffff00000000000000000000000000000000000000ff;
 
    bytes32 ans;
 
    assembly {
 
        ans := xor(mask, randVar)
 
    }
 
    return ans;
 
}
```

输出是 `0xffffffffffffffffffffffff0000000000000000000000000000000000000000`。当`0x00`和`0xff`对齐时，我们才能看到输出 1 ，区别还是很明显的。

`shl()`和`shr()`的操作非常相似。两者都是将输入值移位。`shl()`向左移位，`shr()`向右移位。让我们来看看一些代码!

```solidity
function shlAndShr() external pure returns(bytes32, bytes32) {
   
    bytes32 randVar = 0xffff00000000000000000000000000000000000000000000000000000000ffff;
 
    bytes32 ans1;
    bytes32 ans2;
 
    assembly {
 
        ans1 := shr(16, randVar)
        ans2 := shl(16, randVar)
 
    }
 
    return (ans1, ans2);
 
}
```

输出：
`ans1`: `0x0000ffff00000000000000000000000000000000000000000000000000000000`
`ans2`: `0x00000000000000000000000000000000000000000000000000000000ffff0000`

让我们先看一下`ans1`。我们按16位（2个字节）执行`shr()`。你可以看到最后两个字节从`0xffff`变为`0x0000`，前两个字节向右移了两个字节。知道了这一点，`ans2`似乎就不需要解释了；所发生的只是 比特位 被移到了左边而不是右边。

在我们写到`var5`之前，让我们写一个函数，先读`var4`和`var5`。

```solidity
function readVar4AndVar5() external view returns (uint128, uint128) {
 
        uint128 readVar4;
        uint128 readVar5;
 
        bytes32 mask = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
 
        assembly {
 
            let slot3 := sload(3)
 
            // the and() operation sets var5 to 0x00
            readVar4 := and(slot3, mask)
 
 
            // we shift var5 to var4's position
            // var5's old position becomes 0x00
            readVar5 := shr( mul( var5.offset, 8 ), slot3 )
 
        }
 
        return (readVar4, readVar5);
 
    }
```



输出结果是1和2，符合预期。对于检索`var4`，我们只需要使用一个掩码，将其值设置为`0x0000000000000000000000000000000000000000000000000000000000000001`。然后我们返回一个设置为1的`uint128`。当读取`var5`时，我们需要将`var4`向右移位。这样我们就有了`0x0000000000000000000000000000000000000000000000000000000000000002`，用来返回。需要注意的是，有时你必须将移位和掩码结合起来，以读取一个有2个以上变量的存储槽的值。

好了，我们终于可以把`var5`的值改成4了!

```solidity
function writeVar5(uint256 newVal) external {
 
    assembly {
 
        // load slot 3
        let slot3 := sload(3)
 
        // mask for clearing var5
        let mask := 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff
 
        // isolate var4
        let clearedVar5 := and(slot3, mask)
 
        // format new value into var5 position
        let shiftedVal := shl( mul( var5.offset, 8 ), newVal )
 
        // combine new value with isolated var4
        let newSlot3 := or(shiftedVal, clearedVar5)
 
        // store new value to slot 3
        sstore(3, newSlot3)
    }
 
}
```

第一步是加载存储槽3。接下来，我们需要创建一个掩码。与我们读取`var4`时类似，我们要将数值隔离为 `0x0000000000000000000000000000000000000000000000000000000000000001`。下一步是格式化我们的新值，使其在`var5`的槽位上，所以它看起来像这样的`0x0000000000000000000000000000000400000000000000000000000000000000`。与我们读取`var5`时不同，这次我们要将我们的值向左移动。最后，我们将使用`or()`将我们的值合并成32字节的十六进制，并将该值存储到槽3。我们可以通过调用`getValInHex(3)`来检查我们的工作。这将返回`0x0000000000000000000000000000000400000000000000000000000000000001`，这就是我们期望看到的。

很好，你现在知道如何读写打包的存储槽了!

## 内存

好了，我们终于准备好学习内存了!

内存的行为与存储不同。内存是不持久的。这意味着一旦函数执行完毕，所有的变量都会被清除。内存与其他语言中的堆相当，但没有垃圾收集器。内存比存储要便宜得多。前22个字的内存成本是线性计算的，但要小心，因为之后的内存成本会变成二次方的。内存是以32个字节的序列排布的。我们以后会对此有更好的理解，但现在要理解`0x00`-`0x20`是一个序列（如果有帮助的话，你可以把它看成一个槽，但它们是不同的）。Solidity分配`0x00` - `0x40`作为`scratch空间`。这个区域的内存不保证是空的，它被用于某些操作。`0x40` - `0x60`存储的是所谓的`free memory pointer（自由空闲指针）`的位置，用于向内存写入新的东西。`0x60` - `0x80`是空的，作为一个间隙（gap）。`0x80`是我们开始工作的地方。内存不合并打包数值。从存储器中获取的值将被存储在它们自己的32字节序列中（即`0x80-0xa0`）。

内存被用于以下操作：

- 外部调用的返回值
- 为外部调用设置函数值
- 从外部调用获取数值
- 用一个错误字符串进行还原
- Log信息 （事件）
- 用`keccak256()`进行哈希运算
- 创建其他智能合约

下面是一些有用的Yul指令，供大家记忆!

![img](https://img.learnblockchain.cn/2023/06/27/86184.png)

让我们来看看更多的数据结构!

结构体和固定长度数组的行为实际上是一样的，但是由于我们已经在存储部分看了固定长度数组，所以我们在这里要看一下结构体。请看下面这个结构。

```solidity
struct Var10 {
    uint256 subVar1;
    uint256 subVar2;
}
```

这没有什么不寻常的地方，只是一个简单的结构。现在我们来看看一些代码

```solidity
function getStructValues() external pure returns(uint256, uint256) {
 
    // initialize struct
    Var10 memory s;
    s.subVar1 = 32;
    s.subVar2 = 64;
 
    assembly {
        return( 0x80, 0xc0 )
    }
 
}
```

这里我们将`s.subVar1`设置为内存位置`0x80` - `0xa0`，`s.subVar2`设置为内存位置`0xa0` - `0xc0`。这就是为什么我们要返回`0x80` - `0xc0`。下面是一个交易结束前的内存布局表。

![img](https://img.learnblockchain.cn/2023/06/27/28025.png)

从这里可以看到一些内容：

- `0x00` - `0x40`是空的scratch空间
- `0x40`给了我们空闲的内存指针
- Solidity为`0x60`留了一个空隙（gas）
- `0x80`和`0xa0`用于存储结构的值
- `0xc0`是新的空闲内存指针。

在内存部分的最后一部分，我想向你展示动态数组是如何在内存中工作的。在这个例子中，我们将把`[0, 1, 2, 3]`作为参数`arr`传递。这个例子，我们将向数组添加一个额外的元素。在生产中这样做要小心，因为你可能会覆盖一个不同的内存变量。下面是代码!

```solidity
function getDynamicArray(uint256[] memory arr) external view returns (uint256[] memory) {
 
    assembly {
 
        // where array is stored in memory (0x80)
        let location := arr
 
        // length of array is stored at arr (4)
        let length := mload(arr)
 
        // gets next available memory location
        let nextMemoryLocation := add( add( location, 0x20 ), mul( length, 0x20 ) )
 
        // stores new value to memory
        mstore(nextMemoryLocation, 4)
 
        // increment length by 1
        length := add( length, 1 )
 
        // store new length value
        mstore(location, length)
 
        // update free memory pointer
        mstore(0x40, 0x140)
 
        return ( add( location, 0x20 ) , mul( length, 0x20 ) )
 
    }
 
}
```

我们在这里所做的是获得数组在内存中的存储位置。然后，我们得到数组的长度，它被存储在数组的第一个内存位置。为了看到下一个可用的位置，我们在该位置上添加32个字节（跳过数组的长度），并将数组的长度乘以32个字节。这将使我们前进到数组后的下一个内存位置。在这里，我们将存储我们的新值（4）。接下来，我们将数组的长度更新为1。之后，我们要更新空闲内存指针。最后，我们返回数组。

让我们再看一次内存布局。

![img](https://img.learnblockchain.cn/2023/06/27/20165.png)

关于内存的部分到此结束!

## 合约调用



在本文的最后一节，我们将看一下合约调用在Yul中是如何工作的。

在我们深入研究一些例子之前，我们需要先学习一些更多的Yul操作。让我们来看看。

![img](https://img.learnblockchain.cn/2023/06/27/33092.png)

好了，现在我们来看看这些例子的一些新合约。首先，让我们看一下我们将调用的合约。

```solidity
pragma solidity^0.8.17;
 
contract CallMe {
 
    uint256 public var1 = 1;
    uint256 public var2 = 2;
 
 
    function a(uint256 _var1, uint256 _var2) external payable returns(uint256, uint256) {
 
        // requires 1 ether was sent to contract
        require(msg.value >= 1 ether);
 
        // updates var1 & var2
        var1 = _var1;
        var2 = _var2;
 
        // returns var1 & var2
        return (var1, var2);
       
    }
 
 
    function b() external view returns(uint256, uint256) {
        return (var1, var2);
    }
 
}
```

这不是很高级的合约，但我们还是要看一下它。这个合约有两个存储变量`var1`和`var2`，分别存储在存储槽1和2中。函数`a()`要求用户至少发送1个以太币给合约，否则它就会还原。接下来，函数`a()`更新`var1`和`var2`并返回它们。函数`b()`简单地读取`var1`和`var2`并返回。

在我们调用`CallMe`合约之前，需要花一分钟时间来理解函数选择器。让我们看看下面这个交易`0x773d45e000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002` 的调用数据。Calldata的前4个字节是所谓的函数选择器（`0x773d45e0`）。这就是EVM如何知道你想调用什么函数。我们通过获取函数签名的字符串哈希值的前4个字节来得出函数选择器。所以函数`a()`的签名是`a(uint256,uint256)`。从这个字符串的哈希值可以得到`0x773d45e097aa76a22159880d254a5f1db8365bc2d0f0987a82bda7dfd3b9c8aa`。看一下前4个字节，我们看到它等于`0x773d45e0`。注意签名中没有空格。这很重要，因为添加空格会给我们一个完全不同的哈希值。你不必担心如何代码实例获得选择器，我将提供它们。

让我们先看一下存储布局。

```solidity
uint256 public var1;
uint256 public var2;
bytes4 selectorA = 0x773d45e0;
bytes4 selectorB = 0x4df7e3d0;
```

注意`var1`和`var2`的布局与合约`CallMe`相同。你可能记得我说过，布局必须与我们的其他合约相同，这样才能使`delegatecall()`正常工作。我们满足了这些需求，并且能够拥有其他的变量（`selectorA`和`selectorB`），只要我们的新变量被附加到最后。这可以防止任何存储碰撞。

现在我们已经准备好进行我们的第一次合约调用。让我们从简单的东西开始，`staticcall()`。这里是我们的函数。

```solidity
function getVars(address _callMe) external view returns(uint256, uint256) {
 
    assembly {
 
        // load slot 2 from memory
        let slot2 := sload(2)
       
        // shift selectorA off
        let funcSelector := shr( 32, slot2)
 
        // store selectorB to memory location 0x80
        mstore(0x00, funcSelector)
 
        // static call CallMe
        let result := staticcall(gas(), _callMe, 0x1c, 0x20, 0x80, 0xc0)
 
        // check if call was succesfull, else revert
        if iszero(result) {
            revert(0,0)
        }
 
        // return values from memory
        return (0x80, 0xc0)
 
    }
 
}
```

我们需要做的第一件事是从存储空间中获取`b()`的函数选择器。我们通过加载槽2来完成这个任务（两个选择器都装在一个槽里）。然后我们右移4个字节（32位）来隔离`selectorB`。接下来我们将把函数选择器存储在内存的scratch空间中。现在我们可以进行静态调用了。在这些例子中，我们传入了`gas()`，但是如果你愿意，你可能想指定Gas的数量。我们传入参数`_callMe`为合约地址。`0x1c`和`0x20`说的是我们要把存储的最后4个字节传到 scratch 空间。因为函数选择器是4个字节，但内存是以32个字节为一个系列工作的（同样，记住我们是从右向左存储的）。`staticcall()`的最后两个参数指定我们要将返回数据存储在内存位置`0x80`-`0xc0`。接下来，我们检查函数调用是否成功，否则返回就不包含数据。记住，成功的调用将返回1。最后，我们从内存中返回数据，并看到数值1和2。

接下来让我们看一下`call()`。我们将从`CallMe`中调用函数`a()`。记住，至少要向合约发送1个以太币!在这个例子中，我将把3和4作为`_var1`和`_var2`传入。以下是代码：

```solidity
function callA(address _callMe, uint256 _var1, uint256 _var2) external payable returns (bytes memory) {
 
    assembly {
 
        // load slot 2
        let slot2 := sload(2)
 
        // isolate selectorA
        let mask := 0x000000000000000000000000000000000000000000000000000000000ffffffff
        let funcSelector := and(mask, slot2)
 
        // store function selectorA
        mstore(0x80, funcSelector)
 
        // copies calldata to memory location 0xa0
        // leaves out function selector and _callMe
        calldatacopy(0xa0, 0x24, sub( calldatasize(), 0x20 ) )
 
        // call contract
        let result := call(gas(), _callMe, callvalue(), 0x9c, 0xe0, 0x100, 0x120 )
 
        // check if call was succesfull, else revert
        if iszero(result) {
            revert(0,0)
        }
 
        // return values from memory
        return (0x100, 0x120)
 
    }
 
 
}
```

好的，与我们上一个例子类似，我们必须加载slot2。但是这一次，我们将屏蔽`selectorB`以隔离`selectorA`。现在我们将把选择器存储在`0x80`。由于我们需要来自calldata的参数，我们将使用`calldatacopy()`。我们告诉`calldatacopy()`在内存位置`0xa0`存储我们的calldata。我们还告诉`calldatacopy()`跳过前36个字节。前4个字节是`callA()`的函数选择器，接下来的32个字节是`callMe`的地址（我们将在一分钟内使用它）。我们告诉`calldatacopy()`的最后一件事是存储calldata的大小减去36字节。

现在我们已经准备好进行合约调用。像上次一样，我们传入`gas()`和`_callMe`。然而，这次我们从`0x9c`（`0x80`内存系列的最后4个字节）-`0xe0`传入我们的调用数据，并将数据存储在内存位置`0x100`-`0x120`。再次，检查调用是否成功并返回我们的输出。如果我们检查合约`CallMe`，我们看到值被成功更新为3和4。

为了进一步说明正在发生的事情，这里是我们返回之前的内存布局。

![img](https://img.learnblockchain.cn/2023/06/27/92085.png)



在最后，我们看一下`delegatecall()`。代码看起来几乎是一样的，只有一个变化。

```solidity
function delgatecallA(address _callMe, uint256 _var1, uint256 _var2) external payable returns (bytes memory) {
 
    assembly {
 
        // load slot 2
        let slot2 := sload(2)
 
        // isolate selectorA
        let mask := 0x000000000000000000000000000000000000000000000000000000000ffffffff
        let funcSelector := and(mask, slot2)
 
        // store function selectorA
        mstore(0x80, funcSelector)
 
        // copies calldata to memory location 0xa0
        // leaves out function selector and _callMe
        calldatacopy(0xa0, 0x24, sub( calldatasize(), 0x20 ) )
 
        // call contract
        let result := delegatecall(gas(), _callMe, 0x9c, 0xe0, 0x100, 0x120 )
 
        // check if call was successful, else revert
        if iszero(result) {
            revert(0,0)
        }
 
        // return values from memory
        return (0x100, 0x120)
 
    }
 
 
}
```

我们所做的唯一改变是将`call()`改为`delegatecall()`并删除`callvalue()`。我们不需要`callvalue()`，因为委托调用是在它自己的状态中执行`CallMe`的代码。因此，`a()`中的`require()`语句是在检查以太币是否被发送到我们的`Caller`合约。如果我们检查`CallMe`中的`var1`和`var2`，我们看到没有变化。然而，我们的`Caller`合约中的`var1`和`var2`被成功更新。

关于合约调用的部分，就结束了。
如何要进一步了解Yul，请阅读Yul的文档和以太坊黄皮书，链接：

Yul文档：https://docs.soliditylang.org/en/v0.8.17/yul.html
以太坊黄皮书：https://ethereum.github.io/yellowpaper/paper.pdf

如果你有任何问题，或者希望看到我做一个不同主题的教程，请在下面留言。

如果你想支持我制作教程，这里是我的以太坊地址：0xD5FC495fC6C0FF327c1E4e3Bccc4B5987e256794.

----

本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
