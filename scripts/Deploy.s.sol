// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * ═══════════════════════════════════════════════════════════════════════════════
 * Foundry Deployment Script - Educational Smart Contracts
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * This script deploys all contracts from the vulnerability demo project using Foundry
 * 
 * USAGE:
 *   forge script scripts/Deploy.s.sol:DeployScript --rpc-url <rpc-url> --broadcast
 * 
 * EXAMPLES:
 *   # Local deployment
 *   forge script scripts/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --broadcast
 * 
 *   # Sepolia testnet
 *   forge script scripts/Deploy.s.sol:DeployScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
 * 
 * ⚠️  WARNING: Only deploy to testnets! Never deploy vulnerable contracts to mainnet!
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 */

import "forge-std/Script.sol";
import "forge-std/console.sol";

// Import contracts
import "../VulnerableContract.sol";
import "../MaliciousReceiver.sol";
import "../FixedContract_RequireCheck.sol";
import "../FixedContract_RevertPattern.sol";

contract DeployScript is Script {
    
    // Deployed contract addresses
    VulnerableContract public vulnerableContract;
    MaliciousReceiver public maliciousReceiver;
    FixedContract_RequireCheck public fixedRequireCheck;
    FixedContract_RevertPattern public fixedRevertPattern;
    
    /**
     * @notice Main deployment function
     */
    function run() external {
        // Get deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("\n");
        console.log("================================================================================");
        console.log("  Blockchain Vulnerability Demo - Foundry Deployment");
        console.log("================================================================================\n");
        
        // Display deployer info
        console.log("Deployer Information:");
        console.log("  Address:", deployer);
        console.log("  Balance:", deployer.balance / 1e18, "ETH\n");
        
        // Check chain ID (prevent mainnet deployment)
        uint256 chainId = block.chainid;
        console.log("Network Information:");
        console.log("  Chain ID:", chainId);
        
        if (chainId == 1) {
            console.log("\n");
            console.log("ERROR: Attempting to deploy to MAINNET!");
            console.log("  These are VULNERABLE contracts for educational purposes only.");
            console.log("  Deployment to mainnet is FORBIDDEN.\n");
            revert("Mainnet deployment forbidden");
        }
        
        // Warn if on real testnet
        if (chainId == 11155111 || chainId == 5 || chainId == 80001) {
            console.log("  WARNING: Deploying to a real testnet");
            console.log("  Make sure you have sufficient test ETH");
            console.log("  These contracts are for EDUCATIONAL purposes only!\n");
        }
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("================================================================================");
        console.log("  Deploying Contracts...");
        console.log("================================================================================\n");
        
        // ─────────────────────────────────────────────────────────────────────────
        // Deploy VulnerableContract
        // ─────────────────────────────────────────────────────────────────────────
        console.log("1. Deploying VulnerableContract...");
        vulnerableContract = new VulnerableContract();
        console.log("   Deployed at:", address(vulnerableContract));
        console.log("   Gas used:", gasleft(), "\n");
        
        // ─────────────────────────────────────────────────────────────────────────
        // Deploy MaliciousReceiver
        // ─────────────────────────────────────────────────────────────────────────
        console.log("2. Deploying MaliciousReceiver...");
        maliciousReceiver = new MaliciousReceiver();
        console.log("   Deployed at:", address(maliciousReceiver));
        console.log("   Gas used:", gasleft(), "\n");
        
        // ─────────────────────────────────────────────────────────────────────────
        // Deploy FixedContract_RequireCheck
        // ─────────────────────────────────────────────────────────────────────────
        console.log("3. Deploying FixedContract_RequireCheck...");
        fixedRequireCheck = new FixedContract_RequireCheck();
        console.log("   Deployed at:", address(fixedRequireCheck));
        console.log("   Gas used:", gasleft(), "\n");
        
        // ─────────────────────────────────────────────────────────────────────────
        // Deploy FixedContract_RevertPattern
        // ─────────────────────────────────────────────────────────────────────────
        console.log("4. Deploying FixedContract_RevertPattern...");
        fixedRevertPattern = new FixedContract_RevertPattern();
        console.log("   Deployed at:", address(fixedRevertPattern));
        console.log("   Gas used:", gasleft(), "\n");
        
        // Stop broadcasting
        vm.stopBroadcast();
        
        // ─────────────────────────────────────────────────────────────────────────
        // Deployment Summary
        // ─────────────────────────────────────────────────────────────────────────
        console.log("================================================================================");
        console.log("  Deployment Complete!");
        console.log("================================================================================\n");
        
        console.log("Contract Addresses:");
        console.log("  VulnerableContract:          ", address(vulnerableContract));
        console.log("  MaliciousReceiver:           ", address(maliciousReceiver));
        console.log("  FixedContract_RequireCheck:  ", address(fixedRequireCheck));
        console.log("  FixedContract_RevertPattern: ", address(fixedRevertPattern));
        console.log("\n");
        
        // ─────────────────────────────────────────────────────────────────────────
        // Verification Commands
        // ─────────────────────────────────────────────────────────────────────────
        if (chainId == 11155111 || chainId == 5 || chainId == 80001) {
            console.log("Etherscan Verification:");
            console.log("  Run these commands to verify on Etherscan:\n");
            
            console.log("  forge verify-contract", address(vulnerableContract), "VulnerableContract");
            console.log("  forge verify-contract", address(maliciousReceiver), "MaliciousReceiver");
            console.log("  forge verify-contract", address(fixedRequireCheck), "FixedContract_RequireCheck");
            console.log("  forge verify-contract", address(fixedRevertPattern), "FixedContract_RevertPattern");
            console.log("\n");
        }
        
        // ─────────────────────────────────────────────────────────────────────────
        // Next Steps
        // ─────────────────────────────────────────────────────────────────────────
        console.log("Next Steps:");
        console.log("  1. Save these addresses for your testing");
        console.log("  2. Test the vulnerability in VulnerableContract");
        console.log("  3. Compare with fixed contracts");
        console.log("  4. Share with your team for educational purposes\n");
        
        console.log("Remember:");
        console.log("  - These contracts are for EDUCATION ONLY");
        console.log("  - VulnerableContract has intentional security flaws");
        console.log("  - Never use vulnerable code in production");
        console.log("  - Always audit before deploying to mainnet\n");
        
        console.log("================================================================================\n");
    }
    
    /**
     * @notice Helper function to get short address format
     */
    function getShortAddress(address addr) internal pure returns (string memory) {
        bytes memory addrBytes = abi.encodePacked(addr);
        bytes memory result = new bytes(10);
        
        // First 4 characters (0x + 2 bytes)
        result[0] = "0";
        result[1] = "x";
        for (uint i = 0; i < 2; i++) {
            result[2 + i] = toHexChar(uint8(addrBytes[i]));
        }
        
        // ...
        result[4] = ".";
        result[5] = ".";
        result[6] = ".";
        
        // Last 3 characters
        for (uint i = 0; i < 3; i++) {
            result[7 + i] = toHexChar(uint8(addrBytes[17 + i]));
        }
        
        return string(result);
    }
    
    /**
     * @notice Convert byte to hex character
     */
    function toHexChar(uint8 b) internal pure returns (bytes1) {
        if (b < 10) {
            return bytes1(uint8(b) + 48); // 0-9
        } else {
            return bytes1(uint8(b) + 87); // a-f
        }
    }
}

/**
 * ═══════════════════════════════════════════════════════════════════════════════
 * USAGE EXAMPLES
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * 1. LOCAL DEPLOYMENT (Anvil):
 *    # Start local node
 *    anvil
 *    
 *    # Deploy (in another terminal)
 *    forge script scripts/Deploy.s.sol:DeployScript \
 *      --rpc-url http://localhost:8545 \
 *      --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
 *      --broadcast
 * 
 * 2. SEPOLIA TESTNET:
 *    # Set environment variables
 *    export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR-API-KEY"
 *    export PRIVATE_KEY="your-private-key"
 *    export ETHERSCAN_API_KEY="your-etherscan-api-key"
 *    
 *    # Deploy and verify
 *    forge script scripts/Deploy.s.sol:DeployScript \
 *      --rpc-url $SEPOLIA_RPC_URL \
 *      --broadcast \
 *      --verify \
 *      -vvvv
 * 
 * 3. DRY RUN (Simulate without broadcasting):
 *    forge script scripts/Deploy.s.sol:DeployScript \
 *      --rpc-url $SEPOLIA_RPC_URL
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * ENVIRONMENT VARIABLES
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * Required:
 *   PRIVATE_KEY         - Your deployer private key (without 0x prefix)
 * 
 * Optional:
 *   SEPOLIA_RPC_URL     - RPC URL for Sepolia testnet
 *   GOERLI_RPC_URL      - RPC URL for Goerli testnet  
 *   ETHERSCAN_API_KEY   - For contract verification
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 */
