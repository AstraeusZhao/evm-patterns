// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ERC721NFT
/// @notice A minimal non-fungible token with owner-only minting.
/// @dev Demonstrates ownership accounting, approvals and transfers. Not audited.
contract ERC721NFT {
    error NotOwner(address caller);
    error ZeroAddress();
    error TokenDoesNotExist(uint256 tokenId);
    error NotOwnerOrApproved(address caller, uint256 tokenId);
    error ApprovalCallerNotOwnerOrApproved(address caller, uint256 tokenId);
    error AlreadyMinted(uint256 tokenId);
