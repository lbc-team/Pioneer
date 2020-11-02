> * 链接：https://medium.com/coinmonks/8-ways-of-reducing-the-gas-consumption-of-your-smart-contracts-9a506b339c0a 作者：[Lucas Aschenbach](https://medium.com/@lucas.aschenbach?source=post_page-----9a506b339c0a--------------------------------)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 减少智能合约的 gas 消耗的8种方法

我目前正在开发一个Dapp项目，该项目的第一个主要开发阶段已经接近尾声。由于交易成本始终是开发人员的大问题，因此，我想使用本文分享一些我的见解。分享我过去几周/几个月来在该领域获得的收获。

![](https://img.learnblockchain.cn/2020/09/28/16012790295397.jpg)
<center> 在[Unsplash]上的“ 100美元钞票的特写照片” </center>

下面，我列出了一些优化技术，其中一些可以参考有关该主题的更详细的文章，你可以将其应用于合约设计。我将从一些更基本的、熟悉的概念开始，然后逐步深入到更加复杂细节。

## 1. 首选数据类型

尽量**使用256位的变量**，例如 uint256和bytes32！乍一看，这似乎有点违反直觉，但是当你更仔细地考虑以太坊虚拟机(EVM)的运行方式时，这完全有意义。每个存储插槽都有256位。因此，如果你只存储一个uint8，则EVM将用零填充所有缺少的数字，这会耗费gas。此外，EVM执行计算也会转化为 uint256 ，因此除uint256之外的任何其他类型也必须进行转换。



注意：通常，应该调整变量的大小，以便填满整个存储插槽。在第 3 节 “通过SOLC编译器将变量打包到单个插槽中”中，当使用小于256位的变量有意义时，将变得更加清楚。



## 2. 在合约的字节码中存储值

一种相对便宜的存储和读取信息的方法是，将信息部署在区块链上时，直接将其包含在智能合约的字节码中。不利之处是此值以后不能更改。但是，用于加载和存储数据的 gas 消耗将大大减少。有两种可能的实现方法：

1. 将变量声明为 *constant* 常量 (译者注：声明为 [immutable](https://learnblockchain.cn/article/1059) 同样也可以降低 gas)
2. 在你要使用的任何地方对其进行硬编码。

```js
uint256 public v1;
uint256 public constant v2;

function calculate() returns (uint256 result) {
    return v1 * v2 * 10000
}
```

变量*v1* 是合约状态的一部分，而*v2*和*1000*是合约字节码的一部分。

*(读取v1是通过SLOAD操作执行的，仅此一项就已经消耗了200 gas 。)*

## 3. 通过SOLC编译器将变量打包到单个插槽中

当你将数据永久存储在区块链上时，要在后台执行汇编命令SSTORE。这是最昂贵的命令，费用为20,000 gas，因此我们应尽量少使用它。在内部结构体中，可以通过简单地重新排列变量来减少执行的SSTORE操作量，如以下示例所示：

```
struct Data {
    uint64 a;
    uint64 b;
    uint128 c;
    uint256 d;
}
Data public data;
constructor(uint64 _a, uint64 _b, uint128 _c, uint256 _d) public {
    Data.a = _a;
    Data.b = _b;
    Data.c = _c;
    Data.d = _d;
}
```

请注意，在struct中，所有可以填充为256位插槽的变量都彼此相邻排序，以便编译器以后可以将它们堆叠在一起(也使用占用少于256位的那些变量)。在上面的例子中，仅使用两次SSTORE 操作码，一次用于存储*a*，*b*和*c*，另一次用于存储*d*。**这同样适用于在结构体外部的变量**。另外，请记住，**将多个变量放入同一个插槽所节省的费用要比填满整个插槽([首选数据类型]())所节省的费用大得多**。

*注意：请记得使用编译器打包优化*

## 4. 通过汇编将变量打包到单个插槽中

也可以手动应用将变量堆叠在一起以减少执行的SSTORE操作的技术。下面的代码将4个uint64类型的变量堆叠到一个256位插槽中。

**编码：将变量合并为一个。**

```js
function encode(uint64 _a, uint64 _b, uint64 _c, uint64 _d) internal pure returns (bytes32 x) {
    assembly {
        let y := 0
        mstore(0x20, _d)
        mstore(0x18, _c)
        mstore(0x10, _b)
        mstore(0x8, _a)
        x := mload(0x20)
    }
}
```

为了读取，将需要对该变量进行解码，这可以通过第二个功能实现。

**解码：将变量拆分为其初始部分。**

```js
function decode(bytes32 x) internal pure returns (uint64 a, uint64 b, uint64 c, uint64 d) {
    assembly {
        d := x
        mstore(0x18, x)
        a := mload(0)
        mstore(0x10, x)
        b := mload(0)
        mstore(0x8, x)
        c := mload(0)
    }
}
```

将这种方法的 gas 消耗量与上述方法的 gas 消耗量进行比较，你会注意到，由于多种原因，这种方法的成本明显降低：

1. **精度：**使用这种方法，就位打包而言，几乎可以做任何事情。例如，如果已经知道不需要变量的最后一位，则可以通过将正在使用的1位变量与256位变量合并在一起进行优化。
2. **读取一次：**由于变量实际上存储在一个插槽中，因此只需执行一次加载操作即可接收所有变量。如果变量在一起使用，这将特别有益。

那么，为什么还要使用以前的呢？从这两种实现来看，很明显，我们使用汇编来解码变量，就放弃了代码的可读性，因此，使第二种方法更容易出错。另外，由于每种情况下我们都必须包含编码和解码函数，因此部署成本也将大大增加。但是，如果你确实需要降低函数的gas 消耗， (与其他方法相比，装入单个插槽中的变量越多，节省的费用就越高。)

## 5. 连接函数参数

就像你可以从上面使用编码和解码函数来优化读取和存储数据的过程一样，你也可以使用它们来连接函数调用的参数以减少调用数据的成本。即使这会导致交易的执行成本略有增加，但基本费用将减少，交易将变得更便宜。

下面的文章比较了两个函数调用，一个使用了该技术，另一个没有，完美地说明了实际的情况, 可以参看：

[降低Dapp gas 成本的技术](https://medium.com/coinmonks/techniques-to-cut-gas-costs-for-your-dapps-7e8628c56fc9)

## 6 .  Merkle 证明可减少存储负载

简而言之，[默克尔]([https://learnblockchain.cn/tags/%E9%BB%98%E5%85%8B%E5%B0%94%E6%A0%91](https://learnblockchain.cn/tags/默克尔树))证明使用单个数据块来证明大量数据的有效性。

如果你不熟悉Merkle证明背后的想法，请先阅读以下文章，以基本了解：

[默克尔树是如何工作的？](https://media.consensys.net/ever-wonder-how-merkle-trees-work-c2f8b7100ed3)

[Merkle证明的解释说明](https://medium.com/crypto-0-nite/merkle-proofs-explained-6dd429623dc5)

带有Merkle证明的好处实在令人惊讶。让我们看一个例子：

假设我们要保存一辆汽车的购买交易，其中包含所有订购的32种配置。创建具有32个变量的结构体，每个配置项都是非常昂贵！这是merkle证明的来源：

1. 首先，我们看一下哪些信息将在一起请求，并相应地将32个属性分组。假设我们发现了4个组，每个组包含8个配置，以使事情简单。
2. 现在，我们根据它们内部的数据为这四个组分别创建一个哈希，然后根据以前的标准再次将它们分组。
3. 我们将重复此操作，直到只剩下一个哈希，即默克尔树根(hash1234)。

![merkle 树](https://img.learnblockchain.cn/pics/20201102172848.png)
<center>以默克尔树</center>


我们根据是否同时使用两个元素来对它们进行分组的原因是，对于每次验证，该分支的所有元素(在图表中为彩色)都是必需要的，并且也会自动进行验证。这意味着只需要一个验证过程。例如：

![](https://img.learnblockchain.cn/2020/09/28/16012795687657.jpg)
<center>粉色元素的防指纹</ center>

我们在链上只需要存储默克尔根，通常是256位变量(keccak256)，但是，假设汽车制造商向你发送颜色错误的汽车，你可以轻松地证明这不是你所订购的汽车。

```js
bytes32 public merkleRoot;

//Let a,...,h be the orange base blocks
function check
(
    bytes32 hash4,
    bytes32 hash12,
    uint256 a,
    uint32 b,
    bytes32 c,
    string d,
    string e,
    bool f,
    uint256 g,
    uint256 h
)
    public view returns (bool success)
{
    bytes32 hash3 = keccak256(abi.encodePacked(a, b, c, d, e, f, g, h));
    bytes32 hash34 = keccak256(abi.encodePacked(hash3, hash4));
    require(keccak256(abi.encodePacked(hash12, hash34)) == merkleRoot, "Wrong Element");

    return true;
}
```

谨记：如果必须非常频繁地访问某个变量或不时的需要更改某个变量，那么以常规方式存储该特定值可能更有意义。另外，注意分支不能太大，否则分支将超出可用于该交易的堆栈插槽数量（即[Stack Too Deep错误](https://learnblockchain.cn/article/1629)）。

## 7. 无状态合约

无状态合约利用了交易数据和事件调用之类的内容完全保存在区块链上的优势。因此，你要做的就是发送交易并传递你要存储的值，而不是不断更改合约的状态。由于SSTORE操作通常会占大部分交易成本，因此，无状态合约只会消耗有状态合约所消耗的一小部分 gas 。这篇文章: [无状态智能合约](https://medium.com/@childsmaidment/stateless-smart-contracts-21830b0cd1b6) 完美地解释了无状态合约背后的概念，以及如何创建无状态合约及其后端副本。



回到我们的car示例中，我们将发送一两个交易，具体取决于是否可以拼接函数参数*(5 . 连接函数参数)*，然后传递32种汽车配置。只要我们只需要从外部验证信息，此方法就可以正常工作，甚至比默克尔根方法便宜一些。但是，另一方面，使用这种设计（尽管不会牺牲去中心化）从合约内访问这些信息实际上是不可能的。

## 8. 在IPFS上存储数据

[IPFS](https://learnblockchain.cn/2018/12/25/use-ipfs)是一种去中心的数据存储协议，其中每个文件不是通过URL而是通过其内容的哈希来标识的。这样做的好处是无法更改哈希值，因此，一个特定的哈希值将始终指向同一文件。因此，我们可以仅将数据广播到IPFS网络，然后将各自的哈希保存在我们的合约中以在以后查阅该信息。可以在本文中找到有关其工作原理的更详细说明：

[链下数据存储：以太坊和IPFS](https://medium.com/@didil/off-chain-data-storage-ethereum-ipfs-570e030432cf)

就像无状态合约一样，此方法实际上无法真正使用合约中的数据（与Oracles一起使用是可能的）。但是，特别是如果你要存储大量数据(例如视频)，则此方法是迄今为止最好的方法。 (附带说明：Swarm是另一种去中心化存储系统，可能也值得一看作为IPFS的替代方案。)

由于6、7和8的用例非常相似，因此以下是什么使用那个方案的总结：

* **Merkle树：**中小型数据， 数据可以在合约内使用， 更改数据较复杂。
* **无状态合约：**中小型数据。 合约内不能使用数据。，数据可以更改。
* **IPFS：**大量数据。 在合约中使用数据非常麻烦，更改数据非常复杂。


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。