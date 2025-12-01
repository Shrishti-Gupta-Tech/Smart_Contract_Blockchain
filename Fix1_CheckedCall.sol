// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SecureDepositChecked {
    mapping(address => uint256) public balances;

    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        // FIX: Explicitly capture the return value 'success'.
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        // FIX: Revert the transaction if the transfer failed.
        require(success, "Token transfer failed");

        // State is only updated if the line above succeeded.
        balances[msg.sender] += amount;
    }
}
