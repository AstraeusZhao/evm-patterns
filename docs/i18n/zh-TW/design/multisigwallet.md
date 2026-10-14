# MultiSigWallet

達到所有者確認閾值後才可執行交易的多籤錢包。

## 功能接口

- `submitTransaction(to, value, data)`：所有者提出調用，並自動記錄首個確認。
- `confirmTransaction(txId)` / `revokeConfirmation(txId)`：待執行期間增加或撤銷確認。
- `executeTransaction(txId)`：達到閾值後執行，每筆交易僅可執行一次。
- `addOwner` / `removeOwner` / `replaceOwner` / `changeRequired`：管理所有者；刪除所有者時調整閾值，避免錢包失去治理能力。

## 安全特性

- **權限控制**：狀態修改操作由 `onlyOwner` 限制。
- **CEI 順序**：外部調用前設置 `executed`，重入時會看到交易已執行。
- **重入鎖**：`nonReentrant` 為執行路徑提供第二層保護。
- **閾值不變量**：移除所有者後 `required` 不大於 `owners.length`。

## 信任假設

- 閾值與所有者集合依賴所有者自身可信性，受侵害的多數可取走資金。
- 沒有日支出上限或調用目標白名單，生產錢包通常增加這些限制。

## 2025-11 更新記錄

- 原文記錄曾檢查邏輯；這不是獨立安全認證。
