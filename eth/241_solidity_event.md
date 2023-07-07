> * 原文链接： https://mirror.xyz/spacesailor.eth/LEe2yoLoqy97BWHyO6J65XhnG8t33Nmvz_Vsa3ve7rY
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)  校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)



# 关于Solidity 事件，我希望早一点了解到这些



以太坊是一个世界计算机，网络中的每个节点都在运行它的代码实现，而以太坊区块链是这些节点对世界计算机最新状态的集体约定。

以太坊计算机的一个关键组成部分是，*确定的状态更新*，对于最新状态的共识来说是必要的。以太坊的目标是去中心化，网络中的每个节点必须能够处理新区块中的交易，并拥有与网络中所有其他节点相同的结果最新状态。能够实现这一点的原因之一，是由于以太坊计算机（即以太坊虚拟机）是沙盒化的。这种沙盒化意味着EVM的能力是有限的，因此，给定一组输入，只能有一个输出。这就是每个执行最新交易的节点总是能到达区块链的同样的最新状态。

虽然确定性的状态更新是实现共识的理想选择，但在梳理Web2和以太坊时，有一些权衡因素会带来独特的挑战。其中一个限制是以太坊智能合约如何与存在于所有以太坊沙盒虚拟机之外的世界沟通。造成这种限制的部分原因是，从EVM到外部世界的调用是不确定的。想象一下，你有一个智能合约，向一个网络API发出API请求，以获得一对资产的最新价格。当节点A处理一个触发这个API调用的交易时，它收到一个`42`的响应，并相应地更新它的最新状态。然后当节点B处理同样的交易时，价格发生了变化，所以它收到的响应是`40`，并相应地更新了它的最新状态。然后节点C发出请求，并收到一个`404`的HTTP响应，因为API离线了一秒钟，那么节点C如何更新它的状态呢？无论如何，你可以看到一个更大的问题，即从EVM到它的沙盒之外的世界的调用可能不总是产生相同的响应。如果允许这样做，那么当网络中的每个节点都可能对最新状态有不同的看法时，以太坊世界计算机就无法对最新状态达成共识。

为了帮助解决Web2和以太坊之间的通信问题，EVM允许生成**日志**。在Solidity中，我们通过触发**事件**来利用这些日志。



## 以太坊的日志

在底层，在Solidity中触发事件会指示EVM执行以下操作码（之一）：`LOG0`、`LOG1`、`LOG2`、`LOG3`或`LOG4`（你可以查看它们的细节[这里](https://www.evm.codes/#a0?fork=shanghai)）。当一个事件被触发时，`LOG`操作码产生一个日志条目，包括触发事件的合约地址，一个主题数组和一些数据。主题来自事件的`indexed`索引参数，每个`LOG`操作码后有一个数字，表示它可以处理的主题数量可以0个 到4个）。日志的 `data`属性来自非索引的事件参数，能记录多少数据的限制是存储数据的**Gas成本**（目前每个字节的数据有8个Gas + 下面图片中显示的一些其他值）、和**区块的Gas限制**（即使你愿意支付大量的Gas来存储你的数据，你的交易也很有可能超过当前区块允许使用的Gas总量--特别是当你考虑到你的交易可能不是唯一使用该区块 Gas 配额的交易）。

![LOG EVM操作码文档](https://img.learnblockchain.cn/pics/20230705150339.png)



> LOG EVM 操作码文档

当`LOG`指令被执行时，生成的日志条目被存储在EVM内的交易上下文中，这是一个EVM处理交易时的临时空间。这个交易上下文保存着当前正在处理的交易的信息，包括对状态的任何改变，以及产生的日志条目。一旦交易被 EVM 处理并准备好被纳入区块链，就会创建一个交易收据。该收据是交易执行的摘要，包括状态、使用的Gas和产生的日志。

下面是一个交易收据的例子，为了简洁起见，一些数据被省略了，但你可以在[这里](https://etherscan.io/tx/0x81b886145c37afe0e42353e81f8f2896dd69fb86531a6d2ee9a13ced4d9321fb)查看整个收据：

```json
{
  status: "0x1",
  gasUsed: "0x879e",
  logs: [
    {
      address: "0x6b175474e89094c44da98b954eedeac495271d0f",
      blockHash:
        "0x4230f9e241e1f0f2d466bbe7450350bfe1abceab2dac74c3c1c52443b2e5f307",
      blockNumber: "0x10b4c1d",
      data: "0x0000000000000000000000000000000000000000000000068155a43676e00000",
      logIndex: "0xd1",
      removed: false,
      topics: [
        "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
        "0x000000000000000000000000b0b734cfc8c50f2742449b3946b2f0ed03e96d77",
        "0x000000000000000000000000ff07e558075bac7b225a3fb8dd5f296804464cc1"
      ],
      transactionHash:
        "0x81b886145c37afe0e42353e81f8f2896dd69fb86531a6d2ee9a13ced4d9321fb",
      transactionIndex: "0x52"
    }
  ]
}
```

从这个收据中，我们可以看出这个交易发出了一个事件（因为`logs.length == 1`），有3个主题（因为`logs[0].topic.length == 3`），因此使用了操作码`LOG3`。

## 以太坊日志主题

如上一节所述，主题来自于事件的`indexed`参数，每个`LOG`操作码跟着一个相应的数字，表示它可以包含的主题数量（可以0个 到4个）。主题提供了一种有效的方法，可以方便的从一个区块中的所有交易中过滤出感兴趣的事件。

但主题是如何产生的呢？

每个主题有一个**最大长度为32字节的数据**，每个主题都被编码为这个最大长度，即使数据不占用32字节。正如你在上面的交易收据中看到的，我们有一个主题是

```json
0x000000000000000000000000b0b734cfc8c50f2742449b3946b2f0ed03e96d77
```

其中实际数据`b0b734cfc8c50f2742449b3946b2f0ed03e96d77`只有`20`字节长，但被填充了`0`以达到`32`字节的长度。

Solidity事件确实支持其值可能超过这个`32`字节的最大长度的数据类型，例如动态大小的数组和字符串，在这些情况下，值的`keccak256`散列被用作主题，而不是值本身。

### 命名事件

上面的交易收据是与Dai Stablecoin合约的`transfer`功能交互的交易结果。我们知道它，是因为交易指定的`to`地址是以太坊主网Etherscan上的一个经过验证的合约：

![验证的Dai稳定币地址](https://img.learnblockchain.cn/pics/20230705150413.png)



> 经过验证的Dai稳定币地址

如果我们看一下这个合约的[验证的合约代码](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f#code)，我们可以看到，在第95行，声明了一个名称为`Transfer`的事件：

```js
event Transfer(address indexed src, address indexed dst, uint wad);
```

我们还可以看到，这个 `Transfer `事件有两个 `indexed`参数，`src `和 `dst`，以及一个非索引参数，`wad`。回到我们的交易收据上的`topics`数组：

```json
topics: [
	"0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
	"0x000000000000000000000000b0b734cfc8c50f2742449b3946b2f0ed03e96d77",
	"0x000000000000000000000000ff07e558075bac7b225a3fb8dd5f296804464cc1"
],
```



你可以看到有`3`个主题，而我们的事件只定义了两个`indexed`参数，那么第三个主题是什么？在Solidity中，当事件被命名为 `Transfer `这样的名字时，Solidity 会使用**事件签名**，使用keccak256散列算法对其进行散列，并将其作为第一个元素附加到 `topics `数组中。所以在我们的`topics`数组中，`0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`是我们`Transfer`方法的事件签名的散列。为了进一步证明这个想法，让我们跟随 Solidity 的过程来生成我们的事件签名的哈希值。

首先，什么是事件签名？

#### 事件签名

在 Solidity 中，事件签名是一个事件的唯一标识符，由事件的名称和它的参数类型生成。对于我们的 `Transfer`事件，Dai Stablecoin合约中经过验证的合约代码的第95行：

```js
event Transfer(address indexed src, address indexed dst, uint wad);
```

现在，Solidity 并不只是直接采取上述内容，对其进行哈希处理，然后得到哈希的事件签名。相反，Solidity首先将事件签名中的关键字和参数名称剥离。对于我们的 `Transfer` 事件，这些剥离的值将是：

- `event`
- `indexed`
- `src `
- `dst`
- `wad`
- 任何空格
- `;`

这样，我们剩下的就是：

*请记住，虽然经过验证的合约代码使用* `uint`作为`value`参数的数据类型，但`uint`是`uint256`的别名，Solidity在生成散列事件签名时将使用完整的类型名称，因此我们在下面使用`uint256`。

```js
Transfer(address,address,uint256)
```

现在 Solidity 对剥离的事件签名进行散列，以生成我们的预期主题值。使用这个[在线keccak256哈希函数](https://emn178.github.io/online-tools/keccak_256.html)，你可以看到散列剥离的事件签名确实给了预期的值，我们在日志的`topics`数组中看到了第一个元素。

![转移事件签名的Keccak256哈希函数](https://img.learnblockchain.cn/pics/20230705154046.png)



>  转移事件签名的Keccak256哈希值



### 剩余的事件主题

那么，我们已经弄清楚了日志的`topics`数组中的第一个元素，接下来的两个元素呢？我们知道`topics`数组包含了`indexed`事件参数，所以其他的主题是`src`和`dst`，但是这些值是怎么来的呢？当我们查看Etherscan上的[交易收据](https://etherscan.io/tx/0x81b886145c37afe0e42353e81f8f2896dd69fb86531a6d2ee9a13ced4d9321fb)，并点击**+点击显示更多**按钮，我们可以看到该交易的**输入**数据：

![Dai Stablecoin Transfer Input Data](https://img.learnblockchain.cn/pics/20230705154126.png)



> DAI稳定币转账输入数据

点击**解码输入数据**按钮，我们可以得到这个输入数据的一个更容易理解的版本：

![解码的傣族稳定币转移输入数据](https://img.learnblockchain.cn/pics/20230705155751.png)



>  解码后的Dai稳定币转账输入数据

这是向以太坊提交交易时用户提供的数据。正如你所看到的，这个交易正在调用Dai Stablecoin合约上的`transfer`函数，其数据为：`0xfF07E558075bAc7b225A3FB8dD5f296804464cc1`作为`dst`参数，`120000000000000000`作为`wad`参数。

查看Etherscan上经过验证的合约代码，我们看到`transfer`功能存在于`122 - 124`行：

`transfer`会调用另一个函数`transferFrom`（来自第`125-137`行），所以我也列出了这个函数，以便我们有额外的背景信息：

```js
function transfer(address dst, uint wad) external returns (bool) {
	return transferFrom(msg.sender, dst, wad);
}

function transferFrom(address src, address dst, uint wad)
        public returns (bool)
{
	require(balanceOf[src] >= wad, "Dai/insufficient-balance");
	if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
		require(allowance[src][msg.sender] >= wad, "Dai/insufficient-allowance");
		allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
	}
	balanceOf[src] = sub(balanceOf[src], wad);
	balanceOf[dst] = add(balanceOf[dst], wad);
	emit Transfer(src, dst, wad); // <--- Here is where the `Transfer` event is being emitted
	return true;
}
```

在第`135`行，我们看到：

```js
emit Transfer(src, dst, wad);
```

这是交易收据中看到的事件的确切代码。所以当交易的发送方调用`transfer`函数时，它调用`transferFrom`函数，将`msg.sender`作为`src`参数（这是交易发送方的地址），并提供`dst`和`wad`参数。因此，当`Transfer`事件最终在第`135`行被触发（即被记录）时，这些是被记录到区块链上的值，并在我们的事件日志中显示在交易收据中。

为了清楚起见，下面的代码示例包括传递给函数的参数和`Transfer`事件：

```js
//                This is dst                                 wad
function transfer(0xfF07E558075bAc7b225A3FB8dD5f296804464cc1, 120000000000000000000) external returns (bool) {
	//                  This is msg.sender                          dst                                         wad
	return transferFrom(0xB0B734CFC8c50F2742449B3946B2f0eD03E96D77, 0xfF07E558075bAc7b225A3FB8dD5f296804464cc1, 120000000000000000000);
}

//                    This is src                                 dst                                         wad
function transferFrom(0xB0B734CFC8c50F2742449B3946B2f0eD03E96D77, 0xfF07E558075bAc7b225A3FB8dD5f296804464cc1, 120000000000000000000)
        public returns (bool)
{
	// Irrelevant implementation code...
	//            This is src                                 dst                                         wad
	emit Transfer(0xB0B734CFC8c50F2742449B3946B2f0eD03E96D77, 0xfF07E558075bAc7b225A3FB8dD5f296804464cc1, 120000000000000000000);
	return true;
}
```

因此，当看我们的`topics`数组时，我们的交易收据中的日志：

```json
topics: [
	"0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", // 事件签名的 keccak256 值
	"0x000000000000000000000000b0b734cfc8c50f2742449b3946b2f0ed03e96d77", // src 参数
	"0x000000000000000000000000ff07e558075bac7b225a3fb8dd5f296804464cc1" // dst 参数
],
```

但是为什么`src`和`dst`的值看起来与我们在触发事件时传递的值不同呢？好吧，如果你记得**以太坊日志主题**部分的开头的描述：

> 每个主题都有一个**最大长度为32字节的数据**，每个主题都被编码为这个最大长度，即使数据不占用32字节。

地址只有`20`字节长，所以这些值被填充了`0`，以便它们变成`32`字节长（这是每个事件主题必须使用的长度）。

#### 那缺少的`wad`参数呢？



也许你注意到，当我们在第135行发出 `Transfer `事件时，我们传递了 `src`、`dst `和 `wad `事件参数的值，但只有 `src `和 `dst `显示在日志的 `topics `数组中 - `wad `参数发生了什么？看一下`Transfer`的事件签名：

```js
event Transfer(address indexed src, address indexed dst, uint wad);
```

我们可以看到 `wad `参数没有被 `indexed`。在 Solidity 中，所有未被索引的事件参数都是 ABI 编码的，并存储在事件的`data`属性中。看一下交易收据，我们可以看到`wad`的值被填充到`32`字节，并保存在`logs[0].data`下：

传递给 `Transfer`事件的数据是`12000000000000000`，但是Solidity会把整数转换成十六进制以节省空间。`12000000000000000`转换为十六进制是：68155a43676e00000

```json
{
  status: "0x1",
  gasUsed: "0x879e",
  logs: [
    {
      address: "0x6b175474e89094c44da98b954eedeac495271d0f",
      blockHash:
        "0x4230f9e241e1f0f2d466bbe7450350bfe1abceab2dac74c3c1c52443b2e5f307",
      blockNumber: "0x10b4c1d",
      // This is wad converted to hexidecimal and padded to be 32 bytes
      data: "0x0000000000000000000000000000000000000000000000068155a43676e00000",
      logIndex: "0xd1",
      removed: false,
      topics: [
        "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
        "0x000000000000000000000000b0b734cfc8c50f2742449b3946b2f0ed03e96d77",
        "0x000000000000000000000000ff07e558075bac7b225a3fb8dd5f296804464cc1"
      ],
      transactionHash:
        "0x81b886145c37afe0e42353e81f8f2896dd69fb86531a6d2ee9a13ced4d9321fb",
      transactionIndex: "0x52"
    }
  ]
}
```

### 匿名事件

因此，如果一个命名的事件的第一个主题是哈希的事件签名，怎么能有使用`LOG0`的事件呢，而这个事件没有记录的主题？让我们进入匿名事件!

当在Solidity中声明一个事件时，你可以选择使用`anonymous`关键字，像这样：

```solidity
event RegularEvent();
event AnonymousEvent() anonymous;
event AnonymousEventWithParameter(address indexed sender) anonymous;
```

当一个  `anonymous` 事件被触发时，散列的事件签名不会作为一个主题被包含在事件的 `topics` 数组中。

下面是一个例子，如果 `RegularEvent` 被触发，交易收据的事件日志：

```json
{
  logs: [
    {
      data: "0x0",
      topics: [
	    //  RegularEvent() 的  keccak256 hash  
        "0xef6f955afa69850e8e58a857ef80f5ab7e81117d116a10f94b8c57160c4631d9"
      ]
    }
  ]
}
```

如果 `AnonymousEvent` 被触发：

```json
{
  logs: [
    {
      data: "0x0",
      // There are no topics for this event log because we have no `indexed` parameters,
      // 匿名事件，没有事件签名被包含
      topics: []
    }
  ]
}
```

如果触发了`AnonymousEventWithParameter`：

```json
{
  logs: [
    {
      data: "0x0",
      topics: [
	    // This is an address padded to 32 bytes i.e. the sender event parameter
		"0x000000000000000000000000b0b734cfc8c50f2742449b3946b2f0ed03e96d77"
      ]
    }
  ]
}
```

### 匿名事件使用案例

#### 额外的自定义索引参数

由于EVM目前只支持操作码 `LOG0-4`，一个事件日志最多只能有四个 `主题`。对于命名的事件，第一个主题被保留给散列的事件签名，只留下3 个空间给自定义`indexed`参数。如果一个事件被声明为 `匿名`，那么哈希签名就不会被记录，从而为一个额外的 `indexed`参数留出空间。这在需要索引超过`3`个参数的特定情况下是很有用的。

```solidity
event AnonymousEventWithFourParameters(uint256 indexed one, uint256 indexed two, uint256 indexed three, uint256 indexed four) anonymous;
```

```js
{
  logs: [
    {
      data: "0x0",
      topics: [
		"0x0000000000000000000000000000000000000000000000000000000000000001",
		"0x0000000000000000000000000000000000000000000000000000000000000002",
		"0x0000000000000000000000000000000000000000000000000000000000000003",
		"0x0000000000000000000000000000000000000000000000000000000000000004"
      ]
    }
  ]
}
```

#### 节省 Gas

因为事件签名不存储在日志中，你可以减少事件的Gas成本。例如，如果你的合约事件不多，可以很容易地通过事件主题的数量来区分，像这样：

```js
event HasOneTopic(uint256 indexed one) anonymous;
event HasTwoTopics(uint256 indexed one, uint256 indexed two) anonymous;
event HasThreeTopics(uint256 indexed one, uint256 indexed two, uint256 indexed three) anonymous;
{
  logs: [
    // This is an example event log for HasOneTopic
    {
      data: "0x0",
      topics: [
		"0x0000000000000000000000000000000000000000000000000000000000000001"
      ]
    },
    // This is an example event log for HasTwoTopics
    {
      data: "0x0",
      topics: [
		"0x0000000000000000000000000000000000000000000000000000000000000001",
		"0x0000000000000000000000000000000000000000000000000000000000000002"
      ]
    },
    // This is an example event log for HasThreeTopics
    {
      data: "0x0",
      topics: [
		"0x0000000000000000000000000000000000000000000000000000000000000001",
		"0x0000000000000000000000000000000000000000000000000000000000000002",
		"0x0000000000000000000000000000000000000000000000000000000000000003"
      ]
    }
  ]
}
```

可以节省一些，尽管是非常少的Gas，因为我们可以依靠`logs[].topics.length`来辨别出是哪一个匿名事件被触发出来。

#### 模糊化

匿名事件可以使查验区块链的人更难确定发出的是哪种事件，因为事件签名不包括在日志中。这可以被看作是混淆合约行为的一种方式，但是应该注意的是，通常认为智能合约的操作是透明的，这是最佳做法。

例如，以这两个事件为例：

```solidity
event SuperSecret(uint256 indexed passcode) anonyomous;
event Decoy(uint256 indexed decoy) anonymous;
```

如果一个合约发出几个 `Decoy `事件和一个 `SuperSecret `事件，那么在查验更新秘密的交易日志时，就很难分辨出实际的秘密是什么。在下面的日志中，你能分辨出哪个是`SuperSecret`事件，而不是`Decoy`事件？

```json
{
  logs: [
    {
      data: "0x0",
      topics: [
		"0x0000000000000000000000448960cc9a23414c19031475fc258eba8000000000"
      ]
    },
    {
      data: "0x0",
      topics: [
		"0x000000000000000000000000def171fe48cf0115b1d80b88dc8eab59176fee57"
      ]
    },
    {
      data: "0x0",
      topics: [
		"0x00000000000000000000000089b78cfa322f6c5de0abceecab66aee45393cc5a"
      ]
    },
    {
      data: "0x0",
      topics: [
		"0x000000000000000000000000a950524441892a31ebddf91d3ceefa04bf454466"
      ]
    },
    {
      data: "0x0",
      topics: [
		"0x0000000000000000000000009759a6ac90977b93b58547b4a71c78317f391a28"
      ]
    }
  ]
}
```

并不是说这是一个具体的例子，但它说明了匿名事件的一个潜在使用场景。

### 注意事项

#### 筛选交易的困难

匿名事件的最大缺陷可能是它使过滤使用它们的交易变得困难。正如上面**混淆**的例子中所讨论的，你如何能够过滤那些只更新秘密并发出`SuperSecret`事件的交易呢？如果没有对合约的一些额外的了解，你是无法做到的，因为仅仅看一下交易收据是不明显的。然而，你可以绕过这个限制，就像在**Gas节省**部分所讨论的那样，使用不同数量的事件主题来辨别不同的事件。

#### 事件冒充

在**混淆**部分也描述了，如果没有事件签名的哈希值作为事件日志的唯一标识符，具有相同事件参数的  `anonymous`  事件在被记录时结构是相同的。因此，它可能看起来像一个`SuperSecret`事件，但实际上，所有的事件都可能是`Decoy`事件，而你却无从得知。如果一个特定的  `anonymous`   事件被用来执行一些链外操作，而一个具有相同索引事件参数的假事件被触发出来，这可能是危险的。

### `indexed` 字符串发生了什么？

当我们在讨论事件的 `topics`时，我想快速指出一个问题，如果你试图在你的事件中使用 `string indexed`。在某些时候，你会想发出一个带有一些`string`值的事件，你可能会想使用`indexed`，因为它是一个重要的字符串，你的dApp可以访问。这种情况看起来类似于：

```js
event WhatHappenedToMyString(string indexed importantString);

function emitMyString() public {
	emit WhatHappenedToMyString("Super important string");
}
```



现在，当我们调用这个`emitMyString`函数时，你可能**希望**看到类似的东西：

```json
{
  logs: [
    {
      data: "0x0",
      topics: [
		"0x9a765dc5bb2a8596b4e4c72e864f3d2be32ff913a128d6b1343df14329065f89",
     "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000016537570657220696d706f7274616e7420737472696e6700000000000000000000"
      ]
    }
  ]
}
```

好吧......也许你没料到，因为那不是我们的字符串，`Super important string`。

#### 关于ABI编码的旁白

那么，如果我们把 "Super important string"作为我们的 "字符串"值触发出去，为什么我们会看到这个奇怪的数字，而不是  "Super important string"？

```json
"0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000016537570657220696d706f7274616e7420737472696e6700000000000000000000"
```

这是因为一个叫做**[ABI编码](https://learnblockchain.cn/article/3870)**的东西，我可以写一篇关于这个话题的文章，但现在我将保持相对简短的解释。

那么什么是ABI编码？首先，让我们听听ChatGPT的解释：

> 以太坊应用二进制接口（ABI）是一个标准，用于数据在智能合约的高级代码和以太坊虚拟机（EVM）的低级机器语言之间进行编码和解码。它规定了将高层数据类型（如字符串和数组）转换为EVM可以处理的标准化格式的方法。这包括指定如何将函数调用，包括其名称和参数，编码为EVM的字节数。ABI在与智能合约的交互中起着至关重要的作用，允许用户和外部程序理解合约的结构、函数和变量，并与之进行相应的交互。

所以基本上，ABI编码是我们如何将人类可读的数据转换成EVM可以理解的标准化机器可读数据。为了进一步说明这一点，让我们分解一下如何从 "Super important string" 到ABI编码表示的过程。

首先，我们需要了解 "Super important string" 已经使用了一种叫做[UTF-8](https://blog.hubspot.com/website/what-is-utf-8)的数据编码形式。我链接了一篇关于 UTF8 是什么以及我们为什么使用它的文章，但让ChatGPT来总结一下：

> UTF-8标准将每个字符表示为一到四个字节的唯一序列。ASCII字符（包括所有字母数字字符和一些符号）是UTF-8的一个子集，ASCII字符为一个字节。

因此，我们将人类可读字符串转换为机器可读数据的第一步是将我们的UTF-8字符串转换成它的字节表示。因为我们使用的是UTF-8的ASCII子集，我们知道每个字符都是用`1`个字节表示的，但是我们如何将UTF-8转换成字节呢？

那么，以太坊选择利用的一个直接的解决方案是使用十六进制来表示每个字节。你可以查看[这里](https://www.rapidtables.com/code/text/ascii-table.html)，一个将UTF-8字符转换为十六进制字节的表格。使用这个表格，我们可以看到，将我们的字符串转换为十六进制的字节将看起来像：

```json
'S'         = '53'
'u'         = '75'
'p'         = '70'
'e'         = '65'
'r'         = '72'
' ' (space) = '20'
'i'         = '69'
'm'         = '6D'
'p'         = '70'
'o'         = '6F'
'r'         = '72'
't'         = '74'
'a'         = '61'
'n'         = '6E'
't'         = '74'
' ' (space) = '20'
's'         = '73'
't'         = '74'
'r'         = '72'
'i'         = '69'
'n'         = '6E'
'g'         = '67'
```

将上述内容拼成一行，我们可以得到：`537570657220696d706f7274616e7420737472696e67`.敏锐的人将注意到，这种十六进制字节的组合实际上存在于我们正在建立的ABI编码数据中：

![编码的字符串事件数据](https://img.learnblockchain.cn/pics/20230705160418.svg)



> 编码字符串事件数据

那么，如果我们找到了ABI编码的字符串，其余的数据是干什么用的呢？EVM是为处理`32`字节的数据块而建立的，也称为**字**。如果你回顾一下**以太坊日志主题**部分的开头，每个事件主题也是`32`字节的字。因此，让我们采取完整的ABI编码的字符串，并把它分成这些`32`字节的字：

```js
0x0000000000000000000000000000000000000000000000000000000000000020 // 第一个字,
0000000000000000000000000000000000000000000000000000000000000016 // second,
537570657220696d706f7274616e7420737472696e6700000000000000000000 // and third
```

除去数据开头的`0x`（这只是一个前缀，表示下面的数据将被解释为十六进制），我们有3个EVM字：

1.`0000000000000000000000000000000000000000000000000000000000000020`: 从这第一个字中除去所有的 `0`，我们得到 `20`。将其从十六进制转换为整数，我们得到`32`。这第一个字是告诉EVM，从这个数据块的从 `32`字节数据开始。所以从前缀`0x`后的`0`开始，我们数`32`字节（64个`十六进制`字符，因为`1`字节由`2`十六进制字符表示），我们得到...
2.`0000000000000000000000000000000000000000000000000000000000000016`:从这第二个字中除去所有的 `0`，我们得到 `16`。转换为整数，我们得到`22`。这第二个字是告诉EVM存在一些`22`字节长的数据。所以EVM加载下一个字...
3.`537570657220696d706f7274616e7420737472696e6700000000000000000000`:你可能已经认识到，这是我们的字符串，"Super important string"，被编码为它的十六进制格式的UTF-8字符。我们的数据后面剩下的`0`是确保我们的EVM字达到预期的`32`字节长度（因为我们的字符串只有`22`字节长)



所以总结一下，我们的巨大的数据块是告诉EVM的：我们有一些数据*可能*不适合在一个`32`字节的EVM字中。这个数据从第 `32`字节开始，这个数据是`22`字节长，然后最后它给EVM的数据进行解析，使用我们给它的信息，所以它解析了22`字节`，得到我们的十六进制UTF-8字符串。

#### 为什么要用这么多数据来表示`22`字节的字符串？

你可能想知道为什么我们需要前两个EVM字来理解我们的十六进制编码的字符串。这是因为 `字符串 `可以有一个不确定的长度。其他的值，如`uint`和`int`可以放入`32`字节的EVM字中，因为这些值的最大长度是`32`字节（例如，`uint256`是`256`位长，`256`位是`32`字节（`8`位=`1`字节，所以`256`/`8`=`32`））。

虽然我们的字符串，"Super important string" ，适合于一个`32`字节的EVM字，我们可以很容易地想象一个很多`字符串`不是这样。以`supercalifragilisticexpialidocious`为例。这个字符串是`34`UTF-8字符长（即`34`字节长），它长到足以超过`32`字节的EVM字（`2`字节太长）。所以，`Supercalifragilisticexpialidocious` ABI 编码是：

```js
0x0000000000000000000000000000000000000000000000000000000000000020 // First word,
0000000000000000000000000000000000000000000000000000000000000022 // second,
737570657263616c6966726167696c697374696365787069616c69646f63696f // third,
7573000000000000000000000000000000000000000000000000000000000000 // fourth
```

如果没有前`2`个EVM字告诉我们`string`数据从哪里开始，以及它有多长，我们就只能是：

```js
737570657263616c6966726167696c697374696365787069616c69646f63696f
7573000000000000000000000000000000000000000000000000000000000000
```

如果这就是EVM的全部工作，它将假定每个`32`字节的字是独立的数据，这意味着我们的原始字将被视为两个独立的字：

1.`supercalifragilisticexpialidocio` (`737570657263616c6966726167696c697374696365787069616c69646f63696f`)
2.`us` (`7573000000000000000000000000000000000000000000000000000000000000`)

所以为了避免将我们的 `字符串 `分割成基于每32个字节的多个字，我们告诉EVM我们的 `字符串 `数据从哪里开始，以及它是多少个字节。在`supercalifragilisticexpialidocious`的例子中，第二个EVM字说它是`34`字节长（`0x22`=`34`），所以EVM解析下一个`34`字节作为我们的字符串数据（这是第三个字的整个`32`字节，和第四个EVM字的`2`字节）。

#### 对 "indexed" 字符串的实际处理情况

我们知道事件的 `topics `必须是32字节长，但是 `string `的长度可以超过32字节，那么当你发出一个带有 `indexed `字符串参数的事件时会发生什么呢？简单地说，我们使用字符串值的keccak256哈希值，并将其作为`topic`。这是可能的，因为keccak256哈希值总是`32`字节长，所以这个策略总是有效的，不管我们的字符串数据有多长。

回到我们的`indexed`字符串事件的例子：

```js
event WhatHappenedToMyString(string indexed importantString);

function emitMyString() public {
	emit WhatHappenedToMyString("Super important string");
}
```

当`emitMyString`被调用时，我们的事件日志实际上会看起来像：

```json
{
  logs: [
    {
      data: "0x0",
      topics: [
		"0x9a765dc5bb2a8596b4e4c72e864f3d2be32ff913a128d6b1343df14329065f89",
		"0x8415478cebd2e698dbda720fc2a07faf3d46dc907f1cc27ccd5cbc61609eea21"
      ]
    }
  ]
}
```

其中`8415478cebd2e698dbda720fc2a07faf3d46dc907f1cc27ccd5cbc61609eea21`是`Super important string`的哈希值：

![Keccak-256 Hash of String](https://img.learnblockchain.cn/pics/20230705155848.svg)



> Keccak-256字符串的哈希值

#### 使用 `indexed` 字符串的注意事项

虽然仍然可以使用原始`indexed`字符串数据的哈希值来过滤交易，但如果你需要在某个地方使用原始字符串数据，例如在你的dApp中显示它，那么只有哈希值就没有什么用了。

不过有一个方便的解决方法，通过不对字符串事件参数使用`indexed`，触发的字符串数据将被ABI编码，并在事件日志的`data`属性（`logs[].data`）下可用：

```js
event WhatHappenedToMyString(string importantString); // Notice that importantString is no longer indexed

function emitMyString() public {
	emit WhatHappenedToMyString("Super important string");
}
```

现在当`emitMyString`被调用时，我们的事件日志将看起来像：

```json
{
  logs: [
    {
      data: "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000016537570657220696d706f7274616e7420737472696e6700000000000000000000",
      topics: [
		"0x9a765dc5bb2a8596b4e4c72e864f3d2be32ff913a128d6b1343df14329065f89"
      ]
    }
  ]
}
```

其中`logs[0].data`就是我们在前面 **ABI 编码解释**中提到的`data`，`logs[0].topics[0]`仍然是我们的`WhatHappenedToMyString`事件签名的 keccak256 哈希值。

## 事件数据

实际上，我们已经在**[关于ABI编码的旁白](#关于ABI编码的旁白)**部分介绍了如何获得事件日志的`数据`。对于所有没有 `indexed` 的事件参数，它们的值被 ABI 编码并被设置为日志事件的 `data `属性。

让我们通过几个例子来巩固这个概念。

### 触发的事件无数据

```js
event NoEventData();

function emitEvent() public {
	emit NoEventData();
}
{
  logs: [
    {
      data: "0x",
      topics: [
        "0x40271e61fe9aea6d3aa373c6769bd7b87bcbdfe249455c028ebb26ab321a4eeb"
      ]
    }
  ]
}
```

因为我们在 `NoEventData `中没有触发任何未 `indexed`的数据，所以我们的事件日志的 `data `属性只是：`0x`（意味着没有数据）。主题，`0x40271e61fe9aea6d3aa373c6769bd7b87bcbdfe249455c028ebb26ab321a4eeb`，是事件签名（`keccak256(NoEventData())`的keccak256散列。

### 触发事件有值的类型数据

我们在 **关于ABI编码的旁白** 一节中没有明确介绍的是 Solidity 中 [**值类型** 和 **引用** 类型](https://decert.me/tutorial/solidity/solidity-basic/types)之间的区别。

值类型是数据，其值适合于`32`字节的EVM字。这些类型包括：

- `bool` (一个布尔值是`1`字节)
- `uint` (无符号整数，范围从`8`到`256`位，也就是`1`到`32`字节)
- `int` (有符号的整数，范围从`8`到`256`位，也就是`1`到`32`字节)


- `address` (一个以太坊地址是`20`字节)
- `bytes1`, `bytes2`, `bytes3`, ..., `bytes32` (固定大小的字节数组，范围为`1`到`32`字节)
- `enum`（用户定义的类型，有一定数量的值）。

这意味着Solidity实际上可以利用这些数据，而不必担心数据长于`32`字节（即长于一个EVM字）。当 Solidity 使用一个值类型时，比如把它分配给一个变量或把它传递给一个函数/事件，它使用的是这个数据的拷贝，而不是修改原始数据。

作为一个复制值类型数据的例子，看看这个`makeACopy`函数：

```js
function makeACopy(uint256 original) public pure returns (uint256, uint256) {
	uint256 copy = original;
	copy += 42;
	return (original, copy);
}
```

当我们赋值`copy`为`original`(代码 `uint256 copy = original;`)时，Solidity在底层做的是取`original`的值，做一个数据的副本，然后把它分配给变量`copy`。因此，当我们调用这个函数时，返回给我们的第一个数字总是我们调用这个函数时的数字，而第二个数字是修改后的数字：

```js
makeACopy(100);
// > (100, 142)

makeACopy(312312);
// > (312312, 312354)

makeACopy(0);
// > (0, 42)
```

所以，当我们把这些值类型作为非  `indexed`的事件参数触发出去时，我们会在事件日志的  `data`属性中看到包含在单个 "32 "字节的EVM字中的值。我们不会看到字符常编码中额外的两个EVM字。

```js
event AValueType(uint256 aNumber);

function emitEvent(uint256 aNumber) public {
	emit AValueType(aNumber);
}
```

调用`emitEvent(42)`函数将产生一个像这样的事件日志：

```json
{
  logs: [
    {
      data: "0x000000000000000000000000000000000000000000000000000000000000002a",
      topics: [
        "0x5a5fa3e7f92622c79af0c0da82ae5bbbfe01451078476d69521279c762082b7a"
      ]
    }
  ]
}
```

其中`logs[0].data`是我们给`emitEvent`的数据副本（`0x2a`=`42`）。

为了清楚起见，让我们触发另一个具有这些值类型的事件：

```solidity
enum Enums {
	EnumOne,
	EnumTwo,
	EnumThree
}

event LotsOfValueTypes(bool aBoolean, uint256 aUint, int256 anInt, address anAddress, bytes8 aByteArray, Enums anEnum);

function emitEvent(bool aBoolean, uint256 aUint, int256 anInt, address anAddress, bytes8 aByteArray, Enums anEnum) public {
	emit LotsOfValueTypes(aBoolean, aUint, anInt, anAddress, aByteArray, anEnum);
}
```

像这样调用`emitEvent`：

```js
emitEvent(
	true,
	42,
	24,
	0x6b175474e89094c44da98b954eedeac495271d0f,
	"0x556E697665727365",
	2
);
```

将产生交易日志事件：

```json
{
  logs: [
    {
      data: "0x0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000180000000000000000000000006b175474e89094c44da98b954eedeac495271d0f556e6976657273650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002",
      topics: [
        "0x2dd1bfe7263b65434b7433121256df037d3cf8ac9ba4433210b00e087f40368d"
      ]
    }
  ]
}
```

如果我们把`logs[0].data`分解成`32`字节的EVM字，我们会得到：

```js
0x0000000000000000000000000000000000000000000000000000000000000001 // true
000000000000000000000000000000000000000000000000000000000000002a // 42
0000000000000000000000000000000000000000000000000000000000000018 // 24
0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f // 0x6b175474e89094c44da98b954eedeac495271d0f
556e697665727365000000000000000000000000000000000000000000000000 // 0x556E697665727365
0000000000000000000000000000000000000000000000000000000000000002 // 2
```

### 触发事件有引用类型数据

引用类型和它们听起来一样，它们包含引用数据存储位置的信息（也称为**指针**，因为这个引用指向数据的位置）。我们在**关于ABI编码的旁白**部分介绍了这种区别的原因，但基本上，引用类型的数据可以比我们的`32`字节的EVM字长，所以我们必须告诉EVM数据的开始位置和它的长度，以确保我们不会丢失任何数据（比如我们只读一个EVM字就切断了`supercalifragilisticexpialidocious`的最后`2`字节）。

参考类型是指其值可以超过一个`32`字节的EVM字的数据。这些类型包括：

- `string` (动态大小的UTF-8编码的字符串)
- `bytes` (动态大小的字节数组)
- `array` (动态大小的数组)
- `struct` (用户定义的数据结构)

因此，当这些引用类型作为未 `indexed`的事件参数触发时，它们被ABI编码并被附加到事件日志的`data`属性（与值类型相同，但也有额外的位置和长度数据）。

```solidity
struct AnotherStruct {
	uint256 anotherNumber;
	string anotherString;
}

struct AStruct {
	uint256 aNumber;
	string aString;
	AnotherStruct anotherStruct;
}

event LotsOfReferenceTypes(string aString, bytes aBytesArray, string[] anArrayOfStrings, AStruct aStruct);

function emitEvent(string calldata aString, bytes calldata aBytesArray, string[] calldata anArrayOfStrings, AStruct calldata aStruct) public {
	emit LotsOfReferenceTypes(aString, aBytesArray, anArrayOfStrings, aStruct);
}
```

像这样调用`emitEvent`：

```js
emitEvent(
	"Super important string",
	"0x556E697665727365",
	["stringOne", "stringTwo", "stringThree"],
	[42,"A string",[24,"Another string"]]
);
```

将产生交易日志事件：

```json
{
  logs: [
    {
      data: "0x000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000016537570657220696d706f7274616e7420737472696e67000000000000000000000000000000000000000000000000000000000000000000000000000000000008556e6976657273650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000009737472696e674f6e6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009737472696e6754776f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b737472696e675468726565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000084120737472696e6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000e416e6f7468657220737472696e67000000000000000000000000000000000000",
      topics: [
        "0x304b768a4d13734c98fa64c4c7d775af5620e8801c19b17e8ca4df5e1ea148f0"
      ]
    }
  ]
}
```

如果我们把`logs[0].data`分解成`32`字节的EVM字，我们会得到：

```json
// This is a pointer to the start of our `aString` event parameter
// We can get rid of the padding (the extra `0`s) and we get:
// `0x80` which is `128` in decimal, which means the our string data starts `128` bytes (`4` EVM words) after this word
0x0000000000000000000000000000000000000000000000000000000000000080

// This is a pointer to the start of our `aBytesArray` event parameter
// `0xc0` is `192` in decimal, which means our byte array data starts `192` bytes (`6` EVM words) from the beginning of this word
00000000000000000000000000000000000000000000000000000000000000c0

// This is a pointer to the start of our `anArrayOfStrings` event parameter
// `0x100` is `256` in decimal, which means our byte array data starts `256` bytes (`8` EVM words) from the beginning of this word
0000000000000000000000000000000000000000000000000000000000000100

// This is a pointer to the start of our `aStruct` event parameter
// `0x240` is `576` in decimal, which means our struct data starts `576` bytes (`18` EVM words) from the beginning of this data blob
0000000000000000000000000000000000000000000000000000000000000240

// This is the length of `aString`
// `0x16` is `22` in decimal, so `aString` is `22` bytes long
0000000000000000000000000000000000000000000000000000000000000016

// This is the value of `aString`
// This decodes into the UTF-8 string: "Super important string"
537570657220696d706f7274616e7420737472696e6700000000000000000000

// This is the length of `aBytesArray`
// `0x08` is `8` in decimal, so `aBytesArray` is `8` bytes long
0000000000000000000000000000000000000000000000000000000000000008

// This is the value of `aBytesArray`
// While our event signature specifies that this is just an array of `8` bytes,
// we can interpret this data as UTF-8 encoded bytes and get the string:
// "Universe"
556e697665727365000000000000000000000000000000000000000000000000

// This is the number of elements in our `anArrayOfString` event parameter
// `0x03` is `3` in decimal, meaning `anArrayOfString` contains `3` elements
0000000000000000000000000000000000000000000000000000000000000003

// This is a pointer to the start of `anArrayOfString`
// `0x60` is `96` in decimal, which means our `anArrayOfStrings` data starts `96` bytes (`3` EVM words) from the beginning of this word
0000000000000000000000000000000000000000000000000000000000000060

// This is a pointer to the start of `aStruct.anotherStruct`
// `0xa0` is `160` in decimal, which means our data starts `160` bytes (`5` EVM words) from the start of `aStruct`
00000000000000000000000000000000000000000000000000000000000000a0

// This is a pointer to the start of `aStruct`
// `0xe0` is `224` in decimal, which means our  data starts `224` bytes (`7` EVM words) from the beginning of this word
00000000000000000000000000000000000000000000000000000000000000e0

// This is the length of the first element of `anArrayOfStrings`
// `0x09` is `9` in decimal, so the first element is `9` bytes long
0000000000000000000000000000000000000000000000000000000000000009

// This is the value of first element
// This decodes into the UTF-8 string: "stringOne"
737472696e674f6e650000000000000000000000000000000000000000000000

// This is the length of the second element of `anArrayOfStrings`
// `0x09` is `9` in decimal, so the second element is `9` bytes long
0000000000000000000000000000000000000000000000000000000000000009

// This is the value of second element
// This decodes into the UTF-8 string: "stringTwo"
737472696e6754776f0000000000000000000000000000000000000000000000

// This is the length of the third element of `anArrayOfStrings`
// `0x0b` is `11` in decimal, so the third element is `11` bytes long
000000000000000000000000000000000000000000000000000000000000000b

// This is the value of third element
// This decodes into the UTF-8 string: "stringThree"
737472696e675468726565000000000000000000000000000000000000000000

// This is the value of `aStruct.aNumber`
// `0x2a` is `42` in decimal
000000000000000000000000000000000000000000000000000000000000002a

// This is a pointer to the start of `aStruct.aString`
// `0x60` is `96` in decimal, which means our `aStruct.aString` data starts `96` bytes (`3` EVM words) from the beginning of this word
0000000000000000000000000000000000000000000000000000000000000060

// This is a pointer to the start of `aStruct.anotherStruct.anotherString`
// `0xa0` is `160` in decimal, which means our `anotherString` data starts `160` bytes (`5` EVM words) from the beginning of this word
00000000000000000000000000000000000000000000000000000000000000a0

// This is the length of `aStruct.aString`
// `0x08` is `8` in decimal, so `aString` is `8` bytes long
0000000000000000000000000000000000000000000000000000000000000008

// This is the value of `aStruct.aString`
// This decodes into the UTF-8 string: "A string"
4120737472696e67000000000000000000000000000000000000000000000000

// This is the value of `aStruct.anotherStruct.anotherNumber`
// `0x18` is `24` in decimal
0000000000000000000000000000000000000000000000000000000000000018

// This is a pointer to the start of `aStruct.anotherStruct.anotherString`
// `0x40` is `64` in decimal, which means our `anotherString` data starts `64` bytes (`2` EVM words) from the beginning of `aStruct.anotherStruct`
0000000000000000000000000000000000000000000000000000000000000040

// This is the length of `aStruct.anotherStruct.anotherString`
// `0x0e` is `14` in decimal, so `anotherString` is `14` bytes long
000000000000000000000000000000000000000000000000000000000000000e

// This is the value of `aStruct.anotherStruct.anotherString`
// This decodes into the UTF-8 string: "Another string"
416e6f7468657220737472696e67000000000000000000000000000000000000
```

### 触发的事件有值和参考类型

你也可以触发这些类型的任何混合体，所有的事件参数将被ABI编码并在事件日志的`data`属性下可用。

```js
event BothValueAndReferenceTypes(uint256 someNumber, string aString, bool aBoolean, uint256[] anArrayOfNumbers);

function emitEvent(uint256 someNumber, string calldata aString, bool aBoolean, uint256[] calldata anArrayOfNumbers) public {
	emit BothValueAndReferenceTypes(someNumber, aString, aBoolean, anArrayOfNumbers);
}
```

像这样调用`emitEvent`：

```js
emitEvent(
	42,
	"Super important string",
	true,
	[24, 2, 13]
);
```

将产生交易日志事件：

```json
{
  logs: [
    {
      data: "0x000000000000000000000000000000000000000000000000000000000000002a0000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000016537570657220696d706f7274616e7420737472696e6700000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000d",
      topics: [
        "0xa1f083d1798fdec97dd408052e0813b964892c5a0758ce850eec7093ea8bbc0b"
      ]
    }
  ]
}
```

如果我们把`logs[0].data`分解成`32`字节的EVM字，我们会得到：

```json
// This is the value of `someNumber`
// `0x2a` is `42` in decimal
0x000000000000000000000000000000000000000000000000000000000000002a

// This is a pointer to the start of `aString`
// `0x80` is `128` in decimal, which means our `aString` data starts `128` bytes (`4` EVM words) from the beginning of this word
0000000000000000000000000000000000000000000000000000000000000080

// This is the value of `aBoolean`
// `0x01` is `true`
0000000000000000000000000000000000000000000000000000000000000001

// This is a pointer to the start of `anArrayOfNumbers`
// `0xc0` is `192` in decimal, which means our `anArrayOfNumbers` data starts `192` bytes (`6` EVM words) from the beginning of this data blob
00000000000000000000000000000000000000000000000000000000000000c0

// This is the length of `aString`
// `0x16` is `22` in decimal, so `aString` is `22` bytes long
0000000000000000000000000000000000000000000000000000000000000016

// This is the value of `aString`
// This decodes into the UTF-8 string: "Super important string"
537570657220696d706f7274616e7420737472696e6700000000000000000000

// This is the number of elements in our `anArrayOfNumbers` event parameter
// `0x03` is `3` in decimal, meaning `anArrayOfNumbers` contains `3` elements
0000000000000000000000000000000000000000000000000000000000000003

// This is the value of first element
// `0x18` is `24` in decimal
0000000000000000000000000000000000000000000000000000000000000018

// This is the value of first element
// `0x02` is `2` in decimal
0000000000000000000000000000000000000000000000000000000000000002

// This is the value of first element
// `0x0d` is `13` in decimal
000000000000000000000000000000000000000000000000000000000000000d
```

## 使用Web3.js检索过去的Dai转账事件日志

你可以使用几个库来检索过去的事件日志，使用JavaScript/TypeScript，如[ethers.js](https://github.com/ethers-io/ethers.js/)和[viem](https://github.com/wagmi-dev/viem)，但在本指南中，我选择使用最新版本的[web3.js](https://github.com/web3/web3.js)，版本`4.x`。

在前面的**以太坊日志主题**部分，我们在看Dai合约的`Transfer`事件日志。让我们写一些代码，用 web3.js 检索过去的事件日志：

这个例子的代码可以在[这里](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/dai-transfer-fetcher.ts)找到。

```typescript
import { Web3, utils } from "web3";

(async () => {
  const DAI_VERIFIED_ADDRESS = "0x6b175474e89094c44da98b954eedeac495271d0f";
  const TRANSFER_EVENT_TOPIC = utils.keccak256(
    "Transfer(address,address,uint256)"
  );
  const NUMBER_OF_BLOCKS = BigInt(10);

  const web3 = new Web3("http://localhost:1234");

  const logs = await web3.eth.getPastLogs({
    address: DAI_VERIFIED_ADDRESS,
    topics: [TRANSFER_EVENT_TOPIC],
    // This PR will allows us to pass a BigInt instead of having to format it as a hex string
    // https://github.com/web3/web3.js/pull/6219
    fromBlock: `0x${(
      (await web3.eth.getBlockNumber()) - NUMBER_OF_BLOCKS
    ).toString(16)}`,
  });

  console.log(logs);
})();
```

运行这段代码将`console.log`类似的东西：

请记住，如果在你指定的块范围内没有Dai转账，你可能不会收到任何日志。如果你运行这个例子并收到`[]`空响应： ，尝试增加`NUMBER_OF_BLOCK`变量。然而，也请记住，你的区块范围越大，你的响应就越大。

```json
[
  {
    address: '0x6b175474e89094c44da98b954eedeac495271d0f',
    topics: [
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x000000000000000000000000c2e9f25be6257c210d7adf0d4cd6e3e881ba25f8',
      '0x000000000000000000000000c36442b4a4522e871399cd717abdd847ab11fe88'
    ],
    data: '0x00000000000000000000000000000000000000000000010e305052574353fccd',
    blockNumber: 17540942n,
    transactionHash: '0x1f2e052b537a53178f5a297f800c21e04ff9e4abe463f38bf8ab8aecb99d8c3a',
    transactionIndex: 105n,
    blockHash: '0xd60f88fae8c57e988c765ae03c97f46a044139990116e24266c1bf5a941e504a',
    logIndex: 196n,
    removed: false
  },
  {
    address: '0x6b175474e89094c44da98b954eedeac495271d0f',
    topics: [
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x000000000000000000000000c36442b4a4522e871399cd717abdd847ab11fe88',
      '0x000000000000000000000000741aa7cfb2c7bf2a1e7d4da2e3df6a56ca4131f3'
    ],
    data: '0x00000000000000000000000000000000000000000000010e305052574353fccd',
    blockNumber: 17540942n,
    transactionHash: '0x1f2e052b537a53178f5a297f800c21e04ff9e4abe463f38bf8ab8aecb99d8c3a',
    transactionIndex: 105n,
    blockHash: '0xd60f88fae8c57e988c765ae03c97f46a044139990116e24266c1bf5a941e504a',
    logIndex: 201n,
    removed: false
  },
  {
    address: '0x6b175474e89094c44da98b954eedeac495271d0f',
    topics: [
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x0000000000000000000000000661e5e44666c9f4701a69594840e2b191414755',
      '0x00000000000000000000000074de5d4fcbf63e00296fd95d33236b9794016631'
    ],
    data: '0x0000000000000000000000000000000000000000000000073e128c2828300000',
    blockNumber: 17540943n,
    transactionHash: '0xe89e0af726cb0867313706d09eeea9c80546d9a9aa118bb94e614fb4f0e89568',
    transactionIndex: 75n,
    blockHash: '0x31c0b2b8dc0e155fd3a901008c8963969be52942b3c73d89f9faccd014c98d78',
    logIndex: 162n,
    removed: false
  }
]
```



关于我们刚刚设置的这个Dai `Transfer`过去的日志获取器，有趣的是通过删除一行，即我们的过滤器对象中的`address`属性，我们的获取器从只获取Dai`Transfer`事件，到获取任何ERC-20的所有`Transfer`事件（技术上是任何发出具有`Transfer(address,address,uint256)`签名的事件的合约）：

```typescript
import { Web3, utils } from "web3";

(async () => {
  const TRANSFER_EVENT_TOPIC = utils.keccak256(
    "Transfer(address,address,uint256)"
  );
  const NUMBER_OF_BLOCKS = BigInt(10);

  const web3 = new Web3("http://localhost:1234");

  const logs = await web3.eth.getPastLogs({
    topics: [TRANSFER_EVENT_TOPIC],
    // This PR will allows us to pass a BigInt instead of having to format it as a hex string
    // https://github.com/web3/web3.js/pull/6219
    fromBlock: `0x${(
      (await web3.eth.getBlockNumber()) - NUMBER_OF_BLOCKS
    ).toString(16)}`,
  });

  console.log(logs);
})();
```

这个过去的日志获取器现在被配置为在我们指定的区块范围内获取任何包含主题`TRANSFER_EVENT_TOPIC`的过去的事件日志，不管是什么合约发出的事件。

如果你想获得特定区块范围内的所有ERC20转移，这样的东西可能很有用。然而，你很可能需要做额外的过滤，以删除任何来自非ERC20合约的事件记录。为了证明这个问题，我们上面的代码将捕获以下由以下代码创建的事件日志：

```js
contract FakeTransfer {
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);

    function emitEvent(address sender, address recipient, uint256 amount) public {
        emit Transfer(sender, recipient, amount);
    }
}
```

像这样调用`emitEvent`：

```js
emitEvent(
	"0x74de5d4fcbf63e00296fd95d33236b9794016631",
	"0x2acf35c9a3f4c5c3f4c78ef5fb64c3ee82f07c45",
	"0x01"
)
```

将创建事件日志：

```json
{
    topics: [
	  // You can see here that we have the same keccak256 hash as a Dai transfer event log,
	  // even though we don't transfer anything in the FakeTransfer contract
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x00000000000000000000000074de5d4fcbf63e00296fd95d33236b9794016631',
      '0x0000000000000000000000002acf35c9a3f4c5c3f4c78ef5fb64c3ee82f07c45'
    ],
    data: '0x0000000000000000000000000000000000000000000000000000000000000001',
}
```

这将被我们过去的日志获取器捕获，因为我们过滤的唯一数据是`TRANSFER_EVENT_TOPIC`。

## 使用Web3.js监听新的Dai转账事件

能够获取过去的事件日志是很有用的，但是使用web3.js，我们也可以在事件发生时订阅它们。订阅新事件与请求过去事件的一个关键区别是，我们需要在HTTP上使用WebSocket协议（WS）。这是因为我们现在是在*订阅*新的事件，需要在我们的代码和我们的Web3提供者之间保持一条开放的通信线路，而WebSocket协议就是为了促进这一点。如果你试图用web3.js的HTTP提供者来订阅事件日志，你应该看到这样的错误：

```js
SubscriptionError: Failed to subscribe.
    at /web3.js-event-listening/node_modules/web3-eth-contract/lib/commonjs/contract.js:614:35 {
  innerError: undefined,
  code: 603
}
```

现在来看看监听新的 `transfer`事件的正确实现：

这个例子的代码可以在[这里](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/dai-transfer-listener.ts)找到。

```js
import { Contract } from "web3";

import { DAI_ABI } from "./dai-abi";

(async () => {
  const DAI_VERIFIED_ADDRESS = "0x6b175474e89094c44da98b954eedeac495271d0f";
  const WEB3_PROVIDER = 'ws://127.0.0.1:1234';

  const daiContract = new Contract(
    DAI_ABI,
    DAI_VERIFIED_ADDRESS,
    {
        provider: WEB3_PROVIDER
    }
  );

  const transferEvent = daiContract.events.Transfer();
  transferEvent.on('data', eventLog => console.log(eventLog));
  transferEvent.on('error', error => console.log(error));
})();
```

上述代码与获取过去事件的代码之间的其他一些区别包括：

- `DAI_ABI` - 应用二进制接口（ABI）是一个JSON对象，描述了如何与相关合约进行交互。这个接口包括事件签名，这就是为什么我们不再需要上一个例子中的`TRANSFER_EVENT_TOPIC`。web3.js能够使用提供的合约ABI计算出`Transfer`事件主题。ABI中指定`Transfer`事件签名的部分看起来像：

```json
{
    anonymous: false,
    inputs: [
      { indexed: true, name: "from", type: "address" },
      { indexed: true, name: "to", type: "address" },
      { indexed: false, name: "value", type: "uint256" },
    ],
    name: "Transfer",
	type: "event",
},
```

你可以看到web3.js是如何通过从`inputs`中的每个输入的`type`和事件的`name`来拼凑出正确的`Transfer`事件签名的。你可能想知道我是如何找到Dai合约的ABI的，虽然有多种方法可以获得合约的ABI，但由于Dai合约是在Etherscan上验证的，在[合约代码页](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f#code)上，你会发现 `合约ABI `部分，我从那里复制了ABI：

![Dai Stablecoin Verified Application Binary Interface](https://img.learnblockchain.cn/pics/20230705160019.png)



>  Dai稳定币验证的 ABI 

- 我们正在实例化一个`Contract`的实例 - 正如上一节提到的，你可以删除`address`属性来获取任何发出`Transfer`事件的交易的过去事件，而不是那些只与Dai合约交互的交易。然而，这在这个代码例子中是不可能的，因为我们正在为Dai合约实例化web3.js的`Contract`类，因为我们正在使用`DAI_ABI`和`DAI_VERIFIED_ADDRESS`。因此，我们将只接收来自Dai合约的`Transfer`事件日志，所有其他来自其他合约的`Transfer`事件日志将被忽略。

运行这个例子的代码将`console.log`类似于：

*请记住，你不会不收到任何日志，直到有交易在最新的区块中调用来自Dai合约的* `transfer` 函数。

```json
{
  removed: false,
  logIndex: 95n,
  transactionIndex: 15n,
  transactionHash: '0x675486e678d13e65561906e9439567260bc06318f128eba7f80249dda11f48e3',
  blockHash: '0x076c981fe8a6c00475b3cba4d9b70406302c3a5a972d4770320862a00db05203',
  blockNumber: 17566618n,
  address: '0x6b175474e89094c44da98b954eedeac495271d0f',
  data: '0x0000000000000000000000000000000000000000000000000000000000000000',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    '0x000000000000000000000000c7128596e0cbfe72776eedbd306237baf34db9e6',
    '0x000000000000000000000000a8d676a3ef46fc216db67f13988988b0c125c4db'
  ],
  returnValues: {
    '0': '0xC7128596e0cbFe72776EedBd306237BAf34Db9e6',
    '1': '0xa8d676a3Ef46fC216db67f13988988B0c125c4DB',
    '2': 0n,
    __length__: 3,
    from: '0xC7128596e0cbFe72776EedBd306237BAf34Db9e6',
    to: '0xa8d676a3Ef46fC216db67f13988988B0c125c4DB',
    value: 0n
  },
  event: 'Transfer',
  signature: '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
  raw: {
    data: '0x0000000000000000000000000000000000000000000000000000000000000000',
    topics: [
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x000000000000000000000000c7128596e0cbfe72776eedbd306237baf34db9e6',
      '0x000000000000000000000000a8d676a3ef46fc216db67f13988988b0c125c4db'
    ]
  }
}
{
  removed: false,
  logIndex: 195n,
  transactionIndex: 71n,
  transactionHash: '0x0281fc692e29005121947751007b4eea77fda6bc99d31b3c603eaa794e1577fb',
  blockHash: '0x076c981fe8a6c00475b3cba4d9b70406302c3a5a972d4770320862a00db05203',
  blockNumber: 17566618n,
  address: '0x6b175474e89094c44da98b954eedeac495271d0f',
  data: '0x00000000000000000000000000000000000000000000000285facae8d53dc000',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    '0x00000000000000000000000082f935eaa0dbd60dd548e0fb4d349ac9448d5233',
    '0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60'
  ],
  returnValues: {
    '0': '0x82F935eaA0Dbd60dd548E0Fb4D349AC9448D5233',
    '1': '0x28C6c06298d514Db089934071355E5743bf21d60',
    '2': 46547740000000000000n,
    __length__: 3,
    from: '0x82F935eaA0Dbd60dd548E0Fb4D349AC9448D5233',
    to: '0x28C6c06298d514Db089934071355E5743bf21d60',
    value: 46547740000000000000n
  },
  event: 'Transfer',
  signature: '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
  raw: {
    data: '0x00000000000000000000000000000000000000000000000285facae8d53dc000',
    topics: [
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x00000000000000000000000082f935eaa0dbd60dd548e0fb4d349ac9448d5233',
      '0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60'
    ]
  }
}
{
  removed: false,
  logIndex: 196n,
  transactionIndex: 72n,
  transactionHash: '0xa35d1210008730236dbeea9058af9f51a864b442c6cbef0263557100ff218501',
  blockHash: '0x076c981fe8a6c00475b3cba4d9b70406302c3a5a972d4770320862a00db05203',
  blockNumber: 17566618n,
  address: '0x6b175474e89094c44da98b954eedeac495271d0f',
  data: '0x0000000000000000000000000000000000000000000000022c2dd533aaa7b13b',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    '0x000000000000000000000000ace540d94574c26a1ccfae9cce9de0abbd4da70b',
    '0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60'
  ],
  returnValues: {
    '0': '0xAce540D94574c26a1CCfAE9cCE9De0ABBd4Da70b',
    '1': '0x28C6c06298d514Db089934071355E5743bf21d60',
    '2': 40076923076923076923n,
    __length__: 3,
    from: '0xAce540D94574c26a1CCfAE9cCE9De0ABBd4Da70b',
    to: '0x28C6c06298d514Db089934071355E5743bf21d60',
    value: 40076923076923076923n
  },
  event: 'Transfer',
  signature: '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
  raw: {
    data: '0x0000000000000000000000000000000000000000000000022c2dd533aaa7b13b',
    topics: [
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x000000000000000000000000ace540d94574c26a1ccfae9cce9de0abbd4da70b',
      '0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60'
    ]
  }
}
```

## 使用Web3.js监听你的合约的事件

你可能也对订阅你自己的合约的新事件感兴趣。那么，这样做的代码几乎与上一节的代码完全相同：

这个例子的代码可以在[这里](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/your-contract-listener.ts)找到。

```js
import { Contract } from "web3";

import { YOUR_CONTRACT_ABI } from "./your_contract_abi";

(async () => {
  const YOUR_CONTRACTS_DEPLOYED_ADDRESS = '0x0';
  const WEB3_PROVIDER = 'ws://127.0.0.1:1234';

  const yourContract = new Contract(
    YOUR_CONTRACT_ABI,
    YOUR_CONTRACTS_DEPLOYED_ADDRESS,
    {
        provider: WEB3_PROVIDER
    }
  );

  const transferEvent = yourContract.events.YourEvent();
  transferEvent.on('data', eventLog => console.log(eventLog));
  transferEvent.on('error', error => console.log(error));
})();
```



- `YOUR_CONTRACT_ABI` - 这将是你所部署的合约的ABI，你想监听的事件。这个ABI可以通过其他库获得，比如[solc-js](https://github.com/ethereum/solc-js)，或者你甚至可以利用web3.js的新插件功能，使用一个叫做[web3-plugin-craftsman](https://github.com/conx3/web3-plugin-craftsman#readme)的插件，能够直接使用你的合约的Solidity源文件实例化一个web3.js `Contract`实例.
- `YOUR_CONTRACTS_DEPLOYED_ADDRESS` - 这将是你的合约已经部署的实例的地址，无论是在主网以太坊、测试网络，还是其他EVM兼容链。如果你想一次性部署合约和设置事件监听器感兴趣，下面的web3.js代码就是这样做的：

*这个例子的代码可以在[这里](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/your-contract-deployer-listener.ts)*找到。

```js
import { Web3 } from "web3";

import { YOUR_CONTRACT_ABI, YOUR_CONTRACT_BYTECODE } from "./your_contract_abi";

(async () => {
  const WEB3_PROVIDER = "ws://127.0.0.1:1234";
  const web3 = new Web3(WEB3_PROVIDER);

  const yourContract = new web3.eth.Contract(YOUR_CONTRACT_ABI, "", {
    provider: WEB3_PROVIDER,
  });

  const deployOptions = {
    data: YOUR_CONTRACT_BYTECODE,
    arguments: ["constructorArgumentOne", 2, [3]],
  };
  const sendOptions = {
    from: "0x0",
    gas: `0x${(
      await web3.eth.estimateGas({
        data: YOUR_CONTRACT_BYTECODE,
      })
    ).toString(16)}`,
  };
  const yourContractDeployed = await yourContract
    .deploy(deployOptions)
    .send(sendOptions);

  const transferEvent = yourContractDeployed.events.YourEvent();
  transferEvent.on("data", (eventLog) => console.log(eventLog));
  transferEvent.on("error", (error) => console.log(error));
})();
```

- `YOUR_CONTRACT_BYTECODE` - 合约的字节码是合约的底层表示，它保证无论以太坊客户端或用于编写合约的编程语言如何，合约将始终以相同的方式行事。它是一个十六进制的字符串，做两件事：
  
  1. **创建字节码（或初始化代码）**：这一部分只运行一次，在合约部署期间。它通常包括设置合约的初始状态的代码。在合约部署后，构造函数字节码不存储在区块链上，只有运行时的字节码保留下来。
  
  2. **运行时字节码**：这是字节码的一部分，存储在区块链上，在每次有人与合约交互时执行。它由合约的函数和状态变量的组成。
     合约的字节码很可能是使用你编译合约ABI的相同软件获得的。另外，前面提到的[web3-plugin-craftsman](https://github.com/conx3/web3-plugin-craftsman#readme)也会为你处理实现细节

## 参考文献

- [LOG EVM 代码文档](https://www.evm.codes/#a0?fork=shanghai)
- [Dai转账的交易收据](https://etherscan.io/tx/0x81b886145c37afe0e42353e81f8f2896dd69fb86531a6d2ee9a13ced4d9321fb)
- [Dai Etherscan验证的合约页面](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f#code)
- [在线keccak-256哈希函数](https://emn178.github.io/online-tools/keccak_256.html)
- [了解以太坊区块链上的事件日志](https://learnblockchain.cn/article/1870)
- [Solidity 事件文档](https://learnblockchain.cn/docs/solidity/contracts.html#events)
- [什么是UTF-8](https://blog.hubspot.com/website/what-is-utf-8)
- [UTF-8到16进制表](https://www.rapidtables.com/code/text/ascii-table.html)
- [ethers.js](https://github.com/ethers-io/ethers.js/)
- [viem](https://github.com/wagmi-dev/viem)
- [web3.js](https://github.com/web3/web3.js)
- [检索过去的事件日志代码示例](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/dai-transfer-fetcher.ts)
- [监听新的事件日志代码示例](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/dai-transfer-listener.ts)
- [Dai Etherscan合约代码页](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f#code)
- [监听新的事件日志的合约代码示例](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/your-contract-listener.ts)
- [solc-js](https://github.com/ethereum/solc-js)
- [web3-plugin-craftsman](https://github.com/conx3/web3-plugin-craftsman#readme)
- [部署和监听事件的代码示例](https://github.com/spacesailor24/web3.js-event-listening/blob/master/src/your-contract-deployer-listener.ts)

------

## 我的社交

- [Twitter](https://twitter.com/spacesailor24)
- [Github](https://github.com/spacesailor24)
- Discord用户名: `spacesailor24`.

如果你发现本指南有什么不正确的地方，或者只是有一些反馈，请随时在Twitter或Discord上给我留言。如果你对下一个深入研究的主题有任何想法，也请分享。

---



本翻译由 [DeCert.me](https://decert.me/) 协助支持， 来DeCert码一个未来， 支持每一位开发者构建自己的可信履历。
