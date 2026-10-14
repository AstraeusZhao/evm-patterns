# StorageCollision

演示代理存储冲突反模式。

## 特性

- 代理将 `implementation` 保存在槽 0。
- `ImplValueSlot0` 也把 `value` 保存在槽 0，委托调用 `setValue` 会覆盖代理实现地址。
- `ImplValueSlot1` 使用槽 1，不修改槽 0，展示预留固定槽或 EIP-1967 风格槽的解决方式。

## 信任假设

- 此合约演示已知陷阱，不是可用的生产代理。
