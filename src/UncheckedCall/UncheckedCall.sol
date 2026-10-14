// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/UncheckedCall/UncheckedCall.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Demonstrates why unchecked low-level calls are dangerous:
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title UncheckedCall
/// @notice Demonstrates why unchecked low-level calls are dangerous:
///         if a call fails, the contract continues executing as if it
///         succeeded, leading to inconsistent state.
/// @dev Educational anti-pattern. Always check the return value of calls.
contract UncheckedCall {
    error TransferFailed();

    mapping(address => uint256) public balances;

    /// @notice Withdraw funds — UNCHECKED call (vulnerable).
    /// @dev If the transfer fails, the balance is still decremented,
    ///      effectively burning the user's funds.
    function withdrawUnchecked(uint256 amount) external {
        balances[msg.sender] -= amount;
        payable(msg.sender).call{value: amount}("");
        // No check on whether the call succeeded!
    }

    /// @notice Withdraw funds — CHECKED call (safe).
    function withdrawChecked(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}
