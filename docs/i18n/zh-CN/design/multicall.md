# Multicall

在一笔交易中执行多个自身调用的批处理工具。

## 特性

- 使用 `delegatecall` 保留 `msg.sender` 与存储上下文。
- 任一调用失败时整批原子回滚。

## 信任假设

- 必须信任调用目标，因为 `delegatecall` 让被调用代码使用当前合约的存储。
