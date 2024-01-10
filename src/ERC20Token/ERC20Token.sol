// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ERC20Token
/// @notice A minimal standards-compliant ERC20 with owner-only minting.
/// @dev Demonstrates allowance accounting and transfer invariants. Not audited.
contract ERC20Token {
    error NotOwner(address caller);
    error ZeroAddress();
    error InsufficientBalance(uint256 available, uint256 requested);
