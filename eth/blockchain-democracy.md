# 区块链民主 - 如何开发通过投票运行的合约

> [原文链接](https://medium.com/swlh/blockchain-democracy-932b969d1cc5), 作者：Alberto Cuesta Cañada
 

![民主](https://img.learnblockchain.cn/pics/20200928105038.png)
> Photo by Markus Spiske from Pexels

当你为某事投赞成票时，你如何知道实际上会完成什么事情？ 你怎么知道承诺会兑现？

在本文中，我将简要介绍区块链如何改变民主。 如何通过区块链民主程序，把承诺变成了行动。

我并不是要说我们可以或应该废除政治并建立技术专家制，但是我将展示如何运行一个投票系统，如果投票通过，该系统将自动制定执行。

你可以称之为不可阻挡的民主。

## 概念设计


首先，请让我以两种智能合约来设置场景：

* 智能合约是一个不可变的程序。 智能合约中编码好的规则无法更改。 部署后，也无法停止。

* 智能合约还可以触发其他智能合约的操作。 例如，智能合约可以触发另一个合约以将资金释放到某个帐户，或授予某人执行某些交易的权限。

  

根据这些概念，我们可以编写运行公平投票程序的智能合约。每个人都能看到的明确规则， 在该智能合约中，我们可以包含一个提案，该提案是对另一个智能合约中的功能的调用。



无论如何，投票都会进行。 如果投票通过，无论如何都将执行该提案。

## 以太坊和民主



投票是民主的支柱之一，也是以太坊的核心组成部分之一。



通常认为[Vitalik Buterin](https://about.me/vitalik_buterin)突破了比特币，提议以太坊上创建一个平台，允许在该平台上使用我们上面描述的原则来实施民主组织。



这些基于区块链的民主组织被称为[去中心化自治组织](https://en.wikipedia.org/wiki/Decentralized_autonomous_organization)，简称DAO（Decentralized Autonomous Organizations）。 DAO由其利益相关者指导，规则编码在区块链智能合约中，没有中心控制。



> 当你对某事投票时，你如何知道实际上会完成什么事情？ 你怎么知道承诺会兑现？



阅读[DAO的维基百科文章](https://en.wikipedia.org/wiki/Decentralized_autonomous_organization)非常有趣。 它揭示了早期DAO的概念是如何构思的，以及它是多么的强大。[Daniel Larimer](https://twitter.com/bytemaster7)(他由BitShares，Steem和EOS.IO项目成名)提出并 最早于2013年在BitShares 实现了该概念。 然后你也知道[The DAO(Đ)](https://en.wikipedia.org/wiki/The_DAO_%28organization%29)，该组织在[遭到黑客入侵](https://medium.com/swlh/the-story-of-the-dao-its-history-and-consequences-71e6a8a551ee)前吸引到了所有流通中的14％的以太币投资到该组织中。



但是， “The DAO” 的消亡并不意味着“ DAO组织”的消亡。 去中心化自治组织[还活着并且很好](https://defirate.com/daos/)，因为死亡的 The DAO的漏洞已广为人知，而且很容易避免。

[Vlad Farcas](https://twitter.com/uivlis)和我开始了一个[玩具DAO项目](https://github.com/HQ20/contracts/tree/master/contracts/examples/dao)，因为我们想学习如何应用民主模式。 通过编写DAO，我了解了区块链中民主流程的可能性，这让我大吃一惊。 这就是为什么我要写这个。



介绍结束，让我们深入研究代码。 我们应该怎么做？

## 制定智能合约提案

考虑以下合约：

```js
contract Proposal {
  address public targetContract;
  bytes public targetCall;
  
  /// @param targetContract_ 执行提案的目标合约
  /// @param targetCall_ 执行提案的目标函数（abi 编码及参数）
  constructor(
    address targetContract_,
    bytes memory targetCall_,
  ) public {
    targetContract = targetContract_;
    proposalData = targetCall_;
  }
  
  /// @dev 执行投票的提案
  function enact() external virtual {
    (bool success, ) = targetContract.call(targetCall);
    require(success, “Failed to enact proposal.”);
  }
}
```



该合约具有一些底层的魔法，但解释起来并不难。 在部署时，它需要另一个合约的地址和一个函数调用。 调用`enact()`时，它将在目标合约上执行函数调用。



可以使用[web3.js](https://learnblockchain.cn/docs/web3.js/web3-eth-abi.html#encodefunctioncall)对提案进行编码。 在javascript中，下面的示例中部署了一个`提案`，该提案在执行时将铸造一个`ERC20`代币。

```
token = await ERC20Mintable.new(‘Token’, ‘TKN’, 18);
proposalData = web3.eth.abi.encodeFunctionCall(
  {
    type: ‘function’,
    name: ‘mint’,
    payable: false,
    inputs: [
      {name: ‘account’, type: ‘address’},
      {name: ‘amount’, type: ‘uint256’},
    ],
  },
  [owner, ‘1’]
);
proposal = await Proposal.new(token.address, proposalData);
```



`web3.eth.abi.encodeFunctionCall`有点冗长，但实际上唯一做的就是将函数签名和参数包装在32个字节的数据中（[参考文档](https://learnblockchain.cn/docs/web3.js/web3-eth-abi.html#encodefunctioncall)）。



它的第一个参数表示函数签名，称为`mint`(铸币函数)，是非付费的函数，其`address`参数称为`account`，另一个`uint256`参数称为`amount`。
第二个参数则是为参数赋值，使用在其他地方定义的`owner`帐户，而铸币的数量为1。


有更简单的方法可以让一个合约调用在另一个合约上的函数。 现在也许很难理解为什么我们会以这种复杂的方式来做这件事情。


继续阅读，现在我们将使该提案民主化。 让我们看看制定提案的合约，它需要经过成功的投票之后执行。

## 一币一票


你可以在[HQ20代码库中找到此合约](https://github.com/HQ20/contracts/blob/master/contracts/voting/OneTokenOneVote.sol)代码，请随意使用它，但不要不加修改的用于现实产品中。 为了易于理解，我们忽略了许多对漏洞的处理，例如针对闪贷攻击的漏洞。

```js
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../math/DecimalMath.sol";

contract OneTokenOneVote is Ownable {
    using DecimalMath for uint256;

    event VotingCreated();
    event VotingValidated();
    event ProposalEnacted();
    event VoteCasted(address voter, uint256 votes);
    event VoteCanceled(address voter, uint256 votes);

    IERC20 public votingToken;
    mapping(address => uint256) public votes;
    address public targetContract;
    bytes public proposalData;
    uint256 public threshold;
    bool public passed;

    constructor(
        address _votingToken,
        address _targetContract,
        bytes memory _proposalData,
        uint256 _threshold
    ) public Ownable() {
        votingToken = IERC20(_votingToken);
        threshold = _threshold;
        targetContract = _targetContract;
        proposalData = _proposalData;
        emit VotingCreated();
    }

    modifier proposalPassed() {
        require(passed == true, "Cannot execute until vote passes.");
        _;
    }

    /// @dev Function to enact one proposal of this voting.
    function enact() external virtual proposalPassed {
        // solium-disable-next-line security/no-low-level-calls
        (bool success, ) = targetContract.call(proposalData);
        require(success, "Failed to enact proposal.");
        emit ProposalEnacted();
    }

    /// @dev 用这个函数投票，需要先授权
    /// (from the frontend) to spend _votes of votingToken tokens.
    /// @param _votes The amount of votingToken tokens that will be casted.
    function vote(uint256 _votes) external virtual {
        votingToken.transferFrom(msg.sender, address(this), _votes);
        votes[msg.sender] = votes[msg.sender].addd(_votes);
        emit VoteCasted(msg.sender, _votes);
    }

    /// @dev Use this function to retrieve your votingToken votes in case you changed your mind or the voting has passed
    function cancel() external virtual {
        uint256 count = votes[msg.sender];
        delete votes[msg.sender];
        votingToken.transfer(msg.sender, count);
        emit VoteCanceled(msg.sender, count);
    }

    /// @dev Number of votes casted in favour of the proposal.
    function inFavour() public virtual view returns (uint256) {
        return votingToken.balanceOf(address(this));
    }

    /// @dev Number of votes needed to pass the proposal.
    function thresholdVotes() public virtual view returns (uint256) {
        return votingToken.totalSupply().muld(threshold, 4);
    }

    /// @dev Function to validate the threshold
    function validate() public virtual {
        require(
            inFavour() >= thresholdVotes(),
            "Not enough votes to pass."
        );
        passed = true;
        emit VotingValidated();
    }
}
```

在 OneTokenOneVote.sol 文件里:

* 投票的代币，是来自部署时选择的ERC20合约。
* 投票意味着使用`vote()`将代币转移到`OneTokenOneVote`合约中。
* 如果在任何时候`OneTokenOneVote`持有的比例高于`threshold` （相比于流通量），则通过提案。
* 提案通过后，它将永远保持在 `passed` 状态。
* 选民可以随时取消投票（调用 `cancel`）并取回其代币，但如果他们希望提案通过，则应在提案通过后再进行取回。
* 任何人都可以通过调用`validate()`来触发计票。 如果达到`threshold`，这将使投票通过。


实现投票有[几种方法](https://github.com/HQ20/contracts/blob/master/contracts/voting/OneManOneVote.sol)。 有更安全的投票方式，包括要求达到法定人数。 `OneTokenOneVote.sol` 是我们能想到的最简单的示例，但这足以显示区块链民主的原理。


在部署投票合约时，它接受带有参数编码的 `targetContract` 和`targetFunction`作为提案。 如果投票通过，任何人都可以调用 `enact()` 函数来执行提案。

这意味着投票合约包括如果表决通过将要采取的行动。 不可能忽略投票结果。 在区块链之前这是不可能的，请思考一下。

## 合约民主

我们可以为这种区块链民主概念提供另一种转折。 到目前为止，我们知道如何部署需要执行表决过程然后在执行投票结果结果的合约。


我们可以编写一份合约，其中所有的功能如果经过表决就**才能被**执行。 这就是DAO的精神，它比听起来容易。


在代码库中，我们包含了第三份合约[Democratic.sol](https://github.com/HQ20/contracts/blob/master/contracts/voting/Democratic.sol)，我发现使用起来真的很令人兴奋。 它允许任何合约对是否执行其任何功能进行表决。

* `Democratic.sol`被设计为可被其他合约继承，仅当它们经过投票后才允许将其中函数可执行。 你可以通过使用 `onlyProposal` 来修饰要执行的函数来做到这一点。


* `Democratic.sol`允许任何人提出提案进行投票。 `propose()` 函数可以被任何人使用，目标函数使用 `web3.eth.abi.encodeFunctionCall` 编码。

* 所有提案的投票代币都将相同，从而在[MakerDAO](http://makerdao.com/)中创建一个带有MKR代币的社区。 `Democratic.sol` 的实现是基于代币的投票，但可以轻松更改为基于帐户的投票。


* 全部提案存储在 `proposals` 变量中，并且只有由同一合约创建的提案才能执行标记为`onlyProposal`的函数。


如果考虑到这一点，则可以使用`Democratic.sol`和`OneTokenOneVote.sol`作为[完整民主系统的基础](https://github.com/HQ20/contracts/blob/master/contracts/access /Democracy.sol)。 如果你没有发现这是多么的令人兴奋，我不知道还能告诉你什么。

## 结论

区块链有可能以我们一生中从未有过的程度改变民主进程。


使用区块链可以实现不可阻挡的投票，一旦投票通过，任何人都无法避免被执行。 随着越来越多的世界可以从区块链访问，民主的力量将会增长。


在本文中，我们展示了如何实现智能合约执行的投票程序，并对其进行了改进，以生成只能由民主进程执行的智能合约函数。


自从以太坊诞生以来，这些概念在区块链生态系统中都不是新事物。 但是，在这些合约中，我们提供的基础模块往前民主又迈出了一步。

--- 

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。