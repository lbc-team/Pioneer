> * 原文：https://dev.to/ltmenezes/automated-dapps-scrapping-with-selenium-and-metamask-2ae9 作者：Leonardo Teixeira Menezes
> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[翻译小组](https://learnblockchain.cn/people/1381)
> * 校对：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/3277)





# 使用Selenium和Metamask 与 Dapps 自动化交互







网络开发的最新趋势之一是去中心化应用的崛起，也被称为Dapps。这些应用是利用去中心化的网络建立的，使用智能合约预先定义的交互，在用户之间提供无信任的互动。（如果你想了解更多关于Dapps的信息[请点击这里](https://ethereum.org/en/dapps/)。

为了访问Dapps，用户需要使用一个加密货币钱包来连接，这为那些想要使用[Selenium](https://github.com/SeleniumHQ/selenium)等工具进行自动化/或测试Dapps的开发者带来了新的挑战。在这篇文章中，我们将介绍如何使用Python和Chromium来解决这个问题的基本知识，然而，这里描述的原则可以来应用于任何编程语言和网络浏览器自动化工具。



![img](https://img.learnblockchain.cn/pics/20211212200403.gif)



目前大多数的Dapps都依赖于用户浏览器中的扩展加密钱包 ，它在网页中注入关于用户钱包和它所连接的网络的信息。最流行的浏览器加密钱包是[Metamask](https://metamask.io/)。为了成功地与一个DApp自动交互，我们不仅需要与目标网站互动，还需要同时与Metamask 扩展钱包交互，以批准应用程序与我们的钱包连接和其他可能的交易。



## 压缩扩展



为了在我们的自动浏览器上加载插件，我们首先需要将Metamask扩展压缩成一个.crx文件，以下是步骤：

- 在你的普通chrome上安装Metamask

- 导航到`chrome://extensions/`。

- 点击'打包扩展程序（Pack extension）'，并输入Metamask 插件的本地路径，这将生成一个`.crx`文件，你可以用它作为扩展加载到Chromium上。保存安装扩展的文件夹的名称，这将是我们以后要使用的'扩展ID'。

  

## 加载扩展

要加载安装了Metamask的Chromium，请运行：



```python
from selenium import webdriver

EXTENSION_PATH = 'ENTER THE PATH TO YOUR CRX FILE'
opt = webdriver.ChromeOptions()
opt.add_extension(EXTENSION_PATH)

driver = webdriver.Chrome(chrome_options=opt)
```



## 与 Metamask 交互

为了同时与Dapp和Metamask互动，我们将需要在Chromium中设置多个标签页(tab)，一个是目标Dapp，另一个是Metamask本身。

当Chromium启动时，它将有一个Metamask扩展的欢迎页，它将提示你设置钱包，下面是导入现有钱包的示例代码（你可能需要更新一些步骤，取决于你的Metamask版本）:

```python
driver.find_element_by_xpath('//button[text()="Get Started"]').click()
driver.find_element_by_xpath('//button[text()="Import wallet"]').click()
driver.find_element_by_xpath('//button[text()="No Thanks"]').click()

# After this you will need to enter you wallet details

inputs = driver.find_elements_by_xpath('//input')
inputs[0].send_keys(SECRET_RECOVERY_PHRASE)
inputs[1].send_keys(NEW_PASSWORD)
inputs[2].send_keys(NEW_PASSWORD)
driver.find_element_by_css_selector('.first-time-flow__terms').click()
driver.find_element_by_xpath('//button[text()="Import"]').click()
driver.find_element_by_xpath('//button[text()="All Done"]').click()
```



在这之后，Metamask将在Chromium中设置成功，准备连接到Dapp。
当你需要再次与Metamask互动时，你将需要在不同的标签页(tab)中使用它，像这样:



```python
EXTENSION_ID = 'ENTER HERE THE EXTENSION ID THAT YOU SAVED EARLIER'

driver.execute_script("window.open('');")
driver.switch_to.window(driver.window_handles[1])
driver.get('chrome-extension://{}/popup.html'.format(EXTENSION_ID))
```



这样一来，Metamask将在这个新标签(tab)中打开，准备与之进行互动。

