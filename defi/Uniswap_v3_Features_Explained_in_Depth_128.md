原文链接：https://medium.com/taipei-ethereum-meetup/uniswap-v3-features-explained-in-depth-178cfe45f223

# Uniswap v3 Features Explained in Depth
# 深入理解 Uniswap v3 

![img](https://img.learnblockchain.cn/attachments/2022/05/khrn9Nwd628da1da1f812.png)

Image source: https://uniswap.org/blog/uniswap-v3/

# Outline


```
0. 序言
1. Uniswap & AMM 概览
2. 瞬间标记 Ticks    
3. 集中了的流动性
4. 范围订单: 可反转的限价单
5. v3的影响
6. 结论
```


# 0. 序言

The [announcement of Uniswap v3](https://uniswap.org/blog/uniswap-v3/) is no doubt one of the most exciting news in the DeFi place recently 🔥🔥🔥

[Uniswap V3的发布](https://uniswap.org/blog/uniswap-v3/)无疑是最近DeFi世界最令人激动的新闻。🔥🔥🔥

While most have talked about the impact v3 can potentially bring on the market, seldom explain the delicate implementation techniques to realize all those amazing features, such as concentrated liquidity, limit-order-like range orders, etc.

Since I’ve covered Uniswap v1 & v2 (if you happen to know Mandarin, here are [v1](https://medium.com/taipei-ethereum-meetup/uniswap-explanation-constant-product-market-maker-model-in-vyper-dff80b8467a1) & [v2](https://medium.com/taipei-ethereum-meetup/uniswap-v2-implementation-and-combination-with-compound-262ff338efa)), there’s no reason for me to not cover v3 as well!

Thus, this article aims to guide readers through Uniswap v3, based on their [official whitepaper](https://uniswap.org/whitepaper-v3.pdf) and examples made on the announcement page. However, one needs not to be an engineer, as **not many codes are involved**, nor a math major, as **the math involved is definitely taught in your high school**, to fully understand the following content 😊

If you really make it through but still don’t get shxt, feedbacks are welcomed! 🙏

There should be another article focusing on the codebase, so stay tuned and let’s get started with some background noise!

视频链接：https://www.youtube.com/watch?v=051C0FiNX5U

# 1. Uniswap & AMM recap

Before diving in, we have to first recap the uniqueness of Uniswap and compare it to traditional order book exchanges.

Uniswap v1 & v2 are a kind of AMMs (automated market marker) that follow the constant product equation **`x * y = k`**, with `x` & `y` stand for the **amount** of two tokens X and Y in a pool and `k` as a **constant**.

Comparing to order book exchanges, AMMs, such as the previous versions of Uniswap, offer quite a distinct user experience:

- AMMs have pricing functions that offer the price for the two tokens, which make their users always price takers, while users of order book exchanges can be both makers or takers.
- Uniswap as well as most AMMs have infinite liquidity¹, while order book exchanges don’t. The liquidity of Uniswap v1 & v2 is provided throughout the price range [0,∞]².
- Uniswap as well as most AMMs have price slippage³ and it’s due to the pricing function, while there isn’t always price slippage on order book exchanges as long as an order is fulfilled within one tick.

![img](https://img.learnblockchain.cn/attachments/2022/05/G4YoRmdv628da4de53891.png)

In an order book, each price (whether in green or red) is a tick. Image source: https://ftx.com/trade/BTC-PERP

*¹ though the price gets worse over time; AMM of constant sum such as mStable does not have infinite liquidity*

*² the range is in fact [-∞,∞], while a price in most cases won’t be negative*

³ *AMM of constant sum does not have price slippage*

# 2. Tick

> The whole innovation of Uniswap v3 starts from ticks.

For those unfamiliar with what is a tick:

![img](https://img.learnblockchain.cn/attachments/2022/05/W8yUrLrW628da50d21dfc.png)

Source: https://www.investopedia.com/terms/t/tick.asp

By **slicing the price range [0,∞]** **into numerous granular ticks**, trading on v3 is highly similar to trading on order book exchanges, with only three differences:

- The **price range of each tick is predefined** by the system instead of being proposed by users.
- Trades that happen within a tick **still follows the pricing function of the AMM**, while the equation has to be updated once the price crosses the tick.
- Orders can be executed with any price within the price range, instead of being fulfilled at the same one price on order book exchanges.

With the tick design, Uniswap v3 possesses most of the merits of both AMM and an order book exchange! 💯💯💯

## So, how is the price range of a tick decided?

This question is actually somewhat related to the tick explanation above: *the minimum tick size for stocks trading above 1$ is one cent*.

The underlying meaning of a tick size traditionally being one cent is that one cent (1% of 1$) is the **basis point** of price changes between ticks, ex: `1.02 — 1.01 = 0.1`.

Uniswap v3 employs a similar idea: compared to the previous/next price, the price change should always be **0.01% = 1 basis point**.

However, notice the difference is that the traditional basis point is in **absolute value** 0.1, which means the price change is defined with **subtraction**, while here in v3 the basis point is in **percentage** 0.1**%**, which is defined with **division**.

This is how price ranges of ticks are decided⁴:

![img](https://img.learnblockchain.cn/attachments/2022/05/6SQrc0NI628da5738cf1f.png)

Image source: https://uniswap.org/whitepaper-v3.pdf

With the above equation, the tick/price range can be recorded in the **index** form [i, i+1], instead of some crazy numbers such as `1.0001¹⁰⁰ = 1.0100496621`.

As each price is the multiplication of 1.0001 of the previous price, the price change is always `1.0001 — 1 = 0.0001 = 0.01%`.

For example, when i=1, `p(1) = 1.0001`; when i=2, `p(2) = 1.00020001`.

```
p(2) / p(1) = 1.00020001 / 1.0001 = 1.0001
```

See the connection between the traditional basis point 1 cent (=1% of 1$) and Uniswap v3’s basis point 0.01%?

![img](https://img.learnblockchain.cn/attachments/2022/05/W06dvua4628da5b8c516e.gif)

Image source: https://tenor.com/view/coin-master-cool-gif-19748052

*But sir, are prices really granular enough? There are many shitcoins with prices less than 0.000001$. Will such prices be covered as well?*

## **Price range: max & min**

To know if an extremely small price is covered or not, we have to figure out the max & min price range of v3 by looking into the spec: there is a `int24 tick` state variable in `UniswapV3Pool.sol`.

![img](https://img.learnblockchain.cn/attachments/2022/05/3AWCesIB628da5dd1314f.png)

Image source: https://uniswap.org/whitepaper-v3.pdf

The reason for a signed integer `int` instead of an `uint` is that negative power represents **prices less than 1 but greater than 0.**

24 bits can cover the range between `1.0001 ^ (2²³ — 1)` and `1.0001 ^ -(2)²³`. Even Google cannot calculate such numbers, so allow me to offer smaller values to have a rough idea of the whole price range:

```
1.0001 ^ (2¹⁸) = 242,214,459,604.341
```
```
1.0001 ^ -(2¹⁷) = 0.000002031888943
```


I think it’s safe to say that with a `int24` the range can cover > 99.99% of the prices of all assets in the universe 👌

*⁴ For implementation concern, however, a square root is added to both sides of the equation.*

How about finding out which tick does a price belong to?

## Tick index from price

The answer to this question is rather easy, as we know that `p(i) = 1.0001^i`, simply takes a log with base 1.0001 on both sides of the equation⁴:

![img](https://img.learnblockchain.cn/attachments/2022/05/eWXrzsvS628da6a06b4d3.png)

Image source: https://www.codecogs.com/latex/eqneditor.php

Let’s try this out, say we wanna find out the tick index of *1000000.*

![img](https://img.learnblockchain.cn/attachments/2022/05/Pm9jqfXT628da6cc00697.png)

Image source: https://ncalculators.com/number-conversion/log-logarithm-calculator.htm

Now, `1.0001¹³⁸¹⁶² = 999,998.678087146`. Voila!

*⁵ This formula is also slightly modified to fit the real implementation usage.*

# 3. Concentrated liquidity

Now that we know how ticks and price ranges are decided, let’s talk about how orders are executed in a tick, what is concentrated liquidity and how it enables v3 to compete with stablecoin-specialized DEXs (decentralized exchange), such as [Curve](https://curve.fi/), by improving the **capital efficiency**.

Concentrated liquidity means LPs (liquidity providers) can provide liquidity to **any price range/tick** at their wish, which causes the liquidity to be imbalanced in ticks.

As each tick has a different liquidity depth, the corresponding pricing function `x * y = k` also won’t be the same!

![img](https://img.learnblockchain.cn/attachments/2022/05/oaZpCR7I628da6fbc1f01.png)

Each tick has its own liquidity depth. Image source: https://uniswap.org/blog/uniswap-v3/

Mmm… examples are always helpful for abstract descriptions!

Say the original pricing function is `100(x) * 1000(y) = 100000(k)`, with the price of X token `1000 / 100 = 10` and we’re now in an arbitrary price range [9.08, 11.08].

If the liquidity of the price range [11.08, 13.08] is the same as [9.08, 11.08], we don’t have to modify the pricing function if the price goes from 10 to 11.08, which is the boundary between two ticks.

The price of X is `1052.63 / 95 = 11.08` when the equation is `1052.63 * 95 = 100000`.

However, if the liquidity of the price range [11.08, 13.08] is **two times** that of the current range [9.08, 11.08], balances of `x` and `y` should be **doubled**, which makes the equation become `2105.26 * 190 = 400000`, which is `(1052.63 * 2) * (95 * 2) = (100000 * 2 * 2)`.

We can observe the following two points from the above example:

- Trades always follow the pricing function x * y = k, while once the price crosses the current price range/tick, the liquidity/equation has to be updated.
- `√(x * y) = √k = L` is how we represent the **liquidity**, as I say the liquidity of `x * y = 400000` is two times the liquidity of `x * y = 100000`, as `√(400000 / 100000) = 2`.

What’s more, compared to liquidity on v1 & v2 is always spread across [0,∞], liquidity on v3 can be concentrated within certain price ranges and thus results in **higher** **capital efficiency** from traders’ swapping fees**!**

Let’s say if I provide liquidity in the range [1200, 2800], the capital efficiency will then be 4.24x higher than v2 with the range [0,∞] 😮 There’s a [capital efficiency comparison calculator](https://uniswap.org/blog/uniswap-v3/), make sure to try it out!

![img](https://img.learnblockchain.cn/attachments/2022/05/7vSJycrU628da7346b4d8.png)

Image source: https://uniswap.org/blog/uniswap-v3/

It’s worth noticing that the concept of concentrated liquidity was proposed and already implemented by **Kyper**, prior to Uniswap, which is called [**Automated Price Reserve**](https://blog.kyber.network/introducing-the-automated-price-reserve-77d41ed1aa70) in their case.⁵

*⁶ Thanks to* [*Yenwen Feng*](https://medium.com/u/1c7a5eea11a8?source=post_page-----178cfe45f223--------------------------------) *for the information.*



# 4. Range orders: reversible limit orders

*(The content of this section is updated on May 8; the previous description of excluding the last scenario of the three of being also range orders was wrong.)*

As explained in the above section, LPs of v3 can provide liquidity to any price range/tick at their wish. The behaviour of **LPs providing liquidity** on v3 is called (creating) **range orders**.

Depending on the **current price** and the **targeted price range**, there are three scenarios:

1. current price belongs to the targeted price range
2. current price < the targeted price range
3. current price > the targeted price range

These three scenarios have disparities in whether **both or only one of the two tokens** and also **the number of (which) tokens** is required/**allowed** when providing liquidity.

## Case 1: current price belongs to the targeted price range

Case 1 can be further divided into even two more cases: the current price is **central** to the targeted price range, or not.

If the current price happens to be central to the targeted price range (current price = 10 when the price range is [8, 12]), it’s the exact same liquidity providing mechanism as the previous versions: LPs provide liquidity in **both tokens of the same value** (`= amount * price`).

If the current price is not central to the price range, LPs still have to provide liquidity in both tokens, while the **amount** of each token depends on the distance between the current price and the price range, which will be explained in the next section (though not explicitly).

There’s a similar product to the case: **grid trading**, a very powerful investment tool for a time of **consolidation**. Dunno what’s grid trading? Check out [Binance’s explanation](https://www.binance.com/en/support/faq/f4c453bab89648beb722aa26634120c3) on this, as this topic won’t be covered!

In fact, LPs of Uniswap v1 & v2 **are grid trading** with a range of [0,∞] and the **entry price** as the baseline.

## Case 2 & 3: current price does not belong to the targeted price range

Unlike Case 1 where **both tokens** are required for providing liquidity, in Cases 2 and 3 **only one** of the two tokens is required/**allowed**.

To understand the reason for the above statement, we’d have to first revisit how price is discovered on Uniswap with the equation `x * y = k`, for `x` & `y` stand for the **amount** of two tokens X and Y and `k` as a **constant**.

The price of X compared to Y is `y / x`, which means how many Y one can get for 1 unit of X, and vice versa the price of Y compared to X is `x / y`.

For the price of X to go up, `y` has to increase and `x` decrease.

With this pricing mechanism in mind, it’s example time!

Say an LP plans to place liquidity in the price range [15.625, 17.313], higher than the current price of X `10`, when `100(x) * 1000(y) = 100000(k)`, which is **Case 2**.

- The price of X is `1250 / 80 = 15.625` when the equation is `80 * 1250 = 100000`.
- The price of X is `1315.789 / 76 = 17.313` when the equation is `76 * 1315.789 = 100000`.

If now the price of X reaches 15.625, the only way for the price of X to go even higher is to further increase `y` and decrease `x`, which means **exchanging a certain amount of X for Y**.

Thus, to provide liquidity in the range [15.625, 17.313], an LP needs **only to** **prepare** `80 — 76 = 4` of **X**. If the price exceeds 17.313, all `4` X of the LP is swapped into `1315.789 — 1250 = 65.798` **Y**, and then the LP has nothing more to do with the pool, as his/her liquidity is drained.

What if the price stays in the range? It’s exactly what LPs would love to see, as they can earn **swapping fees** for all transactions in the range! Also, the balance of X will swing between [76, 80] and the balance of Y between [1250, 1315.789].

This might not be obvious, but the example above shows an interesting insight: if the liquidity of one token is provided, **only when the token becomes more valuable will it be exchanged for the less valuable one**.

…wut?

Remember that if `4` X is provided within [15.625, 17.313], only when the price of X **goes up** from 15.625 to 17.313 is `4` X gradually swapped into Y, the less valuable one!

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



