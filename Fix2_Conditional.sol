// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FixedRelayerConditional
 * @dev Fixes the vulnerability by using conditional logic to only credit on success.
 */
contract FixedRelayerConditional {
    mapping(address => uint256) public balances;

    event CallFailed(address indexed target, bytes data);
    event CallSucceeded(address indexed target);

    /**
     * @notice Executes a call to a target contract and credits the sender only if successful.
     * @dev FIX 2: We capture the return value and use an if-statement to control the flow.
     * This allows the transaction to complete even if the external call fails, but ensures
     * the user is NOT credited in that case.
     * @param target The address of the contract to call.
     * @param data The calldata to send to the target.
     */
    function executeAndCredit(address target, bytes calldata data) external {
        // ------------------------------------------------------------------------
        // FIX 2 IMPLEMENTATION
        // ------------------------------------------------------------------------
        
        (bool success, ) = target.call(data);

        if (success) {
            // Only credit the user if the call succeeded
            balances[msg.sender] += 100;
            emit CallSucceeded(target);
        } else {
            // Handle the failure case (e.g., emit an event, log error)
            // The transaction does not revert, but the critical state update (balance) is skipped.
            emit CallFailed(target, data);
        }

        // ------------------------------------------------------------------------
        // END FIX
        // ------------------------------------------------------------------------
    }
}

/**
 * @title RevertingTarget
 * @dev A helper contract to demonstrate the vulnerability fix.
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
