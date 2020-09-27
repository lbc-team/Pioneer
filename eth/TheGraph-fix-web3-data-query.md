
# TheGraph: Fixing the Web3 data querying

## Why we need TheGraph and how to use it


Previously we looked at the [big picture of Solidity](/solidity-overview-2020) and the [create-eth-app](https://github.com/PaulRBerg/create-eth-app) which already mentioned [TheGraph](https://thegraph.com/) before. This time we will take a closer look at TheGraph which essentially became part of the standard stack for developing Dapps in the last year.

But let's first see how we would do things the traditional way...

## Without TheGraph...

So let's go with a simple example for illustration purposes. We all like games, so imagine a simple game with users placing bets:

```
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


Now let's say in our Dapp, we want to display total the total games lost/won and also update it whenever someone plays again. The approach would be:


1. Fetch `totalGamesPlayerWon`.
2. Fetch `totalGamesPlayerLost`.
3. Subscribe to `BetPlaced` events.

We can listen to the [event in Web3](https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html#contract-events) as shown on the right, but it requires handling quite a few cases.

```
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

Now this is still somewhat fine for our simple example. But let's say we want to now display the amounts of bets lost/won only for the current player. Well we're out of luck, you better deploy a new contract that stores those values and fetch them. And now imagine a much more complicated smart contract and Dapp, things can get messy quickly.

![](https://img.learnblockchain.cn/2020/09/27/16011712681617.jpg)


You can see how this is not optimal:

* Doesn't work for already deployed contracts.
* Extra gas costs for storing those values.
* Requires another call to fetch the data for an Ethereum node.

![](https://img.learnblockchain.cn/2020/09/27/16011712859043.jpg)


Now let's look at a better solution.


## Let me introduce you to GraphQL

First let's talk about [GraphQL](https://graphql.org/), originally designed and implemented by Facebook. You might be familiar with the traditional [Rest API model](https://en.wikipedia.org/wiki/Representational_state_transfer). Now imagine instead you could write a query for exactly the data that you wanted:

![](https://img.learnblockchain.cn/2020/09/27/16011713158848.jpg)

![graphql-querygif](https://img.learnblockchain.cn/2020/09/27/graphql-querygif.gif)


The two images pretty much capture the essence of GraphQL. With the query on the right we can define exactly what data we want, so there we get everything in one request and nothing more than exactly what we need. A GraphQL server handles the fetching of all data required, so it is incredibly easy for the frontend consumer side to use. [This is a nice explanation](https://www.apollographql.com/blog/graphql-explained-5844742f195e/) of how exactly the server handles a query if you're interested.

Now with that knowledge, let's finally jump into blockchain space and TheGraph.


## What is TheGraph?


A blockchain is a decentralized database, but in contrast to what's usually the case, we don't have a query language for this database. Solutions for retrieving data are painful or completely impossible. TheGraph is a decentralized protocol for indexing and querying blockchain data. And you might have guessed it, it's using GraphQL as query language.

![](https://img.learnblockchain.cn/2020/09/27/16011714281502.jpg)

Examples are always the best to understand something, so let's use TheGraph for our GameContract example.


## How to create a Subgraph


The definition for how to index data is called subgraph. It requires three components:

1. Manifest (*subgraph.yaml*)
2. Schema (*schema.graphql*)
3. Mapping (*mapping.ts*)


### Manifest (subgraph.yaml)

The manifest is our configuration file and defines:

* which smart contracts to index (address, network, ABI...)
* which events to listen to
* other things to listen to like function calls or blocks
* the mapping functions being called (see *mapping.ts* below)

You can define multiple contracts and handlers here. A typical setup would have a `subgraph` folder inside the Truffle/Buidler project with its own repository. Then you can easily reference the ABI.

For convenience reasons you also might want to use a template tool like [mustache](https://www.npmjs.com/package/mustache). Then you create a `subgraph.template.yaml` and insert the addresses based on the latest deployments. For a more advanced example setup, see for example the [Aave subgraph repo](https://github.com/aave/aave-protocol/tree/master/thegraph).

And the full documentation can be seen here: [https://thegraph.com/docs/define-a-subgraph#the-subgraph-manifest](https://thegraph.com/docs/define-a-subgraph#the-subgraph-manifest).


```
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



### Schema (schema.graphql)


The schema is the GraphQL data definition. It will allow you to define which entities exist and their types. Supported types from TheGraph are

* `Bytes`

* `ID`

* `String`

* `Boolean`

* `Int`

* `BigInt`

* `BigDecimal`


You can also use entities as type to define relationships. In our example we define a 1-to-many relationship from player to bets. The `!` means the value can't be empty. The full documentation can be seen here: [https://thegraph.com/docs/define-a-subgraph#the-graphql-schema](https://thegraph.com/docs/define-a-subgraph#the-graphql-schema).


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



### Mapping (mapping.ts)


The mapping file in TheGraph defines our functions that transform incoming events into entities. It is written in [AssemblyScript](https://www.assemblyscript.org/), a subset of Typescript. This means it can be compiled into WASM ([WebAssembly](https://webassembly.org/)) for more efficient and portable execution of the mapping.

You will need to define each function named in the *subgraph.yaml* file, so in our case we need only one: `handleNewBet`. We first try to load the `Player` entity from the sender address as id. If it doesn't exist, we create a new entity and fill it with starting values.

Then we create a new `Bet` entity. The id for this will be `event.transaction.hash.toHex() + "-" + event.logIndex.toString()` ensuring always a unique value. Using only the hash isn't enough as someone might be calling the `placeBet` function several times in one transaction via a smart contract.

Lastly we can update the Player entity will all the data. Arrays cannot be pushed to directly, but need to be updated as shown here. We use the id to reference the bet. And `.save()` is required at the end to store an entity.


The full documentation can be seen here: [https://thegraph.com/docs/define-a-subgraph#writing-mappings](https://thegraph.com/docs/define-a-subgraph#writing-mappings). You can also add logging output to the mapping file, see [here](https://thegraph.com/docs/assemblyscript-api#logging-and-debugging).


```
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


## Using it in the Frontend


Using something like [Apollo Boost](https://www.apollographql.com/docs/react/get-started/), you can easily integrate TheGraph in your React Dapp (or [Apollo-Vue](https://apollo.vuejs.org/)). Especially when using [React hooks and Apollo](https://www.apollographql.com/blog/apollo-client-now-with-react-hooks-676d116eeae2), fetching data is as simple as writing a single GraphQl query in your component. A typical setup might look like this:


```
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


```
const { loading, error, data } = useQuery(myGraphQlQuery);

React.useEffect(() => {
    if (!loading && !error && data) {
        console.log({ data });
    }
}, [loading, error, data]);
```


And now we can write for example a query like this. This will fetch us

* how many times current user has won
* how many times current user has lost
* a list of timestamps with all his previous bets

    All in one single request to the GraphQL server.

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


But we're missing one last piece of the puzzle and that's the server. You can either run it yourself or use the hosted service.


## TheGraph server


### Graph Explorer: The hosted service


The easiest way is to use the hosted service. Follow the instructions [here](https://thegraph.com/docs/deploy-a-subgraph) to deploy a subgraph. For many projects you can actually find exisiting subgraphs in the explorer at [https://thegraph.com/explorer/](https://thegraph.com/explorer/).

![](https://img.learnblockchain.cn/2020/09/27/16011716343048.jpg)


### Running your own node


Alternatively you can run your own node: [https://github.com/graphprotocol/graph-node#quick-start](https://github.com/graphprotocol/graph-node#quick-start). One reason to do this might be using a network that's not supported by the hosted service. Currently supported are mainnet, Kovan, Rinkeby, Ropsten, Goerli, PoA-Core, xDAI and Sokol.


## The decentralized future

GraphQL supports streams as well for newly incoming events. This is not yet fully supported by TheGraph, but it will be released soon.

One missing aspect though is still decentralization. TheGraph has future plans for eventually becoming a fully decentralized protocol. Those are two great articles explaining the plan in more detail:

* [https://thegraph.com/blog/the-graph-network-in-depth-part-1](https://thegraph.com/blog/the-graph-network-in-depth-part-1)
* [https://thegraph.com/blog/the-graph-network-in-depth-part-2](https://thegraph.com/blog/the-graph-network-in-depth-part-2)

Two key aspects are:

1. Users will be paying the indexers for queries.
2. Indexers will be staking Graph Tokens (GRT).

![](https://img.learnblockchain.cn/2020/09/27/16011716662550.jpg)


原文链接：https://soliditydeveloper.com/thegraph
作者：[Markus Waas](https://soliditydeveloper.com/markuswaas)