> * 原文：https://medium.com/coinmonks/delegatecall-calling-another-contract-function-in-solidity-b579f804178c ， 作者：[zerofruit](https://zerofruit.medium.com)
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)




# 探索以太坊合约委托调用（DelegateCall）

在本文中，我们看看如何调用另一个合约的函数，并更深入讨论`delegatecall`委托调用。

有时，需要在编写以太坊智能合约代码中，与其他合约进行交互。在Solidity中，有几种方法可以实现此目标：



## 如果知道目标合约的ABI，可以直接使用函数签名

假设已经部署了一个简单的合约，称为“Storage”，该合约允许用户保存`val`。

```javascript
pragma solidity ^0.5.8;
contract Storage {
    uint public val;
    constructor(uint v) public {
        val = v;
    }
    
    function setValue(uint v) public {
        val = v;
    }
}
```

现在我们部署另一个称为“Machine”的合约，它是“Storage”合约的调用方。 “Machine”引用“Storage”合约并更改其`val`。

```javascript
pragma solidity ^0.5.8;
import "./Storage.sol";
contract Machine {
    Storage public s;
    
    constructor(Storage addr) public {
        s = addr;
        calculateResult = 0;
    }
    
    function saveValue(uint x) public returns (bool) {
        s.setValue(x);
        return true;
    }
    function getValue() public view returns (uint) {
        return s.val();
    }
}
```

在此案例中，我们知道 `Storage`合约的[ABI](https://learnblockchain.cn/docs/solidity/abi-spec.html)及其地址，以便我们可以使用该地址初始化现有的`Storage`合约，而ABI的作用是告诉我们如何调用`Storage`合约的函数。可以看到`Machine`合约调用了` Storage.setValue()`函数。

编写测试代码检查`Machine.saveValue()`是否实际上调用了` Storage.setValue()`函数并更改了其状态。

```javascript
const StorageFactory = artifacts.require('Storage');
const MachineFactory = artifacts.require('Machine');

contract('Machine', accounts => {
  const [owner, ...others] = accounts;
  
  beforeEach(async () => {
    Storage = await StorageFactory.new(new BN('0'));
    Machine = await MachineFactory.new(Storage.address);
  });
  
  describe('#saveValue()', () => {
    it('should successfully save value', async () => {
      await Machine.saveValue(new BN('54'));
      (await Storage.val()).should.be.bignumber.equal(new BN('54'));
    });
  });
});
```

测试通过了！

```
Contract: Machine
  After initalize
    #saveValue()
      ✓ should successfully save value (56ms)
      
1 passing (56ms)
```

## 如果不知道目标合约的ABI，请使用call或delegatecall

但是，如果调用者(在本例中为“Machine”合约)不知道目标合约的ABI，该怎么办？

其实，我们仍然可以使用`call()`和`delegatecall()`来调用目标合约的函数。

在解释以太坊 Solidity的 `call()`和`delegatecall()`之前，了解EVM如何保存合约变量对于了解`call()`和`delegatecall()`会有所帮助。

## EVM如何将字段变量保存到存储

在以太坊中，有两种空间可以保存合约的字段变量。一个是“内存”，另一个是“存储”。而且，“ foo”保存到存储意味着“ foo”的值会永久记录到区块链状态中。

那么，单个合约中的如此多的变量又是怎样让彼此不重叠呢？ EVM将插槽号分配给字段变量。

```
contract Sample1 {
    uint256 first;  // slot 0
    uint256 second; // slot 1
}
```



![Image for post](https://img.learnblockchain.cn/pics/20201231162628.png)

<center>EVM使用插槽保存字段变量</center>



因为` first`在` Sample1`合约中最先声明，所以分配了0个插槽。每个不同的变量都通过其插槽号来区分。

在EVM中，智能合约存储中具有2<sup>256<sup>个插槽，每个插槽可以保存32字节大小的数据。

## 如何调用智能合约函数

像Java，Python这样的通用编程代码一样，Solidity函数可以看作是一组命令。当我们说“函数被调用”时，这意味着我们将特定的上下文(如参数)注入到该组命令(函数)中，并且在此上下文中一个接一个地执行命令。

函数、命令组、地址空间可以通过其名称找到。

在以太坊函数中，调用可以用字节码表示，使用 4 + 32 * N个字节表达。这个字节码由两部分组成。

- **函数选择器**：这是函数调用字节码的前4个字节。**函数选择器**是通过对目标函数的名称加上其参数类型(不包括空格)进行哈希（keccak-256哈希函数）取前 4 个字节得到，例如`bytes4(keccak-256(“saveValue(uint)”))`。基于此函数选择器，EVM可以决定应在合约中调用哪个函数。
- **函数参数**：将参数的每个值转换为固定长度为32bytes的十六进制字符串。如果有多个参数，则串联在一起。

如果用户将此4 + 32 * N字节字节代码传递给交易的数据字段。 EVM可以找到应执行的函数，然后将参数注入该函数。

## 用测试用例解释DelegateCall

## 上下文（context）

当我们谈论智能合约函数的调用方式时，有一个“上下文（context）”一词。实际上，“上下文”一词在软件中是很笼统的概念，其含义根据场合不同有所改变。

当我们谈论程序的执行时，我们可以说“上下文”是指执行时所有环境(如变量或状态)。例如，在执行程序“A”时，执行该程序的用户名是“zeroFruit”，则用户名 “zeroFruit”可以是程序“A”的上下文。

在以太坊智能合约中，有很多上下文，其中一个代表性的事情是`谁执行这个合约`。你可能会在很多Solidity代码中看到` msg.sender`，而` msg.sender`地址的值就是根据执行此合约函数的人，而有所不同。

## 委托调用（DelegateCall）

**委托调用，顾名思义，是调用方合约如何调用目标合约函数的调用机制，但是当目标合约执行其逻辑时，其使用调用方合约的上下文。**



![Image for post](https://img.learnblockchain.cn/pics/20201231162701.png)

<center>合约调用(call)另一个合约时的上下文</center>



![Image for post](https://img.learnblockchain.cn/pics/20201231162708.png)

<center>合约委托调用(delegatecall)另一个合约时的上下文</center>



那么，当合约委托调用目标时，存储状态将如何更改？

由于当使用委托调用目标时，上下文在调用者合约上，所以所有状态更改逻辑都会反映在调用者的存储上。

例如，我们有代理合约和业务合约。代理合约委托调用到业务合约函数。如果用户调用代理合约，则代理合约会将委托给业务合约，并执行函数。但是所有状态更改将反映在代理合约存储中，而不是业务合约中。

## 测试用例验证

以下是上面解释的合约的扩展版本。它仍然有`Storage`作为字段，还额外增加了有` addValuesWithDelegateCall`，` addValuesWithCall`以测试如何存储的更改。而且`Machine`具有` calculateResult`，` user`用于保存结果，以及谁调用了此函数。

```javascript
pragma solidity ^0.5.8;
import "./Storage.sol";

contract Machine {
    Storage public s;
    
    uint256 public calculateResult;
    
    address public user;
  
    event AddedValuesByDelegateCall(uint256 a, uint256 b, bool success);
    event AddedValuesByCall(uint256 a, uint256 b, bool success);
    
    constructor(Storage addr) public {
        ...
        calculateResult = 0;
    }
    
  ...
    
    function addValuesWithDelegateCall(address calculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = calculator.delegatecall(abi.encodeWithSignature("add(uint256,uint256)", a, b));
        emit AddedValuesByDelegateCall(a, b, success);
        return abi.decode(result, (uint256));
    }
    
    function addValuesWithCall(address calculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = calculator.call(abi.encodeWithSignature("add(uint256,uint256)", a, b));
        emit AddedValuesByCall(a, b, success);
        return abi.decode(result, (uint256));
    }
}
```

下面是目标合约`Calculator`，它也有`calculateResult`和`user`。

```
pragma solidity ^0.5.8;

contract Calculator {
    uint256 public calculateResult;
    
    address public user;
    
    event Add(uint256 a, uint256 b);
    
    function add(uint256 a, uint256 b) public returns (uint256) {
        calculateResult = a + b;
        assert(calculateResult >= a);
        
        emit Add(a, b);
        user = msg.sender;
        
        return calculateResult;
    }
}
```

## 测试addValuesWithCall

下面是`addValuesWithCall`的测试代码。需要测试的有：

- 由于上下文位于“Calculator”而非“Machine”上，因此add结果应保存到“Calculator”合约存储中
- 因此，` Calculator`的` calculateResult`应该为3，而` user`的地址应该设置为` Machine`的地址。
- 并且` Machine`的` calculateResult`应该为0，` user`为零地址。

```javascript
describe('#addValuesWithCall()', () => {
  let Calculator;
      
  beforeEach(async () => {
    Calculator = await CalculatorFactory.new();
  });
      
  it('should successfully add values with call', async () => {
    const result = await Machine.addValuesWithCall(Calculator.address, new BN('1'), new BN('2'));expectEvent.inLogs(result.logs, 'AddedValuesByCall', {
      a: new BN('1'),
      b: new BN('2'),
      success: true,
    });
    
    (result.receipt.from).should.be.equal(owner.toString().toLowerCase());
    (result.receipt.to).should.be.equal(Machine.address.toString().toLowerCase());(await Calculator.calculateResult()).should.be.bignumber.equal(new BN('3'));
    (await Machine.calculateResult()).should.be.bignumber.equal(new BN('0'));(await Machine.user()).should.be.equal(constants.ZERO_ADDRESS);
    
    (await Calculator.user()).should.be.equal(Machine.address);
  });
});
```

按预期通过了所有测试：

```
Contract: Machine
  After initalize
    #addValuesWithCall()
      ✓ should successfully add values with call (116ms)
      
1 passing (116ms)
```

## 测试addValuesWithDelegateCall

下面是我们的`addValuesWithCall`测试代码。我们需要测试的有：

- 由于上下文位于“Machine”而非“Calculator”上，因此add结果应保存到“Machine”存储中。
- 因此，` Calculator`的` calculateResult`应该为0，而` user`的地址应为` 0`地址。
- 而` Machine`的` calculateResult`应为3，而` user`的则为用户地址（EOA）。

```javascript
describe('#addValuesWithDelegateCall()', () => {
  let Calculator;
  
  beforeEach(async () => {
    Calculator = await CalculatorFactory.new();
  });
  
  it('should successfully add values with delegate call', async () => {
    const result = await Machine.addValuesWithDelegateCall(Calculator.address, new BN('1'), new BN('2'));expectEvent.inLogs(result.logs, 'AddedValuesByDelegateCall', {
      a: new BN('1'),
      b: new BN('2'),
      success: true,
    });
    
    (result.receipt.from).should.be.equal(owner.toString().toLowerCase());
    (result.receipt.to).should.be.equal(Machine.address.toString().toLowerCase());// Calculator storage DOES NOT CHANGE!
    (await Calculator.calculateResult()).should.be.bignumber.equal(new BN('0'));
    
    // Only calculateResult in Machine contract should be changed
    (await Machine.calculateResult()).should.be.bignumber.equal(new BN('3'));(await Machine.user()).should.be.equal(owner);
    (await Calculator.user()).should.be.equal(constants.ZERO_ADDRESS);
  });
});
```

**但是失败了！什么呢**？“562046206989085878832492993516240920558397288279”来自哪里？

```
0 passing (236ms)
1 failing1) Contract: Machine
     After initalize
       #addValuesWithDelegateCall()
         should successfully add values with delegate call:
         
AssertionError: expected '562046206989085878832492993516240920558397288279' to equal '3'
    + expected - actual-562046206989085878832492993516240920558397288279
    +3
```

如前所述，每个字段变量都有其自己的插槽。当我们委托调用` Calculator`时，上下文位于` Machine`上，但是插槽编号基于` Calculator`。

因此，由于`Calculator`用` calculateResult`覆盖了`Storage`地址，而`user`覆盖了` calculateResult`，因此测试失败。

基于此知识，我们可以找到“ 562046206989085875878832492993516240920558397288279”的来源。它是EOA的十进制版本。

![Image for post](https://img.learnblockchain.cn/pics/20201231163229.png)

<center>“Calculator”合约字段变量将覆盖“Machine”合约字段变量</center>



因此，要解决此问题，我们需要更改“ Machine”字段变量的顺序。

```
contract Machine {
    uint256 public calculateResult;
    
    address public user;
    
    Storage public s;
    
    ...
}
```

最后，测试通过了！

```
Contract: Machine
  After initalize
    #addValuesWithDelegateCall()
      ✓ should successfully add values with delegate call (106ms)

1 passing (247ms)
```

## 总结一下

在本文中，我们已经看到了如何从合约中调用另一个合约的函数。

- 如果我们知道目标函数的ABI，就可以直接使用目标函数签名
- 如果我们不知道目标函数的ABI，可以使用`call()`或`delegatecall()`。但是在`delegatecall()`的情况下，我们需要关心字段变量的顺序。

### 源代码

如果你想自己进行测试，可以在[此代码库](https://github.com/zeroFruit/upgradable-contract/tree/feat/delegatecall)中找到代码。


------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。