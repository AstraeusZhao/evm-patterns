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

    /// @dev Accounts with a non-zero stake; lets reward-rate changes settle
    ///      every account before the new rate applies.
    address[] private _accounts;

    /// @notice Reward paid per staked token per second.
    uint256 public rewardRatePerSecond;

    uint256 private _lock = 1;

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    /// @notice Configure the per-second reward rate (owner-less demo: any caller).
    /// @dev Settles accrued rewards for every staker at the old rate first, so a
    ///      rate change never rewrites historical reward accrual.
    function setRewardRate(uint256 ratePerSecond) external {
        if (ratePerSecond == 0) revert RewardRateNotSet();
        _updateAll();
        rewardRatePerSecond = ratePerSecond;
        emit RewardRateSet(ratePerSecond);
    }

    function stake() external payable nonReentrant {
        if (msg.value == 0) revert ZeroAmount();
        _update(msg.sender);

        if (stakes[msg.sender].amount == 0) {
            _accounts.push(msg.sender);
        }
        stakes[msg.sender].amount += msg.value;
        stakes[msg.sender].lastUpdate = block.timestamp;

        emit Staked(msg.sender, msg.value);
    }

    /// @notice Withdraw part of the staked principal; accrued rewards stay.
    function unstake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        _update(msg.sender);

        StakeInfo storage s = stakes[msg.sender];
        if (s.amount < amount) revert InsufficientStake(s.amount, amount);

        s.amount -= amount;
        s.lastUpdate = block.timestamp;

        emit Withdrawn(msg.sender, amount);

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    /// @notice Claim accrued rewards without reducing the stake.
    function claimRewards() external nonReentrant {
        _update(msg.sender);

        StakeInfo storage s = stakes[msg.sender];
        uint256 reward = s.accumulatedReward;
        if (reward == 0) revert ZeroAmount();

        s.accumulatedReward = 0;
        s.lastUpdate = block.timestamp;

