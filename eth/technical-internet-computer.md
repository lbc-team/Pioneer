> * 链接：https://medium.com/dfinity/a-technical-overview-of-the-internet-computer-f57c62abc20f 作者：[DFINITY](https://medium.com/@dfinity?source=post_page-----f57c62abc20f--------------------------------)
> 
> 

# A Technical Overview of the Internet Computer



*An explanation of the development platform’s infrastructure, and how software canisters enable web services to scale to billions of users.*

![1__C2zMptYbK0octu5L8zWew -1-](https://img.learnblockchain.cn/2020/11/03/1__C2zMptYbK0octu5L8zWew (1).png)

The last milestone before the full launch of the Internet Computer — a public software development platform created by a network of independent data centers running an advanced decentralized protocol—is fast approaching. [At a virtual event for the release of Sodium on Sept. 30](https://hopin.to/events/sodium), the DFINITY Foundation will unveil the Network Nervous System, an open algorithmic governance system that controls the Internet Computer. The event will also present in-depth technical materials regarding advanced cryptography, consensus protocols, and token economics.

Ahead of this momentous occasion, we want to provide the public with a very high-level overview of how the network operates.

## Network Nervous System

The Internet Computer is based on a blockchain computer protocol called Internet Computer Protocol (ICP). The network itself is constructed from a hierarchy of building blocks. At the bottom are independent data centers that host specialized hardware nodes. These node machines are combined to create subnets. Subnets host [software canisters](https://sdk.dfinity.org/docs/index.html), which are interoperable compute units that are uploaded by users and contain both code and state.


![1_mN3znV92PdK7T_OA4ETnjg -1-](https://img.learnblockchain.cn/2020/11/03/1_mN3znV92PdK7T_OA4ETnjg (1).jpeg)


One of the elements that makes ICP unique is the Network Nervous System (NNS), which is responsible for controlling, configuring, and managing the network.

Data centers join the network by applying to the NNS, which is responsible for inducting data centers. While the NNS itself has an open governance system, it oversees permissions to participate in the network. In a sense, it plays a role equivalent to ICANN on the internet, which, among other things, assigns autonomous system numbers for those that want to run BGP routers. The NNS fulfills a wide range of network management roles, including monitoring the node machines to look for statistical deviation on the Internet Computer network, which could indicate underperformance or faulty behavior.

The NNS also plays a key role in the token economics of the network. The NNS generates new ICP tokens (formerly known as DFN tokens) to reward nodes that are being run by data centers and neurons that are voting within the NNS, which is how it decides on proposals that are submitted to it. When the NNS creates new ICP tokens to reward data centers and neurons, it’s inflationary.

![1_SHQ1Il-EiIr48I7ywBgmqw](https://img.learnblockchain.cn/2020/11/03/1_SHQ1Il-EiIr48I7ywBgmqw.jpeg)

Eventually, data center owners and neuron owners can take their tokens and exchange them with canister owners and managers. Canister owners and managers take these tokens and convert them into cycles, and use those cycles to charge up their canisters. When those canisters perform computations or store memory, for example, they burn their way through the cycles and eventually they have to be recharged with more cycles to continue running. That’s deflationary.

## Subnets

To understand the Internet Computer, you have to understand the concept of subnets, which are the fundamental building block of the overall network. A subnet is responsible for hosting a distinct subset of the software canisters hosted by the Internet Computer network. A subnet is created by bringing together node machines drawn from different data centers in a manner controlled by the NNS. These node machines collaborate via the ICP in order to symmetrically replicate the data and computations pertaining to the software canisters that they host.

![1_a4pC_6GoBCLQVaMfYYFYcQ](https://img.learnblockchain.cn/2020/11/03/1_a4pC_6GoBCLQVaMfYYFYcQ.jpeg)


The NNS combines nodes from independent data centers when constructing subnets. This enables ICP protocol math to ensure that subnets are tamper-proof and unstoppable, using Byzantine fault-tolerant technology and cryptography developed by DFINITY. Although subnets are the fundamental building blocks of the overall Internet Computer network, they’re transparent to users and software. Users and canister software only need to know the identity of a canister to call the functions that it shares.

This transparency is an extension of the internet’s fundamental design principles. On the internet, if a user wants to connect to some software, they only need to know the IP address of the machine that’s running the software and the TCP port that the software is listening to. On the Internet Computer, if a user wishes to call a function, they only need to know the identity of the canister and the function signature. In the same way that the internet creates seamless connectivity, DFINITY has created a seamless universe for software, where any software given permission can call any other software directly without knowing anything about the underlying workings of the network.

The Internet Computer also ensures the transparency of subnets in other ways. The NNS can split and merge subnets, for example, in order to balance load across the overall network. This is also transparent to the hosted canisters.

![1_qfGWhn34r7FE_m7kR16USw](https://img.learnblockchain.cn/2020/11/03/1_qfGWhn34r7FE_m7kR16USw.jpeg)


In this example, we’ve got an imaginary subnet, ABC, that hosts 11 canisters. The NNS tells it to split. Subnet ABC continues with canisters 1–6, and a new subnet is spawned, Subnet XYZ, that continues with canisters 7–11\. None of the canisters involved will have experienced an interruption in service.

When you upload your canisters to the Internet Computer, you have to target a specific subnet type. There’s actually a special subnet that hosts the NNS, but you can’t upload your canisters to that. Instead, you have to target a subnet type, such as “data,” “system,” or “fiduciary.”

![1_aJcAA7yMOqvaO89ZMIDTow](https://img.learnblockchain.cn/2020/11/03/1_aJcAA7yMOqvaO89ZMIDTow.jpeg)


Each subnet type gives your canister certain properties and capabilities. For example, if your canister is hosted on a data subnet, it can process calls but it can’t make calls to other canisters. For that you’ll need a system subnet. If you want your canister to be able to hold balances of ICP tokens or to send cycles to other canisters, you’ll need a fiduciary subnet. And for those reasons, governance canisters can only be hosted on fiduciary subnets.

![1_a3q2laVD_obwN-sS0gNvLQ](https://img.learnblockchain.cn/2020/11/03/1_a3q2laVD_obwN-sS0gNvLQ.jpeg)

The capabilities of subnets partly derives from the underlying fault tolerance. This is a really exciting area of the underlying science that we hope to share with the public soon, including new cryptography that allows the NNS to repair broken subnets.

## Canisters

The purpose of a subnet is to host canisters. Canisters run within dedicated hypervisors and interact with each other via a publicly specified API. Inside a canister is WebAssembly bytecode that can run on a WebAssembly virtual machine and the pages of memory that it runs within. Typically, that WebAssembly bytecode will have been created by compiling down a programming language, such as Rust or Motoko. That bytecode will have incorporated a runtime that makes it easy for the developer to interact with the API.

![1_6uc9Oje4VLK8KSIhLGGSgg](https://img.learnblockchain.cn/2020/11/03/1_6uc9Oje4VLK8KSIhLGGSgg.jpeg)
<center>Note: The sample code shown here is *pseudocode.*</center>


On the Internet Computer, the functions shared by canisters must be invoked in one of two ways. They can either be invoked as an update call or a query call. The essential difference is that when you invoke a function as an update call, any changes that it makes to data in the canisters’ memory are persisted, whereas if a function is invoked as a query call, any changes that it makes to memory are discarded after it’s run.

Update calls make persistent changes, and they’re also tamper-proof because the ICP blockchain computer protocols run them on every node in the subnet. As you would expect, the calls run within a consistent global ordering of calls, using mechanisms that allow for concurrent execution within a fully deterministic execution environment. Update calls complete in just two seconds.

![1_k-sjJJxNwOIosHNsNeXFxQ](https://img.learnblockchain.cn/2020/11/03/1_k-sjJJxNwOIosHNsNeXFxQ.jpeg)

In this example, the user submits a buy order to a financial exchange hosted within a canister.

Query calls, on the other hand, don’t persist changes. Any changes they make to memory are discarded after they run. They are very performant and inexpensive, and complete in just a few milliseconds. This is because they don’t run on all the nodes in the subnet, which also means they provide a lower level of security.

![1_VPmk87CngZfZkmnDUNd5hA](https://img.learnblockchain.cn/2020/11/03/1_VPmk87CngZfZkmnDUNd5hA.jpeg)



In this example, the user is asking for a custom newsfeed and gets back freshly generated content almost immediately.

## Orthogonal persistence

One of the most interesting things about the Internet Computer is the way that developers persist data. Developers don’t have to think about persistence — they just write their code and persistence happens automatically. It’s called orthogonal persistence. That’s because the Internet Computer persists the memory pages in which code runs.

You might be wondering how this all works. With respect to update calls that can mutate memory pages, canisters are software actors. That means there can only be a single thread of execution inside a canister at any given time.


![1_ufXP2244hUCcfBWNbBa8gw](https://img.learnblockchain.cn/2020/11/03/1_ufXP2244hUCcfBWNbBa8gw.jpeg)


Although there’s only a single thread of execution inside a canister, cross-canister update calls can be interleaved by default. That occurs when update calls make cross-canister update calls, which block, allowing the thread of execution to be moved to a new update call.

![1_p6HeMQ7bIQTa-oLrCuXUdg](https://img.learnblockchain.cn/2020/11/03/1_p6HeMQ7bIQTa-oLrCuXUdg.jpeg)

Query calls, by contrast, don’t make persistent changes to memory. And this allows there to be any number of concurrent threads processing query calls inside of a canister at any given time. These query calls run against the snapshot of memory recorded in the last finalized state root.

Finally, no discussion of canisters would be complete without mentioning that canisters can create new canisters, and that the canisters can fork themselves. You can create a new canister simply by specifying the WebAssembly bytecode, and the memory pages start out empty. When a canister forks itself, a newly spawned copy is created that’s identical down to the memory pages inside. Forking proves very powerful when creating scalable internet services.

## Scalability

Now comes a high-level explanation of internet services that scale out. Canisters have upper bounds on their various types of capacity. For example, a canister can only store 4GB of memory pages due to the [limitations](https://v8.dev/blog/4gb-wasm-memory) of WebAssembly implementations. For this reason, when we want to create internet services that scale out to billions of users, we have to use multi-canister architectures.

![1_EC2NnBXu1IpzomK5BKv1-w](https://img.learnblockchain.cn/2020/11/03/1_EC2NnBXu1IpzomK5BKv1-w.jpeg)

We might hope that it’s enough to create some special canister, create lots of copies of the canister, and then shard user content to the different canisters in order to create an internet service that can scale out. Unfortunately, this architecture is too simple for a number of reasons.

It’s true that each additional canister increases the overall memory capacity. It’s also true that each additional canister increases the overall update and query call throughput. But we cannot scale query call requests for a specific user’s content. We also need to rebalance user content whenever we increase the capacity of the system by adding more canister shards, and it’s not really a great edge architecture. There’s also no obvious way to serve query calls to end users from replicas that are in close proximity to them. We’re going to need both front-end canisters and back-end canisters.

![1_Cu4-UfbuprS8U3qOBkgIQw](https://img.learnblockchain.cn/2020/11/03/1_Cu4-UfbuprS8U3qOBkgIQw.jpeg)

The Internet Computer provides some interesting features for connecting end users to front-end canisters. One of these allows domain names to be mapped to multiple front-end canisters via the NNS. When an end user wishes to resolve such a domain name, the Internet Computer looks at the totality of replica nodes in all the subnets hosting the front-end canisters and returns the IP addresses of the replica nodes in closest proximity. This results in the end user executing query calls on nearby replicas, reducing the inherent network latency and improving the user experience, providing the benefits of edge computing without a content distribution network.

![1_6RXOB-vMbOxs1Xw8-4QS3g](https://img.learnblockchain.cn/2020/11/03/1_6RXOB-vMbOxs1Xw8-4QS3g.jpeg)

To make the best use of this functionality, we need a classic architecture involving front-end canisters and back-end data bucket canisters. In this example, a web browser wishes to load a profile picture.

![1_BQA0cqG8neFU9vfFpwnSNw](https://img.learnblockchain.cn/2020/11/03/1_BQA0cqG8neFU9vfFpwnSNw.jpeg)

First of all, the web browser will be mapped to a front-end canister that is running on a subnetwork with a nearby node. The web browser will then submit a query call request to retrieve the photograph to that nearby node.

![1_b-ABeQN5lhUaFUDVFAJ6Wg](https://img.learnblockchain.cn/2020/11/03/1_b-ABeQN5lhUaFUDVFAJ6Wg.jpeg)


The front-end canister will then make a cross-canister query call request to the data bucket canister that holds the photograph.

![1_OHetSwK8a4rqnn5Y6Vd_CQ](https://img.learnblockchain.cn/2020/11/03/1_OHetSwK8a4rqnn5Y6Vd_CQ.jpeg)

If the query call response returned by the data bucket canister involves static content such as a photograph, then the data can be stored in a cache. In such cases, the replica node that’s running the front-end canisters query call can enter the query call response into its query cache.

![1_EJwZt6resEhYTqHVq1U9CA](https://img.learnblockchain.cn/2020/11/03/1_EJwZt6resEhYTqHVq1U9CA.jpeg)

Of course, the query call caching mechanism is completely transparent to the front-end canister code. Once the front-end canister that the user called has collected all the necessary information, it can return the content, either through a query call response or through an HTTP endpoint.

![1_O6OYB5N15AIW_PLUjkZQEg](https://img.learnblockchain.cn/2020/11/03/1_O6OYB5N15AIW_PLUjkZQEg.jpeg)

Over time, the query caches of nodes accumulate static content and generate data that’s of interest to nearby users, providing them with a faster, better user experience. In this way, the native edge architecture of the Internet Computer provides the benefits of a content distribution network, but without developers having to do anything special, and without the need to enlist the help of a separate proprietary service.

![1_oTKvmAdoZUFIW5EtUaMl8w](https://img.learnblockchain.cn/2020/11/03/1_oTKvmAdoZUFIW5EtUaMl8w.jpeg)

For update calls, the classic architecture takes a different approach. It’s necessary to serialize updates to a user’s content and data to prevent problems like lost updates. Typically, this is achieved by mapping a user to a specific front-end canister just by hashing their username, for example.

![1_lxAHdQHHxN3DXIozI62OpQ](https://img.learnblockchain.cn/2020/11/03/1_lxAHdQHHxN3DXIozI62OpQ.jpeg) 

Once a UX/UI running on a web browser or on a smartphone has determined which front-end canister is responsible for coordinating changes to some content or data, it can modify that content or data by submitting an update call to its standard interface.

![1_A1L6WhqIeR3A5WohOdKt6Q](https://img.learnblockchain.cn/2020/11/03/1_A1L6WhqIeR3A5WohOdKt6Q.jpeg)

This front-end canister then typically makes more cross-canister update calls to effect the changes needed.

## Open internet services

To wrap this all up, let’s discuss designing an open internet service using our two-level architecture with front-end canisters and back-end data bucket canisters. First of all, when you write your front-end canister code, you’re going to make your life easy by using the existing library class called BigMap.

![1_yTOjDnUCpVHznMFOtnpRIA](https://img.learnblockchain.cn/2020/11/03/1_yTOjDnUCpVHznMFOtnpRIA.jpeg)

BigMap can store exabytes of data, and you can write objects to it using just one line of code. This architecture will transparently and dynamically scale out by having front end canisters and data bucket canisters fork to divide responsibility for objects assigned to one canister between two canisters.

Finally, to create a true open internet service, you’ll assign responsibility for all your canisters to an open tokenized governance canister. If you’re an entrepreneur, you will raise funds for development by selling some of those governance tokens in the early days. And you’ll probably design schemes that incentivize early participants in your internet service by giving them governance tokens to get better network effects — and win.











