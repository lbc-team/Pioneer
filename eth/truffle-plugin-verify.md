# 用 Truffle 插件自动在Etherscan上验证合约代码



Etherscan是以太坊上最受欢迎的浏览器。 它的一大功能是[验证智能合约的源代码](https://medium.com/etherscan-blog/verifying-contracts-on-etherscan-f995ab772327)。 使用户可以在使用合约之前通过源码了解合约的功能。 从而**增加用户对合约的信任**，也因此使开发者受益。



通过Etherscan网站表单提交代码是验证代码的主要方法，但是这**需要很多手动工作**。 需要输入诸如编译器版本和构造函数参数之类的内容，并且需要提交展开后的合约源代码（译者注：这里是指当合约引用了其他的文件时，需要把引用展开），该合约源代码需要与部署的代码完全匹配。



有些人使用命令行工具来展开Truffle合约，并使用基于浏览器的Remix IDE来部署展开后的源代码。 然后，把相同的展开后的源代码复制到Etherscan验证表单提交。 这是一个非常繁琐的过程，应该自动化。



这是为什么我创建了 [truffle-plugin-verify](https://www.npmjs.com/package/truffle-plugin-verify) 插件，它通过Etherscan API来自动验证Truffle合约。 此插件是一个开源项目，有许多不同的参与者，包括[Ren](https://renproject.io/)的一些开发人员。 使用这个插件只需一个简单的命令即可验证合约：

```shell
truffle run verify ContractName
```

## 依赖条件



本文中，我们假设您已经有一个可部署的Truffle项目。 如果没有，可以参考[此Truffle教程](https://learnblockchain.cn/2019/03/30/dapp_noteOnChain)，该教程也说明了如何使用Infura设置Truffle项目的部署。

你也可以查看本文在GitHub上的[源代码](https://github.com/rkalis/truffle-plugin-verify/tree/master/docs/kalis-me-tutorial-code)。



## 合约

我们以 Casino 合约为例。在合约中，玩家可以下注 1-10个ETH。为确保合约不会亏空，玩家只能押注合约总金额的一小部分。



中奖号码是对当前区块号进行模运算的结果。 这个运算在测试中可以的，但是要注意，在正式生产中可能会被滥用。

在本文中，我们将专门对合约进行进一步拆分，以使合约分散到多个文件中。便于展示插件的全部功能。



#### contracts/Killable.sol

```solidity
pragma solidity ^0.5.8;

contract Killable {
    address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

    function kill() external {
        require(msg.sender == owner, "Only the owner can kill this contract");
        selfdestruct(owner);
    }
}
```

#### contracts/Casino.sol

```solidity
pragma solidity ^0.5.8;

import "./Killable.sol";

contract Casino is Killable {
    event Play(address payable indexed player, uint256 betSize, uint8 betNumber, uint8 winningNumber);
    event Payout(address payable winner, uint256 payout);

    function fund() external payable {}

    function bet(uint8 number) external payable {
        require(msg.value <= getMaxBet(), "Bet amount can not exceed max bet size");
        require(msg.value > 0, "A bet should be placed");

        uint8 winningNumber = generateWinningNumber();
        emit Play(msg.sender, msg.value, number, winningNumber);

        if (number == winningNumber) {
            payout(msg.sender, msg.value * 10);
        }
    }

    function getMaxBet() public view returns (uint256) {
        return address(this).balance / 100;
    }

    function generateWinningNumber() internal view returns (uint8) {
        return uint8(block.number % 10 + 1); // Don't do this in production
    }

    function payout(address payable winner, uint256 amount) internal {
        assert(amount > 0);
        assert(amount <= address(this).balance);

        winner.transfer(amount);
        emit Payout(winner, amount);
    }
}
```

## 验证合约

现在我们已经准备好合约，我们可以展示使用truffle-plugin-verify验证该合约有多么简单。





### 1. 安装 & 启用 truffle-plugin-verify

可以使用npm或yarn安装Truffle插件：

```bash
npm install -D truffle-plugin-verify
yarn add -D truffle-plugin-verify
```



安装后，将以下内容添加到`truffle-config.js`或`truffle.js`文件中，以便Truffle启用该插件：



```javascript
module.exports = {
  /* ... rest of truffle-config */

  plugins: [
    'truffle-plugin-verify'
  ]
}
```

### 2. 创建一个Etherscan API密钥并将其添加到Truffle

![img](https://img.learnblockchain.cn/pics/20200724222939.png!lbc)



要创建Etherscan API密钥，首先需要在[Etherscan网站](https://etherscan.io/)上创建一个帐户。 创建帐户后，可以在[个人资料页](https://etherscan.io/myapikey)上添加新的API密钥，如上图所示。 创建新密钥后，将其添加到`truffle-config.js` 或 `truffle.js`文件的`api_keys`下的：



```javascript
module.exports = {
  /* ... rest of truffle-config */

  api_keys: {
    etherscan: 'MY_API_KEY'
  }
}
```



当前，你可以不提交 API key到代码库中，建议使用 [dotenv](https://www.npmjs.com/package/dotenv) 来保存 API key， 然后在git 库中忽略 `.env`文件，然后在`truffle-config.js` 或 `truffle.js`配置文件读取它，读取方式如下：



```javascript
var HDWalletProvider = require("truffle-hdwallet-provider");
require('dotenv').config();

module.exports = {
  networks: {
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(`${process.env.MNEMONIC}`, `https://rinkeby.infura.io/v3/${process.env.INFURA_ID}`)
      },
      network_id: 4
    }
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  }
};
```

你的配置文件可能和上面有所不同，但是只要设置了公共网络部署，并且正确设置了`plugins`和`api_keys`就可以。



### 3. 部署及验证合约

truffle-plugin-verify的使用设置好了，接下来就是实际部署和验证智能合约。

部署：

```bash
truffle migrate --network rinkeby
```

这将花费一些时间，部署完之后，将显示以下类似的内容：

```bash
Summary
=======
> Total deployments:   2
> Final cost:          0.0146786 ETH
```

部署合同后，我们就可以使用truffle-plugin-verify对我们的Casino合同进行Etherscan验证：



```bash
truffle run verify Casino --network rinkeby
```

依旧需要花费一些时间，并最终返回：

```bash
Pass - Verified: https://rinkeby.etherscan.io/address/0xAf6e21d371f1F3D2459D352242564451af9AA23F#contracts
```

## 结论



本文中，我们讨论了通过Etherscan在线表单进行验证代码的麻烦程度，因为每次部署合约时都需要执行几个手动步骤。 在本文中，我们通过 truffle-plugin-verify者只需一个简单的命令就可以验证任何智能合约，这为手动验证提供一种简单、自动的替代方法。



原文来自: https://kalis.me/verify-truffle-smart-contracts-etherscan/

译者：Tiny熊

