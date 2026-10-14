# StakingVault

記錄本金並按時間線性計算獎勵的質押金庫。

## 特性

- 獎勵按 `elapsed * stakedAmount * rewardRatePerSecond` 累積。
- 提取減少本金，獎勵單獨領取。
- CEI 順序與重入鎖保護支付路徑。

## 信任假設

原設計說明描述演示環境的獎勵率設置。當前源碼中的設置權限及獎勵注資條件須以實際代碼為準。
