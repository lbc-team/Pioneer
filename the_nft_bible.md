> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 非同质化代币圣经：关于NFT你需要知道的一切

![](https://img.learnblockchain.cn/2021/05/11/16206963762608.jpg)


非同质化代币（NFTs）是通过区块链来管理其所有权的一种独特的数字资产，包含如收藏品、游戏项目、数字艺术品、活动门票、域名，甚至是实物资产的所有权记录等。



如果你已经对加密世界有一定的了解，你可能已经听说过“非同质化代币”或者“NFT”这样的词。或许你是一个怀疑论者，一个信仰者，或者你还不知道NFT具体是什么。不管怎样，这篇文章都适合你。



作为一个NFTs市场，OpenSea拥有独特的优势：自2017年底第一个NFT标准出现以来，我们见证了几乎所有上线的NFT相关的项目。事实上，我们可以跟你赌一个[Gods Unchained Card](https://opensea.io/assets/gods-unchained)，你随便问我们一个NFT项目我们都知道，并且我们很有可能还跟开发者交谈过。这个NFT生态系统是由一些不可思议的创新者组成的紧密团体：每一个人，从从爱好者到开发者到游戏者到企业家到艺术家，我们很荣幸成为其中的一部分。


这篇文章将深入讲解非同质化代币的概念：ERC721的技术解剖，NFT的历史，关于NFT的常见误解，以及NFT市场的现状。我们希望这对那些刚刚踏入这个领域的人，或者已经对NFTs有了解但想要更好的理解其内部运作的人都有意义。



## 什么是NFT？

>  不可变质的资产只是普通的东西。可变现的资产是奇货可居的。

> 非同质化资产实际只是普通资产，可替换的资产才是奇怪的。


大多数关于非同质化代币的讨论都是从引入*可替换性*的概念开始的，它被定义为“可替换或者可以被其他同类物品替代”。我们认为这使问题变得更复杂了。想要更好的理解到底是什么构成了非同质化资产，只需要想想你所拥有的大多数东西，你所坐的椅子，你的手机，你的笔记本电脑，任何你可以在eBay上出售的东西，所有这些都属于非同质化资产的范畴。

![](https://img.learnblockchain.cn/2021/05/11/16206964547162.jpg)



事实证明，可替代的资产其实是很奇怪的。我们的货币就是一个非常经典的可替换资产的例子。不管这张钞票上的序号是什么，也不管它是在你兜里还是在你的银行账户里，5美元始终是5美元，你还可以跟别人交换一张5美元（或者5个1美元），你不会有任何损失，这就是可替换的意思。



需要注意的是*可替换性是相对的*，它只在我们理解的同类物品有多个的时候适用。比如商务舱、经济舱和头等舱的机票。只有*同类别*的机票才是大致可替换的，你不会拿你的头等舱去换一张经济舱的机票。你坐的椅子也可以跟同款其他椅子大致互换，除非你对你那张“特别的”椅子产生了特殊的依恋。

有趣的是，可替换性也可以是主观的。继续回到机票的例子，一个人他很在意他的位置是靠窗还是靠过道，那么即使是两张经济舱的机票，他也不愿意交换。同样的，一枚稀有的便士对我来说可能就只值1美分，但对钱币收藏家来说却可能值很多。我们看到了，当要在区块链上表达这些资产时，这些细微的差别是非常重要的。

### 基于区块链的非同质化代币


正如在加密货币出现之前就有了数字货币（如航空里程积分、游戏币）一样，在互联网诞生之初就已经有了非同质化数字资产。像域名、赛事门票、游戏装备、Twitter或Facebook这样的社交网络账号，这些全都是非同质化数字资产，只不过它们在交易、流通和互操作等方面各不相同，而且其中还存在很多非常有价值的资产，如[Epic Games仅在2018年，他们的免费游戏《堡垒之夜》的服装销售收入就达到了24亿美元](https://www.investopedia.com/tech/how-does-fortnite-make-money/)，[门票市场预计在2025年达到680亿美元](https://www.grandviewresearch.com/press-release/global-online-event-ticketing-market)，[域名市场继续看到稳固的增长](https://www.thedomains.com/2019/10/05/the-number-of-domain-names-sold-in-2019-has-already-surpassed-2018/)。

> 我们有大量的数字资产，然而我们从未真正拥有过它们。

很明显，我们已经拥有大量数字资产，但是我们在多大程度上拥有它们呢？假如数字所有权仅仅意味着这个东西属于你而不属于别人，那么你只在一些意义上拥有它。实际上，数字所有权更像是物理意义上的所有权（你可以自由的持有或者转让它），换句话说，设想你在某种特定的环境中拥有的某种数字资产，你可以非常容易的转让它或者持有它，一般的数字资产并不具备这样的属性。试试在ebay上售卖Fortnite皮肤，你会发现将它从一个人转移到另一个人是多么困难。


这正是区块链存在的意义！区块链为数字资产提供了一个中间协调层，它可以永久记录用户对数字资产的所有权，并且用户可以在链上管理自己的资产。区块链为非同质化资产添加几个独特的属性，就改变了用户、开发者与这些资产的关系。

![](https://img.learnblockchain.cn/2021/05/11/16206964852714.jpg)


#### 标准化



传统数字资产——从赛事门票到域名都没有统一的标准，一款游戏和一个票务系统可能以完全不同的方式来处理它的收藏品。而在公链上发布NFT，开发者可以建立所有NFT通用的、可重复使用的、可继承的标准，包括如所有权、交易、简单的访问控制这样的基本要素。而那些额外的标准（如怎样表现NFT）则可以在应用层去实现。


就像用于图像文件的JPEG或PNG文件格式，用于计算机之间请求的HTTP，以及用于在网上显示内容的HTML / CSS，区块链是建立在互联网之上的一层网络，它为开发者提供了一套全新的状态集合原语。


#### 互操作性



NFT标准可以让非同质化代币在多个生态系统间轻松的转移。当开发者推出一个新的NFT项目时，这些NFT就立即可以在几十个不同的钱包中查看，可以在市场上交易，而且，最近还可以在虚拟世界中显示了。因为开放的标准为读取数据提供了一个清晰的、一致的，可靠的，有权限控制的API。


#### 可交易性



互操作性最引人注目的功能是让NFT可以在开放市场自由交易。第一次，用户可以将资产从传统环境中转移出来，并投入市场进行各种方式的交易，比如[eBay式拍卖](https://opensea.io/blog/announcements/introducing-ebay-style-auctions-for-crypto-collectibles/)、[竞价](https://opensea.io/blog/tutorials/how-to-bid-on-crypto-collectibles/)、[捆绑交易](https://opensea.io/blog/announcements/introducing-bundles/)，并且可以用任何币种交易，如[稳定币](https://opensea.io/blog/announcements/buy-and-sell-crypto-collectibles-with-dai/)和[特定应用货币](https://opensea.io/blog/announcements/buy-and-sell-crypto-collectibles-with-mana/) 。



尤其对游戏开发者来说，资产可交易表示从封闭经济过度到了一个开放的，自由的市场经济。游戏开发者不再需要事无巨细的管理游戏中的各种资产和交易，他们可以让自由市场来承担这些繁重的工作。 

#### 流动性

NFTs的即时交易性将导致更高的流动性。NFT市场可以迎合各种受众——从资深操盘手到新手玩家，将资产曝光给更广大的买家群。就像2017年的ICO热潮催生的由具有即时流动性的代币驱动的新型资产一样，NFTs扩大了这个独特的数字资产市场。


#### 不可更改性和可证明的稀缺性


智能合约允许开发者对NFTs的供应设置硬性上线，并强行限定其发行后不可修改。例如，一个开发者可以通过编程强行规定只能创建特定数量的特定稀有资产，同时保持更多普通资产无限制供应。开发者也通过在链上编码限定资产的某种特定属性保持不可变。这对艺术品来说是非常友好的，因为艺术品在很大程度上依赖于于真品的可证明的稀缺性。

#### 可编程性


当然，像传统数字资产一样，NFTs是完全可编程的。CryptoKitties（后面会讲到）直接在宠物猫咪的合约中写入了繁育机制。今天，许多NFTs都有更复杂的机制，比如锻造、制作、赎回、随机生成等等。设计空间充满了各种可能性。

## 非同质化代币标准


标准是NFTs强大的一部分原因。因为标准规范了资产的交易方式，也精确描述了与资产的基本功能交互的方式，这让开发者有了*保障*。


### ERC721


由CryptoKitties开创的[ERC721](http://erc721.org/)是第一个关于非同质化数字资产的标准。ERC721是一个可继承的Solidity智能合约标准，这意味着开发者可以很轻松的从[OpenZeppelin library](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol)导入来创建新的兼容ERC721的合约*（[这里](https://docs.opensea.io/docs)有一篇关于创建第一个ERC721合约的有用教程）*。ERC721实际上是相对简单的：每个资产都有一个唯一标识符，ERC721提供了这个标识符与地址的映射，而这个地址则代表了该资产的所有者。ERC721还提供了关于转移资产的许可，使用`transferFrom`方法。

```
interface ERC721 {
  function ownerOf(uint256 _tokenId) external view returns (address);
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
}
```


仔细想想，这两个方法确实是表示一个NFT的全部了，一个方法用来检查谁拥有什么资产，一个方法用来转移资产。ERC721还有一些对NFT市场很重要的附加功能，但它的核心就只是前面说的非常基础的两点。


### ERC1155

[ERC1155](https://blog.enjin.io/erc-1155-token-standard-ethereum/)由[Enjin](https://enjinx.io/)团队首创，它将半可替换性引入了NFT。在ERC1155里，IDs代表的不是单一资产，而是资产的类别。例如，一个ID可以代表 “swords”，而一个钱包可以拥有1000把这样的swords。在这种情况下，`balanceOf`方法将返回一个钱包所拥有的swords的数量，用户可以通过调用`transferFrom`(带“sword”ID参数)来转移任何数量的这些swords。

```
interface ERC1155 {
  function balanceOf(address _owner, uint256 _id) external view returns (address);
  function transferFrom(address _from, address _to, uint256 _id, uint256 quantity) external payable;
}
```


相比ERC721，ERC1155的优势就在效率：使用ERC721，如果用户想转让1000把swords，他们需要为1000个独一无二的代币修改智能合约的状态（通过调用`transferFrom`方法）。有了ERC1155，开发者只需要调用一次包含参数数量1000的`transferFrom`，并执行一次转账操作。当然，这种效率的提高伴随着信息的损失：我们无法再追踪单个剑的历史。


还要注意的是，ERC1155提供了ERC721功能的超集，这意味着可以使用ERC1155来构建一个ERC721资产（你只需为每个资产设置一个单独的ID，并且数量为1）。由于这些优势，我们最近见证了越来越多ERC1155标准的采用。OpenSea最近为开始使用ERC1155标准开发了一个[Github上的存储库](https://github.com/ProjectOpenSea/opensea-erc1155)。

![](https://img.learnblockchain.cn/2021/05/11/16206965226037.jpg)

对比ERC20、ERC721和ERC1155标准。ERC20将地址映射到金额，ERC721将资产的唯一ID映射到所有者，而ERC1155有一个从ID到所有者到金额的嵌套映射。


#### 可组合性


可组合性,依据[ERC-998 标准](https://github.com/ethereum/eips/issues/998)而来，提供了一个模板 —— NFTs既可以有非同质化资产，又可以有同质化资产。目前主网只有几个可组合的 NFTs，但是我们认为将来会有激动人心的机会用上它。

> ...一只加密猫可能拥有一个猫抓板和一个喂食的盘子；盘子里可能还有一定数量的可替换的 `饲料 `代币。如果我卖掉这只加密猫，我同时卖掉属于这只加密猫所有东西。


### 非以太坊标准


目前大部分NFT标准都是以太坊上的，但也有几个NFT标准出现在了其他链上。[DGoods](https://dgoods.org/)，由[Mythical Games](https://mythical.games/)团队推出，专注于从EOS开始提供一个功能丰富的跨链标准。Cosmos项目也在[开发一个NFT模块](https://github.com/cosmos/cosmos-sdk/issues/4046)，以作为[Cosmos SDK](https://github.com/cosmos/cosmos-sdk)的一部分加以利用。


## NFT元数据

如前所述，`ownerOf`方法提供了一种查询NFT所有者的方法。例如，通过查询[CryptoKitties智能合约](https://etherscan.io/address/0x06012c8cf97bead5deae237070f9587f8e7a266d#readContract)上的`ownerOf(1500718)`，我们可以看到在撰写本文时，CryptoKitty #1500718的所有者是一个地址为0x6452...的账户，这可以通过访问他们在[OpenSea](https://opensea.io/assets/0x06012c8cf97bead5deae237070f9587f8e7a266d/1500718)或[CryptoKitties.co](https://www.cryptokitties.co/kitty/1500718)的CryptoKitty得到验证。

![](https://img.learnblockchain.cn/2021/05/11/16206965317946.jpg)


但是OpenSea和CryptoKitties是如何弄清CryptoKitty #1500718的样子的呢？还有它的名字和独特属性又是什么？

这就是*元数据*的作用。元数据为特定的代币ID提供描述性信息。对CryptoKittty来说，元数据是猫的名字、猫的照片、描述和任何额外的特征（在CryptoKitties里叫“基因组”）。对赛事门票来说，元数据可能包括比赛的日期和门票的类型，此外可能还有名称和描述。上面说的猫的元数据可能看起来像这样:

```
{
  "name": "Duke Khanplum",
  "image": "https://storage.googleapis.com/ck-kitty-image/0x06012c8cf97bead5deae237070f9587f8e7a266d/1500718.png",
  "description": "Heya. My name is Duke Khanplum, but I've always believed I'm King Henry VIII reincarnated."
}
```

问题是如何以及在哪里存储这些数据，才能让相关的NFT应用程序访问到。


### 链上与链下

开发者首先要决定是在链上还是链下存储元数据。也就是说，你是直接把元数据放在智能合约中，还是把它单独托管？


#### 链上元数据


链上元数据的好处是：1）它与代币共存，不受任何应用程序的生命周期影响；2)它可以根据链上逻辑随时更改。第一点是非常重要的，如果资产的长期价值远远超过其初始创造时的价值，比如， 期望一件数字艺术品永远有价值，不管创造这个艺术品的原始网站是否还存在。所以，重要的是，它的元数据与代币同时存在。


此外，链上逻辑可能需要*与元数据交互*。比如CryptoKitties，“繁殖代数”影响着猫咪的繁殖速度，而所有的繁殖都是在链上进行的（繁殖代数高的猫繁殖得更慢）。所以智能合约的逻辑需要可以从内部状态读取元数据。


#### 链下元数据


尽管有这些好处，但由于目前以太坊区块链的存储限制，大多数项目都将元数据存储在链下。ERC721标准包括一个名为 `tokenURI `的方法，开发人员可以通过它告诉应用程序在哪里可以找到需要的元数据。

```
function tokenURI(uint256 _tokenId) public view returns (string)
```

`tokenURI`方法会返回一个公共URL，通过这个URL可以得到一个Json串，像CryptoKitty中的基因组元数据的Json一样，这个元数据应该符合官方的[ERC721元数据标准](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)，这样才能被像OpenSea这样的应用程序所接收。在OpenSea，我们希望开发者可以建立能在我们的市场中显示的丰富的元数据，所以我们已经添加了[ERC721元数据标准的扩展](https://docs.opensea.io/docs/metadata-standards)，允许开发者包括诸如特征、动画和背景颜色等内容。

![](https://img.learnblockchain.cn/2021/05/11/16206965515942.jpg)


### 链下存储解决方案

如果你在链下存储元数据，你有一下两个选项：

#### 中心化服务器

存储元数据最简单的就是选择某个中心化服务器，或者像AWS这样的云存储解决方案。当然，这也有弊端：1）开发者可以随意改变元数据，2）如果项目下线，元数据可能从其原始来源中消失。为了缓解问题2），现在有几个服务（包括OpenSea）会在自己的服务器上缓存元数据，以确保即使原来的托管解决方案宕机，也能有效地提供给用户。


#### IPFS


越来越多的开发者，特别是在数字艺术领域，正在使用[InterPlanetary File System](https://ipfs.io/)（IPFS）来存储链下元数据。IPFS是一个点对点的文件存储系统，它允许内容跨计算机托管，这样文件就会在许多不同的地方被复制。这确保了：A）元数据是不可改变的，因为它是由文件的哈希值唯一寻址的；B）只要有节点愿意托管数据，数据就会长期存在。现在有像[Pinata](https://pinata.cloud/)这样的服务，通过处理部署和管理IPFS节点的基础设施，使这个过程对开发者来说更简单，而[备受期待的Filecoin网络](https://docs.filecoin.io/go-filecoin-tutorial/Storing-on-Filecoin.html#table-of-contents)将（在理论上）在IPFS之上增加一个层，以激励节点托管文件。

## NFTs的历史（2017 - 2020）。

现在我们了解了什么是NFTs以及如何构建它们，接下来我们再深入去了解它们是如何产生的。


### - 0 BC: 在CryptoKitties之前


原始的NFT是在比特币网络上出现的[colored coins](https://en.bitcoin.it/wiki/Colored_Coins)。[Rare Pepes](http://rarepepedirectory.com/)是第一批建立在比特币交易系统上的青蛙Pepe的插图。其中一些[在eBay上出售](https://www.dailydot.com/unclick/rare-pepe-frog-meme-economy/)，还有一套Rare Pepes[后来在纽约的现场拍卖中售出](https://www.vice.com/en_us/article/ev57p4/i-went-to-the-first-live-auction-for-rare-pepes-on-the-blockchain)。



以太坊上的第一个NFT是[CryptoPunks](https://www.larvalabs.com/cryptopunks)，它包含10000个不同的可收藏朋克，每个朋克都是独一无二的。CryptoPunks由[Larva Labs](https://larvalabs.com/)创建，它可以应用于交易市场，可以在像[MetaMask](https://metamask.io/)这样的钱包上使用，从而降低了人们进入NFTs的门槛。如今，由于其数量有限，以及在早期社区中强大的品牌力量，CryptoPunks可能是作为真正的数字古董最好的选择。此外，由于在以太坊网络上，CryptoPunks可以与交易市场或者钱包交互（CryptoPunks早于ERC721，在交互方面比使用ERC721的新资产还是稍差一点）

![](https://img.learnblockchain.cn/2021/05/11/16206966435644.jpg)


### 0 BC: CryptoKitties的诞生


[CryptoKitties](https://cryptokitties.co)是第一个将NFT推向主流的项目，于2017年底在ETH滑铁卢黑客马拉松上推出，它是一个原始的链上游戏，玩家通过繁殖来产生新的具有不同稀有属性的数字猫咪。“第0代”的创世猫咪以[荷兰式拍卖](https://www.investopedia.com/terms/d/dutchauction.asp)的方式出售，其他代的猫咪也可以在二级市场上出售。

虽然游戏界的一些人后来给CryptoKitties贴上了 “不是真正的游戏 ”的标签，但实际上，由于区块链的设计限制，CryptoKitties团队为在设计链上游戏机制方面做了相当多。首先，他们建立了一个链上繁殖算法，隐藏在一个不开源的智能合约中，这个算法决定了一只猫的遗传密码（也就是它的 “属性”）。CryptoKitties团队还设计了一个[复杂的激励系统](https://medium.com/cryptokitties/why-love-isnt-free-for-cryptokitties-7cc00dd2bf6d)来确保繁殖的随机性，并有先见之明地保留了某些低ID的猫咪，以便之后作为促销工具使用。最后，他们还创建了荷兰拍卖合约，后来成为NFT的主要价格发现机制之一。CryptoKitties团队的非凡远见对早期NFT的发展有巨大的推动。


我们认为CryptoKitties的传播可以归结为：

#### 投机机制


CryptoKitties的繁殖和交易机制带来了一条清晰的获利途径：买下一对猫，繁殖出更稀有的猫，再卖掉猫，重复（或者干脆买下一只稀有猫，希望有人会来买）。这促进了*繁殖者社区*（那些致力于繁殖和倒卖稀有猫咪的用户）的发展：。只要有新的玩家加入，价格就会上升。


在狂热的高峰期，CryptoKitties的成交量接近5000ETH，其中[18号创世猫的售价为253ETH](https://opensea.io/assets/0x06012c8cf97bead5deae237070f9587f8e7a266d/18)（时价11万美元）。这一价格后来被[以600ETH售出的一只叫Dragon的猫咪](https://opensea.io/assets/0x06012c8cf97bead5deae237070f9587f8e7a266d/896775)所超越，时价17万美元（2018年9月），尽管许多人猜测[Dragon的出售是非法的](https://thenextweb.com/hardfork/2018/09/05/most-expensive-cryptokitty/)。这些高价吸引了更多的用户进入淘金热。

#### 故事有毒


CryptoKitties成功的另一个因素是[故事](https://techcrunch.com/2017/12/03/people-have-spent-over-1m-buying-virtual-cats-on-the-ethereum-blockchain/)。CryptoKitties是可爱的、可分享的、有趣的，然而购买一只1000美元的数字猫的想法是荒谬的，这就成为了一个很好的新闻故事。此外，智能合约的用户玩坏了以太坊，这本身就又是一个故事。由于以太坊一次只能处理有限数量的交易(大约15个交易/秒)，网络上更高的吞吐量导致了待处理交易池的增长和交易成本上涨。日均待处理交易从1500个交易上升到11000个交易。新的潜在猫咪买家正在支付天文数字的费用，并连续数小时等待他们的交易被确认。



这些因素导致了 “CryptoKitty泡沫”：新的玩家不断涌进CryptoKitty世界，价格上涨，以及价格上涨带来的新玩家。当然，所有泡沫终将破灭。12月初，猫咪的平均价格开始下降，成交量也在下降。许多人意识到，相对于 "真正的游戏"，CryptoKitties的玩法很原始，除了投机者之外，不会有更多的参与。一旦新鲜感消失，市场就会受到影响。今天，CryptoKitties每周只有大约50个ETH的交易量。

![](https://img.learnblockchain.cn/2021/05/11/16206967223882.jpg)


### 2018:炒作，hot-potato 游戏 和 layer 2


尽管市场已不景气，但CryptoKitties 确实创造了奇迹。第一次，一个团队部署了一个基于区块链的非金融区块链应用，并进入了技术主流，尽管只是几周的时间。在CryptoKitties之后，NFT在2018年初经历了第二个小的炒作周期，因为投资者和企业家开始思考拥有数字资产的新方式。

![](https://img.learnblockchain.cn/2021/05/11/16206967950187.jpg)

#### Layer 2 的游戏和体验


在CryptoKitties之后的时期，出现了创新的[Layer 2 游戏](https://www.coindesk.com/the-emerging-trends-in-the-blockchain-gaming-world)，这些游戏是由第三方开发者在CryptoKitties之上建立的，与CryptoKitties的原始团队没有任何关系。CryptoKitties的神奇之处在于，它可以“无权限”开发：开发者可以简单地在公共的CryptoKitty智能合约之上建立自己的应用程序。从某种意义上说，CryptoKitties可以在其原始环境之外拥有自己的生命。例如，[Kitty Race](https://kittyrace.com/)可以让你与你的CryptoKitties比赛，以赢得ETH，[KittyHats](https://kittyhats.co/#/)让玩家用帽子和绘画来装饰他们的CryptoKitties。后来，[Wrapped Kitties](https://wrappedkitties.com/)将Kitties和[DeFi](https://blog.coinbase.com/a-beginners-guide-to-decentralized-finance-defi-574c68ff43c4)结合起来，让你把你的CryptoKitties变成可替换的ERC20代币，在去中心化交易所进行交易，这对CryptoKitty市场产生了各种有趣的影响。Dapper Labs（CryptoKitties之后新成立的公司）整合这些项目组建了[KittyVerse](https://www.cryptokitties.co/kittyverse)。

![](https://img.learnblockchain.cn/2021/05/11/16206968323878.jpg)


#### Hot Potatoes


这一时期还出现了“hot potato”游戏。如果你已经知道什么是“hot potato”游戏，那么你是一个真正的NFT OG。2018年1月，一款名为CryptoCelebrities的游戏推出。其机制很简单，首先，购买一个可收集的名人 NFT。很快，出现有人以更高的价格来买（或者争夺）这个名人NFT，即以前的价格的一些增量。当有人购买你的名人NFT时，你赚取你的购买价格和新的购买价格之间的差额（减去开发者的费用）。只要有人愿意购买你的名人NFT，你就会获利。然而，如果你是最后一个持有人，你就会损失。


由于这种投机机制，CryptoCelebrity 具有惊人的病毒传播能力。像[唐纳德-特朗普](https://opensea.io/assets/0xbb5ed1edeb5149af3ab43ea9c7a6963b3c1374f7/271)这样的名人NFT，能卖出天文数字的高价（123ETH，或时价137000美元）。虽然像CryptoCelebrity这样的游戏可能不利于NFT的良性发展，但我们确实看到了定价和拍卖机制在NFTs的发展中是非常令人兴奋的设计。


#### 风险资本利息


2018年初，风险投资和加密货币基金在也开始对NFT越来越感兴趣。CryptoKitties[从顶级投资者那里筹集了1200万美元](https://techcrunch.com/2018/03/20/cryptokitties-raises-12m-from-andreessen-horowitz-and-union-square-ventures/)，另一个[在11月筹集了1500万美元](https://fortune.com/2018/11/01/cryptokitties-samsung-google-venrock/)。由 Farmville 的联合创始人创办的Rare Bits在2018年初筹集了600万美元，区块链游戏工作室Lucid Sight[筹集了600万美元](https://venturebeat.com/2019/04/02/lucid-sight-raises-6-million-to-take-blockchain-games-to-traditional-platforms/)。后来，Forte筹集了一个[与Ripple合作的1亿美元区块链游戏基金](https://venturebeat.com/2019/03/12/forte-and-ripple-form-100-million-fund-for-mainstream-blockchain-games/)。Immutable（Gods Unchained背后的公司）[从Naspers Ventures和Galaxy Digital筹集了1500万美元的资金](https://www.bloomberg.com/press-releases/2019-09-23/immutable-raises-15-million-in-series-a-funding-from-naspers-ventures-and-galaxy-digital-eos-vc-fund)。Mythical Games [为EOS上的旗舰Blankos Block Party游戏筹集了由Javelin Venture Partners领导的1900万美元的资金](https://venturebeat.com/2019/11/20/mythical-games-raises-19-million-for-blockchain-based-games-with-player-owned-economies/)

OpenSea [筹集了种子轮融资](https://opensea.io/blog/announcements/opensea-raises-2-million/)和战略投资，以推进我们建立一个普遍的开放市场的愿景。衷心感谢我们所有的投资者!


### 2018 - 2019: 回归建设


在2018年初的炒作之后，NFT项目都逐渐走向稳定，回归到踏实的建设工作中。像[Axie Infinity](https://axieinfinity.com/)和[Neon District](https://www.neondistrict.io/)这样的团队，在CryptoKitties之后不久就开始了他们的工作，在他们的核心爱好者社区里加倍努力。[NonFungible.com](http://nonfungible.com/)为NFT市场建立了一个追踪平台，并将 “non-fungible ”一词巩固为描述新资产类别的主要术语。


#### 数字艺术


在这个时候，艺术界开始对NFT敏感。数字艺术被证明是自然适合于NFTs。实物艺术之所以有价值，一个核心因素是能够可靠地证明作品的所有权，并可以将其在某处展示，而这在数字世界中从未实现过。一群兴奋的数字艺术家们开始行动了。


数字艺术平台也出现了。[SuperRare](https://superrare.co/)、[Known Origin](https://knownorigin.io/)、[MakersPlace](https://makersplace.com/)和[Rare Art Labs](https://rareart.io/)都建立了专门发布和发掘数字艺术的平台。其他艺术家如[JOY](https://opensea.io/assets/joyworld-s2)和[Josie](https://opensea.io/assets/josie)部署了他们自己的智能合约，为自己在区块链网络上创造了真正的品牌。[Cent](http://cent.co)，一个拥有独特的小额支付系统的社交网络，成为人们分享和讨论加密货币艺术的一个流行社区。


![unnamed](https://img.learnblockchain.cn/2021/05/11/unnamed.gif)
Josie 的 “Tune In”，一件在OpenSea上以6ETH售出的CryptoArt作品。


#### NFT铸币平台


NFT铸币平台使任何人都能更容易地铸造NFT，无论他们是否拥有部署智能合约的开发技能。

2018年年中，[Digital Art Chain](https://digitalartchain.com/)推出，用户可以从上传的任何数字图像中铸造出NFT--这是第一个此类项目。同年，一个名为[Marble Cards](https://marble.cards/)的项目增加了一个有趣的变化，让用户可以在一个称为 “marbling” 的过程中基于任何URL创建独特的数字卡片。这将根据URL的内容自动生成一个独特的设计和图像，并在数字艺术界引起了一些对 “marbling” 加密艺术的争议。


2019年，铸币工具明显成熟，尽管在普及过程中仍面临摩擦。[Mintbase](https://mintbase.io/)和[Mintable](https://mintable.app/)建立了网站，致力于让普通人轻松创建自己的NFT。[Kred平台](https://www.coin.kred/)使有影响力的人能够轻松地创建名片、收藏品和优惠券。Kred还与CoinDesk的[Consensus conference](https://www.coindesk.com/events/consensus-2019)合作，为与会者创建了一个数字NFT “Swag Bag” 。OpenSea创建了一个[简单的店面管理器](https://opensea.io/blog/developers/how-to-create-your-own-marketplace-on-opensea-in-three-minutes-or-less/)来部署智能合约，并铸造NFT。


**更新：** 在2020年，这些平台的进化版出现了，还有[Rarible](https://rarible.com/)和[Cargo](https://app.cargo.build/)，具有更多的批量创作、可解锁内容和富媒体的功能。这使得艺术家、数字创作者，甚至是音乐家，无需对智能合约进行编程，就可以铸造NFT。到今年年底，OpenSea取消了支付与铸币有关的Gas成本，[使NFT创建免费](https://opensea.io/blog/announcements/introducing-the-collection-manager/)。


#### 传统的IP是不折不扣的。


继CryptoKitties之后，传统的IP所有者在加密货币收藏品领域进行了几次尝试。MLB与Lucid Sight合作，于2018年4月推出了[MLB Crypto](https://fortune.com/2018/08/13/mlb-crypto-baseball-blockchain/)，主要是在链上的棒球游戏。F1与Animoca Brands合作推出[F1DeltaTime](https://www.f1deltatime.com/)，[以10万美元卖出的那辆1-1-1的车](https://opensea.io/assets/0x3c62e8de798721963b439868d3ce22a5252a7e03/111)由OpenSea提供。《星际迷航》在Lucid Sight游戏中推出了一套飞船[CryptoSpaceCommanders](https://opensea.io/assets/cryptospacecommanders)，几个特许足球交易卡公司上线，包括[Stryking](https://opensea.io/assets/stryking)和[Sorare](https://opensea.io/assets/sorare)。最近，最大的实物收藏品销售商之一[Panini America](https://en.wikipedia.org/wiki/Panini_Group)已经[宣布了基于区块链的交易卡收藏品](https://sludgefeed.com/panini-america-enters-blockchain-collectibles-market/)。MotoGP也在[与Animoca合作开发一个区块链游戏](https://www.coindesk.com/animoca-to-develop-motogp-blockchain-game-with-crypto-collectibles)。


#### 日本引领潮流


日本开创了更先进的游戏方式。MyCryptoHeroes是一款以复杂的经济为特色的RPG游戏，一经推出就在DappRadar的排行榜上名列前茅。MyCryptoHeroes是第一批将链上所有权与更复杂的链下游戏相结合的游戏之一。用户可以在游戏中使用英雄，当他们想在二级市场上出售时，可以转到以太坊。

#### 虚拟世界的扩展

新生的区块链原生虚拟世界开始为土地所有权和虚拟世界的资产提供 NFT。[Decentraland](https://decentraland.org/)在ICO中为其MANA代币筹集了2500万美元，为其虚拟世界的地块启动了1000万美元的土地销售。在2018年的大部分时间里，Decentraland的LAND NFT的交易量比其他NFT都要多。 Decentraland项目现在有一个开放的测试版，有一些相当激进的早期体验，如[Battle Racers](https://battleracers.io/)，一个可在虚拟显示世界玩的赛车游戏。


[Cryptovoxels](https://www.cryptovoxels.com/)，另一个虚拟世界项目，用了比较精简的方法。在2018年年中，CryptoVoxels推出一个非常简单的由开发人员领导webVR体验。CryptoVoxels已经逐渐扩大它的宇宙，小心翼翼地避免出售超过需求的土地。今天，CryptoVoxels已经完成了超过1700个ETH的交易量，土地的平均价格稳步上升。


![](https://img.learnblockchain.cn/2021/05/11/16206975976921.jpg)
CryptoVoxels 中的数字艺术博物馆，可访问[这里](https://www.cryptovoxels.com/play?coords=NE@83E,1U,237S)。


CryptoVoxels（以及Decentraland）最令人兴奋的点是可以在整个虚拟世界范围内应用NFT。收藏爱好者们已经创建了CryptoKitty博物馆、赛博朋克艺术馆、NFT降临日历、布满顶级NFT项目的塔楼，以及可以为你的虚拟人物购买可穿戴物品的商店。CrypoVoxels在数字艺术家中发展迅速，特别是在[Cent](https://cent.co/)的用户中，这是一个专为热衷加密世界的人群设计的新的内容平台。一些艺术家甚至用[Roll](http://tryroll.com/)创造了他们自己的货币（或 “社交货币”），Roll是一个可以轻松部署ERC20代币的应用程序，并可以将他们的艺术作品用*自己的社交货币*进行交易。



其他虚拟世界项目也已经出现，包括[Somnium Space](https://somniumspace.com/)，以及[Second Life](https://secondlife.com/)的创建者的项目[High Fidelity](http://highfidelity.com/)。[The Sandbox](https://www.sandbox.game/en/)最近为其Roblox-like宇宙推出了土地销售，旨在为建设者和内容创造者们授权。 这是最令人期待的区块链游戏之一。


[Enjin](https://enjin.io/)在2017年底的ICO中筹集了75041个ETH，扩大了其“多元宇宙”平台，这是一个基于ERC1155的游戏生态系统。Enjin 的核心价值主张之一是能够轻松地将物品从一个游戏带入另一个游戏。例如，Enjin团队发布了一个 “通用”(不是针对特定游戏)的[Oindrasdain Axe](https://opensea.io/assets/0xfaafdc07907ff5120a76b34b731b278c38d6043c/36411184310952944508859562575390614563768575651911745716961922930335654352507)。[Forgotten Artifacts](https://forgottenartifacts.io/)在他们的游戏中加入了Oindrasdain Axe 作为可装备的武器，让拥有Oindrasdain Axe的玩家可以来尝试他们的游戏。

#### 可交易的卡牌游戏


感觉可交易卡牌游戏从一开始就是[自然适合NFT](https://opensea.io/blog/trading-cards/sell-hearthstone-cards/)的。像[Magic the Gathering](https://magic.wizards.com/en)这样的实体卡牌游戏，远不止是一个游戏。它是[一个完整的经济体](https://www.mtgsalvation.com/forums/magic-fundamentals/magic-general/689056-total-mtg-market-cap-secondary-market)，有几十个配套的网站和市场，用于购买、销售和易货贸易。像[炉石传说](https://playhearthstone.com/en-us/)这样的魔法卡牌游戏，可以为他们的卡牌建一个游戏内的市场，不过这样做可能有点多余，可能跟发新包的商业模式不匹配。区块链已经可以支持游戏外的即时的二级市场交易。


继500万美元的卡牌预售之后，[Immutable](https://immutable.com/)推出了[Gods Unchained](https://opensea.io/assets/gods-unchained)，可以说是目前市场上最热的区块链游戏。当《炉石传说》[禁止一名职业玩家](https://www.theverge.com/2019/10/8/20904308/hearthstone-player-blitzchung-hong-kong-protesters-ban-blizzard)对香港进行在线政治抗议时，他们就已经成了主流游戏。Gods Unchained发布了以下公告：


Gods Unchained团队在游戏推出前的很长一段时间内 “锁定 ”了卡片（ERC721核心功能的允许偏离）。在这期间，用户仍可以在第三方市场出售卡牌，但它们实际上不能被买走，因为这个时候卡牌不能被转让。11月卡牌解锁，Gods Unchained市场开放时，市场交易量超过了130万美元。


其他几个卡牌游戏也在悄悄地建立专门的追随者。地Horizon Games的[Skyweaver](https://www.skyweaver.net/)[从Initialized](https://www.businesswire.com/news/home/20190717005162/en/%C2%A0Horizon-Blockchain-Games-Reveals-3.75M-Seed-Led)获得了375万美元的种子轮融资，并发布了他们的公测版本，[Epics](https://epics.gg)成为[第一个基于区块链的可收集电竞卡牌](https://opensea.io/blog/exclusive-auctions/epics-trading-cards/)，而[CryptoSpells](https://cryptospells.jp/)--一个来自日本的卡牌游戏，已经在日本卡牌交易市场处于领先地位。


#### 去中心化的域名服务


第三大 NFT 资产类别（仅次于游戏和数字艺术）就是域名服务，类似于“.com ”这样的，不过是基于去中心化技术的。[以太坊域名服务](https://ens.domains/)，由以太坊基金会资助，于2017年5月推出，2017年-2018年间，已有价值 17万ETH 的域名被锁定（只要投标人持有域名，中的标就会被锁定在合同中）。2019年5月，团队升级了ENS智能合约，兼容ERC721，现在域名也可以在开放的NFT市场上交易。


10月，我们[跟ENS合作](https://opensea.io/blog/domains/the-ens-short-name-auction-is-starting-soon-on-opensea-3d110cd7a0ba/)，用英式拍卖对3-6个字符的域名进行拍卖。拍卖中，总共有50,355次出价，涉及7670个域名。所有中标的总价值为5,698.97 ETH。点击[这里](https://medium.com/the-ethereum-name-service/the-most-popular-eth-names-in-the-ens-short-name-auction-final-5d3466dd8837)阅读拍卖会的一些有趣的统计数据。


[Unstoppable Domains](https://unstoppabledomains.com/)，获得了[来自Draper Associates和Boost VC的400万美元A轮融资](http://www.finsmes.com/2019/05/unstoppable-domains-raises-4m-in-series-a-funding.html)。Unstoppable Domains最初建立在Zilliqa区块链上，最近发布了.crypto 域名作为ERC721资产。


[Kred团队](https://www.nft.kred/influencers/domain-token)正在研究同时兼容ENS和DNS的NFT。如果你的钱包里有[Kred Domain Token](http://www.Domains.Kred)，就可以在DNS（链接到一个网站）和ENS（链接到一个钱包或合约）上管理这个名字。


#### 其他 NFTs 项目

目前大部分NFT项目都是关于收藏品和游戏，其他的应用场景也逐渐开始出现。NFT.NYC和Token Summit都把赛事门票作为NFT出售，Coin.Kred 还发布了一个NFT大礼包。币安最近也加入了，发行了[节日收藏品](https://opensea.io/assets/binance)，微软发布了[Azure Heroes](https://www.microsoft.com/en-ie/azureheroes)为Azure生态系统的贡献者颁发徽章。

![](https://img.learnblockchain.cn/2021/05/11/16206977167672.jpg)
在北美举办的第一次大型NFT活动，NFT.NYC 2019，近500名与会者和80多名发言人在纽约市标志性的时代广场会面，讨论新兴的NFT生态系统。


[Crypto Stamp](https://opensea.io/assets/cryptostamp)--奥地利邮政服务的一个项目--为官方实物邮票的购买者提供了进入数字收藏品世界的便捷途径。每张实体邮票都有一个不透明的刮开式覆盖部分，在刮开的区域下面，购买者可以找到一个有少量ETH的私钥和一个实物邮票的对应，然后他们可以在OpenSea上出售。这个项目特别有趣，因为它将数字资产的稀缺性与有用的实物资产联系在一起，并吸引了现有的收藏家社区。


Dapper Labs，CryptoKitties的创造者，推出了一个名为[CheezeWizards](http://cheezewizards)的锦标赛式游戏。有趣的是，这个游戏有一个[硬分叉](https://www.blockchaingamer.biz/news/13113/cheeze-wizards-smart-contract-exploit-unpasteurized-hackers/)，由于合约中的一个错误，导致了 “未消毒”和 “消毒”的巫师同时存在。这是一个复杂的链上游戏，项目突出了更多标准的必要性，比如关于NFT元数据和合约升级，当资产的核心属性改变时还可以确保拍卖也能随之更新。

#### 伤亡和抢救

不是所有项目都能持续存活，这些年，2018年初的所有potato games现在几乎都死了（尽管资产仍然活在OpenSea上供人查看）。但奇妙的是，其中一些项目被社区成员救活了。[CryptoAssault](https://cryptoassault.io/)和Etheremon（现在的[Ethermon](https://ethermon.io/)）都被他们的社区恢复了。但有一个企图通过名人繁殖游戏让 CryptoCelebrities重生的尝试失败了。


## NFT 神话

到现在我们已经对NFT有了基本了解，接下来我们聊聊那些错误的理解。

### 稀缺性本身就推动了需求


在 NFT 出现的早期，人们相信用户会关心NFT的可证明的稀缺性，他们急于购买NFT，仅仅是因为它们在区块链上。相反，我们认为需求是由更传统的力量驱动的。**实用和出处**。实用性是显而易见的:我购买一张NFT门票，因为它能让我进入一个会议；如果我可以在虚拟世界中展览，我也愿意购买一件艺术品；如果能让我在游戏中获得特殊技能，我也愿意购买一件游戏装备。出处的概念概括了NFT背后的故事。 它是从哪里来的？谁曾拥有过它？随着NFT发展的趋于成熟，有意思的故事对NFT来说越来越具影响。

#### 智能合约意味着资产永远存在


还有人认为，只要部署了智能合约，这些资产就会永远存在。这忽略了一个事实，即还有其他实体（网站、移动应用程序）作为普通用户与这些应用程序交互的门户。如果这些门户网站瘫痪了，资产就会失去很多价值。当然，可能在未来，去中心化的应用程序可以以完全分布式的方式部署，但现在，我们在很大程度上生活在一个混合的世界。


#### 抽象化区块链可以解决我们所有的问题




在2018年和2019年，一些项目采取了 “抽象化区块链” 的方法，通过提供一个具有用户名-密码认证的托管钱包，向用户隐藏NFT的所有机制。这是一个有趣的方法，因为它可以让用户有与中心化应用一样体验。问题是，与NFT生态系统（虚拟世界、钱包、市场）的互操作性已经丧失。我们发现，那些插入现有的NFT生态系统的项目，也许在短期内牺牲了一些可用性，但对当前的早期社区更有吸引力。

## NFT 市场

### 目前的市场规模

![](https://img.learnblockchain.cn/2021/05/11/16206977655131.jpg)

NFT的市场仍然相当小，而且由于资产的现货价格偏低，比加密货币市场更难衡量。在本分析中，我们专注于二级交易量（即NFT的点对点销售）作为市场规模的一个指标。根据这个指标，我们估计目前的二级市场每月大约有200-300万美元的交易量。以下是在过去6个月主要项目的成交量：

### 市场增长

![](https://img.learnblockchain.cn/2021/05/11/16206977782121.jpg)

以转让、竞价、购买或出售来定义的与NFT交互的用户数量。该市场是早期的，但在稳步增长。



在2018年底的CryptoKitties泡沫之后，与NFT交互的账户数量缓慢但稳定地增长，从2018年2月的~8500个账户到2019年12月的超过20000个账户。市场似乎是由一些核心的高级用户群体在驱动。在OpenSea上，中位数卖家卖出了价值71.96美元的东西，平均每个卖家都卖出了1178美元的东西，表明有大量的实力卖家。请注意，像官方游戏账户这样的大账户确实推动了平均值的上升。在OpenSea上，平均每个买家购买了943.81美元的东西，中位数买家购买了价值42.72美元的物品。


鉴于NFT还处在很早期，衡量市场增长的最好方法可能是看一个领先指标：开发商对NFT的兴趣。在过去的一年里，随着新的开发者进入，主网ERC721合约的数量成倍增长，在2019年6月达到了1000个。

![](https://img.learnblockchain.cn/2021/05/11/16206978176200.jpg)


| 统计项目 | 价值 |
|---   |----   |
| 每周购买者的数量（估计） | 1,500人|
| 每周购买人数(估计) | 18,000人|
| 每个用户的平均购买次数 (估计) | 12 | 


### 销售机制


NFTs 目前主要在去中心化交易所以 ETH 出售。令人惊讶的是，很少有以像DAI或USDC这样的稳定币交易，这可能是由于获得稳定币的摩擦。荷兰式拍卖和固定价格销售经常用于销售低价物品，而大体量的物品经常选择英式（eBay式）拍卖的方式，如超值的Gods Unchained卡或传奇游戏装备。捆绑销售也是一种非常受欢迎的销售机制，捆绑销售的比例在今年12月稳步增长到20%。


### NFT分布

人们可能会问的一个问题是：各种NFT项目之间会不会有交互？围绕项目的社区是相对孤立的（Gods Unchained玩家只玩Gods Unchained），还是社区之间是相互渗透的 ？一个CryptoKitties的爱好者是否也可能拥有一个ENS域名或参与数字艺术生态系统？

![](https://img.learnblockchain.cn/2021/05/11/16206978289636.jpg)
基于OpenSea上约40万个地址的原始数据的NFT网络图

[Takens Theorem](https://twitter.com/takenstheorem)，一个匿名但非常友好的Twitter账户，对区块链生态系统进行了一些精彩的分析（强烈建议关注！），对各种NFT社区之间的重叠进行了分析。上面是基于OpenSea上约40万个地址的原始数据的网络图。在外圈，每个网络是由唯一拥有单一类型的NFT的地址组成的。图中的节点数量代表了实际数据中的节点数量--例如，成千上万的地址只拥有CryptoKitties。这些图中的节点是按其拥有的数量来确定大小的。


在Gods Unchained中，你可以看到许多地址拥有许卡牌。连接NFT项目的浅灰色节点代表多个项目共有。在整体图的右侧可以看到有成千上万的地址拥有两个游戏的NFT。但也有其他较小的节点--比如Cryptovoxels和Decentraland之间，以及ENS和其他许多项目之间，由不同项目之间的连接表示。

### NFT的下一步是什么？我们对2020年的预测

如果你走到了这一步，我们向你表示祝贺！我们希望你能学到很多关于NFT的有趣、古怪的知识，并将受到启发，检查一些项目，或者[发布一个你自己的NFT]((https://docs.opensea.io/))。
