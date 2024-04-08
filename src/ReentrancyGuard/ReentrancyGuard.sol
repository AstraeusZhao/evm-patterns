// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ReentrancyGuard
/// @notice Reentrancy protection via a state lock.
/// @dev Guard pattern: set the lock before external calls, restore after.
///      Not audited.
contract ReentrancyGuard {
