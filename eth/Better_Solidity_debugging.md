# Better Solidity debugging: console.log is finally here

## A local Ethereum network designed for development: stack traces and console.log

![1_WGi-zdr3SVFdcV45k_0X7w](https://img.learnblockchain.cn/pics/20200817101938.png)



It’s happening. Building smart contracts on Ethereum is slowly distancing itself from being a task better suited for Elon Musk’s friends on Mars, and looking more and more like something maybe doable by human beings.

Back in October, [we launched Buidler EVM](https://medium.com/nomic-labs-blog/better-solidity-debugging-stack-traces-are-finally-here-dd80a56f92bb): a `ganache-cli` alternative that includes a fully featured Solidity-aware stack traces implementation. This was a big step towards a better developer experience, and now we’re releasing another highly anticipated Buidler EVM feature: `console.log` for Solidity.

![1_WP9NTQMV4dswT7bSI7WkcA](https://img.learnblockchain.cn/pics/20200817101956.png)



> Solidity debugging after Buidler EVM

Buidler EVM is a local Ethereum network designed for development. It allows you to deploy your contracts, run your tests and debug your code — and it was architectured as a platform to enable advanced tooling.

The main technique currently in use for logging data from Solidity is emitting events, but this approach is significantly limited: it only works on successful transactions. This is because the EVM doesn’t emit events when a transaction fails and given that when a transaction is going south is when developers need to understand what’s going on the most, this is tragic.

Buidler EVM carries a robust infrastructure for execution inspection that allowed us to implement a reliable `console.log` that’s always available, **even when a transaction fails** — and in true Buidler-fashion, it works with the testing tools of your choosing.

Using it is straightforward. Just import the `console.sol` file that contains the `console.log` function, and use it as you would in JavaScript.

![1_fpoWhfReJS_StkpzI5HojA](https://img.learnblockchain.cn/pics/20200817102046.png)

>  contract/Greeter.sol in Buidler’s sample project

Then run your tests using Buidler and Buidler EVM as the development network.



![1_WRz_O76rpVRTadX34f4_cQ](https://img.learnblockchain.cn/pics/20200817102119.png)



The contracts will compile with any tool, not just Buidler, so it’s safe to leave the logging calls in if that’s useful. Tools like [Tenderly](https://tenderly.dev/) will integrate the scrapping of logs, so you can even deploy the logging code to testnets and mainnet if you wish. The calls into `console.log` don’t do anything when running in other networks, but they do incur a gas cost.

This latest release of Buidler EVM also adds support for Solidity 6 and the `evm_snapshot` and `evm_revert` JSON-RPC methods, allowing projects using snapshots to migrate to Buidler and keep their testing optimizations.

In combination with the stack traces feature, this release marks a new chapter in smart contract development productivity 🥳.

Take Buidler EVM’s `console.log` out for a spin!

```
mkdir console/
cd console/
npm init -y
npm install --save-dev @nomiclabs/buidler
npx buidler # and create a sample project
npx buidler test
```

[Check Buidler out](https://buidler.dev/) and forget your Solidity debugging frustrations today! 👷‍♀️👷‍♂️

------

- Follow Nomic Labs on [Twitter](https://twitter.com/nomiclabs) and [Medium](http://medium.com/nomic-labs-blog).
- For any help or feedback you may have, you can find us in the [Buidler Support Telegram group](http://t.me/BuidlerSupport).





原文：https://medium.com/nomic-labs-blog/better-solidity-debugging-console-log-is-finally-here-fc66c54f2c4a 作者：[Patricio Palladino](https://medium.com/@alcuadrado?source=post_page-----fc66c54f2c4a----------------------)

