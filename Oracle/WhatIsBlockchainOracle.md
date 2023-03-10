# 什么是区块链预言机?

## 了解预言机的类型和它们的实际使用案例

![8.png](https://img.learnblockchain.cn/attachments/2022/03/VHgpdWbA623d82b28c97a.png)

图片来自 https://chain.link/. 

理想情况下，预言机提供了一种简单的方式，可以将外在的（即“真实世界”或链外的）信息，例如货币对的价格、黄金价格或真正随机的数字，带入以太坊平台供智能合约使用。

区块链和智能合约无法访问链下的数据（即网络之外的数据）。然而，在几个合约协议中，获取来自外部世界的相关信息对于执行协议至关重要。

这就是区块链预言机的用武之地，因为它们提供链下和链上数据之间的链接。预言机在区块链生态系统中至关重要，因为它们扩大了智能合约可以操作的范围。如果没有预言机，智能合约的用途将非常有限，因为它们只能访问其网络内的数据。

重要的是要知道，区块链预言机不是数据源本身，而是查询、验证和认证外部数据源的层，然后传递该信息。预言机提供的数据有多种形式——价格信息、成功完成付款或传感器测量的温度。例如，让我们进行 API 调用：

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


## 去中心化预言机

去中心化的预言机与公共区块链有着相同的目标——避免交易对手风险。

它们提高了提供给智能合约的信息的可靠性，而不依赖单一的真实来源。智能合约查询多个预言机以确定数据的有效性和准确性——这就是为什么去中心化预言机也可以称为共识预言机。

[ChainLink](https://chainlinklabs.com/) 提出了一个去中心化的预言机网络，它由三个关键的智能合约（声誉合约、订单匹配合约和聚合合约）和一个数据提供者的链下注册表组成。

视频网址：https://www.youtube.com/watch?v=6e7DmuYmXKw



## 中心化预言机

中心化预言机由一个实体控制，是智能合约信息的唯一提供者。使用单一信息来源可能存在风险——合约的有效性完全取决于控制预言机的实体。来自不良行为者的任何恶意干扰都会直接影响智能合约。中心化预言机的主要问题是存在故障点，这使得合约对漏洞和攻击的弹性降低。如果你愿意信任一个中心化但可审计的服务，你可以去[Provable](https://provable.xyz/)。

## 预言机的类型

- **软件预言机:** 它处理来自在线资源的信息数据，如温度、商品价格、航班或火车延误等。软件预言机获取所需信息并将其推送到智能合约中。
- **硬件预言机:** 一些智能合约需要直接来自物理世界的信息，例如，运动传感器必须检测运动并将数据发送到供应链行业中的智能合约或 RFID 传感器。
- **入站预言机:** 它提供来自外部世界的数据。
- **出站预言机:** 它为智能合约提供了向外界发送数据的能力。 例如，智能锁在其区块链地址上接收付款并需要自动解锁。
- **基于共识的预言机:**  从[Augur](https://augur.net/)等人类共识和预测市场获取数据。 仅使用一种信息来源可能存在风险。 为了避免市场操纵，预测市场对预言机实施了评级系统。 为了进一步提高安全性，可以使用多个预言机的组合，例如，五分之三的预言机可以确定事件的结果。

## 实际使用案例

**Solidity:**  要使用价格数据，你的智能合约应引用`AggregatorV3Interface`，它定义了 Data Feeds 实现的外部功能。

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
11       * Network: Goerli
12       * Aggregator: ETH/USD
13       * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
14       */
15      constructor() {
16          priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
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


`latestRoundData` 函数返回代表最新价格数据的五个值。

**JavaScript:** 从以太坊上的 [ETH / USD feed](https://goerli.etherscan.io/address/0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e) 获得数据反馈。

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
> 
