原文链接：https://medium.com/blockchannel/the-use-of-revert-assert-and-require-in-solidity-and-the-new-revert-opcode-in-the-evm-1a3a7990e06e


# Solidity 学习：在Solidity中使用`Revert()`、Assert()和Require()，并且在EVM中使用新的Revert操作码


# 关于solidity，未来的改变和功能。

![img](https://img.learnblockchain.cn/attachments/2022/06/WRHGFgyT62b179002a071.jpeg)


取材自 [Osman Rana](https://unsplash.com/search/photos/fence-gate?photo=05Ola97OFoQ)

 

**Crosspost：这篇文章最初是由 ConsenSys 的“**[**Maurelian**](https://twitter.com/maurelian_)**”发表的，可以在** [**这里**](https://media.consensys.net/when-to-use-revert-assert-and-require-in-solidity-61fb2c0e5a57)**找到。 这是经他许可发布的，请欣赏！**



 
在Solidity[0.4.10](https://github.com/ethereum/solidity/releases/tag/v0.4.10)的版本发布引入了 `assert()`、`require()` 和 `revert()` 函数，从那时起，困惑就一直存在。

 

特别是，`assert()` 和 `require()`中的 “判断”函数提高了合约代码的可读性，但区分它们可能会令人困惑。
 
在本文中，将看到：

1.解释这些函数解决的问题。
2.讨论 Solidity 编译器如何处理新的 `assert()`, `require()` 和 `revert()`。
3.给出一些经验法则来决定如何以及何时使用每一个。
 
为方便起见，我使用这些功能中的每一个创建了一个简单的合约，您可以在 [remix] (https://remix.ethereum.org/#gist=c7b647b64d9d2422b81108f8b6af0c7c&version=soljson-v0.4.16+commit.d7661dd9.js)中对其进行测试。


如果你真的只想要一个 TLDR，那么[以太坊堆栈交换上](https://ethereum.stackexchange.com/questions/15166/difference-between-require-and-assert-and-the-difference-between-revert-and-thro)的这个答案应该可以做到。

# Solidity 中的错误处理模式
## 常规方式：` throw `和 if ... throw 模式

假设您的合约有一些特殊功能，只能由指定为 `owner`的特定地址调用。

在 Solidity 0.4.10 之前（以及之后的一段时间），这是强制执行权限的常见模式：
```
contract HasAnOwner {
    address owner;
    
    function useSuperPowers(){ 
        if (msg.sender != owner) { throw; }
        // do something only the owner should be allowed to do
    }
}
```

如果除`owner`之外的任何人调用  `useSuperPowers()`  函数，该函数将抛出返回 `invalid opcode` 错误，撤消所有状态更改，并用完所有剩余的气体（有关以太坊中的气体和费用的更多信息，请参阅[本文](https://www.google.com/url?q=https://media.consensys.net/ethereum-gas-fuel-and-fees-3333e17fe1dc&sa=D&ust=1505493857490000&usg=AFQjCNE7J1D8vcvRB1IcveGYgCJf3JpXkw)）。


throw 关键字现在已被弃用，最终将被完全删除。 幸运的是，新函数 assert()、require() 和 revert() 提供了相同的功能，但语法更简洁。

## 抛异常的模式

让我们看看如何使用我们的新保护函数更新 `if .. throw` 模式。

这一行：

```
if(msg.sender != owner) { throw; }
```


当前的行为与以下所有行为完全相同：

- `if(msg.sender != owner) { revert(); }`
- `assert(msg.sender == owner);`
- `require(msg.sender == owner);`

 

*请注意*，在 *`assert()`* 和 *`require()`* 示例中，条件语句是 `if` 块条件的反转，将比较运算符 `!=`切换为 `==`。

 
# 区分 assert() 和 require()

首先，为了帮助在你的心中区分这些“判断”功能，将 **`assert()`** 想象成一个过于**自信的**强盗，他偷走了你所有的气体。 然后把 **`require()`** 想象成一种礼貌的管理类型，他会指出你的错误，但更**宽容**。

有了那个方便的助记符，这两个函数之间的真正区别是什么？

在拜占庭网络升级之前，`require()` 和 `assert()` 实际上行为相同，但它们的字节码输出略有不同。


1. `assert()` 使用 **`0xfe`** 操作码导致错误条件
2. `require()` 使用 **`0xfd`** 操作码导致错误条件


如果您在黄皮书中查找其中任何一个操作码，您都不会找到它们。 这就是您看到 `invalid opcode`错误的原因，因为没有关于客户端应如何处理它们的规范。
 

然而，在拜占庭之后，这将改变，并且在[以太坊虚拟机中实现 EIP-140：REVERT 指令](https://www.google.com/url?q=https://github.com/axic/EIPs/blob/revert/EIPS/eip-140.md&sa=D&ust=1505493857492000&usg=AFQjCNGXZHdWiEuBOiiP1YhvQr4Ilij8hA)。 然后 `0xfd` 操作码将映射到 REVERT 指令。


这是我觉得真正吸引人的地方：

**自 0.4.10 版本以来已经部署了许多合约，其中包括一个处于休眠状态的新操作码，直到它不再无效。 到了一定的时间，它就会激活，变成** `REVERT`！

*注意：* `throw` 和 `revert()` 也使用 `0xfd`。 在 0.4.10 之前。`throw`使用  `0xfe`。

# REVERT 操作码会做什么
 

**`REVERT`** 仍将撤消所有状态更改，但其处理方式与“无效操作码”有两种不同的处理方式：

1. 它将允许您返回一个值。
2. 它将把剩余的gas退还给调用者。

## 1.它将允许您返回一个值

大多数智能合约开发人员都非常熟悉臭名昭著的且无用的`无效操作码`错误。 幸运的是，我们很快就能返回错误消息，或者返回错误类型数字。

这看起来像这样：
  

```
revert(‘Something bad happened’);
```

或

```
require(condition, ‘Something bad happened’);
```


 

*注意：solidity 尚不支持此返回值参数*，但您可以查看此[*问题*](https://www.google.com/url?q=https://www.google.com/url?q%3Dhttps://github.com/ethereum/solidity/issues/1686%23issuecomment-328181514%26sa%3DD%26ust%3D1505492320159000%26usg%3DAFQjCNHaxNwU92XDdLnWcaMYGX9luuhaQg&sa=D&ust=1505493857494000&usg=AFQjCNEqYU3HJRPkQLJRNvYobZIVPufwbA) 以*了解该更新*。


## 2. 将剩余gas退还给调用者
目前，当你的合约抛出异常时，它会耗尽所有剩余的 gas。 这可能会导致对矿工的慷慨捐赠，并且最终会花费用户很多钱。

一旦在 EVM 中实现了 `REVERT`，没有使用它来退还多余的 gas 将是明显的旧不礼貌的行为。

 
# 在 revert()、assert() 和 require() 之间进行选择


因此，如果`revert()` 和 `require()` 都退还任何剩余的 gas，并允许您返回一个值，为什么要使用 `assert()` 烧掉 gas？

区别在于字节码输出，为此我将引用[文档](https://www.google.com/url?q=https://solidity.readthedocs.io/en/develop/control-structures.html%23error-handling-assert-require-revert-and-exceptions&sa=D&ust=1505493857495000&usg=AFQjCNGsr19Xr-gK6reStgpM9BcgXnCb3Q)(我这里强调)：


 

> 应该使用 `require` 函数来确保满足有效条件，例如输入或合约状态变量，或者来自外部合约调用的有效返回值。 如果使用得当，分析工具可以评估您的合约，以确定将达到失败`assert`的条件和函数调用。 **正常运行的代码永远不应有失败的断言语句； 如果发生这种情况，您的合约中有一个错误，您应该修复它。**
 
 

稍微澄清一下： `require()` 语句失败应该被认为是正常且健康的事件（与 `revert()` 相同）。 当 `assert()` 语句失败时，发生了一些非常错误和意想不到的事情，你需要修复你的代码。


通过遵循本指南，[静态分析](https://en.wikipedia.org/wiki/Static_program_analysis)和[形式验证](https://en.wikipedia.org/wiki/Static_program_analysis#Formal_methods) 工具将能够检查您的合约，以找到并证明可能违反合约的条件，或证明您的合约按设计运行且没有缺陷。

在实践中，我使用一些启发式方法来帮助我决定哪个是合适的。
 

**使用** `require()` 的时候：

- 验证用户输入，即`require（input<20）；`
- 验证来自外部合约的响应，即 `require(external.send(amount));`
- 在执行之前验证状态条件，即。  `require(block.number > SOME_BLOCK_NUMBER)` 或者 `require(balance[msg.sender]>=amount)`
- 通常，您应该最常使用 `require`
- 通常，它将在函数的**开头**

在我们的智能合约最佳实践中有许多 `require()` 用于此类事情的[最佳示例](https://github.com/ConsenSys/smart-contract-best-practices)。
 
**使用** `revert()` 的时候：

- 处理与 require() 相同类型的情况，但逻辑更复杂。
  
如果您有一些复杂的嵌套 `if/else` 逻辑流程，您可能会发现使用 `revert()` 而不是 `require()` 是有意义的。但请记住，[复杂的逻辑是一种代码风格](https://github.com/ConsenSys/smart-contract-best-practices#fundamental-tradeoffs-simplicity-versus-complexity-cases)。

 

**使用** `assert()` 的时候：


- 检查[上溢/下溢](https://github.com/ConsenSys/smart-contract-best-practices#integer-overflow-and-underflow)，即: c = a+b;assert(c > b)
检查[常量](https://en.wikipedia.org/wiki/Invariant_(computer_science))，即:assert(this.balance >= totalSupply)

- 进行更改后验证状态
- 预防永远不可能发生的情况
- 通常，您可能会较少使用 assert
- 通常，它将在函数结束时使用。
 

基本上， `require()` 应该是您检查条件的首选函数， `assert()` 只是为了防止发生任何非常糟糕的事情，但条件评估为 `false` 是不可能的。

另外：“您不应该盲目地使用 assert 进行溢出检查，但前提是您认为以前的检查（使用 `if` 或 `require`）会使溢出变得不可能”。 ——来自@chriseth 的[评论](https://medium.com/@chriseth/thanks-for-this-detailed-writeup-83addc4b7f87)


 
# 结论
这些功能对于您的安全工具箱来说是非常强大的工具。 知道如何以及何时使用它们不仅有助于防止漏洞，还可以使您的代码更加用户友好，并且应对未来的变化。

