> * 来源：https://blog.trailofbits.com/2020/10/30/good-idea-bad-design-how-the-diamond-standard-falls-short/ 


# Good idea, bad design: How the Diamond standard falls short


**TL;DR:** We audited an implementation of the [Diamond standard proposal](https://eips.ethereum.org/EIPS/eip-2535) for contract upgradeability and can’t recommend it in its current form—but see our recommendations and upgrade strategy guidance.

We recently audited an implementation of the Diamond standard code, a new upgradeability pattern. It’s a laudable undertaking, but the Diamond proposal and implementation raise many concerns. The code is over-engineered, with lots of unnecessary complexities, and we can’t recommend it at this time.

Of course, the proposal is still a draft, with room to grow and improve. A working upgradeability standard should include:

* **A clear, simple implementation.** Standards should be easy to read to simplify integration with third-party applications.
* **A thorough checklist of upgrade procedures.** Upgrading is a risky process that must be thoroughly explained.
* **On-chain mitigations against the most common upgradeability mistakes, including function shadowing and collisions.** Several mistakes, though easy to detect, can lead to severe issues. See [slither-check-upgradeability](https://github.com/crytic/slither/wiki/Upgradeability-Checks) for many pitfalls that can be mitigated.
* **A list of associated risks.** Upgradeability is difficult; it can conceal security considerations or imply that risks are trivial. EIPs are proposals to improve Ethereum, not commercial advertisements.
* **Tests integrated with the most common testing platforms.** The tests should highlight how to deploy the system, how to upgrade a new implementation, and how an upgrade can fail.

Unfortunately, the Diamond proposal fails to address these points. It’s too bad, because we’d love to see an upgradeable standard that solves or at least mitigates the main security pitfalls of upgradeable contracts. Essentially, standard writers must assume that developers will make mistakes, and aim to build a standard that alleviates them.

Still, there’s plenty to learn from the Diamond proposal. Read on to see:

* How the Diamond proposal works
* What our review revealed
* Our recommendations
* Upgradeability standard best practices

## The Diamond proposal paradigm

The Diamond proposal is a work-in-progress defined in [EIP 2535](https://eips.ethereum.org/EIPS/eip-2535). The draft claims to propose a new paradigm for contract upgradeability based on delegatecall. (FYI, here’s [an overview of how upgradeability works.](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/)) EIP 2535 proposes the use of:

1. A lookup table for the implementation
2. An arbitrary storage pointer

### Lookup table

The delegatecall-based upgradeability mainly works with two components—a proxy and an implementation:

![](https://img.learnblockchain.cn/2020/11/10/16049796156616.jpg)



**Figure 1**: delegatecall-based upgradeability with a single implementation

The user interacts with the proxy and the proxy delegatecall to the implementation. The implementation code is executed, while the storage is kept in the proxy.

Using a lookup table allows delegatecalls to multiple contract implementations, where the proper implementation is selected according to the function to be executed:

![](https://img.learnblockchain.cn/2020/11/10/16049796556398.jpg)

**Figure 2**: delegatecall-based upgradeability with multiple implementations.

This schema is not new; other projects have used such lookup tables for upgradeability in the past. See [ColonyNetwork](https://colony.io/dev/docs/colonynetwork/docs-upgrade-design) for an example.

### Arbitrary storage pointer

The proposal also suggests using a feature recently introduced into Solidity: the [arbitrary storage pointer](https://github.com/ethereum/solidity/releases/tag/v0.6.4), which (like the name says) allows assignment of a storage pointer to an arbitrary location.

Because the storage is kept on the proxy, the implementation’s storage layout must follow the proxy’s storage layout. It can be difficult to keep track of this layout when doing an upgrade ([see examples here](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/)).

The EIP proposes that every implementation have an associated structure to hold the implementation variables, and a pointer to an arbitrary storage location where the structure will be stored. This is similar to the [unstructured storage](https://github.com/OpenZeppelin/openzeppelin-labs/tree/ff479995ed90c4dbb5e32294fa95b16a22bb99c8/upgradeability_using_unstructured_storage) pattern, where the new Solidity feature allows use of a structure instead of a single variable.

It is assumed that two structures from two different implementations cannot collide as long as their respective base pointers are different.

```
bytes32 constant POSITION = keccak256(
     "some_string"
 );
 
 struct MyStruct {
     uint var1;
     uint var2;
 }
 
 function get_struct() internal pure returns(MyStruct storage ds) {
     bytes32 position = POSITION;
     assembly { ds_slot := position }
 }  
```
 

**Figure 3**: Storage pointer example.

![](https://img.learnblockchain.cn/2020/11/10/16049797478169.jpg)

**Figure 4**: Storage pointer representation.

### BTW, what’s a “diamond”?

EIP 2535 introduces “diamond terminology,” wherein the word “diamond” means a proxy contract, “facet” means an implementation, and so on. It’s unclear why this terminology was introduced, especially since the standard terminology for upgradeability is well known and defined. Here’s a key to help you translate the proposal if you go through it:


 Diamond vocabulary | Common name 
 ------------------ | ----------- 
 Diamond | Proxy 
 Facet | Implementation 
 Cut | Upgrade 
 Loupe | List of delegated functions 
 Finished diamond | Non-upgradeable 
 Single cut diamond | Remove upgradeability functions 

**Figure 5**: The Diamond proposal uses new terms to refer to existing ideas.

## Audit findings and recommendations

Our review of the diamond implementation found that:

* The code is over-engineered and includes several misplaced optimizations
* Using storage pointers has risks
* The codebase had function shadowing
* The contract lacks an existence check
* The diamond vocabulary adds unnecessary complexity

### Over-engineered code

While the pattern proposed in the EIP is straightforward, its actual implementation is difficult to read and review, increasing the likelihood of issues.

For example, a lot of the data kept on-chain is cumbersome. While the proposal only needs a lookup table, from the function signature to the implementation’s address, the EIP defines many interfaces that require storage of additional data:

```
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.
 
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }
 
    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);
 
    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);
 
    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_);
 
    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
```

**Figure 6**: Diamond interfaces.

Here, *facetFunctionSelectors* returns all the function selectors of an implementation. This information will only be useful for off-chain components, which can already extract the information from the contract’s events. There’s no need for such a feature on-chain, especially since it significantly increases code complexity.

Additionally, much of the code complexity is due to optimization in locations that don’t need it. For example, the function used to upgrade an implementation should be straightforward. Taking a new address and a signature, it should update the corresponding entry in the lookup table. Well, part of the function doing so is the following:

```
// adding or replacing functions
 if (newFacet != 0) {
     // add and replace selectors
     for (uint selectorIndex; selectorIndex &amp;amp;amp;amp;amp;lt; numSelectors; selectorIndex++) {
         bytes4 selector;
         assembly {
             selector := mload(add(facetCut,position))
         }
         position += 4;
         bytes32 oldFacet = ds.facets[selector];
         // add
         if(oldFacet == 0) {
             // update the last slot at then end of the function
             slot.updateLastSlot = true;
             ds.facets[selector] = newFacet | bytes32(selectorSlotLength) &amp;amp;amp;amp;amp;lt;&amp;amp;amp;amp;amp;lt; 64 | bytes32(selectorSlotsLength);
             // clear selector position in slot and add selector
             slot.selectorSlot = slot.selectorSlot &amp;amp;amp;amp;amp;amp; ~(CLEAR_SELECTOR_MASK &amp;amp;amp;amp;amp;gt;&amp;amp;amp;amp;amp;gt; selectorSlotLength * 32) | bytes32(selector) &amp;amp;amp;amp;amp;gt;&amp;amp;amp;amp;amp;gt; selectorSlotLength * 32;
             selectorSlotLength++;
             // if slot is full then write it to storage
             if(selectorSlotLength == 8) {
                 ds.selectorSlots[selectorSlotsLength] = slot.selectorSlot;
                 slot.selectorSlot = 0;
                 selectorSlotLength = 0;
                 selectorSlotsLength++;
             }
         }
         // replace
         else {
             require(bytes20(oldFacet) != bytes20(newFacet), "Function cut to same facet.");
             // replace old facet address
             ds.facets[selector] = oldFacet &amp;amp;amp;amp;amp;amp; CLEAR_ADDRESS_MASK | newFacet;
         }
     }
 }
```

**Figure 7**: Upgrade function.

A lot of effort was made to optimize this function’s gas efficiency. But upgrading a contract is rarely done, so it would never be an expensive operation anyway, no matter what its gas cost.

In another example of unnecessary complexity, bitwise operations are used instead of a structure:

```
uint selectorSlotsLength = uint128(slot.originalSelectorSlotsLength);
uint selectorSlotLength = uint128(slot.originalSelectorSlotsLength &amp;amp;amp;amp;amp;gt;&amp;amp;amp;amp;amp;gt; 128);
```

```
// uint32 selectorSlotLength, uint32 selectorSlotsLength
// selectorSlotsLength is the number of 32-byte slots in selectorSlots.
// selectorSlotLength is the number of selectors in the last slot of
// selectorSlots.
uint selectorSlotsLength;
```

**Figure 8**: Use of bitwise operations instead of a structure.

*Update November 5th:*
*Since our audit, the [reference implementation has changed](https://github.com/mudgen/diamond), but its underlying complexity remains. There are now three reference implementations, which makes everything even more confusing for users, and further review of the proposal is more difficult.*

#### Our recommendations:

* Always strive for simplicity, and keep as much code as you can off-chain.
* When writing a new standard, keep the code readable and easy to understand.
* Analyze the needs before implementing optimizations.

### Storage pointer risks

Despite the claim that collisions are impossible if the base pointers are different, a malicious contract can collide with a variable from another implementation. Basically, it’s possible because of the way Solidity stores variables and affects mapping or arrays. For example:

```
contract TestCollision{
     
    // The contract represents two implementations, A and B
    // A has a nested structure 
    // A and B have different bases storage pointer 
    // Yet writing in B, will lead to write in A variable
    // This is because the base storage pointer of B 
    // collides with A.ds.my_items[0].elems
     
    bytes32 constant public A_STORAGE = keccak256(
        "A"
    );
     
    struct InnerStructure{
        uint[] elems;
    }
     
    struct St_A {
        InnerStructure[] my_items;
    }
 
    function pointer_to_A() internal pure returns(St_A storage s) {
        bytes32 position = A_STORAGE;
        assembly { s_slot := position }
    }
     
     
    bytes32 constant public B_STORAGE = keccak256(
        hex"78c8663007d5434a0acd246a3c741b54aecf2fefff4284f2d3604b72f2649114"
    );
     
    struct St_B {
        uint val;
    }
 
    function pointer_to_B() internal pure returns(St_B storage s) {
        bytes32 position = B_STORAGE;
        assembly { s_slot := position }
    }
     
     
    constructor() public{
        St_A storage ds = pointer_to_A();
        ds.my_items.push();
        ds.my_items[0].elems.push(100);
    }
     
    function get_balance() view public returns(uint){
        St_A storage ds = pointer_to_A();
        return ds.my_items[0].elems[0];
    }
     
    function exploit(uint new_val) public{
        St_B storage ds = pointer_to_B();
        ds.val = new_val;
    }
     
}
```

**Figure 9**: Storage pointer collision.

In *exploit*, the write to the *B_STORAGE* base pointer will actually write to the *my_items[0].elems[0]*, which is read from the *A_STORAGE* base pointer. A malicious owner could push an upgrade that looks benign, but contains a backdoor.

The EIP has no guidelines for preventing these malicious collisions. Additionally, if a pointer is reused after being deleted, the re-use will lead to data compromise.

#### Our recommendations

* Low-level storage manipulations are risky, so be extra careful when designing a system that relies on them.
* Using unstructured storage with structures for upgradeability is an interesting idea, but it requires thorough documentation and guidelines on what to check for in a base pointer.

### Function shadowing

Upgradeable contracts often have functions in the proxy that shadow the functions that should be delegated. Calls to these functions will never be delegated, as they will be executed in the proxy. Additionally, the associated code will not be upgradeable.

```
contract Proxy {
 
    constructor(...) public{
          // add my_targeted_function() 
          // as a delegated function
    }
     
    function my_targeted_function() public{
    }
  
    fallback () external payable{
          // delegate to implementations
    }
}
```
**Figure 10**: Simplification of a shadowing issue.

Although this issue is well known, and the code was reviewed by the EIP author, we found two instances of function-shadowing in the contracts.

#### Our recommendations

* When writing an upgradeable contract, use [crytic.io](https://crytic.io/) or [slither-check-upgradeability](https://github.com/crytic/slither/wiki/Upgradeability-Checks) to catch instances of shadowing.
* This issue highlights an important point: Developers make mistakes. Any new standard should include mitigations for common mistakes if it’s to work better than custom solutions.

### No contract existence check

Another common mistake is the absence of an existence check for the contract’s code. If the proxy delegates to an incorrect address, or implementation that has been destructed, the call to the implementation will return success even though no code was executed (see the [Solidity documentation](https://solidity.readthedocs.io/en/v0.4.24/control-structures.html#error-handling-assert-require-revert-and-exceptions)). As a result, the caller will not notice the issue, and such behavior is likely to break third-party contract integration.

```
fallback() external payable {
     DiamondStorage storage ds;
     bytes32 position = DiamondStorageContract.DIAMOND_STORAGE_POSITION;
     assembly { ds_slot := position }
     address facet = address(bytes20(ds.facets[msg.sig]));
     require(facet != address(0), "Function does not exist.");
     assembly {
         calldatacopy(0, 0, calldatasize())
         let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
         let size := returndatasize()
         returndatacopy(0, 0, size)
         switch result
         case 0 {revert(0, size)}
         default {return (0, size)}
     }
 }
```

**Figure 11**: Fallback function without contract’s existence check.

#### Our recommendations

* Always check for contract existence when calling an arbitrary contract.
* If gas cost is a concern, only perform this check if the call returns no data, since the opposite result means that some code was executed.

### Unnecessary Diamond vocabulary

As noted, the Diamond proposal relies heavily on its newly created vocabulary. This is error-prone, makes review more difficult, and does not benefit developers.

> 1. A **diamond** is a contract that uses functions from its facets to execute function calls. A diamond can have one or more facets.
> 2. The word **facet** comes from the diamond industry. It is a side, or flat surface of a diamond. A diamond can have many facets. In this standard a facet is a contract with one or more functions that executes functionality of a diamond.
> 3. A **loupe** is a magnifying glass that is used to look at diamonds. In this standard a loupe is a facet that provides functions to look at a diamond and its facets.

**Figure 12**: The EIP redefines standard terms to ones that are unrelated to software engineering.

#### Our recommendation

* Use the common, well-known vocabulary, and do not invent terminology when it’s not needed.

## Is the Diamond proposal a dead end?

As noted, we still believe the community would benefit from a standardized upgradeability schema. But the current Diamond proposal does not meet the expected security requirements or bring enough benefits over a custom implementation.

However, the proposal is still a draft, and could evolve into something simpler and better. And even if it doesn’t, some of the existing techniques used, such as the lookup table and arbitrary storage pointers, are worth continuing to explore.

## So…is upgradeability feasible or not?

Over the years, we’ve reviewed many upgradeable contracts and published several analyses on this topic. Upgradeability is difficult, error-prone, and increases risk, and we still generally don’t recommend it as a solution. But developers who need upgradeability in their contracts should:

* Consider upgradeability designs that do not require delegatecall (see the [Gemini implementation](https://www.youtube.com/watch?v=sPUBUcjdEzk))
* Thoroughly review existing solutions and their limitations:
    * [Contract upgrade anti-patterns](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/)
    * [How contract migration works](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/)
    * [Upgradeability with OpenZeppelin](https://docs.openzeppelin.com/learn/deploying-and-interacting)
* Use [crytic.io](https://crytic.io/), or add [slither-check-upgradeability](https://github.com/crytic/slither/wiki/Upgradeability-Checks) to your CI
