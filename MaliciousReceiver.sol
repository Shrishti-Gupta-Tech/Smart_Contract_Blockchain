// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MaliciousReceiver
 * @notice This contract can be used to demonstrate the vulnerability
 * @dev This contract rejects all incoming Ether transfers
 * 
 * PURPOSE:
 * ========
 * This contract is designed to reject all Ether transfers, which helps demonstrate
 * what happens when the VulnerableContract makes a payment to a contract that
 * refuses to accept Ether.
 * 
 * USAGE:
 * ======
 * 1. Deploy this contract in Remix
 * 2. Copy its address
 * 3. Use it as the recipient in VulnerableContract.makePayment()
 * 4. Observe how the vulnerable contract fails silently
 * 5. Try the same with FixedContract to see proper error handling
 */

contract MaliciousReceiver {
    
    // Event to log rejected payments
    event PaymentRejected(address indexed sender, uint256 amount);
    
    /**
     * @notice This function is called when Ether is sent to the contract
     * @dev Automatically rejects all incoming Ether transfers
     */
    receive() external payable {
        emit PaymentRejected(msg.sender, msg.value);
        revert("I reject your payment!");
    }
    
    /**
     * @notice Fallback function - also rejects all calls
     * @dev Called when no other function matches or when Ether is sent with data
     */
    fallback() external payable {
        emit PaymentRejected(msg.sender, msg.value);
        revert("I reject your payment!");
    }
    
    /**
     * @notice View function to check contract balance (should always be 0)
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
