# How To Code Gas-Less Tokens on Ethereum

> * https://hackernoon.com/how-to-code-gas-less-tokens-on-ethereum-43u3ew4 作者 [@albertocuestacanada](https://hackernoon.com/u/albertocuestacanada)

## Unlocking Ethereum for the masses



每个人都在谈论 “无gas” 的以太坊交易，因为没有人喜欢支付gas费用。 但是以太坊网络的运行正是因为交易是付费的。 那么，你怎么才能“无gas”交易呢? 这是什么法术?



在本文中，我将展示如何使用 “无 gas” 交易背后的模式。 你会发现，尽管以太坊没有免费的午餐之类的东西，但是你可以通过有趣的方式改变 gas 成本。



通过运用本文中的知识，你的用户将节省大量 gas，享受更好的用户体验，甚至可以在你的智能合约中构建新颖的委派模式。



可是等等！ 还有更多！ 为方便起见，我将所需的所有工具都放在了[此存储库](https://github.com/albertocuestacanada/ERC20Permit?ref=learnblockchain.cn)中。 因此，现在你实现 “无 gas” 代币的障碍就突然降低了很多。




让我们开始吧。

## 背景



我不得不承认，即使我知道如何在智能合约中实现“无 gas”交易，但对于使它们成为可能的密码学我也知之甚少。 那对我来说不是障碍，所以对你也不应该是。




据我所知，私钥用于签署发送给以太坊的交易，一些密码学魔术用于将我（签名者）识别为msg.sender。 这支撑了以太坊中所有访问控制。


> “无 gas” 交易背后的法宝是，我可以使用我的私钥和要执行的智能合约交易进行签名。
>
> 



签名是在链下进行的，而无需花费任何 gas。 然后，我可以将此签名交给其他人，以他们的名义代表我执行交易。



The function that the signature is for will usually be a regular function, but extended with additional signature parameters. For example in [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn) we have the approve function:



签名函数通常就是常规合约方法，但会使用其他签名参数进行扩展。 例如，在[dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)中，我们有授权（`approve`）函数：



```
function approve(address usr, uint wad) external returns (bool)
```



我们还具有`permit`许可函数，该功能与`approve`函数相同，但是将签名作为参数。




```
function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external
```



不用担心所有这些额外的参数，我们将介绍它们。 你需要注意的是这两个函数都使用`allowance`映射执行的操作：


```
function approve(address usr, uint wad) external returns (bool)
{
  allowance[msg.sender][usr] = wad;
  …
}

function permit(
  address holder, address spender,
  uint256 nonce, uint256 expiry, bool allowed,
  uint8 v, bytes32 r, bytes32 s
) external {
  …
  allowance[holder][spender] = wad;
  …
}
```



如果使用`approve`，则允许`spender`最多使用`wad`个代币。

如果你给某人提供有效的签名，则该人可以调用`permit`以允许`spender`  使用你的代币。


因此，基本上，“无 gas”交易背后的模式是制作可以提供给某人的签名，以便他们可以安全地执行特殊交易。 这就像授予某人执行函数的权限。

这是一种授权模式。



## 标准

如果你像我一样，那么你要做的第一件事就是深入研究代码。 我立即注意到此注释：

```
// — — EIP712 niceties — -
```

有了这个，我[钻进了兔子洞](https://learnblockchain.cn/docs/eips/eip-712.html)，却无望地迷路了。 现在，我已经理解了，我可以用简单的方式来解释它。



[EIP712](https://learnblockchain.cn/docs/eips/eip-712.html)描述了如何以通用方式构建函数签名。 其他EIP描述了如何将[EIP712](https://learnblockchain.cn/docs/eips/eip-712.html)应用。 例如，[EIP2612](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-2612.md?ref=learnblockchain.cn)描述了如何使用[EIP712](https://learnblockchain.cn/docs/eips/eip-712.html)的签名应用于`permit`函数，其功能应与ERC20代币中的`approve`功能相同。



如果你只想实现之前提到的签名功能，例如将签名批准添加到自己的MetaCoin，则可以阅读[EIP2612](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-2612.md?ref=learnblockchain.cn) ，你甚至可以继承实现过的合约，并减轻生活压力。


在本文中，我们将研究[dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)中“无 gas”交易的实现。 这将使事情变得清晰。 [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)实现发生在[EIP2612](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-2612.md?ref=learnblockchain.cn)之前，会略有不同。 那不会有问题。



## 签名组成

An early implementation of [EIP712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md?ref=learnblockchain.cn) signatures can be found in [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn). It allows dai holders to approve transfer transactions by calculating an off-chain signature and giving it to the spender, instead of calling approve themselves.



[EIP712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md?ref=learnblockchain.cn)签名的早期实现可以在[dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol)源码中找到 。 它允许Dai持有人通过计算链下签名并将其提供给支出者（spender）来批准转账交易，而不是自己调用approve函数。



它包含下面几个部分：


1. 一个 `DOMAIN_SEPARATOR`   .

2. 一个  `PERMIT_TYPEHASH`  .

3. 一个  `nonces`   变量.

4. 一个 `permit`   函数.



这是`DOMAIN_SEPARATOR`，和相关变量：

```js
string  public constant name     = "Dai Stablecoin";
string  public constant version  = "1";
bytes32 public DOMAIN_SEPARATOR;
constructor(uint256 chainId_) public {
  ...
  DOMAIN_SEPARATOR = keccak256(abi.encode(
    keccak256(
      "EIP712Domain(string name,string version," + 
      "uint256 chainId,address verifyingContract)"
    ),
    keccak256(bytes(name)),
    keccak256(bytes(version)),
    chainId_,
    address(this)
  ));
}
```



`DOMAIN_SEPARATOR`只不过是唯一标识智能合约的哈希。 它是由EIP712域（EIP712Domain）的字符串，包含代币合约的名称，版本，所在的chainId以及合约部署的地址构成。

All that information is hashed on the constructor into the `DOMAIN_SEPARATOR` variable, which will have to be used by the holder when creating the signature, and will need to match when executing permit. That ensures that a signature is valid for one contract only.



所有这些信息都在构造函数上进行hash 运算赋值到`DOMAIN_SEPARATOR`变量中，该变量在创建线下签名时由持有人使用，并且在执行`permit`时需要匹配。 这样可以确保签名仅对一个合约有效。



这是`PERMIT_TYPEHASH`：



![9nMyFjQNicRJ5HwksmBytJBySMi2-ae3d2w4y](https://img.learnblockchain.cn/pics/20200923151751.jpeg)



The signature will be processed in the permit function, and if the `PERMIT_TYPEHASH` used was not for this specific function, it will revert. This makes sure that a signature is only used for the intended function.



`PERMIT_TYPEHASH` 是函数名称(大写开头)和所有参数(包括类型和名称)的哈希。 目的是清楚地标志签名的函数。


签名将在允许功能中处理，如果使用的“ PERMIT_TYPEHASH”不是该特定功能的签名，它将恢复。 这样可以确保仅将签名用于预期的功能。



Then there is the `nonces` mapping:



然后是`nonces`映射：

```
mapping (address => uint) public nonces;
```

This mapping registers how many signatures have been used for a particular holder. When creating the signature, a `nonces` value needs to be included. When executing `permit`, the nonce included must exactly match the number of signatures that have been used so far for that holder. This ensures that each signature is used only once.



该映射记录了特定持有人已使用了多少个签名。 创建签名时，需要包含一个“ nonce”值。 执行“ permit”时，所包含的现时必须与该持有人到目前为止使用的签名数完全匹配。 这样可以确保每个签名仅使用一次。

All these three conditions together, the `PERMIT_TYPEHASH` , the `DOMAIN_SEPARATOR`, and the `nonce`, make sure that each signature is used only for the intended contract, the intended function, and only once.



所有这三个条件，即PERMIT_TYPEHASH，DOMAIN_SEPARATOR和nonce，确保每个签名仅用于预期的合约，预期的功能，并且仅使用一次。



Now let’s see how the signature would be processed in the smart contract.



现在，让我们看看如何在智能合约中处理签名。





**The permit function**

`permit` is the [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn) function that allows using signatures to modify the `allowance` of `holder` towards `spender`.



“ permit”是[dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)函数，允许使用签名来修改“ allowance” 持有人对spender的看法。



```
// --- Approve by signature ---
function permit(
  address holder, address spender,
  uint256 nonce, uint256 expiry, bool allowed,
  uint8 v, bytes32 r, bytes32 s
) external;
```

As you can see, there are a lot of parameters there. They are all the parameters needed to compute the signature, plus `v`,`r` and `s` which are the signature itself.

如你所见，那里有很多参数。 它们是计算签名所需的所有参数，加上签名本身就是“ v”，“ r”和“ s”。



It seems silly that you need the parameters that were used to create the signature, but you do. The only thing that you can recover from the signature is the address that created it, nothing more. We will use all the parameters and the recovered address to ensure the signature is valid.



你需要用于创建签名的参数似乎很愚蠢，但是你确实需要。 你只能从签名中恢复签名的地址，仅此而已。 我们将使用所有参数和恢复的地址来确保签名有效。



First we calculate a `digest` using all the parameters that we will need to ensure safety. The `holder` will need to calculate the exact same digest off-chain, as part of the signature creation:



首先，我们使用确保安全性所需的所有参数来计算“消化”。 作为签名创建的一部分，`holder`将需要计算出完全相同的摘要链外：




```
bytes32 digest =
  keccak256(abi.encodePacked(
    "\x19\x01",
    DOMAIN_SEPARATOR,
    keccak256(abi.encode(
      PERMIT_TYPEHASH,
      holder,
      spender,
      nonce,
      expiry,
      allowed
    ))
  ));
```

Using `ecrecover` and the `v,r,s` signature we can recover an address. If it is the address of the `holder` , we know that all the parameters match ( `DOMAIN_SEPARATOR`, `PERMIT_TYPEHASH`, `nonce`, `holder` , `spender` , `expiry`, and `allowed`
. If anything is off, the signature is rejected:



使用`ecrecover`和`v，r，s`签名，我们可以恢复地址。 如果它是`holder`的地址，我们知道所有参数都匹配(`DOMAIN_SEPARATOR`，`PERMIT_TYPEHASH`，'nonce`，`holder`，`spender`，`expiry`和`allowed`。
。 如果关闭任何内容，则签名被拒绝：



```
require(holder == ecrecover(digest, v, r, s), "Dai/invalid-permit");
```

A word of caution here. There are many parameters that go into a signature, some of them obscure like the `chainId` (part of the `DOMAIN_SEPARATOR`). Any of them being off will cause the signature being rejected with the **exact same error**, which guarantees that debugging off-chain signatures will be difficult. You have been warned.



请注意这里。 签名中有许多参数，其中一些参数很模糊，例如“ chainId”(DOMAIN_SEPARATOR的一部分)。 它们中的任何一个关闭都会导致签名被拒绝，并带有“完全相同的错误” **，这确保调试脱链签名将很困难。 你被警告了。



Now we know that the `holder` approved this function call. Next we will certify that the signature is not being abused. We check that the current time is before the `expiry`, this allows permits to be held only for a specific period.



现在我们知道`holder`批准了这个函数调用。 接下来，我们将证明签名没有被滥用。 我们检查当前时间是否在“过期”之前，这允许仅在特定时期内保留许可证。




```
require(expiry == 0 || now <= expiry, "Dai/permit-expired");
```

We also check that a signature with that `nonce`  hasn’t been used yet, so that each signature can be used only once.



我们还会检查尚未使用带有“ nonce”的签名，以便每个签名只能使用一次。




```
require(nonce == nonces[holder]++, "Dai/invalid-nonce");
```

And we are through! [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn) maxes out the `allowance`  of `holder`  towards `spender`, emits an event, and that’s it.

我们通过了！ [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)使`spender`的`holder`的`allowance'最大化，发出 一个事件，仅此而已。





```
uint wad = allowed ? uint(-1) : 0;
allowance[holder][spender] = wad;
emit Approval(holder, spender, wad);
```

The [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn) contract has a binary approach towards `allowance` , in the [repository](https://github.com/albertocuestacanada/ERC20Permit?ref=learnblockchain.cn) provided you'll find a more traditional behavior.



[repository]中的[dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)合约对`allowance'具有二进制处理方式 (https://github.com/albertocuestacanada/ERC20Permit?ref=learnblockchain.cn)，前提是你会发现更传统的行为。




**Creating the signature off-chain**



创建签名不是为了胆小者，而是通过一些实践和坚持不懈，可以掌握它。 我们将分三步在“许可”中复制智能合约的功能：



Creating the signature is not for the faint of heart, but with a bit of practice and persistence it can be mastered. We will replicate what the smart contract does in `permit` in three steps:

1. Generate the `DOMAIN_SEPARATOR`
2. Generate the `digest`
3. Create the transaction signature

The following function will create the `DOMAIN_SEPARATOR`. It is the same code as in the [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn) constructor, but in JavaScript and using `keccak256`, `defaultAbiCoder` and `toUtfBytes` from [ethers.js](https://github.com/ethers-io/ethers.js/?ref=learnblockchain.cn). It needs the token name and deployment address, along with the `chainId`. It assumes the token version to be “1”.



以下函数将创建“ DOMAIN_SEPARATOR”。 它与[dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)构造函数中的代码相同，但在JavaScript中并使用` 来自[ethers.js](https://github.com/ethers-io/ethers.js/?ref=learnblockchain.cn)的keccak256`，`defaultAbiCoder`和`toUtfBytes`。 它需要代币名称和部署地址，以及`chainId`。 假定代币版本为“ 1”。



![9nMyFjQNicRJ5HwksmBytJBySMi2-q8802wdw](https://img.learnblockchain.cn/pics/20200923151841.jpeg)



The following function will create a `digest` for a specific `permit` call. Note that the `holder`, `spender`, `nonce` and `expiry` are passed on as arguments. It also passes an `approve.allowed` argument for clarity, although you could just set it always to `true`, otherwise the signature will be rejected and what would be the point? The `PERMIT_TYPEHASH` we just copied it from [dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn).



以下函数将为特定的“ permit”调用创建“ digest”。 注意，`holder`，`spender`，`nonce`和`expiry`作为参数传递。 为了清楚起见，它还传递了一个“ approve.allowed”参数，尽管你可以将其始终设置为“ true”，否则签名将被拒绝，这有什么用呢? 我们刚刚从[dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn)复制了“ PERMIT_TYPEHASH”。



![9nMyFjQNicRJ5HwksmBytJBySMi2-cf852wp4](https://img.learnblockchain.cn/pics/20200923151919.jpeg)








Once we have a `digest`, signing it is relatively easy. We just use `ecsign` from [ethereumjs-util](https://github.com/ethereumjs/ethereumjs-util?ref=learnblockchain.cn) after removing the 0x prefix from the `digest`. Note that we need the user private key to do this.

In the code, we would call these functions as follows:



一旦我们有了“摘要”，对其进行签名就相对容易了。 我们从[digest]中删除0x前缀后，只使用[ethereumjs-util](https://github.com/ethereumjs/ethereumjs-util?ref=learnblockchain.cn)中的`ecsign`。 请注意，我们需要用户私钥才能执行此操作。

在代码中，我们将按以下方式调用这些函数：



![9nMyFjQNicRJ5HwksmBytJBySMi2-ot8g2w69](https://img.learnblockchain.cn/pics/20200923151948.jpeg)

Note how the call to `permit` reuses all the parameters that were used to create the `digest`, before it was signed. Only in that case the signature would be valid.



请注意，对“ permit”的调用在签名之前如何重用用于创建“ digest”的所有参数。 只有在这种情况下，签名才有效。



Note as well that the only two transactions in this snippet are being called by `user2`. `user1` is the `holder`, and is the one that created the `digest` and signed it. However, `user1` didn’t spend any gas doing so.



还要注意的是，此代码段中仅有的两个事务是由“ user2”调用的。 “ user1”是“ holder”，是创建“ digest”并签名的用户。 但是，“ user1”并没有花费任何精力。



`user1` gave the signature to `user2`, which used it to execute both the `permit` and the `transferFrom` that `user1` allowed.



“ user1”将签名提供给“ user2”，后者使用它来执行“ user1”允许的“ permit”和“ transferFrom”。





From the point of view of `user1`, it was a “gas-less” transaction. He didn’t spend a wei.



从“ user1”的角度来看，这是一次“无 gas”交易。 他没有花一分钱。



**Conclusion**



This article shows how to use “gas-less” transactions, clarifying that “gas-less” actually means passing the gas cost to someone else. To do that we need a function in a smart contract that is ready to deal with pre-signed transactions, and a good deal of data manipulation to make everything safe.



本文介绍了如何使用“无煤气”交易，阐明了“无煤气”实际上意味着将煤气成本转移给其他人。 为此，我们需要一个智能合约中的功能，该功能可以处理预先签署的交易，并且需要进行大量的数据操作以确保一切安全。



However, there are significant gains from using this pattern, and for that reason it is widely used. Signatures allow passing the transaction gas cost from the user to the service provider, eliminating a considerable barrier in many cases. It also allows for the implementation of more advanced delegation patterns, often with considerable UX improvements.



但是，使用此模式有很多好处，因此，它被广泛使用。 签名允许将交易 gas成本从用户转移到服务提供商，从而在许多情况下消除了相当大的障碍。 它还允许实现更高级的委派模式，通常会对UX进行相当大的改进。



> A [repository](https://github.com/albertocuestacanada/ERC20Permit?ref=learnblockchain.cn) has been provided for you to get started. Please use it, and please [continue the conversation](https://twitter.com/acuestacanada?ref=learnblockchain.cn).

*Very special thanks to Georgios Konstantinopoulos, who taught me all I know about this pattern.*