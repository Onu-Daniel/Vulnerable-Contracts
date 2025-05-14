// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableSignaturePermit {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public nonces;

    address public owner;

    bytes32 public constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    // ⚠️ Still vulnerable to cross-chain replay (hardcoded domain)
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

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function permit(
        address from,
        address to,
        uint256 value,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        require(block.timestamp <= deadline, "Expired signature");

        uint256 nonce = nonces[from];

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    PERMIT_TYPEHASH,
                    from,
                    to,
                    value,
                    nonce,
                    deadline
                ))
            )
        );

        address recovered = ecrecover(digest, v, r, s);
        require(recovered == from, "Invalid signature");

        nonces[from]++;

        require(balances[from] >= value, "Insufficient");
        balances[from] -= value;
        balances[to] += value;
    }
}
