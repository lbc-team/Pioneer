原文链接：https://medium.com/taipei-ethereum-meetup/uniswap-v3-features-explained-in-depth-178cfe45f223

# 深入解读 Uniswap v3 新特性

![img](https://img.learnblockchain.cn/attachments/2022/05/khrn9Nwd628da1da1f812.png)

图片来源: https://uniswap.org/blog/uniswap-v3/

# 提纲


```
0. 序言
1. Uniswap & AMM 概览
2. 报价区间Ticks    
3. 集中了的流动性
4. 范围订单: 可逆的限价单
5. v3的影响
6. 结论
```


# 0. 序言

最近， [Uniswap V3的发布](https://uniswap.org/blog/uniswap-v3/)无疑是DeFi世界中，最令人激动的新闻。🔥🔥🔥

当大多数人的谈论聚焦在v3带给市场的潜在冲击时， 如何使用精妙技术实现那些令人惊叹特性的讨论，却极为罕见。 那些特性包含了集中流动性，类似限价单的范围订单等。

既然之前我已经解读过了Uniswap v1 & v2 (如果你能读中文，链接在此[v1](https://medium.com/taipei-ethereum-meetup/uniswap-explanation-constant-product-market-maker-model-in-vyper-dff80b8467a1) & [v2](https://medium.com/taipei-ethereum-meetup/uniswap-v2-implementation-and-combination-with-compound-262ff338efa)), 因此我也责无旁贷，继续为大家解读v3!

本文将基于[官方白皮书](https://uniswap.org/whitepaper-v3.pdf)和网站上的例子，带领各位读者走上理解Uniswap v3的旅程。 我们不会涉及太多代码，因此无需您有工程师背景； 文章中的数学仅仅限于高中程度，因而也无需您是数学出身。所以您可以完全理解接下来的内容。😊

如果您读完全文却依然不得要领， 欢迎随时给我回复🙏 ！


以后将会有另一篇文章聚焦于代码库。 不过现在先让我们准备好背景音乐，开始这段旅程。

背景音乐视频链接：https://www.youtube.com/watch?v=051C0FiNX5U

# 1. Uniswap & AMM 概述

在深入之前，我们首先回顾一下与传统的订单簿交易所相比，Uniswap具有的独特之处。

Uniswap v1 和v2 都属于自动做市商(AMM)的某种应用。 它们使用 **`x * y = k`** 的固定乘积等式，其中`x` 和 `y` 分别代表同一个池中代币 X 和代币 Y 的**数量**， 而`k`则代表一个**常数**。


Comparing to order book exchanges, AMMs, such as the previous versions of Uniswap, offer quite a distinct user experience:

与订单簿交易所相比， 使用了AMM机制的Uniswap v1 & v2， 为使用者提供了独特的体验:


- AMM能为两种代币之间的相互兑换提供报价，所以AMM的用户始终是价格的接受者，而订单簿交易所的用户既可以是价格提供者，也可以是价格接受者。

- Uniswap 和大多数 AMM一样，能提供无限的流动性¹，而订单簿交易所则无法做到这一点。 事实上，Uniswap v1 和 v2 在[0,∞]²的价格范围内，都能提供了流动性。

- Uniswap 和大多数 AMM一样， 都有价格滑点³，这是由于AMM的定价机制导致的。但是对于订单簿交易所，如果交易订单能在一个tick的时间内完成，那么成交价格并不一定会有滑点。

![img](https://img.learnblockchain.cn/attachments/2022/05/G4YoRmdv628da4de53891.png)

在订单簿中,  每个价格(无论是红色还是绿色)都是一个tick.
图片来源: https://ftx.com/trade/BTC-PERP

*¹ 尽管价格随着时间的推移会变得更差,mStable等常数和的AMM并不具有无限的流动性*  
(译者注:mStable 是一个AMM,参见 https://mstable.app/#/musd/swap)

*² 价格范围事实上可以扩展到[-∞,∞],  不过大多数情况下价格不可能为负值.* 
(译者注: 事实上WTI原油期权价格就曾经短暂为负值)

³ *常数和AMM不会产生价格滑点*


# 2. Tick

> Uniswap v3所有的创新都始于Tick

不熟悉tick的朋友请看

![img](https://img.learnblockchain.cn/attachments/2022/05/W8yUrLrW628da50d21dfc.png)

来源: https://www.investopedia.com/terms/t/tick.asp

v3通过**将价格范围 [0,∞]** **分成无数个细粒度的ticks**，使得在v3上发生的交易极其类似于与在订单簿交易所发生的交易. 它们只有三个不同之处:

- **每个tick的价格范围由系统预定义**，而非由用户决定。

- 在一个tick区间内发生的交易**仍然遵循 AMM 的定价等式**.  一旦价格跨越了该tick, 就需要更新定价等式的值。

- 落在价格范围内的不同订单,成交价可以是范围内任意一个价格，而不像在订单簿交易所那样,只能以相同价格成交。

通过对tick的这个设计，Uniswap v3拥有了AMM 和订单簿交易所的大部分优点！ 💯💯💯

## 那么，一个tick对应的价格区间是如何决定的呢？

事实上, 这个问题与上面关于tick的解释,有一些联系：*交易价格高于 1 美元的股票的最小报价(tick)大小是一美分*。

传统上1个tick被看做等于1美分, 其潜在含义是1美分（1 美元的 1%）是报价变化的1个**基点**，例如：`1.02 — 1.01 = 0.01`。(译者注: 此处原为0.1,应为0.01)

Uniswap v3 也采用了类似的想法：与上个/下个价格相比，价格变化应该总被当做 **0.01% = 1 个基点**。

但是请注意,这里不同之处是，传统上的基点是**绝对值** 0.01，这意味着价格变化是用**减法**定义的，而在v3中，基点是**百分比** 0.01 **%**，用**除法**定义。


如何设置tick的价格范围⁴,请看：

![img](https://img.learnblockchain.cn/attachments/2022/05/6SQrc0NI628da5738cf1f.png)

图片来源: https://uniswap.org/whitepaper-v3.pdf

根据如上等式，可以用 **索引** [i, i+1]的形式来记录 tick/价格范围，而不是一些疯狂的数字，例如 `1.0001¹⁰⁰ = 1.0100496621`。

由于每个价格都是序列中前一个价格的 1.0001倍，因此价格变化比率始终为“1.0001 — 1 = 0.0001 = 0.01%”。

例如, 当i=1, `p(1) = 1.0001`; 当i=2, `p(2) = 1.00020001`.

```
p(2) / p(1) = 1.00020001 / 1.0001 = 1.0001
```
大家看到 传统基点是1美分（=1美元的1%）与 Uniswap v3基点是0.01%之间的联系了吗？

![img](https://img.learnblockchain.cn/attachments/2022/05/W06dvua4628da5b8c516e.gif)

图片来源: https://tenor.com/view/coin-master-cool-gif-19748052

*但是，先生，价格真的足够细分吗？有许多价格低于 0.000001 美元的垃圾币。这样的价格也会被涵盖吗？*

## **价格范围: 最大值 & 最小值**

要了解v3的tick是否涵盖了非常小的价格，我们必须通过查看技术说明书,来确定v3的最大和最小价格范围：在 `UniswapV3Pool.sol`中有一个`int24 tick`状态变量。

![img](https://img.learnblockchain.cn/attachments/2022/05/3AWCesIB628da5dd1314f.png)

图片来源: https://uniswap.org/whitepaper-v3.pdf

使用带符号整数 `int` 而不是 `uint` 的原因是:负幂表示 **价格小于1 但大于0。**

24位覆盖了 `1.0001 ^ (2²³ — 1)` 和 `1.0001 ^ -(2)²³` 之间的价格范围。即使是谷歌也无法计算出这些数字，所以请允许我提供较小的值,用以大致了解整个价格范围:

```
1.0001 ^ (2¹⁸) = 242,214,459,604.341
```
```
1.0001 ^ -(2¹⁷) = 0.000002031888943
```

可以确定地说，使用 `int24` 类型定义的价格范围, 可以涵盖这个世界中超过99.9%的资产价格 👌
*⁴ 基于技术实现的考虑, 等式两边都添加了一个平方根.*

那么,如何找出一个价格对应的那个tick呢？

## 从价格反推Tick索引

问题的答案很简单，既然我们知道 `p(i) = 1.0001^i`，因此只需在等式两边各取一个底数为 1.0001 的对数⁴:

![img](https://img.learnblockchain.cn/attachments/2022/05/eWXrzsvS628da6a06b4d3.png)

图片来源: https://www.codecogs.com/latex/eqneditor.php

让我们来试一试，假设我们想找出 *1000000 的tick索引*

![img](https://img.learnblockchain.cn/attachments/2022/05/Pm9jqfXT628da6cc00697.png)

图片来源: https://ncalculators.com/number-conversion/log-logarithm-calculator.htm

此时, `1.0001¹³⁸¹⁶² = 999,998.678087146`. 哈哈!

*⁵ 这个公式也略有修改,以便适应实际的技术实现。

# 3. 集中流动性

既然我们知道了tick和价格范围是如何计算的，那么接下来看看如何在一个tick定义的价格区间内执行订单，什么是集中流动性, 以及它如何**提高了资本效率**, 使得v3竟能与专为稳定币设计的DEX（去中心化交易所)竞争，例如 [Curve]( https://curve.fi/).

集中流动性,意味着LP（流动性提供者）可以按照自己的意愿,向**任意价格范围/tick**提供流动性. 无疑这将导致:流动性在ticks中的分配变得不再平衡。

由于每个tick拥有的流动性深度(译者注:即流动性值L)不同，相应的定价等式 `x * y = k` 也不再相同！

![img](https://img.learnblockchain.cn/attachments/2022/05/oaZpCR7I628da6fbc1f01.png)

每个tick将拥有它自己的流动性深度. 图片来源: https://uniswap.org/blog/uniswap-v3/

嗯... 描述一个抽象的事物时,举个栗子特有用!

假设最初的定价函数等式为`100(x) * 1000(y) = 100000(k)`, X代币的价格因此为`1000 / 100 = 10`，并且我们位于一个任意的价格范围 [9.08, 11.08 ].

如果价格范围 [11.08, 13.08] 的流动性深度与 [9.08, 11.08] 相同，则当价格从10变为11.08（两个刻度之间的边界时，我们无需修改定价函数。

此时新tick(译者注 :即价格范围[11.08,13.08]) 的定价等式是`1052.63 * 95 = 100000`, 因此X的价格变成了 `1052.63 / 95 = 11.08` 

但是，如果新价格范围 [11.08, 13.08] 的流动性是当前[9.08, 11.08] 的**两倍**，则`x`和`y`的余额应该**翻倍**，等式变为`2105.26 * 190 = 400000`，即 `(1052.63 * 2) * (95 * 2) = (100000 * 2 * 2)`。


从上面的例子中,我们可以有以下两点观察:


- 交易始终遵循定价等式 x * y = k. 一旦价格超过当前的价格范围/tick，流动性/等式 都必须更新。

- `√(x * y) = √k = L` is how we represent the **liquidity**, as I say the liquidity of `x * y = 400000` is two times the liquidity of `x * y = 100000`, as `√(400000 / 100000) = 2`.

- `√(x * y) = √k = L` 是我们对**流动性**的定义. 如上述, `x * y = 400000` 的流动性是 `x * y = 100000 的两倍`，即`√(400000 / 100000) = 2`


更重要的是， v1 和 v2 上的流动性总是分布在 [0,∞] , 而v3 上的流动性可以集中在特定的价格范围内，从而让[流动性提供者]可以**更高的资本效率** 获得交易费分成**！**

假设我提供了[1200, 2800] 范围内的流动性，那么我的资本效率将比范围 [0,∞] 的 v2 高 4.24 倍 😮 
这里有一个 [资本效率比较计算器](https://uniswap. org/blog/uniswap-v3/)，你一定要试试看！

![img](https://img.learnblockchain.cn/attachments/2022/05/7vSJycrU628da7346b4d8.png)

图片来源: https://uniswap.org/blog/uniswap-v3/

值得注意的是，在 Uniswap 之前，**Kyper**也提出并实施了集中流动性的概念，他们称之为[**自动价格储备**](https://blog.kyber.network/introducing- the-automated-price-reserve-77d41ed1aa70）。⁵

*⁶ 感谢* [*Yenwen Feng*](https://medium.com/u/1c7a5eea11a8?source=post_page-----178cfe45f223--------------------------------) *提供了此信息.*



# 4.范围订单: 可逆的限价单

*（本节内容更新于5月8日，之前描述的内容中,排除了最后三种也是范围订单情景的做法是错误的。）*

如上一节所述，v3的LP可以根据自己的意愿为任何价格范围/tick提供流动性。 **LP在v3上提供流动性**的行为就被称为（创建）**范围订单**。

根据**当前价格**和**目标价格范围**的不同关系，存在三种情况：

1. 当前价格属于目标价格范围
2. 当前价格 < 目标价格范围
3. 当前价格 > 目标价格范围

在提供流动性时, LP面临这三种场景, 在是否需要提供**两种代币或仅一种代币** 以及 **需要/被允许（哪个)代币多少数量** 上, 会存在不同之处。

## 场景1：当前价格属于目标价格范围

情况 1 可以进一步分为两种情况：当前价格是或者不是目标价格范围的**中心**。

如果当前价格恰好位于目标价格范围的中心（例如当价格范围为[8, 12] 时，当前价格 = 10），则它与之前uniswap版本(译者注:v1,v2)的流动性提供机制完全相同： 此时LP提供 **具有等同价值的两种代币数量**（`价值= 数量 * 价格`）。

如果当前价格不是价格区间的中心，那么LP 仍然需要分别提供两种代币的流动性，而每个代币的**数量**将取决于当前价格与价格范围端点的距离，这将在下一节进行解释（虽然没有明确说明）。

对应这种情况, 坊间有一个类似的产品: **网格交易**，这是一个非常强大的投资工具，适用于**整合**。如果你不知道什么是网格交易？看[Binance的解释](https://www.binance.com/en/support/faq/f4c453bab89648beb722aa26634120c3).关于这个主题(译者注:网格交易),我们不会再多做涉及.

事实上，Uniswap v1和v2 的 LP就是在做**网格交易**，只不过交易的范围为 [0,∞]，基准价格是**提供流动性时的价格**。


## 场景2 & 3：当前价格不属于目标价格范围内

与场景1中,LP需要为**两种代币** 都提供流动性不同. 在场景2 和场景 3 中, LP **只需要/被允许[提供]/**两种代币中的一种**。

要理解上述做法的原因，我们首先回顾一下 Uniswap 是如何通过等式`x * y = k`定价的，此时`\x`和`y`代表的是X和Y代币各自的**数量**,`k`表示**常量**。

X相对于Y 的价格是 `y / x`，这意味着 1 单位 X可以得到多少Y.反之亦然,Y 相对于 X 的价格是 `x / y`。

要使 X 的价格上涨，`y` 必须增加, 而 `x` 相应地必须减少。

了解了定价机制，现在是栗子时间！

Say an LP plans to place liquidity in the price range [15.625, 17.313], higher than the current price of X `10`, when `100(x) * 1000(y) = 100000(k)`, which is **Case 2**.

例如场景2中, LP计划将流动性置于价格区间 [15.625, 17.313]，高于X当前的价格 `10` 对应等式`100(x) * 1000(y) = 100000(k)`成立.

- X的价格为`1250 / 80 = 15.625`, 对应等式`80 * 1250 = 100000`成立

- X的价格为`1315.789 / 76 = 17.313`, 对应等式 `76 * 1315.789 = 100000`成立


如果现在 X 的价格达到 15.625，那么X 的价格进一步上涨的唯一途径, 就是进一步增加 `y` 并减少 `x`，这意味着需要**用一定数量的 X 换取 Y**。

因此，为了提供 [15.625, 17.313] 范围内的流动性，LP **只需要准备** `80 - 76 = 4` 数量的 **X**。(译者注:80和76是上述场景中15.625和17.713对应的X数量) 
如果价格超过 17.313，LP的所有 `4`个X 都被换成 `1315.789 — 1250 = 65.798`个**Y** (译者注:见上述等式)，此后LP由于X流动性被抽干,因此与流动性池子不再有任何关系.

What if the price stays in the range? It’s exactly what LPs would love to see, as they can earn **swapping fees** for all transactions in the range! Also, the balance of X will swing between [76, 80] and the balance of Y between [1250, 1315.789].

如果价格保持在该价格范围内怎么办？这正是LP希望看到的. 因为他们可以从范围内的所有交易中赚取**交易费**！此时，X的余额将在[76, 80] 之间摆动，Y的余额将在 [1250, 1315.789] 之间摆动。

可能并不显而易见,但是上述例子确实展现了一个有趣的事实：当你提供一种代币的流动性时，**只有当该代币变得更有价值时，该代币才会被[外部套利者]兑换为价值更低的其他代币**。

……唔？

请记住，如果LP在[15.625, 17.313]价格范围中提供了`4`个X，那么只有当X的价格**从15.625上升**到17.313时，`4`个X才会逐渐被兑换成价值较低的Y！

This is the reason why in Cases 2 & 3 only one of the two tokens is required/allowed when providing liquidity: in fact, LPs providing liquidity is essentially **providing a token for others to exchange when that token becomes more valuable**!

What if the price of X drops back to 15.625 immediately after reaching 17.313? As X becomes less valuable, others are going to exchange Y for X, which can eventually make the `65.798` Y (previously swapped from `4` X) be swapped back into `4` X.

The below image illustrates the scenario of DAI/USDC pair with a price range of [1.001, 1.002] well: the pool is always composed **entirely of one token on both sides** of the tick, while in the middle 1.001499⁷ is of both tokens.

![img](https://img.learnblockchain.cn/attachments/2022/05/rPPdTC0A628da7c916a09.png)

Image source: https://uniswap.org/blog/uniswap-v3/

Similarly, to provide liquidity in a price range < current price, which is **Case 3**, an LP has to prepare **a certain amount of Y** for others to exchange Y for X within the range.

To wrap up such an interesting feature, we know that:

1. Only one token is required for Cases 2 & 3, while both tokens are required for Case 1.
2. Only when the current price is within the range of the range order can LP earn trading fees. This is the main reason why most people believe LPs of v3 have to **monitor the price** **more actively** to maximize their income, which also means that **LPs of v3 have become arbitrageurs** 🤯

I will be discussing more the impacts of v3 in **5. Impacts of v3**.

*⁷* `1.001499988 = √(1.0001 * 1.0002)` *is the geometric mean of* `1.0001` *and* `1.0002`*. The implication is that the geometric mean of two prices is the average execution price within the range of the two prices.*

## Reversible limit orders

As the example in the last section demonstrates, if there is `4` X in range [15.625, 17.313], the `4` X will be completely converted into `65.798` Y when the price goes over 17.313.

We all know that a price can stay in a wide range such as [10, 12] for quite some time, while it’s unlikely so in a narrow range such as [15.6, 15.7].

Thus, if an LP provides liquidity in [15.6, 15.7], we can expect that once the price of X goes over 15.6 and immediately also 15.67, and does not drop back, all X are then forever converted into Y.

The concept of **having a targeted price and the order will be executed after the price is crossed** is exactly the concept of **limit orders**! The only difference is that if the range of a range order is not narrow enough, it’s highly possible that the conversion of tokens will be **reverted** once the price falls back to the range.

Thus, providing liquidity on v3, namely range orders, are essentially **fee-earning reversible limit orders**.

> **Update on May 8**
> The following explanation for the range of range orders is far from the real implementation constraint. As the narrowness of a range is designed to be depenedent on the transaction fee ratio, range orders on Uniswap v3 can be quite wide.

As price ranges follow the equation `p(i) = 1.0001 ^ i`, the range can be quite narrow and a range order can thus effectively serve as a limit order:

- When `i = 27490`, `1.0001²⁷⁴⁹⁰ = 15.6248`.⁸
- When `i = 27491`, `1.0001²⁷⁴⁹¹ = 15.6264`.⁸

A range of `0.0016` is not THAT narrow but can certainly satisfy most limit order use cases!

*⁸ As mentioned previously in note #4, there is a square root in the equation of the price and index, thus the numbers here are for explanation only.*

# 5. Impacts of v3

Higher capital efficiency, LPs become arbitrageurs… as v3 has made tons of radical changes, I’d like to summarize my personal takes of the impacts of v3:

1. Higher capital efficiency makes one of the most frequently considered indices in DeFi: **TVL**, total value locked, becomes **less meaningful**, as 1$ on Uniswap v3 might have the same effect as 100$ or even 2000$ on v2.
2. **The ease of spot exchanging** between spot exchanges used to be a huge advantage of spot markets over derivative markets. As LPs will take up the role of arbitrageurs and arbitraging is more likely to happen on v3 itself other than between DEXs, this gap is narrowed … to what extent? No idea though.
3. **LP strategies** and **the aggregation of NFT** of Uniswap v3 liquidity token are becoming the blue ocean for new DeFi startups: see [Visor](https://www.visor.finance/) and [Lixir](https://lixir.finance/). In fact, this might be the **turning point for both DeFi and NFT**: the two main reasons of blockchain going mainstream now come to the alignment of interest: solving the $$ problem.
4. In the right venue, which means a place where transaction fees are low enough, such as Optimism, we might see **Algo trading firms** coming in to share the market of designing LP strategies on Uniswap v3, as I believe Algo trading is way stronger than on-chain strategies or DAO voting to add liquidity that sort of thing.
5. After reading this article by [Parsec.finance](http://parsec.finance/): [**The Dex to Rule Them All**](https://research.parsec.finance/posts/uniswap-v3-vs-LOB), I cannot help but wonder: maybe there is going to be centralized crypto exchanges adopting v3’s approach. The reason is that since orders of LPs in the same tick are executed **pro-rata**, the endless front-running speeding-competition issue in the Algo trading world, to some degree, is… solved? 🤔

Anyway, personal opinions can be biased and seriously wrong. I’m merely throwing out a sprat to catch a whale. Having a different voice? Leave your comment down below!

# 6. Conclusion

That was kinda tough, isn’t it? Glad you make it through here 🥂

There are actually many more details and also a huge section of Oracle yet to be covered. However, since this article is more about features and targeting normal DeFi users, I’ll leave those to the next one; hope there is one :)

If you have any doubt or find any mistake, please feel free to reach out to me and I’d try to reply AFAP.

Stay tuned and in the meantime let’s wait and see how Uniswap v3 is again pioneering the innovation of DeFi!

Thanks toShao



nks toShao



