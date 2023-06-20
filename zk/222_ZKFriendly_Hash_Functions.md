# ZK-Friendly Hash Functions

> An exploration of MiMC, Poseidon, and Vision/Rescue, along with a deep dive into SNARK and STARK complexity

# Introduction

## Hash Function

A [cryptographic hash function](https://en.wikipedia.org/wiki/Cryptographic_hash_function) is one of the basic primitives for cryptography. (In this article, the word hash function will mean cryptographic hash function unless otherwise noted.) A cryptographic hash function satisfies the below three secure properties:

1. **Preimage resistance**: Given hash value $h$, it is hard to find any input message  $m$ that $f(m)=h$.
2. **Second-preimage resistance**: Given input message $m$, it is hard to find message $m′(\not= m)$that $f(m')=f(m)$.
3. **Collision resistance**: It is hard to find any two different input messages $m_1,m_2(\not=m_1)$ that $f(m_1)=f(m_2)$.

Cryptographic schemes such as digital signatures, message authentication codes, commitment schemes, and authentications are built on top of hash function. For example, the preimage resistance property of a hash function enables the [proof-of-work](https://en.wikipedia.org/wiki/Proof_of_work) system in cryptocurrency. SHA-2 and SHA-3 are common examples of hash functions, and they are adopted for general purposes.

## Usage of Hashes in the ZK protocol

A hash function is also useful in the ZK protocol. One famous example is the membership check in a Merkle tree. For a Merkle root $r$, the prover will claim knowledge of the witness $w_1,...,w_n$ such that
$$
H(...H(H(w_1,w_2)w_3))...,w_n)=r
$$


to prove their knowledge of element $w_1$, which is a member of the Merkle tree. We already discussed this usage in our previous post, [“How Does Tornado Cash Work?”](https://www.zellic.io/blog/how-does-tornado-cash-work).

Traditional uses of hash functions can be utilized in the ZK protocol as well, such as integrity checks using vanilla hash computation, retrieving pseudorandom strings from the fixed length seed, and signing transactions.

## Why Are ZK-Friendly Hash Functions Required?

The standardized hash functions such as SHA-2 and SHA-3 are extensively studied, and their security is widely believed. Moreover, traditional software and hardware implementations of them are efficient compared to their competitors.

So when we need to evaluate a hash in ZK protocols, it seems nice to use SHA-2 or SHA-3. However, many ZK protocols are using relatively unfamiliar hash functions such as [MiMC](https://eprint.iacr.org/2016/492), [Poseidon](https://eprint.iacr.org/2019/458), and [Rescue](https://eprint.iacr.org/2019/426) instead of SHA-2 and SHA-3.

The main reason for this is that efficiency in ZK protocols is determined in quite different ways from traditional metrics such as running time, power consumption, and gate count. The efficiency of the circuits in ZK protocols depends on their algebraic structure.

Generally, if the circuit is represented as simple expressions in a large field, it allows efficient proof in terms of prover execution time and proof size. Unfortunately, traditional hash functions are inappropriate for this.

For example, SHA-2 is about 50--100 times more inefficient than ZK-friendly hash functions when the hash is computed in zk-STARK. This huge performance gap demonstrates the need for a ZK-friendly hash function.

In this post, we will introduce several ZK-friendly hash functions that are introduced in famous conferences and journals. It might be fun to focus on the design rationale for each hash function.

# ZK Protocols

We first discuss the ZK protocols. Rather than trying to fully understand the protocols, we'll focus on their high-level characteristics and what the metric is to determine efficiency.

## zk-SNARK

zk-SNARK is an acronym that stands for **zero-knowledge succinct non-interactive argument of knowledge**.

1. Zero-knowledge: Verifier learns nothing other than the statement is true.
2. Succinct: Proof size and verifier time is **sublinear**.
3. Non-interactive: Needs no interaction between prover and verifier.
4. Argument of knowledge: Not only for existence of input $x$ but also prover's knowledge of $x$.

While there are several ways to build a protocol that satisfies the above characteristics, such as [linear PCP + pairing-based cryptography](https://eprint.iacr.org/2016/260), [constant-round polynomial IOP](https://eprint.iacr.org/2019/953), and [polynomial commitment scheme + IOP-based](https://eprint.iacr.org/2022/1608), [Groth16](https://eprint.iacr.org/2016/260) based on the linear PCP and pairing-based cryptography is the most widely used one.

Groth16 and many other zero-knowledge proof systems such as [Aurora](https://eprint.iacr.org/2018/828), [Ligero](https://eprint.iacr.org/2022/1608), and [Bulletproofs](https://eprint.iacr.org/2017/1066) are evaluating the circuit in **Rank-1 Constraint System (R1CS)** form.

### R1CS Examples

The R1CS is a system of equations, where each equation is defined by a triplet of vectors $(\vec a_i,\vec b_i,\vec c_i)$ such that $(\vec a_i \cdot \vec s) \times (\vec b_i \cdot \vec s)=(\vec c_i \cdot \vec s)$.

For example, $y=x^3$ can be interpreted as two equations defined by a triplet of vectors (with intermediate value $z=x^2$):

$x \times x = z :((1\,0\,0) \cdot (x\,y\,z)) \cdot ((1\,0\,0) \cdot (x\,y\,z))=((0\,0\,1) \cdot (x\,y\,z))$,

$z \times x = y :((0\,0\,1) \cdot (x\,y\,z)) \cdot ((1\,0\,0) \cdot (x\,y\,z))=((0\,1\,0) \cdot (x\,y\,z))$.

In the SNARK setting, the cost is determined by the number of constraints in the R1CS. For example, $x^α$ for the constant $α$ requires $⌈log_2(\alpha)⌉$ constraints. This implies that $x^5$ and $x^7$ have the same cost in the SNARK setting.

## zk-STARK

zk-STARK is an acronym that stands for **zero-knowledge scalable transparent argument of knowledge**.

1. Zero-knowledge: Verifier learns nothing other than that the statement is true.
2. Scalable: Prover time is **quasilinear**; proof size and verifier time is **sublinear**.
3. Transparent: No trusted setup is needed.
4. Argument of knowledge: Not only for existence of input $x$ but also for prover's knowledge of$x$.

Any protocol that satisfies the above conditions is called a zk-STARK. However, zk-STARK often refers to the protocol in [the paper](https://eprint.iacr.org/2018/046) where the concept was first proposed. We also refer to the protocol in that paper as zk-STARK in this article.

To evaluate the circuits in a STARK setting, the circuit should be transformed into **algebraic intermediate representation (AIR)**.

### AIR Examples

We give an example of computing a Fibonacci sequence. The Fibonacci sequence is defined as

$a_0=1$

$a_1=1$

$a_i=a_{i-1} + a_{i-2}$ for$ i≥2$.

The prover wants to prove that$a_7=21$. Then an **algebraic execution trace (AET)**, an execution trace of a computation of the Fibonacci sequence, is

| $a$  |
| ---- |
| 1    |
| 1    |
| 2    |
| 3    |
| 5    |
| 8    |
| 13   |
| 21   |

And the AIR constraints described in the polynomial forms are

1. $a_0-1=0$,
2. $a_1-1=0$,
3. $a_i-a_{i-1}+a_{i-2}=0$ for $2 \leq i \leq 7$,
4. $a_7=21$.

Let $t$be a number of rows and $w$ be a number of columns in AET. Then the size of the AET is $t \cdot w $. Moreover, let $d$ be the maximal degree of an AIR constraint. In our case, $t=8,w=1,d=1$. The efficiency of a zk-STARK is determined by $t,w,d$. For each circuit, the efficiency is compared by measuring $t \cdot w \cdot d$.

# ZK-Friendly Hash Functions

Roughly speaking, the simpler the algebraic representation of a given circuit, the more efficient it is for both R1CS and AIR representations. Therefore, cryptographers began to design structures that were both algebraically simple and still secure. We often called these ciphers as **arithmetization-oriented ciphers (AOCs)**.

For AOCs, most traditional symmetric cryptanalysis such as differential and linear cryptanalysis are generally less relevant. The most powerful attack type for AOCs is algebraic attack, such as Gröbner basis, linearization, GCD, and interpolation attack. Once the designer decides their cipher's design, the round number is chosen to be safe from those attacks.

On the other hand, this field is relatively new and interesting attacks (see examples [one](https://eprint.iacr.org/2023/537), [two](https://eprint.iacr.org/2020/182), [three](https://eprint.iacr.org/2021/1232), and [four](https://eprint.iacr.org/2020/188)) have been claimed, often resulting in ciphers being broken or parameters being modified, but we'll talk about those in the next post.

Let's take a look at the design rationale behind the different AOCs.

## MiMC

[MiMC](https://eprint.iacr.org/2016/492) is the first ZK-friendly hash function, introduced in ASIACRYPT 2016. Although more efficient ZK-friendly hash functions are suggested after MiMC, MiMC is still widely used in many applications since it is considered mature compared to the other ZK-friendly hash functions.

The design of MiMC is extremely simple: a function $F(x) :=x^3$is iterated with subkey additions. This concept was already proposed by Nyberg and Knudsen in the 1990s, called [KN-Cipher](https://en.wikipedia.org/wiki/KN-Cipher).

### MiMC-$n/n$

We first take a look at a block cipher. The block cipher is constructed by iterating $r$rounds, where each round function is described as $F_i(x)=(x+k+c_i)^3$. In the round function, $c_i$ is a round constant and $k$ is a key, and the field is $\mathbb F_q$ where $q$ is a large prime or $q=2^n$. The encryption process is defined as 
$$
E_k(x) = (F_{r-1} \circ F_{r-2} \circ \cdots \circ F_0)(x) + k.
$$


and $c_0$ is fixed to $0$ because $c_0$ does not affect security. (If you're interested, I recommend checking it out for yourself!)

For a field $\mathbb F_q$, $F(x)=x^3$ has an inverse if and only if $gcd(3,q-1)=1$. Therefore, the author suggested choosing odd $n$ for $q=2^n$ and $q=3k+2$ for prime $q$.

The round constants $c_i$ are not specified in the paper, but $c_i$ is recommended to be chosen randomly at first and hardcoded into the implementation. To show [nothing up my sleeve](https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number) on the round constants, it is often generated from the SHA-2 (or any other secure hash functions) digest of certain messages like `MiMC0`, `MiMC1`, …….

The round number is determined by $r = \lceil log_3q \rceil$. For example, the round number $r = \lceil log_3(2^{127} \rceil)$ for a field $\mathbb F_{2^{127}}$. We discuss the reason of this later.

![$r$ rounds of MiMC-$n/n$, images from MiMC paper.](https://img.learnblockchain.cn/attachments/2023/06/zI6itO3w648ad5450c2d5.png)*$r$ rounds of MiMC-$n/n$. Images from MiMC paper.*

### MiMC-$2n/n$

It is also possible to construct a block cipher with the same nonlinear permutation in a Feistel network. The round function of MiMC-$2n/n$ is described in the below figure and can be defined as
$$
x_L \lVert x_R \leftarrow x_R + (x_L + k + c_i)^3 \rVert x_L
$$


![img](https://img.learnblockchain.cn/attachments/2023/06/9clRLWGe648ad54517bc7.png)

*MiMC-$2n/n$ round function. Images from [here](https://eprint.iacr.org/2019/951.pdf).*

For each round, only half of the data is changed; therefore, the number of rounds for the Feistel version is $2 \cdot \lceil log_3q \rceil$, which is doubled from the number of rounds of MiMC-.$n/n$

### The Hash Function

When the key is fixed at 00, then the block cipher becomes a permutation. Given a permutation, there is a well-known construction deriving hash functions from a permutation called the [sponge framework](https://en.wikipedia.org/wiki/Sponge_function), which is proven secure and used in many other hash functions, including [SHA-3](https://en.wikipedia.org/wiki/SHA-3).

![img](https://img.learnblockchain.cn/attachments/2023/06/9aP03roP648ad54500f8b.png)

*The sponge construction. $P_i$is input; $Z_i$ is hashed output. The unused capacity $c$ should be twice the desired collision or preimage attacks. Images from [Wikipedia](https://en.wikipedia.org/wiki/SHA-3).*

The sponge construction consists of two phases called *absorb* and *squeeze*. In the absorbing phase, the input data is absorbed into the sponge. Afterwards, the result is squeezed out.

The hash function from MiMC is also based on the sponge framework. In the absorbing phase, message blocks are added to a subset of the state, then transformed as a whole using a permutation function $f$ (in our case, an MiMC permutation). Note that all the other ZK-friendly hash functions introduced in this post are also based on the sponge framework.

### Security Analysis

While interpolation attack, GCD attack, invariant subfields attack, differential cryptanalysis, and linear cryptanalysis are considered in the paper, we will only introduce interpolation attack in here, which provides the lower bound of the round numbers. An interpolation attack constructs a polynomial corresponding to the encryption function without knowledge of the secret key. If an adversary can construct such a polynomial, then for any given plaintext, the corresponding ciphertext can be produced without knowing the secret key.

Let $E_k$ be an encryption function with degree $d$ in terms of input $x$. Then with the $d+1$ plaintext-ciphertext pairs, $E_k(x$) can be constructed using Lagrange's theorem, and the complexity of constructing a Lagrangian interpolation polynomial is $O(d \,log \,d)$. In our case, degree$d=3^r$. By choosing $r=\lceil log_3q \rceil$, the degree $d$ reaches $q-1$ and the attack becomes infeasible.

### SNARK Complexity

Since the single constraint can square the value, there are two R1CS constraints in each round of MiMC permutation:

```
x2 = x*x
x3 = x2*x
```

To generate a 256-bits output hash for the 256-bits input $x$, the sponge construction is used. In details, calculate MiMC-$2n/n$ of $(x,0)$, then left 256-bits are hash value. The round number is chosen as $2 \cdot \lceil log_3(2^{256})\rceil=324$. Then the number of constraints is $324 \times 2 = 628$. Note that field should be chosen as $gcd(3,q-1)= 1$, which means that $\mathbb F_{2^{256}}$ should not be chosen.

### STARK Complexity

In AIR representations, for MiMC-$2n/n$, each row has two variables,  $x_L$and $x_R$. We denote $x_L,x_R$ in -$i$ th row as $x^{(i)}_L,x^{(i)}_R$. Then from the round function $x_L \lVert x_R \leftarrow x_R + (x_L+k+c_i)^3 \rVert x_L$, the constraint polynomial is defined as

1. $x_L^{(i+1)}=x_R^{(i)}+(x_L^{(i)}=k=c_i)^3$,
2. $x_R^{(i+1)}=x_L^{{(i)}}$.

Then the number of rows $t=324$, the number of columns $w=2$, and the maximal degree $d=3$. The efficiency metric is $t \cdot w \cdot d =1944$.

### Implementations

Although the authors suggested $x^3$ as S-box, this S-box is often replaced to other S-boxes such as $x^5,x^7$ if $gcd(3,q-1)=1 $. For example, the [BN254](https://hackmd.io/@jpw/bn254) field is $F_q$ for 254-bits prime $q$, which is $gcd(3,q-1) \not = 1$. As a result, when using MiMC on the BN254, it is preferred to use $x^5$ or $x^7 $instead of $x^3$ ([example 1](https://github.com/iden3/circomlib/blob/master/circuits/mimc.circom), [example 2](https://github.com/iden3/circomlib/blob/master/circuits/mimcsponge.circom)). In this case, the round number is determined as $log_5 q$ or $log_7 q$, which mitigates all the attacks presented so far.

For the round constants, the authors do not specify how to generate them in the paper. Therefore, each implementation will determine the round constants by computing the hash value of strings like `MiMC0` and `MiMC1` using [SHA-2](https://starkware.co/hash-challenge-implementation-reference-code/#MiMCHash) or [SHA-3](https://docs.rs/mimc-rs/0.0.2/src/mimc_rs/lib.rs.html). If someone creates their own MiMC implementation without disclosing how the round constants were generated, there might be a potential vulnerability, such as being susceptible to an invariant subfields attack.

## Poseidon

[Poseidon](https://eprint.iacr.org/2019/458) is a yet another ZK-friendly hash function suggested in USENIX 2021. Poseidon is based on the [HADES](https://eprint.iacr.org/2019/1107) design strategy, which is a generalization of a [substitution-permutation network (SPN)](https://en.wikipedia.org/wiki/Substitution–permutation_network), suggested in EUROCRYPT 2020.

### HADES Design Strategy

SPN is a famous block cipher algorithm. For example, [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) uses the SPN structure. By applying enough alternating rounds of substitution boxes and permutation boxes, the attacker is unable to recover a key from plaintext-ciphertext pairs.

HADES is composed of three steps: *Add Round Key,* *SubWords,* and *MixLayer.*

This seems to be the same approach with SPN, but the main difference between the existing SPN and HADES is that some S-box layers in HADES are partial S-box layers, which means that a single S-box is applied for the rightmost element and identity is applied for the others. The author argued that this would reduce the R1CS or AET cost.

### Poseidon Hash Function

The Poseidon hash function follows the same construction as HADES, with replacing *Add Round Key* to *Add Round Constants*. Poseidon only considers the prime field $\mathbb F_p$. Let $m$ be the number of words in each layer (to avoid confusion with the number of rows $t$ in STARK, we use $m$instead of $t$ unlike the notation in the paper). The graphical overview is shown below.

![img](https://img.learnblockchain.cn/attachments/2023/06/oRt2JdHY648ad54527f92.png)

*Construction of Poseidon. $R_F = 2 \cdot R_f$ is the number of the full S-box rounds, and $R_P$ is the number of the partial S-box rounds. Images from Poseidon paper.*

The S-box is defined by $S-box(x)=x^{\alpha}$, where $\alpha \geq 3$ is the smallest positive integer that satisfies $gcd(\alpha,p-1)=1$.

The purpose of the linear layer is to spread local changes onto the entire state, so usually the linear layer is chosen as an [MDS matrix](https://en.wikipedia.org/wiki/MDS_matrix), and its effects are negligible on the cost. In Poseidon, the linear layer is a [Cauchy matrix](https://www.semanticscholar.org/paper/On-the-Design-of-Linear-Transformations-for-Youssef/fc18795b46726cee9283ab29bf9573ad022ea739), which is defined by
$$
M[i,j]= \frac {1}{x_i+y_j}
$$
for the entries of $\lbrace {x_i} \rbrace_{1\leq i\leq m}$and $\lbrace {y_i} \rbrace_{1\leq i\leq m}$  are pairwise distinct and $x_i+y_i \not=0$, where $i\in1,\cdots,m$ and $j \in 1,\cdots,m$. This was an original suggestion in Poseidon; however, some Cauchy matrixes are insecure if there is an invariant subspace trail. We omit the details of the attack. The interested reader may refer to the [paper](https://tosc.iacr.org/index.php/ToSC/article/view/8913). Therefore, the linear layer should be carefully chosen to avoid this type of attack.

The structure is highly parameterizable, and the suggested parameters for a 256-bits output hash are$m=3,R_F=8,R_P=57$ for an $\alpha=5$ over $\mathbb F_p$with ≈ 256-bit $p$. $R_F=8$ is chosen to prevent statistical attacks, and $R_P=57$ is chosen to prevent algebraic attacks.

### SNARK Complexity

For $\alpha=5$,S-box $x^{\alpha}$ is represented by three constraints:

```
x2 = x*x
x4 = x2*x2
x5 = x4*x
```

And the total S-box number is $m \cdot R_F+R_P$. Therefore, the total number of constraints for $\alpha=5$ is $3\cdot (m \cdot R_F + R_P)$ . For $m=3,R_F=8,R_P=57 $, it requires $276$ R1CS constraints.

### STARK Complexity

If we maintain $m$ variables for each round, then the number of rows is $t=R_F+R_P$, the number of columns is $w=k$, and the maximal degree is $d=\alpha $. Then the efficency metric is $t \cdot w \cdot d =(R_F+R_P) \cdot m \cdot \alpha $. However, this AET representation does not take advantage of partial S-box rounds. Instead of this, by treating every S-box output as a variable, the number of rows is $t=1 $, the number of columns is $w=m\cdot R_F+R_P$, and the maximal degree $d$ is still $\alpha$. For $m=3,R_F=8,R_P=57 $, the efficiency metric is $t \cdot w \cdot d=1 \cdot 81 \cdot 5=425$.

## Vision / Rescue

[Vision / Rescue](https://eprint.iacr.org/2019/426) are ZK-friendly hash functions following the Marvellous design strategy. They are suggested in FSE 2020.

### Marvellous Design Strategy

Marvellous design is a substitution-permutation network parameterized by the tuple $(q,m,\pi,M,v,s)$:

- $q$ : The field is $\mathbb F_q $, with $q$ either a power of $2$ or a prime number,
- $m$ : The state is $m$ elements in $\mathbb F_q$,
- $\pi=(\pi_0,\pi_1)$ : The S-boxes,
- $M$: An [MDS matrix](https://en.wikipedia.org/wiki/MDS_matrix),
- $v$ : The first step constant, and
- $v$ : The desired security level.

In each round of a Marvellous design, a pair of S-boxes $(\pi_0,\pi_1)$ is used alternately. The difference between $\pi_0$ and $\pi_1$ is in their degree. For one, $\pi_0$ should be chosen with a high degree when evaluated forward and a lower degree when evaluated backward. The other S-box, namely $\pi_1$, is chosen with the opposite goal, meaning that it has a low degree in the forward direction and a high degree in the backward direction. This choice has three benefits:

1. No matter which direction an adversary is trying to attack, the degree is guaranteed to be high.
2. It results in the same cost for the encryption and decryption functions.
3. Owing to nonprocedural computation, the low-degree representation of each S-box can be evaluated efficiently.

For Vision / Rescue, $\pi_0$ is obtained directly from $\pi_1:\pi_0=\pi_1^{-1}$.

The linear layer is chosen by the [Vandermonde matrix](https://en.wikipedia.org/wiki/Vandermonde_matrix). As described in Poseidon, there is no security claim related to the Vandermonde matrix, and any other MDS matrix should be fine.

The one interesting thing that differentiates the Marvellous from the others is that it uses a heavy key schedule. In MiMC and HADES, there is no special key schedule and the master key is added for each round. However, in Marvellous, the key schedule reuses the round function. The author claimed that this is a kind of security margin as the domain of AOCs is relatively new. Note that a heavy schedule does not affect the efficiency of hash functions from fixed-key permutations because every subkey is derived in the offline phase.

### Vision

Vision is meant to operate on binary fields with its native field $\mathbb F_{2^n}$. To construct the S-boxes, we select degree $4$, which we denote by $B$. More precisely, there are no $x^3$ terms in $B(x):B(x)=b_4 \cdot x^4+ b_2 \cdot x^2+b_1 \cdot x^1+b_0$. Then $B$ is linearized on $\mathbb F_2$ and it gives benefits for other computation settings such as [MPC](https://en.wikipedia.org/wiki/Secure_multi-party_computation). However, it is irrelevant with the SNARK/STARK setting, so we don't discuss it any further.

After $B$ is chosen, $\pi_0$ and $\pi_1$ is $\pi_0(x)=B^{-1}(x^{-1})$ and $\pi_1(x)=B(x^{-1})$.

Finally, the number of rounds is doubled for the longest reaching attack, which means a 100% safety margin is added, and the round number varies from 10 to 16.

![img](https://img.learnblockchain.cn/attachments/2023/06/qLPoSHwP648ad54526607.png)*A single round (two steps) of Vision. Images from Marvellous paper.*

### Rescue

The second family of algorithms in the Marvellous universe is Rescue. To build the S-box, the smallest prime $\alpha $ such that $gcd(\alpha,q-1)=1$ should be found. Then the S-boxes are set to be $\pi_0(x)=x^{1/\alpha}$ and $\pi_1(x)=x^{\alpha}$. The number of rounds is doubled for the longest reaching attack, as in Vision and the round number it varies from $10$ to $22$.

![img](https://img.learnblockchain.cn/attachments/2023/06/FFiTmGqX648ad54527526.png)*A single round (two steps) of Rescue. Images from Marvellous paper.*

### SNARK Complexity

For Vision, we should consider both inverse mappings $x^{-1}$ and $B(x)$---$B^{-1}(x)$ is analogous with $B(x) $. First, for $x^{{-1}}$, let $y=x^{{-1}}$. Then if $x=0$, then $y=0$, and if $x \not=0 $, then$xy=1$. Putting this together, we get the necessary and sufficient condition that $x(1+xy)=0$ and $y(1+xy)=0$. It is represented by three constraints:

```
z = x*y
eq1 = x*(1+z)
eq2 = y*(1+z)
```

Second, for $B$, it is represented by two constraints because its degree is $4$:

```
x2 = x*x
x4 = x2*x2
```

Note that only $x^4$ and $x^2$ are evaluated, and $B(x)=b^4 \cdot x^4+b_2 \cdot x^2 +b_1 \cdot x^1 +b_0$ is not yet derived. However, this does not matter because the structure of R1CS allows us to multiply and add variables by a constant later.

A single round consists of two steps, and $3m+2m=5m$ constraints are added for each step. Therefore, the number of total constraints is $10 \cdot m \cdot r$ for the round number $r$. From the recommended parameters $q \approx 2^{256},m=3,r=12$, the number of constraints is $10 \times 3 \times 12 =360$.

For Rescue, only $B(x)=x^{\alpha}$ and $B(x)=x^{1/\alpha}$ are nonlinear operations, and for $\alpha=3$, each $B(x)$ and  $B^{-1}(x)$requires two constraints, as we saw in MiMC. Therefore, $4m$ constraints are added for each round, and the total number of constraints is $4 \cdot m \cdot r$ for the round number $r$. From the recommended parameters $q \approx 2^{256},m=3,r=22 $, the number of the constraints is $4 \times 2 \times 22=264$.

### STARK Complexity

For Vision, the author presents an AIR with $w=2m,t=2,d=2$ for each step. The first $m$ elements correspond to the original state (say $S[i]$) and the last $m$ elements are stored auxiliary values (say $R[i]$). For the first cycle, $R[i]=1$ if $S[i]=0$, and $R[i]=0$ otherwise. We denote the value corresponding to $S[i]$ for the next row as $S'[i]$. Our goal is to make $S'[i]=S[i]^{{-1}}$. Then by setting the below constraints, the values of $R[i]$ and $S'[i]$ are verified to be correct.

1. $S[i] \cdot S'[i]-R[i]=0$,
2. $S[i] \cdot (1-R[i])=0$,
3. $S'[i] \cdot(1-R[i])=0$.

For the second cycle, $R[i]=S[i]^2$. Then $S'[i]=B(S[i])$and $R[i]$ are verified by the below constraints:

1. $R[i]-S[i]^2=0$,
2. $S'[i]-b_4 \cdot R[i]^2-b_2 \cdot R[i]-b_1 \cdot S[i]-b_0=0$.

When the round number is $r,w=2m,t=4r,d=2$. From the recommended parameters $q \approx 2^{256},m=3,r=12$, the efficiency metric is $t \cdot w \cdot d=48 \cdot 6 \cdot 2=576$.

For Rescue, no auxiliary values are required. Moreover, it is possible to combine $B(x)$ and $B^{{-1}}(x)$ in one equation. Therefore, for $r$ rounds, $w=m,t=r,d=3$. From the recommended parameters $q \approx 2^{256},m=3,r=22$, the efficiency metric is $t \cdot w \cdot d=23 \cdot 3 \cdot 3=207$.

# Conclusion

In this article, we've discussed the design rationale and performance of various AOCs. There are more AOCs that we haven't mentioned, such as GMiMC, Jarvis, and Friday, but their design rationale follows similar principles to the ones we've covered.

The overall SNARK and STARK performance is shown below.

| AOC      | R1CS(SNARK) | AET(STARK) |
| -------- | ----------- | ---------- |
| MiMC     | 628         | 1944       |
| Poseidon | 276         | 425        |
| Vision   | 360         | 576        |
| Rescue   | **264**     | **207**    |

As you can see on the table, Rescue has competitive results in both SNARK and STARK. In fact, STARKWARE also recommended Rescue from the STARK-friendly hash in their own [survey](https://eprint.iacr.org/2020/948).

In recent years, the hash functions 2-3x more efficient than Rescue in SNARK settings are proposed: [Anemoi](https://eprint.iacr.org/2022/840) and [Griffin](https://eprint.iacr.org/2022/403). They are not yet fully peer-reviewed and need to be validated by academics and industry, but their overwhelming performance means that they can be considered for use once they are matured.

Meanwhile, the algebraic simplicity of AOCs often allows attackers to attack ciphers. Therefore, it is recommended to use ciphers that have been published and proven to be reliable over time rather than using them based on their efficiency alone. In the next article, we'll cover algebraic attacks on AOCs.



原文链接：https://www.zellic.io/blog/zk-friendly-hash-functions





