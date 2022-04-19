在本教程里将指导您使用circom和snarkjs库创建第一个零知识 zkSnark电路。 它将介绍各种编写电路的技术，并向您展示如何创建证明并在[以太坊](https://learnblockchain.cn/categories/ethereum/)上进行链外和链上验证。

我们假定尽可能少的背景知识，并尽最大努力从第一原理中解释相关概念，让我们从基础开始。

## 零知识基础概念

### 什么是零知识证明?

> 在密码学中，零知识证明或零知识协议是一种方法，通过该方法，一方（证明者）可以向另一方（验证者）证明他们知道值x，而无需传达除了他知道值x这个事实之外任何信息。 解释[来源于 Wiki](https://en.wikipedia.org/wiki/Zero-knowledge_proof)

零知识证明使我们能够证明自己的某些特定特征，而无需透露任何额外的信息。

从哲学的角度来看，它们是一组新的加密工具的一部分，这些工具使得透明性不必与隐私性冲突。

### 什么是 zk-snark?

术语“ zk-snarks”代表*zero-knowledge succinct non-interactive arguments of knowledge*:

**zero-knowledge**: 零知识

**Succinctness：**简洁（证据信息较短，方便验证）

**Non-interactivity**：无需交互

**arguments of knowledge**： 知识论据

暂时无需了解这些概念意味着什么（有兴趣的同学可阅读元家昕的[简述零知识证明与zkSNARK](https://learnblockchain.cn/2019/04/16/zero-knowledge-zksnark)）。 可以简单地将zk-snarks视为产生零知识证明的有效（或简洁）方法：证明足够短到可以发布到区块链，并且可以被任何有权验证它们的人（ 我们称为验证者）之后读取它。

### 一些例子

#### 众筹

如果众筹仅针对）仅对KYC或授权用户，使用zk-snarks，你可以证明自己是被授权可参加众筹的人，而无需透露自己是谁或花费了多少。

#### 匿名投票

与上述类似，您可以在不透露性别，年龄甚至姓名的情况下证明自己有资格投票。

例如，可以在全国大选中投票，而仅表明您是该国的公民，并且年满18岁。

#### Covid-19 新冠病毒测试

您可以使用zk-snarks来证明您最近对Covid-19的测试是阴性，而不用透露测试的确切日期或测试的医院：仅需要在官方认可的时间窗口内有效即可。

## 库

我们需要使用两个库: [circom](https://github.com/iden3/circom/blob/master/TUTORIAL.md) 和 [snarkjs](https://github.com/iden3/snarkjs).

Circom是一个可以轻松构建代数电路的库。

snarkjs是zk-snarks协议的独立实现-完全用JavaScript编写。

这是两个设计好在在一起协同工作的库：在circom中构建的任何电路都可以在snarkjs中使用。

### 为什么我们需要电路?

zk-snarks 不能直接应用于任何计算问题。 首先需要将问题转换为正确的形式。 第一步是将其转换为代数电路。

> 尽管做起来并不总是很明显，但事实证明，我们关心的大多数计算问题都可以转化为代数电路。

![img](https://img.learnblockchain.cn/pics/20200609095213.png)

<center>*zk-snark 管道,   Eran Tromer 绘制*</center>

---

既然我们已经介绍了基础知识，那么我们就可以开始学习了。

在以下步骤中，我们将介绍各种编写电路的技术，并向您展示如何在以太坊上链外和链上创建和验证证明。

## 1. 安装工具

### 1.1 先决条件

需要在电脑中安装`Node.js`，Node.js 的最新的稳定版本（或8.12.0）可以正常工作。 不过，如果您安装了当前的最新版本的Node.js（10.15.3），将会看到显着的性能提升。 这是因为最新版本本身包含大数库（Big Integer Libraries）。 `snarkjs` 库会利用这些特性（如果可用的话），从而将性能提高10倍（!）。

### 1.2 安装 circom 和 snarkjs

运行:

```bash
npm install -g circom
npm install -g snarkjs
```

## 2.  构建电路 circuit

让我们创建一个电路，去**证明你能够因式分解一个数字**！

具体来说，让我们构建一个电路，让我们证明我们知道两个数字（称为  `a`  和 `b` ）相乘在一起得到  `c` ，而没有透漏  `a`  和 `b` 。

在开始之前，让我们定义一下电路的含义。

就我们的目的而言，电路等效于具有一个输出和一个或多个输入的语句或确定性程序。

![img](https://img.learnblockchain.cn/pics/20200609103810.png)

电路有两种可能的输入：`private`私有 和 `public`公共。 区别在于，`private` 输入对正在验证语句真实性的人（验证者）是隐藏的。

这里的思路是，给定一个  circom 电路及其输入，我们可以运行该电路并生成证明（使用 `snarkjs` ）。

利用证明，输出和公共输入，我们可以向某人（验证者）证明我们知道一个或多个满足电路约束的私有输入，而无需透露有关私有输入的任何信息 。

换句话说，尽管验证者不知晓电路的私有输入（即对了解输入的知识为零），证明、输出和公共输入也足以说明我们的陈述是正确的（即术语零知识证明）。

现在，我们知道电路是什么以及为什么有用，让我们从设计电路开始。

### 2.1 设计电路

1. 创建一个 `factor` 目录，教程里的所有文件都将放在这个下面

```bash
mkdir factor
cd factor
```

在真实的电路中，您可能需要创建一个 `git` 仓库，其中包含`circuits`目录和一个包含所有测试的`test`目录，以及用于构建所有电路的脚本。

1. 使用下面的内容创建一个 `circuit.circom` 文件：

```cpp
template Multiplier() {
   signal private input a;
   signal private input b;
   signal output c;
   c <== a*b;
}

component main = Multiplier();
```

此电路的目的是让我们向某人证明我们能够因式分解整数c。 具体来说，使用此电路，我们将能够证明我们知道两个数字（a和b）相乘得到c，而不会显示a和b。

这个电路有2个 private 输入信号，名为  `a` 和 `b` ，还有一个输出 `c`.

输入和输出使用`<==`运算符进行关联。 在circom中，<==运算符做两件事。 首先是连接信号。 第二个是施加约束。

在本例中，我们使用`<==`将`c`连接到`a`和`b`，同时将`c`约束为`a * b`的值，即电路做的事情是让强制信号 `c` 为 `a*b` 的值。

在声明 `Multiplier` 模板之后, 我们使用名为`main`的组件实例化它。

注意：编译电路时，必须始终有一个名为`main`的组件。

### 2.2 编译电路

现在，我们准备编译电路。 运行以下命令：

```bash
circom circuit.circom --r1cs --wasm --sym
```

如所见，circom 命令采用一个输入（要编译的电路，在本例中为circuit.circom）和三个命令选项：

- `--r1cs`: 生成 `circuit.r1cs` ( [r1cs](https://medium.com/@VitalikButerin/quadratic-arithmetic-programs-from-zero-to-hero-f6d558cea649) 电路的二进制格式约束系统).
- `--wasm`: 生成 `circuit.wasm` ( wasm 代码用来生成见证 witness  稍后再介绍).
- `--sym`:  生成 `circuit.sym` (以注释方式调试和打印约束系统所需的符号文件）

虽然您不需要知道它是什么或如何工作，但[r1cs](https://medium.com/@VitalikButerin/quadratic-arithmetic-programs-from-zero-to-hero-f6d558cea649)（或 Rank-1约束系统）是将代数电路转换为zk-snark的第一步。

## 3. 将编译后的电路载入 snarkjs

现在电路已经编译好了，我们将继续使用`snarkjs` 去创建证明。

> 我们随时可以通过输入`snarkjs --help` 来访问`snarkjs`的帮助

### 3.1 查看电路有关的信息

要显示电路的信息，可以运行：

```bash
snarkjs info -r circuit.r1cs
```

可以看到如下输出：

```plain
# Wires: 4
# Constraints: 1
# Private Inputs: 2
# Public Inputs: 0
# Outputs: 1
```

此信息与我们设计的电路的思维导图相吻合。 记住，我们有两个私有输入a和b，以及一个输出c。 我们指定的一个约束是`a * b = c`。

可以再检查一遍，通过运行以下命令来打印电路的约束：

```
snarkjs printconstraints -r circuit.r1cs -s circuit.sym
```

输出如下:

```
[  -1main.a ] * [  1main.b ] - [  -1main.c ] = 0
```

如果这看起来有些奇怪，请不要担心。 您可以忽略`1main`前缀，并将其读为：

```
(-a) * b - (-c) = 0
```

如果重新排列等式，则与`a * b = c`相同。

### 3.2  用 *snarkjs* 进行可信配置（Setup）

生成零知识证明的第一步需要所谓的“可信设置”（ **trusted setup**）。

关于可信设置确切解释超出了本教程的范围，让我们尝试在未进行正式定义的情况下说明一下为什么需要可信设置的“直觉”原因。

对可信设置的需求归结为这样一个事实：**证明者的隐私与确保不欺骗验证者之间是一种微妙的平衡**。

为了维持这种微妙的平衡，零知识协议需要使用一些随机性。

通常，此随机性被编码在验证者发送给证明者的质询中（challenge），并用于防止证明者作弊。

但是，随机性无法公开，因为它实质上是（可用来）生成伪造证据的后门。这意味着由可信实体应产生随机性。因此称为**可信设置**。

现在我们对自己的工作有了更好的“直觉”，让我们继续为电路创建一个“可信设置”（在这里因为是教程，我们还将扮演受信任实体的角色）。

现在为电路进行可信设置:

```
snarkjs setup  -r circuit.r1cs
```

默认 `snarkjs` 将寻找和使用 `circuit.r1cs`. 我们也可以用 `-r <circuit r1csFile>` 来指定一个电路文件。

setup 命令会产生一个证明和一个验证 key，他们对应 2 个文件： `proving_key.json` and `verification_key.json`

### 3.3. 计算见证（witness）

在创建任何证明之前，我们需要计算与（所有）电路约束匹配的所有电路信号。这些信号就是“见证”。

#### 为什么我们需要见证？

请记住，在零知识证明中，证明者需要向验证者证明她知道与电路的所有约束匹配的“信号集”，而不透露任何私有输入。 这组“信号”就是我们所说的见证信息（witness）。

重要的是，见证（witness）对验证者是保密的。 证明人仅使用它生成证明，证明她知道见证中包含的一组信号（包括私有信号）。

#### 我们需要什么来计算?

回顾 2.2, 我们生成了 `circom.wasm`  文件，它包含的wasm代码用来生成见证。

我们需要它以及一个我们称之为 `input.json`的文件，它包含给电路的输入信号。

拥有这两个文件后，我们将使用`snarkjs`的`calculatewitness`命令为我们计算见证。

`calculatewitness`命令将来自 `input.json` 的输入发送到  `circuit.wasm`，后者执行电路，计算（并跟踪）所有中间信号和最终输出。

这组信号（输入，中间信号和输出）就是“见证”（*witness*）。

在我们的例子中，我们没有任何中间信号，因为我们只有一个约束，即`a * b = c`，因此见证只是输入`a`和`b`以及输出`c`。

例如，假设我们想证明我们有能力因式分解33。我们需要证明我们知道两个数字 `a` 和 `b`相乘得到33。

很明显两个数字相乘得到 33 是 3 和 11，所以我们创建一个名为 `input.json` 的文件，其内容如下：

```
{"a": 3, "b": 11}
```

现在运行命令计算见证:

```
narkjs calculatewitness --wasm circuit.wasm --input input.json
```

这时会生成包含所有信号的见证文件  `witness.json` ， 可以打开看一看：

```
[
 "1",
 "33",
 "3",
 "11"
]
```

`33` 是输出信号,  `3`和`11` 是定义在`input.json`的输入信号.

> 除了输出，输入和中间信号之外，你还应该看到了见证的开头（数组的第一个条目）还包含一个虚拟变量“ 1”。 要了解为什么需要这个“ 1”，需要深入研究zk-proofs的细节，因此这超出了本文的范围。 如果您好奇，请参阅[Vitalik的文章]（https://medium.com/@VitalikButerin/quadratic-arithmetic-programs-from-zero-to-hero-f6d558cea649）。
>
> 您可能已经注意到，电路上没有任何东西可以阻止我们始终使用 1 和 数字本身作为 `a` 和 `b`（即设置“ a = 1”和“ b = 33”）。 我们稍后将处理此问题。

### 3.4 创建证明

现在我们已经生成了见证信息，我们可以创建证明了，使用以下命令：

```
snarkjs proof --witness witness.json --provingkey proving_key.json
```

这个命令默认会使用 ` prooving_key.json`  和  `witness.json`  文件去生成 `proof.json` 和 `public.json`

`proof.json` 文件包含了实际的证明。而 `public.json` 文件将仅包含公共的输入（当前的例子没有）和输出（当前的例子是 33）。

### 3.5 验证证明

实际上，在此阶段，将把`proof.json`和`public.json`文件都交给验证者。

但是，出于教程的目的，我们还将扮演验证者的角色。

借助证明以及公共输入和输出，我们现在可以向验证者证明我们知道一个或多个满足电路约束的私有信号，而无需透露有关那些私有信号的任何信息。

从验证者的角度来看，她可以验证我们是否知道见证中包含的一组私有信号，而无需访问它。 这是zk-proof背后魔术的核心！

更正式的说，通过使用proof.json，验证者可以检查证明者知道见证信息的公开输入和输出与`public.json`中的匹配。

由于我们扮演着验证者的角色，因此我们来验证一下证明，运行命令:

```bash
> snarkjs verify --verificationkey verification_key.json --proof proof.json --public public.json

OK
```

你应该看到OK已输出到您的控制台。 这表示证明有效。 如果证明无效，那么您将看到INVALID。

你可以通过创建一个名为`public-invalid.json`的新文件进行检查，该文件的公共输出为34，而不是33。

```
[
"34"
]
```

然后运行：

```bash
> snarkjs verify --verificationkey verification_key.json --proof proof.json --public public-invalid.json

INVALID
```

此时证明无效，那么您将看到INVALID。

## 3.6 漏洞修复

在第3.3节的末尾提到了一个漏洞，对于任何`c`，都没有阻止我们使用a = 1和 b = c（反之亦然）来满足电路约束的情况。

现在来通过在电路中添加一些额外的约束修复电路。

这里的技巧是使用0 不可求倒数的属性，我们约束不接受 1 作为任何一个输入，即`(a-1)` 不可求倒数的方式来约束电路。

如果 a 是 1 则 `(a-1)*inv = 1` 是不可能成立的， 通过 `1/(a-1)` 来计算 inv 。

修改电路：

```cpp
template Multiplier() {
   signal private input a;
   signal private input b;
   signal output c;
   signal inva;
   signal invb;

   inva <-- 1/(a-1);
   (a-1)*inva === 1;
   invb <-- 1/(b-1);
   (b-1)*invb === 1;

   c <== a*b;
}

component main = Multiplier();
```

**关于符号的几解释**：

您可能已经注意到，我们引入了两个新的运算符 : `<--` 和   `===` 。

`<--` 和  `-->` 操作符运算符只为信号分配一个值，而不创建任何约束。

`===` 操作符添加约束而不分配值。

如前所述，`<==` 为信号分配一个值并添加一个约束。 这意味着它只是 `<--`和 `===` 的组合。 但是，由于并非总是希望在同一步骤中同时完成这两个步骤，因此circom 的灵活性使我们可以将这一步分为两步。

**最后的想法**

事实证明，电路仍然存在一个细微的问题：由于运算是在[有限域](https://en.wikipedia.org/wiki/Finite_field)（Z_r）上进行的，因此我们需要确保乘法不会溢出。 幸运的是，我们可以通过将输入转换为二进制格式并检查范围来做到这一点。 不用担心这对您没有太大意义，我们将在以后的教程中介绍！

## 4. 链上证明

最后，我们将证明转换为正确的格式，然后在链上发布。

### 4.1 生成 Solidity 的证明

我们可以使用`snarkjs generateverifier`生成可验证零知识证明的[Solidity](https://learnblockchain.cn/categories/Solidity)智能合约。

> 智能合约是在去中心化网络（如以太坊）内部执行的计算机程序。 Solidity是在以太坊上编写智能合约的最受欢迎的语言之一。

从命令行运行：

```bash
snarkjs generateverifier --verificationkey verification_key.json --verifier verifier.sol
```

这个命令将使用到 `verification_key.json`  并生成一个 [solidity](https://learnblockchain.cn/docs/solidity/) 代码文件： `verifier.sol` 。

### 4.2 发布证明

可以复制`verifier.sol`代码到 [remix](https://learnblockchain.cn/tags/Remix) 进行部署。

`verifier.sol` 包含两个合约： Pairings 和 Verifier， 你只需要部署**Verifier** 合约。

可以使用Rinkeby，Kovan或Ropsten等测试网，也可以使用`Javascript VM`，也许在某些浏览器中，验证会花很长时间，并且可能会挂起页面，请知晓。

### 4.3 链上验证证明

上面生成的 Verifier 合约有一个 [view 视图函数](https://learnblockchain.cn/docs/solidity/contracts/functions.html?#view)  `verifyProof`， 如果证明和输入正确，这个函数会返回 true .

为了方便调用，可以使用snarkjs通过输入以下命令来生成调用的参数：

```bash
snarkjs generatecall --proof proof.json --public public.json
```

generatecall 使用了两个参数，证明文件（proof.json）及 公开的输入/输出(public.json), 命令行输出如下：

```
["0x03953a07c9c509de3372fdb737ad19fb79cd4291a76041172cbc9968b643d94a", "0x20bfda38f8dd6120883944368316a417432397aeef80e0603576a0eebeee23da"],
[["0x126a663a9029248f9f7ac141edee74686ab779d37f19393616919540f9c0949e", "0x09d9d071ffcf82ada05cd90ea3cd0bafc0bbcf29876daf5419800449d266b3ad"],["0x03eb926bc03778a37c4729349ad3f6be028b2a60a857ce4875f08891cd3be383", "0x08b4b648c3a2cc491f6f03b2ec3a797e7a691406b4f6967ee4bb8ec1d0306b59"]],
["0x1af6cf97cc5e672052feb44ba381147528bd9b25fa366f08a69a899f0d251faf", "0x15a911429c0e2c63cb90dd8b09f4f767e40292cf60e4e318a749da8cb601f55b"],
["0x0000000000000000000000000000000000000000000000000000000000000021"]
```

> 注意：snarkjs 可以接受自定义输入参数，但它也具有默认值，使事情变得容易。 例如，在以上两个步骤中，我们可以简单地运行snarkjs generateverifier，然后运行snarkjs generatecall。 默认情况下，snarkjs将包含我们指定的输入。 要了解有关命令（参数默认值）的更多信息，请从命令行运行snarkjs --help。

将命令的输出复制到 Remix 中的 `verifyProof` 方法的 parameters 字段中，点击 call 调用 `verifyProof` ，

![wxqmanJ](https://img.learnblockchain.cn/pics/20200609154830.png)

如果一切正常，方法应该返回 `true`。

如果仅更改参数中的任何位，则可以检查结果返回 false 。

## 探索更多

阅读我们的 [代码库](https://github.com/iden3/circom) 了解更多 circom 的特性。

我们写好了一些基本的电路，如：binaritzations、comparators, eddsa, hashes, merkle trees  等等，可以在[circomlib](https://github.com/iden3/circomlib) 找到，还有更多电路在开发中。

## 小结

对于开发人员而言，没有什么比使用buggy  编译器更糟糕的了。现在依旧是编译器的早期阶段，因此存在许多错误，并且需要完成许多工作。

如有任何问题，请与我们联系。哪怕是一小段修复 bug 的代码。

最后，享受[零知识证明](https://learnblockchain.cn/categories/zero)！

原文链接：

https://blog.iden3.io/first-zk-proof.html

https://iden3.io/blog/circom-and-snarkjs-tutorial2.html

