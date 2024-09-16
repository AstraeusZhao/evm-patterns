// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title StorageCollision
/// @notice Demonstrates the classic proxy storage-collision pitfall: when a
///         proxy stores its implementation address at slot 0 and an
///         implementation also uses slot 0 for a variable, delegatecall
///         overwrites the proxy's own storage.
/// @dev Educational demo of an anti-pattern; do not copy.
contract StorageCollisionProxy {
    error NotOwner(address caller);

    address public implementation;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    function setImplementation(address impl) external onlyOwner {
        implementation = impl;
    }

    fallback() external payable {
        _delegate(implementation);
    }

    receive() external payable {
        _delegate(implementation);
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
