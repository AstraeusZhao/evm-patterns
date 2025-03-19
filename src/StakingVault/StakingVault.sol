// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title StakingVault
/// @notice A simple staking vault with per-account accounting and linear
///         rewards accrued over time.
/// @dev Demonstrates time-based reward accounting and CEI ordering. Not audited.
contract StakingVault {
    error ZeroAmount();
    error NoStake(address account);
    error InsufficientStake(uint256 available, uint256 requested);
    error TransferFailed();
    error Reentrancy();
    error RewardRateNotSet();

    event Staked(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event RewardClaimed(address indexed account, uint256 amount);
    event RewardRateSet(uint256 ratePerSecond);

    struct StakeInfo {
        uint256 amount;
        uint256 lastUpdate;
        uint256 accumulatedReward;
    }

    mapping(address account => StakeInfo stake) public stakes;
