> * 原文链接：https://soliditydeveloper.com/thegraph  作者：[MarkusWaas](https://soliditydeveloper.com/markuswaas)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# TheGraph：完善Web3数据查询

## 为什么我们需要TheGraph以及如何使用它


以前我们看过[Solidity的大图](https://soliditydeveloper.com/solidity-overview-2020/solidity-overview-2020)和[create-eth-app](https://github.com/PaulRBerg/create-eth-app)，它们之前已经提到过[TheGraph](https://thegraph.com/)。这次，我们将仔细研究TheGraph，它在去年已成为开发Dapps的标准堆栈的一部分。

但首先让我们看看传统方式下如何开发...

## 没有TheGraph时...

因此，让我们来看一个简单的示例，以进行说明。我们都喜欢游戏，所以想象一个简单的游戏，用户下注：

```js
pragma solidity 0.7.1;

contract Game {
    uint256 totalGamesPlayerWon = 0;
    uint256 totalGamesPlayerLost = 0;
    event BetPlaced(address player, uint256 value, bool hasWon);

    function placeBet() external payable {
        bool hasWon = evaluateBetForPlayer(msg.sender);

        if (hasWon) {
            (bool success, ) = msg.sender.call{ value: msg.value * 2 }('');
            require(success, "Transfer failed");
            totalGamesPlayerWon++;
        } else {
            totalGamesPlayerLost++;
        }

        emit BetPlaced(msg.sender, msg.value, hasWon);
    }
}
```


现在让我们在Dapp中说，我们要显示输/赢的游戏总数，并在有人再次玩时更新它。该方法将是：


1. 获取`totalGamesPlayerWon`。
2. 获取`totalGamesPlayerLost`。
3. 订阅`BetPlaced`事件。

如下代码所示，我们可以监听[Web3中的事件](https://learnblockchain.cn/docs/web3.js/web3-eth-contract.html#id58)，但这需要处理很多情况。

```js
GameContract.events.BetPlaced({
    fromBlock: 0
}, function(error, event) { console.log(event); })
.on('data', function(event) {
    // event fired
})
.on('changed', function(event) {
    // event was removed again
})
.on('error', function(error, receipt) {
    // tx rejected
});
```



现在，对于我们的简单示例来说，这还是可以的。但是，假设我们现在只想显示当前玩家输/赢的赌注数量。好吧，我们不走运，你最好部署一个新合约来存储这些值并获取它们。现在想象一个更复杂的智能合约和Dapp，事情会很快变得混乱。

![](https://img.learnblockchain.cn/2020/09/27/16011712681617.jpg)


你可以看到以上方案不是最佳的选择：

* 不适用于已部署的合约。
* 存储这些值需要额外的 gas 费用。
* 需要额外的调用来获取以太坊节点的数据。

![](https://img.learnblockchain.cn/2020/09/27/16011712859043.jpg)


现在让我们看一个更好的解决方案。


## 让我向你介绍GraphQL

首先让我们谈谈最初由Facebook设计和实现的[GraphQL](https://graphql.org/),。你可能熟悉传统的[Rest API 模型](https://en.wikipedia.org/wiki/Representational_state_transfer).，现在想像一下，你可以为所需的数据编写查询：

![](https://img.learnblockchain.cn/2020/09/27/16011713158848.jpg)

![graphql-querygif](https://img.learnblockchain.cn/2020/09/27/graphql-querygif.gif)


这两个图像几乎包含了GraphQL的本质。通过第二个图的查询，我们可以准确定义所需的数据，因此可以在一个请求中获得所有内容，仅此而已。GraphQL服务器处理所有所需数据的提取，因此前端消费者使用起来非常容易。如果你有兴趣对服务器如何精确地处理查询，[这里有一个很好的解释](https://www.apollographql.com/blog/graphql-explained-5844742f195e/)。





现在有了这些知识，让我们最终进入区块链部分和TheGraph。

## 什么是TheGraph？


区块链是一个去中心化的数据库，但是与通常的情况相反，我们没有该数据库的查询语言。检索数据的解决方案是痛苦或完全不可能的。TheGraph是用于索引和查询区块链数据的去中心化协议。你可能已经猜到了，它使用GraphQL作为查询语言。

![](https://img.learnblockchain.cn/2020/09/27/16011714281502.jpg)

示例始终是最好的理解方法，因此让我们在游戏合约示例中使用TheGraph。

## 如何创建Subgraph


定义如何为数据建立索引，称为Subgraph。它需要三个组件：

1. Manifest 清单(*subgraph.yaml*)
2. Schema 模式(*schema.graphql*)
3. Mapping 映射(*mapping.ts*)

### 清单(subgraph.yaml)

清单是我们的配置文件，它定义：

* 要索引哪些智能合约(地址，网络，ABI...)
* 监听哪些事件
* 其他要监听的内容，例如函数调用或块
* 被调用的映射函数(请参见下面的*mapping.ts*)

你可以在此处定义多个合约和处理程序。一个典型的设置是Truffle/Buidler项目代码库中有一个`subgraph`文件夹。然后，你可以轻松引用到ABI。

为了方便起见，你可能还需要使用[mustache](https://www.npmjs.com/package/mustache)之类的模板工具，然后创建一个`subgraph.template.yaml`并根据​​最新部署插入地址。有关更高级的示例设置，请参见例如：[Aave sub graph repo](https://github.com/aave/aave-protocol/tree/master/thegraph).

完整的文档可以在这里找到：[https://thegraph.com/docs/define-a-subgraph#the-subgraph-manifest](https://thegraph.com/docs/define-a-subgraph＃the-subgraph-manifest)。


```yaml
specVersion: 0.0.1
description: Placing Bets on Ethereum
repository: - Github link -
schema:
  file: ./schema.graphql
dataSources:
  - kind: ethereum/contract
    name: GameContract
    network: mainnet
    source:
      address: '0x2E6454...cf77eC'
      abi: GameContract
      startBlock: 6175244
    mapping:
      kind: ethereum/events
      apiVersion: 0.0.1
      language: wasm/assemblyscript
      entities:
        - GameContract
      abis:
        - name: GameContract
          file: ../build/contracts/GameContract.json
      eventHandlers:
        - event: PlacedBet(address,uint256,bool)
          handler: handleNewBet
      file: ./src/mapping.ts
```



### 模式(schema.graphql)


模式是GraphQL数据定义。它将允许你定义存在的实体及其类型。TheGraph支持的类型有

* `Bytes`(字节)

* `ID`

* `String`(`字符串`)

* `Boolean`(布尔值)

* `Int`(整型)

* `BigInt`(大整数)

* `BigDecimal`(大浮点数)


还可以使用实体作为类型来定义关系。在我们的示例中，我们定义了从玩家到下注的一对多关系。`！`表示该值不能为空。完整的文档可以在这里找到：[https://thegraph.com/docs/define-a-subgraph#the-graphql-schema](https://thegraph.com/docs/define-a-subgraph＃the-graphql-schema)。


```
type Bet @entity {
  id: ID!
  player: Player!
  playerHasWon: Boolean!
  time: Int!
}

type Player @entity {
  id: ID!
  totalPlayedCount: Int
  hasWonCount: Int
  hasLostCount: Int
  bets: [Bet]!
}
```



### 映射(mapping.ts)


TheGraph中的映射文件定义了将传入事件转换为实体的函数。它用TypeScript的子集[AssemblyScript](https://www.assemblyscript.org/)编写。这意味着可以将其编译为WASM([WebAssembly](https://webassembly.org/))，以更高效，更便携式地执行映射。

你将需要定义*subgraph.yaml*文件中命名的每个函数，因此在我们的例子中，我们只需要一个函数：`handleNewBet`。我们首先尝试从发起人地址作为ID加载为为`Player`实体。如果不存在，我们将创建一个新实体，并用起始值填充它。

然后，我们创建一个新的`Bet`实体。此ID为`event.transaction.hash.toHex()` + “-” + `event.logIndex.toString()`，确保始终为唯一值。仅使用哈希是不够的，因为有人可能在一次交易中会多次调用智能合约的`placeBet`函数。

最后我们可以更新Player实体的所有数据。不能将数组直接压入，而需要按如下所示进行更新。我们使用ID来代表下注。最后需要`.save()`来存储实体。


完整的文档可以在这里找到：[https://thegraph.com/docs/define-a-subgraph#writing-mappings](https://thegraph.com/docs/define-a-subgraph＃writing-mappings)。你还可以将日志输出添加到映射文件中，请参阅[这里](https://thegraph.com/docs/assemblyscript-api＃logging-and-debugging)。


```js
import { Bet, Player } from '../generated/schema';
import { PlacedBet }
    from '../generated/GameContract/GameContract';

export function handleNewBet(event: PlacedBet): void {
  let player = Player.load(
    event.transaction.from.toHex()
  );

  if (player == null) {
    // create if doesn't exist yet
    player = new Player(event.transaction.from.toHex());
    player.bets = new Array<string>(0);
    player.totalPlayedCount = 0;
    player.hasWonCount = 0;
    player.hasLostCount = 0;
  }

  let bet = new Bet(
    event.transaction.hash.toHex()
        + '-'
        + event.logIndex.toString()
  );
  bet.player = player.id;
  bet.playerHasWon = event.params.hasWon;
  bet.time = event.block.timestamp;
  bet.save();

  player.totalPlayedCount++;
  if (event.params.hasWon) {
    player.hasWonCount++;
  } else {
    player.hasLostCount++;
  }

  // update array like this
  let bets = player.bets;
  bets.push(bet.id);
  player.bets = bets;

  player.save();
}
```

## 在前端使用


使用类似[ApolloBoost](https://www.apollographql.com/docs/react/get-started/)的东西，你可以轻松地将TheGraph集成到ReactDapp(或[Apollo-Vue](https://apollo.vuejs.org/))中，尤其是当使用[React hooks和Apollo](https://www.apollographql.com/blog/apollo-client-now-with-react-hooks-676d116eeae2)时，获取数据就像编写单个代码一样简单的在组件中进行GraphQl查询，典型的代码如下所示：


```js
// See all subgraphs: https://thegraph.com/explorer/
const client = new ApolloClient({
  uri: "{{ subgraphUrl }}",
});

ReactDOM.render(
  <ApolloProvider client={client}>
    <App />
  </ApolloProvider>,
  document.getElementById("root"),
);
```


```js
const { loading, error, data } = useQuery(myGraphQlQuery);

React.useEffect(() => {
    if (!loading && !error && data) {
        console.log({ data });
    }
}, [loading, error, data]);
```


现在，我们可以编写例如这样的查询。这将带给我们

* 当前用户赢得了多少次
* 当前用户输了多少次
* 他之前所有下注的时间戳列表

仅需要对GraphQL服务器进行一个请求。

```
const myGraphQlQuery = gql`
    players(where: { id: $currentUser }) {
      totalPlayedCount
      hasWonCount
      hasLostCount
      bets {
        time
      }
    }
`;
```

![](https://img.learnblockchain.cn/2020/09/27/16011716047509.jpg)


但是，我们错过了最后一个难题，那就是服务器。你可以自己运行它，也可以使用托管服务。


## Graph服务器


### GraphExplorer：托管服务


最简单的方法是使用托管服务。按照[此处](https://thegraph.com/docs/deploy-a-subgraph)的说明部署subgraph。对于许多项目，你实际上可以在资源管理器中找到现有的subgraph，网址为[https://thegraph.com/explorer/](https://thegraph.com/explorer/).

![](https://img.learnblockchain.cn/2020/09/27/16011716343048.jpg)


### 运行自己的节点


或者，你可以运行自己的节点：[https://github.com/graphprotocol/graph-node#quick-start](https://github.com/graphprotocol/graph-node＃quick-start)。这样做的原因之一可能是使用托管服务不支持的网络。当前仅支持主网，Kovan，Rinkeby，Ropsten，Goerli，PoA-Core，xDAI和Sokol。

## 去中心化的未来

GraphQL还为新进入的事件进行“流”支持。TheGraph尚未完全支持，但即将发布。

缺少的一方面仍然是权力下放。TheGraph未来计划具有最终成为完全去中心化协议。这两篇很棒的文章更详细地说明了该计划：

* [https://thegraph.com/blog/the-graph-network-in-depth-part-1](https://thegraph.com/blog/the-graph-network-in-depth-part-1)
* [https://thegraph.com/blog/the-graph-network-in-depth-part-2](https://thegraph.com/blog/the-graph-network-in-depth-part-2)

两个关键方面是：

1. 用户将向索引器支付查询费用。
2. 索引器将使用Graph通证(GRT)。

![](https://img.learnblockchain.cn/2020/09/27/16011716662550.jpg)

------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。