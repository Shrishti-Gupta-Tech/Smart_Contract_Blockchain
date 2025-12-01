# 🚀 Deployment Guide

> **Complete guide for deploying smart contracts using Remix, Hardhat, or Foundry**

---

## 📋 Table of Contents

1. [Deployment Options](#deployment-options)
2. [Method 1: Remix IDE (Easiest)](#method-1-remix-ide-easiest)
3. [Method 2: Hardhat (Most Popular)](#method-2-hardhat-most-popular)
4. [Method 3: Foundry (Fastest)](#method-3-foundry-fastest)
5. [Network Configuration](#network-configuration)
6. [Post-Deployment](#post-deployment)

---

## 🎯 Deployment Options

### Which Method Should You Use?

| Method        | Difficulty      | Best For                   | Setup Time |
| ------------- | --------------- | -------------------------- | ---------- |
| **Remix IDE** | ⭐ Easiest      | Beginners, quick testing   | 5 min      |
| **Hardhat**   | ⭐⭐ Medium     | Professional development   | 15 min     |
| **Foundry**   | ⭐⭐⭐ Advanced | Fast testing, optimization | 10 min     |

**Recommendation:** Start with Remix, then try Hardhat/Foundry as you advance.

---

## 📱 Method 1: Remix IDE (Easiest)

### Prerequisites

- Web browser
- MetaMask (for testnet deployment)

### Step-by-Step Instructions

#### 1. Open Remix

Visit: https://remix.ethereum.org

#### 2. Upload Contracts

- Click **File Explorer** (📁 icon)
- Click **Upload** button
- Select all 3 `.sol` files:
  - Vulnerable.sol
  - Fix1_CheckedCall.sol
  - Fix2_SafeWrapper.sol

#### 3. Compile Contracts

- Click **Solidity Compiler** tab (left sidebar)
- Select compiler version: **0.8.0+**
- Click **"Compile"** for each contract
- ✅ Look for green checkmarks

#### 4. Deploy

**For Free Testing (Remix VM):**

1. Go to **"Deploy & Run"** tab
2. Select Environment: **"Remix VM (Shanghai)"**
3. Deploy each contract:
   - Select contract from dropdown
   - Click **Deploy**
   - Copy contract address
4. ✅ You get unlimited free test ETH!

**For Real Testnet (Sepolia):**

1. Install and setup MetaMask
2. Switch to Sepolia network
3. Get test ETH from faucet: https://sepoliafaucet.com
4. In Remix, select: **"Injected Provider - MetaMask"**
5. Connect MetaMask when prompted
6. Deploy each contract:
   - Select contract from dropdown
   - Click **Deploy**
   - Confirm in MetaMask
   - Wait for confirmation
   - Copy contract address

#### 5. Save Addresses

Copy all 4 contract addresses and save them:

```
Deployment on [Network] - [Date]

Vulnerable:                0x...
Fix1_CheckedCall:          0x...
Fix2_SafeWrapper:          0x...
```

#### 6. Test!

Follow the testing guide in README.md

---

## 💻 Method 2: Hardhat (Most Popular)

### Prerequisites

- Node.js installed (v16+)
- npm or yarn
- Code editor (VS Code recommended)
- MetaMask (for testnet)

### Setup Instructions

#### 1. Initialize Hardhat Project

```bash
# Create project directory
mkdir blockchain-vulnerability-demo-hardhat
cd blockchain-vulnerability-demo-hardhat

# Initialize npm project
npm init -y

# Install Hardhat
npm install --save-dev hardhat

# Initialize Hardhat
npx hardhat init
# Select: "Create a JavaScript project"
```

#### 2. Install Dependencies

```bash
# Install required packages
npm install --save-dev @nomicfoundation/hardhat-toolbox
npm install --save-dev @nomicfoundation/hardhat-ethers ethers
npm install --save-dev @nomicfoundation/hardhat-verify
npm install --save-dev dotenv
```

#### 3. Configure Hardhat

Create `hardhat.config.js`:

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    // Local network
    localhost: {
      url: "http://127.0.0.1:8545",
    },

    // Sepolia testnet
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
    },

    // For testing only - Hardhat network
    hardhat: {
      chainId: 31337,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY || "",
    },
  },
};
```

#### 4. Set Environment Variables

Create `.env` file:

```env
# RPC URLs
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR-INFURA-KEY
# Or use Alchemy: https://eth-sepolia.g.alchemy.com/v2/YOUR-ALCHEMY-KEY

# Private Key (NEVER share this!)
PRIVATE_KEY=your-private-key-here

# Etherscan API Key (for verification)
ETHERSCAN_API_KEY=your-etherscan-api-key
```

⚠️ **IMPORTANT:** Never commit `.env` file! It's already in `.gitignore`

#### 5. Copy Contracts

Copy all `.sol` files to `contracts/` directory:

```bash
cp Vulnerable.sol contracts/
cp Fix1_CheckedCall.sol contracts/
cp Fix2_SafeWrapper.sol contracts/
```

#### 6. Copy Deployment Script

Copy `scripts/deploy.js` to your Hardhat project

#### 7. Deploy

**To local network:**

```bash
# Start local node (in separate terminal)
npx hardhat node

# Deploy
npx hardhat run scripts/deploy.js --network localhost
```

**To Sepolia testnet:**

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

#### 8. Verify on Etherscan (Optional)

```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```

---

## ⚡ Method 3: Foundry (Fastest)

### Prerequisites

- Foundry installed
- Code editor
- MetaMask (for testnet)

### Setup Instructions

#### 1. Install Foundry

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

#### 2. Initialize Project

```bash
# Create project
forge init blockchain-vulnerability-demo-foundry
cd blockchain-vulnerability-demo-foundry

# Remove example files
rm -rf src/Counter.sol test/Counter.t.sol script/Counter.s.sol
```

#### 3. Copy Contracts

```bash
# Copy contract files to src/
cp Vulnerable.sol src/
cp Fix1_CheckedCall.sol src/
cp Fix2_SafeWrapper.sol src/

# Copy deployment script
cp scripts/Deploy.s.sol script/
```

#### 4. Set Environment Variables

Create `.env` file:

```env
PRIVATE_KEY=your-private-key-here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR-KEY
ETHERSCAN_API_KEY=your-etherscan-api-key
```

#### 5. Load Environment

```bash
source .env
```

#### 6. Deploy

**Dry run (simulation):**

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $SEPOLIA_RPC_URL
```

**Deploy to Sepolia:**

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

**Deploy to local Anvil:**

```bash
# Start Anvil (in separate terminal)
anvil

# Deploy
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

---

## 🌐 Network Configuration

### Sepolia Testnet (Recommended)

**Network Details:**

```
Name: Sepolia
Chain ID: 11155111
RPC URL: https://sepolia.infura.io/v3/YOUR-KEY
Explorer: https://sepolia.etherscan.io
```

**Get Test ETH:**

- https://sepoliafaucet.com
- https://faucet.sepolia.dev
- https://www.infura.io/faucet/sepolia

**Infura/Alchemy Setup:**

1. Create account at Infura.io or Alchemy.com
2. Create new project
3. Copy API key
4. Use in RPC URL

### Local Networks

**Hardhat Network:**

```bash
npx hardhat node
# RPC: http://127.0.0.1:8545
# Chain ID: 31337
```

**Anvil (Foundry):**

```bash
anvil
# RPC: http://127.0.0.1:8545
# Chain ID: 31337
```

**Benefits of Local Networks:**

- ✅ Instant transactions
- ✅ Unlimited ETH
- ✅ Fast testing
- ✅ No internet needed
- ✅ Complete control

---

## 📝 Post-Deployment

### 1. Save Contract Addresses

Create `deployed-addresses.json`:

```json
{
  "network": "sepolia",
  "chainId": 11155111,
  "timestamp": "2024-01-15T10:30:00Z",
  "contracts": {
    "Vulnerable": "0x...",
    "Fix1_CheckedCall": "0x...",
    "Fix2_SafeWrapper": "0x..."
  }
}
```

### 2. Verify Contracts on Etherscan

**Why Verify?**

- ✅ Users can read your source code
- ✅ Increases transparency and trust
- ✅ Easier to interact with
- ✅ Shows you're legitimate

**Hardhat Verification:**

```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```

**Foundry Verification:**

```bash
forge verify-contract CONTRACT_ADDRESS \
  ContractName \
  --chain-id 11155111 \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### 3. Test Deployed Contracts

Follow the testing guide in README.md:

```bash
# Quick test in Remix
1. Load contract at address
2. Deposit 0.1 ETH
3. Try payment to MaliciousReceiver
4. Observe the vulnerability!
```

### 4. Document Your Deployment

Create a deployment record:

```markdown
# Deployment Record

**Date:** 2024-01-15
**Network:** Sepolia Testnet
**Deployer:** 0x...
**Gas Used:** ~2,000,000

## Addresses

- Vulnerable: 0x...
- Fix1_CheckedCall: 0x...
- Fix2_SafeWrapper: 0x...

## Verification

- [x] All contracts verified on Etherscan
- [x] Tested basic functionality
- [x] Vulnerability demonstrated
- [x] Fixes validated

## Notes

- Used for educational workshop on [date]
- Shared with [team/class]
```

---

## 🔐 Security Checklist

### Before Deployment

- [ ] Using testnet (NOT mainnet)
- [ ] Have sufficient test ETH
- [ ] Private key is secure
- [ ] .env file not committed to git
- [ ] Contracts compiled successfully
- [ ] Understand the risks

### After Deployment

- [ ] Save all contract addresses
- [ ] Verify contracts on Etherscan
- [ ] Test basic functionality
- [ ] Document deployment
- [ ] Share with team (if applicable)

---

## 🐛 Troubleshooting

### "Insufficient funds for gas"

**Solution:** Get more test ETH from faucet

### "Nonce too high"

**Solution:** Reset MetaMask account or wait for pending transactions

### "Contract creation failed"

**Solution:**

- Check gas limit
- Verify RPC URL is correct
- Ensure private key has funds

### "Network not supported"

**Solution:**

- Add network to MetaMask manually
- Check chainId is correct
- Verify RPC URL

### "Cannot connect to network"

**Solution:**

- Check internet connection
- Verify RPC URL is accessible
- Try different RPC provider

---

## 💡 Best Practices

### 1. Always Use Testnets First

```bash
# ✅ GOOD - Testing on Sepolia
npx hardhat run scripts/deploy.js --network sepolia

# ❌ NEVER - Don't deploy vulnerable contracts to mainnet!
```

### 2. Keep Private Keys Secure

```bash
# ✅ GOOD - Using environment variables
PRIVATE_KEY=0x... npx hardhat run scripts/deploy.js --network sepolia

# ❌ BAD - Never hardcode private keys
const privateKey = "0x123..."; // NEVER DO THIS!
```

### 3. Verify Contracts

```bash
# Makes your contract readable and trustworthy
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```

### 4. Document Everything

- Save deployment addresses
- Record deployment date
- Note which network used
- Keep transaction hashes

### 5. Test Before Sharing

- Verify all functions work
- Test the vulnerability
- Confirm fixes work properly
- Check gas costs

---

## 📊 Deployment Cost Estimates

### Gas Costs (Sepolia Testnet)

```
Contract Deployments:
├── Vulnerable:                  ~500,000 gas (~0.005 ETH)
├── Fix1_CheckedCall:            ~520,000 gas (~0.0052 ETH)
└── Fix2_SafeWrapper:            ~515,000 gas (~0.0051 ETH)

Total Estimated: ~1,685,000 gas (~0.017 ETH)

Note: Costs vary based on network congestion
```

### Recommended Test ETH

- **Minimum:** 0.05 ETH (for deployment + testing)
- **Comfortable:** 0.1 ETH (includes buffer for mistakes)
- **Recommended:** 0.2 ETH (plenty for experimentation)

---

## 🌍 Network Resources

### Sepolia Testnet

**Faucets:**

- https://sepoliafaucet.com
- https://faucet.sepolia.dev
- https://www.infura.io/faucet/sepolia

**RPC Providers:**

- **Infura:** https://infura.io
- **Alchemy:** https://alchemy.com
- **Public RPC:** https://rpc.sepolia.org

**Block Explorer:**

- https://sepolia.etherscan.io

### Local Development

**Hardhat Network:**

```bash
# Terminal 1: Start node
npx hardhat node

# Terminal 2: Deploy
npx hardhat run scripts/deploy.js --network localhost
```

**Anvil (Foundry):**

```bash
# Terminal 1: Start Anvil
anvil

# Terminal 2: Deploy
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url http://localhost:8545 \
  --broadcast
```

---

## 📱 Quick Reference Commands

### Remix IDE

```
1. Open: https://remix.ethereum.org
2. Upload contracts
3. Compile (Ctrl+S)
4. Deploy & Run Transactions tab
5. Select Remix VM or MetaMask
6. Deploy each contract
```

### Hardhat

```bash
# Compile
npx hardhat compile

# Deploy to local
npx hardhat run scripts/deploy.js --network localhost

# Deploy to Sepolia
npx hardhat run scripts/deploy.js --network sepolia

# Verify
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```

### Foundry

```bash
# Compile
forge build

# Test
forge test

# Deploy (local)
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy (Sepolia)
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

---

## ⚠️ Important Warnings

### DO:

- ✅ Deploy to testnets only
- ✅ Keep private keys secure
- ✅ Use environment variables
- ✅ Test thoroughly
- ✅ Verify on Etherscan
- ✅ Document everything

### DON'T:

- ❌ Deploy vulnerable contracts to mainnet
- ❌ Share private keys
- ❌ Commit .env files
- ❌ Use real funds for testing
- ❌ Skip testing
- ❌ Forget to save addresses

---

## 🎓 Learning Resources

### Video Tutorials

- Search YouTube: "How to deploy Solidity with Hardhat"
- Search YouTube: "Foundry deployment tutorial"
- Search YouTube: "Remix IDE smart contract deployment"

### Documentation

- **Hardhat:** https://hardhat.org/getting-started
- **Foundry:** https://book.getfoundry.sh
- **Remix:** https://remix-ide.readthedocs.io

### Community Help

- **Ethereum Stack Exchange:** https://ethereum.stackexchange.com
- **Hardhat Discord:** https://hardhat.org/discord
- **Foundry Telegram:** https://t.me/foundry_rs

---

## ✅ Deployment Checklist

### Pre-Deployment

- [ ] Contracts compile without errors
- [ ] Test ETH acquired (for testnet)
- [ ] RPC URL configured
- [ ] Private key secured in .env
- [ ] Network settings correct

### Deployment

- [ ] All contracts deployed
- [ ] Transaction confirmations received
- [ ] All addresses copied and saved
- [ ] Gas costs documented

### Post-Deployment

- [ ] Contracts verified on Etherscan
- [ ] Basic functionality tested
- [ ] Vulnerability demonstrated
- [ ] Fixes validated
- [ ] Addresses shared with team

---
