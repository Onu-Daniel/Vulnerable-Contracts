// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableSignaturePermit {
    mapping(address => uint256) public balances;
    address public owner;

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value)");

    // ❌ Hardcoded domain separator without chainId or contract address
    bytes32 public DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            keccak256("EIP712Domain(string name,string version)"),
            keccak256("VulnerableContract"),
            keccak256("1")
        )
    );

    constructor() {
        owner = msg.sender;
    }


    // ❌ No nonce, replayable
    function permit(
        address from,
        address to,
        uint256 value,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, from, to, value))
            )
        );

        address recovered = ecrecover(digest, v, r, s);
        require(recovered == from, "Invalid signature");

        // transfer balance
        require(balances[from] >= value, "Insufficient");
        balances[from] -= value;
        balances[to] += value;
    }
}
