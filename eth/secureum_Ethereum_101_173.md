原文链接：https://secureum.substack.com/p/ethereum-101



# secureum 系列文章(八) Ethereum 101 #173



## Ethereum 101

### 101 key aspects of Ethereum

1. Ethereum is “A Next-Generation Smart Contract and Decentralized Application Platform” (See [here](https://ethereum.org/en/whitepaper/))
2. Ethereum is a blockchain with a built-in Turing-complete programming language, allowing anyone to write smart contracts and decentralized applications where they can create their own arbitrary rules for ownership, transaction formats and state transition functions. (See [here](https://ethereum.org/en/whitepaper/))
3. Ethereum is an open source, globally decentralized computing infrastructure that executes programs called smart contracts. It uses a blockchain to synchronize and store the system’s state changes, along with a cryptocurrency called ether to meter and constrain execution resource costs. It is often described as "the world computer.” (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
4. The Ethereum platform enables developers to build powerful decentralized applications with built-in economic functions. While providing high availability, auditability, transparency, and neutrality, it also reduces or eliminates censorship and reduces certain counterparty risks. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
5. Ethereum’s purpose is not primarily to be a digital currency payment network. While the digital currency ether is both integral to and necessary for the operation of Ethereum, ether is intended as a utility currency to pay for use of the Ethereum platform as the world computer. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
6. Unlike Bitcoin, which has a very limited scripting language, Ethereum is designed to be a general-purpose programmable blockchain that runs a virtual machine capable of executing code of arbitrary and unbounded complexity. Where Bitcoin’s Script language is, intentionally, constrained to simple true/false evaluation of spending conditions, Ethereum’s language is Turing complete, meaning that Ethereum can straightforwardly function as a general-purpose computer. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
7. The original blockchain, namely Bitcoin’s blockchain, tracks the state of units of bitcoin and their ownership. You can think of Bitcoin as a distributed consensus state machine, where transactions cause a global state transition, altering the ownership of coins. The state transitions are constrained by the rules of consensus, allowing all participants to (eventually) converge on a common (consensus) state of the system, after several blocks are mined. Ethereum is also a distributed state machine. But instead of tracking only the state of currency ownership, Ethereum tracks the state transitions of a general-purpose data store, i.e., a store that can hold any data expressible as a key–value tuple. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
8. Ethereum’s core components (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc)):
   1. P2P network: Ethereum runs on the Ethereum main network, which is addressable on TCP port 30303, and runs a protocol called ÐΞVp2p.
   2. Transactions: Ethereum transactions are network messages that include (among other things) a sender, recipient, value, and data payload.
   3. State machine: Ethereum state transitions are processed by the Ethereum Virtual Machine (EVM), a stack-based virtual machine that executes bytecode (machine-language instructions). EVM programs, called "smart contracts," are written in high-level languages (e.g., Solidity or Vyper) and compiled to bytecode for execution on the EVM.
   4. Data structures: Ethereum’s state is stored locally on each node as a database (usually Google’s LevelDB), which contains the transactions and system state in a serialized hashed data structure called a Merkle Patricia Tree.
9. Ethereum’s core components (continued):
   1. Consensus algorithm: Ethereum uses Bitcoin’s consensus model, Nakamoto Consensus, which uses sequential single-signature blocks, weighted in importance by Proof-of-Work (PoW) to determine the longest chain and therefore the current state. 
   2. However, this is being transitioned to a Proof-of-Stake (PoS) algorithm in Ethereum 2.0.
   3. Economic security: Ethereum currently uses a PoW algorithm called Ethash, but this is being transitioned to a PoS algorithm in Ethereum 2.0.
   4. Clients: Ethereum has several interoperable implementations of the client software, the most prominent of which are Go-Ethereum (Geth) and OpenEthereum. The others are Erigon, Nethermind and Turbo-geth. OpenEthereum is being deprecated to transition to Erigon, which is the former Turbo-geth. (See [here](https://www.ethernodes.org/))
10. Ethereum’s ability to execute a stored program, in a state machine called the Ethereum Virtual Machine, while reading and writing data to memory makes it a Turing-complete system. Turing-complete systems face the challenge of the halting problem i.e. given an arbitrary program and its input, it is not solvable to determine whether the program will eventually stop running. So Ethereum cannot predict if a smart contract will terminate, or how long it will run. Therefore, to constrain the resources used by a smart contract, Ethereum introduces a metering mechanism called gas. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
11. As the EVM executes a smart contract, it carefully accounts for every instruction (computation, data access, etc.). Each instruction has a predetermined cost in units of gas. When a transaction triggers the execution of a smart contract, it must include an amount of gas that sets the upper limit of what can be consumed running the smart contract. The EVM will terminate execution if the amount of gas consumed by computation exceeds the gas available in the transaction. Gas is the mechanism Ethereum uses to allow Turing-complete computation while limiting the resources that any program can consume. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
12. Ether needs to be sent along with a transaction and it needs to be explicitly earmarked for the purchase of gas, along with an acceptable gas price. Just like at the pump, the price of gas is not fixed. Gas is purchased for the transaction, the computation is executed, and any unused gas is refunded back to the sender of the transaction. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/01what-is.asciidoc))
13. A Decentralized Application, abbreviated as ÐApp, is a web application that is built on top of open, decentralized, peer-to-peer infrastructure services and typically combines smart contracts with a web interface.
14. ÐApps represent a transition from “Web 2.0” where applications are centrally owned and managed to “Web 3.0” where applications are built on decentralised peer-to-peer protocols for compute (i.e. blockchain), storage and messaging.
15. Ethereum blockchain represents the decentralized compute part of Web 3.0. Swarm represents the decentralized storage and Whisper (now Waku) represents the decentralized messaging protocol.
16. Decentralization can be considered as three types (See [here](https://medium.com/@VitalikButerin/the-meaning-of-decentralization-a0c92b76a274)):
    1. Architectural decentralization
    2. Political decentralization
    3. Logical decentralization
17. Ethereum’s currency unit is called ether or “ETH.” Ether is subdivided into smaller units and the smallest unit is named wei. 10**3 wei is 1 Babbage, 10**6 wei is 1 Lovelace, 10**9 wei is 1 Shannon and 10**18 wei is 1 Ether.
18. Ethereum uses public key cryptography to create public–private key pairs (considered a "pair" because the public key is derived from the private key) which are not used for encryption but for digital signatures.
19. Ethereum uses Elliptic Curve Digital Signature Algorithm (ECDSA) for digital signatures (SECP-256k1 curve) which is based on Elliptic-curve cryptography (ECC), an approach to public-key cryptography based on the algebraic structure of elliptic curves over finite fields. (See [here](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography))
20. An Ethereum private key is a 256-bit random number that uniquely determines a single Ethereum address also known as an account
21. An Ethereum public key is a point on an elliptic curve calculated from the private key using elliptic curve multiplication. One cannot calculate the private key from the public key.
22. Ethereum state is made up of objects called "accounts", with each account having a 20-byte address and state transitions being direct transfers of value and information between accounts. (See [here](https://ethereum.org/en/whitepaper/#ethereum-accounts))
23. Ethereum account contains four fields:
    1. The nonce, a counter used to make sure each transaction can only be processed once
    2. The account's current ether balance
    3. The account's contract code, if present
    4. The account's storage (empty by default)
24. Ethereum has two different types of accounts:
    1. Externally Owned Accounts (EOAs) controlled by private keys
    2. Contract Accounts controlled by their contract code
25. Ownership of ether by EOAs is established through private keys, Ethereum addresses, and digital signatures. Anyone with a private key has control of the corresponding EOA account and any ether it holds.
26. An EOA has no code, and one can send messages from an EOA by creating and signing a transaction
27. A contract account has code and associated storage and every time it receives a message its code activates, allowing it to read and write to internal storage and send other messages or create contracts in turn.
28. Smart contracts can be thought of as "autonomous agents" that live inside of the Ethereum execution environment, always executing a specific piece of code when "poked" by a message or transaction, and having direct control over their own ether balance and their own key/value store to keep track of persistent variables.
29. Ethereum uses Keccak-256 as its cryptographic hash function. Keccak-256 was the winning candidate for the SHA-3 competition held by NIST but is different from the finally adopted SHA-3 standard. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/04keys-addresses.asciidoc))
30. Ethereum address of an EOA account is the last 20 bytes (least significant bytes) of the Keccak-256 hash of the public key of the EOA’s key pair.
31. Transactions are signed messages originated by an externally owned account (EOA), transmitted by the Ethereum network, and recorded on the Ethereum blockchain. Only transactions can trigger a change of state. Ethereum is a transaction-based state machine. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/06transactions.asciidoc))
32. Transaction properties:
    1. Atomic: it is all or nothing i.e. cannot be divided or interrupted by other transactions
    2. Serial: Transactions are processed sequentially one after the other without any overlapping by other transactions
    3. Inclusion: Transaction inclusion is not guaranteed and depends on network congestion and gasPrice among other things. Miners determine inclusion.
    4. Order: Transaction order is not guaranteed and depends on network congestion and gasPrice among other things. Miners determine order.
33. A transaction is a serialized binary message that contains the following components (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/06transactions.asciidoc)):
    1. nonce: A sequence number, issued by the originating EOA, used to prevent message replay
    2. gasPrice: The amount of ether (in wei) that the originator is willing to pay for each unit of gas
    3. gasLimit: The maximum amount of gas the originator is willing to pay for this transaction
    4. recipient: The destination Ethereum address
    5. value: The amount of ether (in wei) to send to the destination
    6. data: The variable-length binary data payload
    7. v,r,s: The three components of an ECDSA digital signature of the originating EOA
34. Nonce: A scalar value equal to the number of transactions sent from the EOA account or, in the case of Contract accounts, it is the number of contract-creations made by the account. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/06transactions.asciidoc#the-transaction-nonce))
35. Gas price: The price a transaction originator is willing to pay in exchange for gas. The price is measured in wei per gas unit. The higher the gas price, the faster the transaction is likely to be confirmed on the blockchain. The suggested gas price depends on the demand for block space at the time of the transaction.
36. Gas limit: The maximum number of gas units the transaction originator is willing to pay in order to complete the transaction
37. Recipient: The 20-byte Ethereum address of the transaction’s recipient which can be an EOA or a Contract account.
    1. The Ethereum protocol does not validate recipient addresses in transactions. One can send a transaction to an address that has no corresponding private key or contract. Validation should be done at the user interface level.
    2. Note that there is no *from* address in the transaction because the EOA’s public key can be derived from the v,r,s components of the ECDSA signature and the transaction originator’s address can be derived from this public key
38. Value: The value of ether sent to the transaction recipient. If the recipient is an EOA then that account’s balance will be increased by this value. If the recipient is a contract address then the result depends on any data that is sent as part of this transaction. If there is no data, the recipient contract’s *receive* or *fallback* function is called if they are present. Depending on the implementation of those functions, the ether value is added to the contract account’s balance or an exception occurs and this ether remains with the originator’s account.
39. Data: The information (typically) sent to a contract account indicating the contract’s function to be called and the arguments to that function.
40. v,r,s: *r* and *s* are the two parts of the ECDSA signature produced by the transaction originator using the private key. *v* is the recovery identifier which is calculated as either one of 27 or 28, or as the chain ID (Ethereum mainnet chainID is 1) doubled plus 35 or 36. (See [here](https://github.com/ethereumbook/ethereumbook/blob/develop/06transactions.asciidoc#digital-signatures))
41. A digital signature serves three purposes in Ethereum: 1) proves that the owner of the private key, who is by implication the owner of an Ethereum account, has authorized the spending of ether, or execution of a contract 2) guarantees non-repudiation: the proof of authorization is undeniable 3) proves that the transaction data has not been and cannot be modified by anyone after the transaction has been signed.
42. Contract creation transactions are sent to a special destination address called the zero address i.e. 0x0. A contract creation transaction contains a data payload with the compiled bytecode to create the contract. An optional ether amount in the value field will create the new contract with a starting balance.
43. Transactions vs Messages:
    1. A transaction is produced by an EOA where an external actor sends a signed data package which either: 1) triggers a message to another EOA where it leads to a transfer of value or 2) triggers a message to a contract account where it leads to the recipient contract account running its code
    2. A message is either: 1) triggered by a transaction to another EOA or contract account or 2) triggered internally within the EVM by a contract account when it executes the CALL family of opcodes and leads to the recipient contract account running its code or value transfer to the recipient EOA 
44. Transactions are grouped together into blocks. A blockchain contains a series of such blocks that are chained together.
45. Blocks: are batches of transactions with a hash of the previous block in the chain. This links blocks together (in a chain) because hashes are cryptographically derived from the block data. This prevents fraud, because one change in any block in history would invalidate all the following blocks as all subsequent hashes would change and everyone running the blockchain would notice. To preserve the transaction history, blocks are strictly ordered (every new block created contains a reference to its parent block), and transactions within blocks are strictly ordered as well. (See [here](https://ethereum.org/en/developers/docs/blocks/))
46. Ethereum node/client: A node is a software application that implements the Ethereum specification and communicates over the peer-to-peer network with other Ethereum nodes. A client is a specific implementation of Ethereum node. The two most common client implementations are Geth and OpenEthereum. Ethereum transactions are sent to Ethereum nodes to be broadcast across the peer-to-peer network. (See [here](https://www.ethernodes.org/))
47. Miners: are entities running Ethereum nodes that validate and execute these transactions and combine them into blocks. The process of validating each block by having a miner provide a mathematical proof is known as a “proof of work.” Miners are rewarded for blocks accepted into the blockchain with a block reward in ether (currently 2 ETH). A miner also gets fees which is the ether spent on gas by all the transactions included in the block.
48. Block gas limit is set by miners and refers to the cap on the total amount of gas expended by all transactions in the block, which ensures that blocks can’t be arbitrarily large. Blocks therefore are not a fixed size in terms of the number of transactions because different transactions consume different amounts of gas. See [here](https://etherscan.io/chart/gaslimit) for historical block gas limits.
49. Blocks take time to propagate through the network and multiple miners are simultaneously producing valid blocks. This leads to the blockchain considering multiple blocks at the same level but ultimately choosing only one block at any level that creates the canonical blockchain. This choice is dictated by Ethereum’s Greedy Heaviest Observed Subtree (GHOST) protocol which includes stale blocks up to seven levels in the calculation of the longest chain. Stale blocks are called uncles or ommers.
50. Consensus: Decentralized consensus in the context of Ethereum refers to the process of determining which miner’s block should be appended next to the blockchain. This involves two key components of Proof-of-Work (PoW) and the Longest-chain Rule. Miners apply these rules to build on the canonical blockchain. This is referred to as "Nakamoto Consensus” and is adapted from Bitcoin.
51. State is a mapping between addresses and account states implemented as a modified Merkle Patricia tree or trie. A Merkle tree or trie is a type of binary tree composed of a set of nodes with:
    1. Leaf nodes at the bottom of the tree that contain the underlying data
    2. Intermediate nodes, where each node is the hash of its two child nodes
    3. A single root node formed from the hash of its two child nodes representing the top of the tree
52. Ethereum’s proof-of-work algorithm is called “Ethash” (previously known as Dagger-Hashimoto). 
    1. The algorithm is formally defined as *m = Hm* ∧ *n <= 2**256/Hd* with *(m, n) = PoW(Hn’, Hn, d)* where Hn’ is the new block’s header but without the nonce and mix-hash components; Hn is the nonce of the header; d is a large data set needed to compute the mixHash and Hd is the new block’s difficulty value
    2. PoW is the proof-of-work function which evaluates to an array with the first item being the mixHash and the second item being a pseudorandom number cryptographically dependent on H and d.
53. Blocks contain block header, transactions and ommers’ block headers. Block header contains (See [here](https://ethereum.github.io/yellowpaper/paper.pdf)):
    1. *parentHash*: The Keccak 256-bit hash of the parent block’s header, in its entirety
    2. *ommersHash*: The Keccak 256-bit hash of the ommers list portion of this block
    3. *beneficiary*: The 160-bit address to which all fees collected from the successful mining of this block be transferred
    4. *stateRoot*: The Keccak 256-bit hash of the root node of the state trie, after all transactions are executed and finalisations applied
    5. *transactionsRoot*: The Keccak 256-bit hash of the root node of the trie structure populated with each transaction in the transactions list portion of the block
    6. *receiptsRoot*: The Keccak 256-bit hash of the root node of the trie structure populated with the receipts of each transaction in the transactions list portion of the block
    7. *logsBloom*: The Bloom filter composed from indexable information (logger address and log topics) contained in each log entry from the receipt of each transaction in the transactions list
    8. *difficulty*: A scalar value corresponding to the difficulty level of this block. This can be calculated from the previous block’s difficulty level and the timestamp
    9. *number*: A scalar value equal to the number of ancestor blocks. The genesis block has a number of zero; 
    10. gasLimit: A scalar value equal to the current limit of gas expenditure per block
    11. *gasUsed*: A scalar value equal to the total gas used in transactions in this block
    12. *timestamp*: A scalar value equal to the reasonable output of Unix’s time() at this block’s inception
    13. *extraData*: An arbitrary byte array containing data relevant to this block. This must be 32 bytes or fewer
    14. *mixHash*: A 256-bit hash which, combined with the nonce, proves that a sufficient amount of computation has been carried out on this block
    15. *nonce*: A 64-bit value which, combined with the mixhash, proves that a sufficient amount of computation has been carried out on this block
54. *stateRoot*, *transactionsRoot* and *receiptsRoot* are 256-bit hashes of the root nodes of modified Merkle-Patricia trees. The leaves of stateRoot are key-value pairs of all Ethereum address-account pairs, where each respective account consists of:
    1. nonce: A scalar value equal to the number of transactions sent from this address or, in the case of accounts with associated code, the number of contract-creations made by this account
    2. balance: A scalar value equal to the number of Wei owned by this address
    3. storageRoot: A 256-bit hash of the root node of a modified Merkle-Patricia tree that encodes the storage contents of the account (a mapping between 256-bit integer values), encoded into the trie as a mapping from the Keccak 256-bit hash of the 256-bit integer keys to the RLP-encoded 256-bit integer values.
    4. codeHash: The hash of the EVM code of this account—this is the code that gets executed should this address receive a message call; it is immutable and thus, unlike all other fields, cannot be changed after construction.
55. Transaction receipt is a tuple of four items comprising: 
    1. The cumulative gas used in the block containing the transaction receipt as of immediately after the transaction has happened
    2. The set of logs created through execution of the transaction
    3. The Bloom filter composed from information in those logs
    4. The status code of the transaction
56. Gas refund and beneficiary: Any unused gas in a transaction (gasLimit minus gas used by the transaction) is refunded to the sender’s account at the same gasPrice. Ether used to purchase gas used for the transaction is credited to the beneficiary address (specified in the block header), the address of an account typically under the control of the miner. This is the transaction “fees” paid to the miner.
57. EVM is a quasi Turing complete machine where the quasi qualification comes from the fact that the computation is intrinsically bounded through a parameter, gas, which limits the total amount of computation done. EVM is the runtime environment for smart contracts.
58. The code in Ethereum contracts is written in a low-level, stack-based bytecode language, referred to as "Ethereum virtual machine code" or "EVM code". The code consists of a series of bytes (hence called bytecode), where each byte represents an operation.
59. The EVM is a simple stack-based architecture consisting of the stack, volatile memory, non-volatile storage with a word size of 256-bit (chosen to facilitate the Keccak256 hash scheme and elliptic-curve computations) and Calldata.
60. Stack is made up of 1024 256-bit elements. EVM instructions can operate with the top 16 stack elements. Most EVM instructions operate with the stack (stack-based architecture) and there are also stack-specific operations e.g. PUSH, POP, SWAP, DUP etc.
61. Memory is a linear byte-array addressable at a byte-level and is volatile. All locations are well-defined initially as zero. This is accessed with MLOAD, MSTORE and MSTORE8 instructions.
62. Storage is a 256-bit to 256-bit key-value store. Unlike memory, which is volatile, storage is non-volatile and is maintained as part of the system state. All locations are well-defined initially as zero. This is accessed with SLOAD/SSTORE instructions.
63. Calldata is a read-only byte-addressable space where the data parameter of a transaction or call is held. This is accessed with CALLDATASIZE/CALLDATALOAD/CALLDATACOPY instructions.
64. EVM does not follow the standard von Neumann architecture. Rather than storing program code in generally accessible memory or storage, it is stored separately in a virtual ROM accessible only through a specialized instruction.
65. EVM uses big-endian ordering where the most significant byte of a word is stored at the smallest memory address and the least significant byte at the largest
66. EVM instruction set can be classified into 11 categories:
    1. Stop and Arithmetic Operations
    2. Comparison & Bitwise Logic Operations
    3. SHA3
    4. Environmental Information
    5. Block Information
    6. Stack, Memory, Storage and Flow Operations
    7. Push Operations
    8. Duplication Operations
    9. Exchange Operations
    10. Logging Operations
    11. System Operations
67. Stop and Arithmetic Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x00 STOP 0 0 Halts execution
    2. 0x01 ADD 2 1 Addition operation
    3. 0x02 MUL 2 1 Multiplication operation
    4. 0x03 SUB 2 1 Subtraction operation
    5. 0x04 DIV 2 1 Integer division operation
    6. 0x05 SDIV 2 1 Signed integer division operation (truncated)
    7. 0x06 MOD 2 1 Modulo remainder operation
    8. 0x07 SMOD 2 1 Signed modulo remainder operation
    9. 0x08 ADDMOD 3 1 Modulo addition operation
    10. 0x09 MULMOD 3 1 Modulo multiplication operation
    11. 0x0a EXP 2 1 Exponential operation
    12. 0x0b SIGNEXTEND 2 1 Extend length of two’s complement signed integer
68. Comparison & Bitwise Logic Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x10 LT 2 1 Less-than comparison
    2. 0x11 GT 2 1 Greater-than comparison
    3. 0x12 SLT 2 1 Signed less-than comparison
    4. 0x13 SGT 2 1 Signed greater-than comparison
    5. 0x14 EQ 2 1 Equality comparison
    6. 0x15 ISZERO 1 1 Simple not operator
    7. 0x16 AND 2 1 Bitwise AND operation
    8. 0x17 OR 2 1 Bitwise OR operation
    9. 0x18 XOR 2 1 Bitwise XOR operation
    10. 0x19 NOT 1 1 Bitwise NOT operation
    11. 0x1a BYTE 2 1 Retrieve single byte from word
    12. 0x1b SHL 2 1 Left shift operation
    13. 0x1c SHR 2 1 Logical right shift operation
    14. 0x1d SAR 2 1 Arithmetic (signed) right shift operation
69. SHA3 (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x20 SHA3 2 1 Compute Keccak-256 hash
70. Environmental Information (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x30 ADDRESS 0 1 Get address of currently executing account
    2. 0x31 BALANCE 1 1 Get balance of the given account
    3. 0x32 ORIGIN 0 1 Get execution origination address
    4. 0x33 CALLER 0 1 Get caller address
    5. 0x34 CALLVALUE 0 1 Get deposited value by the instruction/transaction responsible for this execution
    6. 0x35 CALLDATALOAD 1 1 Get input data of current environment
    7. 0x36 CALLDATASIZE 0 1 Get size of input data in current environment
    8. 0x37 CALLDATACOPY 3 0 Copy input data in current environment to memory
    9. 0x38 CODESIZE 0 1 Get size of code running in current environment
    10. 0x39 CODECOPY 3 0 Copy code running in current environment to memory
    11. 0x3a GASPRICE 0 1 Get price of gas in current environment
    12. 0x3b EXTCODESIZE 1 1 Get size of an account’s code
    13. 0x3c EXTCODECOPY 4 0 Copy an account’s code to memory
    14. 0x3d RETURNDATASIZE 0 1 Get size of output data from the previous call from the current environment
    15. 0x3e RETURNDATACOPY 3 0 Copy output data from the previous call to memory
    16. 0x3f EXTCODEHASH 1 1 Get hash of an account’s code
71. Block Information (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x40 BLOCKHASH 1 1 Get the hash of one of the 256 most recent complete blocks
    2. 0x41 COINBASE 0 1 Get the block’s beneficiary address
    3. 0x42 TIMESTAMP 0 1 Get the block’s timestamp
    4. 0x43 NUMBER 0 1 Get the block’s number
    5. 0x44 DIFFICULTY 0 1 Get the block’s difficulty
    6. 0x45 GASLIMIT 0 1 Get the block’s gas limit
72. Stack, Memory, Storage and Flow Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x50 POP 1 0 Remove item from stack
    2. 0x51 MLOAD 1 1 Load word from memory
    3. 0x52 MSTORE 2 0 Save word to memory
    4. 0x53 MSTORE8 2 0 Save byte to memory
    5. 0x54 SLOAD 1 1 Load word from storage
    6. 0x55 SSTORE 2 0 Save word to storage
    7. 0x56 JUMP 1 0 Alter the program counter
    8. 0x57 JUMPI 2 0 Conditionally alter the program counter
    9. 0x58 PC 0 1 Get the value of the program counter prior to the increment corresponding to this instruction
    10. 0x59 MSIZE 0 1 Get the size of active memory in bytes
    11. 0x5a GAS 0 1 Get the amount of available gas, including the corresponding reduction for the cost of this instruction
    12. 0x5b JUMPDEST 0 0 Mark a valid destination for jumps. This operation has no effect on machine state during execution.
73. Push Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x60 PUSH1 0 1 Place 1 byte item on stack
    2. 0x61 PUSH2 0 1 Place 2-byte item on stack
    3. PUSH3, PUSH4, PUSH5…PUSH31 place 3, 4, 5..31 byte items on stack respectively
    4. 0x7f PUSH32 0 1 Place 32-byte (full word) item on stack
74. Duplication Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x80 DUP1 1 2 Duplicate 1st stack item
    2. DUP2, DUP3..DUP15 duplicate 2nd, 3rd..15th stack item respectively
    3. 0x8f DUP16 16 17 Duplicate 16th stack item
75. Exchange Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0x90 SWAP1 2 2 Exchange 1st and 2nd stack items
    2. 0x91 SWAP2 3 3 Exchange 1st and 3rd stack items
    3. SWAP3, SWAP4..SWAP15 exchange 1st and 4th..15th stack items respectively
    4. 0x9f SWAP16 17 17 Exchange 1st and 17th stack items
76. Logging Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0xa0 LOG0 2 0 Append log record with no topics
    2. 0xa1 LOG1 3 0 Append log record with one topic
    3. 0xa2 LOG2 4 0 Append log record with two topics
    4. 0xa3 LOG3 5 0 Append log record with three topics
    5. 0xa4 LOG4 6 0 Append log record with four topics
77. System Operations (Opcode, Mnemonic, Stack items removed, Stack items placed, Description):
    1. 0xf0 CREATE 3 1 Create a new account with associated code
    2. 0xf1 CALL 7 1 Message-call into an account
    3. 0xf2 CALLCODE 7 1 Message-call into this account with an alternative account’s code
    4. 0xf3 RETURN 2 0 Halt execution returning output dat
    5. 0xf4 DELEGATECALL 6 1 Message-call into this account with an alternative account’s code, but persisting the current values for sender and value
    6. 0xf5 CREATE2 4 1 Create a new account with associated code
    7. 0xfa STATICCALL 6 1 Static message-call into an account
    8. 0xfd REVERT 2 0 Halt execution reverting state changes but returning data and remaining gas
    9. 0xfe INVALID ∅ ∅ Designated invalid instruction
    10. 0xff SELFDESTRUCT 1 0 Halt execution and register account for later deletion
78. Gas costs for different instructions are different depending on their computational/storage load on the client. Examples are:
    1. STOP, INVALID and REVERT are 0 gas
    2. Most arithmetic, logic and stack operations are 3-5 gas
    3. CALL*, BALANCE and EXT* are 2600 gas
    4. MLOAD/MSTORE/MSTORE8 are 3 gas
    5. SLOAD is 2100 gas and SSTORE is 20,000 gas to set a storage slot from 0 to non-0 and 5,000 gas otherwise
    6. CREATE is 32000 gas and SELFDESTRUCT is 5000 gas 
79. A transaction reverts for different exceptional conditions such as running out of gas, invalid instructions etc. in which case all state changes made so far are discarded and the original state of the account is restored as it was before this transaction executed.
80. A transaction with a contract address destination has the contract’s function target and the required arguments in the data field of the transaction. These are encoded according to the Application Binary Interface (ABI):
81. Application Binary Interface (ABI): The Contract Application Binary Interface (ABI) is the standard way to interact with contracts in the Ethereum ecosystem, both from outside the blockchain and for contract-to-contract interaction.
    1.  Interface functions of a contract are strongly typed, known at compilation time and static.
    2. Contracts will have the interface definitions of any contracts they call available at compile-time. 
82. Function Selector: The first four bytes of the call data for a function call specifies the function to be called. 
    1. It is the first (left, high-order in big-endian) four bytes of the Keccak-256 hash of the signature of the function. 
    2. The signature is defined as the canonical expression of the basic prototype without data location specifier, i.e. the function name with the parenthesised list of parameter types. Parameter types are split by a single comma - no spaces are used.
    3. Function Arguments: The encoded arguments follow the function selector from the fifth byte onwards.
83. Block explorers: are portals that allow anyone to see real-time data on blocks, transactions, accounts, contract interactions etc. A popular Ethereum block explorer is [etherscan.io](http://etherscan.io/).
84. Mainnet: Short for "main network," this is the main public Ethereum blockchain. There are other Ethereum “testnets” where protocol or smart contract developers test their protocol upgrades or contracts. While mainnet uses real ETH, testnets use test ETH that can be obtained from faucets. The popular testnets are:
    1. Görli: A proof-of-authority (a small number of nodes are allowed to validate transactions and create blocks) testnet that works across clients
    2. Kovan: A proof-of-authority testnet for those running OpenEthereum clients
    3. Rinkeby: A proof-of-authority testnet for those running Geth client
    4. Ropsten: A proof-of-work testnet. This means it's the best representation of mainnet Ethereum
85. Ethereum Improvement Proposals (EIPs) describe standards for the Ethereum platform, including core protocol specifications, client APIs, and contract standards. Standards Track EIPs are separated into a number of types: (See [here](https://eips.ethereum.org/))
    1. Core: Improvements requiring a consensus fork as well as changes that are not necessarily consensus critical but may be relevant to “core dev” discussions
    2. Networking: Includes improvements around devp2p and Light Ethereum Subprotocol, as well as proposed improvements to network protocol specifications of whisper and swarm
    3. Interface: Includes improvements around client API/RPC specifications and standards, and also certain language-level standards like method names and contract ABIs. The label “interface” aligns with the interfaces repo and discussion should primarily occur in that repository before an EIP is submitted to the EIPs repository
    4. ERC: Application-level standards and conventions, including contract standards such as token standards (ERC-20), name registries, URI schemes, library/package formats, and wallet formats 
    5. Meta: Describes a process surrounding Ethereum or proposes a change to (or an event in) a process
    6. Informational: Describes a Ethereum design issue, or provides general guidelines or information to the Ethereum community, but does not propose a new feature
86. Eth2 or Ethereum 2.0: refers to a set of interconnected upgrades that will make Ethereum more scalable, more secure, and more sustainable (See [here](https://ethereum.org/en/eth2/))
87. Immutable code: Once a contract's code is deployed, it becomes immutable (with exceptions noted below). Standard software development practices that rely on being able to fix bugs and add new features to deployed code do not apply here. This represents a significant security challenge for smart contract development. There are three exceptions:
    1. The modified contract can be deployed at a new address (and old state carried over) but all interacting entities should be notified/enabled to interact with the updated contract at the new address. This is typically considered impractical.
    2. The modified contract can be deployed as a new implementation in a proxy pattern where the proxy points to the modified contract after the update. This is the most commonly used approach to update/add functionality.
    3. CREATE2 opcode allows updating in place using init_code
88. Web3: is a permissionless, trust-minimized and censorship-resistant network for transfer of value and information. 
    1. The popular approach to realise Web3 is to build it over a foundation of peer-to-peer network of nodes for compute, communication and storage. 
    2. In the Ethereum ecosystem, this is a combination of the Ethereum blockchain, Waku (previously Whisper) and Swarm respectively. 
    3. Privacy and anonymity are big motivating factors in Web3.
    4. Most of the foundational security design principles and development practices from Web2 still apply to Web3. But Web3 security is indeed a paradigm shift along many frontiers.
89. Languages: Web2 programming languages such as JavaScript, Go, Rust and Nim are used extensively in Web3. But the entire domain of smart contracts is new and specific to Web3. Languages such as Solidity and Vyper were created exclusively for Web3.
90. On-chain vs Off-chain: Smart contracts are “on-chain” Web3 components and they interact with “off-chain” components that are very similar to Web2 software. So the major differences in security perspectives between Web3 and Web2 mostly narrow down to security considerations of smart contracts vis-a-vis Web2 software.
91. Open-source & Transparent: Given the emphasis on trust-minimization, Web3 software, especially smart contracts, are expected to be open-source by default. 
    1. The deployed bytecode is also expected to be source code verified (on a service such as Etherscan). Security by obscurity with proprietary code is not part of Web3's ethos.
    2. All interactions with smart contracts are recorded on the blockchain as transactions. This includes the transactions’ senders, data and outcome. Having complete visibility into the entire history of transactions and state transitions is akin to having a publicly accessible audit log of a system since inception. 
    3. Furthermore, transactions that are still “in flight” and are yet to be confirmed on the blockchain are also publicly visible in pending transaction queues (i.e. mempools) and lend to front-running attacks.
92. Unstoppable & Immutable: Web3 applications, popularly known as Decentralized Applications ( ÐApps), are expected to be unstoppable and immutable because they run on a decentralized blockchain network. 
    1. There should not be any one entity that can unilaterally decide to stop a running ÐApp or make changes to it. Transactions and data on the blockchain are guaranteed to be immutable unless a majority of the network decides otherwise. 
    2. Smart contracts, in general, are expected (by users) to not have kill switches controlled by deployers. They are also expected to not be arbitrarily upgradeable. Both these stem from the Web3 goal of trust-minimization, i.e. lack of need to trust potentially malicious ÐApp developers. However, this makes fixing security vulnerabilities in deployed code and responding to exploits very challenging.
93. Pseudonymous Teams & DAOs: Perhaps inspired by Bitcoin’s Satoshi Nakamoto, there is a trend among some project teams in Web3 to be pseudonymous and known only by their online handles. 
    1. One reason for this could be to avoid any potential legal implications in future, given the regulatory uncertainty in this space. This makes it harder to associate any social reputation as it pertains to perceived security trustworthiness of the product or the processes behind its development. It also makes it tricky to hold anyone legally/socially liable or accountable. 
    2. “Trust software not wetware” (i.e. people) is the mantra here. While this may be an extreme view, there are still social processes around rollout and governance of projects which affect security posture. 
    3. To minimise the role and influence of a few privileged individuals in the lifecycle of projects, there is an increasing trend towards governance by token-holding community members — a Decentralized Autonomous Organization (DAO) of pseudonymous token-holding blockchain addresses making voting-based decisions on project treasury spending and protocol changes. While this reduces centralized points of wetware failure, it potentially slows down decision-making on security-critical aspects and may even lead to project forks.
94. New Architecture, Language & Toolchains: Ethereum has a new virtual machine (EVM) architecture which is a stack-based machine with 256-bit words and associated gas semantics. 
    1. Solidity language continues to dominate smart contracts without much real competition (except Vyper perhaps). 
    2. The associated toolchains which include development environments (e.g. Truffle, Brownie, Hardhat), libraries (e.g. OpenZeppelin), security tools (e.g. Slither, MythX, Securify) and wallets (e.g. Metamask) are maturing but still playing catch up to the exponential growth of the space.
95. Byzantine Threat Model: The Web3 threat model is based on byzantine faults dealing with arbitrary malicious behavior and governed by mechanism design. 
    1. Given the aspirational absence of trusted intermediaries, everyone and everything is meant to be untrusted by default. Participants in this model include developers, miners/validators, infrastructure providers and users, all of whom could potentially be adversaries.
    2. This is a fundamentally different threat model from that of Web2 where there are generalized notions of trusted insiders with authorized access to resources/assets that have to be protected against untrusted outsiders (and malicious insiders). Web3 is the ultimate zero-trust scenario.
96. Keys & Tokens: While “crypto” may indeed mean cryptocurrencies to some non-technical observers, it factually refers to cryptography which is a fundamental bedrock of Web3. As much as we unknowingly use cryptography in the Web2 world, Web3 is taking it to the masses. Cryptographic keys are first-class members of the Web3 world.
    1. Without the presence of Web2 trusted intermediaries who can otherwise reset passwords or restore accounts/assets from their centralized databases, Web3 ideologically pushes the onus of managing keys (and the assets they control) to end users in their wallets. Loss of private keys (or seed phrases) is irreversible and many assets have been lost to such incidents. This is a significant mindset shift from the Web2 world where passwords have become far too common, security pundits are tired of bemoaning the use of commonly reused simple passwords, password databases continue to be dumped and password-killing technologies continue to evade us. Web2 passwords here symbolize the role of trusted centralized intermediaries that Web3 is seeking to replace.
    2. Web2 security breaches targeting financial assets (i.e. excluding ransomware and botnets for DDoS) typically involve stealing of financial or personal data which is then sold on the dark web and used for monetary gain. This is getting much harder because of various checks and measures (both technical and regulatory) being put in place (at centralized intermediaries) to reduce such cybersecurity incidents and prevent anomalous asset transfers. When such unauthorised asset transfers do happen, the involved intermediaries may even cooperate to reverse such transactions and make good.
    3. The notion of assets in Web3 is fundamentally different. Cryptoassets are borderless digital tokens whose accounting ledger is managed by consensus on the blockchain and ownership is determined by access to corresponding cryptographic keys. If someone gets access to your private keys controlling cryptoassets, they can transfer those assets to blockchain addresses controlled by their keys. In a perfectly decentralized world, no intermediary (e.g. centralized exchange) should exist that can reverse such a loss — transactions are immutable. Because there are limited response options, preventive security measures become more critical in the Web3 space.
97. Composability by Design: Permissionless innovation and censorship-resistance are core aspirational goals of Web3. 
    1. There are numerous stories of Web2 companies that initially enticed developers to build on their platforms only to shut them out later when they were perceived as a competitive threat.
    2. Web3 applications, especially smart contracts, are open by design and can be accessed permissionlessly by end users and other smart contracts alike. 
    3. This composability lends itself to applications that can be layered on top of others like legos, which is great if everything holds up and new lego toys are reliably built on others. However, this unconstrained composability introduces unexpected cross-systemic dependencies that may trigger invalid assumptions across components (likely built by different teams with different constraints in mind) and expose attack surfaces or modes previously unconsidered. 
    4. This makes characterizing Web3 vulnerabilities and exploit scenarios very challenging without deep knowledge of all interacting components, constraints and configurations.
98. Compressed Timescales: It feels like innovation in the Web3 space moves at warp speed. Aspects of transparent-development and composability-by-design are strong catalysts to accelerating permissionless and borderless participation which is further incentivized by Internet-native cryptoeconomic tokens — a perfect storm. 
    1. This shrinks innovation timescales by orders of magnitude where new waves of experiments happen over weeks or months instead of the years it typically takes within the walled gardens of Web2. It may seem like the only moat here is the speed of execution.
    2. This compressed timescale has a tangible impact on security considerations during design, development and deployment. Corners are cut and shortcuts taken to ride new waves of hype. The end result is a poorly tested system that holds millions of dollars worth of tokens but is vulnerable to exploits.
99. Test-in-Prod: A combination of compressed timescale, unrestricted composability, byzantine threat model and challenges of replicating full state for predicting failure modes of interacting components built with rapidly evolving experimental software/tools in many ways forces realistic testing to happen only in production, i.e. on the “mainnet”. This implies that complex technical and cryptoeconomic exploits may only be discoverable upon production deployment.
100. Audit-as-a-Silver-Bullet: Secure Software Development Lifecycle (SSDLC) processes for Web2 products have evolved over several decades to a point where they are expected to meet some minimum requirements of a combination of internal validation, external assessments (e.g. product/process audits, penetration testing) and certifications depending on the value of managed assets, anticipated risk, threat model and the market domain of products (e.g. financial sector has stricter regulatory compliance requirements).
101. Web3 projects seem to increasingly rely on external audits as a stamp of security approval. This is typically justified by the lack of sufficient in-house security expertise. While the optics of this approach seems to falsely convince speculators, this approach is untenable for several reasons: 
     1. Audits currently are very expensive because demand is much greater than supply for top-rated audit teams that have the experience and reputation to analyze complex projects
     2. Audits are typically commissioned once at the end of project development just before production release
     3. Upgrades to projects go unaudited for commercial or logistical reasons
     4. The expectation (from the project team and users) is that audits are a panacea for all vulnerabilities and that the project is “bug-free” after a short audit (typically few weeks)

**References**:

1. https://ethereum.org/en/whitepaper/
2. https://ethereum.github.io/yellowpaper/paper.pdf
3. https://github.com/ethereumbook/ethereumbook
4. https://ethereum.org/en/developers/docs/
5. https://ethereum.org/en/glossary/
6. https://docs.soliditylang.org/
7. https://preethikasireddy.medium.com/how-does-ethereum-work-anyway-22d1df506369
8. https://takenobu-hs.github.io/downloads/ethereum_evm_illustrated.pdf
