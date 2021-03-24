> * 原文：https://consensys.net/diligence/blog/2019/09/factories-improve-smart-contract-security/
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)




# 使用工厂提高智能合约安全性



智能合约可以部署其他智能合约，通常称为[工厂模式](https://en.wikipedia.org/wiki/Factory_(object-oriented_programming))，让你不是创建一个合约跟踪很多事情，而是创建多个智能合约，每个合约只跟踪各个的事情。 使用这种模式可以简化合约代码，减少某些类型的安全漏洞的影响。

在这篇文章中，我将带你了解一个例子，这个例子是基于最近的一次审计中发现的一个关键漏洞修改而来。 如果使用了工厂模式，这个漏洞就不会那么严重了。

## 一个错误的智能合约

下面是一个智能合约，通过一个相当简单的接口来出售 WETH。 如果你有WETH，你只需要 `approve（授权） `这个智能合约来出售你的代币，它将确保你得到正确的金额。 只要批准了足够的代币，任何人都可以向你购买WETH 。

合约采用[提现模式](https://learnblockchain.cn/docs/solidity/common-patterns.html#withdrawal-pattern)向卖家交付出售所得的ETH，但合约作者却犯了严重错误，代码如下：

```javascript
 // 技术上可以实现出售任何代币，但这个例子仅出售  WETH 。
  // 因为这里不想关注价格. 1 WETH = 1 ETH.
 contract WETHMarket {
     IERC20 public weth;
     mapping(address => uint256) public balanceOf;
 
     constructor(IERC20 _weth) public {
         weth = _weth;
     }

    // 从指定的seller购买 WETH . seller 需要先授权 WETH.
    function buyFrom(address seller) external payable {
        balanceOf[seller] += msg.value;
        require(weth.transferFrom(seller, msg.sender, msg.value),
            "WETH transfer failed.");
    }

    // 出售者调用，提取ETH
    function withdraw(uint256 amount) external {
        require(amount <= balanceOf[msg.sender], "Insufficient funds.");

        // Whoops! Forgot this:
        // balanceOf[msg.sender] -= amount;

        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "ETH transfer failed.");
    }
}
```

如果你想知道为什么代码使用`.call`而不是`.transfer`，请阅读[停止使用transfer()](https://learnblockchain.cn/article/2191))。

由于卖方的余额永远不会减少，所以，一个有以太币余额的卖方，只需反复调用`withdraw()`，就可以将合约中所有人的以太币耗尽。 这是一个严重的漏洞。

修复这个bug，就像大多数bug一样，一旦你发现了它，就会变得很容易。 但在这篇文章中，我想谈谈如何通过使用工厂模式来减轻这个bug，即使我们对这个问题一无所知。

## 更小责任的合约

现在让我们来看一个更简单的 `WETHMarket `合约的版本。 在这个版本中，合约只负责销售单个卖家的WETH。 这个合约与之前的版本有同样的BUG。

```javascript
 contract WETHSale {
     IERC20 public weth;
     address seller; // 仅对一个 seller 有效
     uint256 public balance; // 不在需要mapping
     
     constructor(IERC20 _weth, address _seller) public {
         weth = _weth;
         seller = _seller;
     }

    // 不用再指定 seller.
    function buy() external payable {
        balance += msg.value;
        require(weth.transferFrom(seller, msg.sender, msg.value));
    }
    
    function withdraw(uint256 amount) external {
        require(msg.sender == seller, "Only the seller can withdraw.");
        require(amount <= balance, "Insufficient funds.");

        uint256 amount = balance;
        
        // Whoops! Forgot this:
        // balance -= amount;
        
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "ETH transfer failed.");
    }
}
```

尽管是完全相同的逻辑错误，但这个漏洞却没有那么严重。 只允许一个账户调用`withdraw()`，反正合约中存储的所有以太币都属于该账户。 这个bug的影响只是`balance`不能反映合约中的真实余额。

这个bug是为了显示工厂的好处而精心挑选的，但这个bug是围绕“托管”的一大类bug的代表。 根据我们审计智能合约的经验，这是最常见的出现关键漏洞的地方之一。

托管背后的理念是，不同的资金必须分开，以确保合约能够始终覆盖所有的欠款。 要想做好托管，最简单的方法之一就是将资金完全分离到不同的智能合约中。

你可以把工厂模式看成是一种深入防守的托管方式。

## 简单的代码

单个卖家版合约不仅有更鲁棒的托管功能，也更简单。 我们去掉了一个函数参数和一个映射。 在生产代码中，我们可能会更进一步，**完全删除`balance`，**改为`address(this).balance`。

因为这里写的合约是专门为了方便阅读，所以代码非常简单。 在现实世界的例子中，差别可能会更大。 从安全角度来看，任何降低复杂性的机会都是一种胜利。

## 工厂模式

如果不使用工厂模式，那么每个卖方可以直接部署自己的`WETHSale`合约，并因此获得较简单合约的好处，但这种方法有一个主要缺点。 恶意卖家可以部署一个稍加修改的代码版本，实际上并没有转账WETH。

即使有信誉的公司对 `WETHSale `代码进行了审计，每个买方也必须核实自己他们购买的具体合约是否使用了该代码。

使用工厂可以解决这个问题。 工厂确保每个部署的合约都使用相同的代码，它提供了一个简单的查找机制，以找到给定卖方的合约。

```javascript
contract WETHSaleFactory {
    IERC20 public weth;
    mapping(address => WETHSale) public sales;
    
    constructor(IERC20 _weth) public {
        weth = _weth;
    }

    function deploy() external {
        require(sales[msg.sender] == WETHSale(0), "Only one sale per seller.");
        
        sales[msg.sender] = new WETHSale(weth, msg.sender);
    }
}
```

## 工厂模式潜在的缺点



使用工厂模式的一个主要缺点是，它的Gas 较高。 `CREATE`操作码目前的Gas成本为32000。 我们这个特殊的合约还得多做两个`SSTORE`来记录WETH和卖家地址，每一个都要花费2万Gas。 这比原来的多个卖家版至少多了7.2万Gas。

另一个潜在的缺点是复杂性。 在大多数实际情况下，工厂模式简化了你现有的合约，但请记住，它也增加了一个新的合约：工厂本身。 根据你的代码，这可能会产生增加复杂性的净效果。

在做出工厂模式的决定之前，要仔细考虑改变的整体影响。

## 小结

- 围绕托管的错误是造成关键漏洞的重要原因。
- 使用单独的智能合约可以降低这些bug的严重性。
- 工厂模式以一种去信任的方式实现了这一点。
- 在采用工厂模式之前，还要考虑潜在的弊端。

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。