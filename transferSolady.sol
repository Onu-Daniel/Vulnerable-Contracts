// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract TokenTransfer {
    function transferToken(address token, address to, uint256 amount) external {
        require(to != address(0), "Invalid recipient");

        // Transfer ERC20 tokens using Solmate's safeTransfer
        ERC20(token).transferFrom(msg.sender, to, amount);
    }
}
