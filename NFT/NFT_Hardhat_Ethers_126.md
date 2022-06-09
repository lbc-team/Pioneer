原文链接：https://dev.to/jacobedawson/import-test-a-popular-nft-smart-contract-with-hardhat-ethers-12i5

![06537eazw81rxn3xzv54.jpg](https://img.learnblockchain.cn/attachments/2022/05/BuyLYxvN62942b1836696.jpg)

# Import & Test a Popular NFT Smart Contract with Hardhat & Ethers

Today we're going to learn how to use the very cool [smart-contract development framework Hardhat](https://hardhat.org/) to locally import & test a publicly deployed smart contract. To make things fun & relevant, we'll be using the [Bored Ape Yacht Club](https://boredapeyachtclub.com/) NFT smart contract in our example. Using a well-known project's smart contract should make it clear how open the Ethereum ecosystem is, and how many opportunities there are to get started in Dapp and smart contract development!

By the end of this tutorial you will know the following:

- How to find smart contract code for specific projects
- How to add that code to a local development environment
- How to install & set-up a simple Hardhat development environment
- How to compile a contract and write tests for it

This tutorial won't involve any front-end development, but if you're interested in understanding how to get started with Web3 dapp development, feel free to check out my previous tutorials here on dev.to:

- [Build a Web3 Dapp in React & Login with MetaMask](https://dev.to/jacobedawson/build-a-web3-dapp-in-react-login-with-metamask-4chp)
- [Send React Web3 Transactions via MetaMask with useDapp](https://dev.to/jacobedawson/send-react-web3-dapp-transactions-via-metamask-2b8n)

### Step 1: Finding the Smart Contract Code

To begin with, we're going to start by choosing a project (Bored Ape Yacht Club), and then tracking down the smart contract code. Personally the first thing I'd do in this case is quickly check out the website of the project in question to see if they have a link to their contracts. In this case, https://boredapeyachtclub.com/ only contains social links, so we'll have to look elsewhere.

Since Bored Ape Yacht Club is an Ethereum-based NFT project, our next port of call will be [Etherscan](https://etherscan.io/), the Ethereum blockchain explorer. Since I know that Bored Ape Yacht Club uses the symbol BAYC, I can just search for that symbol using Etherscan (why, yes, I use dark mode on everything, how could you tell?):

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--Upq6jmnu--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/o6wz8nqernbmpadnfi0q.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--Upq6jmnu--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/o6wz8nqernbmpadnfi0q.png)

And there we go - we can see that this is a verified ERC-721 token contract with the name we're looking for! If we click on the search result we'll go through to the page for the BoredApeYachtClub token, with the Etherscan address: https://etherscan.io/token/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d

That's great, we're getting closer - in the top right hand section of the token page, called "Profile Summary", we will see a "Contract" address with a link:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--Sbboz9Hp--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/va8pqml5d2wxrxr11ciw.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--Sbboz9Hp--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/va8pqml5d2wxrxr11ciw.png)

If we click that we'll arrive at the "Contract" page on Etherscan - this is what we're looking for! Click on the "Contract" tab:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--6H_DDmp6--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rihi89wfk1rr33vtrqi0.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--6H_DDmp6--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rihi89wfk1rr33vtrqi0.png)

And there we have it - the verified contract source code for the contract named BoredApeYachtClub. Here's the Etherscan link to that specific section: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code

Now, at this point you might be wondering if there's a way to programmatically retrieve the contract code, given that we know the contract name, symbol and address. The answer is: of course :) But let's do it the manual way for now, I'll leave it to you to devise some more efficient ways to grab the contract using code ;)

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--nlfhRO9O--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hmlr5ow7oyuvdna1fdki.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--nlfhRO9O--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hmlr5ow7oyuvdna1fdki.png)

We've almost finished step 1 - we can copy the contract code and save it somewhere - for now you can just put it in a note pad or save it in a file somewhere, we're going to come back to this file later on in the tutorial. Next up, we'll set up our Hardhat environment..

### Step 2: Setting up our Hardhat Project

Tooling for Ethereum development hasn't had very long to evolve - the initial release of Ethereum was in July, 2015 - as of the writing of this article it has been only 6 years (which is hard to believe considering how far the Ethereum ecosystem has come during that time). Thanks to the efforts of the Ethereum community, we've progressed from rudimentary development environments that were only intuitive for experienced developers, through to 2021, where we've been blessed with finely-crafted frameworks, tools & libraries that make developing for the Ethereum ecosystem a breeze.

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--FsjkCbMW--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dtbm0mil8a1ex0agp4ua.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--FsjkCbMW--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dtbm0mil8a1ex0agp4ua.png)

The folks over at Nomic Labs have had their heads down building what has quickly become the gold-standard in Ethereum development environments: [Hardhat](https://hardhat.org/). It encompasses test running, compilation, deployment, a rich plugin-system and a local network to run everything against. When combined with other great tools like [Ethers](https://docs.ethers.io/v5/), [Waffle](https://getwaffle.io/), and [Chai](https://www.chaijs.com/), Hardhat puts an entire control panel in front of you to take an Ethereum project all the way from idea to [IDO](https://hackernoon.com/what-is-ido-the-new-alternative-to-ieo-and-ico-70l34zf).

NOTE: The instructions for this section can also be found in more detail here: https://hardhat.org/getting-started/#overview

Let's start by creating a new folder in your local environment:

```
mkdir hardhat-tutorial
```



Move into that new folder, run `npm init -Y`, and then install hardhat:

```
npm i -D hardhat
```



Now run `npx hardhat` and select "Create an empty hardhat.config.js":

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s---9JzCr0W--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/316a9tftmd3jx60dglun.png)](https://res.cloudinary.com/practicaldev/image/fetch/s---9JzCr0W--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/316a9tftmd3jx60dglun.png)

That will add a hardhat.config.js file for us, which we'll have a look at soon. We're also going to install some other tools, including the Waffle test suite and Ethers. So run:

```
npm i -D @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
```



Let's go all the way and make our [Hardhat project TypeScript ready](https://hardhat.org/guides/typescript.html).

First, install TypeScript and some types:

```
npm i -D ts-node typescript @types/node @types/chai @types/mocha
```



Then we'll rename our `hardhat.config.js` file to be `hardhat.config.ts`:

```
mv hardhat.config.js hardhat.config.ts
```



We now need to make a change to our `hardhat.config.ts` file, since with a Hardhat TypeScript project plugins need to be loaded with `import` instead of `require`, and functions must be explictly imported:

Change this:

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



Into this:

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



Sweet - we're setup with TypeScript. Now if you run `npx hardhat` again you should see some help instructions in your console:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--UfC3Uaz9--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3l32vplkvko7vk2rbguh.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--UfC3Uaz9--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3l32vplkvko7vk2rbguh.png)

Great! If you've made it this far we have a Hardhat project configured with TypeScript and our required tools are installed.

Notice in the screenshot above that there is a section called "Available Tasks" - this is a list of built-in tasks that are provided by the Hardhat team, enabling us to run important tasks from the get-go. Hardhat is extremely malleable, and works with 3rd party plugins that help us to adapt our project to our specific needs. We've already installed the hardhat-waffle and hardhat-ethers plugins, and you can find an extensive list of plugins here: https://hardhat.org/plugins/

We can also create our own tasks. If you open `hardhat.config.ts` you'll see the sample "accounts" task definition. The task definition function takes 3 arguments - a name, a description, and a callback function that carries out the task. If you change the description of the "accounts" task, to "Hello, world!", and then run `npx hardhat` in your console, you'll see that the "accounts" task now has the description "Hello, world!".

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

Now our simple Hardhat project is all set up, let's move on to importing & compiling our Bored Ape contract...

### Step 3: Importing & Compiling our Contract

Let's start by creating a new folder called `contracts` in our root directory (Hardhat uses the "contracts" folder as the source folder by default - if you want to change that name, you'll need to configure it within the `hardhat.config.ts` file):

```
mdkir contracts
```



Create a new file called `bored-ape.sol` in the contracts folder, then paste the contract code that we copied from Etherscan earlier.

NOTE: The .sol extension is the Solidity file extension. To add syntax highlighting and type hints for Solidity files, there is a great VSCode extension made by [Juan Blanco called "solidity"](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity) - I recommend installing it to make developing Solidity easier:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--hF14pbnX--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hdlme4tjzpe9cc7k35kd.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--hF14pbnX--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hdlme4tjzpe9cc7k35kd.png)

I also use a VSCode extension called ["Solidity Visual Developer"](https://marketplace.visualstudio.com/items?itemName=tintinweb.solidity-visual-auditor), and you'll find many more in the VSCode marketplace.

Now that we have a `contracts` folder with the `bored-ape.sol` contract inside it, we are ready to compile the contract. We can use a built-in `compile` task to do this - all we need to do is run:

```
npx hardhat compile
```



When we compile a contract with Hardhat, two files will be generated for each contract and placed into a `artifacts/contracts/<CONTRACT NAME>` folder. These two files (an "artifact" .json file, and a debug "dbg" .json file) will be generated for *each contract* - the Bored Ape contract code that we copied from Etherscan actually contains multiple "contracts".

If you view the original `contracts/bored-ape.sol` file you can see that the "contract" keyword is used 15 times in total, and each instance has its own contract name - therefore, after compiling the `bored-ape.sol` file we will end up with 30 files in the `artifacts/contracts/bored-ape.sol/` folder.

That's ok though - since Solidity contracts are essentially object-oriented classes, we need only be concerned with the `BoredApeYachtClub.json` artifact - this is the file that contains the "BoredApeYachtClub" ABI (the [Application Binary Interface](https://docs.soliditylang.org/en/latest/abi-spec.html#abi-json), a JSON representation of the contract's variables & functions), and is exactly what we need to pass into Ethers in order to create a contract instance.

We've now achieved 3 out of our 4 objectives - our last objective for this tutorial is to write a test file so that we can run tests against our imported contract.

### Step 4: Writing Tests for our Contract

Testing is a deep and complex subject, so we're going to keep this simple, so that you understand the general process and can dive deeper into the subject at your own pace. Our goal for this step will be to setup and write some tests for the "BoredApeYachtClub" contract.

We've already installed "hardhat-ethers", which is a Hardhat plugin that will give us access to the "Ethers" library, and enable us to interact with our smart contract.

NOTE: If you have a JavaScript / Hardhat project, all of the properties of the Hardhat Runtime Environment are automatically injected into the global scope. When using TypeScript, however, nothing is available in the global scope, so we have to import instances explicitly.

Let's create a new test in the `test` folder in the root directory, and call it `bored-ape.test.ts`. Now we'll write a test, and I'll explain what we're doing in the code comments:

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



That's a fair bit of code! Essentially we are creating a Contract Factory, which contains additional information necessary to deploy a contract. Once we have the Contract Factory, we can use the `.deploy()` method, passing in variables that are required by the contract constructor. Here is the original contract constructor:

```
//bored-ape.sol
constructor(string memory name, string memory symbol, uint256 maxNftSupply, uint256 saleStart) ERC721(name, symbol)
```



The constructor takes 4 arguments, each with type definitions:

- name, a string
- symbol, a string
- maxNftSupply, a number
- saleStart, a number

Ok - now comes the moment of truth - let's run our test with:

```
npx hardhat test
```



You should see something like this:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--90AWA7DQ--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2bgksduuxlg8tjzqtmpt.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--90AWA7DQ--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2bgksduuxlg8tjzqtmpt.png)

But hang on - why is it failing? Well, we can see under 1) Bored Ape `AssertionError: Expected "10000" to be equal 5000`. This is nothing to worry about - I've deliberately added a test case that will fail on the first run - this is good practice, to help remove false positives. If we don't add a failing case to begin with, we can't be certain that we aren't accidentally writing a test that will always return true. A more thorough version of this method would actually begin with creating the test first and then gradually writing code to make it pass, but since it's not the focus of this tutorial we'll gloss over that. If you're interested in learning more about this style of writing tests and then implementing code to make it pass, here are a couple of good introductions:

- https://www.codecademy.com/articles/tdd-red-green-refactor
- http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html
- https://medium.com/@tunkhine126/red-green-refactor-42b5b643b506

To make our test pass, edit this line to include 10000:

```
expect(await boredApeContract.MAX_APES()).to.equal(10000);
```



[![image](https://res.cloudinary.com/practicaldev/image/fetch/s---bEolRJ2--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/svlex3607kmajgjpu0ph.png)](https://res.cloudinary.com/practicaldev/image/fetch/s---bEolRJ2--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/svlex3607kmajgjpu0ph.png)

Nice! We now have a passing test case :) Let's write a few more tests to flex our muscles.

Before we do that though, we're going to use a helper function called `beforeEach` that will simplify the setup for each test, and allow us to reuse variables for each test. We'll move our contract deployment code into the `beforeEach` function, and as you can see, we can use the `boredApeContract` instance in our "initialize" test:

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



Since we're using TypeScript, we've imported types for our variables in "beforeEach", and have added an "owner" and "address1" variable that can be used in test cases that require addresses. We've made use of the owner variable by adding another test "Should set the right owner" - this checks that the owner of the contract is the same one that is returned when we deployed the contract.

In the `bored-ape.sol` file, notice that there is a function called `mintApe` which takes in both a number of tokens (representing Bored Ape NFTs), and also expects to receive some ETH. Let's write a test for that function, which will let us try out payments, and force us to make use of some other methods in the contract to make the test pass.

We'll start by defining the test:

```
// bored-ape.test.ts
it("Should mint an ape", async () => {
  expect(await boredApeContract.mintApe(1)).to.emit(
    boredApeContract,
    "Transfer"
  );
});
```



Since the `mintApe` method doesn't return a value, we are going to listen for an event called "Transfer" - we can trace the `mintApe` function's inheritance and see that ultimately it calls the `_mint` function of an ERC-721 token and emits a { Transfer } event:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--hm-o1ujT--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xtqzs2uj42dm2yxb5fyp.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--hm-o1ujT--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xtqzs2uj42dm2yxb5fyp.png)

At the moment it doesn't matter that we listen for the "Transfer" event - this test is going to fail since `mintApe` contains a number of conditions that we haven't fulfilled:

[![image](https://res.cloudinary.com/practicaldev/image/fetch/s--mSxWDSGO--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3nynbhcek8zd74pos4gy.png)](https://res.cloudinary.com/practicaldev/image/fetch/s--mSxWDSGO--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3nynbhcek8zd74pos4gy.png)

We can see that an error "Sale must be active to mint Ape", so it looks like first we have to call the contract method `flipSaleState`:

```
// bored-ape.test.ts
await boredApeContract.flipSaleState();
```



Run `npx hardhat test` and...we're still failing - but with a different error! A different error is actually great news, because it means we're making progress :) Looks like "Ether value sent is not correct" - which makes sense, since we didn't send any ETH along with our contract call. Notice that the `mintApe` method signature contains the keyword "payable":

```
// bored-ape.sol
function mintApe(uint numberOfTokens) public payable 
```



That means that this method can (and expects to) receive ETH. We can retrieve the required cost of a Bored Ape first by calling the `apePrice` getter method:

```
// bored-ape.sol
uint256 public constant apePrice = 80000000000000000; //0.08 ETH
```



Finally, we need to import some more functions, use `apePrice` as our value, and send it through as ETH with our call to `mintApe`. We'll also chain another method called `withArgs` to our `emit` call, which will give us the ability to listen to the arguments emitted by the "Transfer" event:

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



We're using an "overrides" object (https://docs.ethers.io/ethers.js/html/api-contract.html#overrides) to add additional data to our method call - in this case, a value property that will be received by the contract's `mintApe` method as `msg.value`, ensuring that we now satisfy the condition of the "Ether value sent is not correct" requirement:

```
// bored-ape.sol
require(apePrice.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");
```



We've imported `chai` into our test file so that we can use chai "matchers" - which we combine with the "solidity" matcher imported from "ethereum-waffle": https://ethereum-waffle.readthedocs.io/en/latest/matchers.html - now we are able to specify the exact arguments that we expect to receive from the "Transfer" event, and we can ensure that the test is actually passing as intended.

If you're wondering how we determined the arguments we expect to receive, I'll explain: First, we can inspect the `_mint` method in `bored-ape.sol` and see that `Transfer` emits 3 arguments.

```
// bored-ape.sol
emit Transfer(address(0), to, tokenId);
```



The first argument is the "Zero account": https://ethereum.stackexchange.com/questions/13523/what-is-the-zero-account-as-described-by-the-solidity-docs - also known as "AddressZero". The second argument "to" is the address that sent the `mintApe` transaction - in this case we're just using the owner's address. Lastly, the tokenId is defined within a for-loop in the `mintApe` method, and is set to be equal to the return value of calling the `tokenSupply` getter.

Once we know what these values are, we can input them into our `withArgs` method, including a handy constant provided by the ethers library called `AddressZero`:

```
// bored-ape.test.ts
.withArgs(ethers.constants.AddressZero, owner.address, tokenId);
```



And that's it - we can run `npx hardhat test` and we'll get a passing test. If you change any of the values in `withArgs` you'll get a failing test - exactly what we expect!

Here's what the final test file looks like:

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



Jackpot! Well done, we've covered all of our objectives for this tutorial:

- How to find smart contract code for specific projects
- How to add that code to a local development environment
- How to install & set-up a simple Hardhat development environment
- How to compile a contract and write tests for it

Hopefully this has given you some insight into the process of importing and testing contracts with Hardhat, Ethers, Chai & Mocha. The same processes can be followed when you write your own Solidity contracts, and when combined with a front-end repo you have the power of a complete development suite with really intuitive processes & thorough documentation.

If you'd like to view the source code for this tutorial, you can find it here: https://github.com/jacobedawson/import-test-contracts-hardhat

Thanks for playing ;)

Follow me on Twitter: https://twitter.com/jacobedawson