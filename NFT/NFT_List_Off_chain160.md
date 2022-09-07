原文链接：https://betterprogramming.pub/handling-nft-presale-allow-lists-off-chain-47a3eb466e44

# Handling NFT Presale — Allowing Lists Off-chain

## A novel approach to using signed coupons generated off-chain instead of an on-chain allow list.

![1.png](https://img.learnblockchain.cn/attachments/2022/09/IWCtpl086316b8c83ef55.png)

The Humans Of NFT is a project that comprises 1500 truly unique characters who call the Ethereum Blockchain home. Each Human has a handwritten backstory contributed by a member of our community. In our [previous post](https://medium.com/@humansofnft/designing-an-nft-smart-contract-for-flexible-minting-and-claiming-5b420a9a2d82), we provide some context for why we needed such a variety of minting and claiming mechanisms in a single contract.

The verified contract is available for reference on Etherscan:

```
https://etherscan.io/address/0x8575B2Dbbd7608A1629aDAA952abA74Bcc53d22A#code
```

## **The argument against on-chain presale/allow lists**

There are a lot of different strategies for how to handle a *presale list* for an NFT drop. You’ll also hear it referred to as a *whitelist*, or *allow-list* amongst other names. It simply refers to a list of pre-approved addresses that are allowed to interact with the contract in a specified way, eg. minting during a presale window.

A common approach is to simply include a data structure in the contract’s storage that maps each `address` to a `bool`, or each `address` to the number of mints that address is allowed, which might look something like:

```
mapping(address => uint8) _allowList;

function setAllowList(
address[] calldata addresses, 
uint8 numAllowedToMint
) external onlyOwner {
  for (uint256 i = 0; i < addresses.length; i++) {
    _allowList[addresses[i]] = numAllowedToMint;
  }
}
```

There’s absolutely nothing wrong this approach, but it can get a little costly on the contract owner’s side (the `onlyOwner `modifier indicates this function can only be called by the contract owner) when populating the address lists. If you need to add something like 1000 addresses to the presale list, that’s a lot of gas being spent on storage operations. Because The Humans contract had to account for several different “lists” (Authors, Honoraries, Presale, Genesis Claims), we came to the conclusion that this was probably not the best approach for us.

## **The argument for Merkle Trees**

In our search for a more efficient method, the use of Merkle Trees came up a lot. After doing lots of research and learning the ins and outs of how they work, we decided to go the Merkle Tree route. There are many great articles and resources on Merkle Trees. There’s a really great Medium post [(1)](https://nftchance.medium.com/the-gas-efficient-way-of-building-and-launching-an-erc721-nft-project-for-2022-b3b1dac5f2e1) by the team that did the Nuclear Nerds smart contract, which is in itself really impressive, you should check it out! It links to some good resources on Merkle Trees, in addition to a wealth of additional information on gas optimization strategies — we’ll cover a few of these later too. Another great resource is a presentation from Openzeppelin [(2)](https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/slides/20210506 - Lazy minting workshop.pdf) that covers their implementation and how to do the merkle-proof verifications.

I’m not going to use this article to explain how Merkle Trees work, as there are a number of resources, some of which I’ve already mentioned, that will do a much better job of it than I can. The gist is that a Merkle Tree is a hash tree (ie a tree with multiple branches that stores hashes). Every leaf in the tree contains the hash of its parent block of data. Every non-leaf (node) is made up of the hashes of its children and so on. We can then use the root (which we would’ve set in our contract) to verify the presence of any piece of data (in our case an address) in the tree. It’s a very efficient (and secure) way of verifying the contents of a large data structure (eg. a presale list of addresses).

![2.png](https://img.learnblockchain.cn/attachments/2022/09/UnUGUvyq6316b8a6b801b.png)

Diagram of a Merkle Tree from the aforementioned Openzeppelin presentation.

This is the approach we initially decided to take, and it included having three separate Merkle Trees ( Genesis, Honoraries, and Presale). It involved creating three separate Merkle Trees off-chain, and setting the merkle roots in the contract for each sale/claim event via dedicated `onlyOwner `function calls. While you won’t see this implementation in our final contract (for reasons we’ll discuss shortly), the implementation looked something like this (abbreviated for clarity):

```
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
...
// declare bytes32 variables to store each root (a hash)
bytes32 public genesisMerkleRoot; 
bytes32 public authorsMerkleRoot; 
bytes32 public presaleMerkleRoot;
...
// separate functions to set the roots of each individual Merkle Tree
function setGenesisMerkleRoot(bytes32 _root) external onlyOwner {
 genesisMerkleRoot = _root; 
}  
function setAuthorsMerkleRoot(bytes32 _root) external onlyOwner {
  authorsMerkleRoot = _root; 
}
function setPresaleMerkleRoot(bytes32 _root) external onlyOwner {
  presaleMerkleRoot = _root; 
}
...
// create merkle leaves from supplied data
function _generateGenesisMerkleLeaf(
  address _account, 
  uint256 _tokenId
)  internal  pure  returns (bytes32) {  
 return keccak256(abi.encodePacked(_tokenId, _account)); 
}
function _generateAuthorsMerkleLeaf(
  address _account, 
  uint256 _tokenCount
)  internal  pure  returns (bytes32) {  
  return keccak256(abi.encodePacked(_account, _tokenCount)); 
}
function _generatePresaleMerkleLeaf(
  address _account, 
  uint256 _max
)  internal  pure  returns (bytes32) {  
  return keccak256(abi.encodePacked(_max, _account)); 
}
...
// function to verify that the given leaf belongs to a given tree using its root for comparison
function _verifyMerkleLeaf(  
  bytes32 _leafNode,  
  bytes32 _merkleRoot,  
  bytes32[] memory _proof ) internal view returns (bool) {  
  return MerkleProof.verify(_proof, _merkleRoot, _leafNode); 
}
```

Every mint/claim function call would then require the generation and validation of a leaf node using the sender’s address. Eg when minting multiple tokens using `for loop` :

```
require(     
  _verifyMerkleLeaf(
     _generateGenesisMerkleLeaf(
        msg.sender, 
        _tokenIds[i]),      
     genesisMerkleRoot,
     _proofs[i]
), "Invalid proof, you don't own that Token ID");
```

## **But… the final contract doesn’t use Merkle Trees… What gives?**

That’s quite correct… We ended up scrapping the Merkle Tree implementation and rewrote the contract… but why? Upon presenting and discussing this implementation with an advisor, he pointed out that although the approach works, it neglects to take into account the real value proposition of a Merkle Tree. A user should be able to verify themselves against a publicly available tree, so by us having the ability to constantly change the tree kind of defeats the point. In addition, any time an address needs to be added or removed from a given list, a new Merkle Tree needs to be generated, and its new root needs to be set in the contract. Maintaining three separate Merkle trees starts to get messy, especially with constantly evolving/growing/changing lists.

An alternative approach, and the one we ended up deciding to go with, was by using signed Coupons generated off-chain that are passed to the contract functions as parameters. By using this approach, all of the mint/claim functions can be standardized to utilize the same logic, and it ends up being slightly more gas-efficient as there are fewer operations that need to be performed for the verification. It also becomes more cost-efficient from a deployment and admin contract interaction standpoint, as the Coupons are generated off-chain and changing/removing them doesn’t require any interaction with the contract itself.

The idea behind a using a Coupon is relatively straight-forward. If you’ve been around crypto or NFTs for any amount of time, you‘ve probably heard the terms “asymmetric” or “public-key” cryptography before. After all, your Eth wallet address is the public key portion of your private-public keypair, where your private key is used to sign your transactions and verify that you’re the owner of the address.

If you haven’t heard these terms before, that’s okay, it’s essentially a cryptographic system that utilizes a private-public keypair — your private key should be kept secret and never shared with anyone, whereas your public key is available for anyone to see, ie. it’s “publicly” available. With respect to our Coupons, a piece of data is signed off-chain using a private (secret) key that’s only known to us, and the signature (or public key) can be recovered on-chain. This way, we can prove cryptographically that the data being received by the contract was sent from a known origin, ie. the coupon itself was signed by our (The Humans) private key. In our case, that data contains some combination of the user’s address (for example someone on the presale list) and a piece of data specific to that function call (ie. an integer that matches the presale event enum value).

Every mint/claim option (except for the public sale) in our contract requires a coupon. Before we get stuck in, let’s go over some of the necessary data types that are declared at the top of the contract. The `Coupon` struct defines the data generated by the signing process off-chain. The `CouponType` enum allows us to create event-specific coupons, so someone who’s verified to claim as an Author cannot automatically claim during the presale, for example. Finally, the `SalePhase` enum lets us (as the contract owner) control which event is active.

```
struct Coupon {
  bytes32 r;
  bytes32 s;
  uint8 v;
 }
 
enum CouponType {
  Genesis,
  Author,
  Presale
}

enum SalePhase {
  Locked,
  PreSale,
  PublicSale
}
```

Now that we’ve got some background info, let’s take a look at the function definition for the presale minting:

```
 /// Mint during presale
 /// @dev mints by addresses validated using verified coupons signed by an admin signer
 /// @notice mints tokens with randomized token IDs to addresses eligible for presale
 /// @param count number of tokens to mint in transaction
 /// @param coupon coupon signed by an admin coupon
 function mintPresale(uint256 count, Coupon memory coupon)
  external
  payable
  ensureAvailabilityFor(count)
  validateEthPayment(count)
 {
    require( 
      phase == SalePhase.PreSale, 
      'Presale event is not active'
    ); // 1
  
    require(
      count + addressToMints[msg.sender]._numberOfMintsByAddress <=
      MAX_PRESALE_MINTS_PER_ADDRESS,
      'Exceeds number of presale mints allowed'
    ); // 2
    bytes32 digest = keccak256(
      abi.encode(CouponType.Presale, msg.sender)
    ); // 3
  
    require(
      _isVerifiedCoupon(digest, coupon), 
     'Invalid coupon'
    ); // 4
...
}
```

Let’s break down what’s happening in the above function. You can see from the function’s definition that the second argument is of Type `Coupon` — which is the struct we declared earlier in the contract.

// 1
The first `require` statement checks that the presale event is active (using a variable set earlier using the `SalePhase` enum).

// 2
The second `require` statement ensures that the function caller has not minted more than the allowed amount as dictated by the `MAX_PRESALE_MINTS_PER_ADDRESS` constant.

// 3
Now we get to the juicy part — we create a 32 byte hash of the encoded `CouponType` (an integer) and the function caller’s address ( `msg.sender` ), which would look something like this if we were to expand it:

```
bytes32 digest = keccak256(
 abi.encode(
  2, 
  0x8575B2Dbbd7608A1629aDAA952abA74Bcc53d22A
 )
);
```

It’s important to point out here that we’re using `abi.encode` as opposed to `abi.encodePacked` . Using `abi.encode` is less ambiguous, and makes things a little cleaner when we’re generating the coupons, which we’ll go into later.

// 4
Before we allow the `_mint()` function to be called, we need to verify that the Coupon was signed by our private key, that it contains the function caller’s address (ie they’re “on” the presale list) and that they’re minting at the right time.

```
 /// @dev check that the coupon sent was signed by the admin signer
 function _isVerifiedCoupon(bytes32 digest, Coupon memory coupon)
  internal
  view
  returns (bool)
 {
  address signer = ecrecover(digest, coupon.v, coupon.r, coupon.s);
  require(signer != address(0), 'ECDSA: invalid signature');
  return signer == _adminSigner;
 }
```

In the above snippet you can see that we “recover” the signer, ie. the public key from the keypair whose private key initially created the coupon. We get this public key ( the `signer`) using solidity’s built-in `ecrecover` function by passing in the digest ( ie. the 32 byte hash of the coupon type and the sender’s address) along with the Coupon itself. This [(3)](https://soliditydeveloper.com/ecrecover) article was really helpful in explaining the intricacies of how `ecrecover` works under the hood, if you’re interested in diving deeper. The final step in the `_isVerifiedCoupon()` method is checking that the signer actually matches the `_adminSigner` , which was set in the contract’s constructor when it was deployed. As a reminder, this `_adminSigner` is the public key that belongs to the private key that’s used to create the signature (ie the Coupons) off-chain in our development environment. The security afforded by this approach relies entirely on the developer, ie us, keeping the private key a secret.

## **So where does the Coupon come from?**

Great question! The Coupons are generated locally using a script inside our isolated development environment (where we can securely store our private key). The coupons are then synced to the Humans API, where they can be fetched by users who are accessing our mint site.

![3.png](https://img.learnblockchain.cn/attachments/2022/09/mZkaGEPG6316b8aa0fe58.png)

A user validating their position on the list by fetching a coupon

The private key used for signing/creating the coupons **should never be stored on a server,** hopefully for obvious reasons (you don’t want it to fall into a malicious actors hands). Once the coupons have been manually generated, they’re synced with the mint site’s backend ( The Humans API ). A user connects their wallet to the site, then when they attempt to access a certain mint/claim section of the site, the site attempts to fetch a coupon using the user’s address as a lookup. This allows a user to confirm their position on a specific list — ie. if they’re on the list, the API returns the coupon and the user is allowed to proceed to the mint section of the site. When they interact with the contract by calling the mint function, the coupon is passed in along with any other parameters that are required.

![4.png](https://img.learnblockchain.cn/attachments/2022/09/iizER53y6316b8ad5a037.png)

Coupon Lifecycle

The coupons are stored by the API with the user’s address as the primary key:

```
{
  "0x1813183E1A2a5a...a868A4e1b7610c0": {
    "coupon": {
         "r": "0x77b675bb4808.....674c42bde11618a",
         "s": "0x17baa76756fed.....4b0b9f4a380b8a9",
         "v": 27
    }
}
```

Once the coupon has been fetched from the API, it’s passed to the respective mint function. The snippet below shows the implementation used for the presale by calling the contract’s `mintPresale` function from our front-end.

```
mintPresale(
  qty: number, 
  priceInEth: number, 
  coupon: ICoupon
) {
  const mintPriceBn = utils.parseEther(priceInEth.toString());
  return this.contract.mintPresale(qty, coupon, {
    value: mintPriceBn.mul(qty),
    gasLimit: GAS_LIMIT_PER * qty
  });
}
```

**Creating the Coupons**

We collected presale addresses via our custom Discord bot (we’ll do a separate post to cover how we did this). Then, in our local dev environment, after pulling the addresses from the DB, a coupon is generated for each and stored in an object with the users’ addresses as the key. We’re using utils from the `ethers` and `ethereumjs-utils` libraries to help generate the coupons. Take a look at the code below and we’ll step through the process of generating the coupon.

```
const {
  keccak256,
  toBuffer,
  ecsign,
  bufferToHex,
} = require("ethereumjs-utils");
const { ethers } = require('ethers');
...
// create an object to match the contracts struct
const CouponTypeEnum = {
  Genesis: 0,
  Author: 1,
  Presale: 2,
};
let coupons = {};
for (let i = 0; i < presaleAddresses.length; i++) {
  const userAddress = ethers.utils.getAddress(presaleAddresses[i]);
  const hashBuffer = generateHashBuffer(
    ["uint256", "address"],
    [CouponTypeEnum["Presale"], userAddress]
  );
  const coupon = createCoupon(hashBuffer, signerPvtKey);
  
  coupons[userAddress] = {
    coupon: serializeCoupon(coupon)
  };
}
// HELPER FUNCTIONS
function createCoupon(hash, signerPvtKey) {
   return ecsign(hash, signerPvtKey);
}
function generateHashBuffer(typesArray, valueArray) {
   return keccak256(
     toBuffer(ethers.utils.defaultAbiCoder.encode(typesArray,
     valueArray))
   );
}
function serializeCoupon(coupon) {
   return {
     r: bufferToHex(coupon.r),
     s: bufferToHex(coupon.s),
     v: coupon.v,
   };
}
```

If you remember back to when we’re verifying the coupon in the contract, we get the digest by hashing the encoded `CouponType` enum and the user’s address using the `keccak256` algorithm. Perhaps this is a good time to focus in on the security aspects of this approach. Although we’re obviously going to do everything possible to prevent anyone from gaining access to our backend, even if a malicious actor does manage to get their hands on one (or even every) coupon, there’s still nothing they can do with it. The intended recipient of the coupon is encoded in the hash that gets signed. This is checked against the `msg.sender` on the contract side, so the only way to recover the correct signer is if the sender of the coupon is encoded in the coupon itself. Without access to our private key that matches the `_adminSigner` from the keypair, there’s no way for a malicious actor to generate his/her own valid coupons.

```
// [solidity] recreating the digest in the contract 
bytes32 digest = keccak256(
  abi.encode(CouponType.Presale, msg.sender)
);

// [javascript] Creating the digest for the coupon off-chain
const hashBuffer = generateHashBuffer(
   ["uint256", "address"],
   [CouponTypeEnum["Presale"], userAddress]
);

function generateHashBuffer(typesArray, valueArray) {
   return keccak256(
     toBuffer(ethers.utils.defaultAbiCoder.encode(typesArray,
     valueArray))
   );
}
```

When generating the coupon, we’ve created a convenience function called `generateHashBuffer(typesArray, valueArray)` that makes use of the `keccack256` method from `ethereumjs-utils` , which takes a buffer as its only argument and returns a buffer containing the hashed data. In order to encode the data, before converting it to a buffer, we make use of the `ethers.utils.defaultAbiCoder.encode()` method to encode the data, which accepts two arrays, the first of which contains the Types `[“uint256”, “address”]` as strings, and the second with the values to encode `[CouponTypeEnum[“Presale”], userAddress]` .

Now that we have the hash of the data we’ll be using to recover the signature from, we can create the coupon using the `ecsign` method from `ethereumjs-utils` .

```
function createCoupon(hash, signerPvtKey) {
   return ecsign(hash, signerPvtKey);
}
```

The `ecsign` method accepts the hashed data (Buffer) and the signers Private key (also a Buffer) and returns an `ECDSASignature` . The Elliptic Curve Digital Signature Algorithm (ECDSA) [(4)](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) is another example of asymmetrical cryptography, where user A creates a signature with their private key, and user B is able to apply a standard algorithm to recover the public key of the signer (user A). This Medium article [(5)](https://betterprogramming.pub/secure-and-test-the-contract-with-ecdsa-signature-3ff368a479a6) provides some good insight into how it’s used. It’s also noteworthy to point out that the `ecsign` method converts the signature format for the `eth_sign` RPC method, and not `personal_sign` which would prepend the `\x19Ethereum Signed Message:\n` string to the message, which we do not need for our use case. Once we’ve created our coupon, we call the `serializeCoupon()` convenience function and pass in the raw coupon. The function returns an object with the `r` and `s` buffers converted to hex strings for convenient storage. If you’re interested in learning more about the `{r,s,v}` components of the `ECDSASignature`, this practical guide on cryptography [(6)](https://cryptobook.nakov.com/digital-signatures/ecdsa-sign-verify-messages) offers some good insight.

If you remember a little earlier we mentioned that the private key parameter of `ecsign` expects a buffer, so we mustn’t forget to convert it from a string before using it to generate the coupons:

```
const signerPvtKeyString = process.env.ADMIN_SIGNER_PRIVATE_KEY || "";

const signerPvtKey = Buffer.from(signerPvtKeyString, "hex");
```

Something worth mentioning is that the private key does not have to be from an existing/active wallet, in fact it’s probably safer that it’s not. Instead, you can generate a single-purpose private key using `crypto.randomBytes(32)` and then derive the public key (signer) from that using :

```
const { privateToAddress } = require("ethereumjs-utils");
const { ethers } = require("ethers");
const crypto = require("crypto");

const pvtKey = crypto.randomBytes(32);
const pvtKeyString = pvtKey.toString("hex");
const signerAddress = ethers.utils.getAddress(
privateToAddress(pvtKey).toString("hex"));

console.log({ signerAddress, pvtKeyString });
```

In the above snippet, the `signerAddress` is the address we’d pass into the constructor to set the `_adminSigner` when deploying the contract.

## **What are the different use cases for the coupons in The Humans contract?**

As we mentioned in the precursor to this post, we had a variety of mint / claim events, each with its own special circumstances and conditions. Using coupons allowed us to handle all of them using the same approach, without the need to repeat code or add any custom complex logic. I’ll expand on these below.

## **Authors** Our Authors earned free mints in exchange for submitting Bios for our Humans. Each Author earned a different number of Humans based on their own individual contributions and were entitled to claim their earned Humans for free (with the exception of paying the gas fee). Let’s take a look at the function definition and the coupon creation code.

```
// [solidity] function signature
function claimAuthorTokens(
  uint256 count, 
  uint256 allotted, 
  Coupon memory coupon
) public ensureAvailabilityFor(count) {
  require(claimActive, 'Claim event is not active');
  bytes32 digest = keccak256(
    abi.encode(
      CouponType.Author, allotted, msg.sender
    )
  );
  require(_isVerifiedCoupon(digest, coupon), 'Invalid coupon');
  ...
}
// [javascript] Creating the Author Coupons
  
for (const [address, qty] of Object.entries(authorAddressList)) {
  const hashBuffer = generateHashBuffer(
    [
      "uint256", 
      "uint256", 
      "address"
    ],
    [
      CouponTypeEnum["Author"], 
      qty, 
      ethers.utils.getAddress(address)
    ]
  );
  const coupon = createCoupon(hashBuffer, signerPvtKey);
  coupons[ethers.utils.getAddress(address)] = {
     qty,
     coupon: serializeCoupon(coupon)
  };
}
```

As you can see from the snippet above, the `qty` (ie. number of Humans earned) varies by Author, so each Author’s coupon has their allotted number encoded into it. We pass the `qty` (total number they’re allowed to claim), along with the `count` (the number being claimed in this transaction), into the contracts `claimAuthorTokens()` function. I feel like this is a good time to point out that our Coupons do not contain a nonce, which’ll you see used in most implementations. Traditionally this would prevent someone from reusing a coupon, but in this instance we’re okay with the coupon being reused, because the contract keeps track of how many Humans have been claimed:

```
require( 
 count + addressToMints[msg.sender]._numberOfAuthorMintsByAddress <=
 allotted,'Exceeds number of earned Tokens'
);
```

## **Honorary Humans**

We had a total of 35 Honorary Humans. These are 1-of-1 hand-drawn Humans created for specific individuals who’d helped support and/or inspire the project. We reserved Token IDs `230 — 264` for these individuals, so we needed to incorporate the designated IDs into the coupons. Let’s examine the function definition:

```
function claimReservedTokensByIds(
  address owner_,
  uint256[] calldata idxsToClaim,
  uint256[] calldata idsOfOwner,
  Coupon memory coupon
) external {
  require(claimActive, 'Claim event is not active');
  bytes32 digest = keccak256(
    abi.encode(CouponType.Genesis, idsOfOwner, owner_)
  );
  ...
}
```

The `claimReservedTokensByIds()` function doubles as a method for us, as the project team, to airdrop specific IDs to given addresses if for whatever reason they’re not able to claim on their own. It uses the same mechanism of providing the recipient address ( `owner_` ), an array of the indices ( `idxsToClaim` ) for the `idsOfOwner` array that contains the IDs that belong to the `owner_` address. This sounds a bit confusing, but take a look at the missing part of the function definition:

```
   ...
  require(_isVerifiedCoupon(digest, coupon), 'Invalid coupon');
  for (uint256 i; i < idxsToClaim.length; i++) {
     uint256 tokenId = idsOfOwner[idxsToClaim[i]];
     _claimReservedToken(owner_, tokenId);
  }
}
```

Let’s say a user owns Token IDs `[3,9,122,211]` , these will all be encoded in the Coupon. If, for whatever reason they only wanted to claim ids `9` and `211` , then as the `idxsToClaim` they’d pass in the array `[1,3]` because `idsOfOwner[1] = 9;` etc. This allows the user, or us airdropping tokens on their behalf, to claim a subset of all of their tokens in a single transaction.

```
const hashBuffer = generateHashBuffer(
  [
    "uint256",
    "uint256[]",
    "address"
  ],
  [
    CouponTypeEnum["Genesis"],
    idsArray,
    ethers.utils.getAddress(address)
  ]
);
const coupon = createCoupon(hashBuffer, signerPvtKey);
```

As you can see in the above snippet when we generate the Coupons, we’re including the `CouponType` enum for the Genesis Claim (which is for reserved token IDs), along with the array of IDs owned by the user.

## **Burn-to-claim Genesis Tokens**

In the preceding post, we mentioned that we have a genesis collection of 229 Humans that were minted on Opensea’s shared ERC1155 contract. We wanted to merge these into the new collection on our own contract, so we implemented a burn-to-replace mechanism. We’ll discuss the transfer mechanics in another post, but for now we’ll expand on how we used the coupons for this as we think it’s an interesting use-case.

![5.png](https://img.learnblockchain.cn/attachments/2022/09/TKpcmKpt6316b8b0bf022.png)

In order to burn the token from the Opensea contract and claim its one-to-one replacement from our new contract, we need to know the Opensea Token ID for each token. If you’re not familiar with what token IDs from the ERC1155 standard look like, they’re stored as a `uint256` . When we created the original collection, we decided to “name” the Humans by their number in the collection (ie. an our own ID), eg. `HumansOfNFT #1 `. Opensea assigns it’s own token IDs (which are not sequential), so in order to map our IDs to their Opensea IDs, we created a script that pulled down our collection from Opensea’s API, parsed the metadata and extracted our IDs from the `name` property. Here’s an example of an entry from our API that maps our own token ID to the token ID that was assigned by Opensea’s shared contract:

```
{
  "genesisId": 1,
  "openseaTokenId": "23436743935348681979378854387323145555258469867980315876480069342051002482689"
}
```

![6.png](https://img.learnblockchain.cn/attachments/2022/09/6xxy36Mc6316b8b5035b4.png)

Burn-to-claim replacement genesis tokens

When a user clicked on our `genesis_claim.png` icon, we’d scan their wallet and check it for any tokens from Opensea’s shared contract. We then compared those token IDs against the ones stored for our original collection. If a match was found, the Coupon for that ID was retrieved from the API. Because the burn mechanism involves invoking the `safeTransferFrom()` method on the Opensea contract, the only way to pass the coupon is inside the additional `data` field. Take a look at how we initiate the transfer on the front-end:

```
function burnOpenseaToken( 
   userAddress: string,
   openseaId: string,
   newCollectionId: number,
   coupon: Object
) {

  const openseaIdBN = ethers.BigNumber.from(openseaId);
  const data = utils.defaultAbiCoder.encode(
     ["uint256", "tuple(bytes32 r, bytes32 s, uint8 v)"],
     [newCollectionId, coupon]
  );
  const callData = {
    from: utils.getAddress(userAddress),
    to: utils.getAddress(this.humansContractAddress),
    id: openseaIdBN,
    data,
  };
  // call the opensea contracts safeTransferFrom fn
  return this.contract.safeTransferFrom(
    callData.from,
    callData.to,
    callData.id,
    1,
    callData.data
  );
}
```

In order to do this, we simply include the ABI from the standard ERC1155 contract implementation that allows us to call the function using `ethers `. Before we dive into the above snippet, let’s just take a quick look at the function signature for ERC1155’s `safeTransferFrom()` :

```
safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes data)
```

You’ll notice that the last parameter to be passed in ( `data`) is of type `bytes` . So, in order for us to pass the coupon, we need to encode it as a `tuple` :

```
const data = utils.defaultAbiCoder.encode(
     ["uint256", "tuple(bytes32 r, bytes32 s, uint8 v)"],
     [newCollectionId, coupon]
  );
```

This way, we’re able to pass the coupon as a string of `bytes` , and decode it in the contract when the `onERC1155Received` callback fires when the transfer is initiated.

```
function onERC1155Received(
  address, 
  address from,
  uint256 id, 
  uint256, 
  bytes memory data
) public virtual override returns (bytes4) { 
  require(
    msg.sender == _openseaSharedContractAddress,
    'Sender not approved'
  );
  (uint256 genesisId, Coupon memory coupon) = abi.decode(
    data(uint256, Coupon)
  );
  ...
}
```

First things first, we make sure that only tokens from Opensea’s shared contract can be received by our contract — we don’t want people sending random tokens to our contract. Next, we extract the `genesisId` (the token ID in our new collection ) along with the coupon. In order to recover the signer, we need the `CouponType` , the `genesisId` (ie. the ID in the new collection), and the `id` ( the `uint256` token ID from the shared contract).

```
bytes32 digest = keccak256(
  abi.encode(CouponType.Genesis, genesisId, id)
);
```

Once we’ve created the digest and confirmed that the recovered signer matches our signer’s public key, the token transfer is allowed to complete.

## **Presale**

We used the presale coupons as the example for much of this post, so we won’t go over the implementation again as we’ve covered it in-depth.

## **So, how do we test the coupons before deploying them to mainnet?**

Test, test, and test again. I can’t emphasize enough how important it is (or at least it was for me) to test as many scenarios as possible. I use Hardhat as part of my workflow, so as part of my unit tests I’m able to generate coupons on the fly. Take a look at an excerpt from one of our unit tests below:

```
describe('presale minting', async function () {
  it('should be active', async function () {
    await expect(await humansOfNft.phase()).to.equal(1);
  });
  // presaleAddresses are populated using ethers.getSigners();
  presaleAddresses.forEach(async function (account) {
    it('should allow a whitelisted wallet to mint during presale',
      async function () {
        console.log(`${account} is minting presale`);
        let presaleIndex = this.accounts.findIndex(
        (signer: SignerWithAddress) => {
          return ( signer.address === account);
        });
        const tokenCount = Math.ceil(Math.random() * 3);
        const mintPriceInWei = await humansOfNft.mintPrice();
        const mintAmountInEther = parseFloat(
          ethers.utils.formatEther(mintPriceInWei.toString())
        ) * tokenCount;
        const hash = generateHashBuffer(
           ['uint256', 'address',[CouponTypeEnum['Presale'],
           this.accounts[presaleIndex].address]
        );
        const coupon = createCoupon(hash, this.signerPvtKey);
        expect(await humansOfNft.connect(
           this.accounts[presaleIndex]).mintPresale(
             tokenCount, coupon, { 
               value: ethers.utils.parseEther(
               mintAmountInEther.toString())
             })
           ).to.emit(humansOfNft, 'Transfer');
        });
    });
})
```

That about sums it up! If you have any questions, or notice any errors in the write up, please feel free to call them out in the comments!

Special thanks to [xtremetom](https://medium.com/u/f8fef5ff64a6?source=post_page-----47a3eb466e44--------------------------------) who was kind enough to answer my DMs and offer some pointers, and to 

[Lawrence Forman](https://medium.com/u/6f41ae64d95?source=post_page-----47a3eb466e44--------------------------------) for his guidance and wisdom.

```
Want to Connect?You can find us via our website: https://humansofnft.com. Or come and visit us on Discord: https://discord.gg/humansofnft
```

## **References**

(1) https://nftchance.medium.com/the-gas-efficient-way-of-building-and-launching-an-erc721-nft-project-for-2022-b3b1dac5f2e1

(2) [https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/slides/20210506%20-%20Lazy%20minting%20workshop.pdf](https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/slides/20210506 - Lazy minting workshop.pdf)

(3) https://soliditydeveloper.com/ecrecover

(4)https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm

(5) https://betterprogramming.pub/secure-and-test-the-contract-with-ecdsa-signature-3ff368a479a6

(6) https://cryptobook.nakov.com/digital-signatures/ecdsa-sign-verify-messages



