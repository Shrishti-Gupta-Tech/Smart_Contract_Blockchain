// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Attacker
 * @notice This contract demonstrates how to exploit the vulnerability in Vulnerable.sol
 * @dev This contract rejects all incoming Ether transfers
 * 
 * PURPOSE:
 * ========
 * This contract is designed to reject all Ether transfers, which helps demonstrate
 * what happens when the Vulnerable contract makes a payment to a contract that
 * refuses to accept Ether.
 * 
 * HOW THE ATTACK WORKS:
 * ====================
 * 1. The Attacker contract has a receive() function that always reverts
 * 2. When Vulnerable.sol tries to send Ether to this contract, the transfer fails
 * 3. Because Vulnerable.sol doesn't check return values, it continues execution
 * 4. The sender's balance is deducted, but the Ether remains in Vulnerable.sol
 * 5. This creates a state inconsistency - the accounting is wrong!
 * 
 * ATTACK SCENARIO:
 * ===============
 * 1. Deploy this Attacker contract
 * 2. Deploy Vulnerable.sol
 * 3. Deposit Ether into Vulnerable.sol from a normal account
 * 4. Try to make a payment to this Attacker contract address
 * 5. The payment will fail silently - balance deducted but Ether not transferred!
 * 6. The Ether gets "stuck" in the Vulnerable contract
 * 
 * USAGE:
 * ======
 * 1. Deploy this contract in Remix
 * 2. Copy its address
 * 3. Use it as the recipient in Vulnerable.makePayment()
 * 4. Observe how the vulnerable contract fails silently
 * 5. Try the same with FixedWithRequire.sol or FixedWithRevert.sol to see proper error handling
 */

contract Attacker {
    
    // Event to log rejected payments
    event PaymentRejected(address indexed sender, uint256 amount, string reason);
    
    // Counter to track rejection attempts
    uint256 public rejectionCount;
    
    /**
     * @notice This function is called when Ether is sent to the contract
     * @dev Automatically rejects all incoming Ether transfers
     * 
     * HOW IT EXPLOITS THE VULNERABILITY:
     * - When Vulnerable.sol calls .send() or .call{value: x}(), it tries to send Ether here
     * - This receive() function reverts, causing the transfer to fail
     * - Vulnerable.sol doesn't check the return value, so it continues as if nothing happened
     * - The result: sender loses their balance but Ether stays in Vulnerable.sol
     */
    receive() external payable {
        rejectionCount++;
        emit PaymentRejected(msg.sender, msg.value, "I reject your payment!");
        revert("I reject your payment!");
    }
    
    /**
     * @notice Fallback function - also rejects all calls
     * @dev Called when no other function matches or when Ether is sent with data
     */
    fallback() external payable {
        rejectionCount++;
        emit PaymentRejected(msg.sender, msg.value, "I reject your payment (fallback)!");
        revert("I reject your payment (fallback)!");
    }
    
    /**
     * @notice View function to check contract balance (should always be 0)
     * @dev This will always return 0 because we reject all incoming Ether
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @notice View function to see how many times payments were rejected
     */
    function getRejectionCount() public view returns (uint256) {
        return rejectionCount;
    }
}

/**
 * DEMONSTRATION STEPS:
 * ===================
 * 
 * STEP 1: Deploy the contracts
 * - Deploy Attacker.sol (this contract)
 * - Deploy Vulnerable.sol
 * - Copy the Attacker contract address
 * 
 * STEP 2: Deposit Ether into Vulnerable.sol
 * - Call Vulnerable.deposit() with 1 ETH from your account
 * - Check your balance: Vulnerable.getUserBalance(YOUR_ADDRESS) should show 1 ETH
 * 
 * STEP 3: Attempt payment to Attacker (this will demonstrate the vulnerability)
 * - Call Vulnerable.makePayment(ATTACKER_ADDRESS, 0.5 ETH)
 * - The transaction will succeed ✅ (that's the problem!)
 * - Check your balance: Vulnerable.getUserBalance(YOUR_ADDRESS) now shows 0.5 ETH
 * - Check Attacker balance: Attacker.getBalance() shows 0 ETH (payment was rejected!)
 * - Check Vulnerable contract balance: should still have 1 ETH
 * 
 * STEP 4: Observe the vulnerability
 * - Your balance was deducted by 0.5 ETH
 * - But the Ether never left the Vulnerable contract
 * - This is a STATE INCONSISTENCY - the accounting is wrong!
 * - The 0.5 ETH is now "stuck" and unaccounted for
 * 
 * STEP 5: Try with fixed contracts (FixedWithRequire.sol or FixedWithRevert.sol)
 * - Deploy one of the fixed contracts
 * - Deposit 1 ETH
 * - Try to make payment to Attacker address
 * - The transaction will REVERT ❌ with a clear error message
 * - Your balance remains unchanged (still 1 ETH)
 * - No state inconsistency occurs!
 * 
 * COMPARISON:
 * ==========
 * Vulnerable.sol: Transaction succeeds, balance deducted, Ether stuck ❌
 * Fixed contracts: Transaction reverts, balance preserved, clear error ✅
 */
