> * 原文链接： https://jeancvllr.medium.com/solidity-all-about-runtime-errors-57f22e8d6046
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 深入理解 Solidity 错误 #2 - 运行时错误





![img](https://img.learnblockchain.cn/2023/07/28/9444.jpeg)



在上一篇介绍了[编译时错误（由 Solidity 编译器生成的错误）](https://learnblockchain.cn/article/6242)之后，我们将在本文介绍运行时错误（与链上的合约交互时发生的错误）。

我们将看到，Solidity 可以生成 4 种主要类型的错误：`Error(string)`、`Panic(uint256)`、自定义 `error` 和  `invalid`。本文将介绍每种错误的规则和语义。最后，我们将预测一下可能添加到 Solidity 编程语言中的新错误类型。



本文内容有：
- Solidity 中的常见错误示例
- Solidity 错误类型
- Error(string) 
- Panic(uint256)
    -  Panic Error - 示例
    - Panic(uint256)  恐慌错误码
- 自定义错误（Custom Errors）
    - 如何定义自定义错误？
    - 为什么使用自定义错误而不是字符串错误？
    - 自定义错误的命名参数
    - 自定义错误的 Natspec 注释
    - 自定义错误是 ABI 的一部分
- Invalid 
- Solidity 中的未来错误类型



## 常见的错误示例

在许多情况下， Solidity 合约代码都可能出现运行时错误。

与 Solidity 相关的一些标准运行时错误包括：

- 当调用`require()`时，参数结果为false。
- 使用 `new` 关键字创建合约失败，且进程无法正常结束。
- 将无代码（`address.code.length`）合约指向外部函数时。(当通过 `constructor` 运行时，请注意 `isContract()` 失效）。
- 在调用公共 getter (`view`)或`pure`方法时发送 ethers (使用 `msg.value`)。
- 向合约中未标记为 `payable` 的函数发送以太币 (即 `msg.value`) 时。
- 当 `assert()` 中的条件为 `false` 时。
- 调用 `function` 类型的零初始化变量时。
- 当一个很大值或负值被转换为一个 `enum` 时。
- 以过大或负值的索引访问数组时。

然而，我们会发现，在这份情况列表中，每种情况都属于特定的错误类别，取决于错误的原因。

## Solidity 错误类型

- `Error(string)` → 通过内置函数 `require` 和 `revert` 触发。
- `Panic(uint256)` → 通过内置函数 `assert` 触发，或在某些情况下由编译器创建。
- 自定义 `error` → 通过 `revert CustomError()` 触发。
- `invalid`操作码 → 通过汇编触发。

*示例 1:*

`Error(string)`的`keccak256`哈希值为 0x**08c379a0**afcc32b1a39302f7cb8073359698411ab5fd6e3edb2c02c0b5fba8aa。

如果保留前 4 个字节，我们将得到 `Error(string)` 错误选择器为 `0x08c379a0` 。

*示例 2:*

`Panic(uint256)` 的 `keccak256` 哈希值是 0x**4e487b71**539e0164c9d29506cc725e49342bcac15e0927282bf30fedfe1c7268 。

如果保留前 4 个字节，我们将得到`Panic(uint256)` 错误选择器 `0x4e487b71`  。

下表总结了 Solidity 中不同类型的错误:

| 错误类型      | 错误签名         | `bytes4` 错误选择器                  |
| ------------- | ---------------- | ------------------------------------ |
| String Error  | `Error(string)`  | `0x08c379a0`                         |
| Panic         | `Panic(uint256)` | `0x4e487b71`                         |
| Custom Errors | 用户错误自定义   | 基于自定义错误的名称 及 参数（若有） |
| Invalid       | 无               | 无                                   |



让我们看看 Solidity 代码示例，以便更好地理解

```Solidity
pragma solidity ^ 0.8 .0;

contract SolidityErrors {

  error InsufficientBalance(
    uint256 amount,
    uint256 balance
  );

  function testRevertErrorEmpty()
  public
  pure {
    revert();
  }

  function testRevertError()
  public
  pure {
    revert("something went wrong!");
  }

  function testPanicError(uint256 a)
  public
  pure
  returns(uint256) {
    return 10 / a;
  }

  function testCustomError(uint256 amount)
  public
  view {
    revert InsufficientBalance(
      amount,
      address(this).balance
    );
  }

  function testInvalid()
  public
  pure {
    assembly {
      invalid()
    }
  }
}
```

如果我们在 Remix 中调试交易，就会发现在操作码 `REVERT` 之前，有一个 4 字节的值被推入堆栈。这 4 个字节的值对应于正在抛出的错误类型的选择器。

![Solidity - 错误类型](https://img.learnblockchain.cn/pics/20230802114634.jpeg!lbclogo)

<p align=center>在 Remix 中调试以找到每种 Solidity 错误类型的选择器 </p>

## Error(string)

内置错误 `Error(string)` 用于 "回退并提示错误信息"。

在下列情况下会出现 `Error(string)` 异常（在参数 `string` 中提供了错误信息）：

1. 调用 `require(x, "error message")`，其中 `x` 值为 `false` ，并且你提供了一条 `error message` 。

2. 使用 `revert()` 或 `revert("description")` 时。

3. 如果你执行外部函数调用，而调用的目标是不包含相应的代码。

4. 如果你的合约通过公共函数（包括构造函数和回退函数）接收以太，而该公共函数未包含`payable`修饰符。

5. 如果你的合约通过公共 getter 函数接收以太币。

所提供的 `string` 会以调用函数 `Error(string)` 的方式进行 abi 编码。

## Panic(uint256)

当涉及到 Solidity 中的 `Panic(uint256)` 类型错误时，有一条唯一的规则需要牢记：

**`Panic(uint256)` 错误不应出现在无错误的代码中**。

如果你在开发和测试 Solidity 合约时遇到 `Panic` 类型的错误： **你应该修复你的代码！ **

已经部署在网络上的智能合约在运行时出现 "Panic" 错误，很可能是智能合约代码中的一个错误，或者是智能合约的设计要求没有被完全满足或正确。

在此案例中，必须修复 Solidity 代码中的错误，这样智能合约就不会在运行时再次出现同样的 "Panic" 错误。

[Solidity](https://learnblockchain.cn/docs/solidity/control-structures.html#assert-require-revert) 文档更强调了这一点：

> 正常运行的代码绝不会产生 "Panic"，即使是无效的外部输入也不会。
>
> 如果发生了这种情况，那么你的合约中就有一个错误，你应该修复它。

### Panic错误 - 示例

让我们来看一个真实世界的例子，看看 "Panic "错误是如何发生和修复的。请看下面的 Solidity 代码段。

```Solidity
// SPDX-License-Identifier: GPL-3.0  
pragma solidity ^0.8.0;

contract PanicErrorExample {

  function countTrailingZeroBytes(bytes32 data) public pure returns(uint256) {
    uint256 index = 31;

    // CHECK each bytes of the key, starting from the end (right to left)  
    // skip each empty bytes `0x00` to find the first non-empty byte  
    while (data[index] == 0x00) index--;

    return 32 - (index + 1);
  }

}
```

顾名思义，该函数用于计算`bytes32`数据值末尾的`0x00`零字节数。

例如，当提供下面的值作为 `data` 参数时，它将返回 `4` ：

```
data = 0xcafecafecafecafecafecafecafecafecafecafecafecafecafecafe00000000
result = 4
```

![img](https://img.learnblockchain.cn/2023/07/28/41478.png!lbclogo)

乍一看，这个函数似乎没有什么危害。如果输入的数据以一定数量的 `0x00` 结尾，我们可以肯定会得到一个结果。

但不要被这个函数所迷惑！这个函数和它的注释都在说谎！让我们再仔细看看。

```solidity
// CHECK each bytes of the key, starting from the end (right to left)
// 忽略 `0x00` 字节，直到找到一个非零字节 
while (data[index] == 0x00) index--;
```

虽然注释在代码中是个好东西，但不要被它迷惑了。事实上，第 2 行注释告诉了我们一个谎言。我们相信函数忽略 `0x00` 为零字节。**但相反，它只是在继续计数**。`while`循环可以用简单理解：

```solidity
// data 参数中 `index` 处的字节不是 0x00，继续将 index 减 1
while (data[index] == 0x00) index--;
```

这说明了什么？它告诉我们，我们从 `index = 31` 开始递减。但是，如果我们将下面的值作为 `data` 参数提供给函数，会发生什么呢？

```
data = 0x0000000000000000000000000000000000000000000000000000000000000000
result = 32?
```

我们应该期望结果是 `32`。但我们能得到这个结果吗？让我们试试看：

![img](https://img.learnblockchain.cn/2023/07/28/26021.png)



正如我们所说，上面的代码 一直在计数， 所以当 `index` 达到 `0` 时，如果试图用 `index--` 来递减，就会出现下溢，并产生错误代码为 `Panic` 的错误：`0x11`

一些语言分析工具可以用来分析Solidity源代码并捕捉这些`Panic`错误。此类工具包括:

- [Slither](https://github.com/crytic/slither)
- [MythX](https://mythx.io/)

## Panic(uint256) 错误码

`Panic(uint256)` 错误类型抛出的异常只有一个参数：代表十六进制错误代码的 `uint256` 数字。

下表列出并描述了每种错误码:

| 错误码（以 `uint256` 十六进制数字） | 说明|
| ------------------------------------ | ------------------------------------------------------------ |
| `0x00` | 通常编译器插入的Panic。           |
| `0x01` | 如果你在调用 `assert` 时，参数值为 `false`。|
| `0x11` | 如果一个算术运算结果在一个 `unchecked { ...}` 块溢出 |
| `0x12` | 如果除数为零或对 0取模（例如 `5 / 0 或 23 % 0`）。 |
| `0x21` | 如果你将过大的值或负值转换为枚举类型。 |
| `0x22` | 如果你访问编码错误的存储字节数组。 |
| `0x31` | 如果在一个空数组上调用 `.pop()`。                     |
| `0x32` | 如果以超出边界或负数索引（即 `x[i]` 而 `i >= x.length` 或 `i < 0` 时的 `x[i]` ）访问数组、`bytesN`或数组片段。|
| `0x41` | 如果分配的内存过多或创建的数组过大。|
| `0x51` | 如果调用内部函数类型的未初始化变量。 |



注意：在 Solidity 0.8.0 之前，`Panic(uint256) `异常使用`invalid`操作码，`invalid`会耗尽所有可用Gas。现在情况不再如此。从 Solidity 0.8.x 主版本开始，`Panic(uint256)`错误使用 `REVERT` 操作码。

> **注 2：** 如果你在一个开源项目（无论是否流行）的 Github 代码库中发现了 `Panic` 错误，你应该选择以下两种方法之一：
>
> 与开发团队取得联系，分享错误和重现错误的方法
>
> 或提交一个 PR，并附上描述和修复方法。
>
> 根据 Panic 错误的性质，它们可以成为 bug 赏金的来源！因此，你可以与开发团队进行交流，同时让协议代码更加健壮，对所有其他用户更加安全！

## 自定义错误

自[0.8.4版本的Solidity](https://github.com/ethereum/solidity/releases/tag/v0.8.4)起，开发者可以自定义错误。自定义错误可以提供操作失败的原因，它们将返回给函数的调用者。下面是一个基本示例：

```solidity
error InsufficientBalance(uint256 requested, uint256 available);

// Sends an amount of existing coins
// from any caller to an address
function send(address receiver, uint amount) public {
    if (amount > balances[msg.sender]) {
      revert InsufficientBalance(amount, balances[msg.sender]);
    }
    
    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    emit Sent(msg.sender, receiver, amount);
}
```

### 如何定义自定义错误？

自定义错误使用 `error` 语句定义，与定义 `event` 的方法相同。

它们可以在合约或文件级别定义：

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

error InsufficientBalance(uint256 requested, uint256 available);

contract CustomErrorExample {
    error NotAuthorised(address notAllowedCaller);
}
```

### 为什么使用自定义错误而不是Error(string)？

与回退原因字符串相比，自定义错误具有多种优势：

- 它们可以减少合约字节码的大小，从而降低智能合约的部署成本。
- 它们允许在回退消息中传递动态数据。

自定义错误通常比字符串错误信息（如 `require(condition, "error message")` 或 `revert("error message")`）便宜得多，而且会减少合约字节码的大小。

### 自定义错误的命名参数

向自定义错误传递命名参数的方式与传递函数和事件参数的方式相同。命名参数可以写成一个对象，错误参数可以任意顺序定义。

这有助于提高 Solidity 代码中回退时的可读性。通常情况下，自定义的 "error"定义在远离其使用位置的地方。这就需要找到错误的导入位置并查找参数。

请看下面的对比示例(我删除了顶部的 `error` 定义）。由于我们现在已将自定义错误的命名参数作为一个对象并进行了内联，因此自定义 `error` 在回退时提供了哪些信息就变得非常明显了。

```solidity
// Sends an amount of existing coins
// from any caller to an address
function send(address receiver, uint amount) public {
    if (amount > balances[msg.sender]) {
        revert InsufficientBalance({
            requested: amount,
            available: balances[msg.sender]
        });
    }
    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    emit Sent(msg.sender, receiver, amount);
}
```

目前，在 solc 0.8.19 之前，无法将自定义错误与 `require()` 结合使用。因此，要使用自定义错误，应使用带有`if`语句的语法，该语句的值为 false：

```solidity
if (!condition) revert CustomError();
```

### 用于自定义错误的 Natspec 注释

可以通过 NatSpec 注释对自定义错误进行更详细的描述。你可以使用 `@dev` 和 `@param` 标记来描述错误以及参数。

下面是 Seaport Solidity 代码库中的一个示例，其中自定义错误 `OrderAlreadyFilled` 并使用 Natspec 注释：

![img](https://img.learnblockchain.cn/2023/07/28/71431.png)

>  [来源](https://github.com/ProjectOpenSea/seaport/blob/4b2c048a52f99062176476c2e1b6068c07ca0ab8/contracts/interfaces/ConsiderationEventsAndErrors.sol#L78-L85)

使用文档生成工具，你可以通过解析 Natspec 注释为自定义错误生成文档。

### 自定义错误是 ABI 的一部分

需要注意的一点是，自定义错误是由 `solc` 编译器生成的合约 JSON ABI 的一部分。

下面是一个例子，[LUKSO](https://medium.com/u/2376b006b57f?source=post_page-----57f22e8d6046--------------------------------) 的 [lsp-smart-contracts.](https://github.com/lukso-network/lsp-smart-contracts)说明从 `solc` 编译器生成的 `LSP0ERC725Account` 的 JSON ABI。



![img](https://img.learnblockchain.cn/2023/07/28/19636.png)

>  [源文件：LUKSO lsp-smart-contracts repo on Github, file LSP0ERC725Account.sol](https://github.com/lukso-network/lsp-smart-contracts/blob/v0.8.1/contracts/LSP0ERC725Account/LSP0ERC725AccountCore.sol)

你可以使用 `.selector` 语法访问自定义错误的 bytes4 选择器，方法与访问函数的 bytes4 函数选择器相同。例如：`CustomError.selector`（自定义错误选择器

```solidity
// SPDC-License-Identifier: Apache-2.0
pragma solidity 0.8.4;

error CustomError();
error InsufficientFunds(uint256 balance);

contract CustomErrorsContract {
    
    function getCustomErrorSelector() public pure returns (bytes4) {
        return CustomError.selector;
    }
    function getInsufficientFundsErrorSelector() public pure returns (bytes4) {
        return InsufficientFunds.selector;
    }
    
}
```

但是，在内联汇编中无法访问自定义 `error` 的选择器。

从 Solidity v0.8.12 版起，你可以使用 `solc` 编译器选项 `--hashes`，列出自定义错误选择器

![img](https://img.learnblockchain.cn/2023/07/28/76620.png)

在 Github 上发布的 Solidity v0.8.12 版编译器有生成错误签名的功能（来源：https://github.com/ethereum/solidity/releases/tag/v0.8.12）

## Invalid

`Invalid`操作码（指令 "0xfe"）只能在内联汇编中使用。它在 Solidity 中不能作为内置函数使用。

与 Solidity 中的特殊函数 `require` 和 `revert` 不同的是，在汇编中，`invalid()` 操作码指令除了回退交易和所有状态变化外，还会消耗所有可用的剩余Gas。

![img](https://img.learnblockchain.cn/2023/07/28/12551.png)

要使用 `invalid` 操作码，必须在汇编块中使用，例如：

```solidity
function runInvalid() public {
    assembly {
        invalid()
    }
}
```

让我们来看一个通过内联汇编使用`invalid`的真实Solidity合约的例子。在 OpenZeppelin 合约库中有一个不为人知的合约：`MinimalForwarder`。

该合约提供了一个基本的转发函数 `execute(...)`，用于将函数调用转发到目标地址。

仔细观察第 67 行，你会发现 `invalid` 操作码是如何使用的。你还将看到第 62-65 行上方注释中的附加说明，强调它不会将剩余Gas返回给调用者，而是消耗掉所有Gas。

![img](https://img.learnblockchain.cn/2023/07/28/82777.png)

>  [来源：openzeppelin/contracts Github repo (v4.1.8), MinimalForwarder.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.2/contracts/metatx/MinimalForwarder.sol)

## Solidity 中未来的错误类型？



注：这些假设是基于撰写本文时（2023 年 3 月 22 日）Solidity Github 代码库中的当前研究。这些可能会改变。

在Solidity中，错误类型有两个潜在的未来发展方向。

- 为 `abi.encode` 和 `abi.decode` 中的某些编码/解码函数引入带有特定错误代码的 `Error(uint256)` 。
- 在 Solidity 的全局命名空间（未来的 `std` 库）中提供 `Panic` 和 `Error` 错误代码。

![img](https://img.learnblockchain.cn/2023/07/28/96072.png)

> 截图来源：https://github.com/ethereum/solidity/issues/13869#issuecomment-1423021751

你可以在 Github 代码库 Solidity 上的讨论问题中找到有关这些当前提案的更多详情。请参阅以下链接：

1. [考虑对某些revert进行编码](https://github.com/ethereum/solidity/issues/11664)

2. [无法使用 `try`/`catch` 捕获本地 revert](https://github.com/ethereum/solidity/issues/13869#issuecomment-1423021751)...

---


本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来 DeCert 码一个未来， 支持每一位开发者构建自己的可信履历。
