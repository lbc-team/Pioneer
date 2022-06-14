原文链接：https://chasewright.com/ethereum-and-ipfs/



# Debug Transactions with ArchiveNode.io and IPFS

## Introduction

One of the most common use cases for an Archive Node is running `debug` commands against older transactions. The problem is, not many services offer the `debug` namespace to end users, and if they do it’s usually behind a paywall. At ArchiveNode we set out to provide a service for free, to as wide of a developer audience as we could, while not opening it up to just any random end user who didn’t actually need “Archive” access.

There have been a number of situations where developers who were not already signed up with us really needed access to a debug, or a whole bunch of people really wanted to debug the same transaction over a short period. The problem is, `debug` methods are a nightmare. They consume a massive amount of resources to compute and give back (CPU, RAM, Bandwidth, etc.). They’ll also just straight up kill your node if they’re big enough, and let’s face it, the interesting transactions that everyone wants to look at are the massive flash loan attacks. Bye bye nodes.

## A Possible Solution

A while ago, I and another user discovered that a large enough trace would kill Geth and Turbo-Geth with OOM errors. We reported it here: https://github.com/ethereum/go-ethereum/issues/22244

The only viable solution was to either disable the memory tracing, or to stream the debug to a file, which if you’re trying to do this remotely over JSON-RPC is impossible.

However, that got me thinking, what if I could stream this to a file? What if I could distribute that file quickly to the mass of people looking to debug a popular transaction?

I can. With IPFS…

## Prototype it!

Full disclosure, I have no idea what I’m doing.

### Prerequisites:

- Enable the debug namespace on a node
- Install IPFS
- Run IPFS as a daemon

### Workflow:

So, we know that `debug_standardTraceBlockToFile` will write the trace to a file, but it needs both the blockHash and the txHash to work for what we want it to do. We only want the end user to have to ask for a transaction hash.

1. User submits API request (or visits a website?) with the txHash they want.
2. We locally call `eth_getTransactionByHash` which returns to us the blockHash
3. We call `debug_standardTraceBlockToFile` with the parameters:
   `"params": [ $blockHash, { "txHash": $txHash }]`
4. This returns to us the temporary file from `/tmp` in $results[0]
5. We compress that file with gzip (you’d be shocked how well compression works here).
6. We run `ipfs add --pin -Q txHash.gz` and we get an IPFS hash back
7. We give the IPFS hash to the user and they can download that file with `ipfs get` or `ipfs cat`
8. They unzip it
9. Somebody profits?

### See it in Action

```
$ curl -H 'Content-Type: application/json' --data '{"txHash":"0x78c1ca6e9f2faea9166b8a54cacfb7a5e3014eb5b74df4159afb7e0588f29d67"}' http://geth02:3000/debug

Qmc4n5qPpHRMS3XepuPJAvmUoUbAafNki5e56rerUmdfSd

$ ipfs get Qmc4n5qPpHRMS3XepuPJAvmUoUbAafNki5e56rerUmdfSd -o 0x78c1ca6e9f2faea9166b8a54cacfb7a5e3014eb5b74df4159afb7e0588f29d67.gz

Saving file(s) to 0x78c1ca6e9f2faea9166b8a54cacfb7a5e3014eb5b74df4159afb7e0588f29d67.gz
 120.69 KiB / 120.69 KiB


$ gunzip 0x78c1ca6e9f2faea9166b8a54cacfb7a5e3014eb5b74df4159afb7e0588f29d67.gz

$ du -sh 0x78c1ca6e9f2faea9166b8a54cacfb7a5e3014eb5b74df4159afb7e0588f29d67

5.9M

$ head -n 5 0x78c1ca6e9f2faea9166b8a54cacfb7a5e3014eb5b74df4159afb7e0588f29d67

{"pc":0,"op":96,"gas":"0x19c41","gasCost":"0x3","memory":"0x","memSize":0,"stack":[],"returnStack":null,"returnData":"0x","depth":1,"refund":0,"opName":"PUSH1","error":""}
{"pc":2,"op":96,"gas":"0x19c3e","gasCost":"0x3","memory":"0x","memSize":0,"stack":["0x80"],"returnStack":null,"returnData":"0x","depth":1,"refund":0,"opName":"PUSH1","error":""}
{"pc":4,"op":82,"gas":"0x19c3b","gasCost":"0xc","memory":"0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","memSize":96,"stack":["0x80","0x40"],"returnStack":null,"returnData":"0x","depth":1,"refund":0,"opName":"MSTORE","error":""}
{"pc":5,"op":96,"gas":"0x19c2f","gasCost":"0x3","memory":"0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080","memSize":96,"stack":[],"returnStack":null,"returnData":"0x","depth":1,"refund":0,"opName":"PUSH1","error":""}
{"pc":7,"op":54,"gas":"0x19c2c","gasCost":"0x2","memory":"0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080","memSize":96,"stack":["0x4"],"returnStack":null,"returnData":"0x","depth":1,"refund":0,"opName":"CALLDATASIZE","error":""}
```

As you can see that gzip saved us almost 6MB in size for this ONE debug. Some debugs can be literally 10s of GB in size, but they compress very well.

The beautiful thing about this setup is that the more people who grab the file via IPFS the more available that file becomes, the community can pin it if they want, etc.

## What’s Next?

Ideally I, or someone from the community, could help me solidify this into a nice, reliable service, IF the community of developers out there thinks this is a valuable service and would benefit from it.

I coded up this little PoC in about a day, having almost no experience with NodeJS or IPFS. Special thanks to [androolloyd.eth](https://twitter.com/androolloyd) – one of my favorite Ethereum hackers for helping me 🙂

Ideally, I’d like to be able to add stuff like “direct download” links for people who don’t have IPFS available, perhaps a database of txHash to IPFS hash that we can check so we don’t re-run debugs that we don’t need to run. Cleanup jobs. Maybe a front end website to make it easy to use??

Tell me what you think!

Oh..and..also…I need Nethermind and Turbo-Geth to support this method of generating Transaction Debugs 🙂