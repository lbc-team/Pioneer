# [译]智能合约间权限控制的协作模式



> * 原文链接: https://hackernoon.com/identifying-smart-contract-orchestration-patterns-in-solidity-pd223x20 作者: [@albertocuestacanada](https://hackernoon.com/u/albertocuestacanada)



![9nMyFjQNicRJ5HwksmBytJBySMi2-ln112x17](https://img.learnblockchain.cn/pics/20200908220800.jpeg)





除那些最简单的以太坊应用，大部分应用程序都由几个智能合约组成。这是因为在任何已部署的智能合约都受到[24KB](https://blog.ethereum.org/2016/11/18/hard-fork-no-4-spurious-dragon/)的硬限制，并且随着智能合约的复杂性增加，烦恼也会随之增加。



## 合约之前如何安全的协作



一旦将代码分解为可管理的智能合约，你就会发现一个智能合约具有仅由另一个智能合约调用的函数。



举个例子，在[Uniswap v2](https://github.com/Uniswap/uniswap-v2-core/tree/master/contracts)中，只有合约工厂应该初始化Uniswap 交易对（pair）。

> 译者注： 工厂是指用来创建其他对象的对象，这在面向对象中称为工厂模式，在本文中的对象指的是合约。

```js
// called once by the factory at time of deployment
function initialize(address _token0, address _token1) external {
    require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
    token0 = _token0;
    token1 = _token1;
}
```



Uniswap团队通过一个简单的检查就解决了他们的问题，但是只要随便找找，都能找到更多个项目从头开始编写合约协作方案的例子。



在理解此问题并开发协作模式的过程中，我们更好地了解了如何从多个智能合约中构建应用程序，这也使[Yield协议](http://yield.is/)更加健壮和安全。





在本文中，我将通过著名项目中的示例深入研究智能合约协作模式。当你读完它时，将能够查看你自己项目的协作需求，并决定适合你的方法。



我创建了这个[示例代码库](https://github.com/albertocuestacanada/Orchestrated)帮助你继续前行。



## 背景



因为有两个限制（一个是技术上的限制，一个是设计上的考量）。 需要将你的项目分解为一系列智能合约，我之前也有提到。



技术限制是在2016年11月实施的[Spurious Dragon](https://blog.ethereum.org/2016/11/18/hard-fork-no-4-spurious-dragon/)硬分叉，  硬分叉包括[EIP-170](https://learnblockchain.cn/docs/eips/eip-170.html)。此更改将部署的智能合约的大小限制为最大24576字节。



如果没有此限制，攻击者便可以部署进行无限量的计算（部署期间）智能合约，它不会影响存储在区块链中的任何数据，但可以当作为对以太坊节点的拒绝服务攻击（Denial-Of-Service attack）。



当时 gas limit 也不允许使用这种规模的智能合约，因此这种变化被认为是[非破坏性](https://github.com/ethereum/EIPs/issues/170)的：



> 解决方案是对可以保存到区块链中的对象的大小设置硬上限，并通过将上限设置为略高于当前gas limit 的可行值来进行无中断操作， 最欢的情况是使用470万gas 创建 〜23200字节的智能合约，通常创建的智能合约大概是〜18 kb





那是在DeFi爆炸之前。对于Yield协议，我们编码了2000行智能合约代码，部署后的总和将接近100 KB。我们的审计人员甚至不认为我们的项目非常复杂。



但是，我们仍然必须将项目分解为多个智能合约。



### 复杂性与面向对象程序设计



将区块链应用分解为多个智能合约的第二个原因与技术限制无关，而与人的（认知）限制有关。



我们在一个特定的时间只能在大脑中保存那么多信息。如果我们更擅长处理以有限方式相互作用的小问题，而不是处理一个单一的大问题（所有事物都能相互作用的问题）。



可以说，面向对象编程使软件可以达到更高的复杂度。通过定义代表某种概念的“对象”，并将变量和函数定义为对象的属性，开发人员可以更好地从心理上解决他们要解决的问题。



[Solidity](https://learnblockchain.cn/docs/solidity/)使用面向对象编程，但在智能合约级别。你可以将智能合约视为具有变量和功能的对象。复杂的区块链应用程序将更容易在你的脑海中映射为一组智能合约，每个智能合约代表一个实体。



例如在MakerDAO中，每种加密货币都有单独的智能合约，记录债务的另一个智能合约，代表债务库和外部世界之间的网关也是单独智能合约等。试图在单个智能合约中编写所有代码可能是不可能的。即便可以也是很难的。



将大问题分解为以有限方式交互的小问题确实有帮助。



## 实现



在接下来，我们将研究[Uniswap](https://learnblockchain.cn/tags/Uniswap)，MakerDAO和Yield的业务流程实现。这会很有趣的。



### 简单的协作  Uniswap 和 Ownable.sol



我喜欢Uniswap v2，因为它太简单了。他们成功的在410行智能合约代码中建立了非常成功的去中心化交易所。它们只有两种部署的智能合约：一个工厂合约和不限数量的交易对合约。



由于他们工厂合约的设计方式，新的交易对合约的部署需要两个步骤。首先部署智能合约，然后使用将要交易的两个代币（[Token](https://learnblockchain.cn/tags/ERC20)）对其进行初始化（参考第一部分出现的代码）。



我不知道他们是如何保护自己不受攻击的，但他们需要确保只有创建配对交易工厂合约的才能初始化该合约。为了解决这个问题，他们重新实现了`Ownable`模式。



```js
address public factory;

constructor() public {
	factory = msg.sender;
}
```



如果你的案例和他们的一样简单，你也会成功的。如果你知道你的智能合约只需要授予对另一个智能合约的特权访问权，那么你可以使用`Ownable.sol`. 

你甚至不需要使用像Uniswap这样的工厂。你可以部署两个智能合约（`Boss`和`Minion`，`Minion`继承自`Ownable.sol`），然后执行`minion.transferOwnership(address(boss))` 。



### 复杂的协作 — Yield协议



对于Yield协议，我们没有设法编写像Uniswap v2一样简单的解决方案。我们的核心合约有五个，特权访问关系不是一对一的。一些智能合约具有受限制的函数，我们需要将这些函数提供给核心合约中的多个智能合约。



因此，我们将`Ownable.sol`扩展为具有两个访问层，其中之一具有多个成员：



```js
contract Orchestrated is Ownable {
    event GrantedAccess(address access);
    
    mapping(address => mapping(bytes4 => bool)) public orchestration;
    
    constructor() Ownable() {}
    
    /// @dev Restrict usage to authorized users;
    modifier onlyOrchestrated(string memory err) {
        require(orchestration[msg.sender][msg.sig], err);
        _;
    }
    
    /// @dev add orchestration
    function orchestrate(address user, bytes4 sig) public OnlyOwner {
      orchestration[user][sig] = true;
      emit GrantedAccess(user);
    }
    

}
```



智能合约所有者可以将任何地址添加到特权列表（`authorized`）。继承合约可以包括`onlyOrchestrated`修饰器，该修饰器将限制对注册地址的访问。



作为附加的安全检查，每个地址都与[函数签名选择器](https://learnblockchain.cn/docs/solidity/abi-spec.html#function-selector)一起注册，从而缩小了在[Orchestrated合约](https://github.com/albertocuestacanada/Orchestrated)中对单个函数的访问范围。检查[代码库](https://github.com/albertocuestacanada/Orchestrated)以获取有关此内容的详细信息。



没有函数用来撤消访问权，因为我们在部署过程中对智能合约进行的`orchestrate`，然而 `owner` 可以通过对所有智能合约调用`transferOwnership(address(0))` 放弃自己的访问特权。



我们自己的平台代币 `yDai` 将从`Orchestrated`继承，并将`mint`限制为在部署期间设置的特定智能合约（在`owner` 放弃自己的访问特权之前设置的）。



```js
/// @dev Mint yDai, Only callable by Controller contracts.
function mint(address to, uint256 yDaiAmount) public override onlyOrchestrated("YDai: Not Authorized") {
    _mint(to, yDaiAmount);
}
```



这种模式相对易于实现和调试，并允许我们实现仅应由我们控制的合约使用的函数。



### 复杂的协作— MakerDAO



MakerDAO因使用荒谬的术语而臭名昭著，这使其非常难以理解。直到我分解Yield问题之后，我才意识到他们使用的实现几乎完全相同。




```js
// -- Auth -- 
mapping(address => uint) public wards;

function rely(address usr) external note auth {
  require(live == 1,  "Vat/not-live");
  wards[usr] = 1;
}

function deny(address usr) external note auth {
  require(live == 1,  "Vat/not-live");
  wards[usr] = 0;
}

modifier auth {
  require(wards[msg.sender] == 1, "Vat/not-authorized");
  _;
}

```

```
// --- Init ---
constructor() public {
   wards[msg.sender] == 1;
   live = 1;
}
```


1.  智能合约部署者是wards的最初授权成员。

2. `wards`   可以通过  `rely`   添加其他的 ( `usr` ) 成为 `wards`  成员.

3. 函数访问通过 (`auth` ) 来限制，以便 `wards` 成员能执行。



例如，MakerDAO的`Vat.sol`合约中的`fold`函数用于更新利率累加器，并且只能由其集合中的另一个合约调用（`Jug.sol`合约，`drip`函数）。如果你查看该函数，将看到`auth`修饰符，以下是他们的代码：




```js
// rates
function fold(bytes32 i, address u, int rate) external note auth {
  require(live == 1, "Vat/not-live");
  Ilk storage ilk = ilks[i];
  ilk.rate = add(ilk.rate, rate);
  int rad = mul(ilk.Art, rate);
  dai[u]  = add(dai[u], rad);
  debt = add(debt, rad);
}
```



在某种程度上，`auth`和其他协作实现是`private`和`internal`函数概念的扩展，他们是仅用于智能合约之间的访问控制。



MakerDAO的实现与我们自己想到的实现非常相似。



1. 智能合约部署者是 wards的最初授权成员。在Yield协议中它是`owner`。
2. `wards`   可以通过  `rely`   添加其他的 ( `usr` ) 成为 `wards`  成员，在Yield中，只有`owner`可以通过`orchestrate`把其他地址指定为`authorized`。
3. 函数可以被限制（`auth`），这样只有`wards`才能执行它们。在Yield中，我们说只有经过`onlyOrchestrated`的地址才能调用被标记的函数。我们进一步限制对单个函数的访问权限。



除了在Yield中我们使用了两个访问层（`owner`和`authorized`）和单个函数限制，实现是相同的。智能合约协作是一种通用模式，可以实现一次并经常重用。



为了使审计员和用户更加满意，我们还开发了一个脚本，该脚本[可追踪区块链事件](https://medium.com/coinmonks/smart-contracts-are-not-databases-5bb5926223be)并描绘我们智能合约的所有权和合约授权。该脚本可从我们的网站上线获取，并证明除部署时设置的智能合约外，没有人拥有过特权访问它们。



毕竟，这就是智能合约协作的重点。





## 结论



智能合约的协作权限控制是一个在大多数项目中都会重复出现的问题，并且大多数项目都是从头开始实施的。通常所实现的解决方案彼此几乎相同。



当一个实现协作权限控制的典型标准出现时，我们就会更安全和高效，请使用本文中的示例去理解和实先满足你要求的解决方案。 如果适合，可以使用[示例代码库]（https://github.com/albertocuestacanada/Orchestrated）中的代码。




感谢 [Allan Niemerg](https://twitter.com/niemerg), [Dan Robinson](https://twitter.com/danrobinson) 和 [Georgios Konstantopoulos](https://twitter.com/gakonst) 给我在编写Yield合约时的杰出的反馈。

