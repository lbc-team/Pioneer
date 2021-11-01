> * 原文：https://medium.com/mycrypto/the-ethereum-virtual-machine-how-does-it-work-9abac2b7c9e  作者：https://medium.com/@luith
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[ARC_hunk](https://learnblockchain.cn/people/3904)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)

# 以太坊虚拟机是如何运行的？

如果您曾尝试过在以太坊上开发智能合约，或者至少了解过相关内容，那么你也许会听说过“EVM”，该术语是“以太坊虚拟机”的缩写。就本质而言，虚拟机在代码和机器之间创建了一层抽象，以此提升软件的可移植性，同时确保应用程序与主机、其他应用之间的隔离性。

## 创建智能合约

智能合约通常使用[Solidity](https://github.com/ethereum/solidity)编写，这是一种类似于JavaScript和C++的语言。其他合约编程语言则包括[Vyper[(https://github.com/ethereum/vyper)和[Bamboo](https://github.com/cornellblockchain/bamboo)等。在Solidity发布之前，[Serpent](https://github.com/ethereum/serpent)（已废弃）和[Mutan](https://github.com/obscuren/mutan)（已废弃）也曾被使用过。

智能合约示例([The Greeter](https://ethereum.org/en/developers/))：

```javascript
pragma solidity >=0.4.22 < 0.6.0;

contract Mortal {
    /* 定义owner变量，它的类型是address*/
    address owner;

    /* 构造器在初始化时被执行，它设置了owner变量*/
    constructor() public {owner = msg.sender}

    /* 用于取回合约资产*/
    function kill() public { if(msg.sender == owner) selfdestruct(msg.sender);}
}

contract Greeter is Mortal {
    /* 定义greeting变量，它的类型*/
    string greeting;

    /* 合约运行的时候被执行（译者注：此处应为笔误，应该是合约部署的时候被执行）*/
    constructor(string memory _greeting) public {
        greeting = _greeting;
    }
    /* 主函数*/
    function greet() public view returns(string memory) {
        return greeting;
    }
}

```

Solidity这样的智能合约语言无法直接被EVM所执行，他们需先被编译为低级的机器指令（被称为操作码）。

## 操作码

从内部来看，EVM通过一组指令来执行特定任务，这组指令被称为操作码。在本文编写之时，目前共有140个不同的操作码，它们使得EVM[图灵完备](https://en.wikipedia.org/wiki/Turing_completeness)，即在给定足够资源的前提下，足以完成任何计算。由于操作码为1字节大小，最多只可能有256（16²）个字节码。简单起见，我们可将所有操作码归为如下几类：
- 栈操作相关的字节码（POP, PUSH, DUP, SWAP）
- 运算/比较/位操作相关的字节码（ADD， SUB， GT, LT, AND, OR）
- 环境相关的字节码（CALLER, CALLERVALUE， NUMBER）
- 内存操作字节码（MLOAD, MSTORE, MSTORE8, MSIZE）
- 存储操作字节码（SLOAD, SSTORE）
- 程序计数器相关的字节码（JUMP, JUMPI, PC, JUMPDEST）
- 终止相关的字节码（STOP， RETURN, REVERT, INVALID, SELFDESTRUCT）


![](https://miro.medium.com/max/1250/1*I4v8ArsePBK_iFSxgljxTg.png)

<center style="font-size:14px;color:#C0C0C0;text-decoration:underline">Byzantium分支中的全部操作码，包括Constantinople版本所计划的</center>

## 字节码


为了有效的保存操作码，操作码会被编码为字节码。每个操作码被赋予一个特定字节（例如，STOP对应0x00）。我们来看一下这个字节码：0x6001600101

![](https://miro.medium.com/max/2000/1*BhaR7mREQOIj_CzbuWVb5g.png)
<center style="font-size:14px;color:#C0C0C0;text-decoration:underline">字节码、拆分后的字节、对应的操作码（执行流），还有当前的栈</center>


在执行时，字节码会被拆分为多个字节（一个字节由两个16进制字符表示）。位于0x60-0x7f（PUSH1-PUSH32）范围内的字节，会以其他方式处理，因为它们包含压栈的数据，这些数据会被添在操作码后面，而不会被当作单独的操作码。

第一个指令是0x60，它的含义是PUSH1。因此，我们知道要压入的数据是1字节长，故我们将下一个字节压入到栈上。现在，栈上已包含了一个数据项，我们来执行下一条指令。由于我们知道0x01属于PUSH指令的一部分，下一条我们要执行的指令是另一个0x60（PUSH1），外加同样的数据。此时栈上包含了两个相同的数据项。最后一个指令是0x01，它对应ADD操作码。这一条指令会从栈上取2个数据项，然后将它们之和压入到栈上，使栈上目前只包含一个数据项：0x02.


## 合约状态

许多著名的高层编程语言允许用户直接给函数传参（function(argument1,argument)），与此不同的是，底层的编程语言则常用栈来给函数传递参数。EVM使用基于256位的寄存器栈，这个栈最近的16个数据项可以被直接访问和操作。整个栈最多保存1024个数据项。

由于这些限制，复杂的操作码会转而使用合约内存来读写数据。然而，内存并非持久化的。当合约执行完成后，内存的内容并不会被保存。因此，栈可以看作函数参数，而内存则可看作声明的变量。

为了能够长久保存数据，并使其可为将来的合约执行所用，我们可以使用存储。合约存储本质上就像是公共数据库，数据可以被外部读取，且无需发送任何交易（没有手续费！）。但是，比之于写内存，对存储的写入操作则昂贵的多（可达6000倍）。

## 合约交互的开销


合约的每次执行，均会在每一个以太坊节点上运行，因此攻击者可以尝试创建那种包含大量计算量的合约，以此来降低网络的速度。为了防止这种攻击发生，每个字节码都有相应的基础gas消耗。此外，一些复杂合约还会收取动态的gas费用。例如，操作码KECCAK256（以前也称为SHA3）的基础开销是30 gas，而其动态开销为6gas / 字（字为256位的数据项）。比之于简单、直接的指令，计算量高昂的指令会收取更多的gas费用。此外，每笔交易一开始便会收取21000 gas。

![](https://miro.medium.com/max/1050/1*o6WQw0cVj-StbMprOYKEoQ.png)

在执行那些降低状态大小的指令时，gas可以被退还。将一个非零的存储数值设为0，将会退还15000 gas；完整的移除一个合约（使用SELFDESTRUCT）会退还24000 gas。仅当合约执行完成之后，才会退还资金，因为合约自己无法执行偿还操作。此外，一笔退款的数额，无法超过当前合约调用所耗费的gas的一半。如果您想对gas有更多了解，您可以阅读这一篇文章，写的很好：[什么是Gas？](https://support.mycrypto.com/gas/what-is-gas-ethereum.html)

## 部署合约


在部署智能合约的时候，一个常规的交易会被创建，但不会设置地址。此外，一些字节码会被添加到输入数据上，这个字节码充当了构造函数（译者注：被称为creation字节码），它会在runtime字节码被拷贝到合约代码前，初始化存储变量。在部署期间，creation字节码仅会运行一次，而runtime字节码会在每一次合约调用时运行。

![](https://miro.medium.com/max/1050/1*XUA0cflNiSm4kmRyPAGcrg.png)

<center style="font-size:14px;color:#C0C0C0;text-decoration:underline">另一个Solidity合约示例，及部署它所需要的字节码</center>

我们可以把上述字节码拆分成三部分：

### 构造函数
```
60806040526001600055348015601457600080fd5b5060358060226000396000f3fe
```

![](https://miro.medium.com/max/2000/1*tpR_uuHdpPy4HPXzJRqv4g.png)

<center style="font-size:14px;color:#C0C0C0;text-decoration:underline">构造函数将初始值写入存储中，并将runtime字节码拷贝到合约内存中</center>

### 运行时
```
6080604052600080fdfe
```
![](https://miro.medium.com/max/2000/1*ppd0K01AFAXYsjx0V19vGg.png)

<center style="font-size:14px;color:#C0C0C0;text-decoration:underline">这部分字节码在合约创建的过程中被写入内存</center>

### 元数据
```
a165627a7a723058204e048d6cab20eb0d9f95671510277b55a61a582250e04db7f6587a1bebc134d20029
```

Solidity会创建一份[元数据文件](https://solidity.readthedocs.io/en/v0.5.2/metadata.html)，它的[Swarm哈希](https://github.com/ethereum/wiki/wiki/Swarm-Hash)会被添加到字节码尾部。Swarm是一个分布式存储平台外，也是内容分发服务，换句话说是一个分布式文件存储系统。尽管Swarm哈希被纳入到了runtime字节码中，它永远不会被EVM解释为操作码，因为它的位置永远不会被执行到。目前，Solidity使用下述格式：

```
0xa1 0x65 'b' 'z' 'z' 'r' '0' 0x58 0x20 [32 bytes swarm hash] 0x00 0x29
```

因此，在这个例子，我们可以提取出Swarm的哈希：
```
4e048d6cab20eb0d9f95671510277b55a61a582250e04db7f6587a1bebc134d2
```

元数据文件包含了合约的各种信息，比如编译器版本，合约函数等。不幸的是，这是一个实验中的特性，而且并没有很多的合约会公开将元数据文件上传到Swarm网络上。

## 反编译字节码


为了让字节码更便于阅读，一些项目提供了相应的工具，比如，你可以使用[eveem.org](https://eveem.org/)或[ethervm.io](https://ethervm.io/)来反编译主网上的合约。不幸的是，由于编译器优化的缘故，原始合约中的一些信息会丢失，比如函数名、事件名等。尽管如此，多数函数名还是可以通过对常用的函数名、事件名称进行暴力枚举来取得（见[4byte.directory](https://www.4byte.directory/)）。


合约调用通常需要一个"ABI"(应用程序二进制接口)，这是一份描述了所有函数和事件的文档，包含了它们的输入输出信息。当调用合约函数的时候，函数的签名通过对函数名及其输入参数进行哈希（使用[keccak256](https://en.wikipedia.org/wiki/SHA-3)）并截取前4个字节得到。

![](https://miro.medium.com/max/2000/1*4ZOy0KCHO0r1paTceMDpJQ.png)

<center style="font-size:14px;color:#C0C0C0;text-decoration:underline">Solidity合约示例，及ABI</center>


如上图所示，HelloWorld函数生成的签名哈希是0x7fffb7bd。如果我们想调用这个函数，交易数据的开头就要设置为0x7fffb7bd。 函数所需要的参数（本例中没有）会按32字节大小，即数据字的大小，添加到交易数据中签名哈希的后面。
如果一个参数包含了超过32字节（256位）的数据，例如数组或字符串，该参数将被拆分为多个数据字，并添加到输入数据中所有其他参数之后。此外，这些数据字的数目，则会单独编码到一个数据字中，放在具体内容的数据字前面。在这个参数所对应的位置，放入了参数数据字的起始位置（从大小数据字计起）。


## 总结

以太坊为那些使用Solidity和EVM的应用开发者提供了一套去中心化的生态系统。比之于在传统服务器上运行程序，使用智能合约来和EVM交互会昂贵一些，但仍然有很多场景，这些场景中，去中心化要比开销更为重要。
如果这篇文章使你对学习开发智能合约产生兴趣，可以看下这篇优秀文章：[智能合约入门](https://solidity.readthedocs.io/en/latest/introduction-to-smart-contracts.html)，深入学习Solidity运行原理。感谢阅读！


## 参考

[Wood, G. (2014). Ethereum: A secure decentralised generalised transaction ledger](https://ethereum.github.io/yellowpaper/paper.pdf)
[Ethereum Foundation. (2016). Solidity Documentation](https://solidity.readthedocs.io/en/latest/)
[Santander, A., & Arias, L. (2018). Deconstructing a Solidity Contract](https://blog.zeppelin.solutions/deconstructing-a-solidity-contract-part-i-introduction-832efd2d7737)
[Howard. (2017). Diving Into The Ethereum Virtual Machine](https://blog.qtum.org/diving-into-the-ethereum-vm-6e8d5d2f3c30)

---

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。

