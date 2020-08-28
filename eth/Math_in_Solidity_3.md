# 优化Solidity 中的百分数和比例运算

本文是 Solidity 中进行数学运算系列文章中的第三篇，这篇文章的主题是: **百分数和比例运算**.

![](https://img.learnblockchain.cn/2020/08/13/15973037934793.jpg)

## 引言

金融数学最基础的就是百分数。 $x$ 乘 $y$ 的百分数是多少？ $y$ 占 $x$ 的百分比是多少？ 我们都知道答案：$x$ 乘 $y$ 的百分数是 $x×y÷100$ , $y$ 是 $x$ 的百分之:  $y×100÷x$ 。 我们在数学课上都学过这些。



上面的公式是计算比例的特例。 通常情况下比例是以下形式的等式：$a÷b = c÷d$，计算比例就是在已知其他三个值的情况下算出第四个值。 例如，已知 $a$, $b$ 和 $c$ 求 $d$ , 计算过程如下：$d = b×c÷a$。

在主流编程语言中计算这个比较简单，而在 Solidity 中，这种计算十分具有挑战性性，正如我们在[我们以前的文章](https://medium.com/coinmonks/math-in-solidity-part-2-overflow-3cd7283714b4)提及的一样。 主要是由两个原因引起的: i) Solidity 不支持分数； ii）Solidity 中的数字类型可能会溢出


在 Javascript 中，我们只需要写`x*y/z`就能计算 $x×y÷z$ 。 然而在 Solidity 中，对于足够大的 $x$ 和 $y$ 乘法可能会溢出，因此计算结果可能不正确，这样的表达式也往往不能通过安全审计。 使用 SafeMath 也并啥用，因为它可能导致即使最终计算结果在 256 位以内，交易却失败。 在上一篇文章中，我们称这种情况为“假溢出”（phantom overflow）。 在乘法之前先做除法，比如 `x/z*y` 或 `y/z*x` 可以解决假溢出问题，但这可能导致精度降低。

在本文中，我们会阐述在 Solidity 中更好地处理**分数和比例**的方法。

## 一步步实现比例计算的“完全体”

本文的目标是在 Solidity 中实现以下函数:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
```

这个函数的功能是,计算 $x×y÷z$ ，并将结果四舍五入，同时如果 $z$ 为零会抛出错误。 让我们先从以下简单的方法开始：

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  return x * y / z;
}
```

这个方案基本上满足大多数要求：它看起来能计算出 $x×y÷z$ ，然后将结果四舍五入，并在 $z$ 为零的情况下抛出错误。 但是，有一个问题是：它实际计算的是$x×y\mod \ 2 ^{256}÷z$ 。 这就是 Solidity 中乘法溢出的机制。 当乘法结果大于 256 位时，仅返回结果中最低的 256 位。 对于较小的 $x$ 和 $y$ ，当 $x×y<2^ {256}$ 时，这没有区别，但是对于较大的 $x$ 和 $y$ 会产生错误的结果。所以第一个问题是：

## 我们该如何避免溢出?

> 思路：不让它溢出。

在 Solidity 中防止乘法溢出的常用方法是使用 SafeMath 库中的`mul`函数:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  return mul (x, y) / z;
}
```

该代码保证了正确的结果，所以现在所有的要求似乎都满足了，对吧？但其实还没完。。。

程序的要求是在溢出时能回滚，这个方案似乎可以满足要求。 但问题是，即使最终的结果不会溢出，只要$x×y$溢出，程序也会回滚。 我们称这种情况为“假溢出”(“phantom overflow”)。 在上一篇文章中，我们给大家展示了如何以精确度为代价解决假溢出问题，但是因为我们需要精确的结果，所以该解决方案在这里行不通。

由于无法避免假溢出，因此

## 如何在保持精度的同时避免假溢出?

> 思路: 简单的数学技巧.

让我们进行以下替换：$x=a×z+b$ 和 $y=c×z+d$，其中 $a, b, c$ 和 $d$ 是整数，且 $0≤b<z$ 。那么:

$$
x×y÷z=
(a×z+b)×(c×z+d)÷z=
(a×c×z^2+(a×d+b×c)×z+b×d)÷z=
a×b×z+a×d+b×c+b×d÷z
$$

$a，b，c$ 和 $d$ 的值可分别用 $x$ 和 $y$ 对 $z$ 求余来计算。

因此，可以这样重写该函数:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  uint a = x / z; uint b = x % z; // x = a * z + b
  uint c = y / z; uint d = y % z; // y = c * z + d
  return a * b * z + a * d + b * c + b * d / z;
}
```

在这里，我们使用简单的 `+` 和 `*` 运算符来提高可读性，在真实代码应使用 SafeMath 函数来防止真溢出（即非假溢出）。

在此实现中，假溢出仍可能存在，但仅在最后一项`b * d / z`中。但是，只要保证$z≤2^ {128}$ ，此代码就没问题，因为 $b$ 和 $d$ 都小于 $z$ ，这保证了$b×d$ 可以容纳 256 位。 因此，可以在已知 $z$ 不超过 $2^{128}$ 的情况下使用。 一个常见的示例是固定乘法的小数点位数为 18 位：$x×y÷10 ^ {18}$。

但是，

## 我们到底如何才能彻底避免假溢出?

> 思路: 使用位数更宽的数字.

假溢出问题的根源在于中间乘法结果超出 256 位。 因此，让我们使用位数更宽的数字。 Solidity 本身不支持大于 256 位的数据类型，因此我们必须模拟它们。 我们需要两个基本操作：$uint×uint→wide$ 和 $wide÷uint→uint$ 。

由于两个 256 位无符号整数的乘积不能超过 512 位，因此较宽的类型必须至少为 512 位宽。 我们可以通过两个 256 位无符号整数对来模拟 512 位无符号整数，而这两个 256 位无符号整数分别表示整个 512 位数字的较低和较高 256 位部分。

因此，代码可能看起来像这样:

```
function mulDiv (uint x, uint y, uint z)
public pure returns (uint)
{
  (uint l, uint h) = fullMul (x, y);
  return fullDiv (l, h, z);
}
```

这里的`fullMul`函数将两个 256 位无符号整数相乘，并将 512 位无符号整数的结果分成两个 256 位整数的形式返回。函数`fullDiv`除以两个 256 位无符号整数形式传递的 512 位无符号整数，和一个 256 位无符号整数，并以 256 位无符号整数形式返回结果。

让我们用学校里学的数学来实现这两个函数：

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

和

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

这里的`mostSignificantBit`是一个函数，它返回参数最高有效位的索引（从零开始索引)。此函数可以通过以下方式实现：

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

上面的代码很复杂，可能需要给大家解释，但是我们现在将略过这些解释，而将重点先放在其他问题上。 这段代码的问题在于，每次调用 mulDiv 函数会消耗高达 2.5K 的 gas。

## 我们可以把它弄得便宜一点吗?

> 思路: 数学!

以下代码基于[Remco Bloemen](https://medium.com/u/da8bcc0c6bbc?source=post_page-----4db014e080b1----------------------)提出的惊人数学发现，如果您喜欢此代码，请为他的“数学”文章鼓掌 👏。

首先，我们重写`fullMul`函数:

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

每次`fullMul`调用可节省约 250 gas.

然后我们重写`mulDiv`函数:

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

该函数中，每次`mulDiv`调用仅消耗约 550 gas，并且可以进一步优化。 这比学校里学到的数学方法好 5 倍，不要太 nb！ 但是，实际上只有数学博士才能编写这样的代码，并且并非每个问题都具有这样的数学解决方案。 如果我们可以使用浮点数，问题会变得很简单：

## 在 Solidity 中使用浮点数

就像我们在本文开头说过的那样，用 JavaScript 只需编写 `a * b / c`，其余部分就由该语言处理。 我们改如何在 Solidity 中实现类似的功能?

实际上这是可以的。虽然核心语言不支持浮点数，但有些库支持。 例如，使用[ABDKMathQuad](https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMathQuad.md)库，我们就可以这样写代码：

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

这种方法不像 JavaScript 那样优雅，也不如数学解决方案那样便宜,但是它简单而精确,因为这里使用的四精度浮点数大约有 33 位有效小数。

此方法超过一半的 gas 消耗用于将`uint`值进行浮点数和无符号整数的相互转换，比例计算本身仅消耗约 1.4K gas。 因此，在所有智能合约中使用浮点数可能比混用整数和浮点数便宜得多。

## 结论

由于 Solidity 存在溢出问题，并且不支持分数；百分数和比例计算在 Solidity 中比较复杂。但是,可以使用各种数学技巧有效地解决这些问题。

使用库支持的浮点数会将问题简化很多，但同时也会增加 gas 消耗并牺牲精度。

在下一篇文章中，我们将更深入地研究金融数学，下一个主题将是： [**复利**](https://medium.com/coinmonks/math-in-solidity-part-4-compound-interest-512d9e13041b)。

原文链接：https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
作者：[Mikhail Vladimirov](https://medium.com/@mikhail.vladimirov)
