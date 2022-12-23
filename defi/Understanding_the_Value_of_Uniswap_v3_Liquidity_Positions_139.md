> - 原文链接：https://lambert-guillaume.medium.com/understanding-the-value-of-uniswap-v3-liquidity-positions-cdaaee127fe7
> - 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> - 译者：[songmint](https://learnblockchain.cn/people/13263) 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> - 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/5202)



# 如何理解Uniswap v3 流动性头寸的价值

*请跳到*此系列文章的[*part 1*](https://lambert-guillaume.medium.com/uniswap-v3-lp-tokens-as-perpetual-put-and-call-options-5b66219db827?source=friends_link&sk=43c071fa2796639a60fce6c9abd5aa76) *和* [*part 2*](https://lambert-guillaume.medium.com/synthetic-options-and-short-calls-in-uniswap-v3-a3aea5e4e273?source=friends_link&sk=9fa4cdb12aab88ca9ecdc4d767a4ee1e) *, 您可以学习到为何Uniswap v3 流动性代币[译者注:即头寸]为何类似于看涨期权空头和看跌期权空头[的组合,译者注]*

Uniswap 在第3版协议中,改进了流动性头寸的创建和管理方法。与Uniswap v2相比，v3建立新头寸的过程是相当复杂。如果您像我一样[通过UI操作,译者注]，那么只需单击 **+ New Position ** 按钮,并调整范围和参数，直到获得一个看上去不错的头寸。那么选择 LP头寸参数的最佳方法是什么呢？

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

改变范围(tL, tH),就会改变收益曲线V(P)的“锐度”。当(tL,tH)区间只有一个tick那么大时，V(P)曲线将收敛于上图中的虚线。同样，1个tick大小的LP头寸收益, 恰好等于一个到期时不考虑交易费的[covered call备兑期权](https://lambert-guillaume.medium.com/uniswap-v3-lp-tokens-as-perpetual-put-and-call-options-5b66219db827?source=friends_link&sk=43c071fa2796639a60fce6c9abd5aa76) 的收益

## 计算Delta,净头寸价值的变化率

LP头寸的价值将如何受到标的物价格的影响？具体来说，我们想知道如果token0的值改变1美元，净头寸价值会改变多少。这个改变的值称为“delta”，代表期权的对于标的价格的敏感性。

我们通过求V(p)对价格P的偏导数,得到 变化率δ(P)，表达式如下：

![img](https://img.learnblockchain.cn/attachments/2022/05/o9epzvJU62849ea338dfd.png)

**LP头寸的Delta.** 当标的资产价格变动 1 美元时，LP 头寸的价值会变化多少？

我们看图,并将ΔE的值进行标准化，会容易理解该表达式。由于函数在某个点上的导数就是该点的斜率，所以delta的值就是与价格曲线V(P)相切的直线的斜率：

![img](https://img.learnblockchain.cn/attachments/2022/05/kCcm5WMh62849ea7c4b2b.png)

**Delta即斜率** 红色曲线的斜率表示标准化了的LP头寸 1*sqrtV(P) 的 delta 值。随着价格在下限 tL 和上限 tH 之间变化，斜率从 100% 变为 0%。 [下载 GIF 版本](https://cdn-images-1.medium.com/max/2400/1JDTDeS1htEIp9kHzyyG-EA.gif)。

delta代表的是 LP头寸的价值跟随标的物价格的变化幅度。随着标的价格上涨，Delta从1变为0，这意味着当价格较低时,LP的头寸价值将与标的物价格同幅度变化;当高于上限价格时, LP的头寸价值将不再变化(即为0%)。

具体的说，当我们考虑在 (2000, 3000) 之间部署LP头寸，该头寸可以收取交易费用,并实现30%的APR(年化收益率)。您可以将delta视为蓝线的斜率除以红线的斜率。由于 δ(P) 的值总是小于或等于 1，因此 LP头寸的收益也将小于或等于直接持有代币的策略。

![img](https://img.learnblockchain.cn/attachments/2022/05/81xHUvgd62849ead13aef.png)

**范围备兑期权.** 
LP头寸的收益来自于ETH在2000到3000之间的价格波动。当ETH价格低于下限tL,LP头寸的价值将跟随ETH价格; 当 ETH 的价格高于上限 3000 时,LP头寸价值将保持不变。交易费的收益率大概是8%。

请注意，当价格高于 3000 时，ETH价格与 LP 头寸之间存在相当大的差异。红色和蓝色曲线之间的区域称为[无常损失](https://uniswap.org/docs/v2/advanced-topics/understanding-returns/) (IL)。有些人会认为 IL表示 “错失了获利的大好机会”，甚至会为此痛心疾首.

我倒一点也不担心无常损失，因为我知道这种“错失的机会”是备兑期权的*特点*。正如我在[最近的一系列推文](https://twitter.com/guil_lambert/status/1412608674380632067?s=20) 中所述，虽然 LP 头寸确实遭受无常损失，但 LP 头寸实际上降低了投资组合回报的波动性：

链接：https://twitter.com/guil_lambert/status/1412608696778203138

![image-20221223145035610](https://img.learnblockchain.cn/pics/20221223145036.png)

## 理解净Delta收益的影响

为什么我们关心delta？了解投资组合的 delta 有助于管理风险并降低回报的波动性。对冲基金通常需要计算其金融工具的delta，以创建一个许多资产构成的投资组合,并保持总体上的[delta 中性](https://en.wikipedia.org/wiki/Delta_neutral) ——尽管市场波动，其总价值仍将保持不变。

我在 [上一篇文章](https://lambert-guillaume.medium.com/synthetic-options-and-short-calls-in-uniswap-v3-a3aea5e4e273?source=friends_link&sk=9fa4cdb12aab88ca9ecdc4d767a4ee1e ) 构建了勒式策略和跨式策略. 它们是限制价格波动风险 (delta=0) 的两个例子。我希望这些头寸能够通过限制“无常损失”来保持其价值，并通过累积费用来获利。 （*更新：距离“到期”还有 7 天，他们仍然盈利！*）

或者，*负* delta 可能也有收益，这样当标的价格下跌时，投资组合的价值就会增加。当考虑建立ETH 和其他代币之间的LP 头寸时,情况尤其如此。许多 DeFi代币在过去 6 个月中表现不及 ETH，尽管它们的价值在以稳定币计价时有所增加。投资者可能希望通过创建[看涨期权空头](https://lambert-guillaume.medium.com/synthetic-options-and-short-calls-in-uniswap-v3-a3aea5e4e273)  对冲那些表现不佳的代币资产


因此，如果要了解投资组合的总价值如何随着组成资产的上涨和下跌而变化，我们需要知道投资组合的 **净Delta**。我们将通过一个由 3 个 LP 头寸组成的假想投资组合来说明如何做到这一点：这三个头寸分别是ETH/Dai、ETH/UNI 和 ETH/WBTC。每个 LP 头寸的参数如下。

![img](https://img.learnblockchain.cn/attachments/2022/05/Hjb9B5kH62849eb21226f.png)

**LP组合**由 ETH/Dai、ETH/WBTC 和 ETH/UNI LP 头寸组成的投资组合的详细信息。总价值和delta已转换为ETH, 以简化净delta 计算。

在这里，我们引入了 beta (β)，这是一个跟踪参考资产的[相关性](https://en.wikipedia.org/wiki/Beta_(finance)) 的变量。使用 beta，我们可以用beta 加权每个资产的 delta 来计算投资组合的 **净Delta**（这里我用 ETH 表示 delta 以简化计算）：


![img](https://img.learnblockchain.cn/attachments/2022/05/Z0eLsJJH62849eb75b343.png)

使用上表中的信息，可以得到我们的投资组合的净delta为 1.126。这意味着ETH价格每变化 1 美元，我们的组合(包含相当复杂的 ETH、Uni 和 WBTC LP 头寸)就会变化 1.126 美元。

整个投资组合的净头寸价值为 2.69 ETH，但 ETH 价格变化后,预期收益的变化等同于持有 1.126 ETH的收益变化. 与2.69相比,减少了约60%。虽然意味着较小的回报，但也意味着较低的投资组合波动性。

投资组合的净delta的另一种用法,是确定空头头寸的规模. 空头头寸将抵消这些delta, 以对冲 ETH 价格的小幅变化并帮助维持投资组合价值。对于不同数量的ETH空头，上述头寸的盈亏如下所示。

![img](https://img.learnblockchain.cn/pics/20221223144832.png)

**ETH/Dai、ETH/WBTC 和 ETH/UNI 投资组合的净delta**投资组合的beta加权预期收益,会根据做空的 ETH 数量而变化，目的是平衡组合头寸的增量。调整做空ETH的数量,也会改变头寸的盈亏平衡点。我们假设最初收取 100 Dai 的费用来,计算该头寸的 beta 加权损益。Gif 演示：

![ GIF 版本](https://img.learnblockchain.cn/pics/20221223145409.gif)

## 未来的工作

在这篇文章中，我们推导出了 Uniswap v3 LP 头寸总价值的表达式。我们探讨了Uniswap v3 LP 期权的价格敏感性, 这将有助于理解未来的收益. 并且,我们描述了如何计算多个 Uniswap v3 LP头寸组合的净delta。

对于那些了解 Black-Scholes 模型和期权衍生品“希腊字母”的人来说，上面的讨论可能非常熟悉。除了 delta 之外，其他需要考虑的相关量是 gamma = dδ/dS、theta=dV/dt 和 vega=dV/dσ。

每个人在确定投资组合的收益方面都有自己的思虑，我们将在下一篇文章中扩展这些参数的使用，,以基于几何布朗运动模型的“Black-Scholes”的定价模型推导出 Uniswap v3 期权的预期投资收益。

请继续关注我!

*如果您对这些想法感兴趣并想为交易 Uni v3 期权的 UI 界面的开发做出贡献，请在推特上私信我 @guil_lambert 或发送电子邮件至 guil.lambert @protonmail.com*

