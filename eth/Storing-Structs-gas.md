
# Gas 优化 - 如何优化存储

> * [原文链接](https://medium.com/@novablitz/storing-structs-is-costing-you-gas-774da988895e)， 作者：[Nova Blitz](https://medium.com/@novablitz)


我们会很快进入一些非常技术性的Solidity概念。 

## 变量合并

在[Solidity](https://learnblockchain.cn/docs/solidity/)（用于以太坊智能合约的编程语言）中，你拥有“内存（memory）”（想像计算机上的RAM）和“存储（storage）”（想像硬盘驱动器）。 两者均以32字节的块为操作单位（一个字节大约是一个字母）。 在Solidity 中，内存价格便宜（存储或更新值仅需要 3 gas）。 存储很昂贵（存储新的值需要20,000 gas，更新值需要 5000 gas）。


大多数dApp和游戏都需要将数据存储在区块链上，因此必须与存储进行交互。 优化智能合约的gas成本是一项重要的工作。


这是一个简单的区块链游戏可能存储的数据：

```
address owner;
uint64 creationTime;
uint256 dna;
uint16 strength;
uint16 race;
uint16 class;
```


如果我们只是直接存储这些值，则可能需要执行以下操作：


```
mapping(uint256 => address) owners;
mapping(uint256 => uint64) creationTime;
mapping(uint256 => uint256) dna;
mapping(uint256 => uint16) strength;
mapping(uint256 => uint16) race;
mapping(uint256 => uint16) class;
```


存储这些数据需要花费120,000 gas(12万)，这确实非常昂贵！ 当我们构造一个结构体并将其存储时，我们会得到更好的结果：


```js
struct GameCharacter {
  address owner;
  uint64 creationTime;
  uint256 dna;
  uint16 strength;
  uint16 race;
  uint16 class;
}

mapping(uint256 => GameCharacter) characters;
```


现在，当我们存储此结构体时，我们支付的费用更少：75000 gas 。 编译器会将 owner 和creationTime 巧妙地打包到同一插槽中，因此花费25,000，而不是40,000 （译者注，因为第2个写值被当做更新）。 同样效果却更少的花费，不过，我们可以做得更好：


```js
struct GameCharacter {
  address owner;
  uint48 creationTime;
  uint16 strength;
  uint16 race;
  uint16 class;
  uint256 dna;
}
mapping(uint256 => GameCharacter) characters;
```

新代码的花费：60,000 gas！ 我们在此处进行了两项更改：首先，将dna移至末尾。 它是一个uint256，已经是32个字节，因此不能包含任何其他的内容。 然后，我们将 creationTime 的类型从uint64 更改为uint48。 这使前五个字段全部打包成32个字节。 时间戳记不必超过uint48 类，而且Solidity（与其他大多数语言不同）允许uint为8的任意倍数，而不仅仅是8/16/32/64等（如果你迫切地需要空间， 你可以将时间戳使用uint32，在2106年它可能导致问题之前，你可能已经死了 ：） 。


我们将费用减半了 -- 很好，对吧？ 好吧，不 -- 我们希望所有功能的 gas 消耗都尽可能小，并且仍可以通过将前5个数据字段编码为单个 uint256 来降低成本：


```js
mapping(uint256 => uint256) characters;
mapping(uint256 => uint256) dnaRecords;
function setCharacter(uint256 _id, address owner, uint256 creationTime, uint256 strength, uint256 race, uint256 class, uint256 dna) 
    external 
{
    uint256 character = uint256(owner);
    character |= creationTime<<160;
    character |= strength<<208;
    character |= race<<224;
    character |= class<<240;
    characters[_id] = character;
    dnaRecords[_id] = dna;
}

function getCharacter(uint256 _id) 
    external view
returns(address owner, uint256 creationTime, uint256 strength, uint256 race, uint256 class, uint256 dna) {
    uint256 character = characters[_id];
    dna = dnaRecords[_id];
    owner = address(character);
    creationTime = uint256(uint40(character>>160));
    strength = uint256(uint16(character>>208));
    race = uint256(uint16(character>>224));
    class = uint256(uint16(character>>240));
}

```


将数据存储为 uint256 只会花费40,000多gas -- 仅进行两次存储操作，再加上一些移位和按位或运算。 考虑到我们最初为120,000gas，这是一个很大的进步！ 使用此方法检索数据也要便宜一些。 请注意，这两个函数不会执行任何错误检查-你需要自己执行此操作，以确保所有输入的最终值都不会超过其最大值（但你必须在所有这些实现中进行相同的检查）。


## 编码与解码


上面的代码中可能有一些字符让你感觉陌生。 让我们来一探究竟：


```
|=
```


这是按位或赋值运算符。 用来组合两个二进制值（我们在计算机上，所以一切都是二进制的），方法是“如果其中任一位为1，则结果中的该位为1”。 我们可以在这里使用它，因为我们以`uint256(address)`开头，这意味着我们知道在位160之上的所有位均为0。


```
<<
```


这是左移位运算符。 它取一个数字的位，然后将它们向左移动。 因此，`creationTime<<160` 并将creationTime移至结果代码中的插槽160–207中。 将移位和按位或赋值运算相结合，就可以构建编码。


```
>>
```


这是右移位运算符。 它的工作方式与`<<`类似，但方向相反。 我们可以使用此方法从编码数据转换回来。 但是，我们还需要：

```
uint256(uint48())
```


这利用了solidity编译器的功能。 如果将uint256转换为uint48，则会丢弃所有高于位 48 的位。 这对于我们的目的而言是完美的，因为我们知道 `creationTime` 的长度为48位，因此仅提取所需的数据。


使用这些技术，我们可以显着提高智能合约的性能。

## 使用数据


现在你已经有了数据存储，你可能需要在函数之间传递数据。 除非你的应用程序像这里描述的那样简单，否则你将遇到16个局部变量的堆栈限制。 因此，你需要将数据作为结构体传递到内存中。 此结构体看起来与之前显示的结构略有不同：

```
struct GameCharacter {
  address owner;
  uint256 creationTime;
  uint256 strength;
  uint256 race;
  uint256 class;
  uint256 dna;
}

function getCharacterStruct(uint256 _id) 
    external view
returns(GameCharacter memory _character) {
    uint256 character = characters[_id];
    _character.dna = dnaRecords[_id];
    _character.owner = address(character);
    _character.creationTime = uint256(uint40(character>>160));
    _character.strength = uint256(uint16(character>>208));
    _character.race = uint256(uint16(character>>224));
    _character.class = uint256(uint16(character>>240));
}
```


所有字段均为uint256。 这是 solidity 中最有效的数据类型。 内存中的变量（甚至是结构体）根本没有打包，因此在内存中使用uint16不会获得任何好处，而且由于solidity必须执行额外的操作才能将uint16转换为uint256进行计算，所以你也许会迷失方向。


## 总结

我们确实在1980年代早期编写了一个兔子洞编程-对数据进行编码，需要关注我们可以从代码中抽出的每一个小优化。 编写Solidity不同于编写现代语言，这是一种不同的”物种" - 以太坊区块链的限制意味着你正在有效地为功能不如1973 Apple 1 。

每一点细微的优化都会帮助你实现更有效的存储方法， 来为你和你的用户节省一些gas。









