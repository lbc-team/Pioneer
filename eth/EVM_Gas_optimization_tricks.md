# EVM Gas optimization tricks
The goal of this repository is to compile all evm gas optimization tricks and resources for learning about them.

Feel free to submit a pull request, with anything from small fixes to docs or tools you'd like to add.



## Main Gas optimization areas in solidity
* Storage
* Variables
* Functions
* Loops
* Operations
## Storage
* Saving one variable in storage costs 20,000 gas (Check gas used by EVM opcodes)
* 5,000 gas when we rewrite the variable
* reading from the slot take 200 gas
* But storage variable declaration doesn't cost anything, as there's no initialization
## Tips
* always save a storage variable in memory in a function
* if you wanna update a storage variable then first calculate everything in the memory variables
* organize & try to pack two or more storage variables into one it's much cheaper
* also while using structs, try to pack them
* Don’t initialize Zero Values - when writing a for loop instead of writing `uint256 index = 0`; instead write `uint256 index`; as being a uin256 it will be 0 by default so you can save some gas by avoiding initialization
* make solidity values constant where possible
## Refunds
* Free storage slot by zeroing corresponding variables as soon as you don't need them anymore. This will refund 15,000 of gas.
* Removing a contract by using Selfdestruct opcodes refunds 24,000 gas. But a refund must not surpass half the gas that the ongoing contract call uses.
## Data types and packing
* Use bytes32 whenever possible, because it is the most optimized storage type.
* If the length of bytes can be limited, use the lowest amount possible from bytes1 to bytes32.
* Using bytes32 is cheaper than using string
* Variable packing only occurs in storage — memory and call data does not get packed.
* You will not save space trying to pack function arguments or local variables
* Storing a small number in a uint8 variable is not cheaper than storing it in uint256 coz the number in uint8 is padded with numbers to fill 32 bytes.
## Inheritance
* when we extend a contract, the variables in the child can be packed with the variables in the parent.

* The order of variables is determined by [C3 linearization](https://en.wikipedia.org/wiki/C3_linearization), all you need to know is that child variables come after parent variables.

## Memory vs Storage
* copying between the memory and storage will cost some gas, so don't copy arrays from storage to memory, use a [storage pointer](https://blog.b9lab.com/storage-pointers-in-solidity-7dcfaa536089).

* the cost of memory is complicated. you "buy" it in chunks, the cost of which will go up quadratically after a while

* Try adjusting the location of your variables by playing with the keywords "storage" and "memory". Depending on the size and number of copying operations between Storage and memory, switching to memory may or may not give improvements. All this is coz of varying memory costs. So optimizing here is not that obvious and every case has to be considered individually.

## Variables
* Avoid public variables
* Use global variables efficiently
* it is good to use global variables with private visibility as it saves gas
* Use events rather than storing data
* Use memory arrays efficiently
* Use return values efficiently
* A simple optimization in Solidity consists of naming the return value of a function. It is not needed to create a local variable then.
## Mapping vs Array
* Use mapping whenever possible, it's cheap instead of the array
* But an array could be a good choice if you have a small array
## Fixed vs Dynamic
* Fixed size variables are always cheaper than dynamic ones.
* It's good to use memory arrays if the size of the array is known, fixed-size memory arrays can be used to save gas.
* If we know how long an array should be, we specify a fixed size
* This same rule applies to strings. A string or bytes variable is dynamically sized; we should use a byte32 if our string is short enough to fit.
* If we absolutely need a dynamic array, it is best to structure our functions to be additive instead of subractive. Extending an array costs constant gas whereas truncating an array costs linear gas.
## Functions
* use external most of the time whenever possible
* Each position will have an extra 22 gas, so
  * Reduce public varibles
  * Put often-called functions earlier
* reduce the parameters if possible (Bigger input data increases gas because more things will be stored in memory)
* payable function saves some gas as compared to non-payable functions (as the compiler won't have to check)
* Solidity Modifiers Increase Code Size, So sometimes make them functions
## Fallback Function
* Fallback Function Calls are cheaper than regular function calls - The Fallback function (and Sig-less functions in Yul) save gas because they don’t require a function signature to call, for an example implementation I recommend looking at @libevm’s [subway](https://github.com/libevm/subway/blob/master/contracts/src/Sandwich.yulp) which utilize’s a sig-less function
## View Functions
* You are not paying for view functions but this doesn't mean they aren't consuming gas, they do.
* it cost gas when calling in a tx
## Loops
* use memory variables in loops
* try to avoid unbounded loops
* write uint256 index; instead of writing uint256 index = 0; as being a uint256, it will be 0 by default so you can save some gas by avoiding initialization.
* if you put `++` before `i` it costs less gas
## Operations
### Order
* Order cheap functions before
  * f(x) is cheap
  * g(y) is expensive
  * ordering should be
  * f(x) || g(y)
  * f(x) && g(y)
## Use Short-Circuiting rules to your advantage
When using logical disjunction (||), logical conjunction (&&), make sure to order your functions correctly for optimal gas usage. In logical disjunction (OR), if the first function resolves to true, the second one won’t be executed and hence save you gas. In logical disjunction (AND), if the first function evaluates to false, the next function won’t be evaluated. Therefore, you should order your functions accordingly in your solidity code to reduce the probability of needing to evaluate the second function.

## Using unchecked
Use unchecked for arithmetic where you are sure it won't over or underflow, saving gas costs for checks added from solidity v0.8.0.

## Other Optimizations
* Remove the dead code
* Use different solidity versions and try
* EXTCODESIZE is quite expensive, this is used for calls between contracts, the only option we see to optimize the code in this regard is minimizing the number of calls to other contracts and libraries.
* If you are testing in Production, use Self-Destruct and Factory patterns for an Upgradeable contract - Using a technique explained in this [Twitter thread](https://twitter.com/libevm/status/1468390867996086275?s=21) you can make it easily upgradeable and testable contracts with re-init and self-destruct. This mostly applied to MEV but if you are doing some cool factory-based programming it’s worth trying out.
## Libraries
When a public function of a library is called, the bytecode of that function is not made part of a client contract. Thus, complex logic should be put in libraries (but there is also the cost of calling the library function)

## Errors
* Use "require" for all runtime conditions validations that can't be prevalidated on the compile time. And "assert" should be used only for static validation that normally fails never fail on a properly functioning code.
* string size in require statements can be shortened to reduce gas.
* A failing "assert" consumer all the gas available to the call, while "require" doesn't consume any.
## Hash functions
* keccak256: 30 gas + 6 gas for each word of input data
* sha256: 60 gas + 12 gas for each word of input data
* ripemd160: 600 gas + 120 gas for each word of input data
* So if you don't have any specific reasons to select another hash function, just use keccak256
## Use ERC1167 To Deploy the same Contract many times
EIP1167 minimal proxy contract is a standardized, gas-efficient way to deploy a bunch of contract clones from a factory.EIP1167 not only minimizes length, but it is also literally a “minimal” proxy that does nothing but proxying. It minimizes trust. Unlike other upgradable proxy contracts that rely on the honesty of their administrator (who can change the implementation), the address in EIP1167 is hardcoded in bytecode and remain unchangeable

## Merkle proof
* A Merkle tree can be used to prove the validity of a large amount of data using a small amount of data.
## Yul tricks
* Utilize Access Lists for the Good of the Chain and Save gas - Call eth_createAccessList on a node (probably Geth) and include your transaction blob, and include that access list when sending your transaction to save gas, especially helpful the more storage slots your write to.

**Important** too for Ethereum’s state management, and will eventually be used to do cool things

* Before Using Yul, Verify YOUR assembly is better than the compiler’s [- Case and Point](https://twitter.com/fubuloubu/status/1453002622642819093) Just a reminder if you are a Yul Noob it may be worth testing against Solidity implementations to see if you are saving gas

* Overwrite new values onto old ones you’re not using when Possible - Solidity doesn’t garbage collect, and this is just cheaper in Yul, but write new values onto old unused ones to conserve memory and storage used saving gas!

* Keep Data in Calldata where possible - Since Calldata has already been paid for with the transaction, if you don’t modify a parameter to a function, then don’t bother copying the function to memory and just read the value from calldata.

* View Solidity Compiler Yul Output - If you want to see what your Solidity is doing under the hood, just add -yul and -ir to your solc compiler options. Very helpful to see how your code is working, see if you order operations unsafely, or just see how Solidity is beating your Yul in gas usage.

[Solc Compiler Options](https://docs.soliditylang.org/en/latest/using-the-compiler.html)

* Using Vanity Addresses with lots of leading zeroes- Why? Well if you have 2 addresses - 0x000000a4323… and 0x0000000000f38210 because of the leading zeroes you can pack them both into the same storage slot, then just prepend the necessary amount of zeroes when using them. This saves you storage when doing things such as checking the owner of a contract.

* Using Sub 32 Byte values doesn’t always save gas - Sub 32 byte values can save gas in the event of packing, but note that they require extra gas to decode and should be used on a case-by-case basis.

* Writing to an existing Storage Slot is cheaper than using a new one - EIP - 2200 changed a lot with gas, and now if you hold 1 Wei of a token it’s cheaper to use the token than if you hold 0. There is a lot to unpack here so just google EIP 2200 and learn if you want, but in general, if you need to use a storage slot, don’t empty it if you plan to re-fill it later. Goes for all Yul+ and Yul contracts when managing memory.

* Negative values are more expensive in calldata - Negative values have leading bytes of 0xfff while regular integers have zeri leading bytes, and in calldata non-zero bytes cost more than zero bytes, so negative ints end up consuming more gas in calldata.

* Using iszero() in a lot of places because the compiler is smart - He explains it very well [here](https://twitter.com/transmissions11/status/1474465495243898885) but because the compiler knows how to optimize, putting it before some pieces of logic can end up reducing overall gas costs, so test out inserting it before JUMP opcodes.

* Use Gas() when using call() in Yul - When using call() in Yul you can avoid manually counting out all the gas you need to perform the call, and just forward all available gas via using gas() for the gas parameter.

* A lot of [Solmate](https://github.com/transmissions11/solmate) is written in inline Yul, so if you’re writing in Yul, you can just copy a lot of the assembly - Solmate is written as very efficient Solidity, and because of this is mostly Yul. So if you don’t know how to find a Sqrt in Yul for example, just go to Solmate and copy from within the assembly {} blocks for a working implementation, then add GPL-V3 to your SPDX license identifier!

* Store Storage in Code - So [Zefram’s blog](https://zefram.xyz/posts/how-i-almost-cheesed-the-evm/) explains this well, but you can save gas by deploying what you want to store in a new contract, and deploying that contract, then reading from that address. This adds a lot of complexity to code but if you need to cut costs and use SLOAD a lot, I recommend looking into SLOAD2.

* Half of the Zero Address Checks in the NFT spec aren’t necessary - Launching a new NFT collection and looking to cut minting and usage costs? Use Solmate’s NFT contracts, as the standard needlessly prevents transfers to the void, unless someone can call a contract from the 0 address, and the 0 address has unique permissions, you don’t need to check that the caller isn’t the 0 address 90% of the time.

* If it can’t overflow without uint256(-1) calls, you don’t need to check for overflow - Save gas and avoid safemath with unchecked {} , this one is Solidity only but I wanted to include it, I was tired of seeing counters using Safemath, it is cost-prohibitive enough to call a contract billions of times to prevent an attack.

* Trustless calls from L2 to L2 exist, and can be very useful for L2 based DAO’s - The OVM and ArbOS have built-in functions on contract calls from L1 to L2 to verify msg.sender and vice versa. Therefore if you make an L1 contract that can only be called by a trusted party on one L2 before calling another L2, you can create a trustless bridge. Recommend reading about Hop for this, but a cool design choice for DAO building.

## Some more resources
[Check Gas used by EVM Opcodes](https://github.com/crytic/evm-opcodes)

[Awesome Solidity Gas Optimization](https://github.com/harendra-shakya/awesome-solidity-gas-optimization)

[Yul (and Some Solidity) Optimizations and Tricks](https://hackmd.io/@gn56kcRBQc6mOi7LCgbv1g/rJez8O8st)

[Gas Puzzel](https://github.com/RareSkills/gas-puzzles)

## Tools for estimating gas
Remix
Truffle
Eth Gas reporter