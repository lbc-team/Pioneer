# Buidler's tutorial for beginners



![Teacher Buidler](https://img.learnblockchain.cn/pics/20200810093036.svg)

# 1. Overview

Welcome to our beginners guide to Ethereum contracts and dApp development. This tutorial is aimed at hackathon participants who are getting setup to quickly build something from scratch.

To orchestrate this process we're going to use **Buidler**, which is a task runner that facilitates building on Ethereum. It helps developers manage and automate the recurring tasks that are inherent to the process of building smart contracts and dApps, as well as easily introducing more functionality around this workflow. This means compiling and testing at the very core.

**Buidler** also comes built-in with **Buidler EVM**, a local Ethereum network designed for development. It allows you to deploy your contracts, run your tests and debug your code.

In this tutorial we'll guide you through:

- Setting up your Node.js environment for Ethereum development
- Creating and configuring a **Buidler** project
- The basics of a Solidity smart contract that implements a token
- Writing automated tests for your contract using [Ethers.js](https://docs.ethers.io/ethers.js/html/) and [Waffle](https://getwaffle.io/)
- Debugging Solidity with `console.log()` using **Buidler EVM**
- Deploying your contract to **Buidler EVM** and Ethereum testnets

To follow this tutorial you should be able to:

- Write code in [JavaScript](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/JavaScript_basics)
- Operate a [terminal](https://en.wikipedia.org/wiki/Terminal_emulator)
- Use [git](https://git-scm.com/doc)
- Understand the basics of how [smart contracts](https://ethereum.org/learn/#smart-contracts) work
- Set up a [Metamask](https://metamask.io/) wallet

If you can't do any of the above, follow the links and take some time to get learn the basics.



# 2. Setting up the environment

Most Ethereum libraries and tools are written in JavaScript, and so is **Buidler**. If you're not familiar with Node.js, it's a JavaScript runtime built on Chrome's V8 JavaScript engine. It's the most popular solution to run JavaScript outside of a web browser and **Buidler** is built on top of it.

## Installing Node.js

You can [skip](https://buidler.dev/tutorial/setting-up-the-environment.html#checking-your-environment) this section if you already have a working Node.js `>=10.0` installation. If not, here's how to install it on Ubuntu, MacOS and Windows.

### Linux

#### Ubuntu

Copy and paste these commands in a terminal:

```text
sudo apt update
sudo apt install curl git
sudo apt install build-essential # We need this to build native dependencies
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install nodejs
```

### MacOS

Make sure you have `git` installed. Otherwise, follow [these instructions](https://www.atlassian.com/git/tutorials/install-git).

There are multiple ways of installing Node.js on MacOS. We will be using [Node Version Manager (nvm)](http://github.com/creationix/nvm). Copy and paste these commands in a terminal:

```text
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.2/install.sh | bash
nvm install 10
nvm use 10
nvm alias default 10
npm install npm --global # Upgrade npm to the latest version
npm install -g node-gyp # Make sure we have node-gyp installed
# This next setp is needed to build native dependencies.
# A popup will appear and you have to proceed with an installation.
# It will take some time, and may download a few GB of data.
xcode-select --install
```

### Windows

Installing Node.js on Windows requires a few manual steps. We'll install git, Node.js 10.x and NPM's Windows Build Tools. Download and run these:

1. [Git's installer for Windows](https://git-scm.com/download/win)
2. `node-v10.XX.XX-x64.msi` from [here](https://nodejs.org/dist/latest-v10.x)

Then [open your terminal as Administrator](https://www.howtogeek.com/194041/how-to-open-the-command-prompt-as-administrator-in-windows-8.1/) and run the following command:

```text
npm install --global --production windows-build-tools
```

It will take several minutes and may download a few GB of data.

## Checking your environment

To make sure your development environment is ready, copy and paste these commands in a new terminal:

```text
git clone https://github.com/nomiclabs/ethereum-hackathon-setup-checker.git
cd ethereum-hackathon-setup-checker
npm install
```

If this is succesful you should see a confirmation message meaning that your development environment is ready. Feel free to delete the repository directory and move on to [Creating a new Buidler project](https://buidler.dev/tutorial/creating-a-new-buidler-project.html).

If any of them failed, your environment is not properly setup. Make sure you have `git` and Node.js `>=10.0` installed. If you're seeing errors mentioning "node-gyp", make sure you installed the build tools mentioned before.

If you have an older version of Node.js, please refer to the next section.

##  Upgrading your Node.js installation

If your version of Node.js is older than `10.0` follow the instructions below to upgrade. After you are done, go back to [Checking your environment](https://buidler.dev/tutorial/setting-up-the-environment.html#checking-your-environment).

### Linux

#### Ubuntu

1. Run `sudo apt remove nodejs` in a terminal to remove Node.js.
2. Find the version of Node.js that you want to install [here](https://github.com/nodesource/distributions#debinstall) and follow the instructions.
3. Run `sudo apt update && sudo apt install nodejs` in a terminal to install Node.js again.

### MacOS

You can change your Node.js version using [nvm](http://github.com/creationix/nvm). To upgrade to Node.js `12.x` run these in a terminal:

```text
nvm install 12
nvm use 12
nvm alias default 12
npm install npm --global # Upgrade npm to the latest version
npm install -g node-gyp # Make sure we have node-gyp installed
```

###  Windows

You need to follow the [same installation instructions](https://buidler.dev/tutorial/setting-up-the-environment.html#windows) as before but choose a different version. You can check the list of all available versions [here](https://nodejs.org/en/download/releases/).

# 3. Creating a new Buidler project

We'll install **Buidler** using the npm CLI. The **N**ode.js **p**ackage **m**anager is a package manager and an online repository for JavaScript code.

Open a new terminal and run these commands:

```text
mkdir buidler-tutorial 
cd buidler-tutorial 
npm init --yes 
npm install --save-dev @nomiclabs/buidler 
```

> TIP

>  Installing **Buidler** will install some Ethereum JavaScript dependencies, so be patient.

In the same directory where you installed **Buidler** run:

```text
npx buidler
```

Select `Create an empty buidler.config.js` with your keyboard and hit enter.



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

When **Buidler** is run, it searches for the closest `buidler.config.js` file starting from the current working directory. This file normally lives in the root of your project and an empty `buidler.config.js` is enough for **Buidler** to work. The entirety of your setup is contained in this file.

## Buidler's architecture

**Buidler** is designed around the concepts of **tasks** and **plugins**. The bulk of **Buidler**'s functionality comes from plugins, which as a developer [you're free to choose](https://buidler.dev/plugins/) the ones you want to use.

### Tasks

Every time you're running **Buidler** from the CLI you're running a task. e.g. `npx buidler compile` is running the `compile` task. To see the currently available tasks in your project, run `npx buidler`. Feel free to explore any task by running `npx buidler help [task]`.

> TIP

>  You can create your own tasks. Check out the [Creating a task](https://buidler.dev/guides/create-task.html) guide.

### Plugins

**Buidler** is unopinionated in terms of what tools you end up using, but it does come with some built-in defaults. All of which can be overriden. Most of the time the way to use a given tool is by consuming a plugin that integrates it into **Buidler**.

For this tutorial we are going to use the Ethers.js and Waffle plugins. They'll allow you to interact with Ethereum and to test your contracts. We'll explain how they're used later on. To install them, in your project directory run:

```text
npm install --save-dev @nomiclabs/buidler-ethers ethers @nomiclabs/buidler-waffle ethereum-waffle chai
```

Add the highlighted lines to your `buidler.config.js` so that it looks like this:

 

```js
usePlugin("@nomiclabs/buidler-waffle");

module.exports = {
  solc: {
    version: "0.6.8"
  }
};
```

We're only invoking `buidler-waffle` here because it depends on `buidler-ethers` so adding both isn't necessary.

# 4. Writing and compiling smart contracts

We're going to create a simple smart contract that implements a token that can be transferred. Token contracts are most frequently used to exchange or store value. We won't go in depth into the Solidity code of the contract on this tutorial, but there's some logic we implemented that you should know:

- There is a fixed total supply of tokens that can't be changed.
- The entire supply is assigned to the address that deploys the contract.
- Anyone can receive tokens.
- Anyone with at least one token can transfer tokens.
- The token is non-divisible. You can transfer 1, 2, 3 or 37 tokens but not 2.5.

>  TIP

> You might have heard about ERC20, which is a token standard in Ethereum. Tokens such as DAI, USDC, MKR and ZRX follow the ERC20 standard which allows them all to be compatible with any software that can deal with ERC20 tokens. **For simplicity's sake the token we're going to build is \*not\* an ERC20.**

## Writing smart contracts

Start by creating a new directory called `contracts` and create a file inside the directory called `Token.sol`.

Paste the code below into the file and take a minute to read the code. It's simple and it's full of comments explaining the basics of Solidity.

> TIP

> To get syntax highlighting you should add Solidity support to your text editor. Just look for Solidity or Ethereum plugins. We recommend using Visual Studio Code or Sublime Text 3.

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
     * Contract initialization.
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
     * A function to transfer tokens.
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
     * Read only function to retrieve the token balance of a given account.
     *
     * The `view` modifier indicates that it doesn't modify the contract's
     * state, which allows us to call it without executing a transaction.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
```

> TIP

> `*.sol` is used for Solidity files. We recommend matching the file name to the contract it contains, which is a common practice.

## Compiling contracts

To compile the contract run `npx buidler compile` in your terminal. The `compile` task is one of the built-in tasks.

```text
$ npx buidler compile
Compiling...
Compiled 1 contract successfully
```

The contract has been successfully compiled and it's ready to be used.

# 5. Testing contracts

Writing automated tests when building smart contracts is of crucial importance, as your user's money is what's at stake. For this we're going to use **Buidler EVM**, a local Ethereum network designed for development that is built-in and the default network in **Buidler**. You don't need to setup anything to use it. In our tests we're going to use ethers.js to interact with the Ethereum contract we built in the previous section, and [Mocha](https://mochajs.org/) as our test runner.

## Writing tests

Create a new directory called `test` inside our project root directory and create a new file called `Token.js`.

Let's start with the code below. We'll explain it next, but for now paste this into `Token.js`:

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

On your terminal run `npx buidler test`. You should see the following output:

```text
$ npx buidler test
All contracts have already been compiled, skipping compilation.


  Token contract
    ✓ Deployment should assign the total supply of tokens to the owner (654ms)


  1 passing (663ms)
```

This means the test passed. Let's now explain each line:

```js
const [owner] = await ethers.getSigners();
```

A `Signer` in ethers.js is an object that represents an Ethereum account. It's used to send transactions to contracts and other accounts. Here we're getting a list of the accounts in the node we're connected to, which in this case is **Buidler EVM**, and only keeping the first one.

The `ethers` variable is available in the global scope. If you like your code always being explicit, you can add this line at the top:

```js
const { ethers } = require("@nomiclabs/buidler");
```

> TIP

>  To learn more about `Signer`, you can look at the [Signers documentation](https://docs.ethers.io/ethers.js/html/api-wallet.html).

```js
const Token = await ethers.getContractFactory("Token");
```

A `ContractFactory` in ethers.js is an abstraction used to deploy new smart contracts, so `Token` here is a factory for instances of our token contract.

```js
const buidlerToken = await Token.deploy();
```

Calling `deploy()` on a `ContractFactory` will start the deployment, and return a `Promise` that resolves to a `Contract`. This is the object that has a method for each of your smart contract functions.

```js
await buidlerToken.deployed();
```

When you call on `deploy()` the transaction is sent, but the contract isn't actually deployed until the transaction is mined. Calling `deployed()` will return a `Promise` that resolves once this happens, so this code is blocking until the deployment finishes.

```js
const ownerBalance = await buidlerToken.balanceOf(owner.getAddress());
```

Once the contract is deployed, we can call our contract methods on `buidlerToken` and use them to get the balance of the owner account by calling `balanceOf()`.

Remember that the owner of the token who gets the entire supply is the account that makes the deployment, and when using the `buidler-ethers` plugin `ContractFactory` and `Contract` instances are connected to the first signer by default. This means that the account in the `owner` variable executed the deployment, and `balanceOf()` should return the entire supply amount.

```js
expect(await buidlerToken.totalSupply()).to.equal(ownerBalance);
```

Here we're again using our `Contract` instance to call a smart contract function in our Solidity code. `totalSupply()` returns the token's supply amount and we're checking that it's equal to `ownerBalance`, as it should.

To do this we're using [Chai](https://www.chaijs.com/) which is an assertions library. These asserting functions are called "matchers", and the ones we're using here actually come from [Waffle](https://getwaffle.io/). This is why we're using the `buidler-waffle` plugin, which makes it easier to assert values from Ethereum. Check out [this section](https://ethereum-waffle.readthedocs.io/en/latest/matchers.html) in Waffle's documentation for the entire list of Ethereum-specific matchers.

### Using a different account

If you need to send a transaction from an account (or `Signer` in ethers.js speak) other than the default one to test your code, you can use the `connect()` method in your ethers.js `Contract` to connect it to a different account. Like this:





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

### Full coverage

Now that we've covered the basics you'll need for testing your contracts, here's a full test suite for the token with a lot of additional information about Mocha and how to structure your tests. We recommend reading through.

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

This is what the output of `npx buidler test` should look like against the full test suite:

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

Keep in mind that when you run `npx buidler test`, your contracts will be compiled if they've changed since the last time you ran your tests.



# 6. Debugging with Buidler EVM

**Buidler** comes built-in with **Buidler EVM**, a local Ethereum network designed for development. It allows you to deploy your contracts, run your tests and debug your code. It's the default network **Buidler** connects to, so you don't need to setup anything for it to work. Just run your tests.

## Solidity `console.log`

When running your contracts and tests on **Buidler EVM** you can print logging messages and contract variables calling `console.log()` from your Solidity code. To use it you have to import **Buidler**'s`console.log` from your contract code.

This is what it looks like:



```solidity
pragma solidity ^0.6.0;

import "@nomiclabs/buidler/console.sol";

contract Token {
  //...
}
```

Add some `console.log` to the `transfer()` function as if you were using it in JavaScript:





```solidity
function transfer(address to, uint256 amount) external {
    console.log("Sender balance is %s tokens", balances[msg.sender]);
    console.log("Trying to send %s tokens to %s", amount, to);

    require(balances[msg.sender] >= amount, "Not enough tokens");

    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

The logging output will show when you run your tests:



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

Check out the [documentation](https://buidler.dev/buidler-evm/#console-log) to learn more about this feature.

# 7. Deploying to a live network

Once you're ready to share your dApp with other people what you may want to do is deploy to a live network. This way others can access an instance that's not running locally on your system.

There's the Ethereum network that deals with real money which is called "mainnet", and then there are other live networks that don't deal with real money but do mimic the real world scenario well, and can be used by others as a shared staging environment. These are called "testnets" and Ethereum has multiple ones: *Ropsten*, *Kovan*, *Rinkeby* and *Goerli*. We recommend you deploy your contracts to the *Ropsten* testnet.

At the software level, deploying to a testnet is the same as deploying to mainnet. The only difference is which network you connect to. Let's look into what the code to deploy your contracts using ethers.js would look like.

The main concepts used are `Signer`, `ContractFactory` and `Contract` which we explained back in the [testing](https://buidler.dev/tutorial/testing-contracts.html) section. There's nothing new that needs to be done when compared to testing, given that when you're testing your contracts you're *actually* making a deployment to your development network. This makes the code very similar, or the same.

Let's create a new directory `scripts` inside the project root's directory, and paste the following into a `deploy.js` file:

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

To indicate **Buidler** to connect to a specific Ethereum network when running any tasks, you can use the `--network` parameter. Like this:

```text
npx buidler run scripts/deploy.js --network <network-name>
```

In this case, running it without the `--network` parameter would get the code to run against an embedded instance of **Buidler EVM**, so the deployment actually gets lost when **Buidler** finishes running, but it's still useful to test that our deployment code works:

```text
$ npx buidler run scripts/deploy.js
All contracts have already been compiled, skipping compilation.
Deploying contracts with the account: 0xc783df8a850f42e7F7e57013759C285caa701eB6
Account balance: 10000000000000000000000
Token address: 0x7c2C195CD6D34B8F845992d380aADB2730bB9C6F
```

## Deploying to remote networks

To deploy to a remote network such as mainnet or any testnet, you need to add a `network` entry to your `buidler.config.js` file. We’ll use Ropsten for this example, but you can add any network similarly:



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

We're using [Infura](https://infura.io/), but pointing `url` to any Ethereum node or gateway would work. Go grab your `INFURA_PROJECT_ID` and come back.

To deploy on Ropsten you need to send ropsten-ETH into the address that's going to be making the deployment. You can get some ETH for testnets from a faucet, a service that distributes testing-ETH for free. [Here's the one for Ropsten](https://faucet.metamask.io/), you'll have to change Metamask's network to Ropsten before transacting.

TIP

You can get some ETH for other testnets following these links:

- [Kovan faucet](https://faucet.kovan.network/)
- [Rinkeby faucet](https://faucet.rinkeby.io/)
- [Goerli faucet](https://goerli-faucet.slock.it/)

Finally, run:

```text
npx buidler run scripts/deploy.js --network ropsten
```

If everything went well, you should see the deployed contract address.

# 8. Buidler Hackathon Boilerplate Project

If you want to get started with your dApp quickly or see what this whole project looks like with a frontend, you can use our hackathon boilerplate repo.

https://github.com/nomiclabs/buidler-hackathon-boilerplate

## What's included

- The Solidity contract we used in this tutorial
- A test suite using ethers.js and Waffle
- A minimal front-end to interact with the contract using ethers.js

###  Solidity contract & tests

In the root of the repo you'll find the **Buidler** project we put together through this tutorial with the `Token` contract. To refresh your memory on what it implements:

- There is a fixed total supply of tokens that can't be changed.
- The entire supply is assigned to the address that deploys the contract.
- Anyone can receive tokens.
- Anyone with at least one token can transfer tokens.
- The token is non-divisible. You can transfer 1, 2, 3 or 37 tokens but not 2.5.

###  Frontend app

In `frontend/` you'll find a simple app that allows the user to do two things:

- Check the connected wallet's balance
- Send tokens to an address

It's a separate npm project and it was created using `create-react-app`, so this means that it uses webpack and babel.

### Frontend file architecture

- ```
  src/ 
  ```

  contains all the code

  - ```
  src/components
    ```
  
    contains the react components

    - `Dapp.js` is the only file with business logic. This is where you'd replace the code with your own if you were to use this as boilerplate
- Every other component just renders HTML, no logic.
    - `src/contracts` has the ABI and address of the contract and these are automatically generated by the deployment script

## How to use it

First clone the repository, and then to get the contracts deployed:

```text
cd buidler-hackathon-boilerplate/
npm install
npx buidler node
```

Here we just install the npm project's dependencies, and by running `npx buidler node` we spin up an instance of **Buidler EVM** that you can connect to using MetaMask. In a different terminal in the same directory, run:

```text
npx buidler --network localhost run scripts/deploy.js
```

This will deploy the contract to **Buidler EVM**. After this completes run:

```text
cd buidler-hackathon-boilerplate/frontend/
npm install
npm run start
```

To start the react web app. Open http://localhost:3000/ in your browser and you should see this: ![img](https://buidler.dev/front-5.png)

Set your network in MetaMask to `localhost:8545`, and click the button. You should then see this:

![img](https://buidler.dev/front-2.png)

What's happening here is that the frontend code to show the current wallet's balance is detecting that the balance is `0`, so you wouldn't be able to try the transfer functionality. By running:

```text
npx buidler --network localhost faucet <your address>
```

You'll run a custom **Buidler** task we included that uses the balance of the deploying account to send 100 MBT and 1 ETH to your address. This will allow you to send tokens to another address.

You can check out the code for the task in [`/tasks/faucet.js`](https://github.com/nomiclabs/buidler-hackathon-boilerplate/blob/master/tasks/faucet.js), which is required from `buidler.config.js`.

```text
$ npx buidler --network localhost faucet 0x0987a41e73e69f60c5071ce3c8f7e730f9a60f90
Transferred 1 ETH and 100 tokens to 0x0987a41e73e69f60c5071ce3c8f7e730f9a60f90
```

In the terminal where you ran `npx buidler node` you should also see:

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

Showing the `console.log` output from the `transfer()` function in our contract, and this is what the web app will look like after you run the faucet task: ![img](https://buidler.dev/front-6.png)

Try playing around with it and reading the code. It's full of comments explaining what's going on and clearly indicating what code is Ethereum boilerplate and what's actually dApp logic. This should make the repository easy to reuse for your project.

# 9. Final thoughts

Congratulations on finishing the tutorial!

Here are some links you might find useful throughout your journey:

- [Buidler's Hackathon Boilerplate](https://github.com/nomiclabs/buidler-hackathon-boilerplate)
- [Buidler's documentation site](https://buidler.dev/getting-started/)
- [Telegram Buidler Support Group](https://t.me/BuidlerSupport)
- [Ethers.js Documentation](https://docs.ethers.io/ethers.js/html/)
- [Waffle Documentation](https://getwaffle.io/)
- [Mocha Documentation](https://mochajs.org/)
- [Chai Documentation](https://www.chaijs.com/)

Happy hacking!

![img](https://buidler.dev/cool-buidler.svg)