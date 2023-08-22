> * 原文链接： https://www.rareskills.io/post/solidity-style-guide
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# Solidity 编码规范标准



本文的目的不是重复官方的[Solidity 编程风格指南](https://learnblockchain.cn/docs/solidity/style-guide.html)，你应该阅读它。相反，本文旨在记录代码审查或审计中常见的偏离风格指南的情况。这里的一些项目不在风格指南中，但却是 Solidity 开发人员常见的风格错误。

## 前两行

### 1. 包含 SPDX 许可标识符

当然，如果没有它，你的代码也能编译，但会收到警告，所以只需让警告消失即可。

### 2. 固定 solidity pragma，除非编写库

你可能见过像下面这样的程序：

```solidity
pragma solidity ^0.8.0;
```

和

```solidity
pragma solidity 0.8.21;
```

你应该在什么时候使用哪个版本？如果你是编译和部署合约的人，你知道你编译的 Solidity 版本，所以为了清楚起见，你应该根据你使用的编译器固定 Solidity 版本。

另一方面，如果你正在创建一个可供其他人扩展的库，比如 OpenZeppelin 和 [Solady](https://www.solady.org/)，你就不应该固定 pragma，因为你不知道最终用户将使用哪个版本的编译器。

## 导入（import）

### 3. 在导入语句中明确设置库版本

不是这样做：

```
import "@openzepplin/contracts/token/ERC20/ERC20.sol";
```

这样做

```
import "@openzeppelin/contracts@4.9.3/token/ERC20/ERC20.sol";
```

点击 github 左侧的分支下拉菜单，然后点击标签（tags），选择最新发布的版本，即可获得最新版本。使用最新的正式版本（非 rc，即非候选发布版本）。

![solidity 库版本](https://img.learnblockchain.cn/2023/08/22/89715.png!smlogo)

如果你没有对导入进行版本更新，而底层库又进行了更新，那么你的代码有可能无法编译或出现意外行为。

### 4. 使用命名导入，而不是导入整个命名空间

不要这样做

```solidity
import "@openzeppelin/contracts@4.9.3/token/ERC20/ERC20.sol";
```

这样做

```solidity
import {ERC20} from "@openzeppelin/contracts@4.9.3/token/ERC20/ERC20.sol";
```

如果在导入文件中定义了多个合约或库，就会污染命名空间。如果编译器优化程序不删除这些代码，就会导致代码死机（这一点不应依赖编译器优化程序）。

### 5. 删除未使用的导入

如果你使用的是像 Slither 这样的[智能合约安全工具](https://www.rareskills.io/post/smart-contract-audit-tools)，这种情况会被自动捕获。但一定要删除这些内容。不要害怕删除代码。

## 合约级别

### 6. 使用合约级 natspec

natspec（自然语言注释规范）的目的是提供易于人类阅读的内联文档。

合约的 natspec 示例如下：

```solidity
/// @title Liquidity token for Foo protocol
/// @author Foo Incorporated
/// @notice Notes for non-technical readers/
/// @dev Notes for people who understand Solidity
contract LiquidityToken {

}
```

### 7.根据风格指南布局合约结构

根据[风格指南](https://learnblockchain.cn/docs/solidity/style-guide.html)， 函数在合约内顺序，应先按 "外部性 "排序，再按 "状态变化性 "排序。

应按以下顺序排列：接收和回退函数（如有）、外部函数、公共函数、内部函数和私有函数。

在这几组中，先是 payable 函数，然后是非 payable 函数，再是视图函数，最后是pure（纯）函数。

```solidity
contract ProperLayout {

	// type declarations, e.g. using Address for address
	// state vars
	address internal owner;
	uint256 internal _stateVar;
	uint256 internal _starteVar2;

	// events
	event Foo();
	event Bar(address indexed sender);

	// errors
	error NotOwner();
	error FooError();
	error BarError();
	
	// modifiers
	modifier onlyOwner() {
		if (msg.sender != owner) {
			revert NotOwner();
		}
		_;
	}

	// functions
	constructor() {

	}

	receive() external payable {

	}

	falback() external payable {

	}

	// functions are first grouped by
	// - external
	// - public
	// - internal
	// - private
	// note how the external functions "descend" in order of how much they can modify or interact with the state
	function foo() external payable {

	}

	function bar() external {

	}

	function baz() external view {

	}

	function qux() external pure {

	}

	// public functions
	function fred() public {

	}

	function bob() public view {

	}

	// internal functions
	// internal view functions
	// internal pure functions
	// private functions
	// private view functions
	// private pure functions
}
```



## 常量

### 8.用常数代替神奇数字

如果你在代码中看到数字 100，它是什么？100%？100 个基点？

一般来说，数字应该作为常数写在合约的顶部。

### 9.如果用数字来衡量以太币或时间，应使用 solidity 关键词

不要写成：

```solidity
uint256 secondsPerDay = 60 * 60 * 24;
```

而是这样写：

```solidity
1 days;
```

不要写

```solidity
require(msg.value == 10**18 / 10, "must send 0.1 ether");
```

而是：

```solidity
require(msg.value == 0.1 ether, "must send 0.1 ether");
```

### 10. 使用下划线使大数字更易读

不这样写：

```solidity
uint256 private constant BASIS_POINTS_DENOMINATOR = 10000
```

而是：

```solidity
uint256 private constant BASIS_POINTS_DENOMINATOR = 10_000
```

## 函数

### 11. 从不会被重载的函数中移除"virtual"修饰符

virtual 修饰符的意思是 "可由子合约重写"。但如果你知道自己不会重写函数（因为你是部署者），那么这个修饰符就是多余的。删除它即可。

### 12. 按正确顺序排列函数修饰符 可见性、可变性、virtual、覆盖自定义修饰符

以下方式正确：

```solidity
// visibility (payability), [virtual], [override], [custom]
function foo() public payable onlyAdmin {

}

function bar() internal view virtual override onlyAdmin {

}
```

### 13. 正确使用 natspec

natspec 有时被称为 "solidity 注释样式"，其正式名称是 natspec：

其规则与合约级 natspec 类似，不过我们还根据函数参数和返回值参数注释。

这是在不使用长参数变量的情况下描述参数名称的好方法：

```solidity
/// @notice Deposit ERC20 tokens
/// @dev emits a Deposit event
/// @dev reverts if the token is not allowlisted
/// @dev reverts if the contract is not approved by the ERC20
/// @param token The address of the ERC20 token to be deposited
/// @param amount The amount of ERC20 tokens to deposit
/// @returns the amount of liquidity tokens the user receives
function deposit(address token, uint256 amount) public returns (uint256) {

}

// If the contract inherits functions, you can also inherit their natspec
/// @inheritdoc Lendable
function calculateAccumulatedInterest(address token, uint256 since) public override view returns (uint256 interest) {

} 
```

对于 @dev 参数注释，最好能说明它能做哪些状态变化，例如发出事件、发送以太币、自毁等。

@notice 和参数 natspec 可由 Etherscan 读取。

![etherscan读取natspec](https://img.learnblockchain.cn/2023/08/22/95189.png!smlogo)

从下面的 [代码](https://etherscan.io/token/0xc00e94cb662c3520282e6f5717214004a7f26888?a=0x3d9819210a31b4961b30ef54be2aed79b9c9cd3b#code) 截图中，你可以看到 Etherscan 从何处获得这些信息。



![带 natspec 的固态函数](https://img.learnblockchain.cn/2023/08/22/79019.png!smlogo)

## 通用简洁

### 14.删除已注释的代码

这一点不言自明。如果代码被注释掉，还留在那里， 就会显得杂乱无章。

### 15.仔细考虑变量名

为变量命名是编写优秀代码的难点之一，但它对代码的可读性大有裨益。

**一些小贴士**：

- 避免使用 "通用名词"，如 "用户"， 而是要更精确命名：例如 "管理员"、"买家"、"卖家"。
- "数据"一词通常表示不精确， 用 "userAccount"代替 "userData"。
- 不要用两个不同的名词来指同一个现实世界的实体。例如，如果 "deposititor "和 "liquidityProvider "指的是现实世界中的同一个实体，只需使用一个术语即可，不要在代码中同时使用两个术语。
- 在变量名中包含单位。用 "interestRatesBasisPoints" 或 "feeInWei "代替 "interestRate"。
- 更改状态的函数名称中应包含动词。
- 始终**保持一致**：在使用下划线区分内部变量和函数参数与覆盖的状态变量时，如果在变量前加上下划线表示 `internal`，应确保它在其他上下文中没有其他含义，例如，与状态变量同名的函数参数就不要使用下划线了。
- 使用 "get" 查看数据，使用 "set" 更改数据是编程中广泛遵循的惯例。请考虑采用这种方法。
- 写完代码后，离开电脑，15 分钟后再回来，问问自己每个变量和函数的名称是否尽可能精确。因为你比任何人都更了解代码库的意图，所以这种深思熟虑的比任何检查对照表都更有益。

## 整理大型代码库的其他技巧

- 如果你有大量的存储变量，你可以在一个单一的合约中定义所有的存储变量，然后从该合约继承以获得对这些存储变量的访问权限。
- 如果函数需要大量参数，可以使用结构体来传递信息。
- 如果需要大量导入，可以将所有文件和类型导入到一个 solidity 文件中，然后导入该文件（需要故意打破命名导入的规则）。
- 使用库将相同类别的函数组合在一起，使文件更小。

组织大型代码库是一门艺术。学习这门艺术的最好方法就是研究大型成熟项目的代码库。



## 学习更多

如果你要系统学习Solidity ，你可以学习：

1. [区块链技术集训营 - 视频课](https://learnblockchain.cn/course/28)  
2. 订阅[全面掌握Solidity智能合约开发 专栏](https://learnblockchain.cn/column/1) 
3. 订阅[Ethernaut 题库闯关 - 精进 Solidity](https://learnblockchain.cn/column/19)






本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来 DeCert 码一个未来， 支持每一位开发者构建自己的可信履历。
