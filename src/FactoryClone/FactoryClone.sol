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
