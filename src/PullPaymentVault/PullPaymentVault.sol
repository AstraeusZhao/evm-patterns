// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title PullPaymentVault
/// @notice A small, non-custodial credit vault for demonstrating safe value flows.
/// @dev Users withdraw their own credit. The owner can pause the vault but cannot
///      withdraw user funds.
contract PullPaymentVault {
    error InsufficientCredit(uint256 available, uint256 requested);
    error NoChange();
    error NotOwner(address caller);
    error Paused();
    error Reentrancy();
    error TransferFailed();
    error ZeroAddress();
    error ZeroAmount();

    event CreditDeposited(address indexed account, uint256 amount);
    event CreditWithdrawn(address indexed account, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PausedStateChanged(bool isPaused);

    address public owner;
    bool public paused;
    mapping(address account => uint256 credit) public credits;

    uint256 private _lock = 1;

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert Paused();
        _;
    }

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    /// @notice Add ETH credit that the sender can withdraw later.
    function deposit() external payable whenNotPaused {
        _credit(msg.sender, msg.value);
    }

    /// @notice Withdraw only the caller's previously deposited credit.
    /// @dev State is updated before the external call (CEI), and the lock
    ///      blocks a recipient contract from re-entering this function.
    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        if (amount == 0) revert ZeroAmount();

        uint256 available = credits[msg.sender];
        if (amount > available) {
            revert InsufficientCredit(available, amount);
        }

        credits[msg.sender] = available - amount;

        emit CreditWithdrawn(msg.sender, amount);

        (bool sent,) = payable(msg.sender).call{value: amount}("");
        if (!sent) revert TransferFailed();
    }

    function pause() external onlyOwner {
        if (paused) revert NoChange();
        paused = true;
        emit PausedStateChanged(true);
    }

    function unpause() external onlyOwner {
        if (!paused) revert NoChange();
