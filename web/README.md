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

页面支持按名称搜索和分类浏览。每个合约详情作为独立项目展示，编辑器目录只列出该项目的
Solidity 源码与专项测试文件，点击文件可查看内容并复制。现有测试采用 Foundry `.t.sol`；
API 也会识别 `test/<项目>/` 和 `tests/<项目>/` 下的 TypeScript 测试文件。

界面默认使用英式英语，并支持简体中文、繁体中文、德语和荷兰语。语言选择保存在本地；
源码、注释、合约摘要和设计文档展示仓库中的原文。

语言菜单支持整框点击、方向键和 Escape。源码区会根据当前屏幕高度调整；文件路径栏
滚到顶部导航下方后，页面停止继续向下滚动，目录保持固定，只滚动代码。长行自动折行，
续行不重复显示行号。
