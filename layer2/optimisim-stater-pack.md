> * 原文来自：https://azfuller20.medium.com/optimism-scaffold-eth-draft-b76d3e6849e8 作者： [Adam Fuller](https://azfuller20.medium.com/)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)




# 为 Optimism 上开发Dapp 准备的脚手架



[Optimism 的 Optimistic Rollup ](https://optimism.io/)主网发布在即! 我们在热切的期待中，因此我们为Optimisim 的早期参与者准备了一个[scaffold-eth（脚手架）](https://github.com/austintgriffith/scaffold-eth/tree/local-optimism)的专门分支（分支名为：`local-optimism`），脚手架包含以下内容:

- 运行本地链(L1)与Optimistic Rollup (L2)。
- L1和L2交互
- 在L1和L2之间移动ETH
- 在L2部署智能合约
- 创建自己的ERC20代币桥接!

>  这些工作仍在进行中：这是在一个全新的协议上的全新的构建方式，所以预计一切都会发展和变化：），欢迎反馈!

如果你想直奔主题， [代码在这里](https://github.com/austintgriffith/scaffold-eth/tree/local-optimism)(步骤在README中)。

关于[Optimism的Rollup是如何工作的](https://research.paradigm.xyz/optimism)，其他人已经写了更详细的。 这篇文章的重点是我们可以在乐观的以太坊上做什么，如何运行和开发...

我们开始吧！

## 运行一个具有Rollup的本地链

> 你需要安装[Docker](https://www.docker.com/products/docker-desktop)!

在本地几条链，让他们互相交互，不是件容易的事。 值得庆幸的是，Optimism团队提供了一个[开箱即用的集成仓库](https://github.com/ethereum-optimism/optimism-integration)，包含了运行所需的六个Docker容器。 这是 `local-optimism`分支的一部分，作为[Git子模块](https://git-scm.com/book/en/v2/Git-Tools-Submodules)提供。 当你把repo拉下来的时候，你需要启动&更新子模块，然后就是一个命令就可以把整个东西创建起来。

```
cd docker/optimism-integration && make up
```

![img](https://img.learnblockchain.cn/pics/20210319102848.gif)

<center>启动并运行</center>



有点像飞船起飞的感觉!

看日志可以很实际的感受到Optimism的工作原理--首先初始化一个L1链，并部署[Optimism核心合约](https://community.optimism.io/docs/protocol/protocol.html#system-overview)，然后初始化几个在L1和L2之间传递信息服务，最后启动L2 geth实现。

如果一切顺利，我们就可以开始了!

## Rollup与本地链交互

Optimism实现的真正优势之一是与EVM的兼容性 -- 在很多方面，它就像改变 RPC URL 和 chain ID一样简单。

```
l1Local: { rpc: "http://localhost:9545", chainId: 31337 }

l2Local: { rpc: "http://localhost:9545", chainId: 420 }

l2Kovan: { rpc: "https://kovan.optimism.io", chainId: 69 }
```

当然，也有[一些需要考虑的差异](https://community.optimism.io/docs/protocol/evm-comparison.html#behavioral-differences)，这里让我们边走边讲。

从用户和开发者的角度来看，需要考虑的主要问题之一是如何处理L1和L2网络，哪些要呈现给用户，以及如何确保钱包连接到正确的网络。

> 使用[自定义网络API](https://learnblockchain.cn/article/2223)，可以很好的解决后一个问题(在这个分支中还没有实现--欢迎PR!)

在这个分支中，我们实例化了两个[provider(提供者)](https://docs.ethers.io/v5/api/providers/)和两个[singer(签名者)](https://docs.ethers.io/v5/api/signer/)，因为我们要支持与本地链和Rollup的交互。

![1_vF4ynkFGTcdgvDm77hEC3g](https://img.learnblockchain.cn/pics/20210319105839.png)

<center>一个钱包有两个余额!</center>



## 在L1和L2之间转移ETH

本地Rollup和目前在Kovan上的部署不需要任何交易费用，但这将是主网的一个关键过渡。 我们有一个简单的 `OptimisticETHBridge `组件，它可以显示用户在L1和L2的余额，并允许他们存款到L2或从 L2取款。

![1_iUEdefxX0UwlELeOwG4Gdg](https://img.learnblockchain.cn/pics/20210319110522.gif)

<center>L1/L2桥</center>

存款是指在`L1ETHGateway`合约上调用*payable* `deposit`函数，存入你想存入的数量。该合约作为Optimism初始化的一部分进行部署，在本地设置上的部署地址总是相同的（可以检查一下部署日志），但在Kovan上是不同的。

在Optimism上，没有原生的ETH，ETH只是一个ERC20的代币（虽然是部署在[预部署地址](https://community.optimism.io/docs/protocol/protocol.html#predeployed-contracts)的代币，在任何Rollup上都是一样的），提现是转入到ERC20合约中。

```
await l2Tx(L2ETHGatewayContract.withdraw(
            parseEther(values.amount.toString())))
```

该组件还为L1和L2内置了简单的 `Send `功能。

Optimism团队短期内正在研究的难题：

- 目前L2还不支持用`{ value }`发送的交易，所以我们实例化一个`ethers.js`合约，并调用 `transfer`。
- 目前在L2上实现的geth版本并不像在L1上那样抛出 `transactionResponse`，需要 `wait() `等待 `transactionReceipt`。 在scaffold-eth中，这意味着要给我们的Transactor helper增加一行。

```
result = await signer.sendTransaction(tx);
await result.wait()
```

## 在Optimism上进行部署合约。

Optimism的主要关注点之一是转移性，从EVM到OVM。 因此，我们只需要做一些小的改动，就可以使我们的现有scaffold-eth上的合约在L2上可行--我们只需要在我们的hardhat配置中导入[Optimism编译器](https://hardhat.org/plugins/eth-optimism-plugins-hardhat-compiler.html)(然后编译所有合约，除非有`//@unsupported: ovm`标志的合约)，然后使用[Optimism ethers variant](https://hardhat.org/plugins/eth-optimism-plugins-hardhat-ethers.html)来部署我们的合约。

```javascript
const { l2ethers } = require("hardhat");

...

contractArtifacts = await l2ethers.getContractFactory(contractName, signerProvider);
const deployed = await contractArtifacts.deploy(...contractArgs, overrides);
await deployed.deployTransaction.wait()
```

> 请注意前面提到的`wait()`!

有一些细微的差别--我们不能使用内置的Hardhat网络，必须实例化我们自己的提供者和签名者。

我们不需要对合约做任何修改，尽管可能不一定是这样，例如对`.balance`的调用会在编译时抛出一个错误。 一般来说，编译器的错误对追踪问题都很有帮助。



我们确实做了一些改动，在Optimism上出块时间`block.timestamp`确实存在，但却是对L1时间的引用。 有两件动作会更新了L2上的时间： 从L1到L2的桥接信息，以及按设定频率( `心跳`)定期更新L2时间。

![1_dCfswNwv6CKF4PXboiR_Hg](https://img.learnblockchain.cn/pics/20210319111854.png)



这确实给处理L2上的时间时产生了一些有趣的挑战，因为获取的 `block.timestamp `总是过去的。 以后还会有更多的思考...

> 在一个非常实际的问题上，这意味着在本地开发中，你需要定期在本地链上进行交易，以保持你的L2时间的更新!

## 在Optimism的桥接：古英语 ERC20

虽然对于很多使用场景来说，使用他人部署的ETH桥和代币桥 可以满足大部分 L1到 L2 桥接的需求，但我们也想了解如何将自己的L1 ERC20转移到L2，以及如何返回。

幸运的是，Optimism团队在他们[合约包](https://www.npmjs.com/package/@eth-optimism/contracts) 提供了一些参考合约，再加上[有用的教程](https://github.com/ethereum-optimism/optimism-tutorial/tree/deposit-withdrawal)，所以我们能够把它们拉到我们的分支中，我们将部署三个合约：

- `ERC20.sol`：在L1上，这是 `真理之源`---- 一个简单的ERC20实现，有一个`mint(value)`函数，允许任何人自己铸造一些代币。
- `L1ERC20Gateway.sol`：也是在L1上，这允许我们向L2存款，同时锁定代币。
- `L2DepositedERC20.sol`：该合约部署在L2上，它也是一个ERC20的实现，当新的代币从L1存入时，它就将其铸成新的代币，当它们被提取时，就将其销毁。

部署顺序很重要，因为 `L1ERC20Gateway `需要知道 `ERC20 `地址和 `L2DepositedERC20 `地址，然后需要通过 `init() `与 `L1ERC20Gateway `地址激活 `L2DepositedERC20 `合约，完成连接。 我们部署的合约分别与 `L1Messenger `和 `L2Messenger `进行通信，以进行存款和提款。



部署完成后，我们就可以测试桥接功能了，可以在前端应用中测试，也可以在直接在[部署脚本](https://github.com/austintgriffith/scaffold-eth/blob/local-optimism/packages/hardhat/scripts/oe-deploy.js)中测试。

![l2 l1 桥接测试](https://img.learnblockchain.cn/pics/20210319114712.png)

`L1ERC20Gateway`必须经过批准才能转移代币，才能启动整个事情。

目前有在进行一个想法，希望有一个[通用的用于ERC20代币的桥接](https://github.com/ethereum-optimism/contracts/pull/257)，这样的桥接在生产中可能不需要，但它仍然是一个有益的概念验证，以方便本地开发。

## 下一步

显然，下一步的关键是上测试网（然后上主网！）local-optimism 分支包含了去Kovan部署Optimism的配置选项，就像更新`App.js`中的`selectedNetwork`，以及从Hardhat部署时的`defaultNetwork`或`--network`参数一样简单。

> 但更大的问题是，在Optimism上构建什么!

我们将在未来几周内发布更多的试运行、概念验证，甚至可能是成熟的产品。欢迎关注。

> 如果你还没有-[ 获取分支](https://github.com/austintgriffith/scaffold-eth/tree/local-optimism)， 那就赶快尝试一下吧。

*非常感谢来自Optimism的Ben和Kevin的有益回答，以及* [*Austin Griffith*](https://twitter.com/austingriffith)的帮助、努力和支持!

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。