# EVM Patterns Web

基于 PNPM、Vite、React、TypeScript、Tailwind CSS 和 Rust 的 Solidity 合约浏览器。
Rust API 会在请求时扫描仓库中的 Solidity 源码、测试、设计说明和覆盖报告，并读取
Git 分支、提交和工作区状态。前端不需要手工登记新合约。

## 开发

```powershell
pnpm install
pnpm dev
```

开发环境需要安装 Rust stable。`pnpm dev` 会同时启动 Rust API 和 Vite，默认地址为
`http://127.0.0.1:3001` 和 `http://127.0.0.1:5173`。

## 构建

```powershell
pnpm build
```

构建后的前端由 Vite 生成到 `dist/`。单独预览时需要在两个终端分别启动：

终端一：

```powershell
cargo run --manifest-path backend/Cargo.toml
```

终端二：

```powershell
pnpm preview
```

页面支持按名称搜索和 14 个分类浏览。每个合约详情作为独立项目展示，目录树只展示当前
项目对应的 `src/<项目>/`、`test/<项目>/`、`script/<项目>/`，支持任意深度的子目录。
API 启动时补齐这三个目录，并为其中空目录写入 `.gitkeep`。界面隐藏 `.gitkeep`、隐藏文件、
`lib`、`out`、`cache` 和 `broadcast`，展开空目录显示本地化的“暂无文件”。目录存在不代表
有测试或部署记录；源码文件不会被移动，也不会生成测试或部署脚本。

开发框架由用户显式选择，偏好按项目保存。Foundry 显示 Solidity 测试，Hardhat 和 Truffle
显示 TypeScript / JavaScript 测试，Ape 显示 Python 测试。文件 API 同样按所选框架和
当前项目限制访问。源码、测试与脚本支持按扩展名高亮 Solidity、TypeScript、JavaScript、
Python、JSON、TOML、Shell 和 Markdown。

界面默认使用英式英语，并支持简体中文、繁体中文、德语和荷兰语。语言选择保存在本地；
源码和注释展示仓库原文；合约摘要和设计正文随语言切换。摘要翻译位于
`src/data/localisedSummaries.json`，设计翻译位于仓库 `docs/i18n/<语言>/design/`。
新项目未提供翻译时显示原文；新增设计文档应同步补齐四种译文。

语言菜单支持整框点击、方向键和 Escape。源码区会根据当前屏幕高度调整；文件路径栏
滚到顶部导航下方后，页面停止继续向下滚动，目录保持固定，只滚动代码。长行自动折行，
续行不重复显示行号。设计说明与简介使用相同宽度和随视口调整的高度，内容在面板内滚动。

后端验证：`cargo test --manifest-path backend/Cargo.toml`。覆盖目录递归、空目录占位、
框架文件过滤、辅助源码归属与跨项目文件隔离。
