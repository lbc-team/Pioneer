原文链接：https://hackernoon.com/using-ethereums-create2-nw2137q7

# Using Ethereum’s CREATE2

![image](https://img.learnblockchain.cn/attachments/2022/05/eDgCw1rv628744f22768f.jpg)



*To see the contract that uses CREATE2, jump to Step 2.*

The new opcode `CREATE2`was added to the Ethereum virtual machine nearly a year ago — at the end of February 2019. This opcode introduced a second method of calculating the address of a new smart contract (previously only `CREATE`was available). Using `CREATE2` is certainly more complex than the original `CREATE`. You can no longer just write `new Token()` in Solidity, and instead must resort to writing in assembly code.

However `CREATE2`has an important property that makes it preferable in certain situations: it doesn’t rely on the current state of the deploying address. This means you can be sure the contract address calculated today would be the same as the address calculated 1 year from now. This is important is because you can interact with the address, and send it ETH, before the smart contract has been deployed to it.

So, with few practical walk-throughs available online, I decided to create this simple explanatory blog to explain:

1. How`CREATE`and`CREATE2`each work
2. How to use`CREATE2`in your smart contract, and
3. How I used it to solve one of the [Capture The Ether](https://capturetheether.com/?ref=hackernoon.com) challenges

## The CREATE opcode.

This is the opcode used by default to deploy contracts. The resulting contract address is calculated by hashing:

1. The deploying address
2. The number of contracts that have previously been deployed from that address — known as the`nonce`

```
keccak256(rlp.encode(deployingAddress, nonce))[12:]
```

## The CREATE2 opcode.

This opcode was introduced to Ethereum in February 2019 and so is still relatively new. It is essentially just another way to deploy a smart contract, but with a different way to calculate the new contract address. It uses:

1. The deploying address
2. The hash of the bytecode being deployed
3. A random ‘salt’ (32 byte string), supplied by the creator.

```
keccak256(0xff ++ deployingAddr ++ salt ++ keccak256(bytecode))[12:]
```

## The Challenge

For my worked example using `CREATE2`, I'm going to solve the [Fuzzy Identity challenge on Capture the Ether](https://capturetheether.com/challenges/accounts/fuzzy-identity/?ref=hackernoon.com). To complete the task defined on the challenge page, you need to create a contract that has 2 properties:

1. Has a`name()`function that returns`bytes32("smarx")`
2. Has the string`badc0de` somewhere in its address.

The first is easy to implement. The second is where the challenge comes in, and to complete it we must use knowledge of how Ethereum calculates contract addresses — which we just went over!

## Solve it with CREATE?

To succeed in this challenge using the `CREATE`opcode we’d need to generate many private keys. For each of these we would calculate the corresponding Ethereum address, use a nonce of `0`to calculate the resulting contract address.



## Solve it with CREATE2?

Using just 1 Ethereum address, we instead can just loop through different salt values until we find one that works. This seems like a nice option over generating potentially hundreds of thousands of private keys. 

Considering Capture the Ether was created in 2018, `CREATE2`was certainly not the intended solution for the problem — but I think it sounds like the nicer option.



## The Solution

To use `CREATE2`to find an address containing `badc0de`we need:

1. The bytecode of the contract to be deployed
2. The address deploying the contract (a contract that uses`CREATE2`)
3. Our salt — that we will calculate.

## Step 1: The bytecode of contract to be deployed

The first step is to get the bytecode of the contract that we want to deploy at an address containing badc0de. The contract to pass [the challenge](https://capturetheether.com/challenges/accounts/fuzzy-identity/?ref=hackernoon.com) is simple, and can be defined as follows:

```
pragma solidity ^0.5.12;
contract BadCodeSmarx is IName {
   function callAuthenticate(address _challenge) public {
      FuzzyIdentityChallenge(_challenge).authenticate(); 
   }
   function name() external view returns (bytes32) {
      return bytes32("smarx");
   }
}
```

Running a quick `truffle compile`, the bytecode can then be found inside 
`/build/BadCodeSmarx.json`:

```
"bytecode": "0x608060405234801561001057600080fd5b506101468061002..."
```

Or the same result can be achieved using [Remix](https://remix.ethereum.org/?ref=hackernoon.com) instead of Truffle.

## Step 2: A contract that uses CREATE2

Now we can define a simple contract that is provided a salt, and uses `CREATE2`to deploy this bytecode:

```
contract Deployer {
  bytes contractBytecode = hex"608060405234801561001057600080fd5b5061015d806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c806306fdde031461003b5780637872ab4914610059575b600080fd5b61004361009d565b6040518082815260200191505060405180910390f35b61009b6004803603602081101561006f57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506100c5565b005b60007f736d617278000000000000000000000000000000000000000000000000000000905090565b8073ffffffffffffffffffffffffffffffffffffffff1663380c7a676040518163ffffffff1660e01b8152600401600060405180830381600087803b15801561010d57600080fd5b505af1158015610121573d6000803e3d6000fd5b505050505056fea265627a7a72315820fb2fc7a07f0eebf799c680bb1526641d2d905c19393adf340a04e48c9b527de964736f6c634300050c0032";
 
  function deploy(bytes32 salt) public {
    bytes memory bytecode = contractBytecode;
    address addr;
      
    assembly {
      addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
    }
  }
}
```

In Solidity assembly, create2() takes 4 parameters:

- 1: The amount of wei to send to the new contract as`msg.value`. This is 0 for this example.

- 2–3: The location of the bytecode in memory

- 4: The salt — that we will calculate in step 3. We leave this as a parameter so it can we provided after we have calculated it.

It also returns the address of the created contract — which you must catch in a variable whether or not you want to use it.

So now this contract is ready to go. I deployed it on Ropsten testnet at: [0xca4dfd86a86c48c5d9c228bedbeb7f218a29c94b](https://ropsten.etherscan.io/address/0xca4dfd86a86c48c5d9c228bedbeb7f218a29c94b?ref=hackernoon.com). Now that we know the address that will be deploying our `BadCodeSmarx`contract, and we have the bytecode, all we need to do is calculate a salt that will result in address containing `badc0de`.



## Step 3: Calculating the salt

To find a salt that will result in an address containing `badc0de`, we need a simple script to loop through each salt one by one, and calculate the address it would obtain.

So as to ensure the script was calculating the resulting address correctly, I deployed a contract using salt `0x00...001`. I then used that contract address to ensure my script was correctly formatting and hashing parameters — and therefore producing the same address as `CREATE2`does onchain.

As a reminder — the formula for address creation is as follows, where `[12:]`means the first 12 bytes are removed to find the address.



```
keccak256(0xff ++ deployingAddr ++ salt ++ keccak256(bytecode))[12:]
```

Here is the script I used. I used the package ethereumjs-util to perform keccak256 hashes — you can find it on [Github](https://github.com/ethereumjs/ethereumjs-util?ref=hackernoon.com).

```
const eth = require('ethereumjs-util')

// 0xff ++ deployingAddress is fixed:
var string1 = '0xffca4dfd86a86c48c5d9c228bedbeb7f218a29c94b'

// Hash of the bytecode is fixed. Calculated with eth.keccak256():
var string2 = '4670da3f633e838c2746ca61c370ba3dbd257b86b28b78449f4185480e2aba51'

// In each loop, i is the value of the salt we are checking
for (var i = 0; i < 72057594037927936; i++) {
   // 1. Convert i to hex, and it pad to 32 bytes:
   var saltToBytes = i.toString(16).padStart(64, '0')

   // 2. Concatenate this between the other 2 strings
   var concatString = string1.concat(saltToBytes).concat(string2)
   
   // 3. Hash the resulting string
   var hashed = eth.bufferToHex(eth.keccak256(concatString))

   // 4. Remove leading 0x and 12 bytes
   // 5. Check if the result contains badc0de
   if (hashed.substr(26).includes('badc0de')) {
      console.log(saltToBytes)
      break
   }
}
```

Running this script, less than 30 seconds later out popped my resulting salt:

```
0x00000000000000000000000000000000000000000000000000000000005b2bfe
```

Then all I had to do was execute `Deployer.deploy(0x00...005b2bfe)`. Lo and behold an instance of `BadCodeSmarx`was deployed at:

0xa905a3922a4ebfbc7d257cecdb1df04a3**badc0de**

## References:

1. [EIP1014 — Skinny CREATE2](https://eips.ethereum.org/EIPS/eip-1014?ref=hackernoon.com)
2. [Capture the Ether — Fuzzy Identity](https://capturetheether.com/challenges/accounts/fuzzy-identity/?ref=hackernoon.com)
3. [Truffle](https://www.trufflesuite.com/?ref=hackernoon.com)
4. [ethereumjs-util](https://github.com/ethereumjs/ethereumjs-util?ref=hackernoon.com)