https://soliditydeveloper.com/uniswap4

# How to integrate Uniswap 4 and create custom hooks

## Let's dive into Uniswap v4's new features and integration

**Uniswap v4 adds several key updates to improve gas efficiency, customizability, and functionality.**

So let's not lose time and dive into it!

![DEX-vs-CEX-Meme](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/d3ab897c06188906/a85600257cd0/v/74ead17b5fdb/dex-vs-cex.jpeg)

By now you've probably heard of Uniswap and so-called **AMMs** (automated market makers). But if you're not familiar with [Uniswap](https://uniswap.exchange/) yet, it's a fully decentralized protocol for automated liquidity provision on Ethereum. An easier-to-understand description would be that it's a decentralized exchange (DEX) relying on external liquidity providers that can add tokens to smart contract pools and users can trade those directly.

Since it's running on Ethereum, what we can trade are Ethereum ERC-20 tokens and ETH. Originally for each token there was its own smart contract and liquidity pool, now in **Uniswap 4** there is one smart contract that manages the state for all pools. A pool is any two tokens with some customizations for what fees and hooks. We'll discuss this later in more detail.

Uniswap - being fully decentralized - has no restrictions to which tokens can be added. If no pools for a token pair + customization exist yet, **anyone can create** one and **anyone can provide liquidity** to a pool.

**The** **price of a token is determined by the liquidity in a pool**. For example if a user is buying *TOKEN1* with *TOKEN2*, the supply of *TOKEN1* in the pool will decrease while the supply of *TOKEN2* will increase and the price of *TOKEN1* will increase. Likewise, if a user is selling *TOKEN1*, the price of *TOKEN1* will decrease. Therefore the token price always reflects the supply and demand. This behavior can be described using the known formula: `**x \* y = k**`.

And of course a user doesn't have to be a person, it can be a smart contract. That allows us to add Uniswap to our own contracts for adding additional payment options for users of our contracts. Uniswap makes this process very convenient, see below for how to integrate it.

![Uniswap UI](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/64fffff02c44018e/2b54bfc6c00f/v/f970f09c6aad/uniswap-ui.png)

![One Pool Meme](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/56c721fadf283308/1a8abba51891/v/7910c36ef457/one-pool-meme.jpeg)



## What is new in UniSwap v4?

We've discussed what's new in Uniswap v3 [here](https://soliditydeveloper.com/uniswap3), but now let's see what's new in Uniswap v4:

1. **Hooks**: At the heart of Uniswap v4 is a new concept known as 'hooks'. Think of hooks like plugins you can add to your music software to create a new sound effect. Similarly, these hooks can be used to add new functionalities or features to the liquidity pools in Uniswap v4. In practical terms, hooks can enable a variety of functions like setting up limit orders, dynamic fees or creating custom oracle implementations. We'll take a closer look at this feature!
2. **Singleton and Flash Accounting**: In previous versions, every new token pair had its own contract. However, Uniswap v4 introduces the singleton design pattern, meaning all pools are managed by a single contract. And Uniswap v4 uses a system called 'flash accounting'. This method only transfers tokens externally at the end of a transaction, updating an internal balance throughout the process. All this improves gas costs a lot.
3. **Native ETH**: Uniswap v4 is bringing back support for native ETH. So, instead of wrapping your ETH into an ERC-20 token for trading, you can trade directly using ETH. Another feature for saving gas.
4. **ERC1155 Accounting**: With Uniswap v4, you can keep your tokens within the singleton (that mega contract we talked about earlier) and avoid constant transfers to and from the contract. The accounting itself uses the ERC1155 standard which is a multi-token standard. It allows you to send multiple different token classes in one transaction. We've discussed the standard [here](https://soliditydeveloper.com/erc-1155) before. 
5. **Governance Updates**: Uniswap v4 also brings changes to how fees are managed. There are two separate governance fee mechanisms - swap fees and withdrawal fees. The governing body can take a certain percentage of these fees.
6. **Donate Function**: Uniswap v4 introduces a `donate` function that allows users to pay liquidity providers directly in the tokens of the pool.

![Uniswap Brain Meme](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/963cec0ea9cea6ea/7a9e75949a55/v/b3eff58053dc/uniswap-evolution-meme.jpeg)



## Further Resources

- [Source code + Whitepaper](https://github.com/Uniswap/v4-core/tree/main)
- [Introduction Blog Post + Vision](https://blog.uniswap.org/uniswap-v4)



## What happens to Uniswap v3?

![Uni Hayden Meme](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/8d8c78f071b4d6b6/163a2aa4dc4e/v/806cedd05d9a/uni-haryden-meme.jpg)

# "

'Uniswap is an automated, decentralized set of smart contracts. It will continue functioning for as long as Ethereum exists.'

Hayden Adams, Founder of Uniswap



## Integrating UniSwap v4

Doing a swap within your contracts is now a little more complex in Uniswap 4. So let's take a look at one example:

- We'll import the contracts directly via URL, so you could take this example and **plug it right into Remix**.
- We're working with the code from commit `blob/86b3f657`, make sure to update this to `**/blob/main**` **to get the latest version**.

Let's investigate the `swapTokens` function that takes in three parameters: 

1. `IPoolManager.PoolKey poolKey`
2. `IPoolManager.SwapParams calldata swapParams`
3. `uint256 deadline`

The `poolKey` is the identifier for which pool you want to use for the swap. This not only consists of the two token addresses, but also of the specified fees, tick spacing and hooks:

```solidity
struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    IHooks hooks;
}
```

That means there will be an **infinite amount of pools per token pair** now! It **will be up to you** to determine which ones to use.

The currency here is actually using the new Solidity feature of custom types:

```solidity
type Currency is address;
```

So in other words `Currency` is just an address type. Typically an **ERC20** token address. So why not IERC20? Because `Currency` can also mean **native ETH**. In this case you have to pass `address(0)`.

As for the `IHooks`, we'll discuss this in greater details later.

Now the second parameter we send is `SwapParams` which consists of:

1. **zeroForOne**: A boolean indicating the direction (buy vs. sell)
2. **amountSpecified**: The actual amount you want to swap.
3. **sqrtPriceLimitX96**: This represents the lowest price you are fine to accept. It's represented as the square root of the `x * y` formula. And X96 refers to this being represented as a fixed-point decimal with 96 bits of precision to the right of the decimal point.

```solidity
struct SwapParams {
    bool zeroForOne;
    int256 amountSpecified;
    uint160 sqrtPriceLimitX96;
}
```

Now we look at the flow from `swapTokens` next, here's where some magic happens. `swapTokens` calls the `lock` function on the `poolManager`. By calling `lock`, you're asking Uniswap to allow trading against it.

**This allows Uniswap to** **allow you to get negative balances****. Why?**

As soon as the `lock` is called, the `poolManager` contract from Uniswap automatically calls `lockAcquired` on your contract again. Inside here we can do all the trades and interaction we want. After the call to `lockAcquired` is finished (so your code is done executing), Uniswap does **one last check** still:

```solidity
if (lockState.nonzeroDeltaCount != 0) {
    revert CurrencyNotSettled();
}
```

So at the end of it all, you must have settled your balances again. This keeps token transfers to an absolute minimum, because we have to do it only once at the end.

The function `_settleCurrencyBalance` is called for each currency involved in the swap. If we have a negative delta it means the **pool still owes us money**. We can take it back by calling `take`.

In the other case we have to **pay back** the amount using **settle**:

- For ETH we can just send the amount directly along with the `settle` call.
- For ERC20 tokens we have to transfer them to the pool manager and then call `settle` separately.

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

**And voila! Your tokens have been swapped.**

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

An alternative architecture to the above one that's slightly more flexible could also be this one on the left.

Here we're basically just passing any data from the caller to the lock which is then passed to the lockAcquired. From there we simply call `address(this).call(data)`.

In our case the data then to execute `swapTokens` should be the `swapTokens` function signature combined with its input parameters.

![Uniswap Hooks Meme](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/584eb9d4bbe4e152/6f2aa265697a/v/9a26cddb0bcf/Uniswap-Hooks.jpeg)



## Entering a New Uniswap Era with Hooks

Now let's discuss the biggest new feature, the hooks. There are **three different hook interfaces** available.

The first and biggest one is `IHooks`:

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

The `IHooks` interface in Uniswap 4 provides you with an option to interact with different stages of transactions in your liquidity pools. You can consider hooks as operations that get triggered before and after key operations in your pool.

- **`beforeInitialize` and `afterInitialize`**: When a new pool is initialized, e.g. if you want to add some additional setup logic when creating a new pool, this is the place.

  

- **`beforeModifyPosition` and `afterModifyPosition`**: When an LP position in a pool is being changed, in other words every time an LP adds/removes liquidity or changes parameters of his LP position.

- **`beforeSwap` and `afterSwap`**: Before and after a swap operation happens. You can see the flow on the right.

- **`beforeDonate` and `afterDonate`**: When liquidity is being added to the pool via the new `donate` function.

Remember, you don't need to implement all the hooks. Depending on your requirements, you can choose to implement only those that you need.

We'll explore how you can add these hooks to a pool soon, but first let's take a look at two other hook interfaces.

![Uniswap Swap Flow](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/d1007a7c91fd4f90/4b904462457b/v/555751a48d9f/uniswap-swap-flow.png)

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

The `IHookFeeManager` is a separate interface from the `IHooks` related to allowing a hook itself to take some fee.

- **`getHookSwapFee`**: This method allows a hook to define how much cut a hook should get when a swap happens.
- **`getHookWithdrawFee`**: This method sets how much a hook can charge when assets are withdrawn from the pool.

Lastly the `IDynamicFeeManager` interface is used for determining the regular swap fees:

- **`getFee`**: This method returns the dynamic fee for a pool. This allows for more flexible and potentially changing fee structures, e.g. you could base fees on factors like market conditions.

```solidity
interface IDynamicFeeManager {
    function getFee(
        IPoolManager.PoolKey calldata key
    ) external returns (uint24);
}
```

Now those hooks in total are available.

**But how do you now create a pool with custom hooks?**



## Creating Custom Uniswap 4 Hooks

![Customization is key](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/fd344d92324e69a7/1f271d45a23a/v/867985edfa91/customization-is-key.jpg)

Well the short answer is, you can use this new template I created for foundry as a starting point:

```bash
$ forge init my-project --template https://github.com/soliditylabs/uniswap-v4-custom-pool
```

And check out the repository over at https://github.com/soliditylabs/uniswap-v4-custom-pool.

But now to the longer answer with some explanations. There are **two different mechanisms for how the fees are executed**:

1. The **prefix of the deployed Ethereum address** itself of your Hooks contract.
2. **Special flags in the fee** definition, if set to 1, will trigger the specific fee hook. 

Let's start with the first one. There's a bit of magic in here, but it's not too hard.

`IHooks` has 8 defined hook functions. **Each function corresponds to a bit in the beginning of your Ethereum address.**

What do we mean with that?

Imagine you have a random address like `0x480f0d4887ed4f16d2299031dffec90782826269`. The first two characters ``0x48`` represented in binary will be `01001000`.

This will result in the hooks `afterInitialize` and `beforeSwap` being executed.

If you want to run all hooks for example, you must make sure that your deployed address starts with ``0xff``.

Now the next question is, **how do you ensure that the address starts with the correct bits?**

Usually the address of a deployed contract will be a combination of the deployer address, its transaction nonce and the deployed bytecode.  That would make deployments quite challenging.

**Fortunately Ethereum has a second way to deploy contracts using the `CREATE2` opcode.**

![Uniswap Hook Bits](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/c53d7f4251460a30/d1246b3f2e0e/v/9573aa0dda1d/UniHookBits.png)



### Deploying Hook at the Correct Address

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

CREATE2 deployments take in a salt parameter. In Solidity this can be done by simply adding `{salt: salt}` to the deployment call.

This allows for deterministic addresses that are not based on the transaction nonce and deployer address anymore. Instead it **depends solely on the salt and contract bytecode.**

We can then also easily precompute what the address of such a Hook would be. Note that the 0xff here is a different concept and has nothing to do with the hooks. You can read the `CREATE2` EIP [here](https://eips.ethereum.org/EIPS/eip-1014), to learn more on this.

Given this easy way to determine the address, to deploy our hooks we only need to find the correct salt that gives us the address we want. This is a small **brute-force effort**.

If you're using Foundry, you can add something like this to your deploy script:

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

This will ensure you're deploying with the correct salt!

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

**Now as a last way to verify you have set the address correctly**, we can use the `Hooks.validateHookAddress` function provided by Uniswap.

Inside the constructor of our Hook we can call `validateHookAddress` with the booleans set exactly to those hooks we want to have registered.

If the address doesn't match this specification, the deployment will fail.

For example on the left it would only succeed if the address actually starts with ``0xff``, because we have set all hooks to be required.



### Setting Fee Hooks

Now the mechanism for the fee hooks is slightly different.

When you initialize a pool in the poolManager, you have to call something like on the right. If you want the fee hooks to be executed, you have to set the specific flags here for `myFees`, if not you would put a static fee number here.

```solidity
poolManager.initialize(IPoolManager.PoolKey({
    currency0: Currency.wrap(address(token1)),
    currency1: Currency.wrap(address(token2)),
    fee: myFees,
    tickSpacing: 1,
    hooks: IHooks(deployedHooks)
}), sqrtPriceX96);
```

For example if you want all fee hooks to be executed, you would just set all flags by setting `myFees` like this:

```solidity
uint24 myFees = Fees.DYNAMIC_FEE_FLAG + Fees.HOOK_SWAP_FEE_FLAG + Fees.HOOK_WITHDRAW_FEE_FLAG;
```

That's it! You can dive into the full examples over at https://github.com/soliditylabs/uniswap-v4-custom-pool.

And use them as a starting point in Foundry like this:

```bash
$ forge init my-project --template https://github.com/soliditylabs/uniswap-v4-custom-pool
```

And also worth noting, you can find some **examples for implemented hooks** here: https://github.com/Uniswap/v4-periphery/tree/main/contracts/hooks/examples.

One interesting example is the feature to enable limit orders. On a high level it works as follows. The hook contract  has two functions:

1. `function placeLimitOrder(PoolKey calldata key, int24 tickLower, bool zeroForOne, uint128 liquidity)`: Allow users to add liquidity to the hook at specified ticks.
2. `function afterSwap`: Inside the hook, we can check the new ticks and modify the hook's LP position accordingly.

That's it. You've reached the end. Now good luck on your Uniswap journey.

**Onwards and upwards.**

![Uniswap Onwards and Upwards](https://cdn0.scrvt.com/b095ee27d37b3d7b6b150adba9ac6ec8/982d099c44fe42ac/b59de49a4cd1/v/54dad2d0950a/Uniswap-onwards-upwards.png)