> * 原文链接： https://hackernoon.com/how-to-implement-a-stake-and-reward-contract-in-solidity
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

#  Solidity 如何实现质押和奖励合约



质押代币是一种 DeFi 工具，它允许用户在合约中质押代币并获得奖励。它是最重要的 DeFi 原语之一，也是成千上万 tokenomic 模型的基础。



在这篇文章中，我将向你展示如何使用[简单实现](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn)来构建质押奖励合约。然后，我将展示两个更高级的版本：[代币化质押奖励](#ERC20 代币化奖励质押) 以及 [ERC4626 代币化金库](#ERC4626 代币化金库合约)。

## 关于质押

代币质押是指在合约中持有资产以支持做市等协议操作的过程。作为交换，资产持有者（即质押者）获得代币奖励，奖励代币可以是他们存入的相同类型，也可以不是。



给区块链协议中提供服务的用户提供奖励的概念是代币经济的基本原理之一，自 ICO 繁荣时期甚至在此之前就已经存在。[Compound](https://github.com/compound-finance/compound-protocol/blob/master/contracts/Comptroller.sol?ref=learnblockchain.cn)和 Curve 在利用奖励推动业务方面非常成功，围绕它们的代币经济设计开发了一整套其他区块链应用。



然而，事实证明，独立质押的合约 [k06a 的实现](https://github.com/k06a/Unipool/blob/master/contracts/Unipool.sol?ref=learnblockchain.cn) 是使用最广泛，有数百种部署和变体。在[Unipool](https://github.com/k06a/Unipool/blob/master/contracts/Unipool.sol?ref=learnblockchain.cn)发布之后，再看[其他的质押合约](https://github.com/yam-finance/yam-protocol/blob/master/contracts/distribution/YAMETHPool.sol?ref=learnblockchain.cn)，很可能就是从它衍生出来的。

## 简单质押奖励合约

[Unipool](https://github.com/k06a/Unipool/blob/master/contracts/Unipool.sol) 质押合约影响巨大，[k06a](https://twitter.com/k06a?ref=learnblockchain.cn) 是世界级的开发者，但出于教育目的，我决定以更清晰的方式再次实现该算法。



[Simple Rewards](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn)合约允许用户 "押注"一个 `stakingToken`，并获得一个 `rewardsToken`，用户必须 "领取（`claim`）"这个 `rewardsToken`。用户可以随时"提取 "质押，但奖励也会停止累积。这是一个无权限合约，将在部署时定义的时间间隔内分配奖励。仅此而已。



![简单SimpleRewards.sol 中的操作](https://img.learnblockchain.cn/2023/08/15/94248.jpeg)



<p align="center">SimpleRewards.sol 中的函数</p>



### 计算奖励的数学

这篇[Dan Robinson的文章](https://www.paradigm.xyz/2021/05/liquidity-mining-on-uniswap-v3?ref=learnblockchain.cn) 对质押合约背后的数学进行了精彩的描述，还有[原始论文链接](https://uploads-ssl.webflow.com/5ad71ffeb79acc67c8bcdaba/5ad8d1193a40977462982470_scalable-reward-distribution-paper.pdf?ref=learnblockchain.cn)。我将跳过大部分数学符号，用更简单的语言解释他们的工作。



奖励只在一个有限的时间段内分配，首先在时间上均匀分配，然后按每个持有者所投入代币的比例分配。



例如，如果我们要分发 100 万个奖励代币，奖励将在 10,000 秒内分发完毕，那么我们每秒正好分发 100 个奖励代币。如果在某一秒钟内只有两个质押者，一个质押 1 个代币和一个质押 3 个代币，那么第一个质押者在这一秒钟内将获得 25 个奖励代币，而另一个质押者将获得 75 个奖励代币。



在区块链上，如果按每秒分配奖励代币会很复杂，也很昂贵。取而代之的是，我们会累积一个计数器，用于计算直到当前时间为止，质押者单个代币可获得的重奖励，并在每次合约中发生交易时更新这个累积器。



每次交易更新累积器的公式是：上次更新后的时间乘以创建时定义的奖励率，再除以更新时的质押总额。



```javascript
currentRewardsPerToken = accumulatedRewardsPerToken + elapsed * rate  / totalStaked
```



每代币奖励累加器（rewardsPerToken accumulator）告诉我们，如果在奖励间隔期开始时质押一个代币，质押者将获得多少奖励。这很有用，但我们希望允许认购者在奖励间隔期开始后也可以质押，而且我们希望允许他们不止一次质押。



为此，我们为每个用户存储了他们最后一次交易时的奖励，以及他们最后一次交易时的每代币奖励累积量。根据这些数据，在任何时间点，我们都可以计算出他们的奖励：

```javascript
currentUserRewards =
  accumulatedUserRewards +
   userStake * (userRecordedRewardsPerToken - currentRewardsPerToken)
```



每次用户交易都会更新累积奖励，并记录该用户当前的每代币奖励。这一过程允许用户根据自己的意愿多次质押和取消质押。

### 实现

实现[代码](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol)如下（SimpleRewards.sol）：

```solidity
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";


/// @notice Permissionless staking contract for a single rewards program.
/// From the start of the program, to the end of the program, a fixed amount of rewards tokens will be distributed among stakers.
/// The rate at which rewards are distributed is constant over time, but proportional to the amount of tokens staked by each staker.
/// The contract expects to have received enough rewards tokens by the time they are claimable. The rewards tokens can only be recovered by claiming stakers.
/// This is a rewriting of [Unipool.sol](https://github.com/k06a/Unipool/blob/master/contracts/Unipool.sol), modified for clarity and simplified.
/// Careful if using non-standard ERC20 tokens, as they might break things.

contract SimpleRewards {
    using SafeTransferLib for ERC20;
    using Cast for uint256;

    event Staked(address user, uint256 amount);
    event Unstaked(address user, uint256 amount);
    event Claimed(address user, uint256 amount);
    event RewardsPerTokenUpdated(uint256 accumulated);
    event UserRewardsUpdated(address user, uint256 rewards, uint256 checkpoint);

    struct RewardsPerToken {
        uint128 accumulated;                                        // Accumulated rewards per token for the interval, scaled up by 1e18
        uint128 lastUpdated;                                        // Last time the rewards per token accumulator was updated
    }

    struct UserRewards {
        uint128 accumulated;                                        // Accumulated rewards for the user until the checkpoint
        uint128 checkpoint;                                         // RewardsPerToken the last time the user rewards were updated
    }

    ERC20 public immutable stakingToken;                            // Token to be staked
    uint256 public totalStaked;                                     // Total amount staked
    mapping (address => uint256) public userStake;                  // Amount staked per user

    ERC20 public immutable rewardsToken;                            // Token used as rewards
    uint256 public immutable rewardsRate;                           // Wei rewarded per second among all token holders
    uint256 public immutable rewardsStart;                          // Start of the rewards program
    uint256 public immutable rewardsEnd;                            // End of the rewards program       
    RewardsPerToken public rewardsPerToken;                         // Accumulator to track rewards per token
    mapping (address => UserRewards) public accumulatedRewards;     // Rewards accumulated per user
    
    constructor(ERC20 stakingToken_, ERC20 rewardsToken_, uint256 rewardsStart_, uint256 rewardsEnd_, uint256 totalRewards)
    {
        stakingToken = stakingToken_;
        rewardsToken = rewardsToken_;
        rewardsStart = rewardsStart_;
        rewardsEnd = rewardsEnd_;
        rewardsRate = totalRewards / (rewardsEnd_ - rewardsStart_); // The contract will fail to deploy if end <= start, as it should
        rewardsPerToken.lastUpdated = rewardsStart_.u128();
    }

    /// @notice Update the rewards per token accumulator according to the rate, the time elapsed since the last update, and the current total staked amount.
    function _calculateRewardsPerToken(RewardsPerToken memory rewardsPerTokenIn) internal view returns(RewardsPerToken memory) {
        RewardsPerToken memory rewardsPerTokenOut = RewardsPerToken(rewardsPerTokenIn.accumulated, rewardsPerTokenIn.lastUpdated);
        uint256 totalStaked_ = totalStaked;

        // No changes if the program hasn't started
        if (block.timestamp < rewardsStart) return rewardsPerTokenOut;

        // Stop accumulating at the end of the rewards interval
        uint256 updateTime = block.timestamp < rewardsEnd ? block.timestamp : rewardsEnd;
        uint256 elapsed = updateTime - rewardsPerTokenIn.lastUpdated;
        
        // No changes if no time has passed
        if (elapsed == 0) return rewardsPerTokenOut;
        rewardsPerTokenOut.lastUpdated = updateTime.u128();
        
        // If there are no stakers we just change the last update time, the rewards for intervals without stakers are not accumulated
        if (totalStaked == 0) return rewardsPerTokenOut;

        // Calculate and update the new value of the accumulator.
        rewardsPerTokenOut.accumulated = (rewardsPerTokenIn.accumulated + 1e18 * elapsed * rewardsRate / totalStaked_).u128(); // The rewards per token are scaled up for precision
        return rewardsPerTokenOut;
    }

    /// @notice Calculate the rewards accumulated by a stake between two checkpoints.
    function _calculateUserRewards(uint256 stake_, uint256 earlierCheckpoint, uint256 latterCheckpoint) internal pure returns (uint256) {
        return stake_ * (latterCheckpoint - earlierCheckpoint) / 1e18; // We must scale down the rewards by the precision factor
    }

    /// @notice Update and return the rewards per token accumulator according to the rate, the time elapsed since the last update, and the current total staked amount.
    function _updateRewardsPerToken() internal returns (RewardsPerToken memory){
        RewardsPerToken memory rewardsPerTokenIn = rewardsPerToken;
        RewardsPerToken memory rewardsPerTokenOut = _calculateRewardsPerToken(rewardsPerTokenIn);

        // We skip the storage changes if already updated in the same block, or if the program has ended and was updated at the end
        if (rewardsPerTokenIn.lastUpdated == rewardsPerTokenOut.lastUpdated) return rewardsPerTokenOut;

        rewardsPerToken = rewardsPerTokenOut;
        emit RewardsPerTokenUpdated(rewardsPerTokenOut.accumulated);

        return rewardsPerTokenOut;
    }

    /// @notice Calculate and store current rewards for an user. Checkpoint the rewardsPerToken value with the user.
    function _updateUserRewards(address user) internal returns (UserRewards memory) {
        RewardsPerToken memory rewardsPerToken_ = _updateRewardsPerToken();
        UserRewards memory userRewards_ = accumulatedRewards[user];
        
        // We skip the storage changes if already updated in the same block
        if (userRewards_.checkpoint == rewardsPerToken_.lastUpdated) return userRewards_;
        
        // Calculate and update the new value user reserves.
        userRewards_.accumulated += _calculateUserRewards(userStake[user], userRewards_.checkpoint, rewardsPerToken_.accumulated).u128();
        userRewards_.checkpoint = rewardsPerToken_.accumulated;

        accumulatedRewards[user] = userRewards_;
        emit UserRewardsUpdated(user, userRewards_.accumulated, userRewards_.checkpoint);

        return userRewards_;
    }

    /// @notice Stake tokens.
    function _stake(address user, uint256 amount) internal
    {
        _updateUserRewards(user);
        totalStaked += amount;
        userStake[user] += amount;
        stakingToken.safeTransferFrom(user, address(this), amount);
        emit Staked(user, amount);
    }


    /// @notice Unstake tokens.
    function _unstake(address user, uint256 amount) internal
    {
        _updateUserRewards(user);
        totalStaked -= amount;
        userStake[user] -= amount;
        stakingToken.safeTransfer(user, amount);
        emit Unstaked(user, amount);
    }

    /// @notice Claim rewards.
    function _claim(address user, uint256 amount) internal
    {
        uint256 rewardsAvailable = _updateUserRewards(msg.sender).accumulated;
        
        // This line would panic if the user doesn't have enough rewards accumulated
        accumulatedRewards[user].accumulated = (rewardsAvailable - amount).u128();

        // This line would panic if the contract doesn't have enough rewards tokens
        rewardsToken.safeTransfer(user, amount);
        emit Claimed(user, amount);
    }


    /// @notice Stake tokens.
    function stake(uint256 amount) public virtual
    {
        _stake(msg.sender, amount);
    }


    /// @notice Unstake tokens.
    function unstake(uint256 amount) public virtual
    {
        _unstake(msg.sender, amount);
    }

    /// @notice Claim all rewards for the caller.
    function claim() public virtual returns (uint256)
    {
        uint256 claimed = _updateUserRewards(msg.sender).accumulated;
        _claim(msg.sender, claimed);
        return claimed;
    }

    /// @notice Calculate and return current rewards per token.
    function currentRewardsPerToken() public view returns (uint256) {
        return _calculateRewardsPerToken(rewardsPerToken).accumulated;
    }

    /// @notice Calculate and return current rewards for a user.
    /// @dev This repeats the logic used on transactions, but doesn't update the storage.
    function currentUserRewards(address user) public view returns (uint256) {
        UserRewards memory accumulatedRewards_ = accumulatedRewards[user];
        RewardsPerToken memory rewardsPerToken_ = _calculateRewardsPerToken(rewardsPerToken);
        return accumulatedRewards_.accumulated + _calculateUserRewards(userStake[user], accumulatedRewards_.checkpoint, rewardsPerToken_.accumulated);
    }
}

library Cast {
    function u128(uint256 x) internal pure returns (uint128 y) {
        require(x <= type(uint128).max, "Cast overflow");
        y = uint128(x);
    }
}
```



实现过程应简单易懂：

- [结构体](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn#L25) 用于数据打包，可节省一些Gas。
- [数学公式](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn#L57) 被放在独立的函数（`_calculateRewardsPerToken()`）中，以便于理解和测试。
- 与数学函数相关的[状态变量的更新](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn#L86)也包含在单独的函数中（`_updateRewardsPerToken()`），以便清楚地显示更新发生与否。
- [stake功能在内部函数中实现](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn# L118)，外部函数的实现是为了以更友好的方式向用户展示[功能](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn#L153)。
- 最后，还实现了两个函数（`currentRewardsPerToken()` 及 `currentUserRewards()` ），以[显示当前时间点合约的预计奖励](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn#L174)，而无需耗费Gas。

### 精度

如果总质押（totalStaked）非常大， 在与奖励率和上次更新后的时间相比后，那么 rewardsPerToken 变量就可能非常小。因此，在存储 rewardsPerToken 时，会按比例增加 18 位精度。

### 与 Unipool 的区别

[Simple Rewards](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/SimpleRewards.sol?ref=learnblockchain.cn)合约代码看起来可能不同，但功能非常相似。Simple Rewards添加的功能是可以使用任何质押和奖励代币，以及奖励间隔的任何持续时间。我删除了可以延长奖励间隔的功能。我还删除了在单个函数调用中实现领取奖励和取消质押的功能。

## ERC20 代币化奖励质押

独立质押合约的一个缺点是需要一个单独的交易来质押。考虑一下这样一种情况：你想用质押来激励为某个合约增加流动性。用户将在第一笔交易中增加流动性并获得一些流动池代币，然后他将需要第二笔交易来把获得的流动性代币进行质押。



这种不便可以通过使用批处理机制来解决，但第二个缺点是押注的头寸不具有流动性。如果有人持有代币，就不能将其作为借款等的抵押品。他们也不能交易自己的代币。



这两个问题都可以通过[让质押合约本身成为ERC20代币](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC20Rewards.sol?ref=learnblockchain.cn)，并将质押/退出操作在铸币、销毁和转账功能中来解决。



![将奖励嵌入到 ERC20 中](https://img.learnblockchain.cn/2023/08/15/11236.jpeg)

<p align="center">在 ERC20 中嵌入奖励</p>



完整的代码在：https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC20Rewards.sol 



### 功能

- 没有单独的质押，持有就是质押。
- 用户可以铸造或接收质押代币，开始累积奖励。
- 当用户转走或销毁他们的质押代币时，就会停止累积奖励。
- 一个奖励间隔结束后，可以通过治理开始另一个奖励间隔。



该[合约](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC20Rewards.sol)的实现考虑到了可重用性，这意味着代码更加复杂，但也更加通用和高效。请注意，由于该合约没有任何可以铸造或销毁代币的公共方法，因此需要继承它。

## ERC4626 代币化金库合约



[ERC4626 代币化金库标准](https://ethereum.org/en/developers/docs/standards/tokens/erc-4626/?ref=learnblockchain.cn) 已被热烈采用，[奖励用户存入资产是顺理成章的补充](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC4626Rewards.sol?ref=learnblockchain.cn)。这可以通过让 ERC4626 实现继承上一节中的 [ERC20 质押合约](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC20Rewards.sol )来实现。



在我的实现中，我复制了 [Solmate ERC4626 实现](https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol?ref=learnblockchain.cn)，并修改了导入和构造函数。我还添加了两行，以便在用户完全退出时自动领取所有奖励，模仿 Unipool 的 "退出（`exit`）"函数。



![让ERC4626 质押合约](https://img.learnblockchain.cn/2023/08/15/61798.jpeg)



<p align="center">修改为支持 ERC4626 的质押合约</p>



### 功能

- 没有单独的质押，持有或存入就是质押。
- 用户可以存入、铸造或接收质押代币，开始累积奖励。
- 当用户转走、赎回或提款时，他们将停止累积奖励。
- 奖励间隔结束后，可以通过治理开始另一个奖励间隔。



## 在主网上使用此代码

Staking 代码库中的代码都没有什么创新。SimpleRewards.sol合约是对[Unipool.sol](https://github.com/k06a/Unipool/blob/master/contracts/Unipool.sol?ref=learnblockchain.cn)的重写。ERC20Rewards.sol合约是对[ERC20Rewards.sol](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC20Rewards.sol?ref=learnblockchain.cn)合约的少量更新，[Yield](https://app.yieldprotocol.com/?ref=learnblockchain.cn)已经使用该合约两年了。[ERC4626Rewards.sol](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC4626Rewards.sol?ref=learnblockchain.cn)合约是修改自[solmate ERC4626合约](https://github.com/transmissions11/solmate/blob/bfc9c25865a274a7827fea5abf6e4fb64fc64e6c/src/mixins/ERC4626.sol?ref=learnblockchain.cn)，但继承自[ERC20Rewards.sol](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC20Rewards.sol?ref=learnblockchain.cn)。



我已经对 SimpleRewards.sol 和 [ERC20Rewards.sol](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC20Rewards.sol?ref=learnblockchain.cn) 进行了单元测试，因为如果没有测试，我就不知道重构是否有效。我没有对 [ERC4626Rewards.sol](https://github.com/alcueca/staking/blob/b9349f3af585c03121c3627a57e0d4312c913c14/src/ERC4626Rewards.sol?ref=learnblockchain.cn) 进行单元测试，因为它是两个合约的简单混合。



目前这些代码都没有经过审计。如果你打算在生产环境中使用它，请自行审计。如果你是新晋审计工程师，并希望审核此代码，请进行审核。我将上传我收到的任何审核结果，并回复提出的任何问题。

## 结论

[Unipool.sol](https://github.com/k06a/Unipool/blob/master/contracts/Unipool.sol?ref=learnblockchain.cn)合约使协议能够激励资产分配。这一基本功能帮助数以千计的项目走上了成功之路，并有可能在未来数年成为去中心化应用的基石。



在本文中，我们重新实现了[Unipool.sol](https://github.com/k06a/Unipool/blob/master/contracts/Unipool.sol?ref=learnblockchain.cn)，并强调了其清晰性。我们还提供了另外两个合约，奖励持有代币或将代币存入代币保险库。



这些代码中有一部分是为了在 [Yield Protocol](https://app.yieldprotocol.com/?ref=learnblockchain.cn) 上实现奖励而实现的，其余部分则是为了好玩。写这篇文章是因为我相信它会对某些人有所帮助，而这就是我所追求的所有奖励。请慢用。

---


本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
