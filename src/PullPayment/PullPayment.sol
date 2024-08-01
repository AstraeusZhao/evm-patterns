// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title PullPayment
/// @notice A payment pattern that credits senders on receipt and lets them
///         withdraw later ("pull" instead of "push").
/// @dev Avoids forcing funds on recipients and keeps CEI ordering simple.
///      Not audited.
contract PullPayment {
    error ZeroAmount();
    error InsufficientCredit(uint256 available, uint256 requested);
    error TransferFailed();
