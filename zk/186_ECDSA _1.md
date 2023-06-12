# zk-ECDSA: zkSNARKs for ECDSA (Part 1)

We present [circom-ecdsa](https://github.com/0xPARC/circom-ecdsa), an efficient proof-of-concept implementation of zkSNARK circuits for ECDSA algorithms in circom.

## Introduction

In the past several years, the Ethereum and Bitcoin networks have bootstrapped large public-key identity registries, putting the building blocks for user-controlled digital identity in the hands of millions of people. Anyone can create a public/private key pair, hold digital assets, and participate in a wide ecosystem of decentralized applications using tools for signing and authentication.

However, as we've outlined in some of our [previous posts](https://0xparc.org/blog/zk-id-1), public-key cryptography alone is likely insufficient for building expressive identity systems. Application and infrastructure builders will need a richer set of cryptographic tools in order to allow users to prove and compose arbitrary claims about knowledge of private keys, membership in groups, possession of attestations, and more. Concretely, these claims might look like:

- I am the owner of a Dark Forest planet NFT, but I won't tell you which one (i.e. I know a private key corresponding to one of these 1024 public keys of known high-reputation accounts).
- I've obtained enough votes to pass a DAO funding proposal, but I won't provide you the full vote log (i.e. I possess message signatures of a "yes" vote from 3 out of 5 public keys).

One way to enable claims like these is to implement Ethereum's key-generation and digital signature algorithms inside of a zkSNARK. zkSNARKs are a new cryptographic primitive that allow users to prove claims about the execution of arbitrary computation. In theory, this would allow developers to embed arbitrary identity claims into their applications.

There are a number of challenges to implementing existing signature algorithms in zkSNARKs. Today's zkSNARK proving systems generally use [specific elliptic curves](https://github.com/zcash/libsnark) that only allow operations on numbers represented as residues modulo [a specific prime](https://iden3-docs.readthedocs.io/en/latest/iden3_repos/research/publications/zkproof-standards-workshop-2/baby-jubjub/baby-jubjub.html). This limits the maximum "register size" for numbers used in zkSNARK proofs to 254 bits. However, networks like Ethereum and Bitcoin use the Elliptic Curve Digital Signature Algorithm (ECDSA) and the [secp256k1 curve](https://www.secg.org/sec2-v2.pdf), a NIST-standard curve that is not "SNARK-friendly."[1](https://0xparc.org/blog/zk-ecdsa-1#user-content-fn-1) Operations on secp256k1 elliptic curve points involve arithmetic on 256-bit numbers, which would overflow the 254-bit registers allowed in today's SNARK systems. Implementing ECDSA algorithms inside requires us to build ZK circuits for BigInt arithmetic and secp256k1 operations using 254-bit registers; essentially, we must perform "non-native field arithmetic."

In this series of posts, we present a proof-of-concept implementation of ECDSA circuits in [circom](https://docs.circom.io/), a programming language for specifying ZK circuits. These circuits can then be used to generate zkSNARKs. We break down techniques for optimizing non-native field arithmetic, and suggest a path to a production-grade toolstack for ZK Identity claims based on ECDSA registries.

## circom-ecdsa

Our main contribution is the [circom-ecdsa](https://github.com/0xPARC/circom-ecdsa) repository, which includes a collection of (unaudited) ZK circuits for the following operations:

- bigint: circuits for BigInteger/non-native field arithmetic.
- secp256k1: circuits for secp256k1 curve operations.
  - `Secp256k1AddUnequal` adds two non-identical points using the elliptic curve group addition law.
  - `Secp256k1Double` doubles a point.
  - `Secp256k1ScalarMult` multiplies a point by a scalar.
  - `Secp256k1PointOnCurve` checks that a point is on the curve.
- ecdsa: circuits for ECDSA algorithms.
  - `ECDSAPrivToPub` computes and constrains the public key associated with a private key.
  - `ECDSAVerifyNoPubkeyCheck` checks that a signature for a given message and public key is valid. To reduce the number of constraints, this circuit does **not** verify that the public key itself is valid; if you are interacting with any public keys, checking their validity must be handled out-of-band.
  - We have not implemented the extended verify or ecrecover algorithms, but they are relatively easy to do given the above.
- eth_addr: a circuit for proof of private key of Ethereum address.
  - `PrivKeyToAddr` computes and constrains the Ethereum address associated with a private key.

We represent private keys, public key coordinates, and other large (256+ bit) numbers in a little-endian form adapted to zkSNARKs. For example, we generally use arrays of three signals constrained to 86 bits each to represent 256 bit numbers; a three-signal array `arr` can be interpreted as the number `arr[0] + 2**86 * arr[1] + 2**172 * arr[2]`.

Instructions for building the repository and other usage notes are included in the README. A small "group signature" CLI demo is also included for demonstration purposes. As noted in the repository, these circuits are unaudited and not suitable for production-grade usage. We are currently exploring some directions for semi-automated verification methods.

### Benchmarks

We use a number of techniques to optimize our circuits and bring them down to practical sizes, including a polynomial multiplication trick from [xJsnark](https://github.com/akosba/xjsnark) and precomputation of useful multiples of the generator point. Proof of private key can be run in-browser, while signature verification generally requires a dedicated server. There are still a number of optimizations that can be made to further reduce the proving key size and proving time, which we will discuss in our next post.

|                                      | ECDSAPrivToPub | PrivKeyToAddr | ECDSAVerifyNoPubkeyCheck |
| ------------------------------------ | -------------- | ------------- | ------------------------ |
| Constraints                          | 416883         | 568823        | 9480361                  |
| Circuit compilation                  | 90s            | 115s          | 324s                     |
| Witness generation                   | 8s             | 7s            | 150s                     |
| Trusted setup phase 2 key generation | 150s           | 167s          | 5569s                    |
| Trusted setup phase 2 contribution   | 28s            | 47s           | 767s                     |
| Proving key size                     | 254MB          | 347MB         | 5.8GB                    |
| Proving key verification             | 157s           | 185s          | 6211s                    |
| Proving time                         | 12s            | 17s           | 239s                     |
| Proof verification time              | <1s            | <1s           | <1s                      |

*All benchmarks use Groth16 on a 20-core 3.3GHz, 64G RAM machine running the circom and snarkjs toolstack.*

## What can we do with zk-ECDSA?

Because ECDSA is the signature scheme for accounts in Ethereum, zkSNARKS for `PrivKeyToAddr` and `ECDSAVerify` allow users to prove ownership of an account in zero-knowledge. zk-ECDSA is thus a core primitive for the application ideas below:

- **Proof of group membership:** Crypto communities often give certain access permissions to Ethereum addresses in a certain group (e.g. private Discord channels for verified holders of an NFT). In these cases, proof of ownership is checked by tools like [Collab.Land](https://collab.land/) via ECDSA signature verification. By replacing this signature by a zkSNARK of *knowledge of a signature* for an address in a given group, zk-ECDSA enables this operation without compromising privacy. Early experiments in this direction include [Proof of Dark Forest Winner](https://github.com/jefflau/zk-identity) and the design for [Vocdoni](https://blog.aragon.org/binding-execution-on-ethereum-with-zk-rollups/), which highlights implementing zk-ECDSA as a key challenge.
- **Private airdrops:** A [common](https://uniswap.org/blog/uni) [pattern](https://ens.mirror.xyz/-eaqMv7XPikvXhvjbjzzPNLS4wzcQ8vdOgi9eNXeUuY) for token distribution is a *retroactive airdrop*, where a prespecified list of addresses can claim tokens based on prior usage of a protocol. Current implementations require users to demonstrate inclusion of their address in a Merkle tree to receive tokens. By replacing this public Merkle proof with a zkSNARK of *knowledge of a signature corresponding to an address in the Merkle tree*, zk-ECDSA allows privacy preserving airdrop claims. [StealthDrop](https://stealthdrop.xyz/) is an early prototype built on our zk-ECDSA work.
- **On-chain Snapshot vote aggregation:** Governance votes in DAOs are often done using signatures on off-chain platforms like [Snapshot](https://snapshot.org/#/) to save gas. Once a vote is concluded, on-chain implementation depends on social enforcement. Using zk-ECDSA as a primitive, @ludens proposes building a zkSNARK which proves that there are enough votes to pass a proposal and verifies signatures within the SNARK. Such a zkSNARK could be verified on-chain and implement the off-chain governance decision in a trustless fashion. [Vocdoni](https://blog.aragon.org/binding-execution-on-ethereum-with-zk-rollups/) is a proposal for a design in this direction.

We discuss these ideas at greater length in our ZK Identity [posts](https://0xparc.org/blog/zk-ecdsa-1).

## What needs to happen to make zk-ECDSA production-grade?

Our zk-ECDSA construction is unaudited and not intended for use in production, which is a general difficulty in the ZK space. We see the following as the main remaining steps to get zk-ECDSA to production:

- **Auditing, testing, and formal verification of circuits:** To have confidence in our zk-ECDSA circuits, we must verify that (1) witness generation is correct and (2) there are no missing constraints. We have used traditional unit testing for (1), but building confidence in (2) remains challenging. In addition to a traditional [audit](https://tornado.cash/audits/TornadoCash_circuit_audit_ABDK.pdf), we are building tools for automated verification of (2).
- **Circuit-specific trusted setup or porting to PLONK:** We currently use Groth16 as our proof system to take advantage of the powerful `circom`/`snarkjs` toolstack. This requires a per-circuit [trusted setup ceremony](https://zkproof.org/2021/06/30/setup-ceremonies/) to ensure security, meaning we need to find a decentralized group of ceremony participants to deploy our current circuits. Changing to a [PLONK](https://vitalik.ca/general/2019/09/22/plonk.html)-based proof system would remove the need for this, since PLONK has a *universal* trusted setup. This change is blocked on the availability of performant production-grade PLONK implementations, which are just emerging as of this post.
- **Accessibility of prover infrastructure:** Because our zk-ECDSA construction has such a large number of constraints, generating proofs requires heavy duty compute (our test machine has 20 cores and 64G RAM) beyond most user capabilities. Deployment thus requires either developing a robust remote prover infrastructure or optimizing our circuits to make proving more broadly accessible. Switching to a PLONK-based infrastructure may enable such optimization via constructions like [plookup](https://eprint.iacr.org/2020/315.pdf).

Stay tuned for Part 2 on the techniques and optimizations in our implementation of zk-ECDSA!

## Acknowledgements

This project was built during [0xPARC](http://0xparc.org/)'s [Applied ZK Learning Group #1](https://0xparc.org/blog/zk-learning-group).

We use a [circom implementation of keccak](https://github.com/vocdoni/keccak256-circom) from Vocdoni. We also use some circom utilities for converting an ECDSA public key to an Ethereum address implemented by [lsankar4033](https://github.com/lsankar4033), [jefflau](https://github.com/jefflau), and [veronicaz41](https://github.com/veronicaz41) for another ZK Learning Group project in the same cohort. We use an optimization for big integer multiplication from [xJsnark](https://github.com/akosba/xjsnark).

## Footnotes

## Footnotes

1. While ECDSA is not SNARK-friendly, other SNARK-friendly ECC-based digital signature algorithms do exist, such as [EdDSA](https://en.wikipedia.org/wiki/EdDSA). [↩](https://0xparc.org/blog/zk-ecdsa-1#user-content-fnref-1)



原文链接：https://0xparc.org/blog/zk-ecdsa-1