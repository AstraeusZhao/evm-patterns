// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title TimelockController
/// @notice A governance timelock that queues and delays privileged calls so
///         users can react before a change takes effect.
/// @dev Role-based access: proposers schedule and cancel, executors run calls
///      after the delay. An operation may declare a predecessor it depends on.
///      Educational pattern; not audited.
contract TimelockController {
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    error NotAdmin(address caller);
    error NotRole(bytes32 role, address caller);
    error OperationAlreadyScheduled(bytes32 id);
    error OperationNotScheduled(bytes32 id);
    error OperationNotReady(bytes32 id);
    error OperationExpired(bytes32 id);
    error PredecessorNotDone(bytes32 predecessor);
    error InvalidDelay(uint256 delay);
    error ZeroAddress();
    error CallFailed(address target);

    event CallScheduled(
