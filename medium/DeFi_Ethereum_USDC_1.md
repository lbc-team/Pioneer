
# Introduction to Building on DeFi with Ethereum and USDC — Part 1



*By* [*Pete Kim*](https://twitter.com/petejkim)


At Coinbase, our mission is to build an open financial system. We strongly believe that increasing economic freedom will make the world a better place. Decentralized Finance, or DeFi for short — an open, borderless, and programmable version of finance — is an inseparable part of that vision.

## Smart Contracts

DeFi is powered by smart contracts running on decentralized networks such as Ethereum (“the blockchain”) and digital currencies like USD Coin (USDC), a tokenization of US Dollars on the blockchain. The idea of smart contracts is actually quite simple. Nick Szabo, a pioneer in digital currency and cryptography who [originally came up with the idea](https://www.fon.hum.uva.nl/rob/Courses/InformationInSpeech/CDROM/Literature/LOTwinterschool2006/szabo.best.vwh.net/idea.html) in 1997 described the vending machine as the ancestor of smart contracts.

The vending machine is an automated version of a contract, expressed in the form of electrical hardware:

1. You pay the displayed price by inserting money into the machine, the machine dispenses a drink
2. You don’t pay the displayed price, it doesn’t dispense a drink
3. If you paid the displayed price but the machine didn’t dispense a drink, or if it dispensed a drink even though you didn’t pay the displayed price, then there is a violation of the contract

The vending machine is able to manage its contractual obligations completely autonomously without human intervention.

Modern smart contracts work the same way, but the contractual clauses are expressed as executable computer code as opposed to being implemented in hardware. The decentralized nature of the network on top of which smart contracts are run ensures that they are executed as written and that no single entity is able to bend the rules or manipulate the outcome. One important caveat is that because the network executes the code verbatim, faulty smart contract code can result in unexpected consequences (“code is law”).

## No Better Time Than Now

A lot of people find building on crypto and blockchain very intimidating and think it is only accessible to hard-core computer scientists. While that may have been true as recently as just a few years ago, tooling and developer UX have improved significantly since then, and anyone with basic programming skills can start building ([or BUIDLing](https://en.wikipedia.org/wiki/Hodl)).

The DeFi ecosystem is currently undergoing explosive growth. [USDC reached a $1B market cap in less than 2 years](https://medium.com/centre-blog/usdc-market-cap-exceeds-1-billion-fastest-growing-digital-dollar-stablecoin-to-do-so-c5ba314474ca), and the total value of assets stored in various DeFi services blew past $2B in less than 3 years. There really has not been a better time to start developing in this space.

![](https://img.learnblockchain.cn/2020/07/24/15955628861882.jpg)

*Source:* [*DeFi Pulse*](https://defipulse.com/)



The tutorial below serves as a simple guide to begin developing your own DeFi smart contracts. It is our hope that such a guide will help democratize the creation of a global, open financial system.

# Getting Started

This tutorial series assumes that you have some experience with [JavaScript](https://en.wikipedia.org/wiki/JavaScript), which is the most widely used programming language in the world. You will also be introduced to [Solidity](https://solidity.readthedocs.io/), a smart contract programming language used on [Ethereum](https://ethereum.org/), which is the most widely used smart contract blockchain in the world. Finally, you will get to interact with [USDC](https://www.coinbase.com/usdc), the most widely adopted fiat-backed stablecoin in DeFi applications.

## Setting up the Development Environment

To get started, we’re going to need a Unix-like environment and [Node.js v12.x](https://nodejs.org/) (the latest LTS release) installed on it. macOS is natively a Unix environment, and Windows users can get it by installing [Ubuntu on WSL](https://ubuntu.com/wsl) from the Microsoft Store. More detailed steps can be found [here for macOS](https://treehouse.github.io/installation-guides/mac/node-mac.html), and [here for Windows](https://docs.microsoft.com/en-us/windows/nodejs/setup-on-wsl2). As for the text editor, [Visual Studio Code](https://code.visualstudio.com/) is strongly recommended because the project template you’ll be using comes pre-configured for it, but you can technically use any editor. Oh, and I prefer [Vim keybindings over Emacs](https://xkcd.com/378/).

## Setting up the Project

It takes some work to set up a Solidity project, and honestly getting distracted by it isn’t very useful for learning at this stage, so a [pre-configured template](https://github.com/CoinbaseStablecoin/solidity-tutorial) has been prepared for you.

Run the following commands in your terminal to download and setup the template:
```
$ **git clone** [**https://github.com/CoinbaseStablecoin/solidity-tutorial.git**](https://github.com/CoinbaseStablecoin/solidity-tutorial.git)
$ **cd solidity-tutorial**
$ **npm install -g yarn**        # Install yarn package manager
$ **yarn**                       # Install project dependencies
```
You may see some compilation errors as yarn tries to build native extensions. Those are optional and it is safe to ignore the errors. As long as you see the “Done” message at the end, you’re good to go.

## Opening the Project in Visual Studio Code

Open the project folder (**solidity-tutorial**) in Visual Studio Code. The first time the project is open, Visual Studio Code may prompt you to install extensions. Go ahead and click on “Install All”, this will add various useful extensions such as automatic code formatting and Solidity syntax highlighting to the editor.

![](https://img.learnblockchain.cn/2020/07/24/15955721532271.jpg)

# Creating an Account on Ethereum

Before you can do anything on Ethereum, you need to have an account. Accounts are often called “wallets”, because they can contain digital assets like ETH and USDC. End users typically create accounts by using an Ethereum wallet app like [Coinbase Wallet](https://wallet.coinbase.com/) or [Metamask](https://metamask.io/), but creating an account programmatically is really simple as well, using the excellent [ethers.js](https://github.com/ethers-io/ethers.js/) library that comes preinstalled with the template.

Create a new JavaScript file called **createWallet.js** in the **src** folder, and enter the following code:

```
const ethers = require("ethers");

const wallet = ethers.Wallet.createRandom();

console.log(`Mnemonic: ${wallet.mnemonic.phrase}`);
console.log(`Address: ${wallet.address}`);
```

Save the file, and execute the code using Node.js as follows:
```
$ **node src/createWallet.js**Mnemonic: rabbit enforce proof always embrace tennis version reward scout shock license wing
Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
```

What just happened? Well, you got yourself a brand-spanking new Ethereum account. The “mnemonic” or perhaps more commonly referred to as “recovery phrase” is a human-readable representation of the cryptographic key that is needed to perform actions from the account, and the address is the name and identifier of the account. Copy those down somewhere. On a side note, the mnemonic shown in this post has been slightly altered to discourage you from using it, please use your own!

Think of those as the password and the account number to your bank account, except you could create one in just a few seconds, and you didn’t have to fill out an application form or share any personal information. You can also run this code wherever you are.

> *⚠️* The account’s mnemonic must be kept a secret. If you lose it, you will lose access to your account and any assets stored in the account forever and no one will be able to help you! Keep it in a safe place!
> 
> *ℹ️* Technically, you haven’t really “created” an account per se. Instead, what you created was a private/public key pair. If you are curious about what is actually happening under the hood, read about [elliptic-curve cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography), and the Bitcoin and Ethereum specifications [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki), [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki), [EIP55](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md) and their implementation [in this project](https://github.com/petejkim/wallet.ts).

## About Gas and Mining

Ethereum is a decentralized network of thousands of computers around the world, and they don’t exactly do work for free. To perform any state change on the blockchain such as storing and updating data, you have to pay the network operators a transaction fee in Ether (ETH), also known as “gas” on Ethereum. This, along with the bonus reward the operators get for adding new blocks to the chain, is what incentivizes them to keep their computers up and running. This process is called “mining” and the network operators are called “miners”. We will be revisiting this later in this tutorial (Gas, Gas Price and Gas Limit).

## Obtaining Testnet ETH

Now that you have an account, you should deposit some ETH. We don’t want to waste real money while developing, so we are going to get some fake-ETH meant for developing and testing on the test network (“testnet”) instead. There are many different Ethereum testnets, but we are going to be using Ropsten because of the ease of obtaining test tokens. First, let’s check your current balance using [Etherscan](https://ropsten.etherscan.io/), a block explorer for Ethereum. You can do that by entering the following URL in your browser, replacing **YOUR_ADDRESS** with the address you created earlier, starting with **0x**.

[https://ropsten.etherscan.io/address/**YOUR_ADDRESS**](https://ropsten.etherscan.io/address/YOUR_ADDRESS)

![](https://img.learnblockchain.cn/2020/07/24/15955734131072.jpg)
*Source:* [*ropsten.etherscan.io*](https://ropsten.etherscan.io/)


You should see that your balance is 0 ETH. Keep this tab open, and open [Ropsten Ethereum Faucet](https://faucet.ropsten.be/) in a different tab. In the faucet page, enter your address and click on the “Send me” button. The transaction may take as little as a few seconds to a minute or two to complete. Check Etherscan again in a bit, and you should see a new balance of 1 ETH and an incoming transaction in the list.

![](https://img.learnblockchain.cn/2020/07/24/15955740098521.jpg)
*Source:* [*faucet.ropsten.be*](https://faucet.ropsten.be/)



# Getting ETH Balance Programmatically

## *Connecting to Ethereum*

Using Etherscan to view the balance is useful, but it is also easy to view it with code as well. Before we get back to the code however, we need a way to connect to Ethereum. There are many ways to do it, including running a network node yourself on your computer, but by far the quickest and the easiest way is to do it through a managed node provider such as [INFURA](https://infura.io/) or [Alchemy](https://alchemyapi.io/). Head over to [INFURA](https://infura.io/), create a free account and create a new project to obtain the API Key (Project ID).

> *ℹ️* [Go Ethereum (“geth”)](https://geth.ethereum.org/) and [Open Ethereum](https://github.com/openethereum/openethereum#readme) (formerly known as Parity Ethereum) are the two most widely used Ethereum node software.

## Viewing ETH Balance with Code

First, let’s write code that reads and derives the account back from the mnemonic. Create a new JavaScript file called **wallet.js** in the **src** folder, and enter the following code:

```
const ethers = require("ethers");

// Replace the following with your own mnemonic
const mnemonic =
  "rabbit enforce proof always embrace tennis version reward scout shock license wing";
const wallet = ethers.Wallet.fromMnemonic(mnemonic);

console.log(`Mnemonic: ${wallet.mnemonic.phrase}`);
console.log(`Address: ${wallet.address}`);

module.exports = wallet;
```

Replace the mnemonic string in the code with your own. Please note that in production code, the mnemonic shouldn’t be hard-coded like that. Instead it should be read from a config file or an environment variable, so that it does not get leaked accidentally for instance by having it checked into a source code repository.

Executing the code, you should be able to see the same address as the one you got earlier:

```
$ **node src/wallet.js**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
```

Next, create a new file called **provider.js** in the same folder. In this file, we will be initializing a provider object with the INFURA API key we obtained earlier. Be sure to replace the API key string with your own:

```
const ethers = require("ethers");


const provider = ethers.getDefaultProvider("ropsten", {
  // Replace the following with your own INFURA API key
  infura: "0123456789abcdef0123456789abcdef",
});

module.exports = provider;
```

Finally, we will use both **wallet.js** and **provider.js** we created in a new file called **getBalance.js** in the same folder to get ETH balance:

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

Run the code, and you’ll see your ETH balance!
```
$ **node src/getBalance.js**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
ETH Balance: 1.0
```
## Token Denominations

The code we just created is pretty self-explanatory, but you may be wondering what **ethers.utils.formatUnits(balance, 18)** does. Well, ETH is actually divisible to 18 decimal places, and the smallest denomination unit is called “wei” (pronounced “way”). In other words, one ETH is equivalent to 1,000,000,000,000,000,000 wei. Another commonly seen denomination is Gwei (pronounced “Giga-way”), which is 1,000,000,000 wei. The **getBalance** method happens to return the result in wei, so we have to convert it back to ETH by multiplying the result by 10¹⁸. The full list of the denominations can be found [here](https://ethdocs.org/en/latest/ether.html).

> *ℹ️* You can also use **ethers.utils.formatEther(balance)**, which is a shorthand for **ethers.utils.formatUnits(balance, 18)**.

# Obtaining Testnet USDC

The ETH in your account is feeling a little bit lonely, so let’s also get some USDC in it as well. I’ve deployed a pseudo [USDC smart contract](https://ropsten.etherscan.io/token/0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4) on the Ropsten testnet. There isn’t a fancy faucet website for it, but the contract contains a function that will give you some free testnet USDC when called. If you navigate to the [contract code tab in Etherscan](https://ropsten.etherscan.io/address/0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4#code) and search for **gimmeSome** in the contract source code. That is the function we’ll be calling to get some USDC sent to our account.

![](https://img.learnblockchain.cn/2020/07/24/15955742039661.jpg)

## Making a Transaction to Call a Smart Contract Function

In Ethereum smart contracts there are mainly two types of functions: read-write and read-only. The former may result in a change in the data stored in the blockchain, and the latter purely reads, but never writes. Read-only functions can be called without creating a transaction and therefore without a transaction fee, unless called as part of a read-write function. Read-write functions on the other hand must be called inside a transaction, and the transaction fee (gas) must be paid. Invoking the **gimmeSome** function results in a change in the USDC balances stored in the blockchain, therefore it has to be called inside a transaction.

Calling a smart contract function requires some extra steps, but it is not too difficult. First, we need to find the full interface of the function we’d like to call, also known as the function signature or the function prototype. Look for **gimmeSome** again in the contract source code and you will find that the interface is the following:

```
function gimmeSome() external
```

It is a really simple function that does not take in any arguments, and it is marked as **external**, which means that this function can only be called from outside, and not from other functions within this contract. That is OK because we will be calling this function directly in a transaction.

> *ℹ️* The **gimmeSome** function does not exist in the [“real” USDC contract](https://etherscan.io/address/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) deployed on the main Ethereum network, for obvious reasons.

Create a new file called **getTestnetUSDC.js** in the **src** folder and enter the following code:
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

The code first instantiates a contract object (**new ethers.Contract**) with the interface of the function we are interested in, **gimmeSome**, and points it at the address of the testnet USDC contract: [0x68ec⋯69c4](https://ropsten.etherscan.io/address/0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4). You can then call any of the functions you’ve listed. **gimmeSome** function does not take in any arguments on its own, but you can specify transaction options as the last argument. In this case, we are giving it 20 Gwei of gas price, which should speed up the transaction. All methods that interact with the network are asynchronous in nature and return a [**Promise**](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), so we are using JavaScript’s [**await**](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await) expression. The code then prints the transaction hash, which is a unique identifier of your transaction that can be used to track the progress. It then waits until the transaction is confirmed.

Run the code, and you will see something like the following:

```
$ **node src/getTestnetUSDC.js**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Transaction hash: 0xd8b4b06c19f5d1393f29b408fc0065d0774ec3b4d11d41be9fd72a8d84cb6208
Transaction confirmed in block 8156350
Gas used: 35121
```

Voilà! You’ve made your first Ethereum transaction with code! Check your address and the transaction hash in [Ropsten Etherscan](https://ropsten.etherscan.io/). You should now see that you now have 10 testnet USDC, and a little less than 1 ETH, due to the gas paid to execute the transaction.

![](https://img.learnblockchain.cn/2020/07/24/15955743524825.jpg)

> *ℹ️* If you inspect the transaction in Etherscan, you will find that it is a transaction that sends zero (0) ETH to the contract address along with 4 bytes of data. If the function call had arguments, there would be more than just 4 bytes of data. If you want to learn about how this data is encoded, read the [Ethereum contract ABI specification](https://solidity.readthedocs.io/en/v0.6.10/abi-spec.html).

## Gas, Gas Price and Gas Limit

Earlier, I mentioned that we are giving the transaction 20 Gwei of gas price to speed up the transaction and the script also prints the amount of gas used. What do all these things mean? Well, Ethereum is a network comprised of network operators. Think of it as a world computer. It is not a free computer though, and every instruction you run on this computer costs money. This computer is also shared by everyone around the world, which means everyone must compete with each other to get their time on this computer.

How do we make this fair? Well, we can auction off time on this computer, and the more you are willing to pay for each compute instruction you run on this computer, the more the network operators (miners) will likely be giving you the time. This sure isn’t perfect, as it could have an effect where only the rich are able to have the privilege of using this system. However it is the least bad solution we have until the system is made much more scalable and can accommodate much more transactions.

Coming back to the blockchain jargon, the “gas used” is the amount of computing resources you’ve consumed as a result of running the transaction and the “gas price” is how much you are willing to pay per unit of gas. In general, the higher you are willing to pay, the higher priority your transaction will have, and the faster it will be confirmed by the network. In our case, we used 20 Gwei as the gas price, and the gas used was 35,121 (you can also find this by inspecting the transaction in Etherscan), so the total gas cost is 35,121 * 20 Gwei = 702,420 Gwei or 0.00070242 ETH.

Since gas costs money, you might want to set an upper limit of the maximum gas you are willing to spend. Luckily, you can set a “gas limit”. If the transaction ends up needing more gas than the gas limit specified, the transaction will fail instead of continuing with the execution and consuming more gas than you’re willing to pay. One side effect to be mindful of is that if the execution ends up failing due to the limit, the amount of gas already spent will not be refunded back to you.

## Calling a Smart Contract Function to Read Data

You were able to check that you received 10 USDC on Etherscan, but let’s confirm that by checking the balance with code.

Let’s modify the existing file **getBalance.js** in the **src** folder, with the following content:

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main() {
  const account = wallet.connect(provider);

  // Define contract interface
  const usdc = new ethers.Contract(
    "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
    [
      "function balanceOf(address _owner) public view returns (uint256 balance)",
    ],
    account
  );

  const ethBalance = await account.getBalance();
  console.log(`ETH Balance: ${ethers.utils.formatEther(ethBalance)}`);

  // Call balanceOf function
  const usdcBalance = await usdc.balanceOf(account.address);
  console.log(`USDC Balance: ${ethers.utils.formatUnits(usdcBalance, 6)}`);
}

main();
```

USDC is an ERC20 token, so it contains all of the methods defined in the [ERC20 specification](https://eips.ethereum.org/EIPS/eip-20). **balanceOf** is one of them, and its interface is taken straight from the spec. **balanceOf** is a read-only function, so it can be called for free and does not need to be submitted as a transaction. Finally, it is important to note that USDC uses 6 decimal places of precision as opposed to 18 that many other ERC20 tokens use.

![](https://img.learnblockchain.cn/2020/07/24/15955744064056.jpg)

> *ℹ️* You can learn more about Solidity functions [here](https://solidity.readthedocs.io/en/v0.6.11/contracts.html#functions).

Run the code, and now you will see USDC balance as well:

```
$ **node src/getBalance.js**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
ETH Balance: 0.9961879
USDC Balance: 10.0
```

# Transferring ETH and USDC

Now let’s check out how we can spend ETH and USDC we have in our account.

## Transferring ETH

Create **transferETH.js** in the **src** folder and enter the following code:

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main(args) {
  const account = wallet.connect(provider);
  let to, value;

  // Parse the first argument - recipient address
  try {
    to = ethers.utils.getAddress(args[0]);
  } catch {
    console.error(`Invalid recipient address: ${args[0]}`);
    process.exit(1);
  }

  // Parse the second argument - amount
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

  // Check that the account has sufficient balance
  const balance = await account.getBalance();
  if (balance.lt(value)) {
    const balanceFormatted = ethers.utils.formatEther(balance);

    console.error(
      `Insufficient balance to send ${valueFormatted} (You have ${balanceFormatted})`
    );
    process.exit(1);
  }

  console.log(`Transferring ${valueFormatted} ETH to ${to}...`);

  // Submit transaction
  const tx = await account.sendTransaction({ to, value, gasPrice: 20e9 });
  console.log(`Transaction hash: ${tx.hash}`);

  const receipt = await tx.wait();
  console.log(`Transaction confirmed in block ${receipt.blockNumber}`);
}

main(process.argv.slice(2));
```

This code, while lengthier than the previous ones, is really just a combination of everything you’ve learned so far. This script takes in two command line arguments. The first one is the recipient address, and the second is the amount to send. It then ensures that the address provided is valid, the amount provided is not negative and that the account has enough balance to be able to send the amount requested. It then submits the transaction and waits for it to be confirmed.

Create a new account using the **createWallet.js** script we created earlier, and try sending money to the new address:

```
$ **node src/createWallet.js**Mnemonic: napkin invite special reform cheese hunt refuse ketchup arena bag love caution
Address: 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 0.1**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Transferring 0.1 ETH to 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13...
Transaction hash: 0xa9f159fa8a9509ec8f8afa8ebb1131c3952cb3b2526471605fd84e8be408cebf
Transaction confirmed in block 8162896
```

![](https://img.learnblockchain.cn/2020/07/24/15955745416416.jpg)


You can verify the result in [Etherscan](https://ropsten.etherscan.io/). Let’s also test that the validation logic works:

```
$ **node src/transferETH.js foo**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Invalid address: foo$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 0.1.2**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Invalid amount: 0.1.2$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 -0.1**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Invalid amount: -0.1$ **node src/transferETH.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 100**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Insufficient balance to send 100.0 (You have 0.89328474)
```

## Transferring USDC

You will be able to use the majority of the code for USDC. The main differences are that USDC has 6 decimal places, and that you have to use the **transfer** function of the ERC20 spec to perform the transaction. You also pass the arguments “**to**” and “**value**” to the **transfer** smart contract function, rather than the Ethereum transaction itself.

Create **transferUSDC.js** in the same folder and enter the following:

```
const ethers = require("ethers");
const wallet = require("./wallet");
const provider = require("./provider");

async function main(args) {
  const account = wallet.connect(provider);
  
  // Define balanceOf and transfer functions in the contract
  const usdc = new ethers.Contract(
    "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
    [
      "function balanceOf(address _owner) public view returns (uint256 balance)",
      "function transfer(address _to, uint256 _value) public returns (bool success)",
    ],
    account
  );

  let to, value;

  // Parse the first argument - recipient address
  try {
    to = ethers.utils.getAddress(args[0]);
  } catch {
    console.error(`Invalid address: ${args[0]}`);
    process.exit(1);
  }

  // Parse the second argument - amount
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

  // Check that the account has sufficient balance
  const balance = await usdc.balanceOf(account.address);
  if (balance.lt(value)) {
    const balanceFormatted = ethers.utils.formatUnits(balance, 6);

    console.error(
      `Insufficient balance to send ${valueFormatted} (You have ${balanceFormatted})`
    );
    process.exit(1);
  }

  console.log(`Transferring ${valueFormatted} USDC to ${to}...`);

  // Submit a transaction to call the transfer function
  const tx = await usdc.transfer(to, value, { gasPrice: 20e9 });
  console.log(`Transaction hash: ${tx.hash}`);

  const receipt = await tx.wait();
  console.log(`Transaction confirmed in block ${receipt.blockNumber}`);
}

main(process.argv.slice(2));
```

Try it out, it should work just as well:
```
$ **node src/transferUSDC.js 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13 1**Address: 0xB3512cF013F71598F359bd5CA3f53C1F4260956a
Transferring 1.0 USDC to 0xDdAC089Fe56F0a9C70e6a04C74DCE52F86a91e13...
Transaction hash: 0xc1b2157a83f29d6c04f960bc49e968a0cd2ef884761af7f95cc83880631fe4af
Transaction confirmed in block 8162963
```

![](https://img.learnblockchain.cn/2020/07/24/15955746249527.jpg)


# Congratulations!

In this tutorial, you’ve learned how to generate an account, query balance, transfer tokens, and call smart contract functions. You might think that you still don’t know very much about crypto, but you now actually know enough to be able to build your own crypto wallet application. We’ve been writing command-line scripts to keep things simple, but how about building one with a nice web-based graphical interface for homework?

In the next part of this tutorial series, we will write our own Ethereum smart contract from scratch with Solidity and learn how you can build your own coin that is exchangeable with USDC. We’ll also be using the techniques learned today to interact with that contract. Stay tuned.


原文链接：https://blog.coinbase.com/introduction-to-building-on-defi-with-ethereum-and-usdc-part-1-ea952295a6e2


