原文链接：https://medium.com/@danielyamagata/understand-evm-opcodes-write-better-smart-contracts-e64f017b619

# 深入理解EVM操作码，才写出更好的智能合约。

Your good developer habits are leading you to write inefficient smart contracts. For typical programming languages, the only costs associated with state changes and computation are time and the electricity used by the hardware. However, for EVM-compatible languages, such as Solidity and Vyper, these actions explicitly cost *money*. This cost is in the form of the blockchain’s native currency (ETH for Etheruem, AVAX for Avalanche, etc.), which can be thought of as a commodity used to pay for these actions.

你的一些编程“好习惯”反而会让你写出低效的智能合约。对于普通编程语言而言，计算机做运算和改变程序的状态顶多只是费点电或者费点时间，但对于 EVM 兼容类的编程语言，显然执行这些操作都是*费钱*的！例如 Solidity 和 Vyper。这些花费的形式是区块链的原生货币（如以太坊的 ETH，Avalanche 的 AVAX 等等...），想象成你是在用原生货币买计算操作。

The cost for computation, state transitions, and storage is called *gas*. Gas is used to prioritize transactions, as a [Sybil resistance](https://en.wikipedia.org/wiki/Sybil_attack) mechanism, and to prevent attacks stemming from the [halting problem](https://en.wikipedia.org/wiki/Halting_problem).

用于购买计算、状态转移还有存储空间的开销被称做 *燃料（下文统称gas）*。 gas 的作用是确定交易的优先级, 同时形成一种能抵御【女巫攻击】的机制（Sybil resistance)(https://en.wikipedia.org/wiki/Sybil_attack) ，而且还能防止【停止问题】引起的攻击 [halting problem](https://en.wikipedia.org/wiki/Halting_problem)。

*Feel free to read my article on* [*Solidity basics* ](https://medium.com/@danielyamagata/solidity-basics-your-first-smart-contract-f11f4f7853d0)*to learn more about gas*

*欢迎阅读我的文章* [*Solidity 基础* ](https://medium.com/@danielyamagata/solidity-basics-your-first-smart-contract-f11f4f7853d0)*去了解gas的方方面面*

These atypical costs lead to software design patterns that would seem both inefficient and strange in typical programming languages. To be able to recognize these patterns and grasp why they lead to cost efficiencies, you must first have a basic understanding of the Ethereum Virtual Machine, i.e. the EVM.

这些非典型的开销导致经典的软件设计模式在合约编程语言中看起来既低效又奇怪。如果想要识别这些模式并理解它们与运行效率的关系，您必须首先对以太坊虚拟机（即 EVM）有一个基本的了解。

**What is the EVM?**
**什么是EVM？**

*如果您已经熟悉 EVM，请随时跳到下个部分：* ***什么是 EVM 操作码？\***

A blockchain is a transaction-based [*state machine*](https://en.wikipedia.org/wiki/Finite-state_machine). Blockchains incrementally execute transactions, which morph into some new state. Therefore, each transaction on a blockchain is a *transition of state.*

一个任何区块链都是一个基于交易的 [*状态机*](https://en.wikipedia.org/wiki/Finite-state_machine)。 区块链递增地执行交易，交易完成后就变成新状态。因此，区块链上的每笔交易都是一次*状态转换*。

Simple blockchains, like Bitcoin, natively only support simple transfers. In contrast, smart-contract compatible chains, like Ethereum, implement two types of accounts, externally owned accounts and contract accounts, in order to support complex logic.

简单的区块链，如比特币，本身只支持简单的交易传输。相比之下，可以运行智能合约的链，如以太坊，实现了两种类型的账户，即外部账户和合约账户，所以支持复杂的逻辑。

Externally owned accounts are controlled by users via private keys and have no code associated with them, while contract accounts are solely controlled by their associated code. EVM code is stored as [bytecode](https://en.wikipedia.org/wiki/Bytecode) in a virtual [ROM](https://en.wikipedia.org/wiki/Read-only_memory).
外部账户由用户通过私钥控制，不包含代码，而合约账户仅受其关联的代码控制。EVM 代码以[字节码](https://en.wikipedia.org/wiki/Bytecode)的形式存储在虚拟 [ROM] (https://en.wikipedia.org/wiki/Read-only_memory)中。

The EVM handles the execution and processing of all transactions on the underlying blockchain. It is a stack machine in which each item on the stack is 256-bits or 32 bytes. The EVM is embedded within each Ethereum node and is responsible for executing the contract’s bytecode.
EVM 负责区块链上所有交易的执行和处理。它是一个栈机器，栈上的每个元素长度都是 256 位或 32 字节。EVM 嵌在每个以太坊节点中，负责执行合约的字节码。

The EVM stores data in both storage and memory. *Storage* is used to store data permanently while *memory* is used to store data during function calls. You can also pass in function arguments as *calldata,* which act similar to allocating to memory except the data is non-modifiable.
EVM 把数据保存在存储（Storage）和内存（memory）中。*存储（Storage）*用于永久存储数据，而*内存（memory）*仅在函数调用期间保存数据。还有一个地方保存了函数参数的数据，叫做*调用数据（calldata）*，这个存储方式有点像内存，但数据是不可修改的。

*Learn more about Ethereum and the EVM in Preethi Kasireddy’s* [*article, “How does Ethereum work, anyway?”*](https://www.preethikasireddy.com/post/how-does-ethereum-work-anyway#:~:text=The Ethereum blockchain is essentially,transition to a new state.)
*在 Preethi Kasireddy 的文章中了解有关以太坊和 EVM 的更多信息[*“Ethereum 是如何工作的？”*]* (https://www.preethikasireddy.com/post/how-does-ethereum-work-anyway#:~:text=The Ethereum blockchain is essentially,transition to a new state.)。

Smart contracts are written in higher-level languages, such as Solidity, Vyper, or Yul, and subsequently broken down into EVM bytecode via a compiler. However, there are times when it is more gas efficient to use bytecode directly in your code.
智能合约是用高级语言编写的，例如 Solidity、Vyper 或 Yul，随后通过编译器编译成 EVM 字节码。但是，有时直接在代码中使用字节码会更高效（省gas）。

![1.png](https://img.learnblockchain.cn/attachments/2022/09/3yW6IizY6316af8248ebd.png)

[LooksRare 写的 TransferSelectorNFT 智能合约](https://github.com/LooksRare/contracts-exchange-v1/blob/master/contracts/TransferSelectorNFT.sol)

EVM bytecode is written in hexadecimal. It is the language that the virtual machine is able to interpret. This is somewhat analogous to how CPUs can only interpret machine code.
EVM 字节码以十六进制编写。它是一种虚拟机能够解释的语言。这有点像 CPU 只能解释机器代码。

![2.png](https://img.learnblockchain.cn/attachments/2022/09/gUZSV7fM6316af85c8841.png)

Solidity 字节码示例

**什么是 EVM 操作码？**

All Ethereum bytecode can be broken down into a series of operands and opcodes. Opcodes are predefined instructions that the EVM interprets and is subsequently able to execute. For example, the ADD opcode is represented as 0x01 in EVM bytecode. It removes two elements from the stack and pushes the result.
所有以太坊字节码都可以分解为一系列操作数和操作码。操作码是一些预定义的操作指令，EVM 识别后能够执行这个操作。例如，ADD 操作码在 EVM 字节码中表示为 0x01。它从栈中删除两个元素并把结果压入栈中。

从堆栈中移除和压入堆栈的元素数量取决于操作码。例如，PUSH 操作码有 32 个：PUSH1 到 PUSH32。 PUSH在栈上 * 添加一个 * 字节元素，元素的大小可以从 0 到 32 字节。它不会从栈中删除元素。作为对比, 操作码 ADDMOD 表示 [模加法运算](https://libraryguides.centennialcollege.ca/c.php?g=717548&p=5121840#:~:text=Properties of addition in modular,%2B d ( mod N ) .) ，它从栈中删除3个元素然后压入模加结果。请注意，PUSH 操作码是唯一带有操作数的操作码。

![3.png](https://img.learnblockchain.cn/attachments/2022/09/cuWOtV4M6316af89b9b6d.png)

The Opcodes of the Prior Bytecode Example
操作码示例

Each opcode is one byte and has a differing cost. Depending on the opcode, these costs are either fixed or determined by a formula. For example, the ADD opcode costs 3 gas. In contrast, SSTORE, the opcode which saves data in storage, costs 20,000 gas when a storage value is set to a non-zero value from zero and costs 5000 gas when a storage variable’s value is set to zero or remains unchanged from zero.
每个操作码都占一个字节，并且操作成本有大有小。操作码的操作成本是固定的或由公式算出来。例如，ADD 操作码固定需要 3 个 gas。而将数据保存在存储中的操作码 SSTORE ，当把值从0设置为非0时消耗 20,000 gas，当把值改为0或保持为0不变时消耗 5000 gas。

*SSTORE’s cost actually varies further depending on if a value has been accessed or not. Full details of SSTORE’s and SLOAD’s costs can be found* [*here*](https://hackmd.io/@fvictorio/gas-costs-after-berlin)
*SSTORE 的开销实际上会其他变化，具体取决于是否已访问过这个值。可以在这里找到有关 SSTORE 和 SLOAD 开销的完整详细信息* [*详见*](https://hackmd.io/@fvictorio/gas-costs-after-berlin)

**为什么了解 EVM 操作码很重要？**

Understanding EVM opcodes is extremely important for minimizing gas consumption, and, in turn, reducing costs for your end user. Since the cost associated with EVM opcodes is arbitrary, different coding patterns that achieve the same result might lead to greatly higher costs. Knowing which opcodes are the most expensive will help you minimize and avoid their usage when unnecessary. View the [Ethereum documentation](https://ethereum.org/en/developers/docs/evm/opcodes/) for a full list of EVM opcodes and their associated gas costs.
想要降低 gas 开销，了解 EVM 操作码极其重要，这也会降低你的终端用户的成本。由于不同的 EVM 操作码的成本是不同的，因此虽然实现了相同结果，但不同的编码方式可能会导致更高的开销。了解哪些操作码是比较昂贵的，可以帮助您最大程度地减少甚至避免使用它们。您可以查看 [以太坊文档](https://ethereum.org/en/developers/docs/evm/opcodes/) 以获取 EVM 操作码及其相关 gas 开销的列表。

![4.png](https://img.learnblockchain.cn/attachments/2022/09/p1uzciT06316af8d1666d.png)

Below are concrete examples of unintuitive design patterns stemming from the cost of EVM opcodes:
下面是一些考虑了 EVM 操作码开销的反直觉设计模式的具体示例：

**Using Multiplication over Exponetentiation: MUL vs EXP**
**用乘法求乘方: MUL vs EXP**

The MUL opcode costs 5 gas and is used to perform multiplication. For example, the arithmetic behind 10 * 10 would cost 5 gas.
MUL 操作码花费 5 gas 用于执行乘法。例如，10 * 10 背后的算术将花费 5 gas。

The EXP opcode is used to perform exponentiation, and its gas cost is determined by a formula: if the exponent is zero, the opcode costs 10 gas. However, if the exponent is greater than zero, it costs 10 gas plus 50 times the number of bytes in the exponent.
EXP 操作码用于求幂，其 gas 消耗由公式决定：如果指数为零，则消耗10gas。但是，如果指数大于零，则需要 10 gas 加上指数字节数的 50 倍。

Since a byte is 8 bits, a single byte is used to represent values between 0 and 2⁸-1, two bytes would be used to represent values between 2⁸ and 2¹⁶-1, etc. For example, 10¹⁸ would cost 10 + 50 * 1 = 60 gas, while 10³⁰⁰ would cost 10 + 50 * 2 = 160 gas, since it takes one byte to represent 18 and two bytes to represent 300.
一个字节是 8 位，一个字节可以表示 0 到 2⁸-1 之间的值（即0-255），两个字节可以表示 2⁸ 到 2¹⁶-1 之间的值，以此类推。因此，例如求 10¹⁸ 将花费 10 + 50 * 1 = 60 gas，而求 10³⁰⁰ 将花费 10 + 50 * 2 = 160 gas，因为来表示 18 需要一个字节，表示 300 需要两个字节。

从上面可以清楚地看出，在某些时候您应该使用乘法而不是求幂。下面一个具体的例子：

```
contract squareExample {
uint256 x;
constructor (uint256 _x) {
   x = _x;
 }
function inefficcientSquare() external {
   x = x**2;
 }
function efficcientSquare() external {
     x = x * x;
 }
}
```

Both *inefficcientSquare* and *efficcientSquare* set the state variable, *x*, to the square of itself. However, the arithmetic of *inefficcientSquare* costs 10 + 1 * 50 = 60 gas while the arithmetic of *efficcientSquare* costs 5 gas.
*inefficientSquare* 和 *eficcientSquare* 两个方法都把状态变量 x 改为 x 的平方。然而，*inefficientSquare* 的算术开销为 10 + 1 * 50 = 60 gas，而 *efficientSquare* 的算术开销为5 gas。

For reasons in addition to the above cost of arithmetic, *inefficcientSquare* costs ~200 more gas than *efficcientSquare* on average*.*
由于上述算术开销之外的原因，*inefficientSquare* 的 gas 费用平均比 *efficientSquare* 多 200 左右。

![5.png](https://img.learnblockchain.cn/attachments/2022/09/257Lojs26316af9026e6d.png)

**缓存数据：SLOAD & MLOAD**


It is well known that caching data leads to far better performance at scale. However, caching data on the EVM is *extremely important* and will lead to dramatic gas savings even for a small number of operations.
众所周知，缓存数据可以大规模地提升更好的性能。同样，在 EVM 上使用缓存也*极端重要*，即使只有少量操作，也会明显节省 gas。

The SLOAD and MLOAD opcodes are used to load data from storage and memory. MLOAD always cost 3 gas, while SLOAD’s cost is determined by a formula: SLOAD costs 2100 gas to initially access a value during a transaction and costs 100 gas for each subsequent access. This means that it is ≥97% cheaper to load data from memory than from storage.
SLOAD 和 MLOAD 两个操作码用于从存储和内存中加载数据。MLOAD 成本固定 3 gas，而 SLOAD 的成本由一个公式决定：SLOAD 在交易过程中第一次访问一个值需要花费 2100 gas，之后每次访问需要花费 100 gas。这意味着从内存加载数据比从存储加载数据便宜 97% 以上。

Below is some sample code and the potential gas savings:
下面是一些节省潜在 gas 的示例代码：

```
contract storageExample {
uint256 sumOfArray;
function inefficcientSum(uint256 [] memory _array) public {
        for(uint256 i; i < _array.length; i++) {
            sumOfArray += _array[i];
        }
} 
function efficcientSum(uint256 [] memory _array) public {
   
   uint256 tempVar;
   for(uint256 i; i < _array.length; i++) {
            tempVar += _array[i];
        }
   sumOfArray = tempVar;
} 
} // end of storageExample
```

The contract, storageExample, has two functions: **inefficcientSum** and **efficcientSum**
合约 storageExample 有两个函数： **inefficientSum** 和 **efficientSum**

Both functions take *_array*, which is an array of unsigned integers, as an argument. They both set the contract’s state variable, *sumOfArray*, to the sum of the values in *_array*.
这两个函数都将 *_array* 作为参数，这是一个无符号整型数组。他们都会把合约的状态变量 *sumOfArray* 设置为 *_array* 中所有元素的总和。

**inefficcientSum** uses the state variable, itself, for its calculations. Remember that state variables, such as *sumOfArray*, are kept in storage*.*
**inefficcientSum** 使用状态变量进行计算。请牢记，状态变量（例如 *sumOfArray*）保存在 *存储* 中。

**efficcientSum** creates a temporary variable in memory, *tempVar*, that is used to calculate the sum of the values in *_array*. *sumOfArray* is then subsequently assigned to the value of *tempVar*.
**efficcientSum** 在内存中创建一个临时变量 *tempVar*，用于计算 *_array* 中值的总和。然后将 *tempVar* 赋值给 *sumOfArray*。

*efficcientSum* is >50% gas efficient than *inefficcientSum* when passing in array of **only 10 unsigned integers.**
当传入的数组仅包含 **10 个无符号整数**时， *efficientSum*的 gas 效率比 inefficcientSum 高 50% 以上。

![6.png](https://img.learnblockchain.cn/attachments/2022/09/htSLDxPR6316af932c3d9.png)

These efficiencies scale with the number of computations: *efficcientSum* is >300% more gas efficient than *inefficcientSum* when passing in an array of 100 unsigned integers.
它们的效率随着计算次数的增加而增加：当传入 100 个无符号整数的数组时，*eficcientSum* 比 *inefficcientSum* 的 gas 效率高 300% 以上。

![7.png](https://img.learnblockchain.cn/attachments/2022/09/3cNHPYNU6316af975451d.png)

**避免使用面向对象编程：CREATE 操作码**

The CREATE opcode is used when creating a new account with associated code (i.e. a smart contract). It costs *at least* 32,000 gas and is the most expensive opcode on the EVM.
CREATE 操作码用于创建包含关联代码的新帐户（即智能合约）。它花费*至少*32,000 gas，是 EVM 上最昂贵的操作码。

It is best to minimize the number of smart contracts used when possible. This is unlike typical object-oriented programming in which the separation of classes is encouraged for reusability and clarity.
最好尽可能减少使用的智能合约数量。这与典型的面向对象编程不同，在典型的面向对象编程中，为了可复用性和清晰性，鼓励定义多个类。

**这是一个具体的例子：**

Below is some code to create a “vault” using an object-oriented approach. Each vault contains a uint256, which is set in its constructor.
下面是一段使用面向对象方法创建“保险库”的代码。每个保险库都包含一个 uint256 变量，并在构造函数中初始化。

```
contract Vault {
    uint256 private x; 
    constructor(uint256 _x) { x = _x;}
    function getValue() external view returns (uint256) {return x;}
} // end of Vault
interface IVault {
    function getValue() external view returns (uint256);
} // end of IVault
contract InefficcientVaults {
    address[] public factory;
    constructor() {}
    function createVault(uint256 _x) external {
        address _vaultAddress = address(new Vault(_x)); 
        factory.push(_vaultAddress);
}
    function getVaultValue(uint256 vaultId) external view returns (uint256) {
        address _vaultAddress = factory[vaultId];
        IVault _vault = IVault(_vaultAddress);
        return _vault.getValue();
    }
} // end of InefficcientVaults
```

Each time that *createVault()* is called, a new *Vault* smart contract is created. The value stored in the *Vault* is determined by the argument passed into *createVault().* The address of the new *Vault* contract is then stored in an array, *factory.*

Now here is some code that accomplishes the same goal but uses a mapping in place of creating a new smart contract:

```
contract EfficcientVaults {
// vaultId => vaultValue
mapping (uint256 => uint256) public vaultIdToVaultValue;
// the next vault's id
uint256 nextVaultId;
function createVault(uint256 _x) external {
    vaultIdToVaultValue[nextVaultId] = _x;
    nextVaultId++;
}
function getVaultValue(uint256 vaultId) external view returns (uint256) {
    return vaultIdToVaultValue[vaultId];
}
} // end of EfficcientVaults
```

Each time that *createVault()* is called, its argument is stored in a mapping, and its ID is determined by the state variable, *nextVaultId,* which is incremented each time that *createVault()* is called.

This difference in implementation leads to a dramatic reduction in gas costs.

![8.png](https://img.learnblockchain.cn/attachments/2022/09/1NyGnqci6316af9a31bba.png)

EfficcientVaults’ *createVault()* is 61% more efficient and costs ~76,300 less gas than that of InefficcientVaults on average.

It should be noted that there are certain times when creating a new contract from within a contract is desirable and is typically done for immutability and efficiency. *The transaction cost for all interactions with a contract will increase with the size of a contract*. Therefore, if you expect to store massive amounts of data on-chain, it’s likely better to separate this data via separate contracts. However, if this is not the case, creating new contracts should be avoided.

**Storing Data: SSTORE**

SSTORE is the EVM opcode to save data to storage. As a generalization, SSTORE costs 20,000 gas when setting a storage value to non-zero from zero and 5000 gas when a storage value is set to zero.

Due to this cost, storing data on-chain is highly inefficient and costly. It should be avoided whenever possible.

This practice is most common with NFTs. Developers will store an NFT’s metadata (its image, attributes, etc.) on a decentralized storage network, like Arweave or IPFS, in place of storing it on-chain. The only data that is kept on-chain is a link to the metadata on the respective decentralized storage network. This link is queryable by the *tokenURI()* function found in all ERC721s that contain metadata.

![9.png](https://img.learnblockchain.cn/attachments/2022/09/mAjvW1Ku6316af9e93ae0.png)

A standard implementation of a tokenURI( ) function. (Source: [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol))

For example, take the [Bored Ape Yacht Club smart contract](https://etherscan.io/token/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#readContract). Calling the *tokenURI( )* function with the tokenId, 0, returns the following link: *ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/0*

![10.png](https://img.learnblockchain.cn/attachments/2022/09/WmjqnrXF6316afa3478a4.png)

If you go to this link, you will find the JSON file that contains the BAYC #0’s metadata:

![11.png](https://img.learnblockchain.cn/attachments/2022/09/eBv6mhxk6316afa76f064.png)

These attributes are easily verifiable on [OpenSea](https://opensea.io/assets/ethereum/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d/0):

![12.png](https://img.learnblockchain.cn/attachments/2022/09/PWDKlpqu6316afabdf409.png)

It should also be noted that certain data structures are simply unfeasible in the EVM due to the cost of storage. For example, representing [a graph using an adjacency matrix ](https://www.geeksforgeeks.org/graph-and-its-representations/)would be completely unfeasible due to its O(V²) space complexity.

*All of the above code can be found on my* [*Github*](https://github.com/tokyoDan67/evmOpcodeExamples)

Thank you for reading, and I hope you enjoyed this article!

There are so many more gas optimizations and nuances that I did not have a chance to cover. To learn more, I suggest the following resources:

- [*Tight Variable Packing*](https://fravoll.github.io/solidity-patterns/tight_variable_packing.html) and [*Memory Array Building*](https://fravoll.github.io/solidity-patterns/memory_array_building.html) by Franz Volland
- [*Solidity gas optimization tips*](https://mudit.blog/solidity-gas-optimization-tips/) and [*Solidity tips and tricks to save gas and reduce bytecode size*](https://blog.polymath.network/solidity-tips-and-tricks-to-save-gas-and-reduce-bytecode-size-c44580b218e6) by Mudit Gupta
- [*EVM: From Solidity to byte code, memory and storage*](https://www.youtube.com/watch?v=RxL_1AfV7N4&ab_channel=EthereumEngineeringGroup) by the Ethereum Engineering Group
- [*The Ethereum Yellowpaper*](https://ethereum.github.io/yellowpaper/paper.pdf)

*Please reach out to me and my team at* [*Bloccelerate VC*](https://www.bloccelerate.vc/) *if you are building in Web3. We are always looking to back great founders.*

[Website](https://bloccelerate.vc/)

[LinkedIn](https://www.linkedin.com/in/daniel-yamagata/)

[Twitter](https://twitter.com/daniel_yamagata)

*Feel free to also drop me a note if you have any suggestions for any toolings or topics that I should cover in the future*

