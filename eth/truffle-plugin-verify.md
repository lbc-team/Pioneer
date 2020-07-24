# Automatically verify Truffle smart contracts on Etherscan



Etherscan is the most popular explorer in the Ethereum space. And one of its big features is [verifying the source code of smart contracts](https://medium.com/etherscan-blog/verifying-contracts-on-etherscan-f995ab772327). This allows users of smart contracts to understand what a contract is doing before using it. This **increases trust in these smart contract**, and benefits their developers because **users will feel more comfortable** using their smart contracts.

The main way smart contract developers can add their verified code on Etherscan is through the form on their website, but unfortunately **this is a lot of manual work**. You need to enter things like compiler version and constructor parameters, and you need to provide the contract source code in a flattened format that needs to exactly match the deployed code.

What some people do is flattening their Truffle contracts using a command line tool and using the browser-based Remix IDE to deploy the flattened source code. Then they copy the same flattened code to the Etherscan verification form. This is a **very cumbersome process that should be automated**.

This is why I created [truffle-plugin-verify](https://www.npmjs.com/package/truffle-plugin-verify), a Truffle plugin that can be used to automatically verify your Truffle contracts through the Etherscan API. The plugin is an Open Source project with many different contributors, including some developers at [Ren](https://renproject.io/). With this plugin you can verify your contracts with just a simple command:

```shell
truffle run verify ContractName
```

## Prerequisites

For this guide we assume you already have a Truffle project with a deployment process set up. If you don't, you can refer to [this Truffle tutorial](https://truffleframework.com/tutorials/using-infura-custom-provider) that shows how to set up deployment of Truffle projects with Infura.

**Note:** You can also check out the [source code](https://github.com/rkalis/truffle-plugin-verify/tree/master/docs/kalis-me-tutorial-code) for this guide on GitHub.

## The contract

If you've read any of my [previous](https://kalis.me/check-events-solidity-smart-contract-test-truffle/) [articles](https://kalis.me/assert-reverts-solidity-smart-contract-test-truffle/), you know that I'm a fan of using a simple Casino contract as an example. With this contract a player can bet ETH on a number from 1 to 10. To make sure the contract does not go underwater, the player can only bet a small percentage of the contract's total balance.

The winning number is generated as a modulo operation on the current block number. This is fine for testing, but be aware that it would be easily abused in production.

In this guide, we will specifically split up the contract further so it's spread out over multiple files. This allows us to showcase the full functionality of the plugin.

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

## Verifying the contract

Now that we have our contract ready, we can show how simple it is to verify this contract with truffle-plugin-verify.

### 1. Install & enable truffle-plugin-verify

You can install the Truffle plugin using npm or yarn:

```bash
npm install -D truffle-plugin-verify
yarn add -D truffle-plugin-verify
```

When it is installed, you should add the following to your `truffle-config.js` or `truffle.js` file to enable the plugin with Truffle:

```javascript
module.exports = {
  /* ... rest of truffle-config */

  plugins: [
    'truffle-plugin-verify'
  ]
}
```

### 2. Create an Etherscan API key and add it to Truffle

![img](https://img.learnblockchain.cn/pics/20200724222939.png!lbc)

To create an Etherscan API key, you first need to create an account on the [Etherscan website](https://etherscan.io/). After creating an account, you can add a new API key on your [profile page](https://etherscan.io/myapikey), as seen in the image above. After creating a new key, it should be added to `truffle-config.js` or `truffle.js` under `api_keys`:

```javascript
module.exports = {
  /* ... rest of truffle-config */

  api_keys: {
    etherscan: 'MY_API_KEY'
  }
}
```

Of course you shouldn't commit this API key to your Git repository, so I suggest using [dotenv](https://www.npmjs.com/package/dotenv) to store the API key in a gitignored `.env` file and read it from there.

After following these steps, your full config file should look like this:

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

Your specific config file might be different, but as long as you have a public network deployment set up, and your plugins and api_keys lists are set correctly, you should be good to go.

### 3. Deploy & verify the contract

Now that everything is set up to use truffle-plugin-verify, the only thing left is to actually deploy and verify the smart contract.

```bash
truffle migrate --network rinkeby
```

This should take some time, and will show information about the deployment, finally displaying something similar to this:

```bash
Summary
=======
> Total deployments:   2
> Final cost:          0.0146786 ETH
```

With the contract deployed we can use truffle-plugin-verify to run the Etherscan verification of our Casino contract:

```bash
truffle run verify Casino --network rinkeby
```

This will again take some time, and eventually return:

```bash
Pass - Verified: https://rinkeby.etherscan.io/address/0xAf6e21d371f1F3D2459D352242564451af9AA23F#contracts
```

## Conclusion

We've discussed how cumbersome Etherscan verification can be when doing it through their online form, as there are several manual steps to go through every time you deploy a contract. In this article we have shown that truffle-plugin-verify offers a simple and automatic replacement for the manual verification process. It is easy to install, and can be used to verify any smart contract with just one easy command.

------



From: https://kalis.me/verify-truffle-smart-contracts-etherscan/

