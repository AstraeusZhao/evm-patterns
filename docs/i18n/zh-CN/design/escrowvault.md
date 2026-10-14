# EscrowVault

三方 ETH 托管：存款人注资，代理人向受益人放款或向存款人退款，交易双方均可发起争议冻结资金。

## 角色

- **存款人**：向托管注资，可提出争议。
- **受益人**：接受放款，可提出争议。
- **代理人**：受信任的第三方，负责放款、退款和解决争议。

## 状态机

```
Active --release()--> Released
Active --refund()--> Refunded
Active --raiseDispute()--> Disputed --resolveDispute(bool)--> Released / Refunded
```

每次状态修改均由 `inState` 保护，仅允许上述转换。

## 安全特性

- **角色分离**：只有指定参与者可执行各项操作。
- **CEI 顺序**：ETH 转账前先修改状态。
- **重入锁**：支付路径使用 `nonReentrant`。
- **避免强制入金陷阱**：`receive()` 回滚；记账余额仅包含存款人显式存入金额，`release` 与 `refund` 转移对应托管金额。

## 信任假设

- 完全信任代理人：在 `Active` 状态可随时放款或退款，并决定争议结果。生产托管通常使用多签或仲裁市场替代单个代理人。
