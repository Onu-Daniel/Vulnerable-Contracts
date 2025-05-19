// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract SolmateToken is ERC20 {
    constructor() ERC20("SolmateToken", "SMT", 18) {
        _mint(msg.sender, 1_000_000 ether);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
