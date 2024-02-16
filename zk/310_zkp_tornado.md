# 通过 Tornado Cash 的源代码理解零知识证明

> 通过零知识证明深入了解智能合约的世界

![img](https://img.learnblockchain.cn/attachments/migrate/1708050736073)

> 来源：https://unsplash.com/photos/JrrWC7Qcmhs

根据 [Wikipedia](https://en.wikipedia.org/wiki/Zero-knowledge_proof)，零知识证明（ZKP）的定义如下：

> … 零知识证明或零知识协议是一种方法，其中一方（证明者）可以向另一方（验证者）证明给定的陈述是真实的，而证明者避免传达除了该陈述确实是真实的之外的任何其他信息。零知识证明的本质在于，通过简单地揭示信息，可以轻松地证明某人拥有某些信息的知识；挑战在于证明拥有这样的知识，而不泄露信息本身或任何其他附加信息。

[ZKP](https://learnblockchain.cn/tags/%E9%9B%B6%E7%9F%A5%E8%AF%86%E8%AF%81%E6%98%8E) 技术可以广泛应用于许多不同领域，如匿名投票或在像区块链这样的公共数据库上难以解决的匿名货币转账。

[Tornado Cash](https://tornado.cash/) 是一个可以用来匿名化你的以太坊交易的混币器。由于区块链的逻辑，每笔交易都是公开的。如果你的账户上有一些 ETH，你无法匿名地转移它，因为任何人都可以在区块链上跟踪你的交易历史。像 Tornado Cash 这样的混币器可以通过使用 ZKP 打破源地址和目标地址之间的链式关联来解决这一隐私问题。

如果你想匿名化你的一笔交易，你必须在 Tornado Cash 合约上存入少量 ETH（或 ERC20 代币）（例如：1 ETH）。过一段时间后，你可以使用不同的账户提取这 1 ETH。诀窍在于没有人能够创建源账户和提取账户之间的关联。如果数百个账户在一边存入 1 ETH，另外数百个账户在另一边提取 1 ETH，那么没有人将能够追踪资金流动的路径。技术上的挑战在于智能合约交易也像以太坊网络上的任何其他交易一样是公开的。这就是 ZKP 将会发挥作用的地方。

当你在合约上存入你的 1 ETH 时，你必须提供一个“承诺”。这个承诺被智能合约存储。当你在另一边提取 1 ETH 时，你必须提供一个“nullifier”和一个零知识证明。nullifier是与承诺相关联的唯一 ID，而 ZKP 证明了这种关联，但没有人知道哪个nullifier分配给哪个承诺（除了存款人/提取人的所有者）。

**再次强调：我们可以证明其中一个承诺分配给我们的nullifier，而不泄露我们的承诺。**

nullifier由智能合约跟踪，因此我们只能使用一个nullifier提取一笔存入的 ETH。

听起来容易吗？并不是！ :) 让我们深入了解技术。但在任何事情之前，我们必须了解另一个棘手的事情，即 [Merkle 树](https://learnblockchain.cn/tags/Merkle%E6%A0%91) 。

![img](https://img.learnblockchain.cn/attachments/migrate/1708050736079)

来源：https://en.wikipedia.org/wiki/Merkle_tree

Merkle 树是哈希树，其中叶子是元素，每个节点都是子节点的哈希。树的根是 Merkle 根，它代表了整个元素集。如果你添加、删除或更改树中的任何元素（叶子），Merkle 根将发生变化。Merkle 根是元素集的唯一标识符。但我们如何使用它呢？

![img](https://img.learnblockchain.cn/attachments/migrate/1708050736083)

还有另一种叫做 Merkle 证明的东西。如果我有一个 Merkle 根，你可以向我发送一个证明，证明一个元素在由根表示的集合中。下图显示了它是如何工作的。如果你想向我证明 H*K* 在集合中，你必须向我发送 H*L*、H*IJ*、H*MNOP* 和 H*ABCDEFGH* 哈希。使用这些哈希，我可以计算 Merkle 根。如果根与我的根相同，则 H*K* 在集合中。我们可以在哪里使用它呢？

一个简单的例子是白名单。想象一个智能合约，它有一个只能由白名单用户调用的方法。问题在于有 1000 个白名单账户。你如何将它们存储在智能合约上？简单的方法是将每个账户存储在映射中，但这样做非常昂贵。更便宜的解决方案是构建一个 Merkle 树，并仅存储 Merkle 根（1 个哈希 vs 1000 个不算坏）。如果有人想调用该方法，她必须提供一个 Merkle 证明（在这种情况下是一个包含 10 个哈希的列表），这可以很容易地由智能合约验证。

**再次强调：Merkle 树用于用一个哈希（Merkle 根）表示一组元素。Merkle 证明可以证明元素的存在。**

接下来我们必须了解的是零知识证明本身。使用 ZKP，你可以证明你知道某事而不泄露你所知道的事情。要生成 ZKP，你需要一个电路。电路类似于一个具有公共输入和输出以及私有输入的小程序。这些私有输入是你不会为验证而泄露的知识，这就是为什么它被称为零知识证明。使用 ZKP，我们可以证明输出可以从给定的电路输入生成。

一个简单的电路看起来像这样：

```
pragma circom 2.0.0;

include "node_modules/circomlib/circuits/bitify.circom";
include "node_modules/circomlib/circuits/pedersen.circom";

template Main() {
    signal input nullifier;
    signal output nullifierHash;

    component nullifierHasher = Pedersen(248);
    component nullifierBits = Num2Bits(248);

    nullifierBits.in <== nullifier;
    for (var i = 0; i < 248; i++) {
        nullifierHasher.in[i] <== nullifierBits.out[i];
    }

    nullifierHash <== nullifierHasher.out[0];
}

component main = Main();
```

使用这个电路，我们可以证明我们知道给定哈希的来源。这个电路有一个输入（nullifier）和一个输出（nullifier哈希）。输入的默认可访问性是私有的，而输出始终是公开的。这个电路使用 Circomlib 中的 2 个库。[Circomlib](https://github.com/iden3/circomlib) 是一组有用的电路。第一个库是 bitlify，其中包含位操作方法，第二个是 pedersen，其中包含 Pedersen 哈希算法。Pedersen 哈希是一种可以在 ZKP 电路中高效运行的哈希方法。在 Main 模板的主体中，我们填充哈希器并计算哈希。（有关 circom 语言的更多信息，请参阅 [circom 文档](https://docs.circom.io/) ）

要生成零知识证明，你将需要一个证明密钥(proving key)。这是 ZKP 中最敏感的部分，因为使用用于生成证明密钥的源数据，任何人都可以生成伪造的证明。这个源数据被称为“有毒废物(toxic waste)”，必须被销毁。因此，有一个用于生成证明密钥的“仪式”。仪式有许多成员，每个成员都为证明密钥做出贡献。只需要一个非恶意的成员就足以生成有效的证明密钥。使用私有输入、公共输入和证明密钥，ZKP 系统可以运行电路并生成证明和输出。

![img](https://img.learnblockchain.cn/attachments/migrate/1708050736090)

有一个用于证明密钥的验证密钥，可以用于验证。验证系统使用公共输入、输出和验证密钥来验证证明。

![img](https://img.learnblockchain.cn/attachments/migrate/1708050736093)

Snarkjs 是一个全功能工具，可以通过仪式生成证明密钥和验证密钥，生成证明并验证它。它还可以生成用于验证零知识证明的智能合约，可以被任何其他合约使用来验证零知识证明。更多信息，请查看 [snarkjs 文档](https://github.com/iden3/snarkjs) 。
现在，我们已经掌握了理解Tornado Cash（TC）的一切。当你在 TC 合约上存入 1 ETH 时，你必须提供一个承诺哈希。这个承诺哈希将存储在一个默克尔树中。当你使用不同的账户提取这 1 ETH 时，你必须提供 2 个零知识证明。第一个证明了 Merkel 树包含你的承诺。这个证明是一个默克尔证明的零知识证明。但这还不够，因为你应该只能提取这 1 ETH 一次。因此，你必须提供一个对承诺唯一的nullifier。合约存储这个nullifier，这确保了你不能提取存入的资金超过一次。

nullifier的唯一性是由承诺生成方法确保的。承诺是通过对nullifier和一个秘密进行哈希生成的。如果你更改nullifier，那么承诺也会改变，因此一个nullifier只能用于一个承诺。由于哈希的单向性质，不可能将承诺和nullifier联系起来，但我们可以为其生成一个零知识证明。

![img](https://img.learnblockchain.cn/attachments/migrate/1708050736086)

了解理论之后，让我们看看 [TC 的 withdraw 电路](https://github.com/tornadocash/tornado-core/blob/master/circuits/withdraw.circom)是什么样子：

```
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/pedersen.circom";
include "merkleTree.circom";

// 计算 Pedersen(nullifier + secret)
template CommitmentHasher() {
    signal input nullifier;
    signal input secret;
    signal output commitment;
    signal output nullifierHash;
    
    component commitmentHasher = Pedersen(496);
    component nullifierHasher = Pedersen(248);
    component nullifierBits = Num2Bits(248);
    component secretBits = Num2Bits(248);
    nullifierBits.in <== nullifier;
    secretBits.in <== secret;
    for (var i = 0; i < 248; i++) {
        nullifierHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i + 248] <== secretBits.out[i];
    }
    
    commitment <== commitmentHasher.out[0];
    nullifierHash <== nullifierHasher.out[0];
}

// 验证与给定secret和nullifier相对应的承诺是否包含在存款的merkle树中 
template Withdraw(levels) {
    signal input root;
    signal input nullifierHash;
    signal private input nullifier;
    signal private input secret;
    signal private input pathElements[levels];
    signal private input pathIndices[levels];
    
    component hasher = CommitmentHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;
    hasher.nullifierHash === nullifierHash;
    
    component tree = MerkleTreeChecker(levels);
    tree.leaf <== hasher.commitment;
    tree.root <== root;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }
}

component main = Withdraw(20);
```

第一个模板是 CommitmentHasher。它有两个输入，nullifier和 secret ，这两个输入都是两个随机的 248 位数。该模板计算nullifier哈希和承诺哈希，即nullifier和secret的哈希，就像我之前写的那样。

第二个模板是 Withdraw 本身。它有 2 个公共输入，Merkle 根和nullifier哈希。Merkle 根是用于验证 Merkle 证明的，nullifier哈希是智能合约需要存储的。私有输入参数是nullifier、secret 和 Merkle 证明的 pathElements 和 pathIndices。电路通过从 nullifier 和 secret 生成承诺并检查给定的 Merkle 证明来检查nullifier。如果一切正常，将生成零知识证明，该证明可以由 TC 智能合约验证。

你可以在该存储库的 [contracts 文件夹](https://github.com/tornadocash/tornado-core/tree/master/contracts)中找到智能合约。Verifier 是从电路生成的。它被 Tornado 合约用于验证给定nullifier哈希和 Merkle 根的 ZKP。

使用合约的最简单方法是[命令行界面](https://github.com/tornadocash/tornado-core/blob/master/src/cli.js) 。它是用 JavaScript 编写的，其源代码相对简单。你可以轻松找到参数和 ZKP 生成和用于调用智能合约的地方。

零知识证明在加密世界中相对较新。其背后的数学非常复杂，难以理解，但像`snarkjs`和`circom`这样的工具使其易于使用。我希望本文能帮助你理解这种“神奇”的技术，并且你可以在下一个项目中使用 ZKP。

阅读愉快...



我还写了一些关于零知识证明的文章：

[使用 SnarkJS 和 Circom 进行零知识证明](https://betterprogramming.pub/zero-knowledge-proofs-using-snarkjs-and-circom-fac6c4d63202?source=post_page-----41d335c5475f--------------------------------)

以及另一篇关于如何基于 Tornado Cash 的源代码构建了一个 JavaScript 库，用于匿名投票的文章。这是一个逐步教程，涉及 circom、Solidity 和 JavaScript 代码：

[zkSNARK 上的匿名投票 JavaScript 库介绍](https://learnblockchain.cn/article/6896)

以及如何基于此构建了一个投票系统的文章：

[如何使用零知识证明在以太坊区块链上构建匿名投票系统](https://thebojda.medium.com/how-i-built-an-anonymous-voting-system-on-the-ethereum-blockchain-using-zero-knowledge-proof-d5ab286228fd)

---

