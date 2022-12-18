原文链接：https://moralis.io/how-to-create-a-solana-token-in-5-steps/

![22_02_How_to_Create_a_Solana_Token_in_5_Steps_V24.jpg](https://img.learnblockchain.cn/attachments/2022/05/Vlg0yiwb62836262b9def.jpg)

# 如何通过 5 个步骤创建 Solana 代币

在本文中，我们将通过五个步骤指导你如何创建 Solana 代币。除了更深入地研究该过程，我们还将发现更多关于 Solana 区块链和 SPL 代币的信息。现在，如果你想直接跳到创建代币的文档，请查看以下链接:

**完整文档 –** [**https://github.com/YosephKS/solana-spl-tutorial**](https://github.com/YosephKS/solana-spl-tutorial)

如果你是[Moralis](https://moralis.io/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)的老读者，你可能偶然发现了有关[如何创建以太坊代币](https://moralis.io/how-to-create-ethereum-tokens-in-4-steps/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)或[如何创建Polygon代币](https://moralis.io/how-to-create-a-polygon-token/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)的文章。但是，在本文中，我们将把注意力转移到其他地方，并仔细研究最令人兴奋的区块链之一：Solana。Solana 在 2021 年迅速增长，并正在成为以太坊和其他[EVM](https://moralis.io/evm-explained-what-is-ethereum-virtual-machine/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)兼容链的最大竞争对手之一。该平台专注于速度和可扩展性，解决了其竞争对手的一些重大问题。因此，我们将在本文中深入研究SPL代币以及如何使用Moralis操作系统创建Solana代币的过程。 

Moralis 为所有用户提供了无限可扩展的后端基础设施以及广泛的工具箱。例如，在这些工具中，你可以找到[Moralis Speedy Nodes](https://moralis.io/speedy-nodes/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、[NFT API](https://moralis.io/ultimate-nft-api-exploring-moralis-nft-api/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、[Web3UI 工具包](https://moralis.io/web3ui-kit-the-ultimate-web3-user-interface-kit/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、[Price API](https://moralis.io/introducing-the-moralis-price-api/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)等等。在市场上，这些功能以及后端基础架构提供了最佳的开发人员体验。这使你可以显着缩短所有未来区块链项目的开发时间，并使[Web3 开发](https://moralis.io/how-to-build-decentralized-apps-dapps-quickly-and-easily/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)更易于访问。 

因此，如果你希望[成为一名区块链开发人员](https://moralis.io/how-to-become-a-blockchain-developer/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)，那么最快、最容易获得的途径就是加入 Moralis。注册该平台是免费的，你可以立即创建你的第一个区块链项目！ 

### Solana 是什么?

Solana 是一个去中心化的区块链，在 2021 年实现了巨大的增长，并正在成为[以太坊](https://moralis.io/full-guide-what-is-ethereum/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)网络最突出的竞争对手之一。因此，许多开发人员想要学习如何创建 Solana 代币也就不足为奇了。此外，Solana 与以太坊一样，兼容智能合约。这意味着可以在 Solana 网络上构建[dApp](https://moralis.io/decentralized-applications-explained-what-are-dapps/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、代币和其他 Web3 项目。 

![](https://img.learnblockchain.cn/attachments/2022/05/P927JXZp62835f4417152.png)

然而，以太坊和 Solana 生态系统之间的一个重要区别是术语可能不同。例如，“[智能合约](https://moralis.io/smart-contracts-explained-what-are-smart-contracts/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)”在 Solana 生态系统中被称为“程序”。因此，如果你更熟悉 Ethereum 和 [Solidity](https://moralis.io/solidity-explained-what-is-solidity/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)编程，本指南中的术语可能会有点令人困惑。但不要担心，我们会尽量让它简单明了。

开发以太坊区块链的一个主要缺点是网络拥挤。 随着越来越多的人采用区块链和加密技术，网络无法处理越来越多的交易。 这抬高了gas价格，使得在以太坊网络上进行交易在经济上不可行。

为此，Solana 着手创建强调交易速度和降低成本的区块链。事实上，该链每秒处理近 3,000 笔交易，每笔交易的平均成本为 0.00025 美元。因此，Solana 设法解决了以太坊区块链的一些缺点，使其成为一个激烈的竞争对手。那么，Solana 是如何实现这种吞吐量的呢？ 

### Solana 的共识机制——历史证明（PoH）

区块链行业通常有两种主要的共识机制，工作量证明（PoW）和权益证明（PoS）。以太坊和比特币目前使用 PoW。这允许网络中的节点就信息状态达成一致，并防止经济攻击和其他问题，例如双花问题。这样可以确保网络安全；但是，它使共识相对较慢。另一方面，Solana 结合了 PoS 和历史证明 (PoH)。 

![](https://img.learnblockchain.cn/attachments/2022/05/c0mAqmwi62835f8656c9a.png)

在其他区块链上，通常需要链上的验证器彼此通信以形成区块。然而，PoH可以在某种程度上绕过这一点，因为共识机制创建了一个历史记录，证明某个事件在特定时刻发生过。因此，可以更容易地形成区块，从而实现更高的可扩展性。

最后，一条额外的重要信息是要注意，你不使用 Solidity 在 Solana 区块链上构建程序（智能合约），而是使用另一种称为 Rust 的区块链编程语言。因此，如果你希望为 Solana 生态系统开发 dApp，那么精通 Rust 将大有裨益。

###  SPL 代币是什么?

Solana 生态系统的另一个重要组成部分是其原生 SOL 代币。SOL 是在 Solana 区块链上运行的加密货币，它还充当治理代币。因此，SOL 的持有者有可能对区块链的未来进行投票并帮助管理网络。如果你想加深对此类代币的了解，请查看我们的“[什么是治理代币？](https://moralis.io/what-are-governance-tokens-full-guide/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)"文章。

![img](https://img.learnblockchain.cn/attachments/2022/05/jfXTv1Kc628360052c78a.png)

此外，SOL 是一种所谓的 SPL 代币，在本节中，我们将探讨什么是 SPL 代币。SPL 代币对于 Solana 就像[ERC-20](https://moralis.io/erc20-exploring-the-erc-20-token-standard/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、[ERC-721](https://moralis.io/erc721-contract-exploring-erc721-smart-contracts/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)和[ERC-1155](https://moralis.io/erc1155-exploring-the-erc-1155-token-standard/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)代币对于以太坊网络一样。因此，SPL 可以被视为 Solana 区块链的代币标准。 

但是，如果你熟悉以太坊的代币标准，那么你就会知道 ERC-20 标准规范了同质化代币、ERC-721 NFT 和 ERC-1155 半同质化代币。 在 Solana 生态系统中，只有一个程序定义了同质化代币和 NFT 的通用实现。 因此，基本上有一个代币标准来规范这两种代币类型。

这使得 Solana 代币的开发变得非常简单，这就是为什么我们在接下来的部分中将探索如何创建同质化和非同质化的 Solana SPL 代币。

## 如何通过 5 个步骤创建 Solana 代币

通过更好地了解 Solana 区块链和什么是 SPL 代币，我们可以继续本文的中心部分：如何创建 Solana 代币。创建同质化或非同质化的 SPL 代币非常容易。现在，为了使这个过程更容易理解，我们将把这个过程分解为以下五个步骤： 

1. 安装 Solana 和 SPL CLI（命令行界面）。
2. 创建钱包并获取测试网 SOL。
3. 制作同质化的代币。
4. 创建 NFT。
5. 将代币添加到你的 Phantom 钱包。

这些步骤很容易执行；但是，如果你更喜欢观看整个过程的视频教程，那么一定要查看来自[Moralis YouTube](https://www.youtube.com/channel/UCgWS9Q3P5AxCWyQLT2kQhBw)频道的下列视频：

https://www.youtube.com/embed/IsTFNOedPkk?feature=oembed

因此，事不宜迟，让我们开始仔细看看如何下载创建代币所需的Solana和SPL CLI !

### 第 1 步：如何创建 Solana 代币——安装 Solana 和 SPL CLI

在本教程的第一步中，我们将安装 Solana CLI。这样做很简单；但是，命令有所不同，你可能还需要添加一些环境变量，具体取决于你使用的操作系统。尽管如此，以下是安装 Solana CLI 的命令： 

**MacOS & Linux:**

```
sh -c "$(curl -sSfL https://release.solana.com/v1.9.5/install)"
```

**Windows:**

```
curl https://release.solana.com/v1.9.5/solana-install-init-x86_64-pc-windows-msvc.exe --output C:\solana-install-tmp\solana-install-init.exe --create-dirs

C:\solana-install-tmp\solana-install-init.exe v1.9.5
```

有了 Solana CLI，这个初始步骤的下一部分是安装 SPL CLI。要安装 CLI，你可以使用以下输入： 

```
cargo install spl-token-cli
```

正如你从上面的命令中看到的，我们正在使用你可能不熟悉的“cargo”。这本质上是 Rust 版本的“npm”或“yarn”，要使用它，你可能需要安装一些 Rust 工具。

然而，在安装了SPL CLI之后，我们可以继续进行到流程的第二步，在那里我们将生成一个钱包并获得一些测试网SOL。

### 第 2 步：如何创建 Solana 代币——创建钱包并获取测试网 SOL

创建 Solana 代币的第二步涉及生成“文件系统钱包”并获取一些测试网 SOL。我们需要它来支付网络上的交易费用。因此，让我们从创建钱包开始，这是通过以下命令完成的： 

```
solana-keygen new --no-outfile
```

现在你有了钱包，你可以通过检查钱包的 SOL 余额来确保一切正常： 

```
solana balance
```

最初，当你刚刚创建钱包时，余额应为零。但是，我们即将改变这一点，因为我们将获得一些测试网 SOL。但是，在获得 SOL 之前，我们还需要确保我们在测试网集群上： 

```
solana config get
```

输入此命令将提供以下输出：

![img](https://img.learnblockchain.cn/attachments/2022/05/EYuLVkgD6283612dcdfbd.png)

如你所见，我们现在在测试网上。现在，如果你不在正确的集群或网络上，那么你需要配置这个。我们可以简单地使用以下输入进入正确的网络：

```
solana config set --url https://api.devnet.solana.com
```

如果你使用 EVM，这本质上等同于切换链。然后，你可以使用与之前相同的命令来检查你是否在正确的集群上，如果是，只需通过此命令获取测试网 SOL：

```
solana airdrop 1
```

### 如何创建 Solana 代币——创建同质化代币

现在有了钱包和测试网 SOL，我们可以继续本教程的中心部分，我们将在其中创建 Solana 代币。由于我们同时拥有 Solana 和 SPL CLI，这个过程变得相对容易，我们可以使用一些简单的命令轻松创建同质化代币。一旦我们完成了同质化代币，将继续下面的步骤，并深入研究如何创建NFT。

因此，我们需要做的第一件事是使用以下输入创建代币本身： 

```
spl-token create-token
```

交易完成后，我们将获得以下输出： 

![img](https://img.learnblockchain.cn/attachments/2022/05/eYvf6U10628361519cd98.png)

正如你从上面的屏幕截图中看到的那样，我们收到了代币 ID 和签名。然后我们可以利用代币 ID 来检查特定代币的余额： 

```
spl-token supply <token-identifier>
```

初始供应量应该为零，因为我们没有向代币添加任何东西。但是，不用担心，我们将向你展示如何添加所需数量的供应。然而，在实际铸造供应之前，我们确实需要为该程序创建一个帐户。手动添加这个的原因是 Solana 区块链上的程序默认情况下通常没有任何存储。因此，我们需要自己添加帐户： 

```
spl-token create-account <token-identifier>
```

为我们的代币创建的帐户，我们可以通过以下命令简单地铸造指定数量的令牌： 

```
 spl-token mint <token-identifier> <token-amount>
```

这将自动将代币铸造到文件系统钱包中。然后，你可以通过使用我们之前使用的相同命令检查余额来确保一切正常。 

![img](https://img.learnblockchain.cn/attachments/2022/05/IZSNxEMD6283617ad7e46.png)

就是这样！这就是创建同质化SPL 代币的简单之处。接下来，我们将创建一个 Solana NFT！ 

### 第 4 步：如何创建 Solana 代币——创建非同质化代币 (NFT)

现在，如果不想创建 Solana NFT，则可以跳过此步骤并转到本教程的第五部分也是最后一部分。否则，请继续学习如何创建 Solana NFT。如果按照上一步进行操作，那么你已经掌握了所有基本信息，我们只需要解决一些次要细节。

因此，你需要做的第一件事是再次创建一个新代币。但是，这一次，由于这是 NFT，你需要将decimals指定为“0”。因此，创建 NFT 的命令如下所示：

```
spl-token create-token --decimals 0
```

创建 NFT 后，下一步类似于创建同质化代币，需要为该程序创建一个帐户。这是以完全相同的方式完成的： 

```
spl-token create-account <token-identifier>
```

有了这个账户，就可以继续创建代币了。然而，由于这是一个NFT，只需铸造一个代币，因为它们是完全唯一的。因此，可以输入以下内容并将令牌 ID 和帐户替换为你的值：

```
spl-token mint <token-identifier> 1 <token-account>
```

铸造代币后，最后一部分只是简单地禁用未来的铸造，因为我们只希望这些令牌中有一个存在。这可以通过以下命令完成： 

```
spl-token authorize <token-identifier> mint --disable
```

### 第 5 步：如何创建 Solana 代币——将代币添加到你的钱包 

现在，如果你决定创建一个同质化、非同质化或两者兼而有之的代币，可以继续输入以下命令来检查钱包的余额： 

```
spl-token accounts
```

这将为你提供类似于此的内容：

![img](https://img.learnblockchain.cn/attachments/2022/05/WvYfdNho628361bb425d7.png)

这是你钱包中所有代币的列表，你在本教程中创建的代币应显示在此处。但是，既然创建了代币，你还需要将它们转移到你的常规钱包中。在本教程中，我们将使用 Phantom 钱包；但是，如果你使用任何其他替代方法，则该过程不会有太大差异。

由于我们在本教程中创建了测试网代币，你需要做的第一件事就是将 Phantom 钱包的网络更改为测试网。选择合适的网络后，转移代币变得相对容易。事实上，你需要做的就是输入以下命令并更改参数以满足你的需要：

```
spl-token transfer <token-identifier> <token-amount> <wallet-address> --fund-recipient
```

如你所见，我们需要代币 ID、转账的具体金额以及钱包地址。可以通过从 Phantom 钱包界面顶部复制来获取钱包地址。输入正确的信息后，你需要做的就是运行命令，令牌应该会转移。 

![img](https://img.learnblockchain.cn/attachments/2022/05/1OcYE6WA628361f2aa8f7.png)

为确保一切正常，你可以使用“spl-token accounts”命令检查你的 Phantom 钱包或本地钱包。然而，当你检查你的 Phantom 钱包时，你会注意到这些代币没有名称、没有符号，也没有图标。要添加它，你可以访问[GitHub 页面](https://github.com/solana-labs/token-list)并提出拉取请求。从 19:40 开始观看前面提到的视频以了解更多信息。

### 如何创建 Solana 代币——总结

在本教程中，我们能够通过以下五个步骤创建 Solana 代币： 

1. 安装 Solana 和 SPL CLI（命令行界面）。
2. 创建钱包并获取测试网 SOL。
3. 制作同质化的代币。
4. 创建 NFT。
5. 将代币添加到你的 Phantom 钱包。

该指南讲解了如何轻松创建同质化代币和[NFT](https://moralis.io/non-fungible-tokens-explained-what-are-nfts/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)，使我们能够在几分钟内完成。因此，如果你按照上面列出的步骤操作，应该能够轻松创建 Solana 代币。此外，如果你通读了整篇文章，你还将对 Solana 区块链及其原生 SOL 代币有基本的了解。

如果你想了解有关代币开发和整个区块链行业的更多信息，请务必查看 [Moralis 博客](https://moralis.io/blog/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)。 你可以了解更多关于区块[链开发的最佳语言](https://moralis.io/best-languages-for-blockchain-development-full-tutorial/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、[如何创建以太坊 dApp](https://moralis.io/how-to-create-an-ethereum-dapp-instantly/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、[MetaMask](https://moralis.io/metamask-explained-what-is-metamask/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)、[元宇宙](https://moralis.io/what-is-the-metaverse-full-guide/?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)等等。

因此，如果你对区块链开发感兴趣，请务必[注册 Moralis](https://admin.moralis.io/register?utm_source=blog&utm_medium=post&utm_campaign=How%20to%20Create%20a%20Solana%20Token%20in%205%20Steps)。创建帐户是免费的，只需几秒钟！
