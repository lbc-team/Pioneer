# What Is Blockchain Oracle?

## Know the types of oracles and their practical use cases

![8.png](https://img.learnblockchain.cn/attachments/2022/03/VHgpdWbA623d82b28c97a.png)

Image by https://chain.link/. Edited by author

Oracles, ideally, provide a simple way of getting extrinsic (i.e., “real-world” or off-chain) information, like the price of currency pairs, the price of gold, or truly random numbers, onto the Ethereum platform for smart contracts to use.

Blockchains and smart contracts cannot access off-chain data (data that’s outside of the network). However, for several contractual agreements, it’s vital to possess relevant information from the outside world to execute the agreement.

This is where blockchain oracles came in, as they provide a link between off-chain and on-chain data. Oracles are essential within the blockchain ecosystem because they broaden the scope in which smart contracts can operate. Without it, smart contracts would’ve very limited use as they would only have access to data from within their networks.

It’s important to know that a blockchain oracle is not the data source itself, but rather the layer that queries, verifies, and authenticates external data sources and then relays that information. The data provided by oracles comes in many forms — price information, the successful completion of a payment, or the temperature measured by a sensor. For example, lets make an API call:

```
 1  // SPDX-License-Identifier: MIT
 2  pragma solidity ^0.8.7;
 3
 4  import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
 5
 6  /**
 7   * Request testnet LINK and ETH here: https://faucets.chain.link/
 8   * Find information on LINK Token Contracts and get the latest ETH  and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 9   */
10
11  /**
12   * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
13   * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
14   */
15  contract APIConsumer is ChainlinkClient {
16      using Chainlink for Chainlink.Request;
17  
18      uint256 public volume;
19    
20      address private oracle;
21      bytes32 private jobId;
22      uint256 private fee;
23    
24      /**
25       * Network: Kovan
26       * Oracle: 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8 (Chainlink Devrel   
27       * Node)
28       * Job ID: d5270d1c311941d0b08bead21fea7747
29       * Fee: 0.1 LINK
30       */
31      constructor() {
32          setPublicChainlinkToken();
33          oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
34          jobId = "d5270d1c311941d0b08bead21fea7747";
35          fee = 0.1 * 10 ** 18; // (Varies by network and job)
36      }
37    
38      /**
39       * Create a Chainlink request to retrieve API response, find the target
40       * data, then multiply by 1000000000000000000 (to remove decimal places from data).
41       */
42      function requestVolumeData() public returns (bytes32 requestId) 
43      {
44          Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
45        
46          // Set the URL to perform the GET request on
47          request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");
48        
49          // Set the path to find the desired data in the API response, where the response format is:
50          // {"RAW":
51          //   {"ETH":
52          //    {"USD":
53          //     {
54          //      "VOLUME24HOUR": xxx.xxx,
55          //     }
56          //    }
57          //   }
58          //  }
59          request.add("path", "RAW.ETH.USD.VOLUME24HOUR");
60        
61          // Multiply the result by 1000000000000000000 to remove decimals
62          int timesAmount = 10**18;
63          request.addInt("times", timesAmount);
64        
65          // Sends the request
66          return sendChainlinkRequestTo(oracle, request, fee);
67      }
68     
69      /**
70       * Receive the response in the form of uint256
71       */ 
72    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId)
73      {
74          volume = _volume;
75      }
76
77      // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
78  }
79

```


## Decentralized Oracles

Decentralized oracles share quite the same objectives as public blockchains — avoiding counterparty risk.

They increase the reliability of the information provided to smart contracts without relying on a single source of truth. The smart contract queries multiple oracles to determine the validity and accuracy of the data — this is why decentralized oracles can also be referred to as consensus oracles.

[ChainLink](https://chainlinklabs.com/) has proposed a decentralized oracle network that consists of three key smart contracts — a reputation contract, an order-matching contract, and an aggregation contract — and an off-chain registry of data providers.

视频网址：https://www.youtube.com/watch?v=6e7DmuYmXKw



## Centralized Oracles

A centralized oracle is controlled by one entity and is the sole provider of information for the smart contract. Using one source of information can be risky — the effectiveness of the contract depends entirely on the entity controlling the oracle. Any malicious interference from a bad actor will affect directly the smart contract. The main problem with centralized oracles is the existence of a point of failure, which makes the contracts less resilient to vulnerabilities and attacks. If you are willing to trust a centralized but auditable service, you can go to [Provable](https://provable.xyz/).

## Types of Oracles

- **Software Oracles:** It handles information data that comes from online sources, like temperature, prices of commodities and goods, flight or train delays, etc. The software oracle fetches needed information and pushes it into the smart contract.
- **Hardware Oracles:** Some smart contracts need information directly from the physical world, for example, movement sensors must detect movement and send the data to a smart contract or RFID sensors in the supply chain industry.
- **Inbound Oracles:** It provides data from the external world.
- **Outbound Oracles:** It provides smart contracts the ability to send data to the outside world. For example, a smart lock receives payment on its blockchain address and needs to unlock automatically.
- **Consensus-based Oracles:** They get their data from human consensus and prediction markets like [Augur](https://augur.net/). Using only one source of information might be risky. To avoid manipulation in the market, prediction markets implement a rating system for oracles. For further security, a combination of several oracles may be used, where, for example, three out of five oracles could determine the outcome of an event.

## Practical Use Case

**Solidity:** To consume price data, your smart contract should reference `AggregatorV3Interface`, which defines the external functions implemented by Data Feeds.

```
 1
 2  pragma solidity ^0.8.7;
 3  
 4  import   "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
 5
 6  contract PriceConsumerV3 {
 7
 8      AggregatorV3Interface internal priceFeed;
 9
10      /**
11       * Network: Kovan
12       * Aggregator: ETH/USD
13       * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
14       */
15      constructor() {
16          priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
17      }
18
19      /**
20       * Returns the latest price
21       */
22      function getLatestPrice() public view returns (int) {
23          (
24              uint80 roundID, 
25              int price,
26              uint startedAt,
27              uint timeStamp,
28              uint80 answeredInRound
29          ) = priceFeed.latestRoundData();
30          return price;
31      }
32  }
```


The `latestRoundData` function returns five values representing the latest price data.

**JavaScript:** To retrieve feed data from the [ETH / USD feed](https://kovan.etherscan.io/address/0x9326BFA02ADD2366b30bacB125260Af641031331) on the Ethereum network.

```
 1  const Web3 = require("web3") // for nodejs only
 2  const web3 = new Web3("https://kovan.infura.io/v3/<infura_project_id>")
 3  const aggregatorV3InterfaceABI = [{ "inputs": [], "name": "decimals", "outputs": [{ "internalType": "uint8", "name": "", "type": "uint8" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "description", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "uint80", "name": "_roundId", "type": "uint80" }], "name": "getRoundData", "outputs": [{ "internalType": "uint80", "name": "roundId", "type": "uint80" }, { "internalType": "int256", "name": "answer", "type": "int256" }, { "internalType": "uint256", "name": "startedAt", "type": "uint256" }, { "internalType": "uint256", "name": "updatedAt", "type": "uint256" }, { "internalType": "uint80", "name": "answeredInRound", "type": "uint80" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "latestRoundData", "outputs": [{ "internalType": "uint80", "name": "roundId", "type": "uint80" }, { "internalType": "int256", "name": "answer", "type": "int256" }, { "internalType": "uint256", "name": "startedAt", "type": "uint256" }, { "internalType": "uint256", "name": "updatedAt", "type": "uint256" }, { "internalType": "uint80", "name": "answeredInRound", "type": "uint80" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "version", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }]
 4  const addr = "0x9326BFA02ADD2366b30bacB125260Af641031331"
 5  const priceFeed = new web3.eth.Contract(aggregatorV3InterfaceABI, addr)
 6  priceFeed.methods.latestRoundData().call()
 7      .then((roundData) => {
 8          // Do something with roundData
 9          console.log("Latest Round Data", roundData)
10      })
```



> 原文链接：https://betterprogramming.pub/what-is-blockchain-oracle-ce2ad4a46c08
