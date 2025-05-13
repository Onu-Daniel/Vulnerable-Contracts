// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IValidator {
    function validateWithdraw(uint256 amount, address user) external;
}

contract Vault {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    IValidator public validator;

    mapping(address => uint256) public balances;
    mapping(address => bool) public withdrawalPending;

    bool private locked;

    modifier noReentrant() {
        require(!locked, "Reentrancy blocked");
        locked = true;
        _;
        locked = false;
    }

    constructor(IERC20 _token, IValidator _validator) {
        token = _token;
        validator = _validator;
    }

    function deposit(uint256 amount) external noReentrant {
        token.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(!withdrawalPending[msg.sender], "Already pending");

        withdrawalPending[msg.sender] = true;

        // External call to another contract (cross-contract)
        validator.validateWithdraw(amount, msg.sender);

        // Vulnerable: State update after external call
        balances[msg.sender] -= amount;
        withdrawalPending[msg.sender] = false;
    }
}
