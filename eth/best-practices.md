
# Best Practices for Smart Contract Development

![](https://img.learnblockchain.cn/2020/09/15/16001337715241.jpg)

The history of software development spans decades. We benefit from the best practices, design patterns, and nuggets of wisdom that has accumulated over half a century.

In contrast, smart contract development is just getting started. Ethereum and Solidity launched in 2015, only a handful of years ago.

The crypto space is an ever-growing uncharted territory. There’s **no definitive stack of tools** to build decentralized apps. There are **no developer handbooks** like [Design Patterns](https://en.wikipedia.org/wiki/Design_Patterns) or [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) for smart contracts. Information about tools and best practices are scattered all over the place.

You’re reading **the missing guide I wish existed**. It summarizes the lessons I’ve learned from writing smart contracts, building decentralized applications, and open source projects in the Ethereum ecosystem.


> 💡 This handbook is a living document. If you have any feedback or suggestions, feel free to comment or [email me directly](mailto:hello@yos.io).

# Who this is for[](#who-this-is-for)

This handbook is for:

* Developers who are just starting out with smart contracts, and
* Experienced Solidity developers who wish to bring their work to the next level.

If you’re a developer new to crypto, please let me know if you find this guide helpful.

This is NOT meant to be an introduction to the [Solidity](https://learnblockchain.cn/docs/solidity/) language.

# TL;DR[](#tldr)

* [Use a development environment](#use-a-development-environment)
* [Develop locally](#develop-locally)
* [Use static analysis tools](#use-static-analysis-tools)
* [Understand security vulnerabilities](#understand-security-vulnerabilities)
* [Write unit tests, no exceptions](#write-unit-tests)
* [Security audit your contracts](#security-audit-your-contracts)
* [Use audited, open source contracts](#use-audited-open-source-contracts)
* [Launch on a public testnet](#launch-on-a-public-testnet)
* [Consider formal verification](#consider-formal-verification)
* [Store keys in a secure manner](#store-keys-in-a-secure-manner)
* [Make it open source](#make-it-open-source)
* [Build CLI tools and runbooks](#build-cli-tools-and-runbooks)
* [Prioritize developer experience](#prioritize-developer-experience)
* [Provide contract SDKs](#provide-contract-sdks)
* [Write good documentation](#write-good-documentation)
* [Set up event monitoring](#set-up-event-monitoring)
* [On building DApp backends](#on-building-dapp-backends)
* [On building DApp frontends](#on-building-dapp-frontends)
* [Strive for usability](#strive-for-usability)
* [Build with other protocols in mind](#build-with-other-protocols-in-mind)
* [Understand systemic risks](#understand-systemic-risks)
* [Participate in dev communities](#participate-in-dev-communities)
* [Subscribe to newsletters](#subscribe-to-newsletters)

# Use a Development Environment[](#use-a-development-environment)

Use a development environment such as [Truffle](https://learnblockchain.cn/docs/truffle/) (alternatively, [Embark](https://learnblockchain.cn/article/566), [Buidler](https://buidler.dev/) [dapp.tools](http://dapp.tools/)) to get productive, fast.

![](https://img.learnblockchain.cn/2020/09/15/16001341569297.jpg)

Using a development environment speeds up recurring tasks such as:

* Compiling contracts
* Deploying contracts
* Debugging contracts
* Upgrading contracts
* Running unit tests

![](https://img.learnblockchain.cn/2020/09/15/16001343301985.jpg)


For example, Truffle provides the following useful commands out-of-the-box:

* **compile:** Compiles a Solidity contract to its ABI and bytecode formats.
* **console:** Instantiates an interactive JS console where you can call and interact with your web3 contracts.
* **test:** Runs your contracts’ unit test suite.
* **migrate:** Deploys your contracts to a network.

Truffle supports plugins that offer additional features. For example, [`truffle-security`](https://github.com/ConsenSys/truffle-security) provides smart contract security verification. [`truffle-plugin-verify`](https://learnblockchain.cn/article/1314) publishes your contracts on blockchain explorers. You can also create [custom plugins](https://www.trufflesuite.com/docs/truffle/getting-started/writing-external-scripts#creating-a-custom-command-plugin).

Likewise, [Buidler](https://learnblockchain.cn/article/1371) supports a growing list of plugins for Ethereum smart contract developers.

Whichever development environment you use, picking a good set of tools is a must.

# Develop Locally[](#develop-locally)

Run a local blockchain for development with [Ganache](https://www.trufflesuite.com/ganache) (or [Ganache CLI](https://github.com/trufflesuite/ganache-cli)) to **speed up your iteration cycle**.

![](https://img.learnblockchain.cn/2020/09/15/16001346187508.jpg)

On the mainnet, Ethereum transactions [cost money](https://www.investopedia.com/terms/g/gas-ethereum.asp) and can take [minutes](https://ethgasstation.info/) to be confirmed. Skip all this waiting by using a local chain. Run your contracts locally to get free and instant transactions.

![](https://img.learnblockchain.cn/2020/09/15/16001346606172.jpg)

Ganache comes with a built-in block explorer that shows your decoded transactions, contracts, and events. This local environment is [configurable](https://www.trufflesuite.com/docs/ganache/reference/ganache-settings) to suit your testing needs.

Setting up is easy and quick. [Download here](https://www.trufflesuite.com/ganache).

# Use Static Analysis Tools[](#use-static-analysis-tools)

Static analysis or ‘linting’ is the process of running a program that analyzes code for programming errors. In smart contract development, this is useful for catching **style inconsistencies** and **vulnerable code** that the compiler may have missed.

## 1\. Linters[](#1-linters)

![](https://img.learnblockchain.cn/2020/09/15/16001347755489.jpg)

Lint Solidity code with [solhint](https://github.com/protofire/solhint) and [Ethlint](https://github.com/duaraghav8/Ethlint). Solidity linters are similar to linters for other languages (e.g. JSLint.) They provide both Security and Style Guide validations.

## 2\. Security Analysis[](#2-security-analysis)

![](https://img.learnblockchain.cn/2020/09/15/16001352402449.jpg)

Security analysis tools identify [smart contract vulnerabilities](https://yos.io/2018/10/20/smart-contract-vulnerabilities-and-how-to-mitigate-them/). These tools run a suite of vulnerability detectors and prints out a summary of any issues found. Developers can use this information to find and address vulnerabilities throughout the implementation phase.

Options include: [Mythril](https://github.com/ConsenSys/mythril) · [Slither](https://github.com/crytic/slither) · [Manticore](https://github.com/trailofbits/manticore) · [MythX](https://mythx.io/) · [Echidna](https://github.com/crytic/echidna) · [Oyente](https://github.com/melonproject/oyente)

## Extra: Use Pre-Commit Hooks[](#extra-use-pre-commit-hooks)

Make your developer experience seamless by setting up [Git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) with [`husky`](https://github.com/typicode/husky). Pre-commit hooks let you run your linters before every commit. For example:



```
// package.json
{
  "scripts": {
    "lint": "./node_modules/.bin/solhint -f table contracts/**/*.sol",
  },
  "husky": {
    "hooks": {
      "pre-commit": "npm run lint"
    }
  },
}
```


The above snippet runs a predefined `lint` task before every commit, failing if there are outstanding style or security violations in your code. This setup enables developers in your team to work with the linter in an iterative approach.

# Understand Security Vulnerabilities[](#understand-security-vulnerabilities)

Write software without bugs is notoriously difficult. Defensive programming techniques can only go so far. Fortunately, you can fix bugs by deploying new code. Patches in traditional software development are frequent and straightforward.

![](https://img.learnblockchain.cn/2020/09/15/16001353110014.jpg)


However, smart contracts are **immutable**. It’s sometimes impossible to [upgrade](https://yos.io/2018/10/28/upgrading-solidity-smart-contracts/) contracts that are already live. In this aspect, smart contracts are closer to virtual hardware development than software development.

Worse, smart contract bugs can lead to extreme financial losses. The [DAO Hack](https://medium.com/swlh/the-story-of-the-dao-its-history-and-consequences-71e6a8a551ee) lost more than 11.5 million Ether (US$70M at the time of the hack, now over $2B) and the 2nd [Parity Hack](https://hackernoon.com/parity-wallet-hack-2-electric-boogaloo-e493f2365303) lost US$200M of user funds. Today, with a market size of [nearly $1B](https://defipulse.com/), the DeFi space has a lot to lose - should things go wrong.

Smart contract development demands a completely different mentality than web development. ‘Move fast and break things’ does not apply here. You need to invest lots of resources upfront to write bug-free software. As a developer, you must:

1. Be familiar with Solidity [security](https://yos.io/2019/11/10/smart-contract-development-best-practices/) [vulnerabilities](https://yos.io/2018/10/20/smart-contract-vulnerabilities-and-how-to-mitigate-them/), and

2. Understand Solidity [design](https://consensys.github.io/smart-contract-best-practices/recommendations/) [patterns](https://github.com/fravoll/solidity-patterns) such as pull vs push payments and Checks-Effects-Interactions, amongst others.

3. Use defensive programming techniques: static analysis and unit tests.

4. Audit your code.

The following sections will explain points (3) and (4) in detail.

> 💡 **Tip for Beginners:** You can practice your Solidity security chops in an interactive way with [Ethernauts](https://ethernaut.openzeppelin.com/).

# Write Unit Tests[](#write-unit-tests)

Uncover bugs and unexpected behaviour early with **a comprehensive test suite**. Testing different scenarios through your protocol helps you identify edge cases.

Truffle uses the [Mocha](https://mochajs.org/) testing framework and [Chai](https://www.chaijs.com/) for assertions. You write unit tests in Javascript against [contract wrappers](#provide-contract-wrappers) like how frontend ÐApps will call your contracts.

![](https://img.learnblockchain.cn/2020/09/15/16001353660527.jpg)


From Truffle `v5.1.0` onwards, you can interrupt tests to [debug](https://www.trufflesuite.com/docs/truffle/getting-started/debugging-your-contracts#in-test-debugging) the test flow and start the debugger, allowing you to set breakpoints, inspect Solidity variables, etc.

![](https://img.learnblockchain.cn/2020/09/15/16001353786145.jpg)


Truffle is missing several features which are essential for testing smart contracts. Installing [openzeppelin-test-helpers](https://github.com/OpenZeppelin/openzeppelin-test-helpers) gives you access many important utilities for validating contract state, such as **matching contract events** and **moving forward in time**.

> Alternatively, [OpenZeppelin Test Environment](https://github.com/OpenZeppelin/openzeppelin-test-environment) offers a tooling-agnostic option if you prefer using other test runners.

## Measure Test Coverage[](#measure-test-coverage)

Writing tests is not enough; Your test suite must reliably catch regressions. **[Test Coverage](https://en.wikipedia.org/wiki/Code_coverage)** measures the effectiveness of your tests.


![](https://img.learnblockchain.cn/2020/09/15/16001354069788.jpg)


A program with high test coverage has more of its code executed during testing. This means it has a lower chance of having undetected bugs compared to code with low coverage. Untested code could do anything!

You can collect Solidity code coverage with [`solidity-coverage`](https://github.com/sc-forks/solidity-coverage).

## Set up Continuous Integration[](#set-up-continuous-integration)

Once you have a test suite, run it **as frequently as possible**. There are a few ways to accomplish this:

1. Set up [Git hooks](#use-pre-commit-Hooks) as we did earlier for linting, or
2. Set up a CI pipeline that executes your tests after every Git push.

If you’re looking for an out-of-the-box CI check out [Truffle Teams](https://www.trufflesuite.com/teams) or [Superblocks](https://superblocks.com/). They provide hosted environments for continuous smart contract testing.

![](https://img.learnblockchain.cn/2020/09/15/16001354347819.jpg)


Hosted CIs run your unit tests regularly for maximum confidence. You can also monitor your deployed contracts’ transactions, state, and events.

# Security Audit Your Contracts[](#security-audit-your-contracts)

Security audits help you **uncover unknowns** in your system that defensive programming techniques (linting, unit tests, design patterns) miss.

![](https://img.learnblockchain.cn/2020/09/15/16001354443476.jpg)


In this exploratory phase, you try your best to break your contracts - supplying unexpected inputs, calling functions as different roles, etc.

Nothing can replace manual security audits, especially when the surface area of a hack can be [the entire DeFi ecosystem](https://medium.com/@peckshield/bzx-hack-full-disclosure-with-detailed-profit-analysis-e6b1fa9b18fc).

> ⚠️ Before proceeding to the next phase, your code should already pass the [security tools](#use-static-analysis-tools) mentioned in an earlier section.

## Bring in External Auditors[](#bring-in-external-auditors)

Major protocols in the Ethereum space hire (expensive) security auditors who dive deep into their codebase to find potential security holes. These auditors use a combination of proprietary and open-source static analysis tools such as:

* [Manticore](https://github.com/trailofbits/manticore/releases/tag/0.1.6), a symbolic emulator capable of simulating complex multi-contract and multi-transaction attacks against EVM bytecode.
* [Ethersplay](https://github.com/crytic/ethersplay), a graphical EVM disassembler capable of method recovery, dynamic jump computation, source code matching, and binary diffing.
* [Slither](https://github.com/crytic/slither), a static analyzer that detects common mistakes such as bugs in reentrancy, constructors, method access, and more.
* [Echidna](https://github.com/crytic/echidna), a next-generation smart fuzzer that targets EVM bytecode.

Auditors will help **identify any design and architecture-level risks** and educate your team on common smart contract vulnerabilities.

![](https://img.learnblockchain.cn/2020/09/15/16001354660778.jpg)


At the end of the process, you get a report that summarizes the auditors’ findings and recommended mitigations. You can read audit reports by [ChainSecurity](https://github.com/ChainSecurity/audits), [OpenZeppelin](https://blog.openzeppelin.com/security-audits/), [Consensys Diligence](https://diligence.consensys.net/audits/), and [TrailOfBits](https://github.com/trailofbits/publications/tree/master/reviews) to learn what kind of issues are found during a security audit.

# Use Audited, Open Source Contracts[](#use-audited-open-source-contracts)

Secure your code from Day 1 by using **battle-tested open-source code** that has already passed security audits. Using audited code **reduces the surface area you need to audit** later on.

![](https://img.learnblockchain.cn/2020/09/15/16001354825935.jpg)

[OpenZeppelin Contracts](https://github.com/openzeppelin/openzeppelin-contracts) is a framework of modular, reusable smart contracts written in Solidity. It includes implementations of popular ERC standards such as ERC20 and ERC721 tokens. It comes with the following out of the box:

* Access Control: Who’s allowed to do what.
* [ERC20](https://docs.openzeppelin.com/contracts/3.x/tokens#ERC20) & [ER721](https://docs.openzeppelin.com/contracts/3.x/tokens#ERC721) Tokens: Open source implementations of popular token standards, along with [optional modules](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token).
* [Gas Stations Network](https://docs.openzeppelin.com/contracts/3.x/gsn): Abstracts away gas from your users.
* Utilities: `SafeMath`, `ECDSA`, `Escrow`, and other utility contracts.

You can deploy these contracts as-is or extend it to suit your needs as part of a larger system.

> 💡 **Tip for Beginners:** Open source Solidity projects such as OpenZeppelin Contracts are excellent learning materials for new developers. They provide a readable introduction to what’s possible with smart contracts. Don’t hesitate to check it out! [Start here](https://docs.openzeppelin.com/contracts/3.x/).

# Launch on a Public Testnet[](#launch-on-a-public-testnet)

Before you launch your protocol on the Ethereum mainnet, consider **launching on a [testnet](https://medium.com/compound-finance/the-beginners-guide-to-using-an-ethereum-test-network-95bbbc85fc1d)**. Think of it as deploying to staging before production. [Rinkeby](https://www.rinkeby.io/#stats) and [Kovan](https://kovan-testnet.github.io/website/) testnets have faster block times than mainnet and test Ether can be [requested](https://faucet.rinkeby.io/) for free.

![](https://img.learnblockchain.cn/2020/09/15/16001355114662.jpg)


During the testnet phase, organize a **bug bounty** program. Your users and the larger Ethereum security community can help identify any remaining critical flaws in the protocol (in return for a monetary reward.)

# Consider Formal Verification[](#consider-formal-verification)

[Formal verification](https://en.wikipedia.org/wiki/Formal_verification) is the act of proving or disproving the correctness of an algorithm against a formal specification, using formal methods of mathematics. The verification is done by providing a formal proof on a mathematical model of the system, such as finite state machines and labelled transitions.

![](https://img.learnblockchain.cn/2020/09/15/16001355225672.jpg)


The reason why formal verification hasn’t caught on is because of **a reputation of requiring a huge amount of effort** to verify a tiny piece of relatively straightforward code. The return on investment is only justified in safety-critical domains such as medical systems and avionics. If you’re not writing code for medical devices or rockets, you tolerate bugs and fix iteratively.

However, teams at Amazon Web Services (AWS) have used formal verification with Leslie Lamport’s [TLA+](https://learntla.com/introduction/example/) to [verify the correctness of S3 and DynamoDB](https://blog.acolyer.org/2014/11/24/use-of-formal-methods-at-amazon-web-services/):

> “In every case TLA+ has added significant value, either finding subtle bugs that we are sure we would not have found by other means, or giving us enough understanding and confidence to make aggressive performance optimizations without sacrificing correctness.”

Smart contract development requires a complete shift in mindset. You need huge amounts of rigor and intensity to make software that cannot be hacked and will perform as expected. Given the constraints of smart contracts, the decision to go for formal verification may be justified. After all, you only have one chance to get it right.

![](https://img.learnblockchain.cn/2020/09/15/16001355329539.jpg)


Within the Ethereum ecosystem, available model checkers include:

* [VerX](https://medium.com/chainsecurity/verx-full-functional-verification-for-ethereum-contracts-now-at-your-fingertips-f8d20085e4ec) is an automated verifier for custom function requirements of Ethereum contracts. VerX takes as inputs Solidity code and functional requirements written in VerX’s specification language, and either verifies that the property holds or outputs a sequence of transactions that may result in violating the property.

* [cadCAD](https://cadcad.org/) is a Python package that assists in the processes of designing, testing and validating complex systems through simulation, with support for Monte Carlo methods, A/B testing and parameter sweeping. It’s been used to simulate cryptoeconomic models in the [Clovers](https://www.youtube.com/watch?v=5Eg360OC6Qg) project.

* [KLab](https://github.com/dapphub/klab) is a tool for generating and debugging proofs in the K Framework, tailored for the formal verification of ethereum smart contracts. It includes a succinct specification language for expressing the behavior of ethereum contracts, and an interactive debugger.

For reference, you can see example results of formal verification [here](https://github.com/runtimeverification/verified-smart-contracts).

# Store Keys in a Secure Manner[](#store-keys-in-a-secure-manner)

Store private keys of Ethereum accounts in a [secure manner](https://silentcicero.gitbooks.io/pro-tips-for-ethereum-wallet-management/). Here are a few suggestions:

* [Generate entropy](https://iancoleman.io/bip39/) safely.
* Do NOT post or send your seed phrase anywhere. If it’s a must, use an encrypted communication channel such as [Keybase Chat](https://keybase.io/).
* Do use hardware wallets such as a [Ledger](https://www.ledger.com/).
* Do use a multi-signature wallet ([Gnosis Safe](https://gnosis-safe.io/)) for particularly sensitive accounts.

![](https://img.learnblockchain.cn/2020/09/15/16001355452470.jpg)


> 💡 With the rise of [smart contract wallets](https://medium.com/argenthq/recap-on-why-smart-contract-wallets-are-the-future-7d6725a38532), seed phrases may become less prevalent over time.

# Make It Open Source[](#make-it-open-source)

Smart contracts enable permissionless innovation that lets anyone build and innovate on them. That is what blockchains are really useful for: public, programmable and verifiable computation.

If you’re building a DeFi protocol, you want to attract third-party developers. To attract developers you need to show that you won’t [change the rules of the game later on](https://news.ycombinator.com/item?id=19854381). Open sourcing your code inspires confidence.

![](https://img.learnblockchain.cn/2020/09/15/16001355596142.jpg)


[Making](https://github.com/compound-finance/compound-protocol) [your](https://github.com/bZxNetwork/bZx-monorepo) [code](https://github.com/0xProject/0x-monorepo) [public](https://github.com/AugurProject/augur) also allows anyone to fork your code should things go awry.

> 💡 Remember to [verify your contracts on Etherscan](https://yos.io/2019/08/10/verify-smart-contracts-on-etherscan/).

# Prioritize Developer Experience[](#prioritize-developer-experience)

For the longest time, integrating payments was really hard. Early payments companies lacked modern code bases, and things like APIs, client libraries and documentation were virtually non-existent. [Stripe](https://growthhackers.com/growth-studies/how-stripe-marketed-to-developers-so-effectively) made it easy for developers to add payments to their software. They are now incredibly successful.

The developer experience (DevEx) of your protocol is paramount. Make it easy for other developers to build on your protocol with [developer-friendly APIs](https://yos.io/2018/02/14/api-developer-portal-best-practices/). Here are two suggestions to start:

* [Provide contract SDKs and sample code](#provide-contract-sdks)
* [Write good documentation](#write-good-documentation)

The user experience of your developer portal, the completeness of the API documentation, the ease with which people can search for the right solution for their use case, and the speed at which developers can start calling your contracts are all critical for adoption to happen.

> 💡 The [0x](https://0x.org/) protocol is probably the gold standard when it comes to developer experience. Their high adoption rate is testament to the protocol’s value and smooth onboarding.

Community engagement also plays an important part. How do developers find you? Where do you connect with developers? What makes your project attractive to build on? Building an active community around your project will help drive adoption in the long term. The crypto developer community is active on various Twitter, Telegram, and Discord channels.

## Provide Contract SDKs[](#provide-contract-sdks)

Writing and maintaining robust, client libraries for many programming languages is non-trivial. Having SDKs available helps developers build on your protocol.

![](https://img.learnblockchain.cn/2020/09/15/16001355719566.jpg)


Contract wrappers built with [typechain](https://github.com/ethereum-ts/TypeChain), [truffle-contract](https://www.npmjs.com/package/truffle-contract), [ethers](https://docs.ethers.io/v5/api/contract/), or [web3.js](https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html)) makes calling contracts as simple as calling Javascript functions. Distribute your SDK as NPM packages that developers can install.



```
var provider = new Web3.providers.HttpProvider("http://localhost:8545");
var contract = require("truffle-contract");

var MyContract = contract({
  abi: ...,
  unlinked_binary: ...,
  address: ..., // optional
  // many more
})
MyContract.setProvider(provider);

const c = await MyContract.deployed();
const result = await c.someFunction(5); // Calls a smart contract
```



> 💡 Having a client SDK greatly reduces the effort required for developers to get started, especially for those new to to a specific programming language.
> 
> Some projects go one step further and provide fully-functional codebases that you can run and deploy. For example, the [0x Launch Kit](https://0x.org/launch-kit) provides decentralized exchanges that works out-of-the-box.

## Write Good Documentation[](#write-good-documentation)

Building on open source software reduces development time, but comes with a tradeoff: learning how to use it takes time. Good documentation reduces the time developers spend learning.

![](https://img.learnblockchain.cn/2020/09/15/16001356010442.jpg)


There are many types of [documentation](https://www.divio.com/blog/documentation/):

* **High-level explainers** describe in plain-English what your protocol does. Explain in clear terms what the capabilities of your protocol. This section enables decision makers to evaluate whether or not your product serves their use cases.
* **Tutorials** go into more details: step-by-step instructions and explanations of what the various components are and how to manipulate them to achieve a certain goal. Tutorials should strive to be clear, concise and evenly spaced across steps. Use plenty of code examples to encourage copy/pasting.
* **API Reference** document the technical details of your smart contracts, functions, and parameters.

Tools like [`leafleth`](https://github.com/clemlak/leafleth) allows you to generate automated documentation using [NatSpec](https://solidity.readthedocs.io/en/develop/natspec-format.html) comments and produce a website to publish the documentation.

> 💡To document an HTTP API, check out [`redoc`](https://github.com/Redocly/redoc) or [`slate`](https://github.com/slatedocs/slate). You can check out other helpful resources for building HTTP APIs [here](https://github.com/yosriady/api-development-tools).

# Build CLI Tools and Runbooks[](#build-cli-tools-and-runbooks)

Runbooks are codified procedures to achieve a specific outcome. Runbooks should contain the minimum information necessary to successfully perform the procedure.

Build internal CLI tools and [runbooks](https://wa.aws.amazon.com/wat.concept.runbook.en.html) to improve operations. With smart contracts, this is usually a [script](https://www.trufflesuite.com/docs/truffle/getting-started/writing-external-scripts) containing one or more contract calls that performs a business operation.

Should things go wrong, runbooks provide developers who are unfamiliar with procedures or the workload, the instructions necessary to successfully complete an activity such as a recovery action. The process of writing runbooks also prepares you to handle potential failure modes. Perform internal exercises to identify potential sources of failure so that they can be removed or mitigated.

> 💡 To get started, pick an effective manual process, implement it in code, and trigger automated execution where appropriate.

# Set up Event Monitoring[](#set-up-event-monitoring)

Efficient and effective management of contract events is necessary for [operational excellence](https://wa.aws.amazon.com/wat.pillar.operationalExcellence.en.html). An event monitoring system for your smart contracts keeps you notified of real-time changes in the system. If you’re building a DeFi protocol, price slippage alerts are particularly useful to prevent hacks.

![](https://img.learnblockchain.cn/2020/09/15/16001356150127.jpg)


You can roll out your own monitoring backend with [`web3.js`](https://learnblockchain.cn/docs/web3.js/) or use a dedicated service such as [Dagger](https://matic.network/dagger/), [Blocknative Notify](https://www.blocknative.com/notify), [Tenderly](https://tenderly.co/), or [Alchemy Notify](https://notify.alchemyapi.io/).

# On Building DApp Backends[](#on-building-dapp-backends)

DApps need a way to read and transform data from smart contracts. However, on-chain data aren’t always stored in an easy-to-read format. Reading contract data directly from an Ethereum node is sometimes too slow for user-facing web and mobile apps. Instead, you need to index the data into a more accessible format.

![](https://img.learnblockchain.cn/2020/09/15/16001356573712.jpg)


[theGraph](https://thegraph.com/explorer/) offers a hosted GraphQL indexing service for your smart contracts. Queries are processed on a decentralized network that ensures that data remains open and that DApps continue to run no matter what.

Alternatively, you can build your own indexing service. This service would communicate with an Ethereum node and subscribe to relevant contract events, perform transformations, and save the result in a read-optimized format. There are [open source implementations](https://github.com/AugurProject/augur-node) you can use as reference if you decide to roll your own. Either way, this service needs to be hosted somewhere.

> 💡 The lack of regulatory clarity in jurisdictions across the world means that at the flip of a hat, [control can become liability](https://vitalik.ca/general/2019/05/09/control_as_liability.html). To address this, making parts of your system [decentralized](https://onezero.medium.com/why-decentralization-matters-5e3f79f7638e) and non-custodial can help reduce that liability.

# On Building DApp Frontends[](#on-building-dapp-frontends)

A frontend application allows users to interact with smart contracts. Examples include the [Augur](https://www.augur.net/ipfs-redirect.html) and [Compound](https://app.compound.finance/) apps. DApp frontends are usually hosted in a centralized server, but can also be hosted on the decentralized [IPFS](https://ipfs.io/) network to further introduce decentralization and reduce liability.

![](https://img.learnblockchain.cn/2020/09/15/16001356707275.jpg)

Frontend dApps load smart contract data from an Ethereum node through client libraries such as [`web3.js`](https://learnblockchain.cn/docs/web3.js/) and [`ethers.js`](https://learnblockchain.cn/docs/ethers.js/). 

Libraries such as [Drizzle](https://www.trufflesuite.com/drizzle), [web3-react](https://github.com/NoahZinsmeister/web3-react), and [subspace](https://github.com/embarklabs/subspace) offer higher-level features that simplify connecting to web3 providers and reading contract data.

There are several DApp boilerplates available, such as [create-eth-app](https://github.com/PaulRBerg/create-eth-app/), [scaffold-eth](https://github.com/austintgriffith/scaffold-eth), [OpenZeppelin Starter Kit](https://docs.openzeppelin.com/starter-kits/tutorial), and [Truffle’s Drizzle box](https://github.com/truffle-box/drizzle-box). They come with everything you need to start using smart contracts from a React app.

> 💡 Instead of reading contract data from Ethereum nodes, frontends can also call a backend which indexes smart contract events into a read-optimized format. See [the Building DApp Backends section](#on-building-dapp-backends) for more detail.

# Strive for Usability[](#strive-for-usability)

Crypto has a usability problem. **Gas fees** and **seed phrases** are intimidating for new users. Fortunately, the crypto user experience is improving at a rapid pace.

![](https://img.learnblockchain.cn/2020/09/15/16001358555774.jpg)


[Meta Transactions](https://medium.com/@andreafspeziale/understanding-ethereum-meta-transaction-d0d632da4eb2) and the [Gas Stations Network](https://www.opengsn.org/) offers a solution to the gas fee problem. Meta transactions allow services to pay gas fees on behalf of users, removing the need for users to hold Ether. Meta transactions also lets users pay fees in other tokens instead of ETH. These improvements are made possible through clever use of [cryptographic signatures](https://yos.io/2018/11/16/ethereum-signatures/). With GSN, these meta transactions are distributed across a network of relayers who pays the gas.

![](https://img.learnblockchain.cn/2020/09/15/16001358656705.jpg)


Hosted wallets and smart contract wallets remove the need for browser extensions and seed phrases. Projects under this category include [Fortmatic](https://fortmatic.com/), [Portis](https://www.portis.io/), [Bitski](https://www.bitski.com/), [SquareLink](https://squarelink.com/), [Universal Login](https://unilogin.io/), [Torus](https://tor.us/), [Argent](https://www.argent.xyz/), and [walletconnect](https://walletconnect.org/).

> 💡 Consider using the [web3modal](https://github.com/Web3Modal/web3modal) library to add support for major wallets.

# Build with Other Protocols in Mind[](#build-with-other-protocols-in-mind)

Ethereum has created a [digital finance stack](https://medium.com/pov-crypto/ethereum-the-digital-finance-stack-4ba988c6c14b). Financial protocols are building on top of each other, powered by the permissionless and composable nature of smart contracts. These protocols include:

* **MakerDAO:** Digitally-native stablecoin, Dai.
* **Compound:** Digitally-native autonomous token lending and borrowing.
* **Uniswap:** Digitally-native autonomous token exchange.
* **Augur:** Digitally-native prediction market.
* **dYdX:** Algorithmically-managed derivative market.
* **UMA:** Synthetic token platform.
* And many more…

Each protocol provides the foundation for other protocols to build more sophisticated products.

![](https://img.learnblockchain.cn/2020/09/15/16001358868617.jpg)


If Ethereum is the **Internet of Money**, Decentralized Finance protocols are **Money Legos**. Each financial building block opens the door to new things that can be built on Ethereum. As the number of Money Legos grows, so too does the number of novel financial products. We’ve only begun scratching the surface of what’s possible.

> 💡 You can experience the lightspeed pace of innovation in the DeFi space by just looking at [the varieties of DAI](https://medium.com/bzxnetwork/a-tour-of-the-varieties-of-dai-9ff155f7666c).

Don’t reinvent the wheel in isolation. **Build with other protocols in mind**. Instead of forking a clone of an existing protocol, can you build something *for* or *with* the pieces that already exist? Compared to building on centralized platforms, access to smart contracts cannot be taken away from under you.

This philosophy extends to centralized services. There’s a growing ecosystem of building blocks available to you:

* [Infura](https://infura.io/), [Azure Blockchain](https://azure.microsoft.com/es-es/blog/ethereum-blockchain-as-a-service-now-on-azure/), [QuikNode](https://www.quiknode.io/), [Nodesmith](https://nodesmith.io/): Hosted Ethereum nodes save you the headache of running your own.
* [3box](https://docs.3box.io/): Decentralized storage and social API for comments and user profiles.
* [zksync](https://zksync.io/): Protocol for scaling payments and smart contracts on Ethereum.
* [Matic](https://matic.network/): Faster and extremely low-cost transactions.

There’s an ever growing set of building blocks for you to ship better DApps, faster.

# Understand Systemic Risks[](#understand-systemic-risks)

![](https://img.learnblockchain.cn/2020/09/15/16001359040167.jpg)

When you’re building on DeFi, you must assess whether a protocol / currency adds more value than risk.

## 1\. Smart Contract Risk[](#1-smart-contract-risk)

Smart contracts can have bugs. Always consider the possibility that a bug is found in the protocols you depend on.

The [DeFi Score](https://defiscore.io/) offers a way to quantify smart contract risk. This metric depends on whether the associated smart contracts have been audited, how long the protocol has been in use, the amount of funds that has been managed by the protocol so far, etc.

Smart contract risk **compounds as more protocols are composed together**, similar to [how SLA scores are calculated](https://devops.stackexchange.com/questions/711/how-do-you-calculate-the-compound-service-level-agreement-sla-for-cloud-servic). Because of the permissionless composability of smart contracts, a single flaw cascades into all dependent systems.

## 2\. Counterparty Risk[](#2-counterparty-risk)

How is a protocol governed? Some governance models may give direct control over funds or attack vectors to the governance architecture which could expose control and funds.

You can gauge counterparty risk by the number of parties that control the protocol as well as the number of holders.

Different protocols have different degrees of decentralization and control. Be wary of protocols with a small community and limited track record.

## 3\. Mitigating Risk[](#3-mitigating-risk)

Mitigate your overall risk exposure by following these basic principles:

* Interact only with audited smart contracts.
* Interact only with liquid currencies that has a significant community and product.
* Purchase [smart contract insurance](https://nexusmutual.io/).

# Participate in dev communities[](#participate-in-dev-communities)

Smart contract development is evolving rapidly, with new tools and standards launching from talented teams all over the world.

![](https://img.learnblockchain.cn/2020/09/15/16001359297942.jpg)


Keep up with the latest developments in the space by visiting online Ethereum communities: [ETH Research](https://ethresear.ch/), [Ethereum Magicians](https://ethereum-magicians.org/), [r/ethdev](https://www.reddit.com/r/ethdev/), [OpenZeppelin Forum](https://forum.openzeppelin.com/), and the [EIPs Github repo](https://github.com/ethereum/EIPs).

# Subscribe to newsletters[](#subscribe-to-newsletters)

Newsletters are a great way to stay up-to-date with the Ethereum ecosystem. I recommend subscribing to [Week in Ethereum](https://weekinethereumnews.com/) and [EthHub Weekly](https://ethhub.substack.com/).

# In Closing[](#in-closing)

This handbook is a living document. As the Ethereum developer ecosystem grows and evolves, new tools will emerge and old techniques may become obsolete.

If you have any feedback or suggestions, feel free to comment or [email me directly](mailto:hello@yos.io).

If you’re a developer new to crypto, please let me know if you find this guide helpful!

原文链接：https://yos.io/2019/11/10/smart-contract-development-best-practices/
作者：[Yos Riady](https://yos.io/about/)