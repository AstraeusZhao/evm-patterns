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
        if (!isOwner[msg.sender]) revert NotOwner(msg.sender);
        _;
    }

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    /// @param initialOwners The initial set of wallet owners.
    /// @param requiredConfirmations Number of confirmations needed to execute.
    constructor(address[] memory initialOwners, uint256 requiredConfirmations) {
        if (initialOwners.length == 0) revert InvalidRequired(requiredConfirmations);
        if (requiredConfirmations == 0 || requiredConfirmations > initialOwners.length) {
            revert InvalidRequired(requiredConfirmations);
        }
        for (uint256 i = 0; i < initialOwners.length; i++) {
            _addOwner(initialOwners[i]);
        }
        required = requiredConfirmations;
        emit RequiredChanged(required);
    }

    receive() external payable {}

    /// @notice Propose a new transaction; the proposer auto-confirms it.
    /// @return txId Index of the newly submitted transaction.
    function submitTransaction(address to, uint256 value, bytes calldata data)
        external
        onlyOwner
        returns (uint256 txId)
    {
        if (to == address(0)) revert ZeroAddress();

        txId = transactions.length;
        Transaction storage t = transactions.push();
        t.to = to;
        t.value = value;
        t.data = data;
        t.confirmed[msg.sender] = true;
        t.confirmationCount = 1;

        emit TransactionSubmitted(txId, msg.sender, to, value, data);
        emit ConfirmationAdded(txId, msg.sender);
    }

    /// @notice Confirm a pending transaction.
    function confirmTransaction(uint256 txId) external onlyOwner {
        Transaction storage t = _getTransaction(txId);
        if (t.executed) revert AlreadyExecuted(txId);
        if (t.confirmed[msg.sender]) revert AlreadyConfirmed(txId);

        t.confirmed[msg.sender] = true;
        t.confirmationCount += 1;
        emit ConfirmationAdded(txId, msg.sender);
    }

    /// @notice Revoke the caller's own confirmation while the tx is pending.
    function revokeConfirmation(uint256 txId) external onlyOwner {
        Transaction storage t = _getTransaction(txId);
        if (t.executed) revert AlreadyExecuted(txId);
        if (!t.confirmed[msg.sender]) revert NotConfirmedByCaller(msg.sender, txId);

        t.confirmed[msg.sender] = false;
        t.confirmationCount -= 1;
        emit ConfirmationRevoked(txId, msg.sender);
    }

    /// @notice Execute a transaction once it has enough confirmations.
    /// @dev The executed flag is set before the external call (CEI) and the
    ///      reentrancy lock prevents a malicious callee from re-entering.
    function executeTransaction(uint256 txId) external nonReentrant onlyOwner {
        Transaction storage t = _getTransaction(txId);
        if (t.executed) revert AlreadyExecuted(txId);
        if (t.confirmationCount < required) {
            revert NotEnoughConfirmations(t.confirmationCount, required);
        }

        t.executed = true;
        emit TransactionExecuted(txId, msg.sender);

        (bool ok,) = t.to.call{value: t.value}(t.data);
        if (!ok) revert TransactionFailed(txId);
    }

    /// @notice Total number of transactions ever submitted.
    function transactionCount() external view returns (uint256) {
        return transactions.length;
    }

    /// @notice Number of confirmations collected for a transaction.
    function getConfirmationCount(uint256 txId) external view returns (uint256) {
        return _getTransaction(txId).confirmationCount;
    }

    /// @notice Whether an owner has confirmed a transaction.
