
# Storing Structs is costing you gas

This is going to get into some very technical Solidity concepts, very quickly. You have been warned!

In Solidity (the programming language used for Ethereum smart contracts), you have “memory”, (think RAM on a computer), and “storage” (think the hard drive). Both are set up in chunks of 32 bytes (a byte is roughly a letter, so “are set up in chunks of 32 bytes” is 32 bytes of data). In Solidity, memory is inexpensive (3 gas to store or update a value). Storage is expensive (20,000 gas to store a value, 5,000 gas to update one).

Most dApps and games need to store data on the blockchain, so have to interact with storage. Minimizing storage costs is a major part of optimizing the gas costs for your smart contracts.

Here’s the data that a simple blockchain game might store:

```
address owner;
uint64 creationTime;
uint256 dna;
uint16 strength;
uint16 race;
uint16 class;
```

If we just stored these values directly, we could do:

```
mapping(uint256 => address) owners;
mapping(uint256 => uint64) creationTime;
mapping(uint256 => uint256) dna;
mapping(uint256 => uint16) strength;
mapping(uint256 => uint16) race;
mapping(uint256 => uint16) class;
```

This costs 120,000 gas to store this data, and that’s really expensive! We get much better results when we make a struct, and store that:

```
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

Now, when we store this struct, we pay less: 75,000 gas. The compiler cleverly packs the owner and the creationTime into the same slot, so that costs 25,000, instead of 40,000\. And it does the same thing with strength, race, and class. We can do better, though:

```
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

New cost: 60,000 gas! We made two changes here: First, we moved dna to the end. It’s a uint256, which is already 32 bytes, so it can’t pack with anything. Then, we changed creationTime from a uint64 to a uint48\. This lets the top five fields all pack together into 32 bytes. Timestamps don’t need to be more than uint48, and Solidity (unlike most other languages) allows a uint to be any multiple of 8, not just 8/16/32/64 etc. (if you’re reeeally crunched for space, you can use a uint32 for timestamp — you’ll likely be dead before it causes a problem in 2106).

We’ve halved our costs — pretty good, right? Well, no — we want the minimum possible gas cost for all our functions, and we can still go lower by encoding the first 5 data fields into a single uint256:

```
mapping(uint256 => uint256) characters;
mapping(uint256 => uint256) dnaRecords;function setCharacter(uint256 _id, address owner, uint256 creationTime, uint256 strength, uint256 race, uint256 class, uint256 dna) 
    external 
{
    uint256 character = uint256(owner);
    character |= creationTimefunction getCharacter(uint256 _id) 
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

Storing the data as a uint256 costs just over 40,000 gas — only two storage operations, plus some bit-shifts and bitwise OR operations. That’s a big discount, considering we started at a cost of 120,000 gas! Retrieving data is also mildly cheaper with this method. Note that these two functions don’t perform any error checking — you’ll need to do that yourself, to ensure that none of the inputs end up larger than their max values (but you’d have to do that same checking in all these implementations).

# Encoding & Decoding

There’s likely some unfamiliar characters in the above code. Let’s unpack them a little:

```
|=
```

This is the bitwise OR assignment operator. It’s used to combine two binary values (and we’re on a computer, so everything is binary) by saying “if any bit in either is 1, then that bit in the result is 1”. We can use it here, because we started with `uint256(address)`, which means we know that all the bits above bit 160 are 0s.

```
<<
```
 
This is the bit-shift (left) operator. It takes the bits of a number, and moves them to the left. So, `creationTime<<160` takes the creation time, and moves it up to slots 160–207 in the resulting code. Combining bit-shift and bitwise OR assignment lets us build up the encoding.

```
>>
```

This is the bit-shift (right) operator. It works just like `<<`, but in the opposite direction. We can convert back from our encoded data using this. But, we also need:

```
uint256(uint48())
```

This takes advantage of a feature of the solidity compiler. If you convert a uint256 to uint48, you just discard all bits higher than bit 48\. This is perfect for our purposes, as we know the `creationTime` is 48 bits long, so this pulls out just the data we want.

Using these techniques, we can significantly improve performance of our smart contracts.

# Using the data

Now you’ve got your data storage, you likely need to pass the data between functions. Unless your application is as simple as described here, you’re going to run up against the stack limit of ~16 local variables. So you need to pass the data as a struct, in memory. This struct looks a little different from the one shown earlier:

```
struct GameCharacter {
  address owner;
  uint256 creationTime;
  uint256 strength;
  uint256 race;
  uint256 class;
  uint256 dna;
}function getCharacterStruct(uint256 _id) 
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

All the fields are uint256\. This is the most efficient data type in solidity. Variables in memory (even structs) aren’t packed at all, so you don’t gain anything by using uint16 in memory, and you lose out because solidity has to do additional operations to convert a uint16 to a uint256 for calculations.

# Summary

We’ve really gone down an early 1980s programming rabbit hole here — encoding data, and caring about every little optimization we can wring out of the code. Writing Solidity is such a different animal than writing modern languages — the constraints of the Ethereum blockchain mean that you’re effectively coding for machine that’s less capable than a 1973 Apple 1.

Every tiny bit of optimization helps a ton. So save you and your users some gas and implement a more efficient storage method!

原文链接：https://medium.com/@novablitz/storing-structs-is-costing-you-gas-774da988895e 
作者：[Nova Blitz](https://medium.com/@novablitz)







