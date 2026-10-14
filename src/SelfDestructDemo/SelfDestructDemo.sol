// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/SelfDestructDemo/SelfDestructDemo.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Demonstrates the selfdestruct pattern: a contract that can
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title SelfDestructDemo
/// @notice Demonstrates the selfdestruct pattern: a contract that can
///         destroy itself and send remaining funds to a beneficiary.
/// @dev EIP-6780 (Cancun): ETH still transfers, including to contract recipients.
///      Code/storage are deleted only when destruction occurs in the creation transaction.
///      https://eips.ethereum.org/EIPS/eip-6780
///      Not audited.
contract SelfDestructDemo {
    error NotOwner(address caller);

    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Destroy the contract and send funds to the caller.
    function destroy() external {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        selfdestruct(payable(owner));
    }

    receive() external payable {}
}
