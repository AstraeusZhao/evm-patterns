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
        _lock = 1;
    }

    /// @notice Record any received ETH as credit for the sender.
    receive() external payable {
        if (msg.value == 0) revert ZeroAmount();
        credits[msg.sender] += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
    }

    /// @notice Withdraw part of the caller's recorded credit.
    /// @dev Balance is reduced before the transfer (CEI).
    function withdrawCredits(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        uint256 available = credits[msg.sender];
        if (amount > available) revert InsufficientCredit(available, amount);

        credits[msg.sender] = available - amount;

        emit PaymentWithdrawn(msg.sender, amount);

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }
