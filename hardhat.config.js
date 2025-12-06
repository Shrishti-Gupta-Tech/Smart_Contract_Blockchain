require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); // Load environment variables from .env file

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20", // Matches the pragma in your contracts
  networks: {
    // Localhost network (default for 'npx hardhat node')
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // Sepolia Testnet (Example configuration)
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "https://eth-sepolia.public.blastapi.io",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  paths: {
    sources: "./", // Contracts are in the root directory
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};
