// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title Multicall
/// @notice Batches multiple self-calls into a single transaction.
/// @dev Uses delegatecall so `msg.sender` and storage context are preserved.
///      Calls are executed in order under the value sent with the whole
///      transaction; a failure reverts the entire batch (atomic rollback).
///      A variant could collect per-call results instead. Not audited.
contract Multicall {
    error CallFailed(uint256 index);

