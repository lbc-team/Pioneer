# 如何使用 Helius 获取新铸造的代币

## 介绍

Solana 的 memecoin 最近成为头条新闻，其中 [$WIF 突破 35 亿美元](https://x.com/DegenerateNews/status/1773433976746565802?s=20) ，[Boden 达到 3 亿美元](https://x.com/DegenerateNews/status/1773439634313208311?s=20)。[Popcat](https://x.com/DegenerateNews/status/1773302167983583279?s=20) 和 [Wen](https://x.com/DegenerateNews/status/1772800622149943721?s=20) 最近超过了 3.5 亿美元。[Slerf](https://www.coindesk.com/markets/2024/03/19/solana-meme-coin-slerf-clocks-higher-trading-volume-than-all-of-ethereum/) 在第一天内的交易量超过了所有基于以太坊的交易所。在去年 11 月 [BONK 的繁荣](https://decrypt.co/206788/bonk-goes-boom-solana-meme-token-soars-1700-30-days-hit-all-time-high)之后，Solana 上面可以看到比以往更多的新代币被创建。根据 [Solscan 数据](https://analytics.solscan.io/overview) ，过去三个月使用 Solana Program Library（SPL）标准铸造的新代币数量翻了一番。

![来源：Solcan 实时新铸造的 SPL 代币数据](https://img.learnblockchain.cn/attachments/migrate/1712115702634)

来源：[Real-time newly minted SPL Tokens data by Solcan](https://www.umbraresearch.xyz/writings/mev-on-solana#value-capture)

本文探讨了 Solana 上如何创建代币，SPL 代币是什么，以及如何监视新代币并使用 Helius 检索其元数据。

## Solana 上如何创建代币？

Solana 支持原生币 SOL 和其它代币。[Solana Program Library（SPL）](https://spl.solana.com/) 为 Solana 上的同质化和非同质化代币（NFT）定义了通用标准。与以太坊不同，以太坊为不同类型的非同质化（[ERC-721](https://ethereum.org/en/developers/docs/standards/tokens/erc-721/)）和同质化代币（[ERC-20](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)）设置了不同的标准，Solana Program Library 没有为不同的代币类型特别计算标准。

### Token Program（代币程序）

Solana 上同质化和非同质化代币（NFT）的标准实现是 [Token Program](https://spl.solana.com/token) 。它提供诸如创建新的代币类型和账户、转移和销毁代币等功能，以及[更多](https://spl.solana.com/token#operational-overview) 。Token Program 是[完整的](https://spl.solana.com/token#status) ，并且没有计划添加新功能。可能会有更改以修复重要/破坏性错误。

然而，Token Program 是有限的——开发人员必须分叉它以添加新功能，使交易变得更加复杂和风险。为了解决这个问题，Solana 推出了 [Token-2022](https://spl.solana.com/token-2022)，它是额外功能和增强功能的套件，如：
[代币元数据程序](https://developers.metaplex.com/token-metadata)

1. **铸造扩展**：机密转账、转账费用、关闭铸造、计息代币、不可转让代币、永久委托、转账挂钩、元数据指针、元数据。
2. **账户扩展**：入账转账需要备忘录、不可变所有权、默认账户状态、CPI 保护。

要了解有关 Token-2022 的更多信息，请参阅此[文章](https://www.helius.dev/blog/plug-and-play-token-extensions) 。

Solana 的 Token Program 允许我们创建铸造账户和代币账户。铸造账户包含有关代币的全局信息，而代币账户存储钱包和铸造账户之间的关系。你可以使用以下[代码或 spl-token-cli](https://spl.solana.com/token#reference-guide) 来创建代币。例如，如果已安装 [spl-token-cli](https://spl.solana.com/token#setup)，可以在命令行中运行以下命令来创建同质化代币：

```bash
spl-token create-token
```

### Token Metadata Program（代币元数据程序）

铸造账户包含某些数据属性，如当前代币供应量。然而，它们缺乏诸如名称和符号之类的标准化数据。为了解决这个问题，[Metaplex](https://developers.metaplex.com/) 引入了 [Token Metadata Program](https://developers.metaplex.com/token-metadata) 。该程序允许使用从铸造地址派生的[程序派生地址（PDAs）](https://solanacookbook.com/core-concepts/pdas.html#facts) 向同质化和非同质化代币附加附加数据。

![来源：Metaplex 创建的账户结构，由 Token Metadata Program 创建](https://img.learnblockchain.cn/attachments/migrate/1712115702631)

来源：[Metaplex](https://developers.metaplex.com/token-metadata) 创建的账户结构

Token Metadata Program 最初是为了简化在 Solana 上创建 NFT 而创建的。然而，它也适用于[半同质化代币（SFTs）](https://developers.metaplex.com/token-metadata#semi-fungible-tokens)，这是一种介于同质化和非同质化代币之间的代币。SFTs 最初表现得像同质化代币，这意味着它们可以与相同的代币进行交换，而不会对任何一方失去价值。

在使用后，它们失去了交换价值，并获得了可收藏的非同质化代币的属性。SFT 在游戏或元宇宙环境中作为一种独特类型的账户运作，附加了元数据以表示特征。在某些情况下，由于其效率、成本效益、灵活性和改进的交易安全性，SFT 比 NFT 更受青睐。

Token Metadata Program 还支持[可编程 NFTs（pNFTs）](https://developers.metaplex.com/token-metadata/pnfts)。这种新的资产标准允许创建者在特定操作上定义自定义规则，并更细粒度地委托给第三方机构。无论 pNFT 是否被委托，其代币账户始终在 SPL Token Program 上被冻结。

这确保没有人可以通过直接与 SPL Token Program 交互来绕过 Token Metadata Program。

## 监视新代币

要监视新铸造的代币，我们将设置一个 [webhook](https://docs.helius.dev/webhooks-and-websockets/what-are-webhooks)。Webhook 允许你监听链上事件，并在发生这些事件时触发特定操作。我们将配置我们的 webhook 以监听来自[代币元数据程序](https://developers.metaplex.com/token-metadata)的 **TOKEN_MINT** 交易类型。目前支持此交易类型的来源有（其它来源将被标记为 **“UNKNOWN”**）：

```
 "TOKEN_MINT": [   "CANDY_MACHINE_V1",   "ATADIA",   "SOLANA_PROGRAM_LIBRARY" ]
```

可以使用 [Helius Dashboard](https://dev.helius.xyz/dashboard/app) 创建 webhook，也可以使用 [API 参考](https://dev.helius.xyz/dashboard/app)进行编码。要通过 [Dashboard](https://dev.helius.xyz/) 创建 webhook，转到左侧面板的 **Webhooks** 部分，然后单击 **New Webhook**。然后，通过提供详细信息来配置 webhook，例如：
1. **网络:** 主网/开发网
2. **Webhook 类型**: 你可以选择增 Enhanced（增强型）/Raw（原始）/Discord。如果选择 Discord，你必须提交 Webhook URL，你的通知将由机器人格式化并直接发送。你可以参考[此处](https://dev.helius.xyz/)获取 Discord 机器人的 Webhook URL。如果选择 Raw，你将无法指定交易类型。
3. **交易类型:** 选择 **TOKEN_MINT** 以监听新铸造的代币。你可以在[此处](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)找到程序支持的其它交易类型。
4. **Webhook URL:** 添加将接收通知的端点（例如，Discord 机器人，网站等）。
5. **身份验证标头:** 输入身份验证标头以将 POST 请求传递到你的 Webhook。请注意，此为可选项。
6. **账户地址:** 在此处添加 Token Metadata Program 地址: **metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s**。对于其它情况，如果需要，可以添加多个账户地址。如果希望从特定用户那里收到通知，可以包括他们的地址。

![设置 Webhook 以监听新代币铸造](https://img.learnblockchain.cn/attachments/migrate/1712115702626)

设置 Webhook 以监听新代币铸造

确认后，你的 Webhook 将准备就绪，并且可以根据你的 **Webhook URL** 构建适当的前端。在这里，我们选择了 **Discord** 作为 **Webhook 类型**，并提供了 Discord 机器人的 **Webhook URL**，因此我们无需编写 Discord 机器人。我们将收到此类通知:

![Discord 机器人发送的新代币铸造通知](https://img.learnblockchain.cn/attachments/migrate/1712115702638)

Discord 机器人发送的新代币铸造通知

## 检索代币元数据

你可以使用代币 ID（代币的铸造地址）来获取特定代币的元数据。解析通过**增强型 Webhook** 发送的 JSON 通知（当 Webhook 类型设置为增强型时）。铸造地址可以在 transferTokens 数组的第一个对象中的 "mint" 字段中找到。一旦你有了代币 ID，你可以使用 [DAS API](https://docs.helius.dev/compression-and-das-api/digital-asset-standard-das-api) 提供的 [getAsset](https://docs.helius.dev/compression-and-das-api/digital-asset-standard-das-api/get-asset) 方法来检索有关代币的其它信息。

例如，你可以使用 [getAsset](https://docs.helius.dev/compression-and-das-api/digital-asset-standard-das-api/get-asset) 方法来获取有关 Jito Staked SOL (JitoSOL) 的信息:

```javascript
解释

const url = `https://mainnet.helius-rpc.com/?api-key=<api_key>`

const getAsset = async () => {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      jsonrpc: '2.0',
      id: 'my-id',
      method: 'getAsset',
      params: {
        id: 'J1toso1uCk3RLmjorhTtrVwY9HJ7X8V9yYac6Y7kGCPn',
        displayOptions: {
	    showFungible: true //return details about a fungible token
	}
      },
    }),
  });
  const { result } = await response.json();
  console.log("Asset: ", result);
};
getAsset();
```

你可以在我们的 [文档](https://docs.helius.dev/compression-and-das-api/digital-asset-standard-das-api/get-asset) 中找到该方法的更多示例以及请求和响应的完整模式。

## 结论

在本文中，我们了解了如何在 Solana 上创建代币，SPL 代币是什么，以及如何通过设置 Webhook 和通过 Helius 获取它们的元数据来监视新代币。如果你需要任何帮助或支持，请随时在 [Discord](https://discord.gg/raeYgMjtDB) 上联系我们！

请务必在下方输入你的电子邮件地址，以便你不会错过 Solana 的最新更新。准备深入了解吗？探索 [Helius 博客](https://www.helius.dev/blog)上的最新文章，并继续你的 Solana 之旅。

## 资源

- [Token-2022 Program](https://spl.solana.com/token-2022)
- [Token Metadata Program](https://developers.metaplex.com/token-metadata)
- [创建 Webhook](https://docs.helius.dev/webhooks-and-websockets/api-reference/create-webhook)
- [DAS API](https://docs.helius.dev/compression-and-das-api/digital-asset-standard-das-api)