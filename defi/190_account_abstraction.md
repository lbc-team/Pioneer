# The road to account abstraction

Account abstraction allows us to use smart contract logic to specify not just the *effects* of the transaction, but also the *fee payment and validation logic*. This allows many important security benefits, such as [multisig and smart recovery wallets](https://vitalik.ca/general/2021/01/11/recovery.html), being able to change keys without changing wallets, and quantum-safety.

Many approaches to account abstraction have been proposed and implemented to various degrees, see: [EIP-86](https://github.com/ethereum/EIPs/issues/86), [EIP-2938](https://eips.ethereum.org/EIPS/eip-2938), and [this doc from two years ago](https://ethereum-magicians.org/t/implementing-account-abstraction-as-part-of-eth1-x/4020). Today, development on EIPs is stalled due to a desire to focus on the merge and sharding, but an alternative that does *not* require any consensus changes has seen great progress: [ERC-4337](https://github.com/ethereum/EIPs/pull/4337).

ERC-4337 attempts to do the same thing that EIP-2938 does, but through extra-protocol means. Users are expected to send off-chain messages called *user operations*, which get collected and packaged in bulk into a single transaction by either the block proposer or a builder producing bundles for block proposers. The proposer or builder is responsible for filtering the operations to ensure that they only accept operations that pay fees. There is a separate mempool for user operations, and nodes connected to this mempool do ERC-4337-specific validations to ensure that a user operation is guaranteed to pay fees before forwarding it.

![image.png](https://img.learnblockchain.cn/attachments/2023/06/XcQI72Md6486cee5a9a08.png)

ERC-4337 can do a lot as a purely voluntary ERC. However, there are a few key areas where it is weaker than a truly in-protocol solution:

1. **Existing users cannot upgrade** without moving all their assets and activity to a new account
2. **Extra gas overhead** (~42k for a basic UserOperation compared to ~21k for a basic transaction)
3. **Less benefit from in-protocol censorship resistance techniques** such as [crLists](https://notes.ethereum.org/@vbuterin/pbs_censorship_resistance#Solution-2-can-we-still-use-proposers-“hybrid-PBS”-but-only-for-inclusion-of-last-resort), which target transactions and would miss user operations

One realistic path toward getting the best of all worlds is to start heavily supporting ERC-4337 in the short term, and then add EIPs that cover for its weaknesses over time. This does not necessarily require committing to enshrining ERC-4337 specifically. Rather, it’s possible to design the in-protocol support to be more generic and support both ERC-4337 and alternatives and improvements to it.

Here, I will list some of these EIPs and give an idea as to what order they could be implemented in.

## Convert an EOA into a smart contract wallet

To allow existing EOAs to upgrade to ERC-4337 wallets, we can make an EIP that allows EOAs to perform an operation that sets their contract code. Once an EOA does this, the transformation is irreversible; from that point on, that account will only function as a smart contract wallet. Fortunately, because ERC-4337 accounts are DELEGATECALL proxies, it would be possible to later convert the wallet into a smart contract compatible with a *different* ERC if desired.

There are a few proposals for how to implement this upgrade procedure:

### A “replace code” transaction type

This hasn’t yet been introduced as a formal EIP, but the approach would be simple: add a new [EIP-2718](https://eips.ethereum.org/EIPS/eip-2718https://eips.ethereum.org/EIPS/eip-2718) transaction type that simply replaces the account code with the calldata.

### AUTH_USURP (EIP-5003)

[EIP-5003](https://github.com/ethereum/EIPs/pull/5003) is an extension to [EIP-3074](https://eips.ethereum.org/EIPS/eip-3074) (`AUTH` and `AUTHCALL`) that introduces a new `AUTHUSURP` opcode. If, using the EIP-3074 mechanism, an EOA address `A` has authorized another address `B` to act on its behalf, `AUTHUSURP` allows `B` to set `A`’s code.

This approach is more complex than the “replace code” route; it only makes sense if we intend to adopt EIP-3074 anyway for its other usability properties.

### Mandatory conversion

In the longer-term future, we may want to do mandatory force-conversion to simplify the protocol and make contracts the only account type, de-enshrining ECDSA from the protocol. One possible way to do this would be to add an overlay rule that, from some block forward, an account with no code is treated as an account that has some particular standardized “ERC-4337 EOA wallet” code.

This could be done with a “poking” procedure where any transaction that originates from an EOA converts it, and any transaction that touches an EOA with a nonzero nonce converts it. It could also be done with a one-time pass through the entire state.

### Issues

- **In-contract ECRECOVER validation**: some smart contracts rely on the assumption that if you provide a signature that ECRECOVERs to a particular account, you own the account. If an EOA converts to a contract, and then changes its validation key, the original key would still have the ability to “represent” the account in those specific contexts. This can be solved by starting now to encourage all such projects to change to a model that uses [EIP-1271](https://eips.ethereum.org/EIPS/eip-1271) verification instead of ECRECOVER in the event that an account has code.
- **Not-yet-detectable accounts**: one challenge with mandatory conversion specifically is accounts that own assets (eg. ERC20s, ERC721s, but not ETH) but have not yet sent or received any transactions, so they are not reliably detectable by the protocol. The protocol would have to either retain the functionality to convert such accounts to default wallets forever, or there would need to be a cutoff period (eg. 4 years after deployment) after which accounts that have not yet instantiated themselves would be burned.
- **EOA-only checks for non-transferability**: some applications implement in-contract checks to allow only EOAs to interact with them. This is usually intended to enforce non-transferability. This is fundamentally a bad idea, and is incompatible with the goal of switching to smart contracts to improve safety. Hence, it should be discouraged, and applications should instead be encouraged to rely on original-owner recovery procedures to make transfers unenforceable.

## Reducing gas costs

ERC-4337 wallets face higher gas costs (~42000 gas for a basic ERC-4337 operation, compared to 21000 gas for a basic regular transaction) for a few reasons:

- Need to pay lots of individual storage read/write costs, which in the case of EOAs get bundled into a single 21000 gas payment:
  - Editing the storage slot that contains pubkey+nonce (~5000)
  - UserOperation calldata costs (~4500, reducible to ~2500 with compression)
  - ECRECOVER (~3000)
  - Warming the wallet itself (~2600)
  - Warming the recipient account (~2600)
  - Transferring ETH to the recipient account (~9000)
  - Editing storage to pay fees (~5000)
  - Access the storage slot containing the proxy (~2100) and then the proxy itself (~2600)
- On top of the above storage read/write costs, the contract needs to do “business logic” (unpacking the UserOperation, hashing it, shuffling variables, etc) that EOA transactions have handled “for free” by the Ethereum protocol
- Need to expend gas to pay for logs (EOAs don’t issue logs)
- One-time contract creation costs (~32000 base, plus 200 gas per code byte in the proxy, plus 20000 to set the proxy address)

Many of these issues will be resolved automatically in the Verkle tree [witness gas cost EIP](https://notes.ethereum.org/@vbuterin/witness_gas_cost_2) and the [write gas cost reform EIP](https://notes.ethereum.org/@vbuterin/verkle_write_gas_extension), which replaces a lot of storage costs with a more streamlined system. For example, the pubkey and nonce can be stored in slots 0…63 , which reduce the cost of accessing them to under 1000. Users would pay less fees for transferring ETH and paying fees, because the target account and the recipient account would only need to be warmed once.

There are further EIPs that could simplify things. For example:

- A voluntary ERC that bans slot 0 from being used by smart contract logic would allow it to be used to store the proxy, allowing it to benefit from the cheaper gas costs.
- A “code address” field could make proxying easier and lighter on gas.
- A “snappy compression” precompile could make it easier to use ABI objects without paying calldata gas costs for all the zero bytes.

This is an area that requires more research.

## Transaction inclusion lists

This is a longer-term concern, as it’s only really applicable once full in-protocol proposer/builder separation is enabled. The challenge is that we want proposers to be able to identify user operations that “deserve” to be included (ie. they pay enough fees), so that the protocol can force them to be included in the next block that has space for them.

This requires an enshrined in-protocol notion of “validation” and “execution”. For a user operation, there must be a defined way to `validate` the operation, and a defined way to `execute` the operation, such that if an operation is validated, an attempt to execute it is guaranteed to pay fees, unless the state that was read during validation is modified. These operations could be implemented either by enshrining ABI methods or by [adding dedicated EOF sections](https://notes.ethereum.org/@axic/account-abstraction-with-eof) if the [EOF EIPs](https://eips.ethereum.org/EIPS/eip-3540) are implemented.

Fortunately, **this does not require “enshrining ERC-4337”**; it requires enshrining a weaker concept that ERC-4337 supports, but other ERCs that differ in very substantial ways can easily support as well.

The reason is that much of the complexity of ERC-4337 and [EIP-2938](https://eips.ethereum.org/EIPS/eip-2938) has to do with solving a stronger DoS resistance problem: it should not be possible to make one operation that cancels hundreds of others, because that would allow cheaply spamming the mempool. This requires imposing restrictions on which accounts validation can access. Here, we can do something simpler: merely *record* which state objects were touched during validation, and don’t require inclusion if any of those state objects get edited.

This allows individual accounts to choose their own tradeoff between censorship resistance against flexibility. In the extreme, an account *could* pay fees during validation through Uniswap if it wanted to, but because anyone can send a transaction that affects the Uniswap state, such accounts would have effectively no censorship resistance guarantee.

A rough outline of a crList design would be:

- A proposal can include a `crList`, which specifies a list of operations to include, along with a list of (key, value) pairs of state objects read by each operation. The builder (or whoever else) accepts the `crList` must check that all operations pass thir `validate` check.
- That block is required to `execute` each operation in the `crList`, unless either the block does not have enough gas remaining, or the current state at time of execution has already edited one of the state objects read by that operation.

The remaining complexity of ERC-4337 would be used only for mempool safety. In principle, there could be multiple competing ERCs that achieve that goal in different ways, as long as they all follow the same `validate` and `execute` standard.

One weakness of this approach is that it’s not fully compatible with singature aggregation (as [ERC-4337 is trying to do](https://github.com/eth-infinitism/account-abstraction/pull/92)): because the protocol does not “understand” the aggregation scheme, it cannot force aggregation, and malicious builders could include unaggregated operations and force senders to pay the full gas for them. However, this is arguably only a moderate inconvenience.

## Probable roadmap

#### Short term

- Get ERC-4337 to full production. Ideally extend it with signature aggregation capabilities for rollup-friendliness.
- There should be easy-to-use browser wallets that use ERC-4337 wallets.
- Consider implementing [signature aggregation](https://github.com/eth-infinitism/account-abstraction/pull/92) and compression to make ERC-4337 more layer-2-friendly.
- Bootstrap the ERC-4337 ecosystem in layer-2 protocols, where gas costs are less of an issue.

#### Medium term

- Implement Verkle trees, add EIPs to reduce gas costs
- Add optional EOA-to-ERC-4337 conversion
- Add crList logic along with or soon after in-protocol PBS rollout

#### Long term

- Consider mandatory conversion

#### Possible alternatives

- Consider writing an EIP that enshrines ERC-4337 equivalent accounts and transactions at protocol level, and pushing for its adoption in L2s
- Use a censorship resistance solution that [works through axuliary blocks](https://notes.ethereum.org/@vbuterin/pbs_censorship_resistance#Solution-2-can-we-still-use-proposers-“hybrid-PBS”-but-only-for-inclusion-of-last-resort), removing the need for user operations to be legible to the Ethereum protocol



原文链接：https://notes.ethereum.org/@vbuterin/account_abstraction_roadmap
