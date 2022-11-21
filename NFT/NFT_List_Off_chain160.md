原文链接：https://betterprogramming.pub/handling-nft-presale-allow-lists-off-chain-47a3eb466e44

# 处理 NFT 预售——链下白名单

## 一种使用链下生成的签名优惠券而不是链上白名单的新方法。

![1.png](https://img.learnblockchain.cn/attachments/2022/09/IWCtpl086316b8c83ef55.png)

The Humans Of NFT 是一个由1500个真正独特的角色组成的项目，他们将以太坊称为区块链家园。每个人类都有一个由我们社区成员提供的手写背景故事。在我们[之前的文章中](https://medium.com/@humansofnft/designing-an-nft-smart-contract-for-flexible-minting-and-claiming-5b420a9a2d82)，我们提供了一些背景信息，说明为什么我们需要在单个合约中使用如此多种铸造和认领机制。

在Etherscan已验证的合约可供参考:

```
https://etherscan.io/address/0x8575B2Dbbd7608A1629aDAA952abA74Bcc53d22A#code
```

## **反对链上预售/白名单的论点**

对于如何处理 NFT 空投的*预售清单*，有很多不同的策略。你还会听到它被称为*白名单*或*允许名单*。 它只是指允许以指定方式与合约交互的预先批准的地址列表。例如， 在预售窗口期间铸造。

一种常见的方法是在合约的存储中简单地包含一个数据结构，将每个`地址`映射到一个`布尔值`，或者每个`地址`映射到该地址允许的铸币数量，这可能看起来像：

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

这种方法绝对没有错，但是在填充地址列表时，对于合约所有者来说，它可能会付出一些代价(`onlyOwner`修饰符表示该函数只能由合约所有者调用)。如果你需要将1000个地址添加到预售列表中，那么储存操作将花费大量gas。因为Humans合约必须考虑几个不同的“列表”(Authors, Honoraries, Presale, Genesis Claims)，我们得出的结论是，这可能不是最适合我们的方法。

## **默克尔树的论证**

在我们寻找更有效的方法时，出现了很多使用 Merkle 树的情况。 在进行了大量研究并了解了它们的工作原理后，我们决定采用 Merkle Tree 路线。 有很多关于 Merkle Trees 的优秀文章和资源。有一篇非常棒的 Medium 帖子 [(1)](https://nftchance.medium.com/the-gas-efficient-way-of-building-and-launching-an-erc721-nft-project-for-2022- b3b1dac5f2e1) 由执行 Nuclear Nerds 智能合约的团队提供，这本身就非常令人印象深刻，你应该看看！ 除了有关gas优化策略的大量附加信息外，它还链接到 Merkle Trees 上的一些好的资源——我们稍后也会介绍其中的一些。 另一个很棒的资源是来自 Openzeppelin [(2)](https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/slides/20210506 - Lazy minting Workshop.pdf) 的演示文稿，其中涵盖 他们的实现以及如何进行 merkle-proof 验证。

我不会用这篇文章来解释默克尔树是如何工作的，因为有很多资源，其中一些我已经提到过，它们会比我做得更好。 要点是默克尔树是一棵哈希树（即具有多个存储哈希的分支的树）。 树中的每个叶子都包含其父数据块的哈希值。 每个非叶子（节点）都由其子节点的哈希值等组成。 然后，我们可以使用根（我们将在合约中设置）来验证树中是否存在任何数据（在我们的例子中是地址）。 这是一种验证大型数据结构（例如预售地址列表）内容的非常有效（且安全）的方法。

![2.png](https://img.learnblockchain.cn/attachments/2022/09/UnUGUvyq6316b8a6b801b.png)

Openzeppelin 演示中的 Merkle 树图

这是我们最初决定采用的方法，它包括拥有三个独立的 Merkle 树（Genesis、Honoraries 和 Presale）。 它涉及在链下创建三个独立的默克尔树，并调用合约中`onlyOwner`修饰的函数为每个出售/认领事件设置默克尔根。 虽然你不会在我们的最终合约中看到这个实现（原因我们稍后会讨论），但实现看起来像这样（为了清楚起见）：

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

然后，调用每个 mint/claim 函数都需要使用发送者的地址来生成和验证叶子节点。 例如，当使用 `for loop` 铸造多个代币时：

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

## **但是……最终的合约没有使用 Merkle Trees……那使用了什么？**

这是完全正确的……我们最终取消了 Merkle Tree 的实现并重写了合约……但是为什么呢？ 在与顾问介绍并讨论此实现时，他指出尽管该方法有效，但它忽略了考虑默克尔树的真正价值主张。 用户能够根据公开可用的树来验证自己，我们能够不断地改变树的类型就可以解决问题。 此外，任何时候从给定列表中添加或删除地址时，都需要生成新的 Merkle Tree，并且需要在合约中设置其新根。 维护三个独立的 Merkle 树开始变得混乱，尤其是在不断发展/增长/变化的列表中。

另一种方法，也是我们最终决定采用的方法，是使用在链下生成的已签名优惠券，这些优惠券作为参数传递给合约函数。 通过使用这种方法，所有铸币/认领功能都可以以使用相同的逻辑标准化，并且由于需要为验证执行的操作更少，因此最终会稍微更加节省gas。 从部署和管理合约交互的角度来看，它也变得更具成本效益，因为优惠券是在链下生成的，并且更改/删除它们不需要与合约本身进行任何交互。

使用优惠券背后的想法相对简单。 如果你在任何时候都使用过加密或 NFT，那么你之前可能已经听说过“非对称”或“公钥”密码学这些术语。 毕竟，你的 Eth 钱包地址是你的私钥-公钥对的公钥部分，你的私钥用于签署你的交易并验证你是地址的所有者。

如果你以前没有听说过这些术语，那没关系，它本质上是一个使用私钥-公钥对的加密系统——你的私钥应该保密，永远不要与任何人共享，而你的公钥可供任何人查看， 它是“公开”可用的。 对于我们的优惠券，使用只有我们知道的私有（秘密）密钥在链下对一段数据进行签名，并且可以在链上恢复签名（或公钥）。 通过这种方式，我们可以通过密码证明合约接收的数据是从已知来源发送的，优惠券本身是由我们的私钥签署。 在我们的例子中，该数据包含用户地址（例如预售名单上的某人）和特定于该函数调用的一段数据（即与预售事件枚举值匹配的整数）的某种组合。

我们合约中的每个铸币/认领选项（公开销售除外）都需要一张优惠券。 在我们陷入困境之前，让我们回顾一下合约顶部认领的一些必要数据类型。 `Coupon` 结构定义了链下签名过程生成的数据。 `CouponType` 枚举允许我们创建特定于事件的优惠券，例如，经过验证声称为作者的人不能在预售期间自动认领。 最后，`SalePhase` 枚举让我们（作为合约所有者）控制哪个事件处于活动状态。

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

现在我们已经有了一些背景信息，让我们看一下预售铸币的函数定义：

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

让我们分解上述函数中发生的事情。 从函数的定义中可以看出，第二个参数的类型是“Coupon”——这是我们之前在合约中认领的结构。

// 1
第一个 `require` 语句检查预售事件是否处于活动状态（使用之前使用 `SalePhase` 枚举设置的变量）。

// 2
第二个 `require` 语句确保函数调用者没有超过 `MAX_PRESALE_MINTS_PER_ADDRESS` 常量规定的允许数量。

// 3
现在我们进入了有趣的部分——我们通过编码 `CouponType`（一个整数）和函数调用者的地址（`msg.sender`）创建了一个 32 字节的哈希，如果我们扩展它看起来像这样：

```
bytes32 digest = keccak256(
 abi.encode(
  2, 
  0x8575B2Dbbd7608A1629aDAA952abA74Bcc53d22A
 )
);
```

需要指出的是，我们使用的是 `abi.encode` 而不是 `abi.encodePacked`。 使用 `abi.encode` 不那么模棱两可，并且在我们生成优惠券时让事情变得更简洁，我们稍后会介绍。

// 4
在我们允许调用`_mint()`函数之前，我们需要验证优惠券是由我们的私钥签名的，它包含函数调用者的地址（即他们在预售列表中）和正确的铸造时间。

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

在上面的代码片段中，你可以看到我们“恢复”了签名者，即从其私钥最初创建优惠券的密钥对中的公钥。我们使用 solidity 的内置 `ecrecover` 函数通过以下方式获取此公钥（`signer`）将摘要（即优惠券类型和调用者地址的32字节哈希值）与优惠券本身一起传递。如果你有兴趣深入了解，这篇 [(3)](https://soliditydeveloper.com/ecrecover) 文章非常有助于解释 `ecrecover` 如何在后台工作的复杂性。 `_isVerifiedCoupon()` 方法的最后一步是检查签名者是否真正匹配 `_adminSigner` ，它在部署时在合约的构造函数中设置。提醒一下，这个 `_adminSigner` 是属于私钥的公钥，用于在我们的开发环境中链下创建签名（即优惠券）。这种方法提供的安全性完全依赖于开发人员将私钥保密。

## 那么优惠券是从哪里来的呢？

好问题！ 优惠券是使用独立的开发环境（可以安全地存储我们的私钥）中的脚本在本地生成的。 然后将优惠券同步到 Humans API，访问我们的 铸币网站的用户可以在其中获取优惠券。

![3.png](https://img.learnblockchain.cn/attachments/2022/09/mZkaGEPG6316b8aa0fe58.png)

用户通过获取优惠券验证其在列表中的位置

用于签名/创建优惠券的私钥**不应该存储在服务器上，** 原因很明显（你不希望它落入恶意行为者手中）。 手动生成优惠券后，它们会与铸币网站的后端（The Humans API）同步。 用户将他们的钱包连接到该站点，然后当他们尝试访问该站点的某个铸币/认领部分时，该站点会尝试使用用户的地址作为查找来获取优惠券。 这允许用户确认他们在特定列表中的位置——如果他们在列表中，API 会返回优惠券，并且允许用户继续访问网站的铸币区。 当他们通过调用 mint 函数与合约进行交互时，优惠券与任何其他所需的参数一起传入。

![4.png](https://img.learnblockchain.cn/attachments/2022/09/iizER53y6316b8ad5a037.png)

优惠券生命周期

优惠券由 API 以用户地址作为主键存储：

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

一旦从 API 中获取优惠券，它就会被传递给相应的 mint 函数。 下面的代码片段显示了通过从我们的前端调用合约的`mintPresale` 函数用于预售的实现。

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

**创建优惠券**

我们通过自定义 Discord 机器人收集了预售地址（我们将单独发布一篇文章来介绍我们是如何做到这一点的）。 然后，在我们的本地开发环境中，从数据库中提取地址后，会为每个人生成一张优惠券，并将其存储在一个以用户地址为键的对象中。 我们使用来自 `ethers` 和 `ethereumjs-utils` 库的工具来帮助生成优惠券。 看看下面的代码，我们将逐步完成生成优惠券的过程。

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

如果你还记得我们在验证合约中的优惠券时，我们通过使用`keccak256 `算法对 `CouponType `枚举和用户地址进行哈希编码得到摘要。 也许现在是关注这种方法的安全方面的好时机。 尽管我们显然会尽一切可能阻止任何人访问我们的后端，即使恶意行为者确实设法获得了一张（甚至每张）优惠券，他们仍然无能为力。 优惠券的预期接收者被编码在签名的哈希中。 这是根据合约端的`msg.sender`检查的，因此恢复正确签名者的唯一方法是优惠券的发送者是否被编码在优惠券本身中。 如果无法访问与密钥对中的 `_adminSigner` 匹配的私钥，恶意行为者就无法生成他自己的有效优惠券。

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

在生成优惠券时，我们创建了一个名为`generateHashBuffer(typesArray, valueArray)`的便捷函数，它使用了`ethereumjs-utils`中的`keccack256`方法，该方法接受一个buffer作为唯一参数，并返回一个包含哈希数据的buffer。为了编码数据，在将其转换为buffer之前，我们使用`ether .utils. defaultabicoder .encode()`方法来编码数据，该方法接受两个数组，第一个包含类型`[" uint256 "， " address "]`的字符串，第二个包含要编码的值`[CouponTypeEnum[" Presale "]， userAddress]`。 

现在我们有了用于恢复签名的数据的哈希值，我们可以使用 `ethereumjs-utils` 中的 `ecsign` 方法创建优惠券。

```
function createCoupon(hash, signerPvtKey) {
   return ecsign(hash, signerPvtKey);
}
```

`ecsign` 方法接受哈希数据（Buffer）和签名者私钥（Buffer）并返回一个 `ECDSASignature`。 椭圆曲线数字签名算法 (ECDSA) [(4)](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) 是非对称加密的另一个示例，其中用户 A 使用其私钥创建签名，用户 B 能够应用标准算法来恢复签名者（用户 A）的公钥。 这篇 Medium 文章 [(5)](https://betterprogramming.pub/secure-and-test-the-contract-with-ecdsa-signature-3ff368a479a6) 很好地了解了它的使用方式。同样值得注意的是，`ecsign `方法转换的是`eth_sign'` RPC方法的签名格式，而不是`personal_sign`，后者会在`\x19Ethereum Signed Message:\n`字符串前面加上消息，在我们的用例中不需要。一旦我们创建了优惠券，我们调用` serializeCoupon()`函数并传入原始优惠券。该函数返回一个对象，其中 `r` 和 `s` 缓冲区转换为十六进制字符串以便于存储。 如果你有兴趣了解有关 `ECDSASignature` 的 `{r,s,v}` 组件的更多信息，请阅读本密码学实用指南 [(6)](https://cryptobook.nakov.com/digital-signatures /ecdsa-sign-verify-messages) 提供了一些很好的见解。

如果你还记得早些时候我们提到过 `ecsign` 的私钥参数需要一个缓冲区，所以我们一定不要忘记在使用它来生成优惠券之前将其从字符串转换：

```
const signerPvtKeyString = process.env.ADMIN_SIGNER_PRIVATE_KEY || "";

const signerPvtKey = Buffer.from(signerPvtKeyString, "hex");
```

值得一提的是，私钥不必来自现有/活动的钱包，事实上它可能更安全。 相反，你可以使用 `crypto.randomBytes(32)` 生成一个单一用途的私钥，然后使用以下方法从中派生公钥（签名者）：

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

在上面的代码片段中，`signerAddress` 是我们在部署合约时传递给构造函数以设置 `_adminSigner` 的地址。

## **The Humans 合约中的优惠券有哪些不同的用例？**

正如我们在这篇文章的前言中提到的，我们有各种各样的铸币/认领事件，每一个都有自己的特殊情况和条件。 使用优惠券使我们能够使用相同的方法处理所有这些，而无需重复代码或添加任何自定义复杂逻辑。 我将在下面扩展这些。

## **Authors** 

我们的作者通过为我们的Humans提交Bios来换取免费铸币。 每位作者根据自己的个人贡献获得了不同数量的Humans，并有权免费认领他们获得的Humans（支付gas费除外）。 我们来看看函数定义和优惠券创建代码。

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

正如你从上面的代码片段中看到的那样`qty`（即获得的Humans数量）因作者而异，因此每个作者的优惠券都有其分配的编号编码。 我们将`qty`（他们被允许认领的总数）和`count`（在此交易中认领的数字）一起传递给合约的“claimAuthorTokens()”函数。 我觉得现在是指出我们的优惠券不包含随机数的好时机，你会看到它在大多数实现中使用。 传统上，这会阻止某人重复使用优惠券，但在这种情况下，我们可以重新使用优惠券，因为合约会跟踪有多少人被认领：

```
require( 
 count + addressToMints[msg.sender]._numberOfAuthorMintsByAddress <=
 allotted,'Exceeds number of earned Tokens'
);
```

## **Honorary Humans**

我们共有 35 名Honorary Humans。 这些是 1-of-1 手绘Humans，是为帮助支持和激发项目的特定个人创建。 我们为这些人保留了 `230 — 264`的Token ID ，因此我们需要将指定的 ID 合并到优惠券中。 我们来看看函数定义：

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

`claimReservedTokensByIds()` 函数兼作我们将特定 ID 空投到给定地址的一种方法，如果出于某种原因他们无法自行认领。 它使用相同的机制来提供接收地址（`owner_`），一个包含属于`owner_`地址的ID的`idsOfOwner`数组的索引数组（`idxsToClaim`）。 这听起来有点令人困惑，但请看一下函数定义中缺少的部分：

```
   ...
  require(_isVerifiedCoupon(digest, coupon), 'Invalid coupon');
  for (uint256 i; i < idxsToClaim.length; i++) {
     uint256 tokenId = idsOfOwner[idxsToClaim[i]];
     _claimReservedToken(owner_, tokenId);
  }
}
```

假设用户拥有 Token ID `[3,9,122,211]`，这些都将被编码在优惠券中。 如果出于某种原因他们只想认领 id `9` 和 `211` ，那么作为 `idxsToClaim` 他们会传入数组 `[1,3]` 因为 `idsOfOwner[1] = 9;` 我们代表他们空投代币，这允许用户在一次交易中认领他们所有代币的一个子集。

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

正如你在上面的代码片段中看到的，当我们生成优惠券时，我们包含了 Genesis Claim（用于保留的令牌 ID）的`CouponType`枚举，以及用户拥有的 ID 数组。

## 销毁认领 Genesis 代币

在上一篇文章中，我们提到我们有 229 个Humans 的创世集合，是在 Opensea 共享的ERC1155 合约上铸造的。 我们想根据我们自己的合约将这些合并到新的集合中，因此我们实施了一种销毁替换机制。 我们将在另一篇文章中讨论转移机制，但现在我们将扩展我们如何使用优惠券，因为我们认为这是一个有趣的用例。

![5.png](https://img.learnblockchain.cn/attachments/2022/09/TKpcmKpt6316b8b0bf022.png)

为了从 Opensea 合约中销毁代币并从我们的新合约中获得一对一的替换，我们需要知道每个代币的 Opensea 代币 ID。 如果你不熟悉 ERC1155 标准中的令牌 ID ，它们被存储为 `uint256`类型 。 当我们创建原始集合时，我们决定通过他们在集合中的编号（即我们自己的 ID）来“命名”Humans，如 `HumansOfNFT #1`。 Opensea 分配它自己的令牌 ID（不是连续的），因此为了将我们的 ID 映射到 Opensea ID，我们创建了一个脚本，从 Opensea 的 API 中提取我们的集合，解析元数据并从`name `属性中提取我们的id。 这是我们 API 中的一个条目示例，它将我们自己的令牌 ID 映射到 Opensea 的共享合约分配的令牌 ID： 

```
{
  "genesisId": 1,
  "openseaTokenId": "23436743935348681979378854387323145555258469867980315876480069342051002482689"
}
```

![6.png](https://img.learnblockchain.cn/attachments/2022/09/6xxy36Mc6316b8b5035b4.png)

Burn-to-claim 替换 genesis 代币

当用户点击我们的`genesis_claim.png`图标时，我们会扫描他们的钱包并检查它是否有来自 Opensea 共享合约的代币。 然后，我们将这些tokenId 与为我们的原始集合存储的那些进行比较。 如果找到匹配项，则从 API 中检索该 ID 的优惠券。 因为销毁机制涉及调用 Opensea 合约上的 `safeTransferFrom()` 方法，所以传递优惠券的唯一方法是在附加的 `data` 字段中。看看我们是如何在前端发起转账的：

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

为此，我们只需包含标准 ERC1155 合约实现中的 ABI，它允许我们使用 `ethers` 调用该函数。 在深入了解上述代码段之前，让我们快速看一下 ERC1155 的 `safeTransferFrom()` 的函数签名：

```
safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes data)
```

你会注意到要传入的最后一个参数（`data`）是`bytes`类型。 因此，为了传递优惠券，我们需要将其编码为tuple` :

```
const data = utils.defaultAbiCoder.encode(
     ["uint256", "tuple(bytes32 r, bytes32 s, uint8 v)"],
     [newCollectionId, coupon]
  );
```

这样，我们可以将优惠券作为 `bytes` 字符串传递，并在合约中发起转账时触发 `onERC1155Received` 回调对其进行解码。

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

首先，确保只有来自 Opensea 共享合约的代币可以被我们的合约接收——不希望人们向我们的合约发送随机代币。 接下来，我们提取 `genesisId`（我们新集合中的代币 ID）和优惠券。 为了恢复签名者，我们需要`CouponType`、`genesisId`（即新集合中的ID）和`id`（来自共享合约的`uint256`token ID）。

```
bytes32 digest = keccak256(
  abi.encode(CouponType.Genesis, genesisId, id)
);
```

一旦我们创建了摘要并确认恢复的签名者与我们的签名者的公钥匹配，就可以完成token转移。

## **预售**

我们在这篇文章的大部分内容中都使用了预售优惠券作为示例，因此我们将不再详细介绍实现，因为我们已经深入介绍了它。

## 那么，我们如何在将优惠券部署到主网之前对其进行测试？

测试，测试，再测试。 尽可能多地测试场景非常重要（或者至少对我而言），我怎么强调都不过分。 使用 Hardhat 作为工作流程的一部分，即时生成优惠券作为单元测试的一部分。 请看下面我们的单元测试之一的摘录：

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

差不多就这么总结了！ 如果你有任何问题，或发现文章中有任何错误，请随时在评论中指出！

特别感谢[xtremetom](https://xtremetom.medium.com/)，他很友好地回答了我的 DM 并提供了一些指导，并感谢[Lawrence Forman](https://medium.com/@merklejerk)的指导和智慧。

```
想要联系吗？你可以通过我们的网站找到我们：https://humansofnft.com。 或者来访问我们的 Discord：https://discord.gg/humansofnft
```

## **参考**

(1) https://nftchance.medium.com/the-gas-efficient-way-of-building-and-launching-an-erc721-nft-project-for-2022-b3b1dac5f2e1

(2) [https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/slides/20210506%20-%20Lazy%20minting%20workshop.pdf](https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/slides/20210506 - Lazy minting workshop.pdf)

(3) https://soliditydeveloper.com/ecrecover

(4)https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm

(5) https://betterprogramming.pub/secure-and-test-the-contract-with-ecdsa-signature-3ff368a479a6

(6) https://cryptobook.nakov.com/digital-signatures/ecdsa-sign-verify-messages
