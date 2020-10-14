

# EIP712 is here: What to expect and how to use it


Ethereum wallets like [MetaMask](https://metamask.io/) will soon introduce the [EIP712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) standard for typed message signing. This standard allows wallets to display data in signing prompts in a structured and readable format. EIP712 is a great step forward for security and usability because users will no longer need to sign off on inscrutable hexadecimal strings, which is a practice that can be confusing and insecure.

Smart contract and dApp developers should adopt this new standard as it has already been merged into the [Ethereum Improvement Proposal repository](https://github.com/ethereum/EIPs), and major wallet providers will soon support it. This blog post aims to help developers to do so. It includes a description of what it does, sample JavaScript and Solidity code, and a working demonstration.

## Before EIP712

![](https://img.learnblockchain.cn/2020/10/14/16026478352494.jpg)
<center>Figure 1: a signature request from a dApp that does not use EIP712</center>



An adage in the cryptocurrency space states: don’t trust; verify. Yet before EIP712, it was difficult for users to verify the data they were asked to sign, which made it all too easy for them to place more trust than they should in dApps that use signed messages as the basis for consequential value transfers.

Figure 1, for example, shows a MetaMask pop-up triggered by a decentralised exchange that requires users to sign a the hash of an order to securely associate it to their wallet address. Unfortunately, as this hash is a hexadecimal string, users without significant technical expertise cannot easily verify that it is *truly* the hash of their intended order. To lay users, it is far easier to blindly trust the dApp and click “Sign”, instead of going through the technical hassle of verifying it. This is bad for security.

If a user inadvertently lands on a malicious phishing dApp, it could make them sign off on incorrect order information. For instance, it could trick them into paying an unreasonably high amount of Ether for a trade which would otherwise cost less. To prevent such attacks, users must have some way of knowing exactly what they are signing, without having to go through the trouble of reconstructing a cryptographic hash all by themselves.

## EIP712 in action

![](https://img.learnblockchain.cn/2020/10/14/16026480444699.jpg)
<center>Figure 2: a signature request from a dApp that uses EIP712</center>

EIP712 offers strong improvements in usability and security. In contrast to the above example, when an EIP712-enabled dApp requests a signature, the user’s wallet shows them the pre-hashed raw data which they may then choose to sign. This makes it much easier for a user to verify it.

## How to implement EIP712

This new standard introduces several concepts which developers must be familiar with, so this section will zoom in on what you need to know to implement it in dApps.

Take for instance that you are building a decentralised auction dApp in which bidders sign bids off-chain, and a smart contract verifies these signed bids on-chain.

### 1\. Design your data structures

First of all, figure out the JSON structure of the data you intend users to sign. For the sake of this example, we use the following:

```
{
    amount: 100, 
    token: “0x….”,
    id: 15,
    bidder: {
        userId: 323,
        wallet: “0x….”
    }
}
```

We can then derive two data structures from the above snippet: `Bid`, which includes the bid `amount` denominated in an ERC20 `token` and the auction `id`, as well as `Identity`, which specifies a `userID` and `wallet` address.

Next, pen down `Bid` and `Identity` as [structs](https://solidity.readthedocs.io/en/v0.4.24/types.html#structs) you would employ in your Solidity code. Refer to the [EIP712 standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#definition-of-typed-structured-data-%F0%9D%95%8A) for a full list of native data types, such as `address`, `bytes32`, `uint256`, and so on.

```
Bid: {
    amount: uint256, 
    bidder: Identity
}
Identity: {
    userId: uint256,
    wallet: address
}
```

### 2\. Design your domain separator

The next step is to create a *domain separator*. This mandatory field helps to prevent a signature meant for one dApp from working in another. As EIP712 [explains](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale):

> It is possible that two DApps come up with an identical structure like `Transfer(address from,address to,uint256 amount)` that should not be compatible. By introducing a domain separator the dApp developers are guaranteed that there can be no signature collision.

The domain separator requires careful thought and effort at the architectural and implementation level. Developers and designers must decide which of the following fields to include or exclude based on what makes sense for their use case.

**name**: the dApp or protocol name, e.g. “CryptoKitties”

**version**: The current version of what the standard calls a “signing domain”. This can be the version number of your dApp or platform. It prevents signatures from one dApp version from working with those of others.

**chainId**: The [EIP-155](https://eips.ethereum.org/EIPS/eip-155) chain id. Prevents a signature meant for one network, such as a testnet, from working on another, such as the mainnet.

**verifyingContract**: The Ethereum address of the contract that will verify the resulting signature. The `this`keyword in Solidity returns the contract’s own address, which it can use when verifying the signature.

**salt**: A unique 32-byte value hardcoded into both the contract and the dApp meant as a last-resort means to distinguish the dApp from others.

In practice, a domain separator which uses all the above fields could look like this:

```
{
    name: "My amazing dApp",
    version: "2",
    chainId: "1",
    verifyingContract: "0x1c56346cd2a2bf3202f771f50d3d14a367b48070",
    salt: "0x43efba6b4ccb1b6faa2625fe562bdd9a23260359"
}
```

One thing to note about `chainId` is that wallet providers should prevent signing if it does not match the network it is currently connected to. As wallet providers may not necessarily enforce this, however, it is crucial that `chainId` is verified on-chain. The only caveat is that contracts have no way to find out which chain ID they are on, so developers must hardcode `chainId` into their contracts *and* take extra care to make sure that it corresponds to the network they deploy on.

Edit (31 May 2019): If [EIP-1344](https://eips.ethereum.org/EIPS/eip-1344) gets included in a future Ethereum upgrade (possibly [Istanbul](http://eips.ethereum.org/EIPS/eip-1679)), there will be a way for contracts to programmatically find out the`chainId`.

#### 2.1\. Install MetaMask version 4.14.0 or above

Before the release of version 4.14.0 of MetaMask, its EIP712 support was slightly in flux due to a rollback over the ETHSanFrancisco weekend. Moving forward, version 4.14.0 and later version should properly support EIP712 signing.

### 3\. Write signing code for your dApp

Your JavaScript dApp now needs to be able to ask MetaMask to sign your data. First, define your data types:

```
const domain = [
    { name: "name", type: "string" },
    { name: "version", type: "string" },
    { name: "chainId", type: "uint256" },
    { name: "verifyingContract", type: "address" },
    { name: "salt", type: "bytes32" },
];
const bid = [
    { name: "amount", type: "uint256" },
    { name: "bidder", type: "Identity" },
];
const identity = [
    { name: "userId", type: "uint256" },
    { name: "wallet", type: "address" },
];
```

Next, define your domain separator and message data.

```
const domainData = {
    name: "My amazing dApp",
    version: "2",
    chainId: parseInt(web3.version.network, 10),
    verifyingContract: "0x1C56346CD2A2Bf3202F771f50d3D14a367B48070",
    salt: "0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558"
};
var message = {
    amount: 100,
    bidder: {
        userId: 323,
        wallet: "0x3333333333333333333333333333333333333333"
    }
};
```

Lay out your variables as such:

```
const data = JSON.stringify({
    types: {
        EIP712Domain: domain,
        Bid: bid,
        Identity: identity,
    },
    domain: domainData,
    primaryType: "Bid",
    message: message
});
```
Next, make the `eth_signTypedData_v3` signing call to `web3`:

```
web3.currentProvider.sendAsync(
{
    method: "eth_signTypedData_v3",
    params: [signer, data],
    from: signer
},
function(err, result) {
    if (err) {
        return console.error(err);
    }
    const signature = result.result.substring(2);
    const r = "0x" + signature.substring(0, 64);
    const s = "0x" + signature.substring(64, 128);
    const v = parseInt(signature.substring(128, 130), 16);
    // The signature is now comprised of r, s, and v.
    }
);
```

Note that at the time of writing, MetaMask and Cipher Browser use `eth_signTypedData_v3` in the method field to allow backward compatibility while the dApp ecosystem adopts the standard. Future releases of these wallets are likely to rename it to just `eth_signTypedData`.

### 4\. Write authentication code for the verifying contract

Recall that before a wallet provider signs EIP712-typed data, it first formats and hashes it. As such, your contract needs to be able to do the same in order to use `ecrecover` to determine which address signed it, and you have to replicate this formatting/hash function in your Solidity contract code. This is perhaps the trickiest step in the process, so be precise and careful here.

First, declare your data types in Solidity, which you should already have done above:

```
struct Identity {
    uint256 userId;
    address wallet;
}
struct Bid {
    uint256 amount;
    Identity bidder;
}
```

Next, define the type hashes to fit your data structures. Note that there are no spaces after commas and brackets, and the names and types should exactly match those specified in the JavaScript code above.

```
string private constant IDENTITY_TYPE = "Identity(uint256 userId,address wallet)";
string private constant BID_TYPE = "Bid(uint256 amount,Identity bidder)Identity(uint256 userId,address wallet)";
```

Also define the domain separator type hash. Note that the following code with a `chainId` of 1 is meant for a contract to be deployed on the mainnet, and that strings (such as “My amazing dApp”) must be hashed.

```
uint256 constant chainId = 1;
address constant verifyingContract = 0x1C56346CD2A2Bf3202F771f50d3D14a367B48070;
bytes32 constant salt = 0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558;
string private constant EIP712_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
bytes32 private constant DOMAIN_SEPARATOR = keccak256(abi.encode(
    EIP712_DOMAIN_TYPEHASH,
    keccak256("My amazing dApp"),
    keccak256("2"),
    chainId,
    verifyingContract,
    salt
));
```

Next, write a hash function for each data type:

```
function hashIdentity(Identity identity) private pure returns (bytes32) {
    return keccak256(abi.encode(
        IDENTITY_TYPEHASH,
        identity.userId,
        identity.wallet
    ));
}
function hashBid(Bid memory bid) private pure returns (bytes32){
    return keccak256(abi.encodePacked(
        "\\x19\\x01",
       DOMAIN_SEPARATOR,
       keccak256(abi.encode(
            BID_TYPEHASH,
            bid.amount,
            hashIdentity(bid.bidder)
        ))
    ));
```

Last but certainly not least, write your signature verification function:

```
function verify(address signer, Bid memory bid, sigR, sigS, sigV) public pure returns (bool) {
    return signer == ecrecover(hashBid(bid), sigV, sigR, sigS);
}
```

## A working demonstration

For a working demonstration of the above code, use [this tool](https://weijiekoh.github.io/eip712-signing-demo/index.html). After installing a EIP712-compatible version of MetaMask, click the button on the page to run the JavaScript code to trigger a signature request pop-up. Click on Sign, and Solidity code will appear in a text box.

This code will contain all of the above hashing code, the signature generated by MetaMask, and your wallet address. If you copy and paste it into the [Remix IDE](https://remix.ethereum.org/#optimize=true&version=soljson-v0.4.24+commit.e67f0147.js), select the JavaScript VM environment, and then run the `verify` function, Remix will run `ecrecover` in the code to get the signer’s address, compare the result to your wallet address, and then return `true` if they match.

Do take note that for the sake of simplicity, the `verify` function generated by this demonstration differs from the example given above, as the signature generated by MetaMask will be dynamically inserted into it.

![](https://img.learnblockchain.cn/2020/10/14/16026598346417.jpg)
<center>Figure 3: What Remix shows when you run the verify function</center>

In practical terms, this is what your smart contract code should do to verify signed data. Feel free to adapt the code for your own purposes. Hopefully, it will save you time when writing hash functions for your own data structures.

## A note on “legacy” EIP712 support in MetaMask

Another thing to note is that when MetaMask releases support for EIP712, it will no longer support an experimental “legacy” typed data signing feature as described in this [October 2017 blog post](/metamask/scaling-web3-with-signtypeddata-91d6efc8b290).

**Edit (29 Sep)**: As I understand it, once MetaMask makes `eth_signTypedData` point to full EIP712 support, it will support legacy typed data sigining via the `eth_signTypedData_v1` call.

# Final notes

In sum, EIP712 support is coming and developers should take advantage of it. It significantly improves usability and helps to prevents phishing. While it is currently a little tricky to implement, we hope that this article and sample code will help developers to adopt it for their own dApps and contracts.

# Acknowledgements

This article was written by Koh Wei Jie, formerly a full-stack developer with ConsenSys Singapore. Many thanks to Paul Bouchon and Dan Finlay for their invaluable feedback and comments.

原文链接：https://medium.com/metamask/eip712-is-coming-what-to-expect-and-how-to-use-it-bb92fd1a7a26
作者：[Koh Wei Jie](https://medium.com/@weijiek?source=follow_footer--------------------------follow_footer-----------)







