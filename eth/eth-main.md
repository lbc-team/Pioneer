> * 原文: https://soliditydeveloper.com/deployments
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 以太坊主网部署终极指南

> 部署到以太坊主网你需要知道的一切

我们都喜欢以太坊，所以你已经创建了一些出色的智能合约。它们通过单元测试和测试网进行了密集的测试。现在终于到了上主网的时候了。但这是一个棘手的事情...

## 1. 究竟什么是部署交易？

首先让我们从低层次快速讨论一下什么是合约部署。任何以太坊交易本身只由几个属性组成，一般有三种交易类型：

1. 发送以太币（ETH）
2. 部署智能合约
3. 调用智能合约



这所有三个交易的某些部分对总是相同的：`from`，`value`，`gas`，`gasPrice`和`nonce`。它们之间的区别来自于 `to `和 `data `参数，这两个参数代表了交易被发送到哪里，以及与之一起发送的数据是什么。

1. 发出以太币交易
   - `to`: ETH的接收地址
   - `data`: 空(这里不涉及智能合约)

2. 部署智能合约
   - `to`：空（我们还没有智能合约的地址，因为我们只是在刚才创建它）
   - `data`：智能合约的字节码（编译智能合约的结果）。

3. 与智能合约的交互
   - `to`：智能合约地址
   - `data`：[函数选择器](https://learnblockchain.cn/docs/solidity/abi-spec.html#function-selector)及函数参数数据



## 2. 部署前的考虑因素

你肯定明白智能合约的安全是极其重要的。虽然从一开始就应该遵循[最佳实践](https://consensys.github.io/smart-contract-best-practices/) - （[中译文](https://learnblockchain.cn/article/1890)），但在部署到主网之前进行审计是最后也是关键的一步。你可以使用https://www.smartcontractaudits.com/，找到一个合适的审计师。

其次要考虑你的私钥的安全性。虽然对于测试网来说，在你的机器上存储一个私钥是完全可以的，但对于主网来说，这还不够好。假设你有某种[访问控制](https://docs.openzeppelin.com/contracts/4.x/access-control)，对非常关键的方面进行控制的地址应该是一个多签名合约。你可以自己设置。例如，一个7分之5的多重签名将需要7个地址中的5个地址来签署交易。你可以使用[Gnosis Safe](https://gnosis-safe.io/)这样的应用程序来创建一个多签合约。而私钥本身最好都是来自硬件钱包，如Ledger和Trezor。

## 3. 如何进行实际部署

总的来说，部署一份合约需要

- 合约的字节码 - 这是通过[编译](https://ethereum.org/en/developers/docs/smart-contracts/compiling/)生成的。
- 一个有足够的ETH来支付Gas费以太坊地址的私钥。
- 一个部署工具或脚本。
- 一个以太坊节点服务，如[Infura](http://infura.io/)、[QuikNode](https://www.quiknode.io/)、[Alchemy](https://alchemy.com/?r=7d60e34c-b30a-4ffa-89d4-3c4efea4e14b)或简单地通过[运行你自己的节点](https://ethereum.org/en/developers/docs/nodes-and-clients/run-a-node/)



有一些工具可以帮助你，我可以告诉你，有些工具对主网来说比其他工具更好用。

### a. Truffle



Truffle仍然是一个非常广泛使用的工具，特别是用于部署。它可以做很多事情，从智能合约的编译到自动测试。但这里我们只对它的[迁移功能](https://learnblockchain.cn/docs/truffle/getting-started/running-migrations.html)感兴趣，它是用于部署的。

#### 典型的Truffle配置

在下边你看到一个非常典型的[truffle 配置](https://learnblockchain.cn/docs/truffle/reference/configuration.html)。在这里你可以看到我们是如何解决部署合约的很多要求的。



```javascript
require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

const { MNEMONIC, INFURA_API_KEY } = process.env;
const kovanUrl = `https://kovan.infura.io/v3/${INFURA_API_KEY}`;
const mainnetUrl = `https://mainnet.infura.io/v3/${INFURA_API_KEY}`;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
    mainnet: {
      provider: () => new HDWalletProvider(MNEMONIC, mainnetUrl),
      network_id: 1,
    },
    kovan: {
      provider: () => new HDWalletProvider(MNEMONIC, kovanUrl),
      network_id: 42,
    },
  },
  compilers: {
    solc: {
        version: "0.8.4",
        optimizer: { enabled: true, runs: 200 }
    },
  },
};
```



- 编译：我们在 `compilers`部分定义我们的solc版本，Truffle将在部署前自动编译我们的合约。
- 私钥：我们使用[hdwallet-provider](https://github.com/trufflesuite/truffle/tree/master/packages/hdwallet-provider#readme)，从助记符中创建一个私钥。这对mainnet来说也是一个不错的选择。然而，**记得**在部署后将合约的所有权改为更安全的账号。或者直接使用[Trezor](https://github.com/daonomic/trezor-web3-provider)或[Ledger](https://github.com/petertulala/truffle-ledger-provider)的 Provider（需要做一些额外工作）。
- Infura：设置Infura端点和密钥。可以改为你正在使用的任何节点服务或你自己的节点的地址。

### 迁移

迁移是为你定义如何部署智能合约的特殊脚本。如果你有多个合约需要部署，而这些合约又相互依赖，或者你需要在部署后调用任何合约上的功能，这就特别有用。

请查看迁移链接[这里](https://learnblockchain.cn/docs/truffle/getting-started/running-migrations.html)，了解如何使用它们的完整文档。

````javascript

var MyContract = artifacts.require("MyContract");

module.exports = deployer => {
  deployer.then(async () => {
    await deployer.deploy(MyContract, param1, param2);
    const myContract = await MyContract.deployed();
    await myContract.changeOwnership(multiSigAddress);
  });
};
```

这里你可以看到一个典型的迁移脚本，它利用了async/await语法。在部署之后，我们将所有权转移到一个已经部署好的multisig合约上。



#### 将Truffle用于主网的弊端

![部署备忘录](https://img.learnblockchain.cn/pics/20210429213951.jpeg)

值得一提的是，由于几个原因，Truffle本身远不是部署到主网的最佳选择。

1. 部署的特殊迁移合约增加了Gas成本。尽管可以删除它。

2. 在主网上，Truffle中的长时间迁移是非常非常痛苦的。

   - Gas 交易成本使主网的部署变得非常困难,你可以在Truffle配置中[设置一个Gas价格](https://learnblockchain.cn/docs/truffle/reference/configuration.html#networks)，但在整个迁移期间都将使用这一个Gas价格。因此，如果Gas价格在你的部署期间大量增加，什么时候被矿工纳入区块，就只能祝你好运。如果一个交易在几分钟内没有被打包，Truffle将直接停止你的部署。你唯一的选择是设置一个非常高的Gas价格，并希望一切都能快速部署。

   - 你的网络连接可能会导致问题，你最好不要在长时间的部署中失去连接，否则就准备从头再来。

至少，Truffle现在在实际部署前会进行运行模拟部署。你可以用`--skip-dry-run`跳过测试网的模拟，但不要在主网上这样做。这将确保你至少不会在中间环节出现错误，而不得不从头开始重新启动。

总而言之，如果你有钱支付使用Truffle所增加的费用，就去使用它吧。否则，请继续阅读替代方案。

### b.Remix

Remix是我最喜欢的快速部署主网的工具。你可以完全控制正在发生的事情，因为你将使用MetaMask手动完成每个步骤。

![Remix部署](https://img.learnblockchain.cn/pics/20210429213958.png)

一旦你有了编译好的合约，部署就像输入参数和点击部署一样简单。你可以使用[truffle-flattener](https://github.com/nomiclabs/truffle-flattener)从Truffle获得Remix的可部署合约，或者使用Hardhat[内置扁平化命令](https://hardhat.org/getting-started/#running-tasks)获得可部署合约。由于你使用的是MetaMask，你会：

- 自动连接到Infura
- 有能力与硬件钱包进行部署
- 能够为每笔交易选择一个准确的Gas价格
- 能够[加速或取消](https://metamask.zendesk.com/hc/en-us/articles/360015489251-How-to-Speed-Up-or-Cancel-a-Pending-Transaction)Pending交易

#### 使用Remix的弊端

然而使用Remix，你必须手动完成每一个步骤，手动输入每个参数，手动部署每一个合约，手动调用每个函数。你可以看到这对很长的部署程序来说是多么的痛苦。



### c. Hardhat

Hardhat中没有对部署的直接支持。然而，你可以写一个脚本，通过ethers.js部署一个合约，并从hardhat命令中调用它。在[solidity-template](https://github.com/paulrberg/solidity-template)中可以看到一个关于如何做到这一点的例子。

下面是一个部署脚本的例子：

```javascript
import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";

async function main(): Promise<void> {
  const Greeter: ContractFactory
      = await ethers.getContractFactory("Greeter");
  const greeter: Contract
      = await Greeter.deploy("Hello, Buidler!");
  await greeter.deployed();

  console.log("Greeter deployed to: ", greeter.address);
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
```



该脚本可以用以下方式调用。

```bash
$ npx hardhat run scripts/deploy.ts
```

另外，你可以使用[hardhat-deploy](https://github.com/wighawag/hardhat-deploy#deploy-scripts)插件，它增加了完成部署后保存在文件的能力。



### d. Web3

当然，你总是可以直接使用Web3(或ethers.js)构建你的自定义部署逻辑。当你频繁地部署合约并需要自定义逻辑来存储部署信息时，这非常有用。Web3直接支持使用[myContract.deploy()](https://learnblockchain.cn/docs/web3.js/web3-eth-contract.html#deploy)进行部署。

````javascript
const myContract = new web3.eth.Contract(jsonABI)
myContract.deploy({
    data: '0x12345...', // bytecode
    arguments: [123, 'My String'] // constructor arguments
}).send({
    from: '0x1234567890123456789012345678901234567891',
    gas: 1500000,
    gasPrice: '30000000000000'
}
```

### e. Truffle Team（高级）

还记得上面提到的用Truffle部署到主网的问题吗？那么有一个解决方案，叫做[Truffle Teams](https://www.trufflesuite.com/teams)。它对开源项目是免费的，否则每个月会[花费几美元](https://www.trufflesuite.com/teams#pricing)。但是，通过Truffle Team你就可以得到一个项目仪表板。这是与Github的直接连接，并作为持续集成运行你的测试。任何成功的构建都可以从仪表板上部署。

这允许你为部署连接MetaMask，意味着完全控制交易成本并加速。

![Truffle Teams Deployments](https://img.learnblockchain.cn/pics/20210429214007.png)

Truffle Teams部署的完整文档，请参阅[这里](https://www.trufflesuite.com/docs/teams/deployments/creating-a-deployment)。

## 4. 部署后的考虑因素

在部署到主网之后，你应该在Etherscan和Sourcify上验证合约的源代码。这涉及到将Solidity代码提交给这些服务，这些服务将对其进行编译，并验证它是否与部署的字节码相匹配。验证成功后，用户可以在Etherscan上获得更多的信息，可以直接在Etherscan上与之交互，或者在Remix等支持工具从Sourcify上获取代码。

你可以在[Etherscan](https://etherscan.io/verifyContract)网站上手动验证你的合约。另外，也推荐使用[Truffle](https://github.com/rkalis/truffle-plugin-verify)、[Hardhat](https://www.npmjs.com/package/@nomiclabs/hardhat-etherscan)插件和直接使用[Etherscan API](https://etherscan.io/apis#contracts)自动验证的插件。

关于如何使用Sourcify，请查看[这篇博文](https://soliditydeveloper.com/decentralized-etherscan)。

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。