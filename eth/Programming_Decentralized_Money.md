

# 🛠 Programming Decentralized Money

## a straightforward guide to building smart contract applications

![](https://img.learnblockchain.cn/2020/07/28/15959043339610.jpg)[Austin Thomas Griffith](https://medium.com/@austin_48503)

* * *


***[Part 1] 📄 Building a Smart Contract Wallet on Ethereum with Social Recovery in Solidity and React***

*[ ☢️ alpha release: May 15, 2020 — updated: May 16, 2020]*

[ 🙋‍♂️ Join [this temporary Telegram group](https://t.me/joinchat/KByvmRe5wkR-8F_zz6AjpA) for feedback/troubleshooting ]

* * *

# 🏃‍♀️ SpeedRun:

[https://www.youtube.com/watch?v=7rq3TPL-tgI](https://www.youtube.com/watch?v=7rq3TPL-tgI)


* * *


# 🤩 Introduction

My first “A ha!” moment with Ethereum was reading these 10 lines of code:
![](https://img.learnblockchain.cn/2020/07/28/15959046766713.jpg)

💡 This code keeps track of an `owner` when the contract is created and only lets the `owner` call `withdraw()` using a `require()` statement.

*🤔 OH! This smart contract controls its own money. It has an address and a balance, it can send and receive funds, it can even interact with other smart contracts.*

*🤖 It’s an always-on, public *state machine* that you can program and anyone in the world can interact with it!*


* * *

# 👩‍💻 Prerequisites

You will need [NodeJS>=10](https://nodejs.org/en/download/), [Yarn](https://classic.yarnpkg.com/en/docs/install/), and [Git](https://git-scm.com/downloads) installed.

This tutorial will assume that you have a basic understanding of [web app development](https://reactjs.org/tutorial/tutorial.html) and maybe even a little exposure to [core Ethereum concepts](https://www.youtube.com/watch?v=9LtBDy67Tho&feature=youtu.be&list=PLJz1HruEnenCXH7KW7wBCEBnBLOVkiqIi&t=13). You can always [read more about Solidity](https://solidity.readthedocs.io/en/v0.6.7/introduction-to-smart-contracts.html) in the docs, but try this first:

* * *

# 🙇‍♀️ Getting Started

Open up a terminal and clone the 🏗 [scaffold-eth](https://github.com/austintgriffith/scaffold-eth) repo. This comes with everything we need to prototype and build a decentralized application:

```
git clone https://github.com/austintgriffith/scaffold-eth
cd scaffold-eth
git checkout part1-smart-contract-wallet-social-recovery
yarn install
```

*☢️ Warning, you might get warnings that look like errors when you run* `*yarn install*` *continue on and run the next three commands. It will probably work!*

💡 Notice how we are grabbing the `part1-smart-contract-wallet-social-recovery` branch for this tutorial. 🏗 [scaffold-eth](https://github.com/austintgriffith/scaffold-eth) is a fork-able Ethereum development stack and each tutorial will be a branch you can fork and use!

Open the code locally in your favorite editor and take a look around:

In `packages/buidler/contracts` you will find `SmartContractWallet.sol`. This is our smart contract (backend).

In `packages/react-app/src` is `App.js` and `SmartContractWallet.js` this is our web app (frontend).

![](https://img.learnblockchain.cn/2020/07/28/15959051423719.jpg)

Start your frontend:

```
yarn start
```

*☢️ Warning, your CPU will go nuts without running the next two lines too:*

Fire up a local blockchain powered by 👷 [Buidler](https://buidler.dev/) in a second terminal:

```
yarn run chain
```

In a third terminal, compile and deploy your contract:

```
yarn run deploy
```

*☢️ Warning, there are a few different directories in this project named “contracts”. Take an extra second to make sure you have found* `*SmartContractWallet.sol*` *in the* `*packages/buidler/contracts*` *folder.*

💡 The code from our smart contract is compiled into “artifacts” called `bytecode` and an `ABI` . This `ABI` defines how to interface with our contract and the `bytecode` is “machine code”. You can find these artifacts in the folder: `packages/buidler/artifacts`.

💡 To deploy a contract, the `bytecode` is sent in a transaction and then our contract will live at specific `address` on our local chain. These artifacts are automatically injected into our frontend so we can interface with our contract.

Open [http://localhost:3000](http://localhost:3000) in a web browser:

![](https://img.learnblockchain.cn/2020/07/28/15959063898250.jpg)



🗺 Let’s take a quick tour of this scaffolding to get a lay of the land… 🔭



* * *



# 🛰 Providers

Open up our frontend `App.js` in `packages/react-app/src` with your editor.

🏗 scaffold-eth has *three* different [**providers**](https://github.com/austintgriffith/scaffold-eth#-web3-providers) for you in `App.js`:

`mainnetProvider` : [Infura](http://infura.io) backed **readonly** main Ethereum network. This is used to get mainnet balances and talk to existing live contracts like the price of ETH from Uniswap or an ENS name lookup.

`localProvider` : [Buidler](http://buidler.dev) **local** chain where your contracts get deployed while we are iterating on the Solidity locally. The local faucet is powered by the first account from this provider.

`injectedProvider` : Starts with a [burner provider](https://www.npmjs.com/package/burner-provider) (instant account on page load), but then you can hit `connect` to bring in a more secure wallet powered by [Web3Modal](https://github.com/Web3Modal/web3modal). This provider acts as our **signer** for sending transactions to *both* our local and mainnet chains.

💡 Blockchains have a network of nodes that hold the current state. We could run our own node if we wanted access to the Ethereum network, but we don’t want our users to have to sync the chain just to use our app. Instead, we’ll talk to an infrastructure “provider” using simple web requests.

![1_KLLE4FdXon9cev8CWvgT-Q -1-](https://img.learnblockchain.cn/2020/07/29/1_KLLE4FdXon9cev8CWvgT-Q (1).gif)



* * *


# 🔗 Hooks

We will also leverage a bunch of [tasty hooks](https://github.com/austintgriffith/scaffold-eth#-hooks) from 🏗 scaffold-eth like `useBalance()` to track an address’s balance or `useContractReader()` to keep our state in sync with our contracts. Read more about React hooks [here](https://reactjs.org/docs/hooks-overview.html).


* * *


# 🎛 Components

This scaffolding also brings along a bunch of [handy components](https://github.com/austintgriffith/scaffold-eth/blob/master/README.md#-components) for building decentralized applications. A good example is the `<AddressInput/>` we’ll see in just a bit. Read more about React components [here](https://reactjs.org/docs/components-and-props.html).

* * *


# ⚙️ Functions

Let’s create a function called `isOwner()` in`SmartContractWallet.sol` in `packages/buidler/contracts`. This function lets us ask the wallet if a certain address is the owner:

```
function isOwner(address possibleOwner) public view returns (bool) {
  return (possibleOwner==owner);
}
```

💡 Notice how this function is marked as `view`? Functions can write to the state **or** just read from it. When we need to write to the state we have to pay gas to send a transaction to the contract, but reading is easy and cheap because we can just ask any provider for the state.

*🤔 OH! To call a function on a smart contract you send a transaction to the contract’s address.*

Let’s also create a *write* function called `updateOwner()` that lets the current owner set a new owner:

```
function updateOwner(address newOwner) public {
  require(isOwner(msg.sender),"NOT THE OWNER!");
  owner = newOwner;
}
```

💡 We are using `msg.sender` and `msg.value`, you can read more about [units and global variables here](https://solidity.readthedocs.io/en/v0.6.7/units-and-global-variables.html). `msg.sender` is the address that sent the transaction and `msg.value` is the amount of ether sent with the transaction.

💡 Notice how that `require()` statement makes sure that the `msg.sender` is the current `owner`. If this isn’t true it will `revert()` and the whole transaction is reversed.

*🤔 OH! Ethereum transactions are atomic; either everything works or everything is reversed. If we send one token to Alice and in the same contract call we fail to take one token from Bob, the entire transaction reverses.*

Save, compile, and deploy your contract:

```
yarn run deploy
```

When the contract comes up, we can see that your address is not the owner:

![](https://img.learnblockchain.cn/2020/07/28/15959083398949.jpg)


Let’s pass in our account to the smart contract when it is deployed so we are the owner. First, copy your account from the top right:

![1_LWdTy9h-Rv_fbJUgS15iEw](https://img.learnblockchain.cn/2020/07/29/1_LWdTy9h-Rv_fbJUgS15iEw.gif)

Then, edit the file `SmartContractWallet.args` in `packages/buidler/contracts` and change the address to your address. Then, redeploy:

```
yarn run deploy
```

💡 We are using an automatic script that tries to find our contracts and get them deployed. Eventually, we will need a more customized solution, but you can take a peek at `scripts/deploy.js` in the `packages/buidler` directory.

Your address should now be the owner of the contract:

![](https://img.learnblockchain.cn/2020/07/28/15959085928296.jpg)

⛽️ You’ll need some test ether to pay the gas to interact with your contract:

Follow the “✅ TODO LIST” and send our account some test ETH. Copy your address from the top right and paste it into the faucet in the bottom left (and hit send). You can give your addresses all the test ether you want.

Then, try to deposit some funds into your smart contract with the `📥 Deposit` button:

![](https://img.learnblockchain.cn/2020/07/28/15959099861240.jpg)


*☢️ This should fail, transactions sending value to your smart contract will revert because we haven’t added a “fallback” function, yet.*

![](https://img.learnblockchain.cn/2020/07/28/15959121577641.jpg)

Let’s add a `payable` `fallback()` function to `SmartContractWallet.sol` so it can accept transactions. Edit your smart contract in `packages/buidler` to add:

```
fallback() external payable {    
  console.log(msg.sender,"just deposited",msg.value);  
}
```

*🤖 The “fallback” function gets called automatically whenever someone interacts with our contract without specifying a function name to call. For example, if they just send ETH directly to the contract address.*

Compile and redeploy your smart contract with:

```
yarn run deploy
```

🎉 Now when you deposit funds it should accept them!

![1_ntUlRyaaZ3UxmV8kGO5YyA](https://img.learnblockchain.cn/2020/07/29/1_ntUlRyaaZ3UxmV8kGO5YyA.gif)

But this is *programmable money*, let’s add some code to limit the amount of total ETH to 0.005 ($1.00 at today’s price) just to be sure no one puts a million dollars in our unaudited contract 😅. **Replace** your `fallback()` with:

```
uint constant public limit = 0.005 * 10**18;
fallback() external payable {
  require(((address(this)).balance) 
```

💡 Notice how we multiply by 10¹⁸ ? Solidity doesn’t support floating points so everything is an integer. 1 ETH equals 10¹⁸ wei. Further, if you send a transaction with the value 1, that means 1 wei, the smallest possible unit in Ethereum. The price of 1 ETH at the time of writing this is:

![](https://img.learnblockchain.cn/2020/07/28/15959122997530.jpg)

Now redeploy and try depositing a bunch of times. You should get an error once you reach the limit.

![](https://img.learnblockchain.cn/2020/07/28/15959124138003.jpg)

💡 Notice how we have valuable feedback in the frontend with the message from the second argument of the `require()` statement in our smart contract. Use this to help you debug your smart contract along with the `console.log` that shows up in your `yarn run chain` terminal:

![](https://img.learnblockchain.cn/2020/07/28/15959198340880.jpg)

You can adjust the wallet limit or even just redeploy a fresh contract to reset everything:

```
yarn run deploy
```

* * *


# 💾 Storage and Computation

Let’s say we want to keep track of friends’ addresses that are allowed to interact with our contract. We could keep a `whilelist[]` [array](https://solidity.readthedocs.io/en/v0.6.7/types.html?highlight=arrays#fixed-size-byte-arrays) but then we would have to loop through the array comparing values to see if a given address is on the whitelist. We could also keep track of a [mapping](https://solidity.readthedocs.io/en/v0.6.7/types.html?highlight=mapping#mapping-types) but then we won’t be able to iterate through them. We’ll have to decide which is best. 🧐

💡 Storing data on-chain is relatively expensive. Every single miner around the world needs to execute and store every single state change. You need to be mindful of expensive loops or excessive computation. It’s worth [exploring some examples](https://solidity.readthedocs.io/en/v0.6.7/solidity-by-example.html) and [reading more about the EVM](https://solidity.readthedocs.io/en/v0.6.7/introduction-to-smart-contracts.html#index-6).

*🤔 OH! That’s why this thing is so resilient / censorship resistant. Thousands of (incentivized) third parties are all executing the same code and agreeing on the state they all store without a centralized authority. It’s unstoppable! 🤖 😳*

Back in the smart contract, let’s use a [mapping](https://solidity.readthedocs.io/en/v0.6.7/types.html?highlight=mapping#mapping-types) to store balances. We *can’t* iterate over all the friends inside the contract but it allows us quick read and write access to a `bool` for any given `address`. Add this code to your contract:

```
mapping(address => bool) public friends;
```

💡 Notice how we labeled this `friends` mapping as `public`? This is a public blockchain, so you should assume everything is public.

*☢️ Warning: even if we set this mapping to* `*private*`*, that just means external contracts can’t read it,* ***everyone can still read private values* ***off-chain****.***

Create a function that lets us call `updateFriend()` to `true` or `false`:

```
function updateFriend(address friendAddress, bool isFriend) public {
  require(isOwner(msg.sender),"NOT THE OWNER!");
  friends[friendAddress] = isFriend;
  console.log(friendAddress,"friend bool set to",isFriend);
}
```

*💡 Notice how we are reusing a specific line of code that requires the* `*msg.sender*` *is the* `*owner*`*? You could clean this up using a* [*modifier*](https://solidity.readthedocs.io/en/v0.6.7/structure-of-a-contract.html?highlight=modifiers#function-modifiers)*. Then, every time you need a function that can only be run by the owner you can add an* `*onlyOwner*``*modifier*` *to the function instead of this line. (totally optional)*

Now let’s deploy this and move back to our frontend:

```
yarn run deploy
```

* * *


*🤔 OH! We can make small incremental changes to both the frontend and smart contract in parallel. This tight dev loops lets us iterate quickly and test new ideas or mechanics.*


* * *


We will want to add a form to the `display` in `SmartContractWallet.js` in the `packages/react-app/src` directory. First, let’s add a state variable:

```
const [ friendAddress, setFriendAddress ] = useState("")
```

Then, let’s create a function that *creates a function* that calls `updateFriend()`:

```
const updateFriend = (isFriend)=>{
  return ()=>{
    tx(writeContracts['SmartContractWallet'].updateFriend(friendAddress, isFriend))
    setFriendAddress("")
  }
}
```

💡 Notice the structure of the code for calling a function on our contract: `*contract*`.`*functionname*`( `*args*` ) all wrapped in a `tx()` so we can track transaction progress. You can also `await` this `tx()` function to get the resulting hash, status, etc.

*🤖 When you write* `*address public owner*` *it will automatically create a “getter” function for this* `*owner*` *variable and we can get that really easily with the* `*useContractReader()*` *hook.*

Next, let’s create an `ownerDisplay` section that only displays for the `owner`. This will display an `AddressInput` with two buttons for `updateFriend(false)` and `updateFriend(true)`.

```
let ownerDisplay = []if(props.address==owner){
  ownerDisplay.push(
    
      Friend:
      
        {setFriendAddress(address)}}
        />
      
      
        } />
        } />
      
    
  )
}
```

Finally, add the `{ownerDisplay}` to the `display` under the owner row:

![](https://img.learnblockchain.cn/2020/07/28/15959202903031.jpg)

Try clicking around after your app 🔥 hot reloads. (You can navigate to [http://localhost:3000](http://localhost:3000/) in a new browser or in incognito mode to get get a new session account to copy a new address.)

![1_AttSC5qoeUxbL-gqP49nxw](https://img.learnblockchain.cn/2020/07/29/1_AttSC5qoeUxbL-gqP49nxw.gif)
 
It’s kind of hard to tell what’s going on without being able to iterate through the addresses. It is hard to list all our friends and what their status is in the frontend.

This is a job for *events*.


* * *


# 🛎 Events

Events are almost like a form of storage. They are relatively cheap to emit from a smart contract during execution, but the key is that smart contracts can’t *read* events.

Let’s head back over to the smart contract `SmartContractWallet.sol`.

Create an event above or below the `updateFriend()` function:

```
event UpdateFriend(address sender, address friend, bool isFriend);
```

Then, inside the `updateFriend()` function, add this `emit`:

```
emit UpdateFriend(msg.sender,friendAddress,isFriend);
```

Compile and deploy the changes:

```
yarn run deploy
```

Then, in our frontend, we can add an event listener hook. Add this code with the rest of our hooks in `SmartContractWallet.js`:

```
const friendUpdates = useEventListener(readContracts,contractName,"UpdateFriend",props.localProvider,1);
```

*(This ^line is already added for you because it is used for the TODO list 😅.)*

In our render, right after the , add a  display:

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

🎉 Now when it reloads we should be able to add and remove friends!
![1_odLcQnTvb5-J15GkB0LJ_A](https://img.learnblockchain.cn/2020/07/29/1_odLcQnTvb5-J15GkB0LJ_A.gif)


* * *

# 👨‍👩‍👧‍👦 Social Recovery

Now that we have `friends` set in our contract, let’s create a “recovery mode” that they can trigger.

Let’s imagine that somehow we lost the [private key](https://www.youtube.com/watch?v=9LtBDy67Tho&list=PLJz1HruEnenCXH7KW7wBCEBnBLOVkiqIi&index=4&t=0s) for the `owner` and now we are locked out of our smart contract wallet. We need to have one of our friends trigger some kind of recovery.

We also need to be sure that if a friend accidentally (or maliciously 😏) triggers the recovery and we still have access to the `owner` account we can cancel the recovery within some `timeDelay` in seconds.

First, let’s setup a few variables in `SmartContractWallet.sol`:

```
uint public timeToRecover = 0;
uint constant public timeDelay = 120; //seconds
address public recoveryAddress;
```

Then give the owner the ability to set the `recoveryAddress`:

```
function setRecoveryAddress(address _recoveryAddress) public {
  require(isOwner(msg.sender),"NOT THE OWNER!");
  console.log(msg.sender,"set the recoveryAddress to",recoveryAddress);
  recoveryAddress = _recoveryAddress;
}
```
* * *


*☢️ There is a lot of copy and pasting of code in this tutorial. Be sure to take a second to slow down and read it to understand what is going on. 🧐*

*💬 If you are ever stuck and frustrated, hit me with a* [*Twitter DM*](https://twitter.com/austingriffith) *and we’ll see if we can figure it out together!* [*Github issues*](https://github.com/austintgriffith/scaffold-eth/issues) *work great for feedback too!*

* * *


Let’s add a function for our friends to call to help us recover our funds:

```
function friendRecover() public {
  require(friends[msg.sender],"NOT A FRIEND");
  timeToRecover = block.timestamp + timeDelay;
  console.log(msg.sender,"triggered recovery",timeToRecover,recoveryAddress);
}
```

💡We use `block.timestamp`, you can read more about [special variables here](https://solidity.readthedocs.io/en/v0.6.7/units-and-global-variables.html?highlight=units#block-and-transaction-properties).

If `friendRecover()` is accidentally triggered, we want our owner to be able to cancel the recovery:

```
function cancelRecover() public {
  require(isOwner(msg.sender),"NOT THE OWNER");
  timeToRecover = 0;
  console.log(msg.sender,"canceled recovery");
}
```

Finally, if we are in recovery mode and enough time has passed, 🤖 anyone can destroy our contract and send all its ether to the `recoveryAddress`:

```
function recover() public {
  require(timeToRecover>0 && timeToRecover<block.timestamp,"NOT EXPIRED");
  console.log(msg.sender,"triggered recover");
  selfdestruct(payable(recoveryAddress));
}
```

💡 `[selfdestruct()](https://solidity.readthedocs.io/en/v0.6.8/cheatsheet.html?highlight=selfdestruct#global-variables)` will remove our smart contract from the blockchain and return all funds to the `recoveryAddress`.

*☢️ Warning, a smart contract with an* `*owner*` *that can call* `*selfdestruct()*` *at any time really isn’t “decentralized”. Developers should be very mindful about building mechanisms that no individual or organization can control or censor.*

Let’s compile, deploy, and move back over to our frontend:

```
yarn run deploy
```

In our `SmartContractWallet.js`, with our other hooks, we will want to track the `recoveryAddress`:

```
const [ recoveryAddress, setRecoveryAddress ] = useState("")
```

Here is the code for a form that lets the owner set the `recoveryAddress` :

```
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

Then we want to track the `currentRecoveryAddress` from our contract with:

```
const currentRecoveryAddress = useContractReader(readContracts,contractName,"recoveryAddress",1777);
```

Let’s also track the `timeToRecover` and the `localTimestamp`:

```
const timeToRecover = useContractReader(readContracts,contractName,"timeToRecover",1777);
const localTimestamp = useTimestamp(props.localProvider)
```

And display the recover address using `<Address />` right after the recovery button. Plus, we’ll add a button for the owner to `cancelRecover()`. Put this code right after the `setRecoveryAddress()` button:

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

💡 We are using [ENS](https://ens.domains/) here to translate a name to an address and back. This works similar to traditional DNS where you can register a name.

Now in our hooks, let’s track if the user `isFriend`:

```
const isFriend = useContractReader(readContracts,contractName,"friends",[props.address],1777);
```

If they are a friend, let’s show them a button to call `friendRecover()` and then eventually `recover()` once the `localTimestamp` is *after* `timeToRecover`. Add this big "else if” at the end of the owner check `if(props.address==owner){`:

```
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

🚀 Try it all out, get a feel for the app. Tweak the contracts, tweak the frontend. It’s *yours* now! 😬

💡 You can create as many accounts to play around with as you need with different browsers and incognito modes. Then use the faucet to give them some ether.

*☢️ Warning, we are getting the timestamp from our local chain and blocks aren’t mined at a regular interval like on a real chain. Therefore, we will have to send some transactions here and there to get the timestamp to update. ⏰*

![1_1Mqo-87iqGEswsyaT4jI2g](https://img.learnblockchain.cn/2020/07/29/1_1Mqo-87iqGEswsyaT4jI2g.gif)

Working demo where the account on the left owns the wallet, makes account on the right a friend, and then eventually the friend recovers ether

* * *

# 🎉 Congratulations!

We’ve built a decentralized application around a smart contract wallet with a safety limit and social recovery!!!

You should have enough context to clone 🏗 [scaffold-eth](https://github.com/austintgriffith/scaffold-eth) and maybe even build the greatest unstoppable app yet!!!

Imaging if this wallet had some sort of 🤖 autonomous market layer where anyone in the world could buy and sell assets with dynamic pricing?

What if we minted 🧩 collectibles and sold them on a curve?!

What if we created an 🧙‍♂️instant wallet for sending and receiving funds quickly?!

What if we built a ⛽️ gas-less app for smooth user onboarding!?

What if we created a 🕹 game with commit/reveal random numbers?!

What if we created a local 🔮 prediction market that just our friends and friends’ friends could participate in?!

What if we deployed a 👨‍💼$me token and then built an application that lets holders stake toward you building your next application?!

What if we could stream those 👨‍💼$me tokens for help sessions about building cool things on 🏗 [scaffold-eth](https://github.com/austintgriffith/scaffold-eth)!?!


* * *



> 🤩 Oh the possibilities!!! 📟 📠 🧭 🕰 📡 💎 ⚖️ 🔮 🚀



* * *



📓 If you would like to learn more about Solidity I recommend playing [Ethernaut](https://ethernaut.openzeppelin.com/), [Crypto Zombies](https://cryptozombies.io/), and then maybe even [RTFM](https://solidity.readthedocs.io/en/v0.6.8/). 🤣

Head over to [https://ethereum.org/developers](https://ethereum.org/developers/) for more resources.

*💬 Feel free to hit me with a* [*Twitter DM*](https://twitter.com/austingriffith) *or* [*in the repo*](https://github.com/austintgriffith/scaffold-eth)*! Thanks!!!*

原文链接：https://medium.com/@austin_48503/programming-decentralized-money-300bacec3a4f