> * 来源：https://yos.io/2019/11/10/smart-contract-development-best-practices/ 作者：[Yos Riady](https://yos.io/about/)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



## 指南：智能合约开发的最佳实践



![](https://img.learnblockchain.cn/2020/09/15/16001337715241.jpg)

软件开发的历史已有数十年之久。我们受益于半个世纪以来积累的最佳实践，设计模式和智慧。

相反，智能合约开发才刚刚开始。2015推出的以太坊和 Solidity 仅有几年的时间。

加密空间是一个不断发展的未知领域。**没有确定的工具堆栈**来构建去中心化应用。对于智能合约，没有诸如[设计模式](https://en.wikipedia.org/wiki/Design_Patterns)或[代码整洁之道](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)之类的开发人员手册。有关工具和最佳实践的信息遍布各处。

你正在阅读**我这份希望它已经存在的指南**。总结了我从以太坊生态系统中编写智能合约，构建去中心化应用程序和开源项目中学到的经验教训。


>💡这本手册是线上的文件。如果你有任何反馈或建议，请随时发表评论或[直接给我发送电子邮件](mailto：hello@yos.io)。

## 这是给谁的

本手册适用于：

* 刚开始使用智能合约的开发人员，以及
* 经验丰富的Solidity开发人员希望将他们的工作提升到一个新的水平。



但是，这并不意味着要介绍[Solidity](https://learnblockchain.cn/docs/solidity/)语言。



那就直接开始正文吧，以下我的一些建议：



## 使用开发环境

使用[Truffle](https://learnblockchain.cn/docs/truffle/)之类的开发环境(或者，[Embark](https://learnblockchain.cn/article/566), [Builder](https://buidler.dev/) [dapp.tools](http://dapp.tools/))等开发环境可以快速高效地工作。

![](https://img.learnblockchain.cn/2020/09/15/16001341569297.jpg)

使用开发环境可以加快经常重复执行的任务，例如：

* 编译合约
* 部署合约
* 调试合约
* 升级合约
* 运行单元测试

![](https://img.learnblockchain.cn/2020/09/15/16001343301985.jpg)


例如，Truffle 提供以下有用的命令：

* **compile：**将Solidity合约编译为其ABI和字节码格式。
* **console**：实例化一个交互式JS控制台，你可以在其中调用web3合约并与之交互。
* **test**：运行合约的单元测试套件。
* **migrate**：将你的合约部署到网络。

Truffle支持提供其他功能的插件。例如，[`truffle-security`](https://github.com/ConsenSys/truffle-security)提供智能合约安全性验证。 [`truffle-plugin-verify`](https://learnblockchain.cn/article/1314)在区块链浏览器上发布你的合约。你还可以创建[自定义插件](https://www.trufflesuite.com/docs/truffle/getting-started/writing-external-scripts＃creating-a-custom-command-plugin)。

同样，[Builder](https://hardhat.org/plugins/) 也有越来越多的插件支持给以太坊智能合约开发人员使用。

无论使用哪种开发环境，选择一套好的工具都是必须。

## 本地开发

使用[Ganache](https://www.trufflesuite.com/ganache)(或[Ganache CLI](https://github.com/trufflesuite/ganache-cli))运行本地区块链进行开发，以“加快迭代周期”。

![](https://img.learnblockchain.cn/2020/09/15/16001346187508.jpg)

在主网上，以太坊交易[得付费](https://www.investopedia.com/terms/g/gas-ethereum.asp)，可能需要[数分钟](https://ethgasstation.info/)才确认。使用本地链跳过所有这些等待。在本地运行合约交易免费且即时。

![](https://img.learnblockchain.cn/2020/09/15/16001346606172.jpg)

Ganache带有一个内置的区块浏览器，可显示你解码后的交易、合约和事件。且本地环境是[可配置](https://www.trufflesuite.com/docs/ganache/reference/ganache-settings)，以满足你的测试需求。

且设置简便快捷。 [在这里下载](https://www.trufflesuite.com/ganache).

## 使用静态分析工具

静态分析或“linting”通过运行程序分析代码中的编程错误。在智能合约开发中，这对于捕获编译器可能错过的“代码风格不一致”和“易受攻击的代码”很有用。

### 1. Linters

![](https://img.learnblockchain.cn/2020/09/15/16001347755489.jpg)

使用[solhint](https://github.com/protofire/solhint)和[Ethlint](https://github.com/duaraghav8/Ethlint) 分析代码，Solidity的Linter与其他语言(例如JSLint)的linter相似。它们提供安全性和代码风格指南验证。

### 2.安全性分析

![](https://img.learnblockchain.cn/2020/09/15/16001352402449.jpg)

安全分析工具识别[智能合约漏洞](https://yos.io/2018/10/20/smart-contract-vulnerabilities-and-how-to-mitigate-them/)，这些工具运行一组漏洞检测器，并打印出发现的所有问题的摘要。开发人员可以在整个实现阶段使用此信息来查找和解决漏洞。

可以选择：[Mythril](https://github.com/ConsenSys/mythril)·[Slither](https://github.com/crytic/slither)·[Manticore](https://github.com/trailofbits/manticore)·[MythX](https://mythx.io/)·[Echidna](https://github.com/crytic/echidna)·[Oyente](https://github.com/melonproject/oyente)

### 额外：使用Pre-Commit Hook

通过使用[`husky`](https://github.com/typicode/husky)设置[Git Hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)，使你的开发人员体验变得无缝，Pre-Commit Hook可让你在每次提交之前运行linters。例如：



```
// package.json
{
  "scripts": {
    "lint": "./node_modules/.bin/solhint -f table contracts/**/*.sol",
  },
  "husky": {
    "hooks": {
      "pre-commit": "npm run lint"
    }
  },
}
```


上面的代码片段在每次提交之前运行一个预定义的`lint` 任务，如果代码中存在突出的样式或安全性违规，则会失败。此设置使你团队中的开发人员能够在迭代中与linter一起使用。

## 了解安全漏洞

编写没有错误的软件非常困难。防御性编程技术只能走这么远。幸运的是，你可以通过部署新代码来修复错误。传统软件开发中的补丁程序频繁且直接。

![](https://img.learnblockchain.cn/2020/09/15/16001353110014.jpg)


但是，智能合约是“不可变更的”。有时无法[升级](https://yos.io/2018/10/28/upgrading-solidity-smart-contracts/)已生效的合约。在这方面，智能合约比软件开发更接近于虚拟硬件开发。

更糟糕的是，合约错误会导致巨大的财务损失。 [DAO Hack](https://medium.com/swlh/the-story-of-the-dao-its-history-and-consequences-71e6a8a551ee)损失了超过1150万以太币(在被黑客入侵时为7000万美元，现在超过了20亿美元)，第二名[Parity Hack](https://hackernoon.com/parity-wallet-hack-2-electric-boogaloo-e493f2365303)损失了2亿美元的用户资金，现在DeFi领域[$ 百亿](https://defipulse.com/)市场规模一旦出错，损失将非常惨重。

智能合约开发需要与Web开发完全不同的心态。 “快速行动并打破常规”在这里不适用。你需要预先投入大量资源来编写无错误的软件。作为开发人员，你必须：

1. 熟悉Solidity [安全性](https://yos.io/2019/11/10/smart-contract-development-best-practices/) [漏洞](https://yos.io/2018/10/20/smart-contract-vulnerabilities-and-how-to-mitigate-them/),和

2. 扎实理解[设计](https://consensys.github.io/smart-contract-best-practices/recommendations/)和 [模式](https://github.com/fravoll/solidity-patterns)，例如：付款提取与推送方式 以及遵循 ”检查“ - "更改" - ”交互“等。

3. 使用防御性编程技术：静态分析和单元测试。

4. 审计你的代码。

以下各节将详细说明要点(3)和(4)。

>💡**初学者提示：**你可以使用[Ethernauts](https://ethernaut.openzeppelin.com/)以交互方式练习Solidity安全性。

## 编写单元测试

借助**全面的测试套件**，尽早发现错误和意外行为。不同的场景测试协议可帮助你识别极端情况。

Truffle使用[Mocha](https://mochajs.org/)测试框架和[Chai](https://www.chaijs.com/)进行断言。你可以使用Javascript针对合约的包装器编写单元测试，就像前端[DApp](https://learnblockchain.cn/tags/DApp)如何调用你的合约。

![](https://img.learnblockchain.cn/2020/09/15/16001353660527.jpg)


从Truffle v5.1.0开始，你可以中断测试以对测试流程进行[debug](https://www.trufflesuite.com/docs/truffle/getting-started/debugging-your-contracts＃in-test-debugging)并启动调试器，从而允许你设置断点，检查Solidity变量等。

![](https://img.learnblockchain.cn/2020/09/15/16001353786145.jpg)

Truffle缺少一些对于测试智能合约必不可少的功能。安装[openzeppelin-test-helpers](https://github.com/OpenZeppelin/openzeppelin-test-helpers)可让你访问许多重要的实用工具以验证合约状态，例如**匹配合约事件**和**向前移动时间**。

译者注： 调试智能合约还有一个选择是使用 [Build EVM 及 console.log](https://learnblockchain.cn/article/1371), 它支持在Solidity源码中打印日志查看变量。

>或者，如果你更喜欢使用其他测试运行器，[OpenZeppelin测试环境](https://github.com/OpenZeppelin/openzeppelin-test-environment)提供了与工具无关的选项。

## 衡量测试覆盖率

编写测试是不够的。你的测试套件必须可靠地捕获回归。**[测试覆盖率](https://en.wikipedia.org/wiki/Code_coverage)**衡量测试的有效性。


![](https://img.learnblockchain.cn/2020/09/15/16001354069788.jpg)


具有较高测试覆盖率的程序在测试期间将执行更多代码。这意味着与覆盖率较低的代码相比，它更容易发现未被检测到的错误。

你可以使用[`solidity-coverage`](https://github.com/sc-forks/solidity-coverage)收集Solidity代码覆盖率

### 配置持续集成

拥有测试套件后，请“尽可能频繁地”运行它。有几种方法可以实现此目的：

1. 像我们之前介绍的，设置Git Hook，或者
2. 设置一个CI（持续集成：Continuous integration） 管道，在每次Git推送后执行测试。

如果你要使用现成的CI，请查看[Truffle团队](https://www.trufflesuite.com/teams)或[super blocks](https://superblocks.com/).，它们为连续进行智能合约测试提供了托管环境。

![](https://img.learnblockchain.cn/2020/09/15/16001354347819.jpg)


托管CI会定期运行你的单元测试，以最大程度地放心。你还可以监视已部署合约的交易，状态和事件。

## 安全审计合约

安全审计可帮助你“发现”防御性编程技术(linting，单元测试，设计模式)所遗漏的未知问题。

![](https://img.learnblockchain.cn/2020/09/15/16001354443476.jpg)


在这个探索阶段，你需要尽最大努力破坏合约， 如：提供意外的输入，以不同的角色调用函数等。

没有什么可以取代人工安全审计，尤其是当黑客入侵的是[整个DeFi生态系统](https://medium.com/@peckshield/bzx-hack-full-disclosure-with-detailed-profit-analysis-e6b1fa9b18fc)时。

>⚠️在进行下一阶段之前，你的代码应该已经通过了前面部分提到的静态分析。

## 聘请外部审计师

聘请(昂贵的)安全审计员来升级以太坊中的主要协议，他们深入研究其代码以发现潜在的安全漏洞。这些审计员结合使用专有和开源静态分析工具，例如：

* [Manticore](https://github.com/trailofbits/manticore/releases/tag/0.1.6) - 一个模拟器，能够模拟针对EVM字节码的复杂的多合约和多交易攻击。
* [Ethersplay](https://github.com/crytic/ethersplay) - 一种图形化EVM反汇编程序，能够进行方法还原，动态跳转计算，源代码匹配和二进制比较。
* [Slither](https://github.com/crytic/slither) - 静态分析器，它检测常见错误，例如重入错误，构造函数，方法访问等。
* [Echidna](https://github.com/crytic/echidna) - 面向EVM字节码的下一代智能模糊器。



审计员将帮助**识别协议中任何设计和架构级别的风险**，并知道你关于常见的智能合约漏洞。

![](https://img.learnblockchain.cn/2020/09/15/16001354660778.jpg)


在该过程的最后，你将获得一份报告，其中总结了审计师的发现和建议的缓解措施。你可以通过阅读[ChainSecurity](https://github.com/ChainSecurity/audits), [OpenZeppelin](https://blog.openzeppelin.com/security-audits/), [Consensys Diligence](https://diligence.consensys.net/audits/),和[TrailOfBits](https://github.com/trailofbits/publications/tree/master/reviews)的审计报告，以了解在安全审计过程中发现了哪些问题。

## 使用经过审计的开源合约

使用经过”经过战斗检验的开放源代码（都经过安全审计）”从第一天开始保护你的代码。使用经过审计的代码“减少了以后需要审计的代码量“。

![](https://img.learnblockchain.cn/2020/09/15/16001354825935.jpg)

[OpenZeppelin合约](https://github.com/openzeppelin/openzeppelin-contracts)是以Solidity编写的模块化、可重用智能合约的框架。它包括流行的ERC标准的实现，例如ERC20和ERC721通证。它具有以下功能：

* 访问控制：允许谁执行操作。
* [ERC20](https://docs.openzeppelin.com/contracts/3.x/tokens#ERC20)和[ER721](https://docs.openzeppelin.com/contracts/3.x/tokens＃ERC721)通证：流行的通证标准的开源实现，以及[可选模块](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token).
* [加油站网络 Gas Stations Network ](https://docs.openzeppelin.com/contracts/3.x/gsn):  用户无需支付 gas 。
* 实用库：` SafeMath`，` ECDSA`，`Escrow`和其他实用工具合约。

你可以按原样部署这些合约，也可以将其扩展以满足更大系统中的需求。

>💡**初学者提示：**诸如OpenZeppelin Contracts之类的开源Solidity项目对于新开发人员而言是极好的学习材料。他们提供了关于智能合约可能实现的可读性介绍。不要犹豫，克隆下来！ [从这里开始](https://docs.openzeppelin.com/contracts/3.x/).

## 在公共测试网上发布

在以太坊主网上启动协议之前，请考虑**在[公共测试网](https://medium.com/compound-finance/the-beginners-guide-to-using-an-ethereum-test-network-95bbbc85fc1d)**上发布。 [Rinkeby](https://www.rinkeby.io/#stats)和[Kovan](https://kovan-testnet.github.io/website/)测试网的出块时间比主网要快，并且可以免费[请求](https://faucet.rinkeby.io/)到测试以太币。

![](https://img.learnblockchain.cn/2020/09/15/16001355114662.jpg)


在测试网阶段，组织一个“漏洞赏金”程序。你的用户和更大的以太坊安全社区可以帮助你识别协议中任何剩余的关键缺陷(以换取金钱上的回报)。

## 考虑形式化验证

[形式化验证](https://en.wikipedia.org/wiki/Formal_verification)是使用形式化的数学方法来证明或证伪形式化算法的正确性的行为。验证是通过对系统的数学模型(例如有限状态机和标记的过渡)提供形式证明来完成的。

![](https://img.learnblockchain.cn/2020/09/15/16001355225672.jpg)


形式化验证未能获得成功的原因是因为**花费大量精力来验证一小段相对简单的代码**。仅在医疗系统和航空电子设备等对安全至关重要的领域中，投资回报才是合理的。如果你不是为医疗设备或火箭编写代码，则可以容忍错误并进行迭代修复。

但是，Amazon Web Services(AWS)的团队已使用Leslie Lamport的[TLA +](https://learntla.com/introduction/example/)的正式验证来[验证S3和DynamoDB的正确性](https://blog.acolyer.org/2014/11/24/use-of-formal-methods-at-amazon-web-services/):

>“在每种情况下，TLA +都可以带来显着的价值，要么找到我们确定无法通过其他方式发现的细微错误，要么为我们提供足够的理解力和信心，从而在不牺牲正确性的情况下进行积极的性能优化。”

智能合约开发需要彻底转变观念。你需要大量的严格性和强度来制作无法被黑客入侵并能够按预期运行的软件。考虑到智能合约的约束，可以进行形式化验证的决定是合理的。毕竟，你只有一次机会让他正确。

![](https://img.learnblockchain.cn/2020/09/15/16001355329539.jpg)


在以太坊生态系统中，可用的模型检查器包括：

* [VerX](https://medium.com/chainsecurity/verx-full-functional-verification-for-ethereum-contracts-now-at-your-fingertips-f8d20085e4ec)是针对以太坊合约进行自定义函数条件的自动验证器。 VerX接受Solidity代码和以VerX规范语言编写的函数条件作为输入，并验证该属性是否持有或输出一系列可能导致违反该属性条件的交易。

* [cadCAD](https://cadcad.org/)是一个Python软件包，可通过模拟器协助设计，测试和验证复杂系统的过程，并支持Monte Carlo方法，A/B测试和参数扫描。 [Clovers](https://www.youtube.com/watch?v=5Eg360OC6Qg)项目中已使用它来模拟加密经济学模型。

* [KLab](https://github.com/dapphub/klab)是用于在K框架中生成和调试证明的工具，专门用于以太坊智能合约的形式验证。它包括用于表达以太坊合约行为的简洁规范语言和交互式调试器。

作为参考，你可以前往[此处](https://github.com/runtimeverification/verified-smart-contracts)查看形式化验证的示例结果.

## 以安全的方式存储密钥

如何以[安全方式](https://silentcicero.gitbooks.io/pro-tips-for-ethereum-wallet-management/)存储以太坊账户的私钥，这里有一些建议：

* [安全地生成熵](https://iancoleman.io/bip39/)。
* 不要在任何地方发布或发送你的助记词。如果必须，请使用加密的通信通道，例如[Keybase Chat](https://keybase.io/).
* 请使用硬件钱包，例如[Ledger](https://www.ledger.com/).
* 对于特别敏感的帐户，请使用多签名钱包([Gnosis Safe](https://gnosis-safe.io/))。

![](https://img.learnblockchain.cn/2020/09/15/16001355452470.jpg)


>💡随着[智能合约钱包](https://medium.com/argenthq/recap-on-why-smart-contract-wallets-are-the-future-7d6725a38532)的兴起，随着时间的流逝，助记词可能会越来越少。

##  开源

智能合约可实现无限制的创新，任何人都可以在其上进行创新。这就是区块链真正有用的地方：公开，可编程和可验证的计算。

如果你要构建DeFi协议，就会希望吸引第三方开发人员。为了吸引开发人员，你需要证明自己不会[在之后更改游戏规则](https://news.ycombinator.com/item?id=19854381)，开放源代码可以增强信心。

![](https://img.learnblockchain.cn/2020/09/15/16001355596142.jpg)

开发源代码，也允许任何人在出现问题时分叉你的代码。

>💡请记住[在Etherscan上验证你的合约](https://yos.io/2019/08/10/verify-smart-contracts-on-etherscan/).

## 优先考虑开发者体验

在很长的时间内，整合付款功能真的很困难。早期付款公司缺乏现代代码库，并且几乎不存在API，客户端库和文档之类的东西。 [Stripe](https://growthhackers.com/growth-studies/how-stripe-marketed-to-developers-so-effectively)使开发人员可以轻松地向其软件添加付款。他们现在非常成功。

协议的开发者体验(DevEx)是至关重要的。使其他开发人员可以轻松地使用[开发者友好的API](https://yos.io/2018/02/14/api-developer-portal-best-practices/).在你的协议上进行构建，以下是两个建议：

* 提供合约SDK和示例代码
* 写好的文档

开发者中心网站的用户体验，API文档的完整性，人们为他们的用例寻找合适的解决方案的难易程度以及开发人员开始调用你的合约的速度，都是能否采用至关重要的原因。

>  [0x](https://0x.org/)协议可能是开发者体验的黄金标准。它们的高采用率证明了该协议的价值和启动的顺利。



社区参与也起着重要的作用。开发人员如何找到你？你在哪里与开发人员联系？是什么使你的项目更具吸引力？从长远来看，围绕你的项目建立一个活跃的社区将有助于推动采用。加密开发者社区在各种Twitter，Telegram和Discord频道上都很活跃。

### 提供合约SDK

为许多编程语言编写和维护健壮的客户端库并非易事。提供SDK可以帮助开发者基于你的协议进行构建。

![](https://img.learnblockchain.cn/2020/09/15/16001355719566.jpg)


使用[typechain](https://github.com/ethereum-ts/TypeChain), [truffle-contract](https://www.npmjs.com/package/truffle-contract), [ethers](https://docs.ethers.io/v5/api/contract/),或[web3.js](https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html))构建的合约包装使调用合约就像调用Javascript函数一样简单。将SDK分发为开发人员可以安装的NPM软件包。



```js
var provider = new Web3.providers.HttpProvider("http://localhost:8545");
var contract = require("truffle-contract");

var MyContract = contract({
  abi: ...,
  unlinked_binary: ...,
  address: ..., // optional
  // many more
})
MyContract.setProvider(provider);

const c = await MyContract.deployed();
const result = await c.someFunction(5); // Calls a smart contract
```



>💡拥有客户端SDK可以极大地减少开发人员入门所需的工作量，尤其是对于那些对特定编程语言不熟悉的开发人员而言。
> 
>有些项目更进一步，并提供了可以运行和部署的功能齐全的代码库。例如，[0x Launch Kit](https://0x.org/launch-kit)提供了开箱即用的去中心化交易所。

### 写好的文档

在开源软件上进行构建可以减少开发时间，但需要权衡取舍：学习如何使用它需要时间。好的文档可以减少开发人员花在学习上的时间。

![](https://img.learnblockchain.cn/2020/09/15/16001356010442.jpg)

[文档](https://www.divio.com/blog/documentation/)的类型很多:

* **高层次介绍**：用纯英语描述你的协议的作用。明确说明协议的功能。该部分使决策者可以评估你的产品是否适合他们的场景。
* 更详细**教程**：逐步说明和解释各种组件是什么，以及如何操纵它们以实现特定目标。教程应努力使步骤之间的内容清晰，简洁，均匀递进。使用大量的代码示例来鼓励复制/粘贴。
* **API参考手册**记录了智能合约，函数和参数的技术细节。

诸如[`leafleth`](https://github.com/clemlak/leafleth)之类的工具可让你使用[NatSpec](https://solidity.readthedocs.io/en/develop/natspec-format.html)注释生成自动文档，并创建一个网站来发布文档。

>💡要记录HTTP API，可以尝试[`redoc`](https://github.com/Redocly/redoc)或[`slate`](https://github.com/slatedocs/slate)，你可以 [在这里](https://github.com/yosriady/api-development-tools)找到其他有用的资源来构建HTTP API.



## 生成CLI工具和Runbook



Runbook是经过编码的步骤，可以实现特定的结果。 Runbook应包含成功执行该过程所需的最少信息。

构建内部CLI工具和[runbooks](https://wa.aws.amazon.com/wat.concept.runbook.en.html)以改善操作。对于智能合约，这通常是[script](https://www.trufflesuite.com/docs/truffle/getting-started/writing-external-scripts)，其中包含一个或多个执行业务操作的合约调用。

如果出现问题，Runbooks为不熟悉步骤或工作负载的开发人员提供成功完成诸如恢复操作之类的活动所需的说明。编写Runbook的过程还使你准备好处理潜在的故障模式。进行内部练习以找出潜在的故障根源，以便将其消除或减轻。

>💡首先，选择一个有效的手动过程，以代码形式实现，并在适当的时候触发自动执行。



## 设置事件监控

有效管理合约事件对于[卓越运营](https://wa.aws.amazon.com/wat.pillar.operationalExcellence.en.html)是必不可少的。智能合约的事件监视系统可让你随时了解系统的实时更改。如果你要构建DeFi协议，则价格下滑警报对于防止黑客入侵特别有用。

![](https://img.learnblockchain.cn/2020/09/15/16001356150127.jpg)


你可以使用[`web3.js`](https://learnblockchain.cn/docs/web3.js/)推出自己的监视后端，或使用诸如[Dagger](https://matic.network/dagger/), [Blocknative Notify](https://www.blocknative.com/notify), [Tenderly](https://tenderly.co/),或[Alchemy Notify](https://notify.alchemyapi.io/)之类的专用服务。

## 构建DApp后端

DApp需要一种从智能合约读取和转换数据的方法。但是，链上数据并非总是以易于读取的格式存储。对于面向用户的Web和移动应用程序而言，直接从以太坊节点读取合约数据有时太慢。相反，你需要将数据索引为更易于访问的格式。

![](https://img.learnblockchain.cn/2020/09/15/16001356573712.jpg)

[theGraph](https://thegraph.com/explorer/)为你的智能合约提供托管的GraphQL索引服务。在去中心化的网络上进行查询处理，以确保数据保持开放状态，并且无论如何DApp都可以继续运行。

或者，你可以构建自己的索引服务。该服务将与以太坊节点通信并订阅相关合约事件，执行转换并将结果保存为读取优化格式。如果你决定自己动手，则可以使用[开源实现](https://github.com/AugurProject/augur-node)作为参考。无论哪种方式，都需要将该服务托管在某个地方。





## 关于构建DApp前端



>  世界各地的司法管辖区缺乏明确的监管规定，这意味着[控制权可能变成责任](https://vitalik.ca/general/2019/05/09/control_as_liability.html)。要解决此问题，请将系统的一部分[去中心化](https://onezero.medium.com/why-decentralization-matters-5e3f79f7638e)和非监护权帮助减少该责任。



前端应用程序允许用户与智能合约进行交互。示例包括[Augur](https://www.augur.net/ipfs-redirect.html)和[Compound](https://app.compound.finance/)应用程序。 DApp前端通常托管在中央服务器中，但也可以托管在去中心化的[IPFS](https://ipfs.io/)网络上，以进一步引入去中心化性并减少责任。

![](https://img.learnblockchain.cn/2020/09/15/16001356707275.jpg)

前端dApp通过客户端库(例如[`web3.js`](https://learnblockchain.cn/docs/web3.js/)和[ethers.js](https://learnblockchain.cn/docs/ethers.js/))从以太坊节点加载智能合约数据。

[Drizzle](https://www.trufflesuite.com/drizzle), [web3-react](https://github.com/NoahZinsmeister/web3-react),和[subspace](https://github.com/embarklabs/subspace)之类的库提供了更高级别的功能，这些功能简化了与web3提供程序的连接和合约数据的读取。

有几种可用的DApp样板，例如[create-eth-app](https://github.com/PaulRBerg/create-eth-app/), [scaffold-eth](https://github.com/austintgriffith/scaffold-eth), [OpenZeppelin入门工具包](https://docs.openzeppelin.com/starter-kits/tutorial),和[Truffle的Drizzle Box](https://github.com/truffle-box/drizzle-box). 他们包含了在React应用程序中使用智能合约需要的内容。



>💡前端也可以调用后端，而不是仅以太坊节点读取合约数据，该后端将智能合约事件索引为经过读取优化的格式。有关更多详细信息，请参见上面的构建 Dapp 后端。

## 为可用性努力

加密存在可用性问题。**gas费**和**助记词**对于新用户来说是令人生畏的。幸运的是，加密用户体验正在快速改善。

![](https://img.learnblockchain.cn/2020/09/15/16001358555774.jpg)

[元交易（Meta Transaction）](https://medium.com/@andreafspeziale/understanding-ethereum-meta-transaction-d0d632da4eb2)和[Gas Station 网络（GSN）](https://www.opengsn.org/)提供了解决gas 费用问题的方法。元交易允许服务代表用户支付 gas 费，从而无需用户持有以太币。元交易还允许用户使用其他代币而不是ETH支付费用。通过巧妙地使用[加密签名](https://yos.io/2018/11/16/ethereum-signatures/)可以实现这些改进，而GSN可以将这些元交易分布在支付费用的中继器网络中。

![](https://img.learnblockchain.cn/2020/09/15/16001358656705.jpg)


托管钱包和智能合约钱包无需浏览器插件和助记词。此类别下的项目包括[Fortmatic](https://fortmatic.com/), [Portis](https://www.portis.io/), [Bitski](https://www.bitski.com/), [SquareLink](https://squarelink.com/), [Universal Login](https://unilogin.io/), [Torus](https://tor.us/), [Argent](https://www.argent.xyz/),和[ walletconnect](https://walletconnect.org/).

>💡考虑使用[web3modal](https://github.com/Web3Modal/web3modal)库添加对主要钱包的支持。

## 注意其他协议的构建

以太坊已经创建了一个[数字金融栈](https://medium.com/pov-crypto/ethereum-the-digital-finance-stack-4ba988c6c14b).，这些金融协议是在彼此之间构建的，并由智能合约的无许可和可组合性质提供支持。这些协议包括：

* **MakerDAO：**数字稳定币，Dai。
* **Compound**：数字货币借贷。
* **Uniswap**：数字货币交易。
* **Augur**：数字预测市场。
* **dYdX：**通过算法管理的衍生市场。
* **UMA：**合成通证平台。
* 还有很多…

每个协议都为其他协议提供了基础，以构建更复杂的产品。

![](https://img.learnblockchain.cn/2020/09/15/16001358868617.jpg)


如果以太坊是“资金的互联网”，那么去中心化金融协议就是“资金乐高”。每个金融积木块都为在以太坊上构建的新事物打开了大门。随着“资金乐高”数量的增加，新型金融产品的数量也随之增加。我们才刚刚开始探索一切可能的事物。

> 只需看一下[DAI的质押品种](https://medium.com/bzxnetwork/a-tour-of-the-varieties-of-dai-9ff155f7666c)，你就可以感受DeFi领域创新的飞速步伐。

不要孤立地重新发明轮子，**与其他协议一起思考**。不要做已有协议的克隆，而应该为已有的部分构建或和他一起构建。与在中心化平台上构建相比，智能合约的访问权不会被你拿走。

不要孤立地重新发明轮子理念也可以扩展到中心化的服务。你可以使用不断增长的基础生态系统：

* [Infura](https://infura.io/), [Azure区块链](https://azure.microsoft.com/es-es/blog/ethereum-blockchain-as-a-service-now-on-azure/), [QuikNode](https://www.quiknode.io/), [Nodesmith](https://nodesmith.io/):托管的以太坊节点使你不必头痛自己去运行。
* [3box](https://docs.3box.io/):用于评论和用户个人资料的去中心化存储和社交API。
* [zksync](https://zksync.io/):用于在以太坊上扩展支付和智能合约的协议。
* [Matic](https://matic.network/):更快，成本更低的交易。

越来越多的基础设施可以让你更快地发布更好的DApp。

## 了解系统性风险

![](https://img.learnblockchain.cn/2020/09/15/16001359040167.jpg)

在DeFi上进行构建时，你必须评估协议/货币是否带来了比风险更多的价值。

### 1. 智能合约风险

智能合约可能存在错误。始终考虑在你依赖的协议中发现错误的可能性。

[DeFi Score](https://defiscore.io/)提供了一种量化智能合约风险的方法。该指标取决于是否已对关联的智能合约进行了审计，协议已使用了多长时间，协议迄今已管理的资金量等。

智能合约风险**随着更多协议的组合而更加复杂**，类似于[SLA分数的计算方式](https://devops.stackexchange.com/questions/711/how-do-you-calculate-the-compound-service-level-agreement-sla-for-cloud-servic)。由于智能合约的无需授权组合性，单个缺陷会级联到所有相关系统中。

### 2. 治理风险

协议如何治理？一些治理模型可能直接控制资金或某些媒介控制治理体系，它他们的攻击可能暴露控制权和资金丢失。

你可以通过控制协议的参与者数量以及持有者数量来评估治理风险。

不同的协议具有不同程度的去中心化和控制权。警惕较小社区共识且记录有限的协议。

### 3. 减轻风险

遵循以下基本原则来减轻总体风险：

* 仅与经审计的智能合约进行交互。
* 仅与具有重要社区和产品的流动货币进行交互。
* 购买[智能合约保险](https://nexusmutual.io/).

## 参与开发社区

智能合约的发展正在迅速发展，全球各地才华横溢的团队推出了新的工具和标准。

![](https://img.learnblockchain.cn/2020/09/15/16001359297942.jpg)


通过访问在线以太坊社区来了解该领域的最新动态：[ETH Research](https://ethresear.ch/), [Ethereum Magicians](https://ethereum-magicians.org/), [r/ethdev](https://www.reddit.com/r/ethdev/), [OpenZeppelin论坛](https://forum.openzeppelin.com/),和[EIPs Github repo ](https://github.com/ethereum/EIPs).

## 订阅新闻通讯

新闻通讯是与以太坊生态系统保持同步的好方法。我建议订阅[以太坊每周](https://weekinethereumnews.com/)和[EthHub每周](https://ethhub.substack.com/).

## 结束语

这本手册是一份有生命的文件。随着以太坊开发者生态系统的成长和发展，新工具将会出现，而旧技术可能会过时。

如果你有任何反馈或建议，请随时发表评论或[直接给我发送电子邮件](mailto：hello@yos.io)。


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。