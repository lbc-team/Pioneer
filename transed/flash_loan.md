> * 原文：https://ethereumdev.io/making-a-flash-loan-with-solidity-aave-dy-dx-kollateral/ 作者：peter
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 概述：通过Solidity进行闪电贷(Aave，Dy/Dx，Kollateral)



![img](https://img.learnblockchain.cn/2020/12/16/ashloans.png)

闪电贷是指借用资产的贷款，在交易结束前就已归还资金(和费用)。此类贷款使你仅需花费很少的费用(在撰写Aave时为0.09％，在Dy/Dx中为0％)即可无担保的使用资金。闪电贷可用于跨DEX的套利，Dy/Dx等协议的头寸清算以及CDP（Collateralized Debt Positions：抵押债仓）的迁移。

在本教程中，我们将介绍你在Solidity智能合约中进行闪电贷的不同方式。如果你想了解更多有关可以用于闪电贷的信息，我们建议你阅读几篇文章:[什么是闪电贷](https://hedgetrade.com/what-are-defi-flash-loans/), [这篇报告](https://arxiv.org/pdf/2003.03810.pdf)或[这个文章](https://medium.com/aave/flash-loans-one-month-in-73bde954a239).

另一种获取有关如何使用闪电贷如何工作的好方法是[在区块浏览器中检查使用闪电贷的某些交易，看看它们都做了什么](https://aavewatch.now.sh/flash-loans).

当前可用的闪电贷协议仅提供每笔交易借入一项资产，但是如果你拥有ETH，则可以很容易地通过它来轻松铸造获得DAI，或者可以[使用1inch聚合器兑换到任何其他代币](https://learnblockchain.cn/article/1856)。

以下是可用于在以太坊区块链上执行闪电贷的不同协议：

![img](https://img.learnblockchain.cn/2020/12/16/11-56-55.png)

## 使用Aave进行闪电贷

Aave是一个开源和非托管协议，旨在获取存款和借贷资产的利息。由于他们的文档确实完善，因此我建议你[查看他们的文档](https://docs.aave.com/developers/tutorials/performing-a-flash-loan).



👍**优势**：

- 简短方便的代码
- 大量可用资产(ETH，USDC，DAI，MAKER，REP，BAT，TUSD，USDT ..)
- ETH直接以太币提供
- 很棒的文档和社区支持

👎**缺点**：

- 需要 0.09% 的费用)

[访问AAVE文档](https://docs.aave.com/developers/tutorials/performing-a-flash-loan)

------

![img](https://img.learnblockchain.cn/2020/12/16/1024x294.png)

## 用Dy/Dx进行闪电贷

DyDx确实提供本地闪电贷。但是你仍然可以通过对SoloMargin合约执行一系列操作来实现类似的行为。为了模仿DyDx上的Aave Flashloan，你需要：

- 借入一定数量的代币
- 使用借入资金调用函数
- 退回接入的代币(+2 wei)

你可以在[Money Legos 网站上找到一个实现示例](https://money-legos.studydefi.com/#/dydx)。此实现基于上面列出的Kollateral的源代码。

👍**优势**：

- 免费(仅2 wei)

👎**缺点**：

- 使用的是ETH的包裹(WETH)
- 代码可读性较低
- 可用代币很少(ETH/USDC/DAI)

[检查代码](https://money-legos.studydefi.com/#/dydx)

------

## 使用 Kollateral 的闪电贷

[Kollateral](https://www.kollateral.co/)是一个智能合约，可汇总来自Aave和Dy/Dx平台的流动资金，并通过简单的界面展示给开发人员。

👍**优势**：

- 简洁的代码
- 使用多种协议的资产

👎**缺点**：

- 不清楚费用是多少
- 有项目的依赖项

带有Kollateral的闪电贷的代码如下所示：

```javascript
import "@kollateral/contracts/invoke/KollateralInvokable.sol";
contract MyContract is KollateralInvokable {
  constructor () public { }
  function execute(bytes calldata data) external payable {
    // liquidate
    // swap
    // refinance
    // etc...
    repay();
  }
}
```

可以通过一种非常简单的方式从javaScript调用：

```javascript
import { Kollateral, Token } from '@kollateral/kollateral'
const kollateral = await Kollateral.init(ethereum);
kollateral.invoke({
    contract: myContractAddress
}, {
  token: Token.DAI,
  amount: web3.utils.toWei(1000)
}).then(() => console.log("success!");
```

[访问Kollateral文档](https://www.kollateral.co/)


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。