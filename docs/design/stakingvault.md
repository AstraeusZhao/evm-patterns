# StakingVault

A staking vault with principal accounting and time-linear rewards.

## Properties

- Rewards accrue as `elapsed * stakedAmount * rewardRatePerSecond`.
- Withdrawals reduce principal only; rewards are claimed separately.
- CEI ordering plus a reentrancy lock protect the payout paths.

## Trust assumptions

- The demo allows anyone to set the reward rate; production contracts should
  gate this behind governance.
