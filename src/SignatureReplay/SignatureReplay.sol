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

