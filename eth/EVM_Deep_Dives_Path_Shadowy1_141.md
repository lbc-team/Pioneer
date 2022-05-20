原文链接：https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy?s=r

# EVM Deep Dives: The Path to Shadowy Super Coder 🥷 💻 - Part 1

### Digging deep into the EVM mechanics during contract function calls



First principles thinking is a term we often hear. It focuses on deeply understanding the foundational concepts of a subject to enable better thinking in the design space of the components which are built on top.

In the smart contract world, the “Ethereum Virtual Machine” along with its algorithms and data structures are the first principles. Solidity and the smart contracts we create are the components built on top of this foundation. To be a great solidity dev one must have a deep understanding of the EVM.

This is the first in a series of articles that will deep dive into the EVM and build that foundational knowledge needed to become a “shadowy super coder”.

## The Basics: Solidity → Bytecode → Opcode

Before we begin, this article assumes some basic knowledge of solidity and how it’s deployed to the Ethereum chain. We’ll briefly touch on these subjects however if you’d like a refresher see this article [here](https://medium.com/@eiki1212/explaining-ethereum-contract-abi-evm-bytecode-6afa6e917c3b).

As you know your solidity code needs to be compiled into bytecode prior to being deployed to the Ethereum network. This bytecode corresponds to a series of opcode instructions that the EVM interprets.

This series will focus on specific parts of the compiled bytecode and illuminate how they work. By the end of each article, you should have a much clearer understanding of how each component functions. Along the way, you will learn lots of the foundational concepts relating to the EVM.

Today we’re going to look at a basic solidity contract along with an excerpt of its bytecode/opcodes to demonstrate how the EVM selects functions.

The runtime bytecode created from solidity contracts is a representation of the entire contract. Within the contract, you may have multiple functions that can be called once it is deployed.

A common question is how does the EVM know what bytecode to execute depending on which function of the contract is called. This is the first question we’ll use to help understand the underlying mechanics of the EVM and how this particular case is handled.

### 1_Storage.sol Breakdown

For our demo, we will use the 1_Storage.sol contract, which is one of the default contracts in the online solidity IDE [Remix](https://remix.ethereum.org/).

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F3400bba6-f870-4b68-8ba8-118562b08aef_489x538.png)

The contract has 2 functions store(uint256) and retrieve() that the EVM will have to decide between when a function call comes in. Below is the compiled runtime bytecode of the entire contract.

```
608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100d9565b60405180910390f35b610073600480360381019061006e919061009d565b61007e565b005b60008054905090565b8060008190555050565b60008135905061009781610103565b92915050565b6000602082840312156100b3576100b26100fe565b5b60006100c184828501610088565b91505092915050565b6100d3816100f4565b82525050565b60006020820190506100ee60008301846100ca565b92915050565b6000819050919050565b600080fd5b61010c816100f4565b811461011757600080fd5b5056fea2646970667358221220404e37f487a89a932dca5e77faaf6ca2de3b991f93d230604b1b8daaef64766264736f6c63430008070033 
```

We are going to focus on the snippet of bytecode below. This snippet represents the function selector logic. Run “ctrl f” on the snippet to verify it is in the above bytecode.

```
60003560e01c80632e64cec11461003b5780636057361d1461005957
```

This bytecode corresponds to a set of EVM opcodes and their input values. You can check out the list of EVM opcodes [here](https://www.ethervm.io/).

Opcodes are 1 byte in length leading to 256 different possible opcodes. The EVM only uses 140 unique opcodes.

The below shows the bytecode snippet broken into its corresponding opcode commands. These are run sequentially on the call stack by the EVM. You can navigate to the link above to verify the opcode number 60 = PUSH1 etc. By the end of the article, you’ll have a full understanding of what these do.

```
60 00                       =   PUSH1 0x00 
35                          =   CALLDATALOAD
60 e0                       =   PUSH1 0xe0
1c                          =   SHR
80                          =   DUP1  
63 2e64cec1                 =   PUSH4 0x2e64cec1
14                          =   EQ
61 003b                     =   PUSH2 0x003b
57                          =   JUMPI
80                          =   DUP1 
63 6057361d                 =   PUSH4 0x6057361d     
14                          =   EQ
61 0059                     =   PUSH2 0x0059
57                          =   JUMPI  
```

### Smart Contract Function Calls & Calldata

Before diving deep into opcodes we need to quickly run through how we call a contract function.

When we call a contract function we include some calldata that specifies the function signature we are calling and any arguments that need to be passed in.

This can be done in solidity with the following.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2Fa9957ce1-945b-4afa-a395-c9d2563d2094_1614x670.png)

Here we are making a contract call to the store function with the argument 10. We use abi.encodeWithSignature() to get the calldata in the desired format. The emit logs our calldata for testing.

```
0x6057361d000000000000000000000000000000000000000000000000000000000000000a
```

The above is what abi.encodeWithSignature("store(uint256)", 10) returns.

Earlier I mentioned function signatures, now let’s take a closer look at what they are.

> Function signatures are defined as the first four bytes of the Keccak hash of the canonical representation of the function signature.

The canonical representation of the function signatures is the function name along with the function argument types ie. “store(uint256)” & “retrieve()”. Try hashing store(uint256) yourself to verify the results [here](https://emn178.github.io/online-tools/keccak_256.html).

```
keccak256(“store(uint256)”) →  first 4 bytes = 6057361d

keccak256(“retrieve()”) → first 4 bytes = 2e64cec1
```

Looking at our calldata above we can see that we have 36 bytes of calldata, the first 4 bytes of our calldata correspond to the function selector we just computed for the store(uint256) function.

The remaining 32 bytes corresponds to our uint256 input argument. We have a hex value of “a” which is equal to 10 in decimal.

```
6057361d = function signature (4 bytes)

000000000000000000000000000000000000000000000000000000000000000a = uint256 input (32 bytes)
```

If we take the function signature 6057361d and refer back to the opcode section, run ctrl f on this value and see if you can find it.

### Opcodes & The Call Stack

We now have everything we need to commence our deep dive into what goes on at the EVM level during function selection.

We are going to run through each of the opcode commands what they do and how they affect the call stack.

If you’re unfamiliar with how a stack data structure works watch this quick [video](https://www.youtube.com/watch?v=FNZ5o9S9prU) as a primer.

We start with PUSH1 which tells the EVM to push the next 1 byte of data, 0x00 (0 in decimal), to the call stack. Why we do this will become apparent with the next opcode.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F52e45eff-44b3-4028-a075-9f5591fd2e7e_900x151.png)

Next, we have CALLDATALOAD which pops off the first value on the stack (0) as input.

This opcode loads in the calldata to the stack using the “input” as an offset. Stack items are 32 bytes in size but our calldata is 36 bytes. The pushed value is msg.data[i:i+32] where “i” is this input. This ensures only 32 bytes are pushed to the stack but enables us to access any part of the calldata.

In this case, we have no offset (the value popped off of the stack was 0 from the previous PUSH1) so we push the first 32 bytes of the calldata to the call stack.

Remember earlier we logged our call data via an emit which equalled “0x6057361d000000000000000000000000000000000000000000000000000000000000000a”.

This means the trailing 4 bytes (“0000000a”) are lost. If we had wanted to access the uint256 variable we would have used an offset of 4 to omit the function signature but include the full variable.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2Fe6f79343-c4c4-4ee6-a29f-f1923fea5b9e_901x150.png)

Another PUSH1 this time with the hex value 0xe0 which has a decimal value of 224. Remember function signatures are 4 bytes long or 32 bits. Our loaded calldata is 32 bytes long or 256 bits. 256 - 32 = 224 you may see where this is going.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F161dea9b-d35b-4eb1-aac5-7adecb6cc17d_901x149.png)

Next, we have SHR which is a bit shift right. It takes the first item off the stack (224) as an input of how much to shift by and the second item off the stack (0x6057361d0…0a) represents what needs to be shifted. We can see after this operation we have our 4-byte function selector on the call stack.

If you are unfamiliar with how bit shifts work see [this](https://youtu.be/fDKUq38H2jk?t=176) short video.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F8db5bd19-2271-44b3-99ed-0eec2731be5c_893x144.png)

Next is DUP1, a simple opcode that takes the value on the top of the stack and duplicates it.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F40b72e9d-6e80-4232-9099-8718604542a8_896x146.png)

PUSH4 pushes the 4 byte function signature of retrieve() (0x2e64cec1) onto the call stack.

In case you’re wondering how it knows this value, remember this is in the bytecode that was compiled from the solidity code. The compiler, therefore, had information on all function names and argument types.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F23dc9994-e360-4205-bf5d-af92aaba42e5_899x189.png)

EQ pops 2 values off of the stack, in this case, 0x2e64cec1 & 0x6057361d and checks if they’re equal. If they are it pushes a 1 back to the stack, if not a 0.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F7cfc3f88-d5eb-4b03-b4c3-eb605bdeb283_895x144.png)

PUSH2 pushes 2 bytes of data onto the call stack 0x003b in hex which is equal to 59 in decimal.

The call stack has something called a program counter which specifies where in the bytecode the next execution command is. Here we set 59 because that is the location for the start of the retrieve() bytecode. (Note the EVM Playground section below will help crystallize how this works)

You can view the program counter location in a similar way to a line number location in your solidity code. If the function is defined on line 59 you can use the line number as a way to tell the machine where to find the code for that function.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F67596d4e-054d-4cd7-b516-64b4789ee01f_900x190.png)

JUMPI stands for “jump if”. It pops 2 values off of the stack as input, the first (59) is the jump location and the second (0) is the bool value for whether this jump should be executed. Where 1 = true and 0 = false.

If it is true the program counter will be updated and the execution will jump to that location. In our case it is false, the program counter is not altered and the execution continues as normal.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F1357763b-4150-4e14-8a8c-583ee74572aa_896x146.png)

DUP1 again.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F40b72e9d-6e80-4232-9099-8718604542a8_896x146.png)

PUSH4 pushes the 4 byte function signature of store(uint256) (0x6057361d) onto the call stack.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2Ff937657d-dbb3-4133-95bb-1b3f5b8117cd_897x188.png)

EQ again however this time the result is true as the function signatures match.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F9c0617f7-2181-427e-9dca-917be7847f0a_898x145.png)

PUSH2, push the program counter location for the store(uint256) bytecode, 0x0059 in hex which is equal to 89 in decimal.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F44dea0e0-9e0c-4459-bd1e-4af814c89203_898x186.png)

JUMPI, this time the bool check is true meaning the jump executes. This updates the program counter to 89 which will move the execution to a different part of the bytecode.

At this location, there will be a JUMPDEST opcode, without this opcode at the destination the JUMPI will fail.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F9f3a7f3c-a5f6-4e29-888f-60708e8863dc_896x146.png)

There we have it, after this opcode executes you’ll be taken to the location of the store(uint156) bytecode and the execution of the function will continue as normal.

While this contract only had 2 functions the same principles apply for a contract with 20+ functions.

You now know how the EVM determines the location of the function bytecode that it needs to execute based on a contract function call. It’s actually just a simple set of “if statements” for each function in your contract along with their jump locations.

### EVM Playground

I highly recommend visiting this[link](https://www.evm.codes/playground?unit=Wei&callData=0x6057361d000000000000000000000000000000000000000000000000000000000000000a&codeType=Mnemonic&code=%27!0~0KCALLDATALOAD~2z2qw!E0~3KSHR~5z2qwDUP1~6(X4_2E64CEC1~7KEQ~12z5qwX2_3B~13(*I~16z3qwDUP1~17KX4_6057361D~18KEQ~23z5qwX2_59~24K*I~27z3qwkY%20wX30_0~28KwZGV59z31q!1~60%20%7BG%7DW%7DKwkYwX26_0~62z2qKZstore%7Buint256V89z27q!0%20ZContinueW.KK%27~%20ZOffset%20z%20%7Bprevious%20instruFoccupies%20w%5Cnq)s%7DwkZThes-ar-just%20paddingNenabl-usNgetN_%200xZ%2F%2F%20Yprogram%20counter%2059%20%26%2089XPUSHW%20funFexecution...V%7Dcodew*DEST~N%20to(wwGretrieve%7BFction%20-e%20*JUMP)%20byte(%20K!X1_%01!()*-FGKNVWXYZ_kqwz~_), it’s an EVM playground where I have set up the exact bytecode we have just run through. You’ll be able to interactively see the stack changing and I’ve included the JUMPDEST so you can see what happens after the final JUMPI.

![img](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F86591a6b-ee71-4590-8462-4ebb38f5cb80_1503x887.png)

The EVM playground will also help with your understanding of the program counter, in the code, you’ll see comments next to each command with its offset which represents its program counter location.

You’ll also see the calldata input to the left of the Run button, try changing this to the retrieve() call data 0x2e64cec1 to see how the execution changes. Just click Run and then the “step into” (curled arrow) button at the top right to jump through each opcode one by one.

Next, in the series, we take a trip down “Memory” lane in [EVM Deep Dives - Part 2](https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy-d6b?s=r).