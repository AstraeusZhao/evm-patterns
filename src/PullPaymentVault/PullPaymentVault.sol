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
