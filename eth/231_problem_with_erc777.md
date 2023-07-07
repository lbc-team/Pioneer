> * 原文链接： https://mixbytes.io/blog/one-more-problem-with-erc777
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# ERC777 与任意调用合约可能出现的安全问题







最近，在与我们的一个客户合作时，我们发现了一个有趣的错误，有可能成为一些DeFi项目的攻击媒介。这个错误尤其与著名的ERC777代币标准有关。此外，它不仅仅是众所周知的黑客中常见的简单的重入问题。

![img](https://img.learnblockchain.cn/2023/06/29/76498.jpeg)

这篇文章对ERC777进行了全面的解释，涵盖了所有必要的细节。深入研究ERC777代币的具体细节的资源很少，这篇文章对于有兴趣深入了解ERC777代币的人来说是一个有价值的详细指南。

在文章的最后部分，将解释我们最近的发现。

## 简短描述攻击载体

这个漏洞利用了ERC777的特性，能够设置一个Hook 接收函数。通过利用在目标合约中进行任意调用的能力，恶意调用者可以调用 ERC777 注册表合约，并为目标合约分配一个特定的Hook地址。因此，只要目标合约在未来收到ERC777代币，攻击者的Hook合约就会被触发。这个Hook可以以各种方式加以利用：要么用于重入攻击以窃取代币，要么只是回退交易，从而阻止目标合约发送或接收ERC777代币。

## ERC777和它的Hook

### 什么是ERC777

ERC777是带有转账Hook的代币标准之一。
这里是 EIP描述：https://eips.ethereum.org/EIPS/eip-777 ， 这里是一篇 [ERC777 实践](https://learnblockchain.cn/2019/09/27/erc777)。

实现ERC777代币的主要动机在于希望能够模仿原生代币转账的行为。通过在代币接收时触发智能合约，开发人员可以执行特定的逻辑，以增强功能并创建更多动态的代币交互。

然而，这些在转账过程中的额外调用使ERC777与ERC20代币不同。这些Hook引入了一个新的攻击载体，可能会影响到那些没有设计时考虑到在代币转账过程中处理额外调用的智能合约。这种出乎意料的行为会给这些合约带来安全风险。

以下是以太坊主网上一些具有一定流动性的ERC777代币的列表：

VRA：https://etherscan.io/address/0xf411903cbc70a74d22900a5de66a2dda66507255
AMP：https://etherscan.io/address/0xff20817765cb7f73d4bde2e66e067e58d11095c2
LUKSO：https://etherscan.io/address/0xa8b919680258d369114910511cc87595aec0be6d
SKL：https://etherscan.io/address/0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7
imBTC：https://etherscan.io/address/0x3212b29e33587a00fb1c83346f5dbfa69a458923
CWEB：https://etherscan.io/address/0x505b5eda5e25a67e1c24a2bf1a527ed9eb88bf04
FLUX：https://etherscan.io/address/0x469eda64aed3a3ad6f868c44564291aa415cb1d9

### 当Hook发生时

ERC20 代币只是在转账过程中更新余额。但ERC777代币是这样做的：



1. 对代币发起者的地址进行Hook调用

2. 更新余额

3. 对代币接收方地址进行Hook调用

这在VRA代币中得到了很好的说明：

![img](https://img.learnblockchain.cn/2023/06/29/62246.png)

源码: https://etherscan.io/address/0xf411903cbc70a74d22900a5de66a2dda66507255

现在，让我们检查一下这些调用的代码：

![img](https://img.learnblockchain.cn/2023/06/29/97082.png)

正如你所看到的：

1. 这个函数从`_ERC1820_REGISTRY`中读取称为`implementer`（实现者）的合约
2. 如果该函数找到了一个实现者，那么这个实现者就会被调用。

让我们研究一下这个注册表，看看什么是实现者。

### 注册表和实现者

所有 ERC777 代币都与注册表（Registry）的合约有关：https://etherscan.io/address/0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24。

这个地址被ERC777代币用来存储设定的 Hook 接收者。这些 Hook 接收者被称为 "接口实现者"。

这意味着Alice可以选择Bob作为她的接口实现者。如果Alice接收或发送ERC777代币，Bob将收到Hook。

Alice 可以管理不同的Hook类型。因此，当 Alice发送代币时，她可以选择Bob作为接口实现者，而只有当Alice收到代币时，她选择Tom作为实现者。

在大多数情况下，她也可以为不同的代币选择不同的接口实现者。

这些偏好设置被存储在这个映射的注册表中：

![img](https://img.learnblockchain.cn/2023/06/29/46687.png)

`_interfaceHash`是Alice为一个事件选择接口实现者的标识。

而任何人都可以用这个函数读取Alice的接口实现者：

![img](https://img.learnblockchain.cn/2023/06/29/86120.png)

正如你所看到的，这就是我们之前在VRA代码中遇到的函数。

变量`_TOKENS_SENDER_INTERFACE_HASH`被用作`_interfaceHash`，它可以是任何字节。但是VRA代币使用这些字节来识别这种类型的Hook：



![img](https://img.learnblockchain.cn/2023/06/29/84979.png)

### 接收Hook

设置一个Hook接收函数，Alice只需在注册表上调用这个函数并输入Bob的地址作为`_implementer`参数。

![img](https://img.learnblockchain.cn/2023/06/29/88475.png)

她还必须指定一个`_interfaceHash`。她会从VRA代币代码中获取这个`_TOKENS_SENDER_INTERFACE_HASH`。

还有一个重要的细节。

在为上面的VRA设置实现者后，Alice 也将会意识到，即使其他ERC777代币被转账，Bob也会收到调用。
比如 [imBTC](https://etherscan.io/address/0x3212b29e33587a00fb1c83346f5dbfa69a458923)， imBTC在发送的代币上有相同的`_interfaceHash`。

这是由于所有ERC777代币共享相同的注册表合约来存储Hook的偏好设置。但这取决于ERC777代币为他们的Hook指定名称，虽然有时它们是相似的，但并不总是如此。

### 如何找到ERC777代币

调用注册表是所有 ERC777 都具有的特征。
因此，我们可以尝试[dune.com](http://dune.com/)来调用所有调用注册表的智能合约。

![img](https://img.learnblockchain.cn/2023/06/29/37846.png)

我们可以使用这个SQL脚本。事实上，我们应该另外过滤出代币地址，但至少我们有一个完美的开始，结果有78个地址。

> 译者备注：dune  [traces表](https://dune.com/docs/data-tables/raw/evm/traces/) 会记录交易内部调用记录。

### 这个注册表是唯一可能的吗？

理论上，没有人能够保证某些代币恰好使用这个0x1820合约作为注册表。
但我们可以用[dune.com](http://dune.com/)来检查。

![img](https://img.learnblockchain.cn/2023/06/29/77956.png)

它返回这些地址

```
0x1820a4b7618bde71dce8cdc73aab6c95905fad24
0xc0ce3461c92d95b4e1d3abeb5c9d378b1e418030
0x820c4597fc3e4193282576750ea4fcfe34ddf0a7
```

我们检查过，0x1820是唯一拥有有价值的ERC777代币的注册表。其他注册表的代币并不那么有价值。

### 可Hook代币的普遍情况

ERC777 不仅是一个带有Hook的标准。还有 ERC223、ERC995或ERC667。
它们并不那么稀奇。你一定听说过实现 ERC667 的[LINK代币](https://etherscan.io/token/0x514910771af9ca656af840dff83e8264ecf986ca)。



## 使用任意调用的攻击载体

这是最近为我们的客户发现的攻击载体。



研究人员通常认为ERC777代币会对调用发起者和接收者进行调用。但实际上，发起者和接收者可选择任意 "Bob" 作为Hook接收者。

因此，想象一下结合那些具有任何数据对任何地址进行任意调用的合约会发生什么？

就有任意调用功能的可以广泛存在于 DEX 聚合器、钱包、multicall 合约中。

> 译者注：任意调用功能是指在合约中存在类似这样的函数：
>
> `function execute(address target, uint value, string memory signature, bytes memory data, uint eta) public payable;`
>
> 它可以调用任何的其他的方法。



攻击方法：

1. 攻击者找到一个允许任意调用的函数的目标合约（Target）

2. 攻击者在目标（Target）上调用：

3. `registy1820.setInterfaceImplementer(Target, hookHash, Attacker)`

4. 现在，我们的`Attacker` 是 `Target` 的实现者

5. `Attacker`  会随着 `ERC777`代币中使用的 `hookHash` 而被调用。

6. 每当目标合约（`Target`）收到ERC777代币时，`Attacker`就会收到一个 Hook 调用。

7. 下面的攻击，取决于 `Target`代码 而不同：

   - `Attacker` 可以在一些用户执行目标合约中的函数时进行重入

   - `Attacker `可以直接回退，这样用户的交易就直接被还原了


如果DEX聚合器计算最佳兑换路径是通过某个有ERC777代币的DEX交易对时，那么可能会遇到问题。

## 保护

经过与客户数小时的讨论，我们找到了一个不会破坏任意调用的解决方案。

项目方最好限制使用 `Registry1820`作为任意调用的地址。因此，没有攻击者能够利用任意调用来设置接口实现者。

## 经验之谈

项目和审计人员必须注意到ERC777中描述的Hook行为。这些代币不仅对接收者和发起者进行调用，也对其他一些Hook接收者进行调用。

在这个意义上，允许任意调用的项目必须特别注意，并考虑ERC777的另一个攻击载体。



原文作者：Daniil Ogurtsov , MixBytes的安全研究员

---



本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
