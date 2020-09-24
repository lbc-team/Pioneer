# Solidity 0.7.0 新变化



##  Solidity 0.7.0新变化的补充概述

在2020年7月28日，Solidity编译器的版本小幅升级到0.7.0。它还附带了一个 [版本更新日志2](https://github.com/ethereum/solidity/releases/tag/v0.7.0) 上面有32个要点和一整页的 [专注于突破性变化2的文档](https://solidity.readthedocs.io/en/latest/070-breaking-changes.html). 我们有必要花点时间深入了解发生了什么变化，并简要考虑一下这些变化在实践中是如何影响可靠性智能合合约代码的。

下面,我将综合上面提到的“更新日志”和“突破性更新文档”, 重述上面所写的内容，同时试图澄清和补充任何这些更新有益的内容。我已经尝试根据实际遇到的可能性来分组介绍这些变化。最后，我列出了我认为不需要太多补充解释的任何变化。

### 最显著的变化

* 外部函数和合约创建调用有了新的语法，这些语法对于同样使用过Web3.js的Solidity开发人员可能会很熟悉。而不是`contract.function.gas(1000).value(2 ether)(arg1, arg2)`  新语法是`contract.function{gas: 1000, value: 2 ether}(arg1, arg2)` 。不再允许使用旧语法。

* 构造函数可见性 (`public` / `external`) 现在被忽略, 因此，不再需要指定。（构造可见性不指定的时候）解析器现在将对此发出警告。 为了防止合约是可部署的，合约本身可以用关键字`abstract`来标记 (例如 `abstract Contract {}`).

* 不再允许使用全局变量'now'。它已经被弃用，取而代之的是`block.timestamp`。这已经是一段时间以来的最佳实践，应该有助于避免"now"一词倾向于产生的误导思维模式。

* 现在不允许对非公共状态变量使用`NatSpec`注释。实际上，这意味着转换现有的隐式或显式的`@notice` `NatSpec` 注释 (例如. `/// comment` or `/// @notice comment`) 以显示`@dev` 注释 (例如 `/// @dev comment`) )或简单的内嵌注释 (例如 `// comment`). 这样的注释在库中并不少见，因此人们可能会发现自己不得不修复依赖关系，直到整个生态系统陷入困境。

* 标记`gwei `现在是一个关键字，所以不能用作变量或函数名。在' ^0.6.0 '中，标记`gwei`用作面值和也可同时用作标识符，这令人混淆，如下例所示:

```
// 
uint gwei = 5;
uint value = gwei * 1 gwei; // value: 5000000000
```

  试图用`gwei`制造这样的混乱，现在只会抛出一个罪有应得的解析错误。

* 另外，关键字`finney(芬尼)`和`szabo(萨博)`已经退役，现在可以作为标识符使用。(不过，为了避免潜在的混淆，最好不要立即把他们当做标识符使用。)
* 除了[ASCII字符和各种转义序列2]之外的任何字符串文字(https://solidity.readthedocs.io/en/latest/types.html?highlight=ascii# String -literals-and-type)将抛出解析器错误。



* 需要表达ASCII以外的字符串变量现在应该显式键入`unicode`字符串。它们用`unicode`前缀来标识(例如:`unicode`)。 (例如. `unicode"Text, including emoji! 🤓"`)。

* 派生合约不再使用“using”声明继承库(例如:`using SafeMath for uint `)。相反，这样的声明必须在希望使用类型库的每个派生合约中重复。

* 相同继承层次结构中的事件不再允许具有相同的名称和参数类型。

### 仍然可以察觉到变化

* 用'`var `关键字声明一个变量，这样它的类型就会被隐式赋值已经被废弃了，已经有几个版本赞成使用显式类型的变量。但是，编译器仍然会识别出`var`语法，编译的时候抛出类型错误。现在，`var`关键字是不允许的，并且会导致解析器错误。

* 在继承期间，函数状态的可变性现在可以变得更加严格。因此，具有默认可变性的`public`函数可以被`view`或`pure`函数覆盖。如果一个继承的函数被标记为`view`，那么它可以被一个`pure`函数覆盖。
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

* 在此版本之前，对非文本进行移位和取幂(例如，`250 << x` 或`250 ** x`)将使用移位量或指数的类型(即例如`x`)。现在，`uint256 `(用于非负数)或`int256`(用于负数)将用于执行这些操作。

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

注意，以前，两个结果都隐式转换为`x `类型，即`uint8 `，结果就会相应地溢出。

现在，更直观的是，这两个结果的类型都是`uint256 `，因此，在本例中要避免溢出。

* 有符号类型的移位(例如`shiftThis >> amount shiftThis << amount `)不再被允许。以前，允许负移位运算，但是会在运行时恢复。

* 解析器将不再为虚函数推荐更严格的可变性，但仍将为任何重写函数提供这样的建议。

* 库函数不再被标记为`virtual`。这是有道理的，因为库是不能继承的。

### 不太明显的变化

#### 外部存储的映射

* 映射只存在于存储中，以前，结构体或数组中的映射将被忽略/跳过。 我们同意文档中的说法，这种行为是“令人困惑和容易出错的”。如果存储中的`struct`或数组包含映射，则在给它们赋值时也会遇到类似的“跳过”行为。这种类型的赋值不再被允许——这使得事情变得不那么混乱了。

#### 内联汇编

* 内联汇编不再支持带有'.'的用户定义标识符。(*period*) -除非运行在Solidity Yul-only模式下。

* 存储指针变量的槽和偏移量现在用点符号"."来访问'。 (例如 `stor.slot` & `stor.offset`) 而不是下划线 `_` (例如 `stor_slot` & `stor_offset`).

#### YUL

> * 不允许在标识符中使用连续的和尾随的点。引导点已经被禁止了。
> * Yul: 不允许`EVM`指令`pc()`。

你可能会想，`pc`的指令是什么?正如黄皮书中所定义的，它应该:“在与此指令对应的增量之前获取程序计数器的值。”

### 为了完整性起见


#### 编译器特性

> * `SMTChecker`: 报告多个交易反例，包括初始化交易的函数调用。这并不包括引用类型和重入调用的具体值。

#### `JSON AST` (抽象语法树)

> * 十六进制字符串现在被标记为:“`hexString`”。
> *  具有空值的成员将从输出中删除。

#### 修正

> * 继承:不允许公共状态变量覆盖纯函数。
> * `NatSpec`: 构造函数和函数具有一致的`userdoc`输出。
> * `SMTChecker`: 修复分配到1元组时的内部错误。
> * `SMTChecker`: 修复元组有额外有效括号时的内部错误。
> * 状态可变性:常量公共状态变量被认为是纯函数。
> * 类型检查器:修复了当函数调用已命名参数时函数类型的推断问题。
> * 固定不变:修复内部编译错误时，不可改变的不被分配。

* * *

 压轴部分要表达的是:正如你所看到的，让Solidity变得更加明确的趋势依然存在，而且很好。这对智能合约安全来说是完全有利的——而要成为一名熟练的`Soldity`开发者，及时了解最新的可靠性变化是重要的一部分。
如果你需要一些建议更新代码,不要忽视的技巧文档2,一定要检查出[solidity-upgrade tool 5](https://solidity.readthedocs.io/en/latest/using-the-compiler.html#solidity-upgrade).
如果有任何不清楚的地方，或者你想讨论任何变化，欢迎继续下面的对话!

原文链接：https://forum.openzeppelin.com/t/changes-in-solidity-0-7-0/3758
作者：[CallMeGwei](https://forum.openzeppelin.com/u/CallMeGwei)