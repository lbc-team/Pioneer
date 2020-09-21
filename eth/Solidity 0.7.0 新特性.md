# Changes in Solidity 0.7.0



## A Supplemental Overview of The Changes in Solidity 0.7.0

On July 28th, 2020, the solidity compiler got a minor version bump to 0.7.0\. It was accompanied by a [release changelog 2](https://github.com/ethereum/solidity/releases/tag/v0.7.0) sporting 32 bullet-points and an entire page of [documentation devoted to breaking changes 2](https://solidity.readthedocs.io/en/latest/070-breaking-changes.html). It’s worth spending a little time diving into what’s changed and briefly considering how those changes impact Solidity smart contract code in practice.

Below, I’ll synthesize the changelog and breaking changes doc mentioned above, restating what’s been written there while attempting to clarify and supplement wherever it seems beneficial to do so. I’ve attempt to present the changes in groups ordered by their likelihood of being encountered in practice. At the end, I list any changes that I felt didn’t require much supplemental explanation.

### Most Pronounced Changes

* There’s a new syntax for external function and contract creation calls that will probably look familiar to Soldity developers who have also used Web3.js. Rather than `contract.function.gas(1000).value(2 ether)(arg1, arg2)` the new syntax is `contract.function{gas: 1000, value: 2 ether}(arg1, arg2)`. Using the old syntax is no longer allowed.

* Constructor visibility (`public` / `external`) is now ignored and, as such, no longer needs to be specified. The parser will now warn about this. To prevent a contract from being deployable, the contract itself can be marked with the keyword `abstract` (e.g. `abstract Contract {}`).

* The global variable `now` is no longer allowed. It has been deprecated in favor of `block.timestamp`. This has already been a best practice for a while and should help avoid the misleading mental model that the term “now” tends to lend itself to.

* NatSpec comments are now disallowed for non-public state variables. Practically, this means converting existing implicit or explicit `@notice` NatSpec comments (e.g. `/// comment` or `/// @notice comment`) to either explicit `@dev` comments (e.g. `/// @dev comment`) or simple inline comments (e.g. `// comment`). Such comments are not uncommon in libraries, so one may find themselves having to fix dependencies until the ecosystem gets caught up.

* The token `gwei` is now a keyword and, so, cannot be used as a variable or function name. In `^0.6.0` the token `gwei` served as a denomination *and* could also,confusingly, be used as an identifier simultaneously - as in the example below:

```
// Behavior Before
uint gwei = 5;
uint value = gwei * 1 gwei; // value: 5000000000
```

  Trying to create such confusion with `gwei` will now just throw a well-deserved parsing error.

* On a related note, the keywords `finney` and `szabo` have been retired and, as a result, may now be used as identifiers. (Though using them immediately may not be advisable to avoid potential confusion.)

* String literals containing anything other than [ASCII characters and a variety of escape sequences 2](https://solidity.readthedocs.io/en/latest/types.html?highlight=ascii#string-literals-and-types) will now throw a parser error.

* String literals that need to express more than ASCII should now be explicitly typed as *unicode* string literals. They are identified with the `unicode` prefix (e.g. `unicode"Text, including emoji! 🤓"`).

* Derived contracts no longer inherit library `using` declarations for types (e.g. `using SafeMath for uint`). Instead, such declarations must be repeated in *every* derived contract that wishes to use the library for a type.

* Events in the same inheritance hierarchy are no longer allowed to have the same name and parameter types.

### Still Perceptible Changes

* Declaring a variable with the `var` keyword so that its type is assigned implicitly has been deprecated for several releases in favor of explicitly typed variables. However, the compiler would still recognize the `var` syntax and complain about it with a type error. Now, the `var` keyword is simply not allowed and will result in a parser error.

* Function state mutability can now be made more restrictive during inheritance. So, `public` functions with default mutability can be overridden by `view` or `pure` functions. If an inherited function is marked `view`, then it can be overridden by a `pure` function.

```
 // Behavior Now
contract Parent {
  function show() public virtual returns(uint){
      return 100;
  }
}

contract Child is Parent {
    function show() public pure override returns(uint){ // overriding with pure is allowed
        return 25;
    }
}
```

* Prior to this release, shifts and exponentiation of literals by non-literals (e.g. `250 << x` or `250 ** x`) would be performed using the type of either the shift amount or the exponent (i.e. `x` in the examples). Now, either `uint256` (for non-negative literals) or `int256` (for negative literals) will be used to perform the operations.

```
// Behavior Before
uint8 x = 2;

uint shift = 250 << x; // shift: 232
uint exp = 250 ** x; // exp: 36
```

```
// Behavior Now
uint8 x = 2;

uint shift = 250 << x; // shift: 1000
uint exp = 250 ** x; // exp: 62500
```

Notice how before, both results were implicitly cast to the type of `x` which is `uint8` and, as a consequence, overflowed accordingly.

Now, more intuitively, both results are of type `uint256` and, so, avoid overflowing in this case.

* Shifts (e.g. `shiftThis >> amount` `shiftThis << amount`) by signed types are no longer allowed. Previously, negative shifts were permitted, but would revert at runtime.

* The parser will no longer recommend stricter mutability for virtual functions, but **will** still make such recommendations for any overriding functions.

* Library functions can no longer be marked `virtual`. Which makes sense, given the fact that libraries cannot be inherited.

### Less Noticeable Changes

#### Mappings Outside Storage

* Mappings only exist in storage, and, previously, mappings in structs or arrays would be ignored/skipped. Such behavior was, we agree with the docs, “confusing and error-prone”. Similar “skipping” behavior was encountered when assigning to structs or arrays in storage if they contained mappings. These sorts of assignments are no longer allowed - making things much less confusing.

#### Inline Assembly

* Inline assembly no longer supports user-defined identifiers with a `.` (*period*) - unless operating in Solidity Yul-only mode.

* Slot and offset of storage pointer variables are now accessed with dot notation `.` (e.g. `stor.slot` & `stor.offset`) rather than an underscore `_` (e.g. `stor_slot` & `stor_offset`).

#### YUL

> * Disallow consecutive and trailing dots in identifiers. Leading dots were already disallowed.
> * Yul: Disallow EVM instruction pc().

What’s the `pc` instruction, you might wonder? As defined in the yellow paper, it should: “Get the value of the program counter prior to the increment corresponding to this instruction.”

### Mentioned for Completeness

#### Compiler Features

> * SMTChecker: Report multi-transaction counterexamples including the function calls that initiate the transactions. This does not include concrete values for reference types and reentrant calls.

#### JSON AST (Abstract Syntax Tree)

> * Hex string literals are now marked with kind: “hexString”.
> * Members with null values are removed from the output.

#### Bugfixes

> * Inheritance: Disallow public state variables overwriting pure functions.
> * NatSpec: Constructors and functions have consistent userdoc output.
> * SMTChecker: Fix internal error when assigning to a 1-tuple.
> * SMTChecker: Fix internal error when tuples have extra effectless parenthesis.
> * State Mutability: Constant public state variables are considered pure functions.
> * Type Checker: Fixing deduction issues on function types when function call has named arguments.
> * Immutables: Fix internal compiler error when immutables are not assigned.

* * *

Good work making it to the bottom of the list! As you can see, the trend to make Solidity ever-more explicit is alive and well. This is a net positive for smart contract security - and staying up to date with the latest Solidity changes is an important part of being a proficient Soldity dev.

If you need some tips for updating your code, don’t overlook the tips in the [docs 2](https://solidity.readthedocs.io/en/latest/070-breaking-changes.html?highlight=shift#how-to-update-your-code) and be sure to check out the [solidity-upgrade tool 5](https://solidity.readthedocs.io/en/latest/using-the-compiler.html#solidity-upgrade).

If anything is unclear or you’d like to discuss any of the changes, feel free to continue the conversation below!

原文链接：https://forum.openzeppelin.com/t/changes-in-solidity-0-7-0/3758
作者：[CallMeGwei](https://forum.openzeppelin.com/u/CallMeGwei)