// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal ERC20 Interface for interaction
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract VulnerableDeposit {
    // Mapping to store user balances
    mapping(address => uint256) public balances;

    // VULNERABILITY: This function allows depositing tokens but ignores the return value.
    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        // DANGER: We call transferFrom but DO NOT check the return boolean.
        // If the token contract returns 'false' (e.g., insufficient allowance),
        // this line silently fails, but execution continues.
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // The contract assumes the transfer succeeded and credits the user.
        // An attacker can get free balance!
        balances[msg.sender] += amount;
    }
}

// A "Fake" Token to demonstrate the exploit in Remix
contract FakeToken {
    // This function mimics an ERC20 transferFrom but always returns FALSE (failure)
    // instead of reverting.
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false; // Simulate failure (e.g., no allowance)
    }
}
