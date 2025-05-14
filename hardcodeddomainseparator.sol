// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableSignaturePermit {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public nonces; // ✅ Add nonce mapping

    address public owner;

    bytes32 public constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce)"
    );

    // ❌ Still missing chainId and contract address — replayable across chains
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
        uint8 v, bytes32 r, bytes32 s
    ) external {
        uint256 nonce = nonces[from]; // ✅ Get current nonce

        // ✅ Include nonce in message hash
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    PERMIT_TYPEHASH,
                    from,
                    to,
                    value,
                    nonce
                ))
            )
        );

        address recovered = ecrecover(digest, v, r, s);
        require(recovered == from, "Invalid signature");

        nonces[from]++; // ✅ Increment nonce to prevent replay

        // Transfer funds
        require(balances[from] >= value, "Insufficient");
        balances[from] -= value;
        balances[to] += value;
    }
}
