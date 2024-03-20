// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ERC20Token
/// @notice A minimal standards-compliant ERC20 with owner-only minting.
/// @dev Demonstrates allowance accounting and transfer invariants. Not audited.
contract ERC20Token {
    error NotOwner(address caller);
    error ZeroAddress();
    error InsufficientBalance(uint256 available, uint256 requested);
    error InsufficientAllowance(uint256 available, uint256 requested);
    error ZeroAmount();

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address account => uint256 balance) public balanceOf;
    mapping(address owner => mapping(address spender => uint256 allowance)) public allowance;

    address public owner;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        if (spender == address(0)) revert ZeroAddress();
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed < value) revert InsufficientAllowance(allowed, value);
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - value;
        }
        _transfer(from, to, value);
        return true;
    }

    /// @notice Owner-only minting, used for demonstrations and tests.
    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
