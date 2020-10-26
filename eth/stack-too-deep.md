> * 原文链接：https://soliditydeveloper.com/stacktoodeep  作者：[Markus Waas](https://soliditydeveloper.com/markuswaas)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[]()
> * 本文永久链接：[learnblockchain.cn/article…]()
 


# Stack Too Deep

## Three words of horror


You just have to add one tiny change in your contracts. You think this will take you only a few seconds. And you are right, adding the code took you less than a minute. All happy about your coding speed you enter the compile command. With such a small change, you are confident your code is correct.

But what's that? You see the message:



<center>**InternalCompilerError: Stack too deep, try removing local variables.**</center>


Ouch. What happened here? Chances are if you've written a few contracts in your career before, this is a very familiar error message and comes up at unpredictable times. But usually when you are short on time.

![](https://img.learnblockchain.cn/2020/10/22/16033393006456.jpg)


Don't worry though, it's not your fault. If you are struggling with this error, you are not the only one.

Just take a look at this recent poll:

![](https://img.learnblockchain.cn/2020/10/22/16033393201847.jpg)


## Why does this error exist?

![](https://img.learnblockchain.cn/2020/10/22/16033393337762.jpg)


The reason is a limitation in how variables can be referenced in the EVM stack. While you can have more than 16 variables in it, once you try to reference a variable in slot 16 or higher, it will fail. It's therefore not always obvious why exactly some code is failing and then a few random changes just seem to fix it.

But I don't want to bore you with too much theory. This is supposed to be a practical blog post.


## I don't care, just show me how to solve it


Now what exactly are some general approaches to fixing this? Let's look at five ways to deal with the error.


#### 1. Use less variables

![](https://img.learnblockchain.cn/2020/10/22/16033393596283.jpg)

#### 2. Utilizing functions

#### 3. Block scoping

#### 4. Utilizing structs

#### 5. Some Hacking

Okay the first one is obvious. If you can, try and refactor your code to simply use less variables. Not much further to it. Got it? Great, let’s  move on.

For the other four, let's look at a stack too deep example code and four different ways to fix it.


## Stack Too Deep Example

Let's look at the following code. It will throw our beloved stack too deep error message. What can we do about it?


```
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

### 1. Use an internal function


Yes using an internal function will make the error go away. For example we can split it into three function calls each adding up three uints. Oddly enough, the stack too deep error can force us to write better code.


```
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


### 2. Make use of block scoping


[Inspired by Uniswap](https://github.com/Uniswap/uniswap-v2-periphery/blob/69617118cda519dab608898d62aaa79877a61004/contracts/UniswapV2Router02.sol#L327-L333) you can also use block scoping. Simply put curly brackets around parts of the code:


```
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

### 3.  Pass structs instead

This is kind of a way to just use less variables. Put data in a struct. More often than not this is a good idea for readability reasons anyways.


```
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
### 4. Parsing msg.data


Original idea for this approach came from user [k06a at Stackexchange](https://ethereum.stackexchange.com/a/83842/33305). It's somewhat a hacky solution, so I generally wouldn't recommend it. But maybe you tried all the other ones without success? Then give this a try:

```
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

How this works is by parsing the `msg.data`. All data being sent to the contract is stored here, so we can comment out variable `a` and `b`, but still receive their values. The first 4 bytes of the msg.data is the [function selector](https://solidity.readthedocs.io/en/v0.7.1/abi-spec.html#function-selector) data. After that come our first two uint256 each with 32 bytes.

This works only for external functions given the msg.data being used. A workaround for using it also with public functions would be calling those public functions via `this.myPublicFunction()`.


**May the stack now always be deep enough for you.**

------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。


