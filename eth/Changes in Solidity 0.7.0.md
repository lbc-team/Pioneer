# Solidity 0.7.0 新特性



##  Solidity 0.7.0新特性的补充概述

在2020年7月28日，solidity编译器的版本小幅升级到0.7.0。它还附带了一个 [版本更新日志2](https://github.com/ethereum/solidity/releases/tag/v0.7.0) 上面有32个要点和一整页的 [专注于突破性变化2的文档](https://solidity.readthedocs.io/en/latest/070-breaking-changes.html). 我们有必要花点时间深入了解发生了什么变化，并简要考虑一下这些变化在实践中是如何影响可靠性智能合合约代码的。

下面,我将综合上面提到的“更新日志”和“突破性更新文档”, 重述上面所写的内容，同时试图澄清和补充任何这些更新有益的内容。我已经尝试根据实际遇到的可能性来分组介绍这些变化。最后，我列出了我认为不需要太多补充解释的任何变化。

### 最显著的变化

*外部函数和合约创建调用有了新的语法，这些语法对于同样使用过Web3.js的Soldity开发人员可能会很熟悉。而不是
`contract.function.gas(1000).value(2 ether)(arg1, arg2)`  新语法是`contract.function{gas: 1000, value: 2 ether}(arg1, arg2)` 。不再允许使用旧语法。

* 构造函数可见性 (`public` / `external`) 现在被忽略, 因此，不再需要指定。（构造可见性不指定的时候）解析器现在将对此发出警告。 为了防止合约是可部署的，合约本身可以用关键字“abstract”来标记 (例如 `abstract Contract {}`).

* 不再允许使用全局变量'now'。它已经被弃用，取而代之的是“block.timestamp”。这已经是一段时间以来的最佳实践，应该有助于避免"now"一词倾向于产生的误导思维模式。

* 现在不允许对非公共状态变量使用NatSpec注释。实际上，这意味着转换现有的隐式或显式的`@notice` NatSpec 注释 (例如. `/// comment` or `/// @notice comment`) 以显示`@dev` 注释 (例如 `/// @dev comment`) )或简单的内嵌注释 (例如 `// comment`). 这样的注释在库中并不少见，因此人们可能会发现自己不得不修复依赖关系，直到整个生态系统陷入困境。

* 标记' gwei '现在是一个关键字，所以不能用作变量或函数名。在' ^0.6.0 '中，标记' gwei '用作面值和也可同时用作标识符，这令人混淆，如下例所示:

```
// 行为之前
uint gwei = 5;
uint value = gwei * 1 gwei; // value: 5000000000
```

  试图用“gwei”制造这样的混乱，现在只会抛出一个罪有应得的解析错误。

* 另外，关键字“finney”和“szabo”已经退役，现在可以作为标识符使用。(不过，为了避免潜在的混淆，最好不要立即把他们当做标识符使用。)
* 除了[ASCII字符和各种转义序列2]之外的任何字符串文字(https://solidity.readthedocs.io/en/latest/types.html?highlight=ascii# String -literals-and-type)将抛出解析器错误。



* 需要表达ASCII以外的字符串变量现在应该显式键入unicode字符串。它们用“unicode”前缀来标识(例如:unicode)。 (例如. `unicode"Text, including emoji! 🤓"`).

* Derived contracts no longer inherit library `using` declarations for types (e.g. `using SafeMath for uint`). Instead, such declarations must be repeated in *every* derived contract that wishes to use the library for a type.

* Events in the same inheritance hierarchy are no longer allowed to have the same name and parameter types.

### Still Perceptible Changes

* Declaring a variable with the `var` keyword so that its type is assigned implicitly has been deprecated for several releases in favor of explicitly typed variables. However, the compiler would still recognize the `var` syntax and complain about it with a type error. Now, the `var` keyword is simply not allowed and will result in a parser error.

* Function state mutability can now be made more restrictive during inheritance. So, `public` functions with default mutability can be overridden by `view` or `pure` functions. If an inherited function is marked `view`, then it can be overridden by a `pure` function.

```
 // Behavior Now
contract Parent {
  function show() public virtual returns(uint){
      return 100;
  }
}

contract Child is Parent {
    function show() public pure override returns(uint){ // overriding with pure is allowed
        return 25;
    }
}
```

* Prior to this release, shifts and exponentiation of literals by non-literals (e.g. `250 << x` or `250 ** x`) would be performed using the type of either the shift amount or the exponent (i.e. `x` in the examples). Now, either `uint256` (for non-negative literals) or `int256` (for negative literals) will be used to perform the operations.

```
// Behavior Before
uint8 x = 2;

uint shift = 250 << x; // shift: 232
uint exp = 250 ** x; // exp: 36
```

```
// Behavior Now
uint8 x = 2;

uint shift = 250 << x; // shift: 1000
uint exp = 250 ** x; // exp: 62500
```

Notice how before, both results were implicitly cast to the type of `x` which is `uint8` and, as a consequence, overflowed accordingly.

Now, more intuitively, both results are of type `uint256` and, so, avoid overflowing in this case.

* Shifts (e.g. `shiftThis >> amount` `shiftThis << amount`) by signed types are no longer allowed. Previously, negative shifts were permitted, but would revert at runtime.

* The parser will no longer recommend stricter mutability for virtual functions, but **will** still make such recommendations for any overriding functions.

* Library functions can no longer be marked `virtual`. Which makes sense, given the fact that libraries cannot be inherited.

### Less Noticeable Changes

#### Mappings Outside Storage

* Mappings only exist in storage, and, previously, mappings in structs or arrays would be ignored/skipped. Such behavior was, we agree with the docs, “confusing and error-prone”. Similar “skipping” behavior was encountered when assigning to structs or arrays in storage if they contained mappings. These sorts of assignments are no longer allowed - making things much less confusing.

#### Inline Assembly

* Inline assembly no longer supports user-defined identifiers with a `.` (*period*) - unless operating in Solidity Yul-only mode.

* Slot and offset of storage pointer variables are now accessed with dot notation `.` (e.g. `stor.slot` & `stor.offset`) rather than an underscore `_` (e.g. `stor_slot` & `stor_offset`).

#### YUL

> * Disallow consecutive and trailing dots in identifiers. Leading dots were already disallowed.
> * Yul: Disallow EVM instruction pc().

What’s the `pc` instruction, you might wonder? As defined in the yellow paper, it should: “Get the value of the program counter prior to the increment corresponding to this instruction.”

### Mentioned for Completeness

#### Compiler Features

> * SMTChecker: Report multi-transaction counterexamples including the function calls that initiate the transactions. This does not include concrete values for reference types and reentrant calls.

#### JSON AST (Abstract Syntax Tree)

> * Hex string literals are now marked with kind: “hexString”.
> * Members with null values are removed from the output.

#### Bugfixes

> * Inheritance: Disallow public state variables overwriting pure functions.
> * NatSpec: Constructors and functions have consistent userdoc output.
> * SMTChecker: Fix internal error when assigning to a 1-tuple.
> * SMTChecker: Fix internal error when tuples have extra effectless parenthesis.
> * State Mutability: Constant public state variables are considered pure functions.
> * Type Checker: Fixing deduction issues on function types when function call has named arguments.
> * Immutables: Fix internal compiler error when immutables are not assigned.

* * *

Good work making it to the bottom of the list! As you can see, the trend to make Solidity ever-more explicit is alive and well. This is a net positive for smart contract security - and staying up to date with the latest Solidity changes is an important part of being a proficient Soldity dev.

If you need some tips for updating your code, don’t overlook the tips in the [docs 2](https://solidity.readthedocs.io/en/latest/070-breaking-changes.html?highlight=shift#how-to-update-your-code) and be sure to check out the [solidity-upgrade tool 5](https://solidity.readthedocs.io/en/latest/using-the-compiler.html#solidity-upgrade).

If anything is unclear or you’d like to discuss any of the changes, feel free to continue the conversation below!

原文链接：https://forum.openzeppelin.com/t/changes-in-solidity-0-7-0/3758
作者：[CallMeGwei](https://forum.openzeppelin.com/u/CallMeGwei)