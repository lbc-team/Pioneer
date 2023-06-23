# 隐私保护智能合约速率限制

简单的合约修改器，用于在任何智能合约函数调用中进行速率限制。

[![logo](https://img.learnblockchain.cn/attachments/2023/06/ayNQjZkw648ad4be9f655.jpg)](https://github.com/rsproule/n-per-epoch/blob/main/assets/logo-n-per-epoch-hr.jpg)

## 速率限制？

该库使合约创建者能够在定义的时间周期内限制特定用户调用函数的次数。时间周期的持续时间非常灵活，允许开发者将其设置为接近无限（永远只能调用一次）或者设置为很短的时间以实现更高的吞吐量。

> ❗️警告
>
> 请一定要考虑到*证明生成时间*和*区块包含时间*。"epochId" 必须同时匹配链上的证明和结算。因此，时间周期长度必须大于证明生成时间和区块包含时间之和，并留出一些缓冲时间。

## 隐私保护？

您会注意到这些合约完全不关心 msg.sender（消息发送者）。这是有意设计的！在内部，它利用了零知识包含证明，通过使用[semaphore](https://semaphore.appliedzkp.org/) 库来实现。该合约通过提供的 zk 证明来强制进行身份验证，而不依赖交易的签署者。[ERC4337](https://eips.ethereum.org/EIPS/eip-4337/) 类型的账户抽象化可以轻松利用这种类型的身份验证！

## 人类？

这个示例使用了由[Worldcoin](https://docs.worldcoin.org/) 开发的已有的 anonymity set （匿名集合），其中包括大约140万个已验证的人类用户。Worldcoin通过扫描人的虹膜，并确保每个虹膜之前未被添加到集合中，建立了这个集合。只需在设置中修改groupId，即可使用不同的集合。

## 为什么速率限制是有用的？

1. **防止滥用**：通过限制每个用户的请求次数，有助于防止恶意行为者或机器人滥用服务或资源。这确保了真实用户能够公平地访问系统，而不会被自动化脚本或攻击排挤出去。
2. **促进公平分配**：在资源、奖励或机会有限的情况下，对人类用户进行速率限制可以确保更加公平的分配。这有助于防止少数用户垄断对有价值的资产或服务的访问，例如 NFT 发行或代币水龙头。
3. **提升用户体验**：当资源受限时，对人类用户进行速率限制可以帮助维持合法用户的流畅和响应式体验。通过防止系统过载或资源枯竭，确保用户可以继续与应用交互而不受干扰。
4. **成本管理**：在区块链应用中，对人类用户进行速率限制有助于管理与Gas费用或其他运营费用相关的成本。通过控制交易或函数调用的频率，服务提供商可以优化开支，同时向用户提供有价值的服务。
5. **保护隐私**：通过关注人类用户并利用隐私保护技术，可以在不牺牲用户隐私的前提下实施速率限制。这在去中心化系统中尤为重要，因为对系统的信任往往是建立在用户隐私和数据安全的基础上的。

## 示例

- **Gas赞助中继**：这些中继旨在为其应用的人类用户提供Gas，同时防止单个用户消耗资源。这个库有效地使协议能够管理单个用户的资源分配。
- **水龙头**：以可控的速度向人类用户分发资产，防止滥用。
- **奖励社交网络上的用户互动**：速率限制有助于限制垃圾信息的影响，同时鼓励真实的互动。
- **稀缺资源的公平分配（例如，NFT 发行）**：通过实施速率限制，可以允许每个人类用户在特定时间内铸造一定数量的资产（例如，每小时一次），促进公平分配。

------

## 如何在您的合约中使用

通过[Foundry](https://github.com/foundry-rs/foundry) 安装:

```
forge install rsproule/n-per-epoch
```

或者通过[Hardhat](https://github.com/nomiclabs/hardhat) 或 [Truffle](https://github.com/trufflesuite/truffle) 安装：

```
npm i https://github.com/rsproule/n-per-epoch
```

查看[`ExampleNPerEpochContract.sol`](https://github.com/rsproule/n-per-epoch/blob/main/src/test/ExampleNPerEpochContract.sol) ，检查修改器已生效：

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

## 安装 / 构建 / 测试

安装：

```
git clone git@github.com:rsproule/n-per-epoch.git
```

构建：

```
make 
```

执行单元测试：

```
make test
```

------

## 待办事项

-  迁移到Foundry。worldcoin启动程序代码中有一些问题，我不想处理
-  将其整理成易于安装的包（`forge-install-rsproule/n-per-epoch`）
-  将脚本迁移到typescript
-  如何部署到生产环境（polygon）
-  示例代码库（嵌入式或独立式）



原文链接：https://github.com/rsproule/n-per-epoch#readme
