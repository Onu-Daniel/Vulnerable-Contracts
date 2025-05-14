// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UnsafeCast {
    uint256 public bigNumber = 300;

    function unsafeDowncast() public view returns (uint8) {
        uint8 smallNumber = uint8(bigNumber); // ❌ Unsafe cast
        return smallNumber;
    }
}
