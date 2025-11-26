// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableContract
 * @notice This contract demonstrates the "Unchecked External Call Return Values" vulnerability
 * 
 * VULNERABILITY EXPLANATION:
 * =========================
 * This contract uses low-level calls (.call, .send) to transfer Ether but does NOT check
 * if these calls succeeded or failed. This creates several critical issues:
 * 
 * 1. SILENT FAILURES: If the external call fails (e.g., recipient rejects, out of gas),
 *    the function continues execution as if nothing went wrong.
 * 
 * 2. STATE INCONSISTENCY: The contract updates its internal state (balance tracking)
 *    even when the actual Ether transfer fails.
 * 
 * 3. LOSS OF FUNDS: Users may believe their withdrawal succeeded when it actually failed,
 *    leading to confusion and potential loss of funds.
 * 
 * 4. EXPLOITATION RISK: Malicious actors can exploit this by creating contracts that
 *    intentionally fail to receive Ether, causing accounting errors.
 */

contract VulnerableContract {
    
    // Mapping to track user balances
    mapping(address => uint256) public balances;
    
    // Events
    event Deposit(address indexed user, uint256 amount);
    event WithdrawalAttempted(address indexed user, uint256 amount);
    event PaymentAttempted(address indexed recipient, uint256 amount);
    
    /**
     * @notice Allows users to deposit Ether into the contract
     */
    function deposit() public payable {
        require(msg.value > 0, "Must send Ether");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @notice VULNERABLE FUNCTION #1: Withdraw using .send()
     * 
     * THE VULNERABILITY:
     * -----------------
     * The .send() function returns a boolean (true/false) but we're NOT checking it!
     * If the send fails (e.g., recipient is a contract that rejects payments, or
     * runs out of gas), the function will:
     * 1. Still deduct the balance from the user's account
     * 2. Emit the event as if withdrawal succeeded
     * 3. Return normally without reverting
     * 
     * RESULT: User loses their balance tracking but doesn't receive the Ether!
     */
    function withdrawWithSend() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // VULNERABILITY: We update state BEFORE the external call (bad pattern)
        // and we DON'T check if send() succeeded!
        balances[msg.sender] = 0;
        
        // This send() might fail, but we ignore the return value
        payable(msg.sender).send(amount);  // ❌ UNCHECKED RETURN VALUE!
        
        emit WithdrawalAttempted(msg.sender, amount);
    }
    
    /**
     * @notice VULNERABLE FUNCTION #2: Payment using .call()
     * 
     * THE VULNERABILITY:
     * -----------------
     * The .call{value: x}() returns (bool success, bytes memory data) but we're
     * NOT capturing or checking these return values!
     * 
     * This is even more dangerous because:
     * 1. .call() forwards all available gas (unlike send which limits to 2300 gas)
     * 2. Failure is completely silent
     * 3. Can be exploited more easily by malicious contracts
     */
    function makePayment(address payable recipient, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient");
        
        // VULNERABILITY: State updated before external call and return value not checked
        balances[msg.sender] -= amount;
        
        // This call() might fail, but we completely ignore the return values!
        recipient.call{value: amount}("");  // ❌ UNCHECKED RETURN VALUE!
        
        emit PaymentAttempted(recipient, amount);
    }
    
    /**
     * @notice VULNERABLE FUNCTION #3: Batch payment vulnerability
     * 
     * THE VULNERABILITY:
     * -----------------
     * When one payment in a batch fails, the contract continues processing
     * without reverting, leading to partial failures that are undetected.
     */
    function batchPayment(address payable[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "Array length mismatch");
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        require(balances[msg.sender] >= totalAmount, "Insufficient balance");
        balances[msg.sender] -= totalAmount;
        
        // VULNERABILITY: If any payment fails, we don't know and don't revert!
        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].call{value: amounts[i]}("");  // ❌ UNCHECKED!
        }
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
