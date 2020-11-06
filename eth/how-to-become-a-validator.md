> * https://bankless.substack.com/p/-guide-how-to-become-a-validator  [Ryan Sean Adams](https://bankless.substack.com/people/221467-ryan-sean-adams)



# Guide: How to become a validator on Eth2



> Learning how to setup a validator node on Eth2

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_dcb6aa86-a247-44f5-85ae-46b2f0467551_1556x566](https://img.learnblockchain.cn/pics/20201106171216.png)

*Last updated: November 4th, 2020*

Dear Bankless Nation,

[Eth2 is here](https://blog.ethereum.org/2020/11/04/eth2-quick-update-no-19/).

That means [ETH staking is here](https://twitter.com/RyanSAdams/status/1324016362939973632?s=20). This is the [birth of the ether as a digital bond](https://bankless.substack.com/p/ether-the-birth-of-the-digital-bond).

The staking contract is open and Eth2 is set to go live on December 1st, 2020. This is years of work finally coming into fruition. And it’s safe to say we’re excited.

That’s why we’re launching this ETH staking guide for those looking to run a validator node on Mainnet. We did one to help people get setup on the Medalla testnet back in August—you can still access [the testnet guide](https://bankless.substack.com/p/guide-becoming-a-validator-on-the) to practice by the way.

But now it’s game time. This is the real deal.

Please join me in thanking[ Collin Myers](https://twitter.com/StakeETH) &[ Mara Schmiedt](https://twitter.com/MaraSchmiedt) from[ ConsenSys](https://consensys.net/) [CodeFi](https://codefi.consensys.net/) & [Bison Trails](https://bisontrails.co/) for putting this together—we hope it serves as an invaluable resource for the Ethereum community on getting started with Eth2. 👏

This is the frontier.

\- RSA

*P.S. Calling all builders! Let’s use Filecoin to build a decentralized future and earn some cash. Get a $20K grant + over $1M in funding. David’s mentoring! [Apply now!](https://bankless.cc/filecoinapply)*

**🙏Sponsor:** [Aave](https://bankless.cc/aave)—earn [high yields](https://bankless.cc/aave) on deposits & borrow at the best possible rate! 

**We dropped a special episode of ALPHA LEAK on ETH2 and ETH staking!**

<iframe width="728" height="410" src="https://www.youtube.com/embed/SkUiw1y3BHU" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>




*Learn everything you need to know on [Eth2 staking](https://www.youtube.com/watch?v=SkUiw1y3BHU) with [Preston Van Loon](https://twitter.com/preston_vanloon)!*

## **Here’s what this guide covers:**

1. Recommended hardware
2. Choosing & Installing Your Client
3. Setting up an Eth1 Node
4. Using the Eth2 Launch Pad
5. Bonus content and resources

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_dbf46668-3377-43e5-a2a1-8f3dffdad63e_1376x820](https://img.learnblockchain.cn/pics/20201106171419.jpeg)

*Bring a friend on the journey! Share this guide with someone. Let’s help the world go bankless!*

[Share](https://bankless.substack.com/p/-guide-how-to-become-a-validator?&utm_source=substack&utm_medium=email&utm_content=share&action=share)

## **1. Hardware Requirements**

Based on the decentralized design goals of Eth2, it is expected that validators will utilize a variety of different infrastructure setups (*on-premise, cloud, etc*).

👉 *If you haven’t previously staked your ETH, using the Medalla Testnet is a great way to get involved and gives you sufficient time to determine what type of setup gives you the best, most reliable performance.*

*Make sure to run some tests before you get started! To test your setup on the Medella testnet first please see [here.](http://medalla.launchpad.ethereum.org/)*

Below you will find some hardware recommendations, resource links, and some useful guides to get you prepared.

#### **Recommended Specs:**

- **Operating System:** 64-bit Linux, Mac OS X, Windows
- **Processor:** Intel Core i7-4770 or AMD FX-8310 (or better)
- **Memory:** 8GB RAM
- **Storage:** 100GB available space SSD
- **Internet:** Broadband internet connection (10 Mbps)
- **Power:** Uninterruptible power supply (UPS)

**Digital Ocean Equivalent (***cloud provider***):**

- [Standard Droplet](https://www.digitalocean.com/pricing/)
  - **Memory:** 8GB RAM
  - **Storage:** 160GB available space SSD
  - **Uptime:** 99.99%
  - **Availability:** 8 Data Centers
  - **$/HR:** $0.060
  - **$/MO:** $40

**Hardware Equivalent:**

- [ZOTAC ZBOX CI662 Nano Silent Passive-Cooled Mini PC 10th Gen Intel Core i7](https://www.amazon.com/ZOTAC-Passive-Cooled-Quad-core-Barebones-ZBOX-CI662NANO-U/dp/B08CVW7ZTC/ref=sr_1_14?crid=3H3C58N0E4ADZ&dchild=1&keywords=mini+pc+barebones+i7&qid=1598263033&sprefix=mini+PC+barebones+%2Caps%2C767&sr=8-14)
- [SanDisk Ultra 3D NAND 2TB Internal SSD](https://www.amazon.com/SanDisk-Ultra-NAND-Internal-SDSSDH3-2T00-G25/dp/B071KGS72Q/ref=sr_1_2?crid=1KNWA41H1VO9Q&dchild=1&keywords=sandisk+ssd+plus+2tb+internal+ssd+-+sata+iii+6&qid=1598262732&sprefix=sandisk+SSD+plus+2TB%2Caps%2C790&sr=8-2)
- [Corsair Vengeance Performance SODIMM Memory 16GB (2x8GB)](https://www.amazon.com/Corsair-Vengeance-Performance-Unbuffered-Generation/dp/B08BLVHWXD/ref=sr_1_2?dchild=1&keywords=CORSAIR+VENGEANCE+SODIMM+16GB+(2x8GB)&qid=1598262850&sr=8-2)

#### **Minimum Requirements:**

- **Operating System:** 64-bit Linux, Mac OS X, Windows
- **Processor:** Intel Core i5-760 or AMD FX-8110 (or better)
- **Memory:** 4GB RAM
- **Storage:** 20GB available space SSD
- **Internet:** Broadband internet connection (10 Mbps)
- **Power:** Uninterruptible power supply (UPS)

**Digital Ocean Equivalent:**

- [Standard Droplet](https://www.digitalocean.com/pricing/)
  - **Memory:** 4GB RAM
  - **Storage:** 80GB available space SSD
  - **Uptime:** 99.99%
  - **Availability:** 8 Data Centers
  - **$/HR:** $0.030
  - **$/MO:** $20

**Hardware Equivalent:**

- [ZOTAC ZBOX CI642 Nano Silent Passive-Cooled Mini PC 10th Gen Intel Core i5](https://www.amazon.com/ZOTAC-Passive-Cooled-Quad-core-Barebones-ZBOX-CI642NANO-U/dp/B08BBN3LS5/ref=sr_1_41?dchild=1&keywords=mini+pc+barebones+i5&qid=1598263166&sr=8-41)
- [SanDisk Ultra 3D NAND 2TB Internal SSD](https://www.amazon.com/SanDisk-Ultra-NAND-Internal-SDSSDH3-2T00-G25/dp/B071KGS72Q/ref=sr_1_2?crid=1KNWA41H1VO9Q&dchild=1&keywords=sandisk+ssd+plus+2tb+internal+ssd+-+sata+iii+6&qid=1598262732&sprefix=sandisk+SSD+plus+2TB%2Caps%2C790&sr=8-2)
- [Corsair Vengeance Performance SODIMM Memory 8GB](https://www.amazon.com/Corsair-Vengeance-Performance-CMSX8GX4M1A2400C16-2400MHz/dp/B077SB72QN/ref=sr_1_1?dchild=1&keywords=CORSAIR+VENGEANCE+SODIMM+8GB&qid=1598263273&sr=8-1)

## **2. Choosing & Installing Your Client**

The launch of Eth2 features multiple clients, providing validators with the option of using different implementations for running their validator.

As of now, there are 4 client teams with production ready implementations that you can try out:

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_b5962645-e344-4a2e-8eac-e8c643b792f5_1600x823](https://img.learnblockchain.cn/pics/20201106171517.png)

#### **Client Teams**

- **Prysm by Prysmatic Labs** ([Discord](https://discord.gg/KSA7rPr))

  [Prysm](https://github.com/prysmaticlabs/prysm) is a Go implementation of the Ethereum 2.0 protocol with a focus on usability, security, and reliability. Prysm is written in Go and released under a GPL-3.0 license.

  - *Instructions*:[ https://docs.prylabs.network/docs/getting-started/](https://docs.prylabs.network/docs/getting-started/)
  - *Github*:[ https://github.com/prysmaticlabs/prysm/](https://github.com/prysmaticlabs/prysm/)

- **Lighthouse by Sigma Prime** ([Discord](https://discord.gg/cyAszAh))

  [Lighthouse](https://github.com/sigp/lighthouse) is a Rust implementation of the Eth2.0 client with a heavy focus on speed and security. The team behind it, [Sigma Prime](https://sigmaprime.io/), is an information security and software engineering firm. Lighthouse is offered under an Apache 2.0 License.

  - *Instructions*:[ https://lighthouse-book.sigmaprime.io/](https://lighthouse-book.sigmaprime.io/)
  - *Github*:[ https://github.com/sigp/lighthouse](https://github.com/sigp/lighthouse)

- **Teku by ConsenSys** ([Discord](https://discord.gg/7hPv2T6))

  [PegaSys Teku](https://pegasys.tech/teku/) is a Java-based Ethereum 2.0 client designed & built to meet institutional needs and security requirements. Teku is Apache 2 licensed and written in Java, a language notable for its maturity & ubiquity.

  - *Instructions:*https://docs.teku.pegasys.tech/en/latest/HowTo/Get-Started/Build-From-Source/
  - *Github:*https://github.com/PegaSysEng/teku

- **Nimbus by Status** ([Discord](https://discord.gg/XRxWahP))

  [Nimbus](https://our.status.im/tag/nimbus/) is a research project and a client implementation for Ethereum 2.0 designed to perform well on embedded systems and personal mobile devices, including older smartphones with resource-restricted hardware. Nimbus (Apache 2) is written in Nim, a language with Python-like syntax that compiles to C.

  - Instructions:[ https://nimbus.team/docs/](https://nimbus.team/docs/)
  - Github:[ https://github.com/status-im/nim-beacon-chain](https://github.com/status-im/nim-beacon-chain)

## **3. Install an ETH1 Node**

Running a validator on Eth2 requires you to run an Eth1 node in order to monitor for 32 ETH validator deposits. There are a variety of options when choosing an Eth1 node, below you will find the tools most commonly used to spin up an Eth1 node.

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_decb1e2e-3b44-4219-b085-e5ab12cc369f_1600x805](https://img.learnblockchain.cn/pics/20201106171546.png)





**Self Hosted:**

- [OpenEthereum](https://www.parity.io/ethereum/)
- [Geth](https://geth.ethereum.org/)
- [Besu](https://besu.hyperledger.org/en/stable/)
- [Nethermind](https://www.nethermind.io/)

**Third Party Hosted:**

- [Infura](https://infura.io/)

## **4. Running an Eth2 Validator**

#### **Step 1: Get ETH**

If you are new to Ethereum, then a major step is getting your fuel to participate. Eth2 requires 32 ETH per validator. This is the real thing! Recognize that if you end up becoming a validator, you’re making a long term commitment (*we’re talking years)* towards this initiative.

If you need to top up on some ETH, here’s the exchanges we recommend.

- **Fiat On-Ramp Exchange (U.S.)**: [Coinbase](https://bankless.cc/coinbase) or[ Gemini](https://gemini.com/)
- **Fiat On-Ramp Exchange (non-U.S.)** [Binance](http://bankless.cc/binance) or [Kraken](http://bankless.cc/kraken)
- **Ethereum DEX:** [Uniswap](https://app.uniswap.org/#/)

#### **Step 2: Head over to the[ Eth2 Launchpad](https://launchpad.ethereum.org/)**

Over the past few months, the[ Ethereum Foundation (EF)](https://ethereum.org/en/foundation/), Codefi Activate, and Deep Work Studio have been working on an interface to make it easier for users to stake and become a validator on Ethereum 2.0. 

The result of this effort is the[ Eth2 Launch Pad](https://launchpad.ethereum.org/), an application designed to securely guide you through the process of generating your Eth2 key pairs and staking your 32 ETH into the official deposit contract on Eth2 mainnet.

The Launch Pad was designed for at-home validators. These are hobbyists who intend to run their own validator and are comfortable running commands in a terminal screen on their computer.![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_60afd7a9-d289-45a9-8e73-44660e04a208_1600x675](https://img.learnblockchain.cn/pics/20201106171655.png)



#### **Step 2a: Due Diligence (*****Overview section*****)**

It is important to take your time and read through the content during this part of the journey. The overview section is designed to be educational and informative about the risks involved when staking your ETH.

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_a7eb4c11-1f4f-45e0-8775-40a471c2c597_1600x820 (1)](https://img.learnblockchain.cn/pics/20201106171751.png)



#### **Step 3: Generate your key pairs and mnemonic phrase**

For each validator node, you are required to generate your validator key pair and a mnemonic phrase to generate your withdrawal key later on. 

As a first step, you are required to select the number of validators you would like to run and on which operating system you would like to run them on. 



![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_34ccbe89-3ac6-4300-984e-387deb2a3239_1600x361](https://img.learnblockchain.cn/pics/20201106171840.png)

The Launchpad will provide you with the two options to generate your deposit keys.

You can find detailed instructions for your operating system[ here](https://github.com/ethereum/eth2.0-deposit-cli/blob/master/README.md): 

https://github.com/ethereum/eth2.0-deposit-cli/blob/master/README.md

The first is to use the binary executable file that you can download from the [Eth2 Github repo](https://github.com/ethereum/eth2.0-deposit-cli/releases/) and then run the ./deposit command in your terminal window.

**Please remember to verify the URL and that you are using is the correct one!**



![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_d2ec73a7-41a0-43d9-9fff-c937c0ce4651_1388x1256](https://img.learnblockchain.cn/pics/20201106171914.png)



The other option is to build the deposit-CLI tool from the Python source code. You will need to follow the instructions to ensure you have all the required development libraries and the deposit-CLI tool installed.

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_0a9f29f2-fee2-4895-9f79-9e8bb11973f0_1060x1372](https://img.learnblockchain.cn/pics/20201106171947.png)

Once you have installed the deposit-CLI tool and run it in your terminal window, you will be prompted to:

1. Specify the number of validators you would like to run
2. The language in which you would like to generate your mnemonic phrase
3. Specify the network (mainnet) on which you would like to run your validator.

**Please make sure you have set --chain mainnet for Mainnet testnet, otherwise the deposit will be invalid.**

Now you will be asked to set your password and once confirmed your mnemonic phrase will be generated. **Make sure you have it written down in a safe place and stored offline!**

If you have successfully completed this step you should see the screen below. ![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_64115b52-1824-4948-9e3f-3701f96a4f23_1122x1032](https://img.learnblockchain.cn/pics/20201106172026.png)



If you have questions about the deposit-cli, please visit the [GitHub repository](https://github.com/ethereum/eth2.0-deposit-cli): 

https://github.com/ethereum/eth2.0-deposit-cli

#### **Step 4: Upload your deposit file**

You are almost there! As a next step upload the deposit .json file you generated in the previous step.

It is located in the /eth2.0-deposit-cli/validator_keys directory and is titled deposit-data-[timestamp].json.

![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_8515f431-b57e-4e10-9ca2-c940ca424ccb_1600x617](https://img.learnblockchain.cn/pics/20201106172127.png)

#### **Step 5: Connect your wallet**

Next connect your Web3 wallet and click continue. **Make sure you select Mainnet in your wallet settings.**



![https___bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com_public_images_55cda529-4a10-4c3d-a4c1-c572d7401473_1456x758](https://img.learnblockchain.cn/pics/20201106172136.png)

#### **Step 6: Confirm transaction summary & initiate deposit**

Once you have connected and confirmed your wallet address you will be taken to a summary page that displays the total amount of ETH required to send to the deposit contract based on the number of validators you have selected to run.

Consent to the alert checks and click confirm to navigate to the final step — the actual deposit. 

Click ‘*Initiate the Transaction*’ to deposit your ETH into the official Eth2 Deposit Contract.

You will be required to confirm the 32 ETH deposit per validator through your wallet.

Once your transaction is confirmed ….Boom! You’ve made it and can call yourself an official staker for a monumental moment in Web3.

Congratulations!! 🥳

## **6. Bonus Content & Resources**

After reviewing the above steps we recommend that to be validators look through the client specific guides below before getting the process kicked off. The above steps will follow different orders of operations based on which client you decide to work with.

The below guides are the most in depth we have seen in the industry so far and will take Bankless readers through the nuances of the process. 

#### **Bonus Resources for Eth2 Validators**

*These are highly recommended once you make your decision about which client you would like to use***:**

**Eth2 Block Explorers:**

- [Eth2Stats](https://eth2stats.io/medalla-testnet)
- [Beaconcha.in](https://beaconcha.in/)
- [BeaconScan](https://beaconscan.com/)

**Infrastructure/Hardware**

- [Hudson Jameson (Running Eth2 on DappNode)](https://hudsonjameson.com/2020-05-18-eth-2-0-staking-and-more-with-topaz-and-dappnode-for-under-750/)
- [Quantstamp Article](https://quantstamp.com/blog/how-to-be-an-eth-2-0-validator-on-the-topaz-testnet)

**CoinCashew Series:**

- [How to stake on ETH2 Medalla Testnet with Prysm on Ubuntu](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2)
- [How to stake on ETH2 Medalla Testnet with Lighthouse on Ubuntu](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2-with-lighthouse)
- [How to stake on ETH2 Medalla Testnet with Teku on Ubuntu](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2-with-teku-on-ubuntu)
- [How to stake on ETH2 Medalla Testnet with Nimbus on Ubuntu](https://www.coincashew.com/coins/overview-eth/guide-how-to-stake-on-eth2-with-nimbus)

**Somer Esat Guides:**

- [Guide to Staking on Ethereum 2.0 (Ubuntu/Medalla/Lighthouse)](https://medium.com/@SomerEsat/guide-to-staking-on-ethereum-2-0-ubuntu-medalla-lighthouse-c6f3c34597a8)
- [Guide to Staking on Ethereum 2.0 (Ubuntu/Medalla/Prysm)](https://medium.com/@SomerEsat/guide-to-staking-on-ethereum-2-0-ubuntu-medalla-prysm-4d2a86cc637b)

**Stay on Top of Eth2 Developments:**

- [What's New in Eth2 (Ben Edgington)](https://hackmd.io/@benjaminion/eth2_news/https%3A%2F%2Fhackmd.io%2F%40benjaminion%2Fwnie2_200817)
- [Ethereum Blog (Danny Ryan's Quick Updates)](https://blog.ethereum.org/)
- [Ben Edgington (Annotated Eth2 Spec)](https://benjaminion.xyz/eth2-annotated-spec/phase0/beacon-chain/#introduction)
- [Jim Mcdonald (Attestant Posts)](https://www.attestant.io/posts/)

**It’s all about the Keys Keys Keys:**

- [Ledger Nano X (BLS Firmware Update)](https://www.ledger.com/first-ever-firmware-update-coming-to-the-ledger-nano-x)
- [Attestant: Protecting Validator Keys](https://www.attestant.io/posts/protecting-validator-keys/)

Earn some[ POAPs](https://beaconcha.in/poap) to compliment your[ Bankless POAP](https://bankless.substack.com/p/-guide-2-using-the-bankless-badge). Run different clients and collect the set.