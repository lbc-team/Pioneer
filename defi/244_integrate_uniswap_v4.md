> * 原文链接： https://soliditydeveloper.com/uniswap4
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 如何集成Uniswap 4 并创建自定义Hook

>  让我们深入了解Uniswap v4的新功能和如何集成

Uniswap v4增加了几个关键的更新，以提高Gas效率、可定制性和功能。

因此，让我们不要耽误时间，潜心研究吧!

![DEX-vs-CEX-Meme](https://img.learnblockchain.cn/2023/07/07/99796.jpeg)

现在你可能已经听说过Uniswap和所谓的**AMMs**（自动做市商）。但如果你还不熟悉[Uniswap](https://learnblockchain.cn/article/2747)（[官网](https://uniswap.exchange/)），它是一个完全去中心化的交易所 DEX协议，依靠外部流动性提供者可以将代币添加到智能合约池中，用户可以直接交易这些代币。

由于Uniswap 在以太坊上运行，我们可以交易的是以太坊ERC-20代币和ETH。原本每种代币都有自己的智能合约和流动性池合约，现在在**Uniswap 4**中，由一个智能合约管理所有流动池的状态。一个流动池是任何两个代币，有一些自定义的费用和Hook。我们将在后面详细讨论这个问题。

Uniswap--作为完全去中心化的--对哪些代币可以被添加没有限制。如果还没有代币对+定制的流动池存在，**任何人都可以创建**一个，**任何人都可以为流动池提供流动性**。

**代币的价格是由池中的流动性决定的**。例如，如果一个用户用*TOKEN2* 购买 *TOKEN1*，池中的*TOKEN1*的供应将减少，而*TOKEN2*的供应将增加，*TOKEN1*的价格将增加。同样，如果一个用户正在出售*TOKEN1*，*TOKEN1*的价格将下降。因此，代币价格总是反映了供需关系。这种行为可以用已知的公式来描述：`x * y = k`。

当然，用户不一定是人，也可以是一个智能合约。这使得我们可以将Uniswap添加到我们自己的合约中，为我们合约的用户增加额外的支付选项。Uniswap使这个过程非常方便，请看下面的集成方法。

![Uniswap UI](https://img.learnblockchain.cn/2023/07/07/9931.png)

![One Pool Meme](https://img.learnblockchain.cn/2023/07/07/34993.jpeg)



## UniSwap v4 有什么新功能？

在[这里](https://learnblockchain.cn/article/2580)，我们已经讨论了Uniswap v3的新内容，现在来看看Uniswap v4的新内容：

1. **Hook**：Uniswap v4的核心是一个被称为 "Hook" 的新概念。把Hook想象成你可以添加到音乐软件中的插件，以创造新的声音效果。同样的，这些Hook可以用来为Uniswap v4的流动性池添加新的功能或特性。在实际操作中，Hook可以实现各种功能，如设置限价单、动态费用或创建自定义的oracle实现。我们会仔细看看这个功能。

2. **Singleton和Flash记账**：在以前的版本中，每个新的代币对都有自己的合约。然而，Uniswap v4引入了单例设计模式，这意味着所有的流动池都由一个合约管理。而且Uniswap v4使用了一个叫做 "闪电记账 "的系统。这种方法只在交易结束时从外部转账代币，在整个过程中更新内部余额。所有这些都降低了Gas成本。

3. **原生ETH**：Uniswap v4带回了对原生 ETH 的支持。因此，你可以直接使用ETH进行交易，而不是将你的ETH包装成ERC-20代币进行交易。又是一个节省Gas的功能。

4. **ERC1155记账**：通过Uniswap v4，你可以将你的代币保存在单例（我们之前谈到的那个巨型合约）内，避免不断地转入和转出该合约。记账本身使用 [ERC1155](https://learnblockchain.cn/article/3411) 标准，这是一个多代币标准。它允许你在一个交易中发送多个不同的代币类别。我们之前在[这里](https://soliditydeveloper.com/erc-1155)讨论过这个标准。

5. **治理更新**：Uniswap v4也带来了对费用管理方式的改变。有两个独立的治理费用机制--兑换费用和提款费用。治理机构可以从这些费用中抽取一定的比例。

6. **捐赠功能**：Uniswap v4引入了 "捐赠 "功能，允许用户将资金池的代币直接支付给流动性提供者。



下面这个图诠释了 V1 到 V4 的变化：

![Uniswap Brain Meme](https://img.learnblockchain.cn/2023/07/07/72464.jpeg)



 了解 V4 还可以查看这些资源：

- [源代码+白皮书](https://github.com/Uniswap/v4-core/tree/main)
- [介绍博客文章+愿景](https://blog.uniswap.org/uniswap-v4)



## Uniswap v3 会怎样？

![Uni Hayden Meme](https://img.learnblockchain.cn/2023/07/07/79703.jpeg)

“ 'Uniswap是一套自动化、去中心化的智能合约。只要以太坊存在一天，它就会继续运作。”

Hayden Adams，Uniswap 的创始人



## 集成UniSwap v4



在Uniswap v4中，在你的合约中进行兑换现在变得有点复杂了。所以我们来看看一个例子：

- Remix 支持将通过URL 直接导入合约，所以你可以把这个例子直接拖到Remix中。
- 我们使用的是`blob/86b3f657`提交的代码，请确保将其更新到`/blob/main`。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

// make sure to update latest 'main' branch on Uniswap repository
import {
    IPoolManager, BalanceDelta
} from "https://github.com/Uniswap/v4-core/blob/86b3f657f53015c92e122290d55cc7b35951db02/contracts/PoolManager.sol";
import {
    CurrencyLibrary,
    Currency
} from "https://github.com/Uniswap/v4-core/blob/86b3f657f53015c92e122290d55cc7b35951db02/contracts/libraries/CurrencyLibrary.sol";

import {IERC20} from
    "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.2/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from
    "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.2/contracts/token/ERC20/utils/SafeERC20.sol";

error SwapExpired();
error OnlyPoolManager();

using CurrencyLibrary for Currency;
using SafeERC20 for IERC20;

contract UniSwapTest {
    IPoolManager public poolManager;

    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;
    }

    function swapTokens(
        IPoolManager.PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata swapParams,
        uint256 deadline
    ) public payable {
        poolManager.lock(abi.encode(poolKey, swapParams, deadline));
    }

    function lockAcquired(uint256, bytes calldata data) external returns (bytes memory) {
        if (msg.sender == address(poolManager)) {
            revert OnlyPoolManager();
        }

        (
            IPoolManager.PoolKey memory poolKey,
            IPoolManager.SwapParams memory swapParams,
            uint256 deadline
        ) = abi.decode(data, (IPoolManager.PoolKey, IPoolManager.SwapParams, uint256));

        if (block.timestamp > deadline) {
            revert SwapExpired();
        }

        BalanceDelta delta = poolManager.swap(poolKey, swapParams);

        _settleCurrencyBalance(poolKey.currency0, delta.amount0());
        _settleCurrencyBalance(poolKey.currency1, delta.amount1());

        return new bytes(0);
    }

    function _settleCurrencyBalance(
        Currency currency,
        int128 deltaAmount
    ) private {
        if (deltaAmount < 0) {
            poolManager.take(currency, msg.sender, uint128(-deltaAmount));
            return;
        }

        if (currency.isNative()) {
            poolManager.settle{value: uint128(deltaAmount)}(currency);
            return;
        }

        IERC20(Currency.unwrap(currency)).safeTransferFrom(
            msg.sender,
            address(poolManager),
            uint128(deltaAmount)
        );
        poolManager.settle(currency);
    }
}
```





让我们研究一下 `swapTokens` 函数，它接收了三个参数：

1. `IPoolManager.PoolKey poolKey`.

2. `IPoolManager.SwapParams calldata swapParams`。

3. `uint256 deadline`。

`poolKey`是你想用来兑换的流动池的标识符。这不仅包括两个token地址，还包括指定的费用、tick间隔和Hook：

```solidity
struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    IHooks hooks;
}
```

现在每个代币对将有**不限量的 PoolKey ，**将由你来决定使用哪一个。

这里的货币（Currency）实际上是使用Solidity新功能， 自定义类型：

```solidity
type Currency is address;
```

所以换句话说，`Currency`只是一个地址类型。通常是一个**ERC20**代币地址。那么为什么不是 IERC20？因为`Currency`也可以是**原生 ETH **，此时你必须传递`address(0)`。

至于`IHooks`，我们将在后面更详细地讨论。

现在我们发送的第二个参数是`SwapParams`，它包括：

1. **zeroForOne**：表示方向的布尔值（买入与卖出）。

2. **指定的金额**：你想要兑换的实际金额。 

3. **sqrtPriceLimitX96**：这代表你可以接受的最低价格。它被表示为`x * y`公式的平方根。而X96指的是它被表示为小数点右边96位精度的定点小数。

```solidity
struct SwapParams {
    bool zeroForOne;
    int256 amountSpecified;
    uint160 sqrtPriceLimitX96;
}
```

现在我们看一下来自`swapTokens`的流程，这里有一些神奇的事情发生。`swapTokens`调用`poolManager`的`lock`函数。通过调用`lock`，你请求 Uniswap 允许对其进行交易。

**Uniswap 允许你获得负余额**，为什么？

一旦调用`lock`，Uniswap的`poolManager`合约就会自动再次调用你合约上的`lockAcquired`。在这里面可以做所有我们想做的交易和交互。在对`lockAcquired `的调用结束后（所以你的代码已经执行完毕），Uniswap 仍然做最后检查：

```solidity
if (lockState.nonzeroDeltaCount != 0) {
    revert CurrencyNotSettled();
}
```

所以在这一切结束后，你必须再次结算你的余额。

代币转账保持在绝对最低的水平，因为我们只需要在最后做一次。

函数`_settleCurrencyBalance`对参与兑换的每个货币都被调用。如果我们有一个负的delta，这意味着**流动池仍然欠我们钱**。我们可以通过调用`take`将其收回。

在另一种情况下，我们必须使用 **settle** 来偿还资金：

- 对于 ETH，我们可以在调用`settle`时直接发送该金额。
- 对于 ERC20 代币，我们必须将其转账到 poolManager，然后单独调用`settle`。



**然后就可以了! 你的代币已经被兑换了**。



与上面的架构相比，另一个稍微灵活的架构也可以是下边的这个：

```solidity
function lock(bytes calldata data) public payable {
    poolManager.lock(data);
}

function lockAcquired(uint256, bytes calldata data) external returns (bytes memory) {
    if (msg.sender == address(poolManager)) {
        revert OnlyPoolManager();
    }

    (bool success, bytes memory returnData) = address(this).call(data);

    if (success) return returnData;
    if (returnData.length == 0) revert LockFailure();

    assembly {
        revert(add(returnData, 32), mload(returnData))
    }
}

function swapTokens(
    IPoolManager.PoolKey calldata poolKey,
    IPoolManager.SwapParams calldata swapParams,
    uint256 deadline
) external returns (bytes memory) {
    // old logic from the previous `lockAcquired`
}
```



在这里，我们基本上只是将任何数据从调用者传递给 lock，再传递给lockAcquired。从那里我们简单地调用`address(this).call(data)`。

在我们的例子中，执行`swapTokens`的数据应该是`swapTokens`函数签名和它的输入参数。

![Uniswap Hooks Meme](https://img.learnblockchain.cn/2023/07/07/90490.jpeg)



## 进入全新 Uniswap Hook 时代

现在让我们来讨论一下最大的新功能，Hook。有**三种不同的Hook接口**。

第一个也是最大的一个是 "IHooks"：

```solidity
interface IHooks {
    function beforeInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96) external returns (bytes4);

    function afterInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, int24 tick) external returns (bytes4);

    function beforeModifyPosition(address sender, PoolKey calldata key, ModifyPositionParams calldata params) external returns (bytes4);

    function afterModifyPosition(address s, PoolKey calldata k, ModifyPositionParams calldata p, BalanceDelta d) external returns (bytes4);

    function beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params) external returns (bytes4);

    function afterSwap(address sender, PoolKey calldata key, SwapParams calldata params, BalanceDelta delta) external returns (bytes4);

    function beforeDonate(address sender, PoolKey calldata key, uint256 amount0, uint256 amount1) external returns (bytes4);

    function afterDonate(address sender, PoolKey calldata key, uint256 amount0, uint256 amount1) external returns (bytes4);
}
```

Uniswap 4中的 "IHooks "接口为你提供了一个选项，可以在流动性池中的不同阶段与你交互。你可以把Hook看作是在你的资金池中关键操作前后被触发的操作。

- `beforeInitialize`和`afterInitialize`：当一个新的流动池被初始化时，例如，如果你想在创建一个新的流动池时添加一些额外的设置逻辑，可以在这里添加。

- `beforeModifyPosition`和`afterModifyPosition`：当池中的LP位置被改变时，换句话说，每次LP增加/删除流动性或改变其LP位置的参数时被调用。

- `beforeSwap`和`afterSwap`：在兑换操作发生之前和之后。你可以在下边看到这个流程。

- `beforeDonate`和`afterDonate`：当流动性通过新的`Donate`函数被添加到池中。



![Uniswap Swap Flow](https://img.learnblockchain.cn/2023/07/07/88134.png)

记住，你不需要实现所有的Hook。根据自己的要求，可以选择只实现需要的那些。

我们很快会探讨如何将这些 Hook 添加到资金池中，但首先让我们看看另外两个Hook接口。



```solidity
interface IHookFeeManager {
    function getHookSwapFee(
        IPoolManager.PoolKey calldata key
    ) external view returns (uint8);

    function getHookWithdrawFee(
        IPoolManager.PoolKey calldata key
    ) external view returns (uint8);
}
```



IHookFeeManager 是一个独立于 "IHooks" 的接口，与允许 Hook 收取一些费用。

- `getHookSwapFee`：这个方法允许一个 Hook 定义当兑换发生时，一个Hook应该得到多少分成。
- `getHookWithdrawFee`：这个方法设置当资产从流动池中提走时，Hook可以收取多少费用。

最后，"IDynamicFeeManager" 接口用于确定常规兑换费用：

- `getFee`：该方法返回一个流动池的动态费用。这允许更灵活和可能变化的费用结构，例如，你可以根据市场情况等因素来收费。

```solidity
interface IDynamicFeeManager {
    function getFee(
        IPoolManager.PoolKey calldata key
    ) external returns (uint24);
}
```

这就是所有可用 的Hook 。

但如何用自定义Hook创建一个流动池？



## 创建自定义Uniswap 4Hook

![自定义是关键](https://img.learnblockchain.cn/2023/07/07/48212.jpeg)

好吧，简短的回答是，你可以使用我为 Foundry 创建的这个新模板作为一个起点：

```bash
$ forge init my-project --template https://github.com/soliditylabs/uniswap-v4-custom-pool
```

你可以在 https://github.com/soliditylabs/uniswap-v4-custom-pool 上查看代码。

但现在是更长的答案，有一些解释。有**种不同的机制来执行费用**：

1. 你的Hooks合约的**部署的以太坊地址的前缀**本身。

2. 费用**定义中的**特殊标志，如果设置为1，将触发特定的费用挂钩。

让我们从第一条开始。这里面有一点神奇，但并不难。

`IHooks`有8个定义的Hook函数。**每个函数都对应于你的以太坊地址开头的一个位。

我们这样做是什么意思？

想象一下，你有一个随机地址，如`0x480f0d4887ed4f16d2299031dffec90782826269`。`0x48`的前两个字符用二进制表示将是`01001000`。

这将导致Hook`afterInitialize`和`beforeSwap`被执行。

例如，如果你想运行所有的Hook，你必须确保你部署的地址以`0xff`开头。

现在，下一个问题是，**你如何确保地址以正确的位开始？

通常情况下，部署合约的地址将是部署者地址、其交易nonce和部署字节码的组合。 这将使部署工作具有相当大的挑战性。

**幸运的是，以太坊有第二种方法来部署合约，使用`CREATE2`操作码。

![Uniswap Hook Bits](https://img.learnblockchain.cn/2023/07/07/27667.png)



## # 在正确的地址上部署Hook

```solidity
contract UniswapHooksFactory {
    function deploy(
        address owner,
        IPoolManager poolManager,
        bytes32 salt
    ) external returns (address) {
        return address(new MyHooksContract{salt: salt}(owner, poolManager));
    }

    function getPrecomputedHookAddress(
        address owner,
        IPoolManager pm,
        bytes32 salt
    ) external view returns (address) {
        bytes32 bytecodeHash = keccak256(abi.encodePacked(
            type(UniswapHooks).creationCode, abi.encode(owner, pm)
        ));
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)
        );
        return address(uint160(uint256(hash)));
    }
}
```

CREATE2部署需要一个盐参数。在 Solidity 中，这可以通过简单地在部署调用中添加 `{salt: salt}` 来完成。

这允许确定的地址，不再基于交易nonce和部署者地址。相反，它只依赖于盐和合约字节码。

然后，我们也可以很容易地预先计算出这样一个Hook的地址是什么。请注意，这里的0xff是一个不同的概念，与Hooks没有关系。你可以阅读`CREATE2`EIP[这里](https://eips.ethereum.org/EIPS/eip-1014)，以了解更多这方面的信息。

鉴于这种确定地址的简单方法，为了部署我们的Hook，我们只需要找到正确的盐，让我们得到我们想要的地址。这是一个小的**裸的努力。

如果你使用Foundry，你可以在你的部署脚本中添加类似这样的内容：

```solidity
for (uint256 i = 0; i < 1500; i++) {
    bytes32 salt = bytes32(i);
    address expectedAddress = uniswapHooksFactory.getPrecomputedHookAddress(owner, poolManager, salt);

    if (_doesAddressStartWith(expectedAddress, 0xff)) {
        IHooks(uniswapHooksFactory.deploy(owner, poolManager, salt));
    }
}

function _doesAddressStartWith(address _address,uint160 _prefix) private pure returns (bool) {
    return uint160(_address) / (2 ** (8 * (19))) == _prefix;
}
```

这将确保你用正确的盐进行部署!

```solidity
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";

constructor(IPoolManager _poolManager) {
    poolManager = _poolManager;
    validateHookAddress(this);
}

function validateHookAddress(BaseHook _this) internal pure {
    Hooks.validateHookAddress(_this, getHooksCalls());
}

function getHooksCalls() public pure returns (Hooks.Calls memory) {
    return Hooks.Calls({
        beforeInitialize: true,
        afterInitialize: true,
        beforeModifyPosition: true,
        afterModifyPosition: true,
        beforeSwap: true,
        afterSwap: true,
        beforeDonate: true,
        afterDonate: true
    });
}
```

**现在，作为验证你已经正确设置了地址的最后一个方法**，我们可以使用Uniswap提供的`Hooks.validateHookAddress`函数。

在我们的Hook的构造函数中，我们可以调用`validateHookAddress`，并将布尔值精确地设置为我们想要注册的那些Hook。

如果地址不符合这个规范，部署就会失败。

例如左边的例子，只有当地址实际以`0xff`开头时才会成功，因为我们已经将所有的Hook都设置为必需。



### 设置收费Hook

现在，收费Hook的机制略有不同。

当你在poolManager中初始化一个池时，你必须调用右边的东西。如果你想让收费Hook被执行，你必须在这里为`myFees`设置特定的标志，如果不是，你会在这里放一个静态的收费号码。

```solidity
poolManager.initialize(IPoolManager.PoolKey({
    currency0: Currency.wrap(address(token1)),
    currency1: Currency.wrap(address(token2)),
    fee: myFees,
    tickSpacing: 1,
    hooks: IHooks(deployedHooks)
}), sqrtPriceX96);
```

例如，如果你想让所有的费用Hook都被执行，你只需像这样设置`myFees`来设置所有的标志：

```solidity
uint24 myFees = Fees.DYNAMIC_FEE_FLAG + Fees.HOOK_SWAP_FEE_FLAG + Fees.HOOK_WITHDRAW_FEE_FLAG;
```

这就是了!你可以在https://github.com/soliditylabs/uniswap-v4-custom-pool 上深入了解完整的例子。

并像这样在Foundry中使用它们作为一个起点：

```bash
$ forge init my-project --template https://github.com/soliditylabs/uniswap-v4-custom-pool
```

另外值得注意的是，你可以在这里找到一些**实施Hook的例子：https://github.com/Uniswap/v4-periphery/tree/main/contracts/hooks/examples。

一个有趣的例子是启用限价订单的功能。在高层次上，它的工作原理如下。Hook合约有两个功能：

1.`函数placeLimitOrder(PoolKey calldata key, int24 tickLower, bool zeroForOne, uint128 liquidity)`：允许用户在指定的点位向Hook添加流动资金。


2.2. `功能 afterSwap`：在Hook内部，我们可以检查新的点位并相应地修改Hook的LP位置。

就这样了。你已经到达了终点。现在祝你的Uniswap之旅好运。

**向前走，向上走。

![Uniswap Onwards and Upwards](https://img.learnblockchain.cn/2023/07/07/81841.png)

感谢 [Chaintool](https://chaintool.tech/) 对本翻译的支持， Chaintool 是一个为区块链开发者准备的开源工具箱
本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
