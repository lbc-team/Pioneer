# Solidity 0.8.23 发布公告

今天，我们宣布发布了 Solidity 编译器 [v0.8.23](https://github.com/ethereum/solidity/releases/tag/v0.8.23 "https://github.com/ethereum/solidity/releases/tag/v0.8.23")。这个最新版本编译器旨在纯粹修复 bug，包括修复一个低严重性重要的 bug。

根据我们的调查，我们预见现实世界不会有该 bug 实例被用作漏洞利用或攻击向量，因此，我们评估其整体严重性为低。

这个版本还引入了一个小改变，优化器设置更加直观。自 v0.8.21 起，禁用 `optimizer.details.yul` 设置不再阻止编译器运行 [`UnusedPruner` 步骤](https://docs.soliditylang.org/en/v0.8.23/internals/optimizer.html#unused-pruner "https://docs.soliditylang.org/en/v0.8.23/internals/optimizer.html#unused-pruner")，我们认为这是防止堆栈问题的内部机制的一个重要部分。该步骤仍然可以被禁用 - 通过显式提供一个空的优化序列 - 但这需要名义上启用 Yul 优化器，这有时会导致用户启用整个优化器并无意中包含额外的优化。现在可以独立于其他设置使用空序列。

## 重要的 Bug 修复

### 修复无效的 `verbatim` 重复 bug

用户报告了一个块重复 bug，导致除了 verbatim 指令内容不同之外相同的块被视为等效，因此合并为一个单一的块。新版本修复了这个 bug。

该 bug 自版本 `0.8.5` 存在，引入了 `verbatim`，并且只影响启用优化的纯 Yul 编译。在内联汇编块中使用的 Solidity 代码或 Yul 不会触发它。

阅读我们的[博客文章描述该 bug](https://blog.soliditylang.org/2023/11/08/verbatim-invalid-deduplication-bug/ "https://blog.soliditylang.org/2023/11/08/verbatim-invalid-deduplication-bug/")，了解它是如何表现的，可能受到影响的合约类型以及其他技术细节。

## 更新日志

### 编译器特性

* 命令行界面：现在始终可以提供一个空的 `--yul-optimizations` 序列。
* 标准 JSON 接口：现在始终可以提供一个空的 `optimizerSteps` 序列。

## 如何安装/升级

要升级到 Solidity 编译器的最新版本，请按照我们文档中提供的[安装说明](https://docs.soliditylang.org/en/v0.8.23/installing-solidity.html "https://docs.soliditylang.org/en/v0.8.23/installing-solidity.html")。

你可以在这里下载 Solidity 的新版本：[v0.8.23](https://github.com/ethereum/solidity/releases/tag/v0.8.23 "https://github.com/ethereum/solidity/releases/tag/v0.8.23")。如果你想从源代码构建，请不要使用 GitHub 自动生成的源代码存档。而是使用 [`solidity_0.8.23.tar.gz`](https://github.com/ethereum/solidity/releases/download/v0.8.23/solidity\_0.8.23.tar.gz "https://github.com/ethereum/solidity/releases/download/v0.8.23/solidity\_0.8.23.tar.gz")，并查看[我们的源代码构建文档](https://docs.soliditylang.org/en/v0.8.23/installing-solidity.html#building-from-source "https://docs.soliditylang.org/en/v0.8.23/installing-solidity.html#building-from-source")。

我们建议所有 Solidity 开发者始终升级到 Solidity 的最新版本，以便利用改进、优化，最重要的是 bug 修复。

最后，我们要感谢所有帮助实现这个发布的贡献者！
