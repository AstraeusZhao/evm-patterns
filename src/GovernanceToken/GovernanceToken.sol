// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/GovernanceToken/GovernanceToken.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: An ERC20-like token with checkpointed voting power: holders can
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title GovernanceToken
/// @notice An ERC20-like token with checkpointed voting power: holders can
///         delegate their votes to themselves or a representative.
/// @dev Demonstrates the Checkpoint pattern used in Compound Governor Bravo
///      and OpenZeppelin Votes. Not audited.
contract GovernanceToken {
    error DelegationFailed();
    error ZeroAddress();

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address account => uint256 balance) public balanceOf;
    mapping(address delegator => address delegate) public delegates;

    struct Checkpoint {
        uint32 fromTime;
        uint224 votes;
    }

    mapping(address account => Checkpoint[] votesHistory) public votesHistory;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    /// @notice Delegate your voting power to another address.
    function delegate(address delegatee) external {
        if (delegatee == address(0)) revert ZeroAddress();
        address currentDelegate = delegates[msg.sender];
        delegates[msg.sender] = delegatee;

        uint256 delegatedAmount = balanceOf[msg.sender];
        _moveVotingPower(currentDelegate, delegatee, delegatedAmount);

        emit DelegateChanged(msg.sender, currentDelegate, delegatee);
    }

    /// @notice Get the current voting power of an account.
    function getVotes(address account) external view returns (uint256) {
        Checkpoint[] storage hist = votesHistory[account];
        if (hist.length == 0) return 0;
        return hist[hist.length - 1].votes;
    }

    /// @notice Mint new tokens (demo only).
    function mint(address to, uint256 amount) external {
        if (to == address(0)) revert ZeroAddress();
        require(amount <= type(uint224).max - totalSupply, "supply overflow");
        balanceOf[to] += amount;
        totalSupply += amount;
        address delegatee = delegates[to];
        if (delegatee != address(0)) {
            _moveVotingPower(address(0), delegatee, amount);
        }
        emit Transfer(address(0), to, amount);
    }

    function _moveVotingPower(address src, address dst, uint256 amount) internal {
        if (src != address(0)) {
            uint256 oldVotes = _getCurrentVotes(src);
            _writeCheckpoint(src, oldVotes - amount);
        }
        if (dst != address(0)) {
            uint256 oldVotes = _getCurrentVotes(dst);
            _writeCheckpoint(dst, oldVotes + amount);
        }
    }

    function _getCurrentVotes(address account) internal view returns (uint256) {
        Checkpoint[] storage hist = votesHistory[account];
        if (hist.length == 0) return 0;
        return hist[hist.length - 1].votes;
    }

    function _writeCheckpoint(address account, uint256 newVotes) internal {
        require(newVotes <= type(uint224).max && block.timestamp <= type(uint32).max, "checkpoint overflow");
        votesHistory[account].push(Checkpoint(uint32(block.timestamp), uint224(newVotes)));
    }
}
