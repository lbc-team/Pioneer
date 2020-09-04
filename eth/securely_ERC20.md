
# Navigating the pitfalls of securely interacting with ERC20 tokens

## Figuring out how to securely interact might be harder than you think

You would think calling a few functions on an ERC-20 token is the simplest thing to do, right? Unfortunately I have some bad news, it's not. There are several things to consider and some errors are still pretty common. Let's start with the easy ones.

Let's take a very common token: ... Now to interact with this token, let's import the IERC20.sol and just use it:

![](https://img.learnblockchain.cn/2020/09/04/15991890349006.jpg)


## How to securely handle ERC-20 interactions


```
// incorrect version
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

function interactWithToken(uint256 sendAmount) {
  // some code
  IERC20 token = IERC20(tokenAddress);
  token.transferFrom(msg.sender, address(this), sendAmount);
}
```

This code works perfectly for a token like [DAI](https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#code). You call the transfer function and the **DAI** contract just reverts the call in case something goes wrong.

But let's see what happens if we are trying to use the 0x token: **ZRX**. You can find its current code [here](https://etherscan.io/address/0xe41d2489571d322189246dafa5ebde1f4699f498#code).


```
function transferFrom(address _from, address _to, uint _value) returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
}
```

You can see, in contrast to the DAI token, it doesn't revert the call. Now instead of reverting on failure, our token transfer returns `false`. But we don't look at the return value in our code. Essentially anyone could interact now with our contract where our contract thinks a token transfer was successful while really nothing was transferred. **Ouch!**

ZRX is still ERC-20 compliant, as it's nowhere defined that the ERC-20 contract has to revert on failure. There are pros and cons with both approaches. Our solution to fix the code example is obviously to just check the return value. A simple `require(token.transferFrom(msg.sender, address(this), sendAmount), "Token transfer failed!");` will be enough to fix it. The same thing is true for any function in the contract, they all return false on failure or revert, so always handle both cases.


## Error handling within the contract


Most of the times tokens just revert on failure. The advantage is that even broken code like our first attempt still securely interacts with this token. This is also the reason why OpenZeppelin has chosen to do this in their [ERC20 reference](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol) implementation and why I recommend you do it this way.

But there's definitely an argument to be made for the return value. If you know the token you're interacting with returns false on failure, or you just want to add extra functionality for those tokens, you can do something like


```
function interactWithToken(uint256 sendAmount) {
  IERC20 token = IERC20(tokenAddress);
  bool success = token.transferFrom(msg.sender, address(this), sendAmount);

  if (success) {
    // handle success case
  } else {
     // handle failure case without reverting
  }
}
```


The advantage here obviously being that we still allow successful transactions even for failed token transfers.

**What about error handling if the token reverts on failure?**

This used to be more complicated, but since Solidity 0.6 it's actually not that difficult anymore. Now they support [try/catch](https://solidity.readthedocs.io/en/latest/control-structures.html#try-catch):

![](https://img.learnblockchain.cn/2020/09/04/15991891334722.jpg)


```
function interactWithToken(uint256 sendAmount) {
  IERC20 token = IERC20(tokenAddress);
  bool success;

  try token.transferFrom(msg.sender, address(this), sendAmount) returns (bool _success) {
    success = _success;
  } catch Error(string memory /*reason*/) {
    success = false;
    // special handling depending on error message possible
  } catch (bytes memory /*lowLevelData*/) {
    success = false;
  }

  if (success) {
    // handle success case
  } else {
     // handle failure case without reverting
  }
}
```

This way you can do error handling for both versions of the ERC-20 contracts.

## How to support all tokens


So that's technically it. Now you support ERC-20 compliant tokens. Unfortunately as it turns out, there are quite a few tokens out there that look like ERC-20, but don't behave like it. This is because of the [missing return value bug](https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca). As it turns out, OpenZeppelin's reference implementation had a bug for some amount of time. They reverted on failure, but they didn't return `true` on success. Quite a few tokens are affected including big names like USDT, OmiseGo and BNB.

Unfortunately if you are now expecting a bool return, but no value is returned, our contracts compiled with Solidity 0.4.22 or higher will correctly revert. This bug has even [affected Uniswap](https://twitter.com/UniswapProtocol/status/1072286773554876416) in the past.

So how do other projects handle this? Let's look at the [Compound version](https://github.com/compound-finance/compound-money-market/blob/241541a62d0611118fb4e7eb324ac0f84bb58c48/contracts/SafeToken.sol#L97):


```
function doTransferOut(address payable to, uint amount) internal {
    EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
    token.transfer(to, amount);

    bool success;
    assembly {
        switch returndatasize()
            case 0 {                      // This is a non-standard ERC-20
                success := not(0)          // set success to true
            }
            case 32 {                     // This is a complaint ERC-20
                returndatacopy(0, 0, 32)
                success := mload(0)        // Set `success = returndata` of external call
            }
            default {                     // This is an excessively non-compliant ERC-20, revert.
                revert(0, 0)
            }
    }
    require(success, "TOKEN_TRANSFER_OUT_FAILED");
}
```

Now we first check the return size. If it's in fact 0, we assume it's one of those misbehaving tokens. If the call itself didn't revert, it therefore must mean that the transfer was successful and `true` should have been returned.

With the advancements of Solidity, we can simplify this code. This is how [Uniswap is doing](https://github.com/Uniswap/uniswap-lib/blob/9642a0705fdaf36b477354a4167a8cd765250860/contracts/libraries/TransferHelper.sol#L13-L17) it:

```
function safeTransfer(address token, address to, uint value) internal {
  // bytes4(keccak256(bytes('transfer(address,uint256)')));
  (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
  require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
}
```

This implementation is only slightly different as the abi.decode will work for other data.lengths as well, not only 32\. But this shouldn't make a difference to you. We can also easily change it to support error handling:

```
function safeTransferNoRevert(address token, address to, uint value) internal returns (bool) {
  (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
  return success && (data.length == 0 || abi.decode(data, (bool));
}
```
![](https://img.learnblockchain.cn/2020/09/04/15991892241026.jpg)

## What should you do? (tl;dr)

So what's the best way to go about it now? Well you can simply use the [OpenZeppelin SafeERC20](https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#SafeERC20) implementation. 

This is a wrapper library around ERC-20 calls. Don't be confused, this is not for creating your own token, but for securely interacting with existing ones. The implementation of SafeERC20 is essentially like the above Uniswap version. You can use it like this:

```
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract TestContract {
    using SafeERC20 for IERC20;

    function safeInteractWithToken(uint256 sendAmount) external {
        IERC20 token = IERC20(address(this));
        token.safeTransferFrom(msg.sender, address(this), sendAmount);
    }
}
```

原文链接：https://soliditydeveloper.com/safe-erc20
作者：[Markus](https://soliditydeveloper.com/about)

