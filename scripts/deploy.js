// ═══════════════════════════════════════════════════════════════════════════════
// Hardhat Deployment Script - Educational Smart Contracts
// ═══════════════════════════════════════════════════════════════════════════════
//
// This script deploys all contracts from the vulnerability demo project
// 
// USAGE:
//   npx hardhat run scripts/deploy.js --network <network-name>
//
// EXAMPLES:
//   npx hardhat run scripts/deploy.js --network localhost
//   npx hardhat run scripts/deploy.js --network sepolia
//
// ⚠️  WARNING: Only deploy to testnets! Never deploy vulnerable contracts to mainnet!
//
// ═══════════════════════════════════════════════════════════════════════════════

const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

// Colors for console output
const colors = {
  reset: "\x1b[0m",
  bright: "\x1b[1m",
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m"
};

/**
 * Format address for display
 */
function formatAddress(address) {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

/**
 * Wait for transaction confirmation
 */
async function waitForConfirmation(tx, confirmations = 2) {
  console.log(`   ⏳ Waiting for ${confirmations} confirmations...`);
  await tx.wait(confirmations);
  console.log(`   ✅ Confirmed!\n`);
}

/**
 * Save deployment addresses to file
 */
function saveDeploymentAddresses(network, addresses) {
  const deploymentsDir = path.join(__dirname, "..", "deployments");
  
  // Create deployments directory if it doesn't exist
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }
  
  const filename = path.join(deploymentsDir, `${network}.json`);
  const data = {
    network: network,
    timestamp: new Date().toISOString(),
    contracts: addresses
  };
  
  fs.writeFileSync(filename, JSON.stringify(data, null, 2));
  console.log(`${colors.green}📝 Deployment addresses saved to: ${filename}${colors.reset}\n`);
}

/**
 * Main deployment function
 */
async function main() {
  console.log("\n" + "═".repeat(80));
  console.log(`${colors.cyan}${colors.bright}  Blockchain Vulnerability Demo - Deployment Script${colors.reset}`);
  console.log("═".repeat(80) + "\n");
  
  // Get network info
  const network = hre.network.name;
  const chainId = hre.network.config.chainId;
  
  console.log(`${colors.yellow}📡 Network Information:${colors.reset}`);
  console.log(`   Network: ${network}`);
  console.log(`   Chain ID: ${chainId}\n`);
  
  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  
  console.log(`${colors.yellow}👤 Deployer Information:${colors.reset}`);
  console.log(`   Address: ${deployer.address}`);
  console.log(`   Balance: ${hre.ethers.formatEther(balance)} ETH\n`);
  
  // Check if we're on mainnet (prevent accidental deployment)
  if (chainId === 1) {
    console.log(`${colors.red}${colors.bright}⛔ ERROR: Attempting to deploy to MAINNET!${colors.reset}`);
    console.log(`${colors.red}   These are VULNERABLE contracts for educational purposes only.${colors.reset}`);
    console.log(`${colors.red}   Deployment to mainnet is FORBIDDEN.${colors.reset}\n`);
    process.exit(1);
  }
  
  // Warn if on a real testnet
  const realTestnets = [11155111, 5, 80001]; // Sepolia, Goerli, Mumbai
  if (realTestnets.includes(chainId)) {
    console.log(`${colors.yellow}⚠️  WARNING: Deploying to a real testnet (${network})${colors.reset}`);
    console.log(`${colors.yellow}   Make sure you have sufficient test ETH.${colors.reset}`);
    console.log(`${colors.yellow}   These contracts are for EDUCATIONAL purposes only!${colors.reset}\n`);
  }
  
  // Object to store deployed addresses
  const deployedContracts = {};
  
  try {
    // ─────────────────────────────────────────────────────────────────────────
    // Deploy VulnerableContract
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}1️⃣  Deploying VulnerableContract...${colors.reset}`);
    
    const VulnerableContract = await hre.ethers.getContractFactory("VulnerableContract");
    const vulnerableContract = await VulnerableContract.deploy();
    await vulnerableContract.waitForDeployment();
    
    const vulnerableAddress = await vulnerableContract.getAddress();
    deployedContracts.VulnerableContract = vulnerableAddress;
    
    console.log(`   ✅ Deployed at: ${colors.green}${vulnerableAddress}${colors.reset}`);
    console.log(`   📝 Short: ${formatAddress(vulnerableAddress)}\n`);
    
    // ─────────────────────────────────────────────────────────────────────────
    // Deploy MaliciousReceiver
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}2️⃣  Deploying MaliciousReceiver...${colors.reset}`);
    
    const MaliciousReceiver = await hre.ethers.getContractFactory("MaliciousReceiver");
    const maliciousReceiver = await MaliciousReceiver.deploy();
    await maliciousReceiver.waitForDeployment();
    
    const maliciousAddress = await maliciousReceiver.getAddress();
    deployedContracts.MaliciousReceiver = maliciousAddress;
    
    console.log(`   ✅ Deployed at: ${colors.green}${maliciousAddress}${colors.reset}`);
    console.log(`   📝 Short: ${formatAddress(maliciousAddress)}\n`);
    
    // ─────────────────────────────────────────────────────────────────────────
    // Deploy FixedContract_RequireCheck
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}3️⃣  Deploying FixedContract_RequireCheck...${colors.reset}`);
    
    const FixedRequire = await hre.ethers.getContractFactory("FixedContract_RequireCheck");
    const fixedRequire = await FixedRequire.deploy();
    await fixedRequire.waitForDeployment();
    
    const fixedRequireAddress = await fixedRequire.getAddress();
    deployedContracts.FixedContract_RequireCheck = fixedRequireAddress;
    
    console.log(`   ✅ Deployed at: ${colors.green}${fixedRequireAddress}${colors.reset}`);
    console.log(`   📝 Short: ${formatAddress(fixedRequireAddress)}\n`);
    
    // ─────────────────────────────────────────────────────────────────────────
    // Deploy FixedContract_RevertPattern
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}4️⃣  Deploying FixedContract_RevertPattern...${colors.reset}`);
    
    const FixedRevert = await hre.ethers.getContractFactory("FixedContract_RevertPattern");
    const fixedRevert = await FixedRevert.deploy();
    await fixedRevert.waitForDeployment();
    
    const fixedRevertAddress = await fixedRevert.getAddress();
    deployedContracts.FixedContract_RevertPattern = fixedRevertAddress;
    
    console.log(`   ✅ Deployed at: ${colors.green}${fixedRevertAddress}${colors.reset}`);
    console.log(`   📝 Short: ${formatAddress(fixedRevertAddress)}\n`);
    
    // ─────────────────────────────────────────────────────────────────────────
    // Deployment Summary
    // ─────────────────────────────────────────────────────────────────────────
    console.log("═".repeat(80));
    console.log(`${colors.cyan}${colors.bright}  Deployment Complete!${colors.reset}`);
    console.log("═".repeat(80) + "\n");
    
    console.log(`${colors.green}✅ All contracts deployed successfully!${colors.reset}\n`);
    
    console.log(`${colors.yellow}📋 Deployment Summary:${colors.reset}`);
    console.log(`   Network: ${network} (Chain ID: ${chainId})`);
    console.log(`   Deployer: ${deployer.address}\n`);
    
    console.log(`${colors.yellow}📍 Contract Addresses:${colors.reset}`);
    for (const [name, address] of Object.entries(deployedContracts)) {
      console.log(`   ${name}:`);
      console.log(`     ${address}`);
    }
    console.log();
    
    // Save deployment addresses
    saveDeploymentAddresses(network, deployedContracts);
    
    // ─────────────────────────────────────────────────────────────────────────
    // Verification Instructions
    // ─────────────────────────────────────────────────────────────────────────
    if (realTestnets.includes(chainId)) {
      console.log(`${colors.yellow}🔍 Etherscan Verification:${colors.reset}`);
      console.log(`   To verify contracts on Etherscan, run:\n`);
      
      for (const [name, address] of Object.entries(deployedContracts)) {
        console.log(`   npx hardhat verify --network ${network} ${address}`);
      }
      console.log();
    }
    
    // ─────────────────────────────────────────────────────────────────────────
    // Next Steps
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.cyan}📝 Next Steps:${colors.reset}`);
    console.log(`   1. Save these addresses for your testing`);
    console.log(`   2. Test the vulnerability in VulnerableContract`);
    console.log(`   3. Compare with fixed contracts`);
    console.log(`   4. Share with your team for educational purposes\n`);
    
    console.log(`${colors.yellow}⚠️  Remember:${colors.reset}`);
    console.log(`   - These contracts are for EDUCATION ONLY`);
    console.log(`   - VulnerableContract has intentional security flaws`);
    console.log(`   - Never use vulnerable code in production`);
    console.log(`   - Always audit before deploying to mainnet\n`);
    
    console.log("═".repeat(80) + "\n");
    
  } catch (error) {
    console.error(`\n${colors.red}❌ Deployment failed!${colors.reset}`);
    console.error(`${colors.red}Error: ${error.message}${colors.reset}\n`);
    
    if (error.message.includes("insufficient funds")) {
      console.log(`${colors.yellow}💡 Tip: You need more ETH in your deployer account.${colors.reset}`);
      console.log(`${colors.yellow}   Get test ETH from a faucet for ${network}${colors.reset}\n`);
    }
    
    process.exit(1);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Execute deployment
// ═══════════════════════════════════════════════════════════════════════════════

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
