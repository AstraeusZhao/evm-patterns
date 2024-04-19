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

    function addToWhitelist(address account) external onlyOwner {
        if (account == address(0)) revert ZeroAddress();
        if (whitelisted[account]) revert AlreadyWhitelisted(account);
        whitelisted[account] = true;
        emit Whitelisted(account);
    }

    function removeFromWhitelist(address account) external onlyOwner {
        if (!whitelisted[account]) revert NotWhitelisted(account);
        whitelisted[account] = false;
        emit WhitelistRemoved(account);
    }
}

/// @notice A tiny sale that accepts ETH only from whitelisted accounts.
contract WhitelistSale {
    error NotOwner(address caller);
    error SaleClosed();
    error AlreadyPurchased();
    error NoFunds();
    error TransferFailed();

    event Purchased(address indexed buyer, uint256 amount);
    event ProceedsWithdrawn(address indexed owner, uint256 amount);

    address public owner;
    Whitelist public whitelist;
    bool public closed;
    mapping(address buyer => bool purchased) public purchased;

    constructor(Whitelist whitelist_) {
        owner = msg.sender;
