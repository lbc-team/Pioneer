

# 构建去中心化智能合约编程货币

**[第1部分]  使用Solidity 和 React在以太坊上构建具有社交找回功能的智能合约钱包**

## 前言

我第一次对以太坊感到兴奋那会儿是阅读这10行代码的时候：
![](https://img.learnblockchain.cn/2020/07/28/15959046766713.jpg)

该代码在创建合约时会跟踪`owner`，并且只允许“owner”使用`require()`语句调用`withdraw()` 。

该智能合约控制自己的资金。 它具有地址和余额，可以发送和接收资金，甚至可以与其他智能合约进行交互。

这是一台永远在线的公共*状态机*,你可以对其编程，世界上任何人都可以与它交互！



##  依赖条件

你需要事先安装 [NodeJS>=10](https://nodejs.org/en/download/), [Yarn](https://classic.yarnpkg.com/en/docs/install/)和 [Git](https://git-scm.com/downloads).

本教程将假定你对[Web应用程序开发](https://reactjs.org/tutorial/tutorial.html) 有基本的了解，并且稍微接触过[以太坊核心概念](https://www.youtube.com/watch?v=9LtBDy67Tho&feature=youtu.be&list=PLJz1HruEnenCXH7KW7wBCEBnBLOVkiqIi&t=13)。你可以随时在文档中[阅读有关Solidity的更多信息](https://solidity.readthedocs.io/en/v0.6.7/introduction-to-smart-contracts.html),但是先试试这个吧:


## 开始

打开一个终端并克隆 🏗 [scaffold-eth](https://github.com/austintgriffith/scaffold-eth)仓库。我们构建去中心化应用程序原型所需的一切都包含在这里：

```
git clone https://github.com/austintgriffith/scaffold-eth
cd scaffold-eth
git checkout part1-smart-contract-wallet-social-recovery
yarn install
```

☢️ 警告，运行 `yarn install`  继续并运行接下来的三个命令时，你可能会收到看起来像错误的警告,它可能没有影响！

注意本教程是如何获取`part1-smart-contract-wallet-social-recovery`分支的，  🏗[scaffold-eth](https://github.com/austintgriffith/scaffold-eth)是一个可fork的以太坊开发技术栈，每个教程都是一个分支，你可以fork和使用!

在你喜欢的编辑器中本地打开代码，然后概览一下：

你可以在`packages/buidler/contracts`中找到`SmartContract Wallet.sol`, 这是我们的智能合约(后端)。

`packages/react-app/src`中的 `App.js` 和 `SmartContractWallet.js` 是我们的web应用程序(前端).

![](https://img.learnblockchain.cn/2020/07/28/15959051423719.jpg)

打开你的前端:

```
yarn start
```

☢️ 警告，如果没有运行接下来的两行，你的CPU会抽风:

在第二个终端中启动由👷[Builder](https://buidler.dev/)驱动的本地区块链:

```
yarn run chain
```

在第三个终端中，编译并部署合约：

```
yarn run deploy
```

☢️ 警告，此项目中有几个名为`contracts`的目录。多花一点时间，以确保所处的目录在`packages/buidler/contracts`文件夹 。

我们智能合约中的代码被编译为称为`字节码`和`ABI`的“工件”(artifacts)。 这个`ABI`定义了我们如何与合约交互，而`bytecode`是“机器代码”。 你可以在`packages/buidler/artifacts`文件夹中找到这些工件。

为了部署合约，首先需要在交易中发送`字节码`，然后我们的合约将在本地链上的特定`地址`运行。 这些工件会自动注入到我们的前端，以便我们可以与合约进行交互。

在浏览器中打开 [http://localhost:3000](http://localhost:3000) :

![](https://img.learnblockchain.cn/2020/07/28/15959063898250.jpg)



让我们快速浏览一下这个脚手架，为后面的做铺垫… 



##  提供者(Provider)

使用你的编辑器打开`packages/react-app/src`文件夹下的`App.js`前端文件。

🏗 在`App.js`中scaffold-eth 有三个不同的 [providers](https://github.com/austintgriffith/scaffold-eth#-web3-providers) :

`mainnetProvider` : [Infura](http://infura.io)支持**只读**的以太坊主网，它用于获取主网余额并与现有的运行的合约交互，例如Uniswap的ETH价格或ENS域名查询。

`localProvider` : [Buidler](http://buidler.dev) 是**本地**链，当我们在本地对Solidity进行迭代时，会将你的合约部署到这里。该provider的第一个帐户提供本地的水龙头。

`injectedProvider` : 程序会先启动[burner provider](https://www.npmjs.com/package/burner-provider)(页面加载后的即时帐户)，但随后你可以点击`connect`以引入由[ Web3Modal](https://github.com/Web3Modal/web3modal)支持的更安全的钱包。该provider会对发送到我们的本地和主网的交易进行**签名**。

区块链是一个节点网络，每一节点都拥有当前状态。如果我们想访问以太坊网络，我们可以运行自己的节点，但我们不希望用户仅因为使用我们的应用程序就必须同步整条链；因此，我们将使用简单的Web请求与基础设施的`provider`进行交互。


![1_KLLE4FdXon9cev8CWvgT-Q](https://img.learnblockchain.cn/pics/20200805162446.gif)



##  钩子函数(Hooks)

我们还将利用🏗scaffold-eth中的一堆[美味钩子](https://github.com/austintgriffith/scaffold-eth#-hooks)比如`userBalance()`来追踪地址的余额或`useContractReader()`使我们的状态与合约保持同步。在[此处](https://reactjs.org/docs/hooks-overview.html)阅读更多有关React钩子的信息。





## 组件(Components)

这个脚手架还包含许多用于构建Dapp的[方便组件](https://github.com/austintgriffith/scaffold-eth/blob/master/README.md#-components)。 我们很快就会看到的`<AddressInput />`就是一个很好的例子。 在[此处](https://reactjs.org/docs/components-and-props.html)阅读有关React组件的更多信息。


## 函数(Functions)

我们在`packages/buidler/contracts`中的`SmartContractWallet.sol`中创建一个 `isOwner()`的函数. 这个函数可以查询钱包是否是某个地址的所有者：

```
function isOwner(address possibleOwner) public view returns (bool) {
  return (possibleOwner==owner);
}
```

注意该函数为什么被标记为`view`？ 函数可以写入状态**或**读取状态。 当我们需要写入状态时，我们必须支付gas才能将交易发送给合约，但是读状态既简单又便宜，因为我们可以向任何provider询问状态。

> 要在智能合约上调用函数，你需要将交易发送到合约的地址。

我们再创建一个名为`updateOwner()`可修改状态的函数，该函数使当前所有者可以设置新的所有者:

```
function updateOwner(address newOwner) public {
  require(isOwner(msg.sender),"NOT THE OWNER!");
  owner = newOwner;
}
```

我们在这里使用了`msg.sender`和`msg.value`，`msg.sender`是发送交易的地址，`msg.value`是随交易发送的以太币数量。你可以在此处详细了解[单位和全局变量](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html)。 

注意`require()`语句如何确保`msg.sender`是当前的所有者。 如果条件不满足，它将`revert()`，并且整个交易都被撤消。

>  以太坊交易是原子的： 要么一切正常，要么一切撤销。如果我们将一个代币发送给Alice，并且在同一合约调用中，我们未能从Bob那里获取一个代币，则整个交易将被撤消。

保存，编译和部署合约:

```
yarn run deploy
```

合约执行后，我们可以看到你的地址不是所有者:

![](https://img.learnblockchain.cn/2020/07/28/15959083398949.jpg)


让我们在部署智能合约时将我们的帐户地址传递给智能合约，以便我们成为所有者。 首先，从右上角复制你的帐户（这个图中的操作后面还会用到，记为✅TODO LIST)：

![1_LWdTy9h-Rv_fbJUgS15iEw](https://img.learnblockchain.cn/2020/07/29/1_LWdTy9h-Rv_fbJUgS15iEw.gif)

然后，在`packages/builder/contracts`中编辑文件`SmartContract Wallet.args`，并将地址更改为你的地址。 然后，重新部署：

```
yarn run deploy
```

 我们正在使用一个自动化脚本，该脚本试图找到我们的合约并进行部署。 最终，我们将需要一个更具定制性的解决方案，但是你可以浏览`packages/buidler`目录中的`scripts/deploy.js`。

你的地址现在应该是合约的所有者：

![](https://img.learnblockchain.cn/2020/07/28/15959085928296.jpg)

你需要一些测试ether支付与合约交互所需的gas：

仿照“✅TODO LIST”图中的操作，并向我们的帐户发送一些测试ETH。 从右上方复制你的地址，然后将其粘贴到左下方的水龙头中(然后单击发送)。 你可以为你的地址提供所有想要的测试ether。

然后，尝试使用“📥Deposit”按钮将一些资金存入你的智能合约中:

![](https://img.learnblockchain.cn/2020/07/28/15959099861240.jpg)


该操作将失败，因为向我们的智能合约传递价值的交易将被撤销，因为我们尚未添加“fallback”函数。

![](https://img.learnblockchain.cn/2020/07/28/15959121577641.jpg)

让我们在`SmartContractWallet.sol`中添加一个`payable` `fallback()`函数，使其可以接受交易。 在` packages/buidler`中编辑你的智能合约并添加:

```
fallback() external payable {    
  console.log(msg.sender,"just deposited",msg.value);  
}
```

每当有人与我们的合约进行交互而未指定要调用的函数名称时，都会自动调用“fallback”函数。 例如，如果他们将ETH直接发送到合约地址。

编译并重新部署你的智能合约:

```
yarn run deploy
```

🎉 现在，当你存入资金时，合约应该执行成功!

![1_ntUlRyaaZ3UxmV8kGO5YyA](https://img.learnblockchain.cn/2020/07/29/1_ntUlRyaaZ3UxmV8kGO5YyA.gif)

但这是“可编程的货币”，让我们添加一些代码以将总ETH的数量限制为0.005(按今天的价格为1.00美元)，以确保没有人在我们的未经审计的合约中投入100万美元。 **替换** 你的 `fallback()` 为:

```
uint constant public limit = 0.005 * 10**18;
fallback() external payable {
  require(((address(this)).balance) <= limit, "WALLET LIMIT REACHED");
  console.log(msg.sender,"just deposited",msg.value);
}
```

> 译者注： 在 Solidity 0.6之后的版本中，可以使用[接收函数](https://learnblockchain.cn/docs/solidity/contracts.html#receive)

注意我们为何乘以10¹⁸？  Solidity不支持浮点数，只支持整数。1 ETH等于10¹⁸wei。 此外，如果你发送的交易值为1，则是1 wei，wei是以太坊中允许的最小单位。 在撰写本文时，1 ETH的价格是:

![](https://img.learnblockchain.cn/2020/07/28/15959122997530.jpg)

现在重新部署并尝试多次depositing，调用次数达到上限后，会报错:

![](https://img.learnblockchain.cn/2020/07/28/15959124138003.jpg)

请注意，在智能合约中，前端如何通过`require()`语句第二个参数的消息获得有价值的反馈。使用它来以及在`yarn run chain`终端中显示的`console.log`帮助你调试智能合约:

![](https://img.learnblockchain.cn/2020/07/28/15959198340880.jpg)

你可以调整钱包限额，或者只需要重新部署新合约即可重置所有内容:

```
yarn run deploy
```



##  存储和计算

假设我们要跟踪允许与我们的合约交互的朋友的地址。 我们可以保留一个`whilelist []`[数组](https://learnblockchain.cn/docs/solidity/types.html#arrays)，但随后我们将拥有遍历数组比较值以查看给定地址是否在白名单中。 我们还可以使用[mapping](https://learnblockchain.cn/docs/solidity/types.html#mapping-types)来追踪，但是我们将无法迭代他们。 我们必须抉择使用哪种数据更好。 

在链上存储数据相对昂贵。 每个世界各地的矿工都需要执行和存储每个状态更改。 注意不要有昂贵的循环或过多的计算。 值得[探索一些示例](https://learnblockchain.cn/docs/solidity/solidity-by-example.html)和[阅读有关EVM的更多信息](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-6)。

> 这就是为什么这个东西如此具有弹性/抗审查性的原因。 数千个(受激励的)第三方都在执行相同的代码，并且在没有中央授权的情况下就它们存储的状态达成一致。 它永不停止！ 

回到智能合约中，让我们使用[mapping](https://solidity.readthedocs.io/en/v0.6.7/types.html?highlight=mapping#mapping-types)存储余额。 我们**无法**遍历合约中的所有朋友，但是它允许我们快速读取和写入任何给定地址的`bool`访问权限。 将此代码添加到你的合约中:

```
mapping(address => bool) public friends;
```

注意我们为什么将这个`friends`映射标记为`public`？ 这是一个公链，所以你应该假设一切都是公共的。

☢️ 警告：即使我们将此映射设置为 `private` ，也仅表示外部合约无法读取它，**任何人仍然可以链下读取私有变量** :

创建一个函数 `updateFriend()`并设置它的 `true` 或 `false`参数:

```
function updateFriend(address friendAddress, bool isFriend) public {
  require(isOwner(msg.sender),"NOT THE OWNER!");
  friends[friendAddress] = isFriend;
  console.log(friendAddress,"friend bool set to",isFriend);
}
```

注意我们一定要复用 `msg.sender` 为`owner`的这行代码吗？ 你可以使用 [修改器Modifier](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html#modifier)进行清理。 然后，每当你需要一个只能由所有者运行的函数时，可以在函数中添加 `onlyOwner modifier` ，而不是此行。完全可选).

现在，我们部署它并回到前端:

```
yarn run deploy
```



>  我们可以同时对前端合约和智能合约进行小的增量更改。 这个紧密的开发循环使我们能够快速迭代并测试新的想法或机制。




我们将要在`packages/react-app/src`目录中的`SmartContractWallet.js`中的`display`中添加一个表单。 首先，让我们添加一个状态变量:

```
const [ friendAddress, setFriendAddress ] = useState("")
```

然后，让我们创建一个变量，该变量 *创建一个函数*，该函数调用`updateFriend()`:

```
const updateFriend = (isFriend)=>{
  return ()=>{
    tx(writeContracts['SmartContractWallet'].updateFriend(friendAddress, isFriend))
    setFriendAddress("")
  }
}
```

注意在我们在合约上调用函数的代码结构：`contract`. `functionname`(`args`)全部包裹在`tx()`中，因此我们可以跟踪交易进度。 你还可以`等待`此`tx()`函数以获取生成的哈希，状态等。

当你写入`地址公共所有者`地址时，它会自动为此变量创建一个“getter”函数，我们可以通过`useContractReader()`钩子轻松地获取它。

接下来，让我们创建一个`ownerDisplay`部分，该部分仅针对`owner`显示。 这将显示一个带有两个按钮的`AddressInput`(地址输入组件)，分别用于`updateFriend(false)`和`updateFriend(true)`。

```javascript
let ownerDisplay = []
if(props.address==owner){
  ownerDisplay.push(
    <Row align="middle" gutter={4}>
      <Col span={8} style={{textAlign:"right",opacity:0.333,paddingRight:6,fontSize:24}}>Friend:</Col>
      <Col span={10}>
        <AddressInput
          value={friendAddress}
          ensProvider={props.ensProvider}
          onChange={(address)=>{setFriendAddress(address)}}
        />
      </Col>
      <Col span={6}>
        <Button style={{marginLeft:4}} onClick={updateFriend(true)} shape="circle" icon={<CheckCircleOutlined />} />
        <Button style={{marginLeft:4}} onClick={updateFriend(false)} shape="circle" icon={<CloseCircleOutlined />} />
      </Col>
    </Row>
  )
}
```

最后，将`{ownerDisplay}`添加到所有者行下的`display`中:

![](https://img.learnblockchain.cn/2020/07/28/15959202903031.jpg)

在你的应用程序🔥重新热加载后，尝试点击一下。(你可以在新的浏览器或隐身模式下导航到[http://localhost：3000](http//localhost:3000/)以获取获取新的会话帐户以复制新地址。)

![1_AttSC5qoeUxbL-gqP49nxw](https://img.learnblockchain.cn/2020/07/29/1_AttSC5qoeUxbL-gqP49nxw.gif)

如果不进行地址迭代，很难知道在发生什么，也很难列出我们所有的朋友以及他们在前端的状态。

这是事件*events*的工作.



## 🛎 事件(Events)

事件几乎就像是一种存储形式。 它们在执行过程中从智能合约中发出的成本相对较低，但是智能合约却不能*读取*事件。

让我们回到智能合约 `SmartContractWallet.sol`.

在`updateFriend()`函数上方或下方创建一个事件:

```
event UpdateFriend(address sender, address friend, bool isFriend);
```

然后，在`updateFriend()`函数中，添加此`emit`:

```
emit UpdateFriend(msg.sender,friendAddress,isFriend);
```

编译并部署更改:

```
yarn run deploy
```

然后，在前端，我们可以添加事件监听器钩子。 将此代码与我们的其他钩子一起添加到`SmartContractWallet.js`:

```
const friendUpdates = useEventListener(readContracts,contractName,"UpdateFriend",props.localProvider,1);
```

(因为需要用在TODO List，上面这一行代码里之前已经写好了😅。）

在我们的渲染中，在之后添加一个显示:

```
<List
  style={{ width: 550, marginTop: 25}}
  header={<div><b>Friend Updates</b></div>}
  bordered
  dataSource={friendUpdates}
  renderItem={item => (
    <List.Item style={{ fontSize:22 }}>
      <Address 
        ensProvider={props.ensProvider} 
        value={item.friend}
      /> {item.isFriend?"✅":"❌"}
    </List.Item>
  )}
/>
```

🎉 现在，当它重新加载时，我们应该能够添加和删除朋友！
![1_odLcQnTvb5-J15GkB0LJ_A](https://img.learnblockchain.cn/2020/07/29/1_odLcQnTvb5-J15GkB0LJ_A.gif)



## 社交找回(Social Recovery)

现在我们在合约中设置了“朋友”，让我们创建一个可以触发的“恢复模式”.

让我们想象一下，我们以某种方式丢失了“所有者”的[私有密钥](https://www.youtube.com/watch?v=9LtBDy67Tho&list=PLJz1HruEnenCXH7KW7wBCEBnBLOVkiqIi&index=4&t=0s)，现在我们被锁定在智能合约钱包之外了 。我们需要让我们的一个朋友触发某种恢复。

我们还需要确保，如果某个朋友意外(或恶意)触发了恢复并且我们仍然可以访问`所有者`帐户，我们可以在几秒钟内的`timeDelay`内取消恢复。

首先，我们在`SmartContractWallet.sol`中设置一些变量 :

```
uint public timeToRecover = 0;
uint constant public timeDelay = 120; //seconds
address public recoveryAddress;
```

然后赋予所有者设置`recoveryAddress`的函数:

```
function setRecoveryAddress(address _recoveryAddress) public {
  require(isOwner(msg.sender),"NOT THE OWNER!");
  console.log(msg.sender,"set the recoveryAddress to",recoveryAddress);
  recoveryAddress = _recoveryAddress;
}
```



本教程中有很多代码需要复制和粘贴。 请务必花一点时间放慢速度阅读，以了解发生了什么。

如果你曾经感到困惑和沮丧，请在 [Twitter DM](https://twitter.com/austingriffith)上给我留言，我们将看看能否一起解决！ [Github issues ](https://github.com/austintgriffith/scaffold-eth/issues)也非常适合反馈！



让我们为朋友添加一个函数，以帮助我们找回资金:

```
function friendRecover() public {
  require(friends[msg.sender],"NOT A FRIEND");
  timeToRecover = block.timestamp + timeDelay;
  console.log(msg.sender,"triggered recovery",timeToRecover,recoveryAddress);
}
```

我们使用`block.timestamp`，你可以在[ special variables here](https://solidity.readthedocs.io/zh/v0.6.7/units-and-global-variables.html?highlight=units#block-and-transaction-properties)阅读更多内容.

如果不小心触发了`friendRecover()`，我们希望所有者能够取消恢复:

```
function cancelRecover() public {
  require(isOwner(msg.sender),"NOT THE OWNER");
  timeToRecover = 0;
  console.log(msg.sender,"canceled recovery");
}
```

最后，如果我们处于恢复模式并且已经过去了足够的时间，任何人都可以销毁我们的合约并将其所有以太币发送到`recoveryAddress`:

```
function recover() public {
  require(timeToRecover>0 && timeToRecover<block.timestamp,"NOT EXPIRED");
  console.log(msg.sender,"triggered recover");
  selfdestruct(payable(recoveryAddress));
}
```

[selfdestruct()](https://solidity.readthedocs.io/en/v0.6.8/cheatsheet.html?highlight=selfdestruct#global-variables)将从区块链中删除我们的智能合约，并将所有资金返还到`recoveryAddress`.

☢️ 警告，具有 `owner` 且可以随时调用 `selfdestruct()` 的智能合约实际上并不是“去中心化”的。 开发人员应非常注意任何个人或组织都无法控制或审查的机制。

让我们编译，部署并回到前端:

```
yarn run deploy
```

在我们的`SmartContractWallet.js`和其他钩子函数中，我们将要跟踪`recoveryAddress`：

```
const [ recoveryAddress, setRecoveryAddress ] = useState("")
```

这是让所有者设置`recoveryAddress`表单的代码 :

```js
ownerDisplay.push(
  <Row align="middle" gutter={4}>
    <Col span={8} style={{textAlign:"right",opacity:0.333,paddingRight:6,fontSize:24}}>Recovery:</Col>
    <Col span={10}>
      <AddressInput
        value={recoveryAddress}
        ensProvider={props.ensProvider}
        onChange={(address)=>{
          setRecoveryAddress(address)
        }}
      />
    </Col>
    <Col span={6}>
      <Button style={{marginLeft:4}} onClick={()=>{
        tx(writeContracts['SmartContractWallet'].setRecoveryAddress(recoveryAddress))
        setRecoveryAddress("")
      }} shape="circle" icon={<CheckCircleOutlined />} />
    </Col>
  </Row>
)
```

然后我们要跟踪在合约中的`currentRecoveryAddress`:

```js
const currentRecoveryAddress = 
useContractReader(readContracts,contractName,"recoveryAddress",1777);
```

我们还要跟踪`timeToRecover`和`localTimestamp`:

```js
const timeToRecover = useContractReader(readContracts,contractName,"timeToRecover",1777);
const localTimestamp = useTimestamp(props.localProvider)
```

并在恢复按钮之后使用`<Address />`显示恢复地址。 另外，我们将为所有者添加一个`cancelRecover()按钮`。 将此代码放在`setRecoveryAddress()`按钮之后:

```
{timeToRecover&&timeToRecover.toNumber()>0 ? (
  <Button style={{marginLeft:4}} onClick={()=>{
    tx( writeContracts['SmartContractWallet'].cancelRecover() )
  }} shape="circle" icon={<CloseCircleOutlined />}/>
):""}
{currentRecoveryAddress && currentRecoveryAddress!="0x0000000000000000000000000000000000000000"?(
  <span style={{marginLeft:8}}>
    <Address
      minimized={true}
      value={currentRecoveryAddress}
      ensProvider={props.ensProvider}
    />
  </span>
):""}
```

![](https://img.learnblockchain.cn/2020/07/28/15959223836941.jpg)

![1_-UVGEbIIH3avYWyQ0TImRg](https://img.learnblockchain.cn/2020/07/29/1_-UVGEbIIH3avYWyQ0TImRg.gif)

我们在这里使用[ENS](https://ens.domains/)将名称转换为地址并返回。 这类似于传统的DNS，你可以在其中注册名称.

现在，让我们来跟踪用户是否是`isFriend`:

```js
const isFriend = 
	useContractReader(readContracts,contractName,"friends",[props.address],1777);
```

如果他们是朋友，请给他们显示一个按钮，以调用`friendRecover()`，然后在`localTimestamp`在`timeToRecover`之后最终调用`recover()`。 在`if(props.address == owner){`检查所有者的末尾添加这个大的`else if`:

```js
}else if(isFriend){
  let recoverDisplay = (
    <Button style={{marginLeft:4}} onClick={()=>{
      tx( writeContracts['SmartContractWallet'].friendRecover() )
    }} shape="circle" icon={<SafetyOutlined />}/>
  )
  if(localTimestamp&&timeToRecover.toNumber()>0){
    const secondsLeft = timeToRecover.sub(localTimestamp).toNumber()
    if(secondsLeft>0){
      recoverDisplay = (
        <div>
          {secondsLeft+"s"}
        </div>
      )
    }else{
      recoverDisplay = (
        <Button style={{marginLeft:4}} onClick={()=>{
          tx( writeContracts['SmartContractWallet'].recover() )
        }} shape="circle" icon={<RocketOutlined />}/>
      )
    }
  }
  ownerDisplay = (
    <Row align="middle" gutter={4}>
      <Col span={8} style={{textAlign:"right",opacity:0.333,paddingRight:6,fontSize:24}}>Recovery:</Col>
      <Col span={16}>
        {recoverDisplay}
      </Col>
    </Row>
  )
}
```

尝试一下，感受一下该应用程序。 玩玩合约，玩玩前端。 现在它是你的！

你可以根据需要使用不同的浏览器和隐身模式创建尽可能多的帐户。 然后用水龙头给他们一些ether。

☢️ 警告，我们正在从本地链中获取时间戳，但是它不会像主网那样定时出块。 因此，我们将不得不时不时地发送一些事务以更新时间戳。

![1_1Mqo-87iqGEswsyaT4jI2g](https://img.learnblockchain.cn/2020/07/29/1_1Mqo-87iqGEswsyaT4jI2g.gif)

上面是运行的Demo，其中左边的帐户拥有钱包，在右边的帐户是朋友账户，然后最终该朋友可以恢复以太币：



## 恭喜你！

我们围绕智能合约钱包构建了具有安全限制和社交找回功能的去中心化应用程序!!!

你应该已经有足够的了解，甚至可以克隆 🏗 [scaffold-eth](https://github.com/austintgriffith/scaffold-eth) 来构建出迄今为止最强大的应用!!!

想象这个钱包是否具有某种自治市场，世界上任何人都可以以动态定价买卖资产?

我们甚至可以铸造收藏品并在curve上出售它们?!

我们甚至可以创建了一个🧙‍♂️即时钱包以快速发送和接收资金?!

我们甚至可以构建gas花费很少应用程序以使用户愿意上车!?

我们甚至可以用`提交/显示`随机数创建了一个🕹游戏?!

我们甚至可以创建一个本地🔮预测市场，只有我们的朋友和朋友的朋友可以参与?!

我们甚至可以部署了👨‍💼$me代币并构建一个应用程序，持有人可以向你投资下一个应用程序？?!

我们可以将这些👨‍💼me代币流化为用于在🏗[scaffold-eth](https://github.com/austintgriffith/scaffold-eth)上构建有趣事物的帮助资源!?!



> 简直无限可能!!! 



本教程还有一个视频：[https://www.youtube.com/watch?v=7rq3TPL-tgI](https://www.youtube.com/watch?v=7rq3TPL-tgI)



如果你想了解有关Solidity的更多信息，建议你玩[Ethernaut](https://ethernaut.openzeppelin.com/)，[Crypto Zombies](https://cryptozombies.io/)，然后甚至是[RTFM](https://learnblockchain.cn/docs/solidity)。

前往[https://ethereum.org/developers](https://ethereum.org/developers/)了解更多资源.

随时在[Twitter DM](https://twitter.com/austingriffith) 或[github仓库](https://github.com/austintgriffith/scaffold-eth)给我留言

原文链接：https://medium.com/@austin_48503/programming-decentralized-money-300bacec3a4f 作者：[Austin Thomas Griffith](https://medium.com/@austin_48503)

