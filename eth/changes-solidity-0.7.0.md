> * 原文链接：https://forum.openzeppelin.com/t/changes-in-solidity-0-7-0/3758 作者：[CallMeGwei](https://forum.openzeppelin.com/u/CallMeGwei)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

#  Solidity 0.7.0 更新点


> Solidity 0.7.0 所涉及的更新的概述

2020年7月28日，Solidity编译器的次要版本升至0.7.0. [变更日志](https://github.com/ethereum/solidity/releases/tag/v0.7.0)上包含32个修改要点。
在 Solidity 文档上也用了一整页[介绍0.7.0的突破性更新](https://learnblockchain.cn/docs/solidity/070-breaking-changes.html)。

因此值得花一些时间深入研究以下其中的变更内容，并思考这些更改在实践中如何影响Solidity智能合约代码。

下面，我将综合上面提到的变更日志和文档中的重大更新，重新陈述相关类型，尽量尝试澄清和做有益的补充，同时，我会尝试按变化程度进行分组排序。


## 最明显的变化

* 外部函数调用和合约创建使用新语法。不再使用 `contract.function.gas(1000).value(2 ether)(arg1，arg2)`，新语法是`contract.function{gas：1000, value：2 ether}(arg1，arg2)`。对于使用过Web3.js的Soldity开发人员来说，应该不会感到陌生。

* 构造函数的可见性(`public`/`external`)现在被省略，因此不再需要指定。解析器现在将对此发出警告。为了防止合约部署，可以在合约上标记关键字`abstract`(例如，`abstract Contract {}`)。

* 不再允许使用全局变量`now`，而推荐使用`block.timestamp`。这已经是一段时间以来推荐的使用方法，因为它有助于避免`now`一词产生的误导性（指的是区块时间而不是当前时间）。

* 现在禁止对非公共状态变量使用NatSpec注释。实际上，这意味着现有的隐式或显式`@notice` NatSpec注释(例如`/// 注释`或`/// @notice 注释`)会转换为显式`@dev`注释(例如`/// @dev 注释` )或简单的行内注释(例如`// 注释`)。

*  现在可以使用 `gwei` 关键字，因此`gwei`不能再作为变量或函数名称。在`0.6.x`版本中，gwei 即可用作面额*，还可以用作标识符，这会让人产生困惑，如下面不好的示例：

```
// 以前的行为
uint gwei = 5;
uint value = gwei * 1 gwei; // value: 5000000000
``` 

现在这样与`gwei`造成的混淆，会触发编译器的解析错误提示。

* 与此相关的是，关键字`finney`和`szabo`已停用，因此，现在可以将其用作标识符。 (尽管建议不要立即使用它们，以免造成潜在的混乱。)

* 字符串常量包含非[ASCII字符和各种转义序列](https://solidity.readthedocs.io/en/latest/types.html?highlight=ascii#string-literals-and-types)内容时，会触发解析器错误。

* 现在，如果需要表达比ASCII更多的字符串文字应该显式以`unicode`前缀标识(例如，`unicode"Text, including emoji! 🤓"`)。

* 派生合约不再继承通过 using 声明的类型的库方法，(例如，using SafeMath for uint)。如果需要使用相应的库方法，需要在每个希望使用该类型的库的派生合约中重复进行声明。

* 相同继承层次结构中的事件不再允许使用相同的名称和参数类型。

## 仍可感知的变化

* 使用`var`关键字声明变量，用来隐式分配类型，已在多个版本中弃用了，现在完全禁止使用，只能使用显式声明类型的变量。

* 函数状态的可变性现在可以在继承后更加严格。因此，具有默认可变性的public函数可以被view函数或pure函数重写。如果被继承的函数被标记为`view`，那么它可以被`pure`函数重写。

```js
 // 现在的写法
contract Parent {
  function show() public virtual returns(uint){
      return 100;
  }
}

contract Child is Parent {
    function show() public pure override returns(uint){ // 可以用 pure 重写 
        return 25;
    }
}
```

* 在此版本之前，将对常量使用移位或指数运算，会使用非常量的类型(例如，`250 << x`或` 250 ** x` 中，使用 x 的类型)。现在，将使用`uint256`(用于非负常量)或`int256`(用于负常量)来执行操作。

```js
// 之前
uint8 x = 2;

uint shift = 250 << x; // shift: 232
uint exp = 250 ** x; // exp: 36
```

```js
// 现在
uint8 x = 2;

uint shift = 250 << x; // shift: 1000
uint exp = 250 ** x; // exp: 62500
```

注意之前如何将两个结果隐式转换为`x`类型，即 uint8，因此会发生溢出。


现在，两个结果均为`uint256`类型，因此在此案例中避免溢出。

* 不再允许有符号类型移位(例如，amount 为有符号类型，` shiftThis >> amount` 和 `shiftThis << amount`)。以前，允许负移，但会在运行时回退。

* 解析器将不再建议对虚拟函数进行严格的可变性声明，但是推荐重载的函数使用。

* 库函数不能再标记为`virtual`。因为库事实上是无法继承的，这实际上说的通。

## 不太明显的变化

### 外部存储映射

* 以前映射仅存在于存储中，并且，结构体或数组中的映射在赋值（或初始化）中被忽略，这种行为“令人困惑且容易出错”。现在这种形式的赋值不再允许，以减少困惑。

### 内联汇编

* 内联汇编不再支持用`.`(* period *)的用户定义标识符，除非在 Solidity Yul-only 模式下运行。

* 存储指针变量的插槽和偏移量现在可以使用点符号`.`访问(例如`stor.slot`和`stor.offset`)，而不再使用下划线_(例如stor_slot和stor_offset)。

### YUL

> * 禁止在标识符中使用`.`。
> * Yul：禁止EVM指令pc。

你可能想知道什么是`pc`指令？如黄皮书中所定义，它应该：`在与该指令相对应的增量之前获取程序计数器的值。`

## 结束语

Solidity 0.7 还有一些不影响编码的修改和 Bug 的修复。


如你所见，Solidity 在往更加明确的语义前进。这对于智能合约的安全性是绝对有利，保持升级Solidity也是成为熟练的Soldity开发人员的重要组成部分。

如果你需要更新代码，可以看看[突破性更新](https://learnblockchain.cn/docs/solidity/070-breaking-changes.html)中提到的技巧，并推荐你使用[solidity-upgrade工具](https://solidity.readthedocs.io/en/latest/using-the-compiler.html#solidity-upgrade)。


------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。