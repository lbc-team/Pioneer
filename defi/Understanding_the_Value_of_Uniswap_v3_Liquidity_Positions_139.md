原文链接：https://lambert-guillaume.medium.com/understanding-the-value-of-uniswap-v3-liquidity-positions-cdaaee127fe7

# 如何理解Uniswap v3 流动性头寸的价值

*请跳到*此系列文章的[*part 1*](https://lambert-guillaume.medium.com/uniswap-v3-lp-tokens-as-perpetual-put-and-call-options-5b66219db827?source=friends_link&sk=43c071fa2796639a60fce6c9abd5aa76) *和* [*part 2*](https://lambert-guillaume.medium.com/synthetic-options-and-short-calls-in-uniswap-v3-a3aea5e4e273?source=friends_link&sk=9fa4cdb12aab88ca9ecdc4d767a4ee1e) *, 您可以学习到为何Uniswap v3 流动性代币[译者注:即头寸]为何类似于看涨期权空头和看跌期权空头[的组合,译者注]*

Uniswap 在第3版协议中,改进了流动性头寸的创建和管理方法。与Uniswap v2相比，v3建立新头寸的过程是相当复杂。如果您像我一样[通过UI操作,译者注]，那么只需单击 ***+ New Position\*** 按钮,并调整范围和参数，直到获得一个看上去不错的头寸。那么选择 LP头寸参数的最佳方法是什么呢？

![img](https://img.learnblockchain.cn/attachments/2022/05/rMq5TjRI62849e8083c93.png)

[如果您试图]寻找一个Uniswap v3 流动性价格范围的选择攻略, 那么结果就是啥都没有。

在本文中，我们将描述当你创建 LP 头寸时,那些隐藏在UI后的代码所做的事。我们还将推导出一组简单的公式，也许可以帮到您在许多底层资产标的中找到一个最佳的价格范围,用以设置Uniswap v3 LP头寸.

## Uniswap v3 LP代币有何价值?

Uniswap v3[白皮书](https://uniswap.org/whitepaper-v3.pdf)中, 描述了LP在建立新头寸时,必须添加的每种代币的数量。在一个新建的LP头寸中 **token0** 和 **token1** 的数量将取决于以下三个变量联合确立的价格范围:

代表较低价格端点的tick **tL**,

代表较高价格端点的tick **tH**,

建立头寸时的价格 **P0**

我以略有不同的符号重印了白皮书中的等式 (6.29) 和 (6.30)，以显示 tL , tH 与 P0 的关系：

![img](https://img.learnblockchain.cn/attachments/2022/05/C0FyUmCv62849e86a8e2e.png)

**一个LP头寸的代币组合**描述了该头寸中有多少token0和token1。

这里，ΔE的值由建立头寸时,头寸中锁定的token0（记为x0）和token1（记为y0）的初始数量决定：

![img](https://img.learnblockchain.cn/attachments/2022/05/wfNjHK1B62849e919f29d.png)

头寸一旦建立,我们就可以让token1数量加上token0数量乘以价格P,两者之和就是**净头寸价值**

![img](https://img.learnblockchain.cn/attachments/2022/05/oRMiktNw62849e95b2982.png)

如果价格高于上限tH，则LP代币的净头寸价值Net Liq将收敛于几何平均值√(tL*tH)。当价格低于下限 tL时，LP代币的净头寸价值就是价格P乘以头寸大小.

当值介于 tL 和 tH 之间时，表达式会稍微复杂一些，并将取决于价格P的平方根。从图形上看，净头寸价值Net Liq值V(P)如下图所示：
![img](https://img.learnblockchain.cn/attachments/2022/05/lXd6ZcEj62849e9cf0ac2.png)

改变范围(tL, tH),就会改变收益曲线V(P)的“锐度”。当(tL,tH)区间只有一个tick那么大时，V(P)曲线将收敛于上图中的虚线。同样，1个tick大小的LP头寸收益, 恰好等于一个到期时不考虑交易费的[covered call备兑期权]的收益（https://lambert-guillaume.medium.com/uniswap-v3-lp-tokens-as-perpetual-put-and-call-options-5b66219db827?source=friends_link&sk=43c071fa2796639a60fce6c9abd5aa76)

# 计算Delta,净头寸价值的变化率

LP头寸的价值将如何受到标的物价格的影响？具体来说，我们想知道如果token0的值改变1美元，净头寸价值会改变多少。这个改变的值称为“delta”，代表期权的对于标的价格的敏感性。

我们通过求V(p)对价格P的偏导数,得到 变化率δ(P)，表达式如下：

![img](https://img.learnblockchain.cn/attachments/2022/05/o9epzvJU62849ea338dfd.png)

**LP头寸的Delta.** 当标的资产价格变动 1 美元时，LP 头寸的价值会变化多少？

我们看图,并将ΔE的值进行归一化，会容易理解该表达式。由于函数在某个点上的导数就是该点的斜率，所以delta的值就是与价格曲线V(P)相切的直线的斜率：

It is much easier to understand this expression if we look at it graphically and normalize by the value of the position ∆E. Since the derivative of a function is its instantaneous slope, the value of delta is simply the slope of a line that is tangential to the price curve V(P):

![img](https://img.learnblockchain.cn/attachments/2022/05/kCcm5WMh62849ea7c4b2b.png)

**Delta as a slope.** The slope of the red curve represents the value of delta for the normalized LP position 1*sqrtV(P). The slope changes from 100% to 0% as the price changes between the lower tick tL and the upper tick tH. [Download GIF version](https://cdn-images-1.medium.com/max/2400/1JDTDeS1htEIp9kHzyyG-EA.gif).

What this figure represents is how much the value of a LP token tracks the price of the underlying. Delta goes from 1 to 0 as the price increases, meaning that the value will match the price of the underlying with 100% correlation at low prices and 0% above the upper tick.

More concretely, let’s consider a LP position deployed between (2000, 3000) that accrues 30% APR from the collected fees. You can think of delta as the slope of the blue line divided by the slope of the red line. Since the value of δ(P) is always less than or equal to 1, the return of a LP position will also be less than or equal to a holding strategy.

![img](https://img.learnblockchain.cn/attachments/2022/05/81xHUvgd62849ead13aef.png)

**Ranged Covered Call.** Return of a LP position defined by an ETH price between 2000 and 3000. The LP position’s value will track the price of ETH below the lower tick tL and will remain unchanged when the price of ETH is above the upper tick 3000. Returns from fees are approximately 8%.

Notice the rather large discrepancy between the ETH price and the LP position when the price is above 3000. The area between the red and blue curve is referred to as the [impermanent loss](https://uniswap.org/docs/v2/advanced-topics/understanding-returns/) (IL). Some will see IL as “missing a great opportunity for profits” and many are extremely worried about it.

Impermanent loss doesn’t worry me at all because I understand that this “missed opportunity” is a *feature* of covered call positions. As I described in a [recent series of tweets](https://twitter.com/guil_lambert/status/1412608674380632067?s=20), while LP positions do suffer from impermanent loss, LP positions actually decreases the volatility of portfolio returns:

链接：https://twitter.com/guil_lambert/status/1412608696778203138?ref_src=twsrc%5Etfw%7Ctwcamp%5Etweetembed%7Ctwterm%5E1412608696778203138%7Ctwgr%5E%7Ctwcon%5Es1_&ref_url=https%3A%2F%2Fcdn.embedly.com%2Fwidgets%2Fmedia.html%3Ftype%3Dtext2Fhtmlkey%3Da19fcc184b9711e1b4764040d3dc5c07schema%3Dtwitterurl%3Dhttps3A%2F%2Ftwitter.com%2Fguil_lambert%2Fstatus%2F1412608696778203138image%3Dhttps3A%2F%2Fi.embed.ly%2F1%2Fimage3Furl3Dhttps253A252F252Fabs.twimg.com252Ferrors252Flogo46x38.png26key3Da19fcc184b9711e1b4764040d3dc5c07

# Understanding the impact of Net Delta on returns

Why do we care about delta? Understanding a portfolio’s delta can help manage risks and reduce returns volatility. Hedge funds typically need to compute the delta of their financial instruments to create a portfolio containing many assets structured in way that is [delta neutral](https://en.wikipedia.org/wiki/Delta_neutral) — ie. whose total value will remain constant despite market swings.

The short strangle and short straddles I created in my [previous post](https://lambert-guillaume.medium.com/synthetic-options-and-short-calls-in-uniswap-v3-a3aea5e4e273?source=friends_link&sk=9fa4cdb12aab88ca9ecdc4d767a4ee1e) are two examples of strategies that limit exposure to price fluctuations (delta=0). My hope is that these positions will maintain their value by limiting “impermanent loss” and turn in a profit by accumulating fees. (*update: they’re still profitable with 7 days to go until “expiration”!*)

Or, it may be beneficial to have a *negative* delta so that the value of a portfolio increases when the price of the underlying decreases. This is true especially when considering a LP position that is established between ETH and another token. Many DeFi tokens have underperformed ETH in the past 6 months even though their value increased when denominated in stablecoin. An investor may wish to hedge against underperforming assets by creating a [short call](https://lambert-guillaume.medium.com/synthetic-options-and-short-calls-in-uniswap-v3-a3aea5e4e273?source=friends_link&sk=9fa4cdb12aab88ca9ecdc4d767a4ee1e) position.

Therefore, to understand how the value of a portfolio will fare against both upward and downward moves across many assets, we need to know what is the **Net Delta** of a portfolio. We’ll illustrate how to do this with a hypothetical portfolio consisting of 3 LP positions: ETH/Dai, ETH/UNI, and ETH/WBTC. The parameters of each LP position are summarized below.

![img](https://img.learnblockchain.cn/attachments/2022/05/Hjb9B5kH62849eb21226f.png)

**LP portfolio.** Details of a portfolio consisting of ETH/Dai, ETH/WBTC and ETH/UNI LP positions. The total value and the delta have been converted into ETH to simplify the net delta calculation.

Here, we introduce beta (β), a quantity that tracks the[ correlation](https://en.wikipedia.org/wiki/Beta_(finance)) to a reference asset. Using beta, we can calculate the portfolio’s N**et Delta** according to the delta of each asset weighted by beta (here I express delta in terms of ETH to simplify the calculation):

![img](https://img.learnblockchain.cn/attachments/2022/05/Z0eLsJJH62849eb75b343.png)

Using the information from the table above, we get that the net delta of our portfolio is 1.126. This means that the value of our portfolio — which contains a rather complex mix of ETH, Uni, and WBTC LP positions — will change by $1.126 for every $1 change in the value of ETH.

One way to look at it is that while combined Net Liq value of the portfolio is 2.69 ETH, the relative change in expected returns following the change in the price of ETH will only be equivalent to a holding with 1.126 ETH, about 60% smaller. While this means smaller returns, it also means lower portfolio volatility.

Another way to use the net delta of a portfolio would be to use it to determine the size of a short position that would neutralize delta and bring it to zero to hedge against small changes in ETH price and help maintain portfolio value. Here’s what the P/L of the position above would look like for different amounts of shorted ETH.

![img](https://img.learnblockchain.cn/attachments/2022/05/BKuePlOq62849ec3c54a1.png)

**Net delta of a ETH/Dai, ETH/WBTC, and ETH/UNI portfolio.** The beta-weighted expected return of the portfolio will change according to the amount of ETH shorted to balancer the delta of the position. Tuning the amount of shorted ETH shifts the position’s break-even points. We assumed an initial 100 Dai in fees were collected to compute the beta-weighted P/L for this position. [Download GIF version.](https://cdn-images-1.medium.com/max/2400/1*X6f_q944yYMqqVlfGgQCLA.gif)

# Future work

In this post, we derived an expression for the total value of a Uniswap v3 LP position. We found that the price sensitivity of a Uniswap v3 LP option can help understand future returns, and we described a procedure for calculating the delta of a portfolio composed of many Uniswap v3 LP pairs.

The discussion above may have been familiar for those that know about the Black-Scholes model and “the Greeks” for options derivatives. Beyond delta, other relevant quantities to consider are gamma = dδ/dS, theta=dV/dt, and vega=dV/dσ.

Each has their role to play in determining the returns of a portfolio, and we will expand the use of these parameters in the next post to derive the expected return on investment for Uniswap v3 options using “Black-Scholes”-like pricing models based on Geometric Brownian Motion.

Stay tuned!

*If you’re interested in these ideas and would like to contribute to the development of a UI interface for trading Uni v3 options, please DM me on twitter @guil_lambert or send an email to guil.lambert @ protonmail.com*



