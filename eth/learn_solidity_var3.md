> * 译文出自：[登链翻译计划](https://github.com/lbc-team/Pioneer)
> * 译者：[Tiny 熊](https://learnblockchain.cn/people/15)
> * 译者：[翻译小组](https://learnblockchain.cn/people/412)
> * 本文永久链接：[learnblockchain.cn/article…](https://learnblockchain.cn/article/1)
> * https://medium.com/better-programming/learn-solidity-variables-part-3-3b02ca71cf06 [wissal haji](https://wissal-haji.medium.com/?source=post_page-----3b02ca71cf06--------------------------------)



## 跟我学 Solidity ：引用变量

> 引用类型，应明确指定数据位置



欢迎阅读`跟我学习 Solidity `系列中的另一篇文章。在[上一篇文章](https://learnblockchain.cn/article/1759),中，我们了解了数据位置的工作方式以及何时可以使用以下三个位置：`memory`，`storage`和`calldata`。

在本文中，我们将继续学习Solidity中的变量。这次，我们将重点放在引用类型上，该引用类型应显式指定数据位置，正如我们在前几篇文章中提到的那样。我们还将看到如何定义映射，枚举和常量。

## Arrays(数组)

在[Solidity](https://learnblockchain.cn/docs/solidity/)中，我们有两种类型的数组：存储数组和内存数组。

### 存储数组(Storage arrays)

这些数组被声明为状态变量，并且可以具有固定长度或动态长度。

动态存储数组可以调整数组的大小，它们通过访问`push()`和`pop()`方法来调节长度。



```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract A {
      uint256[] public numbers;// 动态长度数组
      address[10] private users; // 固定长度数组
      uint8 users_count;
      
      function addUser(address _user) external {
          require(users_count < 10, "number of users is limited to 10");
          users[users_count] = _user;
          users_count++;
      }
      
      function addNumber(uint256 _number) external {
          numbers.push(_number);
      }

```

### 内存数组(Memory arrays)

这些数组以` memory`作为其数据位置声明。它们也可以具有固定长度或动态长度，但是不能调整动态大小的内存数组的大小(即，不能调用`push()`和`pop()`方法)，数组的大小必须预先计算。

使用`new`关键字声明动态大小的内存数组，如下所示：

```
Type[] memory a = new Type[](size)
```

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract B {
     
     function createMemArrays() external view {
         uint256[20] memory numbers;
         numbers[0] = 1;
         numbers[1] = 2;
         
         uint256 users_num = numbers.length;
         address[users_num] memory users1; // 错误 :  应该是整数常量或常量表达式

         address[] memory users2 = new address[](users_num);
         users2[0] = msg.sender; // OK
         users2.push(msg.sender); // 错误 : member push is not available
         
     }
      
}
```


这里要提到的另一点是关于何时使用内存数组并编写如下内容：

```
uint256[] memory array;
array[0] = 1;
```

你不会收到任何警告，但最终将得到无效的操作码，因为根据[内存中布局](https://learnblockchain.cn/docs/solidity/internals/layout_in_memory.html)的描述，`array`将指向零插槽，因此切勿写入。请记住，在使用数组之前，请务必先对其进行初始化，以便获取有效的地址。

### 数组切片(Array slices)

数组切片只能与`calldata`数组一起使用，形式为`x[start:end]`。切片的第一个元素是` x [start]`，最后一个元素是` x[end-1]`。

开始和结束都是可选的：开始默认为0，结束默认为数组的长度。

## 特殊的动态大小数组

1. ` byte[]`和`bytes`

这些数组可以保存任意长度的原始字节数据。两者之间的区别在于，` byte []`遵循数组类型的规则，并且如文档 [Solidity中的内存数组的描述](https://learnblockchain.cn/docs/solidity/internals/layout_in_memory.html)，数组的元素总是占据32个字节的倍数。这意味着如果一个元素的长度小于32字节的倍数，则将对其进行填充，直到其适合所需的大小为止。

对于`byte`数组，每个元素将浪费31个字节，而`bytes`或`string`不是这种情况。我要提醒你，从内存中读取或写入一个字(32个字节)会消耗 3 gas，这就是为什么建议使用`bytes`而不是`byte[]`的原因。

2. `string`

字符串是UTF-8数据的动态数组。与其他语言相反，Solidity中的string不提供获取字符串长度或执行两个字符串的连接或比较的功能(需要使用库)。
可以使用`bytes(<string>)`将字符串转换为字节数组。这将返回字符串的UTF-8表示形式的低级字节。

**注意**：可以将一个字符编码为一个以上的字节，因此字节数组的长度不一定是字符串的长度。

### 字符串常量

请参见[文档的此部分](https://learnblockchain.cn/docs/solidity/types.html#string-literals)。

### `string`与`bytes`

文档的大多数示例都使用` bytes32`而不是` string`，并且如果可以限制字符串的字节数，则应该使用值类型` bytes1`  ... `bytes32`，因为便宜得多。

## 结构体(Struct)

与在C和C ++中一样，结构体允许你定义自己的类型，如下所示：

```
struct Donation {
      uint256 value;
      uint256 date;
}
```

定义结构体后，就可以开始将其用作状态变量或在函数中使用。

为了初始化一个结构体，我们有两种方法：

- 使用位置参数：

```js
Donation donation = Donation(
msg.value,
block.timestamp
);
```

- 使用关键字：

```js
Donation donation = Donation({
value : msg.value,
date: block.timestamp
});
```

第二种方法将避免我们必须记住结构体成员的顺序，因此它可能比第一种有用。

使用点访问结构体的成员：

```
uint256 donationDate = myDonation.date;
```

“虽然结构体本身可以是映射成员的值类型，也可以在动态大小的数组里使用，但是结构体不能包含其自身类型的成员。这个限制是必要的，因为结构体的大小必须是有限的。” — [Solidity文档](https://learnblockchain.cn/docs/solidity/types.html#structs)

## 映射(Mappings)

你可以将映射视为大量的键/值存储，其中每个可能的键都存在，并且可以使用该键来设置或检索任何值。

映射声明如下：

```
mapping( KeyType => ValueType) VariableName
```

` KeyType`可以是任何内置值类型(我们在[第一篇](https://learnblockchain.cn/article/1758)介绍过)、字节或字符串中看到的值、也可以是任何合约或枚举类型。` ValueType`可以是任何类型，包括映射，数组和结构体。

这里要提到的一件事是，映射变量唯一允许的数据位置是`storage`，它只能声明为状态变量、存储指针或库函数的参数。

## 枚举(Enum)

枚举允许你将自定义类型下的相关值分组，如以下示例所示：

```
enum Color { green , blue, red }
```

使用以下语法可以访问`enum`值：

```
Color defaultColor = Color.green;
```

**注意**：枚举也可以在文件级别上声明，而不是在合约或库定义中。

## 常量和不可变状态（Immutable）变量

状态变量可以声明为`constant`或`immutable`。在这两种情况下，构造合约后都无法修改变量。对于`constant`，该值必须在编译时确定，而对于`immutable`，则是在构造时赋值。

编译器不会为这些变量保留一个存储槽，而是在每次出现时会由相应的值替换。

常量使用关键字`constant`声明：

```
uint256 constant maxParticipants = 10;
```

对于不可变状态变量，使用关键字` immutable`声明它们：

```
contract C {
      address immutable owner = msg.sender;
      uint256 immutable maxBalance;
    
      constructor(uint256 _maxBalance){
           maxBalance = _maxbalance;
      }
}
```

你可以在[文档的本部分](https://learnblockchain.cn/docs/solidity/contracts.html#constant-immutable)中找到有关常量和不可变状态变量的更多详细信息。

**注意**：也可以在文件级别定义`constant`变量。

## delete 关键字

我想补充的最后一件事是在Solidity中使用`delete`。
它用于将变量设置为其初始值，这意味着该语句`delete a`的行为如下：

- 对于整数，它等于` a = 0`。
- 对于数组，它分配长度为零的动态数组或长度相同的静态数组，并将所有元素设置为其初始值。
- `delete a[x]`删除数组索引` x`处的项目，并保持所有其他元素和数组长度不变。这尤其意味着它在数组中留有间隙。
- 对于结构体，它将重置结构体的所有成员。
- `delete`对映射没有影响(因为映射的键可能是任意的，并且通常是未知的)。

## 练习时间：Crud（增删改查）

在本练习中，我们将创建一个用于管理用户的合约。

说明如下：

- 创建一个新文件并添加一个名为Crud的合约。
- 创建一个名为User的结构体，其中包含用户的ID和名称。
- 添加两个public 状态变量：1)  动态的用户数组； 2)  每次我们创建新用户时ID都会增加。

下一步是创建Crud函数，但是由于我没有向你介绍Solidity函数，因此将为你提供声明函数的语法。在下一篇文章中，我们将对它们进行详细的讨论：

```js
function function_name(<param_type> <param_name>) <visibility> <state mutability> [returns(<return_type>)]{ ... }
```

可见性（visibiliity）可以是：public，private，internal，external。
状态可变性（state mutability）可以是：view，pure，payable。

这是你将创建的函数的描述：

### 1. add

可见性：public
状态可变性：空

此函数将用户名作为参数，使用新ID创建User实例(每次添加新用户时ID都会自动递增)，并将新创建的用户添加到数组中。

### 2. read

可见性：public
状态可变性：view

此函数获取要查找的用户的ID，如果找到则返回用户名，否则回退(稍后会详细讨论异常)。

### 3. update

可见性：public
状态可变性：空

此函数将获取用户的ID和新名称，然后在找到相应用户时对其进行更新，如果该用户不存在，则回退该交易。

### 4. destroy

可见性：public
状态可变性：空

此函数将用户的ID删除，如果找到，则将其从数组中删除；如果用户不存在，则回退交易。

提示：由于最后三个函数都需要查找用户，因此你将需要创建一个私有函数，该函数将获取用户的ID并在数组中返回其索引(如果找到)，以避免重复相同的代码。

以下是完整代码：

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract Crud {
    
    struct User {
        uint256 id;
        string name;
    }
    
    User[] public users;
    uint256 public nextId = 1;
    
    function add(string memory name) public {
        User memory user = User({id : nextId, name : name});
        users.push(user);
        nextId++;
    }
    
    function read(uint256 id) public view returns(string memory){
        uint256 i = find(id);
        return users[i].name;
    }
    
    function update(uint256 id, string memory newName) public {
        uint256 i = find(id);
        users[i].name = newName;
    }
    
    function destroy(uint256 id) public {
        uint256 i = find(id);
        delete users[i];
    }
    
    function find(uint256 id) private view returns(uint256){
        for(uint256 i = 0; i< users.length; i++) {
            if(users[i].id == id)
                return i;
        }
        revert("User not found");
    }
    
}
```



至此，我们对变量的讨论结束了。下次，我们将研究功能以及如何在Solidity中使用它们，因此，如果你想了解更多信息，请继续关注即将发布的文章。

------

本翻译由 [Cell Network](https://www.cellnetwork.io/?utm_souce=learnblockchain) 赞助支持。