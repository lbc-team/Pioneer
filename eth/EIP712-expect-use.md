


# 应用EIP712

以太坊钱包如[MetaMask](https://metamask.io/)都支持[EIP712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) —— 类型结构化消息签名标准，让钱包可以结构化和可读的格式在签名提示中显示数据。EIP712在安全性和可用性方面向前迈进了一大步，因为用户不再需要对难以理解的十六进制字符串签名（这是一种令人困惑、不安全的做法）。


EIP712已合并到[以太坊改进提案库](https://github.com/ethereum/EIPs)，主流钱包也已支持。本文旨在帮助开发者应用它，包括对其功能的描述、示例 JavaScript 和 Solidity 代码，以及演示。


## EIP712 之前

![](https://img.learnblockchain.cn/2020/10/14/16026478352494.jpg)
\- 图1: 不使用EIP712的dApp的签名请求 -

加密货币领域的格言是:不信任;验证。然而，在 EIP712 之前，用户很难验证被要求签名的数据，在以签名信息作为后续交易基础的 DApp 中，很容易给予更多的信任。

例如，图1是一个由去中心化交易触发的 MetaMask 弹窗，为了安全地将与钱包地址关联起来，要求用户对订单的哈希值进行签名。不幸的是，由于这个哈希值是一个十六进制字符串，没有专业技术知识的用户无法轻松地验证这个哈希值。对于普通用户来说，更容易盲目地相信 DApp 并点击“签名”，而不是通过麻烦的技术验证。这不利于安全。

如果用户无意中登陆了一个恶意的网络钓鱼DApp，就可能会签下错误的订单信息。例如，可以欺骗用户，让他们为一笔本来成本较低的交易支付不合理的高额以太币。为了防止此类攻击，用户必须通过某种方式确切地知道所签名的内容，而不必自己费力地重新构哈希。


## EIP712的改进

![](https://img.learnblockchain.cn/2020/10/14/16026480444699.jpg)
\- 图2: 使用EIP712的DApp的签名请求 -

EIP712在可用性和安全性方面有很大的改进。与上面的例子相反，当启用EIP712的DApp请求签名时，用户的钱包会显示哈希之前的原始数据，这样用户更容易验证它。


## 如何实现 EIP712

标准引入了几个开发人员必须熟悉的概念，本节将详细介绍如何在DApp中实现它。

举个例子，你正在构建一个去中心化的拍卖DApp，在这个DApp中，竞标者在链下签名竞价，一个智能合约会在链上验证这些已经签名的竞价。


### 1、设计数据结构

首先，设计你希望用户签名的数据的JSON结构。本例中我们如下设计:

```js
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

然后，我们可以从上面的代码片段中派生出两个数据结构:`Bid`，它包括以ERC20代币计价的出价`amount`和拍卖`id`，以及`Identity`，它指定了一个`userId`和`wallet`地址。


接下来，写下`Bid`和`Identity`作为你会在你的solididity代码中使用结构体。参考[EIP712标准](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#definition-of-typed-structured-data-%F0%9D%95%8A)获取完整的本地数据类型列表，如`address`, `bytes32`, `uint256`等。


```js
Bid: {
    amount: uint256, 
    bidder: Identity
}
Identity: {
    userId: uint256,
    wallet: address
}
```


### 2、设计域分隔符

下一步是创建一个**域分隔符**。这个强制字段有助于防止一个DApp的签名被用在另一个DApp中。如EIP712的[说明](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale):

> 两个DApp可能会出现相同的结构，如`Transfer(address from,address to,uint256 amount)`，这应该是不兼容的。通过引入域分隔符，DApp开发人员可以保证不会出现签名冲突。

域分隔符需要在体系结构和实现级别上进行仔细的思考和努力。开发人员和设计人员必须根据对他们的用例有意义的内容来决定要包含或排除哪个字段。


**name**: DApp 或协议的名称,如“CryptoKitties”

**version**: “签名域”的当前版本。可以是你的 DApp 或平台的版本号。它阻止一个DApp版本的签名与其他DApp版本的签名一起工作。


**chainId**: [EIP-155](https://eips.ethereum.org/EIPS/eip-155)链id。防止一个网络(如测试网)的签名在另一个网络(如主网)上工作。

**verifyingContract**: 将要验证签名的合约的以太坊地址。Solidity中的`this`关键字返回合约自己的地址，可以在验证签名时使用。


**salt**: 在合约和DApp中都硬编码的惟一的32字节值，这是将DApp与其他应用区分开来的最后手段。

应用上面所有的域分隔符，如下：

```js
{
    name: "My amazing dApp",
    version: "2",
    chainId: "1",
    verifyingContract: "0x1c56346cd2a2bf3202f771f50d3d14a367b48070",
    salt: "0x43efba6b4ccb1b6faa2625fe562bdd9a23260359"
}
```

关于`chainId`需要注意的一点是，如果它与当前连接的网络不匹配，钱包应该阻止签名。然而，由于钱包不一定强制执行这一点，关键是要在链上验证`chainId`。唯一需要注意的是，合约没有办法找到它们所在的链ID，所以开发者必须将`chainId`硬编码到他们的合约中，并且要格外小心，确保它与部署的网络相对应。

>写于(2019年5月31日):如果[EIP-1344](https://eips.ethereum.org/EIPS/eip-1344)被包含在未来的以太坊升级中(可能是[伊斯坦布尔](http://eips.ethereum.org/EIPS/eip-1679))，将会有一种方法让合约通过编程方式找到`chainId`。





#### 2.1、安装4.14.0或以上版本的MetaMask

在4.14.0版本之前的MetaMask，由于 ETHSanFrancisco 的回滚，对EIP712的支持略有变化。4.14.0和更高版本可以正确支持EIP712签名。


### 3、为DApp编写签名代码

您的 JavaScript DApp 现在需要能够要求 MetaMask 为数据签名。首先，定义数据类型:


```js
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

接下来，定义域分隔符和消息数据。


```js
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

变量:

```js
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

接下来，让`eth_signTypedData_v3`签名调用`web3`:

```js
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

请注意，在撰写本文时，MetaMask 和 Cipher Browser 在 method 字段中使用`eth_signTypedData_v3`，以便向后兼容，DApp生态系统就采用这个标准。这些钱包的未来版本可能会将其重命名为`eth_signTypedData`。



### 4、为验证的合约编写身份验证代码

回想一下，在钱包签名 EIP712 类型数据之前，它会先对数据进行格式化和哈希处理。你的合约需要能够做同样的事情，以便用`ecrecover`来确定是哪个地址签名的，你需要在 Solidity 合约代码中复制这个格式化/哈希函数。这可能是最棘手的一步，所以要非常小心。

首先，在 Solidity 中声明数据类型，你应该已经在前面做了:


```js
struct Identity {
    uint256 userId;
    address wallet;
}
struct Bid {
    uint256 amount;
    Identity bidder;
}
```

接下来，定义适合你的数据结构的类型哈希。注意，逗号和方括号后面没有空格，并且名称和类型应该与上面 JavaScript 代码中指定的名称和类型完全匹配。


```js
string private constant IDENTITY_TYPE = "Identity(uint256 userId,address wallet)";
string private constant BID_TYPE = "Bid(uint256 amount,Identity bidder)Identity(uint256 userId,address wallet)";
```

还要定义域分隔符类型哈希。请注意，下面的`chainId`为1表示合约要部署到主网，并且字符串(如“My amazing dApp”)必须被哈希。


```js
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
接下来，为每种数据类型写一个哈希函数:


```js
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

最后，同样重要的是，编写签名验证函数:

```js
function verify(address signer, Bid memory bid, sigR, sigS, sigV) public pure returns (bool) {
    return signer == ecrecover(hashBid(bid), sigV, sigR, sigS);
}
```


## 演示

要演示上述代码，请使用[此工具](https://weijiekoh.github.io/eip712-signing-demo/index.html)。安装与 EIP712 兼容的 MetaMask 版本后，单击页面上的按钮以运行 JavaScript 代码来触发一个签名请求。点击 Sign，solididity 代码将出现在一个文本框。

此代码包含上述所有哈希代码、MetaMask生成的签名、你的钱包地址。如果你将它复制粘贴到 [Remix IDE](https://remix.ethereum.org/#optimize=true&version=soljson-v0.4.24+commit.e67f0147.js)，选择 JavaScript VM 环境，然后运行`verify`功能，Remix 将在代码中运行`ecrecover`获取签名者的地址，将结果与钱包地址比较，如果匹配则返回`true`。


请注意，为了简单起见，演示生成的`verify`函数与上面给出的示例不同，因为由 MetaMask 生成的签名会动态地插入其中。



![](https://img.learnblockchain.cn/2020/10/14/16026598346417.jpg)
\- 图3: 运行验证函数时Remix显示的内容 -

实际上，这就是智能合约验证签名数据应该做的。您可以根据自己的需要调整代码。希望可以在给数据结构写哈希函数时节省时间。


## MetaMask 支持 EIP712 后关于“legacy” 的说明

另一件需要注意的事情是，当 MetaMask 发布对 EIP712 支持时，它将不再支持一个实验性的“legacy”类型化数据签名，正如这篇[2017年10月的博客文章](https://medium.com/metamask/scaling-web3-with-signtypeddata-91d6efc8b290)所描述的。

> **写于(9月29日)**:据我理解，一旦 MetaMask 让`eth_signTypedData`指向完整的 EIP712 支持，它将通过`eth_signTypedData_v1`调用支持 legacy 类型化数据签名。


## 最后

总之，开发人员应该充分利用 EIP712。它显著提高了可用性，并有助于防止网络钓鱼，希望本文能够帮助开发人员在自己的DApp和合约中应用它。


## 特别感谢
本文作者Koh Wei Jie曾是ConsenSys Singapore的一名全栈开发人员。非常感谢Paul Bouchon和Dan Finlay的宝贵反馈和评论。


>原文链接：https://medium.com/metamask/eip712-is-coming-what-to-expect-and-how-to-use-it-bb92fd1a7a26




