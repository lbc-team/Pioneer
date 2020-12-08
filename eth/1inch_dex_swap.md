> * 原文：https://ethereumdev.io/swap-tokens-with-1inch-exchange-in-javascript-dex-and-arbitrage-part-2/  作者：https://ethereumdev.io/author/peter/
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 以太坊DEX的交易与套利：兑换（第2部分）



对于本教程，将了解如何使用[1inch DEX 聚合器](https://1inch.exchange/)执行交易使用web3.js库的Javascript中的。通过本教程，你将了解如何在以太坊区块链上直接交换ERC20代币和以太币。

本文是第2部分([点击这里前往第1部分](https://ethereumdev.io/trading-and-arbitrage-on-ethereum-dex-get-the-rates-part-1/))，在上一篇向你介绍了如何获得交易报价：获取你要出售的代币所获得的代币数量。本文，我们来看一看如何用Javascript执行交易。

![img](https://img.learnblockchain.cn/pics/20201208112015.png)

要完成1inch的DEX聚合器上的兑换，我们需要三件事：

- 获取当前汇率[如第1部分所示](https://ethereumdev.io/trading-and-arbitrage-on-ethereum-dex-get-the-rates-part-1/).
- 授权(Approve)我们要兑换的ERC20代币的数量，以便1inch智能合约可以访问你的资金。
- 通过使用在步骤1中获得的参数调用swap方法进行交易。

但是在开始之前，我们需要定义所有常量变量和一些帮助工具函数，使代码更简单：

## 项目设置

在本教程中，我们将[使用ganache-cli分叉(fork)当前的区块链状态](https://ethereumdev.io/testing-your-smart-contract-with-existing-protocols-ganache-fork/)并使用它来解锁已经拥有很多DAI代币的帐户。在我们的示例中，账号是 *0x78bc49be7bae5e0eec08780c86f0e8278b8b035b*。我们还将 gas 限制设置为非常高，因此在进行测试过程中不至于出现out-of-gas问题，而无需在每次交易前估算 gas 成本。启动分叉区块链的命令行是：



```bash
ganache-cli  -f https://mainnet.infura.io/v3/[YOUR INFURA KEY] -d -i 66 --unlock 0x78bc49be7bae5e0eec08780c86f0e8278b8b035b -l 8000000
```

在本教程中，我们将尝试使用1inch dex聚合器将1000 DAI兑换为ETH，首先，为了方便起见，让我们声明需要的所有变量，例如合约的地址，ABI。

```javascript
var Web3 = require('web3');
const BigNumber = require('bignumber.js');

const oneSplitABI = require('./abis/onesplit.json');
const onesplitAddress = "0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E"; // 1plit contract address on Main net

const erc20ABI = require('./abis/erc20.json');
const daiAddress = "0x6b175474e89094c44da98b954eedeac495271d0f"; // DAI ERC20 contract address on Main net

const fromAddress = "0x4d10ae710Bd8D1C31bd7465c8CBC3add6F279E81";

const fromToken = daiAddress;
const fromTokenDecimals = 18;

const toToken = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE'; // ETH
const toTokenDecimals = 18;

const amountToExchange = new BigNumber(1000);

const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'));

const onesplitContract = new web3.eth.Contract(oneSplitABI, onesplitAddress);
const daiToken = new web3.eth.Contract(erc20ABI, fromToken);
```

我们还定义了一些帮助工具函数，为了方便等待交易在区块链上打包：

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitTransaction(txHash) {
    let tx = null;
    while (tx == null) {
        tx = await web3.eth.getTransactionReceipt(txHash);
        await sleep(2000);
    }
    console.log("Transaction " + txHash + " was mined.");
    return (tx.status);
}
```

## 获取汇率

现在我们已经准备好一切，先使用本系列教程第一部分中的代码来获得交易的预期汇率。我们只是将代码转换为便于阅读的函数。

函数*getQuote*返回一个包含所有参数的对象，以使用[第一部分中详细介绍的兑换函数](https://ethereumdev.io/trading-and-arbitrage-on-ethereum-dex-get-the-rates-part-1/)。

```javascript
async function getQuote(fromToken, toToken, amount, callback) {
    let quote = null;
    try {
        quote = await onesplitContract.methods.getExpectedReturn(fromToken, toToken, amount, 100, 0).call();
    } catch (error) {
        console.log('Impossible to get the quote', error)
    }
    console.log("Trade From: " + fromToken)
    console.log("Trade To: " + toToken);
    console.log("Trade Amount: " + amountToExchange);
    console.log(new BigNumber(quote.returnAmount).shiftedBy(-fromTokenDecimals).toString());
    console.log("Using Dexes:");
    for (let index = 0; index < quote.distribution.length; index++) {
        console.log(oneSplitDexes[index] + ": " + quote.distribution[index] + "%");
    }
    callback(quote);
}
```

## 授权花费代币

一旦获得了第1部分中所述的代币兑换汇率，我们首先需要授权1inch dex聚合器智能合约来花费我们的代币。如你所知，[ERC20代币标准](https://ethereumdev.io/understand-the-erc20-token-smart-contract/)不允许将代币发送到智能合约并在一次交易中触发合约函数， 我们编写了一个简单的函数，该函数调用ERC20合约实例*approve*函数，并等待使用之前的*waitTransaction*函数等待交易完成：

```javascript
function approveToken(tokenInstance, receiver, amount, callback) {
    tokenInstance.methods.approve(receiver, amount).send({ from: fromAddress }, async function(error, txHash) {
        if (error) {
            console.log("ERC20 could not be approved", error);
            return;
        }
        console.log("ERC20 token approved to " + receiver);
        const status = await waitTransaction(txHash);
        if (!status) {
            console.log("Approval transaction failed.");
            return;
        }
        callback();
    })
}
```

请注意，你可以授权比计划交易的代币更多的金额，例如，这样就无需每次进行交易的时候都进行授权。

## 进行兑换

现在已经获取到了所有的参数，接着需要调用1inch聚合器 *swap* 函数，让合约来访问我们的资金。现在，我们将发起一个交易，该交易执行兑换并等待交易打包。

为了确保兑换成功，增加了对DAI代币的*balanceOf*函数的调用，以及获取以太地址的余额，通过对比余额，来确保DAI代币真正兑换了以太币。

```javascript
let amountWithDecimals = new BigNumber(amountToExchange).shiftedBy(fromTokenDecimals).toFixed()

getQuote(fromToken, toToken, amountWithDecimals, function(quote) {
    approveToken(daiToken, onesplitAddress, amountWithDecimals, async function() {
        // We get the balance before the swap just for logging purpose
        let ethBalanceBefore = await web3.eth.getBalance(fromAddress);
        let daiBalanceBefore = await daiToken.methods.balanceOf(fromAddress).call();
        onesplitContract.methods.swap(fromToken, toToken, amountWithDecimals, quote.returnAmount, quote.distribution, 0).send({ from: fromAddress, gas: 8000000 }, async function(error, txHash) {
            if (error) {
                console.log("Could not complete the swap", error);
                return;
            }
            const status = await waitTransaction(txHash);
            // We check the final balances after the swap for logging purpose
            let ethBalanceAfter = await web3.eth.getBalance(fromAddress);
            let daiBalanceAfter = await daiToken.methods.balanceOf(fromAddress).call();
            console.log("Final balances:")
            console.log("Change in ETH balance", new BigNumber(ethBalanceAfter).minus(ethBalanceBefore).shiftedBy(-fromTokenDecimals).toFixed(2));
            console.log("Change in DAI balance", new BigNumber(daiBalanceAfter).minus(daiBalanceBefore).shiftedBy(-fromTokenDecimals).toFixed(2));
        });
    });
});
```

在撰写本文时，以太坊价格约为170美元（DAI），执行显示的内容如下：

![img](https://img.learnblockchain.cn/2020/12/08/20-34-42.png)

如你所见，当我们卖出1000个DAI代币时，兑换了 5.85以太币。

为了方便，我们发布在Github上的公开了[源代码](https://github.com/jdourlens/ethereumdevio-dex-tutorial)，通过下面命令就可以轻松获取代码：

```bash
git clone git@github.com:jdourlens/ethereumdevio-dex-tutorial.git && cd ethereumdevio-dex-tutorial/part2
```

并安装所需的依赖项web3.js和bignumber.js：

```bash
npm install
```

要执行代码：

```bash
node index.js
```

你可能会遇到的问题是以下消息：“**VM Exception while processing transaction: revert OneSplit: actual return amount is less than minReturn**”。这表示链上的报价已经更新。如果要避免发生这种情况，可以在代码中引入滑点，具体方法是将minReturn参数降低1％或3％。



这就是使用1inch DEX聚合器执行链上ERC20和ETH兑换所需要的全部。当然，不必总是与ETH兑换，也可以在2个ERC20代币之间兑换，甚至与Wrapped Ether兑换。



---



本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。