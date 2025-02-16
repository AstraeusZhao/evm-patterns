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

    bytes32 public immutable merkleRoot;
    IERC20Like public immutable token;
    address public owner;
    mapping(address claimant => bool claimed) public claimed;

    constructor(bytes32 merkleRoot_, IERC20Like token_) {
        merkleRoot = merkleRoot_;
        token = token_;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    /// @notice Claim the allocated amount by presenting a Merkle proof.
    /// @param amount Amount this account is entitled to.
    /// @param proof Sibling hashes proving inclusion of (account, amount).
    function claim(uint256 amount, bytes32[] calldata proof) external {
        if (claimed[msg.sender]) revert AlreadyClaimed(msg.sender);
        if (amount == 0) revert ZeroAmount();

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
        if (!_verifyProof(proof, leaf)) revert InvalidProof(msg.sender);

        claimed[msg.sender] = true;

        emit Claimed(msg.sender, amount);

        bool ok = token.transfer(msg.sender, amount);
        if (!ok) revert TransferFailed();
    }

    /// @notice Owner can sweep any tokens left after the airdrop.
    function sweep(IERC20Like recipientToken, address to) external onlyOwner {
        uint256 balance = recipientToken.balanceOf(address(this));
        if (balance == 0) revert ZeroAmount();
        bool ok = recipientToken.transfer(to, balance);
        if (!ok) revert TransferFailed();
    }

    function _verifyProof(bytes32[] calldata proof, bytes32 leaf) internal view returns (bool) {
        bytes32 hash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 sibling = proof[i];
            hash = hash < sibling
                ? keccak256(abi.encodePacked(hash, sibling))
                : keccak256(abi.encodePacked(sibling, hash));
        }
