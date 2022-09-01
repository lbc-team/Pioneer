原文链接：[A Brief Guide to Hybrid Contracts, Oracles, and Chainlink](https://hackernoon.com/a-brief-guide-to-hybrid-contracts-oracles-and-chainlink?source=rss)

# A Brief Guide to Hybrid Contracts, Oracles, and Chainlink

![1.jpg](https://img.learnblockchain.cn/attachments/2022/08/6FvAnxmK63083d819f9cb.jpg)

If you already got a chance to review how smart contracts work in a Blockchain like Ethereum, you would understand they run in an isolated fashion.

The Ethereum VM executes the contracts in a sandbox, making it impossible to use any data or feature not accessible from the network or any other smart contract.

The idea of Oracles comes into the picture here. The term Oracle became popular right after The Matrix movie. It was the lady who knew everything about the Matrix and told Neo, the main character, about what was happening in the outside world. Following the same analogy, an Oracle is a smart contract that knows how to connect with applications or services running outside of the Blockchain.

Oracles represent a critical path for DEFI apps. In most cases, they connect to different external price feeds and provide price data to other contracts running in the network.

A Hybrid contract is another term used by many in this context. It refers to a combination of a Smart Contract (code that runs on-chain) and off-chain services provided by a Decentralized Oracle Network (or DoN in short).

> > As Sergey Nazarov, one of the Chainlink's Founders, would say once. One Blockchain without Oracles, it's like a computer without the internet.

## The Push and Pull Models

The push and pull models refer to the way an Oracle can feed data to other contracts.

In the push model, applications or DApps (Decentralized Apps) running outside the Blockchain push and store data in Smart Contracts, which other contracts reference later on-demand.

In a pull model, a contract calls an Oracle to retrieve external data. The Oracle then uses different mechanisms to connect with the outside, call an API and push back any result. This model works more like an async callback. A contract submits a transaction in the Blockchain targetting the Oracle Smart Contract. A DApp running outside uses the data in that transaction to call an external API or run any computation and pushes the result back as another transaction for the original contract.

## Chainlink

Chainlink is a project whose aim is to provide all the infrastructure and plumbing for running a network of Oracles that integrate with existing Blockchain networks (Ethereum and others). It's not a Blockchain, but it offers the infrastructure to run heterogeneous networks with oracle nodes that act as intermediaries between Smart Contracts and applications running outside.

The value proposition or business value in Chainlink is to offer a mechanism to sell data to apps running in the Blockchain. If you have an API that provides data that might be useful in the Blockchain, you can publish it through a Chainlink's adapter in one or more nodes and get paid for every request made to it. The unit of payments is a LINK token, which is a standard ERC-677 token.

You can run one or more nodes or ask any existing node operators (service providers that run nodes in their infrastructure) to run the adapter for you.

In that sense, Chainlink represents a collection of decentralized oracle networks with nodes hosting different adapters or connections with external applications.

One of the critical aspects of implementing autonomous apps that run in a Blockchain is that they can not rely on a single data source to make decisions. If the data source becomes unavailable or starts providing inaccurate information, it suddenly becomes a big mess.

Chainlink tries to address that issue by aggregating data from multiple sources and making it available through various nodes (horizontal scaling). If one node becomes unresponsive, the other nodes can take that work. The same thing with the data sources is that if one starts providing invalid data, they can still correct it by using other sources.

It's worth mentioning that Chainlink does not offer or enforce any mechanism for data aggregation. You are responsible for implementing that feature when you connect Chainlink with one or more APIs through an external adapter. We will discuss what an external adapter is in the next section.

Based on the documentation available on Chainlink's website. It looks like the two revenue streams for the projects are related to Price Feeds and the Generation of Random numbers (useful for gaming and gambling).

## Chainlink Architecture

![2.png](https://img.learnblockchain.cn/attachments/2022/08/Ag0QeGhm63083d8794de8.png)
*alt*

At a high level, a Chainlink network is run by nodes. A node is a daemon process that hosts integration jobs and connects to the Blockchain. When you start a node, you must provide a private key for signing any transaction submitted to the Blockchain. If you don't provide one, the node will generate one automatically for you.You also need to fund that key with ETH, or otherwise, the node will not be able to pay any gas. The private key also gives you a public address for identifying your node.

You use **jobs** to integrate your running node with the Oracles in the Blockchain. Those jobs are configured as json documents.

A job contains two parts, an initiator and a collection of tasks. An initiator is a component that watches up for a given condition to happen to kick off the job. Chainlink already offers a set of initiators you can use out of the box in a job or create your initiator otherwise.

Initiators watch out for different conditions to kick off jobs. Some of them, for example, look for events emitted on the Blockchain or transactions in the transaction log. Others just run jobs on-demand or in a given interval of time. The former are used to support a push model with a job running and pushing data to a smart contract. The latter are used to support a pull model with a job reacting to an event and pushing data to a contract afterward.

Once a job is started, it runs a set of tasks to convert the input data coming from the initiator into an output that can be pushed to the Blockchain. One of those tasks can be an adapter, which can connect to an external system or API to pull data.

This is an example of a job,

```javascript
{
  "name": "Call my adapter",
  "initiators": [
    {
      "type": "web"
      }
    }
  ],
  "tasks": [
    {
      "type": "myadapter"
    }
  ]
}
```

The web initiator allows launching the job from a web interface in the node. Once the job is launched, it calls a custom adapter "myadapter", which probably pulls data from an API.

As you can see, a job follows the Pipeline pattern, with an input and several tasks that convert that input into an output.

A node provides two interfaces for configuring jobs and adapters. A cli tool that can be run from a terminal, or a web application that can hit from a web browser. Both require a username and password that must be assigned when the node is initially configured.

### External Adapters

An external adapter is a component that allows the integration between Chainlink and external applications/systems.

Adapters must be previously registered in the node to be used in a job. An adapter is no other thing than an API that follows a convention for the input and output data. When you register it in the node, you only have to specify a name and the URL where it's listening. You later reference it by name in the jobs.

An adapter can only accept HTTP POSTs with the following json payload,

```javascript
{"data":{}, "meta": {}, "id": "<job id>", "responseURL": "<url>"}
```

- data: any input argument to be used by the API
- meta: optional metadata arguments.
- responseURL: optional, will be supplied if job supports asynchronous callbacks
- id: optional, the job id.

It must return with the following json payload,

```javascript
{"data": {}, "error": {}, "pending": true|false}
```

- data: any response data returned by the API
- error: optional, any error information.
- pending: optional, the API requires an asynchronous callback.
- 

This does not use HTTP error codes at all, and relies on a payload element to detect if the API call failed or not.

Also, if the API requires authentication, you will have to configure the credentials or keys in the adapter through standard configuration files (.env) or environment variables in the node, or pass them via a job specification as parameters.

At the time of writing this post, a Node will not provide any authentication token to the adapter. If you don't want anyone to call your adapter, you probably have to host it in the same subnet as the node, or do IP restrictions.

## Running a Chainlink node

You can run a Chainlink node directly from the source code or Dockers images.

In this post, I am going to show how to do it from Docker.

You will require two things to run a Node container from a Docker image,

- A Postgres db.
- An ETH Node or a Connection to a public node like Infura.

For the Postgres DB, you can also run it as a docker container. What I am going to show here uses a docker network to communicate the two containers.

1. Create the docker network first


```
docker network create chainlink-net
```

2. Run the Postgres DB container using the network created in the step #1

```
docker run -d -p 5432:5432 --name chainlink-db --net=chainlink-net -e POSTGRES_PASSWORD=password postgres
```

3. Create the node configuration file (.env file). That's a text file with these settings (This uses the Rinkeby testnet).

```
LOG_LEVEL=debug
ETH_CHAIN_ID=4
MIN_OUTGOING_CONFIRMATIONS=2
LINK_CONTRACT_ADDRESS=0x01BE23585060835E02B77ef475b0Cc51aA1e0709
CHAINLINK_TLS_PORT=0
SECURE_COOKIES=false
GAS_UPDATER_ENABLED=true
ALLOW_ORIGINS=*
ETH_URL=<YOUR INFURA Rinkeby ETH URL>
DATABASE_URL=postgresql://postgres:password@chainlink-db:5432/postgres?sslmode=disable
```

4. Run the Chainlink Node Container

```
docker run -v ~/.chainlink-rinkeby:/chainlink -p 6688:6688 -it --net=chainlink-net --env-file=.env smartcontract/chainlink:0.10.8 local n
```

This will start the container in interactive mode. It will prompt you for an username and password for the admin console, and also a password for the Node private key.

The web application for the Admin dashboard assigned to the node will be publised in the port 6688.

Once the Node container starts running, you can navigate to [https://localhost:6688](https://localhost:6688/?ref=hackernoon.com) and start configuring adapters and jobs.

If you want to export the private key and associate with the funds, it can be done from command line with the CLI tool.

1. Connect to the container in Bash mode

```
docker exec -it <container> bash
```

2. Run the following commands

```
chainlink admin login
chainlink keys eth list
chainlink keys eth export <node-address> -p .password --output key.json
```

You will need the Node address, which is shown when the node starts up or also in the web console, and a file with the private's key password.

The output will be a json file that you can import into a wallet like Metamask.

*Also published on: [https://thecibrax.com/hybrid-contracts-oracles-and-chainlink](https://thecibrax.com/hybrid-contracts-oracles-and-chainlink?ref=hackernoon.com)*