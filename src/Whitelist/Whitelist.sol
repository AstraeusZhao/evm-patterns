// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title Whitelist
/// @notice Owner-managed allowlist used to gate participation.
/// @dev Used together with a sale contract that only lets listed accounts buy.
///      Not audited.
contract Whitelist {
    error NotOwner(address caller);
    error ZeroAddress();
    error AlreadyWhitelisted(address account);
    error NotWhitelisted(address account);

    event Whitelisted(address indexed account);
    event WhitelistRemoved(address indexed account);

    address public owner;
    mapping(address account => bool listed) public whitelisted;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    modifier onlyWhitelisted() {
        if (!whitelisted[msg.sender]) revert NotWhitelisted(msg.sender);
        _;
    }
