> * 原文链接：https://soliditydeveloper.com/stacktoodeep  作者：[Markus Waas](https://soliditydeveloper.com/markuswaas)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 本文永久链接：[learnblockchain.cn/article…]()

# "Stack Too Deep（堆栈太深）" 解决方案

## 恐怖的三个词


你只需要在合约中添加一个微小的更改即可。你认为这只需要几秒钟。没错，添加代码只花了不到一分钟的时间。你很高兴你快速解决了这个问题，你输入了compile命令。这么小的更改，你确信代码是正确的。

然而，你确看到以下错误消息：


<center><b>InternalCompilerError：Stack Too Deepp, try removing local variables.(堆栈太深，请尝试删除一些局部变量。)</b></center></br>



哎哟。这里发生了什么？如果你之前写过智能合约，这很可能是一个非常熟悉的错误消息，并且在不可预测的时间出现。但是通常在你时间紧迫的时候。

![](https://img.learnblockchain.cn/2020/10/22/16033393006456.jpg!/scale/50)


不过请放心，这不是你的错。如果你正在为这个错误而苦苦挣扎，那么你不是唯一的一个。

看看最近的调查，您最讨厌[Solidity](https://learnblockchain.cn/docs/solidity/index.html)哪个方面：

![](https://img.learnblockchain.cn/2020/10/22/16033393201847.jpg)


## 为什么会出现此错误？

![](https://img.learnblockchain.cn/2020/10/22/16033393337762.jpg)


原因是在EVM堆栈中如何引用变量方面存在限制。尽管其中可以包含16个以上的变量，但是一旦尝试引用16或更高槽位中的变量，将失败。因此，并非总是很清楚为什么某些代码会失败，然后进行一些随机更改似乎可以解决问题。

但是我不想介绍太多让你厌倦的理论。这是一篇实用的博客文章。


## 如何解决


现在到底有什么通用方法可以解决此问题？让我们看一下处理错误的五种方法：


1. 使用更少的变量

![](https://img.learnblockchain.cn/2020/10/22/16033393596283.jpg)

2. 利用函数

3. 代码块作用域范围

4. 利用结构体

5. 一些黑技巧

好吧，第一个显而易见。如果可以，请尝试重构代码以使用更少的变量。办法很直接，让我们继续前进看看其他 4 个方法。

对于其他四个，我们来看一个堆栈太深的示例代码以及四种修复它的方法。


## Stack Too Deep 的例子

让我们看下面的代码。它将抛出困扰我们的堆栈太深的错误消息。我们可以对它可以做些什么呢？


```js
// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

contract StackTooDeepTest1 {
    function addUints(
        uint256 a,uint256 b,uint256 c,uint256 d,uint256 e,uint256 f,uint256 g,uint256 h,uint256 i
    ) external pure returns(uint256) {

        return a+b+c+d+e+f+g+h+i;
    }
}
```

### 1.使用内部函数


是的，使用内部函数将使错误消失。例如，我们可以将其分为三个函数调用，每个函数调用加起来会包含三个uint。神奇的是，堆栈太深的错误会迫使我们编写更好的代码。


```js
// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

contract StackTooDeepTest1 {
   function addUints(
        uint256 a,uint256 b,uint256 c,uint256 d,uint256 e,uint256 f,uint256 g,uint256 h,uint256 i
    ) external pure returns(uint256) {

        return _addThreeUints(a,b,c) + _addThreeUints(d,e,f) + _addThreeUints(g,h,i);
    }

    function _addThreeUints(uint256 a, uint256 b, uint256 c) private pure returns(uint256) {
        return a+b+c;
    }
}
```


### 2.利用块作用域


[受Uniswap启发] (https://github.com/Uniswap/uniswap-v2-periphery/blob/69617118cda519dab608898d62aaa79877a61004/contracts/UniswapV2Router02.sol＃L327-L333)，你也可以使用块作用域。只需将大括号括在部分代码中：


```js
// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

contract StackTooDeepTest2 {
    function addUints(
        uint256 a,uint256 b,uint256 c,uint256 d,uint256 e,uint256 f,uint256 g,uint256 h,uint256 i
    ) external pure returns(uint256) {

        uint256 result = 0;

        {
            result = a+b+c+d+e;
        }

        {
            result = result+f+g+h+i;
        }

        return result;
    }
}
```

### 3. 通过传递结构体

这是只使用较少变量的一种方法。将数据放入结构中。出于可读性原因，也是一个好主意。


```js
// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

contract StackTooDeepTest3 {
    struct UintPair {
        uint256 value1;
        uint256 value2;
    }

    function addUints(
        UintPair memory a, UintPair memory b, UintPair memory c, UintPair memory d, uint256 e
    ) external pure returns(uint256) {

        return a.value1+a.value2+b.value1+b.value2+c.value1+c.value2+d.value1+d.value2+e;
    }
}
```

### 4.解析msg.data


这种方法的最初想法来自用户[Stackexchange的k06a](https://ethereum.stackexchange.com/a/83842/33305)，这需要点黑技巧，所以我通常不建议这样做。但是如果你尝试了所有其他尝试都没有成功？可以尝试一下：

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

contract StackTooDeepTest4 {
    function addUints(
        uint256 /*a*/,uint256 /*b*/,uint256 c,uint256 d,uint256 e,uint256 f,uint256 g,uint256 h,uint256 i
    ) external pure returns(uint256) {
      return _fromUint(msg.data)+c+d+e+f+g+h+i;
    }

    function _fromUint(bytes memory data) internal pure returns(uint256 value) {
        uint256 value1;
        uint256 value2;

        assembly {
            value1 := mload(add(data, 36))
            value2 := mload(add(data, 68))
            value  := add(value1, value2)
        }
    }
}
```

这是如何工作的，就是通过解析`msg.data`。所有发送到合约的数据都存储此变量，因此我们可以注释掉变量`a`和`b`，但仍接收它们的值。 msg.data的前4个字节是[函数选择器] (https://learnblockchain.cn/docs/solidity/abi-spec.html#function-selector)数据。之后是我们的前两个uint256，每个32位。

使用 msg.data 的方法仅适用于外部函数。一种变通方法是将其与公共函数一起使用， 方法是通过`this.myPublicFunction()`调用那些公共函数。


** 也许现在的堆栈对你来说足够了。：）**

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。