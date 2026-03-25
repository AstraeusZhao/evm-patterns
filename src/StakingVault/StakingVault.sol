// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title StakingVault
/// @notice A simple staking vault with per-account accounting and linear
///         rewards accrued over time.
/// @dev Demonstrates time-based reward accounting and CEI ordering.
///      Educational: reward-rate changes settle all stakers up front,
///      which is fine for small staker counts but would hit block gas
///      limits at scale. Not audited.
contract StakingVault {
    error ZeroAmount();
    error NotOwner(address caller);
    error InsufficientStake(uint256 available, uint256 requested);
    error TransferFailed();
    error Reentrancy();
    error ZeroRate();

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

    address public immutable owner;

    uint256 private _lock = 1;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Configure the per-second reward rate (owner only).
    /// @dev Settles accrued rewards for every staker at the old rate first.
    ///      Note: this loops over all stakers, so it works for small sets
    ///      but would exceed block gas limits at scale. For a production
    ///      system, use the reward-per-token snapshot pattern instead.
    function setRewardRate(uint256 ratePerSecond) external onlyOwner {
        if (ratePerSecond == 0) revert ZeroRate();
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

        emit RewardClaimed(msg.sender, reward);

        (bool ok,) = payable(msg.sender).call{value: reward}("");
        if (!ok) revert TransferFailed();
    }

    /// @notice Total staked amount for an account.
    function stakedOf(address account) external view returns (uint256) {
        return stakes[account].amount;
    }

    function _update(address account) internal {
        StakeInfo storage s = stakes[account];
        if (s.amount > 0 && rewardRatePerSecond > 0) {
            uint256 elapsed = block.timestamp - s.lastUpdate;
            s.accumulatedReward += elapsed * s.amount * rewardRatePerSecond;
        }
        s.lastUpdate = block.timestamp;
    }

    /// @notice Settle accrued rewards for every account with a stake.
    function _updateAll() internal {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _update(_accounts[i]);
        }
    }
}
