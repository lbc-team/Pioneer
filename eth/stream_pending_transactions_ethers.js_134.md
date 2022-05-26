原文链接：https://www.quicknode.com/guides/defi/how-to-stream-pending-transactions-with-ethers-js

# 如何使用 ethers.js 流式处理待处理的交易 ？


#### 概述

如果您喜欢观看而不是阅读，这里代表性的视频指南。

https://www.youtube.com/embed/YjQj6uk9M98

在以太坊上，在形成一个区块中之前，交易会保留在所谓的待处理交易队列、交易池或内存池中——它们的意义相同。然后，矿工从这个队列中选择所有待处理交易的子集进行挖掘——对于交易者、想要节省 gas 费用的人等能够访问和分析这些信息将会得到很多好处。


在这份指南中，我们将学会
如何在以太坊和相似链使用 [ethers.js](https://docs.ethers.io/v5/). 流式处理待处理的交易 


**先决条件**

- 在你的电脑上下载Nodejs
- 一个文本编辑器
- 命令行终端
- 一个以太坊节点



#### 什么是待处理的交易

要在以太坊网络编写或者更新任何内容，需要有人创建，签署和发送交易。交易是外部世界与以太坊网络通信的方式。当发送到以太坊网络时，交易会停留在称为“mempool”的队列中，交易等待旷工被处理----- 处于这种等待交易称为待处理交易。发送交易所需要的少量费用称为gas;交易被旷工包含在一个区块中，并且根据它们包含的给旷工的gas价值量来确定优先级 。






你将得到更多信息在内存池和待处理交易中。[这里](https://www.quicknode.com/guides/defi/how-to-access-ethereum-mempool).

**我为什么想要看未处理的交易呢？**

通过检查待处理的交易，可以执行以下操作：




- 估计gas：理论上我们可以查看待处理的交易来预测下一个区块的最优gas价格。
- 对于交易分析：我们可以分析去中心化交易所的待处理交易。使用分析预测市场趋势。

- 前端运行：在 DeFi 中，您可以预览即将到来的与价格相关的预言机相关交易，并可能对 MKR、COMP 和其他协议的保险库发出清算。

流式处理待处理交易可能有很多案例——我们不会在这里全部介绍。



我们将使用 [ethers.js](https://docs.ethers.io/v5/) 通过 WebSockets 流式传输这些待处理的交易。在编写代码之前，让我们看看如何安装 ethers.js。

 
 

#### 安装ethers.js

我们的第一步是检查系统上是否安装了 node.js。为此，请将以下内容复制粘贴到您的终端


```
1 $ node -v
```

如果没有安装，可以从【官网】（https://nodejs.org/en/）下载 LTS 版本的 NodeJS。

现在我们已经安装了 node.js，让我们使用 node.js 附带的 npm（节点包管理器）安装 ethers.js 库。


```
1 $ npm i ethers
```

此步骤中最常见的问题是 `node-gyp` 的内部故障。您可以按照 [node-gyp 安装说明在这里](https://github.com/nodejs/node-gyp#installation)。



**注意**：如果遇到 node-gyp 问题，您需要让您的 python 版本与上述说明中列出的兼容版本之一匹配。

另一个常见问题是缓存过时。 只需在终端中键入以下内容即可清除 npm 缓存：

```
1  $ npm cache clean
```

如果一切是正常的，ethers.js将安装到了你的操作系统。

#### 启动我们的以太坊节点

对于我们今天的目的，我们几乎可以使用任何以太坊客户端，例如 Geth 或 OpenEthereum (fka Parity)。 由于要流式传输传入的新待处理交易，节点连接必须稳定可靠； 维护一个节点是一项具有挑战性的任务，我们只需 [从 QuickNode 获取一个免费的端点](https://www.quicknode.com/?utm_source=internal&utm_campaign=guides) 来简化这项工作。 创建免费的以太坊端点后，复制您的 WSS (WebSocket) Provider 端点。



![QuickNode 以太坊端点截图](https://www.quicknode.com/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBaU1EIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--5ed295c0c3f3e1c404f1177ce75a6f1d676ea68b/neth%20copy.png)


你以后会需要它的，因此这会复制并且保存它。

#### 流式处理待处理交易

创建一个简短的脚本文件pending.js，它将对传入的未决交易进行交易过滤。将以下内容复制粘贴到文件中：



```
var ethers = require("ethers");
var url = "ADD_YOUR_ETHEREUM_NODE_WSS_URL";

var init = function () {
  var customWsProvider = new ethers.providers.WebSocketProvider(url);
  
  customWsProvider.on("pending", (tx) => {
    customWsProvider.getTransaction(tx).then(function (transaction) {
      console.log(transaction);
    });
  });

  customWsProvider._websocket.on("error", async () => {
    console.log(`Unable to connect to ${ep.subdomain} retrying in 3s...`);
    setTimeout(init, 3000);
  });
  customWsProvider._websocket.on("close", async (code) => {
    console.log(
      `Connection lost with code ${code}! Attempting reconnect in 3s...`
    );
    customWsProvider._websocket.terminate();
    setTimeout(init, 3000);
  });
};

init();
```


所以继续用上面部分中的 WSS (WebSocket) 提供程序替换 `**ADD_YOUR_ETHEREUM_NODE_WSS_URL**`。

上面代码的解释。

第 1 行：导入 ethers 库。

第 2 行：设置我们的以太坊节点 URL。

第 4 行：创建 init 函数。

第 5 行：实例化一个 ethers WebSocketProvider 实例。

第 7 行：为待处理的交易创建一个事件侦听器，每次从节点发送新的交易
哈希时都会运行该事件侦听器。

第 8-10 行：使用从上一步获得的交易哈希获取整个交易，并在控制台中打印交易。

第 13-16 行：如果连接遇到错误，则重新启动 WebSocket 连接的函数。

第 17-21 行：如果连接终止，则重新启动 WebSocket 连接的函数。

第 24 行：调用 init 函数。

 
现在 ，让我一起运行这段脚本。

```
1  $ node pending
```

如果一切执行得顺利，您必须看到传入的待处理交易。 像这样

![img](https://img.learnblockchain.cn/attachments/2022/05/3rjVuPRl628612d732a8b.png)

使用 **Ctrl+c** 来停止这段脚本的运行。



结论

在这里，我们看到了如何使用 ethers,js 从以太坊网络获取待处理的交易。 在他们的[文档](https://docs.ethers.io/v5/single-page/#/v5/api/providers/provider/-%23-Provider-中了解有关ethers.js中的事件过滤器和交易过滤器的更多信息 -事件）。
订阅我们的 [newsletter](https://www.getrevue.co/profile/quiknode) 以获取有关以太坊的更多文章和指南。 如果您有任何反馈，请随时通过 [Twitter](https://twitter.com/QuickNode) 与我们联系。 您可以随时在我们的 [Discord](https://discord.gg/ahckhyA) 社区服务器上与我们聊天，其中包含您将遇到的一些最酷的开发人员 :)