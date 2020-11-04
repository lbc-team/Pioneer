> * 链接：https://medium.com/dfinity/how-ethereum-could-be-supercharged-by-the-internet-computer-network-afc513bf15e1 作者：[Dominic Williams
](https://medium.com/@dominic_w?source=follow_footer-------------------------------------)
> 
> 

# **How Ethereum Could Be Supercharged by the Internet Computer Network**


*The Ethereum community played a key role in the genesis of the Internet Computer project, and will use the network to extend the capabilities of Ethereum dapps.*

![](https://img.learnblockchain.cn/2020/11/04/16044759247329.jpg)

On **September 30, 2020**, the Internet Computer project will pass its Sodium milestone and enter a final stretch before the launch of the public network. These are exciting times for project supporters and the Ethereum community, which provided initial funding in early 2017, and whose core devs contributed in the early days, and shall now use the Internet Computer to extend the capabilities of Ethereum dapps.

**The Internet Computer (IC) is a public blockchain that works differently to any currently in production that introduces new capabilities and functionalities that are highly additive to the decentralized ecosystem.** The network’s architecture leans heavily into the design philosophy of the internet, and is created by independent data centers around the world running huge numbers of special“node computers”that have *standardized hardware.* The compute power of these node computers is combined by an advanced blockchain protocol called ICP (Internet Computer Protocol) that creates a seamless universe where an evolution of smart contracts can be run that are fast and efficient, called “software canisters”, or just “canisters” for short. **Ethereum dapps can use software canisters to expand their capabilities in a multitude of exciting ways, including scaling data storage and processing, and serving Web experiences.**

![](https://img.learnblockchain.cn/2020/11/04/1.jpeg)
<center>An Internet Computer node machine. Four manufacturers currently making this spec. as of Aug 2020</center>



# The Internet Computer is different

**Today’s blockchains disburse “block rewards” to incentivize the “miners” who run hardware to support the operation of their networks.** Miners compete to append new blocks to the blockchain, and when they are successful, are allowed to assign the block reward inside their new block to themselves. In Proof-of-Work networks, miners gain the right to mint new blocks through repetitive hashing, and over the long term, produce blocks in proportion to the hashing they perform relative to everyone else. In Proof-of-Stake networks, miners gain the right to mint new blocks by stashing tokens on nodes, and over the long term, produce blocks in proportion to the size of their “stake” relative to all other stakes. **The ICP protocol takes a different approach and rewards independent data centers for the time that they *correctly operate* standardized compute nodes.**

ICP rewards the operation of node computers, since it is their compute power the network specifically cares about as it underpins the seamless universe for smart contracts and data it creates in cyberspace (the “Internet Computer”). In a sense, the protocol is an evolution of Proof of Work where repetitive hashing has been replaced by whatever useful compute work the network needs the nodes to perform. When the network draws groups of nodes from independent data centers into subnets that host smart contracts, it demands from them common behavior, rather than competitive behavior, and rewards nodes for producing a median number of blocks, rather than engaging them in competitions that are not directly related to the functional purpose of the network. **This is just one of many architectural pillars that the Internet Computer combines with advanced computer science and cryptography so that it can scale out its capacity with demand, and efficiently host smart contract software and data, providing performance on a par with, or better than, the traditional cloud, in many applications.**

In addition to driving forward the capabilities of dapps, the Internet Computer project has several other aims. One of these is to create a public network that can be used as a *complete replacement for today’s legacy IT stack*, including Big Tech’s cloud services, and legacy infrastructure software such as file systems, web servers, middleware, and databases. Another is to *enable the creation of “open internet services”* (or OSIs), which are built with autonomous software controlled by tokenized governance systems, which can replace the closed, proprietary and often monopolistic services of Big Tech that are so problematic for users and currently stifling innovation on the Internet. It aims to reinvigorate the internet ecosystem by enabling services to trustlessly share functionality and data via non-revocable APIs, providing for service composability and allowing startup entrepreneurs to acquire better network effects when fighting centralized incumbents. **The long standing aim of the project is to move the world towards a future where all of humanity’s services, software systems and data live *on* a blockchain.**


![](https://img.learnblockchain.cn/2020/11/04/1_egqtVc1ZHyslxvlzaeOthw.png)
<center>CanCan, an open TikTok clone on the Internet Computer, streaming video to a phone</center>


**The Internet Computer works differently than traditional blockchains, and this enables Ethereum developers to incorporate its capabilities into their dapps with relative ease.** For example, whereas Ethereum requires users to submit some amount of ETH with every transaction to pay for the gas that fuels the computation resulting from smart contract code being invoked, on the Internet Computer canisters (a form of smart contracts) are *pre-charged* with “cycles” (the equivalent of gas) and pay for computation themselves. This means users can interact with services provided by canisters without making payments and thus needing to configure a token wallet such as MetaMask, and hosted code can serve web pages and media objects directly from cyberspace into web browsers, for example, even when the end user is anonymous.

# Where the Internet Computer Fits

One way of thinking about the Internet Computer is of being on a continuum running from traditional cryptocurrency through to a highly optimized blockchain computer. On this spectrum is Bitcoin, which is a pure cryptocurrency designed as a digital gold, through Ethereum, which is a highly programmable cryptocurrency capable of supporting sophisticated DeFi, through to the Internet Computer, which can run mainstream enterprise systems and hyperscale internet services. All three are blockchains, but they provide different things.

**The Ethereum network is currently in the process of moving to a Proof-of-Stake model, which will allow anyone with ETH tokens to run a network node, maximizing the anonymity of participants and resistance to government censorship. The Internet Computer hosts “software canisters”, which are tamperproof just like Ethereum smart contracts, but the underlying network is formed by large numbers of independent data centers around the world — which are not anonymous — running standardized compute hardware, in order to provide unbounded scalability, and increase speed and efficiency by many orders of magnitude**. The Internet Computer’s protocols also apply far more advanced cryptography and computer science, making it more difficult for community developers to drive R&D alone, and is backed by a large team of full time engineers and cryptographers who are currently distributed across four dedicated international research centers, as well as remote teams. This is just a case of “horses for courses”.

# **Integrating Dapps with the Internet Computer**

**What’s so exciting for the Ethereum community is that by bridging to the Internet Computer, dapps can leverage its compute power and the unique functionalities it provides.** For example, dapps might maintain master settlement logic on Ethereum, while using the Internet Computer to scale-out compute intensive processing within the trustless decentralized ecosystem, or serve websites directly into web browsers, removing the need to run them on trusted, insecure, and potentially unreliable proprietary services such as Amazon. Before looking at some examples, let’s first consider how code on Ethereum and code on the Internet Computer can be integrated.

What may surprise you, is that there is work ongoing at the DFINITY Foundation involving advanced cryptography that will allow canister code running on the Internet Computer to securely create and sign Ethereum and Bitcoin transactions. This is related to the “chain key” technology I have recently discussed on Twitter in relation to getting past the need for blockchain hubs. Having code on the Internet Computer call directly into code on Ethereum can therefore be considered straightforward. Going in the other direction is a little bit more tricky. The simple solution will be to have trusted “relay nodes” respond to actions by Ethereum smart contracts by making calls to canisters on the Internet Computer on their behalf. If the security risk is too high (since the trusted relays will need to maintain keys that allow them to call into the canisters on the Internet Computer) then the relay code can additionally be required to submit a sequence of block headers as proof that the smart contracts they report are genuine — and there’s plenty of code out there to handle that kind of thing.

# Examples

## How to Serve a DeFi Website

**Although we can build brilliant DeFi systems on Ethereum using trustless, tamperproof, and unstoppable smart contracts, the users of those systems must often interact with our contracts using insecure, trusted interfaces**. For example, we can build a prediction market using Ethereum smart contracts, which can process ETH and wrapped BTC, say. The system should be completely unstoppable, tamperproof and fair — and it’s even transparent because people can even match smart contract byte code on the Ethereum network with the original Solidity source code on GitHub, which allows them to view the processing logic involved. The problem is that more often than not, users will need to interact with the contracts using a website we created on a trusted centralized service such as Amazon Web Services (AWS).

**This can go wrong in many terrible ways.** First of all, AWS licenses its services to legal entities, which are either individuals or organizations, rather than autonomous code. Such entities can become legally responsible for DeFi systems that are otherwise decentralized and open, and AWS can also simply decide that it wants to stop providing its services and simply turn the website off. Moreover, the website is running on a trusted platform that can be tampered with. The website might be hacked by a malicious Amazon employee, an outside hacker, or the licensing entity might be malicious. The user has no guarantee that the website they are browsing has not been modified, which could have catastrophic results. They might be conned into signing a bad transaction, the market information they are viewing might be redacted or false, and the web page might delay the submission of their orders, for example, so that someone can front-run them. These are just the obvious problems, and examining the security of ancillary systems such as DNS reveals even more.

**To escape from this mess, instead of using AWS to serve websites we can create secure web front ends for our dapps by installing canisters on the Internet Computer.** These can provide a user experience based upon something called “query calls,” which don’t provide the same level of overwhelming security provided by “update calls” (the equivalent of standard transaction execution on Ethereum), but execute with lightning speed while still providing a very high level of security, delivering a vastly more trustless and safer experience than might be achieved otherwise.

To create an Internet Computer front end for a dapp, do the following:

1. Have Ethereum smart contracts forward copies of data required by the website to the front-end canisters on the Internet Computer. Have the canisters cache the latest copy of the data in their state.
2. Design a website that is securely served from the front-end canisters directly from cyberspace into web browsers, generating the content from the most recent copy of the forwarded data.
3. Design how users create Ethereum transactions, for example, to submit and order. Either simply embed a system like MetaMask inside the pages served, such that transactions can be sent directly to the Ethereum network from inside the pages, or first report orders to the canister and have its code generate the Ethereum transaction (note this requires a
    “chain key” upgrade, so start with the first method).

![](https://img.learnblockchain.cn/2020/11/04/2.png)
<center>The incredible LinkedUp OSI website demonstrated at Davos in January 2020 (Bronze milestone)</center>


## How to Store and Process Large Datasets

[**To store 1GB of data inside a smart contract on the Ethereum network would cost millions of dollars**](https://medium.com/ipdb-blog/forever-isnt-free-the-cost-of-storage-on-a-blockchain-database-59003f63e01)**, which can make it prohibitively expensive to maintain anything beyond fiduciary data. By contrast, the cost of storing 1GB of data inside a canister on the Internet Computer over some substantial period of time can cost as little as a few cents, providing an incredible solution for Ethereum dapps that need to maintain and process large data sets.** On the Internet Computer, accessing and modifying data consumes predictable quantities of cycles, which themselves are pegged to traditional currencies, which makes managing storage very simple and predictable for dapps.

Maintaining data on the Internet Computer is incredibly easy for developers. The reason canisters are called “canisters” rather than “smart contracts” is that they are in fact bundles of code and state. Under the hood of a canister, there is smart contract logic in the form of WebAssembly byte code, which the developer has created by compiling high-level code using a programming language such as [Motoko](https://sdk.dfinity.org/) (see also [this recent article by Andreas Rossberg](https://stackoverflow.blog/2020/08/24/motoko-the-language-that-turns-the-web-into-a-computer/), the co-creator of WebAssembly) or Rust, and also state, which consists of the very memory pages that the smart contract logic runs within (in the role of a software “[actor](https://en.wikipedia.org/wiki/Actor_model),” for those interested). **There are no files or database APIs on the Internet Computer — the persistence of data happens automagically in a system of “**[**orthogonal persistence**](https://en.wikipedia.org/wiki/Persistence_(computer_science)#Orthogonal_or_transparent_persistence)**.”**

What this means is that developers can write code as if it will run forever, and that the variables, objects, collections, and other type instances in their high level code will never be reset, and consequently are sufficient to maintain their state. In essence, the architecture of the Internet Computer enables it to persist memory pages on behalf of smart contract code so that the programmer can just describe high level abstractions for holding and processing data, **removing one of the biggest sources of complexity and headaches from programming, as well as unlocking new levels of efficiency.**

Orthogonal persistence means that storing a user profile can be as simple as assigning to a map object, as show below:

![1_Tdd7f58GxLOfP26-220ZrQ](https://img.learnblockchain.cn/2020/11/04/1_Tdd7f58GxLOfP26-220ZrQ.png)
<center>Maintain data in a standard HashMap object. Internet Computer memory is persistent!!</center>



Each canister can maintain up to 4GB of memory pages. But if that is insufficient**, a system can be composed of any number of interacting canisters, such that there is no upper bound on the total quantity of data that they can maintain.** Moreover, there is no need for the developer to maintain multiple canisters themselves, since they can simply import, say, a BigMap canister that provides horizontally scalable map functionality, which allows exabytes of object data to reside in main memory, as shown below:

![1_ptQrlZYAHqnxUjYiuxjfIQ](https://img.learnblockchain.cn/2020/11/04/1_ptQrlZYAHqnxUjYiuxjfIQ.png)
<center>BigMap maintains a network of canisters to enabling you to maintain exabytes of data in memory!!</center>



**Use the same kinds of integration techniques we previously discussed to extend your dapps so that they can process vast amounts of state within this trustless, tamperproof, unstoppable, and decentralized ecosystem!**

**PRO TIP** for curious blockchain architects: The Internet Computer network only maintains the current state of hosted canisters, and does not maintain past blocks (beyond short-term caching). This is one of the ways that it minimizes costs and maximizes computational efficiency, and it is again related to the chain key cryptography technology mentioned earlier. A user (or rather, a user library embedded in the frontend of a dapp, since no user wishes to interact with a low-level blockchain protocol themselves!) can verify their interactions with the Internet Computer network, and the function calls that it executes and the data it returns, starting with only a single 32-byte “chain key.” Consequently, it is vastly less expensive to interact with large data sets maintained by the network, since it is not necessary to download a local copy of the complete chain state and past blocks to interact with it securely.

# Get Started

A great way to get started with Internet Computer canisters is using an SDK developed by the DFINITY Foundation: [**https://sdk.dfinity.org**](https://sdk.dfinity.org).

At the time of writing there are DFINITY SDK’s for [Motoko](https://stackoverflow.blog/2020/08/24/motoko-the-language-that-turns-the-web-into-a-computer/) programmers, and Rust programmers (or about to be at time of writing).

If you are interested in extending support to additional languages, please contact the [**DFINITY team**](https://dfinity.org/foundation#team).

The Internet Computer is under continuous development by [one of the most talented teams](https://dfinity.org/foundation/#team) in tech.

The major [**“Sodium” milestone event**](https://hopin.to/events/sodium)is approaching at end of September (2020), which shall deliver numerous important updates and capabilities— stay tuned!!

Follow me for updates: [https://twitter.com/dominic_w](https://twitter.com/dominic_w)

![1_VeWlfNPJfvr1_00lvTJyww](https://img.learnblockchain.cn/2020/11/04/1_VeWlfNPJfvr1_00lvTJyww.jpeg)
<center>I love the Motoko mascot :)</center>



Bfn!

