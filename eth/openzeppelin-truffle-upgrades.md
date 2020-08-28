# OpenZeppelin Truffle Upgrades





![cover_upgrades_plugins](https://img.learnblockchain.cn/pics/20200828092322.png)

Smart contracts deployed with the OpenZeppelin Upgrades plugins can be upgraded to modify their code, while preserving their address, state, and balance. This allows you to iteratively add new features to your project, or fix any bugs you may find in production.

In this guide, we will show the lifecycle using OpenZeppelin Truffle Upgrades and Gnosis Safe from creating, testing and deploying, all the way through to upgrading with Gnosis Safe:

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

```bash
mkdir mycontract && cd mycontract
npm init -y
```

Install and initialize Truffle. Note: We need to use Truffle version 5.1.35 or greater.

```bash
npm i --save-dev truffle
npx truffle init
```

Install the Truffle Upgrades plugin.

```bash
npm i --save-dev @openzeppelin/truffle-upgrades
```

## Create upgradeable contract

We will use our beloved Box contract from the [OpenZeppelin Learn guides 3](https://docs.openzeppelin.com/learn/developing-smart-contracts#setting-up-a-solidity-project). Create `Box.sol` in your `contracts` directory with the following Solidity code.

Note, upgradeable contracts use [`initialize` functions rather than constructors 2](https://docs.openzeppelin.com/learn/upgrading-smart-contracts#initialization) to initialize state. To keep things simple we will initialize our state using the public `store` function that can be called multiple times from any account rather than a protected single use `initialize` function.

### Box.sol

```js
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

We will use chai expect in our tests, so first we need to install.

```bash
npm i --save-dev chai
```

We will create unit tests for the implementation contract. Create `Box.test.js` in your `test` directory with the following JavaScript.

### Box.test.js

```js
// test/Box.test.js
// Load dependencies
const { expect } = require('chai');
 
// Load compiled artifacts
const Box = artifacts.require('Box');
 
// Start test block
contract('Box', function () {
  beforeEach(async function () {
    // Deploy a new Box contract for each test
    this.box = await Box.new();
  });
 
  // Test case
  it('retrieve returns a value previously stored', async function () {
    // Store a value
    await this.box.store(42);
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.box.retrieve()).toString()).to.equal('42');
  });
});
```

We can also create tests for interacting via the proxy.
Note: We don’t need to duplicate our unit tests here, this is for testing proxy interaction and testing upgrades.

Create `Box.proxy.test.js` in your `test` directory with the following JavaScript.

### Box.proxy.test.js

```js
// test/Box.proxy.test.js
// Load dependencies
const { expect } = require('chai');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
// Load compiled artifacts
const Box = artifacts.require('Box');
 
// Start test block
contract('Box (proxy)', function () {
  beforeEach(async function () {
    // Deploy a new Box contract for each test
    this.box = await deployProxy(Box, [42], {initializer: 'store'});
  });
 
  // Test case
  it('retrieve returns a value previously initialized', async function () {
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.box.retrieve()).toString()).to.equal('42');
  });
});
```

Before we can compile our contract, we will need to change the solc version to `^0.7.0` in `truffle-config.js` as our contract has `pragma solidity ^0.7.0`

We can then run out tests.

```bash
$ npx truffle test
...
  Contract: Box (proxy)
    ✓ retrieve returns a value previously initialized (43ms)

  Contract: Box
    ✓ retrieve returns a value previously stored (100ms)


  2 passing (3s)
```

## Deploy the contract to a public network

To deploy our Box contract we will use Truffle migrations. The Truffle Upgrades plugin provides a `deployProxy` function to deploy our upgradeable contract. This deploys our implementation contract, a ProxyAdmin to be the admin for our projects proxies and the proxy, along with calling any initialization.

Create the following `2_deploy_box.js` script in the migrations directory.

In this guide we don’t have an `initialize` function so we will initialize state using the `store` function.

### 2_deploy_box.js

```js
// migrations/2_deploy_box.js
const Box = artifacts.require('Box');
 
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  await deployProxy(Box, [42], { deployer, initializer: 'store' });
};
```

We would normally first deploy our contract to a local test (such as `ganache-cli`) and manually interact with it. For the purposes of time we will skip ahead to deploying to a public test network.

In this guide we will deploy to Rinkeby. If you need assistance with configuration, see [Connecting to Public Test Networks with Truffle](https://forum.openzeppelin.com/t/connecting-to-public-test-networks-with-truffle/2960). Note: any secrets such as mnemonics or Infura project IDs should not be committed to version control.

Run `truffle migrate` with the Rinkeby network to deploy. We can see our implementation contract (Box.sol), a ProxyAdmin and the proxy being deployed.

```bash
$ npx truffle migrate --network rinkeby
...
2_deploy_box.js
===============

   Deploying 'Box'
   ---------------
   > transaction hash:    0x3263d01ce2e3eb4ba51abf882abbdd9252364b51eb972f82958719d60a8b9ebe
   > Blocks: 0            Seconds: 5
   > contract address:    0xd568071213Ea31B01AA2247BC9eC7285087cf882
...
   Deploying 'ProxyAdmin'
   ----------------------
   > transaction hash:    0xf39e8cb97c332b8bbdf0c66b13f26a9a3dc97b207d2caec73ba6df8d5bb6b211
   > Blocks: 1            Seconds: 17
   > contract address:    0x2A210B6d5EffC0A3BB47dD3791a4C26B8E31f161
...
   Deploying 'AdminUpgradeabilityProxy'
   ------------------------------------
   > transaction hash:    0x439711597b694f03b1065582ab44ac0bea5e22b0c6e3c460ae7b4536f004c355
   > Blocks: 1            Seconds: 17
   > contract address:    0xF325bB49f91445F97241Ec5C286f90215a7E3BC6
...
```

We can interact with our contract using the Truffle console.
Note: `Box.deployed()` is the address of our proxy contract.

```bash
$ npx truffle console --network rinkeby
truffle(rinkeby)> box = await Box.deployed()
truffle(rinkeby)> box.address
'0xF325bB49f91445F97241Ec5C286f90215a7E3BC6'
truffle(rinkeby)> (await box.retrieve()).toString()
'42'
```

## Transfer control of upgrades to a Gnosis Safe

We will use Gnosis Safe to control upgrades of our contract.

First we need to create a Gnosis Safe for ourselves on Rinkeby network. Follow the [Create a Safe Multisig 1](https://help.gnosis-safe.io/en/articles/3876461-create-a-safe-multisig) instructions. For simplicity in this guide we will use a 1 of 1, in production you should consider using at least 2 of 3.

Once you have created your Gnosis Safe on Rinkeby, copy the address so we can transfer ownership.

![img](https://aws1.discourse-cdn.com/business6/uploads/zeppelin/optimized/2X/2/23763f1048e208d13044914126dd0a948f477f26_2_624x165.png)



The admin (who can perform upgrades) for our proxy is a ProxyAdmin contract. Only the owner of the ProxyAdmin can upgrade our proxy. Warning: Ensure to only transfer ownership of the ProxyAdmin to an address we control.

Create `3_transfer_ownership.js` in the `migrations` directory with the following JavaScript. Change the value of `gnosisSafe` to your Gnosis Safe address.

### 3_transfer_ownership.js

```js
// migrations/3_transfer_ownership.js
const { admin } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer, network) {
  // Use address of your Gnosis Safe
  const gnosisSafe = '0x1c14600daeca8852BA559CC8EdB1C383B8825906';
 
  // Don't change ProxyAdmin ownership for our test network
  if (network !== 'test') {
    // The owner of the ProxyAdmin can upgrade our contracts
    await admin.transferProxyAdminOwnership(gnosisSafe);
  }
};
```

We can run the migration on the Rinkeby network.

```bash
$ npx truffle migrate --network rinkeby
...
3_transfer_ownership.js
=======================

   > Saving migration to chain.
   -------------------------------------
...
```

## Create a new version of our implementation

After a period of time, we decide that we want to add functionality to our contract. In this guide we will add an `increment` function.

Note: We cannot change the storage layout of our implementation contract, see [Upgrading 1](https://docs.openzeppelin.com/learn/upgrading-smart-contracts#upgrading) for more details on the technical limitations.

Create the new implementation, `BoxV2.sol` in your `contracts` directory with the following Solidity code.

### BoxV2.sol

```js
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

To test our upgrade we should create unit tests for the new implementation contract, along with creating higher level tests for testing interaction via the proxy, checking that state is maintained across upgrades.

We will create unit tests for the new implementation contract. We can add to the unit tests we already created to ensure high coverage.
Create `BoxV2.test.js` in your `test` directory with the following JavaScript.

### BoxV2.test.js

```js
// test/BoxV2.test.js
// Load dependencies
const { expect } = require('chai');
 
// Load compiled artifacts
const BoxV2 = artifacts.require('BoxV2');
 
// Start test block
contract('BoxV2', function () {
  beforeEach(async function () {
    // Deploy a new BoxV2 contract for each test
    this.boxV2 = await BoxV2.new();
  });
 
  // Test case
  it('retrieve returns a value previously stored', async function () {
    // Store a value
    await this.boxV2.store(42);
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.boxV2.retrieve()).toString()).to.equal('42');
  });
 
  // Test case
  it('retrieve returns a value previously incremented', async function () {
    // Increment
    await this.boxV2.increment();
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.boxV2.retrieve()).toString()).to.equal('1');
  });
});
```

We can also create tests for interacting via the proxy after upgrading.
Note: We don’t need to duplicate our unit tests here, this is for testing proxy interaction and testing state after upgrades.

Create `BoxV2.proxy.test.js` in your `test` directory with the following JavaScript.

### BoxV2.proxy.test.js

```js
// test/Box.proxy.test.js
// Load dependencies
const { expect } = require('chai');
const { deployProxy, upgradeProxy} = require('@openzeppelin/truffle-upgrades');
 
// Load compiled artifacts
const Box = artifacts.require('Box');
const BoxV2 = artifacts.require('BoxV2');
 
// Start test block
contract('BoxV2 (proxy)', function () {
 
  beforeEach(async function () {
    // Deploy a new Box contract for each test
    this.box = await deployProxy(Box, [42], {initializer: 'store'});
    this.boxV2 = await upgradeProxy(this.box.address, BoxV2);
  });
 
  // Test case
  it('retrieve returns a value previously incremented', async function () {
    // Increment
    await this.boxV2.increment();
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.boxV2.retrieve()).toString()).to.equal('43');
  });
});
```

We can then run our tests.

```bash
$ npx truffle test
Using network 'test'.
...
  Contract: Box (proxy)
    ✓ retrieve returns a value previously initialized (38ms)

  Contract: Box
    ✓ retrieve returns a value previously stored (87ms)

  Contract: BoxV2 (proxy)
    ✓ retrieve returns a value previously incremented (90ms)

  Contract: BoxV2
    ✓ retrieve returns a value previously stored (91ms)
    ✓ retrieve returns a value previously incremented (86ms)


  5 passing (1s)
```

## Deploy the new implementation

Once we have tested our new implementation, we can prepare the upgrade. This will validate and deploy our new implementation contract. Note: We are only preparing the upgrade. We will use our Gnosis Safe to perform the actual upgrade.

Create `4_prepare_upgrade_boxv2.js` in the `migrations` directory with the following JavaScript.

### 4_prepare_upgrade_boxv2.js

```js
// migrations/4_prepare_upgrade_boxv2.js
const Box = artifacts.require('Box');
const BoxV2 = artifacts.require('BoxV2');
 
const { prepareUpgrade } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  const box = await Box.deployed();
  await prepareUpgrade(box.address, BoxV2, { deployer });
};
```

We can run the migration on the Rinkeby network to deploy the new implementation. Note: We need to skip dry run when running this migration.

```bash
$ npx truffle migrate --network rinkeby
...
4_prepare_upgrade_boxv2.js
==========================

   Deploying 'BoxV2'
   -----------------
   > transaction hash:    0x078c4c4454bb15e3791bc80396975e6e8fc8efb76c6f54c321cdaa01f5b960a7
   > Blocks: 1            Seconds: 17
   > contract address:    0xEc784bE1CC7F5deA6976f61f578b328E856FB72c
...
```

## Upgrade the contract

To manage our upgrade in Gnosis Safe we use the OpenZeppelin app (look for the OpenZeppelin logo).

First, we need the address of the proxy (`box.address`) and the address of the new implementation (`boxV2.address`). We can get these from the output of truffle migrate or from the truffle console.

```bash
$ npx truffle console --network rinkeby
truffle(rinkeby)> box = await Box.deployed()
truffle(rinkeby)> boxV2 = await BoxV2.deployed()
truffle(rinkeby)> box.address
'0xF325bB49f91445F97241Ec5C286f90215a7E3BC6'
truffle(rinkeby)> boxV2.address
'0xEc784bE1CC7F5deA6976f61f578b328E856FB72c'
```

In the Apps tab, select the OpenZeppelin application and paste the address of the proxy in the Contract address field, and paste the address of the new implementation in the New implementation address field.

The app should show that the contract is EIP1967-compatible.



[![|624x344.30702389572775](https://aws1.discourse-cdn.com/business6/uploads/zeppelin/optimized/2X/4/436461bf273bee6b3e03f74abecb5c8c20c32ca8_2_690x380.png)|624x344.307023895727751381×762 64.7 KB](https://aws1.discourse-cdn.com/business6/uploads/zeppelin/original/2X/4/436461bf273bee6b3e03f74abecb5c8c20c32ca8.png)



Double check the addresses, and then press the Upgrade button.
We will be shown a confirmation dialog to Submit the transaction.



![|634.6614785992219x449](https://aws1.discourse-cdn.com/business6/uploads/zeppelin/optimized/2X/5/53c293e642ea8061d81e2f233ec27a1a395cd9e8_2_690x488.png)



We then need to sign the transaction in MetaMask (or the wallet that you are using).

We can now interact with our upgraded contract. We need to interact with BoxV2 using the address of the proxy. We can then call our new `increment` function, observing that state has been maintained across the upgrade.

```bash
$ npx truffle console --network rinkeby
truffle(rinkeby)> box = await Box.deployed()
truffle(rinkeby)> boxV2 = await BoxV2.at(box.address)
truffle(rinkeby)> (await boxV2.retrieve()).toString()
'42'
truffle(rinkeby)> await boxV2.increment()
{ tx:
...
truffle(rinkeby)> (await boxV2.retrieve()).toString()
'43'
```

## Next Steps

We have created an upgradeable contract, transferred control of the upgrade to a Gnosis Safe and upgraded our contract.

The same process can be performed on mainnet. Note: we should always test the upgrade on a public testnet first.

If you have any questions or suggested improvements for this guide please post in the [Community Forum](https://forum.openzeppelin.com/).



source：https://forum.openzeppelin.com/t/openzeppelin-truffle-upgrades/3579
author：**[abcoathup](https://forum.openzeppelin.com/u/abcoathup)**