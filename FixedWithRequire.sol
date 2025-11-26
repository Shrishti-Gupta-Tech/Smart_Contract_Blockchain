// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FixedWithRequire
 * @notice FIX #1: Using require() statements to check return values
 * 
 * HOW THIS FIX WORKS:
 * ==================
 * This approach uses the require() statement to check the boolean return value
 * from external calls. If the call fails (returns false), require() will:
 * 1. Revert the entire transaction
 * 2. Restore all state changes
 * 3. Refund remaining gas (minus gas used)
 * 4. Provide a clear error message
 * 
 * ADVANTAGES:
 * -----------
 * ✓ Simple and straightforward to implement
 * ✓ Automatic transaction reversion on failure
 * ✓ Clear error messages for debugging
 * ✓ Follows the "fail-fast" principle
 * ✓ Prevents state inconsistencies
 * 
 * KEY IMPROVEMENTS:
 * ----------------
 * 1. Always capture return values from external calls
 * 2. Use require() to verify success before continuing
 * 3. Follow Checks-Effects-Interactions pattern (state changes after validation)
 * 4. Add descriptive error messages
 */

contract FixedWithRequire {
    
    // Mapping to track user balances
    mapping(address => uint256) public balances;
    
    // Events
    event Deposit(address indexed user, uint256 amount);
    event WithdrawalSuccessful(address indexed user, uint256 amount);
    event PaymentSuccessful(address indexed recipient, uint256 amount);
    
    /**
     * @notice Allows users to deposit Ether into the contract
     */
    function deposit() public payable {
        require(msg.value > 0, "Must send Ether");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @notice FIXED FUNCTION #1: Withdraw using .send() with require() check
     * 
     * THE FIX:
     * --------
     * 1. We capture the boolean return value from send()
     * 2. We use require() to check if it's true (success)
     * 3. If send() fails, require() reverts the entire transaction
     * 4. This prevents the balance update from persisting if transfer fails
     * 
     * IMPORTANT: We still follow a problematic pattern here (updating state before
     * external call). A better pattern would be to update state after the call,
     * but require() provides protection by reverting on failure.
     */
    function withdrawWithSend() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // Update state before call (protected by require below)
        balances[msg.sender] = 0;
        
        // ✅ FIX: Capture return value and check it with require()
        bool success = payable(msg.sender).send(amount);
        require(success, "Send failed: transfer rejected or out of gas");
        
        emit WithdrawalSuccessful(msg.sender, amount);
    }
    
    /**
     * @notice FIXED FUNCTION #2: Payment using .call() with require() check
     * 
     * THE FIX:
     * --------
     * 1. We capture both return values from call(): (bool success, bytes memory data)
     * 2. We use require() to verify the success boolean is true
     * 3. Transaction reverts if the call fails for any reason
     * 4. State changes are rolled back automatically
     * 
     * NOTE: Using .call() is preferred over .send() because:
     * - .call() forwards all available gas (send limits to 2300)
     * - .call() works with contracts that need more gas in receive/fallback
     * - Still safe when combined with require() checks
     */
    function makePayment(address payable recipient, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient");
        
        // Update state before call (protected by require below)
        balances[msg.sender] -= amount;
        
        // ✅ FIX: Capture both return values and check success with require()
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Call failed: transfer rejected or reverted");
        
        emit PaymentSuccessful(recipient, amount);
    }
    
    /**
     * @notice FIXED FUNCTION #3: Batch payment with proper error handling
     * 
     * THE FIX:
     * --------
     * Each payment is checked with require(). If ANY payment fails:
     * - The entire transaction reverts
     * - All state changes are rolled back
     * - No partial payments are made
     * - User's balance is restored
     * 
     * This ensures atomicity: either all payments succeed or none do.
     */
    function batchPayment(address payable[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "Array length mismatch");
        require(recipients.length > 0, "Empty arrays");
        
        // Calculate total amount needed
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Amount must be positive");
            totalAmount += amounts[i];
        }
        
        require(balances[msg.sender] >= totalAmount, "Insufficient balance");
        
        // Update state before calls (protected by require checks below)
        balances[msg.sender] -= totalAmount;
        
        // ✅ FIX: Check each payment with require()
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            (bool success, ) = recipients[i].call{value: amounts[i]}("");
            require(success, "Batch payment failed: one or more transfers rejected");
        }
    }
    
    /**
     * @notice ALTERNATIVE FIXED FUNCTION: Using .transfer()
     * 
     * THE FIX:
     * --------
     * Instead of using .send() or .call(), we can use .transfer() which:
     * - Automatically reverts on failure (no need for require)
     * - Limits gas to 2300 (prevents reentrancy)
     * - Simpler and more explicit
     * 
     * TRADE-OFFS:
     * - Gas limit of 2300 may not be enough for some contracts
     * - Less flexible than .call()
     * - Generally safer for simple Ether transfers
     */
    function withdrawWithTransfer() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // Update state before transfer (safe because transfer reverts on failure)
        balances[msg.sender] = 0;
        
        // ✅ FIX: .transfer() automatically reverts on failure
        // No need for require() - reversion is built-in
        payable(msg.sender).transfer(amount);
        
        emit WithdrawalSuccessful(msg.sender, amount);
    }
    
    /**
     * @notice BEST PRACTICE: Withdraw using Checks-Effects-Interactions pattern
     * 
     * THE BEST APPROACH:
     * -----------------
     * This implements the full Checks-Effects-Interactions pattern:
     * 1. CHECKS: Validate all conditions first
     * 2. EFFECTS: Update state variables
     * 3. INTERACTIONS: Make external calls last
     * 
     * Combined with require() checks, this provides maximum security.
     */
    function withdrawBestPractice() public {
        // CHECKS: Validate conditions
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // EFFECTS: Update state
        balances[msg.sender] = 0;
        
        // INTERACTIONS: External call (checked with require)
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit WithdrawalSuccessful(msg.sender, amount);
    }
    
    /**
     * @notice View function to check contract balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @notice View function to check user balance
     */
    function getUserBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}

/**
 * SUMMARY OF FIX #1 (require() checks):
 * ======================================
 * 
 * WHAT WE FIXED:
 * - Capture return values from .send() and .call()
 * - Use require() to verify success
 * - Provide descriptive error messages
 * - Ensure automatic reversion on failure
 * 
 * WHY IT WORKS:
 * - require() reverts transaction if condition is false
 * - All state changes are rolled back on reversion
 * - No state inconsistencies possible
 * - Clear failure feedback to users
 * 
 * WHEN TO USE:
 * - For simple, straightforward validation
 * - When you want automatic reversion
 * - When error messages are helpful
 * - Most common and recommended approach
 */
