
### 合约整洁之道-智能合约模式和实践指南


区块链和智能合约的开发仍是相对较新的且高度试验性的。 他们需要与传统网络或应用开发不同的工程思维方式，传统网络或应用开发已成为“快速行动并打破常规”的准则。

区块链开发更像是硬件或金融服务开发。 智能合约是复杂的工具，可以提供具有透明，防篡改和不可变信息的自我执行合约。 他们有权在复杂系统之间分配高价值资源。 合约往往自主工作，面临巨大的财务损失风险，使得智能合约成为这些系统中的关键组件。 开发此类组件需要更多的投入，设计和前期工作。 扎实的工程实践，严格的测试和强大的安全意识。

在一系列博客文章中，我计划介绍几种可应用于区块链和智能合约开发的模式，实践和原则，以降低与之相关的风险。

# 代码整洁之道

![](https://img.learnblockchain.cn/2020/09/04/15991844482808.jpg)


在第一篇文章中，我将介绍更多基于Clean Code概念的通用工程实践。 整洁代码是软件开发行业中众所周知的概念。 [罗伯特·C·马丁（Robert C Martin），也称为“鲍勃叔叔”（Uncle Bob），写下了著名的手册](https://amzn.to/30RsoKk)。 它的原理甚至可以追溯到敏捷宣言和软件工艺的早期概念。 这是我们思考，编写和阅读代码的方式的知识库。 以数十年的软件开发智慧为基础。

> *“Truth can only be found in one place: the code”*（真理只能在代码中发现）- Robert C. Martin

整洁的代码是易于阅读的代码，容易理解，并且易于维护。简洁的代码是一种尝试，以了解我们正在处理的系统的复杂。 它是一种防御机制，当你不确定某个更改将如何影响代码库时，它可以提供指导。尽管手册存在有效的批评，并且示例被认为已过时，但这些原则仍然非常相关。 特别是对于面向对象的语言，例如Solidity。 它们适用于设计和编写安全，开源和不变的代码，如智能合约。

# 实践

## 命名

合约、函数或变量的命名应该揭示其意图、存在原因以及如何使用。如果一个名字需要注释来解释，那么它不会透露它的意图。

代码的命名要一致。特别是当你使用一个大型的代码库时。在多个合约中，对抽象概念使用相同的名称。

使用可读得出的名字。

使用可搜索的名称。

> *“There are only two hard things in Computer Science: cache invalidation and naming things.”*（计算科学中最难的两件事是缓存失效和命名） - Phil Karlton

**References**

* [代码示例](https://github.com/wslyvh/clean-contracts/tree/master/1-naming)
* [Solidity 风格指南](https://solidity.readthedocs.io/en/latest/style-guide.html)

## 结构 & 顺序

顺序帮助读者确定可以调用哪些函数，更容易找到构造函数和回退定义。

### 结构顺序

按以下顺序排列合约元素

1. Pragma 语句
2. Import 语句
3. Interfaces
4. Libraries
5. Contracts

在每个合约、库或接口中，使用以下顺序

1. 类型声明
2. 状态变量
3. Events
4. Functions

### 函数排序

函数应该根据其可见性和顺序进行分组

1. constructor
2. receive 函数 (如果存在)
3. fallback 函数 (如果存在)
4. external
5. public
6. internal
7. private

明确标记函数和状态变量的可见性。可以将函数制定为 `external`, `public`, `internal`, 或 `private`. 请了解它们之间的区别。

### 修饰符的排序

函数的修饰符顺序应为：

1. Visibility
2. Mutability
3. Virtual
4. Override
5. Custom modifiers

**References**

* [代码示例](https://github.com/wslyvh/clean-contracts/tree/master/2-structure)
* [Solidity 风格指南](https://solidity.readthedocs.io/en/latest/style-guide.html)

## 文档 & Natspec

Solidity合约可以采用注释的形式，为阅读代码的其他人以及最终用户提供丰富的文档。 这称为以太坊自然语言规范格式，或 [NatSpec](https://solidity.readthedocs.io/en/latest/natspec-format.html).

本文档分为面向开发人员的消息和面向最终用户的消息。这些消息可以在与合约交互时显示给最终用户（人）（即签名一个交易）。

建议对所有公共接口（ABI中的所有内容）使用NatSpec对Solidty合约进行完全注释。

**References**

* [代码示例](https://github.com/wslyvh/clean-contracts/tree/master/3-documentation)
* [NatSpec](https://solidity.readthedocs.io/en/latest/natspec-format.html)

## 格式

阅读代码应该像阅读这个博客、一篇文章或一本书一样。它应该被很好地格式化。Solidity风格指南为编写Solidity代码提供了指导。它的目标不是正确的或唯一的方法，而是要保持一致。

可以通过使用lint来实现一致性。 这不仅提供格式和样式指南验证，还包括安全验证。

Solidity可用的lint

* [Ethlint](https://github.com/duaraghav8/Ethlint) (原名 Solium)
* [Solhint](https://github.com/protofire/solhint)
* [VS Code Solidity](https://github.com/juanfranblanco/vscode-solidity/)

为您的dapp开发使用常规的lint（例如eslint，具体取决于您的语言）。

**References**

* [代码示例](https://github.com/wslyvh/clean-contracts/tree/master/4-formatting)
* [Solidity 风格指南](https://solidity.readthedocs.io/en/latest/style-guide.html)

## 合约 & 数据结构

* 合约公开了行为并隐藏了数据 (抽象地说。实际上并未向其他人隐藏数据。实际上，区块链上没有数据被隐藏，请参见章节-合约）。这使得在不更改现有行为的情况下添加新的对象变得容易。 这也使得很难向现有对象添加新行为。
* 数据结构公开数据，没有显著的行为。这使得向现有数据结构添加新行为变得容易，但向现有函数添加新数据结构却变得困难。

由于合约的不可变性，明确区分两者是很重要的。如果希望添加逻辑或部署新合约，则希望能够利用现有的数据结构。将两者分离可以通过存储合约实现。我们将在另一篇博客文章中更详细地介绍这些。

## 系统
保持简单直白（Keep it Simple Stupid ，KISS）。 复杂性增加了出现错误和意外行为的可能性。合约应该只有一个责任，只有一个变更的理由，支持单一责任原则（Single Responsibility Principle）。它是OO设计中最重要的概念之一。

保持你的合约规模小。智能合约中的每一行代码执行起来都要花钱，存储数据也很昂贵。最佳实践是在智能合约中存储数据指针，而不是存储数据本身。例如，可以使用去中心化的数据存储提供商（如IPFS）存储数据。

将您的合约模块化，使其保持较小的规模，并利用现有的标准和库（参见章节“标准&库”）。

功能同样如此。函数应该只做一件事。他们应该做好。他们只能这样做。

在区块链上，一切都是公开的。智能合约中的私有数据和变量实际上不是私有的。 “Private”是指在合约的执行范围内，但数据是公开的，任何人都可以读取。 设计程序时请记住这一点。

仅将区块链和智能合约用于需要去中心化的部分。

> *“The first rule of functions is that they should be small. The second rule of functions is that they should be smaller than that.”*（函数的第一个规则是它们应该很小。 函数的第二个规则是它们应该比小更小） - Robert C. Martin

## 标准 & 库

智能合约的一个固有特征是它的可组合性。将每份合约变成其他人可以利用的组成部分和潜在的构建基块。 这些构件很多，已经存在，并且标准确保了易于使用和开发。最著名的标准是为新兴通证生态系统（token ecosystem）及其服务的交易所创建的：ERC20标准。

在开始编写自己的、自定义的智能合约之前，明智的做法是检查是否存在任何标准或开源组件。如果存在这样的标准合约，并且经过适当的测试和审计，它们可以将您的程序中的风险降到最低。

* 以太坊改进建议（Ethereum Improvement Proposals，EIPs）描述了以太坊平台的标准，包括合约标准 describe standards for the Ethereum platform, including contract standards. [最终的ERC](https://eips.ethereum.org/erc#final)
* [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)

## 错误处理

异常是现代软件工程的关键部分。它们需要特殊处理，并且功能非常强大。与其对抗，我们应该尝试利用它们，因为未处理的异常可能会导致意外行为。

当在Solidity代码中引发异常时，所有状态更改都将回滚并停止进一步执行。幸运的是，Solidity内置了异常处理功能（自0.6版本开始）。这仅适用于外部调用（external calls）。

为异常提供足够的上下文，以确定错误的来源和原因。尝试编写引发这些异常的测试。

尝试编写抛出这些异常的测试。

不要返回null。不要将null传递给函数。

保护检查（Guard Checks）可以帮助确保智能合约的行为及其输入参数符合预期。

正确使用 `assert()`, `require()`, `revert()` . **assert** 应该用于测试内部错误，并检查常量。**require**  应该用于测试输入，合约状态变量或来自外部合约的返回值是否有效。

如果交易没有足够的gas来执行，则不会捕获gas溢出错误。

## Testing

![](https://img.learnblockchain.cn/2020/09/04/15991846572668.jpg)


整洁代码的相同规则也适用于测试。整洁的测试是易于阅读的测试，容易理解，并且易于维护，测试可以帮助您保持代码的灵活性，可维护性和可重用性。它们可以验证行为，降低进行意外更改的风险，并节省调试和编写代码的时间。

### F.I.R.S.T

* **Fast** — 测试速度应该足够快，以便经常运行它们。它应该有助于加速您的开发过程，而不是阻碍它
* **Independent** — 测试应该相互独立并且可以按任何顺序运行
* **Repeatable** — 测试应该在任何环境中都是可重复的
* **Self-validating** — 如果测试通过，则应该有一个清晰的(布尔)输出
* **Timely** — 测试需要及时编写。就在生产代码之前。

### AAA

AAA (Arrange-Act-Assert) 模式是软件测试中最常见的标准之一。它建议将测试划分为相应的部分：arrange、act和assert。它们中的每一个都负责它们被命名的部分。 

* **Arrange** -设置测试所需的代码
* **Act** - 被测试方法的调用
* **Assert** - 检查是否达到预期

每个测试只使用一个断言。

### 测试分离

* **单元测试** 确定一个源代码单元是否适合使用。这通常是一个单独的函数，使用不同的参数进行测试，以确保它返回预期值。
* **集成测试** 确定独立开发的软件单元在连接时是否正常工作。对于智能合约，这意味着单个合约的不同组件之间或多个合约之间的交互。

### 测试覆盖率

编写好的测试来确保你的应用程序按预期工作是不够的。如果你没有测量任何东西，很难说到底有多少代码正在被测试。测试覆盖率（或代码覆盖率）是查找代码库中未测试部分的有用工具。

关于覆盖多少有很多争论。就你最好的判断，但要尽可能高。未经测试的代码可能会执行任何操作并导致意外行为。

### 测试工具

* [Buidler](https://buidler.dev/) - 一个面向以太坊智能合约开发人员的任务运行器，允许您部署合约、运行测试和调试代码
* [OpenZeppelin Test environment](https://docs.openzeppelin.com/test-environment/) - 是一个智能合约测试库：它提供帮助您编写测试的实用程序，但它不会为您运行测试。与Mocha一起工作
* [Brownie](https://github.com/eth-brownie/brownie) - 针对以太坊虚拟机的智能合约基于Python的开发和测试框架
* [Truffle](https://www.trufflesuite.com/truffle) - 使用以太坊虚拟机（EVM）的区块链开发环境、测试框架和资产管道
* [Ganache](https://www.trufflesuite.com/ganache) - 用于以太坊开发的个人区块链，可用于部署合同、开发应用程序和运行测试
* [Solidity-coverage](https://github.com/sc-forks/solidity-coverage) (原名 Solcover) - Solidity智能合约的代码覆盖率

## 安全 & 代码分析

静态代码分析是对没有实际执行程序的软件进行的分析。在大多数情况下，分析是在源代码的某个版本上执行的。分析通常由自动化工具（如Sonarqube）执行。

智能合约分析工具有助于识别智能合约漏洞。这些工具运行一套漏洞检测器，打印出发现的任何问题汇总。

### 分析工具

* [Echidna](https://github.com/crytic/echidna) - 以太坊智能合约模糊器
* [Manticore](https://github.com/trailofbits/manticore) - 符号执行工具
* [Mythril](https://github.com/ConsenSys/mythril) - EVM字节码的安全性分析工具
* [Oyente](https://github.com/melonproject/oyente) - 智能合约分析工具
* [Slither](https://github.com/crytic/slither) - Solidity静态分析工具

### Gas优化

优化gas成本可能是一项值得努力的工作，以减少您自己的部署以及最终用户的成本。 随着当前gas成本达到顶峰，网络使用量正在逐步增加。随着生态系统的不断发展，gas优化的价值也将随之增长。我们将在另一篇博客文章中更详细地介绍这些内容。

可以使用[eth-gas-reporter](https://github.com/cgewecke/eth-gas-reporter)分析代码。 它打印每个函数或每个已部署合约的gas成本估算。

## 持续集成

虽然不是整洁代码原则的一部分，但持续集成（continuous integration，CI）已经成为任何类型软件开发的基本实践。持续集成的一个主要好处是，您可以快速检测错误并更容易地定位错误。

它基于一系列关键原则。

* 保持一个存储库，所有代码都存放在其中，任何人都可以获得当前和以前的版本（例如Git）
* 自动化构建过程，以便任何人都可以使用它直接从源代码进行构建（例如Truffle团队、Travis CI）
* 自动化您的测试，这样任何人都可以在任何时候运行完整的测试套件（参见章节 测试）
* 确保任何人都可以查看结果并从构建过程中获取最新的可执行文件

> *“Continuous Integration doesn’t get rid of bugs, but it does make them dramatically easier to find and remove.”（持续集成并不能消除bug，但它确实使它们更易于查找和删除）* - Martin Fowler

![](https://img.learnblockchain.cn/2020/09/04/15991847411724.jpg) 

## 更多阅读

查看我的 [Clean Contracts](https://github.com/wslyvh/clean-contracts) 每个章节中用于支持代码示例的仓库。

* [Clean Code](https://amzn.to/30RsoKk), Robert C. Martin
* [Solidity Patterns](https://fravoll.github.io/solidity-patterns/), Fravoll
* [Ethereum Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices), ConsenSys
* [Best Practices for Smart Contract Development](https://yos.io/2019/11/10/smart-contract-development-best-practices/), Yos Riady

原文链接：https://www.wslyvh.com/clean-contracts/
作者：[Wesley van Heije](https://www.wslyvh.com/)
翻译：[volunteer1024](https://github.com/volunteer1024)


