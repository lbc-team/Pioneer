> * 原文：https://medium.com/better-programming/learn-solidity-smart-contract-creation-and-inheritance-8424adac3570  作者： [Wissal haji](https://wissal-haji.medium.com/)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 跟我学 Solidity ：合约的创建和继承

> 如何在合约里创建合约


欢迎阅读“学习 Solidity ”系列中的另一篇文章。在[上一篇文章](https://learnblockchain.cn/article/1817),我们看到了如何使用函数，并运用了到目前为止所学到的一切来构建一个多签名钱包。

在本文中，我们将看到如何从一个合约中创建另一个合约，以及如何定义抽象合约和接口。

## 合约创建

可以通过以太坊交易或在Solidity合约中使用` new`关键字创建合约，new关键字将部署该合约的新实例并返回合约地址。

通过Solidity文档中给出的示例，让我们仔细看看它是如何工作的。我将` name`变量设为` public`，以便我们可以读取到它的值，并且还会和`createToken`函数的返回值一起创建一个事件(关于事件，也会有其他的文章介绍)：



```javascript
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.8.0;


contract OwnedToken {
    TokenCreator creator;
    address owner;
    bytes32 public name;
    constructor(bytes32 _name) {
        owner = msg.sender;
        creator = TokenCreator(msg.sender);
        name = _name;
    }

    function changeName(bytes32 newName) public {
        if (msg.sender == address(creator))
            name = newName;
    }

    function transfer(address newOwner) public {
        if (msg.sender != owner) return;

        if (creator.isTokenTransferOK(owner, newOwner))
            owner = newOwner;
    }
}


contract TokenCreator {
    event TokenCreated(bytes32 name, address tokenAddress);

    function createToken(bytes32 name)
        public
        returns (OwnedToken tokenAddress)
    {
        tokenAddress =  new OwnedToken(name);
        emit TokenCreated(name, address(tokenAddress));
    }

    function changeName(OwnedToken tokenAddress, bytes32 name) public {

        tokenAddress.changeName(name);
    }

    function isTokenTransferOK(address currentOwner, address newOwner)
        public
        pure
        returns (bool ok)
    {

        return keccak256(abi.encodePacked(currentOwner, newOwner))[0] == 0x7f;
    }
}

```

[代码](https://gist.github.com/wissalHaji/50af2ffc141fdf8ed6f598c1f516e3f1#file-token-sol)



这次，我们使用[Tuffle框架](https://learnblockchain.cn/docs/truffle/)来辅助开发，可以参考[快速入门指南](https://learnblockchain.cn/docs/truffle/quickstart.html)进行项目设置。

首先，我们将创建一个新项目并通过执行以下命令对其进行初始化：

```
> mkdir token
> cd token
> truffle init
```

打开项目，并更新`truffle-config.js`文件，设置部署合约的节点 RPC 的IP和端口（这里使用[Ganache](https://www.trufflesuite.com/ganache)运行的本地网络）以及使用的Solidity编译器的版本。

现在，我们可以在` contracts`文件夹中创建合约文件` TokenCreator.sol`，复制前面的代码并粘贴.在` migrations`文件夹中创建一个迁移文件，以部署` TokenCreator`合约。将其命名为` 2_deploy_token.js`，然后复制并粘贴以下代码。

```
const TokenCreator = artifacts.require("TokenCreator");module.exports = function (deployer) {
     deployer.deploy(TokenCreator);
};
```



返回命令行终端，输入` truffle console`以启动Truffle控制台，你可以在控制台中编译和部署合约：



![Typing ‘truffle console’ in the terminal to launch the Truffle console.](https://img.learnblockchain.cn/2020/12/28/5Oqt3QpA.png)

> 使用compile 命令编译合约，使用 migrate 命令部署合约。



我们现在要做的是检索已部署的`TokenCreator`的实例。然后，进行两次调用`createToken`函数，并保存每个新创建合约的地址。



![By typing ‘tokenCreator.address’ we can double-check that the same address was displayed when we deployed the contract.](https://img.learnblockchain.cn/2020/12/28/BCHmDRgA.png)



如果使用的是Ganache，你会看到两个代表合约调用的交易被添加到交易列表中，其中数据字段设置为四个字节的函数选择器和传递的参数。如果你想知道真正发生了什么以及如何创建这些合约，请订阅[本专栏](https://learnblockchain.cn/column/1)。

众所周知，合约只是另一种帐户，因此，当我们调用createToken函数时，实际上发生的是状态数据库更新为包括新创建的帐户，并且账户的四个变量(` nonce`，`balance`，`storage_root`，`code_hash`)已正确初始化（每个帐户都会包含这四个变量）。

如果现在回到Truffle控制台，则可以检查每个交易的日志以获取每个合约的地址，然后可以调用`name` 函数来验证它们确实是两个单独的合约实例。

![The logs of each transaction that you can examine to get the address of each contract.](https://img.learnblockchain.cn/2020/12/28/nMlABiCQ.png)



![The user has identified the names ‘kitty’ and ‘sweet’ by looking at the logs.](https://img.learnblockchain.cn/2020/12/28/SI95BlRg.png)

关于web3.js的更多信息可以在[这里](https://learnblockchain.cn/docs/web3.js/)找到。

## 构造函数声明

合约的构造函数在创建合约时被调用，并且不会与其余的合约代码一起存储在区块链上。
构造函数是可选的。只允许一个构造函数，这意味着构造函数不支持重载。

使用关键字` constructor`声明构造函数：

```javascript
contract A {
     uint a;
     bool b;
     constructor(uint _a, bool _b){
        a = _a;
        b = _b;
   }
   ...
}
```

## 抽象合约

如果合约中的至少一个函数没有实现，则合约需要标记为`abstract`。即使实现了所有函数，合约也可能被标记为`abstract`。

抽象合约通过使用关键字`abstract`来完成，未实现的函数应具有关键字`virtual`以表示允许多态

```
abstract contract A {
    function f() public pure virtual;
}
```

抽象合约是直接实例化（部署），即使它实现了所有函数。它们可以用作定义特定行为的基础合约（就像面向对象里面的基类）用来给其他合约继承。实现函数应用`override`关键字修饰。

```
abstract contract A {
    function f() public pure virtual;
}

abstract contract B is A {
    function f() public pure override {
       //function body
    }
}
```

如果派生合约未实现所有未实现的函数，则也需要将其标记为`abstract`。

## 接口

接口类似于抽象合约，但是不能实现任何函数。还有其他限制：

- 它们不能从其他合约继承，但是可以从其他接口继承
- 所有声明的函数必须是外部的
- 他们不能声明构造函数
- 他们不能声明状态变量

使用关键字` interface`声明接口。

```
interface A {
    function f() external pure;
} 
```

接口中声明的所有函数都是隐式的`virtual`。

## 结论



本文就是这样。本文参考[文档](https://learnblockchain.cn/docs/solidity/contracts.html#index-1)，在接下来的文章中，我们将深入研究智能合约开发。欢迎关注。




------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。