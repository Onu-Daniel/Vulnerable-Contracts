// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OverflowAssembly {
    function add(uint8 a, uint8 b) public pure returns (uint8 result) {
        assembly {
            result := add(a, b) // e.g. 250 + 10 = 260 => 4 (overflow)
        }
    }

    function sub(uint8 a, uint8 b) public pure returns (uint8 result) {
        assembly {
            result := sub(a, b) // e.g. 5 - 10 = -5 => 251 (underflow)
        }
    }

    function mul(uint8 a, uint8 b) public pure returns (uint8 result) {
        assembly {
            result := mul(a, b) // e.g. 20 * 13 = 260 => 4 (overflow)
        }
    }

    function div(uint8 a, uint8 b) public pure returns (uint8 result) {
        assembly {
            // ⚠️ No check for division by zero!
            result := div(a, b) // e.g. 5 / 0 => reverts silently
        }
    }
}
