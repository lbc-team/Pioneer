## Sleuthing Toolbox - Everything you need to reverse engineer web3 hacks!

You’ve probably seen the twitter threads of web3 detectives & sleuths diving in when a hack just happened. No-one knows what happened, the protocol team is scrambling to figure things out, and these online detectives are dropping threads explaining exactly how the hack went down.


Pretty cool right? I thought so too!


I wanted to know how these people do it, so I looked at the different tools they use and in this post I’ll give you a rundown of the tools used by the best web3 Sleuths.

### Phalcon

https://phalcon.xyz/

main goal: what happened during this transaction?

supported chains: Ethereum, Binance Smart Chain, Polygon, Arbitrum, Cronos, Avalanche and Fantom

UX: ⭐️⭐️⭐️⭐

![img](https://img.learnblockchain.cn/attachments/2023/06/kFMdP1oi6487e06a8e8aa.png)

Phalcon is a transaction explorer like most of the tools you’ll see in this article. However, what sets Phalcon apart is the completeness of it’s feature set. It provides you with a wealth of information, displayed in an intuitive format, allowing you to dive deep & learn what’s happening in a transaction.



I’m particularly a fan of the ability to label, and colour different aspects in the Invocation flow. A feature which is incredibly useful when you’re reverse engineering the low level execution, and figuring out what’s happening.



Feature set:

- Transaction Info Summary
- Balance Changes Summary
- Fund Flow (as a diagram)
- Transaction Trace Exploring ( with debugging capability )
- Code View

https://blocksecteam.medium.com/getting-started-with-phalcon-2-0-253da584ca91

### https://docs.blocksec.com/phalcon/introduction

## MetaSleuth

https://metasleuth.io/

main goal: assist user in figuring out relation between addresses and accounts

supported chains: Ethereum, Binance Smart Chain, Polygon, Arbitrum, Cronos, Avalanche Moonbeam, Optimism and Fantom

UX: ⭐️⭐️⭐️⭐️

![img](https://img.learnblockchain.cn/attachments/2023/06/JRJKEIyy6487e06c019ae.png)

Metasleuth is a bit different from the other tools in this article. Its focus isn’t on understanding a specific hack, instead it helps you understand accounts and the flow of funds between accounts. This can be incredibly helpful when you’re trying to figure out what happened, during, before, and after an attack!



Similar to Phalcon, MetaSleuth doesn’t just provide visualization. You have various features in the Metasleuth interface that allow you to customize graph nodes, labels and node names. This can help a lot when you’re still trying to understand what happened and trying to get an organized overview!



I really like being able to pick one transaction / address to explore, and then iteratively exploring the associated addresses and transactions. This can be particularly helpful when there are multiple contracts, or multiple exploit transactions!



Feature set:

- Fund Flow (as a diagram) 
  - Suggested related addresses
  - Cross-chain analysis
  - etc.

https://metasleuth.io/

https://docs.blocksec.com/metasleuth/introduction

https://docs.blocksec.com/metasleuth/introductionhttps://blocksecteam.medium.com/metasleuth-how-to-use-metasleuth-to-analyze-a-phishing-attack-b525caac14c5

### Transaction tracer

https://openchain.xyz/trace

main goal: quick summary of what happened during the transaction

UX: ⭐⭐⭐ ( minimalistic 👍)

![img](https://img.learnblockchain.cn/attachments/2023/06/WnEey4N66487e06dac815.png)

Transaction Tracer is a no-nonsense tool that gives you a quick download of what happened during a transaction. You can quickly glance what happened during a transaction and explore a call trace.



It’s simplicity is both the strength and weakness of the platform, so I’ll personally will use it in addition to but not as a replacement of any other tool in this list.



Feature set:

- Transaction Info Summary
- Balance Changes Summary
- Transaction Trace Exploring

### ethtx

https://ethtx.info/

UX: ⭐⭐⭐

goal: turn transaction into human readable database of useful info

![img](https://img.learnblockchain.cn/attachments/2023/06/zNJSCu6K6487e06f034c8.png)

ethtx takes a different approach than all of the other tools in this post. Instead of trying to provide you with a distillation of information, this tool provides you with nicely formatted tabular DATA!

This tool is a perfect extension to some of the other tools you might already be using, there when you need it!


Feature Set:

- Transaction Info Summary
- Events Emissions
- Balance Change Summary
- Token Transfers
- Transaction Trace Exploring

### Tenderly

https://dashboard.tenderly.co/explorer

goal: understand the code being hacked

UX: ⭐⭐⭐⭐

![img](https://img.learnblockchain.cn/attachments/2023/06/J02my0IO6487e070e1b6e.png)

Tenderly is probably the most well-known tool on this list and has been around for a while. It has an extensive list of features and can be tremendously useful when analyzing a hack. Where I think Tenderly excels is its code navigation, debugging and simulation capabilities.



If I had to describe the difference between Tenderly and some of the other tools, I'd say that other tools can help you understand the hack, Tenderly helps you understand the code that's being hacked.



Feature Set:

- Transaction Info Summary

- Events

- State Changes

- Token Transfers

- Transaction Trace Exploring

- Debugging with extensively configurable re-simulation

- Code Explorer

  

### Others

Other tools you might like to check out:

- **eigenphi -** Nice step-through experience for flow of funds diagram.

- **cruise -** Similar to Transaction Tracer.

- **etherscan -** Not aimed at sleuthing, still damn usefull

- **[icevision.xyz](https://icevision.xyz/)** - Nice transaction flow exploration.

  

### Summary

In the future I’ll be using a combination of these tools, with a focus on three in particular:



1. **Phalcon** - To distill what happened during an attack transaction.

2. **MetaSleuth** - To explore the different contracts, accounts and flow of funds related to an attack.

3. **Tenderly** - To explore the execution trace of an attack transaction.

   

I’ve probably missed some tools, so feel free to comment with the ones you like!



原文链接：https://community.thecreed.xyz/c/warez/sleuthing-toolbox-everything-you-need-to-reverse-engineer-web3-hacks