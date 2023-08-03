> * 原文链接： https://jeancvllr.medium.com/solidity-all-about-errors-handling-99f7f02c17d
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 深入理解 Solidity 错误 #3 - 错误处理

![img](https://img.learnblockchain.cn/2023/08/03/56014.jpeg)



本文是["深入理解 Solidity 错误"系列](https://medium.com/better-programming/solidity-all-about-errors-cb831ad0b840)的第三篇： 如何处理错误。

在了解了错误的不同类型（[编译时错误](https://learnblockchain.cn/article/6242)与[运行时错误](https://learnblockchain.cn/article/6251)）、Solidity 错误的不同类型以及它们之间的区别之后，我们现在来看看处理它们的不同方法。



Solidity 提供了多种内置方法来处理错误，包括 `assert()`、`require()` 和 `revert()`。我们将在本文中了解它们之间的区别、每种方法的使用时机以及各自的优点。我们还将探讨如何处理来自外部调用（函数调用与底层调用）的错误。

最后，我们将简要介绍在编写 Solidity 时应注意的一些情况，这些情况可能会导致错误和 bug，但 Solidity 代码不会在运行时发出出错信号！



## 关于 Solidity 中的错误处理

适当而准确地处理错误对任何编程语言都至关重要。我们经常听到这样的说法：

- 在编写 try 代码块之前先编写 catch 代码块
- "及早抛出错误"

智能合约通常持有大量资金，处理重要的业务逻辑，并且一旦部署到正式主网上就无法编辑。所有这些都突显：智能合约是任务关键型程序。

因此，在以太坊和 EVM 环境中错误地处理错误更不可取。

在 solidity 0.4.x 之前，处理错误的唯一方法是使用 `throw`。从 Solidity 0.8.x 开始，Solidity 有 4 种不同的错误处理方式：

- 使用 `revert` 
- 使用 `assert`
- 使用 `require`
- 使用`invalid`

## assert()

在 Solidity 开发者社区中，经常会有这样的困惑：是否应该在合约中使用`assert()`；如果应该使用，那么是何时以及在何种情况下使用呢。

Consensys在他们的[智能合约最佳实践指南](https://consensys.github.io/smart-contract-best-practices/development-recommendations/solidity-specific/assert-require-revert/#enforce-invariants-with-assert)中为这个问题提供了最直接的答案：

**使用 `assert()` 强化不变性**

不变性的意思是*"在执行过程中假定永远为真的东西 "*。换句话说，不变性是指在合约部署后的整个生命周期内都不应该改变且始终保持不变的属性。(例如：代币发行合约中代币与以太币的发行比例可能是固定的）。



Solidity 文档也同样并建议在以下情况下使用 `assert()` 语句：

- 测试内部错误
- 检查不变性



Assert 保护有助于验证这一点在任何时候都是正确的。



### 如何在 Solidity 中使用 assert()？

`assert()` 可以通过检查条件来使用。如果不满足条件，`assert()` 将：

- 抛出一个类型为 `Panic(uint256)` 的错误。
- 还原所有状态更改。

条件被指定为 `assert()` 的第一个参数，其必须是布尔值 `true` 或 `false`。如果布尔条件的值为 `false` 则会产生异常。

```solidity
assert(bool condition)
```

与 `require()` 不同，你不能提供错误提示字符串作为 `assert()` 的第二个参数。

### 自 Solidity 0.8.0 起 assert 行为有变化

在 Solidity 0.8.0 之前，`assert()` 会消耗所有提供给交易的Gas。自 Solidity 0.8.0 版本发布后，情况不再如此。

在 0.7.6 之前，当 `assert()` 中的条件失败时：

- 所有状态变化都将回滚。
- 所有提供的Gas将被消耗。

自 0.8.0 起，当 `assert()` 中的条件失败时：

- 所有状态变化都会回滚。
- 剩余的Gas将返回给发起者。

这是因为在 0.8.0 之前，`Panic(uint256)`类型的错误在 EVM 的底层使用了 `INVALID `操作码。现在情况不再如此。自 0.8.0 版 Solidity 起，`Panic(uint256)` 使用 `REVERT` 操作码。

![solidity- 错误处理 solidity 0.8 asset](https://img.learnblockchain.cn/2023/08/03/86287.png)

>  [Solidity 0.8.0 突破性更改](https://learnblockchain.cn/docs/solidity/080-breaking-changes.html) (来源：Solidity 文档）

让我们来看一个基本示例。如果将基本代码片段粘贴到 Remix 中，并将数字 `0` 作为函数 `addToNumber(...)` 的输入，就会违反`assert`条件。

```solidity
contract Assert {

    uint256 number;

    function addToNumber(uint256 input) public {

        uint256 before = number;

        number += input;

        assert(number > before);
    }

}
```

提供 3 百万Gas，我们可以看到不同的错误信息

![solidity- 错误处理 solidity 0.8 asset](https://img.learnblockchain.cn/2023/08/03/14963.jpeg!lbclogo)

<p align="center">自 Solidity 0.8.0 版起，assert 不再消耗所有Gas</p>



注意：若要消耗所有Gas，可通过内联汇编使用 `INVALID` 操作码来强制消耗调用中可用的所有剩余Gas。更多详情，请参阅下文有关 `invalid `的部分。

### 使用 assert() 进行形式验证

作为一个 Solidity 开发者，一旦你开始掌握 "智能合约不变性 "和不变属性的概念，`assert()`就能帮助你加强智能合约的安全性。

遵循这一范例，形式分析工具就能验证智能合约的不变性是否被违反，并使智能合约永远无法达到某些属性被更改的状态。

这意味着不会违反代码中的不变性，而且代码经过了形式验证。

在 Solidity 代码中使用 `assert()`时，可以运行 SMT Checker 或 K-Framework 等形式化验证工具，查找可能违反这些属性的方法和调用路径。这将有助于找到更多的攻击向量和漏洞，从而加强合约的安全性。

### 关于 assert() 的最后重要说明

断言防护通常应与其他技术相结合，例如暂停合约并允许升级。

否则，你最终可能会被一个总是失败的断言困住。

你可以在[智能合约 (SWC-110)](https://swcregistry.io/docs/SWC-110) 中看到一些违反断言的好例子。



## require()

> **注意：** 在 Metropolis 发布之前，使用 `require` 的异常会消耗所有Gas。现在情况已不同。

在 Solidity 中，`require()`语句是最常用的错误处理方式之一（尽管由于通过`revert`自定义错误的使用越来越多，`require` 的使用也在慢慢减少）。

顾名思义，`require` 有助于确保在智能合约中执行某些函数时满足某些条件（运行时所需的条件）。

根据 Consensys 智能合约最佳实践，[*require()*用于确保满足有效条件](https://docs.soliditylang.org/en/latest/control-structures.html#panic-via-assert-and-error-via-require)，如输入或合约状态变量，或验证调用外部合约的返回值。

`require`可以创建：

- 没有数据的错误
- 或 `Error(string)` 类型的错误

我们将在接下来的章节中详细了解。

### 如何使用 require()？

`require()` 的用法与 "assert"相同，用于检查条件。如果不符合条件，就会抛出异常。

条件为 `require()` 的第一个参数，其值为 `true` 或 `false` 。

如果不满足条件，则抛出异常：

- 则抛出类型为 `Error(string)` 的错误。
- 所有状态更改都会回滚
- 未使用的 Gas 返回给交易发起者

`require()` 可以选择是后指定错误字符串：

```solidity
require(bool condition)
require(bool condition, string memory message)
```

### 使用 require() 检查多个条件（或至少一个条件）

也可以：

- 在一个 `require()` 检查中使用 `&&` （ 位与运算符）组合检查多个条件
- 使用 `||` 检查一个或另一个条件是否有效

下面是 UniswapFactory V3 中的一个示例，说明如何通过 `&&` 在 `require` 中同时确保两个条件。

![solidity- 错误处理 require 检查多个条件](https://img.learnblockchain.cn/2023/08/03/50672.png)

> 来源：https://github.com/Uniswap/v3-core/blob/e3589b192d0be27e100cd0daaf6c97204fdb1899/contracts/UniswapV3Factory.sol#L61-L72

### 何时使用 require()？

应该使用 `require()` 检查来确保满足条件，只有在调用已部署的合约并与之进行 `实时 `交互（无论是在开发测试网还是主网）时才能检测条件是否满足。我们称之为 `运行时`，即执行合约代码时。

必须检查的条件和需要验证的输入包括：

- 提供给函数参数的输入。
- 从外部调用其他合约的返回值。
- 处理后必须具有特定值的合约状态。

下面是从 OpenZeppelin 的 `ERC20 `代币合约的 Solidity 代码中提取的一个常用示例。我们可以从下面的截图中看到，函数上方注释中的要求是通过 Solidity 代码中的 `require(...)` 语法检查的。

![solidity- 错误处理](https://img.learnblockchain.cn/2023/08/03/50889.png!lbclogo)

关于检查外部调用返回的值，OpenZeppelin 的 `Address` 库在使用库中的 `sendValue(...)` 时会检查底层调用是否返回了 `success` 布尔值。

![solidity- call 错误处理](https://img.learnblockchain.cn/2023/08/03/53115.png)

>  来源：https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol

### require() 带错误提示



使用 `require()` 时，你可以选择提供一个错误提示字符串作为第二个参数。其形式为 `require(condition, "error message")`， 此时将创建一个 Error(string) 类型的错误。

当你提供错误提示作为 `require(condition, "error message")` 的第二个参数时，`error message`将是一个 abi 编码的 `字符串`，就像调用名为 `Error(string) `的函数一样。不过**没有函数被调用；只是使用`Error(string)`的字节4选择器**来区分错误类型。

```solidity
function Error(string memory) public {
    // ...
}
```

让我们举例说明，请看下面的代码片段：

```solidity
require(
    amount <= msg.value / 2 ether,
    "Not enough Ether provided."
);
```

以十六进制返回的错误数据格式如下：

```
0x08c379a0                                                         // Error(string) 的函数选择器
0x0000000000000000000000000000000000000000000000000000000000000020 // 数据偏移
0x000000000000000000000000000000000000000000000000000000000000001a // 数据长度
0x4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 // 字符串数据 (utf8 encoded hex "Not enough Ether provided.")
```

让我们来详细分析一下：

- `0x08c379a0` = `Error(string)` 的 keccak256 哈希值的前 4 个字节：

```solidity
keccak256("Error(string)")
= 08c379a0afcc32b1a39302f7cb8073359698411ab5fd6e3edb2c02c0b5fba8aa 
```

- `0x00000000000000000000000000000000000000000020` = `string`错误提示`Not enough Ether provided.`的偏移量
- `0x000000000000000000000000000000000000001a` = 字符串错误提示的长度。

这相当于字符串错误提示 `Not enough Ether provided.`中的字符数，包括空格！(十六进制的 `0x1a` = 十进制的 `26`）。

- 0x4e6f7420656e6f7567682045746865722070726f76696465642e00000000` = utf8 十六进制编码的错误字符串。请参见下面的截图：

![solidity-错误字符串编码](https://img.learnblockchain.cn/2023/08/03/68221.png!lbclogo)

使用十六进制转 utf8 解码器从十六进制数据中获取字符串值。来源：https://onlineutf8tools.com/convert-hexadecimal-to-utf8

**注：** 注意长度和实际的 utf8 编码错误字符串都填充了 0 字节，因为在 EVM 存储器中，无论其类型如何，数据总是填充为 32 字节。

### require() 无错误提示

如果没有为 require() 提供错误提示，将创建一个**没有任何回退数据的错误（连 Error(string) 的 bytes4 错误选择器也没有）**。

正如我们所看到的，`require() `语句的错误提示是可选的，依旧可以进行 `require()` 检查，但不会在条件检查失败时传递任何错误信息。

使用之前的示例：

```
require(amount <= msg.value / 2 ether);
```

但是，如果不向 `require()` 提供 revert 原因字符串，将在**没有任何数据的情况下**回退。

让我们用一个基本代码示例来理解这一细节。

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract RequireExamples {

    function requireWithMessage(uint256 amount) public payable {
        require(
            amount <= msg.value / 2 ether,
            "Not enough Ether provided."
        );
        // ...
    }

    function requireWithoutMessage(uint256 amount) public payable {
        require(amount <= msg.value / 2 ether);
        // ...
    }

}
```

如果在 Remix 中使用无效参数运行下面这两个函数，首先会在 Remix 控制台中看看他们的不同之处。第一个函数会显示一条语句："Reason provided by the contract: ..."，而另一个则不会。

![solidity-错误  remix：无错误提示 vs 有错误提示](https://img.learnblockchain.cn/2023/08/03/8422.png!lbclogo)

现在让我们调试这两个交易，并在回退的地坊分析 EVM 内存。我们比较执行 `REVERT` 操作码时的内存内容。

我们可以从右侧看到，对于带有错误提示的 `require(, "...")` 来说，内存中包含 4 个字节 `0x08c379a0` ，对应于 `Error(string)` 哈希值的前 4 个字节。

相反，在没有错误提示的 `require()` 左边，我们可以看到内存是空的，不包含任何字节的数据。

![solidity-错误：无错误提示 vs 有错误提示](https://img.learnblockchain.cn/2023/08/03/31833.jpeg!lbclogo)

注意： 无数据的错误异常 与空字符串错误提示（=`Error(string)` 内的`string`为空）是不同的

这你是一些违反案例  [CWE-573](https://swcregistry.io/docs/SWC-123/) 。

## revert()

Solidity 内置函数 `revert() `可在智能合约中直接触发回退。它与 `require()` 类似，但可用于标记代码逻辑中某些部分的错误，而无需提供触发条件。

简而言之，Solidity 中的 `revert()` 语句明确告诉  EVM 停止执行。它强制 EVM 停止执行并返回错误。

在Solidity中使用`revert()`有三种可能的方法：

- 无解释性错误提示。
- 有解释性错误提示。
- 使用自定义错误还原

对应着三个语法形式：

```solidity
revert();
revert(string memory reason);
revert CustomError(arg1, arg2);
```

让我们首先关注有错误提示的 `revert`。了解 `revert()` 和 `revert("error message")` 之间的两个区别：

- 使用 `revert()` 会触发无错误数据的回退
- 使用 `revert("error message")` 会创建一个 `Error(string)` 类型的错误。

发生回退时，同样的：

- Gas 返回交易发起者
- 回滚所有的状态

在内部，EVM 使用 `REVERT` 操作码（指令 `0xfd` ）执行回退操作。

下面是 Solidity 文档中的一个示例，说明如何使用 `revert()` 代替 `require()` 。用于说明`if (!condition) revert(...);` 和 `require(condition, ...);` 是等价的:

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract VendingMachine {
    address owner;
    error Unauthorized();

    function buy(uint amount) public payable {
        if (amount > msg.value / 2 ether)
            revert("Not enough Ether provided.");

        // Alternative way to do it:
        require(
            amount <= msg.value / 2 ether,
            "Not enough Ether provided."
        );

        // Perform the purchase...
    }

    function withdraw() public {
        if (msg.sender != owner)
            revert Unauthorized();

        payable(msg.sender).transfer(address(this).balance);
    }

}
```

如果向 `revert("error message")`提供了错误提示，revert 将返回提示字符串，并以与上述 `require(...)` 相同的方式进行 abi 编码，即对 `Error(string)` 的 bytes4 选择器进行编码 + 对 `错误提示`进行 abi 编码。

同样，在所示示例中，以十六进制返回的错误数据具有相同的格式：

```
0x08c379a0                                                         // Function selector for Error(string)
0x0000000000000000000000000000000000000000000000000000000000000020 // Data offset
0x000000000000000000000000000000000000000000000000000000000000001a // String length
0x4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 // String data (utf8 encoded hex "Not enough Ether provided.")
```

> **注意：** 曾经有一个关键字叫 `throw`，其语义与 `revert()`相同，但在 0.4.13 版中已被弃用，并在 0.5.0 版中被删除。

### 汇编中执行回退

也可以在底层汇编中使用 `revert()`操作码。

汇编中的操作码将包含两个参数：

1. 还原时作为错误数据返回在内存中的 `offset` 参数。
2. 从 `offset`（第一个参数） 开始的错误数据字节数（`length` 或 `size`）。

![img](https://img.learnblockchain.cn/2023/08/03/2463.png)

> 来源：https://www.evm.codes/#fd?fork=merge

下面是 OpenZeppelin 流行的 `ERC721` 代码实现中的一个示例，在使用函数 `_checkOnERC721Received`时，在汇编中使用了 `revert` 操作码。

![img](https://img.learnblockchain.cn/2023/08/03/6791.png)

> 来源：https://github.com/OpenZeppelin/openzeppelin-contracts/blob/ca822213f2275a14c26167bd387ac3522da67fe9/contracts/token/ERC721/ERC721.sol#L399-L419

## 外部调用中的错误

当一个合约对另一个合约进行外部调用，而被调用的合约出现错误时，会撤销被调用合约（="调用者"）所做的所有更改。

如果被调用者出现错误，调用者就会收到错误提示。子调用（被调用者）中出现的任何异常都会自动 "冒泡"到调用者，异常会在调用者上下文中重新抛出。

下面举例说明，这里的术语指的是

- 源合约 = 发出外部调用的合约（= 调用方）
- 目标合约 = 接收外部调用的合约（=被调用者）

```solidity
contract SourceContract {

    string savedResponse;

    function pingMessage(TargetContract target) public {
        // test if accept can accept requests
        string memory result = target.ping();
        return result;
    }

}

contract TargetContract {

    function ping() public pure returns (string memory) {
        // return valid response to acknowledge that 
        // we can accept more incoming requests
        return "pong";
    }

}
```

这个简单的例子清楚地说明了发生的事情，在 `TargetContract` 上调用了 `ping()`函数获得相应的结果。但如果 `TargetContract`  回退了，会发生什么呢？

```solidity
contract SourceContract {

    string savedResponse;

    function pingMessage(TargetContract target) public {
        // test if accept can accept requests
        string memory result = target.ping();

        // 由于外部调用revert, 永远无法执行到这一行 
        return result;
    }

}

contract TargetContract {

    function ping() public pure returns (string memory) {
        // return valid response to acknowledge that 
        // we can accept more incoming requests
        revert("ping connection refused!");
    }

}
```

在此案例中，整个函数`pingMessage(...)` 调用都将回退，而函数的二行将永远不会到达。这个例子再次说明当外部调用失败，整个调用都会回退。

这种 "重新抛出错误" 的概念被称为 "错误冒泡"。

当外部调用发生错误时，错误数据会被转发回调用者。

错误数据可以是 `Error(string)`、`Panic(uint256)` 或自定义 `error` 类型的错误（如 `CustomError(...)`）。

以下情况会自动 "抛出"一个错误，如：

- 如果`.transfer()`失败（这种情况不太可能发生，因为`.transfer()`现在已不鼓励使用）。
- 通过消息调用调用函数，但函数由于以下原因没有正常执行：

  1. 函数耗尽了 Gas。

  2. 没有匹配的函数（调用了一个在合约中不存在的函数，而合约中没有 `fallback()` 或 `receive()` 函数作为回退处理程序）。

  3. 被调用的合约抛出了异常。

> 注意：例外情况包括 `send()` 和底层函数 `call()`、`delegatecall()` 和 `staticcall()` 。
>
> 这些[底层函数调用](https://decert.me/tutorial/solidity/solidity-adv/addr_call)从不抛出异常，默认情况下也不会 "抛出" 错误数据。
>
> 相反，它们会通过返回的第一个 `bool` 参数显示外部调用的成功或失败。

## 合约创建中的错误

不仅外部函数调用会在调用失败时自动向调用者返回错误。通过 `new` 创建合约时，如果合约创建没有正确完成，也会在调用者的上下文中自动抛出错误。

让我们看一个基本的代码片段：

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract SourceContract {
    function deployContract() public payable returns (address) {
        NewContract myNewContract = new NewContract(address(0));
        return address(myNewContract);
    }

}

contract NewContract {
    string contractName;

    constructor(address initialOwner) {
        require(initialOwner != address(0), "initialOwner cannot be the zero address");
        contractName = "my new contract";
    }
}
```



如果在 Remix 上部署此合约并运行 `deployContract()` 函数，你会发现交易会回退。这再次向我们表明，通过 `new` 创建合约会将错误抛回给调用者，从而使调用者的上下文自动回退。

![img](https://img.learnblockchain.cn/2023/08/03/80035.png)

## 如何从底层调用中产生错误

对于 Solidity 的底层调用，处理错误的方式有所不同。底层函数 `call()`、`staticcall()` 和 `delegatecall()` 返回两个值：

1. 描述外部调用成功或失败的 `bool` 值。
2. 一个 `bytes` 值，包含外部调用返回的数据。

✅ 如果调用成功 → `bool`返回值为`true`。

❌ 如果调用失败 → `bool` 返回值为`false`。

下面是 @OpenZeppelin 的 `Address.sol` 库中的一个示例。我们可以看到，底层的 `.call` 返回两个值可以元组的形式：`(bool success, bytes memory returnData)` 返回。

![img](https://img.learnblockchain.cn/2023/08/03/65723.png)

>  来源：https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f2346b6749546707af883e2c0acbc8a487e16ae4/contracts/utils/Address.sol#L122-L137

### ✅ 如果底层调用成功

如果 `bool success == true` ， 返回数据包含外部调用返回的数据。

例如，如果你通过底层的 `.call()` 调用另一个合约上的函数，通过对函数调用及其参数进行 abi 编码，`bytes result` 就是被调用函数返回的数据。

### ❌ 如果底层调用失败

如果 `bool success == false` ，这意味着被调用的合约（callee）引发了异常。异常可能包含错误数据，这些数据会以 error 实例的形式传回调用者。

返回数据字节包含被冒泡的错误。

字节的组成如下：

- 错误签名的前 4 个字节："Error(string) "或 "Panic(uint256) "或自定义`error `的选择器。
- 如果是自定义`error`，则是 abi 编码的参数；否则 abi 编码的返回信息 "字符串"。

对于 Solidity 底层调用，如何处理错误由调用者决定，例如：

- **选项1：**可以将收到的错误冒泡，并在调用者合约的上下文中再次冒泡相同的错误。
- **备选方案：**可以对冒泡的错误进行不同的处理。例如，我们可以决定不在调用者上下文中回退。例如 EIP1271 外部调用 `isValidSignature(bytes32,bytes)`就属于这种情况。

## 检查账户是否存在的边缘情况

在账户地址上进行底层调用前，应该先检查该合约账户是否存在，因为有一个中边缘情况，在不存在代码的地址调用函数，依旧会返回 `true` 。

对此，Solidity 文档有相应的说明：

![img](https://img.learnblockchain.cn/2023/08/03/34330.png)

> 来源：https://docs.soliditylang.org/en/v0.8.19/control-structures.html#error-handling-assert-require-revert-and-exceptions

如果我们仔细查看 EVM.codes，也会发现以下警告，注意我们注意边缘情况:

![img](https://img.learnblockchain.cn/2023/08/03/49736.png)

当在一个没有代码的地址上执行调用时， EVM 试图读取代码数据时，将返回默认值 0，该值与STOP 指令相对应，并停止执行。

## 算术运算错误

众所周知，Solidity 中的某些算术运算会出现溢出（上溢或下溢）。无论它们是否会导致错误回退，它们都是众所周知的安全漏洞和错误源。

因此，了解算术错误是怎样的以及在何种情况下处理算术错误非常重要。

自 Solidity 0.8.0 起，任何算术溢出都会导致错误代码为 `0x11` 的 `Panic(uint256)` 错误。

![img](https://img.learnblockchain.cn/2023/08/03/18049.png)

如果算术运算是在一个`unchecked` 代码块中进行的，则上溢/下溢将不会触发"Panic "错误，而是可能导致算术运算错误（如截断）。

## 位运算无溢出错误，总是截断

位运算是不会溢出的，而是总是截断处理，Solidity 文档有说明：

![img](https://img.learnblockchain.cn/2023/08/03/11345.jpeg)

截断可能会导致意想不到的行为。事实上，如果一个值位移过多（无论是左移还是右移），Solidity 不会抛出错误，而是会截断结果。

为了避免这种情况，请事先仔细查看你的 Solidity 代码，并确保位移值绝不会引起截断



在 Code4Rena 审计的 Juicebox V2 合约的上下文中发现了一个可能导致意外错误的例子：

![img](https://img.learnblockchain.cn/2023/08/03/7365.png)

>  来源：https://github.com/jbx-protocol/juice-contracts-v2-code4rena/blob/828bf2f3e719873daa08081cfa0d0a6deaa5ace5/contracts/JBFundingCycleStore.sol



## 使用 ecrecover 时出现的错误

函数 `ecrecover` 在失败时会返回 `0`（零地址）， 而不是触发错误：

![img](https://img.learnblockchain.cn/2023/08/03/2929.png)



你可以从 OpenZeppelin 的 `ECDSA` 库中看到这一点：

![img](https://img.learnblockchain.cn/2023/08/03/92492.png)

>  来源：[OpenZeppelin Github 代码库](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0457042d93d9dfd760dbaa06a4d2f1216fdbe297/contracts/utils/cryptography/ECDSA.sol#L151-L155)

## 参考资料

1. [Assert, Require, Revert](https://consensys.github.io/smart-contract-best-practices/development-recommendations/solidity-specific/assert-require-revert/#enforce-invariants-with-assert)

2. [表达式和控制结构]()

---

本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
