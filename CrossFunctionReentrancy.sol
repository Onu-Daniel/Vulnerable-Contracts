// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrossFunctionReentrancy {
    mapping(address => uint256) public balances;
    mapping(address => bool) public withdrawalPending;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(!withdrawalPending[msg.sender], "Already pending");

        withdrawalPending[msg.sender] = true;

        validateWithdraw(amount, msg.sender);

        // State update after external call (vulnerable)
        balances[msg.sender] -= amount;
        withdrawalPending[msg.sender] = false;
    }

    function validateWithdraw(uint256 amount, address user) internal {
        // External call using full balance, not the passed amount (intentional bug)
        (bool sent, ) = user.call{value: balances[user]}("");
        require(sent, "Failed to send");
    }
}
