![](https://img.learnblockchain.cn/2020/12/07/5fbd1cb4c46914052a5849cc_Blockchain Guide COver.png)


# A Guide for Developers Interested in Learning Blockchain Development

An opinionated list of resources to get you on your way


*A special thanks to* [*RNG*](http://discord.gg/rnglife) *for hosting the talk that gave rise to this article. RNG is a wonky collective of gamers, game devs, blockchain devs, esports enthusiasts, metaverse enthusiasts, NFT enthusiasts, and pretty much anyone who likes hanging out with those sorts.*

I was recently asked in an online forum for my recommendations on resources for developers looking to learn blockchain development, and I started writing an answer, but it sort of kept on going and going. The results are the article in front of you.

‍

This isn’t an article about the advantages and disadvantages of building on a blockchain. It’s just a guide about the things  you’ll need to learn once you’ve decided to learn blockchain, and what the steps of making a blockchain application look like. Not everything should be on a blockchain.

‍

There are a lot of different resources out there, and as with any tech stack choices, things can get opinionated. There is still a need, especially with regards newcomers in the field, to direct to the right tools. I'll try to find a middle ground in between my opinions and a general list.

‍

## Which chain do you want to build on?

‍
![](https://img.learnblockchain.cn/2020/12/03/16069832709375.jpg)


It doesn’t really matter - I'm going to talk about the tools and resources on Ethereum. Some are compatible with some other chains, some are not (at least that's what I'd guess). My personal best guess is that if you're learning about blockchain apps for the first time, learning how to write for and to deploy to Ethereum is likely the best place to start, even if your goal is to build on a different chain. As such, the list here is Ethereum-focused.

‍

## A Warning

‍
![](https://img.learnblockchain.cn/2020/12/03/16069833026349.jpg)



‍
One warning about Ethereum development is how fast it changes. You know how React code from three years ago looks nothing like React code now? Well, Ethereum is worse. Solidity evolves fast, and with sometimes breaking changes. Gas optimization changes as EIPs seek to find better gas pricing mechanisms. New patterns are discovered and popularized. New bugs are found and excised. What was true today might not be true tomorrow. But even so, if you learn Solidity 0.5, you'll still have the bulk of what you need to understand 0.7, and not just that, 0.7 will likely make things easier, not harder. (Looking at you, underflow/overflow protection.)

‍

## Writing Smart Contracts

‍![](https://img.learnblockchain.cn/2020/12/07/giphy (1) (1).gif)


The basic package of creating a dApp involves being able to write contracts, and then something that can communicate with them. I'm going to assume that the something that communicates with the contracts, be it a frontend, API, or whatever, is written in JavaScript. There are tons of libraries out there, I think most fairly mainstream languages have libraries for communicating with Ethereum, but I know the most about JS's ecosystem.

‍

It's worth mentioning that you can make a dApp without coding a single contract. You can build on other people's contracts - that's part of what being a public blockchain is. Do you want to build an alternative frontend for Uniswap? Uniswap can't stop you. They may have some trademarks, so no, you can't make a frontend for Uniswap and then say you are legit the Uniswap team, but you can say 'hey! This is my Uniswap frontend, and it does everything Uniswap's frontend does, but is much cooler, pay me $5/month to use it', and that's completely fine. Still, building for Ethereum usually assumes at least general knowledge of smart contract development. It'll be hard to make an interface with the Uniswap contracts if you don't understand what you're looking at when you look at their contracts.

‍

Solidity is the language to start with in terms of smart contracts. Vyper is a super cool language, I even have a PR in it (largely meaningless, I'm the one who implemented the decision to move to f-strings wherever possible in their codebase, if you know Python), but it's not where you start. There's a larger community around Solidity, meaning more resources, and more people to reach out to when you're stuck.

‍

[Cryptozombies](https://cryptozombies.io) is still probably the best tool for diving into Solidity, even though I don't think it's actively maintained. It's a tutorial where you make a Cryptokitties-like game. (For the record, there is a game-building tutorial which is a bit of a work in progress for Vyper [here](https://vyper.fun).)

‍

I actually find [Solidity's documentation](https://solidity.readthedocs.io/en/latest/) to be quite readable, even though I usually have a mental block around documentation. (Looking at you, Python.) I especially find the "Solidity by Example" section to be useful in seeing what different elements of Solidity look like when implemented.

‍

There are good Solidity tools in Visual Studio Code, and some okay ones in Atom, from what I remember. I think the Vim package got a new maintainer, which it desperately needed, and I don't know anything about Emacs support, but I'm sure there's at least something for it.

‍

One last point: there are a lot of general purpose contracts that you should never write yourself, except for educational purposes. Have you heard about making your own ERC20 token or NFT? That’s great! Don’t write your own boilerplate for them. You should be taken an audited, reliable, open-source boilerplate and building on it, not building it from the ground up. The gold standard is [Open Zeppelin](https://openzeppelin.com/). The repository for their contracts are [here](https://github.com/OpenZeppelin/openzeppelin-contracts), and they have their own [npm package](https://www.npmjs.com/package/@openzeppelin/contracts).

‍

## Smart Contract sandboxes (dev chains)

‍![](https://img.learnblockchain.cn/2020/12/03/16069834539353.jpg)


The next thing to discuss after Solidity itself is sandboxes for playing around with contracts. Let's say you've written a contract, and you want to test it out, see if it works. How do you do that? You're right if you think that you aren't supposed to deploy every Hello World and draft contract to mainnet. Even though there are testnets (maintained Ethereum blockchain where the social contract is that the native ETH is worthless, and is not transferable to other chains), the general workflow doesn't go straight to testnets either. Instead, there are dev chains, virtual chains you can spin up on your machine as needed. That helps you see if your contract is compiling, and lets you test the contract's functions and variables to see if they work as intended. There are limitations to dev chains - one easy example is that if you're building something that interacts with DAI, it'll mean deploying a clone of Maker (DAI) to your dev chain every time you spin it up, in addition to deploying your own contracts. It is still a great first step.

‍

#### The main tools for doing this are:

‍

* [Remix](https://remix.ethereum.org), which is the place to start if you're working with contracts and nothing else (no frontend). Remix can also connect to testnets and mainnet, and is a fairly powerful tool. It can have a bit of a learning curve and look like gibberish at first, but once you've gotten the hang of just compiling and deploying, there is a lot you can do with it.
* [Ganache](https://www.trufflesuite.com/ganache) (a part of the [Truffle](https://www.trufflesuite.com/) Suite), and [Hardhat](https://hardhat.org/) (a separate framework from [Nomic Labs](https://nomiclabs.io/)) - we'll talk about these two more in a minute. They are part of larger frameworks and can be used for contracts alone, but shine when you have a whole application.

‍

Just to clarify, a traditional deployment contains the following steps. First, the contracts need to be compiled. This breaks them down from Solidity (or whatever) into JSON. One particular kind of JSON you'll see mentioned is an ABI, which is a JSON representation of the schema of the contract. These are used in development quite a bit. Then there is the actual deployment, sending the bytecode of a contract to the chain in a transaction. In order to interact with a contract, you need to know its location on a chain (the contract address), and you need its ABI. [Etherscan](https://etherscan.io) is a valuable tool for getting information on contracts on-chain. For example, if you know a contract address, but don't know it's ABI, oftentimes Etherscan will have it, or be able to figure it out (decompile the bytecode).

‍

## Frameworks

‍![](https://img.learnblockchain.cn/2020/12/03/16069834780913.jpg)


That brings us to making a UI (or API or whatever) around a contract. Once you've deployed, how is your contract going to be interacted with? There may be some cases where just having a contract on-chain is enough, and anyone interacting can be expected to use something like Remix in order to interact with it, but usually not. I'm going to start with assuming that there is some kind of GUI in your project. If this is the case, you're going to want a framework. A blockchain framework will integrate your contracts into a frontend project, compiling your contracts into JSONs that can be understood by the frontend (with proper tools, more on that later), providing the ability to spin up dev chains, and to deploy contracts.

‍

The most popular framework is [Truffle](https://www.trufflesuite.com/). Many of the online resources that teach dApp development teach Truffle, too. Truffle can compile, exposes dev chain tools in the form of Ganache, and more.

‍

That being said, I recommend [Hardhat](https://hardhat.org/). Similar to Truffle (I believe it's actually built out of Truffle), you can compile contracts, and get access to dev chains. There's more, though. Solidity does not have console.log out-of-the-box, but Hardhat basically made their own hacked EVM that lets you log in your contracts. Hardhat also has fewer compilation issues in my personal experience. (Looking at you, node-gyp.) There are also more amenities. Before you go and try and set up your own Hardhat environment, let's talk about web3 libraries, and then I'll have a suggestion which should make that far easier.

‍

web3 libraries (lowercase 'w') are the semi-official term for libraries that bridge between non-blockchain code (like JavaScript) and the blockchain. Where's the JavaScript code for instantiating a Contract object, and then for calling a function on that contract? Actually, what functions do you use to connect to the chain at all? Obviously, JS doesn't have that built-in. This is where web3 libraries come in. They expose functions for doing all the things you’ll need to do. The two most prominent libraries in JavaScript are [Web3.js](https://web3js.readthedocs.io/en/v1.3.0/) (link is to the docs for the current latest stable release at the time of writing) and [Ethers.js](https://docs.ethers.io/v4/). I personally find the latter much easier to work with, and would recommend you do the same. (One pro tip is that the current Ethers (v5) has docs that are still a work in progress. If you have trouble finding or understanding something in the v5 docs, search the [v4 docs](https://web3js.readthedocs.io/en/v1.3.0/) as well. The search is more robust, and there are more code snippets.)

‍

> I don’t know of any resources that really zoom in on web3 library proficiency, but the recommendations I give at the end also cover web3.

‍

This has been a lot - you need contracts, a framework environment, and a web3 library. Wouldn’t it be nice if there was some… *thing* that mashed that all together in One Environment to Rule Them All?

‍

## One Environment to Rule Them All

‍
![](https://img.learnblockchain.cn/2020/12/03/16069835210642.jpg)


Naturally, there is. [Scaffold-Eth](https://github.com/austintgriffith/scaffold-eth) has an out-of-the-box environment set up with Hardhat and a ton more in the context of a React app. Web3.js and Ethers are both installed with the same yarn install that installs the rest of the dependencies. It is by far the most painless way to get started, as it has little to no configuration. There is a ton going on in Scaffold, including custom hooks and components. There is even a custom contract component that gives you a near-frictionless way to interact with contracts very similar to Remix. After compiling contracts (which are then automatically injected into the frontend), just drop a **<Contract name=”YourContract /> component in App.jsx** , where name is the name of your contract. Austin Griffith (the author) has a super hyper mode three-minute run-through on an older version of Scaffold [here](https://youtu.be/ShJZf5lsXiM), and a longer walkthrough [here](https://youtu.be/_yRX8Qi75OE).

‍

There’s also a super friendly Telegram channel around it, listed in the README on the GitHub. I strongly recommend it. It’s like the difference between struggling with Webpack and Babel against Create-React-App.

‍

The last thing I’d like to talk about is another detail in the blockchain stack. A blockchain is a network of nodes that each store the history (or some history, I’m not getting overly pedantic about this here) of the blockchain. How does your React app tap into the network? While it’s true that the web3 libraries expose a web3 provider, how does it know where the nodes are, and how to query them? The answer is that it doesn’t. You need to either run your own node or connect to a service that runs them. That’s what finally completes the bridge - your JavaScript uses a web3 library to send a command the chain understands, that command is sent through the web3 provider to the network (either a node or a service, as above), and the viola, you’re talking with the blockchain.

‍

## Blockchain Nodes

‍![](https://img.learnblockchain.cn/2020/12/07/giphy (3).gif)


While I recommend running your own node, and even wrote [a long article](https:/![giphy -3-](https://img.learnblockchain.cn/2020/12/07/giphy (3).gif)
/medium.com/better-programming/run-an-ethereum-node-on-linux-late-2019-b37a1d35800e) about installing Geth, I have to admit using a service is the more widespread practice. I’ll compromise, and give you some information on both. I would recommend [Nethermind](https://www.nethermind.io/) for running your own node for various reasons. In order to be able to do this, you’ll need an SSD which should really have at least 500GB of space. You can sync with 4GB RAM, but should probably have at least 8\. (These are figured for mainnet, testnets need significantly less space, and can probably get by with less memory.) If you’re also doing intense graphics work, you probably already have more, and you can tune how much RAM Nethermind uses fairly easily. Nethermind is written in .NET, but I have not had any problems with it on *nix systems. In terms of services, [Infura](https://infura.io) is the most well-known and widely used, though newcomer [Alchemy](https://alchemyapi.io) deserves a good look too.

‍

One of the reasons I pushed this here and didn’t mention it before is that it is a bit of a non-sequitur. In terms of your actual development, whether or not you run your own node or use a service, the actual impact on your codebase is about half a line when you instantiate a web3 object and need to know what to connect it to.

‍

## Wallets

‍![giphy](https://img.learnblockchain.cn/2020/12/03/giphy.gif)




‍

Similarly, you’ll probably want [MetaMask](https://metamask.io) installed on your browser to test wallet interaction. You could also use other wallets, but MetaMask is still the king in my book.

‍

## Next-Level Stuff

‍![giphy -1-](https://img.learnblockchain.cn/2020/12/03/giphy (1).gif)

Once you’ve got these basics down, you’ll quickly run into a whole new basket of issues and concerns. I couldn’t possibly cover all of them here, I don’t know all of them myself and don’t know enough to intelligently address others, but I’ll try to talk a bit about some of the next things you may want to look into.

‍

# Decentralized file storage

‍
![](https://img.learnblockchain.cn/2020/12/07/giphy (2) (1).gif)



Writing to the blockchain is expensive. You literally pay for each bit of information you write or alter onchain. Not just that, but every node that ever syncs with the chain will have to execute whatever you’ve put on-chain as it syncs. This makes for some interesting optimization in code, but it also makes you think about what should go on-chain at all. Something the chain serves poorly is data storage.

‍

Let’s say you have a platform with user profiles. You don’t want to be storing their bio and avatar on-chain. Where should it go then? Some centralized server? (Cue overly dramatic music:) What was the whole point of decentralizing the whole platform if malicious parties can arbitrarily change users’ avatars!? Don’t worry, there are still decentralized ways to store the data. Decentralized file storage also relies on decentralized peer-to-peer networks, just like blockchains. (Some of the current generation also communicate with their own blockchain, but that’s neither here nor there.) They specialize in taking data in storing it, though. The highest-profile of them right now is Filecoin, though I would personally also mention Swarm and Sia. [Swarm](https://swarm.ethereum.org/) in particular. There may be different advantages to different providers depending on what kind of data you need stored (audio, video, text), what functionality you need (I believe only Swarm is close to a solution on how to delete data), etc.

‍

# Layer 2 solutions

‍

Ethereum itself has gotten to the point where transactions can be prohibitively expensive, and/or take a prohibitively long time to get mined. In addition, privacy can be a difficult venture on the mainnet. Layer 2 solutions have been developed to mitigate congestion issues, and some offer more robust privacy guarantees. We’re in a bit of a Wild West phase with L2s. There are a large number of what seem to be robust, market-ready solutions. Reddit wants an L2 to put some in-platform currency and [received over 20 submissions](https://www.reddit.com/r/ethereum/comments/hbjx25/the_great_reddit_scaling_bakeoff/). I can’t compare and contrast the available platforms - I lack the information and knowledge. If you’re interested in me picking one out of the hat to look at first, I’d recommend [StarWare](https://www.reddit.com/r/ethereum/comments/hbjx25/the_great_reddit_scaling_bakeoff/)’s Cairo or something built with it.

‍

## Oracles


![](https://img.learnblockchain.cn/2020/12/07/16073039592704.jpg)



‍

Sometimes you want to do something on-chain based on something that happens off-chain. Let’s say you want to sell Ether if its USD value is over a certain amount. USD doesn’t live on-chain (currently), so how is the blockchain supposed to know? You could write a bot that polls the price, and executes a transaction if the condition is met, but let’s say you need to have this information in a smart contract - how is the contract supposed to know? This is the problem oracles are meant to solve.

‍

Unfortunately, things that can look like simple solutions are not necessarily ample. samczsun, a rather legendary Ethereum white hat, recently [put out an article](https://samczsun.com/so-you-want-to-use-a-price-oracle/) about oracle attacks. The upshot is to be careful with what you’re doing there.

‍

There are also oracle services. [Chainlink](https://starkware.co) is almost certainly the most famous of them, but make sure it fills your needs. samczsun addresses this better in his article than I possibly could, so I’ll just direct you there.

‍
‍

# Finally getting to something like a conclusion

‍

There’s a ton more we could talk about here: on-chain governance (whatever), upgradeability (please don’t), security (yes please), and more. As you can tell, I picked topics by largely subjective means. This article is by no means exhaustive, though I think it can give good direction to a developer on the outside looking in. As you get more and more proficient, you’ll be able to find your own directions with ease. One of the stellar aspects of the Ethereum community is how friendly so many people in it are. Take advantage, but pay it forward. Some day there’s going to be another dev trying to grok this weird blockchain stuff, and maybe you’ll be the one who gets their DM on Twitter or see their question on the Ethereum StackExchange. With awesome Ethereum comes the responsibility to keep Ethereum awesome, or something like that.

![](https://img.learnblockchain.cn/2020/12/07/16073039728049.jpg)





‍

## Haha, just kidding, I’m going to spam a list of resources here

‍
![](https://img.learnblockchain.cn/2020/12/07/16073039834158.jpg)




‍

I’m going to put a bunch of resources here, both ones mentioned above, and some tutorials.

‍

First, I should link to more comprehensive resources. I’m aiming to list enough resources to be comprehensive for a beginner’s needs, without it being so many as to be overwhelming. There are many more than I will explore here. ConsenSys keeps a list of resources [here](https://github.com/ConsenSys/ethereum-developer-tools-list/blob/master/README.md), which is linked to in [this](https://www.reddit.com/r/ethdev/comments/9jw839/long_list_of_ethereum_developer_tools_frameworks/) thread in /r/ethdev, meaning that the comments there have even more. I’ll also shout out [ethereum.org](https://ethereum.org) for having a really amazing dev portal that they are constantly working on improving.

‍

### Core Resources

* [Solidity docs](https://solidity.readthedocs.io/en/latest/)
* [Vyper docs](https://vyper.readthedocs.io/en/stable/)
* [Remix](https://vyper.readthedocs.io/en/stable/)
* [Contraktor](https://ethcontract.watch/)
* [Eth95](https://eth95.dev/)
* [OpenZeppelin](https://openzeppelin.com/) ([GitHub](https://github.com/OpenZeppelin/openzeppelin-contracts), [npm](https://www.npmjs.com/package/@openzeppelin/contracts))
* [Truffle](https://trufflesuite.com)
* [Hardhat](https://hardhat.org)
* [Web3.js](https://web3js.readthedocs.io/en/v1.3.0/)
* [Ethers](https://docs.ethers.io/v5/)
* [Scaffold-Eth](https://github.com/austintgriffith/scaffold-eth)
* [Nethermind](https://nethermind.io/client)
* [Infura](https://infura.io/)
* [Alchemy](https://infura.io/)

‍

### Tutorials

* [Eat the Blocks](https://www.youtube.com/channel/UCZM8XQjNOyG2ElPpEUtNasA)
* [Dapp University](https://www.youtube.com/channel/UCY0xL8V6NzzFcwzHCgB8orQ)
* There have been good Udemy courses in the past, don’t know if there’s anything current
* [Ethernaut](https://ethernaut.openzeppelin.com) - I recommend using Nicole Zhu’s [excellent walkthroughs](https://hackernoon.com/ethernaut-lvl-1-walkthrough-how-to-abuse-the-fallback-function-118057b68b56)[‍](https://cryptozombies.io)
* [Cryptozombies](https://cryptozombies.io)
* [vyper.fun](https://cryptozombies.io)

‍

### Resources

* [ethereum.org](https://vyper.fun)
* [StackExchange](https://ethereum.stackexchange.com/)
* [/r/ethereum](https://www.reddit.com/r/ethereum/)
* [/r/ethdev](https://www.reddit.com/r/ethdev/)
* Twitter - it’s really an amazing place to see what’s going on and connect with community members, and build up resistance to toxicity, you can get a good start using [hive.one](https://hive.one/ethereum/people)
* [Week In Ethereum](https://weekinethereumnews.com/)
* A gazillion podcasts, I’m not even going to try
* [EthGlobal](https://ethglobal.co/) has done a very good job with virtual hackathons over 2020, which are a great way of meeting and interacting with other Ethereum developers, especially if you’re learning on you own

‍

## Really concluding this time

‍
![5fbd1ab05d0fa2a2570a3d1b_conclusion](https://img.learnblockchain.cn/2020/12/07/5fbd1ab05d0fa2a2570a3d1b_conclusion.gif)




‍

Phew! That was a long list. (Nothing like the smell of CTRL+K and a hundred open tabs in the morning.) I hope this is a good overview, enough to get you started and on your way. You’ll find your own path soon enough!



