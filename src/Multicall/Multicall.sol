// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title Multicall
/// @notice Batches multiple self-calls into a single transaction.
/// @dev Uses delegatecall so `msg.sender` and storage context are preserved.
