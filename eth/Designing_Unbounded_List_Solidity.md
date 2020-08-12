
# Designing an Unbounded List in Solidity

**In most applications, working with lists is fairly trivial. Most languages provide libraries for list handling, and we hardly need to worry about the details. However smart contracts are unlike "most applications", and we need to pay special attention to design restrictions imposed by the blockchain.**

**[The full article source code is available on GitHub](https://github.com/kaxxa123/BlockchainThings/tree/master/UnboundedList)**

## List Requirements

Consider a smart contract that encapsulates a list. Let say this list is storing addresses, but it could really be storing anything. We can summarize our basic requirements as follows:

1. Support for all CRUD operations: Create, Read, Update, Delete
2. Unbounded, callers can add as many items as they want.

## Adding/Removing List Elements

A smart contract platform like Ethereum adds some important considerations. Code that could run for years, gives the term unbounded a whole new meaning.

We need a system where the gas consumption of adding and removing items is relatively constant and independent of the number of items added. It is not acceptable to have any sort of degradation (increase in gas cost) over time.

For this reason, storing the list in a simple array is not an option. The main problem with a simple array is the management of gaps as items start being deleted. The more items are added/deleted, the more fragmented a simple array becomes, requiring some sort of compaction. With compaction, we easily end up with a function whose gas consumption is dependent on the number of listed elements. For example, a shift operation depends on the number of elements following the deleted element:

![](https://img.learnblockchain.cn/2020/08/12/15972164289107.jpg)

An alternative to compaction through shifting, is the filling of gaps as new items are created. However, this raise challenges related to gap tracking. Otherwise we could fill gaps by moving the last item to the deleted position. But moving items around is problematic when long lists are read in batches.

To avoid such problems we implement a 2-way linked list. With this solution adding/removing entries gives us constant gas consumption independently of the list size. Adding an item involves attaching a new entry to the tail of the list. Removing an item involves updating the pointers of the elements immediately preceding and following the deleted element. Most importantly, removing items does not create gaps.

## List State Storage

Let's take a look at the [smart contract code](https://github.com/kaxxa123/BlockchainThings/blob/master/UnboundedList/contracts/ListContract.sol), specifically at the state variables for storing the list. Each list element is made up of 3 pieces of information. Two pointers for linking the previous and next element, plus the element data itself.

```
struct ListElement {
    uint256 prev;
    uint256 next;
    address addr;
}
```

The list elements are stored as an id to `ListElement` mapping:
`mapping(uint256 => ListElement) private items;`

The `ListElement prev/next` values link elements together by storing the id of the preceding and subsequent elements.

To complete our review of state variables, our contract also includes:
`uint256 public nextItem;`
`uint256 public totalItems;`

`nextItem` holds the id to be used on creating the next element. It ensures id uniqueness and that we never resurrect deleted items.

`totalItems` holds the list element total count. The need for this variable is application specific. Our smart contract doesn't truly need it, so we could delete it and save gas. However I am including it to make a point relevant to applications that would need such a total.

Computing this total by traversing the list again leads to a function whose gas consumption is dependent on the list length. Thus, for functions that consume gas, the total has to be computed on adding/removing list items (as shown here) not through traversal.

## The Zero Item Value is Invalid

In my list implementation there is an application specific assumption to be aware of. Here we have a list of addresses and thus the item data is held in `ListElement addr`. This can of course be replaced by any other set of variables. No problem there.

What is important, is the role of the default address value i.e. the Zero Value. My code includes the very convenient assumption that any item having an address of zero is invalid. We can work around this limitation. However in all cases we will need some way to identify invalid (uninitialized) items.

To understand this point let's refer to the [Solidity documentation](https://solidity.readthedocs.io/en/v0.6.0/types.html?highlight=mapping#mapping-types) for mappings:

*"You can think of mappings as hash tables, which are virtually initialised such that every possible key exists and is mapped to a value whose byte-representation is all zeros, a type's default value."*

So our mapping immediately looks as if it is prepopulated by `ListElement` values where `addr` is zero. Treating zero as invalid allows us to identify which elements were truly created by our smart contract. If we wanted `addr` zero to be valid, we would need some other flag. For example we could give a special meaning to the most significant bit of `prev`.

But for simplicity I won't do that here. Just keep in mind that using mappings creates the need for us to identify which items we truly created.

## The Reserved Zero ID

Another little detail to be aware of is that the mapping item for id zero is reserved. Thus it can never be created/deleted through the contract interface.

The item for id zero stores the pointers of the first and last list items. The first list item is:
`items[0].next`

The last list item is:
`items[0].prev`

Having anchors to these items is important for us to read and append to the list.

## Function Signatures

So far we covered all relevant details for adding, removing and updating items. Reading an unbounded list is also very interesting. But before looking into that, here are the function signatures defining the contract interface:

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

## List Reading

With a list that could potentially include many elements, reading also presents its own challenges. Our `read` function is of type view, hence it does not consume gas. However, this doesn't mean that the function is unbound in what it can do. Memory consumption is the most obvious limitation. We avoid this problem by allowing the caller to read items in batches.

Let's take a close look at the function signature:
`function read(uint256 start, uint256 toRead) external view`
`returns (address[] memory addrList, uint256 next)`

Parameters:

|   |   |
|--- |--- |
| `start` | The item id to start reading from. Setting `start` to zero means that we want to start reading from the first list item. |
| `toRead` | The number of items to be returned. Setting `toRead` to zero means that we want to read all items. |

Return Values:

|   |   |
|--- |--- |
| `addrList` | List of items read from the `start` position. In our example this is an address array. |
| `next` | The next item id from which reading is to be continued or zero if we reached the list end. |


Whereas this solution allows us to safely read very long lists, breaking down the process into multiple calls introduces another challenge. What happens if someone deletes an item while we are reading the list in batches? The problem is demonstrated below.

Consider a case where the caller is reading batches of 3 items at a time. Here is the initial list:

![](https://img.learnblockchain.cn/2020/08/12/15972167827165.jpg)


Remember, a start value of zero identifies the first list item. In this case id 1.

Caller1> `read(0,3) Returns:([Item1, Item2, Item3],4)`
Caller1> `read(4,3) Returns:([Item4, Item5, Item6], 7)`

Caller2> `remove(7)`

![](https://img.learnblockchain.cn/2020/08/12/15972168276654.jpg)

Caller1> `read(7,3) Returns: Failed: "Invalid reading position."`

At this point caller1 doesn't know the next reading position.

Caller1 solves this problem with the help of a stack. For every successful call, caller1 pushes on the stack the read start parameter and the returned item array. On failure, caller1 backtracks by popping results from the stack and repeats the read operation. Let's look at an example:

Caller1>
`read(<span 0,3) Returns: ([Item1, Item2, Item3], 4)`
`push stack:`

|  |
|---|
| `([Item1, Item2, Item3], 0)` |


Caller1>
`read(4,3) Returns: ([Item4, Item5, Item6], 7)`
`push stack:`

|  |
|---|
| `([Item4, Item5, Item6], 4)` |
| `([Item1, Item2, Item3], 0)` |

Caller2>
`remove(7)`

Caller1>
`read(7,3) Returns: Failed: "Invalid reading position."`
`pop stack: ([Item4, Item5, Item6], 4)`

| `([Item1, Item2, Item3], 0)` |
|---|

Caller1>
`read(4,3) Returns: ([Item4, Item5, Item6], 8)`
`push stack:`

|  |
|---|
| `([Item4, Item5, Item6],4)` |
| `([Item1, Item2, Item3], 0)` |

Caller1>
`read(8,3) Returns: ([Item8, Item9], 0)`
`push stack:`

|  |
|---|
| `([Item8, Item9], 8)` |
| `([Item4, Item5, Item6], 4)` |
| `([Item1, Item2, Item3], 0)` |

The last read returned a next id of zero. Indicating that we read all list items.

Check the [function pagedRead in 02_read_stack.js](https://github.com/kaxxa123/BlockchainThings/blob/master/UnboundedList/test/02_read_stack.js) for an example of how a client would implement paged reading.

## Useful Links

[Source code and truffle project for this article](https://github.com/kaxxa123/BlockchainThings/tree/master/UnboundedList)
