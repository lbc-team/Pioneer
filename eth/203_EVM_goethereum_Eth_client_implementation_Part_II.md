# Dissecting EVM using go-ethereum Eth client implementation. Part II — EVM

![img](https://img.learnblockchain.cn/attachments/2023/06/BGeKgDoK64880c2d6715e.jpeg)

Photo by [Shubham Dhage](https://unsplash.com/@theshubhamdhage?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com/?utm_source=medium&utm_medium=referral)

In [Part I](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-i-transaction-execution-flow-960a1533e994) we discussed transaction execution flow, now let’s move to the real hero of Ethereum — EVM. Almost everything that will interest us is located at **core/vm** folder. Let’s start with actual [evm.go](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/evm.go), and see how [some important EVM structs are define](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/evm.go#L61-L123)d:

```
type BlockContext struct {
 // CanTransfer returns whether the account contains
 // sufficient ether to transfer the value
 CanTransfer CanTransferFunc
 // Transfer transfers ether from one account to the other
 Transfer TransferFunc
 // GetHash returns the hash corresponding to n
 GetHash GetHashFunc

 // Block information
 Coinbase    common.Address // Provides information for COINBASE
 GasLimit    uint64         // Provides information for GASLIMIT
 BlockNumber *big.Int       // Provides information for NUMBER
 Time        uint64         // Provides information for TIME
 Difficulty  *big.Int       // Provides information for DIFFICULTY
 BaseFee     *big.Int       // Provides information for BASEFEE
 Random      *common.Hash   // Provides information for PREVRANDAO
}
// TxContext provides the EVM with information about a transaction.
// All fields can change between transactions.
type TxContext struct {
 // Message information
 Origin   common.Address // Provides information for ORIGIN
 GasPrice *big.Int       // Provides information for GASPRICE
}
type EVM struct {
 // Context provides auxiliary blockchain related information
 Context BlockContext
 TxContext
 // StateDB gives access to the underlying state
 StateDB StateDB
 // Depth is the current call stack
 depth int
 // chainConfig contains information about the current chain
 chainConfig *params.ChainConfig
 // chain rules contains the chain rules for the current epoch
 chainRules params.Rules
 // virtual machine configuration options used to initialise the
 // evm.
 Config Config
 // global (to this context) ethereum virtual machine
 // used throughout the execution of the tx.
 interpreter *EVMInterpreter
 // abort is used to abort the EVM calling operations
 // NOTE: must be set atomically
 abort int32
 // callGasTemp holds the gas available for the current call. This is needed because the
 // available gas is calculated in gasCall* according to the 63/64 rule and later
 // applied in opCall*.
 callGasTemp uint64
}
```

You can deduce from this what the “context” in Ethereum is. Be it transaction context, block context, call context, all those are just metadata defining some useful information for current execution on different level of abstraction (call/trace/etc.).

# Contract creation

If you remember from [**Part I**](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-i-transaction-execution-flow-960a1533e994), code path for contract creation is slightly different than call execution. But actually both paths meet at common point — running the bytecode —that’s because a smart contract constructor is actually a runnable piece of code, which at the end returns 2 elements: code to deploy’s offset and length, and those values are used to put specific bytes of this range under the newly created smart contract address. So, that means that you’re allowed to create smart contract procedurally, save it to memory and then return it’s memory location. I didn’t see it in the wild, but this could actually be quite interesting usage — creating smart contract code on the fly, based on on-chain state.

After this introduction of code creation, let’s go to [the code](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/evm.go#L508-L511) as see how it’s implemented:

```
func (evm *EVM) Create(caller ContractRef, code []byte, gas uint64, value *big.Int) (ret []byte, contractAddr common.Address, leftOverGas uint64, err error) {
 contractAddr = crypto.CreateAddress(caller.Address(), evm.StateDB.GetNonce(caller.Address()))
 return evm.create(caller, &codeAndHash{code: code}, gas, value, contractAddr, CREATE)
}

func (evm *EVM) Create2(caller ContractRef, code []byte, gas uint64, endowment *big.Int, salt *uint256.Int) (ret []byte, contractAddr common.Address, leftOverGas uint64, err error) {
 codeAndHash := &codeAndHash{code: code}
 contractAddr = crypto.CreateAddress2(caller.Address(), salt.Bytes32(), codeAndHash.Hash().Bytes())
 return evm.create(caller, codeAndHash, gas, endowment, contractAddr, CREATE2)
}
```

We’re just creating the contract address from caller address and nonce, and then call a *create* function. I added also Create2 function, to see the difference in address creation. In second function, address is created from caller address, salt and codeHash. Now, let’s dig into details:

```
func (evm *EVM) create(caller ContractRef, codeAndHash *codeAndHash, gas uint64, value *big.Int, address common.Address, typ OpCode) ([]byte, common.Address, uint64, error) {
 // Depth check execution. Fail if we're trying to execute above the
 // limit.
 if evm.depth > int(params.CallCreateDepth) {
  return nil, common.Address{}, gas, ErrDepth
 }
 if !evm.Context.CanTransfer(evm.StateDB, caller.Address(), value) {
  return nil, common.Address{}, gas, ErrInsufficientBalance
 }
 nonce := evm.StateDB.GetNonce(caller.Address())
 if nonce+1 < nonce {
  return nil, common.Address{}, gas, ErrNonceUintOverflow
 }
 evm.StateDB.SetNonce(caller.Address(), nonce+1)
 // We add this to the access list _before_ taking a snapshot. Even if the creation fails,
 // the access-list change should not be rolled back
 if evm.chainRules.IsBerlin {
  evm.StateDB.AddAddressToAccessList(address)
 }
 // Ensure there's no existing contract already at the designated address
 contractHash := evm.StateDB.GetCodeHash(address)
 if evm.StateDB.GetNonce(address) != 0 || (contractHash != (common.Hash{}) && contractHash != emptyCodeHash) {
  return nil, common.Address{}, 0, ErrContractAddressCollision
 }
```

First, call depth is checked. It’s increased after each call. Max value allowed here is 1024, above that the execution reverts. Then we check if the account actually has required funds to send to the contract constructor. In case that value sent is 0 it will return true. After retrieving a nonce from StateDB, it’s checked for overflow. I can’t imagine a situation for nonce to overflow, as 2²⁵⁶ * 21000 = 2.43163387398364e+81 minimum gas is required to overflow this value, which means that even on chains as cheap as Celo, it would probably cost more than anyone in the world can afford, but better safe than sorry.

Then, if it’s a Berlin hardfork, call *AddAddressToAccessList()*. Let’s stop for a moment here, as this function, together with *AddSlotToAccessList()* is quite important to understand. EVM has a concept of cold and warm storage. This means that if you’re accessing a storage slot, or interact with a specific address for the first time in a transaction (it’s called “touching” it), you pay more, than every next interaction. This is to disincentivize bad actors trying to DoS the network by transactions containing multiple read/writes from random storage, because every first read required IO operation on filesystem to retrieve the value from node storage.

Lastly, EVM ensures that there is no code deployed at that address and no transactions took place on this address — nonce is 0.

```
// Create a new account on the state
 snapshot := evm.StateDB.Snapshot()
 evm.StateDB.CreateAccount(address)
 if evm.chainRules.IsEIP158 {
  evm.StateDB.SetNonce(address, 1)
 }
 evm.Context.Transfer(evm.StateDB, caller.Address(), address, value)

 // Initialise a new contract and set the code that is to be used by the EVM.
 // The contract is a scoped environment for this execution context only.
 contract := NewContract(caller, AccountRef(address), value, gas)
 contract.SetCodeOptionalHash(&address, codeAndHash)

 ...

 ret, err := evm.interpreter.Run(contract, nil, false)

 // Check whether the max code size has been exceeded, assign err if the case.
 if err == nil && evm.chainRules.IsEIP158 && len(ret) > params.MaxCodeSize {
  err = ErrMaxCodeSizeExceeded
 }

 // Reject code starting with 0xEF if EIP-3541 is enabled.
 if err == nil && len(ret) >= 1 && ret[0] == 0xEF && evm.chainRules.IsLondon {
  err = ErrInvalidCode
 }

 // if the contract creation ran successfully and no errors were returned
 // calculate the gas required to store the code. If the code could not
 // be stored due to not enough gas set an error and let it be handled
 // by the error checking condition below.
 if err == nil {
  createDataGas := uint64(len(ret)) * params.CreateDataGas
  if contract.UseGas(createDataGas) {
   evm.StateDB.SetCode(address, ret)
  } else {
   err = ErrCodeStoreOutOfGas
  }
 }

 // When an error was returned by the EVM or when setting the creation code
 // above we revert to the snapshot and consume any gas remaining. Additionally
 // when we're in homestead this also counts for code storage gas errors.
 if err != nil && (evm.chainRules.IsHomestead || err != ErrCodeStoreOutOfGas) {
  evm.StateDB.RevertToSnapshot(snapshot)
  if err != ErrExecutionReverted {
   contract.UseGas(contract.Gas)
  }
 }
 ...
 return ret, address, contract.Gas, err
}
```

This part is actually really interesting. First, the state is snapshotted. This is what makes EVM transactions atomic — every time you invoke a call, create smart contract, or call external contract, first thing that is done before anything is run, state of the StateDB is saved. Then, if any of the errors occur, state is just reverted to previously saved one. Thanks to that, there is no possibility to have a reverted call that modifies the DB.

Next, EVM saved address to DB and sets nonce to 1 — smart contracts nonce always start from 1, and increase only when the smart contract create a new smart contract by CREATE or CREATE2 opcode.

After that msg.value is transferred to newly created smart contract, EVM initializes new contract that is passed to bytecode interpreter to run the contract code. This part is really important, but I’ll deliberately postpone describing it until for later, when discussing normal call. As I already mentioned before, what’s being run here, is a constructor. Even if you won’t define one yourself, the Solidity compiler will do that for you. After all, you have to run it on-chain and return code location using RETURN opcode at the end. Keep in mind, that there is no code deployed at this moment. The constructor just returns what is about to be saved as the smart contract code. That’s why you should newer rely on address code size, as the constructor is the only place you can run any arbitrary opcodes without having it deployed. When it’s done, two variables are returned: *ret* and *err*. First one is a byte array containing the smart contract to be deployed, and the latter one just signalizes if any error occurred. After that we check that the code size is smaller than current limit and it does not start with **0xEF**. This requirement is added here for future EOF. You can find more details on it [HERE](https://notes.ethereum.org/@ipsilon/evm-object-format-overview).

Finally, EVM consumes due gas per smart contract byte, only now saves the code to StateDB, or if an error occurred reverts the state and propagates error higher.

# Call execution

Let’s now focus on second path mentioned in Part I — normal call execution. Some of the parts are similar here:

```
// Call executes the contract associated with the addr with the given input as
// parameters. It also handles any necessary value transfer required and takes
// the necessary steps to create accounts and reverses the state in case of an
// execution error or failed value transfer.
func (evm *EVM) Call(caller ContractRef, addr common.Address, input []byte, gas uint64, value *big.Int) (ret []byte, leftOverGas uint64, err error) {
 // Fail if we're trying to execute above the call depth limit
 if evm.depth > int(params.CallCreateDepth) {
  return nil, gas, ErrDepth
 }
 // Fail if we're trying to transfer more than the available balance
 if value.Sign() != 0 && !evm.Context.CanTransfer(evm.StateDB, caller.Address(), value) {
  return nil, gas, ErrInsufficientBalance
 }
 snapshot := evm.StateDB.Snapshot()
 p, isPrecompile := evm.precompile(addr)

 if !evm.StateDB.Exist(addr) {
  if !isPrecompile && evm.chainRules.IsEIP158 && value.Sign() == 0 {
   // Calling a non existing account, don't do anything, but ping the tracer
   if evm.Config.Debug {
    if evm.depth == 0 {
     evm.Config.Tracer.CaptureStart(evm, caller.Address(), addr, false, input, gas, value)
     evm.Config.Tracer.CaptureEnd(ret, 0, nil)
    } else {
     evm.Config.Tracer.CaptureEnter(CALL, caller.Address(), addr, input, gas, value)
     evm.Config.Tracer.CaptureExit(ret, 0, nil)
    }
   }
   return nil, gas, nil
  }
  evm.StateDB.CreateAccount(addr)
 }
 evm.Context.Transfer(evm.StateDB, caller.Address(), addr, value)
```

First, we check we didn’t go over 1024 call stack depth and have enough value to transfer to the transaction recipient. Then EVM snapshots the state and checks is the recipient is a precompiled contract and returns pointer to it if that’s the case. If not, and the address does not exist yet, it will create it, but ONLY IF the value to be sent to this address is bigger than 0. Otherwise it will do early return. Let’s dig deeper:

```
if isPrecompile {
  ret, gas, err = RunPrecompiledContract(p, input, gas)
 } else {
  // Initialise a new contract and set the code that is to be used by the EVM.
  // The contract is a scoped environment for this execution context only.
  code := evm.StateDB.GetCode(addr)
  if len(code) == 0 {
   ret, err = nil, nil // gas is unchanged
  } else {
   addrCopy := addr
   // If the account has no code, we can abort here
   // The depth-check is already done, and precompiles handled above
   contract := NewContract(caller, AccountRef(addrCopy), value, gas)
   contract.SetCallCode(&addrCopy, evm.StateDB.GetCodeHash(addrCopy), code)
   ret, err = evm.interpreter.Run(contract, input, false)
   gas = contract.Gas
  }
 }
 // When an error was returned by the EVM or when setting the creation code
 // above we revert to the snapshot and consume any gas remaining. Additionally
 // when we're in homestead this also counts for code storage gas errors.
 if err != nil {
  evm.StateDB.RevertToSnapshot(snapshot)
  if err != ErrExecutionReverted {
   gas = 0
  }
  // TODO: consider clearing up unused snapshots:
  //} else {
  // evm.StateDB.DiscardSnapshot(snapshot)
 }
 return ret, gas, err
}
```

From here, there are now paths possible. If it’s a precompile, special function from [**core/vm/contracts.go**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/contracts.go#L143-L156) is used. That’s because precompiled contracts are special ones. Those are not deployed on-chain, but rather live the the execution client code directly. So, even though those have 0 code size, they still execute specific functions, as those are executes natively. Each precompile function has it’s own address. You can find more about precompiles under this [**LINK**](https://www.evm.codes/precompiled). Let’s look at ecrecover (address 0x01) implementation code, you can find [**HERE**](https://github.com/ethereum/go-ethereum/blob/v1.11.5/core/vm/contracts.go#L158-L194):

```
// ECRECOVER implemented as a native contract.
type ecrecover struct{}

func (c *ecrecover) RequiredGas(input []byte) uint64 {
 return params.EcrecoverGas
}

func (c *ecrecover) Run(input []byte) ([]byte, error) {
 const ecRecoverInputLength = 128

 input = common.RightPadBytes(input, ecRecoverInputLength)
 // "input" is (hash, v, r, s), each 32 bytes
 // but for ecrecover we want (r, s, v)

 r := new(big.Int).SetBytes(input[64:96])
 s := new(big.Int).SetBytes(input[96:128])
 v := input[63] - 27

 // tighter sig s values input homestead only apply to tx sigs
 if !allZero(input[32:63]) || !crypto.ValidateSignatureValues(v, r, s, false) {
  return nil, nil
 }
 // We must make sure not to modify the 'input', so placing the 'v' along with
 // the signature needs to be done on a new allocation
 sig := make([]byte, 65)
 copy(sig, input[64:128])
 sig[64] = v
 // v needs to be at the end for libsecp256k1
 pubKey, err := crypto.Ecrecover(input[:32], sig)
 // make sure the public key is a valid one
 if err != nil {
  return nil, nil
 }

 // the first byte of pubkey is bitcoin heritage
 return common.LeftPadBytes(crypto.Keccak256(pubKey[1:])[12:], 32), nil
}
```

If it’s not a precompile, EVM gets code byte array. If it’s length is 0, call returns here with nil return value. That’s why low level calls in Solidity return success and you have to verify if the address is a smart contract yourself. Next, we fill new Contract struct and pass it to interpreter to run the smart contract. At the end, EVM checks if any error occurred, reverting state in such case, and returns result of the run together with gas left and error, if any.

That’s it for now. In [Part III](https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-iii-bytecode-interpreter-8f144004ed7a) we’ll go into how bytecode interpreter works.



原文链接：https://medium.com/@deliriusz/dissecting-evm-using-go-ethereum-eth-client-implementation-part-ii-evm-ce7653f31c6f