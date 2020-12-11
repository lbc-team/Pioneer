> * 原文：[Trading and Arbitrage on Ethereum DEX: Get the rates (part 1)](https://ethereumdev.io/trading-and-arbitrage-on-ethereum-dex-get-the-rates-part-1/) 作者： https://ethereumdev.io/author/peter/
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 以太坊DEX的交易与套利：获取汇率（第1部分）



在本系列教程中，探索围绕以太坊建立使用去中心化交易所(DEX)开发一个简单的自动交易（套利）机器人。



教程中将使用Javascript，Solidity和1inch dex聚合器和闪电贷。

由于主题较多，教程将分为以下几个部分介绍：

- （本文）获取链上代币兑换汇率。
- [使用JavaScript和1inch dex聚合器进行兑换](https://ethereumdev.io/swap-tokens-with-1inch-exchange-in-javascript-dex-and-arbitrage-part-2/)。

本系列文章的目的是学习如何使用DeFi协议(例如DEX和ERC20代币)构建去中心化应用，而不是以暴富为目标哦。



![img](https://img.learnblockchain.cn/pics/20201208144434.png)

## 概念简介

**什么是去中心化交易所(DEX)？**

这是通过代码运行的兑换。在DEX，无需中间人就可以直接交易加密货币（通过合约交易）。在DEX上，每笔交易通常都写入区块链。

> 注：在本文中，去中心化交易所将简写为DEX 



**什么是DEX聚合器？**

DEX聚合器是一个平台，它通过在一揽子DEX中，找到在给定时间和数量下，最优的价格来执行兑换交易。



**什么是ERC20 Token（代币 or 通证）？**

ERC20 是以太坊区块链上的代币标准。 这里有一篇文章介绍[如何创建ERC20代币](https://learnblockchain.cn/2018/01/12/create_token).



**什么是套利？**

套利，简单的说就是在一个市场上买东西，同时在另一个市场上以更高的价格卖出东西，在短暂的的价格差中获利。

在本教程中，我们将套利特指：从一个DEX购买代币，然后在另一个DEX上以更高的价格出售。

在区块链上，早期主要的套利机会主要来自在去中心化和中心化交易之间套利。



### 关于 1inch DEX 聚合器

[1inch 交易所](https://1inch.exchange/)是一个链上去中心化交易所聚合器，由[Anton Bukov](https://github.com/k06a)和[Sergej Kunz](https://github.com/deacix) 开发，能够在一次交易中实现在多个DEX之间拆分订单，为用户提供最佳兑换汇率。 1inch 智能合约开源在[Github](https://github.com/1inch-exchange/1inchProtocol)，你可以看到如何使用智能合约来寻找交易机会。你还可以[在此处访问1inch 网站](https://1inch.exchange/#/)。

![img](https://img.learnblockchain.cn/pics/20201208144422.png)

要在1inch上执行代币兑换，步骤很简单：

- 根据输入的代币或ETH数量，获得预期可兑换的代币数量。
- 授权（Approve）交易所使用你的代币
- 使用第一步的参数进行交易

我们首先需要分析一下1inch exchange智能合约。感兴趣的函数有两个：

- *getExpectedReturn ()*
- *swap*()

### 获取预期可兑换的多少代币

* getExpectedReturn 函数不会修改链上状态，只要你连接到区块链网络节点，就可以调用getExpectedReturn() 函数，不用支付手续费。你可以 [web3.js](https://learnblockchain.cn/search?word=web3.js) 等相关的库来调用智能合约函数。

它接受交易参数，并将返回你将获得的预期代币数量以及交易如何在DEX上分布。

```javascript
function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 disableFlags
) public view
returns(
         uint256 returnAmount,
         uint256[] memory distribution
);
```

函数接受5个参数：

- fromToken ：当前拥有（用来兑换）的代币合约地址。
- toToken：要兑换代币合约地址。
- amount ：兑换所用的代币数量。
- parts ：期望可切分的份数。检查函数 distribution 返回值可以获取更多详细信息，默认情况下我们将使用 100。
- disableFlags ：启动额外的选项，例如，禁用特定的DEX

函数有2个返回值：

- returnAmount ：执行交易后将收到的代币数量。
- distribution ：uint256数组，表示兑换在不同的DEX之间分配的比例。因此，例如，如果你传递了 100作为 parts 参数，并且在Kyber上分配了25％，在Uniswap上分配了75％，则结果将如下所示：[75，25，0，0，…]。你可以在这里看到[数组中DEX的顺序](https://github.com/CryptoManiacsZone/1split/blob/master/contracts/OneSplitBase.sol#L674)。

在编写支持的DEX时，分发的格式如下：

```javascript
[
    "Uniswap",
    "Kyber",
    "Bancor",
    "Oasis",
    "CurveCompound",
    "CurveUsdt",
    "CurveY",
    "Binance",
    "Synthetix",
    "UniswapCompound",
    "UniswapChai",
    "UniswapAave"
]
```

请注意，如果你想交易Eth而不是ERC20代币，则参数 fromToken 地址使用：`0x0`或` 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeeeeEEeE `

getExpectedReturn 函数的返回值需要在*swap()*函数用到，因此很重要。

### 进行兑换

为了执行链上代币的兑换，我们将使用`swap` 函数。swap函数需要使用 `getExpectedReturn`函数的返回值，并且需要消耗 gas 去执行。如果要兑换ERC20代币，则还需要提前给 1plsit 合约（执行交易的兑换合约）授权，以便能够处理要兑换的代币。

```javascript
 function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 disableFlags
 ) public payable;
```

swap函数接受6个参数：

- fromToken ：当前拥有（用来兑换）的代币合约地址。
- toToken：想要兑换代币合约地址。
- amount：兑换所用的代币数量。
- minReturn：想要返回的最少代币数。
- distribution：代表应按什么比例分配到dex。
- disableFlags：启动额外的选项，例如，禁用特定的DEX

### 探索第一笔交易

现在，尝试使用刚才所看到的函数，通过JavaScript和智能合约获得第一次自动交易的汇率。如果你没有和合约交互过，可以阅读[相关 web3js 教程](https://learnblockchain.cn/2018/01/12/first-dapp#%E5%88%9B%E5%BB%BA%E7%94%A8%E6%88%B7%E6%8E%A5%E5%8F%A3%E5%92%8C%E6%99%BA%E8%83%BD%E5%90%88%E7%BA%A6%E4%BA%A4%E4%BA%92/).

为了大家使用方便，我们在[Github上的开放了源代码](https://github.com/jdourlens/ethereumdevio-dex-tutorial)：

```bash
git clone git@github.com:jdourlens/ethereumdevio-dex-tutorial.git && cd ethereumdevio-dex-tutorial/part1
```

安装所需的依赖项 web3.js和bignumber.js：

```bash
npm install
```

执行代码：

```bash
node index.js
```



请注意，你可能需要根据你自己的情况更改 *index.js* 文件第 15 行：以太坊提供者地址。

以下是index.js脚本的内容：

```javascript
var Web3 = require('web3');
const BigNumber = require('bignumber.js');

const oneSplitABI = require('./abis/onesplit.json');
const onesplitAddress = "0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E"; // 1plit contract address on Main net

const fromToken = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE'; // ETHEREUM
const fromTokenDecimals = 18;

const toToken = '0x6b175474e89094c44da98b954eedeac495271d0f'; // DAI Token
const toTokenDecimals = 18;

const amountToExchange = 1

const web3 = new Web3('http://127.0.0.1:8545');

const onesplitContract = new web3.eth.Contract(oneSplitABI, onesplitAddress);

const oneSplitDexes = [
    "Uniswap",
    "Kyber",
    "Bancor",
    "Oasis",
    "CurveCompound",
    "CurveUsdt",
    "CurveY",
    "Binance",
    "Synthetix",
    "UniswapCompound",
    "UniswapChai",
    "UniswapAave"
]


onesplitContract.methods.getExpectedReturn(fromToken, toToken, new BigNumber(amountToExchange).shiftedBy(fromTokenDecimals).toString(), 100, 0).call({ from: '0x9759A6Ac90977b93B58547b4A71c78317f391A28' }, function (error, result) {
    if (error) {
        console.log(error)
        return;
    }
    console.log("Trade From: " + fromToken)
    console.log("Trade To: " + toToken);
    console.log("Trade Amount: " + amountToExchange);
    console.log(new BigNumber(result.returnAmount).shiftedBy(-fromTokenDecimals).toString());
    console.log("Using Dexes:");
    for (let index = 0; index < result.distribution.length; index++) {
        console.log(oneSplitDexes[index] + ": " + result.distribution[index] + "%");
    }
});
```



注释如下：

*第4行*：加载合约ABI，用来在第17行通过web3.js实例化1split合约。

*第19行*：DEX列表，方便在第45行到第47行返回的分配数组描述分配百分比。

*第35行*：调用 *getExpectedReturn* 函数来获取交易结果。

如果你不熟悉[使用BigNumber.js库，则应阅读：如何在JavaScript中处理合约的uint256](https://ethereumdev.io/how-to-deal-with-big-numbers-in-javascript/).

执行脚本的结果应该类似于以下内容：

![img](https://img.learnblockchain.cn/pics/20201208144409.png)

在撰写本文时，DEX聚合器可以以1个以太币购买到148.47 DAI(而Coinbase汇率为148,12)。交易在两个交易所进行：Uniswap 96％和Bancor 4％。 1inch dex聚合器非常适合在去中心化交易中找到最佳汇率。

**请注意，此喂价不应该用作你的智能合约的预言机，因为由于漏洞或用户操纵，DEX会可能提供非常低的价格。**

能够轻松使用DEX聚合器是DeFi的一项很棒的功能。由于大多数协议都是开放的，因此仅需理解它们即可应用强大的去中心化金融的功能。



本文，我们探讨了如何获取两个代币之间的汇率，并获得进行兑换所需的所有信息，在[下一篇文章，我们将使用JavaScript中的1inch DEX聚合器执行兑换](https://ethereumdev.io/swap-tokens-with-1inch-exchange-in-javascript-dex-and-arbitrage-part-2/).

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。