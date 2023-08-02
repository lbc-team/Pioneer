> * 原文链接： https://jeancvllr.medium.com/solidity-all-about-compiler-errors-314aad20a862
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 深入了解 Solidity 错误 #0 - 编译器错误

![img](https://img.learnblockchain.cn/2023/07/31/5833.jpeg)



从[上一篇我们开启了"深入Solidity 错误"系列， 继续更新。

现在，我们将详细介绍 Solidity 中的第一大类错误：与 Solidity 编译器有关的错误，称为 "编译时错误 "或 "编译器错误"。

Solidity 编译器 `solc` 在将 Solidity 代码编译成字节码时，会产生不同类型的错误。各种不同的错误原因都会导致编译器中止运行。



## 编译时错误简介

编译时错误（Compiler Errors），顾名思义，是指 Solidity 合约被 `solc` 编译器编译时发生的错误。

如果你的集成开发环境使用了某些插件（如 [*Solidity Visual Developer* for VS Code](https://marketplace.visualstudio.com/items?itemName=tintinweb.solidity-visual-auditor)），编译时错误会出现在集成了插件的开发环境（Remix、VS Code...）中，或者运行编译命令时出现在终端中。

当使用`solc`编译Solidity智能合约时，`solc`编译器会将`.sol`文件及其内容作为输入，生成输出：智能合约的EVM字节码。但在编译时，可能会错误。我们将这种类型的错误称为**编译时错误**。

Solidity 编译时错误可分为两大类：

- Solc CLI 命令错误
- 编译器错误

## Solc CLI 错误

这些错误与通过命令行使用 `solc` 编译器有关。

1. `JSONError`：JSON 输入不符合所需的格式，例如输入不是 JSON 对象、不支持语言等。

2. `IOError`：IO 和导入处理错误，如无法解决的 URL 或所提供源代码的哈希值不匹配等。

## 编译器错误

当 Solidity 代码被编译成可执行字节码时，就会出现这类编译时错误。

这包括无效语法、类型转换和不符合 Solidity 语法的声明等方面的错误。

以下是不同类型的 Solidity 编译器错误摘要

| 编译器错误                  | 描述                                                     |
| --------------------------- | -------------------------------------------------------- |
| `Warning`                   | 关于合约中可能发生的潜在错误或安全的警告                 |
| `ParserError`               | Solidity代码不符合Solidity语言规则                       |
| `DocstringParsingError`     | 无法解析 Natspec 注释或 Natspec 块                       |
| `SyntaxError`               | 无效的Solidity语法，例如在错误的位置使用内置关键字       |
| `DeclarationError`          | 无法解析为变量、函数或内置标志符                         |
| `TypeError`                 | 将值赋给变量或将变量赋给函数或返回参数时，类型无效       |
| `UnimplementedFeatureError` | 当使用Solidity编译器尚未支持但计划在将来支持的语法时出现 |



## `Warning` (警告)

有时你会使用 `solc` 编译合约，编译成功完成会生成合约字节码 + ABI。

不过，CLI 的输出会标出一些警告错误。这些警告通常以橙色显示，如下图所示。

让我们用一个常见的例子来说明 solc 编译器何时会生成警告：变量遮蔽。

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract MyToken {

    string private _name;
    string private _symbol;

    constructor(string memory _name, string memory _symbol) {
        // ...
    }

}
```

![solidity-编译器警告](https://img.learnblockchain.cn/2023/07/31/54138.png)

<p align="center"> 由 solc 编译器生成的警告会在终端或 Remix 中显示为橙色。</p>

在这段代码，参数变量被传递给了 `MyToken` 合约的 `constructor` ，与定义的状态变量有相同的名称 (称为 [变量遮蔽(variable shadowing)](https://en.wikipedia.org/wiki/Variable_shadowing) 。虽然 `solc` 编译器由于变量声明的范围（在构造函数内）会尝试解决这些赋值问题，但它仍然会感到困惑，并警告开发者可能发生了错误。是因为，由于状态变量与构造函数参数之间的命名冲突，可能会出现错误的赋值。

Solc 编译器器出现 `warning` 依旧允许你编译合约，但可能导致合约中的安全问题。

有多种情况会发生 `warning`， 包括：

- 遮蔽（变量或内置标志符）；
- 语句无效果；
- 无法到达的代码
- 函数定义了返回类型，但函数体内部没有明确的 `return` 语句。
- 函数状态可变性受到限制（例如：从没有修饰符到`view`或`pure`）。
- 未使用低级 `.call`、`.staticcall` 或 `.delegatecall`的返回值。

无法访问的代码通常是由于合约代码中的一条（或几条）语句永远不会被运行。它们就像`死代码 `。这是因为合约中的逻辑流要么提前`return`了， 要么在这条（这些）语句之前停止（`revert`或其他情况）。下面有一些示例。

关于函数的状态可变性，如果可以建议将其向下锁定为 `view` 或 `pure` 。尤其是内部函数。“向下锁定”可以确保这些函数不会对状态产生不必要的副作用，而只是负责**读取合约状态**或**执行纯计算**。

下面是一些`warnings` 示例：

```Solidity
// SPDX-License-Identifier: GPL-3.0  
pragma solidity ^ 0.8 .0;

contract Warnings {

  // all the lines below will return a warning  
  // ---  
  // Warning: This declaration shadows a builtin symbol.  

  string gasleft;
  uint tx;
  uint selfdestruct;

  // function keccak256() public pure;  

  function warningExample1() pure internal {
    // Warning: Statement has no effect.  
    5;
  }

  // Warning: Unnamed return variable can remain unassigned.  
  // Add an explicit return with value to all non-reverting code paths or
  name the variable.
  function warningExample2(uint _value) public pure returns(bool) {

    if (_value < 10) {
      revert();
      // Warning: Unreachable code.  
      _value = 12;
    }

  }

  uint256 a;

  // Warning: Function state mutability can be restricted to pure  
  function warningExample3() public {
    // Warning: Unused local variable.  
    uint256 a = 32;
  }

}
```

另一种需要牢记的重要`warnings`类型是 "未使用的低级调用的返回值（return value of low-level calls not used）"。

![solidity-编译器警告](https://img.learnblockchain.cn/2023/07/31/80149.png)

```Solidity
// SPDX-License-Identifier: GPL-3.0  
pragma solidity ^ 0.8 .0;

contract DeployedContract {
  uint public result = 0;

  function add(uint256 input) public {
    result = result + input;
  }
}

contract Proxy {

  address deployed_contract = 0x1212121212121212121212121212121212121212;

  function lowLevelCall(uint256 lucky_number) public {
    bytes memory _calldata = abi.encode(bytes4(keccak256("add(uint256)")),
      lucky_number);
    deployed_contract.call(_calldata);
  }

}
```



建议始终检查低级调用（如 `.call`、`.staticcall` 和 `.delegatecall`）的第一个 `bool` 类型的返回值。以确保外部调用是成功。

上面的函数 `lowLevelCall(uint256)` 可以修改为如下代码：

```solidity
function LowLevelCall(uint256 lucky_number) public { 
        bytes memory _calldata = abi.encode(bytes4(keccak256("add(uint256)")), lucky_number);
        (bool lowLevelCallSucceeded, ) = deployed_contract.call(_calldata);
    }
```

注意：我给这个 `bool` 参数起了一个很长的名字，目的是明确描述这个 `bool` 代表什么，以及低级调用函数的第一个返回值是什么。



编译器 `warnings` 并不会阻止 solc 编译器生成合约字节码。但是，**强烈建议重构你的 Solidity 代码，以处理和修复编译器警告**。

![solidity - 最佳实践](https://img.learnblockchain.cn/2023/07/31/64475.png)

<p  align=center>来源：https://ethereum.org/en/developers/docs/smart-contracts/security/</p>

## `Parser Error`(解析器错误)

当 Solidity 源代码不符合 Solidity 语言规则时，就会出现`Parser Error`（解析器错误）。

例如:

- 当一行没有以分冒号结束时
- 已声明变量，但未赋值（ 忘记了写`=`符号），且变量末尾无分号`;` )

下面是一些Solidity编译器在编译时产生 "ParseError "的例子：

![Solidity ParseError](https://img.learnblockchain.cn/2023/07/31/84540.png)

<p  align=center>Remix 中的解析器错误示例</p>

如果你注意观察 Parser Error，就会发现在函数 `example1()` 中，结尾的大括号 `}` 被高亮显示。这是因为 Solidity 编译器中的解析器希望在赋值 `42` 之后遇到分号来结束声明，但却遇到了 `}`。

![solidity-编译解析器错误](https://img.learnblockchain.cn/2023/07/31/2784.png)

同样的情况也适用于 `example2()` 。解析器希望遇到一个 `=` 符号或 `;`（结束变量声明），但却遇到了一个常量数字，因此无法解析 Solidity 代码。

![solidity-解析器错误](https://img.learnblockchain.cn/2023/07/31/39167.png)



## `Docstring Parsing Error` (文档解析错误)

当 Natspec 注释中的某些内容无效，导致编译器无法解析 Natspec 注释块时，就会出现 `DocstringParsingError` 错误。

下面是一个无法解析 Natspec 注释块的函数示例:

```Solidity
// SPDX-License-Identifier: GPL-3.0  
pragma solidity ^ 0.8 .0;


// `@param` 缺少 `requested` 参数
// ---  
// DocstringParsingError: Documented parameter "an" not found in the parameter list of the function.

/**  
 * @dev error when trying to transfer more `requested` amount than `available  
 * @param an amount in wei to be transfered  
 */
error InsufficientBalance(uint256 requested, uint256 available);



// `@param` 参数写成了 `request` 而不是 `requested`
// ---  
// DocstringParsingError: Documented parameter "request" not found in the parameter list of the function.

/**  
 * @dev error when trying to transfer more `requested` amount than `available  
 * @param request an amount in wei to be transfered  
 * @param available the amount of wei available in msg.sender's balance  
 */
error InsufficientBalance(uint256 requested, uint256 available);


// we are using a Natspec tag that does not exist (`@test`)  
// ---  
// DocstringParsingError: Documentation tag @test not valid for errors.  

/**  
 * @dev error when trying to transfer more `requested` amount than `available  
 * @param requested an amount in wei to be transfered  
 * @param available the amount of wei available in msg.sender's balance  
 * @test  
 */
error InsufficientBalance(uint256 requested, uint256 available);


// we are trying to use a Natspec tag that is valid but cannot be assigned to the definition type
  // (e.g: using the @title tag above `function`, using the @param tag above `contract`, ...
  // ---  
  // DocstringParsingError: Documentation tag @title not valid for errors.  

  /**  
   * @title  
   * @dev error when trying to transfer more `requested` amount than   `available  
   * @param requested an amount in wei to be transfered  
   * @param available the amount of wei available in msg.sender's balance  
   */
  error InsufficientBalance(uint256 requested, uint256 available);
```

与 Natspec 有关的错误类型一般会在以下情况下出现：

- 当 @param 标记不包含函数参数的名称或名称无效时。
- 尝试使用不存在的 Natspec 标记（例如：`@test`）。
- 当尝试使用的 Natspec 标签无法用于指定的特定定义时（例如：在 `function` 上使用 `@title` 标签，而 `@title` 标签只能用于 `contract` 以上的文档定义）。

然而，文档解析错误可能很难调试，因为报告的错误并不指向 Natspec 代码块中的特定位置，而是指向注释代码块的开头。请看下面的截图：

![solidity-文档解析错误](https://img.learnblockchain.cn/2023/07/31/33937.png)

<p  align=center>-DocstringParsingError 可能需要调试才能修复和调试-</p >



## SyntaxError(语法错误)

语法错误（SyntaxError）：当 Solidity 语法无效时发生。

下面是一些 `SyntaxError` 的例子：

- 在循环块外声明变量。
- 在`for`、`while`或`do while`循环之外使用`break`或`continue`。
- 定义空的 `struct` 结构体
- 当下划线 `_` 被错误地用作数字文字的分隔符时。
- 当 `modifier` 的主体不包括函数主体占位符 `_;`时。

```solidity
pragma solidity ^0.8.0;

contract SyntaxError {

    // SyntaxError: Invalid use of underscores in number literal. 
    // Only one consecutive underscores between digits allowed.
    uint256 constant bitcoin_supply = 21_000__000;

    // SyntaxError: Defining empty structs is disallowed.
    struct Unknown {
    }

    // SyntaxError: Modifier body does not contain '_'.
    modifier FeeToPay {
        require (msg.value != 0);
    }

    uint a = 3;
    uint b = 2;

    function test(uint x) public {
        if ( x < a && x > b) {
            bool result = true;
            continue;
        }
    }
}
```

## `Declaration Error`（声明错误)

`DeclarationError`：当编译器发现无效标识符（如不存在的变量或写错了内置标志符），就会发生这种情况。

`DeclarationError` 包括：

- 不正确的合约或变量名。
- 不可能继承（`继承图不可线性化`）。
- 在同一合约中声明了两个构造函数。

通常情况下，当出现 "DeclarationError"（声明错误）时，Solidity 编译器会很聪明地提示你该如何纠正。

例如，下面的代码片段会生成一个 `DeclarationError`，并建议将拼写错误 `requore` 更正为 `require`。

```solidity
// SPDC-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

contract DeclarationErrors {
    
    address owner;
    
    modifier isOwner {
        // DeclarationError: Undeclared identifier. Did you mean "require"?
        requore(owner == msg.sender);
        _;
    }
}
```

## `TypeError` 类型错误

注意：发生 `TypeError` 的情况非常非常多。无法在本文中一一列出。有关 TypeErrors 的一般列表，请参见 → [solidity-debugger.io](https://solidity-debugger.io/)


> 注意，此列表中的错误来自旧版本的 Solidity 编译器，新版本的 Solidity 存在更多错误情况。

类型错误是编写 Solidity 代码时最常见的错误类型之一。

当类型系统出现错误时，它们就会发生。这包括无效的类型转换和从一种类型到另一种类型的赋值。

类型错误的例子包括：

- 类型转换。
- 不正确的可见性（例如：在 librairies 中）。
- 没有将未实现所有函数（某些函数类似于 "接口"函数）的合约标记为抽象合约。
- 某些复杂类型的变量（结构体、映射、数组等......）未指定  `storage`、`memory`或 `calldata`等数据位置。

- 将一个不可支付的地址明确转换为一个具有可支付的 `fallback` 或 `receive` 函数（以便可以接收以太）的合约时，例如：



```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract TypeErrors {
    
    // TypeError: Explicit type conversion not allowed from non-payable "address" to "contract C", 
    // which has a payable fallback function.
    // Note: Did you mean to declare this variable as "address payable"?
    function f() public pure returns (C c) {
        address a = 0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326;
        c = C(a);
    }
    function notPossibleToEncode() public pure returns (bytes memory) {
        // TypeError: Type too large for memory.
        uint256[134_217_728] memory large_array;
        return abi.encode(large_array); 
    }
  
}

contract C {
    modifier Fee {
        require (msg.value != 0);
    }
    fallback() external payable {
        // some code here
    }
}
```

发生 `TypeError` 的情况非常多， 无法一一列出。

## `Unimplemented Feature Error` 功能未实现错误

当 Solidity 代码中包含与 Solidity 尚未实现和支持的功能时，solc 编译器将返回 `UnimplementedFeatureError` 错误。

然而，正如其名称所示，它有望在未来的版本中得到支持。让我们来看一个实际例子。

![solidity - UnimplementedFeatureError](https://img.learnblockchain.cn/pics/20230801094424.png)

在Solidity中，有一项功能目前还不可用，那就是将整个 `struct`数组 **从** `memory` **复制到** `storage`。也就是说，如果你在 `storage` 中有一个结构数组变量，你就不能在内存中构建它，并将它一次性复制到合约存储空间中。

```Solidity
// SPDX-License-Identifier: GPL-3.0  
pragma solidity ^ 0.8 .0;

contract UnimplementedFeatureError {

  struct Vote {
    uint256 optionId;
    string value;
  }

  Vote[] myVotes;

  function submitVoteNotWorking() public {
    Vote[] memory newVote = new Vote[](1);
    newVote[0] = Vote(1, "test");
    myVotes = newVote;
  }

  // UnimplementedFeatureError: Copying of  
  // type struct UnimplementedFeatureError.Vote memory[] memory to storage not yet supported.

  function working1() public {
    Vote memory newVote = Vote(1, "test");
    myVote[0] = newVote;
  }

  function working2() public {
    Vote memory newVote = Vote(1, "test");
    myVote.push(newVote);
  }

}
```

不能在内存中定义整个结构体数组，然后尝试在存储空间中一次性移动所有结构体... ❌

本例的解决方法是：

在内存中一次创建一个结构体，然后一次一个地将其移动到存储中数组的索引中！✅



关于 `UnimplementedFeatureError`，需要注意的一点是，编译器不会将你指向编译失败和发生错误的那一行（与其他错误不同）。无论是通过 Remix 还是通过 `solc` CLI。

从下面 Remix 的截图中可以看到，只显示了错误， 行号旁边没有红色错误指示。

![img](https://img.learnblockchain.cn/2023/07/31/93355.png)

## `Crash Errors`(崩溃错误)

在某些情况下，如果遇到以下错误，应在 Solidity 编译器的 Github repo 中报告一个 Issue。

- `InternalCompilerError`：编译器触发的内部错误 -- 应作为 Issue 反馈。
- `Exception`：编译过程中出现未知故障  -- 应作为 Issue 反馈。
- `CompilerError`: 与编译器堆栈、无效的设置或配置有关。这包括臭名昭著的 "堆栈过深 "错误，它给许多开发人员带来了很多问题。

下面是从 C++ 源代码中提取的一些示例，以说明在哪些情况下，`solc` 编译器会抛出`CompilerError`(编译器错误)：

![img](https://img.learnblockchain.cn/2023/07/31/44932.png)

> Solidity 编译器的 C++ 源代码中的编译器错误示例 [来源](https://github.com/ethereum/solidity/blob/eb2f874eac0aa871236bf5ff04b7937c49809c33/libsolidity/interface/CompilerStack.cpp)

- `FatalError`：未正确处理的致命错误 - 应作为 Issue 反馈。
- `YulException`：在 Yul 代码生成过程中出错 -- 应作为 Issue 反馈。
- 定义为`FatalError`的错误与其他错误的区别在于，解析器会在遇到致命错误时停止解析后面的任何代码。然后它将抛出并中止。
- 请参阅 Solidity 编译器 C++ 源代码中的以下注释：

![img](https://img.learnblockchain.cn/2023/07/31/71959.png)

> [源代码：ReferencesResolver.h 第 64 行](https://github.com/ethereum/solidity/blob/7dd6d404815651b2341ecae220709a88aaed4038/libsolidity/analysis/ReferencesResolver.h#L64)

---

本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
