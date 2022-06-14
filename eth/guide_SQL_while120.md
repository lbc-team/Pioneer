原文链接：https://towardsdatascience.com/your-guide-to-intermediate-sql-while-learning-ethereum-at-the-same-time-7b25119ef1e2

![1_8jMFzunn7XGSehe9FHYBKw.jpeg](https://img.learnblockchain.cn/attachments/2022/06/xc2NBqBb62a0688a85e7c.jpeg)

Photo by [israel palacio](https://unsplash.com/@othentikisra?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/electric?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

# Your guide to intermediate SQL while learning Ethereum at the same



## Let’s make your queries more efficient and readable, and also help you understand decentralized exchanges like Uniswap on Ethereum.

*if you’re looking for more web3 data content, check out my* [*30-day free course (with videos)*](https://ournetwork.mirror.xyz/gP16wLY-9BA1E_ZuOSv1EUAgYGfK9mELNza8cfgMWPQ)*!*

If you’ve missed part one of the basics of SQL and Ethereum, be sure to [read that first](https://towardsdatascience.com/your-guide-to-basic-sql-while-learning-ethereum-at-the-same-time-9eac17a05929). On the SQL side, today we’ll cover these slightly harder topics:

1. Common Table Expressions (CTEs)
2. Self joins
3. Window functions like PARTITION, LEAD, LAG, NTILE
4. Use of indexes in querying to make operations faster.
5. Subqueries and the impact of subqueries on the efficiency of the query

On the Ethereum side, last time we learned about lending pools and collateralized debt positions. This time, I’m going to introduce you to a decentralized exchange (DEX) — think of this as a foreign exchange where you can swap the US dollar for euros but your exchange rate depends on how much of each currency is left in your local bank. Just replace “currency” with tokens ([remember the USDC smart contract I talked about last time](https://etherscan.io/token/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)) and replace the “bank” with a DEX smart contract. The DEX smart contract that we’re going to be looking at is Uniswap, which in the last week (4/11/21) processed [$8,870,691,188 worth of trades](https://duneanalytics.com/hagaetc/dex-metrics).

As per usual, there will be links to all of these queries saved on [Dune Analytics](https://duneanalytics.com/hagaetc/example-dashboard), so you can edit and run any of them whenever you want. And if you didn’t go back to the last article, then this is a primer for helping understand *what* we are querying:

> *Keep in mind, Ethereum is the* **database**, smart contracts are the **data tables**, and transactions sent from wallets are **the rows** in each table. Wallets and smart contracts have addresses, **which are always unique on Ethereum.**

# Common Table Expressions (CTEs)

Technically, Uniswap is not just a single smart contract — that would run into certain contract size limits ([24 KB](https://cointelegraph.com/news/new-standard-to-avoid-ethreum-contract-size-limitation-developed#:~:text=As Ethereum contracts can hit,developed to help combat it.)) and be extremely complicated to develop. Because of this, our queries will be heavily interlaced with subqueries to get the data we want across contracts. It isn’t efficient or really readable to put your subqueries inside your query, especially if you are using the same subquery more than once. That’s where CTEs come into play!

If you’ve written scripts in an object-oriented language before like Python, then you’re familiar with storing data in variables. CTEs are like variables for SQL, where you store a subquery as a reusable table throughout the rest of your query.

Before we get to the query, a quick detour on contract patterns. Uniswap follows a contract factory pattern, meaning there is a base template for an exchange between two tokens ([UniswapV2Pair.sol](https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2Pair.sol)) that is used for [deploying new pairs](https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2Factory.sol#L23) from the Uniswap factory contract.

![1_5f4KhQ6x9A1DfyOxYX6hgg.jpeg](https://img.learnblockchain.cn/attachments/2022/06/rI2I2mTO62a068d78f2c4.jpeg)

Image by Author ([ERC20 reference](https://docs.openzeppelin.com/contracts/2.x/api/token/erc20))

Now, let’s see if we can get all created pairs in the last month and their most recent reserve balances (i.e. how much of each token is left)

![3.png](https://img.learnblockchain.cn/attachments/2022/06/8V5iF89P62a0690c68791.png)

https://duneanalytics.com/queries/35061

Don’t be alarmed by the length! Let’s go line by line through this query. `WITH` signals the start of the CTEs, followed by our first CTE `cp` which is the set of all pairs created within the last 7 days. `r` is the set of all pairs that had their reserve balances updated in the last 7 days. `r_recent` is keeping only the most recent update for each unique pair contract (`contract_address`) from `r`. Don’t worry about `partition` and `row_number()` for now, as I’ll explain those concepts later. Lastly, I did an `INNER JOIN` of `cp` with `r_recent` on the pair contract addresses to get our final table.

![4.png](https://img.learnblockchain.cn/attachments/2022/06/WfNkFY5Q62a069a1e4511.png)

Based on the row count, we can see there were 390 new pairs created in the last 7 days. Note that pair_address is the Ethereum address of UniswapV2Pair.sol that was deployed for a specific tokenA/tokenB pair after createPair() was called from the UniswapV2Factory.sol contract.

Can you imagine doing all of this using subqueries? Not only would that be hard for others to read, but it’s also more difficult and time-consuming to debug. With CTEs, I’m able to build and test each view separately without having to wait for the whole query to re-run.

# SELF JOINS

Both the factory and pair base contracts referenced above are very low-level and not often directly called. Instead, Uniswap created a Router02 contract that abstracts away most of the contract complexity in a user/dev-friendly way. Once a new pair contract has been created, you can now add liquidity to its liquidity pool through the Router02 contract(those reserves have to get into the contract somehow!). Liquidity pools are a really important concept in decentralized finance ([DeFi](https://ethereum.org/en/defi/)), so I’ll take some time to explain it at a high level.

When adding liquidity to a pair, you’re adding liquidity on top of reserves from other liquidity providers (**LPs**). Uniswap requires you to add 50/50 of each token based on its $ value, and then you get an Uniswap pool token back representing your share of the total pool. Below is an example of someone adding liquidity through the Router02:

![5.png](https://img.learnblockchain.cn/attachments/2022/06/CEZH1MvA62a069e2b1a93.png)

[example transaction](https://etherscan.io/tx/0x036ee02f7ad27fb5248b5ec1155e0bffdc0a561065b9361d95051d951c0ff8f7) of adding liquidity to USDC/USDT pool and receiving UNI-V2 token back

When someone wants to swap one token for another, they add to reserves of one token and take from reserves of the other — thus affecting the exchange rate between the two tokens. We’ll go more into swaps and exchange rate pricing curves in the next section.

Now, let’s say we wanted to get the set of all LPs who have added liquidity to the same pools. This is where a `SELF JOIN` becomes really helpful, as we can build relationships between rows of the same column based on a second column. A good example is usually when you have a column of names and a column of locations, then you `SELF JOIN` to show [who (original column of names) lives in the same location as who (duplicate column of names)](https://www.w3schools.com/sql/sql_join_self.asp). So here, we have a column of LPs by address and we want to see which LPs are adding liquidity to the same pools.

![6.png](https://img.learnblockchain.cn/attachments/2022/06/j9TIFY1u62a06a0c44f7d.png)

https://duneanalytics.com/queries/35058

My query creates a CTE of the unique LPs that added liquidity to each token pair in the last 7 days in `LP`. In the final query, I used `CASE WHEN` to make the column more readable than contract addresses (stored in `pair` ), this is just an “if-else” statement. The key to the `SELF JOIN` is in the last two lines where I am selecting all LPs that provided to the same pool as the selected anchored LP. This will then loop through the table and list related LPs for each pair contract, so if I have 4 LPs providing to the same pair contract then I would end up with 12 rows (4 uniques acting as anchors, 3 rows/related_lps per anchor). The “not equal to” operator `<>` in line 20 makes sure we skip the anchor, otherwise that will show up as a row too. Lastly, line 21 acts as the `ON` operator a typical join would have for us to join `LP1` and `LP2`.

![7.png](https://img.learnblockchain.cn/attachments/2022/06/PK3QIxiB62a06a36cfc6c.png)

Note that WETH is the same as ETH, it's just in a token wrapper for standard consistency

If your column has a lot of unique ids that share a target column, then this query will quickly run out of memory (we’ll come back to this when discussing correlated subqueries at the end of this article). That’s why I limited the date interval and pre-selected two token pairs (otherwise 77,000 LPs and 10,000 pairs would probably have over one million rows). We won’t do anything else with this data right now, but we could use it to start clustering users or perform graph node analysis of the liquidity pool markets across pairs.

# Window functions like PARTITION, LEAD, LAG, NTILE, etc

*By this point we’ve already introduced a lot of new concepts, so you may be feeling overwhelmed. If so, go take a break or play with the linked queries, don’t force yourself through all of this at once!*

In this section we will be going over swaps, such as if I wanted to swap my WETH for USDC. To understand this, we need to cover how a DEX prices a swap:

> x*y = k

It’s a pretty straightforward formula! `x` is the contract’s reserve of WETH, `y` is the contract’s reserve of USDC, and `k` is their total liquidity. This gives us a pricing curve that looks like this:

![8.jpg](https://img.learnblockchain.cn/attachments/2022/06/5Y1xHoGD62a06a5eb85e6.jpg)

https://uniswap.org/docs/v2/protocol-overview/how-uniswap-works/

This means as I swap token A for token B, the reserve of token A increases, and the reserve of token B decreases and makes future swaps of token A for token B marginally more expensive. If this makes sense to you, then pat yourself on the back — no more new Ethereum concepts for the rest of the article!

But there is still a lot of SQL left to learn, starting with window functions. Think of these as allowing aggregations, offsets, and statistical functions without needing to use `GROUP BY` and keeping the original table unchanged — you’re just adding columns based on values in each row instead.

Typically we have some special function followed by `OVER` and then the window `(PARTITION BY column_name)`. Earlier, our special function was `ROW_NUMBER()` which counted new rows `rn` starting from 1 for each unique partition (in that case each unique pair contract in `contract_address`). That’s how we were able to keep just the most recent row of each pair contract reserve sync (`rn=1`).

```
ROW_NUMBER() OVER (PARTITION BY contract_address) rn
```

Another way to think of the window/`PARTITION` is as the column you were originally using for `GROUP BY` , though it can be a column with only a single unique value too. Let’s try and calculate the percentiles for *all swaps going from WETH to USDC* over the last 7 days. We’re still using the Router02 contract, but on the `swapExactTokensForTokens()` function instead of `addLiquidity()`.

![9.png](https://img.learnblockchain.cn/attachments/2022/06/zpaMaQ5662a06a89124c9.png)

https://duneanalytics.com/queries/35980

Here we used the statistics function `NTILE()` instead of the counter `ROW_NUMBER()` . `NTILE()` will assign a tile to each row based on how many tiles total (quartile `NTILE(4)`, quintile `NTILE(5)`, percentile `NTILE(100)`, etc). Since we’re using the same window twice then we can create a `WINDOW` variable to reduce verbosity. `contract_address` has only one unique value for the whole column since it is always Router02 being called, otherwise we would have multiple partitions and each unique value in `contract_address` would get its own set of 100 `NTILE` s.

Here’s a chart showing our query results:

![10.png](https://img.learnblockchain.cn/attachments/2022/06/ItBrQUw262a06aca22002.png)

Visualization tells more than the table here. This data is heavily skewed, so technically logarithmic would have been a better view.

For using aggregations with windows, there are some [basic examples here](https://mode.com/sql-tutorial/sql-window-functions/) you can follow as I won’t show any here. I do want to cover offset functions like `LEAD` and `LAG` , as those are very useful for time series trend analysis.

![11.png](https://img.learnblockchain.cn/attachments/2022/06/qfiD5Vfl62a06b0192570.png)

https://duneanalytics.com/queries/36082

Here we create a CTE called `DAL` to represent the daily total `amountIn` of WETH to USDC swaps over the last 28 days. Then we create two `LAG` columns when querying from `DAL`, one at a 1 row (day) lag and another at a 7 row (day) lag:

![12.png](https://img.learnblockchain.cn/attachments/2022/06/xuS02Drl62a06b27bd028.png)

If we add an `ETH_swapped_to_USDC -` in front of each `LAG` column, then we can get the daily and weekly difference in swaps volume:

![13.png](https://img.learnblockchain.cn/attachments/2022/06/gI22SP4c62a06b500087f.png)

I changed the query from 28 days to 100 days to give us more a better chart to look at.

# Use of indexes in querying to make operations faster.

Any time you make a query, an execution plan runs based on the operations in your script. While a lot of the optimization is handled for you, you want to organize both your query and your table in a way that is most efficient. We’ll cover the ordering of subqueries in the next section, first let’s talk about indices.

If a column is a primary key that means you can create a clustered index that is linked to it. If a column is a foreign key (non-unique values), you can attach a non-clustered index to it. Having these indices is leads to large differences when querying data, especially when it comes to using `WHERE` and/or `JOIN`. Without an index, your query will run as a table scan (i.e. linearly through each row). With an index, an index scan/seek is run instead. This is the difference between a binary search versus a linear search, [leading to O(log n) versus O(n) search time](https://stackoverflow.com/questions/700241/what-is-the-difference-between-linear-search-and-binary-search#:~:text=A linear search looks down,at a time%2C without jumping.&text=A binary search is when,second half of the list.). Ultimately, creating indices leads to longer write times (since each time new data is added the indices must be reordered), but you end up with much faster read times. If you want a longer walkthrough and comparison of indexed versus not indexed queries, I highly recommend you check out [this video](https://www.youtube.com/watch?v=toGvjN5mfp8).

Even if the table doesn’t have an index, you can improve the linear scan by using `ORDER BY` on the columns you are filtering or joining on. This can make the query much more efficient, especially for joins.

# Subqueries and the impact of subqueries on the efficiency of the query

Lastly, let’s talk about subqueries. There are two types of subqueries, correlated subqueries where the subquery must be reevaluated for every row of the outer query, and non-correlated subqueries where the subquery is evaluated only once and then used as a constant for the outer query.

The following is a non-correlated subquery, since `SELECT MAX(“amountIn”)/2 FROM swaps` is only evaluated one time before checking against each row of `“amountIn”` in the outer query.

![14.png](https://img.learnblockchain.cn/attachments/2022/06/Akg6vld862a06b7b584e6.png)

https://duneanalytics.com/queries/36434

![15.png](https://img.learnblockchain.cn/attachments/2022/06/dN3uMHnP62a06bac4aaa8.png)

There were only 4 swaps that were larger than half the maximum swap in the last 7 days, which makes sense given the NTILE(100) chart from earlier.

This next query is a correlated subquery, which looks very similar to a `SELF JOIN` but only compares rows with itself instead of joining. We want to get only the above average swap amounts for each pair in Uniswap:

![16.png](https://img.learnblockchain.cn/attachments/2022/06/P5TATId462a06beb901ad.png)

https://duneanalytics.com/queries/36436 Note that I’m checking where the swap path is the same since that usually represents a token pair.

Even though this is still an aggregate function comparison (using AVG instead of MAX), this one timed out after more than 30 minutes while the non-correlated query took less than 5 seconds. You can make this query faster by turning the correlated subquery into a join subquery instead — it just takes a few mental hoops. We cut it down to 28 seconds with this method:

![17.png](https://img.learnblockchain.cn/attachments/2022/06/6dojBXIT62a06c19baa8e.png)

https://duneanalytics.com/queries/36436 (extension of last query)

![18.png](https://img.learnblockchain.cn/attachments/2022/06/Zgjk14Ni62a06c3f36c3b.png)

some paths are more than one swap, I think this exists if there isn’t a direct pair to swap so it has to go Token A -> WETH -> Token B

If you absolutely have to use a correlated subquery, you should take advantage of the indexes we talked about in the last section — otherwise it can take a very long time to run as it becomes an `n_rows*n_rows = O(n²)` comparison operation.

Lastly, if multiple subqueries are in any parent query make sure that all the subqueries are ordered in the most efficient manner. Especially when it comes to joins, make sure you are filtering with `WHERE` and `HAVING` *before* you join and not afterwards. If your query is taking too long, try to think through the types of subqueries and other options you have in terms of logic and ordering to make it faster. This is another example where breaking the subqueries down into CTEs can help you re-organize and deploy your code in a much faster and cleaner way.

# You made it (again)!🎉

If you made it this far (again), then congrats! You now know how to do more advanced and faster queries using SQL. If you want to understand Ethereum some more, [check out my other article](https://medium.com/coinmonks/crypto-and-web-3-0-are-the-future-of-product-and-work-3d19e3733181) that goes deeper into how it all works.

If you haven’t clicked any of the query links yet, I highly recommend doing so as Dune Analytics is a great place to test queries and also create visualizations or even dashboards quickly. I wish I had a tool like this to practice with when I started learning SQL, rather than relying on tables from hackerank or leetcode (or messing with a local server and filling it with basic mock data tables from online).

Keep an eye out for the last part of this series!