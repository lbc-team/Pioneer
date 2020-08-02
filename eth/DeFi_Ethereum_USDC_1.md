# 介绍通过以太坊和USDC搭建去中心化金融系统

*作者* [*Pete Kim*](https://twitter.com/petejkim)

在Coinbase，我们希望可以创建一个开放的金融系统。我们坚信提高金融的自由度可以让世界更美好。去中心化金融，简称DeFi是一个开放，无界限并且可以程序化的金融，是提供金融自由度的一种方式。

## 智能合约


DeFi是运行在去中心化网络上（例如以太坊），由智能合约（例如USD币：一种区块链上美元代币）驱动的。智能合约其实是很好理解的，Nick Szabo是数字货币和加密学的先驱者，在1997年他[最早提出智能合约]((https://www.fon.hum.uva.nl/rob/Courses/InformationInSpeech/CDROM/Literature/LOTwinterschool2006/szabo.best.vwh.net/idea.html) )并将其比喻为自动贩卖机。


自动贩卖机就如一个被植入自动化程序的合约，他有如下特点：

1. 你按照显示的金额放入货币，机器会给你饮料；

2. 你不按照显示的金额付款，你拿不到饮料；

3. 如果你付了应付金额，但是机器没给你饮料，亦或是你在没付钱的情况下机器给了你饮料，这些都是违反自动贩卖机的规则。

自动贩卖机可以在无人干涉情况下，很好的履行他的合约精神。

现代智能合约工作原理也是类似的，合约的条件是用可执行的代码来表达的。去中心化网络保证按要求执行，并且任何人都不能破坏规则或者篡改结果。因为网络会一字不差地执行代码，有瑕疵的智能合约会产生预想不到的后果。（“代码是条例”）

## 把握当下

很多人觉得在区块链上去搭建应用比较困难，认为只有高级玩家可以尝试。但是近几年出现来了很多工具，开发者界面，帮助编程能力一般的人去实现构建。

最近，DeFi生态呈现爆发式地增长。[USDC不到2年捕获的总价值达到10亿美元](https://medium.com/centre-blog/usdc-market-cap-exceeds-1-billion-fastest-growing-digital-dollar-stablecoin-to-do-so-c5ba314474ca)，同时各种各样的DeFi服务在不到3年的时间，总价值超过20亿美金。当下可谓是DeFi发展的最佳时机。
 
![](https://img.learnblockchain.cn/2020/07/24/15955628861882.jpg)

*来源:* [*DeFi Pulse*](https://defipulse.com/)

下面的教程主要目的是介绍如何开发自己的DeFi智能合约。我们希望，本教程可以帮助创建一个全球、开放的金融体系。

# 开始

本系列教程假设你有使用[JavaScript](https://en.wikipedia.org/wiki/JavaScript)的经验，这是世界上使用最广泛的编程语言。你还将学习[Solidity](https://solidity.readthedocs.io/)，[Ethereum](https://ethereum.org/)上使用的智能合约编程语言。最后，你也会认识[USDC](https://www.coinbase.com/usdc)，这是DeFi应用程序中最广泛采用的由法币支持的稳定代币。

## 设置开发环境

首先，我们需要一个类unix的环境，并在上面安装[Node.js v12.x](https://nodejs.org/) (LTS的最新版本)。macOS本身就是Unix环境，Windows用户可以通过从微软商店安装[Ubuntu on WSL](https://ubuntu.com/wsl)来获得它。更详细的步骤macOS可以查看[这里](https://treehouse.github.io/installing-guides/mac/nod-mac.html)，Windows查看[这里](https://docs.microsoft.com/en-us/windows/nodejs/setup-on-wsl2)。对于文本编辑器，强烈推荐使用[Visual Studio Code](https://code.visualstudio.com/)，因为你将使用的项目模板是预先配置的，但你可以使用任何编辑器。哦，我更喜欢[Vim的快捷键绑定方式](https://xkcd.com/378/)。

## 建立项目

建立一个Solidity项目需要一些工作，而且老实说，在这个阶段我们不希望被搭建项目琐碎的工作而分心了，所以已经为你准备了一个[预配置模板](https://github.com/coinbasestablecoin/solid-tutorial])。

通过在终端中运行以下命令下载和设置模板:

```
$ git clone [https://github.com/CoinbaseStablecoin/solidity-tutorial.git](https://github.com/CoinbaseStablecoin/solidity-tutorial.git)
$ cd solidity-tutorial
$ npm install -g yarn        # Install yarn package manager
$ yarn                       # Install project dependencies
```

当yarn在安装的时候，你可能会看到一些编译错误。你可以忽略这些错误。当你最后看到“完成”信息，你就可以开始了。

## 在Visual Studio Code打开项目

在Visual Studio Code中打开项目文件夹(**solidity-tutorial**)。项目第一次打开时，Visual Studio Code可能会提示你安装扩展。继续并点击“安装所有”，这将增加各种有用的扩展，如代码自动格式化和solidity语法高亮。

![](https://img.learnblockchain.cn/2020/07/24/15955721532271.jpg)

# 在以太坊建立账户

在以太坊上做任何事情之前，你需要有一个帐户。账户通常被称为“钱包”，因为它们可以包含像ETH和USDC这样的数字资产。终端用户通常使用以太坊钱包应用，像[Coinbase钱包](https://wallet.coinbase.com/)或[Metamask](https://metamask.io/)来创建钱包,但通过程序使用[ethers.js](https://github.com/ethers-io/ethers.js/)方式创建一个账户也很简单。

在**src**目录下，创建一个新的js文件**createWallet.js**，写入如下代码：

```
const ethers = require("ethers");

const wallet = ethers.Wallet.createRandom();

console.log(`Mnemonic: ${wallet.mnemonic.phrase}`);
console.log(`Address: ${wallet.address}`);
```

保存文件，然后使用Node.js来执行文件

```
$ node src/createWallet.js
Mnemonic: caveat expect rebel donate vault space gentle visa all garage during culture
Address: 0x742B802F28622E1fdc47Df948D61303b4BA52114
```

刚才发生了什么？好吧，你得到了一个全新的Ethereum账号。“mnemonic”是“助记符”或被称为的“恢复短语”，是用于帐户执行操作所需的加密密钥，地址是帐户的名称。记得把它们写下来。另外，为了防止你们使用我的助记符，我已经做了轻微的修改，请使用你自己的!

可以把这些看作是密码和银行账户的帐号，不过钱包地址可以在几秒钟内创建一个，而且你不需要填写申请表格或分享任何个人信息。而且你可以在任何地方运行此代码。

> *⚠️*助记符必须保密。如果你丢失了它，你将永远无法访问你的帐户和帐户中存储的任何资产，没有人能够帮助你!把它放在安全的地方!

> *ℹ️*从技术上讲，你并没有真正“创造”一个帐户本身。相反，你创建的是一个私有/公共密钥对。如果你好奇到底发生了什么，可以看下[椭圆曲线密码学](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography)，比特币和以太坊规范[BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki), [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki),[EIP55](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md)及其[在本项目中](https://github.com/petejkim/wallet.ts)的实现。

## 关于Gas和挖矿

以太坊是一个去中心化的网络，由世界各地成千上万台计算机组成，但是它们并不是免费运行的。要在区块链上执行变更状态，如存储和更新数据，你必须用用ETH向网络支付交易费，在以太坊上也称为“gas”。gas费用和增加新区块获得的奖金就是激励矿工运算的激励。这个过程被称为“挖矿”，不断做运算的被称为“挖矿者”。我们将在稍后的教程中再次讨论这个问题(gas，gas价格和gas限额)。

## 获得测试网络ETH

现在你有了账户，你应该存一些ETH。在开发的时候我们不想浪费真正的ETH，所以我们需要一些ETH用于在测试网络开发和测试网络(“testnet”)。现在有许多不同的Ethereum测试网络，我们将会使用Ropsten，因为获得测试代币比较容易。首先，让我们使用[Etherscan](https://ropsten.etherscan.io/)检查当前余额，这是一个以太坊的区块信息的浏览器。你可以在浏览器中输入以下URL，将**你的地址**替换为之前创建的地址，以**0x**开始。

[https://ropsten.etherscan.io/address/**YOUR_ADDRESS**](https://ropsten.etherscan.io/address/YOUR_ADDRESS)

![](https://img.learnblockchain.cn/2020/07/24/15955734131072.jpg)

*来源:* [*ropsten.etherscan.io*](https://ropsten.etherscan.io/)

你可以看到现在余额是0。保持该页面打开，并在另一个页面中打开[Ropsten Ethereum Faucet](https://faucet.ropsten.be/)。在第二个页面中，输入你的地址，然后点击“发送我（Send me）”按钮。完成后可能只需要几秒钟到一两分钟。稍后再次检查Etherscan，你应该会看到新的余额为1ETH和转入交易。

![](https://img.learnblockchain.cn/2020/07/24/15955740098521.jpg)
*来源:* [*faucet.ropsten.be*](https://faucet.ropsten.be/)

# 通过编程获取ETH余额

## 连接以太坊网络

我们可以使用Etherscan查看余额，但是使用代码也可以很容易查看余额。在我们写代码之前，我们需要连接到以太坊网络。有许多方法可以实现，包括在自己的计算机上运行一个网络节点，但到目前为止，最快和最简单的方法是通过一个托管节点来实现，例如[INFURA](https://infura.io/)或[Alchemy](https://alchemyapi.io/)。前往[INFURA](https://infura.io/)，创建一个免费帐户并创建一个新项目来获取API密钥(项目ID)。

> *ℹ️* [Go Ethereum (“geth”)](https://geth.ethereum.org/) 和 [Open Ethereum](https://github.com/openethereum/openethereum#readme)（之前被称为Parity Ethereum）。这两个是最为广泛使用地节点软件。

## 通过代码查看ETH余额

首先，通过读取助记符进入到我们的账户中。在**src**文件夹下，创建一个名为**wallet.js**的JavaScript文件。敲入以下代码:

```
const ethers = require("ethers");

// 在这里替换你自己的助记符

const mnemonic =
  "rabbit enforce proof always embrace tennis version reward scout shock license wing";
const wallet = ethers.Wallet.fromMnemonic(mnemonic);

console.log(`Mnemonic: ${wallet.mnemonic.phrase}`);
console.log(`Address: ${wallet.address}`);

module.exports = wallet;
```

用你自己的字符串替换代码中的助记符字符串。请注意，在生产中，助记符不应该像这样直接写在代码中。理想的是它从配置文件或环境变量中读取，这样它就不会因为写在源代码中而泄漏。

执行代码，你应该能够看到和之前相同的地址

```
$ node src/wallet.js
Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
```

接下来，在同一个文件夹中,创建一个名为**provider.js**的新文件。在这个文件中，我们将使用前面获得的INFURA API密钥。记得替换成你自己的api key:

```
const ethers = require("ethers");


const provider = ethers.getDefaultProvider("ropsten", {
  // 替换INFURA API KEY
  infura: "0123456789abcdef0123456789abcdef",
});

module.exports = provider;
```

最后，我们会引用**wallet.js**和**provider.js**，在同一目录下创建新的文件**getBalance.js**

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main() {
  const account = wallet.connect(provider);
  const balance = await account.getBalance();
  console.log(`ETH Balance: ${ethers.utils.formatUnits(balance, 18)}`);
}

main();
```

执行代码，你就可以看到余额了

```
$ node src/getBalance.js
Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
ETH Balance: 1.0
```

## 代币换算

我们刚刚创建的代码非常容易理解，但是你会想知道**ethers.utils.formatUnits(balance, 18)**的作用。嗯，ETH实际上有18位，最小的单位叫“wei”(发音为“way”)。换句话说，一个ETH等于1000,000,000,000,000,000,000 wei。另一个常见的单位是Gwei(发音为“Giga-way”)，也就是1,000,000,000 wei。**getBalance**方法是以wei中返回了结果，因此我们必须通过将结果除以10的18次方将其转换回ETH。你可以在[这里](https://ethdocs.org/en/latest/ether.html)找到全部的单位名称。

> *ℹ️* 你也可以使用 **ethers.utils.formatEther(balance)**, 相当于**ethers.utils.formatUnits(balance, 18)**的简写.

# 获得测试网络的USDC

你账户里的只有ETH，略显孤单，所以我们打算增加一些USDC。我已经在Ropsten testnet上部署了一个[伪USDC智能合约](https://ropsten.etherscan.io/token/0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4)。虽然我们没有专门获得免费USDC的网站，但是在合约中已经包含了该功能，当你调用它时，它会给你一些免费的testnet USDC。你可以在Etherscan中的[合约代码栏目](https://ropsten.etherscan.io/address/0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4#code)找到合约，并在合约源代码中搜索**gimmeSome**。我们将调用这个函数来将一些USDC发送到我们的帐户。

![](https://img.learnblockchain.cn/2020/07/24/15955742039661.jpg)

## 发起交易来调用智能合约

在以太坊的智能合约中有主要有两类方法：读写和只读。第一种方式可以修改区块链上的数据，而第二种仅仅是读取区块链上的数据，但是不能修改数据。 只读方法不用通过交易来调用，所以不会耗费ETH,除非是在读写方法中的一部分。读写方法是一定要通过交易来调用，所以一定会消耗ETH。调用**gimmeSome**方法会改变USDC数量的改变，所以必须通过一次交易来完成。

调用智能合约的方法需要再多些步骤，但是也不复杂。第一，需要知道调用方法的完整接口，被称为函数签名或函数原型。我们看下**gimmeSome**方法的源码如下：

```
function gimmeSome() external
```

这是一个没有任何参数的方法，而且被标记为**external**，表示只能从外部可以调用，不能被合约内的其他方法调用。这个对我们来说不影响，因为我们就是从外部调用。

>在主链上的[真实的USDC合约](https://etherscan.io/address/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)是没有**gimmeSome** 方法的

在**src** 文件夹下创建一个新文件，命名为**getTestnetUSDC.js**，然后输入以下代码

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main() {
  const account = wallet.connect(provider);

  const usdc = new ethers.Contract(
    "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
    ["function gimmeSome() external"],
    account
  );

  const tx = await usdc.gimmeSome({ gasPrice: 20e9 });
  console.log(`Transaction hash: ${tx.hash}`);

  const receipt = await tx.wait();
  console.log(`Transaction confirmed in block ${receipt.blockNumber}`);
  console.log(`Gas used: ${receipt.gasUsed.toString()}`);
}

main();
```

代码开始部分， 使用我们感兴趣的**gimmeSome**的接口和测试网络的地址USDC合约[0x68ec⋯69c4](https://ropsten.etherscan.io/address/0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4)地址实例化了一个合约对象(**new ethers.Contract**)。 这个方法是不需要任何参数，但是你可以在最后加入一个参数。这次我20 Gwei的gas费，来加快交易打包速度。与网络交互的所有方法在本质上是异步的,返回一个[**Promise**](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise),所以我们使用JavaScript的[**await**](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await)。完成后会返回交易的hash值，这是用于查看交易的惟一标识符。

运行该代码，你将看到如下内容:

```
$ node src/getTestnetUSDC.js
Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Transaction hash: 0xd8b4b06c19f5d1393f29b408fc0065d0774ec3b4d11d41be9fd72a8d84cb6208
Transaction confirmed in block 8156350
Gas used: 35121
```

好的，祝贺你通过代码的方式完成了第一次ETH的交易。在[Ropsten Etherscan](https://ropsten.etherscan.io/)查看下你的账户地址和交易hash。你应该可以查看到，账户里有10个测试USDC,ETH的余额小于1，因为支付了gas费用。

![](https://img.learnblockchain.cn/2020/07/24/15955743524825.jpg)

> *ℹ️*如果你在看Etherscan交易,你会发现这是一笔发送0个ETH连同4个字节的数据到合约地址。如果调用方法时有参数，就会有超过4字节的数据。如果你想了解该数据是如何编码的，请阅读[Ethereum合约ABI规范](https://solidity.readthedocs.io/en/v0.6.10/abi-spec.html)。

## Gas，Gas费用 和 Gas限制

之前我提到过，我们给这笔交易20Gwei的gas价格来加快交易速度，程序也显示了使用的gas的量。这一切意味着什么?嗯，以太坊是由网络运营商组成的网络。可以把它想象成一台世界计算机。这不是一台免费的电脑，你在这台电脑上运行的每条指令都要花钱。这台电脑也被全世界的人共享，这意味着每个人都必须互相竞争，以获得他们使用这台电脑的时间。

我们怎样才能做到公平呢?嗯，我们可以把这台电脑上的时间进行拍卖，你愿意出的价越高，你执行的效率也更快。这当然不是十全十美的，因为可能会导致只有有很多ETH的人才有特权使用这个电脑。然而，在系统变得更可扩展并能够容纳更多交易之前，这是我们可以选择的一个可行解决方案。

回到区块链术语上来， “gas used”是在完成交易所消耗的计算资源的数量，“gas price”是你愿意为每一单位gas支付的价格。一般来说，你愿意支付的金额越高，你的交易优先级就越高，通过网络确认的速度也就越快。上面我们使用20 Gwei作为gas价格，所使用的gas为35,121(可以在Etherscan中查看交易)，所以总共使用gas费用为35,121 * 20 Gwei = 702,420 Gwei或0.00070242 ETH。

因为gas需要消耗金钱，你可能想要设定你愿意花费的最多gas。幸运的是，你可以通过“gas limit”设置。如果交易最终需要的gas超过规定的限额，交易就会失败，而不会继续执行。需要注意的是如果交易因为gas限额而失败，已经花费的gas将不会退还给你。

## 通过调用智能合约读取数据

你可以在Etherscan上查看到收到了10个USDC，让我们通过代码检查余额来确认这一点。

我们修改下**src**文件夹下的**getBalance.js**文件

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main() {
  const account = wallet.connect(provider);

  // 定义合约接口
  const usdc = new ethers.Contract(
    "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
    [
      "function balanceOf(address _owner) public view returns (uint256 balance)",
    ],
    account
  );

  const ethBalance = await account.getBalance();
  console.log(`ETH Balance: ${ethers.utils.formatEther(ethBalance)}`);

  // 调用balanceOf方法
  const usdcBalance = await usdc.balanceOf(account.address);
  console.log(`USDC Balance: ${ethers.utils.formatUnits(usdcBalance, 6)}`);
}

main();
```

USDC是ERC20代币，因此它包含[ERC20规范](https://eips.ethereum.org/EIPS/eip-20)中定义的所有方法。**balanceOf**就是其中之一，它的接口直接来自规范定义的。 **balanceOf**是一个只读函数，所以它可以免费调用。最后，值得注意的是，USDC使用6位小数精度，而其他许多ERC20代币使用18位小数。

![](https://img.learnblockchain.cn/2020/07/24/15955744064056.jpg)

> *ℹ️*  你可以在[这里](https://solidity.readthedocs.io/en/v0.6.11/contracts.html#functions)了解更多关于Solidity方法。

执行以下代码，你就可以看到USDC余额

```
$ node src/getBalance.js
Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
ETH Balance: 0.9961879
USDC Balance: 10.0
```

# ETH和USDC转账


现在我们来看看怎么可以使用账户中的ETH和USDC

## 使用ETH

在**src**文件夹下创建**transferETH.js**文件

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main(args) {
  const account = wallet.connect(provider);
  let to, value;

  // 生成第一个参数——接受地址
  try {
    to = ethers.utils.getAddress(args[0]);
  } catch {
    console.error(`Invalid recipient address: ${args[0]}`);
    process.exit(1);
  }

    // 生成第二个参数——数量
  try {
    value = ethers.utils.parseEther(args[1]);
    if (value.isNegative()) {
      throw new Error();
    }
  } catch {
    console.error(`Invalid amount: ${args[1]}`);
    process.exit(1);
  }
  const valueFormatted = ethers.utils.formatEther(value);

  //检查账户有足够余额
  const balance = await account.getBalance();
  if (balance.lt(value)) {
    const balanceFormatted = ethers.utils.formatEther(balance);

    console.error(
      `Insufficient balance to send ${valueFormatted} (You have ${balanceFormatted})`
    );
    process.exit(1);
  }

  console.log(`Transferring ${valueFormatted} ETH to ${to}...`);

  // 提交转账
  const tx = await account.sendTransaction({ to, value, gasPrice: 20e9 });
  console.log(`Transaction hash: ${tx.hash}`);

  const receipt = await tx.wait();
  console.log(`Transaction confirmed in block ${receipt.blockNumber}`);
}

main(process.argv.slice(2));
```

这段代码虽然比前面的代码长，但实际上只是将之前所学的代码组合起来。这段代码中要有两个命令行参数。第一个是接收者地址，第二个是要发送的金额。然后确保提供的地址是有效的，提供的金额不是负数，并且帐户有足够的余额能够发送请求的金额。然后，提交交易并等待它被确认。

用之前的**createWallet.js**创建一个新账户，然后尝试向这个地址转些ETH

```
$ node src/createWallet.js
Mnemonic: napkin invite special reform cheese hunt refuse ketchup arena bag love caution
Address: 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 0.1**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Transferring 0.1 ETH to 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13...
Transaction hash: 0xa9f159fa8a9509ec8f8afa8ebb1131c3952cb3b2526471605fd84e8be408cebf
Transaction confirmed in block 8162896
```

![](https://img.learnblockchain.cn/2020/07/24/15955745416416.jpg)

你可以在[Etherscan](https://ropsten.etherscan.io/)看到结果，我们再来测试验证逻辑是有效的。

```
$ node src/transferETH.js foo
Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Invalid address: foo$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 0.1.2**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Invalid amount: 0.1.2$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 -0.1**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Invalid amount: -0.1$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 100**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Insufficient balance to send 100.0 (You have 0.89328474)
```

## USDC转账

上面很大一部的代码可以用到这里，主要的区别是USDC是精确到6位，还有你是使用ERC20 规范中的**transfer**。入参依然是“**to**” 及 “**value**”，然后调用智能合约的**transfer** 方法。

在同一文件下创建**transferUSDC.js**文件

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main(args) {
  const account = wallet.connect(provider);

  // 在合约中定义balanceOf和transfer方法
  const usdc = new ethers.Contract(
    "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
    [
      "function balanceOf(address _owner) public view returns (uint256 balance)",
      "function transfer(address _to, uint256 _value) public returns (bool success)",
    ],
    account
  );

  let to, value;

    // 生成第一个参数——接受地址
  try {
    to = ethers.utils.getAddress(args[0]);
  } catch {
    console.error(`Invalid address: ${args[0]}`);
    process.exit(1);
  }

    // 生成第二个参数——数量
  try {
    value = ethers.utils.parseUnits(args[1], 6);
    if (value.isNegative()) {
      throw new Error();
    }
  } catch {
    console.error(`Invalid amount: ${args[1]}`);
    process.exit(1);
  }
  const valueFormatted = ethers.utils.formatUnits(value, 6);

  //检查账户有足够余额
  const balance = await usdc.balanceOf(account.address);
  if (balance.lt(value)) {
    const balanceFormatted = ethers.utils.formatUnits(balance, 6);

    console.error(
      `Insufficient balance to send ${valueFormatted} (You have ${balanceFormatted})`
    );
    process.exit(1);
  }

  console.log(`Transferring ${valueFormatted} USDC to ${to}...`);

  // 提交转账，调用transfer方法
  const tx = await usdc.transfer(to, value, { gasPrice: 20e9 });
  console.log(`Transaction hash: ${tx.hash}`);

  const receipt = await tx.wait();
  console.log(`Transaction confirmed in block ${receipt.blockNumber}`);
}

main(process.argv.slice(2));
```

试一试，你应该可以看到以下结果：

```
$ node src/transferUSDC.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 1
Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Transferring 1.0 USDC to 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13...
Transaction hash: 0xc1b2157a83f29d6c04f960bc49e968a0cd2ef884761af7f95cc83880631fe4af
Transaction confirmed in block 8162963
```

![](https://img.learnblockchain.cn/2020/07/24/15955746249527.jpg)

# 恭喜

在本教程中，你学习了如何生成钱包、查询余额、转移代币和调用智能合约。你可能觉得自己还不太了解区块链，不过你已经有足够的知识，去构建自己加密钱包应用程序。为了保持简单，我们一直在编写命令行脚本，那么是否可以尝试构建一个图形界面的网页呢?

在本教程系列的下一部分中，我们将从头开始用solidity编写智能合约，并学习如何构建自己的硬币，可与USDC交换。我们还将使用今天学到的技术来与我们构建的合约进行互动。请继续关注。

原文链接：https://blog.coinbase.com/introduction-to-building-on-defi-with-ethereum-and-usdc-part-1-ea952295a6e2


