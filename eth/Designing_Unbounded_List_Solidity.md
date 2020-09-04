
# Designing an Unbounded List in Solidity
# 在Solidity中创建无限制列表

**In most applications, working with lists is fairly trivial. Most languages provide libraries for list handling, and we hardly need to worry about the details. However smart contracts are unlike "most applications", and we need to pay special attention to design restrictions imposed by the blockchain.**

**在大多数应用中，使用列表相当简单。大多数语言都提供用于处理列表的库，我们不必担心使用细节。但是，智能合约不同于“大多数应用程序”，我们需要特别注意区块链施加的设计限制。**

**[The full article source code is available on GitHub](https://github.com/kaxxa123/BlockchainThings/tree/master/UnboundedList)**

**在github中可以找到文中涉及的[完整代码](https://github.com/kaxxa123/BlockchainThings/tree/master/UnboundedList)**

## List Requirements
## 列表的特性

Consider a smart contract that encapsulates a list. Let say this list is storing addresses, but it could really be storing anything. We can summarize our basic requirements as follows:

我们先假定这个列表是用来存储地址类型的，但实际上这个列表可以存储任何内容。我们可以将基本要求总结如下：

1. Support for all CRUD operations: Create, Read, Update, Delete
1. 支持CRUD运算：创建、读取、更新、删除
2. Unbounded, callers can add as many items as they want.
2. 无限制，可以容纳任意数量的元素

## Adding/Removing List Elements
## 添加/删除列表元素

A smart contract platform like Ethereum adds some important considerations. Code that could run for years, gives the term unbounded a whole new meaning.

以太坊等智能合约平台增加了一些重要的考虑因素。可以运行多年的代码赋予术语“无限制”一个全新的含义。

We need a system where the gas consumption of adding and removing items is relatively constant and independent of the number of items added. It is not acceptable to have any sort of degradation (increase in gas cost) over time.

我们需要一个添加和删除元素消耗的gas是相对恒定的系统，并且与列表的元素个数无关，而且我们不希望随着时间的推移所需的gas增加。

For this reason, storing the list in a simple array is not an option. The main problem with a simple array is the management of gaps as items start being deleted. The more items are added/deleted, the more fragmented a simple array becomes, requiring some sort of compaction. With compaction, we easily end up with a function whose gas consumption is dependent on the number of listed elements. For example, a shift operation depends on the number of elements following the deleted element:

因为这个原因，将列表存储在简单数组中不是个好的选择。 简单数组的主要问题是随着开始删除元素，需要管理好元素之间的”间隙“。 添加/删除的元素越多，简单数组的会变得更碎片化，需要进行某种压缩。 我们很容易可以使用一个函数进行压缩，该函数gas消耗取决于所列元素的数量。 例如，移位操作取决于已删除元素后面的元素数量：

![](https://img.learnblockchain.cn/2020/08/12/15972164289107.jpg)

An alternative to compaction through shifting, is the filling of gaps as new items are created. However, this raise challenges related to gap tracking. Otherwise we could fill gaps by moving the last item to the deleted position. But moving items around is problematic when long lists are read in batches.

除了通过移动进行压缩，另一种方式是在创建新元素时填补空白。 但是，这对如何记录“间隙”提出了挑战。 或者，我们可以通过将最后一个元素移到已删除的位置来填补空白。 但是，当批量读取长列表时，移动元素会出现问题。

To avoid such problems we implement a 2-way linked list. With this solution adding/removing entries gives us constant gas consumption independently of the list size. Adding an item involves attaching a new entry to the tail of the list. Removing an item involves updating the pointers of the elements immediately preceding and following the deleted element. Most importantly, removing items does not create gaps.

为了避免此类问题，我们实现了双向链接列表。 使用此解决方案，添加/删除元素消耗gas量与列表大小无关。 添加元素将新条目附加到列表的末尾。 删除元素只需要更新已删除元素之前和之后的元素的指针。 最重要的是，删除元素不会产生“间隙”。

## List State Storage
## 列表状态变量储存结构

Let's take a look at the [smart contract code](https://github.com/kaxxa123/BlockchainThings/blob/master/UnboundedList/contracts/ListContract.sol), specifically at the state variables for storing the list. Each list element is made up of 3 pieces of information. Two pointers for linking the previous and next element, plus the element data itself.

我们来看看[这个](https://github.com/kaxxa123/BlockchainThings/blob/master/UnboundedList/contracts/ListContract.sol)智能合约代码,尤其是用于储存的状态变量。每一个列表元素由3部分信息，一个指向前一个元素，一个指向后一个元素，再加上元素数据本身。

```
struct ListElement {
    uint256 prev;
    uint256 next;
    address addr;
}
```

The list elements are stored as an id to `ListElement` mapping:
`mapping(uint256 => ListElement) private items;`

列表相当于编号和`ListElement`结构体的映射关系
`mapping(uint256 => ListElement) private items;`

The `ListElement prev/next` values link elements together by storing the id of the preceding and subsequent elements.

ListElement结构体中的prev和next值通过储存前一个编号和后一个编号将元素串起来。

To complete our review of state variables, our contract also includes:
`uint256 public nextItem;`
`uint256 public totalItems;`

为了帮助可以查看状态变量，合约中还包括了：
`uint256 public nextItem;`
`uint256 public totalItems;`

`nextItem` holds the id to be used on creating the next element. It ensures id uniqueness and that we never resurrect deleted items.

`nextItem`储存着下一个元素的编号，可以保证编号的唯一性，以及删除的编号不再被使用。

`totalItems` holds the list element total count. The need for this variable is application specific. Our smart contract doesn't truly need it, so we could delete it and save gas. However I am including it to make a point relevant to applications that would need such a total.

`totalItems`储存着列表中总元素的个数。使用这个变量的原因也是根据应用而定的。实际上我们现在这个合约中并非一定需要，我们可以删除来节省gas，然而我这里使用是为了防止其他应用中需要。

Computing this total by traversing the list again leads to a function whose gas consumption is dependent on the list length. Thus, for functions that consume gas, the total has to be computed on adding/removing list items (as shown here) not through traversal.

遍历列表来统计列表元素的个数会导致gas的消耗随着列表长度不同而不同。

## The Zero Item Value is Invalid
## 零元素是无效的

In my list implementation there is an application specific assumption to be aware of. Here we have a list of addresses and thus the item data is held in `ListElement addr`. This can of course be replaced by any other set of variables. No problem there.

在我设计的列表中，要注意有一个特定于该应用程序的假设。 这里我们有一个地址列表，因此数据被保存在`ListElement addr`中。 当然，你可以用任何其他变量代替。

What is important, is the role of the default address value i.e. the Zero Value. My code includes the very convenient assumption that any item having an address of zero is invalid. We can work around this limitation. However in all cases we will need some way to identify invalid (uninitialized) items.

重要的是默认地址值（即零值）的影响。 我的代码包含一个非常方便的假设，即任何地址为零都是无效的。 我们可以解决此限制。 但是，在所有情况下，我们都需要某种方法来识别无效（未初始化）的元素。

To understand this point let's refer to the [Solidity documentation](https://solidity.readthedocs.io/en/v0.6.0/types.html?highlight=mapping#mapping-types) for mappings:

要了解这一点，请参考[Solidity文档](https://solidity.readthedocs.io/en/v0.6.0/types.html?highlight=mapping#mapping-types)映射：

*"You can think of mappings as hash tables, which are virtually initialised such that every possible key exists and is mapped to a value whose byte-representation is all zeros, a type's default value."*

*映射可以视作哈希表 它们在实际的初始化过程中创建每个可能的key， 并将其映射到字节形式全是零的值：一个类型的默认值*

So our mapping immediately looks as if it is prepopulated by `ListElement` values where `addr` is zero. Treating zero as invalid allows us to identify which elements were truly created by our smart contract. If we wanted `addr` zero to be valid, we would need some other flag. For example we could give a special meaning to the most significant bit of `prev`.

所以我们的映射就可以理解成提前生成好了`addr`为零的一系列`ListElement`。把零值作为无效值可以帮助我们区别出那些是智能合约产生。如果我们希望地址为零值为有效的，那么我们需要其他的一些标识。比我，我们可以给`prev`多一点的含义。

But for simplicity I won't do that here. Just keep in mind that using mappings creates the need for us to identify which items we truly created.

但是为了简单起见，我在这里不做。 请记住，使用映射可以帮助我们确定哪些是我们自己生成的元素。

## The Reserved Zero ID
## 预留的零编号

Another little detail to be aware of is that the mapping item for id zero is reserved. Thus it can never be created/deleted through the contract interface.

要注意的另一个小细节是保留ID为零的映射项。 因此，永远不能通过合约接口创建/删除它。

The item for id zero stores the pointers of the first and last list items. The first list item is:

编号为零的元素储存着第一次和最后一个列表元素的指针。第一个元素为：
`items[0].next`

The last list item is:
最后一个元素为：
`items[0].prev`

Having anchors to these items is important for us to read and append to the list.

通过这两个值的直接引用可以帮我们读取和添加元素。

## Function Signatures
## 函数签名

So far we covered all relevant details for adding, removing and updating items. Reading an unbounded list is also very interesting. But before looking into that, here are the function signatures defining the contract interface:

到目前为止，我们已经涵盖了有关添加，删除和更新元素的所有相关详细信息。 读取无限制列表也非常有趣。但是在研究之前，先定义一下合约接口：

```
function add(address addr) external
function remove(uint256 id) external
function update(uint256 id, address addr) external
function firstItem() public view returns (uint256)
function lastItem() public view returns (uint256)
function nextItem() public view returns (uint256)
function totalItems() public view returns (uint256)
function read(uint256 start, uint256 toRead) external view 
         returns (address[] memory addrList, uint256 next)
```

Except for read, all function signatures should be fairly intuitive. Otherwise take a look at the inline comments preceding every function.

除了读取元素之外，其他所有函数签名都应该非常直观。 否则，请查看每个函数之前的内联注释。

## List Reading
## 列表读取

With a list that could potentially include many elements, reading also presents its own challenges. Our `read` function is of type view, hence it does not consume gas. However, this doesn't mean that the function is unbound in what it can do. Memory consumption is the most obvious limitation. We avoid this problem by allowing the caller to read items in batches.

列表可能包含许多元素，因此read也提出了自己的挑战。 我们的“读取”功能是视图类型，因此它不消耗气体。 但是，这并不意味着该函数在其功能上没有约束。 内存消耗是最明显的限制。 我们通过允许调用者分批读取项目避免了此问题。


Let's take a close look at the function signature:
`function read(uint256 start, uint256 toRead) external view`
`returns (address[] memory addrList, uint256 next)`

我们来看下函数签名
`function read(uint256 start, uint256 toRead) external view`
`returns (address[] memory addrList, uint256 next)`


Parameters:
参数

|   |   |
|--- |--- |
| `start` | The item id to start reading from. Setting `start` to zero means that we want to start reading from the first list item. |
| `toRead` | The number of items to be returned. Setting `toRead` to zero means that we want to read all items. |

|   |   |
|--- |--- |
| `start` | 开始读取元素编号，如果`start`参数为零，代表从第一个元素开始读取  |
| `toRead` | 需要返回的元素个数，如果`toRead`参数为零，代表读取所有的元素|

Return Values:

返回值

|   |   |
|--- |--- |
| `addrList` | List of items read from the `start` position. In our example this is an address array. |
| `next` | The next item id from which reading is to be continued or zero if we reached the list end. |

|   |   |
|--- |--- |
| `addrList` | 从`start`编号开始读取的元素列表。在我们的例子中是一个地址数组。|
| `next` | 接下来读取元素的编号，如果为零则代表读取完毕。|


Whereas this solution allows us to safely read very long lists, breaking down the process into multiple calls introduces another challenge. What happens if someone deletes an item while we are reading the list in batches? The problem is demonstrated below.

尽管此解决方案使我们能够安全地读取很长的列表，但将流程分为多个调用却带来了另一个挑战。 如果在我们批量读取列表时有人删除了元素，会发生什么？ 该问题如下所示。

Consider a case where the caller is reading batches of 3 items at a time. Here is the initial list:

假设调用者批量一次读取3个元素，以下是最原始的列表
![](https://img.learnblockchain.cn/2020/08/12/15972167827165.jpg)


Remember, a start value of zero identifies the first list item. In this case id 1.

记住`start`参数为零表示从第一个元素开始读取，在这里例子中就是id为1的元素。

Caller1> `read(0,3) Returns:([Item1, Item2, Item3],4)`

调用者1> `read(0,3) Returns:([Item1, Item2, Item3],4)`

Caller1> `read(4,3) Returns:([Item4, Item5, Item6], 7)`

调用者1> `read(4,3) Returns:([Item4, Item5, Item6], 7)`

Caller2> `remove(7)`

调用者2> `remove(7)`

![](https://img.learnblockchain.cn/2020/08/12/15972168276654.jpg)

Caller1> `read(7,3) Returns: Failed: "Invalid reading position."`

调用者1> `read(7,3) 返回: Failed: "Invalid reading position."`

At this point caller1 doesn't know the next reading position.

Caller1 solves this problem with the help of a stack. For every successful call, caller1 pushes on the stack the read start parameter and the returned item array. On failure, caller1 backtracks by popping results from the stack and repeats the read operation. Let's look at an example:

此时，调用者1不知道下一个读取位置。

调用者1可以使用堆栈来解决此问题。 对于每次成功的调用，调用者1会将读取开始参数和返回的项目数组压入堆栈。 失败时，c调用者1通过从堆栈中弹出结果并重复读取操作。 让我们看一个例子：


Caller1>
`read(<span 0,3) Returns: ([Item1, Item2, Item3], 4)`
`push stack:`

调用者1>
`read(<span 0,3) Returns: ([Item1, Item2, Item3], 4)`
`压入堆栈`

|  |
|---|
| `([Item1, Item2, Item3], 0)` |


Caller1>
`read(4,3) Returns: ([Item4, Item5, Item6], 7)`
`push stack:`

调用者1>
`read(4,3) Returns: ([Item4, Item5, Item6], 7)`
`压入堆栈`

|  |
|---|
| `([Item4, Item5, Item6], 4)` |
| `([Item1, Item2, Item3], 0)` |

Caller2>
`remove(7)`

调用者2>
`remove(7)`


Caller1>
`read(7,3) Returns: Failed: "Invalid reading position."`
`pop stack: ([Item4, Item5, Item6], 4)`

调用者1>
`read(7,3) Returns: Failed: "Invalid reading position."`
`弹出堆栈: ([Item4, Item5, Item6], 4)`

| `([Item1, Item2, Item3], 0)` |
|---|

Caller1>
`read(4,3) Returns: ([Item4, Item5, Item6], 8)`
`push stack:`

调用者1>
`read(4,3) Returns: ([Item4, Item5, Item6], 8)`
`压入堆栈:`

|  |
|---|
| `([Item4, Item5, Item6],4)` |
| `([Item1, Item2, Item3], 0)` |

Caller1>
`read(8,3) Returns: ([Item8, Item9], 0)`
`push stack:`


调用者1>
`read(8,3) Returns: ([Item8, Item9], 0)`
`压入堆栈:`

|  |
|---|
| `([Item8, Item9], 8)` |
| `([Item4, Item5, Item6], 4)` |
| `([Item1, Item2, Item3], 0)` |

The last read returned a next id of zero. Indicating that we read all list items.

最后一次返回0，表示已经读取完毕。

Check the [function pagedRead in 02_read_stack.js](https://github.com/kaxxa123/BlockchainThings/blob/master/UnboundedList/test/02_read_stack.js) for an example of how a client would implement paged reading.

通过查看[function pagedRead in 02_read_stack.js](https://github.com/kaxxa123/BlockchainThings/blob/master/UnboundedList/test/02_read_stack.js) 学习如何应用列表进行分页阅读

## Useful Links
## 相关链接

[Source code and truffle project for this article](https://github.com/kaxxa123/BlockchainThings/tree/master/UnboundedList)

本文中涉及[truffle 工程源码](https://github.com/kaxxa123/BlockchainThings/tree/master/UnboundedList)