// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title EIP712
/// @notice A minimal EIP-712 typed-data signing demo: users sign an off-chain
///         message authorizing a transfer, and anyone can submit it on-chain.
/// @dev Demonstrates domain separators, type hashes, and ecrecover recovery.
///      Not audited.
contract EIP712 {
    error InvalidSignature();
    error ExpiredDeadline();
    error AlreadyUsed();
    error TransferFailed();

    struct Transfer {
        address to;
        uint256 amount;
        uint256 nonce;
        uint256 deadline;
    }

    bytes32 public constant TRANSFER_TYPEHASH =
        keccak256("Transfer(address to,uint256 amount,uint256 nonce,uint256 deadline)");

    bytes32 public immutable DOMAIN_SEPARATOR;

    mapping(address signer => mapping(uint256 nonce => bool used)) public usedNonces;

    event Executed(address indexed signer, address indexed to, uint256 amount);

    constructor(string memory name, string memory version) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            )
        );
    }

    /// @notice Execute a signed transfer.
    function executeTransfer(
        address signer,
        Transfer calldata transfer,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > transfer.deadline) revert ExpiredDeadline();
        if (usedNonces[signer][transfer.nonce]) revert AlreadyUsed();

        bytes32 structHash = keccak256(abi.encode(
            TRANSFER_TYPEHASH,
            transfer.to,
            transfer.amount,
            transfer.nonce,
            transfer.deadline
        ));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));

        if (signer == address(0) || (v != 27 && v != 28) || uint256(s) > 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0) revert InvalidSignature();
        address recovered = ecrecover(digest, v, r, s);
        if (recovered == address(0) || recovered != signer) revert InvalidSignature();

        usedNonces[signer][transfer.nonce] = true;
        emit Executed(signer, transfer.to, transfer.amount);

        // In a real contract, this would transfer tokens. Here we just emit.
    }
}
