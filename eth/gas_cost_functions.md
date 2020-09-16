
# Gas Cost of Solidity Functions


This article discusses the (sometimes surprising) cost of using contract and library functions in Solidity, the defacto smart contract language for the Ethereum blockchain.

![](https://img.learnblockchain.cn/2020/09/14/16000518790344.jpg)
<center>Photo by [chuttersnap](https://unsplash.com/@chuttersnap?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com?utm_source=medium&utm_medium=referral)</center>


# Background

During development of Datona Labs’ Identity contract templates, we wanted to provide helpful error messages, which required string operations such as concatenation, for example:

```
function TransferTo(address _address, uint amount) public onlyOwner {
    require(amount <= unallocated, concat("Invalid amount. "
        "Available:", stringOfUint(unallocated)));
    // whatever
}
```

String concatenation is facilitated by the Solidity compiler using:

```
string memory result = string(abi.encodePacked("trust", "worthy"))
```

But we would like to wrap that with a more meaningful name and include it with other useful string utility functions such as string of integer.

Of course we want to use as little gas (few cycles) as possible because blockchain languages like Solidity are very expensive to run compared with normal systems and the gas actually costs a measurable amount of money.

# Linkage Options

For adding the string concatenation feature, which is a simple ‘pure’ function which does not access state information, Solidity smart contracts provide the following linkage options:

```
(1) As facilitated by the compiler, i.e. abi.encodePacked
(2) Inherited from a base contract with internal (direct) call
(3) Inherited from a base contract with external (indirect) call
(4) Accessed from a component contract with external (indirect) call
(5) Accessed from a library contract with internal (direct) call
(6) Accessed from a library contract with external (indirect) call
```

It is not possible to access a component contract with internal (direct) calls.

See [https://solidity.readthedocs.io/en/latest/contracts.html#creating-contracts](https://solidity.readthedocs.io/en/latest/contracts.html#creating-contracts) and the subsequent section on libraries for descriptions of the possible linkage options.

The following sections illustrate the implementation of the different linkage options.

## (2) and (3) Inheriting from a Base contract

The base contract can provide the internal and external (classified as public below) string concatenation functions as follows:

```
contract Base {
    function Internal(string memory sm0, string memory sm1) 
        internal pure returns (string memory)
    {
        return string(abi.encodePacked(sm0, sm1));
    }
    function External(string memory sm0, string memory sm1)
        public pure returns (string memory)
    {
        return string(abi.encodePacked(sm0, sm1));
    }
}
```

*The unusual function names are artificial and just for the purposes of this article. Each of the functions performs string concatenation, it is the performance of the different linkage options that we are interested in.*

This must be specified as an inherited contract to enable use of its functions:

```
contract MyContract is Base {
    // whatever
}
```

The functions may be accessed using dot notation, or the base contract name may be omitted (your company’s coding standards document may have something to say about this) :

```
    string memory sm = Base.Internal("pass", "word");
    string memory xx = Internal("what", "ever");
```

## (4) Accessing a Component contract

The component contract is declared as a component of the contract, and must be created at declaration or in the constructor:

```
contract Component is Base {
    // inherit the base functions
}
contract MyContract is whatever {
    Component component = new Component();
    // whatever
}
```

The functions must be accessed using dot notation:

```
string memory sm = component.Internal("mean", "while");
```

## (5) and (6) Accessing a Library contract

The library contract is very similar to a normal contract apart from the library contract type:

```
library Library {
    // the same functions as the Base contract
    // (library contracts cannot inherit from other contracts)
}
```

It is normally held in its own file and used by being imported at the head of a contract file:

```
import "Library.sol"; // provides Internal, External string concat
```

The functions must be accessed using dot notation:

```
    string memory sm = Library.Internal("key", "board");
```

## Measuring Gas Cost

In order to determine how much gas (many cycles) of the EVM (Ethereum virtual machine) each option takes, we need to measure them.

There are many useful blockchain features such as a system function called gasleft() that reports how much gas is left for the running contract, and it is also possible to pass functions to other functions. We can use these features to provide a function that will measure the gas cost of a given function, **fun**:

```
function GasCost(string memory name, 
    function () internal returns (string memory) fun) 
    internal returns (string memory) 
{
    uint u0 = gasleft();
    string memory sm = fun();
    uint u1 = gasleft();
    uint diff = u0 - u1;
    return concat(name, " GasCost: ", stringOfUint(diff), 
                " returns(", sm, ")");
}
```

Since the functions we are measuring use different linkage, it is necessary to invoke the function under test with a small internal wrapper function. We can measure the overhead of that facility and subtract the overhead gas cost from the measured function gas cost.

```
function AbiEncode() internal pure returns (string memory) {
    // (1) As facilitated by the compiler
    string memory sm0 = "0"; 
    string memory sm1 = "1"; 
    return string(abi.encodePacked(sm0, sm1));
}
function BaseInternal() internal pure returns (string memory) {
    // (2) Inherited from a base contract with internal call
    string memory sm0 = "0"; 
    string memory sm1 = "1"; 
    return Base.Internal(sm0, sm1);
}
// and in a similar manner for:
    // (3) Inherited from a base contract with external call
    return Base.External(sm0, sm1);
    // (4) Accessed from a component contract with external call
    return component.External(sm0, sm1);
    // (5) Accessed from a library contract with internal call
    return Library.Internal(sm0, sm1);
    // (6) Accessed from a library contract with external call
    return Library.External(sm0, sm1);
```

Now we just need to collect the gas costs of each linkage method and report them:

```
string report;
    
function CreateReport() public returns (string memory s) {
    s = concat(s, GasCost("AbiEncode ", AbiEncode));
    s = concat(s, GasCost("BaseInternal ", BaseInternal));
    s = concat(s, GasCost("BaseExternal ", BaseExternal));
    s = concat(s, GasCost("ComponentExternal ", ComponentExternal));
    s = concat(s, GasCost("LibraryInternal ", LibraryInternal));
    s = concat(s, GasCost("LibraryExternal ", LibraryExternal));
    report = s;
}
    
function ViewReport() public view returns (string memory) {
    return report;
}
```
The report variable and the ViewReport function are not necessary but they will enable us to easily see the output in the Remix deployment window.

We can then copy the results to a spreadsheet and produce a graph like the one below.

Here is a table of the results using Remix v0.10.1, Solidity compiler v0.6.8:

![](https://img.learnblockchain.cn/2020/09/14/16000523505116.jpg)
<center>Gas Costs for string concat using different Linkage Options</center>


Note that all methods of calling an internal base contract or library function (2), (3) and (5) consume substantially the same amount of gas, and only marginally more than the inline code (1) and the optimised versions unusually using slightly more gas than their unoptimised counterparts. The code of both base contracts and internal library functions will be included in the bytecode for your contract in these cases.

Also, it appears that the Solidity compiler is smart enough to call an external base class function using a direct call rather than a contract call (3).

The gas usage of these direct functions is dwarfed by the gas usage of external calls, either to a component contractor (4) or to a library (6).

# Conclusions

Use any of the internal calling methods. We prefer internal library calls, because of the associated class features (see [Class Features of Solidity](/coinmonks/class-features-provided-by-solidity-84ee97840666) by the same author).

Using an external call to a public library function is very expensive, and will only be worth it to avoid including a lot of code into the bytecode for your contract.

Using a local contract component is the most expensive option and should be avoided unless essential.

# Bio

Jules Goddard is Co-founder of Datona Labs, who provide smart contracts to protect your digital information from abuse.

原文链接：https://medium.com/coinmonks/gas-cost-of-solidity-library-functions-dbe0cedd4678 作者：[Jules Goddard](https://medium.com/@plaxion)