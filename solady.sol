// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "solady/tokens/ERC20.sol"; // import Solady ERC20

contract SoladyTransfer {
    function transferToken(address token, address to, uint256 amount) external {
        require(to != address(0), "Invalid recipient");

        // Transfer tokens from sender to recipient
        ERC20(token).transferFrom(msg.sender, to, amount);
    }
}
