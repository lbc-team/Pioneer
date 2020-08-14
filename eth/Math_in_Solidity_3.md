
# Math in Solidity (Part 3: Percents and Proportions)

## This article is the third one in a series of articles about doing math in Solidity. This time the topic is: **percents and proportions**.

![](https://img.learnblockchain.cn/2020/08/13/15973037934793.jpg)


# Introduction

Financial math begins with percents. What is $x$ percent of $y$? How much percent of $x$ is $y$? We all know the answers: $x$ percent of $y$ is $x×y÷100$ and $y$ is $y×100÷x$ percent of $x$. This is school math.

The formulas above are particular cases of solving proportions. In general, proportion is an equation of the following form: $a÷b=c÷d$, and to solve the proportion is to find one of the values knowing the other three. For example, $d$ could be found from $a$, $b$, and $c$ like this: $d=b×c÷a$.

Being simple and straightforward in mainstream programming languages, in Solidity such simple calculations are surprisingly challenging, as we showed in [our previous article](/coinmonks/math-in-solidity-part-2-overflow-3cd7283714b4). There are two reasons for this: i) Solidity does not support fractions; and ii) numeric types in Solidity may overflow.

In Javascript, one may calculate $x×y÷z$ simple like this: `x*y/z`. In solidity such expression would not pass security audit, as for large enough $x$ and $y$ multiplication may overflow and thus calculation result may be incorrect. Using SafeMath doesn’t help much, as it could make transaction to fail even when final calculation result would fit into 256 bits. In the previous article we called this situation “phantom overflow”. Doing division ahead of multiplication like `x/z*y` or `y/z*x` solves phantom overflow problem, but may lead to precision degradation.

In this article we discover what better ways are there in Solidity to deal with **percents and proportions**.

# Towards Full Proportion

The goal for this article is to implement in Solidity the following function:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
```

That calculates $x×y÷z$, rounds the result down, and throws in case $z$ is zero of the result does not fit into `uint`. Let’s start with the following straightforward solution:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  return x * y / z;
}
```

This solution basically satisfies most of the requirements: it seems to calculate $x×y÷z$, rounds the result down, and throws in case $z$ is zero. However, there is one problem: what it actually calculates is $x×y\ mod\ 2^{256} ÷z$. This is how multiplication overflow works in Solidity. When multiplication result does not fit into 256 bits, only the lowest 256 bits of the result are returned. For small values of $x$ and $y$, when $x×y<2^{256}$ , there is no difference, but for large $x$ and $y$ this would produce incorrect result. So the first question is:.

## **How Could We Prevent Overflow?**

> Spoiler: we shouldn’t.

Common way to prevent multiplication overflow in Solidity is to use `mul` function from SafeMath library:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  return mul (x, y) / z;
}
```

This code guarantees correct result, so now all the requirements seem satisfied, right? Not so fast.

The requirement is to revert in case the result does not fit into `uint`, and this implementation seems to satisfy it. However, this implementation also reverts when $x×y$ does not fit into `uint` even if the final result would fit. We call this situation “phantom overflow”. In the previous article we showed, how to solve phantom overflow at the price of precision, however that solution does not work here, as we want precise precise result.

As just reverting on phantom overflow is not an option, then

## How Could We Avoid Phantom Overflow Preserving Precision?

> Spoiler: simple math tricks.

Let’s do the following substitutions: $x=a×z+b$ and $y=c×z+d$, where $a, b, c, and\ d$ are integers and $0≤b<z$ .Then:

$$
x×y÷z=
(a×z+b)×(c×z+d)÷z=
(a×c×z^2+(a×d+b×c)×z+b×d)÷z=
a×b×z+a×d+b×c+b×d÷z
$$

Values $a, b, c, and\ d$ may be calculated as quotients and reminders by dividing $x$ and $y$ by $z$ respectively.

So, the function could be rewritten like this:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  uint a = x / z; uint b = x % z; // x = a * z + b
  uint c = y / z; uint d = y % z; // y = c * z + d return a * b * z + a * d + b * c + b * d / z;
}
```

Here we use plain `+` and `*` operators for readability, while real code should use SafeMath function to prevent real, i.e. non-phantom, overflow.

In this implementation phantom overflow is still possible, but only in the very last term: `b * d / z`. However, this code is guaranteed to work correctly when $z≤2^{128}$, as both, $b$ and $d$ are less that $z$, thus $b×d$ is guaranteed to fit into 256 bits. So, this implementation could be used in cases when $z$ is known to not exceed $2^{128}$. One common example is fixed-point multiplication with 18 decimals: $x×y÷10^{18}$. But,

## How Could We Avoid Phantom Overflow Completely?

> Spoiler: use wider numbers.

The root of the phantom overflow problem is that intermediary multiplication result dose not fit into 256 bit. So, let’s use wider type. Solidity does not natively support numeric types wider than 256 bit, so we will have to emulate them. We basically need two operations: $uint×uint→wide$ and $wide÷uint→uint$.

As product of two 256-bit unsigned integers may not exceed 512 bits, the wider type has to be at least 512 bits wide. We may emulate 512-bit unsigned integer in Solidity via a pair of two 256-bit unsigned integer holding lower and higher 256-bit parts of the whole 512-bit number respectively.

So, the code could look like this:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  (uint l, uint h) = fullMul (x, y);
  return fullDiv (l, h, z);
}
```

Here `fullMul` function multiplies two 256-bit unsigned integers and returns the result as 512-bit unsigned integer split into two 256-bit parts. Function `fullDiv` divides 512-bit unsigned integer, passed as two 256-bit parts, but 256-bit unsigned integer and returns the result as 256-bit unsigned integer.

Let’s implement these two functions school-math way:

```
function fullMul (uint x, uint y)
public pure returns (uint l, uint h)
{
  uint xl = uint128 (x); uint xh = x >> 128;
  uint yl = uint128 (y); uint yh = y >> 128; 
  
  uint xlyl = xl * yl; uint xlyh = xl * yh;
  uint xhyl = xh * yl; uint xhyh = xh * yh;

  uint ll = uint128 (xlyl);
  uint lh = (xlyl >> 128) + uint128 (xlyh) + uint128 (xhyl);
  uint hl = uint128 (xhyh) + (xlyh >> 128) + (xhyl >> 128);
  uint hh = (xhyh >> 128); 
  
  l = ll + (lh << 128);
  h = (lh >> 128) + hl + (hh << 128);
}
```

and

```
function fullDiv (uint l, uint h, uint z)
public pure returns (uint r) {
  require (h < z);
  
  uint zShift = mostSignificantBit (z);
  uint shiftedZ = z;
  if (zShift <= 127) zShift = 0;
  else
  {
    zShift -= 127;
    shiftedZ = (shiftedZ - 1 >> zShift) + 1;
  }
  
  while (h > 0)
  {
    uint lShift = mostSignificantBit (h) + 1;
    uint hShift = 256 - lShift; 
    
    uint e = ((h << hShift) + (l >> lShift)) / shiftedZ;
    if (lShift > zShift) e <<= (lShift - zShift);
    else e >>= (zShift - lShift);
    
    r += e;
    
    (uint tl, uint th) = fullMul (e, z);
    h -= th;
    if (tl > l) h -= 1;
    l -= tl;
  }
  r += l / z;
}
```

Here `mostSignificantBit` is a functions, that returns zero-based index of the most significant bit of the argument. This function may be implemented as the following:

```
function mostSignificantBit (uint x) public pure returns (uint r) {
  require (x > 0); 
  
  if (x >= 2**128) { x >>= 128; r += 128; }
  if (x >= 2**64) { x >>= 64; r += 64; }
  if (x >= 2**32) { x >>= 32; r += 32; }
  if (x >= 2**16) { x >>= 16; r += 16; }
  if (x >= 2**8) { x >>= 8; r += 8; }
  if (x >= 2**4) { x >>= 4; r += 4; }
  if (x >= 2**2) { x >>= 2; r += 2; }
  if (x >= 2**1) { x >>= 1; r += 1; }
}
```

The code above is quite complicated and probably ought to be explained, but we will skip the explanations for now and focus on different question. The problem with this code is that it consumes about 2.5K gas per invocation of `mulDiv` function, which is quite a lot. So,

## Could We Do It Cheaper?

> Spoiler: mathemagic!

The code below is based on exciting mathematical findings described by [Remco Bloemen](https://medium.com/u/da8bcc0c6bbc?source=post_page-----4db014e080b1----------------------). Please, clap to his “mathemagic” articles if you like this code.

At first, we rewrite `fullMul` function:

```
function fullMul (uint x, uint y)
public pure returns (uint l, uint h)
{
  uint mm = mulmod (x, y, uint (-1));
  l = x * y;
  h = mm - l;
  if (mm < l) h -= 1;
}
```

This saves about 250 gas per `fullMul` invocation.

Then we rewrite `mulDiv` function:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint) {
  (uint l, uint h) = fullMul (x, y);
  require (h < z); 
  
  uint mm = mulmod (x, y, z);
  if (mm > l) h -= 1;
  l -= mm; 
  
  uint pow2 = z & -z;
  z /= pow2;
  l /= pow2;
  l += h * ((-pow2) / pow2 + 1); 
  
  uint r = 1;
  r *= 2 - z * r;
  r *= 2 - z * r;
  r *= 2 - z * r;
  r *= 2 - z * r;
  r *= 2 - z * r;
  r *= 2 - z * r;
  r *= 2 - z * r;
  r *= 2 - z * r; 
  
  return l * r;
}
```

This implementation consumes only about 550 gas per `mulDiv` invocation and may be optimized further. 5 times better than school-math approach. Very good! But one really has to gain PhD in mathematics to write code like this, and not every problem has such mathemagic solution. Things would be much simpler if we could

# Use Floating-Point Number in Solidity

As we already said in the beginning of this article, in JavaScript one simply writes `a * b / c` and the language takes care of the rest. What if we could do the same in Solidity?

Actually we do can. While core language does not support floating point, there are libraries that do. For example, with [ABDKMathQuad](https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMathQuad.md) library one may write:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint) {
  return
    ABDKMathQuad.toUInt (
      ABDKMathQuad.div (
        ABDKMathQuad.mul (
          ABDKMathQuad.fromUInt (x),
          ABDKMathQuad.fromUInt (y)
        ),
        ABDKMathQuad.fromUInt (z)
      )
    );
}
```

Not as elegant as in JavaScript, not as cheap as mathemagic solution (and even more expansive than school-math approach), but straightforward and quite precise, as quadruple precision floating-point numbers used here has about 33 significant decimals.

More than half of the gas consumption of this implementation is used on converting `uint` values into floating-point and back, and the proportion calculation itself consumes only about 1.4K gas. Thus, using floating-point numbers across all the smart contract could be significantly cheaper than mixing integers and floating-point numbers.

# Conclusion

Percents and proportions could be challenging in Solidity as due to overflow and lack of fractions support. However various math tricks allow resolving proportions correctly and efficiently.

Floating-point number supported by libraries may make life even better at the cost of gas and precision.

In our next article we will go deeper into financial math, as the next topic will be: [**compound interest**](/coinmonks/math-in-solidity-part-4-compound-interest-512d9e13041b).

原文链接：https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
作者：[Mikhail Vladimirov](https://medium.com/@mikhail.vladimirov)