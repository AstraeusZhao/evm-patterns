# EscrowVault

三方 ETH 託管：存款人注資，代理人向受益人放款或向存款人退款，交易雙方均可發起爭議凍結資金。

## 角色

- **存款人**：向託管注資，可提出爭議。
- **受益人**：接受放款，可提出爭議。
- **代理人**：受信任的第三方，負責放款、退款和解決爭議。

## 狀態機

```
Active --release()--> Released
Active --refund()--> Refunded
Active --raiseDispute()--> Disputed --resolveDispute(bool)--> Released / Refunded
```

每次狀態修改均由 `inState` 保護，僅允許上述轉換。

## 安全特性

- **角色分離**：只有指定參與者可執行各項操作。
- **CEI 順序**：ETH 轉賬前先修改狀態。
- **重入鎖**：支付路徑使用 `nonReentrant`。
- **避免強制入金陷阱**：`receive()` 回滾；記賬餘額僅包含存款人顯式存入金額，`release` 與 `refund` 轉移對應託管金額。

## 信任假設

- 完全信任代理人：在 `Active` 狀態可隨時放款或退款，並決定爭議結果。生產託管通常使用多籤或仲裁市場替代單個代理人。
