// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title MultiSigWallet
/// @notice A multi-signature wallet that requires a threshold of owner
///         confirmations before any transaction can be executed.
/// @dev Demonstrates authorization boundaries, confirmation accounting,
///      checks-effects-interactions on execution, and owner management.
///      Educational pattern; not audited, do not custody production funds.
contract MultiSigWallet {
    error NotOwner(address caller);
    error InvalidTransactionId(uint256 txId);
    error AlreadyExecuted(uint256 txId);
    error AlreadyConfirmed(uint256 txId);
    error NotConfirmedByCaller(address caller, uint256 txId);
    error NotEnoughConfirmations(uint256 confirmations, uint256 required);
    error TransactionFailed(uint256 txId);
    error DuplicateOwner(address owner);
    error ZeroAddress();
    error InvalidRequired(uint256 required);
    error Reentrancy();

    event TransactionSubmitted(uint256 indexed txId, address indexed proposer, address to, uint256 value, bytes data);
    event ConfirmationAdded(uint256 indexed txId, address indexed owner);
    event ConfirmationRevoked(uint256 indexed txId, address indexed owner);
    event TransactionExecuted(uint256 indexed txId, address indexed executor);
    event OwnerAdded(address indexed owner);
    event OwnerRemoved(address indexed owner);
    event OwnerReplaced(address indexed oldOwner, address indexed newOwner);
    event RequiredChanged(uint256 required);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmationCount;
        mapping(address owner => bool confirmed) confirmed;
    }

    address[] public owners;
    mapping(address owner => bool isOwner) public isOwner;
    uint256 public required;

    Transaction[] public transactions;

    uint256 private _lock = 1;

    modifier onlyOwner() {
