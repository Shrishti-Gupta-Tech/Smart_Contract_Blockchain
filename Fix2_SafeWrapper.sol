// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SecureDepositSafeWrapper {
    mapping(address => uint256) public balances;

    // Helper function to safely transfer tokens
    // This mimics OpenZeppelin's SafeERC20.safeTransferFrom
    function _safeTransferFrom(address token, address from, address to, uint256 value) private {
        // We use a low-level call to handle tokens that might not return a bool
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value)
        );

        // Check 1: The call itself must succeed (no revert in target)
        // Check 2: If data is returned, it must decode to 'true'
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeTransfer: transfer failed"
        );
    }

    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        // FIX: Use the safe wrapper instead of calling directly.
        // This ensures verification of the transfer success.
        _safeTransferFrom(token, msg.sender, address(this), amount);

        balances[msg.sender] += amount;
    }
}
