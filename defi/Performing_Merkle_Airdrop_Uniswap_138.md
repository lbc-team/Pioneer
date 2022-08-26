原文链接：https://steveng.medium.com/performing-merkle-airdrop-like-uniswap-85e43543a592

# 像Uniswap一样执行Merkle空投

*如果你想直接跳过如何实现Uniswap空投，请继续阅读以下部分：* **创建Merkle空投的步骤**

![img](https://img.learnblockchain.cn/attachments/2022/05/kBck9IbG6285e77c2632c.jpeg)

图片来自 https://ccoingossip.com/what-is-airdrop-in-crypto-world/

空投是指项目决定向一组用户分发代币的事件。以下是实现空投的一些潜在方法：

1. **管理员调用函数发送代币**

在这种情况下，一个函数实现如下：

```
function airdrop(address address, uint256 amount) onlyOwner {
  IERC20(token).transfer(account, amount);  
}
```

在这种场景下，所有者必须支付gas费才能调用该函数，如果地址列表很大，尤其是在ETH上，这将是不可持续的。

2. **在合约上存储白名单地址列表**

您可能会实现一个映射，该映射 `mapping(address => some struct)`存储所有列入白名单的地址以及该地址是否已认领空投。同样，所有者也必须支付gas费用来存储合约的白名单地址列表。

# Merkle空投

对于Merkle空投，实现了相同的目标并具有以下好处：

- 所有者只需支付gas费来创建合约并将 Merkle 根存储在合约上。
- 列入白名单的地址可以自行调用合约来申领空投——这也开启了在截止日期前申领空投的可能性。

如果你在Defi中足够早，Uniswap的初始空投是通过Merkle完成的——参考 https://github.com/Uniswap/merkle-distributor

# 什么是Merkle空投？

Merkle-based 空投是基于默克尔树的数据结构。

> *我强烈鼓励不熟悉 Merkle 树的人观看此视频*  https://www.youtube.com/watch?v=qHMLy5JjbjQ

举个例子，如果我们有8个值要存储（**A 到 H**）

- 形成第二层：Hash(A+B), Hash(C+D), Hash(E+F), Hash(G+H)
- 形成第三层：Hash(Hash(A+B), Hash(C+D)), Hash(Hash(E+F), Hash(G+H))
- 最后，第四级显示为橙色。

橙色的就是我们所说的**Merkle root**，即树的根。

![img](https://img.learnblockchain.cn/attachments/2022/05/GEJcdQir6285e88586f38.png)

**为什么这有效?**

Merkle树是有效的，因为我们不需要遍历整个树来证明我们的值存在于Merkle树中。例如，要证明**F**属于 Merkle树，我们只需要提供**E、H(GH)**和**H(ABCD)**，有Merkle根的人就可以验证**F**是否属于Merkle树。

> *验证证明只需要对数级的时间！*

![img](https://img.learnblockchain.cn/attachments/2022/05/k5t2bk0N6285e8c3d7ee1.png)

# 创建Merkle空投的步骤

代码参考可以在 https://github.com/steve-ng/merkle-airdrop 找到——使用了 2 个主要库

- 前端：https://github.com/miguelmota/merkletreejs
- Solidity：https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/cryptography/MerkleProof.sol

**先决条件**

- 生成他们有资格获得的白名单和金额列表
- 根据列表生成Merkle根

该示例可以在 https://github.com/steve-ng/merkle-airdrop/blob/main/test/MerkleDistributor.ts 中找到

```
// 生成有资格的白名单和金额列表
const users = [    
  { address: "0x..", amount: 10 },    
  { address: "0x..", amount: 15 },    
  { address: "0x...", amount: 20 },    
  { address: "0x..", amount: 30 },  
]; 
// 编码数据结构
const elements = users.map((x) =>     
  utils.solidityKeccak256(
    ["address", "uint256"], [x.address, x.amount]));
const merkleTree = 
  new MerkleTree(elements, keccak256, { sort: true });
// 生成Merkle根
const root = merkleTree.getHexRoot();
```

**在你的智能合约中**

生成的 Merkle根存储在你的智能合约中——你可以参考 https://github.com/steve-ng/merkle-airdrop/blob/main/contracts/MerkleDistributor.sol

**在你的前端**

- 存储所有符合空投条件的地址，这样当用户访问你的站点时，他们可以立即查看他们是否符合条件
- 如果他们符合条件，请使用证明调用智能合约。

同样，代码可以在 https://github.com/steve-ng/merkle-airdrop/blob/main/test/MerkleDistributor.ts#L46 的测试用例中找到

# 概括

一旦您了解了 Merkle 空投的工作原理，实现就非常简单。该用例不仅适用于空投，您还可以为具有白名单要求的应用程序实现此功能，如IDO 或早期访问某些功能。
