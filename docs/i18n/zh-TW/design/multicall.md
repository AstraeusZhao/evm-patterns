# Multicall

在一筆交易中執行多個自身調用的批處理工具。

## 特性

- 使用 `delegatecall` 保留 `msg.sender` 與存儲上下文。
- 任一調用失敗時整批原子回滾。

## 信任假設

- 必須信任調用目標，因為 `delegatecall` 讓被調用代碼使用當前合約的存儲。
