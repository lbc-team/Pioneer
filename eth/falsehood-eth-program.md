> * 原文链接：https://gist.github.com/spalladino/a349f0ca53dbb5fc3914243aaf7ea8c6  作者：[Santiago Palladino](https://gist.github.com/spalladino)

# Falsehoods that Ethereum programmers believe

I recently stumbled upon [*Falsehoods programmers believe about time zones*](https://www.zainrizvi.io/blog/falsehoods-programmers-believe-about-time-zones/), which got a good laugh out of me. It reminded me of other great lists of falsehoods, such as about [names](https://shinesolutions.com/2018/01/08/falsehoods-programmers-believe-about-names-with-examples/) or [time](https://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time), and made me look for an equivalent for Ethereum. Having found none, here is my humble contribution to this [set](https://github.com/kdeldycke/awesome-falsehood).

## About Gas

### Calling [`estimateGas`](https://eth.wiki/json-rpc/API#eth_estimategas) will return the gas required by my transaction

Calling `estimateGas` will return the gas that your transaction would require *if it were mined now*. The current state of the chain may be very different to the state in which your tx will get mined. So when your tx is effectively included in a block, it may take a different code path, and may require a completely different amount of gas.

### But if the code executed is the same, then my transaction will require the same amount of gas

Nope. Even if you execute exactly the same instructions with the same arguments, gas cost may be different. For example, `SSTORE` (the operation of writing to storage) is much more expensive if you are writing to a new storage position versus to one that already has a nonzero value (see [EIP2200](https://eips.ethereum.org/EIPS/eip-2200)). This means that if you send two ERC20 token transfers to a fresh address, the first one will be much more expensive than the second one, even if both execute exactly the same code.

### But if the state is exactly the same, then my transaction will require the same amount of gas

Usually yes, unless you're unlucky enough to get a [hardfork that reprices some operations](https://eips.ethereum.org/EIPS/eip-1679) right in between. While this sounds convoluted, it means that you cannot safely hardcode gas limits for transactions in a dapp, unless you're ready to ship an update upon each hardfork.

### But if the code is the same, and the state is the same, and there are no hardforks in the horizon, then I can trust `estimateGas`... right?

Well, you can be sure that your transaction will take the same amount of gas, but you don't know whether it will do what you wanted it to do. The catch about gas estimation is that the node will try out your tx with different gas values, and return the lowest one for which your tx doesn't fail. But it only looks at your tx, not at any of the internal call it makes. This means that if the contract code you're calling has a try/catch that causes it not to revert if an internal call does, you can get a gas estimation that would be enough for the caller contract, but not for the callee.

This happens a lot in the context of multisig wallets: most multisigs mark an operation as executed [even upon failure](https://github.com/gnosis/safe-contracts/blob/94f9b9083790495f67b661bfa93b06dcba2d3949/contracts/GnosisSafe.sol#L158-L159), which means they cannot revert the outermost tx. So a naive gas estimation may return enough gas for the multisig code, but not for the operation you actually wanted to run. This is why Gnosis Safe [has a dedicated method just for gas estimation](https://github.com/gnosis/safe-contracts/blob/94f9b9083790495f67b661bfa93b06dcba2d3949/contracts/GnosisSafe.sol#L265-L288).

As a side note, this also makes it difficult to detect when something failed because of it ran out of gas. An internal call may run out of gas because it was allocated a small stipend, while the tx itself may have still plenty to spare. This means that checking gas usage versus gas limit of the tx is then not a reliable method for detecting out of gas errors.

### Screw it, I can always just send more gas

Most of the times yes, but remember that any contract can inspect the gas it received in a transaction. This makes it trivial to code a contract that would purposefully fail if it receives too much gas. I doubt there is any scenario where it makes sense to do this, except for proving this point.

## About Transactions

### A transaction will eventually get mined if it was accepted by a node

You wish. Network congestion in Ethereum causes gas prices to fluctuate a lot, so your transaction may be evicted from the mempool (the collective set of all transactions waiting to be mined) if gas prices rise, meaning you will need to resubmit it.

### But I can always resubmit my transaction with a slightly higher gas price

As long as you bump the price by the minimum amount required by the node you are interacting with (see [`txpool.pricebump`](https://geth.ethereum.org/docs/interface/command-line-options)), then yes. Otherwise, it will be rejected.

### And miners will always pick the transactions with the highest gas price

Not really. Miners can do whatever they want. They may inject their own transactions for their own profit, or even have an [off-protocol channel](https://samczsun.com/escaping-the-dark-forest/) where they agree to include txs based on other criteria.

But even if they prioritized just by profit from fees, filling up a block the optimal way is equivalent to the [knapsack problem](https://en.wikipedia.org/wiki/Knapsack_problem). Transactions cannot be broken into pieces, so it may be best to include two 5M-gas txs in a 10M-gas block rather than a single 6M-gas one, even if the two 5M-gas txs have a lower gas price than the 6M one.

### But if I resend exactly the same transaction with higher gas price, then they will pick up the replacement

Only if the replacement transaction reaches the miner before it has finalized the new block. This means that, if you send a replacement tx, you still need to monitor all the hashes from all the previous txs you have sent earlier for the same nonce.

## About Nonces

### I can get the nonce for my next transaction via [`getTransactionCount`](https://eth.wiki/json-rpc/API#eth_gettransactioncount)

Depends on the [block parameter](https://eth.wiki/json-rpc/API) you use. If you query for your transaction count on the `latest` block, you will not be accounting for any pending transactions you may have, and could accidentally overwrite any of them.

### I can get the nonce for my next transaction via `getTransactionCount('pending')`

While that works in most cases, you have no guarantee that the node you're querying has all your pending transactions on its mempool. If you had many txs in-flight, the node you are talking to may have dropped some of them - but they may still be somewhere out there!

## About Logs

### I can reliably monitor events by calling [`getLogs`](https://eth.wiki/json-rpc/API#eth_getlogs) continuously

While this is a surprisingly effective method (yay polling!), reorgs can really hurt you here. If you are polling for new logs on the `latest` block, you will never get notified if any of the blocks you have already seen got reorged, and you will never know if any of the events you have seen already needs to be readjusted.

### I can reliably monitor events by installing a [filter](https://eth.wiki/json-rpc/API#eth_newfilter)

Up until [two weeks ago](https://blog.infura.io/filters-support-over-https/), this was not an option in most cases, since Infura didn't have support for filters over http, which is what Metamask uses by default, and by extension 99% of the users of your dapp (note: I may have invented that 99%). Filters will notify you of not only new events, but also of events removed due to reorgs. However, this requires the infrastructure or node you are interacting with to stay online. If they happen to drop and lose filter state, you can miss out on reorged events.

### I can reliably monitor events via a [websocket subscription](https://infura.io/docs/ethereum/wss/eth-subscribe)

Great, now instead of having to trust that your node will stay online as with filters, you have to trust that your node will stay online, you will stay online, and the connection between you two will be reliable. I wonder how many times you have briefly dropped in Zoom calls this week...?

Now, I have to admit I had become a bit obsessed with the difficulty of reliably tracking events a while back, to the point of presenting a [lightning talk](https://www.youtube.com/watch?v=WYXIBUSU4UU) on Devcon 5 about this. If you are interested to read more, the [Rationale for EIP234](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-234.md) has a great writeup on these challenges, and [`ethereumjs-blockstream`](https://github.com/ethereumjs/ethereumjs-blockstream) tackles this very problem.

## About Contracts

### Smart contracts are immutable

You've come to the wrong neighborhood. I have about [30 pages](https://blog.openzeppelin.com/the-state-of-smart-contract-upgrades/) that say otherwise - and you thought *this* was a long read.

### Smart contracts without any funny `DELEGATECALL`s are immutable

A contract can just regular-`CALL` into a variable address and use the results as part of its computation or as instructions to alter its own state, effectively changing the code it is running.

### Smart contracts without any `DELEGATECALL`s or `CALL`s...

And `STATICCALL`s. Don't forget `STATICCALL`s!

### Smart contracts without any kind of `CALL`s are immutable

Unless it was deployed via `CREATE2` dynamically loading the runtime in its initcode, and can be self-destructed. In that case, the "owner" can destroy the contract and recreate it on the same address with a different code.

### Smart contracts without any kind of `CALL`s and not deployed via `CREATE2` are immutable

Unless it was deployed by a contract that was deployed via `CREATE2`. You need to check the entire chain of deployment until you get to an EOA to make sure there can be no funny business, or check for absence of self-destruct operations. [This article](https://medium.com/@jason.carver/defend-against-wild-magic-in-the-next-ethereum-upgrade-b008247839d2) goes deeper on this problem.

## About ERC20 Tokens

Don't even get me started. This needs a full article of its own. Just use [OpenZeppelin's SafeERC20](https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#SafeERC20) when interacting with a token (you can read more about it in [this article](https://soliditydeveloper.com/safe-erc20)), remember that `transfer` [may not grant the recipient all the tokens subtracted from the sender](https://medium.com/balancer-protocol/incident-with-non-standard-erc20-deflationary-tokens-95a0f6d46dea), and let's move on.

## About ETH

### ETH total supply can only increase

We all know that there are tons of unusable ETH sitting in EOAs whose private key has been lost, or [sent to the zero address](https://etherscan.io/address/0x0000000000000000000000000000000000000000) by accident, or [stuck in contracts that have no way to handle it](https://blog.openzeppelin.com/parity-wallet-hack-reloaded/) (sorry, I couldn't resist). But all in all, the ETH it's still there - just inaccessible.

But there is a way to [actually destroy ETH](https://ethereum.stackexchange.com/a/17617/8846). If you `selfdestruct` a contract and designate itself as the recipient of its funds, all ETH contained in it will be effectively erased. This means that, if are willing to burn an amount of ETH greater than the block reward, you can cause Ether to be deflationary for 10 seconds!

### I can write a contract that rejects all ETH transfers

You probably know that Solidity will take care of rejecting any ETH transfers to your contract if you don't declare any `payable` methods, to ensure that no funds will get stuck in there. However, it is still possible to send funds to a contract [without having it trigger any code](https://medium.com/coinmonks/ethernaut-lvl-7-walkthrough-how-to-selfdestruct-and-create-an-ether-blackhole-eb5bb72d2c57): either by making it the beneficiary of a `selfdestruct`, or by making it the beneficiary of the block reward. *Update: as @gorgos points out in the comments, it's possible to precalculate a contract deployment address, and send ETH to it before the contract is actually deployed.*

This also means that, if you were planning on keeping track of all ETH transfers you received in your contract, your total balance may be greater than the sum of all transfers you processed.

