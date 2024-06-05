// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title FactoryClone
/// @notice Deploys cheap EIP-1167 minimal proxy clones of an implementation.
/// @dev Each clone is a 45-byte runtime deployed by CREATE2 with a per-salt
