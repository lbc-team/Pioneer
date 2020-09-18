
# [OpenZeppelin Buidler Upgrades: Step by Step Tutorial](/t/openzeppelin-buidler-upgrades-step-by-step-tutorial/3580)

![](https://img.learnblockchain.cn/2020/09/18/16003907105882.jpg)

## OpenZeppelin Buidler Upgrades

Smart contracts deployed with the OpenZeppelin Upgrades plugins can be upgraded to modify their code, while preserving their address, state, and balance. This allows you to iteratively add new features to your project, or fix any bugs you may find in production.

In this guide, we will show the lifecycle using OpenZeppelin Buidler Upgrades and Gnosis Safe from creating, testing and deploying, all the way through to upgrading with Gnosis Safe:

1. Create an upgradeable contract
2. Test the contract locally
3. Deploy the contract to a public network
4. Transfer control of upgrades to a Gnosis Safe
5. Create a new version of our implementation
6. Test the upgrade locally
7. Deploy the new implementation
8. Upgrade the contract

## Setting up the Environment

We will begin by creating a new npm project:

`mkdir mycontract && cd mycontract` 

`npm init -y` 

We will install Buidler.
When running Builder select the option to “Create an empty buidler.config.js”

`npm i --save-dev @nomiclabs/buidler` 

`npx buidler` 

Install the Buidler Upgrades plugin.

`npm i --save-dev @openzeppelin/buidler-upgrades` 

We use ethers, so we also need to install.

`npm i --save-dev @nomiclabs/buidler-ethers ethers` 

We then need to configure Builder to use the `@nomiclabs/buidler-ethers` and our `@openzeppelin/buidler-upgrades`, as well as setting the compiler version to solc 0.7.0\. To do this add the plugins and set the solc version in your `buidler.config.js` file as follows.

### buidler.config.js

```
// buidler.config.js
usePlugin('@nomiclabs/buidler-ethers');
usePlugin('@openzeppelin/buidler-upgrades');
 
module.exports = {
    solc: {
        version: '0.7.0',
    },
};
```

## Create upgradeable contract

We will use our beloved Box contract from the [OpenZeppelin Learn guides 4](https://docs.openzeppelin.com/learn/developing-smart-contracts#setting-up-a-solidity-project). Create a `contracts` directory in our project root and then create `Box.sol` in the `contracts` directory with the following Solidity code.

Note, upgradeable contracts use [`initialize` functions rather than constructors 2](https://docs.openzeppelin.com/learn/upgrading-smart-contracts#initialization) to initialize state. To keep things simple we will initialize our state using the public `store` function that can be called multiple times from any account rather than a protected single use `initialize` function.

### Box.sol

```
// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
 
contract Box {
    uint256 private value;
 
    // Emitted when the stored value changes
    event ValueChanged(uint256 newValue);
 
    // Stores a new value in the contract
    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }
 
    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return value;
    }
}
```

## Test the contract locally

We should always appropriately test our contracts.
To test upgradeable contracts we should create unit tests for the implementation contract, along with creating higher level tests for testing interaction via the proxy.

We use chai `expect` in our tests, so we also need to install.

`npm i --save-dev chai` 

We will create unit tests for the implementation contract. Create a `test` directory in our project root and then create `Box.js` in the `test` directory with the following JavaScript.

### Box.js

```
// test/Box.js
// Load dependencies
const { expect } = require('chai');
 
let Box;
let box;
 
// Start test block
describe('Box', function () {
  beforeEach(async function () {
    Box = await ethers.getContractFactory("Box");
    box = await Box.deploy();
    await box.deployed();
  });
 
  // Test case
  it('retrieve returns a value previously stored', async function () {
    // Store a value
    await box.store(42);
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await box.retrieve()).toString()).to.equal('42');
  });
});
```

We can also create tests for interacting via the proxy.
Note: We don’t need to duplicate our unit tests here, this is for testing proxy interaction and testing upgrades.

Create `Box.proxy.js` in your `test` directory with the following JavaScript.

### Box.proxy.js

```
// test/Box.proxy.js
// Load dependencies
const { expect } = require('chai');
 
let Box;
let box;
 
// Start test block
describe('Box (proxy)', function () {
  beforeEach(async function () {
    Box = await ethers.getContractFactory("Box");
    box = await upgrades.deployProxy(Box, [42], {initializer: 'store'});
  });
 
  // Test case
  it('retrieve returns a value previously initialized', async function () {
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await box.retrieve()).toString()).to.equal('42');
  });
});
```

We can then run our tests.

```
$ npx buidler test
Compiling...
Downloading compiler version 0.7.0
Compiled 1 contract successfully


  Box
    ✓ retrieve returns a value previously stored (90ms)

  Box (proxy)
    ✓ retrieve returns a value previously initialized


  2 passing (1s)
```

## Deploy the contract to a public network

To deploy our Box contract we will use a script. The OpenZeppelin Buidler Upgrades plugin provides a `deployProxy` function to deploy our upgradeable contract. This deploys our implementation contract, a ProxyAdmin to be the admin for our projects proxies and the proxy, along with calling any initialization.

Create a `scripts` directory in our project root and then create the following `deploy.js` script in the `scripts` directory.

In this guide we don’t have an `initialize` function so we will initialize state using the `store` function.

### deploy.js

```
// scripts/deploy.js
const { ethers, upgrades } = require("@nomiclabs/buidler");

async function main() {
  const Box = await ethers.getContractFactory("Box");
  console.log("Deploying Box...");
  const box = await upgrades.deployProxy(Box, [42], { initializer: 'store' });
  console.log("Box deployed to:", box.address);
}

main();
```


We would normally first deploy our contract to a local test and manually interact with it. For the purposes of time we will skip ahead to deploying to a public test network.

In this guide we will deploy to Rinkeby. If you need assistance with configuration, see [Deploying to a live network 2](https://buidler.dev/tutorial/deploying-to-a-live-network.html). Note: any secrets such as mnemonics or Infura project IDs should not be committed to version control.

We will use the following `buidler.config.js` for deploying to Rinkeby.

### buidler.config.js

```
// buidler.config.js
usePlugin('@nomiclabs/buidler-ethers');
usePlugin('@openzeppelin/buidler-upgrades');

const { projectId, mnemonic } = require('./secrets.json');

module.exports = {
    networks: {
        rinkeby: {
          url: `https://rinkeby.infura.io/v3/${projectId}`,
          accounts: {mnemonic: mnemonic}
        }
    },
    solc: {
        version: '0.7.0',
    },
};
```

Run our `deploy.js` with the Rinkeby network to deploy. Our implementation contract (Box.sol), a ProxyAdmin and the proxy will be deployed.

Note: We need to keep track of our proxy address, we will need it later.

```
$ npx buidler run scripts/deploy.js  --network rinkeby
All contracts have already been compiled, skipping compilation.
Deploying Box...
Box deployed to: 0x120b4Cf16FFDF2CEB842D045930C01b80514C555
```

We can interact with our contract using the Buidler console.
Note: `Box.attach(“PROXY ADDRESS”)` takes the address of our proxy contract.

```
$ npx buidler console --network rinkeby
All contracts have already been compiled, skipping compilation.
> const Box = await ethers.getContractFactory("Box")
> const box = await Box.attach("0x120b4Cf16FFDF2CEB842D045930C01b80514C555")
> (await box.retrieve()).toString()
'42'
```

## Transfer control of upgrades to a Gnosis Safe

We will use Gnosis Safe to control upgrades of our contract.

First we need to create a Gnosis Safe for ourselves on Rinkeby network. Follow the [Create a Safe Multisig 2](https://help.gnosis-safe.io/en/articles/3876461-create-a-safe-multisig) instructions. For simplicity in this guide we will use a 1 of 1, in production you should consider using at least 2 of 3.

Once you have created your Gnosis Safe on Rinkeby, copy the address so we can transfer ownership.

![](https://img.learnblockchain.cn/2020/09/18/16003924796255.jpg)

The admin (who can perform upgrades) for our proxy is a ProxyAdmin contract. Only the owner of the ProxyAdmin can upgrade our proxy. Warning: Ensure to only transfer ownership of the ProxyAdmin to an address we control.

Create `transfer_ownership.js` in the `scripts` directory with the following JavaScript. Change the value of `gnosisSafe` to your Gnosis Safe address.

### transfer_ownership.js

```
// scripts/transfer_ownership.js
const { upgrades } = require("@nomiclabs/buidler");
 
async function main() {
  const gnosisSafe = '0x1c14600daeca8852BA559CC8EdB1C383B8825906';
 
  console.log("Transferring ownership of ProxyAdmin...");
  // The owner of the ProxyAdmin can upgrade our contracts
  await upgrades.admin.transferProxyAdminOwnership(gnosisSafe);
  console.log("Transferred ownership of ProxyAdmin to:", gnosisSafe);
}
 
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```

We can run the transfer on the Rinkeby network.

```
$ npx buidler run scripts/transfer_ownership.js  --network rinkeby
All contracts have already been compiled, skipping compilation.
Transferring ownership of ProxyAdmin...
Transferred ownership of ProxyAdmin to: 0x1c14600daeca8852BA559CC8EdB1C383B8825906
``` 

## Create a new version of our implementation

After a period of time, we decide that we want to add functionality to our contract. In this guide we will add an `increment` function.

Note: We cannot change the storage layout of our implementation contract, see [Upgrading](https://docs.openzeppelin.com/learn/upgrading-smart-contracts#upgrading) for more details on the technical limitations.

Create the new implementation, `BoxV2.sol` in your `contracts` directory with the following Solidity code.

### BoxV2.sol

```
// contracts/BoxV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
 
contract BoxV2 {
    uint256 private value;
 
    // Emitted when the stored value changes
    event ValueChanged(uint256 newValue);
 
    // Stores a new value in the contract
    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }
    
    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return value;
    }
    
    // Increments the stored value by 1
    function increment() public {
        value = value + 1;
        emit ValueChanged(value);
    }
}
```

## Test the upgrade locally

To test our upgrade we should create unit tests for the new implementation contract, along with creating higher level tests for testing interaction via the proxy, checking that state is maintained across upgrades…

We will create unit tests for the new implementation contract. We can add to the unit tests we already created to ensure high coverage.
Create `BoxV2.js` in your `test` directory with the following JavaScript.

### BoxV2.js

```
// test/BoxV2.js
// Load dependencies
const { expect } = require('chai');
 
let BoxV2;
let boxV2;
 
// Start test block
describe('BoxV2', function () {
  beforeEach(async function () {
    BoxV2 = await ethers.getContractFactory("BoxV2");
    boxV2 = await BoxV2.deploy();
    await boxV2.deployed();
  });
 
  // Test case
  it('retrieve returns a value previously stored', async function () {
    // Store a value
    await boxV2.store(42);
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await boxV2.retrieve()).toString()).to.equal('42');
  });
 
  // Test case
  it('retrieve returns a value previously incremented', async function () {
    // Increment
    await boxV2.increment();
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await boxV2.retrieve()).toString()).to.equal('1');
  });
});
```

We can also create tests for interacting via the proxy after upgrading.
Note: We don’t need to duplicate our unit tests here, this is for testing proxy interaction and testing state after upgrades.

Create `BoxV2.proxy.js` in your `test` directory with the following JavaScript.

### BoxV2.proxy.js

```
// test/BoxV2.proxy.js
// Load dependencies
const { expect } = require('chai');
 
let Box;
let BoxV2;
let box;
let boxV2;
 
// Start test block
describe('BoxV2 (proxy)', function () {
  beforeEach(async function () {
    Box = await ethers.getContractFactory("Box");
    BoxV2 = await ethers.getContractFactory("BoxV2");
 
    box = await upgrades.deployProxy(Box, [42], {initializer: 'store'});
    boxV2 = await upgrades.upgradeProxy(box.address, BoxV2);
  });
 
  // Test case
  it('retrieve returns a value previously incremented', async function () {
    // Increment
    await boxV2.increment();
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await boxV2.retrieve()).toString()).to.equal('43');
  });
});
```

We can then run our tests.

```
$ npx buidler test
Compiling...
Compiled 2 contracts successfully


  Box
    ✓ retrieve returns a value previously stored (48ms)

  Box (proxy)
    ✓ retrieve returns a value previously initialized

  BoxV2
    ✓ retrieve returns a value previously stored
    ✓ retrieve returns a value previously incremented

  BoxV2 (proxy)
    ✓ retrieve returns a value previously incremented


  5 passing (2s)
```

## Deploy the new implementation

Once we have tested our new implementation, we can prepare the upgrade. This will validate and deploy our new implementation contract. Note: We are only preparing the upgrade. We will use our Gnosis Safe to perform the actual upgrade.

Create `prepare_upgrade.js` in the `scripts` directory with the following JavaScript.
Note: We need to update the script to specify our proxy address.

### prepare_upgrade.js

```
// scripts/prepare_upgrade.js
const { ethers, upgrades } = require("@nomiclabs/buidler");
 
async function main() {
  const proxyAddress = '0x120b4Cf16FFDF2CEB842D045930C01b80514C555';
 
  const BoxV2 = await ethers.getContractFactory("BoxV2");
  console.log("Preparing upgrade...");
  const boxV2Address = await upgrades.prepareUpgrade(proxyAddress, BoxV2);
  console.log("BoxV2 at:", boxV2Address);
}
 
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```

We can run the migration on the Rinkeby network to deploy the new implementation.

```
$ npx buidler run scripts/prepare_upgrade.js  --network rinkeby
All contracts have already been compiled, skipping compilation.
Preparing upgrade...
BoxV2 at: 0xfDf2E8257d5E3667Cb744348362AeE1ECFF24125
```

## Upgrade the contract

To manage our upgrade in Gnosis Safe we use the OpenZeppelin app (look for the OpenZeppelin logo).

First, we need the address of the proxy and the address of the new implementation. We can get these from the output of when we ran our `deploy.js` and `prepare_upgrade.js` scripts.

In the Apps tab, select the OpenZeppelin application and paste the address of the proxy in the Contract address field, and paste the address of the new implementation in the New implementation address field.

The app should show that the contract is EIP1967-compatible.

![](https://img.learnblockchain.cn/2020/09/18/16003928508973.jpg)


Double check the addresses, and then press the Upgrade button.
We will be shown a confirmation dialog to Submit the transaction.

![](https://img.learnblockchain.cn/2020/09/18/16003929040402.jpg)

We then need to sign the transaction in MetaMask (or the wallet that you are using).

We can now interact with our upgraded contract. We need to interact with BoxV2 using the address of the proxy. Note: `BoxV2.attach(“PROXY ADDRESS”)` takes the address of our proxy contract.

We can then call our new `increment` function, observing that state has been maintained across the upgrade.

```
$ npx buidler console --network rinkeby
All contracts have already been compiled, skipping compilation.
> const BoxV2 = await ethers.getContractFactory("BoxV2")
> const boxV2 = await BoxV2.attach("0x120b4Cf16FFDF2CEB842D045930C01b80514C555")
> (await boxV2.retrieve()).toString()
'42'
> await boxV2.increment()
{ hash:
   '0xc7766249e9084bbb742fcb2b9941995c45ea39acd5ae1dcfd2a36024e72c3ab3',
...
> (await boxV2.retrieve()).toString()
'43'
```

## Next Steps

We have created an upgradeable contract, transferred control of the upgrade to a Gnosis Safe and upgraded our contract. The same process can be performed on mainnet. Note: we should always test the upgrade on a public testnet first.

If you have any questions or suggested improvements for this guide please post in the [Community Forum](https://forum.openzeppelin.com/).

原文链接：https://forum.openzeppelin.com/t/openzeppelin-buidler-upgrades-step-by-step-tutorial/3580
作者：[abcoathup](https://forum.openzeppelin.com/u/abcoathup)
