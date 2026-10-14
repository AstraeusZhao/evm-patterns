# MultiSigWallet

达到所有者确认阈值后才可执行交易的多签钱包。

## 功能接口

- `submitTransaction(to, value, data)`：所有者提出调用，并自动记录首个确认。
- `confirmTransaction(txId)` / `revokeConfirmation(txId)`：待执行期间增加或撤销确认。
- `executeTransaction(txId)`：达到阈值后执行，每笔交易仅可执行一次。
- `addOwner` / `removeOwner` / `replaceOwner` / `changeRequired`：管理所有者；删除所有者时调整阈值，避免钱包失去治理能力。

## 安全特性

- **权限控制**：状态修改操作由 `onlyOwner` 限制。
- **CEI 顺序**：外部调用前设置 `executed`，重入时会看到交易已执行。
- **重入锁**：`nonReentrant` 为执行路径提供第二层保护。
- **阈值不变量**：移除所有者后 `required` 不大于 `owners.length`。

## 信任假设

- 阈值与所有者集合依赖所有者自身可信性，受侵害的多数可取走资金。
- 没有日支出上限或调用目标白名单，生产钱包通常增加这些限制。

## 2025-11 更新记录

- 原文记录曾检查逻辑；这不是独立安全认证。
