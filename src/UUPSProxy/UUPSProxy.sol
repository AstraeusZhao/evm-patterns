// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title UUPSProxy
/// @notice Minimal EIP-1967 proxy with owner-only upgrades.
/// @dev Storage for the implementation lives in the EIP-1967 slot, keeping it
///      out of the implementation's storage namespace. The owner upgrade path
///      mirrors UUPS-style upgrades where the proxy itself holds no logic.
///      Not audited.
contract UUPSProxy {
    error NotOwner(address caller);
    error EmptyImplementation(address impl);

    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    address public immutable owner;

    constructor(address initialImpl) {
        owner = msg.sender;
        _setImplementation(initialImpl);
    }

    fallback() external payable {
        _delegate(_getImplementation());
    }

    /// @notice Upgrade the implementation (owner only).
    function upgradeTo(address newImpl) external {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        if (newImpl.code.length == 0) revert EmptyImplementation(newImpl);
        _setImplementation(newImpl);
