原文链接：https://steveng.medium.com/performing-merkle-airdrop-like-uniswap-85e43543a592

# Performing Merkle Airdrop like Uniswap

*If you want to skip directly on how to implement Uniswap airdrop, proceed to the section:* **Steps on creating a Merkle Airdro**p

![img](https://img.learnblockchain.cn/attachments/2022/05/kBck9IbG6285e77c2632c.jpeg)

Image from https://ccoingossip.com/what-is-airdrop-in-crypto-world/

An airdrop is an event when the project decides to give tokens away to a group of users. These are some potential way to implement airdrop:

1. **Admin call a function to send tokens**

In this case, a function implemented like below:

```
function airdrop(address address, uint256 amount) onlyOwner {
  IERC20(token).transfer(account, amount);  
}
```

In this scenario, the owner would have to pay the gas fee to call the function and it will not be sustainable if the list of addresses is huge and especially on ETH.

**2. Storing the list of whitelisted addresses on the contract**

You would likely implement a mapping `mapping(address => some struct)` which stores all the whitelisted addresses and whether the address has claimed the airdrop. Similarly, the owner would also have to pay the gas fee to store the list of whitelisted addresses of the contract.

# Merkle Airdrop

For Merkle airdrop implementation, the same objective is accomplished with the following benefit:

- The owner only pay the gas fee to create the contract and storing the Merkle root on the contract
- Whitelisted addresses can call the contract on their own to claim their airdrop — this also opens up the possibility of having a deadline to claim the airdrop.

And if you are in Defi early enough, Uniswap's initial airdrop is done through Merkle — ref https://github.com/Uniswap/merkle-distributor

# What is Merkle Airdrop?

Merkle-based Airdrop is based on Merkle Tree data structure.

> I strongly encourage people who are new to Merkle tree to watch this video https://www.youtube.com/watch?v=qHMLy5JjbjQ

Take the example below, if we have 8 values to store (**A to H**), we start by

- Form second layer: Hash(A+B), Hash(C+D), Hash(E+F), Hash(G+H)
- Form third layer: Hash(Hash(A+B), Hash(C+D)), Hash( Hash(E+F), Hash(G+H))
- Finally, the fourth level showed in orange.

The one in orange is what we call **Merkle root**, the root of the tree.

![img](https://img.learnblockchain.cn/attachments/2022/05/GEJcdQir6285e88586f38.png)

**Why is this effective?**

Merkle tree is effective as we do not need the go through the entire tree in order to prove our value exists in the Merkle tree. For example, to prove that **F** belongs to the Merkle tree, we only need to provide **E, H(GH),** and **H(ABCD)** and someone with the root can verify if **F** belongs to the Merkle Tree.

> *It takes only logarithmic time to verify proof!*

![img](https://img.learnblockchain.cn/attachments/2022/05/k5t2bk0N6285e8c3d7ee1.png)

# Steps on creating a Merkle Airdrop

Reference for the code can be found at https://github.com/steve-ng/merkle-airdrop — 2 main libraries are used

- Frontend: https://github.com/miguelmota/merkletreejs
- Solidity side: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/cryptography/MerkleProof.sol

**Pre-requisite**

- Generate the list of whitelisted and amount they are qualified for
- Generate the Merkle root based on the list

The example can be found in https://github.com/steve-ng/merkle-airdrop/blob/main/test/MerkleDistributor.ts

```
// Generate the list of whitelisted user and amount qualified 
const users = [    
  { address: "0x..", amount: 10 },    
  { address: "0x..", amount: 15 },    
  { address: "0x...", amount: 20 },    
  { address: "0x..", amount: 30 },  
]; 
// Encode the datastructure 
const elements = users.map((x) =>     
  utils.solidityKeccak256(
    ["address", "uint256"], [x.address, x.amount]));
const merkleTree = 
  new MerkleTree(elements, keccak256, { sort: true });
// Generate the root 
const root = merkleTree.getHexRoot();
```

**In your smart contract**

Store the Merkle Root generated in your smart contract — you can refer to https://github.com/steve-ng/merkle-airdrop/blob/main/contracts/MerkleDistributor.sol

**In your frontend**

- Store all the address that’s eligible for the airdrop, such that when the user comes to your site, they can immediately see if they are eligible
- If they are eligible, call the smart contract with the proof.

Similarly, the code can be found in the test cases at https://github.com/steve-ng/merkle-airdrop/blob/main/test/MerkleDistributor.ts#L46

# Summary

Once you know how Merkle airdrop works, the implementation is very straightforward. The use case is not only for airdrop, you can also implement this for applications with a whitelisting requirements, eg. IDO or early access to some feature.



