> * 原文 https://medium.com/better-programming/learn-solidity-the-factory-pattern-75d11c3e7d29  作者 [Wissal haji](https://wissal-haji.medium.com/)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)




# 更我学 Solidity ：工厂模式

>  如何在智能合约中使用工厂模式



欢迎来到学习 Solidity 系列的另一部分。在[上一篇文章](https://learnblockchain.cn/article/1944),我们讨论了如何从智能合约中创建另一个智能合约。今天，我们将研究这种情况下的典型用例。

## 什么是工厂模式？

工厂模式的想法是拥有一个合约(工厂)，该合约将承担创建其他合约的任务。在基于类的编程中，此模式的主要动机来自单一职责原则(一个类不需要知道如何创建其他类的实例)，并且该模式为构造函数提供了一种抽象。



![UML diagram for factory method](https://img.learnblockchain.cn/2020/12/30//zog5MPg.png)

>  图片来自[Wikipedia](https://en.wikipedia.org/wiki/Factory_method_pattern).

## 为什么要在 Solidity 中使用工厂模式？

在Solidity中，出于以下原因之一，你可能要使用工厂模式：

- 如果要创建同一合约的多个实例，并且正在寻找一种跟踪它们并简化管理的方法。

  ```javascript
  contract Factory {
        Child[] children;
        function createChild(uint data){
           Child child = new Child(data);
           children.push(child);
        }
  }
  contract Child{
       uint data;
       constructor(uint _data){
          data = _data;
       }
  }
  ```

  

- 节省部署成本：你可以先部署工厂，之后在使用时再来部署其他合约。

- 提高合约安全性(请参阅[本文](https://consensys.net/diligence/blog/2019/09/factories-improve-smart-contract-security/)).

## 如何与已部署的智能合约进行交互

在深入探讨如何实现工厂模式的细节之前，我想澄清一下我们与已部署的智能合约进行交互的方式。工厂模式是用来创建子合约的，并且我们可能希望调用它们的某些函数以更好地管理这些合约。

调用部署的智能合约，需要做两件事：

1. 合约的ABI(提供有关函数签名的信息)。如果合约在同一个项目中。你可以使用import关键字将其导入。
2. 部署合约的地址。

举个例子：



```javascript
contract A {
    address bAddress;
    constructor(address b){
       bAddress = b;
    }
 
    function callHello() external view returns(string memory){
       B b = B(bAddress); // 转换地址为合约类型
       return b.sayHello();
    }
}

contract B {
     string greeting = "hello world";
     function sayHello() external view returns(string memory){
         return greeting;
     }
}
```



在Remix中，首先部署合约B，然后复制其地址，并在部署时将其提供给A的构造函数。现在你可以调用`callHello()`函数，你将获得合约B的`sayHello()`函数的结果。

## 普通工厂模式



在此模式下，我们创建具有创建子合约函数的工厂合约，并且可能还会添加其他函数来有效管理这些合约(例如，查找特定合约或禁用合约)。在create函数中，我们使用`new`关键字来部署子合约。



```javascript
contract Factory{
     Child[] public children;
     uint disabledCount;

    event ChildCreated(address childAddress, uint data);

     function createChild(uint data) external{
       Child child = new Child(data, children.length);
       children.push(child);
       emit ChildCreated(address(child), data);
     }

     function getChildren() external view returns(Child[] memory _children){
       _children = new Child[](children.length- disabledCount);
       uint count;
       for(uint i=0;i<children.length; i++){
          if(children[i].isEnabled()){
             _children[count] = children[i];
             count++;
          }
        }
     }  

     function disable(Child child) external {
        children[child.index()].disable();
        disabledCount++;
     }
 
}
contract Child{
    uint data;
    bool public isEnabled;
    uint public index;
    constructor(uint _data,uint _index){
       data = _data;
       isEnabled = true;
       index = _index;
    }

    function disable() external{
      isEnabled = false;
    }
}
```





## 克隆工厂模式

普通工厂模式的问题在于，由于所有子合约将具有相同的逻辑，并且每次我们几乎都重新部署几乎相同的合约（相同的代码但上下文不同），因此浪费了大量的 [gas](https://learnblockchain.cn/tags/gas) 。我们需要一种方法来仅部署一个具有所有函数的子合约，而使所有其他子合约充当代理，以将调用委派给我们部署第一个子合约，并让函数在代理合约的上下文中执行。



![Diagram of contract flow](https://img.learnblockchain.cn/2020/12/30/g5T0sutw.png)



幸运的是，[EIP-1167](https://learnblockchain.cn/docs/eips/eip-1167.html)提案定义如何低成本实现代理合约的规范。该代理会将所有调用和100％的 gas 转发给实现合约，然后将返回值中继回调用者。根据规范，代理合约的字节码为
`363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebeaf5af43d82803e903d91602b57fd5bf3`。索引10-29(含10-29)处的字节替换为主功能合约(即委托的目标合约)的20字节地址。

代理合约的全部魔力是通过`delegatecall`完成的。你可以通过阅读[本文](https://medium.com/coinmonks/delegatecall-calling-another-contract-function-in-solidity-b579f804178c)了解其工作原理.

我们看看如何实现克隆工厂。可以在[GitHub](https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol)上找到该模式规范的实现。在你的项目中复制粘贴` CloneFactory`的代码，代码如下：

```javascript
contract CloneFactory {

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}
```



我们这次要使用的代码如下：

```javascript
//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import './CloneFactory.sol';

contract Factory is CloneFactory {
     Child[] public children;
     address masterContract;

     constructor(address _masterContract){
         masterContract = _masterContract;
     }

     function createChild(uint data) external{
        Child child = Child(createClone(masterContract));
        child.init(data);
        children.push(child);
     }

     function getChildren() external view returns(Child[] memory){
         return children;
     }
}

contract Child{
    uint public data;
    
    // 用 init 函数替换构造函数
    // 因为创建在createClone函数内完成
    function init(uint _data) external {
        data = _data;
    }
}
```



这次，我们使用了GitHub代码库中的`createClone`函数来创建子合约，而不是`new`关键字。

你可以通过在Truffle中创建一个新的迁移文件来部署合约，如下所示：

```javascript
const Child = artifacts.require("Child");
const Factory = artifacts.require("Factory"); 
module.exports = function (_deployer) {

  _deployer.deploy(Child).then(() => _deployer.deploy(Factory, Child.address)); 
};
```



为了测试代码是否有效，我创建了一个测试文件，确保文件均按预期工作：

```javascript
contract("Factory", function (/* accounts */) {
  it("should assert true", async function () {
    await Factory.deployed();
    return assert.isTrue(true);
  });

  describe("#createChild()",async () => {
    let factory;
    beforeEach(async ()=>{
      factory = await Factory.deployed();
    });

    it("should create a new child", async () => {
      await factory.createChild(1);
      await factory.createChild(2);
      await factory.createChild(3);
      
      const children = await factory.getChildren();
      //console.log(children);
      const child1 = await Child.at(children[0]);
      const child2 = await Child.at(children[1]);
      const child3 = await Child.at(children[2]);

      const child1Data = await child1.data();
      const child2Data = await child2.data();
      const child3Data = await child3.data();

      assert.equal(children.length, 3);
      assert.equal(child1Data, 1);
      assert.equal(child2Data, 2);
      assert.equal(child3Data, 3);

    });
  });
});
```





本文就是这样。请继续关注[专栏:全面掌握Solidity智能合约开发](https://learnblockchain.cn/column/1)

------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。