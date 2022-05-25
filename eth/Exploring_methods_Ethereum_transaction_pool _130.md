原文链接：https://chainstack.com/exploring-the-methods-of-looking-into-ethereums-transaction-pool/

# Exploring the methods of looking into Ethereum’s transaction pool

![img](https://chainstack.com/wp-content/uploads/2020/12/image-1-1024x542.png)

## Introduction

The mempool of the Ethereum mainnet—called transaction pool or txpool—is the dynamic in-memory area where pending transactions reside before they are included in a block and thus become static.

The notion of a global txpool is a bit abstract as there is no single defined pool for all pending transactions. Instead, each node on the Ethereum mainnet has its own pool of transactions and, combined, they all form the global pool.

The thousands of pending transactions that enter the global pool by being broadcast on the network and before being included in a block are an always changing data set that’s holding millions of dollars at any given second.

There’s a lot that one can do here—and many do and make this txpool business a highly competitive market.

A few examples, listed in the order of inconspicuous to contentious:

- Yield farming — you can watch the transactions movement between DeFi applications to be one of the first to detect the yield farming profitability changes.
- Liquidity providing — you detect the potential liquidity movements in and out of DeFi applications and act on the changes.
- Arbitrage — you can detect the movement of transactions that will affect token prices at different DEXes and make your arbitrage trades based on that.
- Front running — you can automatically grab the existing pending transactions, simulate them to identify the potential profit if the transaction is executed, copy the transaction and swap the existing address with your own, and submit it with a higher miner fee so that your transaction gets executed on-chain before the one you are copying.
- Doing a MEV — MEV stands for Miner Extractable Value, and it’s based on that miners are theoretically free to include any transactions in the blocks and/or reorder them. This is a variation of the front running where instead of submitting your transaction with a higher fee to the same pool you picked it from, you get it directly into a block through a miner and bypass the pool.

To run any of the described scenarios, you need access to the Ethereum txpool, and you need the methods to retrieve the transactions from the txpool. While Chainstack has you covered with fast dedicated nodes for the former, this article focuses on all the ways you can look into the txpool.

## Retrieving pending transactions with Geth

Since pending transactions are your targets in the txpool space, we are now going to make this a structured effort and focus on answering the following questions while accompanying the answers with practical examples:

- How do I retrieve pending transactions?
- Why do I view global or local pending transactions?
- Can I view global pending transactions without txpool namespace?

There are a few ways to retrieve pending transactions.

- Filters
- Subscriptions
- Txpool API
- GraphQL API

Before we start, lets clarify a few things:

- **Global pending transactions** refer to pending transactions that are happening globally, which includes your newly created local pending transactions.
- **Local pending transactions** refer strictly to the transactions that you created on your local node. Note that you need ‘personal’ namespace enabled for Geth to send local transactions.
- **Pending transactions** refer to transactions that are pending due to various reasons, like extremely low gas, out of order nonce, etc.
- Chainstack is using **Geth (Go Ethereum)** client.

### Filters

When we create a filter on Geth, Geth will return a unique `filter_id`. Do note that this `filter_id` will only live for 5 minutes from the last query on that specific filter. If you query this filter after 5 minutes, the filter will not exist anymore.

#### Creating a pending transaction filter and retrieving data from it

##### cURL

**Create filter**

Request body:

```rust
'{"jsonrpc":"2.0","method":"eth_newPendingTransactionFilter","params":[],"id":1}'
```

Response body:

```json
{ "id":1, "jsonrpc": "2.0", "result": "0xb337f6e2f833ecffc6e9315ba06cd03d" }
```

**Access filter**

Request body:

```rust
'{"jsonrpc":"2.0","method":"eth_getFilterChanges","params":
["0xb337f6e2f833ecffc6e9315ba06cd03d"],"id":2}'
```

Response body:

```bash
{"jsonrpc":"2.0","id":1,"result":
["0x3c72691ca7997c4ce93f07b968304ab15bfed370b2755b32bf0104bfa581da3f", ...]}
```

##### Web3.js

Filter for pending transactions is not supported anymore. Please use [Subscriptions](https://chainstack.com/exploring-the-methods-of-looking-into-ethereums-transaction-pool/#subscriptions).

##### Web3.py

**Create filter**

```ini
pending_transaction_filter= web3.eth.filter('pending')
```

**Access filter**

```scss
print(pending_transaction_filter.get_new_entries())
```

### Common sources of confusion on filters

#### Web3.py and the pending argument

Why does web3.py have their input arguments as *pending* instead of a dictionary which contains the usual filter parameters like `fromBlock`, `toBlock`, `address`, `topics`.

This is because Web3 does the mapping internally. If we look at the [web3.py source code](https://github.com/ethereum/web3.py/blob/72457e6f9f3cb6d51fe492d1a65bed7904639760/web3/eth.py#L474), when web3.py receives a string pending, it will be mapped to `eth_newPendingTransactionFilter`, and when web3.py receives a dictionary, it is mapped to `eth_newFilter`.

To add to this, web3.py has `get_new_entries` as well as `get_all_entries` for filters but `get_all_entries` does not work in our case. This is because `eth_newPendingTransactionFilter` does not have `get_all_entries` available for it.

#### From latest block to pending block filter

Why doesn’t the following filter give me real-time pending transactions?

```python
web3.eth.filter({'fromBlock': 'latest', 'toBlock': 'pending'})
```

A filter only returns `new_entries()` when the state has changed. This specific filter state changes only when there is a new latest block or pending block. Thus, you will only receive changes when there is a new latest block or pending block, i.e. `(eth.getBlock('latest') / pending)`.

#### The getPendingTransactions filter

Why is the following giving me a different or empty result?

```scss
web3.eth.getPendingTransactions().then(console.log)
```

This function is mapped to `eth.pendingTransactions` which is a function to check local pending transactions and does not give you global transactions.

Based on the [Geth source code](https://github.com/ethereum/go-ethereum/blob/ead814616c094331915b03edd82d4200a7880178/internal/ethapi/api.go#L1700), only `pendingTransactions` that has its `from` field matching with your personal account will be shown.

### Subscriptions

Subscriptions is real-time streaming of data from server to client through WebSocket. You will need a constantly active connection to stream such events. You cannot use curl for this and have to use a WebSocket client like [websocat](https://github.com/vi/websocat) if you want to access it via command line. Once executed, a stream of pending transaction IDs will start flowing in.

For other supported subscriptions, check the Geth documentation: [Supported Subscriptions](https://geth.ethereum.org/docs/rpc/pubsub#supported-subscriptions).

#### Creating a subscription

##### Websocat

**Connect to node**

```perl
websocat wss://username:password@ws-nd-123-456-789.p2pify.com
```

**Create subscription**

Request body:

```json
{"id": 1, "method": "eth_subscribe", "params": ["newPendingTransactions"]}
```

Response body:

```json
{"jsonrpc":"2.0","id":1,"result":"0x2d4f3eb938cdb0b6fa9052de7c4da5de"}
```

**Incoming stream**

```bash
{"jsonrpc":"2.0","method":"eth_subscription","params":
{"subscription":"0x2d4f3eb938cdb0b6fa9052de7c4da5de","result":"0xee426dbaef2a432d0
433d5de600347e97b6a8a855daf8765c18cf1b7efc53461"}}
...
```

### Common sources of confusion on subscriptions

#### Web3.js ‘pendingTransactions’ and Geth ‘newPendingTransactions’

Web3.js has the `pendingTransactions` WebSocket calls mapped directly to `newPendingTransactions` in Geth JSON-RPC API.

To subscribe to pending transactions using web3.js, you must use `pendingTransactions`.

To subscribe to pending transactions using Geth JSON-RPC API, you must use `newPendingTransactions`.

For detailed instructions and code samples on how to subscribe using web3.js, see [Subscribing to global new pending transactions with web3.js](https://support.chainstack.com/hc/en-us/articles/900003426246-Subscribing-to-global-new-pending-transactions).

### Txpool API

Txpool is a Geth-specific API namespace that keeps pending and queued transactions in the local memory pool. Geth’s default is 4096 pending and 1024 queued transactions. However, [Etherscan reports](https://etherscan.io/txsPending) a much bigger number of pending transactions. If we view Geth’s txpool, we will not be able to get all of the transactions. Once the pool of 4096 is full, Geth replaces older pending values with newer pending transactions.

If you need a bigger pool to be stored on your node, the flag `--txpool.globalslots` can be adjusted to a higher value on [Geth CLI options](https://geth.ethereum.org/docs/interface/command-line-options). Do note that the larger the number, the bigger the payload size.

If you see your `txpool_status` to be empty, it can mean your node has not fully synced.

The txpool namespace is only supported on Chainstack dedicated nodes.

#### Use ‘txpool_content’ to get the pending and queued transactions

##### cURL

**Create filter**

Request body:

```json
{"jsonrpc":"2.0","method":"txpool_content","id":1}
```

Response body:

```bash
{ "jsonrpc": "2.0", "id": 1, "result": { "pending": {...}, "queued": {...} } }
```

##### Web3.js

`txpool_content` is not supported.

##### Web3.py

[Geth API](https://web3py.readthedocs.io/en/stable/web3.geth.html).

### GraphQL API

The biggest advantage of [using GraphQL](https://chainstack.com/graphql-on-ethereum-availability-on-chainstack-and-a-quick-rundown/) is that you can filter out the specific fields of the transaction that you want. The query in GraphQL goes through the elements within the txpool. Thus, its limitations are the same as the ones of txpool as stated above.

The following is an example which shows the information of a pending transaction.

Query example:

```css
query {
  pending {
    transactions {
      hash
      gas
      value
      gasPrice
      nonce
      r
      s
      v
      inputData
      status
      gasUsed
      cumulativeGasUsed
      from {
        address
      }
      to {
        address
      }
    }
  }
}
```

GraphQL API is currently supported on Chainstack [dedicated Ethereum nodes](https://chainstack.com/pricing/).

I hope this blog serves you well in understanding the various ways of retrieving pending transactions.

## Additional resources

- [Web3.js](https://web3js.readthedocs.io/)
- [Ethereum JSON-RPC API](https://eth.wiki/json-rpc/API)
- [Checking pending and queued transactions in your Ethereum node’s local pool](https://support.chainstack.com/hc/en-us/articles/900000820506-Checking-pending-and-queued-transactions-in-your-Ethereum-node-s-local-pool)
- [Subscribing to global new pending transaction with web3.js](https://support.chainstack.com/hc/en-us/articles/900003426246-Subscribing-to-global-new-pending-transactions)