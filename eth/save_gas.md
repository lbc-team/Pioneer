> * 链接：https://blog.polymath.network/solidity-tips-and-tricks-to-save-gas-and-reduce-bytecode-size-c44580b218e6 作者：[Mudit Gupta](
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# Solidity 技巧：如何减少字节码大小及节省 gas



![](https://img.learnblockchain.cn/2020/09/03/15991056905111.jpg)

 Solidity 是一种特殊的语言，有许多的奇淫怪巧。由于Solidity被创建为可在EVM上使用其有限的函数集，因此许多函数在Solidity中的行为与大多数其他语言不同。几个月前我写了一篇[博客文章，通过有十个技巧来节省Solidity中的gas 消耗](https://mudit.blog/solidity-gas-optimization-tips/)，但是收到了很大的反响。

> 10 个技巧是：
>
> 1. 合并打包变量
> 2.  uint8 不总是比 uint256 便宜
> 3.  Mappings 大部分时候比 Arrays 便宜
> 4. 不是所有的元素可以被打包
> 5. 用 bytes32 而不是 string/bytes
> 6. 少使用外部调用
> 7. 使用外部函数修改器
> 8. 删除不需要的变量
> 9. 使用短电路规则
> 10. 尽量避免（如循环中）修改存储变量
>
> 在我的专栏：[智能合约开发 - 打通 Solidity 任督二脉](https://learnblockchain.cn/column/1)，有更多的文章深入介绍如何介绍 GAS，订阅超值。



从那篇文章起，我又收集了更多的技巧与大家分享，再次分享给大家：

## 函数修饰器可能效率低下

添加函数修饰器时，将提取修饰器的代码并替换函数内出现的`_`符号。这也可以理解为函数修饰器是内联的。在普通的编程语言中，内联小代码更高效，并且不有任何实际的缺点，但Solidity不同。在[Solidity ](https://learnblockchain.cn/docs/solidity/)中，[EIP 170](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-170.md)将合约的最大大小限制为24 KB，如果同一代码多次内联，则加起来就会很容易达到24 KB大小限制。

另一方面，内部函数不是内联的，而是称为独立函数。这意味着它们在运行时gas要稍微贵一点，但是在部署中可以节省很多冗余字节码。内部函数还可以帮助避免可怕的[“堆栈太深错误”](https://learnblockchain.cn/article/1629)，因为在内部函数中创建的变量与原始函数不会共享相同的堆栈，但是在修饰器中创建的变量共享相同的堆栈。

通过这种技巧，我将一份合约的大小从23.95 KB减小到11.9 KB。修改[提交在这里](https://github.com/PolymathNetwork/polymath-core/pull/548/commits/2dc0286f4e96241eed9603534607431a8a84ba35#diff-8b6746c2c4e7c9e3fca67d62718d70e8)，请查看[DataStore.sol](https://github.com/PolymathNetwork/polymath-core/pull/548/commits/2dc0286f4e96241eed9603534607431a8a84ba35#diff-8b6746c2c4e7c9e3fca67d62718d70e8)合约。

## 布尔类型使用8位，而你只需要1位

在 solidity 的底层，布尔类型(bool)为uint8，即使用8位存储空间。而布尔值只能有两个值：True或False，其实只需要在单个存储位中就可以保存布尔值。你可以在一个字（32 个字节，EVM一次处理数据的长度）中包含256个布尔值。最简单的方法是采用一个`uint256`变量，并使用其所有256位来表示各个布尔值。要从uint256中获取单个布尔值，请使用以下函数：

```js
function getBoolean(uint256 _packedBools, uint256 _boolNumber)
    public view returns(bool)
{
    uint256 flag = (_packedBools >> _boolNumber) & uint256(1);
    return (flag == 1 ? true : false);
}
```

要设置或清除布尔值，可使用：

```js
function setBoolean(
    uint256 _packedBools,
    uint256 _boolNumber,
    bool _value
) public view returns(uint256) {
    if (_value)
        return _packedBools | uint256(1) << _boolNumber;
    else
        return _packedBools & ~(uint256(1) << _boolNumber);
}
```

使用这种技术，你可以在一个存储槽中存储256个布尔值。如果你尝试正常打包`bool`(如在结构体中)变量，一个插槽中则只能在装入32个布尔型。

**注意**：仅当你要存储32个以上的布尔值时才使用此技巧。



## 使用库节省字节码

当你调用库的公共（public）函数时，该函数的字节码不会包含在合约内，因此可以把一些复杂的逻辑放在库中，这样减小合约的大小。不过你得清楚，调用库会花费一些gas和使用一些字节码。对库的调用是通过委托调用（delegate call）的方式进行的，这意味着库可以访问合约拥有的数据，并且具有相同的权限。因此对于简单任务不值得这样做。

另外，你还需要知道，库的内部函数，solc 编译器则把器内联到了合约内。内联有其自身的优点，但是需要字节码空间。



## 无需使用默认值初始化变量

如果未设置/初始化变量，则变量具有默认值(0，false，0x0等，取决于数据类型)。如果你使用默认值对其进行显式初始化，那只会浪费 gas 。

```js
uint256 hello = 0; //错误示范, expensive
uint256 world; //很好, cheap
```

## 使用简短的错误原因字符串

你可以(并且应该)在使用`require`语句时，附加上错误原因字符串，以便更容易理解为什么合约调用被回退。但是，这些字符串会在部署的字节码中占用空间。每个错误原因字符串至少需要32个字节，因此确保错误原因字符串在32个字节以内，否则它会变得更昂贵。

```js
require(balance >= amount, "Insufficient balance"); //很好
require(balance >= amount, "To whomsoever it may concern. I am writing this error message to let you know that the amount you are trying to transfer is unfortunately more than your current balance. Perhaps you made a typo or you are just trying to be a hacker boi. In any case, this transaction is going to revert. Please try again with a lower amount. Warm regards, EVM"; //错误示范
```

## 避免重复检查

无需以不同的形式一次又一次地检查相同的条件。最常见的冗余检查是使用SafeMath库。 SafeMath库本身会检查下溢和上溢，因此无需自己重复检查变量。

```js
require(balance >= amount); 
//This check is redundant because the safemath subtract function used below already includes this check.
balance = balance.sub(amount);
```

## 单行交换变量

Solidity提供了一个相对不常见的功能，可以在单个语句中交换变量的值。可以使用它代替使用临时变量/异或/算术函数交换值。以下代码显示了如何交换不同变量的值：

```
(hello, world) = (world, hello)
```



## 使用事件存储链上不需要的数据



使用事件存储数据比在合约变量中存储要便宜得多。但是，我们没法在从事件中使用数据。另外，要利用起老的事件数据，你也许需要托管自己的节点才能从旧事件中获取数据。你的自己做判断。



## 适当的使用优化(optimizer)



除了允许你打开和关闭优化器之外，solc 还允许自定义优化器的`run`。 `run`不是优化器运行的次数，而是你希望调用该智能合约函数的调用次数。如果智能合约只能一次性使用，如授予或锁定代币的智能合约，则可以将`run`值设置为` 1`，这样编译器将产生最小的字节码，但调用函数成本可能会少量的增高。如果你要部署一个经常使用的合约(例如ERC20代币)，则应将`run`设置为较高的数字(如` 1337`)，这样初始字节码会稍大一些，但对该合约的调用将更便宜，例如：常用的 transfer函数会便宜一些。

## 更少调用函数可能更好

通常，使用具有单个任务的小函数是一种良好的编码习惯。但是，使用多个较小的函数会花费更多的gas，并且需要更多的字节码。而使用较大的复杂函数可能会使测试和审记变得困难，我无法简单建议你使用哪个。

## 调用内部函数更便宜

在智能合约内部，调用内部（internal）函数比调用公共（public）函数要便宜，因为当你调用公共函数时，所有参数都会再次复制到内存中并传递给该函数。相比之下，当你调用内部函数时，将传递这些参数的引用，并且它们不会再次复制到内存中。这样可以节省一些 gas ，尤其是在参数较大时如此。

## 使用代理模式进行大规模部署

如果你希望部署同一合约的多个副本，则可以考虑仅部署一个实现合约和多个代理合约，并将多个代理合约逻辑委派给实现合约。这将允许这些合约共享相同的逻辑而又不同的数据。



## 最后的想法

大多数通用的良好编程原则和优化同样适用于Solidity，但是Solidity中有一些奇怪的地方，例如上面提到的几个，这让优化Solidity代码得更难(但也更有趣)。随着越来越多地使用 Solidity ，你将学到更多技巧。但是，无论使用多少技巧，在创建复杂代码时，你仍然可能面临 24 KB的代码大小限制。你可以使用代理或其他技术将合约分解为多个合约，但是限制仍然很麻烦。如果你希望取消限制，可以在此[GitHub Issue](https://github.com/ethereum/EIPs/issues/1662)的反馈.





------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。