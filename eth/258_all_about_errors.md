> * 原文链接： https://betterprogramming.pub/solidity-all-about-errors-cb831ad0b840
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/6223)

#  深入了解 Solidity 错误 #0



![img](https://img.learnblockchain.cn/2023/07/28/28671.jpeg)

> 由 [Zach Vessels](https://unsplash.com/@zvessels55) 在 [Unsplash](https://unsplash.com/) 上拍摄

今天的文章是 "深入 Solidity "系列文章中的一个新子系列，主要讨论 Solidity 和基于 EVM 的执行环境中的错误。



在智能合约领域，错误是非常致命的。如果没处理好，会导致错误和漏洞。如果处理错误，则会导致智能合约卡死和无法使用。

在直接进入 Solidity 之前，我们先来了解一下 EVM 在发生糟糕或错误的事情时是如何处理的，以及 EVM 内置了哪些不同类型的错误。

> "如果说调试是清除软件错误的过程，那么编程一定是把错误放进去的过程" - Edsger W. Dijkstra 



本文将介绍：

- 程序计数器
- EVM 错误和停止异常
- 错误类型（编译时错误与运行时错误）
- 编译时错误
- 合约运行时错误
- EVM 异常停止
    - Gas 耗尽
    - Stack Under/OverFlow
    - Invalid JUMP 目标
    - 错误指令



## 程序计数器

EVM 运行智能合约字节码时，会使用程序计数器 (PC) 一个接一个地运行每个操作码。

程序计数器（PC）编码了 EVM 下一步应读取（并运行）的指令（存储在合约代码中）。每执行一条指令后，程序计数器（PC）都会递增一个字节（"PUSHN "指令和 "JUMP"/"JUMPI "指令除外，在这些指令中，程序计数器（PC）会被修改为字节码中的 "JUMPDEST" 目标）。

把 EVM 想象成路上的司机。当司机遇到一些带有方向、信号和限制的交通标志时，他知道下一步该做什么或不做什么。

只要 PC 遇到有效的操作码，EVM 就会继续在合约的当前执行环境中运行操作码。

但有些操作码可以指示停止执行。当执行停止时，我们称之为 EVM **halts（见黄皮书）**。

但执行可以成功的停止，也可以出错的停止。如果执行成功停止，区块链的状态就会更新。否则，任何状态变化都会被还原，交易也不会在区块链上记录。这是由于以太坊的原子性。交易要么完全完成，要么根本没有做。不存在*"部分完成 "*的概念。

当程序计数器运行到以下两个操作码之一时，EVM 将停止执行并成功退出：

- `STOP`（操作码 `0x00` ）：成功退出执行。
- `RETURN`（操作码 `0xf3`）：成功离开当前[上下文](https://www.evm.codes/about)+从内存中返回一些数据（=从内存中指定位置偏移开始的特定字节数）。

相反，当程序计数器运行到以下两个操作码之一时，EVM 将停止执行并错误退出：

- `REVERT`：还原所有状态变化。一些数据（在内存中指定）和剩余Gas将返回给调用者。
- `INVALID`：这是 EVM 指定的无效指令。所有状态变化被还原，所有剩余Gas被消耗。调用者不会得到任何Gas返还。

## EVM 错误和异常停止

当 EVM 遇到错误时，运行时停止执行，导致 EVM 回退对状态所做的所有更改。

对于 EVM 来说，如果预期效果没有发生（或发生了意外效果），默认情况下没有安全的方法来继续执行。回退可保持交易的原子性。如 Solidity 文档所述：

> 最安全的操作是还原所有更改，并使整个交易（或至少调用）没有影响

如上一节所示，当程序计数器遇到操作码 "REVERT" 或 "INVALID"时，就会发生错误。但实际上，这些并不是唯一的情况！在 EVM 执行环境中，其他因素也可能导致错误。

我们将在接下来的章节中看到，根据黄皮书，实际上有两种类型的停止操作：

- **异常**停止错误。
- **正常**停止错误。

在黄皮书中被称为*"异常/正常停止状态 "*。

![img](https://img.learnblockchain.cn/2023/07/28/37836.png)

>  正常与异常停止状态错误（来源：以太坊黄皮书）

## 错误类型（编译错误与运行时错误）

在 Solidity 中编写智能合约时，会遇到三大类错误。

- 编译时错误（由 Solidity 编译器生成）
- 运行时错误（由 EVM 与智能合约字节码交互时产生）
- 异常停止错误（由 EVM 的堆栈处理器引起）

运行时错误在 Remix 中被定义为与已部署合约交互时的 "VM 错误"（VM 是 "虚拟机 "的缩写，此处指 EVM）。

![img](https://img.learnblockchain.cn/2023/07/28/77134.png)

> Remix IDE 中显示的 VM 错误



下面是在 Hardhat 中运行测试时出现虚拟机错误的另一个示例。请注意，如果是部署或交互脚本，Hardhat 也会返回相同类型的错误。

![img](https://img.learnblockchain.cn/2023/07/28/66718.png)

> Hardhat 返回的虚拟机错误

## 编译时错误

编译时间错误存在于把智能合约编程语言编写的某些代码编译成 EVM 可执行代码（= EVM 字节码）时。

这些错误包括编译器生成的错误，如

- `solc`（Solidity 编译器）
- [Vyper 编译器](https://docs.vyperlang.org/en/stable/compiling-a-contract.html#compiling-a-contract)
- Yul
- Huff
- [Fe](https://github.com/ethereum/fe) 和 [Fe 编译器](https://github.com/ethereum/fe/blob/master/docs/src/development/build.md)

## 合约运行时错误

运行时错误是一种发生在代码（部署在测试网络或主网上的智能合约）执行中的错误。

"运行时错误"这一名称源于这些错误是在与智能合约交互时发生的。

在调用智能合约并与之交互时，可能会出现 "出错"的情况，智能合约的字节码会用指令revert。

运行时错误就是我们所说的**"状态回退异常"**。也就是说，它们会撤销当前合约调用和交易期间对合约所做的所有状态更改。

智能合约运行时错误可以通过区块链浏览器查看失败的交易，从而进行探索和调试。

下面是一个例子，EOA [tippy.eth](https://etherscan.io/address/0xf42a339f93c1fa4c5d9ace33db308a504e7b0bde) (= 这个 ENS 名称背后的地址) 试图通过与 [1inch v3 Aggregation Router 合约](https://etherscan.io/address/0x11111112542d85b3ef69ae05771c2dccff4faa26) 交互来进行代币兑换，但是出了问题，在调用函数 `swap(address,...,bytes)` 时，交易还原了。

我们可以从这张截图中看到出错的细节：

- 在 `To` 地址（1inch 合约的地址）下，我们可以看到红色信息：`警告！合约执行过程中遇到错误 [已还原](Warning! Error encountered during contract execution [Reverted])`。这说明在智能合约层面发生了错误。
- 在顶部的 `Status `字段旁边，我们可以看到智能合约返回的错误信息：`Fail with error "callBytes failed：Error(ORDER_UNFILLABLE))`。

![运行时 Solidity 智能合约错误：以 Etherscan 上的 1inch v3 Aggregator 合约为例](https://img.learnblockchain.cn/2023/07/28/40196.png)

> Solidity 运行时错误 - 使用 1inch v3 聚合路由器的示例 ([错误来源](https://etherscan.io/tx/0x4a047e6fa06371c3a6a861936ee499e53e3847a39443950138a4743edf33801e))

## EVM 异常停止

![img](https://img.learnblockchain.cn/2023/07/28/47222.png)

> 注意：目前还没有准确的术语来描述这类错误。在以太坊黄皮书中，它们被称为 "异常停止状态"。请参阅上文 "EVM & Halting Exceptions "部分的结尾。

还有一类运行时错误，我将其专门称为 "EVM 异常停止"错误。当 EVM 的堆栈状态机出问题时，就会出现这些错误。

上述合约运行时错误的发生是智能合约编码确定的的，而堆栈状态机错误则是直接与 EVM 以及以太坊虚拟机如何运行和处理指令有关。

EVM 是一个堆栈状态机，使用基于堆栈的处理器来运行操作码指令。

在某些情况下，EVM 可能会遇到无法运行智能合约字节码的情况。这包括

- Out-Of-Gas
- 堆栈溢出
- 无效跳转目标
- 错误指令

### Gas 耗尽

当 EVM 运行一个合约的字节码时，开始时会提供一定量的 Gas。这与在区块链上提交交易时提供的Gas Limit 相对应。

下面是一个来自 etherscan 的运行时错误示例。

EOA 地址 `superphiz.eth` 尝试与 Stoner Cats 代币合约交互，但没有提供足够的Gas来完成整个交易。

交易显示：`Fail `状态，下面的错误信息写着： `警告！合约执行过程中遇到错误 [Gas耗尽]（Warning! Error encountered during contract execution [out of gas]”）`。

![来自 Etherscan 的Gas耗尽错误示例）](https://img.learnblockchain.cn/2023/07/28/72098.png)

> Gas 耗尽错误 - 示例来自 Etherscan ([错误](https://etherscan.io/tx/0x3fa19306a5dfc227537fdaf90b6883104dd0458cf9fbe3410a3254e5ca0e3618)来源)

### 堆栈溢出

在正式链上合约中，这些错误很少发生，因为 solidity 编译器编译字节码时会仅仅检查来避免出现此类错误。



不过，为了演示和了解 EVM 如何以特殊方式停止，可以手动重新创建这些错误。

让我们使用[Nethermind](https://medium.com/u/f219ea92bc61?source=post_page-----cb831ad0b840--------------------------------) [EVM 工作坊](https://github.com/NethermindEth/workshop/blob/master/docs/source/tasks.rst) + EVM.codes 游戏场中的一些练习任务来实验和重现这些错误。



#### 堆栈下溢

![img](https://img.learnblockchain.cn/2023/07/28/24351.png)

> 来自 Nethermind 研讨会的任务 nb10（[来源](https://github.com/NethermindEth/workshop/blob/master/docs/source/tasks.rst)）

![img](https://img.learnblockchain.cn/2023/07/28/92928.png)

**堆栈溢出**

![img](https://img.learnblockchain.cn/2023/07/28/62191.png)

来自 Nethermind 工作室的任务 nb10（来源：https://github.com/NethermindEth/workshop/blob/master/docs/source/tasks.rst）

![Solidity 堆栈溢出](https://img.learnblockchain.cn/2023/07/28/72564.png)

### 无效跳转目标

当 `JUMP` 使用的参数不指向合约字节码中的任何地方时，就会出现这种情况。程序计数器（PC）无法在合约字节码中找到要跳转的指令编号。

![img](https://img.learnblockchain.cn/2023/07/28/57086.png)

### 错误指令

> 注意：不要将其与 `INVALID` 操作码 `0xfe` 混淆。

当 EVM 遇到无法识别的十六进制操作码时，就会发生”错误指令“错误。意思是不属于以太坊虚拟机指令集的操作码。

如果我们查看[ethvm.io](https://ethervm.io/)中的 EVM 指令集完整表，我们可以看到每个 16 进制范围中的一些十六进制值没有与之相关的操作码。

例如，如果程序计数器运行到十六进制操作码 "0x21"，EVM 就会产生 "错误指令（bad instruction）"错误。由于该十六进制值与指令集中的任何有效指令都不相关（见下图红色圆圈），因此 EVM 除了停止执行并抛出**"错误指令 "**错误外，别无选择。

![img](https://img.learnblockchain.cn/2023/07/28/89590.png)

> 注意：这个错误在 evm.codes 中无法重现，因为 playground 会将错误的十六进制字节码指令转换为 `INVALID` 操作码。请看下面的截图。

![img](https://img.learnblockchain.cn/2023/07/28/43777.png)

>  ”错误指令“  不能在 evm.codes 中复现。它们会自动转换为 `INVALID` 操作码。



## 参考

https://eattheblocks.com/how-error-propagate-between-contracts-in-solidity/

https://docs.soliditylang.org/en/v0.8.19/control-structures.html#assert-and-require

https://github.com/ethereum/EIPs/issues/838

https://medium.com/coinmonks/solidity-fundamentals-a95bb6c8ba2a

[学习 Solidity 第 26 课. 错误处理.](https://medium.com/coinmonks/learn-solidity-lesson-26-error-handling-ccf350bc9374)

https://news.ycombinator.com/item?id=14851610

[在非 视图/纯函数上使用`staticcall`时耗Gas大](https://ethereum.stackexchange.com/questions/96547/high-gas-consumption-when-using-staticcall-on-a-non-view-pure-function)

[Solidity 中的自定义错误](https://blog.soliditylang.org/2021/04/21/custom-errors/)

---

本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。

