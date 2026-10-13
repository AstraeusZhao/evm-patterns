import { lazy, Suspense, useEffect, useMemo, useState, type ReactNode } from 'react'
import ReactMarkdown from 'react-markdown'
import {
  ArrowLeft,
  BookOpen,
  Boxes,
  Check,
  ChevronDown,
  Code2,
  Copy,
  ExternalLink,
  FileCode2,
  FileText,
  Search,
  ShieldAlert,
  SlidersHorizontal,
  X,
} from 'lucide-react'
import {
  contracts,
  coverageBaseline,
  extractNotice,
  groups,
  type ContractExample,
  type ContractGroup,
} from './data/contracts'

const SolidityCode = lazy(() => import('./components/SolidityCode'))

type DetailTab = 'source' | 'design' | 'overview'
type SortMode = 'name' | 'coverage-high' | 'coverage-low'

const githubSource = (path: string) =>
  `https://github.com/AstraeusZhao/evm-patterns/blob/main/${path}`

function testDescription(contract: ContractExample) {
  if (contract.dedicatedTests.length > 0) {
    return `${contract.dedicatedTests.length} 个专项测试文件`
  }
  if ((contract.lineCoverage ?? 0) > 0) return '综合回归测试触达'
  return '覆盖基线未记录执行'
}

function hasTestEvidence(contract: ContractExample) {
  return contract.dedicatedTests.length > 0 || (contract.lineCoverage ?? 0) > 0
}

function coverageTone(value: number | null) {
  if (value === null || value === 0) return 'text-coral'
  if (value >= 80) return 'text-green'
  return 'text-amber'
}

function App() {
  const [query, setQuery] = useState('')
  const [category, setCategory] = useState<ContractGroup | 'all'>('all')
  const [sort, setSort] = useState<SortMode>('name')
  const [mobileFiltersOpen, setMobileFiltersOpen] = useState(false)
  const [selectedId, setSelectedId] = useState<string | null>(() => {
    const initialId = decodeURIComponent(window.location.hash.slice(1))
    return contracts.some((contract) => contract.id === initialId) ? initialId : null
  })
  const [activeTab, setActiveTab] = useState<DetailTab>('source')

  useEffect(() => {
    const syncFromHistory = () => {
      const id = decodeURIComponent(window.location.hash.slice(1))
      setSelectedId(contracts.some((contract) => contract.id === id) ? id : null)
    }
    window.addEventListener('popstate', syncFromHistory)
    window.addEventListener('hashchange', syncFromHistory)
    return () => {
      window.removeEventListener('popstate', syncFromHistory)
      window.removeEventListener('hashchange', syncFromHistory)
    }
  }, [])

  const selected = contracts.find((contract) => contract.id === selectedId) ?? null
  const visibleContracts = useMemo(() => {
    const needle = query.trim().toLowerCase()
    return contracts
      .filter((contract) => {
        if (category !== 'all' && contract.group !== category) return false
        if (!needle) return true

        return [contract.family, contract.name, contract.summary, ...contract.tags]
          .join(' ')
          .toLowerCase()
          .includes(needle)
      })
      .sort((left, right) => {
        if (sort === 'coverage-high') {
          return (right.lineCoverage ?? -1) - (left.lineCoverage ?? -1)
        }
        if (sort === 'coverage-low') {
          return (left.lineCoverage ?? 101) - (right.lineCoverage ?? 101)
        }
        return left.family.localeCompare(right.family)
      })
  }, [category, query, sort])

  const categoryCounts = useMemo(() => {
    const counts = new Map<string, number>([['all', contracts.length]])
    for (const contract of contracts) {
      counts.set(contract.group, (counts.get(contract.group) ?? 0) + 1)
    }
    return counts
  }, [])

  function openContract(contract: ContractExample) {
    window.history.pushState(null, '', `#${encodeURIComponent(contract.id)}`)
    setSelectedId(contract.id)
    setActiveTab('source')
    setMobileFiltersOpen(false)
  }

  function closeContract() {
    window.history.pushState(null, '', `${window.location.pathname}${window.location.search}`)
    setSelectedId(null)
  }

  if (selected) {
    return (
      <DetailView
        contract={selected}
        activeTab={activeTab}
        onTabChange={setActiveTab}
        onBack={closeContract}
      />
    )
  }

  return (
    <div className="app-shell min-h-screen text-ink">
      <header className="topbar sticky top-0 z-30 flex h-[68px] items-center gap-4 border-b border-line bg-paper/95 px-4 backdrop-blur md:px-7">
        <button
          aria-label="打开分类筛选"
          className="icon-button md:hidden"
          onClick={() => setMobileFiltersOpen(true)}
          title="打开分类筛选"
          type="button"
        >
          <SlidersHorizontal size={18} />
        </button>
        <a className="brand flex shrink-0 items-center gap-2.5" href="/" onClick={() => closeContract()}>
          <span className="brand-mark flex size-8 items-center justify-center rounded-md bg-green text-white">
            <Boxes size={18} strokeWidth={1.8} />
          </span>
          <span className="hidden sm:block">
            <span className="block text-[12px] font-bold leading-none tracking-[0.04em]">EVM PATTERNS</span>
            <span className="mt-1 block text-[10px] leading-none text-muted">SOLIDITY CONTRACT LIBRARY</span>
          </span>
        </a>

        <label className="search-box mx-auto flex h-10 w-full max-w-[560px] items-center gap-2.5 rounded-md border border-line bg-mist px-3 text-muted focus-within:border-green focus-within:bg-white">
          <Search size={16} className="shrink-0" />
          <input
            aria-label="搜索合约"
            className="w-full bg-transparent text-[13px] text-ink outline-none placeholder:text-faint"
            onChange={(event) => setQuery(event.target.value)}
            placeholder="搜索合约、模式或函数"
            value={query}
          />
          {query ? (
            <button aria-label="清除搜索" className="clear-search" onClick={() => setQuery('')} type="button">
              <X size={15} />
            </button>
          ) : (
            <kbd className="hidden rounded border border-line bg-white px-1.5 py-0.5 text-[10px] text-faint sm:block">/</kbd>
          )}
        </label>

      </header>

      <div className="flex min-h-[calc(100vh-68px)]">
        {mobileFiltersOpen && (
          <button
            aria-label="关闭筛选菜单"
            className="fixed inset-0 z-30 bg-black/30 md:hidden"
            onClick={() => setMobileFiltersOpen(false)}
            type="button"
          />
        )}
        <aside
          className={`sidebar fixed inset-y-0 left-0 z-40 w-[270px] border-r border-line bg-paper px-4 pb-6 pt-4 transition-transform md:sticky md:top-[68px] md:z-10 md:h-[calc(100vh-68px)] md:translate-x-0 ${mobileFiltersOpen ? 'translate-x-0' : '-translate-x-full'}`}
        >
          <div className="mb-5 flex items-center justify-between md:hidden">
            <span className="text-sm font-semibold">浏览分类</span>
            <button aria-label="关闭筛选菜单" className="icon-button" onClick={() => setMobileFiltersOpen(false)} type="button">
              <X size={17} />
            </button>
          </div>
          <div className="sidebar-section">
            <div className="sidebar-heading">主题</div>
            <nav aria-label="按主题筛选" className="mt-2 space-y-1">
              {groups.map((item) => {
                const active = category === item.id
                return (
                  <button
                    aria-current={active ? 'page' : undefined}
                    className={`category-link flex w-full items-center justify-between rounded-md px-2.5 py-2 text-left text-[13px] transition-colors ${active ? 'bg-green-soft font-semibold text-green' : 'text-muted hover:bg-mist hover:text-ink'}`}
                    key={item.id}
                    onClick={() => {
                      setCategory(item.id)
                      setMobileFiltersOpen(false)
                    }}
                    type="button"
                  >
                    <span>{item.label}</span>
                    <span className={`tabular-nums ${active ? 'text-green/70' : 'text-faint'}`}>{categoryCounts.get(item.id) ?? 0}</span>
                  </button>
                )
              })}
            </nav>
          </div>

        </aside>

        <main className="min-w-0 flex-1 px-4 py-6 md:px-7 md:py-7">
          <div className="content-width mx-auto max-w-[1500px]">
            <div className="mb-5 flex flex-col justify-between gap-4 border-b border-line pb-5 sm:flex-row sm:items-end">
              <div>
                <div className="eyebrow mb-2">SOLIDITY / FOUNDRY</div>
                <h1 className="text-[25px] font-semibold leading-tight text-ink">合约浏览器</h1>
                <p className="mt-1.5 max-w-[660px] text-[13px] leading-5 text-muted">
                  浏览仓库中的 Solidity 模式、实现源码与已记录的测试证据。
                </p>
              </div>
              <div className="grid grid-cols-3 gap-4 border-t border-line pt-3 sm:border-0 sm:pt-0">
                <Metric label="源码模块" value={String(contracts.length)} />
                <Metric label="设计说明" value={String(contracts.filter((item) => item.loadDesignNote).length)} />
                <Metric label="测试基线" value={String(coverageBaseline.tests)} />
              </div>
            </div>

            <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
              <div className="text-[12px] text-muted">
                显示 <strong className="font-semibold text-ink">{visibleContracts.length}</strong> / {contracts.length} 个合约
              </div>
              <label className="sort-control flex h-8 items-center gap-2 rounded-md border border-line bg-paper px-2.5 text-[11px] text-muted">
                <span>排序</span>
                <select aria-label="排序方式" className="max-w-[150px] bg-transparent font-medium text-ink outline-none" onChange={(event) => setSort(event.target.value as SortMode)} value={sort}>
                  <option value="name">名称 A–Z</option>
                  <option value="coverage-high">覆盖率从高到低</option>
                  <option value="coverage-low">覆盖率从低到高</option>
                </select>
                <ChevronDown size={13} />
              </label>
            </div>

            {visibleContracts.length > 0 ? (
              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4">
                {visibleContracts.map((contract) => (
                  <ContractCard contract={contract} key={contract.id} onClick={() => openContract(contract)} />
                ))}
              </div>
            ) : (
              <div className="empty-state flex min-h-64 flex-col items-center justify-center rounded-md border border-dashed border-line bg-paper px-6 text-center">
                <Search size={22} className="text-faint" />
                <h2 className="mt-3 text-sm font-semibold text-ink">没有匹配的合约</h2>
                <p className="mt-1 text-xs text-muted">调整关键词或筛选条件后再试。</p>
                <button
                  className="mt-4 rounded-md border border-line px-3 py-1.5 text-xs font-medium text-ink hover:bg-mist"
                  onClick={() => {
                    setQuery('')
                    setCategory('all')
                  }}
                  type="button"
                >
                  清除筛选
                </button>
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  )
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="min-w-[64px]">
      <div className="text-[10px] text-faint">{label}</div>
      <div className="mt-0.5 text-[17px] font-semibold tabular-nums text-ink">{value}</div>
    </div>
  )
}

function ContractCard({ contract, onClick }: { contract: ContractExample; onClick: () => void }) {
  const groupLabel = groups.find((item) => item.id === contract.group)?.label ?? '基础模式'

  return (
    <button className="contract-card group flex min-h-[204px] flex-col rounded-md border border-line bg-paper p-4 text-left transition-colors hover:border-green/50 hover:bg-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green" onClick={onClick} type="button">
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 items-center gap-2.5">
          <span className="flex size-8 shrink-0 items-center justify-center rounded-md border border-line bg-mist text-green">
            <FileCode2 size={17} strokeWidth={1.7} />
          </span>
          <span className="min-w-0">
            <span className="block truncate font-mono text-[13px] font-semibold text-ink">{contract.family}</span>
            <span className="mt-0.5 block truncate text-[10px] text-faint">{contract.path}</span>
          </span>
        </div>
      </div>

      <p className="mt-3 line-clamp-2 min-h-10 text-[12px] leading-[1.55] text-muted">{contract.summary}</p>

      <div className="mt-3 flex flex-wrap gap-1.5">
        <span className="tag tag-category">{groupLabel}</span>
        {contract.tags.slice(1, 3).map((tag) => <span className="tag" key={tag}>{tag}</span>)}
      </div>

    </button>
  )
}

function DetailView({
  contract,
  activeTab,
  onTabChange,
  onBack,
}: {
  contract: ContractExample
  activeTab: DetailTab
  onTabChange: (tab: DetailTab) => void
  onBack: () => void
}) {
  const [copied, setCopied] = useState(false)
  const [source, setSource] = useState('')
  const [sourceLoading, setSourceLoading] = useState(true)
  const [sourceError, setSourceError] = useState(false)
  const [designNote, setDesignNote] = useState<string | null>(null)
  const [designLoading, setDesignLoading] = useState(false)
  const groupLabel = groups.find((item) => item.id === contract.group)?.label ?? '基础模式'
  const lineCount = source ? source.split(/\r?\n/).length : null
  const functionCount = source ? [...source.matchAll(/\bfunction\s+\w+\s*\(/g)].length : null
  useEffect(() => {
    let current = true
    setSource('')
    setSourceLoading(true)
    setSourceError(false)
    contract.loadSource()
      .then((content) => {
        if (current) setSource(content)
      })
      .catch(() => {
        if (current) setSourceError(true)
      })
      .finally(() => {
        if (current) setSourceLoading(false)
      })
    return () => { current = false }
  }, [contract])

  useEffect(() => {
    let current = true
    setDesignNote(null)
    if (!contract.loadDesignNote) {
      setDesignLoading(false)
      return () => { current = false }
    }
    setDesignLoading(true)
    contract.loadDesignNote()
      .then((content) => {
        if (current) setDesignNote(content)
      })
      .finally(() => {
        if (current) setDesignLoading(false)
      })
    return () => { current = false }
  }, [contract])

  async function copySource() {
    if (!source) return
    try {
      await navigator.clipboard.writeText(source)
      setCopied(true)
      window.setTimeout(() => setCopied(false), 1600)
    } catch {
      setCopied(false)
    }
  }

  function markdownHref(href?: string) {
    if (!href) return undefined
    if (/^https?:\/\//.test(href)) return href
    const basePath = contract.designPath ?? 'docs/design/index.md'
    return new URL(href, `https://github.com/AstraeusZhao/evm-patterns/blob/main/${basePath}`).toString()
  }

  return (
    <div className="app-shell min-h-screen text-ink">
      <header className="detail-topbar sticky top-0 z-20 flex h-[60px] items-center gap-3 border-b border-line bg-paper/95 px-4 backdrop-blur md:px-7">
        <button className="icon-button" onClick={onBack} title="返回合约列表" type="button">
          <ArrowLeft size={17} />
        </button>
        <div className="min-w-0">
          <div className="truncate text-[12px] font-semibold text-ink">{contract.family}</div>
          <div className="hidden truncate font-mono text-[10px] text-faint sm:block">{contract.path}</div>
        </div>
        <div className="ml-auto flex items-center gap-1.5">
          <a className="icon-button hidden sm:inline-flex" href={githubSource(contract.path)} rel="noreferrer" target="_blank" title="在 GitHub 查看源码">
            <ExternalLink size={16} />
          </a>
          <button className="icon-button" onClick={copySource} title={copied ? '已复制源码' : '复制源码'} type="button">
            {copied ? <Check size={16} /> : <Copy size={16} />}
          </button>
        </div>
      </header>

      <main className="detail-main mx-auto w-full max-w-[1600px] px-4 py-5 md:px-7 md:py-7">
        <div className="mb-5 flex flex-col justify-between gap-5 border-b border-line pb-5 lg:flex-row lg:items-end">
          <div className="min-w-0">
            <div className="eyebrow mb-2">{groupLabel} / CONTRACT</div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="font-mono text-[22px] font-semibold text-ink">{contract.family}</h1>
              <span className="rounded border border-line bg-white px-2 py-1 font-mono text-[10px] text-muted">{contract.compiler}</span>
            </div>
            <p className="mt-2 max-w-[860px] text-[13px] leading-[1.65] text-muted">{contract.summary}</p>
          </div>
          <div className="flex shrink-0 items-center gap-5 border-t border-line pt-3 lg:border-0 lg:pt-0">
            <Metric label="函数" value={functionCount === null ? '…' : String(functionCount)} />
            <Metric label="源码行" value={lineCount === null ? '…' : String(lineCount)} />
            <Metric label="基线覆盖" value={contract.lineCoverage === null ? '—' : `${contract.lineCoverage.toFixed(1)}%`} />
          </div>
        </div>

        <div className="detail-layout grid min-w-0 grid-cols-1 gap-5 xl:grid-cols-[minmax(0,1fr)_280px]">
          <section className="min-w-0">
            <div className="mb-3 flex flex-wrap items-center justify-between gap-3">
              <div className="tab-strip inline-flex items-center gap-1 rounded-md border border-line bg-white p-1" role="tablist" aria-label="合约详情">
                <TabButton active={activeTab === 'source'} icon={<Code2 size={14} />} onClick={() => onTabChange('source')} label="源码" />
                <TabButton active={activeTab === 'design'} icon={<BookOpen size={14} />} onClick={() => onTabChange('design')} label="设计说明" />
                <TabButton active={activeTab === 'overview'} icon={<FileText size={14} />} onClick={() => onTabChange('overview')} label="概览" />
              </div>
              <a className="inline-flex items-center gap-1.5 text-[11px] font-medium text-muted hover:text-green" href={githubSource(contract.path)} rel="noreferrer" target="_blank">
                打开 GitHub <ExternalLink size={13} />
              </a>
            </div>

            {activeTab === 'source' && (
              <div className="code-panel overflow-hidden rounded-md border border-code-line bg-code">
                <div className="flex h-10 items-center justify-between border-b border-code-line px-3.5 text-[10px] text-code-muted">
                  <span className="font-mono">{contract.path}</span>
                  <span>{lineCount === null ? '加载中' : `${lineCount} lines`}</span>
                </div>
                <div className="code-scroll max-h-[calc(100vh-300px)] min-h-[420px] overflow-auto">
                  {sourceLoading ? (
                    <div className="px-5 py-6 text-xs text-code-muted">正在读取 Solidity 源码…</div>
                  ) : sourceError ? (
                    <div className="px-5 py-6 text-xs text-coral">源码读取失败，请稍后重试。</div>
                  ) : (
                    <Suspense fallback={<div className="px-5 py-6 text-xs text-code-muted">正在加载语法高亮…</div>}>
                      <SolidityCode source={source} />
                    </Suspense>
                  )}
                </div>
              </div>
            )}

            {activeTab === 'design' && (
              <div className="design-panel min-h-[420px] rounded-md border border-line bg-paper px-5 py-5 md:px-8 md:py-7">
                {designLoading ? (
                  <div className="py-4 text-xs text-muted">正在读取设计说明…</div>
                ) : designNote ? (
                  <article className="markdown-body">
                    <ReactMarkdown
                      components={{
                        a: ({ href, children }) => (
                          <a href={markdownHref(href)} rel="noreferrer" target="_blank">{children}</a>
                        ),
                      }}
                    >
                      {designNote}
                    </ReactMarkdown>
                  </article>
                ) : (
                  <div className="flex min-h-[360px] flex-col items-start justify-center">
                    <BookOpen size={22} className="text-green" />
                    <h2 className="mt-4 text-[16px] font-semibold text-ink">暂无独立设计说明</h2>
                    <p className="mt-2 max-w-[520px] text-[13px] leading-6 text-muted">
                      源码中的 NatSpec 摘要可作为入口。测试和覆盖证据请查看右侧信息栏；缺少设计说明不代表该示例已完成安全审查。
                    </p>
                    <button className="mt-5 inline-flex items-center gap-2 rounded-md border border-line px-3 py-2 text-xs font-medium text-ink hover:bg-mist" onClick={() => onTabChange('overview')} type="button">
                      查看覆盖与测试 <ChevronDown size={14} className="-rotate-90" />
                    </button>
                  </div>
                )}
              </div>
            )}

            {activeTab === 'overview' && <Overview contract={contract} source={source} onShowDesign={() => onTabChange('design')} />}
          </section>

          <aside className="detail-aside border-t border-line pt-4 xl:border-l xl:border-t-0 xl:pl-5 xl:pt-0">
            <h2 className="text-[11px] font-semibold text-ink">仓库信息</h2>
            <dl className="mt-2 divide-y divide-line text-[11px]">
              <InfoRow label="分类" value={groupLabel} />
              <InfoRow label="编译版本" value={contract.compiler} monospace />
              <InfoRow label="覆盖基线" value={coverageBaseline.revision} monospace />
              <InfoRow label="基线日期" value={coverageBaseline.date} />
              <InfoRow label="测试证据" value={testDescription(contract)} />
              <InfoRow label="设计说明" value={contract.loadDesignNote ? '已记录' : '暂无'} />
            </dl>

            <div className="mt-6 border-t border-line pt-4">
              <h3 className="text-[11px] font-semibold text-ink">测试文件</h3>
              {contract.dedicatedTests.length > 0 ? (
                <ul className="mt-2 space-y-2">
                  {contract.dedicatedTests.map((path) => (
                    <li key={path}>
                      <a className="file-link break-all font-mono text-[10px] leading-4 text-muted hover:text-green" href={githubSource(path)} rel="noreferrer" target="_blank">{path}</a>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="mt-2 text-[11px] leading-5 text-muted">
                  {contract.lineCoverage && contract.lineCoverage > 0
                    ? '该示例仅由综合回归套件触达，不等同于完整专项测试。'
                    : '当前覆盖报告没有记录该源码的执行。'}
                </p>
              )}
            </div>

            <div className="mt-6 border-t border-line pt-4">
              <h3 className="text-[11px] font-semibold text-ink">安全范围</h3>
              <p className="mt-2 text-[11px] leading-[1.65] text-muted">
                此仓库用于学习与代码审阅，未作为生产协议完成独立审计。测试通过不代表安全认证。
              </p>
              <a className="mt-2 inline-flex items-center gap-1 text-[10px] font-medium text-green hover:underline" href="https://github.com/AstraeusZhao/evm-patterns/blob/main/SECURITY.md" rel="noreferrer" target="_blank">
                SECURITY.md <ExternalLink size={11} />
              </a>
            </div>
          </aside>
        </div>
      </main>
    </div>
  )
}

function TabButton({ active, icon, label, onClick }: { active: boolean; icon: ReactNode; label: string; onClick: () => void }) {
  return (
    <button
      aria-selected={active}
      className={`tab-button inline-flex h-8 items-center gap-1.5 rounded px-2.5 text-[11px] font-medium transition-colors ${active ? 'bg-green text-white' : 'text-muted hover:bg-mist hover:text-ink'}`}
      onClick={onClick}
      role="tab"
      type="button"
    >
      {icon}{label}
    </button>
  )
}

function InfoRow({ label, value, monospace = false }: { label: string; value: string; monospace?: boolean }) {
  return (
    <div className="flex items-start justify-between gap-3 py-2.5">
      <dt className="shrink-0 text-faint">{label}</dt>
      <dd className={`max-w-[175px] text-right font-medium text-ink ${monospace ? 'font-mono' : ''}`}>{value}</dd>
    </div>
  )
}

function Overview({ contract, source, onShowDesign }: { contract: ContractExample; source: string; onShowDesign: () => void }) {
  const hasEvidence = hasTestEvidence(contract)
  const notice = source ? extractNotice(source) : ''
  const functionCount = source ? [...source.matchAll(/\bfunction\s+\w+\s*\(/g)].length : null
  const lineCount = source ? source.split(/\r?\n/).length : null

  return (
    <div className="overview-panel min-h-[420px] rounded-md border border-line bg-paper p-5 md:p-7">
      <div className="flex items-start gap-3 border-b border-line pb-5">
        <span className="flex size-9 shrink-0 items-center justify-center rounded-md bg-green-soft text-green"><FileCode2 size={18} /></span>
        <div>
          <h2 className="text-[15px] font-semibold text-ink">模式摘要</h2>
          <p className="mt-1 text-[12px] leading-5 text-muted">{contract.summary}</p>
        </div>
      </div>

      <div className="grid gap-x-8 gap-y-5 py-5 sm:grid-cols-2">
        <OverviewItem label="源码位置" value={contract.path} code />
        <OverviewItem label="Solidity pragma" value={contract.compiler} code />
        <OverviewItem label="源码函数" value={functionCount === null ? '加载中' : String(functionCount)} />
        <OverviewItem label="源码行数" value={lineCount === null ? '加载中' : String(lineCount)} />
        <OverviewItem label="测试状态" value={testDescription(contract)} />
        <OverviewItem label="设计文档" value={contract.designPath ?? '暂无独立设计说明'} code={Boolean(contract.designPath)} />
      </div>

      <div className="border-t border-line pt-5">
        <div className="flex items-center justify-between gap-4">
          <div>
            <h3 className="text-[12px] font-semibold text-ink">行覆盖基线</h3>
            <p className="mt-1 text-[11px] leading-5 text-muted">
              {coverageBaseline.revision} · {coverageBaseline.date} · {coverageBaseline.tests} 项通过测试
            </p>
          </div>
          <span className={`font-mono text-[18px] font-semibold tabular-nums ${coverageTone(contract.lineCoverage)}`}>
            {contract.lineCoverage === null ? '—' : `${contract.lineCoverage.toFixed(2)}%`}
          </span>
        </div>
        <div className="coverage-track mt-3 h-1.5 overflow-hidden rounded-full bg-mist">
          <div className="h-full rounded-full bg-green" style={{ width: `${Math.max(0, Math.min(contract.lineCoverage ?? 0, 100))}%` }} />
        </div>
        {!hasEvidence && (
          <p className="mt-3 flex items-start gap-2 text-[11px] leading-5 text-coral">
            <ShieldAlert size={14} className="mt-0.5 shrink-0" />
            此源码在当前基线中没有测得执行覆盖。
          </p>
        )}
      </div>

      {notice && (
        <div className="mt-5 border-t border-line pt-5">
          <h3 className="text-[12px] font-semibold text-ink">源码 NatSpec</h3>
          <p className="mt-2 text-[12px] leading-[1.7] text-muted">{notice}</p>
        </div>
      )}

      {contract.loadDesignNote && (
        <button className="mt-5 inline-flex items-center gap-2 border-t border-line pt-4 text-[11px] font-semibold text-green hover:underline" onClick={onShowDesign} type="button">
          阅读设计说明 <BookOpen size={14} />
        </button>
      )}
    </div>
  )
}

function OverviewItem({ label, value, code = false }: { label: string; value: string; code?: boolean }) {
  return (
    <div className="min-w-0">
      <div className="text-[10px] text-faint">{label}</div>
      <div className={`mt-1 break-words text-[11px] text-ink ${code ? 'font-mono' : 'font-medium'}`}>{value}</div>
    </div>
  )
}

export default App
