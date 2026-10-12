# History provenance and verifiable maintenance baseline

Audit baseline before remediation: `d40b8c73865a4f06ab75d780d50c86dc497b31f7`. Audit date: 2026-10-12. Maintained branch: `main`.

Git author/committer dates are user-controlled metadata. They do not independently establish when a project was written or first published. Original commits, tags and parent relationships are preserved. The cause of the discrepancies below is unknown; this document does not invent a migration explanation or attribute intent.

## EVM-GIT-001 — 89 个修复/测试类提交只改变注释或空白

完整审阅 186 个可达提交的 numstat 后得到 90 个极小变更候选；逐个 diff 分类确认其中 89 个只增删注释或空白。例 039c30d7f19efc8fc6433c49f2ac36f7c1e97fa6 标题称修复奖励差一个区块，实际只增加空行和 // fix reward calc。

Disposition: current-source errors are fixed in the new audit commit; earlier history is kept as evidence. Dates and titles in these commits must not be quoted as verified development/release events. Future releases identify their exact source commit, tested toolchain and CI run.

## EVM-GIT-002 — 四个提交时间晚于审计快照，父子时间倒退约八个月

881606b、c1c1d72、ddcebe2、8f43b86 的 committer time 为 2026-10-12 09:22–14:22 UTC，晚于采集的 2026-10-11 22:56 UTC。3815b14 的日期为 2026-02-14，其 parent 881606b 为 2026-10-12。

Disposition: current-source errors are fixed in the new audit commit; earlier history is kept as evidence. Dates and titles in these commits must not be quoted as verified development/release events. Future releases identify their exact source commit, tested toolchain and CI run.

## EVM-GIT-003 — 本地对象库保留十个不在当前 ref 中的提交

fsck --full --unreachable --no-reflogs 和递归 Git log 找到十个唯一不可达提交；普通 fsck 的 dangling tip 只有三个，不能将 tip 数误当完整历史数。

Disposition: current-source errors are fixed in the new audit commit; earlier history is kept as evidence. Dates and titles in these commits must not be quoted as verified development/release events. Future releases identify their exact source commit, tested toolchain and CI run.

## Preserved local objects

Unreferenced commits from the audit were attached to `refs/audit-preserved/<sha>` locally, avoiding accidental garbage collection. They are not substituted into the maintained branch or published as a fabricated old release.

- `da634036608b3124232fe7bb93d6aded17ab57b1`
- `fec5d0bae38ca25bea21378d5ff1480340171984`
- `7a669cc6215f49352f6de946877e8a2e076d8abf`
- `a518ad3e2bf0fa1e192bc85083875f32595c9945`
- `d658129fdee9b887710f18cb05301d8406ab7646`
- `02ebdbfd6be54dc692b01d02a2c4e643c643daaa`
- `1dab8335e76ee69bd88ed10f930b3ecb544ec7fc`
- `a90b2a68c97f5ee6e48f0ea1efee4e488d9974f0`
- `087cef39326b89615b308d59a33fa32d3b3db51e`
- `34bcc88dae2a83801052e1a7e5e2b32f1934519a`
