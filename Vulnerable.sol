// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableRelayer
 * @dev Demonstrates the "Unchecked Return Value" vulnerability with low-level calls.
 */
contract VulnerableRelayer {
    mapping(address => uint256) public balances;

    /**
     * @notice Executes a call to a target contract and credits the sender.
     * @dev VULNERABILITY: The return value of the low-level .call() is ignored.
     * If the call fails (e.g., target reverts), execution continues, and the user
     * is credited incorrectly.
     * @param target The address of the contract to call.
     * @param data The calldata to send to the target.
     */
    function executeAndCredit(address target, bytes calldata data) external {
        // ------------------------------------------------------------------------
        // VULNERABLE CODE START
        // ------------------------------------------------------------------------
        
        // We perform a low-level call to the target.
        // This returns a boolean 'success' and bytes 'returnData'.
        // However, we are ignoring these return values.
        target.call(data);

        // ------------------------------------------------------------------------
        // VULNERABLE CODE END
        // ------------------------------------------------------------------------

        // The contract assumes the call succeeded and credits the user.
        // An attacker can provide a target/data that fails (reverts),
        // but they will still receive the credit here.
        balances[msg.sender] += 100;
    }
}

/**
 * @title RevertingTarget
 * @dev A helper contract to demonstrate the vulnerability.
 * This contract ALWAYS reverts when called.
 */
contract RevertingTarget {
    fallback() external {
        revert("I always revert!");
    }
}

/**
 * @title SuccessTarget
 * @dev A helper contract to demonstrate the normal case.
 * This contract accepts calls successfully.
 */
contract SuccessTarget {
    fallback() external {
        // Do nothing, just succeed
    }
}
