> * 原文链接：https://medium.com/bandprotocol/solidity-102-3-maintaining-sorted-list-1edd0a228d83  作者：[Bun Uthaitirat
](https://medium.com/@taobunoi?source=post_page-----1edd0a228d83--------------------------------)
> * [Tiny 熊](https://learnblockchain.cn/people/15)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 本文永久链接：[learnblockchain.cn/article…]()

# Solidity 优化 - 维护排序列表

本文我们探索和讨论在以太坊独特的EVM成本模型下编写高效的Solidity代码的数据结构和实现技术。
读者应该已经对Solidity中的编码以及EVM的总体工作方式所有了解。

![](https://img.learnblockchain.cn/2020/10/27/16037647124996.jpg)


在[上一篇文章](https://learnblockchain.cn/article/1632)中，我们讨论了(可以在每个元素上迭代的数据结构)如何在列表中添加元素或从列表中删除元素。这篇文章将扩展我们的数据结构，以维护链上已排序的链表。像上一篇文章一样，我们将通过展示每个函数的实现来进行解释。如果你准备好了，那就开始吧！

## 场景范例

像[上一篇文章](https://learnblockchain.cn/article/1632)一样，我们依旧要创建一个“学校”智能合约，但是这次我们只保留了学生地址列表。我们需要根据他们的分数来维持他们的排序，老师可以在学生中增加或减去他们的分数，并且可以保证学生列表仍然可以随时按分数保持顺序。最后一个要求是我们可以列出排名前k的学生，以奖励表现良好的学生。

### 函数需求

 让我们考虑一下满足所有要求所需的函数，需要实现5个函数。

1. 将新学生添加到具有分数排序的列表中
2. 提高学生分数
3. 降低学生分数
4. 从名单中删除学生
5. 获取前K名学生名单

## 实现

但是，在开始实现每个函数之前，我们需要设置基础数据结构(数组，映射等)，我们使用上一篇文章中的[可迭代映射](https://learnblockchain.cn/article/1632)。创建映射以存储分数并为每个函数编写接口，框架代码如下所示：

![](https://img.learnblockchain.cn/2020/10/27/16037648122437.jpg)

注意：GUARD是列表的头。

### 添加带有分数的新学生 `addStudent`

让我们从第一个函数 `addStudent` 开始。与普通的可迭代映射有所不同的是，我们需要在正确的索引处插入新项目，而不是在列表的前面添加以维持我们的排序。

![](https://img.learnblockchain.cn/2020/10/27/16037650248858.jpg)
<center>显示如何将Dave插入维护的排序列表中</center>


为了使代码易于阅读，我们创建了2个辅助函数来查找和验证新值的索引。

`_verifyIndex` 函数用于验证该值在左右地址之间。如果 `左边的值` ≥ `新值` > `右边的值`将返回true(如果我们保持降序，并且如果值等于，则新值应该在旧值的后面)

![验证索引](https://img.learnblockchain.cn/2020/10/27/16037654460182.jpg)
<center>验证索引函数</center>


`_findIndex` 帮助函数，用于查找新值应该插入在哪一个地址后面。从GUARD遍历列表，通过使用`_verifyIndex`检查来找到有效的索引。此代码确保我们可以肯定地找到有效的索引

![查找索引](https://img.learnblockchain.cn/2020/10/27/16037655315983.jpg)
<center>查找索引函数</center>



`addStudent` 在有效索引地址后插入新项目，更新分数并增加listSize。

![addStudent](https://img.learnblockchain.cn/2020/10/27/16037663497968.jpg)
<center>添加学生函数</center>


### 从列表中删除学生：`removeStudent`

`removeStudent` 的实现与上一篇文章相同，因为如果a≥b≥c，然后a≥c，在列表删除b之后仍是排序。

![ 链表删除Bob](https://img.learnblockchain.cn/2020/10/27/16037674281663.jpg)
<center>显示如何从列表中删除Bob</center>

辅助函数`_isPrevStudent`和`_findPrevStudent`

![](https://img.learnblockchain.cn/2020/10/27/16037677628659.jpg)
<center>检查前一个学生并找到前一个学生</center>


与上一篇文章相同的 `removeStudent` 不过需要清除 `scores`映射。

![](https://img.learnblockchain.cn/2020/10/27/16037678924107.jpg)
<center>删除学生函数</center>

### 更新学生分数：`increaseScore` 和 `reduceScore`

`increaseScore`和`reduceScore`可以使用相同的逻辑来实现，即将旧值更新为新值。主要思想是我们将旧项目临时`删除`，然后将其`添加`到新(或相同)索引中，该索引应具有新值，因此我们可以重复使用添加/删除函数。

![](https://img.learnblockchain.cn/2020/10/27/16037690088362.jpg)
<center>显示如何更新鲍勃的分数</center>

![更新分数](https://img.learnblockchain.cn/2020/10/27/16037690823318.jpg)
<center>更新分数函数</center>

注意：我们会检查条件，以确定新值是否适合相同的索引，这样我们不需要删除项目并将其添加到相同的值(这只是优化操作，可以节省1000 gas )

如果我们具有`updateScore`函数，则可以用一行代码来实现`increaseScore`和`reduceScore`函数。

![](https://img.learnblockchain.cn/2020/10/27/16037691112537.jpg)
<center>增加分数并减少分数函数</center>


### 获取前k名学生名单：`getTop`

这个函数没有什么花哨的，只是从GUARD循环开始，将地址存储到数组并返回该数组。容易吧？

![](https://img.learnblockchain.cn/2020/10/27/16037692269163.jpg)
<center>获取前k名学生函数</center>

代码已发布[此处](https://gist.github.com/taobun/198cb6b2d620f687cacf665a791375cc) , 代码如下：

```js
pragma solidity 0.5.9;

contract School{

  mapping(address => uint256) public scores;
  mapping(address => address) _nextStudents;
  uint256 public listSize;
  address constant GUARD = address(1);

  constructor() public {
    _nextStudents[GUARD] = GUARD;
  }

  function addStudent(address student, uint256 score) public {
    require(_nextStudents[student] == address(0));
    address index = _findIndex(score);
    scores[student] = score;
    _nextStudents[student] = _nextStudents[index];
    _nextStudents[index] = student;
    listSize++;
  }

  function increaseScore(address student, uint256 score) public {
    updateScore(student, scores[student] + score);
  }

  function reduceScore(address student, uint256 score) public {
    updateScore(student, scores[student] - score);
  }

  function updateScore(address student, uint256 newScore) public {
    require(_nextStudents[student] != address(0));
    address prevStudent = _findPrevStudent(student);
    address nextStudent = _nextStudents[student];
    if(_verifyIndex(prevStudent, newScore, nextStudent)){
      scores[student] = newScore;
    } else {
      removeStudent(student);
      addStudent(student, newScore);
    }
  }

  function removeStudent(address student) public {
    require(_nextStudents[student] != address(0));
    address prevStudent = _findPrevStudent(student);
    _nextStudents[prevStudent] = _nextStudents[student];
    _nextStudents[student] = address(0);
    scores[student] = 0;
    listSize--;
  }

  function getTop(uint256 k) public view returns(address[] memory) {
    require(k <= listSize);
    address[] memory studentLists = new address[](k);
    address currentAddress = _nextStudents[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      studentLists[i] = currentAddress;
      currentAddress = _nextStudents[currentAddress];
    }
    return studentLists;
  }


  function _verifyIndex(address prevStudent, uint256 newValue, address nextStudent)
    internal
    view
    returns(bool)
  {
    return (prevStudent == GUARD || scores[prevStudent] >= newValue) && 
           (nextStudent == GUARD || newValue > scores[nextStudent]);
  }

  function _findIndex(uint256 newValue) internal view returns(address) {
    address candidateAddress = GUARD;
    while(true) {
      if(_verifyIndex(candidateAddress, newValue, _nextStudents[candidateAddress]))
        return candidateAddress;
      candidateAddress = _nextStudents[candidateAddress];
    }
  }

  function _isPrevStudent(address student, address prevStudent) internal view returns(bool) {
    return _nextStudents[prevStudent] == student;
  }

  function _findPrevStudent(address student) internal view returns(address) {
    address currentAddress = GUARD;
    while(_nextStudents[currentAddress] != GUARD) {
      if(_isPrevStudent(student, currentAddress))
        return currentAddress;
      currentAddress = _nextStudents[currentAddress];
    }
    return address(0);
  }
} 
```

## 优化查找索引

与上一篇文章一样，按链查找索引会消耗与列表长度成比例的 gas 。我们可以通过发送前一个地址到函数来优化这些函数(对于更新分数操作，我们需要发送2个地址以供删除和添加使用)，并通过我们的2个内部函数验证这些地址是否有效。这就是为什么我们分开验证条件并查找地址函数的原因。让我们来看看每个函数！

### addStudent

![](https://img.learnblockchain.cn/2020/10/27/16037693472697.jpg)
<center>优化addStudent</center>

有很多 [require](https://learnblockchain.cn/docs/solidity/control-structures.html#assert-require-revert)！我们添加2个require， 第一个是检查candidateStudent是否存在，第二个是验证新值必须在该candidateStudent之后。

### removeStudent

只需通过`_isPrevStudent`进行验证以删除元素。

![](https://img.learnblockchain.cn/2020/10/27/16037695128709.jpg)
<center>优化删除学生</center>

### updateScore

![](https://img.learnblockchain.cn/2020/10/27/16037696796462.jpg)
<center>优化的更新分数</center>

我们添加验证条件，以防万一在同一索引处进行更新。第一个条件就像移除元素，第二个条件检查新值是否在旧索引上有效。

完整的优化代码已发布[此处](https://gist.github.com/taobun/2e409e4d11659408508fe893c5cf2fc1)， 代码如下：

```js
pragma solidity 0.5.9;

contract OptimizedSchool{
  
  mapping(address => uint256) public scores;
  mapping(address => address) _nextStudents;
  uint256 public listSize;
  address constant GUARD = address(1);
  
  constructor() public {
    _nextStudents[GUARD] = GUARD;
  }
  
  function addStudent(address student, uint256 score, address candidateStudent) public {
    require(_nextStudents[student] == address(0));
    require(_nextStudents[candidateStudent] != address(0));
    require(_verifyIndex(candidateStudent, score, _nextStudents[candidateStudent]));
    scores[student] = score;
    _nextStudents[student] = _nextStudents[candidateStudent];
    _nextStudents[candidateStudent] = student;
    listSize++;
  }
  
  function increaseScore(
    address student, 
    uint256 score, 
    address oldCandidateStudent, 
    address newCandidateStudent
  ) public {
    updateScore(student, scores[student] + score, oldCandidateStudent, newCandidateStudent);
  }
  
  function reduceScore(
    address student, 
    uint256 score, 
    address oldCandidateStudent, 
    address newCandidateStudent
  ) public {
    updateScore(student, scores[student] - score, oldCandidateStudent, newCandidateStudent);
  }
  
  function updateScore(
    address student, 
    uint256 newScore, 
    address oldCandidateStudent, 
    address newCandidateStudent
  ) public {
    require(_nextStudents[student] != address(0));
    require(_nextStudents[oldCandidateStudent] != address(0));
    require(_nextStudents[newCandidateStudent] != address(0));
    if(oldCandidateStudent == newCandidateStudent)
    {
      require(_isPrevStudent(student, oldCandidateStudent));
      require(_verifyIndex(newCandidateStudent, newScore, _nextStudents[student]));
      scores[student] = newScore;
    } else {
      removeStudent(student, oldCandidateStudent);
      addStudent(student, newScore, newCandidateStudent);
    }
  }
  
  function removeStudent(address student, address candidateStudent) public {
    require(_nextStudents[student] != address(0));
    require(_isPrevStudent(student, candidateStudent));
    _nextStudents[candidateStudent] = _nextStudents[student];
    _nextStudents[student] = address(0);
    scores[student] = 0;
    listSize--;
  }
  
  function getTop(uint256 k) public view returns(address[] memory) {
    require(k <= listSize);
    address[] memory studentLists = new address[](k);
    address currentAddress = _nextStudents[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      studentLists[i] = currentAddress;
      currentAddress = _nextStudents[currentAddress];
    }
    return studentLists;
  }
  
  
  function _verifyIndex(address prevStudent, uint256 newValue, address nextStudent)
    internal
    view
    returns(bool)
  {
    return (prevStudent == GUARD || scores[prevStudent] >= newValue) && 
           (nextStudent == GUARD || newValue > scores[nextStudent]);
  }
  
  function _isPrevStudent(address student, address prevStudent) internal view returns(bool) {
    return _nextStudents[prevStudent] == student;
  }
}
``` 

## 结论

在本文中，我们探索了*排序列表*的实现，该列表是从可迭代映射扩展而来的数据结构，用于维护链上排序的列表，可以在列表中添加，删除和更新值。我们还实现了此数据结构的优化版本，以节省寻找有效索引的麻烦。

------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。