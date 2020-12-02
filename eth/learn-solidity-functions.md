> * 来源：https://medium.com/better-programming/learn-solidity-functions-ddd8ea24c00d 作者：[wissal haji](https://wissal-haji.medium.com/?source=post_page-----ddd8ea24c00d--------------------------------)


# Learn Solidity: Functions



## How to use functions in Solidity


![Photo by [Kelly Sikkema](https://unsplash.com/@kellysikkema?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)](https://img.learnblockchain.cn/2020/12/02/16068721030077.jpg)

Welcome to another article in the Learn Solidity series, in the [previous article](/better-programming/learn-solidity-variables-part-3-3b02ca71cf06) we concluded with variables, and today I will introduce you to functions and modifiers, which will give you by the end of this article all the pieces to build a multisignature wallet as we will see in the practice section.



Functions in Solidity have the following form :

```
function function_name(<param_type> <param_name>) <visibility> <state mutability> [returns(<return_type>)]{ ... }
```


## Return Variables

A function can return an arbitrary number of values as output. There are two ways to return variables from functions:

**1. Using names of the return variables:**

```
function arithmetic(uint _a, uint _b) public pure
        returns (uint o_sum, uint o_product)
    {
        o_sum = _a + _b;
        o_product = _a * _b;
    }
```

**2. Provide return values directly with the return statement:**

```
function arithmetic(uint _a, uint _b) public pure
        returns (uint o_sum, uint o_product)
    {
        return (_a + _b, _a * _b);
    }
```

With the second approach, you can omit the names of the return variables and specify only their types.

### Supported parameters and return types

In order to call a smart contract function, we need to use the ABI (Application binary interface) specifications in order to specify the function to be called and encode the parameters, which will be included in the data field of the transaction and send it to the Ethereum network to be executed.
ABI encoding is also used for events and return types, more details can be found in [the documentation](https://docs.soliditylang.org/en/v0.7.5/abi-spec.html#contract-abi-specification).

The first version of the ABI encoder didn’t support all the types we have seen in previous articles, for example, we can’t return structs from a function, if you try to do so you will get an error, that’s why we need to use version 2 of the ABI encoder in order to make the error disappear by including the following line in the file: `pragma abicoder v2;` if you are using Solidity version: 0.7.5\. And for the versions below 0.7.5 we need to use the experimental version: `pragma experimental ABIEncoderV2;`

Here is an example from the Solidity documentation for version: 0.7.5.

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.7.4;
pragma abicoder v2;

contract Test {
    struct S { uint a; uint[] b; T[] c; }
    struct T { uint x; uint y; }
    function f(S memory, T memory, uint) public pure {}
    function g() public pure returns (S memory, T memory, uint) {}
}
```

A full list of supported ABI types can be found in [this part of the documentation](https://docs.soliditylang.org/en/v0.7.5/abi-spec.html#types).



## Visibility

There are four types of visibility for functions:

* **Private**: The most restrictive one, the function can only be called from within the smart contract where it’s defined.
* **Internal**: The function can be called from within the smart contract where it’s defined and all smart contracts that inherit from it.
* **External**: Can only be called from outside the smart contract. (Must use this if you want to call it from within the smart contract.)
* **Public**: Can be called from anywhere. (The most permissive one)


## State mutability

* **view**: Functions declared with `view` can only read the state, but do not modify it.
* **pure**: Functions declared with `pure` can neither read nor modify the state.
* **payable**: Functions declared with `payable` can accept Ether sent to the contract, if it’s not specified, the function will automatically reject all Ether sent to it.

```
contract SimpleStorage {
     uint256 private data;
     function getData() external view returns(uint256) {
         return data;
     }
     function setData(uint256 _data) external {
        data = _data;
    }
}
```

You can find what read the state means [here](https://solidity.readthedocs.io/en/v0.7.4/contracts.html#pure-functions), and write to state means in details [here](https://solidity.readthedocs.io/en/v0.7.4/contracts.html#view-functions).

### Transactions vs calls

Functions defined with `view` and `pure` keywords do not change the state of the Ethereum blockchain, which means when you call these functions you won’t be sending any transaction to the blockchain since transactions are defined as state transition functions that take the blockchain from one state to another. What happens instead is that the node you are connected to executes the code of the function locally by inspecting its own version of the blockchain and gives the result back without broadcasting any transaction to the Ethereum network.

In this section, we will see some special functions that you can use.

## Getter Function

State variables defined as public have a getter function that is automatically created by the compiler. The function has the same name as the variable and has external visibility.

```
contract C {
    uint public data;
    function x() public returns (uint) {
        data = 3; // internal access
        return this.data(); // external access
    }
}
```

## Receive Ether Function

A contract can have at most one `receive` function. This function cannot have arguments, cannot return anything, and must have `external` visibility and `payable` state mutability.

It is executed on a call to the contract that sends Ether and does not specify any function (empty call data). This is the function that is executed on plain Ether transfers (e.g. via `.send()` or `.transfer()`).
This function is declared as follows:

```
receive() external payable {
   ...
}
```

## Fallback Function

A contract can have at most one `fallback` function. This function cannot have arguments, cannot return anything, and must have `external` visibility. It is executed on a call to the contract if **none of the other functions match the given function signature**, or if **no data was supplied at all** and there is **no receive Ether function**.
You can declare such a function as follows:

```
fallback() external [payable]{
     ...
}
```

> “Contracts that receive ether directly without a function call througnt `send` or `transfer` and does not define a `receive` function or a payable fallback function will throw an exeption sending the ether back.” — [Solidity documentation](https://docs.soliditylang.org/en/v0.7.5/abi-spec.html#contract-abi-specification)

Try it on your own in Remix by creating a contract without `receive` or `payable fallback` and send some ether to it. You should see a message that looks like this after clicking on **Transact**.


![Example message](https://img.learnblockchain.cn/2020/12/02/16068738092811.jpg)

## Function Modifier

Modifiers are needed when you want to check some condition prior to a function execution. For example, if you want to check if the sender is the owner of the contract you can write something like:

```
function selectWinner() external {
    require(msg.sender == owner, "this function is restricted to the owner);
    ...
}
```

With modifiers, we can isolate this code so that we can reuse it with other functions, we need only to declare a modifier as follows:

```
modifier onlyOwner(){
   require(msg.sender == owner, "this function is restricted to the owner);
  _; // will be replaced by the code of the function
}
```

And we add the modifier name to the function:

```
function selectWinner() external onlyOwner {
   
    ...
}
```

Multiple modifiers are applied to a function by specifying them in a whitespace-separated list and are evaluated in the order presented.



## Exercise: Multisig Wallet

In this exercise we will build a smart contract for a mulisignature wallet:
A multisignature wallet is a wallet where multiple keys are required in order to authorize a transaction. More on this type of wallet and its use cases can be found in the [bitcoin documentation](https://en.bitcoin.it/wiki/Multisignature).

The first thing we need is the list of the approvers and the quorum required for authorizing the transaction (the minimum number of users required, if we have a two of three multisig wallet this means that the quorum is two).
You need also to create a struct to record the information related to a transfer, including the amount to be paid, the recipient, the number of approvers that already approved the transfer, and its state (if it is sent or still waiting for the confirmations of approvers).

The process goes as follows: One of the approvers will create the transfer, the transfer will be saved on the storage of the smart contract waiting for other approvers confirmations, once the required number of confirmations is achieved the ether is transferred to the recipient.

The solution can be found [here](https://gist.github.com/wissalHaji/3bd5e5c0573618f9e284971abe2af1aa) on Github.


That’s it for functions in Solidity, I hope that this article was useful for you.
We still have a lot to discover in Solidity: interaction between smart contracts, inheritance, events and exception handling, deployment to a public testnet and the list goes on. So as usual, if you want to learn more just stay tuned for the upcoming articles.









