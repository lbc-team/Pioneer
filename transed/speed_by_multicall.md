> * 原文：https://medium.com/better-programming/speed-up-your-defi-queries-using-multicall-d4cf652d8ab6 作者：[IvánAlberquilla](https://medium.com/@ialberquilla?source=post_page-----d4cf652d8ab6--------------------------------)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
>

# 使用Multicall 加速 DeFi查询调用



> 一个实操案例，演示如何通过分组调用的方式更快的从以太坊的DeFi协议获取数据。



![vehicle speedometer with the pointer at zero](https://img.learnblockchain.cn/2021/01/08/ayu951/F6zCx)



## 背景介绍

有时，从区块链获取数据的成本可能会非常高，不管是从请求花费的时间还是从发送的请求数量上来说，都是这样。如果我们想同时获取大量数据，用来在仪表板上显示或进行分析，我们必须调用合约的不同函数或者用不同参数调用相同函数， 这些都可能会导致查询时间很长。另外，当我们使用像[Infura](https://infura.io/)这样的节点提供商，也很容易达到发送请求数量的限额。



### 什么是Multicall？

[Multicall](https://github.com/cavanmflynn/ethers-multicall#readme)是一个npm软件包，可将多个HTTP调用分为一个组。用这个方式，之前想从*n*个不同的请求中获取的数据，现在可以在发送HTTP请求之前对它们进行分组，然后进发送一个请求，从而缩短了请求响应时间，并降低了eth_call调用的次数。

## 用测试了解运作方式

为了了解这种机制的工作原理以及相对于传统方法是否确实有所改进，我们将通过一个对比测试来验证。分别在不使用Multicall和使用Multicall的情况下，对每个函数调用*n*次， 然后分析结果。为此，我们通过调用函数getAccountLiquidity来查询 Compound 协议。我们将使用1,000个不同的地址来获取所有地址的信息。

## 创建项目

### 安装依赖

为了进行测试，先创建一个Node项目，并将安装依赖项：[ethers.js](https://docs.ethers.io/v5/) 用于与区块链交互、[money-legos](https://money-legos.studydefi.com/#/)则用来以更简单的方式引用ABI和合约，以及Multicall软件包。

使用以下命令创建项目：

```
npm init -y
```

然后，安装了上述提到的依赖项：

```
npm install -S @studydefi/money-legos ethers ethers-multicall
```

### 导入依赖

对比测试的两种情况，我们都必须使用引入公共依赖项进行实例化并以此与区块链连接。引入方式如下（import.js）：

```javascript
const { ethers } = require("ethers");
const { ALCHEMY_URL } = require('./config')
const compound = require("@ studydefi/money-legos/compound");
const { accounts } = require("./accounts");
const { Contract, Provider } = require('ethers-multicall');
const provider = new ethers.providers.JsonRpcProvider(ALCHEMY_URL);
```



并创建一个用来显示结果和执行时间的函数，如下所示(calculatetime.js)：

```javascript
const calculateTime = async () => {
  const startDate = new Date();
  const result = await getLiquidity()
  const endDate = new Date();
  const milliseconds = (endDate.getTime() - startDate.getTime());
  console.log(`Time to process in milliseconds: $ {milliseconds}`)
  console.log(`Time to process in seconds: $ {milliseconds / 1000}`)
  const callsCount = Object.keys(result).length;
  console.log(`Number of entries in the result: $ {callsCount}`);
}
```

calculatetime.js

## 调用合约

### 常规循环调用

先使用传统方法进行测试，我们将遍历1,000个的地址数组(在` map`循环中)，逐个获取每个查询的结果，执行方法如下：

```javascript
const getLiquidity = () => {
  const compoundContract = new ethers.Contract(
  compound.comptroller.address,
  compound.comptroller.abi,
  provider
  )
  
  return Promise.all(accounts.map(account => {
  let data
  try {
     data = compoundContract.getAccountLiquidity(account.id)
  } catch (error) {
     console.log(`Error getting the data $ {error}`)
  }
     return data
  }))
}
```

上面实例化compound comptroller 合约，并在每个地址上调用流动性函数。

## 使用 Multicall调用

使用Multicall调用时，调用函数必须稍作更改，形式如下：

```javascript
const getLiquidity = async () => {
  const ethcallProvider = new Provider(provider);
  await ethcallProvider.init();
  
  const compoundContract = new Contract(
    compound.comptroller.address,
    compound.comptroller.abi,
  )
  
  const contractCalls = accounts.map(account => compoundContract.getAccountLiquidity(account.id))
  const results = await ethcallProvider.all(contractCalls);
  return results
}
```



利用Multicall包中的`Provider`和`Contract`类。首先，初始化provider，并传递`web3`、合约地址及其合约ABI。

创建完成后，执行则和之前类似。在`map`里，调用帐户流动性函数。但是现在它不会发送到网络，而是将它们分组到一个数组中。创建此数组后，将调用创建好的Multicall `Provider`的 `all`函数，并进行网络调用。

## 对比分析结果

要查看是否确实有重大改进，只需要对比两个调用消耗的时间。

传统循环方法消耗的时间：

```
Time to process in milliseconds: 124653
Time to process in seconds: 124.653
Number of entries in the result: 1000
```

使用Multicall调用

```
Time to process in milliseconds: 9591
Time to process in seconds: 9.591
Number of entries in the result: 1000
```



## 结论

通过结果对比，发现使用Multicall调用时间的减少是非常可观的，从124秒减少到9.5，花费的时间减少大约十倍。

另外，如果比较`eth_call` RPC 调用的数量，同样是非常明显的减少，从一千个减少到只有一个。

因此，如果我们依赖第三方的节点提供商，而在该提供商中对API的调用是有限额，则这一点也同样重要。



------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。