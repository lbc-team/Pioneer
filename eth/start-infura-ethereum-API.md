> * 原文链接:https://blog.infura.io/getting-started-with-infuras-ethereum-api/
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
# Infura 以太坊 API 入门教程



因此，你想使用Infura的API访问以太坊网络-你将如何做？首先，你需要确保你拥有Infura帐户（查看[此教程](http://blog.infura.io/getting-started-with-infura-28e41844cc89/?&utm_source=infurablog&utm_medium=referral&utm_campaign=tutorials&utm_content=getting_started_eth_api) 申请账号！）接下来，需要确定**要使用哪个接口** - Infura在**HTTPS**和**WebSocket**接口上都支持**JSON-RPC**。在本教程中，我们介绍使用每个接口的原因，以及将通过Node.js示例介绍两种访问以太坊API的方法。

## HTTPS(HTTPS)

HTTP/HTTPS 是“单向”的 - 客户端发送请求，然后服务器发送响应 - 其“无状态”关联，这意味着每个请求都获得一个响应，然后终止连接。如果你获得**仅需要收集一次的数据**或**正在访问旧数据**，则需要使用HTTPS接口。你会看到HTTPS在简单的RESTful应用程序里经常使用。

### 看一个示例

在此示例中，我们将编写一个使用Rinkeby节点的Node.js程序，并使用`eth_getBlockByNumber`将RPC请求发送到Infura以获取最新的区块数据。从那里，我们将把块号从十六进制转换为整数，并将整数块号打印到终端。准备好了？我们开始吧！



编写此代码的第一步是安装Node(如果尚未安装，则可以使用[npm](https://www.npmjs.com/package/node)或[download](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm))、[DotEnv](https://www.npmjs.com/package/dotenv)、以及相关的[依赖](https://docs.npmjs.com/cli/install)。如果你不熟悉`dotenv`，这是一个不会上传到GitHub的单独文件，可确保你的Project ID和Project Secret(配置在环境变量中)在代码中仍然是保密！要了解更多请查看[此篇文章](https://medium.com/@thejasonfile/using-dotenv-package-to-create-environment-variables-33da4ac4ea8f)。

现在，我们已经完成了安装，继续创建 app.js 文件，并在开头引入`dotenv`和`request`。用与访问`dotenv`文件中包含的变量和请求数据。

```js
const dotenv = require('dotenv').config();
var request = require('request');
```



接下来，我们看一下文档，以查看`eth_getBlockByNumber`的[必需请求头](https://infura.io/docs/ethereum/json-rpc/eth-getBlockByNumber)。我们的请求头需要包含`Content-Type:application/json`，因此我们将其添加到我们的app.js文件中:



```js
const dotenv = require('dotenv').config();
var request = require('request');

var headers = {
	'Content-Type': 'application/json'
};
```

接下来，我们将确定要发送到服务器的数据。在这种情况下，要指定我们想要的:

1. JSON-RPC(最新版本)

2. 正在调用的方法

3. 要包含的任何块参数(在本案例下，我们需要最新的块数据，因此我们包含一个参数为`[“latest”,true]`)

4. ID

   

   你可以将这个`dataString`视为我们将其提交给服务器之前要填写的HTML表单的各个部分。

如果你想了解如何组织数据，则可以使用CURL命令查看文档中提供的示例(不一定是我们正在寻找的参数，但是你知道方法)

![](https://img.learnblockchain.cn/2020/10/15/16027267372651.jpg)



因此，看一下语法并确保代码相适配，我们将`var dataString`添加到app.js中:



```js
const dotenv = require('dotenv').config();
var request = require('request');

var headers = {
	'Content-Type': 'application/json'
};

var dataString = '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",true], "id":1}';
```



但是我们到底从哪里得到数据呢？这是接下来要做的。我们需要创建一个变量来说明:

1. url(网址)

2. method(方法：即POST/GET/etc)。

3. headers(请求头)

4. body（请求体）

5. auth：可能的授权信息(如：在其中包含项目密码的信息)。

   

让我们逐一分析一下这些含义:

1. **url:** 用来访问API的URL；你可以在[我们的文档](https://infura.io/docs/gettingStarted/chooseaNetwork?&utm_source=infurablog&utm_medium=referral&utm_campaign=tutorials&utm_content=getting_started_eth_api)中找到所有网络及其相应URL的列表。
  * 注意:文档中URL上显示“YOUR-PROJECT-ID”的位置，使用dotenv文件中的ProjectID
  * 我们将使用Rinkeby节点，因此我们将使用Rinkeby HTTP URL
2. **method:** 特定的每个JSON-RPC调用的[docs](https://infura.io/docs/ethereum/json-rpc/eth-getBlockByNumber?&utm_source=infurablog&utm_medium=referral&utm_campaign=tutorials&utm_content=getting_started_eth_api)使用的HTTP方法(**与dataString中的`method`的标识不同)
  * 可能的选项:POST/GET/PUT/PATCH/DELETE
  * `getBlockByNumber`是一个**POST**请求
3. **headers** : 调用需要的请求头
  * 我们已经在**`var headers`**中标识了这些内容！
4. **body**:  请求发送的任何信息
  * 在这种情况下，我们已经通过创建**`var dataString`**来自己完成这项工作！
5. **auth**: 完成该请求可能需要的授权(不是必须的)
  * 这就需要`Project Secret` - 请注意，`user` 字段保留为空白，而你的`Project Secret`(隐藏在dotenv文件中)填充到`pass`字段。
  * 在此示例中，我们不需要`Project Secret`，但出于语法考虑，我们将其作为注释包括在内:



```js
const dotenv = require('dotenv').config();
var request = require('request');

var headers = {
	'Content-Type': 'application/json'
};

var dataString = '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",true], "id":1}';

var options = {
	url: `https://rinkeby.infura.io/v3/${process.env.PROJECT_ID}`,
	method: 'POST',
	headers: headers,
	body: dataString,
	// auth: {
	//   'user': '',
	//   'pass': `${process.env.PROJECT_SECRET}`
	// }
};
```


 **注意:** 模板的语法非常重要 - 如果需要帮助，请查看[本文](https://dmitripavlutin.com/string-interpolation-in-javascript/)！

好吧，现在我们终于完成了所有设置！我们剩下的就是实际编写函数发送请求，获取响应并从该响应中获取JSON:



```js
const dotenv = require('dotenv').config();
var request = require('request');

var headers = {
	'Content-Type': 'application/json'
};

var dataString = '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",true], "id":1}';

var options = {
	url: `https://rinkeby.infura.io/v3/${process.env.PROJECT_ID}`,
	method: 'POST',
	headers: headers,
	body: dataString,
};

function callback(error, response, body) {
	if (!error && response.statusCode == 200) {
		json = response.body;
		var obj = JSON.parse(json);
		console.log(obj)
	}
}

request(options, callback);
```




下图为我们提供了完整的原始JSON响应:

![](https://img.learnblockchain.cn/2020/10/15/16027471322437.jpg)


但是，我们正在寻找的最新的区块号(它是一个十六进制数据，我们将其转换为整数以进行打印):

对于特定情况，你可以使用最近的交易来获取其区块号并以此来获取最新的区块，但是如果没有交易，则这种方法将行不通！使用以下内容将使你获得块信息，无论它是否有交易:

查看先前打印输出中的JSON数据，可以看到obj.result.number为我们提供了最新区块号的十六进制:

![](https://img.learnblockchain.cn/2020/10/15/16027476042149.jpg)


每个区块还具有一个唯一的哈希，该哈希存储在hash字段中，通常对于后续请求更有用，但是现在我们只关注数字。当我们使用`console.log(obj.result.number)`时，会得到相同的高亮显示的十六进制值(最好再次检查一下期望从代码中得到的值):

![](https://img.learnblockchain.cn/2020/10/15/16027477524350.jpg)


所以，我们可以在代码中将`hex`定义为`obj.result.number`，以便访问该hex值:



```js
const dotenv = require('dotenv').config();
var request = require('request');

var headers = {
	'Content-Type': 'application/json'
};

var dataString = '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",true], "id":1}';

var options = {
	url: `https://rinkeby.infura.io/v3/${process.env.PROJECT_ID}`,
	method: 'POST',
	headers: headers,
	body: dataString,
};

function callback(error, response, body) {
	if (!error && response.statusCode == 200) {
		json = response.body;
		var obj = JSON.parse(json);
		hex = obj.result.number;
	}
}

request(options, callback);
```



现在，挑战的最后一部分: 将十六进制转换为整数并打印出该整数！我们要调用`parseInt(hex，16)`将十六进制字符串转换为整数，然后控制台记录该最终结果。`hex`是我们在上一步中找到的十六进制代码，而16表示`hex`是基数为16的十六进制(如果未指定，则任何以`0x`开头的字符串都将被视为十六进制，因此基数为16；否则基数为10):



```js
const dotenv = require('dotenv').config();
var request = require('request');

var headers = {
	'Content-Type': 'application/json'
};

var dataString = '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",true], "id":1}';

var options = {
	url: `https://rinkeby.infura.io/v3/${process.env.PROJECT_ID}`,
	method: 'POST',
	headers: headers,
	body: dataString,
};

function callback(error, response, body) {
	if (!error && response.statusCode == 200) {
		json = response.body;
		var obj = JSON.parse(json);
		hex = obj.result.number;
		final = parseInt(hex, 16)
		console.log(final)
	}
}

request(options, callback);
```






当我们运行代码时，我们得到:

![](https://img.learnblockchain.cn/2020/10/15/16027478424142.jpg)


成功！你现在知道如何使用Infura API通过HTTPS访问以太坊节点了！如果你要查找更多历史数据或只需要一次数据，此方法非常有用，但是如果你需要滚动的数据，该怎么办？你就需要使用WebSocket连接！

##  WebSocket

WebSocket是**双向**和**有状态**的，这意味着客户端和服务器之间的连接将保持有效状态，直到被任何一方(客户端或服务器)终止。连接关闭后，将终止连接。当你想要将数据连续推送/传输到已经打开的连接时，这是选用WebSocket的最佳时间，例如在加密货币交易平台，游戏应用程序或聊天应用程序中，你想要在其中不断（即时的）更新数据。

### 示例

在此示例中，我们将编写一个Node.js程序，该程序再次使用Rinkeby节点，并使用WebSocket连接通过该WebSocket连接上的`newHeads`订阅类型来获取最新的区块头信息。对于这个例子，我们希望看到来自WebSocket连接的最新块头数据在日志的尾部输出。让我们开始吧！

首先，我们要进行 npm install 以及引入必需的依赖 -`dotenv`和`ws`(用于WebSocket)。`dotenv`将使我们能够隐藏Project ID和Secret， ws用于连接到WebSocket。



```js
const dotenv = require('dotenv').config();
const WebSocket = require('ws');
```




接下来，我们将通过创建WebSocket的新实例来打开WebSocket连接:



```js
const dotenv = require('dotenv').config();
const WebSocket = require('ws');

const ws = new WebSocket(`wss://ropsten.infura.io/ws/v3/${process.env.PROJECT_ID}`);
```




同样，使用`dotenv`文件将Project ID保密，这就是为什么这里有模板文字的原因。

如果你仔细阅读了HTTPS部分，希望其中的一部分对你来说很熟悉！有了WebSocket之后，我们将它打开后，并基于其发送数据(就像我们向服务器提交表单，告诉它我们想要什么)。在此案例中，我们的方法是`eth_subscribe`(因为我们正在[*订阅*以获取最新的区块头](https://infura.io/docs/ethereum/wss/eth-subscribe))，而我们的参数是`newHeads`，因为这是我们要从中获取结果的订阅类型:



```js
const dotenv = require('dotenv').config();
const WebSocket = require('ws');

const ws = new WebSocket(`wss://ropsten.infura.io/ws/v3/${process.env.PROJECT_ID}`);

ws.on('open', function open() {
	ws.send('{"jsonrpc":"2.0","method":"eth_subscribe","params":["newHeads"], "id":1}');
});
```



现在，我们希望能够查看到响应中的数据，因此将为解析后的JSON数据分配一个变量，并对其进行`console.log`操作以获取我们需要的区块头数据:



```js
const dotenv = require('dotenv').config();
const WebSocket = require('ws');

const ws = new WebSocket(`wss://ropsten.infura.io/ws/v3/${process.env.PROJECT_ID}`);
	ws.on('open', function open() {
	ws.send('{"jsonrpc":"2.0","method":"eth_subscribe","params":["newHeads"], "id":1}');
});

ws.on('message', function incoming(data) {
	var obj = JSON.parse(data);
	console.log(obj);
	ws.close()
});
```



请注意，在最后我们**关闭了WebSocket**-当我们仅仅需要获取最新的区块头数据时，这是重要的一步！因为我们已经关闭了WebSocket连接，所以我们的响应正是我们想要的(最新区块头信息及其数据):

![](https://img.learnblockchain.cn/2020/10/15/16027480540896.jpg)


想知道如果不关闭WebSocket连接会怎样？当然可以！我们很快就会得到这个打印输出，然后不断更新，更新和更新，……你明白了。这是当我们保持WebSocket连接打开时发生的示例:

![](https://img.learnblockchain.cn/2020/10/15/16027481281876.jpg)


就这些！现在，你知道了如何打开WebSocket连接，使用参数调用方法，以及获取最新块的输出(以及持续获取最新块的运行列表，如果你需要的话)。

现在就开始[探索 Infura API](https://infura.io/)吧!

## 想要探索更多吗？

在我们的[文档](https://infura.io/docs/ethereum/json-rpc/)中你可以查看通过HTTPS和WebSocket可以发出的所有可能的请求，以及一些更复杂的概念，例如速率限制：

![](https://img.learnblockchain.cn/2020/10/15/16027482924687.jpg)


![](https://img.learnblockchain.cn/2020/10/15/16027483807884.jpg)




------
本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。