原文链接：https://medium.com/blockchannel/the-use-of-revert-assert-and-require-in-solidity-and-the-new-revert-opcode-in-the-evm-1a3a7990e06e

# Solidity Learning: R`evert()`, Assert(), and Require() in Solidity, and the New REVERT Opcode in the EVM

## Upcoming Changes to Solidity and How They Function

![img](https://img.learnblockchain.cn/attachments/2022/06/WRHGFgyT62b179002a071.jpeg)

Photo by [Osman Rana](https://unsplash.com/search/photos/fence-gate?photo=05Ola97OFoQ)

**Crosspost: This post was originally written by “**[**Maurelian**](https://twitter.com/maurelian_)**” of ConsenSys and can be found** [**here**](https://media.consensys.net/when-to-use-revert-assert-and-require-in-solidity-61fb2c0e5a57)**. This was posted with his permission, enjoy!**

The release of Solidity version [0.4.10](https://github.com/ethereum/solidity/releases/tag/v0.4.10) introduced the `assert()`, `require()`and `revert()` functions, and confusion has reigned ever since.

In particular, the `assert()` and `require()` “guard” functions improve the readability of contract code, but differentiating between them can be quite confounding.

In this article, I’ll:

1. explain the problem these functions solve.
2. discuss how the Solidity compiler handles the new `assert()`, `require()`and `revert()`.
3. Give some rules of thumb for deciding how and when to use each one.

For convenience, I’ve created a simple contract using each of these features which you can [test out in remix](https://remix.ethereum.org/#gist=c7b647b64d9d2422b81108f8b6af0c7c&version=soljson-v0.4.16+commit.d7661dd9.js).

If you really just want a TLDR, this answer on the [ethereum stackexchange](https://ethereum.stackexchange.com/questions/15166/difference-between-require-and-assert-and-the-difference-between-revert-and-thro)should do it.

# Patterns for error handling in Solidity

## The old way: `throw `and the if … throw pattern

Say your contract has a few special functions, that should only be callable by a particular address which is designated as the `owner`.

Prior to Solidity 0.4.10 (and for a while afterwards), this was a common pattern for enforcing permissions:

```
contract HasAnOwner {
    address owner;
    
    function useSuperPowers(){ 
        if (msg.sender != owner) { throw; }
        // do something only the owner should be allowed to do
    }
}
```

If the `useSuperPowers()` function is called by anyone other than `owner`, the function will throw returning an `invalid opcode` error, undoing all state changes, and using up all remaining gas (see [this article](https://www.google.com/url?q=https://media.consensys.net/ethereum-gas-fuel-and-fees-3333e17fe1dc&sa=D&ust=1505493857490000&usg=AFQjCNE7J1D8vcvRB1IcveGYgCJf3JpXkw) for more on gas and fees in ethereum).

The throw keyword is now being deprecated, and eventually will be removed altogether. Fortunately, the new functions assert(), require(), and revert() provide the same functionality, with a much cleaner syntax.

## Life after throw

Let’s look at how to update that `if .. throw` pattern with our new guard functions.

This line:

```
if(msg.sender != owner) { throw; }
```

currently behaves exactly the same as all of the following:

- `if(msg.sender != owner) { revert(); }`
- `assert(msg.sender == owner);`
- `require(msg.sender == owner);`

*Note that in the* `assert()` *and* `require()` *examples, the conditional statement is an inversion of the* `if` *block’s condition, switching the comparison operator* `!=`*to* `==`*.*

# Differentiating between assert() and require()

First, to help separate these ‘guard’ functions in your mind, imagine**`assert()`** as an overly **assertive** bully, who steals all your gas. Then imagine **`require()`** as a polite managerial type, who calls out your errors, but is more **forgiving**.

With that mnemonic handy, what’s the real difference between these two functions?

Prior to the Byzantium network upgrade, `require()` and `assert()` actually behave identically, but their bytecode output is slightly different.

1. `assert()` uses the **`0xfe`** opcode to cause an error condition
2. `require()` uses the **`0xfd`** opcode to cause an error condition

If you look up either of those opcodes in the yellow paper, you won’t find them. This is why you see the `invalid opcode` error, because there’s no specification for how a client should handle them.

That will change however after Byzantium, and the implemention of [EIP-140: REVERT instruction in the Ethereum Virtual Machine ](https://www.google.com/url?q=https://github.com/axic/EIPs/blob/revert/EIPS/eip-140.md&sa=D&ust=1505493857492000&usg=AFQjCNGXZHdWiEuBOiiP1YhvQr4Ilij8hA). Then the`0xfd` opcode will be mapped to the`REVERT` instruction.

This is what I find really fascinating:

**Many contracts have been deployed since version 0.4.10, which include a new opcode lying dormant, until it’s no longer invalid. At the appointed time, it will wake up, and become** **`REVERT`**!

*Note:* `throw` *and*`revert()` *also use* `0xfd\`*. Prior to 0.4.10.* `throw` *used* `0xfe\`.

# What the REVERT opcode will do

**` REVERT`** will still undo all state changes, but it will be handled differently than an “invalid opcode” in two ways:

1. It will allow you to return a value.
2. It will refund any remaining gas to the caller.

## 1. It will allow you to return a value

Most smart contract developers are quite familiar with the notoriously unhelpful `invalid opcode` error. Fortunately, we’ll soon be able to return an error message, or a number corresponding to an error type.

That will look something like this:

```
revert(‘Something bad happened’);
```

or

```
require(condition, ‘Something bad happened’);
```

*Note: solidity doesn’t support this return value argument yet, but you can watch* [*this issue*](https://www.google.com/url?q=https://www.google.com/url?q%3Dhttps://github.com/ethereum/solidity/issues/1686%23issuecomment-328181514%26sa%3DD%26ust%3D1505492320159000%26usg%3DAFQjCNHaxNwU92XDdLnWcaMYGX9luuhaQg&sa=D&ust=1505493857494000&usg=AFQjCNEqYU3HJRPkQLJRNvYobZIVPufwbA) *for that update.*

## 2. Refund the remaining gas to the caller

Currently, when your contract throws it uses up any remaining gas. This can result in a very generous donation to miners, and often ends up costing users a lot of money.

Once `REVERT` is implemented in the EVM, it will be plain old bad manners not to use it to refund the excess gas.

# Choosing between revert(), assert() and require()

So, if`revert()` and `require()` both refund any left over gas, AND allow you to return a value, why would want to burn up gas using `assert()`?

The difference lies in the bytecode output, and for this I’ll quote from the [docs](https://www.google.com/url?q=https://solidity.readthedocs.io/en/develop/control-structures.html%23error-handling-assert-require-revert-and-exceptions&sa=D&ust=1505493857495000&usg=AFQjCNGsr19Xr-gK6reStgpM9BcgXnCb3Q)(emphasis mine):

> The `require` function should be used to ensure valid conditions, such as inputs, or contract state variables are met, or to validate return values from calls to external contracts. If used properly, analysis tools can evaluate your contract to identify the conditions and function calls which will reach a failing `assert`. **Properly functioning code should never reach a failing assert statement; if this happens there is a bug in your contract which you should fix.**

To clarify that somewhat: it should be considered a normal and healthy occurrence for a `require()` statement to fail (same with `revert()`). When an `assert()` statement fails, something very wrong and unexpected has happened, and you need to fix your code.

By following this guidance, [static analysis](https://en.wikipedia.org/wiki/Static_program_analysis) and [formal verification](https://en.wikipedia.org/wiki/Static_program_analysis#Formal_methods) tools will be able to examine your contracts to find and prove the conditions which could break your contract, or to prove that your contract operates as designed without flaws.

In practice, I use a few heuristics to help me decide which is appropriate.

**Use** `require()`**to:**

- Validate user inputs ie. `require(input<20);`
- Validate the response from an external contract ie. `require(external.send(amount));`
- Validate state conditions prior to execution, ie. `require(block.number > SOME_BLOCK_NUMBER)` or `require(balance[msg.sender]>=amount)`
- Generally, you should use `require` most often
- Generally, it will be used towards **the beginning** of a function

There are many examples of `require()` in use for such things in our [Smart Contract Best Practices](https://github.com/ConsenSys/smart-contract-best-practices).

**Use** **`revert()`** **to:**

- Handle the same type of situations as `require()`, but with more complex logic.

If you have some complex nested `if/else` logic flow, you may find that it makes sense to use `revert()` instead of `require()`. Keep in mind though, [complex logic is a code smell](https://github.com/ConsenSys/smart-contract-best-practices#fundamental-tradeoffs-simplicity-versus-complexity-cases).

**Use** **`assert()`** **to:**

- Check for [overflow/underflow](https://github.com/ConsenSys/smart-contract-best-practices#integer-overflow-and-underflow), ie. `c = a+b; assert(c > b)`
- Check [invariants](https://en.wikipedia.org/wiki/Invariant_(computer_science)), ie.` assert(this.balance >= totalSupply);`
- Validate state after making changes
- Prevent conditions which should never, ever be possible
- Generally, you will probably use `assert` less often
- Generally, it will be used towards **the end** of a function.

Basically, `require()` should be your go to function for checking conditions, `assert()` is just there to prevent anything really bad from happening, but it shouldn’t be possible for the condition to evaluate to `false`.

Also: “you should not use `assert` blindly for overflow checking but only if you think that previous checks (either using `if`or `require`) would make an overflow impossible”. — [comment](https://medium.com/@chriseth/thanks-for-this-detailed-writeup-83addc4b7f87) from @chriseth

# Conclusion

These functions are very powerful tools for your security toolbox. Knowing how and when to use them will not only help prevent vulnerabilities, but also make your code more user friendly, and future proof against upcoming changes.



