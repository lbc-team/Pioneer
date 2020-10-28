> * 原文链接：https://medium.com/bandprotocol/solidity-102-2-o-1-iterable-map-8d905298c1bc，作者：[Bun Uthaitirat](https://medium.com/@taobunoi?source=post_page-----8d905298c1bc--------------------------------)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…]()

#  Solidity 102 - 编写 O(1) 复杂度的可迭代映射

我们探索及讨论了在[以太坊](https://learnblockchain.cn/categories/ethereum/)独特的EVM成本模型下编写高效Solidity代码的数据结构和实现技术。读者应该对Solidity中的编码以及EVM的总体工作方式有所了解。

![Image for post](https://img.learnblockchain.cn/2020/10/27/tJfQFuQg.png)

在[上一篇文章](https://medium.com/bandprotocol/solidity-102-1-keeping-gas-cost-under-control-ae95b835807f)中，我们讨论了使用Solidity编写智能合约同时控制 gas 成本的技术。在本文中，我们将讨论一种经常需要的具体数据结构：*可迭代映射（Iterable Map） *。

如你所知，原生的 Solidity 的 `mapping` [当前是不可以迭代的](https://learnblockchain.cn/docs/solidity/types.html#mapping-types)，但是我们将通过扩展映射数据结构来使其成为可能，从而以最小的 gas 成本开销支持迭代功能。

在整篇文章中，你将实现智能合约并与我们一起进行实验。如果你准备好了，那就开始吧！

## 示例问题1：学校和学生

我们想创建一个“学校”智能合约来收集学生地址。合约必须具有3个主要功能：

1. 在合约中添加或删除学生。
2. 询问给定的学生地址是否属于学校。
3. 获取所有学生的名单。

我们的`School（学校）`智能合约将如下所示：

![School合约](https://img.learnblockchain.cn/2020/10/27/ztIEBIvQ.png)

## 简单的解决方案(提示：方案不是很理想)

有2种简单的方法可以部分解决问题。但是，每种解决方案在某些情况下都有其自身的缺点。让我们详细探讨这两种解决方案。

### 简单的解决方案1：使用 `mapping(address => bool)`

我们使用映射来存储每个学生的存在。如果映射到给定地址的值是true，则表示该地址是我们的学生之一。虽然解决方案很简单，但是它有局限性，即它不支持获取所有学生。与大多数其他语言不同，在Solidity中，不支持迭代映射。 Solidity 代码如下所示。

![School合约 - mapping实现](https://img.learnblockchain.cn/2020/10/27/XiIhWVgw.png)

> 简单的解决方案1。我们使用普通映射来存储学生地址。此解决方案不支持迭代。

### 简单的解决方案2：使用`address [] students`

在此解决方案中，我们使用地址数组而不是映射。现在很明显，我们解决了第三个要求(可以返回所有学生的名单)。但是，查找和删除现有学生变得更加困难。我们必须循环访问数组中的每个元素以查找地址，检查地址是否存在或删除学生。代码如下所示：

![School合约 - 数组实现](https://img.learnblockchain.cn/2020/10/27/vcwvsuMA.png)

> 简单的解决方案2。我们使用纯数组。性能可能会受到影响。

## 简单的解决方案性能分析

我们进行了一项实验，以了解当列表的大小为10和100时，为了在列表中添加地址或从列表中删除地址而使用了多少 gas 。这就是结果。

![简单-性能分析](https://img.learnblockchain.cn/2020/10/27/CRR7NbCg.png)

> 请注意，通过将溢出的元素与最后一个元素交换，然后从数组中弹出最后一个元素，可以更有效地从数组中删除元素。也就是说，这样做仍然需要**O(n)**的复杂度来循环查找要删除的元素的位置。

我们得出一个简单的结论，`mapping(映射)`更高效，但不能满足所有要求，而`数组`则需要与学生总数成比例的成本来完成所有任务。所以他们都不够好。我们需要更好的选择！

## 更好的解决方案：使用 `mapping(address => address)`

令人兴奋的部分到了！此数据结构的基础是[链表](https://en.wikipedia.org/wiki/Linked_list)。我们存储下一个学生的地址(即指向下一个学生的指针)作为映射值，而不是简单的布尔值。听起来令人困惑困惑吧？这张图片将帮助你理解。


![链表](https://img.learnblockchain.cn/2020/10/27/nFvFq4vA.png)

> 上部：链表数据结构。每个节点指向其下一个节点，最后一个节点指向GUARD。
> 底部：使用键-值映射来具体表示上步示意图。


![链表-代码](https://img.learnblockchain.cn/2020/10/27//eSyHtnA.png)

通过将GUARD设置为指向GUARD来完成数据结构的初始化，这意味着列表为空

现在让我们来看一下每个功能的实现。

### 检查学生是否在学校：`isStudent`

我们已经知道：学校中特定学生的`mapping`结构中的值始终指向下一个学生的地址。因此，我们可以通过检查该地址映射到的值来轻松验证学校中是否有给定地址。如果它指向某个非零地址，则表示该学生地址在学校中。

![验证学生](https://img.learnblockchain.cn/2020/10/27/LxowweWw.png)

### 将新学生添加到学校：`addStudent`

我们可以在 `GUARD`(代表列表的HEAD指针)之后添加一个新地址，方法是将`GUARD`的指针更改为该新地址，并将新地址(`新学生`)的指针设置为先前的地址(`之前的学生`) )。


![mapping 链表 - addStudent](https://img.learnblockchain.cn/2020/10/27/EFdkbDHA.png)

![mapping 链表 - addStudent](https://img.learnblockchain.cn/2020/10/27/PbVCQ3Nw.png)


### 从学校中删除学生：`removeStudent`

这个功能比上面的两个功能更加棘手。我们知道地址是否在列表中，但是我们无法轻松得出任何给定学生的上一个地址(除非我们使用[双向链表](https://en.wikipedia.org/wiki/Doubly_linked_list)，但这在存储成本方面要昂贵得多)。要删除地址，我们需要使其上一个学生指向删除地址的下一个地址，并将删除地址的指针设置为零。

![链表 -removeStudent](https://img.learnblockchain.cn/2020/10/27/fol-bBCg.png)


![链表 - removeStudent](https://img.learnblockchain.cn/2020/10/27/p164ZYAQ.png)

注意，要实现`removeStudent`，我们还必须引入`getPrevStudent`函数，该函数有助于在任何给定学生之前找到先前的学生地址。

![getPrevStudent函数](https://img.learnblockchain.cn/2020/10/27/1x2UD07w.png)


### 获取所有学生的列表：`getStudents`

这很简单。我们从GUARD地址开始遍历映射，并将当前指针设置为下一个指针，直到它再次指向GUARD，即完成迭代为止。

![getStudents](https://img.learnblockchain.cn/2020/10/27/q3cRs-Hg.png)

### 进一步优化`removeStudent`

注意，我们实现的`removeStudent`功能消耗的 gas 与学校中学生的数量成正比，因为我们需要遍历整个列表一次，以找到要删除的地址的上一个地址。我们可以通过使用链外计算将先前的地址发送给函数来优化此函数。因此，智能合约只需要验证先前的地址确实指向我们要删除的地址即可。

![removeStudent](https://img.learnblockchain.cn/2020/10/27/qM7USzNA.png)

## 链表方案性能分析

我们进行了一项实验，以确认链表实现的性能。如下所示，无论列表中的元素数量是多少，添加和删除(优化的)函数成本都是常量的 gas 量(**O(1)**)！更好的是，我们也可以使用此解决方案遍历整个集合。 


![链表方案性能分析](https://img.learnblockchain.cn/2020/10/27/ZG8yGt4g.png)

最终性能分析。如你所见，无论学生人数多少，都需要增加和减少成本 **O(1)** 复杂度gas ！

## 结论

在本文中，我们探索了可迭代映射的实现，该数据结构不仅支持**O(1)**复杂度的添加，删除和查找，类似于传统的`映射`，而且还支持集合迭代。我们进行了性能分析以确认假设，并得出了可行的最终实现！在下一篇文章中，我们将探讨如何进一步利用此数据结构来解决更多实际问题。请继续关注更新！

> Band Protocol 是用于去中心化数据治理的平台。我们是一支由工程师组成的团队，他们对未来充满希望，而无需受信任的各方，智能合约可以有效地连接到真实数据的未来充满期待。如果你是一位热情的开发人员，并且想为Band Protocol做出贡献，请通过*[talent@bandprotocol.com](mailto：talent@bandprotocol.com)*与我们联系。

------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。