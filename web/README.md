# EVM Patterns Web

基于 PNPM、Vite、React、TypeScript 和 Tailwind CSS 的 Solidity 合约浏览器。
合约列表直接从仓库根目录的 `src/**/*.sol` 读取，设计说明和覆盖信息来自
`docs/`，不需要维护重复的合约源码副本。

## 开发

```powershell
pnpm install
pnpm dev
```

## 构建

```powershell
pnpm build
```

页面支持按名称搜索和主题筛选，并可查看 Solidity 源码、设计说明与测试覆盖基线。
覆盖率按报告中注明的基线展示，不代表当前代码已完成全面测试或安全审计。
