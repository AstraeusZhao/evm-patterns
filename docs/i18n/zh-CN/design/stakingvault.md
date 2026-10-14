# StakingVault

记录本金并按时间线性计算奖励的质押金库。

## 特性

- 奖励按 `elapsed * stakedAmount * rewardRatePerSecond` 累积。
- 提取减少本金，奖励单独领取。
- CEI 顺序与重入锁保护支付路径。

## 信任假设

原设计说明描述演示环境的奖励率设置。当前源码中的设置权限及奖励注资条件须以实际代码为准。
