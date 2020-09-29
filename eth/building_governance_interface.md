# 探究Compound治理及构建治理界面

> * [原文链接](https://medium.com/compound-finance/building-a-governance-interface-474fc271588c)， 作者：[Adam Bavosa](https://medium.com/@adam.bavosa)

> Quick Start Guide

![封面](https://img.learnblockchain.cn/pics/20200929084331.png)

社区治理已经取代了Compound协议管理员，这是朝着完全权力下放的重要一步。

权力下放的主要目标是使协议能够发展成为具有弹性的金融基础设施，而没有可知的弱点，也无需依赖任何团队。 通过这种方式，协议可以随着整个加密生态系统的增长而继续扩展，并且可以永久存在或至少伴随着以太坊。

本指南将向你介绍Compound的治理智能合约，并逐步引导你构建与治理系统交互的自定义功能和界面。


## 什么是COMP?

Compound协议只能由COMP代币持有者及其代理升级和配置。 协议的所有潜在更改，包括增加新市场或调整系统参数(如*抵押因子*或*利率算法*)，都必须通过治理智能合约中指定的提案和投票过程。


COMP是在 Compound 治理中具有 1:1 投票权的代币。 以太坊钱包中的COMP代币持有人可以使用[COMP 治理合约](https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/GovernorAlpha.sol)中提供的函数将投票权委托给自己或任何其他以太坊地址。


委托投票权的接收者(称为代理人)，无论他们是COMP持有人本身还是其他地址，都可以提案、投票和执行提案以修改协议。 你可以在[Compound治理面板](https://compound.finance/governance)上看到当前的代理列表。

为了收到COMP，请在以太坊或任何测试网上使用Compound协议。 有关更多详细信息，请查阅[文档](https://compound.finance/docs/governance)。



## 治理的核心概念


一旦了解了基础知识，就可以轻松构建用于治理的接口或扩展其功能。 要更深入地了解治理，请查看完整的[文档](https://compound.finance/docs/governance)。 为了快速入门，这里仅列出关键概念。


1. **COMP** - ERC-20代币，用于指定用户的投票权。 用户钱包中的COMP余额越多，他们对提案的授权或投票就越重。
2. **Delegation委托** — COMP持有人只有在将投票权委托给某个地址后才能投票或创建提案。 一次可以委托各一个地址，包括委托给COMP持有人自己的地址。被委托人的投票数相当于用户账号的 COMP 代币余额。投票将从当前区块开始进行委托，直到发送者再次委托或者转移其 COMP。
3. **Proposals提案** — 提案是可执行的代码，可修改协议及其工作方式。 为了创建提案，必须至少有所有COMP的1％委托给该地址。现有总计1000万个COMP，因此用户必须将至少100,000个COMP委托给其地址。 提案存储在[Governor智能合约](https://etherscan.io/address/0xc0da01a04c3f3e0be433606045bbbb7017a7323e38)的 “proposals” [映射](https://learnblockchain.cn/docs/solidity/types.html#mapping-types)中。 所有提案的投票期均为3天。 如果提案者在整个投票期间未维持其投票权重，则任何人都可以取消该提案。
4. **Voting投票** — 用户将投票权委托给其地址后，便可以对单个提案投票赞成或反对。 提案处于“有效（Active）”状态时可以进行投票。 投票可以使用 `castVote` 立即提交，也可以使用 `castVoteBySig` 离线签名稍后提交。 如果大多数票(达到 4％的委托COMP的法定人数，即400,000 COMP)对某个提案投票赞成，则该提案将在时间锁中排队。
5. **Timelock时间锁** — 所有治理和其他管理操作都必须在时间锁中停留至少2天，然后才能在协议中实施。每个 cToken 合约和 Comptroller 合约都允许 Timelock 地址修改。Timelock 合约可以修改系统参数、逻辑和合约，以 "延迟时间、选择退出" 的升级模式进行修改。

![治理流程](https://img.learnblockchain.cn/pics/20200929105022.jpg)


如果社区决定以治理的形式对其进行升级，则随着时间的推移，治理系统的这些关键组件可能会发生变化。 COMP持有者将是该协议各个方面未来方向的最终仲裁者。

> 注：COMP 部署在[0xc00e94cb662c3520282e6f5717214004a7f26888](https://etherscan.io/token/0xc00e94cb662c3520282e6f5717214004a7f26888) 、 治理合约部署在[0xc0dA01a04C3f3E0be433606045bB7017A7323E38](https://etherscan.io/address/0xc0dA01a04C3f3E0be433606045bB7017A7323E38)


## 通过Compound治理可以构建什么？


应用程序开发人员可以构建自己的自定义工作流和界面，以促进其用户和社区参与Compound治理。 例如，与Compound的利率市场集成的应用程序可能对添加治理功能感兴趣，包括：


- 鼓励用户将COMP投票权委托给应用团队的地址，以便该团队可以代表用户参与治理。
- 向用户显示特定的管理提案，以便拥有COMP的用户可以直接对其投票。
- 向用户提供透明的洞察力，以了解Compound的即将发生的潜在变化，包括添加新市场或其他升级的提案。

此类接口将需要以下组件的组合：

- 投票界面 - 用户能对有效的提案进行投票。
- 委托界面 - 用户将投票权委托给某个地址。
- 投票权排行榜 — 列出按投票权排序的投票地址。
- 我的代理投票界面 - 使用`castVoteBySig` 功能，用户可以创建分配给其他用户的投票。 这将允许另一个用户代理他们提交投票(并支付gas)，而无需委托给另一个用户。
- 提案资源管理器 - 在简化的用户界面中浏览过去或现在的治理提案。
- 提案创建界面 - 如果用户有足够的投票权重(> 1％)，请选择协议修改并初始化提案。


![治理界面](https://img.learnblockchain.cn/pics/20200929085131.png)


## Compound 治理代码示例


治理界面必须在区块链之间进行读写，我们将逐步介绍一些基本的JavaScript代码示例，以实现这两种功能。 读取数据将使用Compound API和Web3完成。 但是，只能使用Web3完成写入操作，例如委托或投票。

我们将按顺序演示如何执行以下每个操作：

- 获取所有COMP代币持有人
- 获取所有委托
- 获取所有提案
- 获取所有提案的选票
- 委托投票权
- 对（有效）提案进行投票


GitHub上的[Compound 治理快速入门](https://github.com/compound-developers/compound-governance-examples)代码库中提供了以下示例完整代码。 


### 获取所有COMP代币持有人


让我们根据其COMP余额按降序获取所有COMP代币持有者。 我们可以通过[CompoundAPI的治理服务](https://compound.finance/docs/api#GovernanceService)来实现。

```js 

let requestParameters = {
  "page_size": 100,            // number of results in a page
  "network": "ropsten",        // mainnet, ropsten
  "order_by": "balance",       // "votes", "balance", "proposals_created"
  // "page_number": 1,         // see subsequent response's `pagination_summary` to specify the next page
  // addresses: ['0x123'],     // array of addresses to filter on
  // with_history: true,       // boolean, returns a list of transaction history for the accounts
};

requestParameters = '?' + new URLSearchParams(requestParameters).toString();

fetch(`https://api.compound.finance/api/v2/governance/accounts${requestParameters}`)
.then((response) => response.json())
.then((result) => {
  let accounts = result.accounts;
  console.log(accounts);
  let holders = [];
  accounts.forEach((account) => {
    holders.push({
      "address": account.address,
      "balance": parseFloat(account.balance).toFixed(4),
      "delegate": account.delegate.address == 0 ? 'None' : account.delegate.address
    });
  });

  holderListContainer.innerHTML = holderListTemplate(holders);
});
```

<center>文件：get_comp_holders_api.js [完整代码示例](https://github.com/compound-developers/compound-governance-examples/blob/master/api-examples/get_comp_holders.html)</center>


这段代码使用内置的浏览器获取方法，该方法返回JavaScript Promise。 代码库有一个相同的示例，在示例中[使用Web3.js对COMP持有人进行直接区块链查询](https://github.com/compound-developers/compound-governance-examples/blob/master/web3-examples/get_comp_holders.html)。 我们可以使用COMP智能合约找到相同的信息。


这两个代码示例的结果都是一个JSON对象数组，其中包含帐户地址，COMP代币余额和帐户委托地址。



```js comp-holder.json 
[
  {
    "address": "0xb61c5971d9c0472befceffbe662555b78284c307",
    "balance": "200000.0000",
    "delegate": "0xb61c5971d9c0472befceffbe662555b78284c307",
  }
]
```
<center>comp-holder.json </center>



### 获取所有委托


我们可以看到委托了COMP的所有地址。 下面是一个区块链查询，它利用COMP合约的`DelegateVotesChanged` 事件来收集当前的每个委托。

```js get_delegates_web3.js
// Ropsten COMP Contract
const compAddress = '0x1fe16de955718cfab7a44605458ab023838c2793';
const compAbi = window.compAbi;
const comp = new web3.eth.Contract(compAbi, compAddress);

(async () => {
  const delegations = await comp.getPastEvents('DelegateVotesChanged', {
    fromBlock: 0,
    toBlock: 'latest'
  });

  const delegateAccounts = {};

  delegations.forEach(e => {
    const { delegate, newBalance } = e.returnValues;
    delegateAccounts[delegate] = newBalance;
  });

  const delegates = [];
  Object.keys(delegateAccounts).forEach((account) => {
    const voteWeight = +delegateAccounts[account];
    if (voteWeight === 0) return;
    delegates.push({
      delegate: account,
      vote_weight: voteWeight
    });
  });

  delegates.sort((a, b) => {
    return a.vote_weight < b.vote_weight ? 1 : -1;
  });

  delegates.forEach(d => {
    d.vote_weight = (100 * ((d.vote_weight / 1e18) / 10000000)).toFixed(6) + '%';
  });

  console.log(delegates);

  delegateListContainer.innerHTML = delegateListTemplate(delegates);
})();
```

<center> get_delegates_web3.js [完整代码示例](https://github.com/compound-developers/compound-governance-examples/blob/master/web3-examples/get_delegates.html) </center>


或者，可以从Compound API 检索此信息。 这是[Compound API 示例](https://github.com/compound-developers/compound-governance-examples/blob/master/api-examples/get_delegates.html)。 这些示例创建一个JSON对象数组，这些对象具有委托地址和COMP供给总量的投票权重(百分比)。

```json delegate.json 
[
  {
    "delegate": "0xb61c5971d9c0472befceffbe662555b78284c307",
    "vote_weight": "2.000000%"
  }
]
```
<center> delegate.json </center>


### 获取所有提案


如果你要创建治理浏览器，则获取所有提案非常有用。 Compound API 在这里很方便。 此示例将获取所有提案，无论其状态如何。 该API能够根据请求参数按状态过滤提案。

```js get_all_proposals_api.js
let requestParameters = {
  "network": "ropsten",   // mainnet, ropsten
  "page_size": 100,       // integer, defaults to 10
  // "proposal_ids": 1,   // an integer ID or array of IDs
  // "state": "active",   //  "pending", "active", "canceled", "defeated", "succeeded", "queued", "expired", "executed"
  // "with_detail": true, // boolean
  // "page_number": 1,    // see subsequent response's `pagination_summary` to specify the next page
};

requestParameters = '?' + new URLSearchParams(requestParameters).toString();

fetch(`https://api.compound.finance/api/v2/governance/proposals${requestParameters}`)
  .then((response) => response.json())
  .then((result) => {
    console.log(result);
    const proposals = result.proposals || [];
    proposals.forEach((p) => {
      p.state = p.states[p.states.length-1].state
      p.for_votes = parseFloat(p.for_votes).toFixed(2);
      p.against_votes = parseFloat(p.against_votes).toFixed(2);
    });
    proposalListContainer.innerHTML = proposalItemTemplate(proposals);
  });
```

<center>get_all_proposals_api.js [完整代码示例](https://github.com/compound-developers/compound-governance-examples/blob/master/api-examples/get_proposals.html)</center>


我们也可以使用治理合约的`ProposalCreated`事件直接通过Web3获取相同的提案数据。 代码示例使用以下提案数据创建一个JSON对象数组。


```json proposal.json
[
  {
    "against_votes": "601000.00",
    "description": "10 BTC is actually a decent amount. Boop!",
    "for_votes": "835000.00",
    "id": 18,
    "title": "Reduce WBTC reserves by 10!",
    "state": "succeeded"
  }
]
```

<center> proposal.json [完整代码示例](https://github.com/compound-developers/compound-governance-examples/blob/master/api-examples/get_proposals.html)</center>

### 获取提案的选票


一旦提案达到“有效”状态，选民就可以开始投票。 选票公开存储在区块链上，因此我们可以随时对其进行检索。 以下是在Ropsten上获取提案1的提交投票的示例。

```js get_all_ballots_web3.js
// Ropsten Governor Alpha Contract
const governanceAddress = '0xc5bfed3bb38a3c4078d4f130f57ca4c560551d45';
const governanceAbi = window.governanceAbi;
const gov = new web3.eth.Contract(governanceAbi, governanceAddress);

(async () => {
  const voteCastEvents = await gov.getPastEvents('VoteCast', {
    fromBlock: 0,
    toBlock: 'latest'
  });

  let submittedBallots = voteCastEvents;
  let formattedBallots = [];
  submittedBallots.forEach((ballot) => {
    const { voter, support, votes, proposalId } = ballot.returnValues;
    if (proposalId == id) {
      formattedBallots.push({
        blockNumber: ballot.blockNumber,
        address: voter,
        support: support ? 'In Favor' : 'Against',
        votes: (parseFloat(votes) / 1e18).toFixed(2),
      });
    }
  });

  formattedBallots.reverse();
  console.log(formattedBallots);

  ballotListContainer.innerHTML = ballotListTemplate(formattedBallots);
})();
```

<center> get_all_ballots_web3.js</center> 

 [完整代码示例](https://github.com/compound-developers/compound-governance-examples/blob/master/web3-examples/get_ballots.html)


提案ID从1开始按升序排列。要查看已提出的提案数量，可以从治理合约中获取 `proposalCount`变量。 选票可以从Compound API中获取，例如在此[治理服务示例](https://github.com/compound-developers/compound-governance-examples/blob/master/api-examples/get_ballots.html)中。 这是一个选票数据的JSON对象的结果数组。


```json ballot.json
[
  {
    "address": "0x9687eb285292cba14a60a0c77dfd36dd95b93889",
    "support": "In Favor",
    "votes": "8500000.00"
  }
]
```

<center> ballot.json </center>

### 委托投票权




为了参与治理，COMP代币持有者必须`delegate委托`其投票权。 可以委托到任何地址，包括代币持有者自己的地址。 一次只能委托一个地址。



以下是设置委托地址的Web3示例。 如果你没有COMP代币，则仍然可以委托，将来收到的COMP代币将自动委托给你选择的委托地址。

```js delegate.js
// Ropsten COMP Contract
compAddress = '0x1fe16de955718cfab7a44605458ab023838c2793';
compAbi = window.compAbi;
comp = new web3.eth.Contract(compAbi, compAddress);

let currentDelegate;
try {
  currentDelegate = await comp.methods.delegates(myAccount).call();
} catch (e) {
  currentDelegate = 0;
}

delegate.innerText = currentDelegate == 0 ? 'None' : currentDelegate;

submit.onclick = async () => {
  const delegateTo = newDelegate.value;

  if (!delegateTo) {
    alert('Invalid address to delegate your votes.');
    return;
  }

  loader.classList.remove('hidden');
  try {
    const tx = await comp.methods.delegate(delegateTo).send({ from: myAccount });
    console.log(tx);
    alert(`Successfully Delagated to ${delegateTo}`);
    window.location.reload();
  } catch(e) {
    console.error(e);
    alert(e.message);
  }
  loader.classList.add('hidden');
};
```

<center> delegate.js  </center>

[完整代码示例](https://github.com/compound-developers/compound-governance-examples/blob/master/web3-examples/set_delegate.html)




该代码依赖于启用了Web3的浏览器。 确保在浏览器中安装[MetaMask](https://metamask.io/)。 可以从水龙头索取Ropsten ETH。 实际效果如下：


![委托投票](https://img.learnblockchain.cn/pics/20200929091207.png)

###  对提案进行投票



Compound治理最激动人心的部分是在更改协议的提案中投下你的一票。 委托者可以为每个有效的提案投反对票或赞成票。



以下代码示例展示了投票用户界面的功能。 如果Ropsten测试网上没有活动的提案，那么选择器中将没有任何提案！

```js cast_vote.js
// Ropsten Governor Contract
governanceAddress = '0xc5bfed3bb38a3c4078d4f130f57ca4c560551d45';
governanceAbi = window.governanceAbi;
gov = new web3.eth.Contract(governanceAbi, governanceAddress);

// Add a list of active proposals to the UI
getProposals();

// Get my account's vote weight
getMyVoteWeight(myAccount);

submit.onclick = async () => {
  // An active proposal needs to be selected in the UI
  if (proposalSelector.value < 1) {
    alert('Select a proposal to vote in.');
    return;
  }

  // A vote choice needs to be selected in the UI
  if (!_for.checked && !against.checked) {
    alert('Select a vote option.');
    return;
  }

  const proposal = proposalSelector.value;
  const vote = _for.checked ? true : false;

  loader.classList.remove('hidden');
  try {
    const tx = await gov.methods.castVote(proposal, vote).send({ from: myAccount });
    console.log(tx);
    alert(`Successfully voted ${vote ? 'for' : 'against'} Proposal ${proposal}`);
    window.location.reload();
  } catch(e) {
    console.error(e);
    alert(e.message);
  }
  loader.classList.add('hidden');
};
```

<center> cast_vote.js  </center>

[完整代码示例](https://github.com/compound-developers/compound-governance-examples/blob/master/web3-examples/cast_vote.html)

![Cast my Vote](https://img.learnblockchain.cn/pics/20200929091055.png)

## 建立自己的治理界面



社区治理的目标是使Compound协议成为对所有人开放和具有弹性的金融基础设施。 要达到这一里程碑，社区、开发人员、用户和机构都必须创建自己的界面和功能，以参与Compound治理。

由于以太坊具有可组合和开放访问的特性，因此任何人和所有人都可以创建自己的COMP和治理项目。 这里有更多资源可以帮助你入门。

### Compound治理资源

- [治理简介(2020年2月)](https://medium.com/compound-finance/compound-governance-5531f524cf68)

- [治理发布公告(2020年4月)](https://medium.com/compound-finance/compound-governance-decentralized-b18659f811e0)

- [Compound协议治理文档](https://compound.finance/docs/governance?ref=medium)

- [Compound API 治理服务文档](https://compound.finance/docs/api#GovernanceService?ref=medium)

- [社区主导的治理论坛](https://compound.comradery.io/)

  

---



本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。







