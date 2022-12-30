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


# 使用智能合约检索历史累积值

利用 V2 作为链上预言机需要“证明”以下先验值：
`price0CumulativeLast` 及其对应的块时间戳

检索以上先验值的当前值是非常简单的（`block.timstamp` & `uniswapMarket.price0CumulativeLast()`）但是你如何检索旧值？最直接的方法是部署一个智能合约，将 `price0CumulativeLast` 的当前值和时间戳记录到自己的存储中，以便稍后作为历史值调用。虽然这是可行的，但它有一些缺点：

- 如果希望价格源持续可用, 那么你必须定期调用以存储快照值
- 如果是不定期调用，您必须提前计划好您的交易,首先存储当前值，等待一段时间，然后触发使用该历史值的交易

您需要被激励使用机器人去不断更新存储值（机器人的使用费来自系统其他地方的利润）; 或者您要求用户发送两笔交易，其中一笔用于快照当下的累积值，并且这种做法需要用户延迟一定秒数再执行交易,使得延迟的秒数能够满足平均价格所需要求.

如果您对为机器人设计经济系统不感兴趣，或者您怀疑用户会愿意等待发送两笔交易，那么有一种更好的方法可以利用 Uniswap V2 作为价格源：Merkle Patricia Proofs！

# 使用存储证明检索历史累积值

以太坊合约的状态被存储在“Merkle Trie”中. 这是一种特殊的数据结构，允许一个32字节哈希值代表每个以太坊合约中存储的值（交易数据和接受方会单独分开）。这个 32 字节的值被称为为“stateRoot”，是每个以太坊区块都会包含的属性（还有你可能更熟悉的那些，比如区块号、区块哈希和时间戳）


(Note:以太坊使用一种被称为[“Merkle Patricia Trie” 的变量, 点击链接你可以了解更多](https://medium.com/codechain/modified-merkle-patricia-trie-how-ethereum-saves-a-state-e6d7555078dd)).

使用以太坊节点的JSON-RPC 接口，您可以调用 `eth_getProof` 来检索有效负载，当结合此 `stateRoot` 值时，可以证明位于存储槽B的地址A的值是C。
使用链上逻辑，可以结合 stateRoot 和存储证明来验证存储槽的值。如果我们以 Uniswap V2 市场和 `price0CumulativeLast` 的存储槽为目标，我们就可以实现基于证明的历史查找。

但是，“stateRoot”的查找操作并没有EVM 操作码；唯一相关的操作码是“BLOCKHASH”，它接受一个块号并返回 32 字节的块哈希值。一个区块的块哈希值是其所有属性的 Keccak256 哈希值，[rlp-encoded](https://eth.wiki/en/fundamentals/rlp)。通过提供区块的所有属性，包括“stateRoot”，我们先hash, 然后与链上 blockHash 查找进行比较来验证原始区块数据是否有效。一旦验证通过，我们就可以使用块所需的属性（时间戳和 `stateRoot`）。


```
// NOTE: Non-functional pseudo code
function verifyBlock(parentBlock, stateRoot, blockNumber, timestamp, ...) returns (bool) {
  bytes32 _realBlockHash = blockhash(blockNumber);
  bytes32 _proposedBlockHash = keccek256(rlpEncode(parentBlock, stateRoot, blockNumber, timestamp, ...));
  return _proposedBlockHash == _realBlockHash;
}
```

1. 像上面的函数可以验证一个完整块的详细信息,并确认该块的所有字段都是正确的
2. 使用 `stateRoot`（已在上面验证）提供的证明（来自 JSON-RPC `getProof` 调用）,以从该块中检索历史存储值
3. 从 Uniswap 市场获取当前的 `price0CumulativeLast` 值
4. 计算所提供区块与当前区块之间的平均价格，做法是`price0CumulativeLast` 的增量除以区块时间戳的差异（秒数）  

此时，内存中的价格是某个可配置时间段内的平均价格，它来自于一个完全去中心化的系统。为了操纵这个价格，攻击者不仅需要将价格推向一个方向，他们还需要在区块之间长时间保持价格。 这反而让其他买家都有机会购买价格过低的资产，从而纠正错误的价格。


注意：链上 `BLOCKHASH`查找操作仅适用于最近的 256 个区块，您用于存储证明的最早的区块必须包含在 **交易上链** 时的最近256 个区块内。


# 介绍 Uniswap-Oracle 库

上述策略包括少量客户端代码（用于处理证明）和大量相当复杂的 Solidity，包括 YUL/assembly 和 Merkle Trie 验证。 [Micah Zoltu](https://medium.com/u/9e15b5664ca?source=post_page-----3530e699e1d3------------------------ ------) 和我，作为 [Keydonix] 的一部分(https://medium.com/u/f605e3324ca4?source=post_page-----3530e699e1d3-------- ----------------------)开发团队，开发并发布了[Uniswap-Oracle](https://github.com/Keydonix/uniswap-oracle /)，一个 Solidity 库，它使其他智能合约能够利用此 oracle 功能。

要与您自己的合约集成，您只需继承基础合约 [UniswapOracle.sol](https://github.com/Keydonix/uniswap-oracle/blob/master/contracts/source/UniswapOracle.sol)（`contract HelloWorld is UniswapOracle`），你的合约将继承 getPrice 函数：

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
若您需要访问Uniswap价格， 则需将proofData作为参数传递给内部“getPrice”函数调用。请参阅 [Uniswap-Oracle README.me](https://github.com/Keydonix/uniswap-oracle/blob/master/README.md) 以获取集成文档。

Uniswap-Oracle 库是**未经审计**的。任何对主网上的价值负责的应用都应该被全面审计；请确保您的应用程序的审核也涵盖 Uniswap-Oracle 代码。

通过 [Keydonix Discord](https://discord.gg/VybAU4) 提出问题并获得集成帮助，并[在 Twitter 上关注我们](https://twitter.com/keydonix) 以获取更新和新项目！
感谢 Micah Zoltu
