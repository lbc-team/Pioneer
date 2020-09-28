
# 8 Ways of Reducing the Gas Consumption of your Smart Contracts

I am currently working on a Dapp project ([Shape](https://medium.com/u/f4b3a95f66b7?source=post_page-----9a506b339c0a--------------------------------)) whose first major development phase is now nearing its end. Since transaction costs are always a big concern for developers, I want to use this article to share some of the insights I gained throughout the past couple of weeks/months in this area in terms of optimization.

![](https://img.learnblockchain.cn/2020/09/28/16012790295397.jpg)
<center>“closeup photo of 100 US dollar banknotes” by [Pepi Stojanovski](https://unsplash.com/@timbatec?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com?utm_source=medium&utm_medium=referral)</center>

Below, I present a list of optimization techniques, some of which with references to more detailed articles on the subject, you can apply to your contract design. I will start with a few more basic, rather familiar concepts and then get more complex as we proceed.


## 1\. Preferred data types

This can be answered in just a few words: **Use 256 bit variables**, ergo uint256 and bytes32! This may seem a little bit counter-intuitive at first but when you think more closely about how the Ethereum Virtual Machine (EVM) operates it completely makes sense. Each storage slot has 256 bits. Hence, if you are storing just a uint8, the EVM will fill up all the missing digits with zeros — this costs gas. Furthermore, calculations are also unexceptionally performed in uint256 by the EVM so that here any type other than uint256 will have to be converted as well.

Note: In general, you should aim to size your variables such that whole storage slots are filled. In the section “*Packing variables into a single slot through the SOLC”* it will become more clear when it makes sense to be using variables with less than 256 bits.


## 2\. Storing values in the contract’s bytecode

A comparatively cheap way of storing and reading information is by directly including them into the bytecode of the smart contract, when deploying it on the blockchain. The downside here is that the value cannot be altered afterwards. However, gas consumption for both loading and storing data will be considerably reduced. There are two possible ways of implementing this:

1. Attach the keyword *constant* to the variable declaration
2. Hardcode the variable wherever you want to use it.

```
uint256 public v1;
uint256 public constant v2;
function calculate() returns (uint256 result) {
    return v1 * v2 * 10000
}
```

The variable *v1* will be part of the contract state whereas *v2* and also *1000* are part of the contract’s bytecode.

*(Reading v1 is performed through the SLOAD operation which already costs 200 gas alone.)*


## 3\. Packing variables into a single slot through the SOLC

When you are storing data permanently on the blockchain, in order to do so the assembly command SSTORE is executed in the background. This is the most expensive command with a cost of 20,000 gas so we should try to use it as little as possible. Inside structs, the amount of SSTORE operations performed can be reduced by simply rearranging the variables as in the following example:

```
struct Data {
    uint64 a;
    uint64 b;
    uint128 c;
    uint256 d;
}
Data public data;
constructor(uint64 _a, uint64 _b, uint128 _c, uint256 _d) public {
    Data.a = _a;
    Data.b = _b;
    Data.c = _c;
    Data.d = _d;
}
```

Notice here that within the struct all variables which can, in sum, fill a 256 bit slot are ordered adjacent to each other so that the compiler can later stack them together (This also works if the variables cover less than 256 bits). In this particular example, the SSTORE operation will only be used twice, once for storing *a*,*b* and *c* and another time for storing *d*. The same also applies to variables outside of structs. Also, keep in mind that the savings from putting multiple variables into the same slot are much more substantial than the ones achieved by filling up the entire slot (Preferred data types).

*Note: Remember to activate optimization for the SOLC*

## 4\. Packing variables into a single slot with assembly

The technique of stacking variables together so that there are less SSTORE operations to be executed can also be applied manually. The following code will stack 4 variables of type uint64 together into one single 256 bit slot.

**Encoding: Merging variables into one.**

```
function encode(uint64 _a, uint64 _b, uint64 _c, uint64 _d) internal pure returns (bytes32 x) {
    assembly {
        let y := 0
        mstore(0x20, _d)
        mstore(0x18, _c)
        mstore(0x10, _b)
        mstore(0x8, _a)
        x := mload(0x20)
    }
}
```

For reading, the variable will need to be decoded which can be realized with this second function.

**Decoding: Splitting a variable into its initial parts.**

```
function decode(bytes32 x) internal pure returns (uint64 a, uint64 b, uint64 c, uint64 d) {
    assembly {
        d := x
        mstore(0x18, x)
        a := mload(0)
        mstore(0x10, x)
        b := mload(0)
        mstore(0x8, x)
        c := mload(0)
    }
}
```

Comparing the gas consumption of this method and the one from above, you will notice that this one is significantly cheaper for a number of reasons:

1. **Precision:** with this approach, you can do pretty much anything in terms of bit packing. For instance, if you already know, that you will not need the last bit of a variable, you can easily optimize by adding a one bit variable your are using in conjunction with the 256 bit variable.
2. **Read once:** Since your variables are actually stored together in a single slot, you will only need to perform one loading operation to receive all variables. This is especially beneficial if the variables will be used in conjunction.

So, why even use the prior one? Looking at both implementations, it becomes clear that we are also giving up on readability by using assembly for *en-* and *decoding* our variables, hence, making this second approach much more prone to errors. Also, since we will have to include *en*- and *decoding* functions for each specific case, the deployment cost will also rise significantly. Nevertheless, if you really need to get the gas consumption of your functions down, this is the way to go! (The more variables you are packing into a single slot, the higher your savings will be, compared to the other method.)

## 5\. Concatenating function parameters

Just like you can use the *en-* and *decode* function from above for optimizing the process of reading and storing data, you can also use them for concatenate the parameters of a function-call in order to reduce call-data load. Even though this causes the execution cost of your transaction to increase slightly, the base fee will be reduced such that in sum, you are coming off cheaper.

This article is comparing two function calls, one with and the other without this technique (bit-compaction) and perfectly illustrates, what is actually happening under the hood here:

[Techniques to Cut Gas Costs for Your Dapps](https://medium.com/coinmonks/techniques-to-cut-gas-costs-for-your-dapps-7e8628c56fc9)

## 6\. Merkle proofs for reduced storage load

In a nutshell, a merkle proof uses a single chunk of data in order to prove the validity of a much larger amount of data.

If you are unfamiliar with the idea behind merkle proofs, check out these articles first in order to get a basic understanding:

[Ever Wonder How Merkle Trees Work?](https://media.consensys.net/ever-wonder-how-merkle-trees-work-c2f8b7100ed3)

[Merkle proofs Explained.](/crypto-0-nite/merkle-proofs-explained-6dd429623dc5)

The benefits which come along with merkle proofs are truly amazing. Let’s look at an example:

Assuming we want to save a purchase transaction for a car, containing all, say, 32 configurations, ordered. Creating a struct with 32 variables, one for each configuration is very expensive! This is where merkle proofs come in:

1. First, we look at, which information will be requested together and group the 32 attributes accordingly. Suppose we found 4 groups, each containing 8 configurations in order to keep things simple.
2. Now, we create a hash for each of the 4 groups from the data inside them and group these again according to the previous criterium.
3. We will repeat this until there is only one hash left, the merkle-root (hash1234).

![](https://img.learnblockchain.cn/2020/09/28/16012794719133.jpg)
<center>Merkle-Tree for Car-Example</center>

The reason why we are grouping them, depending on whether two elements will be used at the same time or not is because for each verification all elements of that branch (colored in diagram) are required and also automatically verified. This means, that only one verification process is necessary. For instance:

![](https://img.learnblockchain.cn/2020/09/28/16012795687657.jpg)
<center>Merkle-Proof for the pink Element</center>

All we had to store on the chain here is the merkle-root, usually a 256 bit variable (keccak256) and yet, assuming the car manufacturer sends you a car in a wrong color, you can easily prove that this is not the car you ordered.

```
bytes32 public merkleRoot;

//Let a,...,h be the orange base blocks
function check
(
    bytes32 hash4,
    bytes32 hash12,
    uint256 a,
    uint32 b,
    bytes32 c,
    string d,
    string e,
    bool f,
    uint256 g,
    uint256 h
)
    public view returns (bool success)
{
    bytes32 hash3 = keccak256(abi.encodePacked(a, b, c, d, e, f, g, h));
    bytes32 hash34 = keccak256(abi.encodePacked(hash3, hash4));
    require(keccak256(abi.encodePacked(hash12, hash34)) == merkleRoot, "Wrong Element");

    return true;
}
```

Keep in Mind: If a certain variable will have to be accessed very frequently or be altered from time to time, it might make more sense to just store this particular value in the conventional way. Also, watch out that your branches are not getting too big because otherwise you will exceed the amount of stack slots available for this transaction.
 
## 7\. Stateless contracts

Stateless contracts take advantage of the fact that things like transaction data and event calls are fully saved on the blockchain. Therefore, instead of constantly changing the contract’s state, all you need to do is send a transaction and pass along the value you want to store. Since the SSTORE operation usually accounts for most of the transaction costs, stateless contracts will only consume a fraction in gas of what stateful contracts do. The following article perfectly explains the concept behind stateless contracts and how to create one and its back-end counterpart.

[Stateless Smart Contracts](/@childsmaidment/stateless-smart-contracts-21830b0cd1b6)

Applying this to our car example from above, we would send one or two transactions, depending on whether we can concatenate the function paramenters or not *(5\. Concatenating function parameters)*, to which we pass along the 32 configurations of our car. As long as we only need to verify the information from the outside, this works fine and is even slightly cheaper than a merkle proof. However, on the other hand, accessing these information from within the contract is virtually impossible with this design without making sacrifices in terms of centralization, cost or user experience.


## 8\. Storing data on IPFS

The IPFS network is a decentralized data storage where each file is not identified through a URL but through a hash of its contents. The advantage here is that the hash cannot be altered, hence, one particular hash will always point to the same file. Thus, we can just broadcast our data to the IPFS network and then save the respective hash in our contract to reference the information at a later point. A more detailed explanation of how this works can be found in this article:

[Off-Chain Data Storage: Ethereum & IPFS](/@didil/off-chain-data-storage-ethereum-ipfs-570e030432cf)

Just like stateless contracts, this method does not really allow for actually using the data inside your smart contract (possible with Oracles). Still, especially if you are looking to store particularly large amounts of data such as videos, this approach is by far the best way to do it. (On a side note: Swarm, a different decentralized storage system, might also be worth taking a look at as an alternative to IPFS.)

Since the use cases of 6, 7 and 8 are fairly similar, here is a sum up for when to use which:

* **Merkle-trees:** Small to mid-sized data. / Data can be used inside the contract. / Altering data is rather complex.
* **Stateless contracts:** Small to mid-sized data. / Data cannot be used inside the contract. / Data can be altered.
* **IPFS:** Large amounts of data. / Using data inside the contract is quite cumbersome / Altering data is rather complex.

原文链接：https://medium.com/coinmonks/8-ways-of-reducing-the-gas-consumption-of-your-smart-contracts-9a506b339c0a
作者:[Lucas Aschenbach](https://medium.com/@lucas.aschenbach?source=post_page-----9a506b339c0a--------------------------------)