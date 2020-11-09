> * 原文：https://bankless.substack.com/p/-guide-how-to-be-e-validator ，作者[Ryan Sean Adams](https://bankless.substack.com/people/221467-ryan-sean-adams)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)


# 指南：如何成为以太坊 2.0 的验证者


>学习如何在Eth2上设置验证器节点

![如何成为以太坊 2.0 的验证者](https://img.learnblockchain.cn/pics/20201106171216.png)

*最后更新时间：2020年11月4日*

## 0. 前言

[Eth2终于要起航了](https://blog.ethereum.org/2020/11/04/eth2-quick-update-no-19/)，马上就可以开始[ETH的抵押了](https://twitter.com/RyanSAdams/status/1324016362939973632?s=20)，现在[抵押合约已经部署](https://etherscan.io/address/0x00000000219ab540356cbb839cbe05303d7705fa)，Eth2将于2020年12月1日投入使用。多年来的工作，终于取得了成果。可以肯定地说我们都很兴奋。

这就是发布此ETH质押指南的原因，希望给愿意在主网上运行验证器节点的人有帮助。我们曾在8月帮助人们在Medalla测试网上进行设置，你仍然可以访问[测试网质押指南](https://bankless.substack.com/p/guide-becoming-a-validator-on-the)进行练习。

这是是真实的质押，实打实在以太坊 2.0 主网上启动验证器节点。



首先感谢[ConsenSys](https://consensys.net/) [CodeFi](https://codefi.consensys.net/)和[Bison Trails](https://bisontrails.co/)的[Collin Myers](https://twitter.com/StakeETH)和[Mara Schmiedt](https://twitter.com/MaraSchmiedt) 为本文所做的贡献，希望本文能提供你入门以太坊 2.0 宝贵的资源



我们还制作了一起特别节目介绍Eth2 质押：https://youtu.be/SkUiw1y3BHU



### 指南大纲

本涵盖以下内容：

1. 推荐硬件
2. 选择并安装客户端
3. 设置一个Eth1节点
4. 使用Eth2启动板（Launch Pad）
5. 奖励内容和资源

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_dbf46668-3377-43e5-a2a1-8f3dffdad63e_1376x820](https://img.learnblockchain.cn/pics/20201106171419.jpeg)



## 1. 硬件要求

基于Eth2的去中心化设计目标，期望验证者利用各种不同的基础架构(*内部部署，云计算等*)运行验证节点。

👉*如果你以前没有抵押过ETH，那么不妨使用Medalla 测试网参与一下，这样可以让你有足够的时间来确定哪种类型的配置可以为你带来最佳，最可靠的性能。*

*参与主网之前，请务必先进行一些测试，在Medella测试网上测试你的设置，请参考[这里](http://medalla.launchpad.ethereum.org/)*

在下面，我列出来一些硬件建议，资源链接以及一些有用的指南，以帮助你做好准备。

#### 推荐配置：

- **操作系统：**64位Linux，Mac OS X，Windows
- **处理器：**Intel Core i7-4770或AMD FX-8310(或更高)
- **内存：**8GB RAM
- **存储空间：**100GB可用空间SSD
- **网络：**宽带互联网连接(10 Mbps)
- **电源：**不间断电源(UPS)

**Digital Ocean(云提供商) 同等配置**:

- [Standard Droplet](https://www.digitalocean.com/pricing/)
 - **内存：**8GB RAM
- 存储空间：**160GB可用空间SSD**
- **正常运行时间：**99.99％
- **可用性：**8个数据中心
- 每小时成本：0.060 美元
- 每月成本：40 美元

同等配置主机配置：

- [ZOTAC ZBOX CI662纳米静音被动冷却迷你PC第十代Intel Core i7](https://www.amazon.com/ZOTAC-Passive-Cooled-Quad-core-Barebones-ZBOX-CI662NANO-U/dp/B08CVW7ZTC/ref=sr_1_14?crid=3H3C58N0E4ADZ&dchild=1&keywords=mini+pc+barebones+i7&qid=1598263033&sprefix=mini+PC+barebones+%2Caps%2C767&sr=8-14)
- [SanDisk Ultra 3D NAND 2TB内置SSD](https://www.amazon.com/SanDisk-Ultra-NAND-Internal-SDSSDH3-2T00-G25/dp/B071KGS72Q/ref=sr_1_2?crid=1KNWA41H1VO9Q&dchild=1&keywords=sandisk+ssd+plus+2tb+internal+ssd+-+sata+iii+6&qid=1598262732&sprefix=sandisk+SSD+plus+2TB%2Caps%2C790&sr=8-2)
- [Corsair Vengeance Performance SODIMM内存16GB(2x8GB)](https://www.amazon.com/Corsair-Vengeance-Performance-Unbuffered-Generation/dp/B08BLVHWXD/ref=sr_1_2?dchild=1&keywords=CORSAIR+VENGEANCE+SODIMM+16GB+(2x8GB)&qid=1598262850&sr=8-2)

### 最低硬件要求：

- **操作系统：**64位Linux，Mac OS X，Windows
- **处理器：**Intel Core i5-760或AMD FX-8110(或更高级)
- **内存：**4GB RAM
- **存储空间：**20GB可用空间SSD
- **互联网：**宽带互联网连接(10 Mbps)
- **电源：**不间断电源(UPS)

**Digital Ocean(云提供商) 同等配置**：

- [Standard Droplet](https://www.digitalocean.com/pricing/)

   - **内存：**4GB RAM

   - 存储空间：**80GB可用空间SSD**

   - **正常运行时间：**99.99％

   - **可用性：**8个数据中心

   - 每小时成本：0.030 美元

   - 每月成本：20 美元

     

**同等配置主机配置：**

- [ZOTAC ZBOX CI642纳米静音被动冷却迷你PC第十代Intel Core i5](https://www.amazon.com/ZOTAC-Passive-Cooled-Quad-core-Barebones-ZBOX-CI642NANO-U/dp/B08BBN3LS5/ref=sr_1_41?dchild=1&keywords=mini+pc+barebones+i5&qid=1598263166&sr=8-41)
- [SanDisk Ultra 3D NAND 2TB内置SSD](https://www.amazon.com/SanDisk-Ultra-NAND-Internal-SDSSDH3-2T00-G25/dp/B071KGS72Q/ref=sr_1_2?crid=1KNWA41H1VO9Q&dchild=1&keywords=sandisk+ssd+plus+2tb+internal+ssd+-+sata+iii+6&qid=1598262732&sprefix=sandisk+SSD+plus+2TB%2Caps%2C790&sr=8-2)
- [Corsair Vengeance Performance SODIMM内存8GB](https://www.amazon.com/Corsair-Vengeance-Performance-CMSX8GX4M1A2400C16-2400MHz/dp/B077SB72QN/ref=sr_1_1?dchild=1&keywords=CORSAIR+VENGEANCE+SODIMM+8GB&qid=1598263273&sr=8-1)

## 2. 选择并安装客户端

以太坊 2.0 已经实现了多个客户端，为验证者提供了不同的实现来运行其验证节点。

截至目前，你可以尝试4个团队为主网准备好的客户端：

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_b5962645-e344-4a2e-8eac-e8c643b792f5_1600x823](https://img.learnblockchain.cn/pics/20201106171517.png)

4 个主网客户端分别是：

1. **Prysmatic Labs开发的Prysm**

[Prysm](https://github.com/prysmaticlabs/prysm)是以太坊 2.0协议的Go实现，重点是可用性，安全性和可靠性。 Prysm用Go编写，在 GPL-3.0 许可下发布。 

 - 使用说明：[https://docs.prylabs.network/docs/getting-started/](https://docs.prylabs.network/docs/getting-started/)  
 - Github：[https://github.com/prysmaticlabs/prysm/](https://github.com/prysmaticlabs/prysm/)

2. **Sigma Prime 开发的 Lighthouse **

[Lighthouse](https://github.com/sigp/lighthouse)是以太坊2.0客户端的Rust实现，重点是速度和安全性。它背后的团队[Sigma Prime](https://sigmaprime.io/)，是一家信息安全和软件工程公司。 Lighthouse在 GPL-3.0 许可下发布。	
 - 使用说明：[https://lighthouse-book.sigmaprime.io/](https://lighthouse-book.sigmaprime.io/)
 - *Github*：[https://github.com/sigp/lighthouse](https://github.com/sigp/lighthouse)

3. **ConsenSys 开发的 Teku**

[PegaSys Teku](https://pegasys.tech/teku/)是基于Java的以太坊2.0客户端，Java 语言的优势是成熟和广泛应用，其设计和构建是为了满足机构需求和安全要求， Teku 在Apache 2许可下发布。

	- 使用说明：https://docs.teku.pegasys.tech/en/latest/HowTo/Get-Started/Build-From-Source/
	- *Github*：https://github.com/PegaSysEng/teku

4. **Status 开发的 Nimbus**

[Nimbus](https://our.status.im/tag/nimbus/)即是一个客户端实现也是以太坊 2.0的一个研究项目，目标是在嵌入式系统和个人移动设备(包括具有资源受限硬件的较旧智能手机)上能良好运行。 imbus 客户端在 Apache 2.0 许可下发布，使用 Nim 编程语言开发，该编程语言使用类似于 Python 的语法，支持编译为 C 语言。

 - 使用说明：https://nimbus.team/docs/
 - Github：[https://github.com/status-im/nim-beacon-chain](https://github.com/status-im/nim-beacon-chain)

## 3. 安装一个以太坊 1.0 节点

在以太坊 2.0 上运行验证器节点要求先运行以太坊 1.0节点以监视32个ETH验证器存款。选择以太坊 1.0节点时有多种选择，下面是最常用的启动以太坊 1.0节点的客户端。

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_decb1e2e-3b44-4219-b085-e5ab12cc369f_1600x805](https://img.learnblockchain.cn/pics/20201106171546.png)





**自托管：**

- [OpenEthereum](https://www.parity.io/ethereum/)
- [Geth](https://geth.ethereum.org/)
- [Besu](https://besu.hyperledger.org/en/stable/)
- [Nethermind](https://www.nethermind.io/)

**第三方托管：**

- [Infura](https://infura.io/)



## 4. 运行Eth2验证程序

### 4.1. 获取ETH

Eth2 要求每个验证者需要质押32 ETH。如果你最终成为了验证者，也意味着你对以太坊 2.0 计划做出了长期承诺

如果你需要购买一些ETH，可以使用以下交易所：

- 支持法币交易的加密货币交易所（美国地区）：[Coinbase](https://bankless.cc/coinbase)或[Gemini](https://gemini.com/)
- 支持法币交易的加密货币交易所（非美国地区）：[Binance](http://bankless.cc/binance)或[Kraken](http://bankless.cc/kraken)
- 以太坊去中心化交易所：[Uniswap](https://app.uniswap.org/#/)

### 4.2. 前往 [Eth2 Launchpad](https://launchpad.ethereum.org/)

在过去的几个月中，[以太坊基金会(EF)](https://ethereum.org/en/foundation/), Codefi Activate和Deep Work Studio一直在开发一个界面，以使用户更容易质押并成为以太坊 2.0的验证者。

这项工作的结果是[Eth2 Launch Pad](https://launchpad.ethereum.org/)，该应用程序旨在安全地指导你完成生成Eth2密钥， 并将32 ETH 质押到Eth2主网上的官方存款合约中。



Launch Pad 是为普通验证人设计的，即便以太坊业余爱好者也可以在家中使用自己的电脑在终端上方便的运行验证程序。

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_60afd7a9-d289-45a9-8e73-44660e04a208_1600x675](https://img.learnblockchain.cn/pics/20201106171655.png)



#### 2.1：尽职调查(概述部分)

在设置验证程序过程中，花点时间阅读这部分内容非常重要。概述部分旨在使你在学习、了解质押ETH时所涉及的风险。

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_a7eb4c11-1f4f-45e0-8775-40a471c2c597_1600x820 (1)](https://img.learnblockchain.cn/pics/20201106171751.png)



### 4.3. 生成密钥对和和助记词

对于每个验证器节点，都需要生成验证器密钥对和一个助记词，以便稍后生成提款密钥。

第一步，选择要运行的验证器数量以及运行验证器的操作系统平台。

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_34ccbe89-3ac6-4300-984e-387deb2a3239_1600x361](https://img.learnblockchain.cn/pics/20201106171840.png)



![image-20201109100001981](https://img.learnblockchain.cn/pics/20201109100008.png)

Launch Pad 提供了两个选择来帮助我们生成存款密钥，你可以在[此处](https://github.com/ethereum/eth2.0-deposit-cli/blob/master/README.md)找到适用于你的操作系统的详细说明。

第一种是使用可从[Eth2 Github代码库](https://github.com/ethereum/eth2.0-deposit-cli/releases/)下载的二进制可执行文件，然后在终端窗口中运行`./deposit`命令。

**记住验证一下下载二进制文件的URL**



![eth2 line](https://img.learnblockchain.cn/pics/20201106171914.png)



另一个选择是下载Python源代码构建deposit-CLI工具。你需要按照说明安装所有依赖的开发库和deposit-CLI工具。

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_0a9f29f2-fee2-4895-9f79-9e8bb11973f0_1060x1372](https://img.learnblockchain.cn/pics/20201106171947.png)

一旦deposit-CLI工具安装完成，就可以在终端窗口中运行它，系统将提示你：

1. 指定你要运行的验证者数量
2. 你想用来生成助记词的语言
3. 指定要运行验证器的网络(主网)。

**确认网络设置为了 mainnet，否则存款将无效。**

之后，便是输入密码，一旦确认，便会生成助记词。**注意把助记词抄写在安全的地方并离线保存！**

如果这些步骤都顺利完成，那么此时应该会看到以下内容：

![助记词 - 成功](https://img.learnblockchain.cn/pics/20201106172026.png)



如果你对deposit-cli有疑问，请访问[GitHub代码库](https://github.com/ethereum/eth2.0-deposit-cli):

### 4.4. 上传你的存款文件

马上就要大功告成了，上传上一步中生成的`deposit .json`文件。

它位于`/eth2.0-deposit-cli/validator_keys`目录中，标题为`deposit-data- [timestamp] .json`。

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_8515f431-b57e-4e10-9ca2-c940ca424ccb_1600x617](https://img.learnblockchain.cn/pics/20201106172127.png)

### 4.5. 连接钱包

接下来，连接你的Web3钱包，然后单击继续。**确保在钱包设置中选择了Mainnet(主网)。**



![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_55cda529-4a10-4c3d-a4c1-c572d7401473_1456x758](https://img.learnblockchain.cn/pics/20201106172136.png)

### 4.6.  存款

连接到钱包地址后，你将进入“Summary(摘要)”页面，该页面根据你选择运行的验证者的数量，显示需要存款的总额。

接受"警报检查"，单击“确认” 导航到最后一步 - 进行实际存款。

点击“ Initiate the Transaction（发起交易）”，将ETH存入正式的以太坊 2.0 存款合约。



稍后在钱包确认一下每个验证者的32 ETH押金时候成功存入。



一旦确认交易完成，那么恭喜你，你已经成为以太坊 2.0 验证人了。



## 5.  额外资源



在查看完上述步骤之后，还建议阅读各客户特定的指南，然后再开始该过程。将根据选择的客户端不同上述步骤操作顺序会有不同。

下面是迄今为止我们在该行业中看到的最深入的指南：



**关于基础设施/硬件**

- [Hudson Jameson(在DappNode上运行Eth2)](https://hudsonjameson.com/2020-05-18-eth-2-0-staking-and-more-with-topaz-and-dappnode-for-under-750/)
- [Quantstamp文章](https://quantstamp.com/blog/how-to-be-an-eth-2-0-validator-on-the-topaz-testnet)

**CoinCashew系列文章：**

- [如何在Ubuntu上用Prysm 参与以太坊 2.0 质押 （Medalla 测试网）](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2)
- [如何在Ubuntu上用Lighthouse 参与以太坊 2.0 质押 （Medalla 测试网）](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2-with-lighthouse)
- [如何在Ubuntu上使用Teku参与以太坊 2.0 质押 （Medalla 测试网）](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2-with-teku-on-ubuntu)
- [如何在Ubuntu上用Nimbus参与以太坊 2.0 质押 （Medalla 测试网）](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2-with-nimbus)

**Somer Esat 系列指南文章：**

- [以太坊2.0 质押指南(Ubuntu/Medalla/Lighthouse)](https://medium.com/@SomerEsat/guide-to-staking-on-ethereum-2-0-ubuntu-medalla-lighthouse-c6f3c34597a8)
- [以太坊2.0 质押指南(Ubuntu/Medalla/Prysm)](https://medium.com/@SomerEsat/guide-to-staking-on-ethereum-2-0-ubuntu-medalla-prysm-4d2a86cc637b)

**关于 以太坊2.0 的开发：**

- [以太坊2.0的新功能(Ben Edgington)](https://hackmd.io/@benjaminion/eth2_news/https%3A%2F%2Fhackmd.io%2F%40benjaminion%2Fwnie2_200817)
- [以太坊博客(Danny Ryan的快速更新)](https://blog.ethereum.org/)
- [Ben Edgington(带注释的Eth2规格)](https://benjaminion.xyz/eth2-annotated-spec/phase0/beacon-chain/ #introduction
- [Jim Mcdonald的文章](https://www.attestant.io/posts/)

**关于密钥：**

- [Ledger Nano X(BLS固件更新)](https://www.ledger.com/first-ever-firmware-update-coming-to-the-ledger-nano-x)

- [证明人：保护验证者密钥](https://www.attestant.io/posts/protecting-validator-keys/)


**关于Eth2 区块浏览器：**

  - [Eth2Stats](https://eth2stats.io/medalla-testnet)
  - [Beaconcha.in](https://beaconcha.in/)
  - [BeaconScan](https://beaconscan.com/)


---



本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。