// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title Ownable
/// @notice Single-owner access control with transfer and renounce paths.
/// @dev Minimal ownership pattern used across the library. Not audited.
contract Ownable {
    error NotOwner(address caller);
    error ZeroAddress();
    error NoChange();

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public owner;

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    /// @notice Transfer ownership to a new account.
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        if (newOwner == owner) revert NoChange();
        emit OwnershipTransferred(owner, newOwner);
