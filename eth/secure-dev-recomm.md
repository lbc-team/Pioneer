> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[六天](https://learnblockchain.cn/people/436)
> * 来源：[原文链接](https://consensys.github.io/smart-contract-best-practices/recommendations/ )


# Secure Development Recommendations
# 以太坊智能合约安全开发建议

This page demonstrates a number of patterns which should generally be followed when writing smart contracts.
本文展示了在编写智能合约时需要遵循的一系列模式和规范。

## Protocol specific recommendations
## 协议相关的建议

The following recommendations apply to the development of any contract system on Ethereum.
以下建议适用于以太坊上任何智能合约的开发。

### External Calls
### 外部请求

#### Use caution when making external calls
#### 在合约中请求外部合约时需谨慎处理
Calls to untrusted contracts can introduce several unexpected risks or errors. External calls may execute malicious code in that contract *or* any other contract that it depends upon. As such, every external call should be treated as a potential security risk. When it is not possible, or undesirable to remove external calls, use the recommendations in the rest of this section to minimize the danger.
请求不可信的合约时可能会引入一些意外风险或错误。在调用外部合约时，外部合约或其依赖的其它合约中可能存在恶意代码。因此，每个外部合约的请求都应该被认为是有风险的。如必须请求外部合约，请参考本节中的建议以最大程度的减小风险。


#### Mark untrusted contracts
#### 对不可信合约进行标记

When interacting with external contracts, name your variables, methods, and contract interfaces in a way that makes it clear that interacting with them is potentially unsafe. This applies to your own functions that call external contracts.
在自己开发的合约调用外部合约时，可以明确的将相关的变量、方法以及合约接口标记为非安全。

```
// bad
Bank.withdraw(100); // 没有明确标记可信或不可信

function makeWithdrawal(uint amount) { // 不清楚该方法是否安全
    Bank.withdraw(amount);
}

// good
UntrustedBank.withdraw(100); // 不可信的外部调用
TrustedBank.withdraw(100); // 由XYZ Corp维护的可信任的外部合约调用

function makeUntrustedWithdrawal(uint amount) {
    UntrustedBank.withdraw(amount);
}
```




#### Avoid state changes after external calls
#### 避免调用外部合约后更改自身合约状态

Whether using *raw calls* (of the form `someAddress.call()`) or *contract calls* (of the form `ExternalContract.someMethod()`), assume that malicious code might execute. Even if `ExternalContract` is not malicious, malicious code can be executed by any contracts *it* calls.
无论使用*raw calls* (类似 `someAddress.call()`)还是*contract calls* (类似 `ExternalContract.someMethod()`)，都应该假定可能会执行恶意代码。即使`ExternalContract`不是恶意代码，也可能通过其他合约调用执行恶意代码。

One particular danger is malicious code may hijack the control flow, leading to vulnerabilities due to reentrancy. (See [Reentrancy](../known_attacks#reentrancy) for a fuller discussion of this problem).
一种极其危险的情况是恶意代码劫持了程序的控制流，而造成重入攻击。(详见 [重入攻击](../known_attacks#reentrancy) ).

If you are making a call to an untrusted external contract, *avoid state changes after the call*. This pattern is also sometimes known as the [checks-effects-interactions pattern](http://solidity.readthedocs.io/en/develop/security-considerations.html?highlight=check%20effects#use-the-checks-effects-interactions-pattern).
如果调用不可信的外部合约，尽量避免在调用后更改合约中的变量状态。这种模式也称为 [checks-effects-interactions 模式](http://solidity.readthedocs.io/en/develop/security-considerations.html?highlight=check%20effects#use-the-checks-effects-interactions-pattern).

详见 [SWC-107](https://swcregistry.io/docs/SWC-107)



#### Don't use `transfer()` or `send()`
#### 不用使用`transfer()` 或 `send()`

`.transfer()` and `.send()` forward exactly 2,300 gas to the recipient. The goal of this hardcoded gas stipend was to prevent [reentrancy vulnerabilities](../known_attacks#reentrancy), but this only makes sense under the assumption that gas costs are constant. Recently [EIP 1884](https://eips.ethereum.org/EIPS/eip-1884) was included in the Istanbul hard fork. One of the changes included in EIP 1884 is an increase to the gas cost of the `SLOAD` operation, causing a contract's fallback function to cost more than 2300 gas.
`.transfer()` 和 `.send()`方法会将固定的2300 gas转给接收者。这种固定gas的目的是为了防止[重入攻击](../known_attacks#reentrancy)，但这种方式仅适合gas费用固定的前提下。伊斯坦布尔升级中包含了[EIP 1884](https://eips.ethereum.org/EIPS/eip-1884)，1884提案中包含的一项更改就是增加了gas花费的`SLOAD`操作码，会导致合约的fallback函数执行消耗的gas大于2300。

It's recommended to stop using `.transfer()` and `.send()` and instead use `.call()`.
建议使用 `.call()`方法代替`.transfer()` 和 `.send()` 。

```
// bad
contract Vulnerable {
    function withdraw(uint256 amount) external {
        // 如果接收者是一个合约，2300的gas可能会不够
        msg.sender.transfer(amount);
    }
}

// good
contract Fixed {
    function withdraw(uint256 amount) external {
        // 使用所有可用的gas
        // 使用该方式请确认检查返回值
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Transfer failed.");
    }
}
```



Note that `.call()` does nothing to mitigate reentrancy attacks, so other precautions must be taken. To prevent reentrancy attacks, it is recommended that you use the [checks-effects-interactions pattern](https://solidity.readthedocs.io/en/develop/security-considerations.html?highlight=check%20effects#use-the-checks-effects-interactions-pattern).
需要注意的是，`.call()`方式并不能避免重入攻击，因此需要采取其他方式。如果需要防止重入攻击，建议使用[checks-effects-interactions pattern](https://solidity.readthedocs.io/en/develop/security-considerations.html?highlight=check%20effects#use-the-checks-effects-interactions-pattern)。


#### Handle errors in external calls
#### 调用外部合约时要对错误进行处理

Solidity offers low-level call methods that work on raw addresses: `address.call()`, `address.callcode()`, `address.delegatecall()`, and `address.send()`. These low-level methods never throw an exception, but will return `false` if the call encounters an exception. On the other hand, *contract calls* (e.g., `ExternalContract.doSomething()`) will automatically propagate a throw (for example, `ExternalContract.doSomething()` will also `throw` if `doSomething()` throws).
Solidity提供了在原合约中调用外部合约的低级别方法： `address.call()`, `address.callcode()`, `address.delegatecall()`, 和 `address.send()`。这些方法不会抛出异常，但在执行异常时会返回`false`结果。另一方面，直接调用外部合约相关方法 (例如, `ExternalContract.doSomething()`) 会自动抛出异常(如, 执行`ExternalContract.doSomething()`时，`doSomething()`抛出异常，该程序也会异常)。

If you choose to use the low-level call methods, make sure to handle the possibility that the call will fail, by checking the return value.
如果选择使用低级别方法，记得检查返回值，来确保合约请求成功。

```
// bad
someAddress.send(55);
someAddress.call.value(55)(""); // 有双重风险，可能会消耗所有剩余的gas，而且没有检查返回结果
someAddress.call.value(100)(bytes4(sha3("deposit()"))); // 如果deposit方法执行异常，call()方法返回false，但交易并不会回滚

// good
(bool success, ) = someAddress.call.value(55)("");
if(!success) {
    // 处理请求失败的情况
}

ExternalContract(someAddress).deposit.value(100)();
```



See [SWC-104](https://swcregistry.io/docs/SWC-104)
详见 [SWC-104](https://swcregistry.io/docs/SWC-104)

#### Favor *pull* over *push* for external calls
#### 调用外部合约时，*被动* 比 *主动* 好

External calls can fail accidentally or deliberately. To minimize the damage caused by such failures, it is often better to isolate each external call into its own transaction that can be initiated by the recipient of the call. This is especially relevant for payments, where it is better to let users withdraw funds rather than push funds to them automatically. (This also reduces the chance of [problems with the gas limit](../known_attacks#dos-with-block-gas-limit).) Avoid combining multiple ether transfers in a single transaction.
调用外部合约时，可能有意或无意造成失败。为了最大程度的减小失败造成的损害，交易发起者可以将每次外部合约调用隔离在单独的交易事务中。特别是在转账交易中，最好让用户主动发起资金提取而不是自动向用户发起转账。(这也减小了 [gas limit的问题](../known_attacks#dos-with-block-gas-limit).)避免在一次交易中包含多个以太坊转账。

```
// bad
contract auction {
    address highestBidder;
    uint highestBid;

    function bid() payable {
        require(msg.value >= highestBid);

        if (highestBidder != address(0)) {
            (bool success, ) = highestBidder.call.value(highestBid)("");
            require(success); // 如果请求一直失败，则无法出价
        }

       highestBidder = msg.sender;
       highestBid = msg.value;
    }
}

// good
contract auction {
    address highestBidder;
    uint highestBid;
    mapping(address => uint) refunds;

    function bid() payable external {
        require(msg.value >= highestBid);

        if (highestBidder != address(0)) {
            refunds[highestBidder] += highestBid; // 记录需要退还给用户的资金
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdrawRefund() external {
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;
        (bool success, ) = msg.sender.call.value(refund)("");
        require(success);
    }
}
```



See [SWC-128](https://swcregistry.io/docs/SWC-128)
详见 [SWC-128](https://swcregistry.io/docs/SWC-128)



#### Don't delegatecall to untrusted code
#### 不用使用delegatecall调用不可信的合约

The `delegatecall` function is used to call functions from other contracts as if they belong to the caller contract. Thus the callee may change the state of the calling address. This may be insecure. An example below shows how using `delegatecall` can lead to the destruction of the contract and loss of its balance.
使用`delegatecall`调用其它合约方法时，就像是调用本地合约一样，这也造成被调合约可以更改调用合约的状态，这是不安全的。下面示例展示了使用`delegatecall` 导致合约被销毁或造成了资金损失。

```
contract Destructor
{
    function doWork() external
    {
        selfdestruct(0);
    }
}

contract Worker
{
    function doWork(address _internalWorker) public
    {
        // unsafe
        _internalWorker.delegatecall(bytes4(keccak256("doWork()")));
    }
}
```



If `Worker.doWork()` is called with the address of the deployed `Destructor` contract as an argument, the `Worker` contract will self-destruct. Delegate execution only to trusted contracts, and **never to a user supplied address**.
如果使用 `Destructor`的合约地址为参数，调用`Worker.doWork()`方法时，`Worker`合约会被销毁。在使用`delegatecall`时，一定不要使用用户提供的地址调用。


> Warning
> Don't assume contracts are created with zero balance An attacker can send ether to the address of a contract before it is created. Contracts should not assume that its initial state contains a zero balance. See [issue 61](https://github.com/ConsenSys/smart-contract-best-practices/issues/61) for more details.

> 警告
> 不要假设合约余额为0，攻击者在合约创建前可以向其地址发送以太币。更多信息参考[issue 61](https://github.com/ConsenSys/smart-contract-best-practices/issues/61) 


See [SWC-112](https://swcregistry.io/docs/SWC-112)
详见 [SWC-112](https://swcregistry.io/docs/SWC-112)



### Remember that Ether can be forcibly sent to an account
### 谨记，以太币可以被强行发送到某个地址中

Beware of coding an invariant that strictly checks the balance of a contract.
在编写合约时，切勿使用常量来判断合约余额。

An attacker can forcibly send ether to any account and this cannot be prevented (not even with a fallback function that does a `revert()`).
攻击者可以强制将以太币发送到任何地址，并且无法阻止（即使在合约的fallback函数中使用了`revert()`）。

The attacker can do this by creating a contract, funding it with 1 wei, and invoking `selfdestruct(victimAddress)`. No code is invoked in `victimAddress`, so it cannot be prevented. This is also true for block reward which is sent to the address of the miner, which can be any arbitrary address.
攻击者可以通过创建一个合约，存入1 wei，调用`selfdestruct(victimAddress)`方法。这种方式并不会调用`victimAddress`地址对应的合约代码，因此无法避免。给矿工地址发送奖励也是这种方式，矿工地址可以是合约地址也可以是普通地址。

Also, since contract addresses can be precomputed, ether can be sent to an address before the contract is deployed.
另外，由于合约地址可以被提前计算出来，因此在合约部署之前，就可以向该地址转账以太币。

See [SWC-132](https://swcregistry.io/docs/SWC-132)
详见 [SWC-132](https://swcregistry.io/docs/SWC-132)



### Remember that on-chain data is public
### 谨记，链上的数据都是公开的

Many applications require submitted data to be private up until some point in time in order to work. Games (eg. on-chain rock-paper-scissors) and auction mechanisms (eg. sealed-bid [Vickrey auctions](https://en.wikipedia.org/wiki/Vickrey_auction)) are two major categories of examples. If you are building an application where privacy is an issue, make sure you avoid requiring users to publish information too early. The best strategy is to use [commitment schemes](https://en.wikipedia.org/wiki/Commitment_scheme) with separate phases: first commit using the hash of the values and in a later phase revealing the values.
很多区块链应用程序要求提交到链上的数据在一定时间内是保密的。例如游戏（例如 猜拳游戏）和拍卖应用（如 保密竞拍[Vickrey auctions](https://en.wikipedia.org/wiki/Vickrey_auction)）类应用。如果需要构建数据保密类的应用，应该尽量避免让用户过早的提交数据。最好的方式是使用具有不同阶段的[承诺方案](https://en.wikipedia.org/wiki/Commitment_scheme)：首先可以先提交数据的hash值，之后在提交元数据。

Examples:
例如：

* In rock paper scissors, require both players to submit a hash of their intended move first, then require both players to submit their move; if the submitted move does not match the hash throw it out.
* In an auction, require players to submit a hash of their bid value in an initial phase (along with a deposit greater than their bid value), and then submit their auction bid value in the second phase.
* When developing an application that depends on a random number generator, the order should always be *(1)* players submit moves, *(2)* random number generated, *(3)* players paid out. The method by which random numbers are generated is itself an area of active research; current best-in-class solutions include Bitcoin block headers (verified through [http://btcrelay.org](http://btcrelay.org)), hash-commit-reveal schemes (ie. one party generates a number, publishes its hash to "commit" to the value, and then reveals the value later) and [RANDAO](http://github.com/randao/randao). As Ethereum is a deterministic protocol, no variable within the protocol could be used as an unpredictable random number. Also be aware that miners are in some extent in control of the `block.blockhash()` value[*](https://ethereum.stackexchange.com/questions/419/when-can-blockhash-be-safely-used-for-a-random-number-when-would-it-be-unsafe).
* 在石头剪刀布游戏中，要求玩家先提交动作的hash，然后在提交动作，如果提交的动作计算hash后与先前提交的hash不匹配，则丢弃。
* 在拍卖中，要求玩家在初始阶段提交竞价的hash（以及大于其出价的保证金），然后在第二阶段提交真实的竞拍价。
* 应用程序如果需要依赖随机数时，提交的顺序是 *(1)* 玩家提交动作；*(2)* 生成随机数； *(3)* 玩家支付。生成随机数的方法本身就是一个快速发展的研究领域。当前最佳解决方案包括比特币的区块头(通过 [http://btcrelay.org](http://btcrelay.org)验证),hash提交显示方案 (即，一方生成一个数字，发布其hash值，并在之后揭示hash对应的数字)和[RANDAO](http://github.com/randao/randao)。由于以太坊是一个确定性的系统，因此系统中任何变量都不能用作不可预测的随机数。还需要注意的是，矿工在一定程度上控制着`block.blockhash()` 值[*](https://ethereum.stackexchange.com/questions/419/when-can-blockhash-be-safely-used-for-a-random-number-when-would-it-be-unsafe).


### Beware of the possibility that some participants may "drop offline" and not return
### 注意，某些参与者可能下线而不会有返回值

Do not make refund or claim processes dependent on a specific party performing a particular action with no other way of getting the funds out. For example, in a rock-paper-scissors game, one common mistake is to not make a payout until both players submit their moves; however, a malicious player can "grief" the other by simply never submitting their move - in fact, if a player sees the other player's revealed move and determines that they lost, they have no reason to submit their own move at all. This issue may also arise in the context of state channel settlement. When such situations are an issue, (1) provide a way of circumventing non-participating participants, perhaps through a time limit, and (2) consider adding an additional economic incentive for participants to submit information in all of the situations in which they are supposed to do so.
不要依赖第三方提供的退款或索赔等特定操作，而自身没有其他方式提取资金。例如，在猜拳游戏中，一个常见的错误是在两个玩家都提交动作后才进行支付。这样，恶意玩家可以通过不提交动作来拖住对方。实际上，如果一个玩家看到对手的动作而确定自己输了的话，那么玩家根本没有理由在给出自己的动作并支付。在使用状态通道的情况下也可能出现该问题。当出现这种情况时，(1) 提供一种规避不参与的方法，例如玩家需要在一定的期限给出动作。 (2) 考虑增加额外的激励措施，使参与者在应有的所有情况下都可以提交信息。


### Beware of negation of the most negative signed integer
### 警惕最大负整数的否定

Solidity provides several types to work with signed integers. Like in most programming languages, in Solidity a signed integer with `N` bits can represent values from `-2^(N-1)` to `2^(N-1)-1`. This means that there is no positive equivalent for the `MIN_INT`. Negation is implemented as finding the two's complement of a number, so the negation of the most negative number [will result in the same number](https://en.wikipedia.org/wiki/Two%27s_complement#Most_negative_number).
Solidity提供了多种有符号的数据类型。与大多数编程语言一样，在Solidity中，有符号整数使用`N`个字节表示从`-2^(N-1)` 到 `2^(N-1)-1`范围的数值。负数的符号占用两个数字位，因此最大负整数的否定[将导致相同的数字](https://en.wikipedia.org/wiki/Two%27s_complement#Most_negative_number).

This is true for all signed integer types in Solidity (`int8`, `int16`, ..., `int256`).
在Solidity的所有有符号整型 (`int8`, `int16`, ..., `int256`)中都需要注意这个问题。

```
contract Negation {
    function negate8(int8 _i) public pure returns(int8) {
        return -_i;
    }

    function negate16(int16 _i) public pure returns(int16) {
        return -_i;
    }

    int8 public a = negate8(-128); // -128
    int16 public b = negate16(-128); // 128
    int16 public c = negate16(-32768); // -32768
}
```



One way to handle this is to check the value of a variable before negation and throw if it's equal to the `MIN_INT`. Another option is to make sure that the most negative number will never be achieved by using a type with a higher capacity (e.g. `int32` instead of `int16`).
处理此问题的一种方法是在否定之前检查变量的值，如果值等于最小整数则抛出异常。另一种方法是使用长度更大的数据类型，使得变量的值不会达到边界值。

A similar issue with `int` types occurs when `MIN_INT` is multiplied or divided by `-1`.
对`int`类型进行乘或除以-1时，也会有类似的问题。

## Solidity specific recommendations
## Solidity 特定建议

The following recommendations are specific to Solidity, but may also be instructive for developing smart contracts in other languages.
以下是针对Solidity语言的特定建议，但对于使用其他语言开发智能合约时也有指导意义。

### Enforce invariants with `assert()`
### 使用`assert()`验证不变量

An assert guard triggers when an assertion fails - such as an invariant property changing. For example, the token to ether issuance ratio, in a token issuance contract, may be fixed. You can verify that this is the case at all times with an `assert()`. Assert guards should often be combined with other techniques, such as pausing the contract and allowing upgrades. (Otherwise, you may end up stuck, with an assertion that is always failing.)
断言失败时将会触发断言保护，如不变量被更改。例如，在以太坊发行的Token的总量是可以固定的，可以通过`assert()`进行验证。断言经常和其他逻辑结合使用，比如暂停合约和允许升级。(否则，可能会出现断言一直失败。)
Example:
例如：

```
contract Token {
    mapping(address => uint) public balanceOf;
    uint public totalSupply;

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        assert(address(this).balance >= totalSupply);
    }
}
```



Note that the assertion is *not* a strict equality of the balance because the contract can be [forcibly sent ether](#remember-that-ether-can-be-forcibly-sent-to-an-account) without going through the `deposit()` function!
注意，断言通过不代表以太币余额一定相等，因为可以不通过`deposit()` 方法，[强制向合约地址发送以太币](#remember-that-ether-can-be-forcibly-sent-to-an-account) 。


### Use `assert()`, `require()`, `revert()` properly
### 正确使用`assert()`, `require()`, `revert()`


> Info
> The convenience functions **assert** and **require** can be used to check for conditions and throw an exception if the condition is not met.
> The **assert** function should only be used to test for internal errors, and to check invariants.
> The **require** function should be used to ensure valid conditions, such as inputs, or contract state variables are met, or to validate return values from calls to external contracts. [*](https://solidity.readthedocs.io/en/latest/control-structures.html#error-handling-assert-require-revert-and-exceptions)
> 信息
> **assert** 和 **require**函数可以用于参数校验，如果不通过则抛出异常。
> **assert**函数只能用于检查内部错误和检查不变量。
> **require**函数更适合用于确保条件满足，如输入或合约状态变量被满足，也可以验证调用外部合约的返回值。[*](https://solidity.readthedocs.io/en/latest/control-structures.html#error-handling-assert-require-revert-and-exceptions)


Following this paradigm allows formal analysis tools to verify that the invalid opcode can never be reached: meaning no invariants in the code are violated and that the code is formally verified.
遵循此范例，形式分析工具可以验证永远不会到达的无效的操作码：这意味着不会违反代码中的不变式且代码将被正式验证。

```
pragma solidity ^0.5.0;

contract Sharer {
    function sendHalf(address payable addr) public payable returns (uint balance) {
        require(msg.value % 2 == 0, "Even value required."); //Require() 具有可选的消息字符串
        uint balanceBeforeTransfer = address(this).balance;
        (bool success, ) = addr.call.value(msg.value / 2)("");
        require(success);
        // 如果转账失败，交易会被回滚
        assert(address(this).balance == balanceBeforeTransfer - msg.value / 2); // used for internal error checking
        return address(this).balance;
    }
}
```



See [SWC-110](https://swcregistry.io/docs/SWC-110) & [SWC-123](https://swcregistry.io/docs/SWC-123)
详见 [SWC-110](https://swcregistry.io/docs/SWC-110) & [SWC-123](https://swcregistry.io/docs/SWC-123)



### Use modifiers only for checks
### 函数修饰器modifier仅用于检查

The code inside a modifier is usually executed before the function body, so any state changes or external calls will violate the [Checks-Effects-Interactions](https://solidity.readthedocs.io/en/develop/security-considerations.html#use-the-checks-effects-interactions-pattern) pattern. Moreover, these statements may also remain unnoticed by the developer, as the code for modifier may be far from the function declaration. For example, an external call in modifier can lead to the reentrancy attack:
modifier中的代码通常是在主函数体之前执行的，因此任何状态变量的改变或外部合约调用都会违反[Checks-Effects-Interactions](https://solidity.readthedocs.io/en/develop/security-considerations.html#use-the-checks-effects-interactions-pattern)模式。而且，由于修饰器的代码和主函数体的代码不在一块，开发者可能会忽略修饰器中的代码。例如，在修饰器中的代码调用外部合约时，可能导致重入攻击。


```
contract Registry {
    address owner;

    function isVoter(address _addr) external returns(bool) {
        // Code
    }
}

contract Election {
    Registry registry;

    modifier isEligible(address _addr) {
        require(registry.isVoter(_addr));
        _;
    }

    function vote() isEligible(msg.sender) public {
        // Code
    }
}
```



In this case, the `Registry` contract can make a reentracy attack by calling `Election.vote()` inside `isVoter()`.
在本例中，`Registry` 合约通过 `Election.vote()` 方法调用 `isVoter()`导致重入攻击。


> Note
> Use [modifiers](https://solidity.readthedocs.io/en/develop/contracts.html#function-modifiers) to replace duplicate condition checks in multiple functions, such as `isOwner()`, otherwise use `require` or `revert` inside the function. This makes your smart contract code more readable and easier to audit.

>> 注意
> 使用[modifiers](https://solidity.readthedocs.io/en/develop/contracts.html#function-modifiers)来替换多个函数中的重复校验，例如 `isOwner()`，否在在函数内部使用 `require` 或 `revert` 。这样合约代码更具可读性，并且易于审核。



### Beware rounding with integer division
### 警惕整数除法的四舍五入

All integer division rounds down to the nearest integer. If you need more precision, consider using a multiplier, or store both the numerator and denominator.
所有整数除法四舍五入向下取整。如果需要更高的精度，建议使用乘数或者将分子和分母同时存储。

(In the future, Solidity will have a [fixed-point](https://solidity.readthedocs.io/en/develop/types.html#fixed-point-numbers) type, which will make this easier.)
(未来, Solidity 会支持 [浮点型](https://solidity.readthedocs.io/en/develop/types.html#fixed-point-numbers) ）

```
// bad
uint x = 5 / 2; // 结果是2，向下取整
```



Using a multiplier prevents rounding down, this multiplier needs to be accounted for when working with x in the future:
在合约代码中，如果需要用到x，可以使用乘数来解决精度问题。

```
// good
uint multiplier = 10;
uint x = (5 * multiplier) / 2;
```



Storing the numerator and denominator means you can calculate the result of `numerator/denominator` off-chain:
存储分子和分母意味着可以在线下计算`numerator/denominator`

```
// good
uint numerator = 5;
uint denominator = 2;
```



### Be aware of the tradeoffs between **abstract contracts** and **interfaces**
### 注意**抽象合约** and **接口**的权衡

Both interfaces and abstract contracts provide one with a customizable and re-usable approach for smart contracts. Interfaces, which were introduced in Solidity 0.4.11, are similar to abstract contracts but cannot have any functions implemented. Interfaces also have limitations such as not being able to access storage or inherit from other interfaces which generally makes abstract contracts more practical. Although, interfaces are certainly useful for designing contracts prior to implementation. Additionally, it is important to keep in mind that if a contract inherits from an abstract contract it must implement all non-implemented functions via overriding or it will be abstract as well.
接口和抽象合约都为智能合约提供了一种可自定义和可重复使用的方法。在Solidity 0.4.11中引入的接口与抽象合约相似，但是不能实现任何功能。接口对于在开发之前设计合约有用，但接口具有局限性，例如无法访问存储或从其他接口继承，而抽象合约可以。另外，需要注意的是，如果合约从抽象合约继承，则必须覆盖实现所有未实现的功能，否则它也将是抽象的。

### Fallback Functions
### Fallback函数

#### Keep fallback functions simple
#### 让Fallback函数尽量简单

[Fallback functions](http://solidity.readthedocs.io/en/latest/contracts.html#fallback-function) are called when a contract is sent a message with no arguments (or when no function matches), and only has access to 2,300 gas when called from a `.send()` or `.transfer()`. If you wish to be able to receive Ether from a `.send()` or `.transfer()`, the most you can do in a fallback function is log an event. Use a proper function if a computation of more gas is required.
当向合约发送不带参数的消息（或没有匹配到合约方法）会自动调用[Fallback 函数](http://solidity.readthedocs.io/en/latest/contracts.html#fallback-function)，并且，如果是使用`.send()` 或 `.transfer()`请求时，只会有 2,300 gas。如果你希望合约能够从`.send()` 或 `.transfer()`方法中接收到以太币，在fallback函数中，最多就是记录一个事件，如果需要有复杂操作，建议使用单独方法。

```
// bad
function() payable { balances[msg.sender] += msg.value; }

// good
function deposit() payable external { balances[msg.sender] += msg.value; }

function() payable { require(msg.data.length == 0); emit LogDepositReceived(msg.sender); }
```



#### Check data length in fallback functions
#### 在fallback函数中检查消息长度

Since the [fallback functions](http://solidity.readthedocs.io/en/latest/contracts.html#fallback-function) is not only called for plain ether transfers (without data) but also when no other function matches, you should check that the data is empty if the fallback function is intended to be used only for the purpose of logging received Ether. Otherwise, callers will not notice if your contract is used incorrectly and functions that do not exist are called.
由于[fallback 函数](http://solidity.readthedocs.io/en/latest/contracts.html#fallback-function) 可以在无消息数据或未匹配到合约方法时被触发，因此，如果仅仅是使用fallback函数接收以太币，建议检查消息是否为空。否则，调用者可能调用了不存在的函数确不知道。

```
// bad
function() payable { emit LogDepositReceived(msg.sender); }

// good
function() payable { require(msg.data.length == 0); emit LogDepositReceived(msg.sender); }
```


### Explicitly mark payable functions and state variables
### 在方法和状态变量中明确标记payable


Starting from Solidity `0.4.0`, every function that is receiving ether must use `payable` modifier, otherwise if the transaction has `msg.value > 0` will revert ([except when forced](../recommendations/#remember-that-ether-can-be-forcibly-sent-to-an-account)).
从Solidity `0.4.0`版本起，函数如有需要接收以太币必须使用`payable` 修饰，否则如果`msg.value > 0`时，交易会被回滚。 ([except when forced](../recommendations/#remember-that-ether-can-be-forcibly-sent-to-an-account)).


> Note
> Something that might not be obvious: The `payable` modifier only applies to calls from *external* contracts. If I call a non-payable function in the payable function in the same contract, the non-payable function won't fail, though `msg.value` is still set
> 注意
> 需要注意的是，`payable`修饰仅适用于外部调用。如果在同一个合约中，在payable修饰的方法中调用未被修饰的方法，即使 `msg.value` 大于0也不会出错。


### Explicitly mark visibility in functions and state variables[¶](#explicitly-mark-visibility-in-functions-and-state-variables "Permanent link")
### 在方法和状态变量中明确标记可见性

Explicitly label the visibility of functions and state variables. Functions can be specified as being `external`, `public`, `internal` or `private`. Please understand the differences between them, for example, `external` may be sufficient instead of `public`. For state variables, `external` is not possible. Labeling the visibility explicitly will make it easier to catch incorrect assumptions about who can call the function or access the variable.
函数可以被标记为 `external`, `public`, `internal` or `private`。注意这些关键字的区别。例如，

* `External` functions are part of the contract interface. An external function `f` cannot be called internally (i.e. `f()` does not work, but `this.f()` works). External functions are sometimes more efficient when they receive large arrays of data.
* `Public` functions are part of the contract interface and can be either called internally or via messages. For public state variables, an automatic getter function (see below) is generated.
* `Internal` functions and state variables can only be accessed internally, without using `this`.
* `Private` functions and state variables are only visible for the contract they are defined in and not in derived contracts. **Note**: Everything that is inside a contract is visible to all observers external to the blockchain, even `Private` variables.[*](https://solidity.readthedocs.io/en/develop/contracts.html?#visibility-and-getters)

* `External` 修饰的函数是合约接口的一部分。一个使用external修饰的函数 `f` 不能在合约内部被调用（即，不能直接`f()`调用，但可以`this.f()`调用）。external修饰的函数在接收大数据时，可能会更有效。
* `Public` 修饰的函数是合约接口的一部分，可以在内部或者外部被调用。对于public类型的变量，会自动生成getter方法。
* `Internal` 修饰的函数和状态变量只能被内部访问，不需要使用`this`关键字。
* `Private` 修饰的函数和状态变量其所在的合约可见，其继承的子合约不可见。 **注意**: 合约内的所有内容对外部都是可见的，也包括 `Private` 修饰的内容.[*](https://solidity.readthedocs.io/en/develop/contracts.html?#visibility-and-getters)

```
// bad
uint x; // 默认是内部变量，但最好使用Internal显性修饰
function buy() { // 默认是public
    // public code
}

// good
uint private y;
function buy() external {
    // only callable externally or using this.buy()
}

function utility() public {
    // callable externally, as well as internally: changing this code requires thinking about both cases.
}

function internalAction() internal {
    // internal code
}
```



See [SWC-100](https://swcregistry.io/docs/SWC-100) and [SWC-108](https://swcregistry.io/docs/SWC-108)
详见 [SWC-100](https://swcregistry.io/docs/SWC-100) 和 [SWC-108](https://swcregistry.io/docs/SWC-108)



### Lock pragmas to specific compiler version
### 明确solidity的具体版本

Contracts should be deployed with the same compiler version and flags that they have been tested the most with. Locking the pragma helps ensure that contracts do not accidentally get deployed using, for example, the latest compiler which may have higher risks of undiscovered bugs. Contracts may also be deployed by others and the pragma indicates the compiler version intended by the original authors.
合约在部署时，应该选用测试时的版本。锁定pragma版本，可以避免部署时意外使用最新的版本，而最新的版本可能包含未知错误。合约也可能被其他人部署，合约开发者应该标明使用的编译器版本。

```
// bad
pragma solidity ^0.4.4;

// good
pragma solidity 0.4.4;
```



Note: a floating pragma version (ie. `^0.4.25`) will compile fine with `0.4.26-nightly.2018.9.25`, however nightly builds should never be used to compile code for production.
注意：一个浮动的pragma版本(即. `^0.4.25`) 最适合使用 `0.4.26-nightly.2018.9.25`编译，但是这种方式不建议用于生产环。


> Warning
> Pragma statements can be allowed to float when a contract is intended for consumption by other developers, as in the case with contracts in a library or EthPM package. Otherwise, the developer would need to manually update the pragma in order to compile locally.
> 警告
> 当合约打算供其他开发人员使用时，可以允许Pragma版本浮动，例如库或EthPM软件包中的合约。否则，开发人员就需要手动更新编译版本以便在本地编译。


See [SWC-103](https://swcregistry.io/docs/SWC-103)
详见 [SWC-103](https://swcregistry.io/docs/SWC-103)



### Use events to monitor contract activity
### 使用events监控合约

It can be useful to have a way to monitor the contract's activity after it was deployed. One way to accomplish this is to look at all transactions of the contract, however that may be insufficient, as message calls between contracts are not recorded in the blockchain. Moreover, it shows only the input parameters, not the actual changes being made to the state. Also events could be used to trigger functions in the user interface.
合约部署后，在很多情况下都需要对其进行监控，其中一种方法是查看合约的所有交易，但如果是合约之间的消息调用没有记录在区块里，通过交易查到的数据可能不满足需求。另外，区块中的数据只能查到输入参数，而不会记录状态变量的改变前的状态。使用Event事件可以触发用户界面的功能。

```
contract Charity {
    mapping(address => uint) balances;

    function donate() payable public {
        balances[msg.sender] += msg.value;
    }
}

contract Game {
    function buyCoins() payable public {
        // 5% goes to charity
        charity.donate.value(msg.value / 20)();
    }
}
```



Here, `Game` contract will make an internal call to `Charity.donate()`. This transaction won't appear in the external transaction list of `Charity`, but only visible in the internal transactions.
上述合约中，`Game`合约内部调用了 `Charity.donate()`。该交易在`Charity`合约的交易列表中是不存在的，只在内部交易里可见。

An event is a convenient way to log something that happened in the contract. Events that were emitted stay in the blockchain along with the other contract data and they are available for future audit. Here is an improvement to the example above, using events to provide a history of the Charity's donations.
event是记录合约变化的一种便捷的方式。事件产生的日志会与其他合约数据一起存在区块链中，可供审核使用。下放代码是对上方示例的改进，使用event事件记录了捐赠记录。

```
contract Charity {
    // define event
    event LogDonate(uint _amount);

    mapping(address => uint) balances;

    function donate() payable public {
        balances[msg.sender] += msg.value;
        // emit event
        emit LogDonate(msg.value);
    }
}

contract Game {
    function buyCoins() payable public {
        // 5% goes to charity
        charity.donate.value(msg.value / 20)();
    }
}
```



Here, all transactions that go through the `Charity` contract, either directly or not, will show up in the event list of that contract along with the amount of donated money.
上述合约中，通过`Charity`合约进行交易（无论是否直接调用）都会记录在该合约的事件列表中，以及捐赠的金额。



> Note
> **Prefer newer Solidity constructs**
> Prefer constructs/aliases such as `selfdestruct` (over `suicide`) and `keccak256` (over `sha3`). Patterns like `require(msg.sender.send(1 ether))` can also be simplified to using `transfer()`, as in `msg.sender.transfer(1 ether)`. Check out [Solidity Change log](https://github.com/ethereum/solidity/blob/develop/Changelog.md) for more similar changes.

> 注意
> **优先使用新版本Solidity的结构**
> 优先使用`selfdestruct` (而不是 `suicide`) ， `keccak256` (而不是 `sha3`)类似的构造/别名。类似的模式 `require(msg.sender.send(1 ether))`可以简化为使用 `transfer()`，如`msg.sender.transfer(1 ether)`. 更新信息查看 [Solidity 更新日志](https://github.com/ethereum/solidity/blob/develop/Changelog.md)。


### Be aware that 'Built-ins' can be shadowed
### 注意，内置方法可能会被覆盖

It is currently possible to [shadow](https://en.wikipedia.org/wiki/Variable_shadowing) built-in globals in Solidity. This allows contracts to override the functionality of built-ins such as `msg` and `revert()`. Although this [is intended](https://github.com/ethereum/solidity/issues/1249), it can mislead users of a contract as to the contract's true behavior.
这是Solidity目前可能被覆盖的内置方法 [shadow](https://en.wikipedia.org/wiki/Variable_shadowing)。合约可以覆盖如 `msg` 和 `revert()`等内置方法。这种覆盖可能是[有意为之](https://github.com/ethereum/solidity/issues/1249), 但可能让合约的使用者误以为这是合约的真实行为。

```
contract PretendingToRevert {
    function revert() internal constant {}
}

contract ExampleContract is PretendingToRevert {
    function somethingBad() public {
        revert();
    }
}
```



Contract users (and auditors) should be aware of the full smart contract source code of any application they intend to use.
合约用户（和审核员）应了解他们打算使用的所有合同源代码。


### Avoid using `tx.origin`
### 避免使用`tx.origin`

Never use `tx.origin` for authorization, another contract can have a method which will call your contract (where the user has some funds for instance) and your contract will authorize that transaction as your address is in `tx.origin`.
永远不用使用`tx.origin`做身份验证，授权用户使用tx.origin变量的合约通常容易受到网络钓鱼攻击的攻击，这可能会诱骗用户在有漏洞的合约上执行身份验证操作。

```
contract MyContract {

    address owner;

    function MyContract() public {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        (bool success, ) = receiver.call.value(amount)("");
        require(success);
    }

}

contract AttackingContract {

    MyContract myContract;
    address attacker;

    function AttackingContract(address myContractAddress) public {
        myContract = MyContract(myContractAddress);
        attacker = msg.sender;
    }

    function() public {
        myContract.sendTo(attacker, msg.sender.balance);
    }

}
```



You should use `msg.sender` for authorization (if another contract calls your contract `msg.sender` will be the address of the contract and not the address of the user who called the contract).
应该使用`msg.sender`来做身份验证（如果其它合约你得合约时，`msg.sender`为其他合约地址，而不是调用的用户地址）。

You can read more about it here: [Solidity docs](https://solidity.readthedocs.io/en/develop/security-considerations.html#tx-origin)
更多信息详见：[Solidity 文档](https://solidity.readthedocs.io/en/develop/security-considerations.html#tx-origin)


> Warning
> Besides the issue with authorization, there is a chance that `tx.origin` will be removed from the Ethereum protocol in the future, so code that uses `tx.origin` won't be compatible with future releases [Vitalik: 'Do NOT assume that tx.origin will continue to be usable or meaningful.'](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof/200#200)

> 警告
> 除了身份验证问题，`tx.origin`未来可能从以太坊协议中删除，如果使用`tx.origin`可能会造成未来的不兼容。[Vitalik: 'Do NOT assume that tx.origin will continue to be usable or meaningful.'](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof/200#200)


It's also worth mentioning that by using `tx.origin` you're limiting interoperability between contracts because the contract that uses tx.origin cannot be used by another contract as a contract can't be the `tx.origin`.
还需要注意的是，不能使用`tx.origin`来限制合约之间的互操作，因为使用`tx.origin`的合约不能被另一个合约使用。

See [SWC-115](https://swcregistry.io/docs/SWC-115)
详见 [SWC-115](https://swcregistry.io/docs/SWC-115)



### Timestamp Dependence
### 对时间戳的依赖

There are three main considerations when using a timestamp to execute a critical function in a contract, especially when actions involve fund transfer.
在合约中使用时间戳时，需要注意三个方面，特别是在涉及资金转移时。

#### Timestamp Manipulation
### 时间戳可被操控

Be aware that the timestamp of the block can be manipulated by a miner. Consider this [contract](https://etherscan.io/address/0xcac337492149bdb66b088bf5914bedfbf78ccc18#code):
矿工可以操控区块的打包时间，请看下方[合约](https://etherscan.io/address/0xcac337492149bdb66b088bf5914bedfbf78ccc18#code):

```
uint256 constant private salt =  block.timestamp;

function random(uint Max) constant private returns (uint256 result){
    // 为随机性获得最佳种子
    uint256 x = salt * 100/Max;
    uint256 y = salt * block.number/(salt % 5) ;
    uint256 seed = block.number/3 + (salt % 300) + Last_Payout + y;
    uint256 h = uint256(block.blockhash(seed));

    return uint256((h / x)) % Max + 1; //介于1到最大之间的随机数
}
```



When the contract uses the timestamp to seed a random number, the miner can actually post a timestamp within 15 seconds of the block being validated, effectively allowing the miner to precompute an option more favorable to their chances in the lottery. Timestamps are not random and should not be used in that context.
当合约使用时间戳作为随机数的种子时，矿工可以在区块通过验证后的15s内发布时间戳，从而使得矿工可以预先计算出对自己有利结果。时间戳不是随机的，不应该在上下文中使用。

#### The 15-second Rule
### 15秒规则

The [Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) (Ethereum's reference specification) does not specify a constraint on how much blocks can drift in time, but [it does specify](https://ethereum.stackexchange.com/a/5926/46821) that each timestamp should be bigger than the timestamp of its parent. Popular Ethereum protocol implementations [Geth](https://github.com/ethereum/go-ethereum/blob/4e474c74dc2ac1d26b339c32064d0bac98775e77/consensus/ethash/consensus.go#L45) and [Parity](https://github.com/paritytech/parity-ethereum/blob/73db5dda8c0109bb6bc1392624875078f973be14/ethcore/src/verification/verification.rs#L296-L307) both reject blocks with timestamp more than 15 seconds in future. Therefore, a good rule of thumb in evaluating timestamp usage is:
[以太坊黄皮书](https://ethereum.github.io/yellowpaper/paper.pdf)只规定下个区块的时间需要比上一个，但[没有规定区块间隔时间区间](https://ethereum.stackexchange.com/a/5926/46821) 。以太坊客户端 [Geth](https://github.com/ethereum/go-ethereum/blob/4e474c74dc2ac1d26b339c32064d0bac98775e77/consensus/ethash/consensus.go#L45) 和 [Parity](https://github.com/paritytech/parity-ethereum/blob/73db5dda8c0109bb6bc1392624875078f973be14/ethcore/src/verification/verification.rs#L296-L307)都拒绝时间戳超过15秒的块。因此评估时间戳使用情况一个比较好的方法是：


> Note
> If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a `block.timestamp`.

> 注意
> 如果与时间有关的事件的每次触发可以相差15秒并保持完整性，则可以安全地使用`block.timestamp`。


#### Avoid using `block.number` as a timestamp
### 避免使用`block.number` 作为时间戳

It is possible to estimate a time delta using the `block.number` property and [average block time](https://etherscan.io/chart/blocktime), however this is not future proof as block times may change (such as [fork reorganisations](https://blog.ethereum.org/2015/08/08/chain-reorganisation-depth-expectations/) and the [difficulty bomb](https://github.com/ethereum/EIPs/issues/649)). In a sale spanning days, the 15-second rule allows one to achieve a more reliable estimate of time.
通过`block.number`属性和[平均区块时间](https://etherscan.io/chart/blocktime)可以评估区块的时间，但这种方法并不可靠，因为区块时间可能改变（例如[分叉重组](https://blog.ethereum.org/2015/08/08/chain-reorganisation-depth-expectations/) 和 [难度炸弹](https://github.com/ethereum/EIPs/issues/649))。在未来几天的时间内，使用15秒的规则来预估出块时间会更可靠。

See [SWC-116](https://swcregistry.io/docs/SWC-116)
详见 [SWC-116](https://swcregistry.io/docs/SWC-116)



### Multiple Inheritance Caution
### 慎用多重继承

When utilizing multiple inheritance in Solidity, it is important to understand how the compiler composes the inheritance graph.
在Solidity中使用多重继承时，了解编译器如何构造继承图谱非常重要。

```
contract Final {
    uint public a;
    function Final(uint f) public {
        a = f;
    }
}

contract B is Final {
    int public fee;

    function B(uint f) Final(f) public {
    }
    function setFee() public {
        fee = 3;
    }
}

contract C is Final {
    int public fee;

    function C(uint f) Final(f) public {
    }
    function setFee() public {
        fee = 5;
    }
}

contract A is B, C {
  function A() public B(3) C(5) {
      setFee();
  }
}
```



When a contract is deployed, the compiler will *linearize* the inheritance from right to left (after the keyword *is* the parents are listed from the most base-like to the most derived). Here is contract A's linearization:
合约被部署时，按照从右到左的顺序线性继承(在关键字 *is*之后，从最高层父类到子类)。合约A的继承顺序：

**Final <- B <- C <- A**
**Final <- B <- C <- A**

The consequence of the linearization will yield a fee value of 5, since C is the most derived contract. This may seem obvious, but imagine scenarios where C is able to shadow crucial functions, reorder boolean clauses, and cause the developer to write exploitable contracts. Static analysis currently does not raise issue with overshadowed functions, so it must be manually inspected.
示例合约中最终fee的值是5。开发人员可以通过对布尔类型的排序，可以隐藏子合约中一些关键信息。对于这种多重继承，需要仔细检查。

For more on security and inheritance, check out this article
有关安全性和继承的更多信息，请查看本文。

To help contribute, Solidity's Github has a project with all inheritance-related issues.
如需贡献，Solidity在Github有一个涉及继承有关的问题项。

See [SWC-125](https://swcregistry.io/docs/SWC-125)
详见 [SWC-125](https://swcregistry.io/docs/SWC-125)

### Use interface type instead of the address for type safety
### 使用接口类型代替地址以确保安全

When a function takes a contract address as an argument, it is better to pass an interface or contract type rather than raw address. If the function is called elsewhere within the source code, the compiler it will provide additional type safety guarantees.
当函数将合同地址作为参数时，最好传递接口或合约类型，而不是地址类型。如果该函数在源代码中的其他位置调用，则编译器将提供其他类型安全保证。

Here we see two alternatives:
下方代码给出了两种方式：

```
contract Validator {
    function validate(uint) external returns(bool);
}

contract TypeSafeAuction {
    // good
    function validateBet(Validator _validator, uint _value) internal returns(bool) {
        bool valid = _validator.validate(_value);
        return valid;
    }
}

contract TypeUnsafeAuction {
    // bad
    function validateBet(address _addr, uint _value) internal returns(bool) {
        Validator validator = Validator(_addr);
        bool valid = validator.validate(_value);
        return valid;
    }
}
```


The benefits of using the `TypeSafeAuction` contract above can then be seen from the following example. If `validateBet()` is called with an `address` argument, or a contract type other than `Validator`, the compiler will throw this error:
从下面的示例中可以看出上方合约`TypeSafeAuction`的好处。如果方法`validateBet()` 不是使用合约 `Validator`类型作为参数调用，则编译器将抛出以下错误：

```
contract NonValidator{}

contract Auction is TypeSafeAuction {
    NonValidator nonValidator;

    function bet(uint _value) {
        bool valid = validateBet(nonValidator, _value); // TypeError: Invalid type for argument in function call.
                                                        // Invalid implicit conversion from contract NonValidator
                                                        // to contract Validator requested.
    }
}
```




### Avoid using `extcodesize` to check for Externally Owned Accounts
### 避免使用`extcodesize`检查是否为外部帐户

The following modifier (or a similar check) is often used to verify whether a call was made from an externally owned account (EOA) or a contract account:
通常使用以下修饰符（或类似的检查）来验证是从外部帐户（EOA）还是合约帐户进行请求：

```
// bad
modifier isNotContract(address _a) {
  uint size;
  assembly {
    size := extcodesize(_a)
  }
    require(size == 0);
     _;
}
```



The idea is straight forward: if an address contains code, it's not an EOA but a contract account. However, **a contract does not have source code available during construction**. This means that while the constructor is running, it can make calls to other contracts, but `extcodesize` for its address returns zero. Below is a minimal example that shows how this check can be circumvented:
这个想法很简单：如果一个地址包含代码，则它不是EOA，而是合约帐户。但是**合约在构造期间没有源代码**。使用`extcodesize`来检查合约地址会返回0.下面示例，展示了如何规避此检查：

```
contract OnlyForEOA {    
    uint public flag;

    // bad
    modifier isNotContract(address _a){
        uint len;
        assembly { len := extcodesize(_a) }
        require(len == 0);
        _;
    }

    function setFlag(uint i) public isNotContract(msg.sender){
        flag = i;
    }
}

contract FakeEOA {
    constructor(address _a) public {
        OnlyForEOA c = OnlyForEOA(_a);
        c.setFlag(1);
    }
}
```



Because contract addresses can be pre-computed, this check could also fail if it checks an address which is empty at block `n`, but which has a contract deployed to it at some block greater than `n`.
由于合约地址可以预先计算，所以在某个区块中，对该地址的检查可能会失败。


> Warning
> This issue is nuanced.
> If your goal is to prevent other contracts from being able to call your contract, the `extcodesize` check is probably sufficient. An alternative approach is to check the value of `(tx.origin == msg.sender)`, though this also [has drawbacks](../recommendations/#avoid-using-txorigin).
> There may be other situations in which the `extcodesize` check serves your purpose. Describing all of them here is out of scope. Understand the underlying behaviors of the EVM and use your Judgement.

> 警告
> 这是一个比较细小的问题。
> 如果只是为了防止其他合约能够调用您的合同，那么使用`extcodesize`来检查足矣。还有一种替代方法是检查`（tx.origin == msg.sender）`的值，这种方式[也有自己的缺点]（../ recommendations /＃avoid-using-txorigin）。
> 在其他情况下，`extcodesize`检查可以满足需求。可以了解EVM的基本原理来判断。

## Deprecated/historical recommendations
## 过时的/历史的 建议

These are recommendations which are no longer relevant due to changes in the protocol or improvements to solidity. They are recorded here for posterity and awareness.
以下这些建议由于协议的更改或solidity版本升级而不再相关。在此仅作记录。

### Beware division by zero (Solidity < 0.4)
### 小心被0除 (Solidity < 0.4)

Prior to version 0.4, Solidity returns zero and does not throw an exception when a number is divided by zero. Ensure you're running at least version 0.4.
在Solidity0.4版本之前，除0返回零而不是引发异常。确保您至少运行版本0.4。

### Differentiate functions and events (Solidity < 0.4.21)
### 区分functions和events (Solidity < 0.4.21)

Favor capitalization and a prefix in front of events (we suggest Log), to prevent the risk of confusion between functions and events. For functions, always start with a lowercase letter, except for the constructor.
在events中建议使用大写字母和添加前缀（建议使用Log），以防止functions和events之间混淆的风险。对于functions，除构造函数外，始终以小写字母开头。

> Note
> In [v0.4.21](https://github.com/ethereum/solidity/blob/develop/Changelog.md#0421-2018-03-07) Solidity introduced the `emit` keyword to indicate an event `emit EventName();`. As of 0.5.0, it is required.

> 注意
> Solidity在[v0.4.21]（https://github.com/ethereum/solidity/blob/develop/Changelog.md#0421-2018-03-07）版本中，引入了`emit`关键字来提交事件`emit EventName();`。从0.5.0开始，为必需的使用方式。