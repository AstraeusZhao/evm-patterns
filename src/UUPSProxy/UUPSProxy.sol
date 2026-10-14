// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/UUPSProxy/UUPSProxy.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Minimal EIP-1967 proxy with owner-only upgrades.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title SimpleProxy
/// @notice Minimal EIP-1967 proxy with owner-only upgrades.
/// @dev This is a simplified transparent-style proxy: the owner upgrade
///      path lives on the proxy itself. True UUPS puts the upgrade logic
///      in the implementation (via delegatecall); this demo shows the
///      simpler pattern where the proxy owns its upgrades.
///      Not audited.
contract SimpleProxy {
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
    }

    function _setImplementation(address impl) internal {
        if (impl.code.length == 0) revert EmptyImplementation(impl);
        assembly {
            sstore(IMPLEMENTATION_SLOT, impl)
        }
    }

    function _getImplementation() internal view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
