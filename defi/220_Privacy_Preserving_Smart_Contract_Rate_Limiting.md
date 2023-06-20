# Privacy Preserving Smart Contract Rate Limiting

Simple contract modifier to add the ability to rate limit humans on any smart contract function call.

[![logo](https://img.learnblockchain.cn/attachments/2023/06/ayNQjZkw648ad4be9f655.jpg)](https://github.com/rsproule/n-per-epoch/blob/main/assets/logo-n-per-epoch-hr.jpg)

## Rate Limiting?

This library enables contract creators to set limits on the number of times a specific user can call a function within a defined epoch. The epoch duration is highly flexible, allowing developers to set it to near infinity (1 per forever) or to a very short duration for higher throughput.

> ❗️Warning
>
> Be sure to take into account *proof generation time* and the *block inclusion time*. The "epochId" must match for both proof and settlement on the chain. So *epochLength* must be greater than the sum of *proof generation time* and *block inclusion time* with some buffer.

## Privacy Preserving?

You will notice that these contracts do not care at all about `msg.sender`. This is by design! Under the hood, this takes advantage of zero knowledge proof of inclusion through the usage of the [semaphore](https://semaphore.appliedzkp.org/) library. The contract enforces auth via the provided zk proof instead of relying on the signer of the transaction. [ERC4337](https://eips.ethereum.org/EIPS/eip-4337/) style account abstraction could trivially leverage this type of authentication!

## Human?

This example leverages an existing "anonymity set" developed by [Worldcoin](https://docs.worldcoin.org/), comprising approximately 1.4 million verified human users. Worldcoin established this set by scanning individuals' irises and ensuring that each iris had not been previously added to the set. To utilize a different set, simply modify the groupId within the settings.

## Why is rate limiting useful?

1. **Prevent abuse**: By limiting the number of requests per user, it helps to prevent abuse of services or resources by malicious actors or bots. This ensures that genuine users have fair access to the system without being crowded out by automated scripts or attacks.
2. **Encourage fair distribution**: In scenarios where resources, rewards, or opportunities are limited, rate limiting human users ensures a more equitable distribution. This can help prevent a few users from monopolizing access to valuable assets or services, such as NFT drops or token faucets.
3. **Enhance user experience**: When resources are constrained, rate limiting human users can help maintain a smooth and responsive experience for legitimate users. By preventing system overload or resource depletion, it ensures that users can continue to interact with the application without disruption.
4. **Manage costs**: In blockchain applications, rate limiting human users can help manage costs associated with gas fees or other operational expenses. By controlling the frequency of transactions or function calls, service providers can optimize their expenses while still offering a valuable service to users.
5. **Preserve privacy**: By focusing on human users and leveraging privacy-preserving techniques, rate limiting can be implemented without compromising user privacy. This is particularly important in decentralized systems, where trust in the system is often built on the foundation of user privacy and data security.

## Example use-cases

- **Gas-sponsoring relays**: These relays aim to provide gas for human users of their applications while preventing resource depletion by a single user. This library effectively enables protocols to manage resource allocation for individual users.
- **Faucets**: Distribute assets to human users at a controlled pace, preventing abuse.
- **Rewarding user interactions on social networks**: Rate limiting helps limit the impact of spamming while still encouraging genuine engagement.
- **Fair allocation of scarce resources (e.g., NFT drops)**: By implementing rate limiting, each human user could be allowed to mint a specific amount (e.g., one per hour), promoting equitable distribution.

------

## How to use in your contracts

Install with [Foundry](https://github.com/foundry-rs/foundry):

```
forge install rsproule/n-per-epoch
```

or install with [Hardhat](https://github.com/nomiclabs/hardhat) or [Truffle](https://github.com/trufflesuite/truffle)

```
npm i https://github.com/rsproule/n-per-epoch
```

Check out [`ExampleNPerEpochContract.sol`](https://github.com/rsproule/n-per-epoch/blob/main/src/test/ExampleNPerEpochContract.sol) to see the modifier in action.

```
import { NPerEpoch} from "../NPerEpoch.sol";
...
...
...
constructor(IWorldID _worldId) NPerEpoch(_worldId) {}

function sendMessage(
    uint256 root,
    string calldata input,
    uint256 nullifierHash,
    uint256[8] calldata proof,
    RateLimitKey calldata actionId
)
    public rateLimit(
        root, 
        abi.encodePacked(input).hashToField(), 
        nullifierHash, 
        actionId, 
        proof
    )
{
    if (nullifierHashes[nullifierHash]) revert InvalidNullifier();
    nullifierHashes[nullifierHash] = true;
    emit Message(input);
}
...
...
...
function settings()
    public
    pure
    virtual
    override
    returns (NPerEpoch.Settings memory)
{
    return Settings(1, 300, 2); // groupId (worldID=1), epochLength, numPerEpoch)
}
```

## Install / Build / Test

Install

```
git clone git@github.com:rsproule/n-per-epoch.git
```

Build

```
make 
```

Run the unit tests:

```
make test
```

------

## TODO

-  Migrate to foundry. There was some issues with the worldcoin starter code that i didnt want to deal with
-  package this nicely for simple install (`forge install rsproule/n-per-epoch`)
-  migrate the scripts to typescript
-  how to deploy to production (polygon)
-  example repo (embedded or separate)



原文链接：https://github.com/rsproule/n-per-epoch#readme