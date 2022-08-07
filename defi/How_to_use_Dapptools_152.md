原文链接：https://medium.com/@patrick.collins_58673/how-to-use-dapptools-code-like-makerdao-fed9909d055b

# How to use Dapptools | Code like MakerDAO

## Learn how to use Dapptools, the smart contract deployment framework for web3 developers who love bash and the command line. We look at using this learning this blockchain deployment framework end-to-end.

![How to use dapptools](https://img.learnblockchain.cn/attachments/2022/08/AoZwUH6J62eb8d435164c.png)

[dapp.tools](https://dapp.tools/)

[MakerDAO](https://makerdao.com/en/) is one of the largest DeFi protocols out there, with the [DAI](https://www.coingecko.com/en/coins/dai) stablecoin being one of the most widely used in the industry. Their team uses a special framework called [dapptools](https://dapp.tools/) to create, deploy, test, and interact with their smart contracts.

Created by the [Dapphub](https://github.com/dapphub) team, the dapptools framework is a minimalistic bash friendly tool that any Linux power user will easily fall in love with, and many have.

![How to use Dapptools](https://img.learnblockchain.cn/attachments/2022/08/0irGOMQa62eb8d8fe0a54.png)

[Transmissions11](https://twitter.com/transmissions11/status/1437518450880966656) exclaiming excitement for dapptools

It’s also incredibly beginner-friendly, so if this is your first look into a deployment framework, you’ve come to the right place. In this article, we are going to show how to do the following with dapptools:

1. Write & compile contracts
2. Test contracts with solidity and fuzzing
3. Deploy contracts
4. Interact with deployed contracts

We are going to be using our [dapptools-demo](https://github.com/PatrickAlphaC/dapptools-demo) that we setup to learn about it. Feel free to jump there to jump in. If you want, you can also check out the [Foundry](https://github.com/gakonst/foundry) tool, which is a re-write of dapptools, but written in rust by the [Paradigm](https://www.paradigm.xyz/) team.

For a more full repo with more good code and examples, check out the [dapptools-starter-kit](https://github.com/smartcontractkit/dapptools-starter-kit), it includes code examples using [Chainlink](https://chain.link/)!

If you want to just git clone the repo to start playing with it, feel free to follow along with the readme in the repo!

Video on all this will be out soon:

https://www.youtube.com/watch?v=ZurrDzuurQs

Dapptools video

# Setup

## Environment

First, you’ll need a code editor, I’m a big fan of [VSCode](https://code.visualstudio.com/). If you’re on windows, you’ll need to download [WSL](https://docs.microsoft.com/en-us/windows/wsl/install), since we will be running a number of windows commands.

Once you’re using VSCode, [open up a terminal](https://code.visualstudio.com/docs/editor/integrated-terminal) to run commands for installing, or whatever way you normally run shell commands.

## Installation / Requirements

1. Git
2. Make
3. Dapptools

First off, you’ll need to [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), follow that link to install git. You’ll know you’ve done it right if you can run:

```
git --version 
```

Then, you’ll need to make sure you have `make` installed. Most computers come with it already installed, but if not, check out this [stack exchange](https://askubuntu.com/questions/161104/how-do-i-install-make) question on the subject.

Then, install dapptools. Be sure to go to the [official documentation](https://github.com/dapphub/dapptools#installation) to install, but it’ll look something like running this:

```
# user must be in sudoers
curl -L https://nixos.org/nix/install | sh

# Run this or login again to use Nix
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

curl https://dapp.tools/install | sh
```

And you should have `dapp` , `seth` , `ethsign` , `hevm` , and a few other commands you can run now!

These instructions only work for Unix based systems (For example, MacOS,

# **Create a local dapptools project**

To create a new folder, run the following:

```
dapp init
```

This will give you a basic file layout that should look like this:

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

`Makefile`: Where you put your “scripts”. Dapptools is command line based, and our makefile helps us run large commands with a few characters.

`lib`: This folder is for external dependencies, like [Openzeppelin](https://openzeppelin.com/contracts/) or [ds-test](https://github.com/dapphub/ds-test).

`out`: Where your compiled code goes. Similar to the `build` folder in `brownie` or the `artifacts` folder in `hardhat`.

`src`: This is where your smart contracts are. Similar to the `contracts` folder in `brownie` and `hardhat`.

## **Run Tests**

To run tests, you’ll just need to run:

```
dapp test
```

and you’ll see an output like:

```
Running 2 tests for src/DapptoolsDemo.t.sol:DapptoolsDemoTest
[PASS] test_basic_sanity() (gas: 190)
[PASS] testFail_basic_sanity() (gas: 2355)
```

## Fuzzing

Dapptools comes built-in with an emphasis on [fuzzing](https://en.wikipedia.org/wiki/Fuzzing). An incredibly powerful tool for testing our contracts with random data.

Let’s update our `DapptoolsDemo.sol` with a function called `play`. Here is what our new file should look like:

```
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

And we will add a new test in our `DappToolsDemo.t.sol` that is fuzzing compatible called `test_basic_fuzzing`. The file will then look like this:

```
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

We can now give our contract random data, and we will expect it to error out if our code gives it the number `55`. Let’s run our tests now with the fuzzing flag:

```
dapp test — fuzz-runs 1000
```

And we will see an output like:

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

And our fuzzing tests picked up the outlier! I ran `1000` different trails for our `test_basic_fuzzing` test and found the 55 outlier. This is *incredibly* important for finding those random use cases that break your contracts that you might not have thought of.

## **Importing from Openzeppelin and external contracts**

Let’s say we want to create an NFT using the Openzeppelin standard. To install external contracts or packages, we can use the `dapp install`command. We need to name the GitHub repo organization and the repo name to install.

First, we need to commit our changes so far! Dapptools brings external packages in as [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so we need to commit first.

Run:

```
git add .

git commit -m ‘initial commit’
```

Then, we can install our external packages. For example, for [OpenZeppelin,](https://github.com/OpenZeppelin/openzeppelin-contracts,) we’d use:

```
dapp install OpenZeppelin/openzeppelin-contracts
```

You should see a new folder in your `lib` folder now labeled `openzeppelin-contracts`.

## **The NFT Contract**

Create a new file in the `src` folder called `NFT.sol`. And add this code:

```
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

If you try to `dapp build` now, you’ll get a big error!

## **Remappings**

We need to tell dapptools that `import “@openzeppelin/contracts/token/ERC721/ERC721.sol”;` is pointing to our `lib` folder. So we make a file called `remappings.txt` and add:

```
@openzeppelin/=lib/openzeppelin-contracts/
ds-test/=lib/ds-test/src/
```

Then, we make a file called `.dapprc` and add the following line:

```
export DAPP_REMAPPINGS=$(cat remappings.txt)
```

Dapptools looks into our `.dapprc` for different configurtion variables, sort of like `hardhat.config.js` in hardhat. In this configuration file, we tell it to read the output of `remappings.txt` and use those as “remappings”. Remappings are how we tell our imports in solidity where we should import the files from. For example in our `remapping.txt` we see:

```
@openzeppelin/=lib/openzeppelin-contracts/
```

This means we are telling dapptools that when it compiles a file, and it sees `@openzeppelin/` in an import statement, it should look for files in `lib/openzeppelin-contracts/`. So if we do

```
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
```

We are really saying:

```
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
```

Then, so that we don’t compile the whole library, we need to add the following to our `.dapprc` file:

```
export DAPP_LINK_TEST_LIBRARIES=0
```

This tells dapptools to not compile everything in `lib` when we run tests.

# **Deploying to a testnet (or mainnet if you want…)**

\> Note: If you want to setup your own local network, you can run `dapp testnet`.

## Add `.env` to your `.gitignore` file.

If you don’t have one already, create a `.gitignore` file, and just append this line inside it:

```
.env
```

Please do this. We won’t be pushing your private key to git at all with this walkthrough (yay!), but we want to get into the habit of adding that to our `.gitignore` always! This will help protect you from accidentally sending environment variables up to a public git repo. You can still force them up though, so be careful!

## Set an `ETH_RPC_URL` environment variable

To deploy to a testnet, we need a blockchain node. A fantastic choice is the [Alchemy](https://alchemy.com/?a=673c802981) project. You can get a free testnet HTTP endpoint. Just sign up for a free project, and hit `view key` (or whatever the text is at the time) and you’ll have an HTTP endpoint!

You can choose your testnet of choice, and you’ll want to get good at working with different testnets. I’d pick one from the [Chainlink Faucets](https://faucets.chain.link/) where you can get both testnet LINK and ETH. Kovan or Rinkeby are going to be great choices, so either one works.

If you don’t already, create a `.env` file, then, add your endpoint to your `.env` file. It’ll look something like:

```
export ETH_RPC_URL=http://alchemy.io/adfsasdfasdf
```

## Create a default sender

Get an [eth wallet](https://metamask.io/) if you haven’t already. You can see more in-depth [instructions for setting up a metamask here](https://docs.chain.link/docs/deploy-your-first-contract/#install-and-fund-your-metamask-wallet). But ideally, you get a metamask, and then get some testnet ETH from the [Chainlink Faucets](https://faucets.chain.link/). Then switch to the testnet you’re working with. Your metamask should look something like:

![Dapptools tutorial | Metamask](https://img.learnblockchain.cn/attachments/2022/08/TVsc1rUQ62eb9749210a4.png)

[Metamask](https://metamask.io/) 

Once you have a wallet, set the address of that wallet as a `ETH_FROM` environment variable.

```
export ETH_FROM=YOUR_ETH_WALLET_ADDRESS
```

Additionally, if using Kovan, [fund your wallet with testnet ETH](https://faucets.chain.link/).

## Add your private key

**> NOTE: I HIGHLY RECOMMEND USING A METAMASK THAT DOESNT HAVE ANY REAL MONEY IN IT FOR DEVELOPMENT.**

**> If you push your private key to a public repo with real money in it, people can steal your funds.**

So if you just made your metamask, and are only working with testnet funds, you’re safe. 😃

Dapptools comes with a tool called `ethsign`, and this is where we are going to store and encrypt our key. To add our private key (needed to send transactions) get the private key of your wallet, and run:

```
ethsign import
```

Then it’ll prompt you to add your private key, and then a password to encrypt it. This encrypts your private key in `ethsign`. You’ll need your password anytime you want to send a transaction moving forward. If you run the command `ethsign ls` and you get a response like:

```
0x3DF02ac6fEe39B79654AA81C6573732439e73A81 keystore
```

You did it right.

## Update your Makefile

The command we can use to deploy our contracts is `dapp create DapptoolsDemo` and then some flags to add in environment variables. To make our lives easier, we can add our deploy command to a Makefile, and just tell the Makefile to use our environment variables.

Add the following to our `Makefile`

```
-include .env
```

5. Deploy the contract!

In our `Makefile`, we have a command called `deploy`, this will run `dapp create DapptoolsDemo` and include our environment variables. To run it, just run:

```
make deploy
```

And you’ll be prompted for your password. Once successful, it’ll deploy your contract!

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

And you should be able to see that final address given on [Etherscan](https://kovan.etherscan.io/address/0xC5a62934B912c3B1948Ab0f309e31a9b8Ed08dd1).

## **Interacting with Contracts**

To interact with deployed contracts, we can use `seth call` and `seth send`. They are slightly different:

- `seth call` : Will only read data from the blockchain. It won’t “spend” any [gas](https://www.sofi.com/learn/content/what-is-ethereum-gas/).
- `seth send` : This will send a transaction to the blockchain, potentially modify the blockchain’s state, and spend gas.

To **read** data from the blockchain, we could do something like:

```
ETH_RPC_URL=<YOUR_RPC_URL> seth call <YOUR_DEPLOYED_CONTRACT> 
"FUNCTION_NAME()" <ARGUMENTS_SEPARATED_BY_SPACE>
```

Like:

```
ETH_RPC_URL=<YOUR_RPC_URL> seth call 0x12345 "play(uint8)" 55
```

To which you’ll get `0x0000000000000000000000000000000000000000000000000000000000000000`whih means false, since that response equals 0, and on a `bool`, 0 means false.

To **write** data to the blockchain, we could do something like:

```
ETH_RPC_URL=<YOUR_RPC_URL> ETH_FROM=<YOUR_FROM_ADDRESS> seth send 
<YOUR_DEPLOYED_CONTRACT> "FUNCTION_NAME()" 
<ARGUMENTS_SEPARATED_BY_SPACE>
```

We didn’t deploy a contract that has a great example to do this with, but let’s say the `play` function *was* able to modify the blockchain state, that would look like:

```
ETH_RPC_URL=<YOUR_RPC_URL> ETH_FROM=<YOUR_FROM_ADDRESS> seth send 
0x12345 "play(uint8)" 55
```

## **Verify your contract on Etherscan**

After you’ve deployed a contract to etherscan, you can verify it by:

1. Getting an [Etherscan API Key](https://etherscan.io/apis).

2. Then running

```
ETHERSCAN_API_KEY=<api-key> dapp verify-contract 
<contract_directory>/<contract>:<contract_name> <contract_address>
```

For example:

```
ETHERSCAN_API_KEY=123456765 dapp verify-contract ./src/DapptoolsDemo.sol:DapptoolsDemo 0x23456534212536435424
```

## **And finally…**

1. Add `cache` to your `.gitignore`

2. Add `update:; dapp update` to the top of your `Makefile`. This will update and download the files in `.gitmodules` and `lib` when you run `make` .

3. Add a `LICENSE`. You can just copy the one from [our repo](https://github.com/PatrickAlphaC/dapptools-demo) if you don’t know how!

And you’re done!

# **Resources**

If you liked this, consider donating!

💸 ETH Wallet address: 0x9680201d9c93d65a3603d2088d125e955c73BD65

- [Dapptools](https://dapp.tools/)
- [Hevm Docs](https://github.com/dapphub/dapptools/blob/master/src/hevm/README.md)
- [Dapp Docs](https://github.com/dapphub/dapptools/tree/master/src/dapp/README.md)
- [Seth Docs](https://github.com/dapphub/dapptools/tree/master/src/seth/README.md)