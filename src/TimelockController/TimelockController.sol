// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title TimelockController
/// @notice A governance timelock that queues and delays privileged calls so
///         users can react before a change takes effect.
/// @dev Role-based access: proposers schedule and cancel, executors run calls
///      after the delay. An operation may declare a predecessor it depends on.
///      Educational pattern; not audited.
contract TimelockController {
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    error NotAdmin(address caller);
    error NotRole(bytes32 role, address caller);
    error OperationAlreadyScheduled(bytes32 id);
    error OperationNotScheduled(bytes32 id);
    error OperationNotReady(bytes32 id);
    error OperationExpired(bytes32 id);
    error PredecessorNotDone(bytes32 predecessor);
    error InvalidDelay(uint256 delay);
    error ZeroAddress();
    error CallFailed(address target);

    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);
    event CallCancelled(bytes32 indexed id);
    event MinDelayChange(uint256 oldDelay, uint256 newDelay);
    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

    enum OperationState {
        Unset,
        Waiting,
        Ready,
        Expired
    }

    struct Operation {
        bool scheduled;
        uint256 timestamp;
    }

    /// @notice Grace period after which a scheduled operation expires.
    uint256 public constant GRACE_PERIOD = 14 days;

    mapping(bytes32 role => mapping(address account => bool granted)) public roles;
    mapping(bytes32 id => Operation) public operations;

    address public admin;
    uint256 public minDelay;

    /// @param initialMinDelay Minimum delay enforced on every schedule.
    /// @param initialProposers Accounts allowed to schedule and cancel.
    /// @param initialExecutors Accounts allowed to execute ready operations.
    /// @param initialAdmin Account that manages roles and the delay.
    constructor(
        uint256 initialMinDelay,
        address[] memory initialProposers,
        address[] memory initialExecutors,
        address initialAdmin
    ) {
        if (initialAdmin == address(0)) revert ZeroAddress();

        admin = initialAdmin;
        minDelay = initialMinDelay;

        _grantRole(PROPOSER_ROLE, initialAdmin);
        _grantRole(EXECUTOR_ROLE, initialAdmin);

        for (uint256 i = 0; i < initialProposers.length; i++) {
            _grantRole(PROPOSER_ROLE, initialProposers[i]);
        }
        for (uint256 i = 0; i < initialExecutors.length; i++) {
            _grantRole(EXECUTOR_ROLE, initialExecutors[i]);
        }
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin(msg.sender);
        _;
    }

    modifier onlyRole(bytes32 role) {
        if (!roles[role][msg.sender]) revert NotRole(role, msg.sender);
        _;
    }

    /// @notice Queue a call for execution after the configured delay.
    /// @param predecessor id of a previous operation that must be done, or 0.
    function schedule(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt)
        external
        onlyRole(PROPOSER_ROLE)
    {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, target, value, data, predecessor, minDelay);
    }

    /// @notice Execute a previously scheduled operation once its delay elapsed.
    /// @dev Reverts if the operation is missing, not ready, or beyond grace.
    function execute(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt)
        external
        onlyRole(EXECUTOR_ROLE)
    {
        if (target == address(0)) revert ZeroAddress();

        bytes32 id = hashOperation(target, value, data, predecessor, salt);

        OperationState state = getOperationState(id);
        if (state == OperationState.Unset) revert OperationNotScheduled(id);
        if (state == OperationState.Waiting) revert OperationNotReady(id);
        if (state == OperationState.Expired) revert OperationExpired(id);

        delete operations[id];

        emit CallExecuted(id, 0, target, value, data);

        (bool ok,) = target.call{value: value}(data);
        if (!ok) revert CallFailed(target);
    }

    /// @notice Cancel a scheduled operation before it becomes ready.
    function cancel(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt)
        external
        onlyRole(PROPOSER_ROLE)
    {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        if (!operations[id].scheduled) revert OperationNotScheduled(id);

        delete operations[id];
        emit CallCancelled(id);
    }

    // --- Views ---

    function hashOperation(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    function getOperationState(bytes32 id) public view returns (OperationState) {
        Operation storage op = operations[id];
        if (!op.scheduled) {
            return OperationState.Unset;
        }
        if (op.timestamp > block.timestamp) {
            return OperationState.Waiting;
        }
        if (block.timestamp > op.timestamp + GRACE_PERIOD) {
            return OperationState.Expired;
        }
        return OperationState.Ready;
    }

    function isOperationPending(bytes32 id) external view returns (bool) {
        OperationState s = getOperationState(id);
        return s == OperationState.Waiting || s == OperationState.Ready;
    }

    function isOperationReady(bytes32 id) external view returns (bool) {
        return getOperationState(id) == OperationState.Ready;
    }

    // --- Admin ---
