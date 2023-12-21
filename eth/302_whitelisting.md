# 智能合约的白名单技术

> tl:dr; 在本教程中，我们将讨论三种智能合约的白名单技术。其中最后一种是使用 [Semaphore](https://semaphore.appliedzkp.org/) 的零知识证明技术栈的全新技术。

![img](https://img.learnblockchain.cn/attachments/migrate/1703067601476)

> [图源](https://www.paldesk.com/wp-content/uploads/2019/06/what-is-whitelist.png)

白名单是一种区分允许使用服务的用户和不允许使用的用户的技术。自几十年来，白名单一直在网络安全中使用，但在区块链世界中，它们在 2017 年的 ICO 狂潮期间变得无处不在。

在本文中，我们将首先讨论自 2017 年以来在 solidity 智能合约中使用的两种白名单技术，这些技术允许地址访问 DApp 的功能。这些技术包括：

1. 使用白名单地址映射
2. 使用 Merkel 树来记录白名单地址

最后，我们将讨论一种全新的前沿技术，称为 Semaphore，以隐私保护的方式在链上维护地址的白名单，而不会透露有关这些地址的任何信息。该技术使用零知识证明来确保不会在链上透露有关用户的任何信息。

因此，让我们开始吧：

## 技术 1: 白名单地址映射

白名单地址的第一种技术是简单地在智能合约中保存映射，并编写相应的 getter 和 setter 函数，只有智能合约的管理员才能调用。

要实现这个简单的智能合约，可以使用以下代码：

```solidity
contract OnChainWhitelistContract is Ownable {

    mapping(address => bool) public whitelist;

    /**
     * @notice Add to whitelist
     */
    function addToWhitelist(address[] calldata toAddAddresses) 
    external onlyOwner {
        for (uint i = 0; i < toAddAddresses.length; i++) {
            whitelist[toAddAddresses[i]] = true;
        }
    }

    /**
     * @notice Remove from whitelist
     */
    function removeFromWhitelist(address[] calldata toRemoveAddresses)
    external onlyOwner {
        for (uint i = 0; i < toRemoveAddresses.length; i++) {
            delete whitelist[toRemoveAddresses[i]];
        }
    }

    /**
     * @notice Function with whitelist
     */
    function whitelistFunc() external
    {
        require(whitelist[msg.sender], "NOT_IN_WHITELIST");

        // Do some useful stuff
    }
}
```

虽然这种技术很容易实现，但Gas成本增长非常快。对于每个地址插入智能合约，你都需要支付 gas。如果你有成千上万个地址需要加入白名单，这将花费多个 ETH。因此，该技术不适合大批量需要列入白名单的地址。

现在我们转向我们的第二种技术。

## 技术 2: 使用 Merkel 树存储预先计算的白名单地址列表

这种技术在 2021 年的空投和 NFT 热潮期间变得流行。大多数情况下，dApp 所有者已经知道他们需要将空投或初始 NFT 发送到哪些地址。例如，dApps 的早期用户或采用者。

在这些情况下，为了允许用户领取奖励，可以在链下创建一个白名单地址的 Merkel 树，并将 Merkel 树的根存储在智能合约中。白名单地址可以从链下应用程序获取其 Merkel 证明，然后将此 Merkel 证明发送到智能合约以领取奖励。

Merkel 树的详细信息和这种技术已经在许多不同的文章中进行了介绍，因此我们在这里不再详细介绍。如果你想了解更多信息，请参阅[此](https://learnblockchain.cn/article/4521)教程。

这种技术的好处是它是无需 gas 的，一旦你在智能合约中存储了 Merkel 根，其余的验证完全免费，为 dApp 所有者节省了大量费用。

但是，该列表是静态的，无法更改。一旦 Merkel 根被存储，就无法添加或删除任何地址。因此，这种技术不适用于白名单列表是动态的情况。

## 技术 3: 使用 Semaphore 的零知识证明生成白名单

[Semaphore](https://semaphore.appliedzkp.org/) 是一个建立在以太坊上的隐私层，使用零知识 SNARK 电路。使用零知识，Semaphore 允许以太坊用户证明他们是某个群组的成员，并发送信号，如投票或认可，而不透露他们的原始身份。

使用 semaphore，dApp 可以允许用户在链下进行身份验证，并为他们生成相应的链上身份，以便将其添加到一个群组。生成的链上身份与区块链身份不同，但用户可以使用它来证明自己是群组的成员；换句话说，他属于白名单。

**Semaphore 特点**

使用 semaphore，你可以执行以下操作：

1. 使用 javascript 库在链下创建一个 Semaphore 身份
2. 在链上创建一个群组
3. 将身份添加到群组
4. 验证用户是否属于一个群组

现在让我们深入了解如何做到这一点：

**步骤 1: 创建用户的身份**

要创建用户的身份，你需要创建一个使用 Semaphore 的 Identity npm 库的链下 dapp

```
import { Identity } from "@semaphore-protocol/identity"
const { trapdoor, nullifier, commitment } = new Identity()
```

生成的身份包含两个随机秘密值：trapdoor 和 nullifier，以及一个公共值：commitment。用户必须将 trapdoor 和 nullifier 保存在一个秘密的地方。

**步骤 2: 在链上创建一个群组**

在添加群组之前，我们需要部署一个可以处理白名单功能的 semaphore 智能合约。原始的 semaphore 合约有一些限制，只允许用户验证一次。因此，我们需要稍微调整合约以删除这个限制。

我已经对智能合约进行了更改，你可以从[这里](https://github.com/Web3-Plurality/zk-onchain-identity-verification/blob/main/dapp-verifier/identity-layer-contracts/SemaphoreIdentity.sol)重用它。

使用你选择的所有者地址部署智能合约。

智能合约部署完成后，现在所有者可以使用智能合约的 CreateGroup 函数在链上创建群组。在链下，你可以使用 semaphore 的 group npm 库创建群组

```javascript
import { Group } from "@semaphore-protocol/group"
const group = new Group(1)
```

*注意：你需要同时维护链上和链下的群组状态，以成功验证参与者。*

**步骤 3: 将身份添加到群组**

我们需要保持链上和链下群组状态的同步，因此我们将在链上和链下都将身份添加到群组。请注意，我们只需要公共的 identityCommitment 来将身份添加到群组。

要在链下将身份添加到群组：

```
group.addMember(identityCommitment)
```

要在链上将身份添加到群组，所有者需要调用智能合约的 addMember 函数。

**步骤 4: 验证用户是否属于一个群组/白名单**

要证明用户是否在白名单内，用户需要使用其公共和私有身份材料，即 commitment、nullifier 和 trapdoor，创建一个链下证明。

```javascript
import { generateProof } from "@semaphore-protocol/proof"
const signal = 1
const fullZKProof = await generateProof(identity, group, groupId, signal)
```

然后，用户将生成的零知识证明提交给 dApp 的所有者（具有群组的最新状态）。所有者然后可以使用智能合约的 VerifyProof 函数将此证明提交到区块链。

如果交易成功，这意味着用户已被列入白名单。如果交易失败，这意味着用户从未被列入白名单或已从白名单群组中删除。

**额外步骤: 撤销**

Semaphore 也支持撤销，你可以使用 group.remove(identityCommitment)链下函数和智能合约的 removeMember 链上函数来移除成员。
一旦成员被移除，需要一定时间成员才会真正从白名单中移除。在官方 semaphore 合约中，过期时间为 1 小时，但在我们更新过的智能合约中，过期时间仅为 1 分钟。

要尝试这些功能，你可以使用 semaphore 样板代码[此处](https://github.com/semaphore-protocol/boilerplate) 。

如有任何问题，请随时留下评论。



感谢你阅读到这里。如果你喜欢这篇文章，请别忘了点赞。




---

