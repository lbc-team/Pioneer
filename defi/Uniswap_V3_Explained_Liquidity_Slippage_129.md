原文链接：https://kushgoyal.com/uniswap-v3-expalined-concentrated-liquidity/

# Uniswap V3 释疑: 集中流动性, 无常损失和滑点_129

Uniswap 协议是一组原生的ETH的智能合约，它可以实现 ERC20代币与ERC20代币的交换, 以及ERC20代币与ETH之间的的交换。

Uniswap 使用自动做市商 (AMM) 算法来执行交易。用户以代币对的形式创建流动性池子,并在其中提供流动性。执行交易就是将所提供的代币存入池中,并从池中提取所请求的代币。
交易费则以被请求代币的形式, 分配给流动性提供者 (LP)。

[Uniswap V3](https://uniswap.org/blog/uniswap-v3/)是该协议的最新版本，引入了集中流动性等诸多概念。在 V3 中，根据提供流动性的风险，存在几个可用的费用等级。费用在池中的2种代币上收取，而不会重新投资到池中。

UNI 是 Uniswap 协议的治理代币。 将来,UNI 代币持有者可能有资格获得[协议费用](https://docs.uniswap.org/concepts/V3-overview/fees#protocol-fees)。当前的协议费率为 0%。 UNI 代币持有者可以更改协议费率。

## 集中流动性

Uniswap V3 使用[集中流动性](https://docs.uniswap.org/concepts/V3-overview/concentrated-liquidity) 做市算法 (CLMM)，这是比标准的常数乘积做市 (CPMM) 算法更有效的算法.

每个池中有两种代币，分别是token0 和 token1。token0 的价格 (P) 以 token1 表示。例如，UNI<>ETH 池中，每 1个ETH 可以兑换100个UNI。

在 CLMM（ 集中流动性做市算法）中，LP必须选择合适的价格范围以提供流动性。如果价格P移到某个池的范围之外，该池的流动性将变为非活跃状态。交易将在下一个可用的池中进行。

在 CLMM 中，池子跟踪[价格的平方根](https://uniswap.org/whitepaper-v3.pdf) (P) 和池中的流动性 (L)。 此时已不再需要池中的已有代币数量用来计算兑换结果。

以下公式定义了代币数量、价格和流动性之间的关系。
```
# x 表示token0的数量, y 表示token1的数量
# 以token1为单位 计算出的token0的价格
P = y / x

# 流动性是代币数量的几何平方数
L = sqrt(x*y)
```
在 V3 中，流动性被定义为:给定平方根P的变化值，token1 数量的变化值。
基于此概念，下面的公式可用于计算你请求的代币数量。

```
Δy = Δ(√P) * L 
Δx = Δ(1/√P) * L
```

上述公式用于计算相邻tick的价格变动。
其中tick是一个整数，可用于计算价格。 tick计算价格的公式如下

```
P = 1.0001^i
sqrt(P) = 1.0001^(i/2)
i = log(sqrt(P)) * 2 / log(1.0001)
```

每个tick与相邻tick的距离为0.1%。
如果一笔交易导致的价格变动超出了该tick对应的价格范围，则交易按照顺序跨越过一个个tick, 每达到一个tick就进行交换，直到交易请求中的所有代币都被交换完成。

当价格处于两个tick之间的价格范围内时， CLMM遵循常数乘积公式。 因此CLMM可以被看做是常数乘积公式的变体。

下面是我编写的python脚本，模拟了使用CLMM进行交易的过程。我忽略了交易手续费，只实现了从token1 到token0 的交换。

```python

import math


def calc_tick(rp):
    # P = 1.0001 ^ i
    # sqrt(P) = 1.0001 ^ (i / 2)
    # i = log(sqrt(P)) * 2 / log(1.0001)
    return (math.log(rp) * 2) / math.log(1.0001)



def calc_sqrt_price(i):
    # sqrt(P) = 1.0001 ^ (i / 2)
    return math.pow(1.0001, i/2)




def swap(offered_y, x, y):
    delta_y = offered_y
    liquidity = math.sqrt(x * y)
    delta_sqrt_price = delta_y / liquidity
    sqrt_price = math.sqrt(y / x)
    tick_start = math.floor(calc_tick(sqrt_price))
    tick_finish = math.floor(calc_tick(sqrt_price + delta_sqrt_price))
    diff = tick_finish - tick_start
    delta_x = 0
    for tick in range(0, diff):
        # calculate the delta_sqrt_price
        tick_sqrt_price = calc_sqrt_price(tick_start + tick + 1)
        delta_sqrt_price = tick_sqrt_price - sqrt_price
        inverse_delta_sqrt_price = (1 / sqrt_price) - (1 / tick_sqrt_price)
        # check how much y is left to swap
        if delta_y - (delta_sqrt_price * liquidity) > 0:
            delta_y -= (delta_sqrt_price * liquidity)
            delta_x += (liquidity * inverse_delta_sqrt_price)
        else:
            # delta_y is exhausted for the integer value of tick
            break
    # apply the same logic for an exchange within adjacent tick
    if delta_y > 0:
        delta_sqrt_price = delta_y / liquidity
        fractional_tick = calc_tick(sqrt_price + delta_sqrt_price)
        tick_sqrt_price = calc_sqrt_price(fractional_tick)
        inverse_delta_sqrt_price = (1 / sqrt_price) - (1 / tick_sqrt_price)
        delta_x += (liquidity * inverse_delta_sqrt_price)
    return delta_x



# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print(swap(1, 10000000, 100000))
```

在 V3 中，流动性池被表示为NFT， 这是因为每个池都彼此不同。由于交易对于价格的影响， 单个交易可能需要跨越多个流动性池。

与标准常数乘积算法相比，集中流动性的效率更高。 CLMM在每个池子的价格范围内使用池子中的全部流动性。而CPMM将流动性分布在 0 到无穷大之间。 CLMM能做到这一点，是因为有不同的公式来计算池子的新状态（译者注：状态包含流动性，tick值，价格等）。


### 价格冲击

当一笔交易再次与池子进行代币交换时，池中代币的比例会发生变化。池中代币的比例是代币 0 相对于代币 1 的价格（P）。

在交换开始时，池子中的代币比例是 100UNI : 1ETH。但是直接用1ETH兑换是不会得到100UNI的，这是因为随着交换的进行，池子中的代币比例发生了变化。这称为交易的[价格冲击](https://docs.uniswap.org/concepts/introduction/swaps#price-impact)。

让我们以 UNI<>ETH 池子为例。当前比率为每1个ETH兑换100个UNI。我们将使用V2中的CPMM公式，因为计算起来相对容易，但是依然适用于V3。

```
# x and y are number of tokens
# x_uni = 10000, y_eth = 100
x_uni * y_eth = k
(x_uni - recieve) * (y_eth + deposit) = k
(10000 - receive) * (100 + 1) = 10000 * 100
receive = 10000 - (10000 * 100 / 101)
receive = 99.0099
```
在上面的计算中，可以看到付出1 ETH， 可以获得99.0099 UNI 代币。虽然池中代币的比例发生了变化，但代币数量的乘积仍然相同。

### 滑点
一笔交易如果提供了更高的gas， 那么该笔交易先于其他较低gas的交易执行。 但是我们无法预测交易执行的具体时间点。在交易广播和交易执行之间的时间间隙中，可能池子已经发生了变化。池子状态的改变可能导致交易价格与预期的价格大相径庭。这种价格变化被认为是[滑点]
(https://docs.uniswap.org/concepts/introduction/swaps#slippage).

### 无常损失

流动性提供者通过提供流动性来承担风险。池中的代币比例将根据当前市场价格不断变化。套利者与流动性池进行交易，使得代币比率（就是价格）与其他更大市场中的代币比率（价格）相匹配。这种代币的再平衡对LP 来说是有风险的。 因为当他们决定从池中撤回资金时，池中会有更多已经相对贬值的代币。


举个例子，下面的示例使用 V2的CPMM，因为它有一个简单的公式，但 V3 的概念也相同。

Alice 和 Bob 决定了 BTC<>ETH 池的资金。我们将看到不同时间点，流动池的状态。 为了计算池的状态，我们需要使用两个方程。

```
# token_x and token_y 分别是代币的数量
# k 是常数乘积，r是代币的比率
token_x * token_y = k
token_x / token_y = r
# substituting the value of token_y
# 替换方程中的token_y，计算得到
token_x^2 / r = k
token_x = √(k*r)
token_y = √(k/r)
```

token_x = BTC, token_y = ETH

**At T0**
r = 1/10
初始池中状态 = 900 BTC + 9000 ETH
Alice 存入 100 BTC + 1000 ETH
最终池中状态 = 1000 BTC + 10000 ETH
Alice 拥有10% 的池子份额

**At T1**
r = 1/8
初始池中状态 = 1118 BTC + 8944 ETH
Bob 存入 80 BTC + 640 ETH
最终池中状态 = 1198 BTC + 9584 ETH
Bob 拥有 6.67% 的池子份额
Alice 如今拥有9.33%的池子份额

**At T2**
r = 1/5
初始池中状态 = 1515.36 BTC + 7576.8 ETH

Alice 决定提取资金
Alice 将获得整个池代币的9.33%么，计算得到为141.38 BTC + 706.91 ETH. 按当前价格计算，折合为208.76 BTC.
如果Alice选择直接持有代币而非提供流动性，那么她将拥有100 BTC + 1000 ETH, 按照当前价格计算，折合为300 BTC. 
所以Alice因为做市，实际损失了17.24个BTC

最终池中状态 = 1373.98 BTC + 6869.89 ETH

Bob 拥有了7.356%的池中份额，并且决定继续保留资金在池子中.

**At T3**
r = 1:8
初始池中状态 = 1086.22 BTC + 8689.76 ETH
Bob 决定提取资金
Bob 将获得整个池代币的7.356% ，计算得到为 79.9 BTC + 639.218 ETH.
按照当前价格， 折合为159.8 BTC.  (由于进位错误，我们直接看做160 而不是159.8）
如果Bob没有注入流动性，那么 他将拥有80 BTC + 640 ETH。 按照当前价格计算，折合为160 BTC.
我们看到Bob并没有损失， 这是因为此时池中的代币比率相对他的存入时刻的比率， 并没有发生变化。

这就是它被称为无常损失的原因。如果池中的代币比率与你存入代币时的比率相同，将不会有任何损失。

LP从每笔交易中收取交易费。如果 LP收取的交易费用大于无常损失，则 LP可以从池中提取资金，获得正收益。
