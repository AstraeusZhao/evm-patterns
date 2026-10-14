# TimelockController

對特權調用排隊並施加最小延遲的治理時間鎖，讓用戶在變更生效前反應。

## 功能接口

- `schedule(...)`：提議者排隊調用，`minDelay` 秒後就緒。
- `execute(...)`：執行者在寬限窗口內執行就緒操作。
- `cancel(...)`：提議者取消就緒前的操作。
- `grantRole` / `revokeRole` / `updateDelay`：管理員管理角色與最小延遲，上限 30 天。

## 狀態機

操作 ID 的四種狀態：

- `Unset`：從未安排，或執行與取消後被刪除。
- `Waiting`：`timestamp` 在未來。
- `Ready`：當前處於 `[timestamp, timestamp + GRACE_PERIOD]`。
- `Expired`：當前超過 `timestamp + GRACE_PERIOD`。

原說明以 `Unset` 描述前置依賴。實際依賴完成狀態及檢查以當前源碼為準。

## 安全特性

- **角色分離**：提議者不能執行，執行者不能安排。
- **寬限期**：14 天后操作過期，不會永遠就緒。
- **前置檢查**：安排與執行路徑均檢查順序依賴。

## 信任假設

- 管理員可授予角色與縮短延遲，生產中自身應受時間鎖或多簽約束。
- 信任執行者執行被要求的操作。
