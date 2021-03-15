> * 原文：https://medium.com/pinata/how-to-create-nfts-like-nba-top-shot-with-flow-and-ipfs-701296944bf  [作者](https://polluterofminds.medium.com/?source=post_page-----701296944bf--------------------------------)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
>

# NFT教程 - 用Flow和IPFS创建NFT

> Flow 创建 NFT 教程 -   第一部分

非同质化代币(NFT)市场[正在进入狂热](https://www.cnbc.com/2021/02/25/nfts-why-digital-art-and-sports-collectibles-are-suddenly-so-popular.html)，回顾NFT早期的发展历程，回忆[CryptoKitties](https://www.cryptokitties.co/)所暴露出挑战是很有意思的。 CryptoKitties由[Dapper Labs](https://www.dapperlabs.com/)的团队打造，是让以太坊第一次出现“大规模”使用的案例。

从那之后，NFT就开始成长之路，[Rarible](https://rarible.com/)、[OpenSea](https://opensea.io/)、[Foundation](https://foundation.app/)、[Sorare](https://sorare.com/)等平台纷纷涌现。 这些平台每月都有数百万元的流量。 尽管磕磕碰碰，但大部分依旧在以太坊区块链上发生着。 但Dapper Labs的团队在经历了CryptoKitties之后，[着手建立一个新的通用的，很适合NFT使用场景区块链](https://medium.com/dapperlabs/introducing-flow-a-new-blockchain-from-the-creators-of-cryptokitties-d291282732f5)。 他们这样做的目标是想解决在以太坊上看到的许多NFT的问题，同时为该领域的开发者和收藏者提供更好的体验。 他们的新区块链[Flow](https://www.onflow.org/)，已经证明了自己能够落地，并吸引一些大牌。，如 [NBA](https://www.nbatopshot.com/)、UFC、甚至Dr. Seuss都在使用Flow。

我们最近[写了使用IPFS上保存标的资产来创建NFT](https://learnblockchain.cn/article/2247)，并且讨论NFT领域的[责任问题](https://medium.com/pinata/who-is-responsible-for-nft-data-99fb4e8147e4)，以及IPFS如何提供帮助。 现在，这篇文章谈谈如何在Flow上创建IPFS支持的NFT。 Flow区块链早期的主要应用之一是[NBA巅峰对决 （NBA Top Shot）](https://www.nbatopshot.com/)。 我们要重新建立一个非常基本的NFT铸币过程，然后在IPFS上回溯NFT元数据和标的资产。

由于我们喜欢piñatas，所以我们的NFT将不再是NBA精彩的视频，而是一个可交易的 piñatas 视频。

本教程有 3 篇文章

1. 创建合约和铸造代币（本文是第一篇）
2. 创建一个应用程序，以查看通过该合约创建的NFT。
3. 创建一个市场，将NFT转让给他人，同时也转移在IPFS上的标的资产。



## 环境设置

我们需要安装Flow CLI。 在[Flow的文档](https://docs.onflow.org/flow-cli/install/)中有一些很好的安装说明：

**macOS**

```
brew install flow-cli
```

**Linux**

```
sh -ci “$(curl -fsSL https://storage.googleapis.com/flow-cli/install.sh)"
```

**Windows**

```
iex “& { $(irm ‘https://storage.googleapis.com/flow-cli/install.ps1') }”
```

我们将在IPFS上存储资产文件。 我们使用[Pinata](https://pinata.cloud/) 来简化操作， 可以在这里注册一个[免费账户](https://pinata.cloud/)，获取一个[API密钥](https://pinata.cloud/keys)。 在本教程的第二篇文章中会使用Pinata API，但在本篇文章中我们使用Pinata网站。

我们还需要安装NodeJS和一个文本编辑器，它可以帮助高亮显示Flow智能合约(这是用一种叫做[Cadence](https://docs.onflow.org/cadence)的语言编写)代码的语法。 Visual Studio Code 有一个[支持Cadence语法的插件](https://docs.onflow.org/vscode-extension)。

让我们为项目创建一个目录：

```
mkdir pinata-party
```

进入该目录，并初始化一个新的flow项目：

```
cd pinata-party
flow project init
```

现在，使用你最喜欢的代码编辑器中打开项目（如果你使用Visual Studio Code，可以安装下 Cadence 插件），让我们开始工作。

你会看到一个`flow.json`文件，我们很快就会用到它。 首先，创建一个名为 `cadence `的文件夹。 在该文件夹内，再添加一个名为 `contracts `的文件夹。 最后，在 `contracts `文件夹中创建一个名为 `PinataPartyContract.cdc `的文件。

说明一下，我们现在所做的一切关于Flow区块链的工作都将在模拟器上完成。 但是，将一个项目部署到测试网或主网，只需要更新`flow.json`文件中的配置这样简单。 我们现在就把这个文件设置成模拟器环境，然后就可以开始写我们的合约了。

更新`flow.json`中的合约对象，代码如下：

```
"contracts": {
     "PinataPartyContract": "./cadence/contracts/PinataPartyContract.cdc"
}
```

然后，更新该文件中的 `deployments `对象，代码如下：

```
"deployments": {
     "emulator": {
          "emulator-account": ["PinataPartyContract"]
     }
}
```

这是在告诉Flow CLI使用模拟器来部署我们的合约，它也在引用（在模拟器上）我们即将写的合约 ...



# 合约

Flow 有一个关于创建NFT合约的出色教程。他是一个很好的参考，但是[正如Flow自己指出的](https://github.com/onflow/flow-nft/issues/9)，他们还没有解决NFT元数据的问题。 他们希望在链上存储元数据。 这是个好主意，他们一定会想出一个合理的办法来。 然而，我们现在想要铸造一些带有元数据的代币，并且我们想要关联上对应的媒体文件（标的）。 元数据只是其中一个组成部分。 我们还需要指出代币最终代表的媒体文件。

如果你熟悉以太坊区块链上的NFT，你可能会知道，许多代币的标的资产都存储在传统的云服务器上，这样做是可以的，但又弊端。 我们曾写过关于[IPFS](https://learnblockchain.cn/tags/IPFS)内容可寻址，以及[在传统云平台上存储区块链数据的弊端](https://medium.com/pinata/off-chain-data-63bca5a9c266)，归结起来主要有两点：

- 资产应可核查
- 应该很容易转移维护责任

[IPFS](https://ipfs.io/)解决了这两点。 而Pinata则以一种简单的方式将该内容长期保存在IPFS上。 这正是我们的NFT 关联的资料所需要的？ 我们要确保能够证明拥有NFT的所有权，并确保我们能控制对标的资产（IPFS）--媒体文件或其他内容，确保不是复制品。

考虑到这一点，让我们写一份合约，它可以铸造NFT，将元数据关联到NFT，并确保元数据指向存储在IPFS上的标的资产。

打开`PinataPartyContract.cdc`，编写一下代码：

```
pub contract PinataPartyContract {
  pub resource NFT {
    pub let id: UInt64
    init(initID: UInt64) {
      self.id = initID
    }
  }
}
```



第一步是定义合约，后面会添加更多的内容，但我们首先定义`PinataPartyContract`，并在其中创建一个`resource`。 资源是存储在用户账户中并通过访问控制措施进行访问。 在这里，`NFT `资源最终用来代表NFT所拥有的东西。 NFT必须是唯一的， `id`属性允许我们标识代币。

接下来，我们需要创建一个资源接口，我们将用它来定义哪些能力可以提供给其他人（即不是合约所有者）。



```
pub resource interface NFTReceiver {
  pub fun deposit(token: @NFT, metadata: {String : String})
  pub fun getIDs(): [UInt64]
  pub fun idExists(id: UInt64): Bool
  pub fun getMetadata(id: UInt64) : {String : String}
}
```



把这个代码放在NFT resource 代码的下面。 这个`NFTReceiver`资源接口用来定义对资源有访问权的人，就可以调用以下方法:

- `deposit`
- `getIDs`
- `idExists`
- `getMetadata`

接下来，我们需要定义代币收藏品（ Colletion ）接口。 把它看成是存放用户所有NFT的钱包。

```
pub resource Collection: NFTReceiver {
    pub var ownedNFT: @{UInt64: NFT}
    pub var metadataObjs: {UInt64: { String : String }}

    init () {
        self.ownedNFT <- {}
        self.metadataObjs = {}
    }

    pub fun withdraw(withdrawID: UInt64): @NFT {
        let token <- self.ownedNFT.remove(key: withdrawID)!

        return <-token
    }

    pub fun deposit(token: @NFT, metadata: {String : String}) {
        self.ownedNFT[token.id] <-! token
    }

    pub fun idExists(id: UInt64): Bool {
        return self.ownedNFT[id] != nil
    }

    pub fun getIDs(): [UInt64] {
        return self.ownedNFT.keys
    }

    pub fun updateMetadata(id: UInt64, metadata: {String: String}) {
        self.metadataObjs[id] = metadata
    }

    pub fun getMetadata(id: UInt64): {String : String} {
        return self.metadataObjs[id]!
    }

    destroy() {
        destroy self.ownedNFT
    }
}
```



这个资源里有很多东西，说明一下。 首先，有一个变量叫`ownedNFT`。 这个是很直接的，它可以跟踪用户在这个合约中所有拥有的NFT。

接下来，有一个变量叫`metadataObjs`。 这个有点特殊，因为我们扩展了Flow NFT合约功能，为每个NFT存储元数据的映射。 这个变量将代币id映射到其相关的元数据上，这意味着我们需要在设置代币id之前，将其设置为元数据。

然后我们初始化变量。 定义在Flow中的资源中的变量必需初始化。

最后，我们拥有了NFT Collection 资源的所有可用函数。 需要注意的是，并不是所有这些函数大家都可以调用。 你还记得在前面，`NFTReceiver`资源接口中定义了任何人都可以访问的函数。

我尤其想指出 `deposit `函数。 正如我们扩展了默认的Flow NFT合约以包含 `metadataObjs `映射一样，我们正在扩展默认的 `deposit `函数，以接受额外的 `metadata `参数。 为什么要在这里做这个？ 因为需要确保只有token的minter可以将该元数据添加到token中。 为了保持这种私密性，将元数据的初始添加限制在铸币执行中。

合约代码就快完成了。 因此，在 `Collection `资源的下面，添加以下内容：

```
pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
}

pub resource NFTMinter {
    pub var idCount: UInt64

    init() {
        self.idCount = 1
    }

    pub fun mintNFT(): @NFT {
        var newNFT <- create NFT(initID: self.idCount)

        self.idCount = self.idCount + 1 as UInt64

        return <-newNFT
    }
}
```



首先，我们有一个函数，在调用时创建一个空的NFT Collection。 这就是第一次与合约进行交互的用户如何创建一个存储位置，该位置映射到定义好的 `Collection `资源。

之后，我们再创建一个资源（resource）。 它很重要的，因为没有它，我们就无法铸造代币。 `NFTMinter`资源包括一个`idCount`，它是递增的，以确保我们的NFT不会有重复的id。 它还有一个功能，用来创造 NFT。

在`NFTMinter`资源的下方，添加主合约初始化函数；

```
init() {
      self.account.save(<-self.createEmptyCollection(), to: /storage/NFTCollection)
      self.account.link<&{NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)
      self.account.save(<-create NFTMinter(), to: /storage/NFTMinter)
}
```



这个初始化函数只有在合约部署时才会被调用。 它有三个作用。

1. 为收藏品（Collection）的部署者创建一个空的收藏品，这样合约的所有者就可以从该合约中铸造和拥有NFT。
2. `Collection`资源发布在一个公共位置，并引用在一开始创建的`NFTReceiver`接口。 通过这个方式告诉合约，在`NFTReceiver`上定义的函数可以被任何人调用。
3. `NFTMinter`资源被保存在账户存储中，供合约的创建者使用。 这意味着只有合约的创造者才能铸造代币。

合约全部代码[可在这里找到](https://gist.github.com/polluterofminds/17e961796b795a4c001c2e644bda6a41)。



现在合约已经准备好了，让我们来部署它，对吗？ 我们也许应该在[Flow Playground](https://play.onflow.org/)上测试一下。 到那里，点击左侧侧栏的第一个账号。 将示例合约中的所有代码替换为我们的合约代码，然后点击部署。 如果一切顺利，你应该在屏幕底部的日志窗口中看到这样的日志。

```
16:48:55 Deployment Deployed Contract To: 0x01
```

现在我们已经准备好将合约部署到本地运行的模拟器上。 在命令行中，运行：

```
flow project start-emulator
```

现在，如果模拟器的运行正确和`flow.json`文件的正确配置，我们可以部署合约。 只需运行这个命令：

```
flow project deploy
```

如果一切顺利，你应该看到这样的输出：

```
Deploying 1 contracts for accounts: emulator-accountPinataPartyContract -> 0xf8d6e0586b0a20c7
```

现在已经在Flow模拟器上上线了一个合约，但我们想铸造一个NFT代币。 

## 铸造NFT

在教程的第二篇文章中，我们将通过一个应用程序和用户界面使铸币过程更加友好。 为了看到所铸造的内容，并展示元数据如何在Flow上与NFT一起工作，我们将使用Cadence脚本和命令行。

在 `pinata-party `项目的根目录下创建一个新的目录，我们把它叫做 `transactions`。 创建好文件夹，在里面创建一个名为`MintPinataParty.cdc` 的新文件。

为了编写出交易，先需要提供给NFT的元数据一个引用文件。 为此，我们将通过Pinata上传一个文件到IPFS。这个教程中，我将上传一个孩子在生日派对上砸pinata的视频。 你可以上传任何你想要的视频文件。 你真的可以上传任何你喜欢的资产文件，并将其与你的NFT关联起来，在本教程系列的第二篇文章将期待视频内容。 一旦你准备好你的视频文件，[在这里上传](https://pinata.cloud/)。

当你上传文件后，你会得到一个IPFS哈希（通常被称为内容标识符或CID）。 复制这个哈希值，因为我们将在铸币过程中使用它。

现在，在你的`MintPinataParty.cdc`文件中，添加以下内容：

```
import PinataPartyContract from 0xf8d6e0586b0a20c7

transaction {
  let receiverRef: &{PinataPartyContract.NFTReceiver}
  let minterRef: &PinataPartyContract.NFTMinter

  prepare(acct: AuthAccount) {
      self.receiverRef = acct.getCapability<&{PinataPartyContract.NFTReceiver}>(/public/NFTReceiver)
          .borrow()
          ?? panic("Could not borrow receiver reference")        
      
      self.minterRef = acct.borrow<&PinataPartyContract.NFTMinter>(from: /storage/NFTMinter)
          ?? panic("could not borrow minter reference")
  }

  execute {
      let metadata : {String : String} = {
          "name": "The Big Swing",
          "swing_velocity": "29", 
          "swing_angle": "45", 
          "rating": "5",
          "uri": "ipfs://QmRZdc3mAMXpv6Akz9Ekp1y4vDSjazTx2dCQRkxVy1yUj6"
      }
      let newNFT <- self.minterRef.mintNFT()
  
      self.receiverRef.deposit(token: <-newNFT, metadata: metadata)

      log("NFT Minted and deposited to Account 2's Collection")
  }
}
```




这是一个非常简单的交易代码，这在很大程度上要归功于Flow 所做的工作，但让我们来看看它。 首先，你会注意到顶部的导入语句。 如果你还记得，在部署合约时，我们收到了一个账户地址。 它就是这里引用的内容。 因此，将`0xf8d6e0586b0a20c7`替换为你部署的账户地址。

接下来我们对交易进行定义。 在我们的交易中，我们首先要做的是定义两个参考变量，`receiverRef`和`minterRef`。 在这种情况下，我们既是NFT的接收者，又是NFT的挖掘者。 这两个变量是引用我们在合约中创建的资源。 如果执行交易的人对资源没有访问权，交易将失败。

接下来，我们有一个`prepare`函数。 该函数获取试图执行交易的人的账户信息并进行一些验证。 它会尝试 `借用`两个资源 `NFTMinter `和 `NFTReceiver `上的可用能力。 如果执行交易的人没有访问这些资源的权限，验证无法通过，这就是交易会失败的原因。

最后是`execute`函数。 这个函数是为我们的NFT建立元数据，铸造NFT，然后在将NFT存入账户之前关联元数据。 如果你注意到，我创建了一个元数据变量。 在这个变量中，添加了一些关于 token的信息。 由于我们的代币代表的是一个事件，即一个piñata 在派对上被打碎，并且因为我们试图复制你在NBA Top Shot中看到的大部分内容，所以我在元数据中定义了一些统计数据。 孩子挥棒打piñata的速度，挥棒的角度和等级。 我只是觉得这些统计数字有意思。 你可以用类似的方式为你的代币定义任何有意义的信息。

你会注意到，我还在元数据中定义了一个`uri`属性。 这将指向IPFS哈希，它承载着我们与NFT相关的标的资产文件。 在这种情况下，它是piñata被击中的真实视频。 你可以用你之前上传文件后收到的哈希值来替换。

我们用`ipfs://`作为哈希的前缀，有几个原因。 这是IPFS上文件的标识符，可以使用IPFS的桌面客户端和浏览器扩展。 也可以直接粘贴到Brave浏览器中（Brave 浏览器[现在提供了对IPFS内容的原生支持](https://learnblockchain.cn/article/2040)）。

调用 `mintNFT `函数来创建代币。 然后调用`deposit`函数将其存入我们的账户。 这也是我们传递元数据的地方。 如果你还记得，我们在 `deposit`函数中定义了一个关联变量，将元数据添加到关联的token id中。

最后，我们只需要日志记录代币已被铸造和存入账户的信息。



现在我们差不多可以执行代码发送交易铸造NFT了。 但首先，我们需要准备好我们的账户。 在项目根目录下的命令行中，创建一个新的签名私钥。

运行以下命令。

```
flow keys generate
```

这将返回你一个公钥和一个私钥， **请始终保护好你的私钥**。

我们将需要私钥来签署交易，所以我们可以把它粘贴到`flow.json`文件中。 我们还需要指定签名算法。 下面是`flow.json`文件中的`accounts` 的内容：

```
"accounts": {
  "emulator-account": {
     "address": "YOUR ACCOUNT ADDRESS",
     "privateKey": "YOUR PRIVATE KEY",
     "chain": "flow-emulator",
     "sigAlgorithm": "ECDSA_P256",
     "hashAlgorithm": "SHA3_256"
  }
},
```

如果你打算在github或任何远程git仓库上存储这个项目的任何内容，请确保你不包含私钥。 你可能想`.gitignore`你的整个`flow.json`。 尽管我们只是使用本地模拟器，但保护你的密钥是个好做法。

现在可以发送交易，简单的运行这个命令：

```
flow transactions send --code ./transactions/MintPinataParty.cdc --signer emulator-account
```

在`flow.json`中引用编写的交易代码文件和签名账户。 如果一切顺利，你应该看到这样的输出：

```
Getting information for account with address 0xf8d6e0586b0a20c7 ...

Submitting transaction with ID 4a79102747a450f65b6aab06a77161af196c3f7151b2400b3b3d09ade3b69823 ...

Successfully submitted transaction with ID 4a79102747a450f65b6aab06a77161af196c3f7151b2400b3b3d09ade3b69823
```



最后，验证token是否在我们的账户中，并获取元数据。 做到这一点，我们要写一个非常简单的脚本，并从命令行调用它。

在项目根目录，创建一个名为 `scripts `的新文件夹。 在里面，创建一个名为`CheckTokenMetadata.cdc`的文件。 在该文件中，添加以下内容：



```
import PinataPartyContract from 0xf8d6e0586b0a20c7

pub fun main() : {String : String} {
    let nftOwner = getAccount(0xf8d6e0586b0a20c7)
    // log("NFT Owner")    
    let capability = nftOwner.getCapability<&{PinataPartyContract.NFTReceiver}>(/public/NFTReceiver)

    let receiverRef = capability.borrow()
        ?? panic("Could not borrow the receiver reference")

    return receiverRef.getMetadata(id: 1)
}
```




这个脚本可以被认为是类似于以太坊智能合约上调用只读方法。 它们是免费的，只返回合约中的数据。

在脚本中，导入部署的合约地址。 然后定义一个 `main `函数（这是脚本运行所需的函数名）。 在这个函数里面，我们定义了三个变量：

- nftOwner：拥有NFT的账户。 由于使用部署了合约的账户中铸造了NFT，所以在我们的例子中，这两个地址是一样的。 这一点不一定，要看你将来的合约设计。
- capability： 需要从部署的合约中 `借用 `的能力（或功能）。 请记住，这些能力是受访问控制的，所以如果一个能力对试图借用它的地址不可用，脚本就会失败。 我们正在从`NFTReceiver`资源中借用能力。
- receiverRef：这个变量只是简单地记录我们的能力。

现在，我们可以调用（可用的）函数。 在这种情况下，我们要确保相关地址确实已经收到了我们铸造的NFT，然后我们要查看与代币相关的元数据。

让我们运行的脚本，看看得到了什么。 在命令行中运行以下内容：

```
flow scripts execute ./scripts/CheckTokenMetadata.cdc
```

你应该会看到元数据输出的类似这样的输出。

```
{"name": "The Big Swing", "swing_velocity": "29", "swing_angle": "45", "rating": "5", "uri": "ipfs://QmRZdc3mAMXpv6Akz9Ekp1y4vDSjazTx2dCQRkxVy1yUj6"}
```

恭喜你！ 你成功创建了一个Flow智能合约，铸造了一个代币，并将元数据关联到该代币，并将该代币的底层数字资产存储在IPFS上。 作为教程的第一部分，还算不错。

接下来，我们有一个关于构建前端React应用的教程，通过获取元数据和解析元数据，让你显示你的NFT。



------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。