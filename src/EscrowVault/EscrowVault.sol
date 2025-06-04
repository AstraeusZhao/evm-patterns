// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title EscrowVault
/// @notice A three-party escrow for ETH: the depositor funds the vault, the
///         agent releases funds to the beneficiary or refunds the depositor,
///         and either counterparty can raise a dispute that freezes the funds.
/// @dev Educational pattern demonstrating role separation, state transitions,
///      CEI ordering and reentrancy protection. Not audited.
contract EscrowVault {
    error NotDepositor(address caller);
    error NotBeneficiary(address caller);
    error NotAgent(address caller);
    error NotParticipant(address caller);
    error WrongState(EscrowVault.State state);
    error ZeroAddress();
    error ZeroAmount();
    error TransferFailed();
    error Reentrancy();

    enum State {
        Active,
        Disputed,
        Released,
        Refunded
    }

    event Deposited(address indexed depositor, uint256 amount);
    event Released(address indexed beneficiary, uint256 amount);
    event Refunded(address indexed depositor, uint256 amount);
    event DisputeRaised(address indexed raiser);
    event DisputeResolved(bool releaseToBeneficiary);

    address public immutable depositor;
    address public immutable beneficiary;
    address public immutable agent;

    State public state;

    uint256 private _lock = 1;

    modifier onlyDepositor() {
        if (msg.sender != depositor) revert NotDepositor(msg.sender);
        _;
    }

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert NotBeneficiary(msg.sender);
        _;
    }

    modifier onlyAgent() {
        if (msg.sender != agent) revert NotAgent(msg.sender);
        _;
    }

    modifier onlyParticipants() {
        if (msg.sender != depositor && msg.sender != beneficiary) {
            revert NotParticipant(msg.sender);
        }
        _;
    }

    modifier inState(State expected) {
        if (state != expected) revert WrongState(state);
        _;
    }

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    /// @param depositor_ Buyer who funds the escrow.
    /// @param beneficiary_ Seller who receives the funds on release.
    /// @param agent_ Trusted third party that arbitrates release and refunds.
    constructor(address depositor_, address beneficiary_, address agent_) {
        if (depositor_ == address(0) || beneficiary_ == address(0) || agent_ == address(0)) {
            revert ZeroAddress();
        }
        depositor = depositor_;
        beneficiary = beneficiary_;
        agent = agent_;
        state = State.Active;
    }
