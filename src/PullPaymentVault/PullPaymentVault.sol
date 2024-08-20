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
