> 原文链接：https://medium.com/@patrick.collins_58673/how-to-use-dapptools-code-like-makerdao-fed9909d055b
>
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Meta](https://learnblockchain.cn/people/5578)
> * 校对：[Tiny熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 如何使用 Dapptools | 类似 MakerDAO 使用的代码

> 了解如何使用[Dapptools](https://dapp.tools/)，这是一个智能合约部署框架，适用于喜欢 bash 和命令行的 web3 开发人员。我们着眼于使用它端到端的学习区块链部署框架。

![How to use dapptools](https://img.learnblockchain.cn/attachments/2022/08/AoZwUH6J62eb8d435164c.png)

> 

[MakerDAO](https://makerdao.com/en/) 是目前规模最大的DeFi协议之一，其中[DAI](https://www.coingecko.com/en/coins/dai)稳定币是行业中应用最广泛的稳定币之一。他们的团队使用一种名为 [dapptools](https://dapp.tools/) 的特殊框架来创建、部署、测试智能合约，并与之交互。

dapptools框架由[Dapphub](https://github.com/dapphub) 团队创建，是一个极简的bash友好工具，任何Linux高级用户都很容易爱上它，而且很多人已经爱上了它。

![How to use Dapptools](https://img.learnblockchain.cn/attachments/2022/08/0irGOMQa62eb8d8fe0a54.png)

[Transmissions11](https://twitter.com/transmissions11/status/1437518450880966656) 对 dapptools 兴奋不已 

它对初学者也非常友好，所以如果这是你第一次了解部署框架，那么你来对地方了。在本文中，将展示如何使用 dapptools 执行以下操作：

1. 编写和编译合约
2. 使用solidity和fuzzing测试合约
3. 部署合约
4. 与已部署的合约交互

将使用我们设置的 [dapptools-demo](https://github.com/PatrickAlphaC/dapptools-demo)来了解它。你可以随意跳到那里。如果需要，你还可以查看 [Foundry](https://github.com/gakonst/foundry)工具，它是 dapptools 的重写版本，但由[Paradigm](https://www.paradigm.xyz/) 团队用 rust 编写。

要获得包含更多优秀代码和示例的完整存储库，请查看 [dapptools-starter-kit](https://github.com/smartcontractkit/dapptools-starter-kit)，它包含使用[Chainlink](https://chain.link/)的代码示例！

如果你只想 git 克隆存储库以开始使用它，请随时遵循存储库中的自述文件！

关于这一切的视频很快就会出来：

https://www.youtube.com/watch?v=ZurrDzuurQs

Dapptools 视频

## 项目设置

### 开发环境

首先，你需要一个代码编辑器，我是[VSCode](https://code.visualstudio.com/)的忠实粉丝。如果你使用的是Windows，则需要下载 [WSL](https://docs.microsoft.com/en-us/windows/wsl/install)，因为我们将运行许多 Windows 命令。

一旦你使用了 VSCode，[打开一个终端](https://code.visualstudio.com/docs/editor/integrated-terminal)来运行安装命令，或以任何通常运行 shell 命令的方式。

#### 安装 / 要求

1. Git
2. Make
3. Dapptools

首先，你需要[安装git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)，按照该链接安装git。如果你可以运行，你就会知道做对了：

```
git --version 
```

然后，你需要确保已`make`安装。大多数计算机都已经安装了它，但如果没有，请查看有关该主题的[stack exchange](https://askubuntu.com/questions/161104/how-do-i-install-make) 问题。 

然后，安装dapptools。一定要去[官方文档](https://github.com/dapphub/dapptools#installation) 安装，但它看起来像运行这个：

```bash
# user must be in sudoers
curl -L https://nixos.org/nix/install | sh

# Run this or login again to use Nix
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

curl https://dapp.tools/install | sh
```

你应该有`dapp` , `seth` , `ethsign` , `hevm`和其他一些你现在可以运行的命令了！

这些说明仅适用于基于 Unix 的系统（例如，MacOS, Linux)。

## 创建本地 dapptools 项目

要创建一个新文件夹，请运行以下命令：

```
dapp init
```

这将为你提供应如下所示的基本文件布局：

```
.
├── Makefile
├── lib
│   └── ds-test
│       ├── LICENSE
│       ├── Makefile
│       ├── default.nix
│       ├── demo
│       │   └── demo.sol
│       └── src
│           └── test.sol
├── out
│   └── dapp.sol.json
└── src
    ├── DapptoolsDemo.sol
    └── DapptoolsDemo.t.sol
```

`Makefile`: 放置“脚本”的地方。Dapptools是基于命令行的，makefile可以帮助我们用几个字符运行大型命令。

`lib`: 该文件夹用于外部依赖项，如[Openzeppelin](https://openzeppelin.com/contracts/) 或 [ds-test](https://github.com/dapphub/ds-test)。

`out`: 编译代码的位置。类似于`brownie`中的`build`文件夹或`hardhat`中的`artifacts`文件夹。

`src`: 你的智能合约就在这里。类似于`brownie`和`hardhat`中的`contracts`文件夹。

## 运行测试

要运行测试，你只需要运行：

```
dapp test
```

你会看到如下输出：

```
Running 2 tests for src/DapptoolsDemo.t.sol:DapptoolsDemoTest
[PASS] test_basic_sanity() (gas: 190)
[PASS] testFail_basic_sanity() (gas: 2355)
```

## 模糊测试

Dapptools在[模糊测试](https://en.wikipedia.org/wiki/Fuzzing)上内置了一个重点。这是一个非常强大的工具，可以用随机数据测试我们的合约。

让我们用一个名为`play`的函数来更新`DapptoolsDemo.sol`。我们的新文件应该是这样的:

```solidity
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

contract DapptoolsDemo {

function play(uint8 password) public pure returns(bool){
        if(password == 55){
            return false;
        }
        return true;
    }
}
```

我们将在`DappToolsDemo.t.sol`中添加一个新的测试，该测试兼容模糊测试名为`test_basic_fuzzing`。 这个文件看起来像这样：

```solidity
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./DapptoolsDemo.sol";

contract DapptoolsDemoTest is DSTest {
    DapptoolsDemo demo;
    
function setUp() public {
        demo = new DapptoolsDemo();
    }
    
function testFail_basic_sanity() public {
        assertTrue(false);
    }
    
function test_basic_sanity() public {
        assertTrue(true);
    }
    
function test_basic_fuzzing(uint8 value) public {
        bool response = demo.play(value);
        assertTrue(response);
    }
}
```

现在可以给我们的合约提供随机数据，如果我们的代码给它一个数字`55`，我们就会期望它出错。用模糊标志运行测试:

```
dapp test — fuzz-runs 1000
```

将看到如下输出：

```
+ dapp clean
+ rm -rf out
Running 3 tests for src/DapptoolsDemo.t.sol:DapptoolsDemoTest
[PASS] test_basic_sanity() (gas: 190)
[PASS] testFail_basic_sanity() (gas: 2355)
[FAIL] test_basic_fuzzing(uint8). Counterexample: (55)
Run:
 dapp test --replay '("test_basic_fuzzing(uint8)","0x0000000000000000000000000000000000000000000000000000000000000037")'
to test this case again, or 
 dapp debug --replay '("test_basic_fuzzing(uint8)","0x0000000000000000000000000000000000000000000000000000000000000037")'
to debug it.

Failure: 
  
  Error: Assertion Failed
```

我们的模糊测试发现了异常值！我为`test_basic_fuzzing`测试运行了`1000`条不同的路径，并找到了`55`这个异常值。 这对于找到那些你可能没有想到的破坏合约的随机用例非常重要。

## 从 Openzeppelin 和外部合约导入

假设我们想使用 Openzeppelin 标准创建一个 NFT。可以使用`dapp install`命令安装外部合约或包。 需要命名GitHub存储库组织和要安装的存储库名称。

首先，我们需要提交到目前为止的更改！Dapptools 将外部包作为[git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)引入，因此我们需要先提交。

运行:

```
git add .

git commit -m ‘initial commit’
```

然后，我们可以安装我们的外部包。例如，对于 [OpenZeppelin,](https://github.com/OpenZeppelin/openzeppelin-contracts,)，我们将使用：

```
dapp install OpenZeppelin/openzeppelin-contracts
```

你应该会在lib文件夹中看到一个名为`openzeppelin-contracts`的新文件夹。

## **NFT合约**

在src文件夹中创建一个名为NFT.sol的新文件。然后添加以下代码:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint256 public tokenCounter;
    constructor () ERC721 ("NFT", "NFT"){
        tokenCounter = 0;
    }

function createCollectible() public returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        tokenCounter = tokenCounter + 1;
        return newItemId;
    }
    
}
```

如果你现在尝试`dapp build`，你会得到一个很大的错误！

## **重新映射**

我们需要告诉 dapptools`import “@openzeppelin/contracts/token/ERC721/ERC721.sol”;`指向我们的`lib`文件夹。所以我们创建了一个名为 `remappings.txt` 的文件并添加：

```
@openzeppelin/=lib/openzeppelin-contracts/
ds-test/=lib/ds-test/src/
```

然后，我们创建一个名为`.dapprc`的文件并添加以下行：

```
export DAPP_REMAPPINGS=$(cat remappings.txt)
```

Dapptools在我们的`.dapprc`中查找不同的配置变量，有点像hardhat中的`hardhat.config.js`。在这个配置文件中，我们告诉它读取输出`remappings.txt`并将其用作“重新映射”。重新映射是我们在solidity中告诉导入的文件应该从哪里导入的方法。例如在`remapping.txt`我们看到：

```
@openzeppelin/=lib/openzeppelin-contracts/
```

这意味着我们告诉dapptools，当它编译一个文件时，如果它在import语句中看到`@openzeppelin/`，它应该在`lib/openzeppelin-contracts/`中查找文件。 所以如果我们这样做

```
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
```

我们实际上是在说:

```
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
```

然后，为了不编译整个库，我们需要将以下代码添加到`.dapprc`文件中:

```
export DAPP_LINK_TEST_LIBRARIES=0
```

这告诉dapptools在运行测试时不要在lib中编译所有内容。

## 部署到测试网（如果需要，也可以部署到主网……）

> 注意：如果你想设置自己的本地网络，可以运行`dapp testnet`。



## 将.env添加到.gitignore文件中

如果你还没有，请创建一个`.gitignore`文件，然后在其中添加这一行：

```
.env
```

请这样做。在本教程中，我们根本不会把你的私钥推送到git中，但我们希望养成将其添加到`.gitignore`中的习惯！这将有助于防止你不小心将环境变量发送到公共git仓库。你仍然可以强迫他们，所以要小心！

## 设置`ETH_RPC_URL`环境变量

要部署到测试网，我们需要一个区块链节点。 [Alchemy](https://alchemy.com/?a=673c802981) 项目是个不错的选择。你可以获得免费的测试网 HTTP 端点。只需注册一个免费项目，然后点击`view key`（或当时的任何文本），你将拥有一个 HTTP 端点！

你可以选择你喜欢的测试网，我会从[Chainlink Faucets](https://faucets.chain.link/)中选择一个，可以在其中获得测试网 LINK 和 ETH。Kovan或Rinkeby将会是很好的选择，所以无论哪一个都可以。

如果还没有，请创建一个`.env`文件，然后将端点添加到`.env`文件中。它看起来像这样:

```
export ETH_RPC_URL=http://alchemy.io/adfsasdfasdf
```

## 创建默认发送方

获得一个[eth wallet](https://metamask.io/)，如果你还没有的话。你可以在[这里](https://docs.chain.link/docs/deploy-your-first-contract/#install-and-fund-your-metamask-wallet)看到关于设置metamask的更深入的说明。但理想情况下，你得到一个metamask，然后从 [Chainlink Faucets](https://faucets.chain.link/)水龙头得到一些测试网ETH。然后切换到你正在使用的测试网。你的metamask应该看起来像这样:

![Dapptools tutorial | Metamask](https://img.learnblockchain.cn/attachments/2022/08/TVsc1rUQ62eb9749210a4.png)

[Metamask](https://metamask.io/) 

拥有钱包后，将该钱包的地址设置为`ETH_FROM`环境变量。

```
export ETH_FROM=YOUR_ETH_WALLET_ADDRESS
```

此外，如果使用 Kovan，[请使用测试网 ETH 为你的钱包注资](https://faucets.chain.link/)。

## 添加你的私钥

> 注意:我强烈推荐使用一个没有任何真正资金的metamask来开发。

> 如果你将你的私钥推送到一个包含真钱的公共仓库，人们就可以窃取你的资金。

因此，如果你刚刚设置了metamask，并且只使用测试网资金，那么你是安全的。 😃

Dapptools附带了一个名为`ethsign`的工具，这是我们将要存储和加密密钥的地方。要添加我们的私钥(需要发送交易)，请获取你的钱包的私钥，并运行:

```
ethsign import
```

然后它会提示你添加你的私钥，然后是加密的密码。这将在`ethsign`中加密你的私钥。． 任何时候你想发送交易，都需要你的密码。如果你运行命令`ethsign ls`，会得到这样的响应:

```
0x3DF02ac6fEe39B79654AA81C6573732439e73A81 keystore
```

你做对了。

## 更新你的Makefile

可以使用`dapp create DapptoolsDemo`命令来部署合约，然后添加一些标志到环境变量中。为了让生活更简单，可以将部署命令添加到Makefile中，并告诉Makefile使用我们的环境变量。

将以下内容添加到`Makefile`中

```
-include .env
```

## 部署合约

在`Makefile`中，有一个名为 `deploy`的命令，它将运行`dapp create DapptoolsDemo`并包含我们的环境变量。要运行它，只需运行：

```
make deploy
```



系统将提示你输入密码。一旦成功，它将部署你的合约!

```
dapp create DapptoolsDemo
++ seth send --create 608060405234801561001057600080fd5b50610158806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c806353a04b0514610030575b600080fd5b61004a60048036038101906100459190610096565b610060565b60405161005791906100d2565b60405180910390f35b600060378260ff161415610077576000905061007c565b600190505b919050565b6000813590506100908161010b565b92915050565b6000602082840312156100ac576100ab610106565b5b60006100ba84828501610081565b91505092915050565b6100cc816100ed565b82525050565b60006020820190506100e760008301846100c3565b92915050565b60008115159050919050565b600060ff82169050919050565b600080fd5b610114816100f9565b811461011f57600080fd5b5056fea264697066735822122004d7143940853a7650f1383002b6ba56991e7a5c7d763e755774a149ca0465e364736f6c63430008060033 'DapptoolsDemo()'
seth-send: warning: `ETH_GAS' not set; using default gas amount
Ethereum account passphrase (not echoed): seth-send: Published transaction with 376 bytes of calldata.
seth-send: 0xeb871eee1fa31c34583b63002e2b16a0252410b5615623fd254b1f90b67369d4
seth-send: Waiting for transaction receipt........
seth-send: Transaction included in block 29253678.
0xC5a62934B912c3B1948Ab0f309e31a9b8Ed08dd1
```

你应该能够看到[Etherscan](https://kovan.etherscan.io/address/0xC5a62934B912c3B1948Ab0f309e31a9b8Ed08dd1)上给出的最终地址。

## 与合约交互

要与已部署的合约交互，我们可以使用`seth call`和`seth send`，它们略有不同：

- `seth call` : 只会从区块链读取数据。它不会“消耗”任何[gas](https://www.sofi.com/learn/content/what-is-ethereum-gas/)。
- `seth send` : 这会将交易发送到区块链，可能会修改区块链的状态，并消耗gas。

要从区块链中**读取**数据，可以执行以下操作：

```
ETH_RPC_URL=<YOUR_RPC_URL> seth call <YOUR_DEPLOYED_CONTRACT> 
"FUNCTION_NAME()" <ARGUMENTS_SEPARATED_BY_SPACE>
```

例如:

```
ETH_RPC_URL=<YOUR_RPC_URL> seth call 0x12345 "play(uint8)" 55
```

得到的结果是`0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000`，这意味着false，因为响应等于0，而在布尔类型中，0表示false。

要将数据**写入**到区块链，可以执行以下操作：

```
ETH_RPC_URL=<YOUR_RPC_URL> ETH_FROM=<YOUR_FROM_ADDRESS> seth send 
<YOUR_DEPLOYED_CONTRACT> "FUNCTION_NAME()" 
<ARGUMENTS_SEPARATED_BY_SPACE>
```

我们没有部署一个有很好例子的合约，但是假设该`play`函数*能够*修改区块链状态，看起来像：

```
ETH_RPC_URL=<YOUR_RPC_URL> ETH_FROM=<YOUR_FROM_ADDRESS> seth send 
0x12345 "play(uint8)" 55
```

## 在 Etherscan 上验证你的合约

将合约部署到 etherscan 后，可以通过以下方式对其进行验证：

1. 获取[Etherscan API 密钥](https://etherscan.io/apis)。

2. 然后运行

```
ETHERSCAN_API_KEY=<api-key> dapp verify-contract 
<contract_directory>/<contract>:<contract_name> <contract_address>
```

例如:

```
ETHERSCAN_API_KEY=123456765 dapp verify-contract ./src/DapptoolsDemo.sol:DapptoolsDemo 0x23456534212536435424
```

## 最后

1. 添加`cache`到你的`.gitignore`

2. 添加`update:; dapp update` 到 `Makefile`的顶部。当你运行 `make` 时，将更新并下载`.gitmodules`和`lib`中的文件。

3. 添加一个`LICENSE`。如果你不知道怎么做，可以从[我们的仓库](https://github.com/PatrickAlphaC/dapptools-demo)中复制一个！

终于大功告成！

# **资源**

如果你喜欢这个，考虑捐赠！

💸 ETH 钱包地址: 0x9680201d9c93d65a3603d2088d125e955c73BD65

- [Dapptools](https://dapp.tools/)
- [Hevm Docs](https://github.com/dapphub/dapptools/blob/master/src/hevm/README.md)
- [Dapp Docs](https://github.com/dapphub/dapptools/tree/master/src/dapp/README.md)
- [Seth Docs](https://github.com/dapphub/dapptools/tree/master/src/seth/README.md)
