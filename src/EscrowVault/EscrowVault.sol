// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title EscrowVault
/// @notice A three-party escrow for ETH: the depositor funds the vault, the
///         agent releases funds to the beneficiary or refunds the depositor,
///         and either counterparty can raise a dispute that freezes the funds.
/// @dev Educational pattern demonstrating role separation, state transitions,
///      CEI ordering and reentrancy protection. Not audited.
contract EscrowVault {
    error NotDepositor(address caller);
    error NotBeneficiary(address caller);
    error NotAgent(address caller);
    error NotParticipant(address caller);
    error WrongState(EscrowVault.State state);
    error ZeroAddress();
    error ZeroAmount();
