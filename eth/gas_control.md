> * 来源：https://medium.com/bandprotocol/solidity-102-1-keeping-gas-cost-under-control-ae95b835807f，作者：[Sorawit Suriyakarn](https://medium.com/@sorawit?source=post_page-----ae95b835807f--------------------------------)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)


# Solidity 优化 - 控制 gas 成本


本系列我们探索和讨论在以太坊独特的 EVM 成本模型下编写高效的 Solidity 代码的数据结构和实现技术。
读者应该已经对 Solidity 中的编码以及 EVM 的总体工作方式所有了解。

![Image for post](https://img.learnblockchain.cn/2020/10/28/LTvNu9Mw.png)

我们讨论在Solidity中编写高性能智能合约时应注意的重要事项。虽然Solidity的语法看上去与JavaScript或C++ 相似，但其EVM运行时却完全不同。了解EVM的局限性以及解决这些局限性的技术将有助于你编写更好的Solidity。本文将重点介绍高级思想，并且在本系列的后续文章中将介绍具体的实现。

本系列文章有：
1. [Solidity 优化 - 控制 gas 成本]()
2. [Solidity 优化 - 编写 O(1) 复杂度的可迭代映射](https://learnblockchain.cn/article/1632)
3. [Solidity 优化 - 维护排序列表](https://learnblockchain.cn/article/1638)

## 与永久性存储交互

> 译者注：以太坊上有三种数据存储位置： 内存（memory）、（永久性）存储（storage）以及调用数据calldata， 详情可参考[Solidity文档 - 应用类型-数据位置](https://learnblockchain.cn/docs/solidity/types.html#data-location)

查看[*以太坊黄皮书*](https://ethereum.github.io/yellowpaper/paper.pdf) 附录G 全面了解EVM操作码成本。

永久性存储操作码(`SSTORE`)非常昂贵。首次写插槽时，每个32个字节的当前成本是为20,000 Gas(在10 Gwei gas价格下为5美分，每ETH为250美元)，而后续每次修改则为5,000 Gas。尽管从理论上讲复杂度成本是`恒定的`，但它却是算术或内存运算成本的一千倍以上，而算术或内存运算的成本通常不到10 Gas。目前整个区块(截至2020年10月)的Gas限制为〜12,000,000 Gas实，开发人员应设计其智能合约以最大程度地减少所需的存储插槽数量。请注意，即将到来(?)的[状态租赁](https://ethereum-magicians.org/t/state-fees-formerly-state-rent-pre-eip-proposal-version-3/2654)升级将不必要使用存储。幸运的是，有一些方法可以帮助缓解问题。

## 不要存储不必要的数据

这听起来似乎很明显，但是非常值得一提。编写智能合约时，你应该只存储交易验证所需的内容。与合约逻辑无关的交易记录或详细说明之类的数据可能不需要保存在合约存储中。考虑以下PollContract智能合约，该用户可以创建一个民意调查，当达到某个阈值时可以自动执行。

![PollContract](https://img.learnblockchain.cn/2020/10/28/R5I-eTew.png)

如果经常调用`createPoll`函数，则可以考虑从`Poll`结构体中删除`memo`，因为它不会直接影响合约的逻辑。而且触发的备忘录的事件已经包含了`memo`，而它仅需要存储`memo`的哈希值(32字节)，就可以方便日后进行快速验证。开发者应仔细考虑 gas 成本与合约简便性之间的权衡。

**此外, 在Band Protocol的Solidity优化教程中，我们介绍的各种数据结构实现，例如链接列表，可迭代映射，Merkle树等，这些实现是专门为减少以太坊存储数据量而设计的。**

## 将多个小变量打包到单个字中

> 译者注：标题中的"字", 也称为字长，表示每个指令操作的数据长度。

EVM在32字节字长存储模型下运行。可以将小于32个字节的多个变量打包到一个存储槽中，以最大程度地减少`SSTORE`操作码的数量。尽管Solidity [自动尝试将小的基本类型打包到同一插槽中](https://learnblockchain.cn/docs/solidity/internals/layout_in_storage.html)，但是糟糕的结构体成员排序可能会阻止编译器执行此操作。考虑下面的`Good`和`Bad`结构体。

![Image for post](https://img.learnblockchain.cn/2020/10/28/MGf38d9w.png)

<center>好和坏结构体成员排序的实现示例</center>

使用启用了优化的编译器：`solc 0.5.9 + commit.e560f70d`，第一个`doBad()`函数调用执行消耗约60,000 Gas，而`doGood()`仅消耗约40,000 Gas。注意是一个字长存储的差异(20,000 Gas)，因为`Good`结构将两个uint128打包为一个字。

![结构体优化 - doBad 成本](https://img.learnblockchain.cn/2020/10/28/wdy9I8Xw.png)

> `doBad`函数调用的执行成本为60709 Gas

![结构体优化 - doGood 成本](https://img.learnblockchain.cn/2020/10/28/IvFYlxKQ.png)

> `doGood`函数调用的执行成本为40493 Gas

## 仅将默克尔根存储为状态

减轻状态膨胀的一种更极端的方法是在区块链上仅存储32字节的[Merkle Root](https://en.wikipedia.org/wiki/Merkle_tree)。交易的调用方负责为交易在执行过程中需要使用的任何数据提供适当的值和证明。智能合约可以验证证明是正确的，但不需要在链上持久存储任何信息-只需保留和更新一个32字节根。

## 潜在的无限迭代

作为[图灵计算机](https://en.wikipedia.org/wiki/Turing_completeness)语言，Solidity允许执行可能无限制的循环。例如，如果一组用户没有明显的大小限制，那么为“每个”用户做某事的函数可能消耗大量的 gas 。避免无限循环将使 gas 成本更易于管理。这是你可以用来改善智能合约的一些技巧。

## 链外计算(提示)

常见的排序列表数据结构，如果向列表中添加元素并确保其仍是排序的，缺乏经验的实现需要在整个集合中进行迭代，以找到合适的位置。

一种更有效的方法是使合约需要进行链下计算，为其提供要添加元素的确切位置。链上计算仅需要进行验证(例如：添加的值时候位于其相邻元素之间)，这可以防止成本随数据结构的总大小线性增长。有关示例的更详尽列表，请参见B9lab的[文章](https://blog.b9lab.com/getting-loopy-with-solidity-1d51794622ad)。

![链下计算对比 gas](https://img.learnblockchain.cn/2020/10/28/kxKvatWw.png)

> **左边:** 在列表链上循环会消耗O(n) gas ，该 gas 会随着列表的增长而线性扩展。**右边（正确）：**计算链下位置并验证链上价值会消耗固定量的 gas ，而与列表的大小无关。

## 使用提款模式

智能合约可以记录每个用户是否执行该操作的映射，而不是遍历每个地址并对其执行操作。由每个用户负责发送交易以启动操作，而智能合约仅验证没有执行来自同一用户的重复操作。采用这种方案，每笔交易的成本保持不变，不会随着用户总数的增长而增加。这消除了一次交易中超出 gas 限制的可能性。但是，需要注意的是， gas 总成本会比在一次交易中完成所有操作更多。

![提款模式](https://img.learnblockchain.cn/2020/10/28/S7FEQYNg.png)

**左边:** 调用一次`Distribute`操作所花费的费用与一笔交易中的接收方数量成正比，这在足够多的用户的情况下会失败。
**右边（正确）：** 所有交易(1个`Add`和4个`Claim`)的成本都不会随用户数量而增加。

## 结论

在本文中，我们介绍了一些Solidity编程模式，这些模式可能会导致昂贵的交易费用，或者更糟糕的是由于区块gas限制导致无法执行智能合约。

这绝不是一个详尽的清单，但它应该使你了解如何优化合约。在[下一篇文章](https://learnblockchain.cn/article/1632)中，我们将开始动手，并使用Solidity实现一些真正的智能合约或库。敬请关注！

*Band Protocal 是用于去中心化数据治理的平台。我们是一支由工程师组成的团队，他们对未来充满希望，而无需受信任的各方，智能合约可以有效地连接到真实数据的未来充满期待。如果你是一位热情的开发人员，并且想为Band Protocol做出贡献，请通过* [*talent@bandprotocol.com *](mailto：talent@bandprotocol.com)*与我们联系。*

------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。