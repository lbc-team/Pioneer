> * 原文链接：https://medium.com/bandprotocol/solidity-102-3-maintaining-sorted-list-1edd0a228d83  作者：[Bun Uthaitirat
](https://medium.com/@taobunoi?source=post_page-----1edd0a228d83--------------------------------)
> * 译者：[]()
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 本文永久链接：[learnblockchain.cn/article…]()

# Solidity 102 #3: Maintaining Sorted list

***This is part 3/N of Band Protocol’s “Solidity 102” series****. We explore and discuss data structures and implementation techniques for writing efficient Solidity code under Ethereum’s unique EVM cost model. Readers should be familiar with coding in Solidity and how EVM works in general.*

![](https://img.learnblockchain.cn/2020/10/27/16037647124996.jpg)


In the previous article, we talked about (data structure that can iterate on each element) how to add/remove element to/from list. Today we will extend our data structure to maintain sorted link-list on-chain. Like the previous article, we will explain by showing implementation of each functions. Therefore we hope everyone can follow us, if you’re ready, let’s get into it!

## Example use case

We want to create a “School” smart contract (again?) but today we just don’t maintain only student address list. We need to maintain their order by their scores, that teacher can add or minus score from student and we can guarantee that our list still maintained order by score at anytime. The last requirement is we can list top-k of students for rewarding students who have a good score.

## Let’s think about functions that we need to fulfill all requirements

There are 5 function that we need to implement.

1. Add new student to list with base score
2. Increase score to a student
3. Reduce score of student
4. Remove student from list
5. Get top-k student list

However before we start implement each function, we need to set up base data structure (array, mapping, etc.) and we choose *Iterable Map* from last article. Create mapping to store score and write interface for each functions, base code will look like this

![](https://img.learnblockchain.cn/2020/10/27/16037648122437.jpg)

Note: GUARD is a header of list.

## Add a new student with his/her score: `addStudent`

Let’s start on the first function `addStudent`. There is one different thing from normal *Iterable Map* that is we need to insert new item at the correct index instead of add at the front of the list to maintained our order.

![](https://img.learnblockchain.cn/2020/10/27/16037650248858.jpg)
<center>Show how to insert dave to maintained sorted list</center>


For make code easy to read, we created 2 helper function to find and verify index of new value.

`_verifyIndex` function for verify that value is between left and right address. It will return true if left_value ≥ new_value > right_value (In case we maintain descending order and in the case value is equal the new one should be at back of the old ones)

![](https://img.learnblockchain.cn/2020/10/27/16037654460182.jpg)
<center>verify index function</center>


`_findIndex` helper function to find address that new value should insert after it. Loop from GUARD through list to find valid index by checking with `verifyIndex`. This code guarantee that we will find a valid index for sure

![](https://img.learnblockchain.cn/2020/10/27/16037655315983.jpg)
<center>find index function</center>



`addStudent` insert new item after valid address, update score and increase listSize.

![](https://img.learnblockchain.cn/2020/10/27/16037663497968.jpg)
<center>add student function</center>


## Remove a student from list: `removeStudent`

`removeStudent` is implemented same as previous article because we remove item from list from transitive property if a ≥ b ≥ c, then a ≥ c (our list still sorted after remove b)

![](https://img.learnblockchain.cn/2020/10/27/16037674281663.jpg)
<center>Show how to remove bob from list</center>

helper functions `_isPrevStudent` and `_findPrevStudent`

![](https://img.learnblockchain.cn/2020/10/27/16037677628659.jpg)
<center>check previous student and find previous student</center>


And `removeStudent` same as previous article add clear `scores` mapping.

![](https://img.learnblockchain.cn/2020/10/27/16037678924107.jpg)
<center>remove student function</center>

## Update score of student: `increaseScore` and `reduceScore`

`increaseScore` and `reduceScore` can use the same logic to implement that is we update value from old to a new one. The main idea is we just **remove** old item temporary first and **add** it to new(or same) index where it should be with new value, so we can reuse add/remove function.

![](https://img.learnblockchain.cn/2020/10/27/16037690088362.jpg)
<center>Show how to update Bob’s score</center>

![](https://img.learnblockchain.cn/2020/10/27/16037690823318.jpg)
<center>update score function</center>

Note: We have checking condition if new value fit in the same index, we don’t need to remove and add item to the same value(It’ s just an optimization save estimate 1000 gas)

If we have this `updateScore` function, `increaseScore` and `reduceScore` functions can be implemented with one line.

![](https://img.learnblockchain.cn/2020/10/27/16037691112537.jpg)
<center>`increase score and reduce score function`</center>


## Get top-k list of students order by their scores: `getTop`

There is nothing fancy in this function, just loop start from GUARD and store address to array and return that array. Easy right?

![](https://img.learnblockchain.cn/2020/10/27/16037692269163.jpg)
<center>get top k function</center>

Code is published [here](https://gist.github.com/taobun/198cb6b2d620f687cacf665a791375cc)

## Bonus find index optimization!

Like the previous article, finding index by loop on-chain consumes gas proportionally to the length of list. We can optimize these functions by sending previous address to function (for update we need to send 2 addresses for remove and where to add later) and verify those addressed is valid by our 2 internal functions. That is why we separate verify condition and find address functions. Let’s take a look on each functions!

## addStudent

![](https://img.learnblockchain.cn/2020/10/27/16037693472697.jpg)
<center>Optimized add student</center>

A lot of requires!! We add 2 requires the first one is check existence of candidateStudent and the second one is verify that new value must be after that candidate.

## removeStudent

Just verify by `_isPrevStudent` for removing element.

![](https://img.learnblockchain.cn/2020/10/27/16037695128709.jpg)
<center>Optimized remove student</center>

## updateScore

![](https://img.learnblockchain.cn/2020/10/27/16037696796462.jpg)
<center>Optimized update score</center>

We add verify condition in case update at the same index. First condition is like remove element and second condition check for new value is valid to be old index.

Full optimized code is published [here](https://gist.github.com/taobun/2e409e4d11659408508fe893c5cf2fc1)

## Conclusion

In this article, we explore an implementation of *Sorted List,* a data structure that extends from *Iterable Map* to maintain sorted list on-chain that can add, remove, and update value in list. We also implemented an optimized version of this data structure to save gas of finding valid index. In the next article, we will extend this data structure not only get list of top-k but we will can check that address is in top-k or not in O(1)! Stay tuned for next article!

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。