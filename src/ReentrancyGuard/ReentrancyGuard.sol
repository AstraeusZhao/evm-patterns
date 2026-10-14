// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/ReentrancyGuard/ReentrancyGuard.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Reentrancy protection via a state lock.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title ReentrancyGuard
/// @notice Reentrancy protection via a state lock.
/// @dev Guard pattern: set the lock before external calls, restore after.
///      Not audited.
contract ReentrancyGuard {
    error Reentrancy();

    uint256 private _lock = 1;

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }
}
