# How Does Tornado Cash Work?

# Introduction

**Tornado Cash** is an open-source decentralized coin mixer on the Ethereum network, developed by Roman Semenov, Alexey Pertsev, and Roman Storm. It was launched in December 2019, and as of March 2023, 3.66M ETH are deposited with 112K ETH in the pool ([Tornado Cash Analysis](https://dune.com/poma/tornado-cash_1)). The feature provided by Tornado Cash is a kind of double-edged sword: it provides strong anonymity so Ethereum co-founder Vitalik Buterin could [send anonymous funds to aid Ukraine](https://twitter.com/VitalikButerin/status/1556925602233569280), but it allows coins earned from criminal activity to be laundered. For example, both North Korean government hacking group [Lazarus](https://en.wikipedia.org/wiki/Lazarus_Group) and the [Euler finance hacker](https://www.zellic.io/blog/euler-finance-exploit-analysis) mixed their coins using Tornado Cash.

In this post, we will talk about the mathematical principles behind Tornado Cash. Let’s deep dive into Tornado Cash!

⚠️ **Caution** As of August 2022, the U.S. Department of the Treasury’s Office of Foreign Assets has announced that **any transactions within the United States or U.S. persons that involve Tornado Cash are prohibited**. This post is for educational purposes only. We are not responsible for any misuse of the information.

# Background

## Hash Function

A **hash function** is a mathematical function that takes in input messages of arbitrary size and returns a fixed-size string of characters called a hash value. For example, $f(x)=x$ (remainder of dividing $x$ by $97$) is a hash function for integer input. The purpose of a hash function is to generate a unique digital fingerprint of the input data, which can be used for various purposes, such as data storage, data retrieval, data integrity checking, digital signatures, and password verification.

We may define a special type of hash function named **cryptographic hash function**. A hash function $f$ is called a cryptographic hash function if it satisfies the below three secure properties:

1. **Pre-image resistance**: Given hash value $h$, it is hard to find any input message $m$ that $f(m)=h$.
2. **Second-preimage resistance**: Given input message $m$, it is hard to find message $m'(\not=m)$that $f(m')=f(m)$.
3. **Collision resistance**: It is hard to find any two different input messages $m_1,m_2(\not=m_1)$ that $f(m_1)=f(m_2)$.

There are many different hash functions available, each hashes with its own characteristics, strengths, and weaknesses. Common examples of hash functions include MD5, SHA-1, SHA-2, and SHA-3. (Note: MD5 and SHA-1 are now deprecated and generally should not be used for cryptographic purposes.)

## Merkle Tree

A **Merkle tree** is a tree data structure used in cryptography and computer science to efficiently verify the integrity and authenticity of large sets of data. The tree structure is based on cryptographic hash functions. To construct a Merkle tree, the elements to be stored are first hashed and the resulting hash values are arranged as the leaf nodes of the tree. Then, pairs of adjacent leaf nodes are hashed together to create a new set of hash values, which are used as the parents of the previous leaf nodes. This process is repeated recursively until a single hash value, known as the root hash, is generated. Here is an example of storing elements *“Alice”, “Bob”, “Charles”, “Daniel”, “Emma”, “Fiona”, “Grace”, and “Henry”* in a Merkle tree.

![Example of storing elements “Alice”, “Bob”, “Charles”, “Daniel”, “Emma”, “Fiona”, “Grace”, and “Henry” in a Merkle tree; $f$ is a cryptographic hash function.](https://img.learnblockchain.cn/attachments/2023/06/COHBUqpY648ad6f6b6471.png)

Example of storing elements *“Alice”, “Bob”, “Charles”, “Daniel”, “Emma”, “Fiona”, “Grace”, and “Henry”* in a Merkle tree; $f$ is a cryptographic hash function.

After storing elements in this Merkle tree, the root $h_{15}$ is opened. To prove “Alice” is in the Merkle tree, it is enough to provide $h_2,h_{10},h_{14}$. Then verifier can recompute $h_15$ by $h_{15}=f(f(f(f("Alice"),h_2),h_{10}),h_{14})$. This additional value required to recompute Merkle root is called **Merkle proof** (also known as Merkle path).

![Example of proving the existence of element “Alice” in a Merkle tree. Green-colored boxes denote the Merkle proof.](https://img.learnblockchain.cn/attachments/2023/06/FjLdb7vF648ad6f75d255.png)

Example of proving the existence of element *“Alice”* in a Merkle tree. Green-colored boxes denote the Merkle proof.

Due to the preimage resistance of $f$, Merkle proof does not reveal the other stored elements and the total number of elements in Merkle proof is log scale of the total number of elements stored in Merkle tree.

## Commitment Scheme

A **commitment scheme** is a cryptographic protocol that allows a party to commit to a message or a value, without revealing the value itself, and later reveal it in a verifiable manner. This is useful in scenarios where a party needs to prove that they made a commitment to a particular message at an earlier time without revealing the message until a later time. Check out this scenario:

> Alice has the foreknowledge of tomorrow's Nasdaq closing price $p$. Alice wants to **convince her foreknowledge without revealing the value itself**. Then Alice can commit price $p$ by choosing sufficiently long random string secretsecret and going public with $com=f(secret\Vert p)$ where $f$ is a cryptographic hash function and $\Vert$ is a concatenation operation. Due to preimage resistance property, it is impossible to recover $p$ from comcom. After tomorrow, $p$ is known to everyone. Then Alice opens secretsecret. Now Alice’s foreknowledge is verified by checking $com \overset{\text{?}}{=}f(secret\Vert p)$.

❓ **Question:** Is secretsecret essential? What if defining $com=f(p)$ instead of $com=f(secret \Vert p)$?

**Answer:** $p$ can be revealed by checking $f(1),f(2),\cdots$ until hash value is the same as comcom. The secret acts as a salt that prevents brute-forcing the hash to reveal the secret.

## (Non-interactive) Zero-Knowledge Proof

A **zero-knowledge proof** is a cryptographic protocol that allows a prover to demonstrate to the verifier that a given statement is true without revealing any additional information beyond the truth of the statement itself. In other words, it allows a prover to convince a verifier that they know a secret value without revealing that value or any other information about it. Zero-knowledge proof must satisfy the below three properties:

1. **Completeness**: If the statement is true, then an honest prover should be able to convince the verifier of its truth.
2. **Soundness**: If the statement is false, then no cheating prover should be able to convince the verifier of its truth.
3. **Zero-knowledgeness**: The proof should not reveal any additional information beyond the truth of the statement.

➕ **Additional Note** Completeness and soundness are clear but zero-knowledgeness can be confusing for a beginner. Can we formally define “any additional information is not revealed to verifier”? The answer is **yes**. To prove zero-knowledgeness of a given protocol, we show every message communicated between prover and verifier can simulated by someone who does not know the statement. For me, zero-knowledge proof for a graph coloring problem is really helpful to understand the concept of zero-knowledge proof. It is recommended to check out [this article](https://blog.cryptographyengineering.com/2014/11/27/zero-knowledge-proofs-illustrated-primer/).

Zero-knowledge proofs are classified into two types, **interactive** or **non-interactive**, depending on the communications between the prover and verifier. If the prover and verifier interact by exchanging messages, similar to an oral test, the protocol is called interactive. On the other hand, if the prover creates a proof that cann be verified without requiring any further interaction between the prover and verifier, the protocol is called non-interactive.

There are several examples of zero-knowledge proof protocols such as zk-SNARK, zk-STARK, Bulletproofs, and Ligero. While we will only cover details of the zk-SNARK, which is used in Tornado Cash later, the most important thing to note is that for any function $f$ and given output $y$, it is possible to prove the knowledge of an input $x$ satisfies $f(x)=y$ without revealing $x$ Moreover, any interactive zero-knowledge proof can be transformed into non-interactive zero-knowledge proof. Finally, for any function $f$ and given output $y$, a prover can prove their **knowledge of an input $x$ satisfies $f(x)=y $ without revealing $x$** by sending only proof $\pi$ to a prover  **with no interaction** .

# Protocol Overview

Tornado Cash aims to provide users with complete anonymity while using Ethereum by allowing them to make private transactions. So the main features of Tornado Cash are simply deposits and withdrawals. This can be done in a single transaction with a predetermined amount of Ether. The amount is not specified in the [white paper](https://berkeley-defi.github.io/assets/material/Tornado Cash Whitepaper.pdf), but it is either 0.1 or 1 or 10 or 100 ETH in the current implementations. The reason for fixing the amount is to prevent tracking the transaction based on its value. For example, there are 10 deposits from $addr$ _ $in_1$,$addr$ _ $in_2$, $\cdots$ ,$addr$_ $in_{10}$ and 10 withdraws from $addr$ _ $out_1$,$addr$ _ $out_2$,$\cdots $,$addr$ _ $out_{10}$. If the amount is different for each deposit, linking deposit address and withdrawal address is trivial.

## Setup

First, a [Pedersen hash function](https://iden3-docs.readthedocs.io/en/latest/iden3_repos/research/publications/zkproof-standards-workshop-2/pedersen-hash/pedersen.html) and [MiMC hash function](https://eprint.iacr.org/2016/492) are used in Tornado Cash. We denote each function as $H_1$ and $H_2$, respectively. The contract has a Merkle tree of height 2020, where each non-leaf node is the hash of its two children with $H_2$. Since the height is $20$, there are $2^{20}$ leaves. The leaves are initialized as $0$ and will be replaced by some value from left to right when a deposit is made. Since each leaf corresponds to a single deposit, the contract supports for only $2^{20} $deposits. After $2^{20 } $ deposits, no more deposits are allowed.

➕ **Additional Note** When the contract maintains a Merkle tree, it does not have to store all the leaves in a tree. It is enough to store only $20$ elements for each *newly-used* leaf, which correspond to the nodes in the route from the recently inserted leaf to the root. For further details, please check the [code](https://github.com/tornadocash/tornado-core/blob/master/contracts/MerkleTreeWithHistory.sol#L31). The `filledSubtrees` is the array representing a Merkle tree as above.

Although not necessary, the contract stores the most recent $n=100$ (as mentioned in the white paper) or $30$ (in the implementation) root values for user convenience, not just the most recent one. Finally, the contract also has a list of nullifier hashes to prevent double spending, which we will introduce later.

## Deposit

The process for a deposit is as follows:

1. A user generates two random numbers $k$(nullifier), $r$(secret) and computes commitment $C=H_1(k\Vert r)$. **This two numbers must be memorized**. This is a commitment scheme that we introduced earlier in this blog post.
2. Send ETH transaction to contract with data $C$. If the tree is not full, the contract accepts the transaction and replaces the leftmost zero leaf to $C$. This changes the $20$ elements in the tree, including the root.

Note that $k,r$ are hidden but commitment $C$ is opened to everyone, and the order is also preserved. For example, from the beginning, if addresses 0x111,0x222,0x111,0x222, and 0x333 make deposits, then it is publicly known that the first leaf belongs to 0x111, the second leaf belongs to 0x222, and the third leaf belongs to 0x333. However, this means almost nothing because, during withdrawal, the leaf index is not revealed.

## Withdrawal

The process for withdrawing the $l$-th leaf $C=H_1(k\Vert r)$ is as follows:

1. Compute the Merkle proof $O$, which proves an existence of $C$ in Merkle tree with root $R$. Root $R$ must be one of the recent $n$ root values.
2. Compute the nullifier hash $h=H_1(k)$.
3. Compute the proof $\pi $, which proves the knowledge of $l,k,r$ such that $h=H_1(k)$ and $O$ is a valid Merkle proof for $l$-th leaf $C=H_1(k\Vert r )$.
4. Send ETH transaction to contract with $R,h,\pi$. The contract accepts the request if proof $\pi $ is valid and  $h$ is not in the list of nullifier hashes.
5. The contract adds ℎ*h* to the list of nullifier hashes.

To understand this withdrawal procedure, we recall non-interactive zero-knowledge proof (NIZK). In NIZK, a prover can prove their **knowledge of an input $x$ satisfies $f(x)=y$ without revealing $x$** by sending only proof $\pi$ to prover with no interaction. Once we define $f$ as

$f(l,k,r,O)={1,if \,h=H_1(k)and O}$ is valid Merkle proof for $l$-th leaf $0$,else and the target output $y=1$, then proof$\pi$ represents that prover is a legitimate withdrawer **without revealing** $l,k,r,O$, so the anonymity is guaranteed. We discuss proof more in the *Zero-Knowledge Proof in Tornado Cash* section.

The withdrawal procedure seems sound. But what about the fee? If a user wants to withdraw a coin to a fresh wallet, the wallet cannot pay a fee because it has no balance. It is also impossible to pay from the original wallet because it allows linking the fresh wallet and original wallet, which violates anonymity. To resolve this issue, users can optionally use a **relay**. The user chooses coin recipient address $A$ and fee $f$ and includes them into the proof $\pi$ Then a user sends the proof to relay and relay transmits it into the contract. A relayer takes a fee as compensation, but they cannot change any withdrawal data, including recipient address.

# Zero-Knowledge Proofs in Tornado Cash

Now we have a bird’s-eye view of Tornado Cash. We will take a more in-depth look at the zero-knowledge proofs used in Tornado Cash in this section.

## zk-SNARKs

⚠️ **Recommendation** The mathematics behind zk-SNARKs, such as group theory, elliptic curve, pairing, and sigma protocol is quite challenging. While we will provide a brief introduction to zk-SNARK in this section, it may not be sufficient for those encountering the concept for the first time. Fortunately, there are numerous articles and slides available online that introduce zk-SNARKs and their basic concepts. We recommend reading these resources first to gain a better understanding if you are a newcomer.

zk-SNARK is an acronym that stands for **Zero-Knowledge Succinct Non-interactive Argument of Knowledge**.

1. Zero-Knowledge: Verifier learns nothing other than the statement is true.
2. Succinct: Proof size and verifier time is **sublinear.**
3. Non-interactive: Need no interaction.
4. Argument of Knowledge: Not only for existence of input $x$ but also prover’s knowledge of $x$.

Not only zero-knowledge but succinct is also mysterious. For example, if a prover wants to prove their knowledge of input $x$ such that $SHA256(x)=0^{256}$ to a verifier, aside from zero-knowledgeness, the easiest way is just to send $x$ to verifier. Of course, the proof size is$\vert x\vert$ and verifier time is exactly the same as computing $SHA256(x)$, so it is not succinct. Now we face the question, *Is it even possible to prove something more cheaply than directly calculating it*? Before we start introducing details of zk-SNARKs, we will show a simple example that allows a verifier to accept a proof with less computation than by directly calculating it. Here is the example:

> There are two $n$ by $n$ matrices $A,B,$ and $C$. The prover wants to prove that $C=AB$. If the verifier directly calculates $AB$ and compares it with $C$, the time complexity is $O(n^3)$— or $O(n^{2.373})$ by using a [state-of-the-art algorithm](https://arxiv.org/abs/2010.05846). However, if the verifier selects random vector $v$ size of $n$ and checks whether $A \cdot(Bv)\overset {\text{?}}{=}Cv$, its time complexity is reduced to $O(n^2)$. It is possible such that $AB\neq C$but $A \cdot (Bv) \overset {\text{?}}=Cv$so the verifier might accept wrong $C$, but the probability of this occurring is dramatically reduced when the verifier repeats this verification for different values of $v$.

## Groth16

Let’s move on to the zero-knowledge proof system actually used in Tornado Cash. Tornado Cash uses [Groth16](https://eprint.iacr.org/2016/260), which is an improved version of [Pinocchio](https://eprint.iacr.org/2013/279). In Groth16, a prover transforms their statement into a **QAP** (quadratic arithmetic program) form. We will show a transformation step by step using a simple example:

```python
def f(x, y):
    return x**2 + 3 * y**2 + 10

assert f(x,y) == 17 # f(2, 1) = 17
```

### Flattening

Prover wants to prove their knowledge of $x,y$ satisfy $f(x,y)=17$. To do this, the prover first converts the given statement into a sequence of special forms where `x = y` and `x = y (op) z` , where `y, z` can be variables or numbers, and `op` can be + or *. This is similar to the concept of three address code from compilers. The transformation of the equation $f(x,y)$ is as follows:

```python
x2 = x * x
y2 = y * y
t1 = 3 * y2
t2 = x2 + t1
out = t2 + 10
```

### R1CS

After flattening, these conditions are transformed into a **R1CS** (Rank-1 Constraint System). R1CS is a system of equations, where each equation is defined by a triplet of vectors $(\vec{a_i},\vec{b_i},\vec{c_i})$ such that $(\vec{a_i} \cdot \vec s) \times (\vec{b_i} \cdot \vec s) \times (\vec{c_i} \cdot \vec s)$. In our case, we will build a system such that the solution vector $\vec s=(1,x,y,x2,y2,t1,t2,out)$. For example, flattened equation `x2 = x * x` is transformed into

$$
\vec a_1=(0,1,0,0,0,0,0,0) \vec b_1=(0,1,0,0,0,0,0,0) \vec c_1=(0,0,0,1,0,0,0,0)
$$
As you can see, each of the elements in vectors $(\vec a_i,\vec b_i,\vec c_i)$ represents a coefficient for a variable (or constant) used in the system of equations. And the solution vector $\vec s$ represents all of the variables used in the system.

Continuing with our example, `y2 = y * y` is transformed into

$$
\vec a_2=(0,0,1,0,0,0,0,0) \vec b_2=(0,0,1,0,0,0,0,0) \vec c_2=(0,0,0,0,1,0,0,0),
$$
`t1 = 3 * y2` is transformed into

$$
\vec a_3=(0,0,0,0,1,0,0,0) \vec b_3=(3,0,0,0,0,0,0,0) \vec c_3=(0,0,0,0,0,1,0,0),
$$
and `t2 = x2 + t1, out = t2 + 10` is transformed into

$$
\vec a_4=(10,0,0,1,0,1,0,0) \vec b_4=(1,0,0,0,0,0,0,0) \vec c_4=(0,0,0,0,0,0,0,1).
$$
After representing all the flattened equations in this format, the only prover who knows the correct $x,y$ can find solution vector $\vec s$ of given constraint system. So the prover’s ultimate goal now is to prove their knowledge of $\vec s$.

### QAP

The purpose of QAP is to prove same system but decrease communication cost using polynomials instead of vector dot products. From the vectors in R1CS, we can derive polynomials. For example, polynomial $a_1$ (note: this is NOT $\vec {a_1}$, which is a vector in the R1CS) is defined by the points $a_1(1)=0,a_1(2)=0,a_1(3)=0,a_1(4)=10$, where $0,0,0,10$ corresponds to the terms for the elements corresponding to 11 in the solution vector in the coefficient vectors $\vec {a_1},\vec {a_2},\vec {a_3},\vec {a_4}$, respectively. This polynomial is degree $3$ and can be generated by [Lagrange interpolation](https://en.wikipedia.org/wiki/Lagrange_polynomial). Polynomials $a_x,a_y,a_{x2},a_{y2},a_{t1},a_{t2},a_{out}$ are also generated in the same way. And the same goes for .$b_1,\cdots,b_{out},c_1,\cdots,c_{out}$.

Let $\vec A=(a_1,a_x,a_y,a_{x2},a_{y2},a_{t1},a_{t2},a_{out})$ (yes, vector of polynomials!) and the same goes for $\vec B,\vec C$. It can observed that $(\vec A(x) \cdot \vec s)\cdot (\vec B(x)\cdot \vec s=\vec C(x) \cdot \vec s$ for $x=1,\cdots,4$.Let $A(x)=(\vec A(x)\cdot \vec s)$ and the same for$B(x),C(x)$. Then, there exists a polynomial $H(x)$ such that $A(x)\cdot B(x)-C(x)=H(x)\cdot(x-1)(x-2)(x-3)(x-4)$ if $\vec s$ is properly chosen. In this example, $f(2,1)=17$, so $\vec s=(1,2,1,4,1,3,7,17)$. This $\vec s$ is called **satisfying assignment**.

From this long journey, we transformed the statement into multiplications of polynomials. If a prover can convince that

1. $A(x),B(x)$ and $C(x)$ are derived from same $\vec s$, and
2. exists $H(x)$ such that $A(x) \cdot B(x)-C(x)=H(x) \cdot Z(H)$ where$Z(x)=(x-1)(x-2)(x-3)(x-4)$,

then the verifier accepts the prover’s knowledge. To guarantee succinctness, rather than directly handling polynomials, $A(t)\cdot B(t)- C(t)=H(t) \cdot Z(t)$ for some random point $t$ is checked.

### Homomorphic Hiding & Pairing

The equation $A(t)\cdot B(t)- C(t)=H(t) \cdot Z(t)$ can hold for some $t$ when $A(t)\cdot B(t)- C(t)\not=H(t) \cdot Z(t)$. This probability is negligible, but if $t$ is known, then an attacker can easily construct $A(x),B(x),C(x),H(x)$ satisfying $A(t)\cdot B(t)- C(t)=H(t) \cdot Z(t)$. Therefore $t$ should be hidden but allowing the prover to calculate $A(t),B(t),C(t),H(t)$. It seems contradictory, but **homomorphic hiding** allows this. From the hardness of elliptic curve discrete logarithm problem, we define an encryption function $E(x)=xg$ for a generator $g$. Then $E$ satisfies the following:

1. It is hard to find $x$ from $E(x)$.
2. $x \neq y$ then $E(x) \neq E(y)$.
3. $E(x+y)=E(x)+E(y)$.
4. $a \cdot E((x)=E(ax)$.

Rather than directly giving $t$ to the prover, the prover is given $E(t^0),E(t^1),\cdots$ .Then, since $A(t),B(t),C(t)$, and $H(t)$ are linear combinations of $t^0,t^1,\cdots$, the prover can calculate $E(A(t)),E(B(t)),E(C(t)),E(H(t))$ . Moreover, the fact that  $E(A(t)),E(B(t)),E(C(t)),E(H(t))$is really derived form $E(t^0),E(t^1),\cdots$ can be proven by the **knowledge of coefficient assumption test**. We omit information of the coefficient assumption test in this article.

Now the prover generates $E(A(t)),E(B(t)),E(C(t)),E(H(t))$, which will be given to the verifier, and the verifier can generate $E(Z(t))$ since $Z(x)$ is known. However, the verifier cannot check $A(t) \cdot B(t)-C(t)=H(t) \cdot Z(t)$ because $E$ is not homomorphic in multiplication. We need another mapping called **[pairings](https://en.wikipedia.org/wiki/Pairing-based_cryptography)**. A pairing is a map $G_1 \times G_2 \rightarrow G_T$ that satisfies $e(aP,bQ)=ab \cdot e(P,Q)$ where $G_1,G_2$ are elliptic curves with the same equation but different generators $g_1,g_2$ having order $q$ and $G_T$ is a cyclic group of order $q$. We slightly extend $E$ to $E_1$ and $E_2$, where $E_1(x)=xg_1,E_2(x)=xg_2$.

From now on, we can multiply hiding values. Finally, $A(t) \cdot B(t)-C(t)=H(t) \cdot Z(t)$ is checked from $e(E_1(A(t)),E_2(B(t))/e(E_1(C(t)),E_2(1)) \overset {?}{=}e(E_1(H) \cdot E_2(Z(t)))$. Since only $E_1(A(t)),E_2(B(t)),E_1(C(t))$ are required to verify, the proof size is fixed to $2$ elements of $G_1$ and $1$ element of $G_2$.

## Trusted Setup

In this procedure, the prover needs $E_1(t^0),E_1(t^1),\cdots,E_2(t^0),E_2(t^1),\cdots$ generated from a random $t$. One possible scenario is that the verifier chooses random $t$ generates $E_1(t^0),E_1(t^1),\cdots,E_2(t^0),E_2(t^1),\cdots $ and sends these values to the prover. However, this method is very costly for prover and only enables an interactive model. In the non-interactive model, the verifier cannot send something to the prover. Therefore, instead of verifier, a third party generates **common reference string** (CRS) ****$E_1(t^0),E_1(t^1),\cdots,E_2(t^0),E_2(t^1),\cdots $and opens it to everyone. This is called a **trusted setup**. The requirement of trusted setup is a significant weakness of zk-SNARK.

➕ **Additional Note** Originally, CRS contained some circuit-specific values other than $E_1(t^i),E_2(t^i)$, and the exact procedure is little more complex because it requires checking whether $A(x),B(x)$, and $C(x)$ are derived from same $\vec s$ using knowledge of coefficient assumption. You may refer to the [Groth16 paper](https://eprint.iacr.org/2016/260) to learn more about this.

### Powers-of-Tau

In Tornado Cash, the users act as provers while the contract serves as the verifier. In the beta version of Tornado Cash, the Tornado Cash team generated CRS and made it public ([see here](https://github.com/tornadocash/tornado-core/releases/tag/1.0), proving key and verification key are derived from CRS). If all users trust the Tornado Cash team, they can generate proof using CRS provided by the team. However, if the Tornado Cash team become malicious, they can generate forged proof and potentially steal all the coins. To resolve this issue, the Tornado Cash team replaced CRS generated from the crypto community, called **power-of-tau**. User 1 to $k$ first hold their own random $t_1,t_2,\cdots ,t_k$. User 1 generates $E_1(t^0_1),E_1(t^1_1),\cdots,E_2(t^0_1),E_2(t^1_1),\cdots$. Note that $E_1(t_1^i)\cdot g_1,E_2(t_1^i)\cdot g_2$. Then user 2 generates $E_1((t_1t_2)^0),E_1((t_1t_2)^1),\cdots,E_2((t_1t_2)^0),E_2((t_1t_2)^1),\cdots$ from $E_1((t_1t_2)^i)=t_2^i \cdot E_1(t_1^i),E_2((t_1t_2)^i)=t_2^i \cdot E_2(t^i_1),$ without knowing $t_1$. After user $k$ generates the list, the CRS from secret $t=t_1t_2 \cdots t_k$ is generated. In the case of Tornado Cash, [1,114 users participated](https://tornado-cash.medium.com/the-biggest-trusted-setup-ceremony-in-the-world-3c6ab9c8fffa) and [CRS is successfully replaced](https://github.com/tornadocash/tornado-core/releases/tag/v2.1).

## Implementations in Tornado Cash

Now we get back to statements in Tornado Cash. Our goal is to prove and verify the knowledge of $l,k,r,O$ such that for a $f(l,k,r,O)=1$ for

$f(l,k,r,O)={1,if h=H_1(k)}$ and $O$ is valid Merkle proof for $l$-th leaf 0,else

This $f$ needs to be transformed into a QAP. Tornado Cash uses circuit compilers [Circom](https://docs.circom.io/) and [snarkjs](https://github.com/iden3/snarkjs). Circuit compiler Circom has their own language called [circom language](https://docs.circom.io/circom-language/signals/). After coding $f$ in a [circom language](https://github.com/tornadocash/tornado-core/tree/master/circuits), the code is transformed into the R1CS using circom compiler. After that, `snarkjs` takes care of almost everything, such as generating CRS (via the trusted setup ceremony in case of Tornado Cash), proof, and a [smart contract for the verification](https://github.com/tornadocash/tornado-core/blob/master/contracts/Verifier.sol).

# Security Concerns

In this section, we will discuss several security concerns for protocol and user levels. It is important to note that addressing these issues does not necessarily mean that Tornado Cash is vulnerable.

## Hash Functions

Using different hash functions $H_1$ and $H_2$ seems unnecessary, and the reasons for this choice were not given by the authors. ABDK Consulting, who audited Tornado Cash, also pointed this out [(see here, section 5.1)](https://web.archive.org/web/20220509033247/https://tornado.cash/Tornado_cryptographic_review.pdf). Moreover, the Pedersen hash function has a homomorphic property, so it is not a cryptographic hash function. Instead, defining both $H_1$ and $H_2$ as MiMC (or any other SNARK-friendly hash function) and applying domain separation might be better.

## Dependencies

The contract source code is not very long and well-analyzed. However, as is often the case, small flaws can cause an apocalypse in this field. In fact, in October 2019, the Tornado Cash team discovered a vulnerability where an attacker could make arbitrary deposits due to issues with the external dependency of the zk-SNARK implementation of the MiMC [(see here)](https://tornado-cash.medium.com/tornado-cash-got-hacked-by-us-b1e012a3c9a8). Therefore, all the dependencies must be also carefully audited.

## User Mistakes

The user must choose a high entropy $k$ and $r$. There are also possibilities of losing anonymity from user mistakes. We recommend reading [this article](https://github.com/tornadocash/docs/blob/en/general/tips-to-remain-anonymous.md).

# Conclusion

Tornado Cash is a popular, decentralized coin mixer on the Ethereum network that offers strong anonymity to its users through the use of cryptographic techniques. As a main feature of Tornado Cash is anonymity in making private transactions, we looked at the math behind their deposits and withdrawals. Taking a deeper dive into their zero-knowledge proof system, Groth16, we exemplified how a transformation of a prover’s statement into quadratic arithmetic program form may occur with reference to flattening, homomorphic hiding and pairing, and the R1CS – and followed with a discussion of procedures such as trusted setup and powers-of-tau. There were also several security concerns to note (including using different hash functions, dependencies needing auditing, and user mistakes). Since the anonymity and privacy in Tornado Cash is one of its strongest features, it is interesting to take a look behind the curtain and see the math behind it.

⚠️ **Disclaimer** It is worth recognizing that while the anonymity provided by Tornado Cash can be beneficial, it can also be used for illegal or prohibited activities. Additionally, it is important to note once again that using Tornado Cash for any transactions within the United States or by U.S. persons is prohibited. We recommend you do your own research and consult with qualified legal counsel before interacting with Tornado Cash.



原文链接：https://www.zellic.io/blog/how-does-tornado-cash-work