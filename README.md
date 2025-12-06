# Smart Contract Vulnerability Analysis

## Unchecked Return Values of Low-Level Calls (SWC-104)

**Course:** Blockchain Technology & Smart Contracts  
**Assignment:** Final Year Project / MTech Assignment

---

## 📌 Project Overview

This project analyzes a critical smart contract vulnerability: **Unchecked Return Values of Low-Level Calls**. In Solidity, functions like `.call()` return `false` on failure instead of reverting. If this return value is ignored, contracts may proceed with incorrect state updates, leading to potential exploits.

This repository provides:

1.  **Vulnerable Code**: A demonstration of the flaw.
2.  **Exploit Scenario**: How an attacker can abuse it.
3.  **Two Fixes**: Secure implementation patterns (`require` check vs. conditional handling).
4.  **Comprehensive Report**: A detailed MTech-style project report.

---

## 📂 Repository Structure

### 📄 Documentation

- **`Smart_Contract_Vulnerability_Report.md`**: 🌟 **MAIN REPORT**. Contains the full analysis, implementation details, testing results, and **Deployment Guide**.

### 💻 Smart Contracts

- **`Vulnerable.sol`**: Contains `VulnerableRelayer` (the flawed contract) and helper contracts for testing.
- **`Fix1_CheckedCall.sol`**: Fix #1 - Uses `require(success)` to revert on failure.
- **`Fix2_Conditional.sol`**: Fix #2 - Uses `if(success)` to handle failure gracefully.

### ⚙️ Tooling & Scripts

- **`scripts/deploy.js`**: Hardhat script to deploy all contracts.
- **`hardhat.config.js`**: Configuration for local and testnet deployments.

---

## 🚀 Quick Start

### Option 1: Read the Report

Open **[`Smart_Contract_Vulnerability_Report.md`](./Smart_Contract_Vulnerability_Report.md)** for the complete project documentation and analysis.

### Option 2: Run in Remix IDE (Easiest)

1.  Go to [Remix IDE](https://remix.ethereum.org).
2.  Upload the `.sol` files.
3.  Deploy `VulnerableRelayer` and `RevertingTarget`.
4.  Test the exploit! (See Chapter 4 of the Report for details).

### Option 3: Run Locally with Hardhat

1.  Install dependencies:
    ```bash
    npm install
    ```
2.  Run the deployment script:
    ```bash
    npx hardhat run scripts/deploy.js --network localhost
    ```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
