# Delegation and Voting with EIP-712 Signatures

![](https://img.learnblockchain.cn/2020/07/29/15960092035766.jpg)

Compound’s governance system is powered by [COMP token](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888), which is distributed to users of the protocol. COMP token holders receive voting power on a 1–1 basis to the amount of COMP held; this voting power can be delegated to any address, and then can be used to vote on proposals.

There are two methods by which a user can delegate their voting rights or cast votes on proposals: either calling the relevant functions (**delegate**, **castVote**) directly; or using by-signature functionality (**delegateBySig**, **castVotebySig**).

A key benefit to users of by-signature functionality is that they can create a signed delegate or vote transaction for free, and have a trusted third-party spend ETH on gas fees and write it to the blockchain for them. In this guide, we will focus on code examples around this type of functionality.

# Delegate By Signature

By using an [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) “typed-structured data” signature, [COMP token](https://etherscan.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888) holders can delegate their voting rights to any Ethereum address. The COMP smart contract’s **delegateBySig** [method](https://compound.finance/docs/governance#delegate-by-signature) is available to users that have a signed delegation transaction.

A use case for these signatures might be that a delegate wishes to recruit COMP holders to delegate their votes to the delegatee, and to enable them to do so with very low friction.

The delegatee can create a web page where users sign a **delegateBySig** transaction using MetaMask and their private key, which would then be posted to the delegatee’s web server. Later on, the delegatee can batch signatures into a single Ethereum transaction, and officially collect the voting rights of their constituents by executing the **delegateBySig** method.

# Cast Vote By Signature

With the same type of signature as **delegateBySig**, users can enable a third party to submit a vote on their behalf in any single [Compound governance proposal](https://compound.finance/governance/proposals). The Governor smart contract’s **castVoteBySig** [method](https://compound.finance/docs/governance#cast-vote-by-signature) is available to anyone that has a signed vote transaction.

The third party in this scenario, submitting the COMP-holder’s signed transaction, could be the same as in the **delegateBySig** example, however the voting power that they hold is for only a single proposal, instead of indefinitely. The signatory still holds the power to vote on their own behalf in the proposal if the third party has not yet published the signed transaction that was given to them.

# Delegate By Signature in a Web3 Site

Using [this code example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples), anyone can create a simple web page that enables users to delegate their voting rights, by signature, to another address. We’ll assume that all users that visit this page are using [MetaMask](https://metamask.io/) to utilize Web3 functionality.

![](https://img.learnblockchain.cn/2020/07/29/15960093052035.jpg)

When a user visits the page, they can see their selected Web3 wallet address, and their current Compound governance delegate address. They can fill in the address of the third party that they want to delegate their voting rights to. In practice, this address can be hard-coded into the web page.

Next, the user will click “Create Delegation Signature” which will trigger a MetaMask approval of the data that is to be signed. The MetaMask documentation has an in-depth description of [signing data](https://docs.metamask.io/guide/signing-data.html).

![](https://img.learnblockchain.cn/2020/07/29/15960096123400.jpg)

Here is the event handler that executes when the user clicks the button.

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

1. The delegatee’s Ethereum address.
2. The nonce of the signatory account from the COMP smart contract.
3. The transaction’s expiry time, in seconds since the Unix epoch.

The typed-structured data signature method accepts the signatory address alongside a JSON string. The EIP-712 specification defines the types, struct, and domain that make up the data that is to be signed. This is implemented in a simple method, which is called in the button-click event handler.

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

```
const sig = signature.value;

const r = '0x' + sig.substring(2).substring(0, 64);
const s = '0x' + sig.substring(2).substring(64, 128);
const v = '0x' + sig.substring(2).substring(128, 130);
```

The [full web page code example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples) for delegating with an EIP-712 signature is available in the [governance examples GitHub repository](https://github.com/compound-developers/compound-governance-examples).

# Cast Vote By Signature in a Web3 Site

Just like in the Delegate By Signature example, a web page can be made for users to create a vote signature. If a user wishes to give away their “ballot” to a third party, that user must sign separate “for” and “against” transactions, and the third-party may choose which transaction to publish.

The structured data object for creating vote signatures is slightly different from a delegate signature. In this case, the user needs a “Ballot” definition.

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

1. The unique ID of the Compound governance proposal (auto-incrementing integer).
2. A boolean value of the user’s support of the proposal (true or false).

Additionally, the user must pass the signature, which must be broken up into 3 parameters, known as **v**, **r**, and **s** (implemented in the previous section).

The [full web page code example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples) for casting a vote with an EIP-712 signature is available in the [governance examples GitHub repository](https://github.com/compound-developers/compound-governance-examples).

# Batch and Publish Signatures with a Script or a Smart Contract

Once a user has collected signed transactions for Compound governance, they need to publish those transactions to the Ethereum blockchain. The code for implementing this could be useful for exchanges and wallet apps that manage many private keys for many different users.

A collection of signed transactions can be published to the blockchain all at once using JSON RPC or a smart contract. This example uses only Web3.js in a Node.js script. The script will create and batch-publish delegation signatures for a collection of private keys.

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

The [full Solidity example](https://github.com/compound-developers/compound-governance-examples/tree/master/signature-examples/batch-publish-examples) is available in the [governance examples GitHub repository](https://github.com/compound-developers/compound-governance-examples) which is complete with a JSON RPC script, as well as a deploy script for the smart contract.

Thanks for reading and be sure to subscribe to the [Compound Newsletter](https://compound.substack.com/?utm_source=guide_signatures). Feel free to comment on this post, or get in touch in the #development room of the very active [Compound Discord server](https://compound.finance/discord).


原文链接：https://medium.com/compound-finance/delegation-and-voting-with-eip-712-signatures-a636c9dfec5e 作者：[Adam Bavosa](/@adam.bavosa?source=post_page-----a636c9dfec5e----------------------)





