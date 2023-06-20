

# Dissecting EVM using go-ethereum Eth client implementation. Part III — bytecode interpreter

![img](https://img.learnblockchain.cn/attachments/2023/06/uJJEv6Cb64880e21d6fae.png)

Photo by [Shubham Dhage](https://unsplash.com/@theshubhamdhage?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com/?utm_source=medium&utm_medium=referral)

I planned on doing only 2 parts, but the second part grew so long, that I had to split it into 2. So, enjoy the last part.

BTW, if you missed previous parts, here they are:

- [Part I](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-i-transaction-execution-flow-960a1533e994)
- [Part II](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-ii-evm-ce7653f31c6f)

# Running bytecode interpreter

We finally arrived to the [**core/vm/interpreter.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/interpreter.go), which interprets raw bytes into runnable code. I’d like to start with explanation of some structs, to better understand what it has to offer.

```
// ScopeContext contains the things that are per-call, such as stack and memory,
// but not transients like pc and gas
type ScopeContext struct {
 Memory   *Memory
 Stack    *Stack
 Contract *Contract
}

// EVMInterpreter represents an EVM interpreter
type EVMInterpreter struct {
 evm   *EVM
 table *JumpTable
 hasher    crypto.KeccakState // Keccak256 hasher instance shared across opcodes
 hasherBuf common.Hash        // Keccak256 hasher result array shared aross opcodes
 readOnly   bool   // Whether to throw on stateful modifications
 returnData []byte // Last CALL's return data for subsequent reuse
}

// NewEVMInterpreter returns a new instance of the Interpreter.
func NewEVMInterpreter(evm *EVM) *EVMInterpreter {
 // If jump table was not initialised we set the default one.
 var table *JumpTable
 switch {
 case evm.chainRules.IsShanghai:
  table = &shanghaiInstructionSet
 ...
  table = &homesteadInstructionSet
 default:
  table = &frontierInstructionSet
 }
 var extraEips []int
 if len(evm.Config.ExtraEips) > 0 {
  // Deep-copy jumptable to prevent modification of opcodes in other tables
  table = copyJumpTable(table)
 }
 for _, eip := range evm.Config.ExtraEips {
  if err := EnableEIP(eip, table); err != nil {
   // Disable it, so caller can check if it's activated or not
   log.Error("EIP activation failed", "eip", eip, "error", err)
  } else {
   extraEips = append(extraEips, eip)
  }
 }
 evm.Config.ExtraEips = extraEips
 return &EVMInterpreter{evm: evm, table: table}
}
```

- *ScopeContext* is, in a nutshell, just allocated memory and stack for a contract. This is important, as it is what’s called a “call context” — by looking at it you can guess that it’s only for a contract you’re currently in during bytecode interpretation. Each time you do call, delegatecall, staticcall, or callcode (now deprecated, but still supported by EVM), you get new ScopeContext, and new memory and stack together with it.
- *EVMInterpreter* contains reference to EVM, jump table, which is just a mapping between uint8 opcode code and underlying operation data, e.g. `**table[0xF1] -> CALL**` **.** Operation details can be found in [**core/vm/jump_table.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/jump_table.go#L32-L45). Let’s see how exemplary jumpTable element is added:

```
func newByzantiumInstructionSet() JumpTable {
 instructionSet := newSpuriousDragonInstructionSet()
 instructionSet[STATICCALL] = &operation{
  execute:     opStaticCall,
  constantGas: params.CallGasEIP150,
  dynamicGas:  gasStaticCall,
  minStack:    minStack(6, 1),
  maxStack:    maxStack(6, 1),
  memorySize:  memoryStaticCall,
 }
...
```

- *hasher* and *hasherBuf* are not really interesting here. But their only usage, as far as I was able to verify, is in keccak256 related operations
- *readOnly* defines if any changes to StateDB are allowed. Only set to `true`, if called via STATICCALL
- *returnData* is exactly the data that is returned via last RETURN opcode

Interpreter constructor is also interesting. You can see here, that it applies different instruction set, based on current fork. At the end, any EIPs that modify opcodes workings are applied.

Ladies and gentlemen, finally the moment that everyone was waiting for -**Run()** function, the one that is in the core of the EVM:

```
// Run loops and evaluates the contract's code with the given input data and returns
// the return byte-slice and an error if one occurred.
//
// It's important to note that any errors returned by the interpreter should be
// considered a revert-and-consume-all-gas operation except for
// ErrExecutionReverted which means revert-and-keep-gas-left.
func (in *EVMInterpreter) Run(contract *Contract, input []byte, readOnly bool) (ret []byte, err error) {
 // Increment the call depth which is restricted to 1024
 in.evm.depth++
 defer func() { in.evm.depth-- }()

 // Make sure the readOnly is only set if we aren't in readOnly yet.
 // This also makes sure that the readOnly flag isn't removed for child calls.
 if readOnly && !in.readOnly {
  in.readOnly = true
  defer func() { in.readOnly = false }()
 }
 // Reset the previous call's return data. It's unimportant to preserve the old buffer
 // as every returning call will return new data anyway.
 in.returnData = nil
 // Don't bother with the execution if there's no code.
 if len(contract.Code) == 0 {
  return nil, nil
 }
 var (
  op          OpCode        // current opcode
  mem         = NewMemory() // bound memory
  stack       = newstack()  // local stack
  callContext = &ScopeContext{
   Memory:   mem,
   Stack:    stack,
   Contract: contract,
  }
  // For optimisation reason we're using uint64 as the program counter.
  // It's theoretically possible to go above 2^64. The YP defines the PC
  // to be uint256. Practically much less so feasible.
  pc   = uint64(0) // program counter
  cost uint64
  // copies used by tracer
  pcCopy  uint64 // needed for the deferred EVMLogger
  gasCopy uint64 // for EVMLogger to log gas remaining before execution
  logged  bool   // deferred EVMLogger should ignore already logged steps
  res     []byte // result of the opcode execution function
 )
 // Don't move this deferred function, it's placed before the capturestate-deferred method,
 // so that it get's executed _after_: the capturestate needs the stacks before
 // they are returned to the pools
 defer func() {
  returnStack(stack)
 }()
 contract.Input = input
```

First thing we do, we increase call depth by one and promise to decrease it at the end. After managing readOnly flag and zero out unnecessary returnData. Then, if there is no code to invoke, we just do an early return. Then you can clearly see how a new call context is being created, process counter (pc), that will increase with every executed operation, some additional utility params. Finally interpreter defers clearing stack and assigns input, which is just a byte array calldata. Let’s quickly go over [**core/vm/stack.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/stack.go) and [**core/vm/memory.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/memory.go).

```
// Stack is an object for basic stack operations. Items popped to the stack are
// expected to be changed and modified. stack does not take care of adding newly
// initialised objects.
type Stack struct {
 data []uint256.Int
}

func newstack() *Stack {
 return stackPool.Get().(*Stack)
}
func returnStack(s *Stack) {
 s.data = s.data[:0]
 stackPool.Put(s)
}
...
func (st *Stack) push(d *uint256.Int) {
 // NOTE push limit (1024) is checked in baseCheck
 st.data = append(st.data, *d)
}
func (st *Stack) pop() (ret uint256.Int) {
 ret = st.data[len(st.data)-1]
 st.data = st.data[:len(st.data)-1]
 return
}
func (st *Stack) swap(n int) {
 st.data[st.len()-n], st.data[st.len()-1] = st.data[st.len()-1], st.data[st.len()-n]
}
func (st *Stack) dup(n int) {
 st.push(&st.data[st.len()-n])
}
```

Just a simple stack implementation. But what’s interesting is that you can `swap` and `dup` element of any depth you want here. It’s only unnecessary EVM limitation, that supports 1 to 16 deep swaps and dups, which results in “stack too deep” errors, if you’re writing anything more interesting than simple escrow contract… And actually you have a pool of stacks, that are being zeroed out after use.

```
// Memory implements a simple memory model for the ethereum virtual machine.
type Memory struct {
 store       []byte
 lastGasCost uint64
}

// NewMemory returns a new memory model.
func NewMemory() *Memory {
 return &Memory{}
}
// Set sets offset + size to value
func (m *Memory) Set(offset, size uint64, value []byte) {
 // It's possible the offset is greater than 0 and size equals 0. This is because
 // the calcMemSize (common.go) could potentially return 0 when size is zero (NO-OP)
 if size > 0 {
  // length of store may never be less than offset + size.
  // The store should be resized PRIOR to setting the memory
  if offset+size > uint64(len(m.store)) {
   panic("invalid memory: store empty")
  }
  copy(m.store[offset:offset+size], value)
 }
}
// Set32 sets the 32 bytes starting at offset to the value of val, left-padded with zeroes to
// 32 bytes.
func (m *Memory) Set32(offset uint64, val *uint256.Int) {
 // length of store may never be less than offset + size.
 // The store should be resized PRIOR to setting the memory
 if offset+32 > uint64(len(m.store)) {
  panic("invalid memory: store empty")
 }
 // Fill in relevant bits
 b32 := val.Bytes32()
 copy(m.store[offset:], b32[:])
}
// Resize resizes the memory to size
func (m *Memory) Resize(size uint64) {
 if uint64(m.Len()) < size {
  m.store = append(m.store, make([]byte, size-uint64(m.Len()))...)
 }
}
```

Again, nothing interesting here. It differs from the stack, because it’s not meant to shrink and grow, but only expand. Apart from the bytes it holds, it also contains info about lastGasCost, which grows quadratically in gas price after reaching specific size. You can read more about it [**HERE**](https://notes.ethereum.org/@vbuterin/proposals_to_adjust_memory_gas_costs).

Next up, I’ll go over actual execution loop. This time, I’ll describe it before showing the code. So, the loop iterates until an error is thrown. It treats `errStopToken` error as an actual success, otherwise it means that the state has to be reverted. Next, we get opcode at specific process counter, search it in jump table, verify if stack won’t underflow or overflow after calling this opcode, check if `gasleft`is enough for both static and dynamic calculation, and memory will not overflow, which is not possible at the moment, as due to quadratic memory expansion cost, you’ll earlier run out of gas, than reach 2²⁵⁶ memory, aaaand we don’t have such big RAM constructed yet. If memory needs to be expanded, it’s being resized and finally operation is being executed with *calldata* and *callContext*.

```
// The Interpreter main run loop (contextual). This loop runs until either an
 // explicit STOP, RETURN or SELFDESTRUCT is executed, an error occurred during
 // the execution of one of the operations or until the done flag is set by the
 // parent context.
 for {
  ...
  // Get the operation from the jump table and validate the stack to ensure there are
  // enough stack items available to perform the operation.
  op = contract.GetOp(pc)
  operation := in.table[op]
  cost = operation.constantGas // For tracing
  // Validate stack
  if sLen := stack.len(); sLen < operation.minStack {
   return nil, &ErrStackUnderflow{stackLen: sLen, required: operation.minStack}
  } else if sLen > operation.maxStack {
   return nil, &ErrStackOverflow{stackLen: sLen, limit: operation.maxStack}
  }
  if !contract.UseGas(cost) {
   return nil, ErrOutOfGas
  }
  if operation.dynamicGas != nil {
   // All ops with a dynamic memory usage also has a dynamic gas cost.
   var memorySize uint64
   // calculate the new memory size and expand the memory to fit
   // the operation
   // Memory check needs to be done prior to evaluating the dynamic gas portion,
   // to detect calculation overflows
   if operation.memorySize != nil {
    memSize, overflow := operation.memorySize(stack)
    if overflow {
     return nil, ErrGasUintOverflow
    }
    // memory is expanded in words of 32 bytes. Gas
    // is also calculated in words.
    if memorySize, overflow = math.SafeMul(toWordSize(memSize), 32); overflow {
     return nil, ErrGasUintOverflow
    }
   }
   // Consume the gas and return an error if not enough gas is available.
   // cost is explicitly set so that the capture state defer method can get the proper cost
   var dynamicCost uint64
   dynamicCost, err = operation.dynamicGas(in.evm, contract, stack, mem, memorySize)
   cost += dynamicCost // for tracing
   if err != nil || !contract.UseGas(dynamicCost) {
    return nil, ErrOutOfGas
   }
   ...
   if memorySize > 0 {
    mem.Resize(memorySize)
   }
  }
  ...
  // execute the operation
  res, err = operation.execute(&pc, in, callContext)
  if err != nil {
   break
  }
  pc++
 }

if err == errStopToken {
  err = nil // clear stop token error
 }
 return res, err
}
```

And now, to the actual operations implementation. All of them are implemented in [**core/vm/instructions.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/instructions.go). Let’s first go over the simplest one — ADD:

```
func opAdd(pc *uint64, interpreter *EVMInterpreter, scope *ScopeContext) ([]byte, error) {
 x, y := scope.Stack.pop(), scope.Stack.peek()
 y.Add(&x, y)
 return nil, nil
}
```

As you can see, interpreter first pops first element, and just peeks the second one (without deleting it). Then it overrides current topmost stack element with sum of the `x` and `y`. It returns nothing. Most of the opcodes are like that, there’s no magic here. When you see how one is done, you basically know them all. I’d like to mention here some additional opcodes — CREATE, CALL and DELEGATECALL, to have full picture of how the opcodes work across call context:

```
func opCreate(pc *uint64, interpreter *EVMInterpreter, scope *ScopeContext) ([]byte, error) {
 if interpreter.readOnly {
  return nil, ErrWriteProtection
 }
 var (
  value        = scope.Stack.pop()
  offset, size = scope.Stack.pop(), scope.Stack.pop()
  input        = scope.Memory.GetCopy(int64(offset.Uint64()), int64(size.Uint64()))
  gas          = scope.Contract.Gas
 )
 if interpreter.evm.chainRules.IsEIP150 {
  gas -= gas / 64
 }
 // reuse size int for stackvalue
 stackvalue := size
 scope.Contract.UseGas(gas)
 //TODO: use uint256.Int instead of converting with toBig()
 var bigVal = big0
 if !value.IsZero() {
  bigVal = value.ToBig()
 }
 res, addr, returnGas, suberr := interpreter.evm.Create(scope.Contract, input, gas, bigVal)
 // Push item on the stack based on the returned error. If the ruleset is
 // homestead we must check for CodeStoreOutOfGasError (homestead only
 // rule) and treat as an error, if the ruleset is frontier we must
 // ignore this error and pretend the operation was successful.
 if interpreter.evm.chainRules.IsHomestead && suberr == ErrCodeStoreOutOfGas {
  stackvalue.Clear()
 } else if suberr != nil && suberr != ErrCodeStoreOutOfGas {
  stackvalue.Clear()
 } else {
  stackvalue.SetBytes(addr.Bytes())
 }
 scope.Stack.push(&stackvalue)
 scope.Contract.Gas += returnGas
 if suberr == ErrExecutionReverted {
  interpreter.returnData = res // set REVERT data to return data buffer
  return res, nil
 }
 interpreter.returnData = nil // clear dirty return data buffer
 return nil, nil
}
```

In short, as you can see, first we get required elements from the stack, deduct gas and … recursively call `evm.Create`, the path that we described at the beginning. This will create a new call context (stack and memory), and start the code interpretation again. Interesting! It’s like starting a new transaction again. Now let’s see how CALL op is implemented:

```
func opCall(pc *uint64, interpreter *EVMInterpreter, scope *ScopeContext) ([]byte, error) {
 stack := scope.Stack
 // Pop gas. The actual gas in interpreter.evm.callGasTemp.
 // We can use this as a temporary value
 temp := stack.pop()
 gas := interpreter.evm.callGasTemp
 // Pop other call parameters.
 addr, value, inOffset, inSize, retOffset, retSize := stack.pop(), stack.pop(), stack.pop(), stack.pop(), stack.pop(), stack.pop()
 toAddr := common.Address(addr.Bytes20())
 // Get the arguments from the memory.
 args := scope.Memory.GetPtr(int64(inOffset.Uint64()), int64(inSize.Uint64()))
 
 if interpreter.readOnly && !value.IsZero() {
  return nil, ErrWriteProtection
 }
 var bigVal = big0
 //TODO: use uint256.Int instead of converting with toBig()
 // By using big0 here, we save an alloc for the most common case (non-ether-transferring contract calls),
 // but it would make more sense to extend the usage of uint256.Int
 if !value.IsZero() {
  gas += params.CallStipend
  bigVal = value.ToBig()
 }
 ret, returnGas, err := interpreter.evm.Call(scope.Contract, toAddr, args, gas, bigVal)
 if err != nil {
  temp.Clear()
 } else {
  temp.SetOne()
 }
 stack.push(&temp)
 if err == nil || err == ErrExecutionReverted {
  scope.Memory.Set(retOffset.Uint64(), retSize.Uint64(), ret)
 }
 scope.Contract.Gas += returnGas
 interpreter.returnData = ret
 return ret, nil
}
```

Actually, there are not so many changes here… And what about DELEGATECALL?

```
func opDelegateCall(pc *uint64, interpreter *EVMInterpreter, scope *ScopeContext) ([]byte, error) {
 stack := scope.Stack
 // Pop gas. The actual gas is in interpreter.evm.callGasTemp.
 // We use it as a temporary value
 temp := stack.pop()
 gas := interpreter.evm.callGasTemp
 // Pop other call parameters.
 addr, inOffset, inSize, retOffset, retSize := stack.pop(), stack.pop(), stack.pop(), stack.pop(), stack.pop()
 toAddr := common.Address(addr.Bytes20())
 // Get arguments from the memory.
 args := scope.Memory.GetPtr(int64(inOffset.Uint64()), int64(inSize.Uint64()))

 ret, returnGas, err := interpreter.evm.DelegateCall(scope.Contract, toAddr, args, gas)
 if err != nil {
  temp.Clear()
 } else {
  temp.SetOne()
 }
 stack.push(&temp)
 if err == nil || err == ErrExecutionReverted {
  scope.Memory.Set(retOffset.Uint64(), retSize.Uint64(), ret)
 }
 scope.Contract.Gas += returnGas
 interpreter.returnData = ret
 return ret, nil
}
```

Hmm… Almost the same. Where’s the different between the two? It’s in **core/vm/evm**, specifically those links: [**DELEGATECALL**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/evm.go#L309-L346) vs [**CALL**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/evm.go#L175-L252). I’ll leave digging into this topic for you, dear reader :-)

It’s almost the end. I won’t describe STATICCALL, as it doesn’t differ from the rest. I’d like to spend a bit of time to summarize difference between storage, memory, stack and call stack:

- **storage** — storage is the most expensive, because each operation on it, requires calling StateDB, which in turn reads/writes values to actual storage on filesystem
- **memory** — way cheaper than storage, because exists only in RAM memory for the duration of a call. It does not shrink over time, so the costs have to be considerable, in order to punish exploitation attempts. Theoretically holds ²²⁵⁶ bytes, but because of quadratic expansion, it’s really limited.
- **stack** — by far the cheapest to work with, but allows only 1024 elements. Is meant to shrink and grow over time, and is the most volatile, hence the low price of using it.
- **call stack** — it’s not something that you can modify. It contains current subcall context — address and index. It grows when new call is made when running EVM, and shrinks with returning from the call.

Phew, what a ride. I hope that after reading through the material here, you’ll be able to get some deep insights into EVM and finally understand why something is, not only that it exists. Everything here has a good reason to be here, and without understanding the underlying technology, you’ll run around in circles, beating your head against the wall.

原文链接：https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-iii-bytecode-interpreter-8f144004ed7a