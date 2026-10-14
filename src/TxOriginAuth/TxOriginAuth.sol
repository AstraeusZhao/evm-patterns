// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/TxOriginAuth/TxOriginAuth.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Demonstrates why tx.origin authentication is dangerous:
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title TxOriginAuth
/// @notice Demonstrates why tx.origin authentication is dangerous:
///         if the owner approves a phishing contract, that contract can
///         call this contract and impersonate the owner.
/// @dev Educational anti-pattern. Always use msg.sender for authentication.
contract TxOriginAuth {
    error NotOwner(address caller);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Withdraw all funds — uses tx.origin (INSECURE).
    /// @dev A phishing contract approved by the owner can call this and
    ///      drain the contract, because tx.origin will be the owner's EOA.
    function withdraw() external {
        if (tx.origin != owner) revert NotOwner(tx.origin);
        (bool ok,) = payable(owner).call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
