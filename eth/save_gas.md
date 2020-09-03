
# Solidity tips and tricks to save gas and reduce bytecode size

![](https://img.learnblockchain.cn/2020/09/03/15991056905111.jpg)


Solidity is a special language with many little quirks. A lot of things behave differently in Solidity than most other languages as Solidity is created to work on the EVM with its limited feature set. I wrote a [blog post with ten tips to save gas in Solidity](https://mudit.blog/solidity-gas-optimization-tips/) a few months back and it got a great response. Since then, I have gathered more tips and tricks to share with you all. Here they are:

## Function modifiers can be inefficient

When you add a function modifier, the code of that function is picked up and put in the function modifier in place of the `_` symbol. This can also be understood as ‘The function modifiers are inlined”. In normal programming languages, inlining small code is more efficient without any real drawback but Solidity is no ordinary language. In Solidity, the maximum size of a contract is restricted to 24 KB by [EIP 170](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-170.md). If the same code is inlined multiple times, it adds up in size and that size limit can be hit easily.

Internal functions, on the other hand, are not inlined but called as separate functions. This means they are very slightly more expensive in run time but save a lot of redundant bytecode in deployment. Internal functions can also help avoid the dreaded “Stack too deep Error” as variables created in an internal function don’t share the same restricted stack with the original function, but the variables created in modifiers share the same stack limit.

I managed to reduce the size of one of my contracts from 23.95 KB to 11.9 KB with this trick. You can see the simple [magical commit here](https://github.com/PolymathNetwork/polymath-core/pull/548/commits/2dc0286f4e96241eed9603534607431a8a84ba35#diff-8b6746c2c4e7c9e3fca67d62718d70e8). Focus on the [DataStore.sol](https://github.com/PolymathNetwork/polymath-core/pull/548/commits/2dc0286f4e96241eed9603534607431a8a84ba35#diff-8b6746c2c4e7c9e3fca67d62718d70e8) contract.

## Booleans use 8 bits while you only need 1 bit

Under the hood of solidity, Booleans (`bool`) are `uint8` which means they use 8 bits of storage. A Boolean can only have two values: True or False. This means that you can store a boolean in only a single bit. You can pack 256 booleans in a single word. The easiest way is to take a `uint256` variable and use all 256 bits of it to represent individual booleans. To get an individual boolean from a `uint256` , use this function:

```
function getBoolean(uint256 _packedBools, uint256 _boolNumber)
    public view returns(bool)
{
    uint256 flag = (_packedBools >> _boolNumber) & uint256(1);
    return (flag == 1 ? true : false);
}
```

To set or clear a bool, use:

```
function setBoolean(
    uint256 _packedBools,
    uint256 _boolNumber,
    bool _value
) public view returns(uint256) {
    if (_value)
        return _packedBools | uint256(1) << _boolNumber;
    else
        return _packedBools & ~(uint256(1) << _boolNumber);
}
```

With this technique, you can store 256 booleans in one storage slot. If you try to pack `bool` normally (like in a struct) then you will only be able to fit 32 bools in one slot. Use this only when you want to store more than 32 booleans.

## Use libraries to save some bytecode

When you call a public function of a library, the bytecode of that function is not made part of your contract so you can put complex logic in libraries while keeping the contract size small. Keep in mind that calling a library costs some gas and requires some bytecode as well. Calls to libraries are made through delegate call which means the libraries have access to the same data that the contract has and also the same permissions. This means that it’s not worth doing for simple tasks. Another thing to remember is that solc inlines the internal functions of the library. Inlining has advantages of its own but it takes bytecode space.

## No need to initialize variables with default values

If a variable is not set/initialized, it is assumed to have the default value (0, false, 0x0 etc depending on the data type). If you explicitly initialize it with its default value, you are just wasting gas.

```
uint256 hello = 0; //bad, expensive
uint256 world; //good, cheap
```

## Use short reason strings

You can (and should) attach error reason strings along with `require` statements to make it easier to understand why a contract call reverted. These strings, however, take space in the deployed bytecode. Every reason string takes at least 32 bytes so make sure your string fits in 32 bytes or it will become more expensive.

```
require(balance >= amount, "Insufficient balance"); //good
require(balance >= amount, "To whomsoever it may concern. I am writing this error message to let you know that the amount you are trying to transfer is unfortunately more than your current balance. Perhaps you made a typo or you are just trying to be a hacker boi. In any case, this transaction is going to revert. Please try again with a lower amount. Warm regards, EVM"; //bad
```

## Avoid repetitive checks

There is no need to check the same condition again and again in different forms. Most common redundant checks are due to SafeMath library. SafeMath library checks for underflows and overflows by itself so you don’t need to check the variables yourself.

```
require(balance >= amount); 
//This check is redundant because the safemath subtract function used below already includes this check.
balance = balance.sub(amount);
```

## Make use of single line swaps

Solidity offers a relatively uncommon feature that allows you to swap values of variables in a single statement. Use that instead of using a temporary variable/xor/arithmetic function to swap values. The following example shows how to swap values of different variables:

```
(hello, world) = (world, hello)
```

## Use events to store data that is not required on-chain

Using events to store data is way cheaper than storing them in variables. You can’t use data in events on-chain though. Also, work is being done on pruning old events so you might have to host your own nodes in the future to get data from old events. Exploiting events like this is kinda unethical but who am I to judge. I won’t tell if you don’t :).

## Make proper use of the optimizer

Apart from allowing you to turn optimizer on and off, solc allows you to customize optimizer runs. `runs` is not how many times the optimizer will run but how many times you expect to call functions in that smart contract. If the smart contract is only of one-time use as a smart contract for vesting or locking of tokens, you can set the `runs` value to `1` so that the compiler will produce the smallest possible bytecode but it may cost slightly more gas to call the function(s). If you are deploying a contract that will be used a lot (like an ERC20 token), you should set the `runs` to a high number like `1337` so that initial bytecode will be slightly larger but calls made to that contract will be cheaper. Commonly used functions like transfer will be cheaper.

## Using fewer functions can be helpful

Usually, it’s good coding practice to use smaller singleton functions that have a single task. In solidity, using multiple smaller functions costs more gas and requires more bytecode. Using larger complex functions can make testing and auditing tough so I won’t outright recommend using them but you can make use of them if you really want to squeeze the juice out of your contracts.

## Calling internal functions is cheaper

From inside a smart contract, calling its internal functions is cheaper than calling its public functions, because when you call a public function, all the parameters are again copied into memory and passed to that function. By contrast, when you call an internal function, references of those parameters are passed and they are not copied into memory again. This saves a bit of gas, especially when the parameters are big.

## Using proxy patterns for mass deployment

If you wish to deploy multiple copies of the same contract then consider deploying just one implementation contract and multiple proxy contracts that delegate their logic to the implementation contract. This will allow these contracts to share the same logic but different data.

## Final thoughts

Most of the general good programming principals and optimization apply to solidity as well but there are some oddities in Solidity like the few mentioned above that make it harder (but interesting) to optimize solidity code. You’ll learn more tricks as you use solidity more and more. However, no matter how many tricks you use, you may still face the 24 KB code size limit when creating complex code. You can split your contracts into various contracts by using proxies or other tricks but the limit is still a pain. If you would like to see the limit removed, please provide your feedback on this [GitHub Issue](https://github.com/ethereum/EIPs/issues/1662).

If you know about any other trick or want to share a tip, feel free to drop a comment below. If you have any doubt or want help, you can drop a comment below as well or contact me personally. If you found this post interesting, share this with your friends and read my previous posts on [my blog](https://mudit.blog/).



原文链接：https://blog.polymath.network/solidity-tips-and-tricks-to-save-gas-and-reduce-bytecode-size-c44580b218e6
作者：[Mudit Gupta](https://blog.polymath.network/@MuditG)






