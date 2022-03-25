
# 使用Echidna测试智能合约库

我们已经展示给我如何通过Echidna工具测试智能合约,显而易见,你将了解:
* 使用不同的工具找到我们在  [Set Protocol audit](https://github.com/trailofbits/publications/blob/master/reviews/setprotocol.pdf)  审计期间发现的错误.
* 为自己的智能合约库指定并检查有用的属性。
* 我们将演示如何使用 [crytic.io](https://cryptic.io/),  来完成所有这些工作，它提供了 GitHub 集成和额外的安全检查。

## 库可能带来风险

某些智能合约中的漏洞很致命的：无论是以代币还是以太币的形式，合约可以管理重要的财产资源，漏洞造成的损失将可能以数百万美元计。不过，以太坊区块链上的代码比任何单个合约都更重要：智能合约库代码。


库可能被 *许多* 热门的合约引用，因此，例如 `SafeMath` 中的一个微妙的未知错误可能让攻击者不仅可以利用一个漏洞，而且可以利用*许多*关键合约。这种基础设施代码的重要性在区块链环境之外得到了很好的理解——[TLS](https://heartbleed.com/) 或 [sqlite](https://www.zdnet.com/article/sqlite-bug-impacts-thousands-of-apps-including-all-chromium-based-browsers/) 等广泛使用的库中的错误具有传染性，可能感染所有依赖于库的代码。


库测试通常侧重于检测内存安全漏洞。然而，在区块链的世界，我们并不那么担心避免堆栈异常或来自包含私钥的区域的`memcpy`；我们最担心库代码的语义正确性。智能合约在“代码就是法律”的金融世界中运行，如果库在某些情况下计算出不正确的结果，那么“代码漏洞”可能会传播到调用合约，并允许攻击者做一些坏事。


除了使库产生不正确的结果之外，此类漏洞可能会产生其他后果；如果攻击者可以强制库代码意外恢复，那么他们就有了潜在的拒绝服务攻击的机会。如果攻击者可以使库函数进入失控循环，他们可以将拒绝服务与昂贵的 gas 消耗结合起来。



这就是在旧版本的用于管理地址数组的库中发现的 bug Trail of Bits 的漏洞，如 [this audit of the Set Protocol code](https://github.com/trailofbits/publications/blob/master/reviews/setprotocol.pdf). 中所述
错误的代码看起来像这样:

```
/**
* 检查是否有重复元素， 运行空间复杂度为O(n^2).
* @param A Array to search
* @return Returns true if duplicate, false otherwise
*/
function hasDuplicate(address[] memory A) returns (bool)
   {
     for (uint256 i = 0; i < A.length - 1; i++) {
       for (uint256 j = i + 1; j < A.length; j++) {
         if (A[i] == A[j]) {
            return true;
         }
       }
   }
   return false;
}

```

问题在于，如果 `A.length` 为 `0`（`A` 为空），则 `A.length - 1` 下溢，并且外部 (`i`) 循环遍历整个 `uint256` 集合。在这种情况下，内部 (`j`) 循环不会执行，因此我们有一个循环（基本上）不起作用。当然，这个过程总是会耗尽gas，调用hasDuplicate的事务也会失败。如果攻击者可以在正确的位置产生一个空数组，那么（例如）使用“hasDuplicate”对地址数组强制执行某些不变量的合约可以被禁用——可能是永久的禁用。

所以，看[the code for our example](https://github.com/crytic-test/addressarrayutils_demo), 并且用它检查 [this tutorial on using Echidna](https://github.com/crytic/building-secure-contracts).

在较高级别上，该库提供了用于管理地址数组的便捷。一个典型的例子涉及使用地址白名单的访问控制。 AddressArrayUtils.sol 有 19 个函数要测试：


```
function indexOf(address[] memory A, address a)
function contains(address[] memory A, address a)
function indexOfFromEnd(address[] A, address a)
function extend(address[] memory A, address[] memory B)
function append(address[] memory A, address a)
function sExtend(address[] storage A, address[] storage B)
function intersect(address[] memory A, address[] memory B)
function union(address[] memory A, address[] memory B)
function unionB(address[] memory A, address[] memory B)
function difference(address[] memory A, address[] memory B)
function sReverse(address[] storage A)
function pop(address[] memory A, uint256 index)
function remove(address[] memory A, address a)
function sPop(address[] storage A, uint256 index)
function sPopCheap(address[] storage A, uint256 index)
function sRemoveCheap(address[] storage A, address a)
function hasDuplicate(address[] memory A)
function isEqual(address[] memory A, address[] memory B)
function argGet(address[] memory A, uint256[] memory indexArray)
```

看起来很多，但是很多函数在效果上是相似的，因为 AddressArrayUtils 提供了`extend`、`reverse`、`pop`的函数版本（操作内存数组参数）和变异版本（需要存储数组），和“删除”。你可以看到，一旦我们为 `pop` 编写了一个测试，为 `sPop` 编写一个测试可能不会太难。

## 基于属性的模糊测试 101



我们的工作是获取我们感兴趣的功能——在这里，所有这些功能——并且：

* 弄清楚每个函数的作用
* 然后编写一个测试，确保函数能做到！

当然，这样做的一种方法是编写大量单元测试，但这是有问题的。如果我们想*彻底*测试这个库，这将是很多工作，而且坦率地说，我们可能会做得很糟糕。我们确定我们能想到每一处的用例吗？即使我们试图覆盖所有源代码，涉及*缺少源代码*的错误，如 `hasDuplicate` 错误，也很容易被遗漏。

我们想使用*基于属性的测试*来指定*所有可能输入*的一般行为，然后生成大量输入。编写行为的一般描述比编写任何单独的具体“给定输入 X，函数应该执行/返回 Y”测试更难。但是编写*所有*所需的具体测试的工作将是费时费力的。最重要的是，即使是非常出色的手动单元测试也找不到那种[weird edge-case bugs attackers are looking for](https://blog.trailofbits.com/2019/08/08/246-findings-from-our-smart-contract-audits-an-executive-summary/).

## Echidna 测试工具：hasDuplicate

测试库的代码最明显的一点是它比库本身大！在这种情况下，这种情况并不少见。不要让你害怕；与库不同，测试工具作为正在进行中的工作，并慢慢改进和扩展，工作得很好。测试开发本质上是渐进式的，如果您拥有像 Echidna 这样的工具来扩大您的付出，那么即使是很小的努力也会带来可观的收益。

举个具体的例子，让我们看看 `hasDuplicate` 错误。我们要检查：

* 如果有重复，`hasDuplicate` 报告它，并且
* 如果没有重复，`hasDuplicate` 报告没有重复。

我们可以重新实现 `hasDuplicate` 本身，但这通常没有多大帮助（在这里，它可能让我们找到错误）。如果我们有另一个独立开发的高质量地址数组实用库，我们可以对其进行比较，这种方法称为差异测试。不幸的是，我们通常没有这样的参考库。


我们这里的方法是通过在库中寻找另一个可以检测重复项而无需调用“hasDuplicate”的函数来应用较弱版本的差异测试。为此，我们将使用 `indexOf` 和 `indexOfFromEnd` 来检查项目的索引（从 0 开始）是否与从数组末尾执行搜索时的索引相同：

```
  for (uint i = 0; i < addrs1.length; i++) {
    (i1, b) = AddressArrayUtils.indexOf(addrs1, addrs1[i]);
    (i2, b) = AddressArrayUtils.indexOfFromEnd(addrs1, addrs1[i]);
    if (i1 != (i2-1)) { // -1 because fromEnd return is off by one
  hasDup = true;
    }
  }
  return hasDup == AddressArrayUtils.hasDuplicate(addrs1);
}
```

 看这个例子[our addressarrayutils demo](https://github.com/crytic-test/addressarrayutils_demo/blob/348132cbb2eb4f0f6e887d426b3f2caeea311564/contracts/crytic.sol#L37-L54)， [This code](https://github.com/crytic-test/addressarrayutils_demo/blob/348132cbb2eb4f0f6e887d426b3f2caeea311564/contracts/crytic.sol#L37-L54)，

遍历 addrs1 并找到每个元素第一次出现的索引。当然，如果没有重复，这将始终只是 *i* 本身。然后代码找到元素最后一次出现的索引（即从末尾开始）。如果这两个索引不同，则存在重复。在 Echidna 中，属性只是 Boolean Solidity 函数，如果满足属性，通常返回 true（我们将在下面看到异常），如果它们恢复或返回 false，则返回失败。现在我们的 `hasDuplicate` 正在测试 `hasDuplicate` 和两个 `indexOf` 函数。如果它们返回false，Echidna 会告诉我们。



我们加入 [a couple of functions to be fuzzed to set addrs1](https://github.com/crytic-test/addressarrayutils_demo/blob/348132cbb2eb4f0f6e887d426b3f2caeea311564/contracts/crytic.sol#L7-L35).
让我们在 Crytic 上运行这个属性：

![](https://img.learnblockchain.cn/2020/09/29/16013634289541.jpg)
<center>测试失败</center>

First, `crytic_hasDuplicate` fails:

```
crytic_hasDuplicate: failed!
  Call sequence:
    set_addr(0x0)
```

触发事务序列非常简单：不要在 `addrs1` 中添加任何内容，然后在其上调用 `hasDuplicate`。就是这样——由此产生的失控循环将耗尽你的 gas 预算，Crytic/Echidna 会告诉你失败。当 Echidna 将故障最小化为可能的最简单序列时，会产生“0x0”地址。

我们的其他属性（`crytic_revert_remove` 和 `crytic_remove`）通过了，这很好。如果我们修复 [`hasDuplicate` 中的错误](https://github.com/crytic-test/addressarrayutils_demo/pull/1)，那么我们的测试将全部通过：


![image](https://img.learnblockchain.cn/2020/09/29/16013635062863.jpg)
<center>测试通过</center>


`crytic_hasDuplicate: fuzzing (2928/10000)` 告诉我们，由于昂贵的 `hasDuplicate` 属性不会很快失败，在我们达到 5 分钟超时之前，我们对每个属性进行的最多 10,000 次测试中只有 3,000 次被执行。


## Echidna 测试工具：库的其余部分

现在我们已经看到了一个测试示例，这里有一些构建其余测试的基本建议（正如我们已经为 addressarrayutils_demo 存储库所做的那样）

* 尝试计算同一事物的不同方法。您拥有的功能的“差异”版本越多，您就越有可能找出其中一个是否错误。例如，查看 [我们交叉检查 `indexOf`、`contains` 和 `indexOfFromEnd` 的所有方式](https://github.com/crytic-test/addressarrayutils_demo/blob/dbdf301d88c51454106c28d5b50220fd63cf647e/contracts/crytic.sol #L37-L84)。
 

* 测试 **revert。** 如果您像我们 [此处](https://github.com/crytic-test/addressarrayutils_demo/blob/dbdf301d88c51454106c28d5b50220fd63cf647e/contracts/crytic. sol#L450-L458)*,* 只有当所有调用都恢复时，该属性才会通过。这可以确保代码在应该失败时失败。
* 不要忘记检查明显的简单不变量，例如，数组与自身的差异始终为空（`ourEqual(AddressArrayUtils.difference(addrs1, addrs1), empty)`）。
* 其他测试中的不变检查和前提条件也可以作为对被测函数的交叉检查。请注意，`hasDuplicate` 在许多根本不打算检查 `hasDuplicate` 的测试中被调用；只是知道数组是无重复的可以建立许多其他行为的附加不变量，例如，在删除任意位置的地址 X 后，数组将不再包含 X。


## 使用 Crytic 启动并运行

您可以通过下载和安装该工具或使用我们的 docker build 自行运行 Echidna 测试——但使用 Crytic 平台集成了基于 Echidna 属性的测试、Slither 静态分析（包括 Slither 的公共版本中不可用的新分析器）、可升级性检查，并在与您的版本控制相关的无缝环境中进行您自己的单元测试。此外，addressarrayutils_demo 存储库显示了基于属性的测试所需的一切：它可以像创建最小的 Truffle 设置、添加具有 Echidna 属性的 crytic.sol 文件以及在 Crytic 中的存储库配置中打开基于属性的测试一样简单.


[手把手教你用Echidna测试智能合约](https://learnblockchain.cn/article/3742)

原文链接：https://blog.trailofbits.com/2020/08/17/using-echidna-to-test-a-smart-contract-library/
作者：[Crytic CI](https://twitter.com/cryticci)