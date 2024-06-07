// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title SignatureReplay
/// @notice EIP-712 signed claims with a per-account nonce to prevent replay.
/// @dev Demonstrates typed-data hashing, ecrecover, deadline checks and
///      nonce monotonicity. Not audited.
contract SignatureReplay {
    error InvalidSignature();
