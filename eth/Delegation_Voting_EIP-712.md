# 按照EIP-712规范签名完成委托和投票

![](https://img.learnblockchain.cn/2020/07/29/15960092035766.jpg)

Compound的治理体系是由发放给用户的[COMP代币](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888)来驱动的。COMP代币持有者拥有与持有量1：1的投票权。投票权利可以委托给任意一个地址，让其去给提案投票。

用户可以通过两种方式委托投票或对提案进行投票:可以直接调用函数(**delegate**, **castVote**)或通过签名功能函数(**delegateBySig**， **castVotebySig**)。

通过签名功能函数的好处是用户可以免费完成委托或投票交易，同时会有可信的第三方花费gas费用将投票结果写到区块链中。在本次教程中，我们重点展示这类函数的例子。

# 使用签名实现委托


按照[EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) 规范定义的结构化数据签名方式，[COMP代币](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888)持有者可以委托给任何一个以太坊地址。任何用户只要有已签名的委托交易，都可以调用COMP智能合约中**delegateBySig** [函数](https://compound.finance/docs/governance#delegate-by-signature)

这种方式的使用场景可能是，一个委托者希望联合其他COMP持有者将他们的投票委托给被委托人，并希望以非常低的成本来完成这项工作。

被委托者可以创建一个网页，让用户通过Metamask和私钥完成**delegateBySig** 交易，这样被委托者就能收集到签名信息。之后，被委托者可以将签名信息打包，批量一次写入到以太坊中，再执行**delegateBySig**函数就可以正式的收集到用户的投票权利。

# 通过签名投票

同**delegateBySig**一样，用户也可以委托第三方给 [Compound治理提案](https://compound.finance/governance/proposals)投票。任何用户只要有已签名的委投票交易，都可以调用智能合约中**castVoteBySig** [函数](https://compound.finance/docs/governance#cast-vote-by-signature)

第三方提交用户签名交易和**delegateBySig**的情况是一样的，但是投票权利仅限于一个提案，并非无限制的提案。在第三方正式将投票交易发送到以太坊之前，原有的用户依然保留自主投票的权利。

# 在Web3页面中使用签名实现委托


使用[此代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples),任何人可以创建一个让用户使用签名来委托投票权利的的网页，我们假定访问此页面的所有用户都使用[MetaMask](https://metamask.io/)来调用Web3函数。

![](https://img.learnblockchain.cn/2020/07/29/15960093052035.jpg)

当一个用户访问这个页面时，他们可以看到自己选中的钱包地址和默认的Compound治理地址。他们可以将被委托人的地址填到这个地址中。在实际应用中，这个地址可以固定写成你要委托的目标地址。

接下来，用户会点击“Create Delegation Signature（创建委托签名）“按钮,这个会触发Metamask执行数据签名。MetaMask的文档里有关于[数据签名](https://docs.metamask.io/guide/signing-data.html)的详细介绍。

![](https://img.learnblockchain.cn/2020/07/29/15960096123400.jpg)


在用户点击按钮“SIGN（签名）”时，会执行如下触发事件：

```
sign.onclick = async () => {
  const _delegatee = delegateTo.value;
  const _nonce = await comp.methods.nonces(myAccount).call();
  const _expiry = 10e9; // expiration of signature, in seconds since unix epoch 以时间戳样式的签名过期时间
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

代码中使用了Metamask自带**eth_signTypedData_v4**[函数](https://docs.metamask.io/guide/signing-data.html#sign-typed-data-v4)。这个函数可以按照EIP-712规范的完成[结构化数据签名](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#definition-of-typed-structured-data-%F0%9D%95%8A)。完成一次有效的签名，需要3个参数

1. 被委托人以太坊地址

2. 使用签名账户从COMP智能合约中获得的的nonce

3. 以时间戳样式的交易过期时间

这个结构化数据签名函数可以接受签名地址加上JSON格式的字符串。EIP-712规范定义了需要签名的数据的types, struct和domain。这个实现在一个简单的函数里，在按钮触发事件发生时会被调用。

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

任何以太坊地址都可以使用被委托人地址，nonce，过期时间和签名来发布委托交易。这些是调用COMP合约的**delegateBySig**函数需要的参数。获得的签名需要分成3个参数，命名为 **v**, **r** 和 **s**。

```
const sig = signature.value;
const r = '0x' + sig.substring(2).substring(0, 64);
const s = '0x' + sig.substring(2).substring(64, 128);
const v = '0x' + sig.substring(2).substring(128, 130);
```

根据EIP-712实现委托的[完整代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples)可以在[compound治理样例代码仓库](https://github.com/compound-developers/compound-governance-examples)中查看。

# 在Web3网页中通过签名投票

和委托一样，投票也可以创建一个网页来完成。用户在委托投票权利的时候，“赞同”和“反对”的委托需要分开发送交易，第三方可以选择最终发布哪一个委托。

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

点击“Create Vote Signatures（创建投票签名）”之后，会弹出让用户选择签名“赞成”和“反对”交易。与**delegateBySig**函数一致，通过传递2个参数来调用**castVoteBySig**函数。

1. Compound治理提案唯一编号（自增的整型）
2. 布尔值来表示赞成还是反对提案

另外用户还要传入分成3部分的签名，通常写作为**v**, **r**和**s**

按照EIP-712规范投票[完整页面代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples)可以在[compound治理样例代码仓库](https://github.com/compound-developers/compound-governance-examples)查看。

# 通过脚本或者智能合约打包和发布签名

一旦用户收集完Compound治理的已签名的交易后，他们需要将这些交易发布到以太坊上。 实现批量发送交易的代码对于对于管理多个用户的私钥交易所和钱包很有帮助。

通过JSON RPC或者智能合约可以一次性将收集好的签名交易发布到区块链上。以下代码仅使用了Web3.js，代码实现创建然后批量发布由每一个私钥生成的委托签名的功能。

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
*Gas使用量: 306046*


**web3.BatchRequest**对象将**delegateBySig** 签名打包，然后发布到区块链上。[完整的Node.js代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples/batch-publish-examples) 可以在[compound治理样例码仓库](https://github.com/compound-developers/compound-governance-examples)查看。更多关于Web.js打包可以查看[文档](https://web3js.readthedocs.io/en/v1.2.9/web3.html#batchrequest).


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
*Gas使用量: 306046*

完整的[Solidity代码](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples/batch-publish-examples) 可以在[compound治理样例代码仓库](https://github.com/compound-developers/compound-governance-examples)找到，里面还有JSON RPC的代码和智能合约部署代码。

感谢阅读，记得订阅[Compound 新闻](https://compound.substack.com/?utm_source=guide_signatures)。欢迎在文末留言或者来[Discord](https://compound.finance/discord)和我们交流

原文链接：https://medium.com/compound-finance/delegation-and-voting-with-eip-712-signatures-a636c9dfec5e 作者：[Adam Bavosa](/@adam.bavosa?source=post_page-----a636c9dfec5e----------------------)

