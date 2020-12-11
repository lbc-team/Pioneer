> * 原文： https://medium.com/mycrypto/understanding-event-logs-on-the-ethereum-blockchain-f4ae7ba50378 作者：[Luit Hollander](https://medium.com/@luith)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 理解以太坊上的事件日志

> 大多数交易都有事件日志，但是这些事件日志却比较难读懂，通过本文，我们可以理解事件如何在存储的。



*序言：先阅读一下 [以太坊虚拟机](https://medium.com/mycrypto/the-ethereum-virtual-machine-how-does-it-work-9abac2b7c9e)，可能会有所帮助，在本文中，我会跳过基础知识直接研究。*

在传统编程中，应用程序经常使用日志来捕获和描述特定时刻的情况。这些日志通常用于调试应用程序，检测特定事件或将日志中发生的事情通知查看者。事实证明，在编写智能合约或与智能合约进行交互时，日志也非常有用！那么以太坊是如何做的呢？

## 以太坊上的日志

EVM当前有**5个操作码**用于触发事件日志：LOG0，LOG1 *，* LOG2 *，* LOG3 和 LOG4。

这些操作码可用于创建“日志记录”。日志记录就是用于描述智能合约中的事件，例如代币转移、所有权变更等。

![Image for post](https://img.learnblockchain.cn/2020/12/10/w89Pq7XA.png)

[以太坊黄皮书](https://ethereum.github.io/yellowpaper/paper.pdf) -拜占庭版本69351d5(2018-12-10)

每个日志记录都包含“主题(topics)”和“数据”。主题是32字节(256位)的“词”，用于描述事件中发生的事情。不同的操作码(LOG0…LOG4)来描述需要包含在日志记录中的主题数。例如，“ LOG1”包括“一个主题”，而“ LOG4”包括“四个主题”。因此，单个日志记录中可以包含的最大主题数是**四个**。

## 以太坊日志记录中的主题

日志记录的第一部分由一组主题组成。这些主题用于描述事件。第一个主题通常为事件名称及其参数类型*(uint256，string等)***签名**([keccak256](https://en.wikipedia.org/wiki/SHA-3)哈希)。一个例外是触发“匿名事件”没有事件签名。由于主题只能容纳32个字节的数据，因此无法将数组或字符串等（可能超过 32 个字节）的内容用作主题。而是应将其作为数据包括在日志记录中，而不是作为主题。如果要尝试包含大于32个字节的主题，则该主题需要被hash计算。因此，仅当你知道原始输入时，才可以知道此哈希表示的内容（译者注： 因为hash计算不可逆）。

总之，主题应该仅用于需要（压缩）搜索查询(例如：地址)的数据。可以将主题视为事件的索引键，它们都映射到相同的值，接下来将讨论。

## 以太坊日志记录中的数据

日志记录的第二部分包含额外的数据。主题和数据在一起组成日志记录，主题和数据每自有其优点和缺点。例如，主题是可搜索的，但数据却不能。而数据比主题“便宜得多”。此外，尽管主题最多有 4 个（限制在**4  * 32字节**），但数据却没有限制，这意味着它可以包括**大量或复杂数据**，例如数组或字符串。因此，事件数据(如果有)可以视为*值*。

让我们看一些示例，看看主题，数据和日志记录是如何使用的。

## 触发事件

以下实现了ERC20的代币合约，使用了Transfer事件：

![Image for post](https://img.learnblockchain.cn/2020/12/10/8lTGq3iw.png)

由于这不是匿名事件，因此第一个主题将包括事件签名：

![Image for post](https://img.learnblockchain.cn/2020/12/10/cAVfc2oQ.png)

现在，让我们看一下此Solidity事件的参数(from *，* to *，* value)：

![Image for post](https://img.learnblockchain.cn/2020/12/10/7Nm5eNow.png)

由于前两个参数声明为**indexed**，因此被视为主题。最后一个参数没有 indexed ，它将作为数据(而不是单独的主题)。这意味着我们可以进行这样的搜索：查找所有从地址**0x0000...**（搜索条件）到地址**0x0000…**（搜索条件）的**转账**日志，或者是“所有转账到地址**0x0000…**（搜索条件）的日志”，但没法搜索“转账金额为**x**（搜索条件）的转账。我们知道了此事件将具有**3个主题**，这意味着此日志记录操作将使用**LOG3**操作码。



![Image for post](https://img.learnblockchain.cn/2020/12/10/UEPO96UA.png)

现在，我们只需要了解如何包含数据(即最后的参数)即可。**LOG3**需要5个参数：

```
LOG3(memoryStart, memoryLength, topic1, topic2, topic3)
```

通过以下方式从内存中读取事件数据：

```
memory[memoryStart...(memoryStart + memoryLength)]
```

幸运的是，像[Solidity](https://learnblockchain.cn/docs/solidity/)，[Vyper](https://github.com/ethereum/vyper)或[Bamboo](https://github.com/cornellblockchain/bamboo)这样的高级智能合约程序设计语言将为我们处理将事件数据写入内存的过程，我们可以在触发日志时直接将数据作为参数传递。

## 检索事件日志

通过使用[web3](https://learnblockchain.cn/docs/web3.js/) JavaScript库，可用于与本地或远程以太坊节点进行交互，我们能够订阅新的事件日志：

![Image for post](https://img.learnblockchain.cn/2020/12/10/mE8kwXlA.png)

每当发生新的SAI代币转账时，此代码都会通知我们，接收到事件通知，这对很多应用程序都很有用。例如，一旦你在以太坊地址上收到代币，钱包界面就可以提醒你。

## 日志的gas成本

![Image for post](https://img.learnblockchain.cn/2020/12/10/Ex-PDS3A.png)

根据黄皮书、日志的基础成本是375 gas 。另外每个的主题需要额外支付375 gas 的费用。最后，每个字节的数据需要**8个 gas **。

![Image for post](https://img.learnblockchain.cn/2020/12/10/3ymWfQhA.png)

这实际上是很便宜！可以计算一下一个ERC-20代币转移事件的成本。首先，基本成本为375 gas 。其次，“转移”事件包含**3个主题**，这是另外的375 * 3 =**1125 gas**。最后，我们为所包含的每个数据字节添加**8 gas **。由于数据仅包含ERC-20 转账的数量，最大为**32字节**，因此用于记录日志数据所需的最大 gas 量为8 * 32 =**256 gas **。这总计要花费**1756 gas **的总 gas 成本。作为对比参考，标准的以太币(非代币)转账要花费21000 gas ，是事件成本的十倍以上了！

如果我们假设 gas 价格为**1 gwei**，那么操作的总成本将为**1756 gwei**，相当于**0.000001756 ETH**。如果以太坊的当前价格在200美元左右，那么总计为$0.0003512。请记住，这是在全球范围内将数据永久存储的费用。

*声明：这只是日志记录操作本身的成本。任何以太坊交易至少需要21000 gas，并且交易的输入数据每字节最多花费16 gas。通常，要转账和日志记录ERC-20代币，费用在40,000–60,000 gas 。*

## 结论

日志是一种以少量价格将少量数据存储在以太坊区块链上的优雅方法。具体来说，事件日志有助于让其他人知道发生了什么事情，而无需他们单独查询合约。

### 参考文献

- [Wood，G.(2014)。以太坊：一个安全的去中心化通用交易账本](https://ethereum.github.io/yellowpaper/paper.pdf)
- [以太坊基金会 Solidity 文档](https://solidity.readthedocs.io/en/latest/)
- [ Web3文档](https://learnblockchain.cn/docs/web3.js/)

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。