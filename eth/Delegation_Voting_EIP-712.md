# Delegation and Voting with EIP-712 Signatures
# 通过EIP-712签名来完成授权和投票

![](https://img.learnblockchain.cn/2020/07/29/15960092035766.jpg)

Compound’s governance system is powered by [COMP token](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888), which is distributed to users of the protocol. COMP token holders receive voting power on a 1–1 basis to the amount of COMP held; this voting power can be delegated to any address, and then can be used to vote on proposals.
Compound的监管制度是由发放给用户的[COMP token](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888)来驱动的。COMP代币持有者拥有与持有量1：1的投票权。投票权利可以通过委托给任意一个地址去给提案投票。


There are two methods by which a user can delegate their voting rights or cast votes on proposals: either calling the relevant functions (**delegate**, **castVote**) directly; or using by-signature functionality (**delegateBySig**, **castVotebySig**).
用户可以通过两种方式委托他们的投票权或投票的提案:可以直接调用函数(**delegate**, **castVote**)或通过签名功能函数(**delegateBySig**， **castVotebySig**)。

A key benefit to users of by-signature functionality is that they can create a signed delegate or vote transaction for free, and have a trusted third-party spend ETH on gas fees and write it to the blockchain for them. In this guide, we will focus on code examples around this type of functionality.
通过签名功能函数的好处是用户可以免费完成委托和投票，同时会有第三方花费gas fee帮他们写到区块链中。在本次教程中，我们重点展示这类函数的例子。

# Delegate By Signature
# 通过签名委托

By using an [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) “typed-structured data” signature, [COMP token](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888) holders can delegate their voting rights to any Ethereum address. The COMP smart contract’s **delegateBySig** [method](https://compound.finance/docs/governance#delegate-by-signature) is available to users that have a signed delegation transaction.

通过使用[EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) 规范定义的结构化数据签名方式，[COMP token](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888)持有者可以委托给任何一个以太坊地址。任何用户有过签字委托转账的，都可以调用COMP智能合约中**delegateBySig** [method](https://compound.finance/docs/governance#delegate-by-signature)


A use case for these signatures might be that a delegate wishes to recruit COMP holders to delegate their votes to the delegatee, and to enable them to do so with very low friction.
使用这种方式的场景可能是，一个委托希望获得COMP持有者将他们的选票委托给被委托的人，并使他们能够以非常低的摩擦来完成这项工作。

The delegatee can create a web page where users sign a **delegateBySig** transaction using MetaMask and their private key, which would then be posted to the delegatee’s web server. Later on, the delegatee can batch signatures into a single Ethereum transaction, and officially collect the voting rights of their constituents by executing the **delegateBySig** method.

被委托者可以创建一个网页，使得用户可以通过Metamask和私钥完成**delegateBySig** 转账，这样被委托者就能收集到签名信息。之后，被委托者可以将签名信息打包，批量一次写入到以太坊中，再执行**delegateBySig**函数就可以正式的收集到选民的投票权利。

# Cast Vote By Signature
# 通过签名投票

With the same type of signature as **delegateBySig**, users can enable a third party to submit a vote on their behalf in any single [Compound governance proposal](https://compound.finance/governance/proposals). The Governor smart contract’s **castVoteBySig** [method](https://compound.finance/docs/governance#cast-vote-by-signature) is available to anyone that has a signed vote transaction.

同**delegateBySig**一样，用户也可以委托第三方给 [Compound管理提案](https://compound.finance/governance/proposals)投票。任何用户有过签字投票转账的，都可以调用智能合约中**castVoteBySig** [函数][method](https://compound.finance/docs/governance#cast-vote-by-signature)

The third party in this scenario, submitting the COMP-holder’s signed transaction, could be the same as in the **delegateBySig** example, however the voting power that they hold is for only a single proposal, instead of indefinitely. The signatory still holds the power to vote on their own behalf in the proposal if the third party has not yet published the signed transaction that was given to them.

这种提交用户签名转账和 **delegateBySig**的情况

# Delegate By Signature in a Web3 Site
# 在Web3中通过签名委托

Using [this code example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples), anyone can create a simple web page that enables users to delegate their voting rights, by signature, to another address. We’ll assume that all users that visit this page are using [MetaMask](https://metamask.io/) to utilize Web3 functionality.

![](https://img.learnblockchain.cn/2020/07/29/15960093052035.jpg)

使用[如下代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples),任何人可以创建一个提供用户通过签名委托投票权利的的网页，我们假设所有的用户都是用 [MetaMask](https://metamask.io/)来调用函数。


When a user visits the page, they can see their selected Web3 wallet address, and their current Compound governance delegate address. They can fill in the address of the third party that they want to delegate their voting rights to. In practice, this address can be hard-coded into the web page.

当一个用户访问这个页面时，他们可以看到自己选中的钱包地址和默认的Compound管理地址。他们可以将需要委托的地址填到这个地址中。在实际应用中，这个地址可以固定写成你要委托的目标地址。

Next, the user will click “Create Delegation Signature” which will trigger a MetaMask approval of the data that is to be signed. The MetaMask documentation has an in-depth description of [signing data](https://docs.metamask.io/guide/signing-data.html).
接下来，用户会点击“创建委托签名”[Create Delegation Signature],这个会触发Metamask执行数据签名。Metamas的文档里有详细的关于[数据签名](https://docs.metamask.io/guide/signing-data.html)的介绍。

![](https://img.learnblockchain.cn/2020/07/29/15960096123400.jpg)

Here is the event handler that executes when the user clicks the button.
当用户点击按钮是，会执行如下触发事件：

```
sign.onclick = async () => {
  const _delegatee = delegateTo.value;
  const _nonce = await comp.methods.nonces(myAccount).call();
  const _expiry = 10e9; // expiration of signature, in seconds since unix epoch
  const _chainId = web3.currentProvider.networkVersion;
  const msgParams = createDelegateBySigMessage(compAddress, _delegatee, _expiry, _chainId, _nonce);
  web3.currentProvider.sendAsync({
    method: 'eth_signTypedData_v4',
    params: [ myAccount, msgParams ],
    from: myAccount
  }, async (err, result) => {
    if (err) {
      console.error('ERROR', err);
      alert(err);
      return;
    } else if (result.error) {
      console.error('ERROR', result.error.message);
      alert(result.error.message);
      return;
    }
    const sig = result.result;
    delegatee.value = _delegatee;
    nonce.value = _nonce;
    expiry.value = _expiry;
    signature.value = sig;
    console.log('signature', sig);
    console.log('msgParams', JSON.parse(msgParams));
  });
};
```

The code utilizes the **eth_signTypedData_v4** [method](https://docs.metamask.io/guide/signing-data.html#sign-typed-data-v4), which is implemented within MetaMask. This is used to create [typed-structured data signatures](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#definition-of-typed-structured-data-%F0%9D%95%8A), which are described in the EIP-712 specification. In order to create a valid signature, the method needs 3 parameters.

代码中使用了Metamask自带**eth_signTypedData_v4**[函数](https://docs.metamask.io/guide/signing-data.html#sign-typed-data-v4)。这个函数可以完成按照EIP-712规范的[结构化数据签名](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#definition-of-typed-structured-data-%F0%9D%95%8A)。完成一次有效的签名，需要3个参数

1. The delegatee’s Ethereum address.
1. 委托人以太坊地址
2. The nonce of the signatory account from the COMP smart contract.
2. 从COMP智能合约获得的签名账户的随机数
3. The transaction’s expiry time, in seconds since the Unix epoch.
3. 以时间戳样式的账户过期时间

The typed-structured data signature method accepts the signatory address alongside a JSON string. The EIP-712 specification defines the types, struct, and domain that make up the data that is to be signed. This is implemented in a simple method, which is called in the button-click event handler.
这个结构化数据签名函数可以接受签名地址加上JSON格式的字符串。EIP-712规范定义了需要签名的数据的types, struct和domain。这个会通过按钮触发事件实现。

```
const createDelegateBySigMessage = (compAddress, delegatee, expiry = 10e9, chainId = 1, nonce = 0) => {
  const types = {
    EIP712Domain: [
      { name: 'name', type: 'string' },
      { name: 'chainId', type: 'uint256' },
      { name: 'verifyingContract', type: 'address' },
    ],
    Delegation: [
      { name: 'delegatee', type: 'address' },
      { name: 'nonce', type: 'uint256' },
      { name: 'expiry', type: 'uint256' }
    ]
  };
  const primaryType = 'Delegation';
  const domain = { name: 'Compound', chainId, verifyingContract: compAddress };
  const message = { delegatee, nonce, expiry };
  return JSON.stringify({ types, primaryType, domain, message });
};
```

The delegatee, nonce, expiry, and signature can then be used by any Ethereum address to publish the delegate transaction. These are the parameters of the **delegateBySig** method in the COMP contract. The signature needs to be broken up into 3 parameters, known as **v**, **r**, and **s**.

任何以太坊地址都可以使用委托人地址，随机数，过期时间和签名来发布委托转账。这些是调用COMP合约的**delegateBySig**函数需要的参数。获得的签名需要分成3个参数，命名为 **v**, **r** 和 **s**。

```
const sig = signature.value;
const r = '0x' + sig.substring(2).substring(0, 64);
const s = '0x' + sig.substring(2).substring(64, 128);
const v = '0x' + sig.substring(2).substring(128, 130);
```

The [full web page code example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples) for delegating with an EIP-712 signature is available in the [governance examples GitHub repository](https://github.com/compound-developers/compound-governance-examples).

根据EIP-712实现委托的[完整代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples)可以在[compound管理代码仓库](https://github.com/compound-developers/compound-governance-examples)。


# Cast Vote By Signature in a Web3 Site
# 在Web3中通过签名投票

Just like in the Delegate By Signature example, a web page can be made for users to create a vote signature. If a user wishes to give away their “ballot” to a third party, that user must sign separate “for” and “against” transactions, and the third-party may choose which transaction to publish.

和委托一样，也可以创建一个网页来完成投票签名。用户在委托投票权利的时候，“赞同”和“反对”的委托需要分开转账，第三方可以选择最终发布哪一个委托。

The structured data object for creating vote signatures is slightly different from a delegate signature. In this case, the user needs a “Ballot” definition.
这个结构化数据和上面的委托签名稍许不同，这里用户需要定义“Ballot”

```
const createVoteBySigMessage = (govAddress, proposalId, support, chainId = 1) => {
  const types = {
    EIP712Domain: [
      { name: 'name', type: 'string' },
      { name: 'chainId', type: 'uint256' },
      { name: 'verifyingContract', type: 'address' },
    ],
    Ballot: [
      { name: 'proposalId', type: 'uint256' },
      { name: 'support', type: 'bool' }
    ]
  };
  const primaryType = 'Ballot';
  const domain = { name: 'Compound Governor Alpha', chainId, verifyingContract: govAddress };
  support = !!support;
  const message = { proposalId, support };
  return JSON.stringify({ types, primaryType, domain, message });
};
```

Clicking “Create Vote Signatures” will prompt the user to sign a “for” and an “against” transaction. Similar to the **delegateBySig** method, votes can be cast by passing 2 parameters to the **castVoteBySig** method.
点击创建投票签名“Create Vote Signatures”之后，会弹出让用户选择签名“赞成”和“反对”转账。与**delegateBySig**函数一致，通过传递2个参数来调用**castVoteBySig**函数。

1. The unique ID of the Compound governance proposal (auto-incrementing integer).
1. Compound管理提案唯一编号（自动增加）
2. A boolean value of the user’s support of the proposal (true or false).
2. 布尔值来表示赞成还是反对提案

Additionally, the user must pass the signature, which must be broken up into 3 parameters, known as **v**, **r**, and **s** (implemented in the previous section).
另外用户还要传入分成3部分**v**, **r**和**s**的签名，

The [full web page code example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples) for casting a vote with an EIP-712 signature is available in the [governance examples GitHub repository](https://github.com/compound-developers/compound-governance-examples).

# Batch and Publish Signatures with a Script or a Smart Contract
# 通过脚本或者智能合约打包和发布签名

Once a user has collected signed transactions for Compound governance, they need to publish those transactions to the Ethereum blockchain. The code for implementing this could be useful for exchanges and wallet apps that manage many private keys for many different users.

用户完成收集签名后，他们需要将这些转账发布到以太坊上。交易所和钱包可以通过以下代码管理多个用户的私钥

A collection of signed transactions can be published to the blockchain all at once using JSON RPC or a smart contract. This example uses only Web3.js in a Node.js script. The script will create and batch-publish delegation signatures for a collection of private keys.
一次性可以通过JSON RPC或者智能合约将收集好的签名转账发布到区块链上。以下代码仅使用了Web3.js实现批量发布委托签名的功能

```
const myWalletAddress = web3.eth.accounts.wallet[0].address;
var batch = new web3.BatchRequest();
signatures.forEach((signature) => {
  const { delegatee, nonce, expiry, v, r, s } = signature;
  batch.add(comp.methods.delegateBySig(delegatee, nonce, expiry, v, r, s).send.request(
    {
      from: myWalletAddress,
      gasLimit: web3.utils.toHex(1000000),
      gasPrice: web3.utils.toHex(25000000000),
    },
      console.log
    )
  );
});
await batch.execute();
```

*Gas used: 454740*

The **web3.BatchRequest** object batches the **delegateBySig** transactions and publishes them to the blockchain. The [full Node.js example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples/batch-publish-examples) is available in the [governance examples GitHub repository](https://github.com/compound-developers/compound-governance-examples). For more information on the Web3.js batching, see the [documentation](https://web3js.readthedocs.io/en/v1.2.9/web3.html#batchrequest).

The same functionality can be implemented with a Solidity smart contract. By comparison, this method uses marginally less gas than the Web3 batch approach.
使用Solidity智能合约也可以到达同样的效果，经过对比，这种方式消耗的gas更少。

```
pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;
interface Comp {
  function delegateBySig(
    address delegatee,
    uint nonce,
    uint expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
}
contract BatchDelegate {
  struct Sig {
    address delegatee;
    uint nonce;
    uint expiry;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }
  function delegateBySigs(Sig[] memory sigs) public {
    Comp comp = Comp(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    for (uint i = 0; i < sigs.length; i++) {
      Sig memory sig = sigs[i];
      comp.delegateBySig(sig.delegatee, sig.nonce, sig.expiry, sig.v, sig.r, sig.s);
    }
  }
}
```

*Gas used: 306046*
*Gas使用量: 306046*

The [full Solidity example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples/batch-publish-examples) is available in the [governance examples GitHub repository](https://github.com/compound-developers/compound-governance-examples) which is complete with a JSON RPC script, as well as a deploy script for the smart contract.
[完整Solidity代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples/batch-publish-examples) 可以在[compound管理代码仓库](https://github.com/compound-developers/compound-governance-examples)找到，里面还有JSON RPC的代码和智能合约部署代码。

Thanks for reading and be sure to subscribe to the [Compound Newsletter](https://compound.substack.com/?utm_source=guide_signatures). Feel free to comment on this post, or get in touch in the #development room of the very active [Compound Discord server](https://compound.finance/discord).
感谢您的阅读，记得订阅[Compound 新闻](https://compound.substack.com/?utm_source=guide_signatures)。欢迎在文末留言或者来[Discord](https://compound.finance/discord)和我们交流

原文链接：https://medium.com/compound-finance/delegation-and-voting-with-eip-712-signatures-a636c9dfec5e 作者：[Adam Bavosa](/@adam.bavosa?source=post_page-----a636c9dfec5e----------------------)

