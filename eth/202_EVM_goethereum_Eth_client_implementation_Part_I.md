# Dissecting EVM using go-ethereum Eth client implementation. Part I — transaction execution flow

![img](https://img.learnblockchain.cn/attachments/2023/06/TguuwOn56487e48f5cb8f.jpeg)

Photo by [Shubham Dhage](https://unsplash.com/@theshubhamdhage?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com/?utm_source=medium&utm_medium=referral)

This article describes EVM, if you’re interested in reading about the rest of the flow – from sending a transaction, up to transaction execution, this article is superb:

https://www.notonlyowner.com/learn/what-happens-when-you-send-one-dai

If you want to get to other parts of this article, here they are:

- [Part II — EVM](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-ii-evm-ce7653f31c6f)
- [Part III — bytecode interpreter](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-iii-bytecode-interpreter-8f144004ed7a)

I overheard people talking about “call context” in Solidity recently, so I chimed in to discuss about it briefly, however I believe that it this topic needs some broader explanation, as not many people know how it really works. When starting to write about it, I realized that the topic of transaction execution is not discussed anywhere, I’ll describe it here, to raise awareness in the space.

I don’t know about you dear reader, but I hate reading research papers. They are overly complex, introduce inhuman scribbles called “scientific notation” and are pain to read. So, I won’t go through Ethereum yellow paper, but rather we’ll go deep into go-ethereum - Ethereum execution client implementation in Go language. But before we start, I’d like to point out to several important ideas from Go (or golang), that may be tricky to understand if you didn’t have any previous exposure to the language, that will be required to fully understand the concepts I’m about to describe:

1. Go is ( just kinda) object oriented

If you come from any mainstream programming language (Solidity included), you know about OOP. In short — you have classes, which are templates of “real world objects” having state and behavior, that are at the core. Then you may either compose them into other classes (has-a relation), or introduce inheritance (is-a relation) to extract out common state and behavior into common ancestor. The closest thing to classes in Go are structs and interfaces compound:

- struct — a typed collection of fields — defines state. Works just like structs in Solidity.
- interface — named collections of method signatures — defines behavior. Works just like interfaces in Solidity.

You can imitate a class in Go by making a struct implement all interface functions. Yep, I know it’s a bit mind boggling, so let’s see how it works in the code. The best example of this may be found in [Go by example — interface](https://gobyexample.com/interfaces) section:

```
type geometry interface { // it's an interface, functions just as you think it does
    area() float64
    perim() float64
}

// For our example we’ll implement this interface on rect and circle types.

type rect struct {
    width, height float64
}
type circle struct {
    radius float64
}
type circle struct {
    geometry // this strange notation means that this struct contains everything
             // what geometry does, which is both of the functions in this case
    radius float64
}

// To implement an interface in Go, we just need to implement all the methods in the interface. Here we implement geometry on rects.

func (r rect) area() float64 { // this is how you define a behavior part of a "class" in Go
    return r.width * r.height
}
func (r rect) perim() float64 {
    return 2*r.width + 2*r.height
}

// The implementation for circles.

// mind the "(c circle)" part here. "c" in this case is treated as "this" or "self"
// from other programing languages. So you can read this function definition as:
// "function area defined on struct type circle takes on parameters and returns float64"
func (c circle) area() float64 {
    // in Java/JS it would be math.Pi * this.radius * this.radius
    return math.Pi * c.radius * c.radius
}
func (c circle) perim() float64 {
    return 2 * math.Pi * c.radius
}

// this is constructor pattern in Go - there is no concept of a "construcor" built-in.
// * and & are not important to understand, treat it as more efficient way
// of passing complex types around, or if you reallt want to dig into it,
// search for "golang pointer"
func NewCircle(_radius float64) *circle {
  return &rect{radius: _radius}
}

// If a variable has an interface type, then we can call methods that are in the named interface. Here’s a generic measure function taking advantage of this to work on any geometry.

func measure(g geometry) {
    fmt.Println(g)
    fmt.Println(g.area())
    fmt.Println(g.perim())
}

func main() {
    r := rect{width: 3, height: 4}
    c := circle{radius: 5}

// The circle and rect struct types both implement the geometry interface so we can use instances of these structs as arguments to measure.

    measure(r)
    measure(c)
}
```

And when it comes to inheritance, well… There is none. So most of the time it’s worked around by composing multiple structs/interfaces.

If you’d like to know more about it, here’s official Go FAQ about just it:

## Frequently Asked Questions (FAQ) — The Go Programming Language

### At the time of Go’s inception, only a decade ago, the programming world was different from today. Production software…

go.dev

2. Go modules are annoying

All mainstream languages have concept of modules/packages that can be imported into your file. Usually package/module is used in tandem with specific file from it uniformly identifies place from where you import specific code. If you import your own code, you put a path to the specific imported file. It makes it really easy to trace the execution flow. But Go does it differently — Go modules can span across multiple files, and don’t need to have any name relation. Damn, you can even import a module directly from GitHub repo source code. So, if you don’t have an IDE with good code indexing capabilities (yes, I’m looking at all of you, except for Goland), you’ll question your life when looking at huge Go codebases. Code snippet below shows exemplary package layout:

```
// file src/dir1/f1.go
package fish
...

// file src/dir1/f2.go
package fish

import (
 "math/big" // standard lib

 "mycompany.com/cat" // my local lib cat from src/dir2/f1.go . No relation to import location
)
...

// file src/dir2/f1.go
package fish

import (
 "github.com/ethereum/go-ethereum/common" // this takes code from current master branch from GH :-O
)
...

// file src/dir2/f1.go
package cat // as you can see, dir2 contains multiple modules, with no connection between file name and package
...
```

3. Go doesn’t have a notion of “throwing” errors

Of course Go introduces the concept of an error, but it works differently than in other languages.

Again, I’ll use modified code snippet from [Go by example](https://gobyexample.com/errors):

```
// By convention, errors are the last return value and have type error, a built-in interface.

func f1(arg int) (int, error) {
    if arg == 42 {

// errors.New constructs a basic error value with the given error message.
        return -1, errors.New("can't work with 42")
    }

// A nil value in the error position indicates that there was no error.
    return arg + 3, nil
}

func main() {
    // this is how you're supposed to handle errors in Go
    if r, e := f1(42); e != nil {
        fmt.Println("f1 failed:", e)
    } else {
        fmt.Println("f1 worked:", r)
    }
}
```

As you can see, errors just implement *error* interface, and are passed around as the last parameter of the function. However, the language itself does not enforce that, it’s treated as a good practice.

4. Go struct elements may define metadata

It’s not really specific to Go. TypeScript calls them “decorators”, Java calls them “annotations”. This is just a way to give some additional attributes to a type, that can be useful in certain situations, mostly some external libraries allowing for almost effortless integration. Here’s an example from a Go code I wrote some time ago, defining how struct elements should be named when converted to JSON and what special DB attributes they have when dealing with Gorm DB library:

```
type PurchaseOrder struct {
 Id      uint      `json:"id" gorm:"primaryKey"`
 UserId  string    `json:"userId"`
 Product []Product `json:"product" gorm:"foreignKey:Id"`
 Date    time.Time `json:"date"`
}
```

5. Go introduced generics just recently…

…, so not many codebases migrated to it. In case you don’t know what “generics” are, those are generic functions defined over arbitrary type parameters. This means that you can extract away common code patterns over similar types writing it only once. For more information you can check out [Go by example](https://gobyexample.com/generics). Actually, you won’t find generics in geth code, but I wanted to write about it to limit amount of WTFs per second you have when seeing code duplicate there, asking yourself “why didn’t they just use generics here?”.

![img](https://miro.medium.com/v2/resize:fit:540/1*oipjIWSY_mkD88krRyu8cA.png)

https://commadot.com/wtf-per-minute/

As a side note, I’ll just add that Go generics are superb to most other languages, reminding me of [algebraic data types](https://en.wikipedia.org/wiki/Algebraic_data_type) from functional programming languages, specifically Haskell.

6. Go has it’s own version of “finally”

Other languages have an option to indicate that they want for something to happen at the end, usually it’s called “finally” block. Go uses `defer` keyword, which accepts a function as a parameter and promises to execute it at the end of the block it’s contained in:

```
func main() {
    // Immediately after getting a file object with createFile, we defer the closing of that file with closeFile. This will be executed at the end of the enclosing function (main), after writeFile has finished.
    f := createFile("/tmp/defer.txt")
    defer closeFile(f)
    writeFile(f)
}
```

BTW, if you’d like to give Go a try, you can check out my [github repo](https://github.com/deliriusz/supply-chain/tree/master/backend) containing simple Go Web2/Web3 backend implementation.

Having most important topics concerning Go laid out, we can move to actual execution flow. I’ll go over networking and transaction propagation just briefly, as this is really not interesting from the execution point of view. Whole flow starts with user sending a signed transaction. Under the hood, a JSON-RPC call over HTTP(S) is send. Then, the transaction is propagated to other Ethereum nodes and put in mempool waiting to be processed.

Because EVM is on very high level “just” a state machine, changing its state with every incoming transaction, let’s start with looking at state change processing using go-ethereum [v1.11.5](https://github.com/ethereum/go-ethereum/tree/v1.11.5) as a basis for our exploration.

When mentioning state change, I could not skip the most important part — database. Main client interface for it is located at [**core/state/statedb.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/state/statedb.go). It’s an abstraction over underlying LevelDB, providing all the goodies you need to run your EVM business:

```
type StateDB interface {
 CreateAccount(common.Address)

 SubBalance(common.Address, *big.Int)
 AddBalance(common.Address, *big.Int)
 GetBalance(common.Address) *big.Int

 GetNonce(common.Address) uint64
 SetNonce(common.Address, uint64)

 GetCodeHash(common.Address) common.Hash
 GetCode(common.Address) []byte
 SetCode(common.Address, []byte)
 GetCodeSize(common.Address) int
 ...

 GetCommittedState(common.Address, common.Hash) common.Hash
 GetState(common.Address, common.Hash) common.Hash
 SetState(common.Address, common.Hash, common.Hash)
 ...
 // Exist reports whether the given account exists in state.
 // Notably this should also return true for suicided accounts.
 Exist(common.Address) bool
 // Empty returns whether the given account is empty. Empty
 // is defined according to EIP161 (balance = nonce = code = 0).
 Empty(common.Address) bool
 ...
 RevertToSnapshot(int)
 Snapshot() int

 AddLog(*types.Log)
 ...
}
```

I skipped some of the functions offered, that are not useful for this article. Please take a look at *RevertToSnapshot* and *Snapshot* functions. Those two do all the heavy lifting concerning state management. We’ll discuss it in details in the Part II of this article, when we’ll deal with call context.

The main part of the execution flow is [**core/state_processor.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/state_processor.go), responsible for processing all the transactions in a block and returning the receipts and logs, modifying StateDB in the process. Let’s see how it’s defined and then discuss it:

```
func (p *StateProcessor) Process(block *types.Block, statedb *state.StateDB, cfg vm.Config) (types.Receipts, []*types.Log, uint64, error) {
 var (
  receipts    types.Receipts
  usedGas     = new(uint64)
  header      = block.Header()
  blockHash   = block.Hash()
  blockNumber = block.Number()
  allLogs     []*types.Log
  gp          = new(GasPool).AddGas(block.GasLimit())
 )
 ...
 vmenv := vm.NewEVM(blockContext, vm.TxContext{}, statedb, p.config, cfg)
 // Iterate over and process the individual transactions
 for i, tx := range block.Transactions() {
  msg, err := TransactionToMessage(tx, types.MakeSigner(p.config, header.Number), header.BaseFee)
  if err != nil {
   return nil, nil, 0, fmt.Errorf("could not apply tx %d [%v]: %w", i, tx.Hash().Hex(), err)
  }
  statedb.SetTxContext(tx.Hash(), i)
  receipt, err := applyTransaction(msg, p.config, gp, statedb, blockNumber, blockHash, tx, usedGas, vmenv)
  if err != nil {
   return nil, nil, 0, fmt.Errorf("could not apply tx %d [%v]: %w", i, tx.Hash().Hex(), err)
  }
  receipts = append(receipts, receipt)
  allLogs = append(allLogs, receipt.Logs...)
 }
 ...
 // Finalize the block, applying any consensus engine specific extras (e.g. block rewards)
 p.engine.Finalize(p.bc, header, statedb, block.Transactions(), block.Uncles(), withdrawals)

 return receipts, allLogs, *usedGas, nil
}

func applyTransaction(msg *Message, config *params.ChainConfig, gp *GasPool, statedb *state.StateDB, blockNumber *big.Int, blockHash common.Hash, tx *types.Transaction, usedGas *uint64, evm *vm.EVM) (*types.Receipt, error) {
 // Create a new context to be used in the EVM environment.
 txContext := NewEVMTxContext(msg)
 evm.Reset(txContext, statedb)

 // Apply the transaction to the current state (included in the env).
 result, err := ApplyMessage(evm, msg, gp)
 if err != nil {
  return nil, err
 }

 // Update the state with pending changes.
 var root []byte
 if config.IsByzantium(blockNumber) {
  statedb.Finalise(true)
 } else {
  root = statedb.IntermediateRoot(config.IsEIP158(blockNumber)).Bytes()
 }
 *usedGas += result.UsedGas

 // Create a new receipt for the transaction, storing the intermediate root and gas used
 // by the tx.
 receipt := &types.Receipt{Type: tx.Type(), PostState: root, CumulativeGasUsed: *usedGas}
 if result.Failed() {
  receipt.Status = types.ReceiptStatusFailed
 } else {
  receipt.Status = types.ReceiptStatusSuccessful
 }
 receipt.TxHash = tx.Hash()
 receipt.GasUsed = result.UsedGas

 // If the transaction created a contract, store the creation address in the receipt.
 if msg.To == nil {
  receipt.ContractAddress = crypto.CreateAddress(evm.TxContext.Origin, tx.Nonce())
 }

 // Set the receipt logs and create the bloom filter.
 receipt.Logs = statedb.GetLogs(tx.Hash(), blockNumber.Uint64(), blockHash)
 receipt.Bloom = types.CreateBloom(types.Receipts{receipt})
 receipt.BlockHash = blockHash
 receipt.BlockNumber = blockNumber
 receipt.TransactionIndex = uint(statedb.TxIndex())
 return receipt, err
}
```

The code is pretty straight-forward. First, create new EVM instance, and for all transactions in the block:

a) decode transaction to a Message struct

b) assign ID to transaction in the block in StateDB

c) reset EVM to current transaction context and stateDB

c) apply the message to current state. That is execute it using EVM, and return the result. We’ll dig deep into *ApplyMessage()* next.

d) prepare transaction receipt and append it together with logs

When it’s done, finalize the block, applying any consensus engine specific extras. That’s because currently execution and consensus parts of Ethereum are decoupled, however they have to communicate to keep the network functional.

Now, let’s dig into *ApplyMessage()* last code piece located at [**core/state_transition.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/state_transition.go)

```
// ApplyMessage computes the new state by applying the given message
// against the old state within the environment.
//
// ApplyMessage returns the bytes returned by any EVM execution (if it took place),
// the gas used (which includes gas refunds) and an error if it failed. An error always
// indicates a core error meaning that the message would always fail for that particular
// state and would never be accepted within a block.
func ApplyMessage(evm *vm.EVM, msg *Message, gp *GasPool) (*ExecutionResult, error) {
 return NewStateTransition(evm, msg, gp).TransitionDb()
}
```

Nothing interesting here, we’re just creating new *StateTransition* struct, in order to call *TransitionDb()* function on it. Actually, name of this function is rather unfortunate, as it does not convey what it really does. [Its code comment](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/state_transition.go#L301-L405) does pretty good jobs describing it:

> TransitionDb will transition the state by applying the current message and returning the evm execution result with following fields.
> — used gas: total gas used (including gas being refunded)
> — returndata: the returned data from evm
> — concrete execution error: various EVM errors which abort the execution, e.g. ErrOutOfGas, ErrExecutionReverted
> However if any consensus issue encountered, return the error directly with nil evm execution result

Let’s dissect this function. First, it does all required checks to make sure that the message should be even considered valid for execution:

```
func (st *StateTransition) TransitionDb() (*ExecutionResult, error) {
 // First check this message satisfies all consensus rules before
 // applying the message. The rules include these clauses
 //
 // 1. the nonce of the message caller is correct
 // 2. caller has enough balance to cover transaction fee(gaslimit * gasprice)
 // 3. the amount of gas required is available in the block
 // 4. the purchased gas is enough to cover intrinsic usage
 // 5. there is no overflow when calculating intrinsic gas
 // 6. caller has enough balance to cover asset transfer for **topmost** call

 // Check clauses 1-3, buy gas if everything is correct
 if err := st.preCheck(); err != nil {
  return nil, err
 }
```

If all the checks are successful, we check if this is a contract creation transaction (without transaction recipient set), or regular call, and invoke EVM functions accordingly:

```
 ...
 contractCreation = msg.To == nil

 var (
  ret   []byte
  vmerr error // vm errors do not effect consensus and are therefore not assigned to err
 )
 if contractCreation {
  ret, _, st.gasRemaining, vmerr = st.evm.Create(sender, msg.Data, st.gasRemaining, msg.Value)
 } else {
  // Increment the nonce for the next transaction
  st.state.SetNonce(msg.From, st.state.GetNonce(sender.Address())+1)
  ret, st.gasRemaining, vmerr = st.evm.Call(sender, st.to(), msg.Data, st.gasRemaining, msg.Value)
 }
```

And finally fee calculations. There are few moving parts — first, you may receive gas refund if you clear state. Second, proper tip is calculated. Third, you may not pay for the gas at all. WTF? This path is possible, but it’s currently only used by MEV service providers like FlashBots. In this case, MEV searcher pays ether directly to the coinbase address, skipping fees. Why? Because if a message reverts, you still have to pay for the fees up to the revert point, and MEV searchers usually gather tens or hundreds of transactions into one bundle and failing such a transaction would incur big losses for them. Additionally, you may see that there are some rules concerning Ethereum hard forks. At first you may think that this is developer’s sloppiness that they left dead code here, but it’s actually useful for running simulations on historical blocks.

```
if !rules.IsLondon {
  // Before EIP-3529: refunds were capped to gasUsed / 2
  st.refundGas(params.RefundQuotient)
 } else {
  // After EIP-3529: refunds are capped to gasUsed / 5
  st.refundGas(params.RefundQuotientEIP3529)
 }
 effectiveTip := msg.GasPrice
 if rules.IsLondon {
  effectiveTip = cmath.BigMin(msg.GasTipCap, new(big.Int).Sub(msg.GasFeeCap, st.evm.Context.BaseFee))
 }

 if st.evm.Config.NoBaseFee && msg.GasFeeCap.Sign() == 0 && msg.GasTipCap.Sign() == 0 {
  // Skip fee payment when NoBaseFee is set and the fee fields
  // are 0. This avoids a negative effectiveTip being applied to
  // the coinbase when simulating calls.
 } else {
  fee := new(big.Int).SetUint64(st.gasUsed())
  fee.Mul(fee, effectiveTip)
  st.state.AddBalance(st.evm.Context.Coinbase, fee)
 }
```

As a side note, I found a function [**buyGas** ](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/state_transition.go#L228)(), which indicates that gas is not just deducted from you in some barbaric fashion — you’re buying it from a validator, free market babe!

That’s all for now. In [Part II](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-ii-evm-ce7653f31c6f), we’ll finally get a hang of [**core/vm/evm.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/evm.go), and will see how your bytecode is run.

I hope you liked it and learned something new here. If you’d like to go really deep into geth exploration, here are some additional materials to check out (bear in mind that those may be outdated):

- https://www.mslinn.com/blog/2018/06/13/evm-source-walkthrough.html
- https://mslinn.gitbooks.io/go-ethereum-walkthrough/content/
- https://github.com/Billy1900/Ethereum-tutorial-EN



原文链接：https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-i-transaction-execution-flow-960a1533e994