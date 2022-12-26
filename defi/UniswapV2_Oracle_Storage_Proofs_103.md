原文链接：https://medium.com/@epheph/using-uniswap-v2-oracle-with-storage-proofs-3530e699e1d3

# 使用带有存储证明的Uniswap V2 预言机

[Uniswap V2 发布了许多新特性](https://uniswap.org/blog/launch-uniswap-v2/), 包括:

- 代币：代币流动性对（不再需要ETH/DAI和ETH/MKR这种方式接力， Uniswap V2可以原生支持 MKR/DAI了）
- 内建对多跳兑换路由的支持（例如可以通过 ETH->DAI->MKR->USDT, 获取ETH->USDT的价格）
- 兼容ERC777
- **价格累积预言机**

在本文中，我们将讨论“价格累积预言机”的工作原理和使用方法。 并且我们将介绍一个可将预言机集成到你自己以太坊项目中的Solidity库。本文将假设你对Uniswap此类恒定乘积市场有深入的了解。如果你不清楚下面即将讨论的定价机制，请从这篇[[优秀\]的Uniswap 文档](https://uniswap.org/docs/v2/#how-it-all-works)开始。

*如果您已经了解本文的主旨所在，可以在此处获得代码示例和solidity库：* [*https://github.com/Keydonix/uniswap-oracle*](https://github.com/Keydonix/uniswap-orcale)
*如果您想了解更多信息，请继续阅读！*

我们通常认为, 预言机可以看做一个(译者注:信息转移系统), 它从可信的/被绑定的市场参与者(例如Maker Price Feed、ChainLink）的多笔交易中获取链下信息, 然后将这些信息公布到区块链上. 但是Uniswap V2预言机提供这些有用的信息时, 不需要任何特定的(译者注:和可信外部参与者的)交易。相反，每个(译者注:uniswap上的)兑换交易都会为这个预言机贡献信息。

为了说明带有新预言机的Uniswap V2解决了什么问题，我们首先看看Uniswap V1 的问题所在.

![img](https://img.learnblockchain.cn/attachments/2022/06/7opSP92C62b3d943b5411.jpeg)

#  别把Uniswap V1用作预言机

Uniswap团队从未将 Uniswap V1 宣传为可行的链上预言机。正是由于 Uniswap 简单、无需许可、链上且面向市场的功能，才吸引了富有创造力的人将其作为一个整体使用。 Uniswap V1 预言机的代码很简单:

```
uint256 tokenPrice = token.balanceOf(uniswapMarket) / address(uniswapMarket).balance
```

由于 Uniswap V1 市场的当前“价格”只是代币余额和以太币余额的比率，因此计算简单且节省燃料。然而，问题在于它非常地不安全。事实已经有许多因使用 Uniswap V1 作为预言机而导致的相关攻击，但最引人注目的攻击可能是 [bZx/Fulcrum/Compound 攻击，该攻击在 24 小时内净赚了近 100 万美元。](https://cointelegraph.com/news/are-the-bzx-flash-loan-attacks-signaling-the-end-of-defi）

Uniswap V1 的问题在于,其价格流是瞬间的，并且*很容易在短时间内(包括瞬间)被操纵*。让我们看看下面的伪代码示例：

```
//  发送100个 ether, 接受一些token
uniswapMarket.ethToTokenSwapInput.value(100 ether)(100 ether);exploitTarget.doSomethingThatUsesUniswapV1AsOracle();

// 返还上一步我们接收到的token
uniswapMarket.tokenToEthSwapInput(token.balanceOf(address(this));
```

在上述攻击中，你将向流动性提供者支付非常小的以太币费用，大约 0.6 ETH（双向 0.3%）。然而，当调用 exploitTarget 时，它会认为代币比实际更有价值。如果 exploitTarget 使用 Uniswap V1预言机 来确保你存入的抵押品的价值足以提取其他一些代币，那么该系统将允许你提取比存款凭证多得多的借出代币。

# Uniswap V2 如何扮演预言机


在上面的例子中，Uniswap V1 读取的价格瞬间就会发生变化, 因此存在问题。 V2部署了一个聪明的(译者注:预言机)系统，它把价格-时间数据流记录在链上. 因而(译者注:攻击者)在短时间内操纵价格的成本很高，而且*不可能在单个交易中进行价格操纵*。通过使用“累积”的价格-时间值，价格的可用时间被加权到一个特殊的值中，每次代币交换都会花费少量燃料来同步这些值。

这是 Uniswap market代码的一个片段：

*注意：与 V1 不同，V2是两个代币之间的市场。在内部，一对代币中的两个代币被分别表示为* `token0` *和* `token1`*。它们的余额是* `reserve0` *和* `reserve1`*.* [*Uniswap Docs 有更多关于代币排序的信息*](https://uniswap.org/docs/v2/technical-considerations/pair-addresses/)*.*

```
contract UniswapV2Pair {
  // Contract Storage Variables:
  uint public price0CumulativeLast;
  uint public price1CumulativeLast;
...
  // The only place these storage variables are updated:
  function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
    uint32 timeElapsed = blockTimestamp - blockTimestampLast;
    if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
      price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
      price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
    }
    blockTimestampLast = blockTimestamp;
  }
}
```

`price(0|1)CumulativeLast` 是累积“价格-时间”的独立存储变量。 `UQ112x112` 使代码有点难以阅读，但在概念上并不重要；它仅作为高精度除法的包装器。这些 cumulativeLast 值的“0”和“1”版本之间的唯一区别是价格的方向。
```

- `price0CumulativeLast` is “the price of `token0` denominated in `token1`”
- `price1CumulativeLast` is “the price of `token1` denominated in `token0`”
```

*由于执行加法时的数学运算方法，* `price0CumulativeLast` * 不是 * `price1CumulativeLast`* 的倒数。对于本文档的其余部分，我们将仅参考* `price0CumulativeLast`*，但同样适用于这两个值。此外，* `price0CumulativeLast` *不一定在每个区块上都是最新的，因此您要么需要* [*在市场上运行 sync()*](https://github.com/Uniswap/uniswap-v2-core/blob/4dd59067c76dea4a0e8e4bfdda41877a6b16dedc/contracts/UniswapV2Pair.sol#L198-L200)*，或* [*自己调整值*](https://github.com/Keydonix/uniswap-oracle/blob/1c739f0ea575b15c1a52b15c1a525/contracts/source/UniswapOracle.sol#L84-L92)*.*

`price0CumulativeLast` 的值仅在块上的第一笔交易发生时进行更新. 方法是采用上一个已知的 `reserve0` 和 reserve1 值（`token0` 和 `token1` 的代币余额），计算它们的比率（价格），并对其进行缩放,缩放比例来自于上次更新“price0CumulativeLast”后历经的秒数。 `price0CumulativeLast` 会不断累加*每秒reserve值的比率*。因此要将此变量重新转换为价格，需要 `price0CumulativeLast` 在两个时间点上的值，然后使用以下公式：


```
(price0CumulativeLATEST — price0CumulativeFIRST) / (timestampOfLATEST — timestampOfFIRST)
```

通过将两个时间点中“price0CumulativeLast”的*差值*除以这两个样本之间的秒数，得到了该时间段的时间加权价格。 在这个计算的过程中,选择的时间窗口会是一个重要的安全因素：


- 样板时间点的间隔越小, 价格越新, 但也越容易被操纵
- 样板时间点的间隔越大, 价格越不那么新,但也更加难以操纵

您需要为自己项目仔细考虑这个值, 在防篡改和价格及时之间找到适当的平衡。
有了这个价格的计算公式，还剩一个问题：如何在链上获取历史价格累计信息？

# Retrieving historic cumulative values using a smart contract

Leveraging V2 as an on-chain oracle requires “proving” a prior value of:
`price0CumulativeLast` and its corresponding block timestamp

Retrieving current values for each of these is trivial (`block.timstamp` & `uniswapMarket.price0CumulativeLast()`) but how do you retrieve the old one? The most straightforward approach is to deploy a smart contract which records the current value of `price0CumulativeLast` and timestamp into its own storage, to be recalled later as the historical value. While this would work, it has some drawbacks:

- Must be called periodically to store snapshot values, if you want that price feed constantly available in the future
- If not called periodically, you must plan your transaction ahead, first to store the current value, waiting some period of time, then firing the transaction that uses that historical value

You are stuck between somehow incentivizing bots to continually update the stored value (with bot fees coming from profits elsewhere in the system), or requiring users to send two transactions, one to snapshot the cumulative value, delaying the transaction they want to execute by some non-trivial amount of time in order to reach the number of seconds desired for the price feed average.

If you are not interested in designing an economic system for bots and you doubt users will want to wait to send two transaction, there is a better way to leverage Uniswap V2 as a price feed: Merkle Patricia Proofs!

# Retrieving historic cumulative value using storage proofs

Ethereum contract state storage is stored in a “Merkle Trie”, a special data structure which allows a single 32 byte hash value to represent every storage values in every Ethereum contract (with separate tries for receipts and transaction data). This 32-byte value, named `stateRoot, `is an attribute of every Ethereum block (alongside ones you might be more familiar with, like block number, block hash, and timestamp)

(Note: Ethereum uses a variant called a [“Merkle Patricia Trie” which you can read about here](https://medium.com/codechain/modified-merkle-patricia-trie-how-ethereum-saves-a-state-e6d7555078dd)).

Using the JSON-RPC interface of an Ethereum node, you can call `eth_getProof` to retrieve a payload which, when combined with this `stateRoot` value, can prove that for address A at storage slot B, the value C.

Using on-chain logic, it is possible to combine a stateRoot and storage proof to verify a storage slot’s value. If we target a Uniswap V2 Market and the storage slot for `price0CumulativeLast`, we can achieve the proof-based historic lookups we need.

However, `stateRoot` lookup is NOT available as an EVM opcode; the only relevant opcode is `BLOCKHASH`, which takes a blockNumber and returns the 32-byte block hash. The blockhash of a block is a simple Keccak256 hash of all of its various attributes, [rlp-encoded](https://eth.wiki/en/fundamentals/rlp). By providing ALL attributes of a block, including `stateRoot`, we can verify that the raw block data is valid, by hashing and comparing to the on-chain blockHash lookup. Once verified, we can then use the required attributes of the block (timestamp & `stateRoot`).

```
// NOTE: Non-functional pseudo code
function verifyBlock(parentBlock, stateRoot, blockNumber, timestamp, ...) returns (bool) {
  bytes32 _realBlockHash = blockhash(blockNumber);
  bytes32 _proposedBlockHash = keccek256(rlpEncode(parentBlock, stateRoot, blockNumber, timestamp, ...));
  return _proposedBlockHash == _realBlockHash;
}
```

1. A function like the one above can verify a full-block’s details and confirm all fields are correct for that block
2. Using the `stateRoot` (verified above) parse the provided proof (from a JSON-RPC `getProof` call) to retrieve the historic storage values from that block
3. Fetch the current `price0CumulativeLast` value from Uniswap market
4. Calculate average price between the provided block (from verified timestamp) and right now by dividing the increase in `price0CumulativeLast` by the number of seconds since the verified timestamp.

At this point, you have your price in memory, an average over some configurable period of time, from a fully decentralized system based purely on market dynamics. For this price feed to be manipulated, the attacker would not only need to push this price in one direction, they would need to keep it there for long periods of time, between blocks, giving any buyer the chance to buy under-priced assets, which would in turn correct the price feed.

Note: on-chain `BLOCKHASH` lookups only work for the past 256 blocks, the oldest block you can use for your storage proof must be **within the last 256 blocks at the time the transaction lands** on chain.

# Introducing Uniswap-Oracle Library

The above strategy consists of a small bit of client side code (for handling proofs) and a larger amount of fairly complex Solidity, including YUL/assembly and Merkle Trie verification. [Micah Zoltu](https://medium.com/u/9e15b5664ca?source=post_page-----3530e699e1d3--------------------------------) and I, as part of the [Keydonix](https://medium.com/u/f605e3324ca4?source=post_page-----3530e699e1d3--------------------------------) development team, have developed and published [Uniswap-Oracle](https://github.com/Keydonix/uniswap-oracle/), a Solidity library which enables other smart contracts to leverage this oracle functionality.

To integrate with your own contract, simple inherit from the base contract [UniswapOracle.sol](https://github.com/Keydonix/uniswap-oracle/blob/master/contracts/source/UniswapOracle.sol) ( `contract HelloWorld is UniswapOracle`), your contract will inherit the `getPrice` function:

```
function getPrice(
    IUniswapV2Pair uniswapV2Pair,
    address denominationToken,
    uint8 minBlocksBack,
    uint8 maxBlocksBack,
    ProofData memory proofData)
  
  public view
  
  returns (
    uint256 price,
    uint256 blockNumber
  )
```
Your own function which requires access to this Uniswap price will need to receive this proof data as an argument to be passed along to this internal `getPrice` function call. Please see the [Uniswap-Oracle README.me](https://github.com/Keydonix/uniswap-oracle/blob/master/README.md) for integration documentation.

The Uniswap-Oracle library is **unaudited**. Any application that is responsible for value on mainnet should be fully audited; please ensure your application’s audit covers the Uniswap-Oracle code as well.

Stop by the [Keydonix Discord](https://discord.gg/VybAU4) to ask questions and get help with integration and [follow us on Twitter](https://twitter.com/keydonix) for updates and new projects!

Thanks to Micah Zoltu
