// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/BatchMint/BatchMint.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Batch minting demo: mint many tokens to many recipients in a
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title BatchMint
/// @notice Batch minting demo: mint many tokens to many recipients in a
///         single transaction, saving gas vs individual mints.
/// @dev Demonstrates array-based batch operations and gas optimization.
///      Not audited.
contract BatchMint {
    error NotOwner(address caller);
    error LengthMismatch();

    event Transfer(address indexed from, address indexed to, uint256 amount);

    address public immutable owner;
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Batch mint tokens to multiple recipients.
    function batchMint(address[] calldata recipients, uint256[] calldata amounts) external {
        require(msg.sender == owner, "not owner");
        if (recipients.length != amounts.length) revert LengthMismatch();

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "zero recipient");
            balances[recipients[i]] += amounts[i];
            totalSupply += amounts[i];
            emit Transfer(address(0), recipients[i], amounts[i]);
        }
    }

    /// @notice Batch transfer tokens from the caller to multiple recipients.
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        if (recipients.length != amounts.length) revert LengthMismatch();

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "zero recipient");
            uint256 amount = amounts[i];
            require(balances[msg.sender] >= amount, "insufficient balance");
            balances[msg.sender] -= amount;
            balances[recipients[i]] += amount;
            emit Transfer(msg.sender, recipients[i], amount);
        }
    }
}
