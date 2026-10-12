# Audit remediation record

Original audit: 2026-10-12. This record maps the original finding IDs to changes in the new maintenance baseline. Historical facts retain their provenance limitations; code changes do not retrospectively authenticate old dates or commit titles.

## Repository policy

The maintained branch uses the `Verify` CI check. Branch policy requires PRs, zero additional approvals for the single maintainer, resolved conversations and a current passing CI check, and rejects force pushes/deletion. Remote enforcement and exact new commit/CI IDs are verified after the audit push and recorded in the delivered cross-repository report. Security scan language scope is in `docs/SECURITY_SCAN_SCOPE.md`.

## GIT-001 — 六个默认分支均无保护规则或仓库 ruleset

Original evidence: GitHub branches API 对六个默认分支返回 protected=false；rulesets API 均返回空数组。分支保护 API 的 404 与这两个成功响应交叉印证。

Changes: Remote branch rules described above are enabled after the successful audit CI run.

Source references: workflow/configuration and history documents.

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## GIT-002 — 远端没有验证项目代码的自定义 CI 工作流

Original evidence: 六个默认分支均没有已跟踪的 .github/workflows 文件。DolphinPort Actions 中的动态 Dependabot Updates 不构成 Flutter/Rust/Android 构建验证；其余仓库 workflows 列表为空。DolphinPort 本地有被忽略的工作流，详见 DP-GIT-002。

Changes: 六仓库提交固定action SHA/Node/npm/pnpm/Go/Rust/Flutter/Foundry版本的可运行CI; CI包含构建、安全回归、官方依赖审计和Android APK原生payload检查

Source references: workflow/configuration and history documents.

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## GIT-003 — 安全告警 API 存在权限或功能缺口，不能以“无告警”判定安全

Original evidence: 六个仓库 Dependabot alerts 查询均失败，响应包含功能未启用和权限要求；多个 code-scanning/secret-scanning 查询返回 403/404。evm-patterns、MiniEVM 的 secret-scanning 查询成功且返回空列表，code-scanning 返回 no analysis found。逐接口状态在各项目远端表中完整列出。

Changes: 使用各仓库实际owner凭据消除安全告警读取权限缺口，启用Dependabot/secret scanning/push protection; 提交固定SHA CodeQL Actions/JS/Go/Rust扫描，明确Solidity/Dart不在CodeQL覆盖范围，区分404未配置与200无告警

Source references: workflow/configuration and history documents.

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DEP-ENV-001 — 默认 npm 镜像不支持本次 audit 接口

Original evidence: 初次 npm audit 使用本机 registry.npmmirror.com，返回 404 Not Found / NOT_IMPLEMENTED。切换官方 registry.npmjs.org 后得到实际漏洞结果。该配置属于本机环境，不是六个项目均写入了此设置。

Changes: npm用户默认registry改官方npmjs，六仓库提交.npmrc并由CI显式审计; 移除冲突用户级GOROOT，默认go1.25.12与机器GOROOT一致；服务CI和本地验证显式使用Go1.26.5

Source references: workflow/configuration and history documents.

Validation: 默认go version/ go env GOROOT一致; npm config get registry=https://registry.npmjs.org/

## ENV-GO-001 — 默认 Go 可执行文件与 GOROOT 不匹配

Original evidence: 默认 go 是 1.25.12，但本机 GOROOT 指向 1.26.5，导致标准库 compile: version mismatch。改用 1.25.12 的目录后又出现标准库源码缺失。使用 C:\Dev\Go\1.26.5\bin\go.exe 并匹配 GOROOT 后，HerbTable API 和 UI captcha 后端 go vet 成功，HerbTable captcha 的未使用 import 被明确检出。

Changes: npm用户默认registry改官方npmjs，六仓库提交.npmrc并由CI显式审计; 移除冲突用户级GOROOT，默认go1.25.12与机器GOROOT一致；服务CI和本地验证显式使用Go1.26.5

Source references: workflow/configuration and history documents.

Validation: 默认go version/ go env GOROOT一致; npm config get registry=https://registry.npmjs.org/

## EVM-GIT-001 — 89 个修复/测试类提交只改变注释或空白

Original evidence: 完整审阅 186 个可达提交的 numstat 后得到 90 个极小变更候选；逐个 diff 分类确认其中 89 个只增删注释或空白。例 039c30d7f19efc8fc6433c49f2ac36f7c1e97fa6 标题称修复奖励差一个区块，实际只增加空行和 // fix reward calc。

Changes: 逐仓库提交历史可信边界/维护与发布基线文档，不改写或美化旧时间戳; Dolphin master唯一维护分支、旧main只读与新tag来源检查；EVM悬空commit建立本地保留ref; 疑点原因仍未知，不伪造迁移说明；未来开发事实以修复commit/CI/产物校验为据

Source references: workflow/configuration and history documents.

Validation: original Git object/metadata evidence is preserved; see HISTORY_PROVENANCE.md.

## EVM-GIT-002 — 四个提交时间晚于审计快照，父子时间倒退约八个月

Original evidence: 881606b、c1c1d72、ddcebe2、8f43b86 的 committer time 为 2026-10-12 09:22–14:22 UTC，晚于采集的 2026-10-11 22:56 UTC。3815b14 的日期为 2026-02-14，其 parent 881606b 为 2026-10-12。

Changes: 逐仓库提交历史可信边界/维护与发布基线文档，不改写或美化旧时间戳; Dolphin master唯一维护分支、旧main只读与新tag来源检查；EVM悬空commit建立本地保留ref; 疑点原因仍未知，不伪造迁移说明；未来开发事实以修复commit/CI/产物校验为据

Source references: workflow/configuration and history documents.

Validation: original Git object/metadata evidence is preserved; see HISTORY_PROVENANCE.md.

## EVM-GIT-003 — 本地对象库保留十个不在当前 ref 中的提交

Original evidence: fsck --full --unreachable --no-reflogs 和递归 Git log 找到十个唯一不可达提交；普通 fsck 的 dangling tip 只有三个，不能将 tip 数误当完整历史数。

Changes: 逐仓库提交历史可信边界/维护与发布基线文档，不改写或美化旧时间戳; Dolphin master唯一维护分支、旧main只读与新tag来源检查；EVM悬空commit建立本地保留ref; 疑点原因仍未知，不伪造迁移说明；未来开发事实以修复commit/CI/产物校验为据

Source references: workflow/configuration and history documents.

Validation: original Git object/metadata evidence is preserved; see HISTORY_PROVENANCE.md.

## EVM-001 — NFT 买入清空 storage 引用后把卖家款转给零地址

Original evidence: buy 使用 Listing storage l，计算金额后 delete listings[nft][tokenId]；随后 l.price 和 l.seller 均已变成零。事件价格为 0，sellerAmount 发给 address(0)。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/NFTMarketplace/NFTMarketplace.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-002 — NFT 市场没有交付 NFT，也没有核验挂牌权限

Original evidence: list 允许任意调用者覆盖任意 nft/tokenId 的卖家；整个合约没有 ownerOf、授权检查或 ERC721 transfer/safeTransfer 调用。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/NFTMarketplace/NFTMarketplace.sol`, `src/NFTMarketplace/NFTMarketplace.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-003 — 市场 feeBps 不设上限且超额 ETH 被留在合约

Original evidence: constructor 未要求 feeBps<=10000；buy 只要求 msg.value>=price，却只分配 price，没有找零和剩余余额提取路径。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/NFTMarketplace/NFTMarketplace.sol`, `src/NFTMarketplace/NFTMarketplace.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-004 — 单个 owner 可以把多签门槛改成 1 并控制 owner 集合

Original evidence: addOwner、removeOwner、changeRequired 仅要求 onlyOwner，无需通过钱包多签交易执行。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/MultiSigWallet/MultiSigWallet.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-005 — 初始 owners 允许零地址，移除 owner 遍历全部历史交易

Original evidence: constructor 的 _addOwner 没有外部 addOwner 的零地址保护；_removeOwner 对 transactions.length 全量清除确认。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/MultiSigWallet/MultiSigWallet.sol`, `src/MultiSigWallet/MultiSigWallet.sol`, `src/MultiSigWallet/MultiSigWallet.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-006 — FlashLoanReceiver 回调允许任意调用者取得 token allowance

Original evidence: executeOperation 不校验 msg.sender 为受信 lender/Pool，也不绑定 initiator；它给 msg.sender approve(amount+fee)。合约定义的 UntrustedLender 没有用于保护该调用。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/FlashLoanReceiver/FlashLoanReceiver.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-007 — 闪电贷示例的回调不符合 ERC-3156，救援忽略 token 返回 false

Original evidence: 使用 executeOperation(...)->bool 形式，而 ERC-3156 是 onFlashLoan 并返回规定的 bytes32；rescueToken 只判断底层 call 是否 revert，没有判断 ERC20 bool 返回值。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/FlashLoanReceiver/FlashLoanReceiver.sol`, `src/FlashLoanReceiver/FlashLoanReceiver.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-008 — 质押奖励没有定点缩放，并可消耗其他人的本金

Original evidence: 奖励直接计算 elapsed*stake*rewardRate，没有比例分母；奖励与本金从同一 ETH 余额支出，没有单独的已注资奖励上限或本金准备金保护。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/StakingVault/StakingVault.sol`, `src/StakingVault/StakingVault.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-009 — 重复退出再质押造成 _accounts 重复增长

Original evidence: stake 在用户 stake 为 0 时将地址追加 _accounts，退出清零但没有删除或去重；修改奖励率调用更新所有账户的循环。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/StakingVault/StakingVault.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-010 — EnglishAuction 推送退还上一 bidder，拒收 ETH 可阻塞后续竞拍

Original evidence: 新 bid 中直接调用上一最高出价者并 require/revert 于转账失败。CEI 能降低重入风险，但不解决收款方拒收带来的可用性问题。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/EnglishAuction/EnglishAuction.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-011 — Timelock 把从未安排和已取消前序都视为“已完成”

Original evidence: OperationState 没有 Done；执行和取消都 delete。_checkPredecessor 只在 schedule 调用，并接受所有 Unset，包括从未创建的 id。execute 没有再检查 predecessor。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/TimelockController/TimelockController.sol`, `src/TimelockController/TimelockController.sol`, `src/TimelockController/TimelockController.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-012 — Timelock admin 可直接把未来操作延迟降低到零

Original evidence: updateDelay onlyAdmin，允许 newDelay=0；初始 admin 同时具有 proposer/executor 角色。延迟修改没有经过 timelock 自身。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/TimelockController/TimelockController.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-013 — safeTransferFrom 没有接收者回调

Original evidence: safeTransferFrom 直接调用 transferFrom，没有 onERC721Received 检查，也缺少四参数重载和 ERC165 支持。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/ERC721NFT/ERC721NFT.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-014 — ERC1155 示例缺少接收回调，mint 注释称 owner only 但无权限检查

Original evidence: safeTransferFrom 没有标准 data 参数和 onERC1155Received/batchReceived 回调；mint 标注 owner-only，却允许任意调用者。接口还缺 balanceOfBatch、URI/ERC165 等标准部分，_transfer拒绝标准应允许的零值，且未禁止零地址接收者。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/ERC1155/ERC1155.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-015 — permit 和 EIP712 示例接受恢复结果为零地址的无效签名

Original evidence: ecrecover 失败返回 address(0)，当前只比较 recovered==owner/from，未先禁止 owner/from 为零地址。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/ERC20Permit/ERC20Permit.sol`, `src/EIP712/EIP712.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-016 — GovernanceToken 把票数截断为 uint224

Original evidence: 余额/委托票以 uint256 表示，但 checkpoint 写入时直接强转 uint224；公开演示 mint 可以产生超过该范围的票数。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/GovernanceToken/GovernanceToken.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-017 — SafeTransfer 接受无代码地址的空成功响应

Original evidence: 底层 call 成功且 returndata 为空时直接接受，没有检查目标 token 地址存在代码。对 EOA 调用也会返回 success、空 returndata。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/SafeERC20Wrapper/SafeERC20Wrapper.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-018 — VestingWallet 只检查底层 call 成功，忽略 transfer 返回 false

Original evidence: 释放时先推进 released，再调用 transfer；代币返回 false 但不 revert 时，ok 仍为 true。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/VestingWallet/VestingWallet.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-019 — FactoryClone 只禁止零地址 implementation，没有核验代码

Original evidence: constructor 仅检查 implementation!=address(0)；EOA 作为目标同样能生成最小代理，后续 delegatecall 会空成功。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/FactoryClone/FactoryClone.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-020 — SimpleProxy 初始 implementation 不检查代码

Original evidence: 构造函数仅检查初始地址非零，而 upgradeTo 对新地址检查 code.length。初始部署与升级的校验规则不一致。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/UUPSProxy/UUPSProxy.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-021 — BondingCurve 小额购买可能支付 ETH 但铸造零 token

Original evidence: 用整数 sqrt 计算 newSupply 后取 mint=newSupply-totalSupply，没有最小 mint/minOut。供给较大且 deposit 很小时，sqrt 舍入保持原 supply。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/BondingCurve/BondingCurve.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-022 — FrontRunning 的全局 commit 可被首次调用者永久占用

Original evidence: 使用单一全局 committedHash 和 committedSender；成功reveal后会清空，但不揭示时没有超时、撤销或过期重新开放机制。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/FrontRunning/FrontRunning.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-023 — SelfDestruct 注释错误描述 Cancun 后的行为

Original evidence: 注释把 Cancun 后是否转移余额与目标是否为 EOA 混在一起。EIP-6780 仍会将余额转给目标；通常保留合约代码/存储，仅同一交易创建并销毁时保留旧的删除语义。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/SelfDestructDemo/SelfDestructDemo.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-024 — Royalty 的 supportsInterface 没有报告 ERC165 接口

Original evidence: 只返回 ERC2981 interface id，不返回 ERC165 自身 0x01ffc9a7。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/Royalty/Royalty.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-025 — 41 个 Solidity 源文件只有 23 个对应测试文件夹，文档仍宣称更广覆盖

Original evidence: 当前 src 含 41 个源文件，而 test 只有 23 个模式文件夹；新增的一批模式没有相应测试。foundry.toml 还全局排除多种 lint，排除理由不能替代逐合约安全论证。

Changes: 增加审计安全回归suite；README移除笼统全覆盖承诺，提交全部源文件的实测覆盖率与映射限制

Source references: `README.md`, `foundry.toml`

Validation: forge test:132通过; forge coverage --report summary:exit0，总行覆盖76.58%，分支30.57%（含test helper）

## EVM-026 — AMM 仅修改虚拟储备，却允许接收 ETH 且没有取回路径

Original evidence: addLiquidity 为 payable，但 msg.value 与 amountA/amountB 无关；swap 无 token transfer/transferFrom，也没有LP份额、removeLiquidity或ETH取回函数。任意调用者可无资产增加reserve。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/AMM/AMM.sol`, `src/AMM/AMM.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-027 — PriceOracle 没有显式区分“未发布”与价格为零的 feed

Original evidence: 未设置feed默认为price=0、updatedAt=0，getPrice只比较staleness；timestamp<=24小时的私链/测试环境可返回(0,0)，主网当前时间则会按陈旧价格拒绝。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/PriceOracle/PriceOracle.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-028 — BatchMint 可写入零地址且 batchTransfer 注释与权限不符

Original evidence: batchMint和batchTransfer没有禁止零地址；batchTransfer注释称“from the owner”，实际任何持币msg.sender均可批量转出自己的余额。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/BatchMint/BatchMint.sol`, `src/BatchMint/BatchMint.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-029 — 自称标准兼容的ERC20拒绝零值转账

Original evidence: _transfer在value==0时revert ZeroAmount。ERC20要求零值transfer/transferFrom按普通转账处理并产生Transfer事件；mint/burn的零值策略则是另一个问题。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/ERC20Token/ERC20Token.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## EVM-030 — Multicall可接收ETH但当前合约没有使用或提取路径

Original evidence: 唯一公开方法multicall为payable，允许calls为空或递归调用自身，合约没有deposit、业务结算、refund或withdraw。delegatecall还让每个子调用共享整笔msg.value。

Changes: 资金、NFT交付、多签self-call/epoch、ERC3156回调、已注资惰性质押奖励; 竞拍pull退款、timelock Done与延迟self-call、标准接收回调/签名/票数边界; token返回校验、合约代码验证、曲线输出、每人commit/reveal、零值ERC20及纯模拟资金限制

Source references: `src/Multicall/Multicall.sol`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.
