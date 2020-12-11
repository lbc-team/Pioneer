> * 来源：https://defiprime.com/synthetic-assets-defi

# Synthetic Assets in DeFi: Use Cases & Opportunities




While the primary use-case for cryptoassets continues to be speculation, I don’t believe this is a bad thing. Speculation was a key driver in the development of traditional financial markets and continues to play an important role in the industry today. Most importantly, speculators provide liquidity, allowing participants to enter or exit the market more easily. This reduces transaction costs and increases access for market participants.

The cryptoasset market today remains immature and suffers from a lack of liquidity; unlike assets within the traditional financial system, which have built a baseline of liquidity over multiple decades, most cryptoassets are less than a few years old. For example, 24-hour dollar trade volumes are around $700 million for [Bitcoin](https://www.bitcointradevolume.com/) and $5.3 billion for [Apple](https://www.bloomberg.com/quote/AAPL:US). Insufficient liquidity limits the utility of underlying protocols, as we’ve seen with decentralized exchanges and prediction markets.

I believe that cryptoasset markets will evolve similarly to traditional financial markets and, as such, will require more sophisticated financial instruments, specifically synthetic assets (“synthetics”), for both institutional and retail participants.

In this post, I will:

* Provide an overview of synthetic assets, explaining what they are and how they are used in traditional financial markets.
* Explain why synthetics are crucial to the maturation of the cryptoasset markets and provide examples of projects using synthetics today.
* Offer examples of new, “crypto-native” derivatives that could be built.

The first part will focus on basic explanations and examples of synthetics. If you are familiar with these (or find financial engineering too boring), scroll down to the second half of the post.

## What are synthetics?

A synthetic is a financial instrument that simulates other instruments. In other words, the risk/reward profile of any financial instrument can be simulated using a combination of other financial instruments. Synthetics are comprised of one or more derivatives, which are assets that are based on the value of an underlying asset and include:

* Forward commitments: [Futures](https://en.wikipedia.org/wiki/Futures_contract), [forwards](https://en.wikipedia.org/wiki/Forward_contract), and [swaps](https://en.wikipedia.org/wiki/Swap_(finance))
* Contingent claims: [Options](https://en.wikipedia.org/wiki/Option_(finance)), [credit derivatives](https://en.wikipedia.org/wiki/Credit_derivative) such as credit default swaps (CDS), and [asset-backed securities](https://en.wikipedia.org/wiki/Asset-backed_security)

## What are synthetics good for?

There are a variety of reasons why an investor would choose to purchase a synthetic asset. These include:

* Funding
* Liquidity creation
* Market access

Below I will provide an overview and examples from traditional finance for each of these reasons. Note that these are not mutually exclusive.

### Funding

Synthetics can lower funding costs. One example is a [Total Return Swap](https://www.investopedia.com/terms/t/totalreturnswap.asp) (TRS) that is used as a funding tool to secure financing for assets held. It allows the party to obtain funding for a pool of assets it already owns and the swap counterparty to earn interest on funds that are secured by a pool of assets. Used in this way, the TRS is similar to a secured loan because:

* The party that sells the securities and agrees to buy them back is the party that needs financing, and
* The party that buys the securities and agrees to sell them back is the party that provides the financing.

### Liquidity creation

Synthetics can be used to inject liquidity into the market, which reduces costs for investors. One example is a [credit default swap](https://en.wikipedia.org/wiki/Credit_default_swap). A CDS is a derivative contract between two parties, a credit protection buyer and a credit protection seller, in which the buyer makes a series of cash payments to the seller and receives a promise of compensation for credit losses resulting from a “credit event”, such as a failure to pay, bankruptcy, or restructuring. This gives a CDS seller the ability to synthetically long an underlying asset and a CDS buyer the ability to hedge their credit exposure on an underlying asset.

[In this paper](http://finance.wharton.upenn.edu/conferences/liquidity2014/pdf/Synthetic%20or%20Real%20The%20Equilibrium%20Effects%20of%20Credit%20Default%20Swaps%20on%20Bond%20Markets_Martin%20Oehmke.pdf), the author demonstrates that CDS markets are more liquid than their underlying bond markets. One of the main reasons for this is standardization: the bonds issued by a particular firm are usually fragmented into a number of different issues which differ in their coupons, maturities, covenants, etc. The resulting fragmentation reduces the liquidity of these bonds. The CDS market, on the other hand, provides a standardized venue for the firm’s credit risk.

### Market access

Synthetics can open up the marketplace to relatively free participation by recreating the cash flow of virtually any security through a combination of instruments and derivatives. For example, we could also use a CDS to replicate the exposure of a bond. This can be helpful in a situation where the bond is difficult to obtain in the open market (e.g., perhaps there weren’t any available).

Let me provide a concrete example using Tesla 5-year bonds which are yielding 600 basis points over Treasuries:

1. Buy $100,000 of 5-year Treasuries and hold them as collateral.
2. Write (sell) a 5-year, $100,000 CDS contract.
3. Receive the interest on the Treasuries and get a 600 basis point annual premium on the CDS.

If there’s no default, the coupons on the Treasury plus the CDS premium will give the same yield as the 5-year Tesla bond. If the Tesla bond defaults, the portfolio value would be the Treasury less the CDS payout, which amounts to the default losses on the Tesla bond. So in either case (default or no default), the payoff from the portfolio (Treasuries + CDS) would be the same as owning the Tesla bond.

## What makes a good synthetic?

In some instances, synthetic product development has only been possible once a critical mass of liquidity has been attained in the underlying. There is little point in creating a synthetic if the underlying is too illiquid since it is likely to reduce the economic benefits.

Total return swaps are a good example of this process. Though the credit derivative market began to form in the early 1990s, total return swaps were not widely quoted or traded for several years. In fact, investors or speculators seeking exposure to a specific corporate bond or bond index were more likely to purchase or short the reference bond or index directly. As market makers began managing their credit portfolios more actively and quoting two-way prices on a range of credit derivatives, activity began to build, and opportunities for investors to participate in synthetic credit positions via total return swaps improved. As a robust two-way market began to form, bid-offer spreads on the synthetic compressed, attracting more end-users eager to assume or transfer credits synthetically. The market is now able to support a broad range of credit references because the underlying credit derivative market is liquid, active, and well supported.

## Why synthetics and DeFi?

There are several reasons why synthetics are useful to multiple participants in the “decentralized finance” (DeFi) ecosystem.

### Scaling assets

One of the biggest challenges in the space is bringing real-world assets on-chain in a trustless manner. One example is fiat currencies. While it’s possible to create a fiat-collateralized stablecoin like Tether, another approach is to gain synthetic price exposure to USD without having to hold the actual asset in custody with a centralized counterparty. For many users, price exposure is good enough. Synthetics provide a mechanism for real-world assets to be traded on a blockchain.

### Scaling liquidity

One of the main issues in the DeFi space is a lack of liquidity. Market makers play an important role here for both long-tail and established cryptoassets, but have limited financial tools for proper risk management. Synthetics and derivatives more broadly could help market markets scale their operations by hedging positions and protecting profits.

### Scaling technology

Another issue is the current technical limitations of smart contract platforms. We haven’t yet solved cross-chain communication, which limits the availability of assets on a decentralized exchange. With synthetic price exposure, however, traders don’t need direct ownership of an asset.

### Scaling participation

While synthetics have traditionally been available to large and sophisticated investors, permissionless smart contract platforms like Ethereum allow smaller investors to access their benefits. It would also allow more traditional investment managers to enter the space by increasing their risk management toolset.

## Synthetics in DeFi

There is actually already widespread use of synthetics in the DeFi space. Below I will provide several examples of projects utilizing synthetics along with simplified diagrams of what the asset creation flow looks like.

### Abra

Founded in 2014, [Abra](https://www.abra.com/) is the O.G. of synthetics in crypto. When an Abra user deposits funds into their wallet, the funds are immediately converted to Bitcoin and represented as USD in the Abra app. For example, if Alice deposits $100 into her Abra wallet and the price of Bitcoin is $10,000, she will receive a deposit of 0.01 BTC which will show up as $100\. Abra is able to do this by maintaining a BTC/USD peg which guarantees that Alice has the right to redeem $100, regardless of the price fluctuations of either BTC or USD. In effect, Abra is creating a crypto-collateralized stablecoin.

Furthermore, Abra immediately hedges away its risk so it could honor all trades at all times. When a user funds his or her wallet, they are effectively taking a short position on Bitcoin and a long position on the hedged asset, and Abra is taking a long position on Bitcoin and a short position on the hedged asset.

![](https://img.learnblockchain.cn/2020/12/11/16076508610866.jpg)
Purple: Real assets, Green: Synthetic assets

### MakerDAO

[Maker’s](https://makerdao.com/) Dai stablecoin is likely the most widely known and used synthetic in DeFi. By locking Ethereum as collateral, users are able to mint a synthetic asset, Dai, which maintains a soft peg to USD. In effect, Dai holders receive synthetic price exposure to USD. Similar to Abra’s design, this “collateral-backed synthetic asset” model has been popular among many other protocols.

![](https://img.learnblockchain.cn/2020/12/11/16076508831031.jpg)
Purple: Real assets, Green: Synthetic assets

### UMA

[UMA](https://umaproject.org/) provides a protocol for Total Return Swaps on Ethereum, which could provide synthetic exposure to a wide variety of assets.

The smart contract contains the economic terms, termination terms, and margin requirements of the bilateral agreement between Alice and Bob. It also requires a price feed oracle to return the current price of the underlying reference asset.

![](https://img.learnblockchain.cn/2020/12/11/16076508975582.jpg)
Purple: Real assets, Green: Synthetic assets

One implementation of the protocol has been the [USStocks](https://medium.com/uma-project/announcing-us-stock-index-token-powered-by-uma-and-dai-c394586c575a) ERC20 token, which represented the U.S. S&P 500 index and traded on the Beijing-based decentralized exchange DDEX. This was done by fully collateralizing one side of a UMA contract and then tokenizing the margin account, resulting in synthetic ownership of the long side of that contract.

### MARKET Protocol

[MARKET Protocol](https://marketprotocol.io/) allows users to create synthetic assets that track, via an oracle, the price of any reference asset. These “Position Tokens” provide bounded long and short exposure to the underlying and, together, offer a payoff structure similar to that of a bull call spread in traditional finance. Similar to Dai, the long and short tokens represent claims to a pool of collateral.

![](https://img.learnblockchain.cn/2020/12/11/16076509144321.jpg)
Purple: Real assets, Green: Synthetic assets

### Rainbow Network

The [Rainbow Network](https://rainbownet.work/) is an off-chain non-custodial exchange and payment network that supports any liquid asset. It is composed of “Rainbow channels,” a variant of payment channels where settlement balances are computed based on the current prices of other assets. In other words, the protocol nests synthetics along with other assets within a payment channel.

![](https://img.learnblockchain.cn/2020/12/11/16076509241221.jpg)
Purple: Real assets, Green: Synthetic assets

In Rainbow channels, each state represents a [contract for difference](https://en.wikipedia.org/wiki/Contract_for_difference), which is similar to a total return swap.

### Synthetix

Synthetix is an issuance platform, collateral type, and exchange that allows users to mint a range of synthetic assets. Similar to Maker, users lock up collateral to create a synthetic asset and need to repay their loan to reclaim the collateral. Users are then able to “exchange” one synthetic asset for another via an oracle. Note that there is no direct counterparty to the “exchange” — the user is effectively repricing the collateral per the oracle. That said, because of the pooled collateral mechanism, the SNX stakers collectively take on the counterparty risk of other users’ synthetic positions.

![](https://img.learnblockchain.cn/2020/12/11/16076509377583.jpg)
Purple: Real assets, Green: Synthetic assets

## Crypto-native derivatives

Synthetic representations of real assets are an important first step, but I believe the design space for derivatives in crypto is massive and largely untapped. This includes traditional derivatives that are structured for the various participants in the cryptoasset markets, as well as “crypto-native” derivatives that have not previously existed in traditional financial markets.

Below I will provide a few examples of both variants, many of which might not be feasible or have a large enough market to gain liquidity.

### Bitcoin Difficulty Swaps

The premise is to offer a hedging instrument for miners who want to mitigate the risk of an increase in difficulty reducing their expected Bitcoin production (i.e., hedging a miner’s “difficulty curve risk”). This is actually being structured and offered today by [BitOoda](http://bitooda.io/) as a financially settled product, which means that settlement is done via fiat transfer rather than renting or loaning physical compute power. At scale, it is unclear how much traction this product will get on the sell-side (i.e., who is long difficulty?) and among market makers (i.e. [swap dealers](https://www.investopedia.com/terms/s/swap-dealer.asp)). There is also the potential for large miners to manipulate the market (e.g., collude to lower difficulty).

### Hash-Power Swaps

The idea is to have a miner sell a portion of their mining capacity to a buyer, such as a fund, for cash. This gives miners a steady income stream that does not rely on the underlying cryptoasset price and gives funds exposure to a cryptoasset without having to invest in mining equipment. In other words, miners are able to hedge market risk because they do not have to rely on the market price of the cryptoasset they are mining to remain profitable. This is also being structured and offered by BitOoda via their physically settled “Hash-Power Weekly Extendable Contracts.”

### Electricity Futures

This is a product that has been available in traditional commodity markets for quite some time but could be offered to cryptocurrency miners. The miner enters into a futures agreement to purchase electricity at a given price at an agreed time in the future (e.g., three months). This provides the miner with the ability to hedge their energy risk since a sharp rise in electricity costs could make mining unprofitable. In other words, the miner turns their electricity costs from variable to fixed.

### Staking Yield Swaps

This would allow validators in Proof of Stake networks to hedge their exposure to market risk of their chosen cryptoasset. Similar to a hash-power swap, a validator would sell a portion of their staking yield in exchange for cash. This would allow the validator to receive a fixed amount on their locked assets, while the buyer would gain exposure to staking income without setting up staking infrastructure.

Staking Yield Swaps is live today on [Vest](https://vest.io/#/), which is a marketplace that allows users to purchase future staking rewards and stakers to reduce the variance of their staking rewards. The project implements this via “staking contracts,” which allows a user to pay X and receive rewards from staking Z tokens for duration T.

### Slashing Penalty Swaps

This would allow delegators in Proof of Stake networks to hedge their operational risk exposure for their chosen validator. You could think of a slashing as a credit event and the Slashing Penalty Swap as insurance against that event. If a validator gets slashed, the delegator receives a payout to cover the loss. The seller of the Slashing Penalty Swap is effectively long on the operational excellence of the validator, and it could even be the validator themselves. At scale, this could pose an interesting dilemma for protocol designers — those who are short the validator are incentivized to sabotage their operations.

### Stability Fee Swaps

While the Maker [Stability Fee](https://mkr.tools/governance/stabilityfee) is currently 16.5%, it was as high as 20.5% from July 13 to August 22, 2019\. CDP holders might want to mitigate the risk of rising stability fees (variable interest rates), and as such could enter into a swap agreement with a counterparty to pay a fixed fee (interest rate swaps) for a given time frame.

### Airdroptions

This would be an option to purchase a cryptoasset with a strike price equal to that of its airdrop. The option buyer receives a payout structure similar to that of a deep-in-the-money call option, with a premium that equals the market price of that airdrop. If the airdrop performs well, the buyer exercises the option, and the seller delivers the cryptoasset. If the airdrop does not, the buyer doesn’t exercise the option, and the seller receives the premium.

### Lockdrop Forwards

This would be a bilateral agreement for a buyer to purchase cryptoassets released from a lockdrop at a given price. The buyer pays a premium to the seller which reflects illiquidity and opportunity cost associated with their locked asset but provides the buyer with exposure to a new cryptoasset without having the underlying asset which is necessary for the lockdrop.

## Conclusion

If you’ve made it this far, consider becoming a CFA! Synthetics are complex financial instruments that have gotten the global economy in trouble many times. Similarly, they could also pose risks to protocol security in ways we do not yet understand. That said, synthetics continue to serve an important role in traditional financial markets and are becoming a key component of the DeFi movement. It is still early days in the industry, and we need more experimentation from both developers and financiers to bring new financial products to market.

Many thanks to [Dan Robinson](https://twitter.com/danrobinson) and [Matteo Leibowitz](https://twitter.com/teo_leibowitz) for their feedback on this piece.

