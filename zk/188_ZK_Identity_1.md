# ZK Identity: Why and How (Part 1)

*Last month, we kicked off the 0xPARC ZK-Identity Working Group: a working group experimenting with zkSNARKs to build digital identity tools. This post is the first in a series on why advances in cryptography will be important for enabling new identity primitives. This first post covers the “Why”; future posts will cover the “How.”*

The design of online identity systems has been the subject of intense debate in the last few years. Modern digital identity systems have enabled new and complex kinds of online interactions and communities. Unfortunately, many of these systems also have significant weaknesses.

Many of these weaknesses can be attributed to inherent limitations of centralized identity system designs. Firstly, these systems are generally built around central points of control—and therefore, central points of failure. Modern e-commerce, social media, and messaging platforms are vulnerable to [pressure or interference](https://www.bbc.com/news/59338205) from powerful actors (such as authoritarian governments), or to [technical attacks](https://www.upguard.com/breaches/facebook-user-data-leak) from malicious hackers; when a central operator is coerced or hacked, many parties beyond just the central operator are put at risk. Secondly, these systems rely on the concentration of power in the hands of operators who cannot possibly be fully aligned (financially, socially, or morally) with all of their users—for example, private social media companies with diverse global audiences must often [make decisions](https://blog.twitter.com/en_us/topics/company/2020/suspension) about what constitutes an act of unjustified censorship versus an act in the interest of public safety, though they are often ill-equipped to do so.

Decentralized and cryptographic mechanisms are not a magical panacea, but they do offer some useful tools, and they expand the design space for digital identity systems. As more of our social and economic lives move online, designing secure, privacy-preserving, and user-controlled identity systems will become increasingly important. In this post, we’ll argue that new cryptographic primitives such as zkSNARKs will be crucial for building identity systems with these properties.

At their core, zkSNARKs are useful because they enable users of digital systems to produce *credible claims* of arbitrary complexity, without reliance on a trusted party. All identity systems are built around some mechanism for generating *credible claims* of identity and reputation—typically, fairly complex claims attached to attestations from a trusted authority, like a government or a company. By applying zkSNARK constructions to claims about identity and reputation, we can rearchitect digital identity systems and put control and data custody in the hands of users.

## Credible Claims

As zkSNARKs operate over precise, mathematically-defined “claims,” we must first precisely break down the nature of claims involved in identity systems.

It’s hard to do business with a completely unknown and untrusted counterparty. Common sense tells us that as trust between counterparties decreases, the likelihood of cooperation does as well; game theory tells us that the optimal strategy in a one-shot prisoner’s dilemma is [always to defect](https://en.wikipedia.org/wiki/Prisoner's_dilemma#Strategy_for_the_prisoner's_dilemma). Would you be more willing to buy a used car from a close friend who is tightly linked to your social circles, or from a sleazy Craigslist seller dropping by from out-of-town, who won’t even give you their name?

To build trust with each other, we need to be able to make *credible claims*: claims about our identities and reputations that people who we interact with can find believable. It’s not really a credible claim if the Craigslist seller above assures you he’s “sold tons of cars before, and everyone loves my cars—take my word for it.” But if this claim was associated with a collection of five-star ratings from verified buyers on a popular website that you know about, it would certainly feel more credible.

The idea of credible claims sounds obvious, but building and legitimizing a mechanism (in this example, a popular listings website) for producing credible claims is no easy task. In traditional models, our usual solution is to delegate record-keeping management to a trusted authority, so that they can attest to our claims about identity and reputation and lend them credibility. This authority must prove their legitimacy and trustworthiness over time (often in adversarial environments), and maintain infrastructure for generating and distributing attestations at scale.

Crucially, in most models, *the central authority’s attestation is what makes a claim credible*. *This* is a valid government ID, so I’m a citizen; *that* is an accurate list of my followers, so I’m a social influencer; *these* are a vetted set of reviews and ratings, so I’m a trustworthy online retailer.

Another application for credible claims lives at an even lower level of the stack. To begin with, how do you know that the person or business you’re interacting with is presenting you with a claim about themselves, and not someone else? In systems that depend on a trusted authority, these authorities take on the even more basic function of attesting to identity itself. An API [access token](https://developers.facebook.com/docs/facebook-login/access-tokens/), a government-issued passport, or a chain of signatures generated by Certificate Authorities when you visit a website are all attestations for claims about identity.

Useful identity systems allow participants to make a very wide variety of complex credible claims:

- (Digital) When you order food delivery via Doordash, the Doordash webserver makes a credible claim to you (”I am the Doordash webserver” via a chain of DNS signatures); you make credible claims about your identity to Doordash via a third-party identity provider (”I am a Doordash user who should be allowed to access this account’s saved credit cards” via ”Login with Google”); you make credible claims about future payment to Doordash via various financial institutions (”I have the money to pay you for my order, and this payment will arrive soon” via a credit card provider that does not decline the transaction).
- (Physical) When you take out a mortgage to purchase a house, you’re implicitly making a huge number of credible claims about your identity and reputation to your bank, to your real estate agent, to a seller, and to the government.
- (Mixture) When you apply for a job, you make credible claims to your potential employer by drawing on many different attestation systems. You claim that you have adequate training and temperament for the job, citing attestations (degrees, certificates) from educational institutions or professional certification authorities, from other colleagues you’ve worked with, and from prior companies. Social media and other online account providers provide further attestations for implicit claims about the kind of person you are.

## Privacy

The fact that nearly all identity systems inherently require *privacy* to function as intended further complicates the picture.

Privacy is important for ethical and ideological reasons that are sometimes controversial; but even more fundamentally, it’s often necessary as a simple matter of system design. For example, almost all identity systems rely on the notion of secret data to generate believable claims about identity—a password, Social Security number, private key, credit card PIN, account recovery question, etc. This data must be kept private, for obvious reasons. Additionally, the process of producing credible claims with completely transparent data may have negative externalities, or at least externalities that are hard to reason about; privacy guarantees prevent these. For example, if you had to present your entire financial history just to buy or sell an item in an online marketplace—bank statements, credit card transactions, loan payments, and the works—a counterparty could use this information to initiate out-of-scope interactions that have nothing to do with the original transaction (negative examples include advertising, or even harassing and blackmailing). Privacy “sandboxes” one-off interactions, cleanly defining and limiting their scope, so that we can build more complex systems from simple and understandable building blocks.

In traditional systems that require privacy, we have to delegate even more power to the central authority—in such systems, central authorities store private data and attest to credible claims about this data that are *nearly* *impossible to verify*.

## The Role of Cryptography

So far, all of the models we’ve discussed for credible claim generation and identity systems have involved a centralized actor. And as we’ve discussed, there are plenty of reasons why we may want to explore systems that don’t rely on a powerful record-keeper or manager.

Immediately, we run into the obvious problems: how can I trust your claims, when I don’t have your data? If you send me your data, how do I know that the data is valid? And what do we do if you’re trying to make claims about private data? This is exactly where cryptography comes in.

Viewed in our lens, much of applied cryptography (and consensus) in the last fifty years has been a project of gradually expanding the scope of what credible claims it is possible to make without a trusted authority, under various resource constraints and privacy conditions:

- Digital signature schemes allow me to make a credible claim about the consistency of my identity online, across a sequence of multiple different actions, by signing a series of messages with the same private key. “I am authorized to charge to Alice’s credit card.”
- Group signature schemes allow me to make more complex privacy-preserving claims about identity. “I am a member of this alumni organization, but I won’t tell you which member.”
- Signature aggregation, multi-signature, and threshold signature schemes allow me to make claims about group behavior, under various different resource constraints. “This large collective body—not just a single rogue employee—has authorized a currency transfer from our financial accounts.”
- Consensus schemes and programmable smart contracts allow me to make credible and irreversible commitments to future actions. “If you send me digital asset A, I will immediately send you digital asset B in return.”

Progress has historically been slow—each of these cryptographic primitives defines a new and tightly scoped kind of claim, whose structure is highly specified. However, this has changed in the last several years.

What’s exciting today is that we now have the machinery to make *arbitrary* credible claims efficiently, thanks to SNARKs. And with the zero-knowledge property of zkSNARKs, we can also tune the privacy guarantees of our claims exactly to our liking.

Here are a few examples of the kinds of claims that you can make with a zkSNARK, that would not have been possible before:

- “I’m a trustworthy debtor: I’ve paid off large loans from three trusted banks in a timely fashion, though I won’t reveal the banks or what the loans were taken out for.”
- “I’m a respected community member: Though I am writing this post anonymously, under my named account I have accumulated over 10000 upvotes on this forum.”
- “I’m a long-term cryptotoken collector: Ethereum addresses that I control collectively hold at least two NFTs from the Dark Forest Valhalla collection, and at least 100ETH.”

These claims can be combined, composed, and even programmed in arbitrarily complex ways.

While all of this is theoretically possible, we still have a long ways to go to. Producing a robust suite of ZK identity tools for the next generation of applications requires making substantial improvements in performance, reliability, developer experience, and application design patterns. In the next post, we’ll discuss our understanding of the road ahead.

## Addendum: What’s in an Identity?

To understand where cryptography can be useful for building an identity system, it’s useful to break down the idea of an identity system into its key components.

In analyzing a particular identity system, we might ask some of the following questions:

- What is the atomic unit of identity?
  - Physical world: identity is often associated with legal personhood. In other words, the atomic unit of identity is an individual person, or a corporation.
  - Cyberspace: identity can be a Google/Facebook/Twitter account; the public/private key pair associated with a Certificate Authority; a holder of some Ethereum-based token (which may not be tied to a specific address!); or others.
- What constitutes a valid proof or attestation of identity? Who can issue attestations for identity? Who can revoke the privileges associated with identity attestation?
  - Physical world: a valid attestation might look like a state-issued ID or an EIN letter. Government ultimately has power of the privileges that come with holding a valid identity attestation: for example, the government can revoke your passport.
  - Cyberspace: a valid attestation might be a FB-provided OAuth token, or a valid digital signature (or chain of signatures). Various service providers have power over various attestations: for example, Twitter can ban your account.
- Who custodies auxiliary data associated with your identity? Who can access this data, and who controls this access?
  - Physical world: auxiliary data is held by a combination of government agencies and bureaucracies, private service providers (banks, credit score agencies), and private individuals (your personal network).
  - Cyberspace: in centralized models, auxiliary data is held by big tech companies. In decentralized models, auxiliary data is held by a combination of client software (a browser, a personal webserver) which you control, as well as decentralized storage networks (for example, historical transaction data or smart contract state in a blockchain).
- What records, artifacts, or attestations signal reputation and credibility? Who decides these signals and how they are interpreted? Who has access to the underlying input data that determines reputation? Who can access these signals?
  - Physical world: credit score reports, background checks, social references, letters of employment, credentials and honors and titles.
  - Cyberspace: NFT ownership, account age and previous activity, networks of attestations, karma/forum upvotes.

Some of these concepts blend into each other: identity, reputation, and proof-of-identity are closely related, and not easily divisible. For example, in some systems, the atomic unit of identity is even defined as “that which a central authority can provide a valid attestation for”—there is no notion of a Facebook account that isn’t stored in Facebook’s database.

In general, however, we use *identity* in this series of posts to refer to a persistent tag for an entity (a person, an organization, a bot) that stays constant and representative of the entity over time—legal personhood, a public key, an account ID, etc. We use *reputation* to refer to the claims about past behavior that can be made about the entity (”Alice has always kept her word,” “Bob has always paid his credit card bills on time,” “Comfort Homes has always used accurate pictures for its Airbnb listings”).

## Links and Acknowledgements

*Thanks to Yi Sun and David Schwartz for feedback and review.*

[iden3](https://iden3.io/)

[Semaphore](https://semaphore.appliedzkp.org/)



原文链接：https://0xparc.org/blog/zk-id-1