// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrossFunctionReentrancy {
    mapping(address => uint256) public balances;
    mapping(address => bool) public withdrawalPending;

    bool private locked;

    modifier noReentrant() {
        require(!locked, "Reentrancy blocked");
        locked = true;
        _;
        locked = false;
    }

    function deposit() external payable noReentrant {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(!withdrawalPending[msg.sender], "Already pending");

        withdrawalPending[msg.sender] = true;

        validateWithdraw(amount, msg.sender);

        // Vulnerability: State update happens after external call
        balances[msg.sender] -= amount;
        withdrawalPending[msg.sender] = false;
    }

    function validateWithdraw(uint256 amount, address user) internal {
        (bool sent, ) = user.call{value: amount}("");
        require(sent, "Failed to send");
    }
}
