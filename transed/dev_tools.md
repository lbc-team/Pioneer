> * https://simpleaswater.com/ethereum-developer-tools-list/ 作者：[Vaibhav Saini](https://simpleaswater.com/author/vaibhav/)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)




# 以太坊开发工具大全

## 新手指引

- [ Solidity ](https://learnblockchain.cn/docs/solidity/) -最受欢迎的智能合约语言。
- [Truffle](https://learnblockchain.cn/docs/truffle/) - 最流行的智能合约开发，测试和部署框架。通过npm安装命令行工具，Truffle [新手教程](https://learnblockchain.cn/2018/01/12/first-dapp)。
- [Metamask](https://metamask.io/) -Chrome 钱包插件，用来与Dapps进行交互。
- [Truffle Box](https://trufflesuite.com/boxes) - 可以直接使用各种打包好的开发组件。
- [OpenZeppelin Starter Kits](https://openzeppelin.com/starter-kits/) - 多功能的入门套件，帮助开发人员快速启动基于智能合约的应用程序。包括了 Truffle、OpenZeppelin SDK、经审计过的 OpenZeppelin/contracts-ethereum-package 智能合约库，react-app 和 方便设计的 rimble 。
- [EthHub.io](https://docs.ethhub.io/) - 以太坊的全面概述 - 描述以太坊历史、治理、未来计划和开发资源。
- [Cobra](https://github.com/cobraframework/cobra) - 在以太坊虚拟机(EVM)上进行测试和部署的开发环境框架。
- [Fortmatic](https://fortmatic.com/) - 用于构建web3 dApp的钱包SDK，无需让用户下载钱包插件或App。
- [Portis](https://portis.io/) - 非托管钱包SDK，无需安装就可与与DApp交互。
- [Kauri.io](https://kauri.io/) - 一个关注Web3和新兴技术的社区型的知识平台。分享高质量的技术文章（hahaha 海外版登链社区么  ）， 这里有[入门基础知识](https://kauri.io/community/5d9b16fc890d310001b66e1b)。
- [dfuse](https://dfuse.io/) - 丝滑的区块链API。
- [biconomy](https://biconomy.io/) -通过使用简单易用的SDK启用元交易，在dapp中进行无需gas的交易。



## 智能合约开发

### 智能合约语言

- [Solidity](https://learnblockchain.cn/docs/solidity/) -以太坊智能合约语言
- [Vyper](https://vyper.readthedocs.io/en/latest/) -新的实验性pythonic编程语言

### 开发构架

- [Truffle](https://trufflesuite.com/) - 最流行的智能合约开发，测试和部署框架。Truffle套件包括Truffle，[Ganache](https://github.com/trufflesuite/ganache),和[Drizzle](https://github.com/truffle-box/drizzle-box)。 [从这里可深入了解Truffle](https://media.consensys.net/truffle-deep-dive-what-you-need-to-know-when-developing-on-ethereum-e548d4df6e9)
- [Embark](https://github.com/embark-framework/embark) - DApp开发框架
- [Waffle](https://getwaffle.io/) - 一个小巧、灵活的高级智能合约开发和测试框架(基于ethers.js)
- [dapp-tools](https://dapp.tools/dapp/) -DApp开发框架（命令行脚手架）
- [Etherlime](https://github.com/LimeChain/etherlime) -基于ethers.js的Dapp部署框架
- [Parasol](https://github.com/Lamarkaz/parasol) - 敏捷智能合约开发环境， 有测试，INFURA部署，自动合约文档等功能。
- [0xcert](https://github.com/0xcert/framework/) -用于构建去中心化应用程序的JavaScript框架
- [OpenZeppelin SDK](https://openzeppelin.com/sdk/) - 一套工具帮助开发，编译，升级，部署智能合约并与合约交互的工具。
- [sbt-ethereum](https://sbt-ethereum.io/) -一个用于智能合约交互和开发的命令控制台（可自动补全命令），可进行钱包和ABI管理，支持ENS以及高级Scala集成。
- [Brownie](https://github.com/iamdefinitelyahuman/brownie) - 用于部署、测试并与智能合约交互的Python框架。
- [Cobra](https://github.com/cobraframework/cobra) - 在以太坊虚拟机(EVM)上进行测试和部署的开发环境框架。

### 集成开发环境（IDE）

- [Remix](https://remix.ethereum.org/) -内置静态分析的Web IDE。
- [Atom编辑器](https://atom.io/) - 可用插件 [Atom Solidity Linter](https://atom.io/packages/atom-solidity-linter),[Etheratom](https://atom.io/packages/etheratom), [autocomplete-solisity](https://atom.io/packages/autocomplete-solidity)和[language-solidity](https://atom.io/packages/language-solidity)
- [Vim solidity ](https://github.com/tomlion/vim-solidity) - 为 Solidity 准备的Vim语法文件
- [VS Code](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity) - Visual Studio Code 增加了对Solidity的支持
- [Ethcode](https://marketplace.visualstudio.com/items?itemName=quantanetwork.ethcode) - VS Code插件，可用于编译，执行和调试Solidity＆Vyper程序
- [Eth Fiddle](https://ethfiddle.com/) - [The Loom Network](https://loomx.io/)开发的IDE允许你编写，编译和调试智能合约。用户分享和查找代码片段。

##  其他工具

- [Atra区块链服务](https://console.atra.io/) - Atra提供Web服务来帮助在以太坊区块链上构建，部署和维护去中心化应用程序。
- [Buidler](https://buidler.dev/) -可扩展的开发人员工具，可组合所需工具来帮助智能合约开发人员提高生产率。
- [用于VSCode的Azure 开发套件](https://marketplace.visualstudio.com/items?itemName=AzBlockchain.azure-blockchain) -VSCode扩展，方便在Visual Studio Code中创建智能合约并进行部署

## 测试区块链网络

- [ethnode](https://github.com/vrde/ethnode) -运行以太坊节点(Geth或Parity)进行开发，一条命令启动：`npm i -g ethnode && ethnode`。
- [Ganache](https://github.com/trufflesuite/ganache) - 具有可视化UI和日志显示的测试以太坊区块链的应用程序
- [Kaleido](https://kaleido.io/) -使用Kaleido来建立联盟区块链网络。非常适合PoC和测试
- [Besu 私有网络](https://besu.hyperledger.org/en/stable/Tutorials/Quickstarts/Azure-Private-Network-Quickstart/) - 在Docker容器中运行Besu节点的私有网络
  - [Orion](https://github.com/PegaSysEng/orion) -由PegaSys开发的隐私交易组件
  - [Artemis](https://github.com/PegaSysEng/artemis) -由PegaSys开发的以太坊2.0信标链的Java实现
- [Cliquebait](https://github.com/f-o-a-m/cliquebait) -通过模拟真实区块链网络的docker实例简化了智能合约集成和测试
- [本地雷电网络](https://github.com/ConsenSys/Local-Raiden) -在Docker容器中运行本地Raiden网络以进行演示和测试
- [私有网络部署脚本](https://github.com/ConsenSys/private-networks-deployment-scripts) -现成的用于启动PoA网络的部署脚本
- [本地以太坊网络](https://github.com/ConsenSys/local_ethereum_network) -现成的用于启动本地PoW网络的部署脚本
- [Azure上的以太坊](https://docs.microsoft.com/en-us/azure/blockchain/templates/ethereum-poa-deployment) - 用于PoA联盟链网络的部署和治理
- [Google Cloud上的以太坊](https://console.cloud.google.com/marketplace/details/click-to-deploy-images/ethereum?filter=category:developer-tools) - 基于工作量证明建立以太坊网络
- [Infura](https://infura.io/) - 通过API访问以太坊网络(包括主网和多个测试网：Ropsten，Rinkeby，Goerli，Kovan)
- [Alchemy](https://dashboard.alchemyapi.io/signup?referral=7d60e34c-b30a-4ffa-89d4-3c4efea4e14b) - 和 Infura 一样的节点提供商，可用的免费访问额外更高。

其他可用的节点，可参考文章：[以太坊可用RPC节点列表](https://learnblockchain.cn/article/1792)

### 获取测试以太水龙头

- [Rinkeby水龙头](https://faucet.rinkeby.io/)
- [Kovan 水龙头](https://github.com/kovan-testnet/faucet)
- [Ropsten 水龙头](https://faucet.metamask.io/)
- [Goerli水龙头](https://goerli-faucet.slock.it/)
- [通用水龙头](https://faucets.blockxlabs.com/)
- [Nethereum 水龙头](https://github.com/Nethereum/Nethereum.Faucet) 

## 与以太坊交互

### 前端以太坊API

- [Web3.js](https://learnblockchain.cn/docs/web3.js/)  -  Javascript Web3  API 

   ​	以下几个 API 作用和 Web3.js 类似，可供选择：

   - [Eth.js](https://github.com/ethjs) -  Javascript Web3   API 
   - [Ethers.js](https://github.com/ethers-io/ethers.js/) - Javascript Web3   API ，包含实用工具和钱包功能
   - [light.js](https://github.com/paritytech/js-libs/tree/master/packages/light.js) - 针对轻客户端优化的响应式JS库。
   - [Web3Wrapper](https://github.com/0xProject/0x-monorepo/tree/development/packages/web3-wrapper) -Typescript Web3 API
   - [Ethereumjs](https://github.com/ethereumjs/) - 以太坊的实用工具函数集合，例如： [ethereumjs-util](https://github.com/ethereumjs/ethereumjs-util)和[ethereumjs-tx](https://github.com/ethereumjs/ethereumjs-tx)
   - [flex-contact](https://github.com/merklejerk/flex-contract)和[flex-ether](https://github.com/merklejerk/flex-ether) - 现代化的零配置用于与智能合约进行交互的库。
   - [ez-ens](https://github.com/merklejerk/ez-ens) - 简单的零配置以太坊域名服务地址解析器。
   - [web3x](https://github.com/xf00f/web3x) - web3.js的TypeScript 移植。具有小巧和类型安全的优势。

- [Nethereum](https://github.com/Nethereum/) -跨平台的以太坊开发框架

- [dfuse](https://github.com/dfuse-io/client-js) -使用[dfuse Ethereum API](https://dfuse.io/)的TypeScript库

- [Drizzle](https://github.com/truffle-box/drizzle-box) - Redux库，将前端连接到区块链

- [Tasit SDK](https://github.com/tasitlabs/tasitsdk) -使用React Native制作原生移动以太坊dapp的JavaScript SDK

- [Subproviders](https://0x.org/docs/tools/subproviders) -与[Web3-provider-engine](https://github.com/MetaMask/web3-provider-engine)结合使用的几个有用的子提供商(包括一个LedgerSubprovider - 用于向dApp添加Ledger硬件钱包支持)

- [web3-react](https://github.com/NoahZinsmeister/web3-react) -用于构建单页以太坊dApp的React框架

- [ethvtx](https://github.com/ticket721/ethvtx) -支持以太坊且与框架无关的redux存储配置， [文档](https://ticket721.github.io/ethvtx/)

- 类型严格 - Javascript替代方案

   - [elm-ethereum](https://github.com/cmditch/elm-ethereum)
   - [purescript-web3](https://github.com/f-o-a-m/purescript-web3)

- [ChainAbstractionLayer](https://github.com/liquality/chainabstractionlayer) -使用单个界面与不同的区块链(包括以太坊)进行通信。

- [Delphereum](https://github.com/svanas/delphereum) -以太坊区块链的Delphi接口，允许开发适用于Windows，macOS，iOS和Android的本地dApp。

### 后端以太坊API

- [Web3.py](https://github.com/ethereum/web3.py) - Python Web3
- [Web3.php](https://github.com/sc0Vu/web3.php) - PHP Web3
- [以太坊-php](https://github.com/digitaldonkey/ethereum-php) - PHP Web3
- [Web3j](https://github.com/web3j/web3j) - Java Web3
- [Nethereum](https://nethereum.com/) - Net Web3
- [Ethereum.rb](https://github.com/EthWorks/ethereum.rb) - Ruby Web3
- [Web3.hs](https://hackage.haskell.org/package/web3) - Haskell Web3
- [KEthereum](https://github.com/komputing/KEthereum) - Kotlin Web3
- [Eventeum](https://github.com/ConsenSys/eventeum) -以太坊智能合约事件和后端微服务之间的桥梁，由Kauri用Java开发
- [Ethereumex](https://github.com/mana-ethereum/ethereumex) -以太坊区块链的Elixir JSON-RPC客户端
- [Ethereum-jsonrpc-gateway](https://github.com/HydroProtocol/ethereum-jsonrpc-gateway) - 允许你运行多个以太坊节点以实现冗余和负载平衡目的的网关。可以作为Infura的替代品(或在其之上)运行，用Golang写。
- [EthContract](https://github.com/AgileAlpha/eth_contract) -一组帮助在Elixir中查询智能合约的帮助方法
- [MESG](https://mesg.com/) -MESG服务，可根据其地址和ABI与任何以太坊合约进行交互。
- [以太坊服务](https://github.com/mesg-foundation/service-ethereum) -MESG服务，用于与以太坊中的事件进行交互并与其进行交互。
- [Marmo](https://marmo.io/) -Python，JS和Java SDK，用于简化与以太坊的交互。使用中继器将交易成本分担给中继器。

### 开箱即用工具

- [Truffle Box](https://trufflesuite.com/boxes) - 可以直接使用各种打包好的开发组件。

- [Besu私有网络](https://besu.hyperledger.org/en/stable/Tutorials/Quickstarts/Azure-Private-Network-Quickstart/) -在Docker容器中运行Besu节点的私有网络

- [Testchains](https://github.com/Nethereum/TestChains) -预先配置的.NET开发链以实现快速响应的PoA网络

  ​	* [Blazor /区块链资源管理器](https://github.com/Nethereum/NethereumBlazor) - Wasm区块链资源管理器(功能示例)

- [本地雷电网络](https://github.com/ConsenSys/Local-Raiden) -在Docker容器中运行本地Raiden网络以进行演示和测试

- [私有网络部署脚本](https://github.com/ConsenSys/private-networks-deployment-scripts) - 现成的用于启动PoA网络的部署脚本MESG

- [Parity Demo-PoA教程](https://wiki.parity.io/Demo-PoA-tutorial.html) - 一个教程，用于构建具有2个节点的PoA测试链。

- [本地以太坊网络](https://github.com/ConsenSys/local_ethereum_network) - 现成的用于启动Pow网络的部署脚本

- [Kaleido](https://kaleido.io/) -使用Kaleido来建立联盟区块链网络，非常适合PoC和测试。

- [Cheshire](https://github.com/endless-nameless-inc/cheshire) - CryptoKitties API和智能合约的本地沙盒实现，可以作为Truffle Box使用

- [aragonCLI](https://github.com/aragon/aragon-cli) - aragonCLI用于创建和开发Aragon应用程序和组织。

- [ColonyJS](https://github.com/JoinColony/colonyJS) - 提供用于与Colony 网络智能合约进行交互的API的JavaScript客户端。

- [ArcJS](https://github.com/daostack/arc.js) -便于javascript应用程序访问DAOstack Arc以太坊智能合约的库。

- [Arkane Connect](https://docs.arkane.network/pages/connect-js.html) -JavaScript客户端，提供与Arkane Network(用于构建用户友好型dapp的钱包提供商)进行交互的API。

- [Blocknative](https://blocknative.com/) - Assist.js是一个可嵌入的小部件，用于提高Dapp的可用性。该工具通过[监听交易内存池](https://explorer.blocknative.com/)的方式，告知最终用户所进行的操作，用来克服(甚至防止)常见的陷阱和障碍。

### 以太坊ABI工具

- [Hashex](https://abi.hashex.org/) - 一个 Web 工具，通过 ABI 和参数获得ABI 编码数据

- [ABI解码器](https://github.com/ConsenSys/abi-decoder) - 用于从以太坊交易中解码数据参数和事件的库

- [ABI-gen](https://github.com/0xProject/0x-monorepo/tree/development/packages/abi-gen) -从合约ABI生成Typescript合约包装器。

- [以太坊 ABI UI](https://github.com/hiddentao/ethereum-abi-ui) - 以太坊合约ABI自动生成UI表单字段定义和相关的验证器

- [headlong](https://github.com/esaulpaugh/headlong/) - 类型安全的合约ABI和递归长度前缀库（Java 版本）

- [ OneClick dApp](https://oneclickdapp.com/) - 使用ABI在唯一的URL上立即创建dApp。

- [Truffle pig](https://npmjs.com/package/trufflepig) -开发工具，提供简单的HTTP API来查找和读取Truffle生成的合约文件，以便在本地开发期间使用。通过http提供新的合约ABI。

  

## 开发范式与最佳实践

### 智能合约开发范式

- [Dappsys](https://github.com/dapphub/dappsys)：收集整理了一些安全且高可复用合约模块
    - 提供以太坊/常见问题的解决方案，例如：

        - [白名单](https://steemit.com/ethereum/@nexusdev/dapp-a-day-11-whitelist-boring)

      - [可升级的ERC20代币](https://steemit.com/ethereum/@nikolai/dapp-a-day-6-upgradeable-tokens)

      - [ERC20-Token-Vault](https://steemit.com/ethereum/@nexusdev/dapp-a-day-18-erc20-token-vault)

      - [授权(RBAC)](https://steemit.com/ethereum/@nikolai/dapp-a-day-4-access-control-via-auth)

      - [...更多...](https://github.com/dapphub/dappsys)

        

    - 为[MakerDAO]提供了构建基块(https://github.com/makerdao/maker-otc)或[TAO](https://github.com/ryepdx/the-tao)
    - 在创建自己的未经测试的解决方案之前应咨询
    - [Dapp-a-day 1-10]中描述了用法(https://steemit.com/@nikolai)和[Dapp-a-day 11-25](https://steemit.com/@nexusdev)
- OpenZeppelin合约：以Solidity语言编写的可重用和安全智能合约的开放框架。
    - 可能是使用最广泛的代码库和智能合约
    - 与Dappsys类似，更多集成到Truffle框架中
    - [博客: 关于安全审核最佳实践](https://blog.openzeppelin.com/)

- [Assembly 高级研讨课](https://github.com/androlo/solidity-workshop)
- [简单以太坊Multisig（多签）](https://medium.com/@ChrisLundkvist/exploring-simpler-ethereum-multisig-contracts-b71020c19037)  
- [CryptoFin Solidity 审核清单](https://github.com/cryptofinlabs/audit-checklist)  - 主网上线前常见问题审计清单。
- aragonOS：用于构建DAO，Dapp和协议的智能合约框架
     - 可升级性：智能合约可以升级到新版本
     - 权限控制：通过使用auth和authP修饰符，可以控制经过允许的实体能访问函数
     - 转发器：aragonOS应用程序可以将其执行操作的动作发送给其他应用程序，以便在满足一组要求时转发动作

### 可升级性

- 博客 von Elena Dimitrova，来自Colony.io的开发者
 - https://blog.colony.io/writing-more-robust-smart-contracts-99ad0a11e948
- https://blog.colony.io/writing-upgradeable-contracts-in-solidity-6743f0eecc88
- Aragon 研究博客
 - [库驱动开发](https://blog.aragon.org/library-driven-development-in-solidity-2bebcaf88736)
- [高级Solidity代码部署技术](https://blog.aragon.org/advanced-solidity-code-deployment-techniques-dc032665f434/)
- [OpenZeppelin代理库](https://blog.openzeppelin.com/proxy-libraries-in-solidity-79fbe4b970fd/)

## 基础设施

### 以太坊客户端

- [Besu](https://besu.hyperledger.org/en/latest/) -以Apache 2.0许可开发并以Java编写的开源以太坊客户端。该项目由Hyperledger托管。
- [Geth](https://geth.ethereum.org/docs/) - Go 客户端
- [OpenEthereum](https://github.com/OpenEthereum/open-ethereum) - Rust客户端
- [Aleth](https://github.com/ethereum/aleth) - C ++ 客户端
- [Nethermind](https://github.com/NethermindEth/nethermind) - .NET 客户端
- [Infura](https://infura.io/) - 一种托管服务，提供符合以太坊客户端标准的 API
- [Trinity](https://trinity.ethereum.org/) -使用 Python 客户端 [py-evm](https://github.com/ethereum/py-evm)
- [Ethereumjs](https://github.com/ethereumjs/ethereumjs-client) - 使用 [ethereumjs-vm](https://github.com/ethereumjs/ethereumjs-vm) 的 JS 客户端
- [Seth](https://github.com/dapphub/dapptools/tree/master/src/seth) - Seth 是一个以太坊客户端工具，就像“命令行的 MetaMask”一样
- [Mustekala](https://github.com/musteka-la/mustekala) - Metamask 的以太坊轻客户端项目
- [Exthereum](https://github.com/exthereum/blockchain) - Elixir 客户
- [EWF Parity](https://github.com/energywebfoundation/energyweb-ui) - Tobalaba 测试网络的 Energy Web Foundation 客户端
- [Quorum](https://github.com/jpmorganchase/quorum) - [JP Morgan](https://jpmorgan.com/quorum) 授权的以太坊支持数据隐私的实现
- [Mana](https://github.com/mana-ethereum/mana) - 用 Elixir 写的以太坊全节点实现。
- [Chainstack](https://chainstack.com/) - 提供共享和专用 Geth 节点的托管服务
- [QuikNode](https://quiknode.io/) - 具有 API 访问和节点即服务的区块链开发云。

### 存储

- IPFS -去中心化存储和文件引用

  - [Mahuta](https://github.com/ConsenSys/Mahuta) -具有附加搜索功能的IPFS存储服务，以前称为IPFS-Store
  - [OrbitDB](https://github.com/orbitdb/orbit-db) -IPFS之上的去中心化数据库
  - [JS IPFS API](https://github.com/ipfs/js-ipfs-http-client) -使用JavaScript实现的IPFS HTTP API客户端库
  - [Temporal](https://github.com/RTradeLtd/Temporal) - 易于使用的API集成到IPFS和其他分布式/去中心化存储协议中
- [Swarm](https://swarm-gateways.net/) -分布式存储平台和内容分发服务，以太坊web3技术栈的基础层服务

- [Infura](https://infura.io/) - 托管的IPFS API网关和pinning服务

- [3Box 存储](https://docs.3box.io/api/storage) -用于用户控制的分布式存储的api。建立在IPFS和Orbitdb之上。

### 通信协议

- [Whisper](https://github.com/ethereum/wiki/wiki/Whisper) -DApp相互通信的通信协议，以太坊Web3技术栈的服务
- [DEVp2p Wire 协议](https://github.com/ethereum/devp2p/blob/master/rlpx.md) -运行以太坊/Whisper节点之间的P2P通信
- [Pydevp2p](https://github.com/ethereum/pydevp2p) -RLPx网络层的Python实现
- [3Box线程](https://docs.3box.io/api/messaging) - 一个方便 开发人员实现IPFS持久化，或 内存中 p2p 通信。

## 测试工具

- [Truffle Team](https://trufflesuite.com/teams) -零配置持续集成Truffle项目
- [ Solidity 代码覆盖率](https://github.com/0xProject/0x-monorepo/tree/development/packages/sol-coverage) - Solidity 代码覆盖率工具
- [ Solidity 覆盖率](https://github.com/sc-forks/solidity-coverage) -Solidity 代码覆盖率工具（另一个替代方案）
- [ Solidity 函数分析器](https://github.com/EricR/sol-function-profiler) - Solidity 合约函数性能分析器
- [Sol-profiler](https://github.com/Aniket-Engg/sol-profiler) - Solidity 合约函数性能分析器（另一个替代方案）
- [Espresso](https://github.com/hillstreetlabs/espresso) -快速，并行化，可热加载 Solidity 测试框架
- [Eth tester](https://github.com/ethereum/eth-tester) -用于测试以太坊应用程序的工具套件
- [Cliquebait](https://github.com/f-o-a-m/cliquebait) -通过类似于真实区块链网络的docker实例简化了智能合约应用程序的集成和接受测试
- [Hevm](https://github.com/dapphub/dapptools/tree/master/src/hevm) -hevm项目是以太坊虚拟机(EVM)的实现，专门用于单元测试和调试智能合约
- [以太坊 graph debuger](https://github.com/fergarrui/ethereum-graph-debugger) - Solidity 图形调试器
- [ Tenderly CLI](https://github.com/Tenderly/tenderly-cli) -通过人类可读的堆栈跟踪加快开发速度
- [EthTx](https://ethtx.info/) - 详细分析交易信息 - （查看代币的流动和函数调用）。
- [Solhint](https://github.com/protofire/solhint) -Solidity Linter，可提供安全性，编程风格指南和最佳实践规则，以进行智能合约验证
- [Ethlint](https://github.com/duaraghav8/Ethlint) -Linter可以识别和修复Solidity(以前为Solium)中的编程风格和安全问题
- [Decode](https://github.com/hacker-DOM/decode) -npm软件包，它将交易提交到本地testrpc节点进行解析，以使其更易读和理解
- [Truffle断言](https://github.com/rkalis/truffle-assertions) -带有其他断言和实用工具的npm软件包，在Truffle中测试Solidity智能合约。最重要的是，它能对是否已触发特定事件进行断言。
- [Psol](https://github.com/Lamarkaz/psol) -Solidity词法预处理器，具有mustache.js 语法风格、宏、条件编译和包含自动远程依赖关系。
- [solpp](https://github.com/merklejerk/solpp) -Solidity预处理器，具有全面的指令和表达式语言，高精度数学和许多有用的辅助函数。
- [解码和发布](https://flightwallet.github.io/decode-eth-tx/) – 解码并发布原始的以太坊交易。类似于https://live.blockcypher.com/btc-testnet/decodetx/
- [Doppelgänger](https://getdoppelganger.io/) -一个用于在单元测试期间模拟智能合约依赖关系的库。
- [rocketh](https://github.com/wighawag/rocketh) - 一个简单的工具，用来测试以太坊智能合约，可以允许使用任何web3库和来运行测试程序。
- [pytest-cobra](https://github.com/cobraframework/pytest-cobra) -PyTest插件，用于测试智能合约。

## 安全工具

- [EthTx](https://ethtx.info/) - 详细分析交易信息 - （查看代币的流动和函数调用）。
- [MyXX](https://mythx.io/) -以太坊开发人员的安全验证平台和工具生态系统
- [Mythril](https://github.com/ConsenSys/mythril) -开源EVM字节码安全性分析工具（另一个替代方案）
- [Oyente](https://github.com/melonproject/oyente) -智能合约静态安全分析
- [Securify](https://securify.chainsecurity.com/) -以太坊智能合约的安全扫描器
- [SmartCheck](https://tool.smartdec.net/) -静态智能合约安全分析器
- [Ethersplay](https://github.com/crytic/ethersplay) -EVM反汇编器（python）
- [Manticore](https://github.com/trailofbits/manticore) -智能合约和二进制文件上的符号执行工具
- [Slither](https://github.com/crytic/slither) -Solidity静态分析框架
- [Adelaide](https://github.com/sec-bit/adelaide) - SECBIT对Solidity编译器的静态分析插件
- [solv-verify](https://github.com/SRI-CSL/solidity/) -用于对Solidity智能合约的模块化验证
- [Solidity安全博客](https://github.com/sigp/solidity-security-blog) -已知攻击媒介和常见反模式的完整列表
- [有漏洞 ERC20代币](https://github.com/sec-bit/awesome-buggy-erc20-tokens) -受到代币影响的ERC20智能合约中的漏洞集合
- [免费的智能合约安全审核](https://callisto.network/smart-contract-audit/) -来自Callisto Network的免费智能合约安全审核
- [Piet](https://piet.slock.it/) -可视化Solidity体系架构分析器

## 交易与数据监控

- [Alethio](https://aleth.io/) -先进的以太坊分析平台，提供实时监控和异常监控，包含代币各种指标，智能合约审计，图形可视化和区块链搜索。还可以探索以太坊去中心化交易所的实时市场信息和交易活动。
- [amberdata.io](https://amberdata.io/) -提供实时监控和异常监控，包含代币各种指标，智能合约审计，图形可视化和区块链搜索
- [Neufund-智能合约观察](https://github.com/Neufund/smart-contract-watch) -监视大量智能合约和交易的工具
- [Scout](https://scout.cool/) -以太坊上智能合约的活动和事件日志的实时数据馈送
- [Tenderly](https://tenderly.co/) -一个平台，可通过Web仪表板的形式为用户提供可靠的智能合约监控和警报。
- [Chainlyt](https://www.chainlyt.io/main/dashboard/contract) -使用已解码的交易数据探索智能合约，查看如何使用合约并通过特定的函数调用搜索交易
- [BlockScout](https://github.com/poanetwork/blockscout) -用于检查和分析基于EVM的区块链的工具。一款以太坊网络的功能完善的区块链浏览器。
- [Terminal](https://terminal.co/) - 用于监视dapp的控制面板。终端可用于监视用户，dapp，区块链基础设施，交易等。
- [Ethereum-watcher](https://github.com/HydroProtocol/ethereum-watcher) -用Golang编写的可扩展框架，用于侦听链上事件并做出响应。

## 其他工具

- [aragonPM](https://hack.aragon.org/docs/apm-intro.html) - 由 aragonOS 和 Ethereum 支持的去中心化软件包管理器。aragonPM 支持对软件包升级进行分布式管理，从而消除集中式故障点。
- Truffle boxes 用于快速构建 DApp 的打包组件
  - [Cheshire](https://github.com/endless-nameless-inc/cheshire) - CryptoKitties API 和智能合约的本地沙盒实现，可以作为Truffle boxes 使用
- [Solc](https://solidity.readthedocs.io/en/latest/using-the-compiler.html) - Solidity 编译器
- [Sol-compiler](https://sol-compiler.com/) -项目级 Solidity 编译器
- [Solidity cli](https://github.com/pubkey/solidity-cli) - 更快，更轻松，更可靠地编译 Solidity 代码
- [Solidity flattener](https://github.com/poanetwork/solidity-flattener) - Solidity 项目展开到单个文件的实用程序。对于可视化导入的合约或在 Etherscan 上验证合约很有用
- [Sol-merger](https://github.com/RyuuGan/sol-merger) - 将所有导入合并到单个文件中（替代方案）
- [RLP](https://github.com/ethereumjs/rlp) - JavaScript 中的递归长度前缀编码
- [eth-cli](https://github.com/protofire/eth-cli) - 一系列 CLI 工具的帮助以太坊学习和开发
- [Ethereal](https://github.com/wealdtech/ethereal) - Ethereal 是用于管理以太坊中常见任务的命令行工具
- [Eth crypto](https://github.com/pubkey/eth-crypto) - 以太坊的加密 JavaScript 函数以及将其与 web3js 和 solidity 结合使用的教程
- [Parity Signer](https://github.com/paritytech/parity-signer) - 允许移动应用程序签署交易
- [py-eth](http://py-eth.com/) - 以太坊生态系统的 Python 工具集合
- [truffle-flattener](https://github.com/nomiclabs/truffle-flattener) -  Truffle 框架下，合并 Solidity 的所有依赖项
- [Decode](https://github.com/hacker-DOM/decode) - npm 软件包，它将 tx 提交到本地 testrpc 节点的解析，使它们更具可读性和易懂性
- [TypeChain](https://github.com/ethereum-ts/TypeChain) - 以太坊智能合约的 Typescript 绑定
- [EthSum](https://ethsum.netlify.com/) - 一个简单的以太坊地址校验和工具
- [PHP based Blockchain indexer](https://github.com/digitaldonkey/ethereum-php-eventlistener) - 在 PHP 中索引块或侦听的事件
- [Web3Model](https://web3modal.com/) -  用统一的方式接入所有钱包
- [Purser](https://github.com/JoinColony/purser) - JavaScript 的基于以太坊的钱包通用钱包工具。支持软件，硬件和 Metamask-使dApp 开发有一致的接口接入所有钱包。
- [Node-Metamask](https://github.com/JoinColony/node-metamask) - 从 node.js 连接到 MetaMask
- [Solidity-docgen](https://github.com/OpenZeppelin/solidity-docgen) - Solidity 项目的文档生成器
- [Ethereum ETL](https://github.com/blockchain-etl/ethereum-etl) - 将以太坊区块链数据导出到 CSV 或 JSON 文件
- [prettier-plugin-solidity](https://github.com/prettier-solidity/prettier-plugin-solidity) - solidity-用于格式化 Solidity 代码的插件
- [Unity3dSimpleSample](https://github.com/Nethereum/Unity3dSimpleSample) - 以太坊和 Unity 集成Demo
- [Flappy](https://github.com/Nethereum/Nethereum.Flappy) - 以太坊和 Unity 集成Demo/示例
- [Wonka](https://github.com/Nethereum/Wonka) - Nethereum 业务规则引擎Demo/示例
- [Resolver-Engine](https://github.com/Crypto-Punkers/resolver-engine) - 一组用于标准化框架中 Solidity 导入和工件解析的工具。
- [eth-reveal](https://github.com/justinjmoses/eth-reveal) - 探究交易详情，使用在线找到的 ABI 尽可能解码方法，事件日志和回退的原因。
- [Ethereum-tx-sender](https://github.com/HydroProtocol/ethereum-tx-sender) -一个用 Golang 编写的有用的库，用于可靠地发送交易-提取一些棘手的底层细节，例如gas优化，随机数计算，同步和重试。
- [truffle-plugin-verify](https://github.com/rkalis/truffle-plugin-verify) - 从 Truffle 命令行在 Etherscan 上无缝验证合约源代码。

## 智能合约标准和代码库

### [ERC](https://eips.ethereum.org/erc) 标准（以太坊评论提案库）

- 代币标准
 - [ERC-20](https://eips.ethereum.org/EIPS/eip-20) - 可替代资产的原始代币合约
- [ERC-721](https://eips.ethereum.org/EIPS/eip-721) -不可替代资产的代币标准
- [ERC-777](https://eips.ethereum.org/EIPS/eip-777) - ERC-20改进版代币标准
- [ERC-918](https://eips.ethereum.org/EIPS/eip-918) -可采矿代币标准
- [ERC-165](https://eips.ethereum.org/EIPS/eip-165) -创建一种标准方法来发布和检测智能合约实现的接口。
- [ERC-725](https://eips.ethereum.org/EIPS/eip-725) -用于密钥管理和执行的代理合约，以建立区块链身份。
- [ERC-173](https://eips.ethereum.org/EIPS/eip-173) -合约所有权的标准接口

### 流行的智能合约库

- [Zeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts) -包含经过测试的可重用智能合约，例如SafeMath和[OpenZeppelin SDK 库](https://github.com/OpenZeppelin/openzeppelin-sdk)实现智能合约的可升级性
- [DateTime库](https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary) - 节省 gas 的Solidity日期和时间库
- [Aragon](https://github.com/aragon/aragon) -DAO协议，包含[aragonOS智能合约框架](https://github.com/aragon/aragonOS)专注于可升级性和治理
- [ARC](https://github.com/daostack/arc) -DAO和DAO堆栈的基础层的操作系统。
- [0x](https://github.com/0xProject) -DEX协议
- [Token Libraries with Proofs](https://github.com/sec-bit/tokenlibs-with-proofs) -包含代币合约wrt的正确性证明。
- [可证明的API](https://github.com/provable-things/ethereum-api) -提供使用Provable服务的合约，允许进行链下操作，数据获取和计算

## 二层扩容开发指南

### 可扩展性

#### Rollup

​	参考[Rollup 各方案异同简介](https://learnblockchain.cn/article/739)

 * ZK Rollup
    * ZkSync
    * loopring
* Optimistic Rollup
* Arbitrum Rollup

#### 支付/状态通道

- [以太坊支付通道](https://medium.com/@matthewdif/ethereum-payment-channel-in-50-lines-of-code-a94fad2704bc) -50行代码的以太坊支付通道
- [µRaiden文档](https://microraiden.readthedocs.io/) -µRaiden发送者/接收者用例的指南和示例

#### Plasma

- [学习Plasma](https://github.com/ethsociety/learn-plasma) -作为节点应用程序的网站，该应用程序始于康奈尔大学的2018 IC3-以太坊加密货币新手训练营，涵盖了所有Plasma变体(MVP /Cash/借记卡)
- [Plasma MVP](https://github.com/omisego/plasma-contracts) -OmiseGO的最小可行血浆的研究实现
- [Plasma MVP Golang](https://github.com/kyokan/plasma) -Golang实现和最小可行血浆规范的扩展
- [Plasma Guard](https://github.com/mesg-foundation/plasma-guard) -在需要时自动观看并挑战或退出OmisegoPlasma网络。
- [Plasma OmiseGo Watcher](https://github.com/mesg-foundation/service-plasma-omisego-watcher) -与Plasma OmiseGo网络交互并通知任何拜占庭事件。

#### 侧链

- POA Network 
 - [POA 桥接](https://bridge.poa.net/)
- [POA 桥接 UI](https://github.com/poanetwork/bridge-ui)
- [POA 桥接合约](https://github.com/poanetwork/poa-bridge-contracts)
- [Loom 网络](https://github.com/loomnetwork)
- [Matic网络](https://docs.matic.network/)

### 隐私/保密

##### zkSNARKs

- [ZoKrates](https://github.com/Zokrates/ZoKrates) -以太坊上的zkSNARKS的工具箱
- [AZTEC协议](https://github.com/AztecProtocol/AZTEC) -以太坊网络上的隐私交易，在以太坊主网上实时实现
- [Nightfall](https://github.com/EYBlockchain/nightfall) -将任何ERC-20/ERC-721代币转为隐私交易-开源工具和微服务
- 代理重新加密(PRE)
* [NuCypher网络](https://github.com/nucypher/nucypher) -代理重新加密网络，可在去中心化系统中实现数据隐私
* [pyUmbral](https://github.com/nucypher/pyumbral) -门限代理重新加密密码库
- 全同态加密(FHE)
* [NuFHE](https://github.com/nucypher/nufhe) -GPU加速的FHE库

## 预构建的UI组件

- [aragonUI](https://ui.aragon.org/) -包含Dapp组件的React库
- [components.bounties.network](https://components.bounties.network/) -包含Dapp组件的React库
- [ui.decentraland.org](https://github.com/decentraland/ui) -包含Dapp组件的React库
- [dapparatus](https://github.com/austintgriffith/dapparatus) -可重复使用的React Dapp组件
- [Metamask ui](https://github.com/MetaMask/metamask-extension/tree/develop/ui/app/components) -Metamask React组件
- [DappHybrid](https://github.com/Nethereum/Nethereum.DappHybrid) -用于基于Web的去中心化应用程序的跨平台混合托管机制
- [Nethereum.UI.Desktop](https://github.com/Nethereum/Nethereum.UI.Desktop) -跨平台桌面钱包示例
- [eth-button](https://eth-button.github.io/eth-button/) -极简主义捐赠按钮
- [边框设计系统](https://rimble.consensys.design/) -适用于去中心化应用的组件和设计标准。
- [3Box插件](https://docs.3box.io/build/plugins) 社交功能的react组件。包括评论，个人资料和消息。


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。