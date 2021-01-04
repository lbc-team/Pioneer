https://medium.com/coinmonks/frax-a-partially-collateralized-stablecoin-53d7841a4558 Auther: [Alexis Direr](https://medium.com/u/52e090ff31b0?source=post_page-----53d7841a4558--------------------------------)



# FRAX, a partially collateralized stablecoin

## FRAX is a decentralized, fractional-reserve stablecoin launched on the Ethereum network and pegged to the dollar. Initially fully collateralized, its aim is to gradually transition to a fully algorithmic protocol





![Image for post](https://img.learnblockchain.cn/pics/20210104223454.png)





This post presents a short introduction to the stablecoin, its functioning, seigniorage model and capacity to handle financial shocks.

# Functionning

FRAX can be minted by anyone who provides two tokens: a collateral token, currently USDC, and the protocol’s share token FXS. The proportions are given by the collateral ratio. For example, a 60% ratio means that $1 FRAX can be minted with $0.60 USDC and $0.40 FXS:



![Image for post](https://img.learnblockchain.cn/pics/20210104223521.png)

Example with a 60% collateral ratio

1 FRAX can always be redeemed for $1. To continue the example with a 60% collateral ratio, each FRAX is redeemable for $0.60 of collateral and $.40 of FXS:

![Image for post](https://img.learnblockchain.cn/pics/20210104223526.png)

Example with a 60% collateral ratio

FRAX is collateralized by USDC, but contrary to stablecoins like DAI, it is partially collateralized by design. The reserve of USDC held in the protocol is less than the amount of circulating coins.

The two-way convertibility of FRAX guarantees its peg with USDC:

- If 1 FRAX < $1, arbitragers buy FRAX, redeem them, get USDC and FXS in exchange, sell FXS and make a profit. The buy pressure restores the peg.
- If 1 FRAX > $1, arbitragers mint FRAX with USDC and FXS, sell FRAX and make a profit. The sell pressure restores the peg.

The protocol mints and distributes FXS to liquidity providers in (currently) three incentivized pools: FRAX/USDC, FRAX/WETH and FRAX/FXS:



![Image for post](https://img.learnblockchain.cn/pics/20210104223535.png)

FXS rewards liquidity providers

# Seigniorage

The protocol proposes an original model of seigniorage. FXS is needed to mint FRAX. Since people find valuable to hold the stablecoin because of its peg to the dollar, FXS is also valuable. The total amount of seigniorage is the circulating market capitalization of FXS.

FXS holders benefit from seigniorage essentially through price increase. When new FRAX are minted, FXS are burnt in proportion to the uncollateralized fraction. Continuing the previous example with a collateral ratio (CR) of 60%, 1 FRAX minted means $0.40 FXS burnt:



![Image for post](https://img.learnblockchain.cn/pics/20210104223543.png)

This reduces the quantity of circulating FXS, which drives its price upward. Moreover, when the protocol lowers the CR, more FXS are burnt for a given supply of FRAX. This also create a buy pressure, which benefits to FXS holders.

Liquidity providers in the FRAX pools also benefit from seigniorage. By providing FRAX in the three incentivized pools, they earn FXS. The less the CR (that is the more seigniorage), the more FXS they get. Going from a 100% CR to a 0% CR would boost 2x the emission rate.

The price of FXS essentially depends on the supply side. On the one hand, a steady flow of FXS is minted and distributed to liquidity providers, which expands the circulating supply and exerts downward pressure. On the other hand, as usages and adoption grow, more FRAX are minted than redeemed, meaning that large amounts of FXS are burnt in the process and withdrawn from circulation.

To get some ideas of the numbers, assume that the supply of FRAX expands in 2021 from 50M to 300M, which is quite a plausible projection. With an hypothetical CR of 50%, this would translate into a demand for additional FXS of 0.5 x 250M = 125M. In the meantime, the emission of FXS would be around 1.5 x 18M = 27M (taking into account the 50% CR-boost) + 35M of gradually unlocked team/founders/investors’ stake = 62M. The mismatch between supply and demand is by design and is a strong factor of price increase.

# Risks

Holding FXS has benefits if the FRAX supply expands and the protocol becomes more algorithmic. There are also some risks. To recall:

- If 1 FRAX < $1, arbitrageurs buy FRAX, redeem them in exchange of USDC and FXS and **sell** FXS.
- Conversely, If 1 FRAX > $1, arbitrageurs **buy** FXS, mint FRAX with USDC and FXS and sell FRAX.

In both events, the peg to the dollar is maintained, despite possible large demand fluctuations, by transferring price volatility to FXS holders. In particular, the price of FXS may fall if the demand for FRAX contracts. In rare black-swan events, this could possibly trigger a bank-run type massive redemption of FRAX.

To handle strong contraction phases, the system is protected by three types of safeguards. First, the protocol recollateralizes the system during contraction phases. Redeemers of FRAX receive more collateral and less FXS. This should increase market confidence in FRAX as its backing increases.

Second, the FRAX:FXS ratio (called the growth ratio) is kept in check. It is the amount of circulating FRAX divided by the fully diluted market capitalization of FXS. The larger the market capitalization, the smaller the FXS price decrease for a given amount of FRAX sold in the market. A low ratio means therefore a more resilient system. The current supply of FRAX (as of 01/02/2021) is 74M. The market capitalization of FXS is 686M, hence a ratio of 10,8%. However, keep in mind that in the short/medium term, the circulating market capitalization of FXS is lower (currently 16M).

Third, the issuance of FRAX bonds (still to be launched) could mitigate FXS selling during contraction phases by incentivizing holders to stake their FXS by buying bonds.

To conclude, FRAX is an interesting ongoing monetary experiment which strikes a new balance between price stability, capital efficiency and censorship resistance. The protocol has worked well after a week of existence. It remains to see by how far it can move away from fully collateralized protocols by reducing the CR while preserving its stability.



