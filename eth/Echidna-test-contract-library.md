
# Using Echidna to test a smart contract library

In this post, we’ll show you how to test your smart contracts with the [Echidna](https://github.com/crytic/echidna) fuzzer. In particular, you’ll see how to:

* Find a bug we discovered during the [Set Protocol audit](https://github.com/trailofbits/publications/blob/master/reviews/setprotocol.pdf) using a variation of differential fuzzing, and
* Specify and check useful properties for your own smart contract libraries.

And we’ll demonstrate how to do all of this using [crytic.io](https://cryptic.io/), which provides a GitHub integration and additional security checks.

## Libraries may import risk

Finding bugs in individual smart contracts is critically important: A contract may manage significant economic resources, whether in the form of tokens or Ether, and damages from vulnerabilities may be measured in millions of dollars. Arguably, though, there is code on the Ethereum blockchain that’s even more important than any individual contract: library code.

Libraries are potentially shared by *many* high-value contracts, so a subtle unknown bug in, say, `SafeMath`, could allow an attacker to exploit not just one, but *many* critical contracts. The criticality of such infrastructure code is well understood outside of blockchain contexts—bugs in widely used libraries like [TLS](https://heartbleed.com/) or [sqlite](https://www.zdnet.com/article/sqlite-bug-impacts-thousands-of-apps-including-all-chromium-based-browsers/) are contagious, infecting potentially all code that relies on the vulnerable library.

Library testing often focuses on detecting memory safety vulnerabilities. On the blockchain, however, we’re not so worried about avoiding stack smashes or a `memcpy` from a region containing private keys; we’re worried most about the semantic correctness of the library code. Smart contracts operate in a financial world where “code is law,” and if a library computes incorrect results under some circumstances, that “legal loophole” may propagate to a calling contract, and allow an attacker to make the contract behave badly.

Such loopholes may have other consequences than making a library produce incorrect results; if an attacker can force library code to unexpectedly revert, they then have the key to a potential denial-of-service attack. And if the attacker can make a library function enter a runaway loop, they can combine denial of service with costly gas consumption.

That’s the essence of a bug Trail of Bits discovered in an old version of a library for managing arrays of addresses, as described in [this audit of the Set Protocol code](https://github.com/trailofbits/publications/blob/master/reviews/setprotocol.pdf).

The faulty code looks like this:

```
/**
* Returns whether or not there's a duplicate. Runs in O(n^2).
* @param A Array to search
* @return Returns true if duplicate, false otherwise
*/
function hasDuplicate(address[] memory A) returns (bool)
   {
     for (uint256 i = 0; i < A.length - 1; i++) {
       for (uint256 j = i + 1; j < A.length; j++) {
         if (A[i] == A[j]) {
            return true;
         }
       }
   }
   return false;
}
```

The problem is that if `A.length` is `0` (`A` is empty), then `A.length - 1` underflows, and the outer (`i`) loop iterates over the entire set of `uint256` values. The inner (`j`) loop, in this case, doesn’t execute, so we have a tight loop doing nothing for (basically) forever. Of course this process will always run out of gas, and the transaction that makes the `hasDuplicate` call will fail. If an attacker can produce an empty array in the right place, then a contract that (for example) enforces some invariant over an address array using `hasDuplicate` can be disabled—possibly permanently.

## The library

For specifics, see [the code for our example](https://github.com/crytic-test/addressarrayutils_demo), and check out [this tutorial on using Echidna](https://github.com/crytic/building-secure-contracts).

At a high level, the library provides convenient functions for managing an array of addresses. A typical use case involves access control using a whitelist of addresses. AddressArrayUtils.sol has 19 functions to test:

```
function indexOf(address[] memory A, address a)
function contains(address[] memory A, address a)
function indexOfFromEnd(address[] A, address a)
function extend(address[] memory A, address[] memory B)
function append(address[] memory A, address a)
function sExtend(address[] storage A, address[] storage B)
function intersect(address[] memory A, address[] memory B)
function union(address[] memory A, address[] memory B)
function unionB(address[] memory A, address[] memory B)
function difference(address[] memory A, address[] memory B)
function sReverse(address[] storage A)
function pop(address[] memory A, uint256 index)
function remove(address[] memory A, address a)
function sPop(address[] storage A, uint256 index)
function sPopCheap(address[] storage A, uint256 index)
function sRemoveCheap(address[] storage A, address a)
function hasDuplicate(address[] memory A)
function isEqual(address[] memory A, address[] memory B)
function argGet(address[] memory A, uint256[] memory indexArray)
```

It seems like a lot, but many of the functions are similar in effect, since AddressArrayUtils provides both functional versions (operating on memory array parameters) and mutating versions (requiring storage arrays) of `extend`, `reverse`, `pop`, and `remove`. You can see how once we’ve written a test for `pop`, writing a test for `sPop` probably won’t be too difficult.

## Property-based fuzzing 101

Our job is to take the functions we’re interested in—here, all of them—and:

* Figure out what each function does, then
* Write a test that makes sure the function does it!

One way to do this is to write a lot of unit tests, of course, but this is problematic. If we want to *thoroughly* test the library, it’s going to be a lot of work, and, frankly, we’re probably going to do a bad job. Are we sure we can think of every corner case? Even if we try to cover all the source code, bugs that involve *missing source code*, like the `hasDuplicate` bug, can easily be missed.

We want to use *property-based testing* to specify the general behavior over *all possible inputs*, and then generate lots of inputs. Writing a general description of behavior is harder than writing any individual concrete “given inputs X, the function should do/return Y” test. But the work to write *all* the concrete tests needed would be exorbitant. Most importantly, even admirably well-done manual unit tests don’t find the kind of [weird edge-case bugs attackers are looking for](https://blog.trailofbits.com/2019/08/08/246-findings-from-our-smart-contract-audits-an-executive-summary/).

## The Echidna test harness: hasDuplicate

The most obvious thing about the code to test the library is that it’s bigger than the library itself!  That’s not uncommon in a case like this. Don’t let that daunt you; unlike a library, a test harness approached as a work-in-progress, and slowly improved and expanded, works just fine. Test development is inherently incremental, and even small efforts provide considerable benefit if you have a tool like Echidna to amplify your investment.

For a concrete example, let’s look at the `hasDuplicate` bug. We want to check that:

* If there is a duplicate, `hasDuplicate` reports it, and
* If there isn’t a duplicate, `hasDuplicate` reports that there isn’t one.

We could just re-implement `hasDuplicate` itself, but this doesn’t help much in general (here, it might let us find the bug). If we had another, independently developed, high-quality address array utility library, we could compare it, an approach called differential testing. Unfortunately, we don’t often have such a reference library.

Our approach here is to apply a weaker version of differential testing by looking for another function in the library that can detect duplicates without calling `hasDuplicate`. For this, we’ll use `indexOf` and `indexOfFromEnd` to check if the index of an item (starting from 0) is the same as that when a search is performed from the end of the array:

```
  for (uint i = 0; i < addrs1.length; i++) {
    (i1, b) = AddressArrayUtils.indexOf(addrs1, addrs1[i]);
    (i2, b) = AddressArrayUtils.indexOfFromEnd(addrs1, addrs1[i]);
    if (i1 != (i2-1)) { // -1 because fromEnd return is off by one
  hasDup = true;
    }
  }
  return hasDup == AddressArrayUtils.hasDuplicate(addrs1);
}
```
<center>See the full example code in [our addressarrayutils demo](https://github.com/crytic-test/addressarrayutils_demo/blob/348132cbb2eb4f0f6e887d426b3f2caeea311564/contracts/crytic.sol#L37-L54)</center>

[This code](https://github.com/crytic-test/addressarrayutils_demo/blob/348132cbb2eb4f0f6e887d426b3f2caeea311564/contracts/crytic.sol#L37-L54) iterates through addrs1 and finds the index of the first appearance of each element.  If there are no duplicates, of course, this will always just be *i* itself. The code then finds the index of the last appearance of the element (i.e., from the end). If those two indices are different, there is a duplicate. In Echidna, properties are just Boolean Solidity functions that usually return true if the property is satisfied (we’ll see the exception below), and fail if they either revert or return false. Now our `hasDuplicate` test is testing both `hasDuplicate` and the two indexOf functions. If they don’t agree, Echidna will tell us.

Now we can add [a couple of functions to be fuzzed to set addrs1](https://github.com/crytic-test/addressarrayutils_demo/blob/348132cbb2eb4f0f6e887d426b3f2caeea311564/contracts/crytic.sol#L7-L35).

Let’s run this property on Crytic:

![](https://img.learnblockchain.cn/2020/09/29/16013634289541.jpg)
<center>The property test for hasDuplicate fails in Crytic</center>

First, `crytic_hasDuplicate` fails:

```
crytic_hasDuplicate: failed!
  Call sequence:
    set_addr(0x0)
```

The triggering transaction sequence is extremely simple: Don’t add anything to `addrs1`, then call `hasDuplicate` on it. That’s it—the resulting runaway loop will exhaust your gas budget, and Crytic/Echidna will tell you the property failed. The `0x0` address results when Echidna minimizes the failure to the simplest sequence possible.

Our other properties (`crytic_revert_remove` and `crytic_remove`) pass, so that’s good. If we fix [the bug in `hasDuplicate`](https://github.com/crytic-test/addressarrayutils_demo/pull/1) then our tests will all pass:

![](https://img.learnblockchain.cn/2020/09/29/16013635062863.jpg)
<center>All three property tests now pass in Crytic</center>

The `crytic_hasDuplicate: fuzzing (2928/10000)` tells us that since the expensive `hasDuplicate` property doesn’t quickly fail, only 3,000 of our maximum of 10,000 tests for each property were performed before we hit our timeout of five minutes.

## The Echidna test harness: The rest of the library

Now we’ve seen one example of a test, here are some basic suggestions for building the rest of the tests (as we’ve done [for the addressarrayutils_demo repository](https://github.com/crytic-test/addressarrayutils_demo/pull/1/files)):

* Try different ways of computing the same thing. The more “differential” versions of a function you have, the more likely you are to find out if one of them is wrong. For example, look at [all the ways we cross-check `indexOf`, `contains`, and `indexOfFromEnd`](https://github.com/crytic-test/addressarrayutils_demo/blob/dbdf301d88c51454106c28d5b50220fd63cf647e/contracts/crytic.sol#L37-L84).
* Test for **revert.** If you add the prefix `_revert_` before your property name as we do [here](https://github.com/crytic-test/addressarrayutils_demo/blob/dbdf301d88c51454106c28d5b50220fd63cf647e/contracts/crytic.sol#L450-L458)*,* the property only passes if all calls to it revert. This ensures code fails when it is supposed to fail.
* Don’t forget to check obvious simple invariants, e.g., that the diff of an array with itself is always empty (`ourEqual(AddressArrayUtils.difference(addrs1, addrs1), empty)`).
* Invariant checks and preconditions in other testing can also serve as a cross-check on tested functions. Note that `hasDuplicate` is called in many tests that aren’t meant to check `hasDuplicate` at all; it’s just that knowing an array is duplicate-free can establish additional invariants of many other behaviors, e.g., after removing address X at any position, the array will no longer contain X.

## Getting up and running with Crytic

You can run Echidna tests on your own by downloading and installing the tool or using our docker build—but using the Crytic platform integrates Echidna property-based testing, Slither static analysis (including new analyzers not available in the public version of Slither), upgradability checks, and your own unit tests in a seamless environment tied to your version control. Plus the addressarrayutils_demo repository shows all you need for property-based testing: It can be as simple as creating a minimal Truffle setup, adding a crytic.sol file with the Echidna properties, and turning on property-based tests in your repository configuration in Crytic.

原文链接：https://blog.trailofbits.com/2020/08/17/using-echidna-to-test-a-smart-contract-library/
作者：[Crytic CI](https://twitter.com/cryticci)