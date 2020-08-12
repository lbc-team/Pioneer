# Buidler 新手教程



## 1. 概述

欢迎来到**Buidler**的初学者指南，看看如何基于**Buidler**进行以太坊合约和dApp开发。

**Buidler**是一个方便在以太坊上进行构建的任务运行器。使用它可以帮助开发人员管理和自动化构建智能合约和dApp的过程中固有的重复任务，以及轻松地围绕此工作流程引入更多功能。



**Buidler**还内置了**Buidler EVM**，后者是为开发而设计的本地以太坊网络。 它允许你部署合约，运行测试和**调试代码**。



在本教程中，我们将指导你完成以下操作：

- 为以太坊开发设置Node.js环境

- 创建和配置 Buidler 项目

- 实现Solidity智能合约代币

- 使用 [Ethers.js](https://docs.ethers.io/ethers.js/html/) 和 [Waffle](https://getwaffle.io/)为合约编写自动化测试

- 使用**Buidler EVM**通过`console.log()`调试Solidity

- 将合约部署到**Buidler EVM**和以太坊测试网

  

要完成本教程，你应该能够：

- 编写 [JavaScript](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/JavaScript_basics)
- 打开 [terminal](https://en.wikipedia.org/wiki/Terminal_emulator)
- 使用 [git](https://git-scm.com/doc)
- 了解 [smart contracts](https://ethereum.org/learn/#smart-contracts) 基础知识
- 设置 [Metamask](https://metamask.io/)钱包



如果你不具备上述知识，请访问链接并花一些时间来学习基础知识。





## 2. 环境搭建



大多数以太坊库和工具都是用JavaScript编写的，**Buidler**也是如此。 如果你不熟悉Node.js，它是基于Chrome的V8 JavaScript引擎构建的JavaScript运行时。 这是在网络浏览器之外运行JavaScript的最受欢迎的解决方案，**Buidler **就是建立Node.js之上。



### 安装 Node.js

如果你已经安装了的Node.js`> = 10.0`，则可以跳过本节。 如果没有，请按照以下步骤在Ubuntu，MacOS和Windows上安装它。

#### Linux

##### Ubuntu

将以下命令复制并粘贴到终端中：

```text
sudo apt update
sudo apt install curl git
sudo apt install build-essential ## 构建工具，我们需要它来建立本地依赖
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install nodejs
```

#### MacOS

确保你已安装`git`。 否则，请遵循[这些说明](https://www.atlassian.com/git/tutorials/install-git)安装。



在MacOS上有多种安装Node.js的方法。 我们将使用 [Node 版本管理器(nvm)](http://github.com/creationix/nvm)。 将以下命令复制并粘贴到终端中：



```text
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.2/install.sh | bash
nvm install 10
nvm use 10
nvm alias default 10
npm install npm --global ## 将npm升级到最新版本
npm install -g node-gyp ## 确保我们已安装node-gyp
## 下一步需要构建本地依赖项。
## 将会出现一个弹出窗口，你必须继续进行安装。
## 这将需要一些时间，并且可能会下载几个G的数据。
xcode-select --install
```

#### Windows

在Windows上安装Node.js需要一些手动步骤。 我们将安装git，Node.js 10.x和NPM的Windows构建工具。 下载并运行以下命令：



1. [Git的Windows安装程序](https://git-scm.com/download/win)
2. 从 [这里](https://nodejs.org/dist/latest-v10.x)下载`node-v10.XX.XX-x64.msi` 

然后 [以管理员身份打开终端](https://www.howtogeek.com/194041/how-to-open-the-command-prompt-as-administrator-in-windows-8.1/) 并运行以下命令：

```text
npm install --global --production windows-build-tools
```

这将需要几分钟，并且可能会下载几GB的数据。



### 检查环境

为了确保你的开发环境已经准备就绪，请将以下命令复制并粘贴到新的终端中：



```text
git clone https://github.com/nomiclabs/ethereum-hackathon-setup-checker.git
cd ethereum-hackathon-setup-checker
npm install
```

如果成功，你将看到一条确认消息，表示你的开发环境已准备就绪。 你可以随时删除这个检查环境的代码库目录，然后在 [创建新的Buidler项目](https://buidler.dev/tutorial/creating-a-new-buidler-project.html)中继续前进。



如果遇到提示失败，则说明你的环境未正确设置。 确保已经安装了git和Node.js `>= 10.0`。 如果看到提到“ node-gyp”的错误，请确保安装了前面提到的构建工具。



如果你有旧版本的Node.js，请参阅下一节。

###  升级 Node.js

如果你的Node.js版本低于 `10.0` ，请按照以下说明进行升级。 完成后，请返回 [检查环境](https://buidler.dev/tutorial/setting-up-the-environment.html#checking-your-environment)。



#### Linux

##### Ubuntu

1. 在控制台运行 `sudo apt remove nodejs` 以删除 node.js
2. 在[此处](https://github.com/nodesource/distributions#debinstall)中找到要安装的Node.js版本，然后按照说明进行操作。
3. 在控制台运行  `sudo apt update && sudo apt install nodejs` 以再次安装新的 node.js

#### MacOS

你可以使用[nvm](http://github.com/creationix/nvm)更改Node.js版本。 要升级到Node.js`12.x`，请在终端中运行以下命令：



```text
nvm install 12
nvm use 12
nvm alias default 12
npm install npm --global ## Upgrade npm to the latest version
npm install -g node-gyp ## Make sure we have node-gyp installed
```

####  Windows



你需要像以前一样遵循[安装说明](https://buidler.dev/tutorial/setting-up-the-environment.html#windows)，但选择其他版本。 你可以在[此处](https://nodejs.org/en/download/releases/)检查所有可用版本的列表。



## 3. 创建新的 Buidler 工程



我们将使用npm 命令行安装**Builder **。 NPM是一个Node.js软件包管理器和一个JavaScript代码在线存储库。
打开一个新终端并运行以下命令：



```text
mkdir buidler-tutorial 
cd buidler-tutorial 
npm init --yes 
npm install --save-dev @nomiclabs/buidler 
```

> 提示：安装**Builder**将安装一些以太坊JavaScript依赖项，因此请耐心等待。

在安装**Builder**的目录下运行：



```text
npx buidler
```

使用键盘选择 “创建一个新的builder.config.js(`Create an empty buidler.config.js`)”，然后回车。



```text
$ npx buidler
888               d8b      888 888
888               Y8P      888 888
888                        888 888
88888b.  888  888 888  .d88888 888  .d88b.  888d888
888 "88b 888  888 888 d88" 888 888 d8P  Y8b 888P"
888  888 888  888 888 888  888 888 88888888 888
888 d88P Y88b 888 888 Y88b 888 888 Y8b.     888
88888P"   "Y88888 888  "Y88888 888  "Y8888  888

👷 Welcome to Buidler v1.0.0 👷‍‍

? What do you want to do? …
  Create a sample project
❯ Create an empty buidler.config.js
  Quit
```



在运行**Buidler**时，它将从当前工作目录开始搜索最接近的`buidler.config.js`文件。 这个文件通常位于项目的根目录下，一个空的`buidler.config.js`足以使**Buidler**正常工作。



### Buidler 架构

**Buidler**是围绕**task(任务)**和**plugins(插件)**的概念设计的。 **Buidler **的大部分功能来自插件，作为开发人员，你[可以自由选择](https://buidler.dev/plugins/)你要使用的插件。



#### Tasks(任务)

每次你从CLI运行**Buidler**时，你都在运行任务。 例如 `npx buidler compile`正在运行`compile`任务。 要查看项目中当前可用的任务，运行`npx buidler`。 通过运行`npx buidler help [task]`，可以探索任何任务。



> 提示：你可以创建自己的任务。 请查看[创建任务](https://buidler.dev/guides/create-task.html)指南。



#### Plugins(插件)

在最终选择哪种工具，**Buidler**并不是排他的，但是它确实内置了一些特性，所有这些也都可以覆盖。 大多数时候，使用给定工具的方法是使用将其集成到**Buidler**中的插件。



在本教程中，我们将使用Ethers.js和Waffle插件。 他们允许你与以太坊进行交互并测试合约。 稍后我们将解释它们的用法。 要安装它们，请在项目目录中运行：

```text
npm install --save-dev @nomiclabs/buidler-ethers ethers @nomiclabs/buidler-waffle ethereum-waffle chai
```



将高亮行添加到你的`builder.config.js`中，如下所示：

 

```js
usePlugin("@nomiclabs/buidler-waffle");

module.exports = {
  solc: {
    version: "0.6.8"
  }
};
```

我们在这里仅调用`builder-waffle`，因为它依赖于`builder-ethers`，因此不需要同时添加两者。



## 4. 编写和编译合约

我们将创建一个简单的智能合约，该合约实现可以转让的代币。 代币合约最常用于交换或存储价值。 在本教程中，我们将不深入讨论合约的Solidity代码，但是我们实现一些逻辑你应该知道：



- 代币有固定的发行总量，并且总量是无法更改的。
- 整个发行总量都分配给了部署合约的地址。
- 任何人都可以接收代币。
- 拥有至少一个代币的任何人都可以转让代币。
- 代币不可分割。 你可以转让1、2、3或37个代币，但不能转让2.5个代币。

>  提示：你可能听说过ERC20，这是以太坊中的代币标准。 DAI，USDC，MKR和ZRX之类的代币都遵循ERC20标准，使这些代币都可以与任何能处理ERC20代币的软件兼容。 **为了简单起见，我们要构建的代币不是ERC20**。

### 编写合约

首先创建一个名为 `contracts` 的新目录，然后在目录内创建一个名为`Token.sol`的文件。



将下面的代码粘贴到文件中，花一点时间阅读代码。 它很简单，并且有很多解释[Solidity基础语法](https://learnblockchain.cn/docs/solidity/)的注释。



> 提示：在文本编辑器中添加相应的插件(搜索Solidity 或 Ethereum 插件)可以支持Solidity语法高亮，我们建议使用Visual Studio Code或Sublime Text 3。

```solidity
// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.6.0;


// This is the main building block for smart contracts.
contract Token {
    // Some string type variables to identify the token.
    string public name = "My Buidler Token";
    string public symbol = "MBT";

    // The fixed amount of tokens stored in an unsigned integer type variable.
    uint256 public totalSupply = 1000000;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    // A mapping is a key/value map. Here we store each account balance.
    mapping(address => uint256) balances;

    /**
     * 合约构造函数
     *
     * The `constructor` is executed only once when the contract is created.
     * The `public` modifier makes a function callable from outside the contract.
     */
    constructor() public {
        // The totalSupply is assigned to transaction sender, which is the account
        // that is deploying the contract.
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    /**
     * 代币转账.
     *
     * The `external` modifier makes a function *only* callable from outside
     * the contract.
     */
    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        // If `require`'s first argument evaluates to `false` then the
        // transaction will revert.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    /**
     * 读取某账号的代币余额
     *
     * The `view` modifier indicates that it doesn't modify the contract's
     * state, which allows us to call it without executing a transaction.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
```

> 提示：`*.sol` 的Solidity 合约文件的后缀。 我们建议将文件名与其包含的合约名一致，这是一种常见的做法。

### 编译合约

要编译合约，请在终端中运行 `npx buidler compile` 。 `compile`任务是内置任务之一。



```text
$ npx buidler compile
Compiling...
Compiled 1 contract successfully
```

合约已成功编译，可以使用了。



## 5. 测试合约

为智能合约编写自动化测试至关重要，因为事关用户资金。 为此，我们将使用**Buidler EVM**，这是一个内置的以太坊网络，专门为开发而设计，并且是**Buidler **中的默认网络。 你无需进行任何设置即可使用它。 在我们的测试中，我们将使用[ethers.js](https://learnblockchain.cn/docs/ethers.js/)与上一节中构建的以太坊合约进行交互，并使用 [Mocha](https://mochajs.org/) 作为测试框架。



### 编写测试用例

在项目根目录中创建一个名为`test`的新目录，并创建一个名为`Token.js`的新文件。

让我们从下面的代码开始。 接下来，我们将对其进行解释，但现在将其粘贴到`Token.js`中：



```js
const { expect } = require("chai");

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    const [owner] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");

    const buidlerToken = await Token.deploy();
    await buidlerToken.deployed();

    const ownerBalance = await buidlerToken.balanceOf(owner.getAddress());
    expect(await buidlerToken.totalSupply()).to.equal(ownerBalance);
  });
});
```

在终端上运行`npx buidler test`。 你应该看到以下输出：



```text
$ npx buidler test
All contracts have already been compiled, skipping compilation.


  Token contract
    ✓ Deployment should assign the total supply of tokens to the owner (654ms)


  1 passing (663ms)
```

这意味着测试通过了。 现在我们逐行解释一下：

```js
const [owner] = await ethers.getSigners();
```



ethers.js中的`Signer`是代表以太坊账户的对象。 它用于将交易发送到合约和其他帐户。 在这里，我们获得了所连接节点中的帐户列表，在本例中节点为**Buidler EVM**，并且仅保留第一个帐户。



`ethers`变量在全局作用域下都可用。 如果你希望代码始终是明确的，则可以在顶部添加以下行：

```js
const { ethers } = require("@nomiclabs/buidler");
```

> 提示：要了解有关`Signer`的更多信息，可以查看[Signers文档](https://docs.ethers.io/ethers.js/html/api-wallet.html)。

```js
const Token = await ethers.getContractFactory("Token");
```

ethers.js中的`ContractFactory`是用于部署新智能合约的抽象，因此此处的`Token`是我们代币合约实例的工厂。

```js
const buidlerToken = await Token.deploy();
```

在`ContractFactory`上调用`deploy()`将启动部署，并返回解析为`Contract`的`Promise`。 该对象包含了智能合约所有函数的方法。



```js
await buidlerToken.deployed();
```

当你调用`deploy()`时，将发送交易，但是直到该交易打包出块后，合约才真正部署。 调用`deployed()`将返回一个`Promise`，因此该代码将阻塞直到部署完成。



```js
const ownerBalance = await buidlerToken.balanceOf(owner.getAddress());
```



部署合约后，我们可以在`buidlerToken` 上调用我们的合约方法，通过调用`balanceOf()`来获取所有者帐户的余额。



请记住，获得全部代币发行量的账户是进行部署的帐户，并且在使用 `buidler-ethers` 插件时，默认情况下， `ContractFactory`和`Contract`实例连接到第一个签名者。 这意味着`owner`变量中的帐户执行了部署，而`balanceOf()`应该返回全部发行量。



```js
expect(await buidlerToken.totalSupply()).to.equal(ownerBalance);
```



在这里，我们再次使用`Contract`实例调用Solidity代码中合约函数。 `totalSupply()`返回代币的发行量，我们检查它是否等于`ownerBalance`。



为此，我们使用[Chai](https://www.chaijs.com/)，这是一个断言库。 这些断言函数称为“匹配器”，我们在此使用的实际上来自[Waffle](https://getwaffle.io/)。 这就是为什么我们使用`buidler-waffle`插件，这使得从以太坊上断言值变得更容易。 请查看Waffle文档中的[此部分](https://ethereum-waffle.readthedocs.io/en/latest/matchers.html)，了解以太坊特定匹配器的完整列表。





#### 使用不同的账号



如果你需要从默认帐户以外的其他帐户(或ethers.js 中的 `Signer`)发送交易来测试代码，则可以在ethers.js的`Contract`中使用`connect()`方法来将其连接到其他帐户。 像这样：



```js
const { expect } = require("chai");

describe("Transactions", function () {

  it("Should transfer tokens between accounts", async function() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");

    const buidlerToken = await Token.deploy();
    await buidlerToken.deployed();
   
    // Transfer 50 tokens from owner to addr1
    await buidlerToken.transfer(await addr1.getAddress(), 50);
    expect(await buidlerToken.balanceOf(await addr1.getAddress())).to.equal(50);
    
    // Transfer 50 tokens from addr1 to addr2
    await buidlerToken.connect(addr1).transfer(await addr2.getAddress(), 50);
    expect(await buidlerToken.balanceOf(await addr2.getAddress())).to.equal(50);
  });
});
```



#### 完整测试



既然我们已经介绍了测试合约所需的基础知识，一下是代币的完整测试用例，其中包含有关Mocha以及如何构组织测试的许多信息。 我们建议你通读。



```js
// We import Chai to use its asserting functions here.
const { expect } = require("chai");

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Token contract", function () {
  // Mocha has four functions that let you hook into the the test runner's
  // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

  // They're very useful to setup the environment for tests, and to clean it
  // up after they run.

  // A common pattern is to declare some variables, and assign them in the
  // `before` and `beforeEach` callbacks.

  let Token;
  let buidlerToken;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("Token");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // To deploy our contract, we just have to call Token.deploy() and await
    // for it to be deployed(), which happens onces its transaction has been
    // mined.
    buidlerToken = await Token.deploy();
    await buidlerToken.deployed();

    // We can interact with the contract by calling `buidlerToken.method()`
    await buidlerToken.deployed();
  });

  // You can nest describe calls to create subsections.
  describe("Deployment", function () {
    // `it` is another Mocha function. This is the one you use to define your
    // tests. It receives the test name, and a callback function.

    // If the callback function is async, Mocha will `await` it.
    it("Should set the right owner", async function () {
      // Expect receives a value, and wraps it in an assertion objet. These
      // objects have a lot of utility methods to assert values.

      // This test expects the owner variable stored in the contract to be equal
      // to our Signer's owner.
      expect(await buidlerToken.owner()).to.equal(await owner.getAddress());
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await buidlerToken.balanceOf(owner.getAddress());
      expect(await buidlerToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      // Transfer 50 tokens from owner to addr1
      await buidlerToken.transfer(await addr1.getAddress(), 50);
      const addr1Balance = await buidlerToken.balanceOf(
        await addr1.getAddress()
      );
      expect(addr1Balance).to.equal(50);

      // Transfer 50 tokens from addr1 to addr2
      // We use .connect(signer) to send a transaction from another account
      await buidlerToken.connect(addr1).transfer(await addr2.getAddress(), 50);
      const addr2Balance = await buidlerToken.balanceOf(
        await addr2.getAddress()
      );
      expect(addr2Balance).to.equal(50);
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
      const initialOwnerBalance = await buidlerToken.balanceOf(
        await owner.getAddress()
      );

      // Try to send 1 token from addr1 (0 tokens) to owner (1000 tokens).
      // `require` will evaluate false and revert the transaction.
      await expect(
        buidlerToken.connect(addr1).transfer(await owner.getAddress(), 1)
      ).to.be.revertedWith("Not enough tokens");

      // Owner balance shouldn't have changed.
      expect(await buidlerToken.balanceOf(await owner.getAddress())).to.equal(
        initialOwnerBalance
      );
    });

    it("Should update balances after transfers", async function () {
      const initialOwnerBalance = await buidlerToken.balanceOf(
        await owner.getAddress()
      );

      // Transfer 100 tokens from owner to addr1.
      await buidlerToken.transfer(await addr1.getAddress(), 100);

      // Transfer another 50 tokens from owner to addr2.
      await buidlerToken.transfer(await addr2.getAddress(), 50);

      // Check balances.
      const finalOwnerBalance = await buidlerToken.balanceOf(
        await owner.getAddress()
      );
      expect(finalOwnerBalance).to.equal(initialOwnerBalance - 150);

      const addr1Balance = await buidlerToken.balanceOf(
        await addr1.getAddress()
      );
      expect(addr1Balance).to.equal(100);

      const addr2Balance = await buidlerToken.balanceOf(
        await addr2.getAddress()
      );
      expect(addr2Balance).to.equal(50);
    });
  });
});
```

这是 `npx buidler test`在完整测试用例下输出的样子：



```text
$ npx buidler test
All contracts have already been compiled, skipping compilation.

  Token contract
    Deployment
      ✓ Should set the right owner
      ✓ Should assign the total supply of tokens to the owner
    Transactions
      ✓ Should transfer tokens between accounts (199ms)
      ✓ Should fail if sender doesn’t have enough tokens
      ✓ Should update balances after transfers (111ms)


  5 passing (1s)
```

请记住，当你运行`npx buidler test`时，如果你的合约在上次运行测试后发生了修改，则会对其进行重新编译。





## 6. 用 Buidler EVM 调试

**Buidler**内置了**Buidler EVM **，这是一个专为开发而设计的以太坊网络。 它允许你部署合约，运行测试和调试代码。 这是**Buidler**所连接的默认网络，因此你无需进行任何设置即可工作。 你只需运行测试就好。



### Solidity `console.log`

在**Buidler EVM**上运行合约和测试时，你可以在Solidity代码中调用`console.log()`打印日志信息和合约变量。 你必须先从合约代码中导入**Buidler **的`console.log`再使用它。

像这样：

```solidity
pragma solidity ^0.6.0;

import "@nomiclabs/buidler/console.sol";

contract Token {
  //...
}
```

就像在JavaScript中使用一样，将一些`console.log`添加到`transfer()`函数中：



```solidity
function transfer(address to, uint256 amount) external {
    console.log("Sender balance is %s tokens", balances[msg.sender]);
    console.log("Trying to send %s tokens to %s", amount, to);

    require(balances[msg.sender] >= amount, "Not enough tokens");

    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

运行测试时，将输出日志记录：



```text
$ npx buidler test
Compiling...
Compiled 2 contracts successfully


  Token contract
    Deployment
      ✓ Should set the right owner
      ✓ Should assign the total supply of tokens to the owner
    Transactions
Sender balance is 1000 tokens
Trying to send 50 tokens to 0xead9c93b79ae7c1591b1fb5323bd777e86e150d4
Sender balance is 50 tokens
Trying to send 50 tokens to 0xe5904695748fe4a84b40b3fc79de2277660bd1d3
      ✓ Should transfer tokens between accounts (373ms)
      ✓ Should fail if sender doesn’t have enough tokens
Sender balance is 1000 tokens
Trying to send 100 tokens to 0xead9c93b79ae7c1591b1fb5323bd777e86e150d4
Sender balance is 900 tokens
Trying to send 100 tokens to 0xe5904695748fe4a84b40b3fc79de2277660bd1d3
      ✓ Should update balances after transfers (187ms)


  5 passing (2s)
```

请查看[buidler 文档](https://buidler.dev/buidler-evm/#console-log)以了解有关此功能的更多信息。



## 7. 部署

准备好与其他人分享dApp后，你可能要做的就是将其部署到真实的以太坊网络中。 这样，其他人可以访问不在本地系统上运行的实例。



具有真实价值的以太坊网络被称为“主网”，然后还有一些不具有真实价值但能够很好地模拟主网的网络，它可以被其他人共享阶段的环境。 这些被称为“测试网”，以太坊有多个：*Ropsten*，*Kovan*，*Rinkeby*和*Goerli*。 我们建议你将合约部署到*Ropsten*测试网。



在应用软件层，部署到测试网与部署到主网相同。 唯一的区别是你连接到哪个网络。 让我们研究一下使用ethers.js部署合约的代码是什么样的。



主要概念是`Signer`，`ContractFactory`和`Contract`，我们在[测试](https://buidler.dev/tutorial/testing-contracts.html)部分中对此进行了解释。 与测试相比，并没有什么新的内容，因为当你测试合约时，你实际上是在向开发网络进行部署。 因此代码非常相似或相同。



让我们在项目根目录的目录下创建一个新的目录`scripts`，并将以下内容粘贴到 `deploy.js`文件中：



```js
async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    await deployer.getAddress()
  );
  
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();

  await token.deployed();

  console.log("Token address:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```



为了在运行任何任务时指示**Builder**连接到特定的以太坊网络，可以使用`--network`参数。 像这样：



```text
npx buidler run scripts/deploy.js --network <network-name>
```



在这种情况下，如果不使用`--network` 参数来运行它，则代码将再次部署在**Buidler EVM **上，因此，当**Buidler**完成运行时，部署实际上会丢失，但是它用来测试我们的部署代码时仍然有用：



```text
$ npx buidler run scripts/deploy.js
All contracts have already been compiled, skipping compilation.
Deploying contracts with the account: 0xc783df8a850f42e7F7e57013759C285caa701eB6
Account balance: 10000000000000000000000
Token address: 0x7c2C195CD6D34B8F845992d380aADB2730bB9C6F
```

### 部署到线上网络

要部署到诸如主网或任何测试网之类的线上网络，你需要在`buidler.config.js` 文件中添加一个`network`条目。 在此示例中，我们将使用Ropsten，但你可以类似地添加其他网络：



```js
usePlugin("@nomiclabs/buidler-waffle");

// Go to https://infura.io/ and create a new project
// Replace this with your Infura project ID
const INFURA_PROJECT_ID = "YOUR INFURA PROJECT ID";

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const ROPSTEN_PRIVATE_KEY = "YOUR ROPSTEN PRIVATE KEY";

module.exports = {
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: [`0x${ROPSTEN_PRIVATE_KEY}`]
    }
  }
};
```

我们这里使用[Infura](https://infura.io/)，但是你将url指向其他任何以太坊节点或网关都是可以。请你从https://infura.io/网站复制 Project ID，替换`INFURA_PROJECT_ID`。



要在Ropsten上进行部署，你需要将ropsten-ETH发送到将要进行部署的地址中。 你可以从水龙头获得一些用于测试网的ETH，水龙头服务免费分发测试使用的ETH。 [这是Ropsten的一个水龙头](https://faucet.metamask.io/)，你必须在进行交易之前将Metamask的网络更改为Ropsten。



> 提示：你可以通过以下链接为其他测试网获取一些ETH
>
> * [Kovan faucet](https://faucet.kovan.network/)
> * [Rinkeby faucet](https://faucet.rinkeby.io/)
> * [Goerli faucet](https://goerli-faucet.slock.it/)

最后运行：

```text
npx buidler run scripts/deploy.js --network ropsten
```

如果一切顺利，你应该看到已部署的合约地址。



## 8. Buidler 前端模板项目

如果你想快速开始使用dApp或使用前端查看整个项目，可以使用我们的[hackathon模板库](https://github.com/nomiclabs/buidler-hackathon-boilerplate)。



### 包含了哪些内容

- 我们在本教程中使用的Solidity合约
- 使用ethers.js和Waffle的测试用例
- 使用ethers.js与合约进行交互的最小前端

####  合约及测试

在项目仓库的根目录中，你会发现本教程的`Token`合约已经放在里面，回顾一下其实现的内容：



- 代币有固定的发行总量，并且总量是无法更改的。

- 整个发行总量都分配给了部署合约的地址。

- 任何人都可以接收代币。

- 拥有至少一个代币的任何人都可以转让代币。

- 代币不可分割。 你可以转让1、2、3或37个代币，但不能转让2.5个代币。

  

####  前端应用

在 `frontend/` 下你会发现一个简单的前端应用，它允许用户执行以下两项操作：

- 查看已连接钱包的账户余额
- 代币转账

这是一个单独的npm项目，是使用 `create-react-app`创建的，这意味着它使用了webpack和babel。



#### 前端目录结构

- ```
  src/ 
  ```

  包含了所有代码

  - ```
  src/components
    ```
  
    包含了 react 组件

    - `Dapp.js` 是唯一具有业务逻辑的文件。 如果用作模板使用，请在此处用自己的代码替换它
- 其他组件仅渲染HTML，没有逻辑。
  
    - `src/contracts` 具有合约的ABI和地址，这些由部署脚本自动生成。

### 如何使用

首先克隆代码库，然后部署合约：

```text
cd buidler-hackathon-boilerplate/
npm install
npx buidler node
```

在这里，我们仅需要安装npm项目的依赖项，然后运行`npx buidler node`启动一个可以公MetaMask连接的**Buidler EVM**实例。 在同一目录下的另一个终端中运行：

```text
npx buidler --network localhost run scripts/deploy.js
```

这会将合约部署到**Builder EVM**。 完成此运行后：



```text
cd buidler-hackathon-boilerplate/frontend/
npm install
npm run start
```

启动react Web应用后，在浏览器中打开http://localhost:3000/，你应该看到以下内容：

![img](https://img.learnblockchain.cn/pics/20200811150131.png)

在MetaMask中将你的网络设置为`localhost:8545`，然后单击“Connect Wallet”按钮。 然后，你应该看到以下内容：



![img](https://img.learnblockchain.cn/pics/20200811150224.png)

前端代码正在检测到当前钱包余额为“ 0”，因此你将无法使用转账功能。运行：



```text
npx buidler --network localhost faucet <your address>
```



你运行的是自定义**Builder**任务，该任务使用部署帐户的余额向你的地址发送100 MBT和1 ETH。 之后你就可以将代币发送到另一个地址。



你可以在[`/tasks/faucet.js`](https://github.com/nomiclabs/buidler-hackathon-boilerplate/blob/master/tasks/faucet.js)中查看任务的代码， 它需要在`buidler.config.js`引入。



```text
$ npx buidler --network localhost faucet 0x0987a41e73e69f60c5071ce3c8f7e730f9a60f90
Transferred 1 ETH and 100 tokens to 0x0987a41e73e69f60c5071ce3c8f7e730f9a60f90
```

在运行`npx buidler node`的终端中，你还应该看到：



```text
eth_sendTransaction
  Contract call:       Token#transfer
  Transaction:         0x460526d98b86f7886cd0f218d6618c96d27de7c745462ff8141973253e89b7d4
  From:                0xc783df8a850f42e7f7e57013759c285caa701eb6
  To:                  0x7c2c195cd6d34b8f845992d380aadb2730bb9c6f
  Value:               0 ETH
  Gas used:            37098 of 185490
  Block #8:            0x6b6cd29029b31f30158bfbd12faf2c4ac4263068fd12b6130f5655e70d1bc257

  console.log:
    Transferring from 0xc783df8a850f42e7f7e57013759c285caa701eb6 to 0x0987a41e73e69f60c5071ce3c8f7e730f9a60f90 100 tokens
```

上面显示了合约中`transfer()`函数的`console.log`输出，这是运行水龙头任务后Web应用的界面：

 ![front-6](https://img.learnblockchain.cn/pics/20200811151458.png)



试着去阅读这份代码。 里面有很多注释解释了代码所做的事情，它清楚地表明哪些代码是以太坊模板，哪些是实际的dApp逻辑。 让我们在项目中重用它非常方便。



## 9. 最后的想法

恭喜你完成了本教程！

以下是在开发旅程中可能会有用的一些链接：

- [Buidler模板工程](https://github.com/nomiclabs/buidler-hackathon-boilerplate)
- [Buidler's 文档](https://buidler.dev/getting-started/)
- [Telegram Buidler Support Group](https://t.me/BuidlerSupport)
- [Ethers.js 文档](https://docs.ethers.io/ethers.js/html/) 及 [ethers.js文档中文版](https://learnblockchain.cn/docs/ethers.js/)
- [Waffle 文档](https://getwaffle.io/)
- [Mocha 文档](https://mochajs.org/)
- [Chai 文档](https://www.chaijs.com/)



![img](https://buidler.dev/cool-buidler.svg)



原文链接：https://buidler.dev/tutorial/
