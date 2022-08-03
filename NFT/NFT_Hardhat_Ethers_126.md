原文链接：https://dev.to/jacobedawson/import-test-a-popular-nft-smart-contract-with-hardhat-ethers-12i5

![06537eazw81rxn3xzv54.jpg](https://img.learnblockchain.cn/attachments/2022/05/BuyLYxvN62942b1836696.jpg)
 

# 用Hardhat和Ethers引入测试知名的NFT智能合约

今天我们将学习如何使用非常酷的[智能合约开发框架Hardhat](https://hardhat.org/),在本地导入,并且测试公开部署的智能合约。 为了让事情变得有趣和相关，将在示例中使用 Bored Ape Yacht Club NFT 智能合约。使用知名项目的智能合约应该清楚以太坊生态的开放程度，以及有多少上手Dapp和智能合约开发的机会！


在本教程结束时，你将了解以下内容：

- 如何找到特定项目的智能合约代码
- 如何将该代码添加到本地开发环境
- 如何安装和设置一个简单的Hardhat开发环境
- 如何编译合约并为其编写测试功能



本教程不涉及任何前端开发，但如果你有兴趣了解如何开始 Web3 dapp 开发，请随时在 dev.to 上查看我以前的教程：

 
- [在 React 中构建 Web3 Dapp, 并使用 MetaMask 登录](https://dev.to/jacobedawson/build-a-web3-dapp-in-react-login-with-metamask-4chp)
- [使用 useDapp 通过 MetaMask 发送 React Web3 交易](https://dev.to/jacobedawson/send-react-web3-dapp-transactions-via-metamask-2b8n)



### 第 1 步：查找智能合约代码


首先，我们将首先选择一个项目（Bored Ape Yacht Club），然后追踪智能合约代码。 就个人而言，在这种情况下，我要做的第一件事是快速查看相关项目的网站，看看他们是否有指向合约的链接。 在这种情况下，https://boredapeyachtclub.com/ 仅包含社交链接，因此将不得不寻找其他地方。


由于Bored Ape Yacht Club是一个基于以太坊的 NFT 项目，我们的下一个停靠点将是以太坊区块链浏览器 [Etherscan](https://etherscan.io/)。 因为我知道 Bored Ape Yacht Club 使用符号 BAYC，所以我可以使用 Etherscan 搜索该符号（为什么，是的，我对所有东西都使用暗模式，你怎么知道？ 



[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--Upq6jmnu--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/o6wz8nqernbmpadnfi0q.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--Upq6jmnu--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/o6wz8nqernbmpadnfi0q.png)


我们开始了 - 可以看到这是一个经过验证的 ERC-721 代币合约，其名称是我们正在寻找的！ 如果我们点击搜索结果，将进入 BoredApeYachtClub 代币页面，其 Etherscan 地址为：https://etherscan.io/token/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d

太好了，我们越来越近了——在token页面的右上角，称为“Profile Summary(资料摘要)”，将看到一个带有链接的”Contract(合约)”地址:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--Sbboz9Hp--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/va8pqml5d2wxrxr11ciw.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--Sbboz9Hp--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/va8pqml5d2wxrxr11ciw.png)


如果我们点击它，将到 Etherscan 上的“Contract(合约)”页面——这就是要寻找的！ 点击”Contract(合约)”标签：

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--6H_DDmp6--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rihi89wfk1rr33vtrqi0.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--6H_DDmp6--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rihi89wfk1rr33vtrqi0.png)

 

我们有了它 - 名为 BoredApeYachtClub 是经过验证的合约源代码。 这是该特定部分的 Etherscan 链接：https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code

 

现在，鉴于我们知道合约名称、符号和地址，此时你可能想知道是否有其他办法以编程方式检索合约代码。 答案是：当然 :) 。但是现在让我们以手动方式进行，我将留给你设计一些更有效的方法来使用代码获取合约 :) 


[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--nlfhRO9O--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hmlr5ow7oyuvdna1fdki.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--nlfhRO9O--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hmlr5ow7oyuvdna1fdki.png)


我们几乎完成了第 1 步 - 可以复制合约代码并将其保存在某个地方 - 现在你可以将其放在记事本中或将其保存在某个文件中，稍后我们将回到这个文件 在教程中。 接下来，我们将设置Hardhat环境..

### 步骤 2：设置我们的Hardhat项目

以太坊开发工具的发展并没有很长的时间——以太坊的最初版本是在 2015年7月——截至撰写本文时，它只有 6 年（这很难相信以太坊生态系统在这段时间里已经走了多远）。感谢以太坊社区的努力，我们已经从只适合有经验的开发人员的基本开发环境发展到2021年，我们有幸拥有为以太坊生态开发精心准备的框架、工具和库。


[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--FsjkCbMW--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dtbm0mil8a1ex0agp4ua.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--FsjkCbMW--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dtbm0mil8a1ex0agp4ua.png)

 
Nomic Labs 的伙伴们已经低调地创造了以太坊开发环境的标准：[Hardhat](https://hardhat.org/)。 它包括测试运行、编译、部署、丰富的插件系统和运行一切的本地网络。 当与 [Ethers](https://docs.ethers.io/v5/)、[Waffle](https://getwaffle.io/) 和 [Chai](https://www. chaijs.com/)，Hardhat 将整个控制面板放在你面前，让以太坊项目从构思到 [IDO](https://hackernoon.com/what-is-ido-the-new-alternative-to-ieo-and-ico-70l34zf)。


注意：此部分的说明也可以在此处找到更详细的说明：https://hardhat.org/getting-started/#overview

让我们首先在本地环境中创建一个新文件夹：

```
mkdir hardhat-tutorial
```


进入那个新文件夹，运行`npm init -Y`，然后安装hardhat：

```
npm i -D hardhat
```


现在运行 `npx hardhat` 并选择“Create an empty hardhat.config.js(新建一个hardhat.config.js文件)”：

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s---9JzCr0W--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/316a9tftmd3jx60dglun.png)](https://res.cloudinary.com/practicaldev/image/fetch/s---9JzCr0W--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/316a9tftmd3jx60dglun.png)

我们很快就会看到将为添加一个 hardhat.config.js 文件。我们还将安装一些其他工具，包括 Waffle 测试套件和 Ethers。 所以运行：

```
npm i -D @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
```



为了我们一路顺利，让 [Hardhat 项目 TypeScript 准备就绪](https://hardhat.org/guides/typescript.html)。

首先，安装 TypeScript 和一些类型：

```
npm i -D ts-node typescript @types/node @types/chai @types/mocha
```


然后我们将`hardhat.config.js` 文件重命名为 `hardhat.config.ts`：

```
mv hardhat.config.js hardhat.config.ts
```



我们现在需要对 `hardhat.config.ts` 文件进行更改，因为对于 Hardhat TypeScript 项目，插件需要使用 `import` 而不是 `require` 加载，并且必须显式导入函数：

改变这里：

```
// hardhat.config.ts
require("@nomiclabs/hardhat-waffle");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.7.3",
};
```



进入这里：

```
// hardhat.config.ts
import { task } from "hardhat/config"; // import function
import "@nomiclabs/hardhat-waffle"; // change require to import

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.address);
  }
});

export default {
  solidity: "0.7.3",
};
```

 令人愉快的 - 我们使用 TypeScript 进行设置。 现在，如果你再次运行 `npx hardhat`，你应该会在控制台中看到一些帮助说明：


[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--UfC3Uaz9--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3l32vplkvko7vk2rbguh.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--UfC3Uaz9--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3l32vplkvko7vk2rbguh.png)

 


厉害了！ 如果你已经做到了这一点，我们就有了一个使用 TypeScript 配置的 Hardhat 项目，并且安装了所需的工具。

请注意，在上面的屏幕截图中，有一个名为"Available Tasks"的部分 - 这是 Hardhat 团队提供的内置任务列表，使我们能够从一开始就运行重要任务。 Hardhat 具有极强的延展性，可与三方插件一起使用，帮助我们调整项目以满足特定需求。 我们已经安装了 hardhat-waffle 和 hardhat-ethers 插件，你可以在此处找到大量插件列表：https://hardhat.org/plugins/

我们也可以创建自己的任务。 如果你打开 `hardhat.config.ts`，你将看到示例“accounts(帐户)”任务定义。 任务定义函数接受 3 个参数 - 名称、描述和执行任务的回调函数。 如果你将“accounts(帐户)”任务的描述更改为“Hello, world!”，然后在控制台中运行`npx hardhat`，你将看到“accounts(帐户)”任务现在具有描述“Hello, world!”。

```
// hardhat.config.ts
import { task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";

task("accounts", "Hello, world!", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  solidity: "0.7.3",
};
```



[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--0rZJ_vMT--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ppslyd1vdj4xl6bpaf7v.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--0rZJ_vMT--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ppslyd1vdj4xl6bpaf7v.png)
 

现在我们简单的 Hardhat 项目已经全部建立，继续导入和编译我们的 Bored Ape 合约......

 
### 第 3 步：导入和编译我们的合约

让我们首先在根目录中创建一个名为 `contracts` 的新文件夹（Hardhat 默认使用“contracts(合约)”文件夹作为源文件夹 - 如果你想更改该名称，你需要在 `hardhat.config.ts` 文件里配置）：

```
mdkir contracts
```

 

在 contracts 文件夹中创建一个名为“bored-ape.sol”的新文件，然后粘贴我们之前从 Etherscan 复制的合约代码。

注意：.sol 扩展名是 Solidity 文件扩展名。 要为 Solidity 文件添加语法突出显示和类型提示，[Juan Blanco 称为“solidity”]（https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity）制作了一个很棒的 VSCode 扩展 - 我建议安装 它使开发 Solidity 更容易：


[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--hF14pbnX--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hdlme4tjzpe9cc7k35kd.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--hF14pbnX--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hdlme4tjzpe9cc7k35kd.png)

 

我还使用了一个名为 ["Solidity Visual Developer"](https://marketplace.visualstudio.com/items?itemName=tintinweb.solidity-visual-auditor) 的 VSCode 扩展，你会在 VSCode 市场中找到更多。

现在我们有了一个 `contracts` 文件夹，里面有 `bored-ape.sol` 合约，我们准备编译合约。 我们可以使用内置的 `compile` 任务来执行此操作 - 我们需要做的就是运行：


```
npx hardhat compile
```


当我们使用 Hardhat 编译合约时，将为每个合约生成两个文件，并放置在 `artifacts/contracts/<CONTRACT NAME>` 文件夹中。 这两个文件（分别是“artifact”.json 文件和“dbg”.json 文件）将为*每个合约*生成这样的文件——我们从 Etherscan 复制的 Bored Ape 合约代码实际上包含多个“contracts(合约)”。


如果查看原始的 `contracts/bored-ape.sol` 文件，你会发现“contract(合约)”关键字总共使用了 15 次，并且每个实例都有自己的合约名称 - 因此，在编译 `bored-ape. sol` 文件我们最终会在 `artifacts/contracts/bored-ape.sol/` 文件夹中得到 30 个文件。

不过没关系 - 因为 Solidity 合约本质上是面向对象的类，我们只需要关注 `BoredApeYachtClub.json` 工件 - 这是包含“BoredApeYachtClub” ABI 的文件（[应用程序二进制接口]（https://docs.soliditylang.org/en/latest/abi-spec.html#abi-json），合约变量和函数的 JSON 表示），这正是我们需要使用以太币以创建合约实例的内容 .

 
我们现在已经实现了3/4的目标，——本教程的最后一个目标是编写一个测试文件，以便我们可以针对导入的合约运行测试。

### 第 4 步：为我们的合约编写测试

测试是一个深刻而复杂的主题，因此我们将保持简单，以便你了解一般流程并按照自己的步调深入研究该主题。 我们这一步的目标是为“BoredApeYachtClub”合约设置和编写一些测试。
 
我们已经安装了“hardhat-ethers”，这是一个 Hardhat 插件，可以让我们访问“Ethers”库，并使我们能够与我们的智能合约进行交互。

注意：如果你有一个 JavaScript / Hardhat 项目，Hardhat Runtime Environment 的所有属性都会自动注入到全局范围内。 然而，当使用 TypeScript 时，没有全局范围内可用的上下文，所以我们必须显式地导入实例。

让我们在根目录下的 `test` 文件夹中新建一个测试，并命名为 `bored-ape.test.ts`。 现在我们将编写一个测试，我将在代码注释中解释我们在做什么：


```
// bored-ape.test.ts
// We are using TypeScript, so will use "import" syntax
import { ethers } from "hardhat"; // Import the Ethers library
import { expect } from "chai"; // Import the "expect" function from the Chai assertion library, we'll use this in our test

// "describe" is used to group tests & enhance readability
describe("Bored Ape", () => {
  // "it" is a single test case - give it a descriptive name
  it("Should initialize Bored Ape contract", async () => {
    // We can refer to the contract by the contract name in 
    // `artifacts/contracts/bored-ape.sol/BoredApeYachtClub.json`
    // initialize the contract factory: https://docs.ethers.io/v5/api/contract/contract-factory/
    const BoredApeFactory = await ethers.getContractFactory("BoredApeYachtClub");
    // create an instance of the contract, giving us access to all
    // functions & variables
    const boredApeContract = await BoredApeFactory.deploy(
      "Bored Ape Yacht Club",
      "BAYC",
      10000,
      1
    );
    // use the "expect" assertion, and read the MAX_APES variable
    expect(await boredApeContract.MAX_APES()).to.equal(5000);
  });
});
```
 
这是相当多的代码！ 本质上，我们正在创建一个合约工厂，其中包含部署合约所需的额外信息。 一旦我们有了合约工厂，就可以使用 .deploy() 方法，传入合约构造函数所需的变量。 这是原始的合约构造函数：

```
//bored-ape.sol
constructor(string memory name, string memory symbol, uint256 maxNftSupply, uint256 saleStart) ERC721(name, symbol)
```
 

构造函数接受 4 个参数，每个参数都有类型定义：

- name，字符串
- symbol ，字符串
- maxNftSupply，数字
- saleStart，数字

好的 - 现在是关键时刻 - 让我们运行我们的测试：

```
npx hardhat test
```

你应该看到如下内容：


[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--90AWA7DQ--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2bgksduuxlg8tjzqtmpt.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--90AWA7DQ--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2bgksduuxlg8tjzqtmpt.png)

 

但是坚持住 - 为什么它失败了？好吧，我们可以看到 1) Bored Ape `AssertionError: Expected "10000" to be equal 5000`。这没什么好担心的——我故意添加了一个在第一次运行时会失败的测试用例——这是一种很好的做法，有助于消除误报。如果我们一开始不添加一个失败的案例，我们就不能确定不会意外地编写一个总是返回 true 的测试。这种方法的更彻底的版本实际上会首先创建测试，然后逐渐编写代码以使其通过，但由于它不是本教程的重点，我们将忽略它。如果你有兴趣了解更多关于这种编写测试的风格，然后实现代码以使其通过，这里有几个很好的介绍：


- https://www.codecademy.com/articles/tdd-red-green-refactor
- http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html
- https://medium.com/@tunkhine126/red-green-refactor-42b5b643b506

为了让我们通过测试，修改这行，值修改为10000:

```
expect(await boredApeContract.MAX_APES()).to.equal(10000);
```



[![image](https://res.cloudinary.com/practicaldev/image/fetch/s---bEolRJ2--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/svlex3607kmajgjpu0ph.png)](https://res.cloudinary.com/practicaldev/image/fetch/s---bEolRJ2--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/svlex3607kmajgjpu0ph.png)

 

好的！ 现在有一个测试用例通过了 :) 让我们再写几个测试来强化练习。

不过，在我们这样做之前，将使用一个名为“beforeEach”的辅助函数，它将简化每个测试的设置，并允许为每个测试重用变量。 我们将把合约部署代码移动到 `beforeEach` 函数中，如你所见，可以在“初始化”测试中使用 `boredApeContract` 实例：

```
// bored-ape.test.ts
import { expect } from "chai";
import { ethers } from "hardhat";
import { beforeEach } from "mocha";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("Bored Ape", () => {
  let boredApeContract: Contract;
  let owner: SignerWithAddress;
  let address1: SignerWithAddress;

  beforeEach(async () => {
    const BoredApeFactory = await ethers.getContractFactory(
      "BoredApeYachtClub"
    );
    [owner, address1] = await ethers.getSigners();
    boredApeContract = await BoredApeFactory.deploy(
      "Bored Ape Yacht Club",
      "BAYC",
      10000,
      1
    );
  });

  it("Should initialize the Bored Ape contract", async () => {
    expect(await boredApeContract.MAX_APES()).to.equal(10000);
  });

  it("Should set the right owner", async () => {
    expect(await boredApeContract.owner()).to.equal(await owner.address);
  });
});
```
 

由于我们使用的是 TypeScript，在“beforeEach”中为我们的变量导入了类型，并添加了一个“owner”和“address1”变量，可以在需要地址的测试用例中使用。 我们通过添加另一个测试“应该设置正确的所有者”来使用所有者变量 - 这将检查合约的所有者是否与我们部署合约时返回的所有者相同。

在 `bored-ape.sol` 文件中，请注意有一个名为 `mintApe` 的函数，它接收多个token（代表 Bored Ape NFT），并且还期望接收一些 ETH。 让我们为该函数编写一个测试，这将让我们尝试支付，并迫使我们使用合约中的其他一些方法来使测试通过。

将从定义测试开始：

```
// bored-ape.test.ts
it("Should mint an ape", async () => {
  expect(await boredApeContract.mintApe(1)).to.emit(
    boredApeContract,
    "Transfer"
  );
});
```

由于 `mintApe` 方法没有返回值，我们将监听一个名为“Transfer”的事件——可以跟踪 `mintApe` 函数的继承，并看到它最终调用了 ERC-721 的 `_mint` 函数，并发出 { Transfer } 事件：


[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--hm-o1ujT--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xtqzs2uj42dm2yxb5fyp.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--hm-o1ujT--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xtqzs2uj42dm2yxb5fyp.png)
 

目前，我们监听“Transfer”事件并不重要——这个测试将会失败，因为 `mintApe` 包含许多没有满足的条件：


[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--mSxWDSGO--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3nynbhcek8zd74pos4gy.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--mSxWDSGO--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3nynbhcek8zd74pos4gy.png)

 

我们可以看到一个错误“Sale must be active to mint Ape”，所以看起来我们首先必须调用合约方法`flipSaleState`：
```
// bored-ape.test.ts
await boredApeContract.flipSaleState();
```


运行 `npx hardhat test` 并且......我们仍然失败 - 但出现了不同的错误！ 一个不同的错误实际上是个好消息，因为这意味着正在取得进展 :) 看起来“Ether value sent is not correct(发送的以太币不正确)”——这是有道理的，因为我们没有在合约调用中发送任何 ETH。 请注意，`mintApe` 方法签名包含关键字“payable”：

```
// bored-ape.sol
function mintApe(uint numberOfTokens) public payable 
```


这意味着该方法可以（并且期望）接收 ETH。 我们可以通过调用 `apePrice` getter 方法首先能得到 Bored Ape 所需的成本：


```
// bored-ape.sol
uint256 public constant apePrice = 80000000000000000; //0.08 ETH
```


最后，我们需要导入更多函数，使用 `apePrice` 作为我们的值，并通过调用 `mintApe` 将其作为 ETH 发送。 还将另一个名为 `withArgs` 的方法触发我们的 `emit` ，这将使能够监听“Transfer”事件发出的参数：


```
// bored-ape.test.ts
import chai from "chai";
import { solidity } from "ethereum-waffle";

chai.use(solidity)

it("Should mint an ape", async () => {
  await boredApeContract.flipSaleState();
  const apePrice = await boredApeContract.apePrice();
  const tokenId = await boredApeContract.totalSupply();
  expect(
    await boredApeContract.mintApe(1, {
      value: apePrice,
    })
  )
  .to.emit(boredApeContract, "Transfer")
  .withArgs(ethers.constants.AddressZero, owner.address, tokenId);
});
```


我们正在使用“overrides”对象（https://docs.ethers.io/ethers.js/html/api-contract.html#overrides）向方法调用添加额外的数据——在本例中是一个值属性 这将被合约的`mintApe`方法作为`msg.value`接收，确保满足“发送的以太值不正确”的条件：

```
// bored-ape.sol
require(apePrice.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");
```


我们已经将`chai`导入到测试文件中，这样我们就可以使用chai “matchers”——将它与从“ethereum-waffle”导入的“solidity”匹配器结合起来：https://ethereum-waffle.readthedocs.io/en/latest/matchers.html - 现在能够指定我们期望从“Transfer”事件接收的确切参数，并且我们可以确保测试实际上按预期通过。

如果你想知道我们如何确定期望接收的参数，我将解释：首先，我们可以检查 `bored-ape.sol` 中的 `_mint` 方法，并看到 `Transfer` 发出 3 个参数。

```
// bored-ape.sol
emit Transfer(address(0), to, tokenId);
```


第一个参数是“Zero account(零地址)”：https://ethereum.stackexchange.com/questions/13523/what-is-the-zero-account-as-describe-by-the-solidity-docs - 也称为“AddressZero(零地址)”。 第二个参数“to”是发送 `mintApe` 交易的地址——在这种情况下，我们只是使用所有者的地址。 最后，tokenId 在 `mintApe` 方法的 for 循环中定义，并设置为等于调用 `tokenSupply` getter 的返回值。

一旦我们知道这些值是什么，我们就可以将它们输入到 `withArgs` 方法中，包括由 ethers 库提供的一个方便的常量，称为 `AddressZero`：


```
// bored-ape.test.ts
.withArgs(ethers.constants.AddressZero, owner.address, tokenId);
```

 
就是这样 - 我们可以运行“npx hardhat test”，将获得通过测试。 如果你更改 `withArgs` 中的任何值，你将得到一个失败的测试 - 正是所期望的！

这是最终测试文件的样子：

```
import { expect } from "chai";
import { ethers } from "hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { beforeEach } from "mocha";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

chai.use(solidity);

describe("Bored Ape", () => {
  let boredApeContract: Contract;
  let owner: SignerWithAddress;
  let address1: SignerWithAddress;

  beforeEach(async () => {
    const BoredApeFactory = await ethers.getContractFactory(
      "BoredApeYachtClub"
    );
    [owner, address1] = await ethers.getSigners();
    boredApeContract = await BoredApeFactory.deploy(
      "Bored Ape Yacht Club",
      "BAYC",
      10000,
      1
    );
  });

  it("Should initialize the Bored Ape contract", async () => {
    expect(await boredApeContract.MAX_APES()).to.equal(10000);
  });

  it("Should set the right owner", async () => {
    expect(await boredApeContract.owner()).to.equal(await owner.address);
  });

  it("Should mint an ape", async () => {
    await boredApeContract.flipSaleState();
    const apePrice = await boredApeContract.apePrice();
    const tokenId = await boredApeContract.totalSupply();
    expect(
      await boredApeContract.mintApe(1, {
        value: apePrice,
      })
    )
      .to.emit(boredApeContract, "Transfer")
      .withArgs(ethers.constants.AddressZero, owner.address, tokenId);
  });
});
```

大奖！ 做得好，我们已经涵盖了本教程的所有目标：

- 如何找到特定项目的智能合约代码
- 如何将该代码添加到本地开发环境
- 如何安装和设置一个简单的安全帽开发环境
- 如何编译合约并为其编写测试

希望这能让你对使用 Hardhat、Ethers、Chai 和 Mocha 导入和测试合约的过程有所了解。 当你编写自己的 Solidity 合约时，可以遵循相同的流程，当与前端存储库结合使用时，你将拥有完整的开发套件的强大功能，其中包含非常直观的流程和详尽的文档。

如果你想查看本教程的源代码，可以在这里找到：https://github.com/jacobedawson/import-test-contracts-hardhat

感谢参与 :)

在 Twitter 上关注我：https://twitter.com/jacobedawson
