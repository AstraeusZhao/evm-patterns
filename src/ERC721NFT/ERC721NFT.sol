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
        if (msg.sender != owner && !_operatorApprovals[owner][msg.sender]) {
            revert ApprovalCallerNotOwnerOrApproved(msg.sender, tokenId);
        }
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        _requireExists(tokenId);
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        if (operator == address(0)) revert ZeroAddress();
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        _checkTransfer(from, to, tokenId);
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        _checkTransfer(from, to, tokenId);
        _transfer(from, to, tokenId);
    }

    /// @notice Mint a token to an account; owner-only.
    function mint(address to, uint256 tokenId) external onlyMinter {
        if (to == address(0)) revert ZeroAddress();
        if (_owners[tokenId] != address(0)) revert AlreadyMinted(tokenId);
        _mint(to, tokenId);
    }

    function _requireExists(uint256 tokenId) internal view {
        if (_owners[tokenId] == address(0)) revert TokenDoesNotExist(tokenId);
    }

    function _checkTransfer(address from, address to, uint256 tokenId) internal view {
        if (to == address(0)) revert ZeroAddress();
        address owner = ownerOf(tokenId);
        if (from != owner) revert NotOwnerOrApproved(msg.sender, tokenId);
        if (msg.sender != owner && _tokenApprovals[tokenId] != msg.sender && !_operatorApprovals[owner][msg.sender]) {
            revert NotOwnerOrApproved(msg.sender, tokenId);
        }
    }

    function _mint(address to, uint256 tokenId) internal {
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }
}
