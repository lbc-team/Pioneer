> * 来源：https://medium.com/@chiqing/merkle-patricia-trie-explained-ae3ac6a7e123

# Ethereum Merkle Patricia Trie Explained



## Introduction

Merkle Patricia Trie is one of the key data structures for the Ethereum’s storage layer. I wanted to understand how exactly it works. So I did a deep research on all the materials I could find and implemented the algorithm myself.

In this block post, I’ll share what I have learned. Explain how exactly Merkle Patricia Trie works, and show you a demo of how a merkle proof is generated and verified.

The source code of the algorithm and the examples used in this blog post are all open sourced.
https://github.com/zhangchiqing/merkle-patricia-trie

OK, let’s get started.

## A basic key-value mapping

Ethereum’s Merkle Patricia Trie is essentially a key-value mapping that provides the following standard methods:

```
type Trie interface {
  // methods as a basic key-value mapping
  Get(key []byte) ([]byte, bool) {
  Put(key []byte, value []byte)
  Del(key []byte, value []byte) bool
}
```
An implementation of the above Trie interface should pass the following test cases:

```
func TestGetPut(t *testing.T) {
	t.Run("should get nothing if key does not exist", func(t *testing.T) {
		trie := NewTrie()
		_, found := trie.Get([]byte("notexist"))
		require.Equal(t, false, found)
	})

	t.Run("should get value if key exist", func(t *testing.T) {
		trie := NewTrie()
		trie.Put([]byte{1, 2, 3, 4}, []byte("hello"))
		val, found := trie.Get([]byte{1, 2, 3, 4})
		require.Equal(t, true, found)
		require.Equal(t, val, []byte("hello"))
	})

	t.Run("should get updated value", func(t *testing.T) {
		trie := NewTrie()
		trie.Put([]byte{1, 2, 3, 4}, []byte("hello"))
		trie.Put([]byte{1, 2, 3, 4}, []byte("world"))
		val, found := trie.Get([]byte{1, 2, 3, 4})
		require.Equal(t, true, found)
		require.Equal(t, val, []byte("world"))
	})
}
```

(Test cases in this tutorial are included [in the repo](https://github.com/zhangchiqing/merkle-patricia-trie) and passed.)

## Verify Data Integrity

What is merkle patricia trie different from a standard mapping?

Well, merkle patricia trie allows us to verify data integrity. (For the rest of this tutorial, we will call it trie for simplicity)

One can compute the Merkle Root Hash of the trie with the `Hash` function, such that if any key-value pair was updated, the merkle root hash of the trie would be different; if two Tries have the identical key-value pairs, they should have the same merkle root hash.

```
type Trie interface {
  // compute the merkle root hash for verifying data integrity
  Hash() []byte
}
```

Let’s explain this behavior with some test cases:

```
// verify data integrity
func TestDataIntegrity(t *testing.T) {
	t.Run("should get a different hash if a new key-value pair was added or updated", func(t *testing.T) {
		trie := NewTrie()
		hash0 := trie.Hash()

		trie.Put([]byte{1, 2, 3, 4}, []byte("hello"))
		hash1 := trie.Hash()

		trie.Put([]byte{1, 2}, []byte("world"))
		hash2 := trie.Hash()

		trie.Put([]byte{1, 2}, []byte("trie"))
		hash3 := trie.Hash()

		require.NotEqual(t, hash0, hash1)
		require.NotEqual(t, hash1, hash2)
		require.NotEqual(t, hash2, hash3)
	})

	t.Run("should get the same hash if two tries have the identicial key-value pairs", func(t *testing.T) {
		trie1 := NewTrie()
		trie1.Put([]byte{1, 2, 3, 4}, []byte("hello"))
		trie1.Put([]byte{1, 2}, []byte("world"))

		trie2 := NewTrie()
		trie2.Put([]byte{1, 2, 3, 4}, []byte("hello"))
		trie2.Put([]byte{1, 2}, []byte("world"))

		require.Equal(t, trie1.Hash(), trie2.Hash())
	})
}
```

## Verify the inclusion of a key-value pair

Yes, the trie can verify data integrity, but why not simply comparing the hash by hashing the entire list of key-value pairs, why bother creating a trie data structure?

That’s because trie also allows us to verify the inclusion of a key-value pair without the access to the entire key-value pairs.

That means trie can provide a proof to prove that a certain key-value pair is included in a key-value mapping that produces a certain merkle root hash.

```
type Proof interface {}

type Trie interface {
  // generate a merkle proof for a key-value pair for verifying the inclusion of the key-value pair
  Prove(key []byte) (Proof, bool)
}

// verify the proof for the given key with the given merkle root hash
func VerifyProof(rootHash []byte, key []byte, proof Proof) (value []byte, err error)
```

This is useful in Ethereum. For instance, imagine the Ethereum world state is a key-value mapping, and the keys are each account address, and the values are the balances for each account.

As a light client, which don’t have the access to the full blockchain state like full nodes do, but only the merkle root hash for certain block, how can it trust the result of its account balance returned from a full node?

The answer is, a full node can provide a merkle proof which contains the merkle root hash, the account key and its balance value, as well as other data. This merkle proof allows a light client to verify the correctness by its own without having access to the full blockchain state.

Let’s explain this behavior with test cases:

```
func TestProveAndVerifyProof(t *testing.T) {
	t.Run("should not generate proof for non-exist key", func(t *testing.T) {
		tr := NewTrie()
		tr.Put([]byte{1, 2, 3}, []byte("hello"))
		tr.Put([]byte{1, 2, 3, 4, 5}, []byte("world"))
		notExistKey := []byte{1, 2, 3, 4}
		_, ok := tr.Prove(notExistKey)
		require.False(t, ok)
	})

	t.Run("should generate a proof for an existing key, the proof can be verified with the merkle root hash", func(t *testing.T) {
		tr := NewTrie()
		tr.Put([]byte{1, 2, 3}, []byte("hello"))
		tr.Put([]byte{1, 2, 3, 4, 5}, []byte("world"))

		key := []byte{1, 2, 3}
		proof, ok := tr.Prove(key)
		require.True(t, ok)

		rootHash := tr.Hash()

		// verify the proof with the root hash, the key in question and its proof
		val, err := VerifyProof(rootHash, key, proof)
		require.NoError(t, err)

		// when the verification has passed, it should return the correct value for the key
		require.Equal(t, []byte("hello"), val)
	})

	t.Run("should fail the verification if the trie was updated", func(t *testing.T) {
		tr := NewTrie()
		tr.Put([]byte{1, 2, 3}, []byte("hello"))
		tr.Put([]byte{1, 2, 3, 4, 5}, []byte("world"))

		// the hash was taken before the trie was updated
		rootHash := tr.Hash()

		// the proof was generated after the trie was updated
		tr.Put([]byte{5, 6, 7}, []byte("trie"))
		key := []byte{1, 2, 3}
		proof, ok := tr.Prove(key)
		require.True(t, ok)

		// should fail the verification since the merkle root hash doesn't match
		_, err := VerifyProof(rootHash, key, proof)
		require.Error(t, err)
	})
}
```


A light client can ask for a merkle root hash of the trie state, and use it to verify the balance of its account. If the trie was updated, even if the updates was to other keys, then the verification would fail.

And now, the light client only needs to trust the merkle root hash, which is a small piece of data, to convince themselves whether the full node returned the correct balance for its account.

OK, but why should the light client trust the merkle root hash?

Since Ethereum’s consensus mechanism is Proof of Work, and the merkle root hash for the world state is included in each block head, the computation work is the proof for verifying/trusting the merkle root hash.

It’s pretty cool that small as the merkle root hash can be used to verify the state of a giant key-value mapping.

## Verify the implementation

I’ve explained how merkle patricia trie works. [This repo](https://github.com/zhangchiqing/merkle-patricia-trie) provides a simple implementation. But, how can we verify our implementation?

An easy way is to verify with the Ethereum mainnet data and the official Trie golang implementation.

Ethereum has 3 Merkle Patricia Tries: Transaction Trie, Receipt Trie and State Trie. In each block header, it includes the 3 merkle root hashes: `transactionRoot`, `receiptRoot` and the `stateRoot`.

Since the `transactionRoot` is the merkle root hash of all the transactions included in the block, we could verify our implementation by taking all the transactions, then store them in our trie, compute its merkle root hash, and in the end compare it with the `transactionRoot` in the block header.

For instance, I picked the [block 10467135 on mainnet](https://etherscan.io/block/10467135), and saved all the 193 transactions into a [transactions.json](https://github.com/zhangchiqing/merkle-patricia-trie/blob/master/transactions.json) file.

Since the transaction root for block `10467135` is `[0xbb345e208bda953c908027a45aa443d6cab6b8d2fd64e83ec52f1008ddeafa58](https://api.etherscan.io/api?module=proxy&action=eth_getBlockByNumber&tag=0x9fb73f&boolean=true&apikey=YourApiKeyToken)`. I can create a test case that adds the 193 transactions of block 10467135 to our Trie and check:

* Whether the merkle root hash is `bb345e208bda953c908027a45aa443d6cab6b8d2fd64e83ec52f1008ddeafa58`.
* Whether a merkle proof for a certain transaction generated from our trie implementation could be verified by the official implementation.

But what would be the keys and values for the list of transactions? The keys are the RLP encoding of a unsigned integer starting from index 0; the values are the RLP encoding of the corresponding transactions.

OK, let’s see the test cases:

```
import (
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/trie"
)
// use the official golang implementation to check if a valid proof from our implementation can be accepted
func VerifyProof(rootHash []byte, key []byte, proof Proof) (value []byte, err error) {
	return trie.VerifyProof(common.BytesToHash(rootHash), key, proof)
}
// load transaction from json
func TransactionJSON(t *testing.T) *types.Transaction {
	jsonFile, err := os.Open("transaction.json")
	defer jsonFile.Close()
	require.NoError(t, err)
	byteValue, err := ioutil.ReadAll(jsonFile)
	require.NoError(t, err)
	var tx types.Transaction
	json.Unmarshal(byteValue, &tx)
	return &tx
}
func TestTransactionRootAndProof(t *testing.T) {
	trie := NewTrie()
	txs := TransactionsJSON(t)
	for i, tx := range txs {
		// key is the encoding of the index as the unsigned integer type
		key, err := rlp.EncodeToBytes(uint(i))
		require.NoError(t, err)
		transaction := FromEthTransaction(tx)
		// value is the RLP encoding of a transaction
		rlp, err := transaction.GetRLP()
		require.NoError(t, err)
		trie.Put(key, rlp)
	}
	// the transaction root for block 10467135
	// https://api.etherscan.io/api?module=proxy&action=eth_getBlockByNumber&tag=0x9fb73f&boolean=true&apikey=YourApiKeyToken
	transactionRoot, err := hex.DecodeString("bb345e208bda953c908027a45aa443d6cab6b8d2fd64e83ec52f1008ddeafa58")
	require.NoError(t, err)
	t.Run("merkle root hash should match with 10467135's transactionRoot", func(t *testing.T) {
		// transaction root should match with block 10467135's transactionRoot
		require.Equal(t, transactionRoot, trie.Hash())
	})
	t.Run("a merkle proof for a certain transaction can be verified by the offical trie implementation", func(t *testing.T) {
		key, err := rlp.EncodeToBytes(uint(30))
		require.NoError(t, err)
		proof, found := trie.Prove(key)
		require.Equal(t, true, found)
		txRLP, err := VerifyProof(transactionRoot, key, proof)
		require.NoError(t, err)
		// verify that if the verification passes, it returns the RLP encoded transaction
		rlp, err := FromEthTransaction(txs[30]).GetRLP()
		require.NoError(t, err)
		require.Equal(t, rlp, txRLP)
	})
}
```

The above test cases passed, and showed if we add all the 193 transactions of block 10467135 to our trie, then the trie hash is the same as the transactionRoot published in that block. And the merkle proof for the transaction with index 30, generated by our trie, is considered valid by official golang trie implementation.

## Merkle Patricia Trie Internal — Trie Nodes

Now, let’s take a look at the internal of the trie.

Internally, the trie has 4 types of nodes: EmptyNode, LeafNode, BranchNode and ExtensionNode. Each node will be encoded and stored as key-value pairs in the a key-value store.

As an example, let’s take at Block [10593417](https://etherscan.io/block/10593417) on mainnet to show how a transaction trie was built and how is it stored.

[Block 10593417](https://etherscan.io/block/10593417) only has 4 transactions with the transactionRoot hash: [0xab41f886be23cd786d8a69a72b0f988ea72e0b2e03970d0798f5e03763a442cc](https://api.etherscan.io/api?module=proxy&action=eth_getBlockByNumber&tag=0xa1a489&boolean=true&apikey=YourApiKeyToken). So to store the 4 transactions to a trie, we are actually storing the following key-value pairs in hex-string form:

```
(80, f8ab81a5852e90edd00083012bc294a3bed4e1c75d00fa6f4e5e6922db7261b5e9acd280b844a9059cbb0000000000000000000000008bda8b9823b8490e8cf220dc7b91d97da1c54e250000000000000000000000000000000000000000000000056bc75e2d6310000026a06c89b57113cf7da8aed7911310e03d49be5e40de0bd73af4c9c54726c478691ba056223f039fab98d47c71f84190cf285ce8fc7d9181d6769387e5efd0a970e2e9)
(01, f8ab81a6852e90edd00083012bc294a3bed4e1c75d00fa6f4e5e6922db7261b5e9acd280b844a9059cbb0000000000000000000000008bda8b9823b8490e8cf220dc7b91d97da1c54e250000000000000000000000000000000000000000000000056bc75e2d6310000026a0d77c66153a661ecc986611dffda129e14528435ed3fd244c3afb0d434e9fd1c1a05ab202908bf6cbc9f57c595e6ef3229bce80a15cdf67487873e57cc7f5ad7c8a)
(02, f86d8229f185199c82cc008252089488e9a2d38e66057e18545ce03b3ae9ce4fc360538702ce7de1537c008025a096e7a1d9683b205f697b4073a3e2f0d0ad42e708f03e899c61ed6a894a7f916aa05da238fbb96d41a4b5ec0338c86cfcb627d0aa8e556f21528e62f31c32f7e672)
(03, f86f826b2585199c82cc0083015f9094e955ede0a3dbf651e2891356ecd0509c1edb8d9c8801051fdc4efdc0008025a02190f26e70a82d7f66354a13cda79b6af1aa808db768a787aeb348d425d7d0b3a06a82bd0518bc9b69dc551e20d772a1b06222edfc5d39b6973e4f4dc46ed8b196)
```

`80` is the hex form of the bytes from the result of RLP encoding of unsigned integer 0: `RLP(uint(0))`. `01` is the result of `RLP(uint(1))`, and so on.

The value for key `80` is the result of RLP encoding of the first transaction. The value for key `01` is for the second transaction, and so on.

So we will add the above 4 key-value pairs to the trie, and let’s see how the internal structure of the trie changes when adding each of them.

To be more intuitive, I will use some diagrams to explain how it works. You could also inspect the state of each step by adding logs to the test cases.

## Empty Trie

The trie structure contains only a root field pointing to a root node. And the Node type is an interface, which could be one of the 4 types of nodes.

```
type Trie struct {
	root Node
}
```

When a trie is created, the root node points to an EmptyNode.

![](https://img.learnblockchain.cn/2020/12/21/16085222358705.jpg)


## Adding the 1st transaction

When adding the key-value pair of the 1st transaction, a LeafNode is created with the transaction data stored in it. And the root node is updated to point to that LeafNode.


![](https://img.learnblockchain.cn/2020/12/21/16085223503829.jpg)



## Adding the 2nd transaction

When adding the 2nd transaction, the LeafNode at the root will be turned into a BranchNode with two branches pointing to the 2 LeafNodes. The LeafNode on the right side holds the remaining nibbles (nibbles are a single hex character) — `1`, and the value for the 2nd transaction.

And now the root node is pointing to the new BranchNode.

![](https://img.learnblockchain.cn/2020/12/21/16085224360843.jpg)

![](https://img.learnblockchain.cn/2020/12/21/16085225210822.jpg)



## Adding the 3rd transaction

Adding the 3rd transaction will turn the LeafNode on the right side to be a BranchNode, similar to the process of adding the 2nd transaction. Although the root node didn’t change, its root hash has been changed, because it’s `0` branch is pointing to a different node with different hashes.

![](https://img.learnblockchain.cn/2020/12/21/16085229209601.jpg)

![](https://img.learnblockchain.cn/2020/12/21/16085229929255.jpg)


## Adding the 4th transaction

Adding the last transaction is similar to adding the 3rd transaction. Now we can verify the root hash is identical to the transactionRoot included in the block.


![](https://img.learnblockchain.cn/2020/12/21/16085231121900.jpg)

![](https://img.learnblockchain.cn/2020/12/21/16085232340057.jpg)







## Getting Merkle Proof for the 3rd transaction

The Merkle Proof for the 3rd transaction is simply the path to the LeafNode that stores the value of the 3rd transaction. When verifying the proof, one can start from the root hash, decode the Node, match the nibbles, and repeat until find the Node that matches all the remaining nibbles. If found, then the value is the one paired with the key; if not found, then the merkle proof is invalid.

## The rule of updating the trie

In the above example, we’ve built a trie with 3 types of Nodes: EmptyNode, LeafNode and BranchNode. However, we didn’t have the chance to use ExtensionNode. Please find other test cases that use the ExtensionNode.

In general, the rule is:

* When stopped at an EmptyNode, replace it with a new LeafNode with the remaining path.
* When stopped at a LeafNode, convert it to an ExtensionNode and add a new branch and a new LeafNode.
* When stopped at an ExtensionNode, convert it to another ExtensionNode with shorter path and create a new BranchNode points to the ExtensionNode.

There are quite some details, if you are interested, you can read the [source code](https://github.com/zhangchiqing/merkle-patricia-trie/blob/master/trie.go#L62).

## Summary

Merkle Patricia Trie is a data structure that stores key-value pairs, just like a map. In additional to that, it also allows us to verify data integrity and the inclusion of a key-value pair.









