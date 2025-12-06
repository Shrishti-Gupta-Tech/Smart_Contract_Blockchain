// ═══════════════════════════════════════════════════════════════════════════════
// Hardhat Deployment Script - Unchecked Return Value Vulnerability
// ═══════════════════════════════════════════════════════════════════════════════
//
// This script deploys the vulnerable and fixed contracts for the assignment.
// 
// USAGE:
//   npx hardhat run scripts/deploy.js --network <network-name>
//
// EXAMPLES:
//   npx hardhat run scripts/deploy.js --network localhost
//   npx hardhat run scripts/deploy.js --network sepolia
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

function formatAddress(address) {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

function saveDeploymentAddresses(network, addresses) {
  const deploymentsDir = path.join(__dirname, "..", "deployments");
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

async function main() {
  console.log("\n" + "═".repeat(80));
  console.log(`${colors.cyan}${colors.bright}  Unchecked Return Value Vulnerability - Deployment Script${colors.reset}`);
  console.log("═".repeat(80) + "\n");
  
  const network = hre.network.name;
  const chainId = hre.network.config.chainId;
  
  console.log(`${colors.yellow}📡 Network Information:${colors.reset}`);
  console.log(`   Network: ${network}`);
  console.log(`   Chain ID: ${chainId}\n`);
  
  const [deployer] = await hre.ethers.getSigners();
  
  console.log(`${colors.yellow}👤 Deployer Information:${colors.reset}`);
  console.log(`   Address: ${deployer.address}`);
  // Balance check might fail on some networks if provider is not ready, keeping it simple
  
  const deployedContracts = {};
  
  try {
    // ─────────────────────────────────────────────────────────────────────────
    // 1. Deploy VulnerableRelayer
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}1️⃣  Deploying VulnerableRelayer...${colors.reset}`);
    const VulnerableRelayer = await hre.ethers.getContractFactory("VulnerableRelayer");
    const vulnerableRelayer = await VulnerableRelayer.deploy();
    await vulnerableRelayer.waitForDeployment();
    const vulnerableAddress = await vulnerableRelayer.getAddress();
    deployedContracts.VulnerableRelayer = vulnerableAddress;
    console.log(`   ✅ Deployed at: ${colors.green}${vulnerableAddress}${colors.reset}\n`);

    // ─────────────────────────────────────────────────────────────────────────
    // 2. Deploy FixedRelayerChecked (Fix 1)
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}2️⃣  Deploying FixedRelayerChecked (Fix 1)...${colors.reset}`);
    const FixedRelayerChecked = await hre.ethers.getContractFactory("FixedRelayerChecked");
    const fixedChecked = await FixedRelayerChecked.deploy();
    await fixedChecked.waitForDeployment();
    const fixedCheckedAddress = await fixedChecked.getAddress();
    deployedContracts.FixedRelayerChecked = fixedCheckedAddress;
    console.log(`   ✅ Deployed at: ${colors.green}${fixedCheckedAddress}${colors.reset}\n`);

    // ─────────────────────────────────────────────────────────────────────────
    // 3. Deploy FixedRelayerConditional (Fix 2)
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}3️⃣  Deploying FixedRelayerConditional (Fix 2)...${colors.reset}`);
    const FixedRelayerConditional = await hre.ethers.getContractFactory("FixedRelayerConditional");
    const fixedConditional = await FixedRelayerConditional.deploy();
    await fixedConditional.waitForDeployment();
    const fixedConditionalAddress = await fixedConditional.getAddress();
    deployedContracts.FixedRelayerConditional = fixedConditionalAddress;
    console.log(`   ✅ Deployed at: ${colors.green}${fixedConditionalAddress}${colors.reset}\n`);

    // ─────────────────────────────────────────────────────────────────────────
    // 4. Deploy Helper Contracts (RevertingTarget, SuccessTarget)
    // ─────────────────────────────────────────────────────────────────────────
    console.log(`${colors.bright}${colors.magenta}4️⃣  Deploying Helper Contracts...${colors.reset}`);
    
    // RevertingTarget
    const RevertingTarget = await hre.ethers.getContractFactory("RevertingTarget");
    const revertingTarget = await RevertingTarget.deploy();
    await revertingTarget.waitForDeployment();
    const revertingAddress = await revertingTarget.getAddress();
    deployedContracts.RevertingTarget = revertingAddress;
    console.log(`   ✅ RevertingTarget: ${colors.green}${revertingAddress}${colors.reset}`);

    // SuccessTarget
    const SuccessTarget = await hre.ethers.getContractFactory("SuccessTarget");
    const successTarget = await SuccessTarget.deploy();
    await successTarget.waitForDeployment();
    const successAddress = await successTarget.getAddress();
    deployedContracts.SuccessTarget = successAddress;
    console.log(`   ✅ SuccessTarget:   ${colors.green}${successAddress}${colors.reset}\n`);

    // ─────────────────────────────────────────────────────────────────────────
    // Summary
    // ─────────────────────────────────────────────────────────────────────────
    console.log("═".repeat(80));
    console.log(`${colors.green}✅ All contracts deployed successfully!${colors.reset}\n`);
    
    saveDeploymentAddresses(network, deployedContracts);
    
  } catch (error) {
    console.error(`\n${colors.red}❌ Deployment failed!${colors.reset}`);
    console.error(`${colors.red}Error: ${error.message}${colors.reset}\n`);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
