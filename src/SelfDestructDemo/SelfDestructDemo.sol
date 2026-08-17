// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title SelfDestructDemo
/// @notice Demonstrates the selfdestruct pattern: a contract that can
///         destroy itself and send remaining funds to a beneficiary.
/// @dev Important: in Cancun+, selfdestruct no longer forces ETH to the
///      recipient if the recipient already has code. Use with care.
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
