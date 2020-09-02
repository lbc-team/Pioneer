# 更好Solidity合约调试  : console.log 

Builder EVM 是一个用于本地开发的以太坊网络，提供了更好的堆栈跟踪功能和console.log() 输出日志。



## Build EVM 及 console.log

![1_WGi-zdr3SVFdcV45k_0X7w](https://img.learnblockchain.cn/pics/20200817101938.png)



 在以太坊上建立智能合约看起来越来越像人类可以做的事情，这一切正在发生。

在 19 年 10 月, [我们推出了Buidler EVM](https://medium.com/nomic-labs-blog/better-solidity-debugging-stack-traces-are-finally-here-dd80a56f92bb)：一种ganache-cli替代方案，其实现了Solidity的堆栈跟踪功能。 这是迈向更好的开发人员体验的重要一步，现在我们发布了另一个备受期待的Buidler EVM功能：用于Solidity的 ` console.log()`。

> 译者注： 是时候用Buidler EVM 替换ganache了， 安装完成后，用 `npx buidler node`启动 Builder EVM后，其他就和使用 Ganache 完全一样。



![Solidity debugging after Buidler EVM](https://img.learnblockchain.cn/pics/20200817101956.png)



> 从此 Debug 有了双眼



Buidler EVM是为开发而设计的本地以太坊网络。 它允许您部署合约，运行测试和调试代码， 并且Buidler EVM是被设计为可启用高级工具的平台。



当前从Solidity记录数据的主要方法是触发事件（emitting events），但是这种方法有很大限制：它仅适用于成功的交易。 这是因为EVM不会在交易失败时触发事件。而往往是交易失败时，开发人员需要了解发生了什么情况，因此这对开发来说是很悲惨的。



Buidler EVM拥有强大的执行检查架构，使我们能够实现可靠`console.log` ，它将始终可用，**即使在交易失败的时候**，它还可以与您选择的测试工具一起使用 。

### 使用 console.sol



使用它很简单。 只需导入`@nomiclabs/buidler/console.sol` ，然后在函数中加入`console.sol`，就像在JavaScript中一样使用它即可，例如：

![Buidler’s 示例代码](https://img.learnblockchain.cn/pics/20200817102046.png)

然后使用Builder EVM作为开发网络使用Builder运行测试。

![1_WRz_O76rpVRTadX34f4_cQ](https://img.learnblockchain.cn/pics/20200817102119.png)

可以使用任何工具（不仅是Buidler）编译合约，因此需要，可以放心的保留着log的调用。 诸如[Tenderly](https://tenderly.dev/)之类的工具将集成日志的抓取功能，因此，您甚至可以根据需要将日志记录代码部署到测试网和主网。 在其他网络中运行时，调用`console.log`不会执行任何操作，但会产生gas费用。



Buidler EVM的最新版本还增加了对`Solidity 0.6`支持以及新的JSON-RPC方法`evm_snapshot`和`evm_revert` ，从而允许项目使用快照迁移到Buidler并继续其测试优化。



结合堆栈跟踪功能，标志着智能合约开发生产力的新篇章。

带着 Builder EVM的`console.log`去兜兜风！

```
mkdir console/
cd console/
npm init -y
npm install --save-dev @nomiclabs/buidler
npx buidler # and create a sample project
npx buidler test
```

使用Builder，你很快会忘记Solidity调试给你的挫败感 👷‍♀️👷‍♂️



## 在Truffle项目中使用console.log



在现有的 truffle 项目中也可以非常容易的使用`console.log`，先在项目下安装 buidler ：

```
npm install --save-dev @nomiclabs/buidler
// 或
yarn add @nomiclabs/buidler
```



然后在合约文件中引入 `import "@nomiclabs/buidler/console.sol";`，然后在需要的地方加入`console.log() `打印即可



接着就是部署和测试，在 truffle 项目，一般使用的是 Ganache 网络，现在我们使用Builder EVM替代Ganache，修改truffle-config.js 配置：

```
  networks: {
    development: {
       host: "127.0.0.1",     
       port: 8545,   
       network_id: "*"
    }
  }
```



Ganache的默认 RPC 端口通常是 7545， Builder EVM 默认 RPC 端口是8545，因此我们修改development网络的端口为8545。

启动Builder EVM后，就可以进行部署了，使用命令`npx buidler node`启动Builder EVM ，Builder EVM 会为我们分配 20 个账号、每个账号有 10000 个以太币。

> 如果是第一次启动，会提示我们创建一个项目，可以选择"Create an empty buidler.config.js"，即创建一个空的`buidler.config.js` 。



之前就可以和之前开发 Truffle 项目完全一致了，开启另一个命令终端，使用`truffle migrate`命令进行部署，如果我们在构造函数中加入了`console.log() `，那么在Builder EVM终端里，就可以参看到日志了。





原文：https://medium.com/nomic-labs-blog/better-solidity-debugging-console-log-is-finally-here-fc66c54f2c4a 作者：[Patricio Palladino](https://medium.com/@alcuadrado?source=post_page-----fc66c54f2c4a----------------------)

