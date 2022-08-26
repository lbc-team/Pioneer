原文链接：https://steveng.medium.com/performing-merkle-airdrop-like-uniswap-85e43543a592
 

# 像 Uniswap 一样执行 Merkle 空投

*如果你想直接跳过如何实现 Uniswap 空投，请继续以下部分：* **创建 Merkle 空投的步骤**


![img](https://img.learnblockchain.cn/attachments/2022/05/kBck9IbG6285e77c2632c.jpeg)

图片来自https://ccoingossip.com/what-is-airdrop-in-crypto-world/

 


空投是项目决定将代币赠送给一部分用户时的事件。 这些是实现空投的一些潜在方法：

1. **管理员调用函数发送tokens**

在这个例子里，如下是一个函数实现：
```
function airdrop(address address, uint256 amount) onlyOwner {
  IERC20(token).transfer(account, amount);  
}
```
 
在这种情况下，所有者必须支付 gas 费才能调用该函数，如果地址列表很大，尤其是在 ETH 上，这将是不可持续的方案。


**二。 在合约上存储白名单地址列表**

你可能会实现一个映射`mapping(address => some struct)`，它存储所有列入白名单的地址以及该地址是否已认领空投。 同样，合约所有者也必须支付 gas 费用来存储合约的白名单地址列表。

 

# Merkle空投

对于 Merkle 空投实现，实现了相同的目标，并具有以下好处：

- 所有者只需支付创建合约并将 Merkle 根存储在合约上的 Gas 费
- 列入白名单的地址可以自行调用合约来领取空投——这也开启了在截止日期前领取空投的可能性。

如果你在 Defi 中足够早，Uniswap 的初始空投是通过 Merkle 完成的——参考 https://github.com/Uniswap/merkle-distributor



# 什么是Merkle空投？

Merkle-based 空投基于 Merkle Tree 数据结构。

> 我强烈建议刚熟悉 Merkle 树的人观看此视频 https://www.youtube.com/watch?v=qHMLy5JjbjQ

举个下面的例子，如果我们有8个值要存储（**A到H**），我们从

- 形成第二层：Hash(A+B), Hash(C+D), Hash(E+F), Hash(G+H)
- 形成第三层：Hash(Hash(A+B), Hash(C+D)), Hash(Hash(E+F), Hash(G+H))
- 最后，第四级显示为橙色。

橙色的就是我们所说的 **Merkle root**，树的根。


![img](https://img.learnblockchain.cn/attachments/2022/05/GEJcdQir6285e88586f38.png)

 
**为什么这会有效的？**

Merkle 树是有效的，因为我们不需要遍历整个树来证明我们的值存在于 Merkle 树中。 例如，要证明 **F** 属于 Merkle 树，我们只需要提供 **E, H(GH),** 和 **H(ABCD)** 并且有根的人可以验证是否 **F** 属于Merkle树。

> *验证它只需要对数！*

![img](https://img.learnblockchain.cn/attachments/2022/05/k5t2bk0N6285e8c3d7ee1.png)
 
# 创建 Merkle 空投的步骤

代码参考可以在链接的代码中找到 https://github.com/steve-ng/merkle-airdrop ——使用了2个主要库

- 前端：https://github.com/miguelmota/merkletreejs
- Solidity 方面：https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/cryptography/MerkleProof.sol

**先决条件**

- 生成他们有资格获得的白名单和金额列表
- 根据列表生成 Merkle 根

该示例可以在 https://github.com/steve-ng/merkle-airdrop/blob/main/test/MerkleDistributor.ts 中找到

```
// Generate the list of whitelisted user and amount qualified 
const users = [    
  { address: "0x..", amount: 10 },    
  { address: "0x..", amount: 15 },    
  { address: "0x...", amount: 20 },    
  { address: "0x..", amount: 30 },  
]; 
// Encode the datastructure 
const elements = users.map((x) =>     
  utils.solidityKeccak256(
    ["address", "uint256"], [x.address, x.amount]));
const merkleTree = 
  new MerkleTree(elements, keccak256, { sort: true });
// Generate the root 
const root = merkleTree.getHexRoot();
```
 
**在你的智能合约中**

在你的智能合约中存储生成的 Merkle Root——你可以参考 https://github.com/steve-ng/merkle-airdrop/blob/main/contracts/MerkleDistributor.sol

**在你的前端**

- 存储所有符合空投条件的地址，这样当用户访问你的站点时，他们可以立即查看他们是否符合条件。
- 如果他们符合条件，请调用智能合约加以证明。

同样，代码可以在 https://github.com/steve-ng/merkle-airdrop/blob/main/test/MerkleDistributor.ts#L46 的测试用例中找到

 

# 概括

一旦你了解了 Merkle 空投的工作原理，实现起来就非常简单。 该用例不仅适用于空投，你还可以为具有白名单要求的应用程序实现此功能，例如。 IDO 或早期访问某些功能。


