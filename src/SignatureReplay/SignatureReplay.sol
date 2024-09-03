// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title SignatureReplay
/// @notice EIP-712 signed claims with a per-account nonce to prevent replay.
/// @dev Demonstrates typed-data hashing, ecrecover, deadline checks and
///      nonce monotonicity. Not audited.
contract SignatureReplay {
    error InvalidSignature();
    error SignatureExpired(uint256 deadline);
    error NotSigner(address recovered, address expected);
    error ZeroAddress();

    event Claimed(address indexed account, uint256 amount, uint256 nonce);

    /// @dev secp256k1n / 2: signatures above this bound are malleable.
    bytes32 private constant LOW_S_MAX =
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0;

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant CLAIM_TYPEHASH =
        keccak256("Claim(address account,uint256 amount,uint256 nonce,uint256 deadline)");

    mapping(address account => uint256 nonce) public nonces;
    address public immutable signer;

    constructor(address signer_) {
        if (signer_ == address(0)) revert ZeroAddress();
        signer = signer_;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("SignatureReplay"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
