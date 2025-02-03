// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title MerkleAirdrop
/// @notice Gas-efficient token airdrop verified with Merkle proofs.
/// @dev Claimants prove inclusion with a Merkle proof; each leaf binds an
///      account to an amount, and claims are tracked to prevent double-spend.
///      Not audited.
contract MerkleAirdrop {
    error NotOwner(address caller);
    error InvalidProof(address claimant);
    error AlreadyClaimed(address claimant);
    error ZeroAmount();
    error TransferFailed();

    event Claimed(address indexed claimant, uint256 amount);

