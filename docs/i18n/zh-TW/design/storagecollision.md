# StorageCollision

演示代理存儲衝突反模式。

## 特性

- 代理將 `implementation` 保存在槽 0。
- `ImplValueSlot0` 也把 `value` 保存在槽 0，委託調用 `setValue` 會覆蓋代理實現地址。
- `ImplValueSlot1` 使用槽 1，不修改槽 0，展示預留固定槽或 EIP-1967 風格槽的解決方式。

## 信任假設

- 此合約演示已知陷阱，不是可用的生產代理。
