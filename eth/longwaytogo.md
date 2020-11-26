> * 原文链接：https://soliditydeveloper.com/erc20-permit
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 无需gas代币和ERC20-Permit还任重而道远

> RC20-Permit(EIP-2612)下，如何避免 使用进行两步交易：授权+ transferFrom！


![](https://img.learnblockchain.cn/2020/10/26/16036950187816.jpg)

**今天是2019年4月在悉尼。**在这里我正在寻找悉尼大型大学大楼内的Edcon Hackathon。感觉就像一个城市中的一个小城市。当然，我在综合大楼的尽头，我意识到要前往举办Hackathon的场地，我需要步行30分钟到另一端。在正式开始前几分钟，我在会场报名！

在所有参与者都生活和呼吸加密的情况下，建立了允许在一种自助餐厅中使用DAI进行付款的系统。这特别有用，因为[AlphaWallet](https://alphawallet.com/)开展一项促销活动：向Hackathon参与者赠送20个促销DAI(随后可购卖打折饮品)，我已经下载了钱包和获得了20个DAI，接下来找到自助餐厅就完美了...

事实并非如此简单。首先，步行15分钟即可到达大学城的中心。我终于找到了。我选择了午餐，很高兴尝试这个新的付款系统。在2012年之前，我已经在餐厅使用比特币付款，但这是我第一次使用ERC-20 . 我扫描QR码，在DAI中输入要支付的金额，然后...

*'没有足够的 gas 来支付交易费用。'*

**啊**！所有的激动都消失了。当然，你需要ETH来支付 gas 费！我的新钱包有0 ETH。我是一个Solidity开发人员，我知道这一点。然而，即使我也发生了。我的有ETH的计算机一直都在会场，所以对我来说没有解决方案。没有午餐，而是漫不经心地回到了会场，我对自己想。要使这项技术成为主流，我们还有很长的路要走。



## 快进至EIP-2612


从那时起，DAI和Uniswap一直在朝着名为[EIP-2612](https://eips.ethereum.org/EIPS/eip-2612)的新标准的方向发展，该标准可以取消 approve + transferFrom，同时还允许无 gas 通证转账。 DAI是第一个为其ERC-20通证添加新的`permit`功能的公司。它允许用户在链下签署授权的交易，生成任何人都可以使用并提交给区块链的签名。这是解决gas 支付问题的基本的第一步，并且消除了用户不友好的两步过程：发送`approve`和之后的` transferFrom`。

让我们详细研究一下EIP。

![](https://img.learnblockchain.cn/2020/10/26/16036950485596.jpg)

## 原始的错误方法


总体而言，该过程非常简单。用户不在发起授权（approve）交易，而是对`approve(spender, amount)`签名。签名结果可以被任何人传递到` permit`函数，在` permit`函数我们只需使用` ecrecover`来检索签名者地址，接着用` approve(signer，spender，amount)`。

这种方式可用于让其他人为交易支付 gas 费用，也可以删除掉常见的授权（approve）+ transferFrom模式：

**之前方法**：

1. 用户提交`token.approve(myContract.address, amount)`交易。
2. 等待交易确认。
3. 用户提交第二个` myContract.doSomething()`交易，该交易内部使用` token.transferFrom`。

**现在**：

1. 用户进行授权签名：签名信息`signature=(myContract.address，amount)`。
2. 用户向` myContract.doSomething(signature)`提交签名。
3. ` myContract`使用` token.permit`增加配额，并调用 ` token.transferFrom` 获取代币。



之前需要两笔交易，现在只需要一笔！

## Permit 细节：防止滥用和重播


我们面临的主要问题是签名可能会多次使用或在原本不打算使用的其他地方使用。为防止这种情况，我们添加了几个参数。在底层，我们使用的是已经存在的，广泛使用的[EIP-712](https://learnblockchain.cn/docs/eips/eip-712.html)标准。

### 1. EIP-712 域哈希（Domain Hash）


使用EIP-712，我们为ERC-20定义了一个域分隔符：

```js
bytes32 eip712DomainHash = keccak256(
    abi.encode(
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ),
        keccak256(bytes(name())), // ERC-20 Name
        keccak256(bytes("1")),    // Version
        chainid(),
        address(this)
    )
);
```

这样可以确保仅在正确的链ID上将签名用于我们给定的通证合约地址。chainID是在以太坊经典分叉之后引入（以太坊经典network id 依旧为 1）， 用来精确识别在哪一个网络。 可以在此处查看现有[chain ID的列表](https://medium.com/@piyopiyo/list-of-ethereums-major-network-and-chain-ids-2bc58e928508)。

### 2. Permit 哈希结构

现在我们可以创建一个Permit的签名：

```
bytes32 hashStruct = keccak256(
    abi.encode(
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
        owner,
        spender,
        amount,
        nonces[owner],
        deadline
    )
);
```

此hashStruct将确保签名只能用于

* Permit 函数
* 从`owner`授权
* 授权`spender`
* 授权给定的`value` （金额）
* 仅在给定的`deadline`之前有效
* 仅对给定的` nonce`有效

` nonce`可确保某人无法重播签名，即在同一合约上多次使用该签名。

### 3. 最终哈希

现在我们可以用兼容 [EIP-191](https://eips.ethereum.org/EIPS/eip-191)的712哈希构建（以0x1901开头）最终签名：

```js
bytes32 hash = keccak256(
    abi.encodePacked(uint16(0x1901), eip712DomainHash, hashStruct)
);
```

### 4. 验证签名



在此哈希上，我们可以使用[ecrecover](https://solidity.readthedocs.io/en/latest/units-and-global-variables.html#mathematical-and-cryptographic-functions) 获得该函数的签名者：


```
address signer = ecrecover(hash, v, r, s);
require(signer == owner, "ERC20Permit: invalid signature");
require(signer != address(0), "ECDSA: invalid signature");
```

无效的签名将产生一个空地址，这就是最后一次检查的目的。

### 5. 增加Nonce 和 授权


现在，最后我们只需要增加所有者的Nonce并调用授权函数即可：

```
nonces[owner]++;
_approve(owner, spender, amount);
```

你可以在[此处](https://github.com/soliditylabs/ERC20-Permit/blob/main/contracts/ERC20Permit.sol)看到完整的实现示例。

## 已有的ERC20-Permit 实现



### DAI ERC20-Permit


DAI是最早引入` permit`的通证之一，如[此处](https://docs.makerdao.com/smart-contract-modules/dai-module/dai-detailed-documentation#3-key-mechanisms-and-concepts)所述。实现与EIP-2612略有不同:

1. 没有使用 `value`，而只使用一个`bool allowed`，并将allowance 设置为`0`或`MAX_UINT256`
2. `deadline`参数称为`expiry`

### Uniswap ERC20-Permit


Uniswap实现与当前的EIP-2612保持一致，请参见[这里](https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)。它允许你调用[removeLiquidityWithPermit](https://uniswap.org/docs/v2/smart-contracts/router02/#removeliquiditywithpermit)，从而省去了额外的`授权`步骤。

如果你想体验一下该过程，请转到[https://app.uniswap.org/#/pool](https://app.uniswap.org/#/pool)并切换到Kovan网络。不用增加资金的流动性。现在尝试将其删除。单击“Approve”后，你会注意到此MetaMask弹出窗口如下图所示。

这不会提交交易，而只会创建具有给定参数的签名。你可以对其进行签名，并在第二步中使用生成的签名调用`removeLiquidityWithPermit`。总而言之：只需提交一份交易。

![](https://img.learnblockchain.cn/2020/10/26/16036951814486.jpg)

## ERC20-Permit 代码库

我已经创建了可以导入的ERC-20-Permit代码库。你可以在[https://github.com/soliditylabs/ERC20-Permit](https://github.com/soliditylabs/ERC20-Permit)中找到它

其使用：

* [OpenZeppelin ERC20 Permit](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237)
* [0x-inspired](https://github.com/0xProject/0x-monorepo/blob/development/contracts/utils/contracts/src/LibEIP712.sol)节省gas的 汇编代码。
* [eth-permit](https://github.com/dmihal/eth-permit) 前端库，用于测试

你可以通过npm安装来简单地使用它：

```
$ npm install @soliditylabs/erc20-permit --save-dev
```

像这样将其导入到你的ERC-20合约中：

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import {ERC20, ERC20Permit} from "@soliditylabs/erc20-permit/contracts/ERC20Permit.sol";

contract ERC20PermitToken is ERC20Permit {
    constructor (uint256 initialSupply) ERC20("ERC20Permit-Token", "EPT") {
        _mint(msg.sender, initialSupply);
    }
}
```

### 前端使用

你可以在我的测试中[代码在这里](https://github.com/soliditylabs/ERC20-Permit/blob/6a07a436bc39d7be53e8d9c160d6c87e0305980c/test/ERC20Permit.test.js#L43-L49)看到如何使用eth-permit库创建有效的签名。它会自动获取正确的随机数，并根据当前标准设置参数。它还支持DAI样式的许可证签名创建。完整文档可在[https://github.com/dmihal/eth-permit](https://github.com/dmihal/eth-permit)获得

关于调试的一句话：这可能很痛苦。关闭任何单个参数都将导致`revert: Invalid signature`。祝你好运找出原因。

在撰写本文时，似乎仍然有一个[已知 issue](https://github.com/dmihal/eth-permit/issues/2)，它可能会或也可能不会影响你，具体取决于你的Web3提供程序。如果确实对你有影响，请使用通过[patch-package](https://www.npmjs.com/package/patch-package)安装[这里](https://github.com/soliditylabs/ERC20-Permit/blob/main/patches/eth-permit%2B0.1.7.patch)的补丁



## 无需gas代币解决方案



现在回想起我在悉尼的经历，单靠这个标准并不能解决问题，但这是解决该问题的第一个基本模块。现在，你可以为其创建加油站网络，例如[Open GSN](https://www.opengsn.org/)。部署合约，该网络只需通过permit + transferFrom即可进行通证转账。 GSN内部运行的节点将获取许可签名并提交。

谁支付 gas 费？这将取决于特定的场景。也许Dapp公司支付这些费用作为其客户获取成本(CAC)的一部分。也许用转移的通证支付了GSN节点费用。要弄清所有细节，我们还有很长的路要走。

## 一如既往的小心使用

请注意，该标准尚未最终确定。当前与Uniswap实现相同，但将来可能会有所变化。如果标准再次更改，我将保持库的更新。我的图书馆代码也未经审核，使用后果自负。




------


本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。