> * 原文链接:https://soliditydeveloper.com/erc20-permit
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[]()
> * 本文永久链接：[learnblockchain.cn/article…]()


# A Long Way To Go: On Gasless Tokens and ERC20-Permit

## And how to avoid the two step approve + transferFrom with ERC20-Permit (EIP-2612)!


![](https://img.learnblockchain.cn/2020/10/26/16036950187816.jpg)


**It's April 2019 in Sydney.** Here I am looking for the Edcon Hackathon inside the massive Sydney university complex. It feels like a little city within a city. Of course, I am at the wrong end of the complex and I realize to get to the venue hosting the Hackathon I need to walk  30 minutes to the other side. At the venue I register just a few minutes before the official start!

With all participants living and breathing crypto, a system was setup which allowed payments with DAI in one of the cafeterias. This is particularly useful, because there is also a promotion running by [AlphaWallet](https://alphawallet.com/) giving away 20 promotional DAI to Hackathon participants (and later on [discounted drinks](https://twitter.com/Victor928/status/1114650025240350720)). With my wallet already downloaded and 20 DAI, it's the perfect time to find the cafeteria...

Not so easy as it turns out. Firstly, it's a 15 minute walk back to the center of the university city. I finally find it. I choose my lunch and I'm happy to try this new payment system. I've paid with Bitcoin in restaurants before back in 2012, but this would be my first time using ERC-20\. I scan the QR-code, enter the amount in DAI to pay and...

*'Not enough gas available to cover the transaction fees.'*

**Yikes**! All the excitement gone. Of course you need ETH to pay for the gas! And my new wallet had 0 ETH. I'm a Solidity developer, I know this. Yet it happened even to me.  My computer with ETH on it was all the way back at the venue, so there was no solution for me. Without lunch in my hands taking the long walk back to the venue, I thought to myself; we have a long way to go for this technology to become more mainstream.


## Fast forward to EIP-2612


Since then, DAI and Uniswap have lead the way towards a new standard named [EIP-2612](https://eips.ethereum.org/EIPS/eip-2612) which can get rid of the approve + transferFrom, while also allowing gasless token transfers. DAI was the first to add a new `permit` function to its ERC-20 token. It allows a user to sign an approve transaction off-chain producing a signature that anyone could use and submit to the blockchain. It's a fundamental first step towards solving the gas payment issue and also removes the user-unfriendly 2-step process of sending `approve` and later `transferFrom`.

Let's examine the EIP in detail.

![](https://img.learnblockchain.cn/2020/10/26/16036950485596.jpg)


## Naive Incorrect Approach


 On a high level the procedure is very simple. Instead of a user signing an approve transaction, he signs the data "approve(spender, amount)". The result can be passed by anyone to the `permit` function where we simply retrieve the signer address using `ecrecover`, followed by `approve(signer, spender, amount)`.

This construction can be used to allow someone else to pay for the gas costs and also to remove the common approve + transferFrom pattern:

**Before**:

1. User submits `token.approve(myContract.address, amount)` transaction.
2. Wait for transaction confirmation.
3. User submits second `myContract.doSomething()` transaction which internally uses `token.transferFrom`.

**After**:

1. User signs `signature = approve(myContract.address, amount)`.
2. User submits signature to `myContract.doSomething(signature)`.
3. `myContract` uses `token.permit` to increase allowance, followed by `token.transferFrom`.

We go from two transaction submissions, to only one!


## Permit in Detail: Preventing Misuse and Replays


The main issue we are facing is that a valid signature might be used several times or in other places where it's not intended to be used in. To prevent this we are adding several parameters. Under the hood we are using the already existing, widely used [EIP-712](https://eips.ethereum.org/EIPS/eip-712) standard.


### 1. EIP-712 Domain Hash


With EIP-712, we define a domain separator for our ERC-20:

```
bytes32 eip712DomainHash = keccak256(
    abi.encode(
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ),
        keccak256(bytes(name())), // ERC-20 Name
        keccak256(bytes("1")),    // Version
        chainid(),
        address(this)
    )
);
```

This ensures a signature is only used for our given token contract address on the correct chain id. The chain id was introduced to exactly identify a network after the Ethereum Classic fork which continued to use a network id of 1.  A list of existing chain ids can be seen [here](https://medium.com/@piyopiyo/list-of-ethereums-major-network-and-chain-ids-2bc58e928508).


### 2. Permit Hash Struct

Now we can create a Permit specific signature:

```
bytes32 hashStruct = keccak256(
    abi.encode(
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
        owner,
        spender,
        amount,
        nonces[owner],
        deadline
    )
);
```

This hashStruct will ensure that the signature can only used for

* the `permit` function
* to approve from `owner`
* to approve for `spender`
* to approve the given `value`
* only valid before the given `deadline`
* only valid for the given `nonce`

The nonce ensures someone can not replay a signature, i.e., use it multiple times on the same contract.

### 3. Final Hash

Now we can build the final signature starting with 0x1901 for an [EIP-191](https://eips.ethereum.org/EIPS/eip-191)-compliant 712 hash:

```
bytes32 hash = keccak256(
    abi.encodePacked(uint16(0x1901), eip712DomainHash, hashStruct)
);
```

### 4. Verifying the Signature



Using this hash we can use [ecrecover](https://solidity.readthedocs.io/en/latest/units-and-global-variables.html#mathematical-and-cryptographic-functions) to retrieve the signer of the function:


```
address signer = ecrecover(hash, v, r, s);
require(signer == owner, "ERC20Permit: invalid signature");
require(signer != address(0), "ECDSA: invalid signature");
```

Invalid signatures will produce an empty address, that's what the last check is for.

### 5. Increasing Nonce and Approving


Now lastly we only have to increase the nonce for the owner and call the approve function:

```
nonces[owner]++;
_approve(owner, spender, amount);
```

You can see a full implementation example [here](https://github.com/soliditylabs/ERC20-Permit/blob/main/contracts/ERC20Permit.sol).


## Existing ERC20-Permit Implementations


### DAI ERC20-Permit


DAI was one of the first tokens to introduce `permit` as described [here](https://docs.makerdao.com/smart-contract-modules/dai-module/dai-detailed-documentation#3-key-mechanisms-and-concepts). The implementation differs from EIP-2612 slightly

1. instead of `value`, it only takes a bool `allowed` and sets the allowance either to `0` or `MAX_UINT256`
2. the `deadline` parameter is called `expiry`


### Uniswap ERC20-Permit


The Uniswap implementation aligns with the current EIP-2612, see [here](https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol). It allows you to call [removeLiquidityWithPermit](https://uniswap.org/docs/v2/smart-contracts/router02/#removeliquiditywithpermit), removing the additional `approve` step.

If you want to get a feel for the process, go to [https://app.uniswap.org/#/pool](https://app.uniswap.org/#/pool) and change to the Kovan network. Not add liquidity to a pool. Now try to remove it. After clicking on 'Approve', you will notice this MetaMask popup as show on the right.

This will not submit a transaction, but only creates a signature with the given parameters. You can sign it and in a second step call removeLiquidityWithPermit with the previously generated signature. All in all: just one transaction submission.

![](https://img.learnblockchain.cn/2020/10/26/16036951814486.jpg)


## ERC20-Permit Library

I have created an ERC-20 Permit library that you can import. You can find it at [https://github.com/soliditylabs/ERC20-Permit](https://github.com/soliditylabs/ERC20-Permit).

Built using

* [OpenZeppelin ERC20-Permit](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237)
* [0x-inspired](https://github.com/0xProject/0x-monorepo/blob/development/contracts/utils/contracts/src/LibEIP712.sol) gas saving hashes with assembly
* [eth-permit](https://github.com/dmihal/eth-permit) frontend library for testing

You can simply use it by installing via npm:

```
$ npm install @soliditylabs/erc20-permit --save-dev
```

Import it into your ERC-20 contract like this:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import {ERC20, ERC20Permit} from "@soliditylabs/erc20-permit/contracts/ERC20Permit.sol";

contract ERC20PermitToken is ERC20Permit {
    constructor (uint256 initialSupply) ERC20("ERC20Permit-Token", "EPT") {
        _mint(msg.sender, initialSupply);
    }
}
```

### Frontend Usage

You can see [here](https://github.com/soliditylabs/ERC20-Permit/blob/6a07a436bc39d7be53e8d9c160d6c87e0305980c/test/ERC20Permit.test.js#L43-L49) in my tests how I use the `eth-permit` library to create valid signatures. It automatically fetches the correct nonce and sets the parameters according to the current standard. It also supports the DAI-style permit signature creation. Full documentation available at [https://github.com/dmihal/eth-permit](https://github.com/dmihal/eth-permit).

A word on debugging: It can be painful. Any single parameter off will result in a `revert: Invalid signature`. Good luck finding out the reason why.

At the time of this writing, there still seems to be an [open issue](https://github.com/dmihal/eth-permit/issues/2) with it which may or may not affect you depending on your Web3 provider. If it does affect you, just use my patch [here](https://github.com/soliditylabs/ERC20-Permit/blob/main/patches/eth-permit%2B0.1.7.patch) installed via [patch-package](https://www.npmjs.com/package/patch-package).


## Solution for Gasless Tokens

Now recall my Sydney experience. This standard alone wouldn't solve the problem, but it's first basic module towards it. Now you can create a Gas Station Network such as [Open GSN](https://www.opengsn.org/). Deploying contracts for it that simply transfer the tokens via permit + transferFrom. And nodes running inside the GSN will take the permit signatures and submit them.

Who pays the gas fees? That will depend on the specific use case. Maybe the Dapp company pays the fees as part of their customer acquisition cost (CAC). Maybe the GSN nodes are paid by the transferred tokens. We still have a long way to go to figure out all the details.


## As always use with care


Be aware that the standard is not yet final. It's currently identical to the Uniswap implementation, but it may or may not change in the future. I will keep the library updated in case the standard changes again. My library code was also not audited, use at your own risk.

**You have reached the end of the article. I hereby permit you to comment and ask questions.**


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。