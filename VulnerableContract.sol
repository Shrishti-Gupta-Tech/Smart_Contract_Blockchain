// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableContract
 * @author Educational Project - Blockchain Security Demo
 * @notice This contract intentionally demonstrates the "Unchecked External Call Return Values" vulnerability (SWC-104)
 * @dev ⚠️ WARNING: This contract is INTENTIONALLY VULNERABLE for educational purposes. NEVER use in production!
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * VULNERABILITY CLASSIFICATION
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * Name:     Unchecked External Call Return Values
 * SWC-ID:   SWC-104
 * Severity: HIGH
 * Category: Error Handling / Input Validation
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * WHAT IS THIS VULNERABILITY?
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * In Solidity, when you send Ether using low-level functions like:
 * - .send()         → Returns: bool (true/false)
 * - .call{value}()  → Returns: (bool success, bytes memory data)
 * - .delegatecall() → Returns: (bool success, bytes memory data)
 * 
 * These functions DO NOT automatically revert on failure. Instead, they return
 * a boolean value indicating success or failure. If you ignore this return value,
 * your contract will continue executing even when the transfer fails!
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * WHY IS THIS DANGEROUS?
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * 1. 🔇 SILENT FAILURES
 *    - Transfer fails but no error is thrown
 *    - User thinks transaction succeeded
 *    - No indication something went wrong
 * 
 * 2. 💔 STATE INCONSISTENCY  
 *    - Contract state updates (e.g., balance -= amount)
 *    - But actual Ether transfer fails
 *    - Accounting becomes incorrect
 *    - Real balance ≠ Tracked balance
 * 
 * 3. 💸 LOSS OF FUNDS
 *    - User's tracked balance decreases
 *    - But Ether stays stuck in contract
 *    - Funds become unrecoverable
 *    - Users lose money permanently
 * 
 * 4. 🎯 EXPLOITATION VECTOR
 *    - Malicious contracts can reject payments intentionally
 *    - Attackers can manipulate contract state
 *    - Creates accounting errors that benefit attackers
 *    - Can be used in complex attack chains
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * REAL-WORLD IMPACT
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * Historical Examples:
 * - King of the Ether Throne: Users got stuck, couldn't claim throne
 * - Various ICO contracts: Users lost ETH during token distribution
 * - Multiple DeFi protocols: Funds locked due to failed transfers
 * 
 * Financial Impact:
 * - Millions of dollars lost across various projects
 * - Reputation damage to affected projects
 * - User trust erosion in blockchain ecosystem
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * HOW TO EXPLOIT THIS CONTRACT (For Educational Testing)
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * Step 1: Deploy VulnerableContract
 * Step 2: Deploy MaliciousReceiver (a contract that rejects payments)
 * Step 3: Deposit Ether into VulnerableContract
 * Step 4: Call makePayment() with MaliciousReceiver address
 * Step 5: Observe: Transaction succeeds but Ether is stuck!
 * 
 * Result: Your balance tracking shows deduction, but Ether never left!
 */

contract VulnerableContract {
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // STATE VARIABLES
    // ═══════════════════════════════════════════════════════════════════════════════
    
    /**
     * @dev Mapping to track each user's Ether balance in the contract
     * @notice This is our "accounting ledger" - it tracks who owns what
     * 
     * Key Concept for Beginners:
     * - Mapping is like a database table: address → balance
     * - Each user's address maps to their balance (in wei)
     * - 1 Ether = 1,000,000,000,000,000,000 wei (18 decimals)
     * 
     * Why we track balances:
     * - Users can deposit Ether and withdraw later
     * - We need to know how much each user has deposited
     * - This allows for more complex logic than just .transfer()
     * 
     * ⚠️ THE VULNERABILITY RISK:
     * If external calls fail but we don't check, this mapping becomes
     * incorrect (shows deductions that never happened in reality)
     */
    mapping(address => uint256) public balances;
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    /**
     * @dev Emitted when a user deposits Ether into the contract
     * @param user The address of the user making the deposit
     * @param amount The amount of Ether deposited (in wei)
     * 
     * Events Explanation for Beginners:
     * - Events are like "logs" on the blockchain
     * - They allow external applications (dApps) to track what happened
     * - Events are cheaper than storing data in contract state
     * - You can search for events on blockchain explorers (like Etherscan)
     */
    event Deposit(address indexed user, uint256 amount);
    
    /**
     * @dev Emitted when a withdrawal is attempted (whether successful or not!)
     * @param user The address attempting to withdraw
     * @param amount The amount attempting to be withdrawn
     * 
     * ⚠️ VULNERABILITY INDICATOR:
     * This event name is misleading! It says "Attempted" which suggests
     * it might fail, but users might interpret it as successful.
     * Better name: "WithdrawalInitiated" or just "Withdrawal"
     */
    event WithdrawalAttempted(address indexed user, uint256 amount);
    
    /**
     * @dev Emitted when a payment is attempted to another address
     * @param recipient The address receiving the payment
     * @param amount The amount being sent
     * 
     * ⚠️ VULNERABILITY INDICATOR:
     * Same issue - "Attempted" doesn't clearly indicate success/failure.
     * The event fires even when payment fails!
     */
    event PaymentAttempted(address indexed recipient, uint256 amount);
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // FUNCTIONS - SAFE (No vulnerability)
    // ═══════════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Allows users to deposit Ether into the contract
     * @dev This function is SAFE - it doesn't have the vulnerability
     * 
     * Function Modifiers Explained:
     * - public:  Anyone can call this function
     * - payable: This function can receive Ether
     * 
     * How it works:
     * 1. User sends Ether when calling this function
     * 2. We validate they sent more than 0 (using require)
     * 3. We update their balance in our mapping
     * 4. We emit an event for tracking
     * 
     * Key Concepts:
     * - msg.value = Amount of Ether sent (in wei)
     * - msg.sender = Address of the caller
     * - require() = If condition fails, revert everything
     * 
     * Why this is SAFE:
     * - No external calls made
     * - No return values to check
     * - Simple state update
     * - Follows Checks-Effects pattern
     */
    function deposit() public payable {
        // CHECK: Validate input
        require(msg.value > 0, "Must send Ether");
        
        // EFFECT: Update state
        balances[msg.sender] += msg.value;
        
        // LOG: Emit event for off-chain tracking
        emit Deposit(msg.sender, msg.value);
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // VULNERABLE FUNCTIONS - ⚠️ THESE DEMONSTRATE THE SECURITY FLAW
    // ═══════════════════════════════════════════════════════════════════════════════
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableContract
 * @author Educational Project - Blockchain Security Demo
 * @notice This contract intentionally demonstrates the "Unchecked External Call Return Values" vulnerability (SWC-104)
 * @dev ⚠️ WARNING: This contract is INTENTIONALLY VULNERABLE for educational purposes. NEVER use in production!
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * VULNERABILITY CLASSIFICATION
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * Name:     Unchecked External Call Return Values
 * SWC-ID:   SWC-104
 * Severity: HIGH
 * Category: Error Handling / Input Validation
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * WHAT IS THIS VULNERABILITY?
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * In Solidity, when you send Ether using low-level functions like:
 * - .send()         → Returns: bool (true/false)
 * - .call{value}()  → Returns: (bool success, bytes memory data)
 * - .delegatecall() → Returns: (bool success, bytes memory data)
 * 
 * These functions DO NOT automatically revert on failure. Instead, they return
 * a boolean value indicating success or failure. If you ignore this return value,
 * your contract will continue executing even when the transfer fails!
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * WHY IS THIS DANGEROUS?
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * 1. 🔇 SILENT FAILURES
 *    - Transfer fails but no error is thrown
 *    - User thinks transaction succeeded
 *    - No indication something went wrong
 * 
 * 2. 💔 STATE INCONSISTENCY  
 *    - Contract state updates (e.g., balance -= amount)
 *    - But actual Ether transfer fails
 *    - Accounting becomes incorrect
 *    - Real balance ≠ Tracked balance
 * 
 * 3. 💸 LOSS OF FUNDS
 *    - User's tracked balance decreases
 *    - But Ether stays stuck in contract
 *    - Funds become unrecoverable
 *    - Users lose money permanently
 * 
 * 4. 🎯 EXPLOITATION VECTOR
 *    - Malicious contracts can reject payments intentionally
 *    - Attackers can manipulate contract state
 *    - Creates accounting errors that benefit attackers
 *    - Can be used in complex attack chains
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * REAL-WORLD IMPACT
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * Historical Examples:
 * - King of the Ether Throne: Users got stuck, couldn't claim throne
 * - Various ICO contracts: Users lost ETH during token distribution
 * - Multiple DeFi protocols: Funds locked due to failed transfers
 * 
 * Financial Impact:
 * - Millions of dollars lost across various projects
 * - Reputation damage to affected projects
 * - User trust erosion in blockchain ecosystem
 * 
 * ═══════════════════════════════════════════════════════════════════════════════
 * HOW TO EXPLOIT THIS CONTRACT (For Educational Testing)
 * ═══════════════════════════════════════════════════════════════════════════════
 * 
 * Step 1: Deploy VulnerableContract
 * Step 2: Deploy MaliciousReceiver (a contract that rejects payments)
 * Step 3: Deposit Ether into VulnerableContract
 * Step 4: Call makePayment() with MaliciousReceiver address
 * Step 5: Observe: Transaction succeeds but Ether is stuck!
 * 
 * Result: Your balance tracking shows deduction, but Ether never left!
 */

contract VulnerableContract {
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // STATE VARIABLES
    // ═══════════════════════════════════════════════════════════════════════════════
    
    /**
     * @dev Mapping to track each user's Ether balance in the contract
     * @notice This is our "accounting ledger" - it tracks who owns what
     * Key Concept for Beginners:
     * - Mapping is like a database table: address → balance
     * - Each user's address maps to their balance (in wei)
     * - 1 Ether = 1,000,000,000,000,000,000 wei (18 decimals)
     * 
     * Why we track balances:
     * - Users can deposit Ether and withdraw later
     * - We need to know how much each user has deposited
     * - This allows for more complex logic than just .transfer()
     * 
     * ⚠️ THE VULNERABILITY RISK:
     * If external calls fail but we don't check, this mapping becomes
     * incorrect (shows deductions that never happened in reality)
     */
    mapping(address => uint256) public balances;
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    /**
     * @dev Emitted when a user deposits Ether into the contract
     * @param user The address of the user making the deposit
     * @param amount The amount of Ether deposited (in wei)
     * 
     * Events Explanation for Beginners:
     * - Events are like "logs" on the blockchain
     * - They allow external applications (dApps) to track what happened
     * - Events are cheaper than storing data in contract state
     * - You can search for events on blockchain explorers (like Etherscan)
     */
    event Deposit(address indexed user, uint256 amount);
    
    /**
     * @dev Emitted when a withdrawal is attempted (whether successful or not!)
     * @param user The address attempting to withdraw
     * @param amount The amount attempting to be withdrawn
     * 
     * ⚠️ VULNERABILITY INDICATOR:
     * This event name is misleading! It says "Attempted" which suggests
     * it might fail, but users might interpret it as successful.
     * Better name: "WithdrawalInitiated" or just "Withdrawal"
     */
    event WithdrawalAttempted(address indexed user, uint256 amount);
    
    /**
     * @dev Emitted when a payment is attempted to another address
     * @param recipient The address receiving the payment
     * @param amount The amount being sent
     * 
     * ⚠️ VULNERABILITY INDICATOR:
     * Same issue - "Attempted" doesn't clearly indicate success/failure.
     * The event fires even when payment fails!
     */
    event PaymentAttempted(address indexed recipient, uint256 amount);
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // FUNCTIONS - SAFE (No vulnerability)
