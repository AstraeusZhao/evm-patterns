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
    error Reentrancy();

    event PaymentReceived(address indexed account, uint256 amount);
    event PaymentWithdrawn(address indexed account, uint256 amount);

    mapping(address account => uint256 credit) public credits;

    uint256 private _lock = 1;

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
