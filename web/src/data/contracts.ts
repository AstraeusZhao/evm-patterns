export type ContractGroup = 'core' | 'token' | 'defi' | 'governance' | 'security'

export type ContractExample = {
  id: string
  name: string
  family: string
  path: string
  loadSource: () => Promise<string>
  summary: string
  compiler: string
  group: ContractGroup
  tags: string[]
  lineCoverage: number | null
  dedicatedTests: string[]
  designPath: string | null
  loadDesignNote: (() => Promise<string>) | null
}

export const groups: { id: ContractGroup | 'all'; label: string }[] = [
  { id: 'all', label: '全部示例' },
  { id: 'core', label: '基础模式' },
  { id: 'token', label: '代币与 NFT' },
  { id: 'defi', label: 'DeFi 与市场' },
  { id: 'governance', label: '治理与权限' },
  { id: 'security', label: '安全示例' },
]

const groupByFamily: Record<string, ContractGroup> = {
  AMM: 'defi',
  BatchMint: 'token',
  BlockTimestamp: 'security',
  BondingCurve: 'defi',
  Counter: 'core',
  Crowdfunding: 'core',
  DutchAuction: 'defi',
  EIP712: 'security',
  ERC1155: 'token',
  ERC20Permit: 'token',
  ERC20Token: 'token',
  ERC721NFT: 'token',
  EnglishAuction: 'defi',
  EscrowVault: 'core',
  FactoryClone: 'core',
  FlashLoanReceiver: 'defi',
  FrontRunning: 'security',
  GovernanceToken: 'governance',
  MerkleAirdrop: 'token',
  MultiSigWallet: 'governance',
  Multicall: 'core',
  NFTMarketplace: 'defi',
  Ownable: 'governance',
  Pausable: 'governance',
  PriceOracle: 'defi',
  PullPayment: 'core',
  PullPaymentVault: 'core',
  Randomness: 'security',
  ReentrancyGuard: 'security',
  Royalty: 'token',
  SafeERC20Wrapper: 'token',
  SelfDestructDemo: 'security',
  SignatureReplay: 'security',
  StakingVault: 'defi',
  StorageCollision: 'security',
  TimelockController: 'governance',
  TxOriginAuth: 'security',
  UUPSProxy: 'core',
  UncheckedCall: 'security',
  VestingWallet: 'token',
  Whitelist: 'governance',
}

const summaries: Record<string, string> = {
  AMM: '恒定乘积做市公式演示；储备为虚拟数值，不托管或结算代币。',
  BatchMint: '展示面向多个接收者的批量铸造与转账操作。',
  BlockTimestamp: '演示区块时间戳的可操纵范围及其使用边界。',
  BondingCurve: '按二次曲线定价的代币发行与买卖示例。',
  Counter: '用最小状态变量展示读取、递增、递减和事件。',
  Crowdfunding: '展示活动期限、众筹状态和按需退款流程。',
  DutchAuction: '价格随时间下降，由首位接受当前价格的买家成交。',
  EIP712: '展示 EIP-712 域分隔、结构化数据哈希和签名恢复。',
  ERC1155: '多代币余额、批量转移和接收者检查示例。',
  ERC20Permit: '用 EIP-2612 签名授权代替单独的链上 approve。',
  ERC20Token: '展示 ERC-20 余额、授权、转账和受限铸造。',
  ERC721NFT: '展示 NFT 所有权、授权和安全转移。',
  EnglishAuction: '递增出价拍卖与独立提取的退款。',
  EscrowVault: '三方 ETH 托管、状态迁移和争议处理。',
  FactoryClone: '用 CREATE2 部署 EIP-1167 最小代理。',
  FlashLoanReceiver: '面向单一配置出借方的 ERC-3156 风格接收者。',
  FrontRunning: '将提交与揭示绑定到发送者和链的防抢跑示例。',
  GovernanceToken: '用检查点记录委托后的当前投票权变化。',
  MerkleAirdrop: '验证 Merkle 证明并阻止同一地址重复领取。',
  MultiSigWallet: '多签门槛、交易确认和受权执行流程。',
  Multicall: '在同一存储上下文中执行原子化 delegatecall 批处理。',
  NFTMarketplace: '固定价格 NFT 挂单、交付和付款拆分。',
  Ownable: '单一所有者授权、转移与放弃流程。',
  Pausable: '由所有者控制的紧急暂停开关。',
  PriceOracle: '带更新时间与过期检查的管理员报价源。',
  PullPayment: '先记账再由收款人主动提取付款。',
  PullPaymentVault: '用户 ETH 额度、暂停开关和重入防护。',
  Randomness: '说明为什么区块属性不适合生成有价值的随机数。',
  ReentrancyGuard: '状态锁防重入，并配有恶意回调演示。',
  Royalty: '实现 EIP-2981 版税查询和 ERC-165 接口声明。',
  SafeERC20Wrapper: '兼容缺少返回值或返回 false 的 ERC-20 代币。',
  SelfDestructDemo: '展示 Cancun / EIP-6780 后 selfdestruct 的行为变化。',
  SignatureReplay: '使用 EIP-712、nonce、期限和 ECDSA 检查防止重放。',
  StakingVault: 'ETH 质押与按时间累积、由余额支持的奖励。',
  StorageCollision: '演示代理存储冲突，并对比固定槽位写法。',
  TimelockController: '提案者、执行者和延迟操作状态机。',
  TxOriginAuth: '演示用 tx.origin 做身份校验的钓鱼风险。',
  UUPSProxy: 'EIP-1967 代理槽位和所有者升级流程演示。',
  UncheckedCall: '演示低级 call 失败后未检查返回值的风险。',
  VestingWallet: '按线性计划计算 ERC-20 已归属数量并向受益人释放。',
  Whitelist: '所有者维护的白名单与受限 ETH 销售。',
}

const sourceModules = import.meta.glob<string>('../../../src/**/*.sol', {
  query: '?raw',
  import: 'default',
})

const designModules = import.meta.glob<string>('../../../docs/design/*.md', {
  query: '?raw',
  import: 'default',
})

const testPaths = Object.keys(import.meta.glob('../../../test/**/*.t.sol'))
const coverageReport = Object.values(
  import.meta.glob<string>('../../../docs/reports/AUDIT_COVERAGE.md', {
    eager: true,
    query: '?raw',
    import: 'default',
  }),
)[0] ?? ''

const normalize = (value: string) => value.toLowerCase().replace(/[^a-z0-9]/g, '')
const repoRelative = (path: string) => path.replace(/^(?:\.\.\/)+/, '')

export function extractNotice(source: string) {
  const lines = source.split(/\r?\n/)
  const start = lines.findIndex((line) => line.includes('@notice'))
  if (start < 0) return ''

  const noticeLine = lines[start].split('@notice')[1]?.trim() ?? ''
  const parts = noticeLine ? [noticeLine] : []

  for (let index = start + 1; index < lines.length; index += 1) {
    const match = lines[index].match(/^\s*\/\/\/\s?(.*)$/)
    if (!match || match[1].trim().startsWith('@')) break
    if (match[1].trim()) parts.push(match[1].trim())
  }

  return parts.join(' ').replace(/\s+/g, ' ')
}

const coverageByFamily = new Map<string, number>()
const coverageRow = /^\|\s*src\/([^/]+)\/[^|]+\|\s*([\d.]+)%/gm
for (const match of coverageReport.matchAll(coverageRow)) {
  coverageByFamily.set(match[1], Number(match[2]))
}

function makeTags(family: string, summary: string, group: ContractGroup) {
  const candidates: [string, RegExp][] = [
    ['ERC-20', /ERC20|ERC-20/i],
    ['ERC-721', /ERC721|ERC-721/i],
    ['ERC-1155', /ERC1155|ERC-1155/i],
    ['签名', /EIP-712|EIP712|签名|signature/i],
    ['代理', /\bproxy\b|代理|implementation/i],
    ['重入', /reentrancy|重入/i],
    ['Merkle', /Merkle/i],
    ['拍卖', /auction|拍卖|bid/i],
  ]
  const tags = [groups.find((item) => item.id === group)?.label ?? 'Solidity']
  for (const [label, pattern] of candidates) {
    if (pattern.test(`${family} ${summary}`) && tags.length < 4) tags.push(label)
  }
  return tags
}

export const contracts: ContractExample[] = Object.entries(sourceModules)
  .map(([modulePath, loadSource]) => {
    const match = modulePath.match(/\/src\/([^/]+)\/([^/]+\.sol)$/)
    if (!match) return null

    const [, family, filename] = match
    const sourcePath = `src/${family}/${filename}`
    const normalizedFamily = normalize(family)
    const designEntry = Object.entries(designModules).find(([path]) =>
      normalize(path.split('/').at(-1)?.replace(/\.md$/, '') ?? '') === normalizedFamily,
    )
    const dedicatedTests = testPaths.filter((path) => path.includes(`/test/${family}/`))
    const coverage = coverageByFamily.get(family) ?? null
    const group = groupByFamily[family] ?? 'core'
    const summary = summaries[family] ?? 'Solidity example'

    return {
      id: family,
      name: filename,
      family,
      path: sourcePath,
      loadSource,
      summary,
      compiler: '^0.8.24',
      group,
      tags: makeTags(family, summary, group),
      lineCoverage: coverage,
      dedicatedTests: dedicatedTests.map(repoRelative),
      designPath: designEntry ? repoRelative(designEntry[0]) : null,
      loadDesignNote: designEntry?.[1] ?? null,
    }
  })
  .filter((contract): contract is ContractExample => contract !== null)
  .sort((left, right) => left.family.localeCompare(right.family))

export const coverageBaseline = {
  revision: coverageReport.match(/Source baseline:\s*`([^`]+)`/)?.[1] ?? 'unknown',
  date: coverageReport.match(/Source baseline:\s*`[^`]+`\s*\(([^)]+)\)/)?.[1] ?? 'unknown',
  tests: Number(coverageReport.match(/passed\s+(\d+)\s+tests/)?.[1] ?? 0),
  linePercent: Number(coverageReport.match(/Total\s*\|\s*([\d.]+)%/)?.[1] ?? 0),
}
