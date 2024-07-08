// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title FactoryClone
/// @notice Deploys cheap EIP-1167 minimal proxy clones of an implementation.
/// @dev Each clone is a 45-byte runtime deployed by CREATE2 with a per-salt
///      address; the factory keeps the implementation immutable. Not audited.
contract FactoryClone {
    error ZeroAddress();
    error DuplicateDeployment(bytes32 salt);

    event CloneDeployed(address indexed clone, bytes32 indexed salt);

    address public immutable implementation;

    constructor(address implementation_) {
        if (implementation_ == address(0)) revert ZeroAddress();
        implementation = implementation_;
    }

    /// @notice Deploy a clone; the salt makes the resulting address
    ///         deterministic via CREATE2.
    function deploy(bytes32 salt) external returns (address clone) {
        bytes20 implBytes = bytes20(implementation);
