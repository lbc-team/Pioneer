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
# x is the amount of token0, y is the amount of token1
# price of token0 in terms of token1
P = y / x

# liquidity is the geometric mean of the amount of tokens
L = sqrt(x*y)
```

In V3 the liquidity is defined as the change in amount of token1 for a given change in square root P. Based on this concept the below V3 formulas are used to calculate the amount of tokens you can get.

```
Δy = Δ(√P) * L 
Δx = Δ(1/√P) * L
```

The above formulas is used for movement of price per adjacent tick. A tick is an integer which represents the price using the below formula.

```
P = 1.0001^i
sqrt(P) = 1.0001^(i/2)
i = log(sqrt(P)) * 2 / log(1.0001)
```

Each tick is 0.1% away from the adjacent one. If the price movement for the complete swap is beyond the adjacent tick then swap is performed in step functions moving from one tick to another until all the tokens are swapped.

CLMM follows the constant product formula for the price movement within 2 adjacent ticks. CLMM is a variation of the constant product formula.

Below is a script I wrote to emulate a swap using concentrated liquidity formula. I have ignored applying fee in the swap. Only the swap for token1 to token0 is implemented.

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



In V3 the liquidity pools are represented as NFTs since each pool is distinct from each other. A single swap might move from pool to pool based on the price impact of the swap.

Concentrated liquidity is highly efficient when compared to the standard constant product algorithm. CLMM uses the full liquidity in the pool within the price range of the pool. But CPMM spreads the liquidity over 0 to infinity. This is because CLMM has different formulas to calculate the new state of the pool.

### Price Impact

When a swap is made agains a pool the ratio of the tokens in the pool changes. The ratio of tokens in the pool is the price (P) of the token0 in terms of token1.

At the at the beginning of the swap the ratio of the poll is 100UNI : 1ETH. But you will not get 100UNI when swapping with 1ETH because the ratio of the pool changes. This is called the [price impact](https://docs.uniswap.org/concepts/introduction/swaps#price-impact) on the swap.

Let us take an example of UNI<>ETH liquidity pool. With current ratio 100UNI per 1 ETH. We will be using V2 formula of CPMM because the calculations are much easy but the concept still the same for V3.

```
# x and y are number of tokens
# x_uni = 10000, y_eth = 100
x_uni * y_eth = k
(x_uni - recieve) * (y_eth + deposit) = k
(10000 - receive) * (100 + 1) = 10000 * 100
receive = 10000 - (10000 * 100 / 101)
receive = 99.0099
```

In the above calculation you see that for 1 ETH you get 99.0099 UNI tokens. The ratio of tokens in the pool has changed but the product of the amount of tokens is still the same.

### Slippage

Transactions with higher gas can be executed before transactions with lower fee. It is not possible to predict at which point in time will the transaction execute. The state of the pool might have changed between the transaction broadcast and execution. The changed state of the pool might result in a very different price for the swap than predicted. This change in price is considered as [slippage](https://docs.uniswap.org/concepts/introduction/swaps#slippage).

### Impermanent loss

Liquidity providers are taking risk by providing liquidity. The ratio of tokens in the pool will keep on changing based on the current market price. Arbitrageurs will trade with pool to match the pool token ratio (price) with that of the larger market. This rebalancing of the portfolio is risky for the LPs because when they decide to withdraw the funds the ratio might be very skewed in the direction of token which has lost value.

Lets us take an example to see this. The below example uses V2 CPMM because it has a simple formula but the concept is same for V3 as well.

Alice and Bob decide the fund the BTC<>ETH pool. We will see the state of the liquidity pool at different times. The state of the pool is calculated using 2 equations.

```
# token_x and token_y are number of tokens
# k is the constant product and r is the ratio of tokens
token_x * token_y = k
token_x / token_y = r
# substituting the value of token_y
token_x^2 / r = k
token_x = √(k*r)
token_y = √(k/r)
```

token_x = BTC, token_y = ETH

**At T0**
r = 1/10
Initial pool state = 900 BTC + 9000 ETH
Alice deposits 100 BTC + 1000 ETH
Final pool state = 1000 BTC + 10000 ETH
Alice is 10% owner of the pool

**At T1**
r = 1/8
Initial pool state = 1118 BTC + 8944 ETH
Bob deposits 80 BTC + 640 ETH
Final pool state = 1198 BTC + 9584 ETH
Bob owns 6.67% of the total pool
Alice now owns 9.33% of the pool

**At T2**
r = 1/5
Initial pool state = 1515.36 BTC + 7576.8 ETH

Alice decides to withdraw from the pool
Alice will get 9.33% of the pool which is 141.38 BTC + 706.91 ETH. Which at current rate is worth 282.76 BTC.
If Alice would have held the tokens instead of adding then to the pool she would have 100 BTC + 1000 ETH which is worth 300 BTC at current rates. So Alice lost 17.24 worth BTC in her holding.

Final pool state = 1373.98 BTC + 6869.89 ETH

Bob now owns 7.356% of the pool and decides to keep his funds in the pool.

**At T3**
r = 1:8
Initial pool state = 1086.22 BTC + 8689.76 ETH
Bob decides to withdraw his funds from the pool
Bob will get 7.356% of the pool which is 79.9 BTC + 639.218 ETH. Which at the current rate is worth 159.8 BTC (consider this 160 because of decimal errors it is coming 159.8). If Bob would have not deposited in the pool he would have 80 BTC + 640 ETH which at the current rate is worth 160 BTC.
Here we see that Bob did not lose any value because the ratio of the pool is same as when he deposited his tokens.

This is the reason it is called impermanent loss. If the ratio of the pool is same as when you deposited the token there is no loss.

LPs get trading fees for every trade. If the trading fees collected by the LP is greater than the impermanent loss then the LP can withdraw the funds from the pool with a profit.
