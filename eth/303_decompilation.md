# 深入研究智能合约反编译

![Heimdall Header](https://img.learnblockchain.cn/attachments/migrate/1705459602001)

Heimdall-rs 反编译模块是一个强大的工具，用于理解以太坊智能合约的内部工作原理。它允许用户将原始字节码转换为可读的 Solidity 代码及其对应的应用程序二进制接口（ABI）。在本文中，我们将深入研究反编译模块的内部工作原理，探讨它如何在低级别执行此转换，并探索其各种功能和能力。

请记住，本文讨论的是 heimdall-rs 如何执行反编译。这可能与其他反编译器的工作方式不同。如果你有任何建议或更正，请随时在 [GitHub](https://github.com/Jon-Becker/heimdall-rs) 上提出问题或提交PR，谢谢！

## 介绍

反编译是将机器码或字节码转换为更高级别、可读性更强的表示形式的过程。然而，由于以下几个原因，这并不是一项简单的任务：

- 机器码或字节码是设计用于计算机执行的，而不是供人类阅读的。因此，它可能含糊不清且难以解释。
- 字节码不包含有关变量和函数名称的信息，这使得难以理解代码的不同部分的目的。
- 字节码不包含原始源代码具有的所有信息，例如注释、变量和函数名称、类型等。
- 字节码不是源代码的线性表示，有多种原因，例如编译器优化，使得反编译更具挑战性。

为了使这个复杂、错综复杂的过程更容易理解，我将整个反编译过程分为四个主要步骤，我们将在接下来的章节中详细探讨这些步骤：

- **反汇编**：将字节码转换为其汇编表示的过程。
- **符号执行**：从反汇编代码生成类似分支的控制流图（CFG）的过程。
- **分支分析**：分析和将 CFG 转换为更高级别表示的过程。
- **后处理**：清理输出并使其更易读的过程。

## 反汇编

反编译过程的第一步是将字节码转换为更易读的汇编表示。这样做是为了让反编译器找到并分析智能合约整体结构的不同部分。

汇编是字节码的低级表示，其中每个指令由助记符及其对应的参数表示。每个指令大致分为 3 部分：

```
snippet.asm

<program_counter> <opcode> <arguments>
```

程序计数器是字节码中指令的索引。操作码是指令本身，参数是指令操作的值。有关以太坊操作码的高级信息，请查看 [EVM Codes](https://www.evm.codes/?fork=arrowGlacier)。

例如，来自*[0x1bf797219482a29013d804ad96d1c6f84fba4c45](https://etherscan.io/address/0x1bf797219482a29013d804ad96d1c6f84fba4c45)*的以下字节码：

```
// snippet.bin
731bf797219482a29013d804ad96d1c6f84fba4c45301460806040...9d5ef505ae7230ffc3d88c49ceeb7441e0029
```

将转换为以下汇编：

```
// snippet.asm
20 PUSH20 1bf797219482a29013d804ad96d1c6f84fba4c45
21 ADDRESS
22 EQ
24 PUSH1 80
26 PUSH1 40
27 MSTORE
29 PUSH1 04
30 CALLDATASIZE
31 LT
34 PUSH2 0058
35 JUMPI
37 PUSH1 00
38 CALLDATALOAD
...
```

## Solidity 调度器

Heimdall-rs 使用这些反汇编代码来搜索调度查找表中的`JUMPI`语句，该表用于确定正在调用的函数。在以太坊虚拟机（EVM）中，通过将函数选择器作为调用数据的前 4 个字节来调用函数。函数选择器是函数签名的 keccak256 哈希的前 4 个字节，函数签名是函数名称及其对应的参数。例如，函数签名`transfer(address,uint256)`将转换为函数选择器`0xa9059cbb`。

调度查找表是函数选择器到相应函数地址（作为程序计数器）的映射。它用于通过调用数据的前 4 个字节确定正在调用的函数。通常，使用`AND(PUSH4(0xFFFFFFFF), CALLDATALOAD(0))`来加载调用数据的前 4 个字节，然后将函数选择器与调度查找表中的函数选择器进行比较，以确定正在调用的函数。如果找到匹配项，则程序跳转到字节码中的相应位置。

例如，以下汇编显示了 WETH 合约*[0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2](https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)*的调度表的运行情况：

```
// snippet.asm

14 PUSH1 00
15 CALLDATALOAD
45 PUSH29 0100000000000000000000000000000000000000000000000000000000
46 SWAP1
47 DIV
52 PUSH4 ffffffff
53 AND
54 DUP1
59 PUSH4 06fdde03
60 EQ
63 PUSH2 00b9
64 JUMPI
65 DUP1
70 PUSH4 095ea7b3
71 EQ
74 PUSH2 0147
75 JUMPI
```

从中我们可以看到，`0x06fdde03` *（`name()`）*的函数选择器告诉 EVM 跳转到程序计数器`0xb9`，`0x095ea7b3` *（`approve(address,uint256)`）*的函数选择器告诉 EVM 跳转到程序计数器`0x147`。Heimdall-rs 的反编译模块通过搜索这个调度查找表来找到所有函数选择器及其在字节码中的对应位置，从而实现符号执行和分支分析步骤。

## 符号执行

反编译过程的第二步是从反汇编代码生成控制流图（CFG）。CFG 是表示程序控制流的有向图。图中的每个节点表示按顺序执行的一组指令。图中的每条边表示一个跳转或分支，即条件跳转到另一个基本块。CFG 用于表示程序的控制流，并用于确定程序可以采取的不同路径。

Heimdall-rs 通过在专门设计用于反编译和字节码分析的自定义 EVM 实现中执行字节码来生成此 CFG。每当 EVM 遇到`JUMPI`指令时，CFG 中就会创建一个新分支。为每个分支创建一个新的虚拟机，并执行程序直至终止。重复此过程，直到探索完所有分支，CFG 完成。

```rust
pub fn recursive_map(
    evm: &VM,
    handled_jumpdests: &mut Vec<String>,
    path: &mut String,
) -> VMTrace {
    let mut vm = evm.clone();

    // create a new VMTrace object
    let mut vm_trace = VMTrace {
        instruction: vm.instruction,
        operations: Vec::new(),
        children: Vec::new(),
        loop_detected: false,
        depth: 0,
    };

    // cap the number of branches to prevent infinite loops. Needs to be fixed in the future.
    if handled_jumpdests.len() >= 1000 { return vm_trace }

    // step through the bytecode until we find a JUMPI instruction
    while vm.bytecode.len() >= (vm.instruction * 2 + 2) as usize {
        let state = vm.step();
        vm_trace.operations.push(state.clone());

        // if we encounter a JUMPI, create children taking both paths and break
        if state.last_instruction.opcode == "57" {
            vm_trace.depth += 1;

            path.push_str(&format!("{}->{};", state.last_instruction.instruction, state.last_instruction.inputs[0]));

            // we need to create a trace for the path that wasn't taken.
            if state.last_instruction.inputs[1] == U256::from(0) {

                // break out of loops
                match LOOP_DETECTION_REGEX.is_match(&path) {
                    Ok(result) => {
                        if result {
                            vm_trace.loop_detected = true;
                            break;
                        }
                    }
                    Err(_) => {
                        return vm_trace
                    }
                }

                handled_jumpdests.push(format!("{}@{}", vm_trace.depth, state.last_instruction.instruction));

                // push a new vm trace to the children
                let mut trace_vm = vm.clone();
                trace_vm.instruction = state.last_instruction.inputs[0].as_u128() + 1;
                vm_trace.children.push(recursive_map(
                    &trace_vm,
                    handled_jumpdests,
                    &mut path.clone()
                ));

                // push the current path onto the stack
                vm_trace.children.push(recursive_map(
                    &vm.clone(),
                    handled_jumpdests,
                    &mut path.clone()
                ));
                break;
            } else {

                // break out of loops
                match LOOP_DETECTION_REGEX.is_match(&path) {
                    Ok(result) => {
                        if result {
                            vm_trace.loop_detected = true;
                            break;
                        }
                    }
                    Err(_) => {
                        return vm_trace
                    }
                }

                handled_jumpdests.push(format!("{}@{}", vm_trace.depth, state.last_instruction.instruction));

                // push a new vm trace to the children
                let mut trace_vm = vm.clone();
                trace_vm.instruction = state.last_instruction.instruction + 1;
                vm_trace.children.push(recursive_map(
                    &trace_vm,
                    handled_jumpdests,
                    &mut path.clone()
                ));

                // push the current path onto the stack
                vm_trace.children.push(recursive_map(
                    &vm.clone(),
                    handled_jumpdests,
                    &mut path.clone()
                ));
                break;
            }
        }

        if vm.exitcode != 255 || vm.returndata.len() > 0 {
            break;
        }
    }

    vm_trace
}
```

## 分支分析

生成 CFG 后，下一步是分析 CFG 的分支。这是真正的反编译开始的地方，开始从操作码翻译到 Solidity 。

### WrappedOpcode 结构

如前所述，反编译和符号执行由我的自定义 EVM 实现提供支持。该实现引入了`WrappedOpcodes`，它们本质上是带有附加信息的操作码。这些信息包括指令指针、输入和输出。这些信息用于生成 CFG，并用于生成反编译代码。

可以在 [heimdall-rs](https://github.com/Jon-Becker/heimdall-rs/blob/main/common/src/ether/evm/opcodes.rs#L163-L193) 的以下代码片段中看到此结构：

```rust
// snippet.rs

// enum allows for Wrapped Opcodes to contain both raw U256 and Opcodes as inputs
#[derive(Clone, Debug, PartialEq)]
pub enum WrappedInput {
    Raw(U256),
    Opcode(WrappedOpcode),
}

// represents an opcode with its direct inputs as WrappedInputs
#[derive(Clone, Debug, PartialEq)]
pub struct WrappedOpcode {
    pub opcode: Opcode,
    pub inputs: Vec<WrappedInput>,
}
```

VM 实现通过跟踪这些`WrappedOpcodes`来执行字节码。这允许将任何指令的每个输入和输出追溯到其来源。这对于反编译至关重要，因为它允许反编译器准确了解每个指令的操作以及其输入的来源，最终允许反编译器生成正确的 Solidity 代码。

```rust
[
    WrappedOpcode {
        opcode: Opcode {
            name: "SUB",
            mingas: 3,
            inputs: 2,
            outputs: 1,
        },
        inputs: [
            Opcode(
                WrappedOpcode {
                    opcode: Opcode {
                        name: "ADD",
                        mingas: 3,
                        inputs: 2,
                        outputs: 1,
                    },
                    inputs: [
                        Opcode(
                            WrappedOpcode {
                                opcode: Opcode {
                                    name: "PUSH1",
                                    mingas: 3,
                                    inputs: 0,
                                    outputs: 1,
                                },
                                inputs: [
                                    Raw(
                                        32,
                                    ),
                                ],
                            },
                        ),
                        Opcode(
                            WrappedOpcode {
                                opcode: Opcode {
                                    name: "MLOAD",
                                    mingas: 3,
                                    inputs: 1,
                                    outputs: 1,
                                },
                                inputs: [
                                    Opcode(
                                        WrappedOpcode {
                                            opcode: Opcode {
                                                name: "PUSH1",
                                                mingas: 3,
                                                inputs: 0,
                                                outputs: 1,
                                            },
                                            inputs: [
                                                Raw(
                                                    64,
                                                ),
                                            ],
                                        },
                                    ),
                                ],
                            },
                        ),
                    ],
                },
            ),
            Opcode(
                WrappedOpcode {
                    opcode: Opcode {
                        name: "SLOAD",
                        mingas: 3,
                        inputs: 1,
                        outputs: 1,
                    },
                    inputs: [
                        Opcode(
                            WrappedOpcode {
                                opcode: Opcode {
                                    name: "PUSH1",
                                    mingas: 3,
                                    inputs: 0,
                                    outputs: 1,
                                },
                                inputs: [
                                    Raw(
                                        1,
                                    ),
                                ],
                            },
                        ),
                    ],
                },
            ),
        ],
    },
]
```



### 包装操作码 转 Solidity

上面的`WrappedOpcode`基本上可以分解为

```
// snippet.rs

SUB(
    ADD(
        PUSH1(32),
        MLOAD(
            PUSH1(64)
        )
    ),
    SLOAD(
        PUSH1(1)
    )
)
```

这可以进一步简化为

```
//snippet.yul

SUB(ADD(32, MLOAD(64)), SLOAD(1))
```

并且可以表示为 solidity 中的

```solidity
// snippet.sol

(32 + memory[64]) - storage[1]
```

对`CFG`中的每个`WrappedOpcode`进行这种 solidifying（转换为 solidity）的过程是递归进行的。这允许反编译器为任何给定的合约生成 solidity 代码。

在 heimdall-rs 中，这个过程是在`WrappedOpcode`结构体的`solidify`函数中完成的。可以在以下代码片段中查看此函数，链接如下：[heimdall-rs](https://github.com/Jon-Becker/heimdall-rs/blob/8157fae82bcf3b16a74e8fcb7ed0e53a62f56001/common/src/ether/solidity.rs#L24)：

```rust
// snippet.rs

pub fn solidify(&self) -> String {
    let mut solidified_wrapped_opcode = String::new();

    match self.opcode.name.as_str() {
        "ADD" => {
            solidified_wrapped_opcode.push_str(
                format!(
                    "{} + {}",
                    self.inputs[0]._solidify(),
                    self.inputs[1]._solidify()
                ).as_str()
            );
        },
        "MUL" => {
            solidified_wrapped_opcode.push_str(
                format!(
                    "{} * {}",
                    self.inputs[0]._solidify(),
                    self.inputs[1]._solidify()
                ).as_str()
            );
        },
        "SUB" => {
            solidified_wrapped_opcode.push_str(
                format!(
                    "{} - {}",
                    self.inputs[0]._solidify(),
                    self.inputs[1]._solidify()
                ).as_str()
            );
        },
        ...
    }
}
```

## 分析 CFG 分支

`VMTrace`结构体的`analyze`函数用于对 CFG 分支进行分析。可以在以下代码片段中查看此函数，链接如下：[analyze.rs](https://github.com/Jon-Becker/heimdall-rs/blob/main/heimdall/src/decompile/analyze.rs#L1)。此函数迭代处理符号执行生成的`VMTrace`分支中的操作，并通过以下步骤执行大部分的反编译：

### 确定函数可见性

反编译器首先确定当前操作码是否会修改函数的可见性。在 solidity 中，`pure`函数不能通过以下操作码读取或写入状态：

```yul
snippet.yul

BALANCE, ORIGIN, CALLER, GASPRICE, EXTCODESIZE, EXTCODECOPY, BLOCKHASH, COINBASE, TIMESTAMP, NUMBER, DIFFICULTY, GASLIMIT, CHAINID, SELFBALANCE, BASEFEE, SLOAD, SSTORE, CREATE, SELFDESTRUCT, CALL, CALLCODE, DELEGATECALL, STATICCALL, CREATE2
```

如果当前操作码在这组修改状态的操作码中，`Function`结构体的`pure`属性将被设置为`false`。

同样，`view`函数不能通过以下操作码写入状态：

```
snippet.yul

SSTORE, CREATE, SELFDESTRUCT, CALL, CALLCODE, DELEGATECALL, STATICCALL, CREATE2
```

同样，如果当前操作码在这组修改状态的操作码中，`Function`结构体的`view`属性将被设置为`false`。这也会将`pure`属性设置为`false`。

### 转换操作码

主要的反编译过程是将操作码转换为其对应的 solidity 代码。只有直接修改内存或存储的操作码才会被转换，因为栈操作将由`WrappedOpcode` solidifying 处理。

#### LOGN

`LOG0`、`LOG1`、`LOG2`、`LOG3`和`LOG4`操作码将被转换为 solidity 中对应的`emit`语句。

1. 首先，事件将保存到`Function`结构体以进行 ABI 生成。

2. 日志的`data`字段将通过`WrappedOpcode::solidify`解码为变量。

   ```rust
   snippet.rs
   
   let data_mem_ops: Vec<StorageFrame> = function.get_memory_range(instruction.inputs[0], instruction.inputs[1]);
   let data_mem_ops_solidified: String = data_mem_ops.iter().map(|x| x.operations.solidify()).collect::<Vec<String>>().join(", ");
   ```

   这将产生一个形式为`memory[0]，(1 + memory[1])，...`的字符串。

3. 然后，每个`topic`将通过`WrappedOpcode::solidify` 。

   ```rust
   snippet.rs
   
   let mut solidified_topics: Vec<String> = Vec::new();
   for (i, _) in topics.iter().enumerate() {
       solidified_topics.push(instruction.input_operations[i+3].solidify());
   }
   ```

4. 使用以下格式生成适当的`emit`语句：

   ```solidity
   snippet.sol
   
   emit Event_<selector>(<solidified_topics>, <data_mem_ops_solidified>);
   ```

   类型和事件命名将在后续阶段解析。

#### JUMPI

`JUMPI`操作码将转换为 solidity 中对应的`if`语句。它还用于处理伪`require()`语句，这将在后续版本中修复。

1. 首先，检查`JUMPI`在此分支中是否未被执行。如果未被执行且分支`REVERT`，则可以假定`JUMPI`是一个`require()`语句。

2. 否则，固化`JUMPI`的条件并生成`if`语句。

3. 我们还检查条件以确定函数是否是`payable`。如果条件是`!msg.value`，则函数可能是`payable`。

#### REVERT

`REVERT`操作码将转换为 solidity 中对应的`revert`语句。这个直接的操作码有一些特殊情况由反编译器处理：

1. 如果`REVERT`数据以`08c379a0`（`Error(string)`签名）开头，则将生成带有相应错误消息的`revert`语句。我们可以解码错误消息并使用以下格式生成`revert`语句：

   ```solidity
   // snippet.sol
   
   if (!<condition>) revert("Error message");
   ```

2. 如果`REVERT`数据以`4e487b71`（`Panic(uint256)`签名）开头，则该语句将被忽略。由于符号执行保证找到所有分支，因此将包括并且可以忽略这些 panic。

3. 如果不满足上述两种情况，则这是一个自定义错误。反编译器将这些保存到函数逻辑中，如下所示：

   ```solidity
   // snippet.sol
   
   if (!<condition>) revert CustomError_<selector>();
   ```

   同样，这些将用于 ABI 生成，并将在后续阶段解析。

#### RETURN

`RETURN`操作码将转换为 solidity 中对应的`return`语句。我们使用这个操作码来通过以下启发式确定函数的返回类型：

1. 如果返回数据使用`ISZERO`进行检查，我们可以假定返回类型为`bool`。

2. 如果返回数据进行位操作，我们可以执行变量大小检查以确定潜在的类型。

3. 对于超过 32 字节的返回数据，我们可以假定返回类型为`bytes`或`string`。返回类型也是`memory`。

4. 如果以上都不成立，我们假定返回类型为`uint256`。

#### SELFDESTRUCT

这非常直接，转换为 solidity 中对应的`selfdestruct`语句：

```solidity
// snippet.sol

selfdestruct(<address>);
```

#### SSTORE 和 MSTORE

`SSTORE`操作码将转换为 solidity 中对应的`storage`语句。这些转换为：

```solidity
snippet.sol

storage[<key>] = <value>;
```

由于`MSTORE`本质上也是做同样的事情，我们可以将其转换为 solidity 中对应的`memory`语句：

```solidity
snippet.sol

memory[<offset>] = <value>;
```

#### CALL、CALLCODE、DELEGATECALL 和 STATICCALL

这些操作码将转换为 solidity 中对应的`call`语句。这些转换为：

```solidity
snippet.sol

(bool success, bytes memory ret0) = address(<address>).<opcode>{gas: <gas>, value: <value>}(<solidified_memory>);
```

#### CREATE 和 CREATE2

为简单起见，这些操作码将转换为汇编：

- `CREATE`：

```solidity
snippet.sol

assembly { addr := create(<value>, <offset>, <size>) }
```

- `CREATE2`：

```solidity
snippet.sol

assembly { addr := create(<value>, <offset>, <size>, <salt>) }
```

#### CALLDATALOAD

这个操作码用于确定函数的参数。以下公式用于确定参数槽：

```solidity
snippet.rs

let calldata_slot = (instruction.inputs[0].as_usize() - 4) / 32;
```

例如，如果`CALLDATALOAD`在偏移量`4`处，则参数槽为`0`。如果`CALLDATALOAD`在偏移量`36`处，则参数槽为`1`。

然后，将此参数添加到`Function`结构体中，并添加一些默认的潜在类型给参数（例如`uint256`、`bytes32`、`int256`、`string`、`bytes`、`uint`、`int`）。这些潜在类型将在后续阶段缩小范围。

#### ISZERO

如果`ISZERO`用于`CALLDATALOAD`操作，我们可以假定参数可能在集合{`bool`、`bytes1`、`uint8`、`int8`}中。我们将这些潜在类型添加到参数中。

#### AND 和 OR

通过检查这些操作是否通过`CALLDATALOAD`修改参数的大小，并相应地更新参数的潜在类型。

### 确定变量类型

在大多数编程语言中，变量和参数都有与之关联的类型。当程序或智能合约编译时，这些类型通常会被移除，并用位掩码操作替换。例如，在 solidity 中，`address`是一个 20 字节的值。编译时，字节码通常会使用位掩码操作来确保该值恰好为 20 字节。这样做是为了节省字节码中的空间，并使字节码更加高效。

我们可以使用这种启发式来推断智能合约中变量和参数的类型。例如：

```solidity
snippet.yul

AND(PUSH20(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF), CALLDATALOAD(4))
```

反编译器理解这是 calldata 的第一个槽中的参数（因为 calldata 的前 4 个字节用于函数选择器）。我们知道这个参数很可能是一个存在于{`address`、`uint160`、`bytes20`}中的变量。

我们可以使用这种启发式来推断智能合约中变量或参数的*大小*。为了确定可能的类型，我们需要观察智能合约如何与该值交互。

例如，反编译器假定以下值是一个`address`，因为它在程序中被用作地址。

```solidity
snippet.yul

STATICCALL(GAS(), AND(PUSH20(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF), CALLDATALOAD(4)), ...)
```

此外，反编译器假定以下值是一个`uint256`，因为它在程序中被用于算术运算。

```solidity
snippet.yul

ADD(PUSH1(0xFF), AND(PUSH20(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF), CALLDATALOAD(4)))
```

对于`bytes`类型也是一样。例如，反编译器假定以下值是一个`bytes32`，因为它在程序中被用于位操作。

```
snippet.yul

BYTE(0, AND(PUSH20(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF), CALLDATALOAD(4)))
```

结合使用这些启发式，我们可以准确推断出任何给定智能合约中大多数变量和参数的类型。如果无法应用启发式到变量，反编译器将查找表达式中的其他变量，以继承它们的类型。例如：

```solidity
//snippet.sol

function() external payable {
    uint256 a = 0;
    b = a + 1;
}
```

由于`a`是一个有类型的变量，并且用于实例化`b`，因此`b`通常可以安全地继承`a`的类型：

```solidity
snippet.sol

function() external payable {
    uint256 a = 0;
    uint256 b = a + 1;
}
```

在无法推断类型的情况下，反编译器默认为`bytes32`或`uint256`，因为这是 solidity 中最常见的 32 字节类型。

### 处理预编译合约

EVM 有许多预编译合约，可以执行某些操作，例如恢复消息的签名者。Heimdall-rs 支持这些预编译合约，并可以将外部调用转换为相应的 solidity 函数调用。

处理这些合约非常简单。每当反编译器遇到外部调用时，都会检查`to`地址是否是预编译合约。如果是，反编译器可以解码 calldata 并将调用转换为 solidity 函数调用。

例如，这个简单的 [ECRecovery](https://etherscan.io/address/0x1bf797219482a29013d804ad96d1c6f84fba4c45) 合约几乎完美地编译为以下 solidity 代码：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @title            Decompiled Contract
/// @author           Jonathan Becker <jonathan@jbecker.dev>
/// @custom:version   heimdall-rs v0.2.2
///
/// @notice           This contract was decompiled using the heimdall-rs decompiler.
///                     It was generated directly by tracing the EVM opcodes from this contract.
///                     As a result, it may not compile or even be valid solidity code.
///                     Despite this, it should be obvious what each function does. Overall
///                     logic should have been preserved throughout decompiling.
///
/// @custom:github    You can find the open-source decompiler here:
///                       https://github.com/Jon-Becker/heimdall-rs

contract DecompiledContract {

    /// @custom:selector    0x19045a25
    /// @custom:name        Unresolved_19045a25
    /// @param              arg0 ["bytes", "bytes32", "int", "int256", "string", "uint", "uint256"]
    /// @param              arg1 ["bytes", "uint256", "int256", "string", "bytes32", "uint", "int"]
    function Unresolved_19045a25(bytes memory arg0, bytes memory arg1) public payable returns (address) {
        bytes memory var_a = var_a + (0x20 + ((0x1f + (arg1) / 0x20) * 0x20));
        if (var_a.length == 0x41) {
            if (!(var_a[0x60]) < 0x1b) {
                if (var_a[0x60] == 0x1b) {
                    if (var_a[0x60] == 0x1b) {
                        var_a = 0x20 + var_a;
                        uint256 var_d = arg0;
                        bytes1 var_e = var_a[0x60];
                        uint256 var_f = var_a[0x20];
                        uint256 var_g = var_a[0x40];
                        address var_h = ecrecover(var_d, var_e, var_f, var_g);
                        if (!var_h) { revert(); } else {
                            address var_d = var_h;
                            return(var_d);
                        }
                        return(0);
                    }
                    if (var_a[0x60] == 0x1c) {
                        var_a = 0x20 + var_a;
                        uint256 var_d = arg0;
                        bytes1 var_e = var_a[0x60];
                        uint256 var_f = var_a[0x20];
                        uint256 var_g = var_a[0x40];
                        address var_h = ecrecover(var_d, var_e, var_f, var_g);
                        if (!var_h) { revert(); } else {
                            address var_d = var_h;
                            return(var_d);
                        }
                        return(0);
                    }
                }
                if (var_a[0x60] + 0x1b == 0x1b) {
                    if (var_a[0x60] + 0x1b == 0x1c) {
                        var_a = 0x20 + var_a;
                        uint256 var_d = arg0;
                        bytes1 var_e = var_a[0x60] + 0x1b;
                        uint256 var_f = var_a[0x20];
                        uint256 var_g = var_a[0x40];
                        address var_h = ecrecover(var_d, var_e, var_f, var_g);
                        if (!var_h) { revert(); } else {
                            address var_d = var_h;
                            return(var_d);
                        }
                        return(0);
                    }
                    if (var_a[0x60] + 0x1b == 0x1b) {
                        return(0);
                        var_a = 0x20 + var_a;
                        uint256 var_d = arg0;
                        bytes1 var_e = var_a[0x60] + 0x1b;
                        uint256 var_f = var_a[0x20];
                        uint256 var_g = var_a[0x40];
                        address var_h = ecrecover(var_d, var_e, var_f, var_g);
                        if (!var_h) { revert(); } else {
                            address var_d = var_h;
                            return(var_d);
                        }
                    }
                }
            }
            return(0);
        }
    }
}
```

可以在[这里](https://www.evm.codes/precompiled)找到完整的预编译合约列表。

### 递归分析子分支

分支分析的最后一步是分析每个`VMTrace`的子分支。一旦所有分支都被分析，合约的逻辑应该完全提取并准备好进行后处理。

## 后处理

反编译的最后一步是后处理。这一步负责清理反编译代码并使其更易读。它还负责为变量分配可读的名称，并解析函数、事件和错误选择器。

### 解析选择器

后处理的第一步是解析函数、错误和事件的选择器。这是通过使用 Samczsun 的[Ethereum Signature Database](https://sig.eth.samczsun.com/) API 来解析选择器并找到其匹配的签名来完成的。一旦我们获得每个选择器的潜在签名列表，我们检查它们是否与函数、事件或错误的参数匹配。如果匹配，我们将选择器替换为签名。

例如，以下选择器：

```solidity
function Unresolved_19045a25(bytes memory arg0, bytes memory arg1) public payable returns (address) {
```

在解析选择器后将被替换为：

```solidity
function recover(bytes32 arg0, bytes memory arg1) public payable returns (address) {
```

### 构建 ABI

现在我们有了已解析和未解析选择器的列表，我们可以构建合约的 ABI。这非常简单，因为我们只需要从已解析和未解析选择器的列表构建一个带有以下结构的 JSON 文件：

```rust
//snippet.rs

#[derive(Serialize, Deserialize)]
struct FunctionABI {
    #[serde(rename = "type")]
    type_: String,
    name: String,
    inputs: Vec<ABIToken>,
    outputs: Vec<ABIToken>,
    #[serde(rename = "stateMutability")]
    state_mutability: String,
    constant: bool,
}

#[derive(Serialize, Deserialize)]
struct ErrorABI {
    #[serde(rename = "type")]
    type_: String,
    name: String,
    inputs: Vec<ABIToken>
}


#[derive(Serialize, Deserialize)]
struct EventABI {
    #[serde(rename = "type")]
    type_: String,
    name: String,
    inputs: Vec<ABIToken>
}
```

从已解析和未解析选择器的列表构建这些结构后，我们可以将它们序列化为 JSON 并写入文件，得到一个美观且极其准确的合约 ABI。

### 清理代码

现在我们可以从合约逻辑中组装 solidity 代码。在最终确定之前，每行代码都会经过一系列后处理步骤，以清理代码并使其更易读。

1. 将所有位掩码转换为强制类型转换。

   例如：

   ```
   (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) & (arg0);
   ```

   将被转换为：

   ```
   uint256(arg0);
   ```

2. 简化强制类型转换

   例如：

   ```
   ecrecover(uint256(uint256(arg0)), uint256(uint256(arg0)), uint256(uint256(uint256(arg0)));
   ```

   将被简化为：

   ```
   ecrecover(uint256(arg0), uint256(arg0), uint256(arg0));
   ```

3. 将`iszero(...)`转换为`!(...)`

4. 简化括号

   例如：

   ```
   if (((((((((((((((cast(((((((((((arg0 * (((((arg1))))))))))))) + 1)) / 10)))))))))))))))) {
   ```

   将被简化为：

   ```
   if (cast((arg0 * (arg1)) + 1 / 10)) {
   ```

5. 将所有内存访问转换为变量。例如：

   ```
   memory[0x20] = 0;
   memory[0x40] = memory[0x20] + 0x20;
   ```

   将被转换为：

   ```
   var_a = 0;
   var_b = var_a + 0x20;
   ```

6. 删除可以使用现有变量的表达式

7. 将所有最外层的类型转换移到变量声明中。例如：

   ```
   var_a = uint256(arg0);
   ```

   将被转换为：

   ```
   uint256 var_a = arg0;
   ```

8. 从表达式中继承或推断现有变量的类型。

9. 用其签名替换所有已解析的选择器。

10. 删除未使用的变量赋值。

## 结论

就是这样！我们已成功地反编译了一个合约。最后一步是将反编译代码写入文件，然后我们就完成了！希望本文能够解释一些关于反编译器的工作原理，以及它们如何用于分析智能合约。如果你有任何问题，欢迎在 [Twitter](https://twitter.com/BeckerrJon) 上联系我。




