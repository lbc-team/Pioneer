# 在 Solidity中使用值数组以降低 gas 消耗

本文讨论如何使用值数组（Value Array）方式来减少Solidity智能合约的gas 消耗。



## 背景

我们Datona Labs在开发和测试Solidity数据访问合约（S-DAC：Smart-Data-Access-Contract）模板过程中，经常需要使用只有很小数值的小数组（数组元素个数少）。在本示例中，研究了使用值数组（Value Array）是否比引用数组（Reference Array）更高效。





# 讨论



Solidity支持内存（memory）中的分配数组，这些数组会很浪费空间（参考 [文档](https://learnblockchain.cn/docs/solidity/types.html#arrays)），而存储（*storage*）中的数组则会消耗大量的gas来分配和访问存储。但是Solidity所运行的[以太坊虚拟机（EVM）](https://learnblockchain.cn/2019/04/09/easy-evm)有一个256位（32字节）机器字长。正是后一个特性使我们能够考虑使用值数组（Value Array）。在机器字长的语言中，例如32位（4字节），值数组（Value Array）不太可能实用。



我们可以使用值数组（Value Array）减少存储空间和gas消耗吗？



> 译者注：机器字长 是指每一个指令处理的数据长度。



## 比较值数组与引用数组

### 引用数组（Reference Array）



在 Solidity 中，数组通常是引用类型。这意味着每当在程序中遇到变量符号时，都会使用指向数组的指针，不过也有一些例外情况会生成一个拷贝（参考[文档-引用类型](https://learnblockchain.cn/docs/solidity/types.html#reference-types)）。在以下代码中，将10个元素的 8位uint  `users` 的数组传递给`setUser`函数，该函数设置users数组中的一个元素：

```js
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

函数返回后，`users`数组元素将被更改。



### 值数组（Value Arrays）



值数组是以[值类型](https://learnblockchain.cn/docs/solidity/types.html#value-types)保存的数组。这意味着在程序中遇到变量符号，就会使用其值。



```javascript
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



请注意，在函数返回之后，函数的users参数将保持不变，因为它是通过值传递的，为了获得更改后的值，需要将函数返回值赋值给users变量。



## Solidity bytes32 值数组

Solidity 在 bytesX（X=1..32）类型中提供了一个部分值数组。这些字节元素可以使用数组方式访问单独读取，例如：



```
    ...
    bytes32 bs = "hello";
    byte b = bs[0];
    require(bs[0] == 'h');
    ...
```

但不幸的是，在[Solidity 目前的版本](https://learnblockchain.cn/docs/solidity/types.html#index-7)中，我们无法使用数组访问方式写入某个字节：



```
    ...
    bytes32 bs = "hello";
    bs[0] = 'c'; // 不可以实现
    ...
```



让我们使用Solidity的 [using for](https://learnblockchain.cn/docs/solidity/contracts.html#using-for) 导入库的方式为bytes32类型添加新能力：



```js
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

这个库提供了set()函数，它允许调用者将bytes32变量中的任何字节设置为想要的字节值。根据你的需求，你可能希望为你使用的其他bytesX类型生成类似的库。



### 测试一把

让我们导入该库并测试它：

```javascript
import "bytes32lib.sol";

contract TestBytes32 {
    using bytes32lib for bytes32;
    
    function test1() public pure {
        bytes32 va = "hello";
        require(va[0] == 'h');
        // 类似 va[0] = 'c'; 的功能
        va = va.set(0, 'c');
        require(va[0] == 'c');
    }
}
```



在这里，你可以清楚地看到set()函数的返回值被分配回参数变量。如果缺少赋值，则变量将保持不变，require()就是来验证它。



# 可能的固定长度值数组

在Solidity机器字长为256位（32字节），我们可以考虑以下可能的值数组。

## 固定长度值数组

这些是以些Solidity[可用整型](https://learnblockchain.cn/docs/solidity/types.html#integers)匹配的固定长度的值数组：



```
                         固定长度值数组
类型          类型名       描述
uint128[2]   uint128a2   2个128位元素的值数组
uint64[4]    uint64a4    4个64位元素的值数组
uint32[8]    uint32a8    8个32位元素的值数组
uint16[16]   uint16a16   16个16位元素的值数组
uint8[32]    uint8a32    32个8位元素的值数组
```

> 128位元素: 意思是一个元素占用128位空间

我建议使用如上所示的类型名，这在本文中都会用到，但是你可能会找到一个更好的命名约定。



## 更多固定长度值数组



实际上，还有更多可能的值数组。 我们还可以考虑与Solidity可用类型不匹配的类型，对于特定解决方案可能有用。 X（值的位数）乘以Y（元素个数）必须小于等于256：

```
                    更多固定长度值数组
类型          类型名       描述
uintX[Y]     uintXaY     X * Y <= 256

uint10[25]   uint10a25   25个10位元素的值数组

uint7[36]    uint7a36    36个7位元素的值数组
uint6[42]    uint6a42    42个6位元素的值数组
uint5[51]    uint5a51    51个5位元素的值数组
uint4[64]    uint4a64    64个4位元素的值数组

uint1[256]   uint1a256   256个1位元素的值数组
...
```



特别感兴趣的是uint1a256值数组。 这使我们可以将最多256个1位元素值（代表布尔值）有效地编码为1个EVM字长。 相比之下，Solidity的bool [256]会消耗256倍的内存空间，甚至是8倍的存储空间。



## 还有更多固定长度值数组



还有更多可能的值数组。以上是最有效的值数组类型，因为它们有效地映射到EVM字长中的位。在上面的值数组类型中，X表示元素所占用的位数。

还有按位移位技术的在算术编码中使用乘法和除法，但这超出了本文的范围，可以参考[这里](https://en.wikipedia.org/wiki/Arithmetic_coding)



## 固定长度值数组实现

下面是一个有用的可导入库文件，为值数组类型uint8a32提供get和set函数：



```js
// uint8a32.sol

library uint8a32 { // 等效于 uint8[32]
    uint constant bits = 8;
    uint constant elements = 32;
    
    // 确保 bits * elements <= 256
   
    uint constant range = 1 << bits;
    uint constant max = range - 1;  

    // get 函数
    function get(uint va, uint index) internal pure returns (uint) {
        require(index < elements);
        return (va >> (bits * index)) & max;
    }
    
    // set 函数
    
    function set(uint va, uint index, uint ev) internal pure 
    returns (uint) {
        require(index < elements);
        require(value < range);
        index *= bits;
        return (va & ~(max << index)) | (ev << index);
    }
}
```



get()函数只是根据index参数从值数组中返回适当的值。set()函数将删除现有值，然后根据index参数将给定值设置到返回值里。



可以推断出，只需复制上面给出的uint8a32库代码，然后更改bits和elements常量，即可用于其他uintXaY值数组类型。



Solidity库合约中[无法存储变量](https://solidity.readthedocs.io/en/latest/contracts.html#libraries)。



## 测试一把

让我们测试一下上面的示例库代码：



```js
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





通过编译器的using for 指令，因此可以在变量上直接使用`.` 语法来调用set()函数。但是在你的智能合约需要多种不同的值数组类型的情况下，由于名称空间冲突（或者需要每种类型使用各自特定名称的函数），这需要使用显式库名点表示法来访问函数：



```js
import "uint8a32.sol";
import "uint16a16.sol";
contract MyContract {
    uint users; // uint8a32
    uint roles; // uint16a16
    
    ...
    
    function setUser(uint n, uint user) private {
        // 想实现的是: users = users.set(n, user);
        users = uint8a32.set(users, n, user);
    }
    
    function setRole(uint n, uint role) private {
        //  想实现的是: roles = roles.set(n, role);
        roles = uint16a16.set(roles, n, role);
    }
    
    ...
}
```

还需要小心在正确的变量上使用正确的值数组类型。



这是相同的代码，但为了阐述该问题，变量名称包含了数据类型：

```js
import "uint8a32.sol";
import "uint16a16.sol";
contract MyContract {
    uint users_u8a32;
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

## 避免赋值

如果我们提供一个使用1个元素的数组的函数，则实际上有可能避免使用set()函数的返回值赋值。 但是，由于此技术使用更多的内存，代码和复杂性，因此抵消了使用值数组的可能优势。



# Gas 消耗对比

编写了库和合约后，我们使用在[此文](https://medium.com/coinmonks/gas-cost-of-solidity-library-functions-dbe0cedd4678)中介绍的技术测量了gas消耗。结果如下：



## bytes32 值数组



![1_1rFIufB3Y9e6txiTnDpoKQ](https://img.learnblockchain.cn/pics/20200820105003.png!wl)

> 在内存和存储上，bytes32的get和set的Gas消耗32个变量

不用奇怪，在内存中gas消耗可以忽略不计，而存储中，gas消耗是巨大的，尤其是第一次用非零值（大蓝色块）写入存储位置时。随后使用该存储位置消耗的gas要少得多。

## uint8a32 值数组

在这里，我们比较了在EVM内存中使用固定长度的uint8 []数组与uint8a32值数组的情况：



![uint8与byte内存上gas 消耗对比](https://img.learnblockchain.cn/pics/20200820105037.png!wl)



> 在uint8/byte内存上，gas 消耗对比



令人惊讶的是，uint8a32 值数组消耗的gas只有固定长度数组uint8[32] 的一半左右。而uint8[16]和uint8[4]相应的gas消耗更低。这是因为值数组代码必须读取和写入值才能设置元素值，而uint8[]只需写入值。



以下是在EVM存储中比较gas 消耗：





![gas 消耗对比](https://img.learnblockchain.cn/pics/20200820105111.png!wl)



> 在存款上，gas 消耗的对比



在这里，与使用uint8[Y]相比，每个uint8a32 set() 函数消耗的gas循环少几百个。uint8 [32]，uint8 [16]和uint8 [4]的gas 消耗量相同，因为它们使用相同数量的EVM存储空间（一个32字节的插槽）。



## uint1a256 值数组



在EVM内存中，固定长度的bool[]数组与uint1a256值数组的gas对比：



![gas 对比](https://img.learnblockchain.cn/pics/20200820105136.png)



>  bool与1bit 在内存的 gas消耗 对比

显然，bool数组的gas消耗很显著



相同的比较在EVM存储中：



![1_pqdUNkuGjqJd7UyejQxoIg](https://img.learnblockchain.cn/pics/20200820105204.png)



> bool与1bit 在存储中的 gas消耗 对比



bool [256]和bool [64] 使用2个存储插槽，因此gas 消耗相似。bool [32]和uint1a256仅使用一个存储插槽。



## 作为子合约和库的参数

![参数的gas消耗](https://img.learnblockchain.cn/pics/20200820105235.png!wl)

> 将bool/1bit参数传递给子合约或库的gas消耗



不用奇怪，最大的gas消耗是为子合约或库函数提供数组参数。

使用单个值而不是复制数组显然会消耗更少的gas。



# 其他可能性

如果你发现固定长度的值数组很有用，那么你还可以考虑固定长度的多值数组、动态值数组、值队列、值堆栈等。



# 结论

我已经提供用于写入Solidity bytes32变量的代码，以及用于uintX [Y]值数组的通用库代码。

也提出了如固定长度的多值数组，动态值数组，值队列，值堆栈等其他可能性。



是的，我们可以使用值数组减少存储空间和gas消耗。



如果你的Solidity智能合约使用较小值的小数组（例如用户ID，角色等），则使用值数组可能会消耗更少的gas。



当数组被复制时，例如智能合约或库参数，值数组将始终消耗少得多的gas。







作者：[Julian Goddard](https://medium.com/@plaxion?source=post_page-----32ca65135d5b----------------------)

https://medium.com/coinmonks/value-arrays-in-solidity-32ca65135d5b