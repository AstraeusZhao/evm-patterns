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
