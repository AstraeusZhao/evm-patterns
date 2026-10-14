# TimelockController

对特权调用排队并施加最小延迟的治理时间锁，让用户在变更生效前反应。

## 功能接口

- `schedule(...)`：提议者排队调用，`minDelay` 秒后就绪。
- `execute(...)`：执行者在宽限窗口内执行就绪操作。
- `cancel(...)`：提议者取消就绪前的操作。
- `grantRole` / `revokeRole` / `updateDelay`：管理员管理角色与最小延迟，上限 30 天。

## 状态机

操作 ID 的四种状态：

- `Unset`：从未安排，或执行与取消后被删除。
- `Waiting`：`timestamp` 在未来。
- `Ready`：当前处于 `[timestamp, timestamp + GRACE_PERIOD]`。
- `Expired`：当前超过 `timestamp + GRACE_PERIOD`。

原说明以 `Unset` 描述前置依赖。实际依赖完成状态及检查以当前源码为准。

## 安全特性

- **角色分离**：提议者不能执行，执行者不能安排。
- **宽限期**：14 天后操作过期，不会永远就绪。
- **前置检查**：安排与执行路径均检查顺序依赖。

## 信任假设

- 管理员可授予角色与缩短延迟，生产中自身应受时间锁或多签约束。
- 信任执行者执行被要求的操作。
