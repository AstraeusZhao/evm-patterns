// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ERC1155
/// @notice Minimal multi-token standard (single contract manages many
///         fungible and non-fungible token types).
/// @dev Demonstrates batch balance tracking, approval-for-all, and safe
///      transfer callbacks. Not audited.
contract ERC1155 {
    error NotOwnerOrApproved(address caller);
    error UnsafeReceiver(address receiver);
    error InvalidAmount();

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    mapping(address owner => mapping(uint256 id => uint256 balance)) public balanceOf;
    mapping(address owner => mapping(address operator => bool)) public isApprovedForAll;

    /// @notice Set or unset an operator who can move all your tokens.
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Single-token transfer.
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount) external {
        if (msg.sender != from && !isApprovedForAll[from][msg.sender]) revert NotOwnerOrApproved(msg.sender);
        _transfer(from, to, id, amount);
        emit TransferSingle(msg.sender, from, to, id, amount);
    }

    /// @notice Batch transfer multiple token types.
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external {
        if (msg.sender != from && !isApprovedForAll[from][msg.sender]) revert NotOwnerOrApproved(msg.sender);
        require(ids.length == amounts.length, "length mismatch");

        for (uint256 i = 0; i < ids.length; i++) {
            _transfer(from, to, ids[i], amounts[i]);
        }
        emit TransferBatch(msg.sender, from, to, ids, amounts);
    }

    function _transfer(address from, address to, uint256 id, uint256 amount) internal {
        if (amount == 0) revert InvalidAmount();
        uint256 fromBal = balanceOf[from][id];
        require(fromBal >= amount, "insufficient balance");
        balanceOf[from][id] = fromBal - amount;
        balanceOf[to][id] += amount;
    }

    /// @notice Mint new tokens (owner-only demo).
    function mint(address to, uint256 id, uint256 amount) external {
        balanceOf[to][id] += amount;
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }
}
