原文链接：https://chainstack.com/exploring-the-methods-of-looking-into-ethereums-transaction-pool/

# 探索查看以太坊交易池的方法

![img](https://chainstack.com/wp-content/uploads/2020/12/image-1-1024x542.png)
 

## 介绍
以太坊主网的内存池（称为交易池或 txpool）是动态内存中的区域，在那有待处理的交易驻留在其中，之后它们会被静态地包含在一个块中。

全局 txpool 的概念有点抽象，因为它不是为所有待处理交易定义一个单独的池。 相反，以太坊主网上的每个节点都有自己的交易池，它们共同构成了全局池。

交易在网络上广播并在被包含在块中之前，进入全局交易池的数千个待处理交易是一个不断变化的数据集，在任何给定的秒内都有数百万美元的流水。

在这里可以做很多事情——很多人都可以做，并使这个 txpool 业务成为一个竞争激烈的市场。


几个例子，按从不显眼到有争议的顺序列出：

- 收益农场 —— 你可以观察 DeFi 应用程序之间的交易动态，成为最先检测到收益农场盈利能力变化的应用程序之一。

- 流动性提供 —— 你检测进出 DeFi 应用程序的潜在流动性变动并根据这些变化采取行动。


- 套利 —— 你可以检测会影响不同 DEX 代币价格的交易动向，并以此为基础进行套利交易。

- 抢跑 —— 你可以自动抓取现有的待处理交易，模拟它们以识别交易执行后的潜在利润，复制交易并将现有地址替换为自己的地址，并以更高的矿工费提交，以便你的交易得到在被你复制的交易之前在链上执行。

- 做 MEV —— MEV 代表矿工可提取价值，它基于矿工理论上可以自由地将任何交易包含在区块中和/或重新排序它们。这是抢跑的一种变体，你无需以更高的费用将交易提交到你从中选择的同一个池中，而是通过矿工将其直接放入一个区块并绕过交易池。

要运行任何以上描述的场景，你需要访问以太坊交易池，并且你需要从交易池中检索交易的方法。 虽然 Chainstack 为你介绍了前者的快速专用节点，但本文重点介绍了你可以查看 txpool 的所有方式。
 
## 使用 Geth 检索待处理的交易
由于待处理的交易是你在 txpool 空间中的目标，我们现在将使其成为结构化的工作，并专注于回答以下问题，同时附上实际示例的答案：

- 如何检索待处理的交易？
- 为什么要查看全局或本地待处理交易？
- 我可以在没有 txpool 命名空间的情况下查看全局待处理交易吗？
 

有几种方法可以检索待处理的交易。

- 过滤器
- 订阅
- 交易池 API
- GraphQL API

 

在我们开始之前，让我们搞清楚一些事情：

- **全局待处理交易**是指全局发生的待处理交易，包括你新创建的本地待处理交易。
- **本地待处理交易**严格指你在本地节点上创建的交易。 请注意，你需要为 Geth 启用“personal”命名空间才能发送本地交易。
- **待处理交易**是指由于各种原因而待处理的交易，例如极低的gas、乱序nonce等。
- Chainstack 正在使用 **Geth (Go Ethereum)** 客户端。


### 过滤器

当我们在 Geth 上创建过滤器时，Geth 将返回一个唯一的 `filter_id`。 请注意，从对该特定过滤器的最后一次查询开始，这个 `filter_id` 只会存在 5 分钟。 如果你在 5 分钟后查询此过滤器，则该过滤器将不再存在。

#### 创建待处理交易过滤器并从中检索数据


##### cURL

**创建过滤器**

请求体:

```rust
'{"jsonrpc":"2.0","method":"eth_newPendingTransactionFilter","params":[],"id":1}'
```

响应体:

```json
{ "id":1, "jsonrpc": "2.0", "result": "0xb337f6e2f833ecffc6e9315ba06cd03d" }
```


**访问过滤器**

请求体:

```rust
'{"jsonrpc":"2.0","method":"eth_getFilterChanges","params":
["0xb337f6e2f833ecffc6e9315ba06cd03d"],"id":2}'
```

响应体:

```bash
{"jsonrpc":"2.0","id":1,"result":
["0x3c72691ca7997c4ce93f07b968304ab15bfed370b2755b32bf0104bfa581da3f", ...]}
```

##### Web3.js

不再支持过滤待处理交易。 请使用[订阅](https://chainstack.com/exploring-the-methods-of-looking-into-ethereums-transaction-pool/#subscriptions).
 
##### Web3.py

**创建过滤器**

```ini
pending_transaction_filter= web3.eth.filter('pending')
```

**访问过滤器**

```scss
print(pending_transaction_filter.get_new_entries())
```
 
### 过滤器混淆的常见问题

#### Web3.py 和pending参数

为什么 web3.py 的输入参数是 *pending* 而不是包含常用过滤器参数，例如 `fromBlock`、`toBlock`、`address`、`topics`。


这是因为 Web3 在内部进行映射。 如果我们查看 [web3.py 源代码](https://github.com/ethereum/web3.py/blob/72457e6f9f3cb6d51fe492d1a65bed7904639760/web3/eth.py#L474)，当 web3.py 收到一个待处理的字符串时，它 会映射到 `eth_newPendingTransactionFilter`，当 web3.py 收到字典参数时，会映射到 `eth_newFilter`。
 
除此之外，web3.py 有 `get_new_entries` 和 `get_all_entries` 用于过滤器，但 `get_all_entries` 在我们的例子中不起作用。 这是因为 `eth_newPendingTransactionFilter` 没有可用的 `get_all_entries`。
 
#### 从最新块到待处理块的过滤器

为什么下面的过滤器没有给我实时的待处理交易？


```python
web3.eth.filter({'fromBlock': 'latest', 'toBlock': 'pending'})
```
过滤器仅在状态更改时返回`new_entries()`。 仅当有新的最新块或待处理块时，此特定过滤器状态才会更改。 因此，只有在有新的最新块或待处理块时，你才会收到更改，即 `(eth.getBlock('latest') / pending)`。

#### getPendingTransactions 过滤器

为什么给我一个不同或空的结果？

```scss
web3.eth.getPendingTransactions().then(console.log)
```
 
此函数映射到 `eth.pendingTransactions`，这是一个检查本地待处理交易的函数，不会为你提供全局交易。

基于 [Geth 源代码](https://github.com/ethereum/go-ethereum/blob/ead814616c094331915b03edd82d4200a7880178/internal/ethapi/api.go#L1700)，只有 `pendingTransactions` 的 `from` 字段匹配 将显示你的个人帐户。
 

### 订阅

订阅是通过 WebSocket 从服务器到客户端的实时数据流。 你将需要一个持续活跃的连接来流式传输此类事件。 你不能为此使用 curl，如果你想通过命令行访问它，则必须使用像 [websocat](https://github.com/vi/websocat) 这样的 WebSocket 客户端。 执行后，待处理的交易 ID 流将开始流入。
 

对于其他可支持的订阅内容，请查看 Geth 文档：[支持的订阅](https://geth.ethereum.org/docs/rpc/pubsub#supported-subscriptions)。

#### 创建订阅

##### Websocat

**连接节点**

```perl
websocat wss://username:password@ws-nd-123-456-789.p2pify.com
```
**创建订阅**

请求体:

```json
{"id": 1, "method": "eth_subscribe", "params": ["newPendingTransactions"]}
```
响应体:

```json
{"jsonrpc":"2.0","id":1,"result":"0x2d4f3eb938cdb0b6fa9052de7c4da5de"}
```
 **传入流**

```bash
{"jsonrpc":"2.0","method":"eth_subscription","params":
{"subscription":"0x2d4f3eb938cdb0b6fa9052de7c4da5de","result":"0xee426dbaef2a432d0
433d5de600347e97b6a8a855daf8765c18cf1b7efc53461"}}
...
```
 
### 使用订阅易混淆的常见问题

#### Web3.js 'pendingTransactions' 和 Geth 'newPendingTransactions'

Web3.js 将 `pendingTransactions` WebSocket 调用直接映射到 Geth JSON-RPC API 中的 `newPendingTransactions`。

要使用 web3.js 订阅待处理交易，你必须使用 `pendingTransactions`。
 
要使用 Geth JSON-RPC API 订阅待处理交易，你必须使用`newPendingTransactions`。

有关如何使用 web3.js 订阅的详细说明和代码示例，请参阅[使用 web3.js 订阅全局新的待处理交易](https://support.chainstack.com/hc/en-us/articles/900003426246-Subscribing -to-global-new-pending-transactions)。

### Txpool API
Txpool 是一个特定于 Geth 的 API 命名空间，它在本地内存池中保存待处理和排队的交易。 Geth 的默认值为 4096 个待处理交易和 1024 个排队交易。 但是，[Etherscan 报告](https://etherscan.io/txsPending) 待处理的交易数量要大得多。 如果我们查看 Geth 的 txpool，我们将无法获得所有交易。 一旦 4096 池已满，Geth 就会用新的待处理交易替换旧的待处理值。


如果你需要在节点上存储更大的池，可以在 [Geth CLI 选项](https://geth.ethereum.org/docs/interface/) 上将标志 `--txpool.globalslots` 调整为更高的值 命令行选项）。 请注意，数字越大，有效载荷越大。

如果你看到 `txpool_status` 为空，则可能意味着你的节点尚未完全同步。

txpool 命名空间仅在 Chainstack 专用节点上受支持。


#### 使用‘txpool_content’获取待处理和排队的交易

##### cURL


**创建过滤器**

请求体:

```json
{"jsonrpc":"2.0","method":"txpool_content","id":1}
```

响应体:

```bash
{ "jsonrpc": "2.0", "id": 1, "result": { "pending": {...}, "queued": {...} } }
```

##### Web3.js

`txpool_content` 不被支持.

##### Web3.py

[Geth API](https://web3py.readthedocs.io/en/stable/web3.geth.html).

### GraphQL API

[使用 GraphQL](https://chainstack.com/graphql-on-ethereum-availability-on-chainstack-and-a-quick-rundown/) 的最大优点是可以过滤掉你认为是具体的交易字段。 GraphQL 中的查询会遍历 txpool 中的元素。 因此，它的限制与上述 txpool 的限制相同。

以下是显示待处理交易信息的示例。


查询实例:

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

Chainstack [专用以太坊节点](https://chainstack.com/pricing/) 目前支持 GraphQL API。

我希望这个博客能很好地帮助你了解检索待处理交易的各种方式。


## 额外信息

- [Web3.js](https://web3js.readthedocs.io/)
- [以太坊 JSON-RPC API](https://eth.wiki/json-rpc/API)
- [检查以太坊节点本地池中的待处理和排队交易](https://support.chainstack.com/hc/en-us/articles/900000820506-Checking-pending-and-queued-transactions-in-your-Ethereum -node-s-local-pool)
- [使用 web3.js 订阅全局新待处理交易](https://support.chainstack.com/hc/en-us/articles/900003426246-Subscribing-to-global-new-pending-transactions)
