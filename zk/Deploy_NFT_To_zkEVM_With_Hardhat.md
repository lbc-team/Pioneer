

# Deploy An Animated NFT To zkEVM With Hardhat





## How To Deploy An ERC721 NFT Contract To zkEVM Testnet With Hardhat

![img](https://miro.medium.com/v2/resize:fit:1400/1*V-WEmCNBK3yhAhsoSNg05A.png)

Deploy An Onchain Animated SVG NFT To zkEVM Testnet With Hardhat

# What Is zkEVM

In short [***Polygon zkEVM\***](https://polygon.technology/polygon-zkevm) is an L2 scaling solution that aims for [***EVM-equivalence\***](https://vitalik.ca/general/2022/08/04/zkevm.html) and allows you to deploy contracts to it cheaper, faster, more securely, and without any extra steps using your existing Solidity code.

Want to go further in depth to understand it? Check out my other article on [***How To Deploy An ERC20 Token Contract To zkEVM Testnet\***](http://93f3/).

# Network, Goerli Testnet Tokens, & Bridging

To get configured and bridged quickly, I recommend using the [***Polygon zkEVM Bridge site\*** ](https://public.zkevm-test.net/), to add the network to our wallet and proceed to bridge any Goerli to zkEVM Testnet.

![img](https://miro.medium.com/v2/resize:fit:1400/1*GXeiJE9oQWboK4RKO3j11w.png)

https://public.zkevm-test.net/

# Requirements

Before we begin, make sure you have the following installed on your computer and you have your wallet configured and goerli testnet tokens bridged to zkEVM Testnet. If you want to see how that’s done, check out my other article [***How To Deploy An ERC20 Contract To zkEVM Testnet\***](https://codingwithmanny.medium.com/how-to-deploy-a-contract-to-polygon-zkevm-testnet-385afc1fb1a5#9ff4).

- NVM or Node `v18.15.0`

# Deploying A Contract With Hardhat

Let’s build an ERC721 NFT and deploy it to zkEVM with Hardhat.

Making sure we start off fresh, we’ll utilize Hardhat templating to generate a basic TypeScript project for us.

```
# Create our project folder
mkdir zkevm-erc721-hardhat;
cd zkevm-erc721-hardhat;

npx hardhat;

# Expected Output:
# Ok to proceed? (y) y
# 888    888                      888 888               888
# 888    888                      888 888               888
# 888    888                      888 888               888
# 8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
# 888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
# 888    888 .d888888 888    888  888 888  888 .d888888 888
# 888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
# 888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888
#
# 👷 Welcome to Hardhat v2.13.0 👷‍
#
# ? What do you want to do? …
#   Create a JavaScript project
# ❯ Create a TypeScript project
#   Create an empty hardhat.config.js
#   Quit
#
# ✔ What do you want to do? · Create a TypeScript project
# ✔ Hardhat project root: · /path/to/zkevm-erc721-hardhat
# ✔ Do you want to add a .gitignore? (Y/n) · y
# ✔ Do you want to install this sample project's dependencies with npm (hardhat @nomicfoundation/hardhat-toolbox)? (Y/n) · y
```

Next let’s install the dependencies.

```
npme install;
npm install @openzeppelin/contracts dotenv;
```

## Creating Our NFT

For our NFT we’re going to make it stand out a little by introducing an animated SVG.

First remove the templated contract that was generated and create a new one in its place.

```
rm contracts/Lock.sol;
touch contracts/zkEVMNFT.sol;
```

In the file, copy and paste the following NFT solidity code.

**File:** `./contracts/zkEVMNFT.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Imports
// ========================================================
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// Contract
// ========================================================
contract ZkEVMNFT is ERC721 {
    // Extending functionality
    using Strings for uint256;

    /**
     * Main constructor
     */
    constructor() ERC721("zkEVMNFT", "zkNFT") {}

    /**
     * Main minting function
     */
    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    /**
     * @dev See {ERC721}
     */
    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    /**
     * Public function or burning
     */
    function burn (uint256 tokenId) public {
        _burn(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        // Validation
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        
        // SVG Image
        bytes memory imageSVG = abi.encodePacked(
            "<svg width=\"256\" height=\"256\" viewBox=\"0 0 256 256\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">",
            "<style xmlns=\"http://www.w3.org/2000/svg\">@keyframes rainbow-background { 0% { fill: #ff0000; } 8.333% { fill: #ff8000; } 16.667% { fill: #ffff00; } 25.000% { fill: #80ff00; } 33.333% { fill: #00ff00; } 41.667% { fill: #00ff80; } 50.000% { fill: #00ffff; } 58.333% { fill: #0080ff; } 66.667% { fill: #0000ff; } 75.000% { fill: #8000ff; } 83.333% { fill: #ff00ff; } 91.667% { fill: #ff0080; } 100.00% { fill: #ff0000; }} #background { animation: rainbow-background 5s infinite; } #text { font-family: \"Helvetica\", \"Arial\", sans-serif; font-weight: bold; font-size: 72px; }</style>",
            "<g clip-path=\"url(#clip0_108_2)\">",
            "<rect id=\"background\" width=\"256\" height=\"256\" fill=\"#ff0000\"/>",
            "<rect x=\"28\" y=\"28\" width=\"200\" height=\"200\" fill=\"white\"/>",
            "</g>",
            "<defs>",
            "<clipPath id=\"clip0_108_2\">",
            "<rect width=\"256\" height=\"256\" fill=\"white\"/>",
            "</clipPath>",
            "</defs>",
            "<text xmlns=\"http://www.w3.org/2000/svg\" id=\"text\" x=\"128\" y=\"150\" fill=\"black\" style=\"width: 256px; display: block; text-align: center;\" text-anchor=\"middle\">", tokenId.toString(), "</text>",
            "</svg>"
        );

        // JSON
        bytes memory dataURI = abi.encodePacked(
            "{",
                "\"name\": \"NUMSVG #", tokenId.toString(), "\",",
                "\"image\": \"data:image/svg+xml;base64,", Base64.encode(bytes(imageSVG)), "\"",
            "}"
        );

        // Returned JSON
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}
```

## Configuring Hardhat

Almost there. Next we’ll configure out Hardhat configuration file to enable environment variables to be loaded, configure support for the network, and adjust for optimization.

**File:** `./hardhat.config.ts`

```typescript
// Imports
// ========================================================
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

// Config
// ========================================================
dotenv.config();
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      }
    }
  },
  networks: {
    mumbai: {
      url: `${process.env.RPC_MUMBAI_URL || ''}`,
      accounts: process.env.WALLET_PRIVATE_KEY
        ? [`0x${process.env.WALLET_PRIVATE_KEY}`]
        : [],
    },
    zkevmTestnet: {
      url: `${process.env.RPC_ZKEVM_URL || ''}`,
      accounts: process.env.WALLET_PRIVATE_KEY
        ? [`0x${process.env.WALLET_PRIVATE_KEY}`]
        : [],
    }
  },
};

// Exports
// ========================================================
export default config;
```

## Adding Environment Variables For Hardhat

Once we’ve finished the Hardhat config, we’ll create an environment variable file to store our key values.

```
touch .env;
```

**NOTE:** Remember to keep your private key safe from prying eyes.

**File:** `./env`

```toml
RPC_MUMBAI_URL=https://rpc.ankr.com/polygon_mumbai
RPC_ZKEVM_URL=https://rpc.public.zkevm-test.net
WALLET_PRIVATE_KEY=<YOUR-WALLET-PRIVATE-KEY>
```

Lastly, let’s modify our deploy script to point to the correct contract.

**File:** `./scripts/deploy.ts`

```typescript
// Imports
// ========================================================
import { ethers } from "hardhat";

// Main Deployment Script
// ========================================================
async function main() {
  // Make sure in the contract factory that it mateches the contract name in the solidity file
  // Ex: contract zkEVMNFT
  const zkERC721Contract = await ethers.getContractFactory("zkEVMNFT");
  const contract = await zkERC721Contract.deploy();

  await contract.deployed();

  console.log(`zkEVMNFT deployed to ${contract.address}`);
};

// Init
// ========================================================
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

## Deploying Out NFT Contract

Once everything is set, we can now deploy our NFT contract to zkEVM Testnet.

```bash
# FROM: ./zkevm-erc721-hardhat

npx hardhat run scripts/deploy.ts --network zkevmTestnet;

# Expected Output:
# zkEVMNFT deployed to 0x7F77cF06C84A7bae6D710eBfc78a48214E4937a7
```

If we go to the contract on the explorer, we can see the following result:

![img](https://miro.medium.com/v2/resize:fit:1400/1*JkgHHi-A5UJwxDU3mMrwsg.png)

https://explorer.public.zkevm-test.net/address/0x7F77cF06C84A7bae6D710eBfc78a48214E4937a7

## Verifying Our NFT Contract On zkEVM Block Explorer

We could interact with the contract directly through Hardhat for the minting and reading, but we’ll use the blockchain explorer to connect and mint a new NFT.

Before we jump into the verification process, we’ll be verifying via Standard Input JSON and we’ll need a file to upload.

If we look at our `build-info` folder, we can find a JSON file where we need to get just the input section. Copy that entire section and create a new file called `verify.json` and paste the JSON data in there.

Remember that you will need to compile the contract before hand to generate these files with `npx hardhat compile`.

**File:** `./artifacts/build-info/your-build-file.json`

![img](https://miro.medium.com/v2/resize:fit:1400/1*StDb6G6VDrdPgMFP3s2s8g.png)

Build JSON file

![img](https://miro.medium.com/v2/resize:fit:1400/1*IYLh6ZfJo6Y-jID5FT5BYw.png)

Our new Standard Input JSON file as verify.json

Next visit the contract on the block explorer and start the verification process.

![img](https://miro.medium.com/v2/resize:fit:1400/1*2c2q1CED81cY7FFo_J-GRg.png)

zkEVM Testnet Block Explorer Verify & Publish Contract

![img](https://miro.medium.com/v2/resize:fit:1400/1*0V_Bjw5MUG_6RJ7v-0fuzQ.png)

zkEVM Testnet Block Explorer Verification Via Standard Input JSON

![img](https://miro.medium.com/v2/resize:fit:1400/1*wWhYlOId4B-Z_KJcDvXAww.png)

zkEVM Testnet Block Explorer Verification Conifgure verify.json

Once verified, we can see the full code of our contract on the zkEVM Testnet block explorer.

![img](https://miro.medium.com/v2/resize:fit:1400/1*eWiSfsddCyKusEmae2jSEQ.png)

https://explorer.public.zkevm-test.net/address/0x7F77cF06C84A7bae6D710eBfc78a48214E4937a7/contracts#address-tabs

## Minting An NFT On zkEVM Testnet

Now that our contract is verified, we can interact with it via the block explorer and our wallet.

For the purposes of this tutorial, we’ll mint an NFT tokenID of 4 in honour of the number of days until zkEVM Mainnet Beta launch — March 27, 2023.

![img](https://miro.medium.com/v2/resize:fit:1400/1*6kr5_RW15fGCLWEQkizAvw.png)

https://explorer.public.zkevm-test.net/address/0x7F77cF06C84A7bae6D710eBfc78a48214E4937a7/write-contract#address-tabs

![img](https://miro.medium.com/v2/resize:fit:1400/1*FyXy_HG3HptXya9DgTNc0w.png)

Minting NFT on zkEVM Testnet

![img](https://miro.medium.com/v2/resize:fit:1400/1*kHMffx_89RjIo7tpTYol9A.png)

Confirmation of Successfully Minting An NFT on zkEVM Testnet

## Viewing Our zkEVM NFT

We minted our NFT to zkEVM Testnet, now we want to be able to see this on-chain SVG NFT visually.

![img](https://miro.medium.com/v2/resize:fit:1400/1*aLyyelBrbM3pLVc2BMIuSA.png)

zkEVM Testnet Block Explorer Read NFT

Copy the data portion of the `tokenURI` query and, in Chrome, paste it in the address bar.

![img](https://miro.medium.com/v2/resize:fit:1400/1*tWNRJqIjF4dRQr2qv2DOHw.png)

zkEVM Testnet NFT tokenURI JSON Data

Copy the `image` value from the JSON and, in Chrome, paste it in the address bar.

![img](https://miro.medium.com/v2/resize:fit:1400/1*gpH8IHl8tTLmHToX73mRlA.png)

zkEVM Testnet NFT SVG

🎉 There we go! We successfully deployed the contract, verified the contract, and we were able to see our minted NFT.

# Full zkEVM NFT Code Repository

Check out the full repository for this tutorial here.

https://github.com/codingwithmanny/zkevm-erc721-hardhat

# What’s Next?

Look out for more tutorials on zkEVM coming.

If you haven’t already read [***How To Deploy A Contract To Polygon zkEVM Testnet\***](https://codingwithmanny.medium.com/how-to-deploy-a-contract-to-polygon-zkevm-testnet-385afc1fb1a5), please give it a read and if you want to get more in depth with zkEVM, check out [***Polygon University\***](https://university.polygon.technology/).

If you got value from this, please give it some love, and please also follow me on twitter (where I’m quite active) [@codingwithmanny](http://twitter.com/codingwithmanny) and instagram at [@codingwithmanny](https://instagram.com/codingwithmanny).