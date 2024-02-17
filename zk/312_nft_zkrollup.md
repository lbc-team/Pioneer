

# 如何使用 Circom 和 SnarkJS 实现极简 NFT zkRollup

> 零知识 Rollup（ZK-rollups）是 Layer2 扩展解决方案，通过将计算和状态存储转移到链下，从而增加了以太坊主网的吞吐量。ZK-rollups 可以批处理处理数千笔交易，然后仅向主网发布一些最小的摘要数据。这些摘要数据定义了应对以太坊状态进行的更改以及这些更改正确的加密证明。*—* [*以太坊文档*](https://ethereum.org/en/developers/docs/scaling/zk-rollups/)

听起来不错？为什么不为了好玩而实现我们自己的 Rollup 呢？

在本文中，我们将开发一个极简的零知识 Rollup。需要注意的是，本文的主要目标是让读者了解这项技术，因此重点不在于效率，而在于简单和易懂。

理解本文的先决条件是了解零知识证明技术、Circom 语言和 SnarkJS 库的基础知识。如果这些主题对你来说都很陌生，那么值得阅读[我的文章](https://learnblockchain.cn/article/7402)关于零知识证明技术，以及[我的文章](https://learnblockchain.cn/article/7403)关于使用 Circom 和 SnarkJS 进行编程。

实现 zkRollup 并不是一项简单的任务。在开始之前，我们需要熟悉稀疏默克尔树（SMT）的概念。

[稀疏默克尔树](https://ethresear.ch/t/optimizing-sparse-merkle-trees/3751)是一个键/值存储。在这方面，它类似于[默克尔帕特里夏树](https://ethereum.org/en/developers/docs/data-structures-and-encoding/patricia-merkle-trie/) （以太坊将所有数据存储在这些结构中），但要简单得多。默克尔帕特里夏树是一个复杂的数据结构，而稀疏默克尔树是一个简单的二叉树，其中每个父节点存储其子节点的哈希，存储的值是叶子元素，类似于一般的默克尔树。它通过根据键位确定子元素的路径来成为键/值存储。让我们看一下下面这个非常简单的默克尔树，它有两层，包含 4 个值：

![img](https://img.learnblockchain.cn/attachments/migrate/1708177975971)

> 来源：维基百科

在这棵树中，两位键可以寻址元素。如果给定位的位是 0，我们向树的左侧移动；如果是 1，我们向右侧移动。例如，如果键是 10，首先我们向右移动，然后向左移动，从而到达元素 L3。当然，在实践中，两位键并没有太多意义，而且随着键的大小增加，树的大小呈指数级增长，因此对于大量键的存储需要大量的存储容量。因此，如果我们想要在树中存储 5 个数字，但键的大小是 16 位，我们将不得不存储 65536 个值，其中有 5 个是有意义的，而 65531 个是 0。这就是为什么这种结构被称为稀疏默克尔树，因为我们通常在其中存储的值远少于其容量。幸运的是，这样的结构可以被相当巧妙地压缩：只需要向下移动与相关位一样深的结构。

让我们在上面的结构中存储 3 个值。它们的键是 00、01、10。要存储与键 00 和 01 对应的值，我们必须到达第 2 级，但与键 10 对应的值我们可以存储在第 1 级。因此，我们得到了一棵树，在根元素的左侧有一个带有 2 个叶子的分支节点，而在右侧直接有一个叶子节点。通过对二叉树的“修剪”，我们可以非常有效地存储这些元素。

SMT 相对于一般的默克尔树的优势在于，它不仅允许我们提供**包含证明**，还允许我们提供**排除证明**。这意味着我们可以证明树不包含给定键的值。由于这一点，我们可以证明任何操作（插入、删除、更新），这将是我们的 Rollup 的一个非常重要的特性。幸运的是，Circomlib（以及 [CircomlibJS](https://github.com/iden3/circomlibjs)）包括了 SMT 的实现，因此我们不需要自己实现这一点。

我们的 Rollup 将在 SMT 中存储 NFT。NFT 的 ID 将作为键，其值将是当前所有者的公钥。要转移 NFT，所有者必须生成一个包含新所有者公钥和 NFT 标识符的数字签名交易。所有者必须证明两件事：一是他们签署了交易，二是他们是 NFT 的所有者，因此他们的公钥与 NFT 的 ID 一起存储。如果这两个证明有效，那么 NFT 的所有权将转移到新所有者名下。

排序器（sequencer）收集这些 NFT 转移交易，计算遵循交易的默克尔根，然后将新根、交易列表和零知识证明发送到一个智能合约，证明发送的交易确实生成了发送的根。智能合约检查零知识证明，如果检查成功，则修改根。

任何人都可以向智能合约提交交易批次，只要他们提供相应的零知识证明。为此，他们需要设置 SMT，这很容易实现，因为所有交易都写在了区块链上。还有一种特殊的 Rollups 变体，称为 Validium，其中交易不会写在区块链上，而是存储在外部存储库（例如 IPFS 或 Swarm）。这是一个更便宜的解决方案，但我们必须保证数据的可用性。例如，在一个 DAO 中，我们必须选择验证者，他们必须在验证数据确实可用后签署状态根修改，然后才能签署交易。

以下是 Vitalik Buterin 的一个非常简单的总结图：

![img](https://img.learnblockchain.cn/attachments/migrate/1708177975965)

简而言之，这就是我们的 Rollup 的工作原理。听起来并不太复杂，对吧？从代码中我们将看到魔鬼就在细节中。让我们来看一下代码。（当然，所有代码都可以在 [GitHub](https://github.com/TheBojda/mini-zk-rollup) 上找到。）

为简单起见，我们将预先创建 NFT，并且它们无法从 Rollup 转移到区块链（NFT 只存在于 Rollup 上），因此实现 NFT 转移就足够了（这本身已经足够复杂了）。在文章的最后，我将解释如何进一步开发我们的 Rollup，以使 NFT 能够在区块链和 Rollup 之间转移。

作为第一步，让我们生成钱包用户账户。与以太坊账户类似，每个 Rollup 账户都有一个私钥、一个公钥和一个地址，但是，我们使用 EDDSA 而不是 ECDSA 来对交易进行数字签名。EDDSA 是一种适用于零知识证明的数字签名格式。我们将随机生成私钥，并借助 Poseidon Hash（一种适用于零知识证明的哈希算法）从公钥生成地址。以下是生成 5 个测试账户的代码：

```
for (let i = 0; i < 5; i++) {
  // generate private and public eddsa keys, 
  // the public address is the poseidon hash of the public key
  const prvKey = randomBytes(32);
  const pubKey = eddsa.prv2pub(prvKey);
  accounts[i] = {
    prvKey: prvKey,
    pubKey: pubKey,
    address: trie.F.toObject(poseidon(pubKey))
  }
}
```

在地址生成时，我们使用 trie.F.toObject 函数将 Poseidon 哈希转换为[有限域](https://en.wikipedia.org/wiki/Finite_field) 。

下一步是创建 NFT。为此，我们创建一个 SMT 并正确填充它。SMT 中的键是 NFT ID，相关值是 NFT 所有者的地址。（稍后我将介绍关于 nonce SMT 的内容。）

```javascript
// generate 5 NFTs, and set the first account as owner
for (let i = 1; i <= 5; i++) {
  await trie.insert(i, accounts[0].address)
  await nonceTrie.insert(i, 0)
}
```

解决的第一个任务是使用户能够创建数字签名交易。交易由 3 个数据元素组成。要转移的资产的 NFT ID，要发送的 NFT 的目标地址以及一个 nonce。nonce 是一个递增的计数器，用于使每个交易都是唯一的且只能执行一次。这与以太坊用于使交易唯一的解决方案非常相似，只是以太坊将 nonce 分配给以太坊地址，而在我们的情况下，我们将其分配给 NFT。如果我们将 nonce 分配给地址，那么我们将需要一个更大的 SMT（如果地址是密钥，则密钥大小为 32 位），因此将其与只需要一个 10 位树的 NFT 相关联更为实际。因此，交易是这 3 个值的 Poseidon 哈希。这是使用 EDDSA 进行数字签名的。

```javascript
const createTransferRequest = (owner: Account, target: Account, 
  nftID: number, nonce: number): TransferRequest => {
  const transactionHash = poseidon([
    buffer2hex(target.address), nftID, buffer2hex(nonce)
  ])
  const signature = eddsa.signPoseidon(owner.prvKey, 
    transactionHash);
  return {
    ownerPubKey: owner.pubKey,
    targetAddress: target.address,
    nftID: nftID,
    nonce: nonce,
    signature: signature
  }
}
```

可以使用以下 Circom 电路验证此交易：

```
pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/eddsaposeidon.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template VerifyTransferRequest() {

    signal input targetAddress;
    signal input nftID;
    signal input nonce;
    
    signal input Ax;
    signal input Ay;
    signal input S;
    signal input R8x;
    signal input R8y;
    
    component eddsa = EdDSAPoseidonVerifier();
    component poseidon = Poseidon(3);
    
    // calculate the transaction hash
    
    poseidon.inputs[0] <== targetAddress;
    poseidon.inputs[1] <== nftID;
    poseidon.inputs[2] <== nonce;
    
    // verify the signature on the transaction hash
    
    eddsa.enabled <== 1;
    eddsa.Ax <== Ax;
    eddsa.Ay <== Ay;
    eddsa.S <== S;
    eddsa.R8x <== R8x;
    eddsa.R8y <== R8y;
    eddsa.M <== poseidon.out;

}
```

前 3 个输入信号（targetAddress、nftID、nonce）是交易的数据，而接下来的 5 个（Ax、Ay、S、R8x、R8y）是公钥和数字签名。该电路首先从交易数据计算出 Poseidon 哈希，然后验证数字签名以及其是否属于给定的公钥。

以下代码片段显示了如何使用 TypeScript 检查电路：

```typescript
const transferRequest = await createTransferRequest(accounts[0], 
  accounts[1], 1, 0)

const inputs = {
  targetAddress: buffer2hex(transferRequest.targetAddress),
  nftID: transferRequest.nftID,
  nonce: buffer2hex(transferRequest.nonce),
  Ax: eddsa.F.toObject(transferRequest.ownerPubKey[0]),
  Ay: eddsa.F.toObject(transferRequest.ownerPubKey[1]),
  R8x: eddsa.F.toObject(transferRequest.signature.R8[0]),
  R8y: eddsa.F.toObject(transferRequest.signature.R8[1]),
  S: transferRequest.signature.S,
}

const w = await verifyTransferCircuit.calculateWitness(inputs, true);
await verifyTransferCircuit.checkConstraints(w);
```

电路的每个输入信号都是 BigNumber。使用 bufer2hex 函数将 targetAddress 和 nonce 转换为十六进制 BigNumber 格式，而使用 eddsa.F.toObject 将 Ax、Ay、R8x 和 R8y 信号转换为有限域格式。这是必要的，因为在零知识证明的世界中，所有计算都是在有限域中进行的。对于 targetAddress、nonce、nftID 和 S 参数，这是不必要的，因为它们已经映射到了有限域。

我使用了 [circom_tester](https://github.com/iden3/circom_tester) 库来检查电路，这是一种非常有效的测试电路的解决方案，因为无需为测试编译电路。calculateWitness 函数计算见证，然后由 checkConstraints 进行检查。

下一步是运行完整的交易并为其生成证明：

```javascript
const transferNFT = async (from: Account, to: Account, nftID: number) => {
  // get the nonce for the NFT
  const nonce = BigNumber.from(
    nonceTrie.F.toObject((await nonceTrie.find(nftID)).foundValue)
  ).toNumber()

  // creating transfer request
  const transferRequest = await createTransferRequest(from, to, nftID, nonce)

  // move the NFT to the new owner
  const nft_res = await trie.update(nftID, transferRequest.targetAddress)

  // increase nonce for the NFT
  const nonce_res = await nonceTrie.update(nftID, transferRequest.nonce + 1)

  // generate and check zkp
  let nft_siblings = convertSiblings(nft_res.siblings)
  let nonce_siblings = convertSiblings(nonce_res.siblings)

  const inputs = {
    targetAddress: buffer2hex(transferRequest.targetAddress),
    nftID: transferRequest.nftID,
    nonce: buffer2hex(transferRequest.nonce),
    Ax: eddsa.F.toObject(transferRequest.ownerPubKey[0]),
    Ay: eddsa.F.toObject(transferRequest.ownerPubKey[1]),
    R8x: eddsa.F.toObject(transferRequest.signature.R8[0]),
    R8y: eddsa.F.toObject(transferRequest.signature.R8[1]),
    S: transferRequest.signature.S,
    oldRoot: trie.F.toObject(nft_res.oldRoot),
    siblings: nft_siblings,
    nonceOldRoot: trie.F.toObject(nonce_res.oldRoot),
    nonceSiblings: nonce_siblings
  }

  const w = await verifyRollupTransactionCircuit.calculateWitness(
    inputs, true
  );
  await verifyRollupTransactionCircuit.checkConstraints(w);
  await verifyRollupTransactionCircuit.assertOut(w, {
    newRoot: trie.F.toObject(nft_res.newRoot),
    nonceNewRoot: trie.F.toObject(nonce_res.newRoot)
  });

}
```

首先，我们读取与 NFT 关联的 nonce 以生成交易。要运行交易，我们将 SMT 从所有者更新到新所有者，并将 nonce 值在 nonce SMT 中递增 1。update 函数除了执行修改外，还返回了证明操作所需的兄弟节点。

我们像往常一样使用 checkConstraints 函数检查电路的正确执行。如果电路正常工作，则两个输出必须与 SMT 的新根匹配。

让我们看一下验证交易的电路：

```circom
pragma circom 2.0.0;

include "verify-transfer-req.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template RollupTransactionVerifier(nLevels) {

    signal input targetAddress;
    signal input nftID;
    signal input nonce;
    
    signal input Ax;
    signal input Ay;
    signal input S;
    signal input R8x;
    signal input R8y;
    
    signal input oldRoot;
    signal input siblings[nLevels];
    
    signal input nonceOldRoot;
    signal input nonceSiblings[nLevels];
    
    signal output newRoot;
    signal output nonceNewRoot;
    
    component transferRequestVerifier = VerifyTransferRequest();
    component smtVerifier = SMTProcessor(nLevels);
    component nonceVerifier = SMTProcessor(nLevels);
    component poseidon = Poseidon(2);
    
    // verify the transfer request
    
    transferRequestVerifier.targetAddress <== targetAddress;
    transferRequestVerifier.nftID <== nftID;
    transferRequestVerifier.nonce <== nonce;
    
    transferRequestVerifier.Ax <== Ax;
    transferRequestVerifier.Ay <== Ay;
    transferRequestVerifier.S <== S;
    transferRequestVerifier.R8x <== R8x;
    transferRequestVerifier.R8y <== R8y;
    
    // verify the SMT update
    // the old value of the NFT ID key has to be the poseidon hash of 
    // the signers public key, 
    // the new value is the target address 
    
    poseidon.inputs[0] <== Ax;
    poseidon.inputs[1] <== Ay;
    
    smtVerifier.fnc[0] <== 0;
    smtVerifier.fnc[1] <== 1;
    smtVerifier.oldRoot <== oldRoot;
    smtVerifier.siblings <== siblings;
    smtVerifier.oldKey <== nftID;
    smtVerifier.oldValue <== poseidon.out;
    smtVerifier.isOld0 <== 0; 
    smtVerifier.newKey <== nftID;
    smtVerifier.newValue <== targetAddress;
    
    // verify nonce SMT update, the new value has to be the old value + 1
    
    nonceVerifier.fnc[0] <== 0;
    nonceVerifier.fnc[1] <== 1;
    nonceVerifier.oldRoot <== nonceOldRoot;
    nonceVerifier.siblings <== nonceSiblings;
    nonceVerifier.oldKey <== nftID;
    nonceVerifier.oldValue <== nonce;
    nonceVerifier.isOld0 <== 0; 
    nonceVerifier.newKey <== nftID;
    nonceVerifier.newValue <== nonce + 1;
    
    newRoot <== smtVerifier.newRoot; 
    nonceNewRoot <== nonceVerifier.newRoot;

}
```

RollupTransactionVerifier 模板有一个参数：SMT 的深度。输入是数字签名的交易、SMT 的先前根和兄弟节点。我们必须证明：

- 交易是有效的
- 签署交易的用户地址与 SMT 中转移的 NFT 相关联
- 在 SMT 中，与 NFT 相关联的地址已被修改为新地址（targetAddress）
- 与关联 NFT 的 SMT 中的 nonce 已增加 1

在第一个代码块中，我们使用之前介绍的 VerifyTransferRequest 电路验证交易。

在第二个代码块中，我们验证 SMT 修改。为此，我们使用 Poseidon 哈希从 Ax 和 Ay 参数计算出交易签署者的地址。如果此地址最初分配给 NFT，则交易有效。

我们可以使用 SMTProcessor 电路证明 SMT 修改。这是一个通用电路，适用于证明每个转换（插入、更新、删除）。fnc 信号确定电路的功能。如果 fnc 值为 01，我们可以证明更新。如果旧值（oldValue）与 nftID 关联，并且新值（newValue）是交易中指定的 tragetAddress 的地址，则交易有效。

在第三个代码块中，我们验证 SMT 中的 nonce 是否增加了 1。如果所有条件都满足，则电路输出是 SMT 和 nonce SMT 的新根。

现在我们可以验证交易，剩下的就是创建最终的电路，可以验证整个批处理。这是最终电路的样子：

```javascript
pragma circom 2.0.0;

include "rollup-tx.circom";
include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template Rollup(nLevels, nTransactions) {

    signal input oldRoot;
    signal input newRoot;
    
    signal input nonceOldRoot;
    signal input nonceNewRoot;
    
    signal input nonceList[nTransactions];
    signal input targetAddressList[nTransactions];
    signal input nftIDList[nTransactions];
    
    signal input AxList[nTransactions];
    signal input AyList[nTransactions];
    signal input SList[nTransactions];
    signal input R8xList[nTransactions];
    signal input R8yList[nTransactions];
    
    signal input siblingsList[nTransactions][nLevels];
    signal input nonceSiblingsList[nTransactions][nLevels];
    
    signal input transactionListHash;
    signal input oldStateHash;
    signal input newStateHash;
    
    // verify the transactions in the transaction list, 
    // and calculate the new roots
    
    var root = oldRoot;
    var nonceRoot = nonceOldRoot;
    component rollupVerifiers[nTransactions];
    for (var i = 0; i < nTransactions; i++) {
        rollupVerifiers[i] = RollupTransactionVerifier(nLevels);
    
        rollupVerifiers[i].targetAddress <== targetAddressList[i];
        rollupVerifiers[i].nftID <== nftIDList[i];
        rollupVerifiers[i].nonce <== nonceList[i];
    
        rollupVerifiers[i].Ax <== AxList[i];
        rollupVerifiers[i].Ay <== AyList[i];
        rollupVerifiers[i].S <== SList[i];
        rollupVerifiers[i].R8x <== R8xList[i];
        rollupVerifiers[i].R8y <== R8yList[i];
    
        rollupVerifiers[i].siblings <== siblingsList[i];
        rollupVerifiers[i].oldRoot <== root;
    
        rollupVerifiers[i].nonceSiblings <== nonceSiblingsList[i];
        rollupVerifiers[i].nonceOldRoot <== nonceRoot;
    
        root = rollupVerifiers[i].newRoot;
        nonceRoot = rollupVerifiers[i].nonceNewRoot;
    }
    
    // compute sha256 hash of the transaction list
    
    component sha = Sha256(nTransactions * 2 * 32 * 8);
    component address2bits[nTransactions];
    component nftid2bits[nTransactions];
    
    var c = 0;
    
    for(var i=0; i<nTransactions; i++) {
        address2bits[i] = Num2Bits(32 * 8);
        address2bits[i].in <== targetAddressList[i];
        for(var j=0; j<32 * 8; j++) {
            sha.in[c] <== address2bits[i].out[(32 * 8) - 1 - j];
            c++;
        }
    }
    
    for(var i=0; i<nTransactions; i++) {
        nftid2bits[i] = Num2Bits(32 * 8);
        nftid2bits[i].in <== nftIDList[i];
        for(var j=0; j<32 * 8; j++) {
            sha.in[c] <== nftid2bits[i].out[(32 * 8) - 1 - j];
            c++;
        }
    }
    
    component bits2num = Bits2Num(256);
    for(var i=0; i<256; i++) {
        bits2num.in[i] <== sha.out[255 - i];
    }
    
    // check the constraints
    
    transactionListHash === bits2num.out;
    newRoot === root;
    nonceNewRoot === nonceRoot;
    
    component oldStateHasher = Poseidon(2);
    oldStateHasher.inputs[0] <== oldRoot;
    oldStateHasher.inputs[1] <== nonceOldRoot;
    
    component newStateHasher = Poseidon(2);
    newStateHasher.inputs[0] <== newRoot;
    newStateHasher.inputs[1] <== nonceNewRoot;
    
    oldStateHash === oldStateHasher.out;
    newStateHash === newStateHasher.out;

}

component main {public [oldStateHash, newStateHash, transactionListHash]} = 
  Rollup(10, 8);
```

主要点在第一个代码块，我们在迭代中调用了之前介绍的 RollupTransactionVerifier。我们将 root 和 nonceRoot 变量设置为 SMT 的当前根和 nonce SMT，然后按顺序执行交易，并始终更新 root 和 nonceRoot 变量的值。执行交易后，我们得到最终的根，可以将其存储在区块链上。Rollup 的第一个版本只包括此代码块，并且交易数据是公共输入，但效率不高。

如果我们在链上使用智能合约验证零知识证明，验证的成本取决于公共变量的数量，因此验证的成本随着交易数量的增加而增加。因此，我修改了 rollup 电路，使用交易的 sha256 哈希而不是交易列表。这足以验证交易，而且只需要 1 个输入而不是多个。因此，第二个代码块计算交易的 sha256 哈希，并将其与由智能合约生成的 transactionListHash 输入进行比较。在 circom 电路中计算 sha256 哈希有点棘手，因为位的顺序并不容易处理，但经过几天的研究、阅读和尝试，我找到了正确的计算哈希的方法。

在电路的最后，第三个代码块还有一点优化。电路最初使用了 2 个 SMT 根，即 NFT 状态根和 nonce 状态根。从这些根通过 Poseidon 哈希形成了一个 oldStateHash 和一个 newStateHash 值，因此状态参数的数量从 4 减少到 2，只需要在区块链上存储 1 个状态根而不是 2 个。因此，rollup 最终有 3 个公共输入：oldStateHash 是初始状态，transactionListHash 是交易列表的 sha256 哈希，newStateHash 是将要存储在区块链上的最终状态。

这是使用上述电路生成零知识证明的 TypeScript 代码，用于验证整个批处理：

```typescript
const generateBatchTransferZKP = async (_trie: any, _nonceTrie, 
  transferRequestList: TransferRequest[]) => {
  let targetAddressList = []
  let nftIDList = []
  let nonceList = []
  let AxList = []
  let AyList = []
  let SList = []
  let R8xList = []
  let R8yList = []
  let siblingsList = []
  let nonceSiblingsList = []

  const oldRoot = _trie.F.toObject(_trie.root)
  const nonceOldRoot = _nonceTrie.F.toObject(_nonceTrie.root)

  for (const transferRequest of transferRequestList) {
    targetAddressList.push(buffer2hex(transferRequest.targetAddress))
    nftIDList.push(buffer2hex(transferRequest.nftID))
    nonceList.push(buffer2hex(transferRequest.nonce))
    AxList.push(eddsa.F.toObject(transferRequest.ownerPubKey[0]))
    AyList.push(eddsa.F.toObject(transferRequest.ownerPubKey[1]))
    SList.push(transferRequest.signature.S)
    R8xList.push(eddsa.F.toObject(transferRequest.signature.R8[0]))
    R8yList.push(eddsa.F.toObject(transferRequest.signature.R8[1]))

    const res = await _trie.update(transferRequest.nftID, 
      transferRequest.targetAddress)
    siblingsList.push(convertSiblings(res.siblings))
    
    const res2 = await _nonceTrie.update(transferRequest.nftID, 
      transferRequest.nonce + 1)
    nonceSiblingsList.push(convertSiblings(res2.siblings))
  }

 const newRoot = _trie.F.toObject(_trie.root)
  const nonceNewRoot = _nonceTrie.F.toObject(_nonceTrie.root)

  let transactionBuffers = []
  for (const transferRequest of transferRequestList) {
    transactionBuffers.push(numToBuffer(transferRequest.targetAddress))
  }
  for (const transferRequest of transferRequestList) {
    transactionBuffers.push(numToBuffer(transferRequest.nftID))
  }
  const hash = createHash("sha256").update(Buffer.concat(transactionBuffers))
    .digest("hex")
  const ffhash = BigNumber.from('0x' + hash).mod(FIELD_SIZE)

  const oldStateHash = poseidon([oldRoot, nonceOldRoot])
  const newStateHash = poseidon([newRoot, nonceNewRoot])

  return await snarkjs.groth16.fullProve(
    {
      targetAddressList: targetAddressList,
      nftIDList: nftIDList,
      nonceList: nonceList,
      AxList: AxList,
      AyList: AyList,
      R8xList: R8xList,
      R8yList: R8yList,
      SList: SList,
      siblingsList: siblingsList,
      nonceSiblingsList: nonceSiblingsList,
      oldRoot: oldRoot,
      nonceOldRoot: nonceOldRoot,
      newRoot: newRoot,
      nonceNewRoot: nonceNewRoot,
      transactionListHash: ffhash.toHexString(),
      oldStateHash: poseidon.F.toObject(oldStateHash),
      newStateHash: poseidon.F.toObject(newStateHash)
    },
    "./build/rollup_js/rollup.wasm",
    "./build/rollup.zkey");
}
```

最后，智能合约在区块链上存储状态根，并验证零知识证明：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./RollupVerifier.sol";
import "hardhat/console.sol";

uint256 constant FIELD_SIZE = 
  21888242871839275222246405745257275088548364400416034343698204186575808495617;

interface IVerifier {
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[3] memory input
    ) external pure returns (bool r);
}

contract Rollup {
    IVerifier public immutable verifier;

    event RootChanged(uint newRoot);
    
    uint root;
    
    constructor(uint _root, IVerifier _verifier) {
        root = _root;
        verifier = _verifier;
    }
    
    function updateState(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint _oldRoot,
        uint _newRoot,
        uint[16] calldata transactionList
    ) external {
        require(root == _oldRoot, "Invalid old root");
    
        uint256 hash = uint256(sha256(abi.encodePacked(transactionList)));
        hash = addmod(hash, 0, FIELD_SIZE);
    
        require(
            verifier.verifyProof(_pA, _pB, _pC, [hash, _oldRoot, _newRoot]),
            "Verification failed"
        );
    
        root = _newRoot;
        emit RootChanged(root);
    }
    
    function getRoot() public view virtual returns (uint) {
        return root;
    }

}
```

Rollup 合约本身相对简单。在构造函数中，它接收初始状态根和 ZKP 验证器合约的地址，该地址可以从电路的 snarkjs 生成。合约有一个名为 root 的变量，用于存储状态根，并在每次批处理运行后发出 RootChanged 事件。

合约有一个 updateState 方法。方法的前三个参数（`_pA`、`_pB`、`_pC`）是零知识证明。`_oldRoot` 是旧状态根，`_newRoot` 是新状态根，transactionList 是交易列表。列表包括我们正在转移的 NFT 列表和作为 NFT 新所有者的目标地址列表。由于我们的示例 rollup 包含 8 个元素，transactionList 将包含 16 个元素。

首先，检查` _oldRoot` 是否与存储在智能合约中的根相匹配。然后计算交易列表的 sha256 哈希。由于在 ZKP 的情况下，每个计算都是在有限域中进行的，我们需要将哈希转换为有限域，这可以通过 addmod 函数来实现。然后对证明进行验证，如果一切正常，就设置新的根

这是一个 TypeScript 示例代码，用于生成零知识证明并调用智能合约：

```typescript
trie = await newMemEmptyTrie()
nonceTrie = await newMemEmptyTrie()
let transferRequests = []
for (let i = 1; i <= BATCH_SIZE; i++) {
  await trie.insert(i, accounts[0].address)
  await nonceTrie.insert(i, 0)
  transferRequests.push(createTransferRequest(accounts[0], accounts[1], i, 0))
}

const oldRoot = trie.F.toObject(trie.root)
const nonceOldRoot = nonceTrie.F.toObject(nonceTrie.root)
const oldStateHash = poseidon.F.toObject(poseidon([oldRoot, nonceOldRoot]))

const Rollup = await ethers.getContractFactory("Rollup");
rollup = await Rollup.deploy(oldStateHash, await rollupVerifier.getAddress());

const { proof, publicSignals } = await generateBatchTransferZKP(
  trie, nonceTrie, transferRequests
)

const newRoot = trie.F.toObject(trie.root)
const nonceNewRoot = nonceTrie.F.toObject(nonceTrie.root)
const newStateHash = poseidon.F.toObject(poseidon([newRoot, nonceNewRoot]))

let transactionList: any = []
for (const transferRequest of transferRequests) {
  transactionList.push(transferRequest.targetAddress)
}
for (const transferRequest of transferRequests) {
  transactionList.push(BigNumber.from(transferRequest.nftID).toBigInt())
}

await rollup.updateState(
  [proof.pi_a[0], proof.pi_a[1]],
  [[proof.pi_b[0][1], proof.pi_b[0][0]], [proof.pi_b[1][1], proof.pi_b[1][0]]],
  [proof.pi_c[0], proof.pi_c[1]],
  publicSignals[1], publicSignals[2], transactionList
)

assert.equal(await rollup.getRoot(), newStateHash);
```

在文章开头，我们提到 Rollup 与 Validium 的不同之处在于将交易列表存储在 calldata 中的区块链上。这很重要，因为如果有人想要向智能合约提交新的批次，他们需要构建 SMT。使用 Rollup，这可以很容易地完成，因为每个交易都存储在区块链上，从中可以构建 SMT。让我们看看实现这一点的代码：

```js
trie = await newMemEmptyTrie()
 nonceTrie = await newMemEmptyTrie()

 for (let i = 1; i <= BATCH_SIZE; i++) {
   await trie.insert(i, accounts[0].address)
   await nonceTrie.insert(i, 0)
 }

 const events = await rollup.queryFilter(rollup.filters.RootChanged)
 for (const event of events) {
   const tx = await event.provider.getTransaction(event.transactionHash)
   const pubSignals = rollup.interface.parseTransaction(tx).args.at(5)
   for (let i = 0; i < BATCH_SIZE; i++) {
     const address = pubSignals[i];
     const nftID = pubSignals[BATCH_SIZE + i];
     await trie.update(nftID, address)
     const nonce = BigNumber.from(
       nonceTrie.F.toObject((await nonceTrie.find(nftID)).foundValue)
     ).toNumber()
     await nonceTrie.update(nftID, nonce + 1)
   }

   const newRoot = trie.F.toObject(trie.root)
   const nonceNewRoot = nonceTrie.F.toObject(nonceTrie.root)
   const newStateHash = poseidon.F.toObject(poseidon([newRoot, nonceNewRoot]))

   assert.equal(newStateHash, rollup.interface.parseTransaction(tx).args.at(4))
```

正如我所写的，智能合约在每次批次运行后会发出 RootChanged 事件。这很有用，因为它使我们能够收集交易，从中我们可以提取交易数据。在上面的代码中，我们使用 queryFilter 方法查询事件。与事件关联的交易哈希可用于完整交易，可以使用 parseTransaction 方法提取 calldata 的交易数据，从中可以重建 SMT，这对于提交新的批次是必要的。

简而言之，这就是极简 NFT Rollup 的工作原理。让我们快速回顾一下。

## 优点

我将传统 NFT 合约与 64 元素批处理大小的 Rollup 进行了比较。在链上转移 64 个 NFT 的成本为 2,965,696 gas，而运行 64 元素批处理仅需 299,575 gas。因此，在 Rollup 上转移 NFT 的成本约为链上解决方案的 10%，我们只在区块链上存储一个根以及 calldata 中的交易列表（或在 Validium 的情况下什么也不存储）。这听起来相当不错。此外，ZKP 验证的成本不取决于交易数量，因此，如果批处理中的交易数量增加了 2 倍或 4 倍，成本也不会增加太多，因此可以节省更多 gas，以及区块链上的更多空间。

## 缺点

编译电路需要大量的 RAM 和计算能力。在我的笔记本电脑上（24G RAM，i7），我能够编译的最大电路约为 64 个元素。对于更大的批处理大小电路（比如 256 个元素），需要大量的 RAM。编译时间也约为半小时到一小时，风扇噪音非常大。幸运的是，为批处理生成证明的时间要快得多，但仍需等待几分钟。通过使用 [rapidsnark](https://github.com/iden3/rapidsnark) 进行证明生成，这个时间可能可以大大缩短，未来这项技术也可能会有很大的改进，例如使用基于 GPU 或 ASIC 的证明生成。

## 不足之处

正如我在文章开头所写的，这是一个极简的解决方案，其目的不是效率，而是理解，因此仍有很多地方可以改进。

Rollup 通常会压缩交易数据，以减少 calldata 的使用。我们的 Rollup 在 32 字节中存储地址和 NFT ID，因此每个批处理中的交易使用 64 字节的 calldata。对于 64 元素批处理，这就是 4096 字节。如果我们只在 4 字节中存储 NFT ID，并引入一个新的 SMT 将地址映射到 ID，那么 4 字节也足以存储地址。这意味着每个交易只需要 8 字节，因此 64 元素批处理只需要 512 字节的 calldata。

我们提到的另一件事是，无法在 Rollup 和区块链之间转移 NFT，因此我们必须预先生成所有 NFT，并仅将它们保留在 Rollup 上。我们之所以这样做是为了保持我们的代码简单。通过引入一个新的 Merkle 树，可以通过将物品转移到 Rollup（存款）来实现。如果有人想要将 NFT 转移到 Rollup，他们应该将其锁定在智能合约中，并提供 Rollup 地址，Rollup 地址将成为 Rollup 上的 NFT 的所有者。这将存储在智能合约管理的 Merkle 树中。然后，必须生成零知识证明，包括 SMT 插入证明和包含证明，以确保相同的地址在智能合约管理的 Merkle 树中提供了 NFT。如果一切正常，那么 NFT 将出现在 Rollup 上，并且可以像之前讨论的那样转移。

要将 NFT 提取到区块链上，必须向 Rollup 合约发送一个 SMT 删除证明，并由 NFT 的当前所有者进行数字签名（使用 EDDSA），并提供智能合约可以将 NFT 转移到的以太坊地址。

## 总结

零知识证明技术和 zk rollup 是区块链世界中最热门的领域之一，可以期待许多突破。我设想未来区块链的唯一职责将是验证 zk 证明和管理状态根，因为每个资产都将存在于 Rollup 上。将不再需要在区块链上运行智能合约，因为这些将在链下运行，只有状态根的变化将被写入区块链，并将由相应的零知识证明进行验证。有了这个解决方案，计算和存储将更加高效地分布，区块链的性能将大大提高。这是一个更加高效而又去中心化的系统。

这些解决方案已经存在于我们的日常生活中。一个例子是 [mina 协议](https://minaprotocol.com/)，在这里智能合约在链下运行，PoS 验证者只收集和存储交易。Mina 不是一个区块链，因为它用递归证明取代了区块链。每个区块包含了前一个区块有效性的证明。由于这个原因，mina 的“区块链” [只有 22KB 大小](https://minaprotocol.com/blog/22kb-sized-blockchain-a-technical-reference) 。

未来非常令人兴奋。因此，值得熟悉零知识证明技术，因为它正在成为区块链世界中日益重要的一部分。


