// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title Pausable
/// @notice Owner-controlled pause switch for emergency stops.
/// @dev Works as an operational stop, not a recovery mechanism. Not audited.
contract Pausable {
    error NotOwner(address caller);
    error Paused();
    error NotPaused();

    event PausedStateChanged(bool isPaused);

    address public immutable owner;
    bool public paused;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert Paused();
        _;
    }

    modifier whenPaused() {
        if (!paused) revert NotPaused();
        _;
    }

