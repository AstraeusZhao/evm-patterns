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

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    string public name;
    string public symbol;

    mapping(uint256 tokenId => address owner) private _owners;
    mapping(address account => uint256 balance) private _balances;
    mapping(uint256 tokenId => address approved) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool approved)) private _operatorApprovals;

    address public minter;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        minter = msg.sender;
    }

    modifier onlyMinter() {
        if (msg.sender != minter) revert NotOwner(msg.sender);
        _;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) revert TokenDoesNotExist(tokenId);
        return owner;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (account == address(0)) revert ZeroAddress();
        return _balances[account];
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ApprovalCallerNotOwnerOrApproved(msg.sender, tokenId);
