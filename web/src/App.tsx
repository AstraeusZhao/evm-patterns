import {
  lazy,
  Suspense,
  useEffect,
  useMemo,
  useId,
  useRef,
  useState,
  type ReactNode,
} from 'react'
import ReactMarkdown from 'react-markdown'
import {
  ArrowLeft,
  BookOpen,
  Boxes,
  Check,
  ChevronDown,
  ChevronRight,
  Code2,
  Copy,
  ExternalLink,
  FileCode2,
  FileText,
  Folder,
  FolderOpen,
  Languages,
  Search,
  X,
} from 'lucide-react'
import {
  fetchCatalog,
  groups,
  type ContractExample,
  type ContractGroup,
  type CatalogResponse,
} from './data/contracts'
import {
  initialLocale,
  languages,
  localiseTag,
  translations,
  type Locale,
} from './i18n'

const SolidityCode = lazy(() => import('./components/SolidityCode'))
const repositoryUrl = 'https://github.com/AstraeusZhao/evm-patterns'
const githubSource = (path: string) => `${repositoryUrl}/blob/main/${path}`
type DetailTab = 'source' | 'design' | 'overview'

function LanguagePicker({
  locale,
  onChange,
}: {
  locale: Locale
  onChange: (locale: Locale) => void
}) {
  const [open, setOpen] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)
  const triggerRef = useRef<HTMLButtonElement>(null)
  const menuId = useId()
  const current = languages.find((item) => item.id === locale)!
  useEffect(() => {
    if (!open) return
    const closeOutside = (event: PointerEvent) => {
      if (!containerRef.current?.contains(event.target as Node)) setOpen(false)
    }
    document.addEventListener('pointerdown', closeOutside)
    containerRef.current
      ?.querySelector<HTMLButtonElement>('[aria-checked="true"]')
      ?.focus()
    return () => document.removeEventListener('pointerdown', closeOutside)
  }, [open])
  return (
    <div className="language-picker" ref={containerRef}>
      <button
        className="language-trigger"
        ref={triggerRef}
        type="button"
        title={current.name}
        aria-label={translations[locale].language}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={open ? menuId : undefined}
        onClick={() => setOpen((previous) => !previous)}
        onKeyDown={(event) => {
          if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
            event.preventDefault()
            setOpen(true)
          }
          if (event.key === 'Escape') setOpen(false)
        }}
      >
        <Languages size={16} aria-hidden="true" />
        <span>{current.label}</span>
        <ChevronDown
          size={13}
          className={open ? 'rotate-180' : ''}
          aria-hidden="true"
        />
      </button>
      {open && (
        <div
          className="language-menu"
          role="menu"
          id={menuId}
          aria-label={translations[locale].language}
          onKeyDown={(event) => {
            const items = Array.from(
              event.currentTarget.querySelectorAll<HTMLButtonElement>(
                '[role="menuitemradio"]',
              ),
            )
            const index = items.indexOf(
              document.activeElement as HTMLButtonElement,
            )
            if (event.key === 'Escape') {
              event.preventDefault()
              setOpen(false)
              triggerRef.current?.focus()
            } else if (event.key === 'Tab') setOpen(false)
            else if (
              ['ArrowDown', 'ArrowUp', 'Home', 'End'].includes(event.key)
            ) {
              event.preventDefault()
              const next =
                event.key === 'Home'
                  ? 0
                  : event.key === 'End'
                    ? items.length - 1
                    : (index +
                        (event.key === 'ArrowDown' ? 1 : -1) +
                        items.length) %
                      items.length
              items[next]?.focus()
            }
          }}
        >
          {languages.map((language) => (
            <button
              className="language-option"
              key={language.id}
              role="menuitemradio"
              aria-checked={locale === language.id}
              type="button"
              onClick={() => {
                onChange(language.id)
                setOpen(false)
                triggerRef.current?.focus()
              }}
            >
              <span>{language.name}</span>
              {locale === language.id && <Check size={14} aria-hidden="true" />}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

function App() {
  const [catalog, setCatalog] = useState<CatalogResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [loadError, setLoadError] = useState(false)
  const [reloadKey, setReloadKey] = useState(0)
  const [query, setQuery] = useState('')
  const [category, setCategory] = useState<ContractGroup | 'all'>('all')
  const [selectedId, setSelectedId] = useState<string | null>(
    () => decodeURIComponent(window.location.hash.slice(1)) || null,
  )
  const [activeTab, setActiveTab] = useState<DetailTab>('source')
  const [locale, setLocale] = useState<Locale>(initialLocale)
  const t = translations[locale]
  const contracts = useMemo(() => catalog?.contracts ?? [], [catalog])

  useEffect(() => {
    let current = true
    fetchCatalog()
      .then((response) => {
        if (current) setCatalog(response)
      })
      .catch(() => {
        if (current) setLoadError(true)
      })
      .finally(() => {
        if (current) setLoading(false)
      })
    return () => {
      current = false
    }
  }, [reloadKey])
  useEffect(() => {
    const sync = () => {
      setSelectedId(decodeURIComponent(window.location.hash.slice(1)) || null)
    }
    window.addEventListener('popstate', sync)
    window.addEventListener('hashchange', sync)
    return () => {
      window.removeEventListener('popstate', sync)
      window.removeEventListener('hashchange', sync)
    }
  }, [])
  useEffect(() => {
    document.documentElement.lang = locale
    document.title = `EVM Patterns | ${t.title}`
    document
      .querySelector('meta[name="description"]')
      ?.setAttribute('content', t.subtitle)
  }, [locale, t])

  const visibleContracts = useMemo(() => {
    const needle = query.trim().toLowerCase()
    return contracts
      .filter((contract) => {
        if (category !== 'all' && contract.group !== category) return false
        return (
          !needle ||
          [
            contract.family,
            contract.name,
            contract.summary,
            t[contract.group],
            ...contract.tags.map((tag) => localiseTag(tag, t)),
          ]
            .join(' ')
            .toLowerCase()
            .includes(needle)
        )
      })
      .sort((a, b) => a.family.localeCompare(b.family, locale))
  }, [contracts, category, query, t, locale])
  const counts = useMemo(() => {
    const map = new Map<string, number>([['all', contracts.length]])
    for (const contract of contracts)
      map.set(contract.group, (map.get(contract.group) ?? 0) + 1)
    return map
  }, [contracts])
  const selected = contracts.find((contract) => contract.id === selectedId)
  function openContract(contract: ContractExample) {
    window.history.pushState(null, '', `#${encodeURIComponent(contract.id)}`)
    setSelectedId(contract.id)
    setActiveTab('source')
  }
  function closeContract() {
    window.history.pushState(
      null,
      '',
      `${window.location.pathname}${window.location.search}`,
    )
    setSelectedId(null)
  }
  function changeLocale(next: Locale) {
    setLocale(next)
    try {
      localStorage.setItem('evm-patterns-language', next)
    } catch {
      /* Storage is optional. */
    }
  }

  if (!catalog)
    return (
      <div className="app-shell min-h-screen text-ink">
        <main className="mx-auto max-w-3xl px-6 py-16">
          <div className="mb-8 flex justify-end">
            <LanguagePicker locale={locale} onChange={changeLocale} />
          </div>
          {loading ? (
            <p className="text-sm text-muted" role="status">
              {t.loading}
            </p>
          ) : (
            <>
              <h1 className="text-lg font-semibold">{t.unavailable}</h1>
              {loadError && (
                <p className="mt-2 text-sm text-muted">{t.serviceError}</p>
              )}
              <button
                className="mt-5 rounded-md border border-line px-3 py-2 text-sm hover:bg-mist"
                onClick={() => {
                  setLoading(true)
                  setLoadError(false)
                  setReloadKey((key) => key + 1)
                }}
                type="button"
              >
                {t.retry}
              </button>
            </>
          )}
        </main>
      </div>
    )
  if (selected)
    return (
      <DetailView
        key={selected.id}
        contract={selected}
        activeTab={activeTab}
        onTabChange={setActiveTab}
        onBack={closeContract}
        locale={locale}
        onLocaleChange={changeLocale}
      />
    )
  return (
    <div className="app-shell min-h-screen text-ink">
      <header className="topbar sticky top-0 z-30 flex h-[68px] items-center gap-4 border-b border-line bg-paper/95 px-4 backdrop-blur md:px-7">
        <a className="brand flex shrink-0 items-center gap-2.5" href="/">
          <span className="flex size-8 items-center justify-center rounded-md bg-green text-white">
            <Boxes size={18} strokeWidth={1.8} />
          </span>
          <span className="hidden sm:block">
            <span className="block text-[12px] font-bold leading-none tracking-[0.04em]">
              EVM PATTERNS
            </span>
            <span className="mt-1 block text-[10px] leading-none text-muted">
              {t.library}
            </span>
          </span>
        </a>
        <label className="search-box ml-5 flex h-10 w-full max-w-[560px] items-center gap-2.5 rounded-md border border-line bg-mist px-3 text-muted">
          <Search size={16} className="shrink-0" />
          <input
            aria-label={t.search}
            className="w-full min-w-0 bg-transparent text-[13px] text-ink outline-none placeholder:text-faint"
            placeholder={t.placeholder}
            value={query}
            onChange={(event) => setQuery(event.target.value)}
          />
          {query && (
            <button
              aria-label={t.clear}
              className="clear-search"
              onClick={() => setQuery('')}
              type="button"
            >
              <X size={15} />
            </button>
          )}
        </label>
        <LanguagePicker locale={locale} onChange={changeLocale} />
      </header>
      <div className="flex min-h-[calc(100vh-68px)] flex-col md:flex-row">
        <aside className="sidebar shrink-0 border-b border-line bg-paper px-4 py-4 md:sticky md:top-[68px] md:h-[calc(100vh-68px)] md:w-[250px] md:overflow-auto md:border-b-0 md:border-r">
          <div className="sidebar-heading">{t.categories}</div>
          <nav
            aria-label={t.categories}
            className="mt-2 flex gap-1 overflow-x-auto md:block md:space-y-1"
          >
            {groups.map((item) => (
              <button
                key={item.id}
                type="button"
                aria-current={category === item.id ? 'page' : undefined}
                onClick={() => setCategory(item.id)}
                className={`category-link flex shrink-0 items-center justify-between gap-4 whitespace-nowrap rounded-md px-2.5 py-2 text-left text-[13px] md:w-full ${category === item.id ? 'bg-green-soft font-semibold text-green' : 'text-muted hover:bg-mist hover:text-ink'}`}
              >
                <span>{item.id === 'all' ? t.all : t[item.id]}</span>
                <span className="tabular-nums opacity-70">
                  {counts.get(item.id) ?? 0}
                </span>
              </button>
            ))}
          </nav>
        </aside>
        <main className="min-w-0 flex-1 px-4 py-6 md:px-7 md:py-7">
          <div className="mx-auto max-w-[1500px]">
            <div className="mb-5 border-b border-line pb-5">
              <div className="eyebrow mb-2">SOLIDITY / FOUNDRY</div>
              <h1 className="text-[25px] font-semibold leading-tight">
                {t.title}
              </h1>
              <p className="mt-1.5 text-[13px] leading-5 text-muted">
                {t.subtitle}
              </p>
            </div>
            <div className="mb-4 text-[12px] text-muted">
              {t.showing}{' '}
              <strong className="font-semibold text-ink">
                {visibleContracts.length}
              </strong>{' '}
              / {contracts.length} {t.contracts}
            </div>
            {visibleContracts.length ? (
              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4">
                {visibleContracts.map((contract) => (
                  <ContractCard
                    key={contract.id}
                    contract={contract}
                    onClick={() => openContract(contract)}
                    locale={locale}
                  />
                ))}
              </div>
            ) : (
              <div className="flex min-h-64 flex-col items-center justify-center rounded-md border border-dashed border-line bg-paper px-6 text-center">
                <Search size={22} className="text-faint" />
                <h2 className="mt-3 text-sm font-semibold">{t.empty}</h2>
                <p className="mt-1 text-xs text-muted">{t.emptyHint}</p>
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  )
}

function ContractCard({
  contract,
  onClick,
  locale,
}: {
  contract: ContractExample
  onClick: () => void
  locale: Locale
}) {
  const t = translations[locale]
  return (
    <button
      className="contract-card flex min-h-[204px] flex-col rounded-md border border-line bg-paper p-4 text-left hover:border-green/50 hover:bg-white"
      onClick={onClick}
      type="button"
    >
      <div className="flex min-w-0 items-center gap-2.5">
        <span className="flex size-8 shrink-0 items-center justify-center rounded-md border border-line bg-mist text-green">
          <FileCode2 size={17} strokeWidth={1.7} />
        </span>
        <span className="min-w-0">
          <span className="block truncate font-mono text-[13px] font-semibold">
            {contract.family}
          </span>
          <span className="mt-0.5 block truncate text-[10px] text-faint">
            {contract.path}
          </span>
        </span>
      </div>
      <p className="mt-3 line-clamp-2 min-h-10 text-[12px] leading-[1.55] text-muted">
        {contract.summary}
      </p>
      <div className="mt-3 flex flex-wrap gap-1.5">
        <span className="tag tag-category">{t[contract.group]}</span>
        {contract.tags.slice(1, 3).map((tag) => (
          <span className="tag" key={tag}>
            {localiseTag(tag, t)}
          </span>
        ))}
      </div>
    </button>
  )
}

function ContractExplorer({
  contract,
  selectedPath,
  onSelect,
  locale,
}: {
  contract: ContractExample
  selectedPath: string
  onSelect: (path: string) => void
  locale: Locale
}) {
  const [collapsed, setCollapsed] = useState<Set<string>>(() => new Set())
  const files = [contract.path, ...contract.dedicatedTests]
  const folders = [...new Set(files.map((path) => path.split('/')[0]))]
  return (
    <aside className="project-explorer">
      <div className="project-root">
        <FolderOpen size={15} />
        <span>{contract.family}</span>
      </div>
      <nav aria-label={translations[locale].files}>
        <ul>
          {folders.map((folder) => {
            const open = !collapsed.has(folder)
            return (
              <li key={folder}>
                <button
                  className="explorer-row"
                  type="button"
                  aria-expanded={open}
                  onClick={() =>
                    setCollapsed((previous) => {
                      const next = new Set(previous)
                      if (next.has(folder)) next.delete(folder)
                      else next.add(folder)
                      return next
                    })
                  }
                >
                  {open ? (
                    <ChevronDown size={13} />
                  ) : (
                    <ChevronRight size={13} />
                  )}
                  {open ? <FolderOpen size={14} /> : <Folder size={14} />}
                  <span>{folder}</span>
                </button>
                {open && (
                  <ul>
                    {files
                      .filter((path) => path.startsWith(`${folder}/`))
                      .map((path) => (
                        <li key={path}>
                          <button
                            type="button"
                            className={`explorer-row explorer-file ${path === selectedPath ? 'is-active' : ''}`}
                            aria-current={
                              path === selectedPath ? 'page' : undefined
                            }
                            onClick={() => onSelect(path)}
                            title={path}
                          >
                            <FileCode2 size={14} />
                            <span>
                              {path.split('/').slice(2).join('/') ||
                                path.split('/').at(-1)}
                            </span>
                          </button>
                        </li>
                      ))}
                  </ul>
                )}
              </li>
            )
          })}
        </ul>
      </nav>
    </aside>
  )
}

function DetailView({
  contract,
  activeTab,
  onTabChange,
  onBack,
  locale,
  onLocaleChange,
}: {
  contract: ContractExample
  activeTab: DetailTab
  onTabChange: (tab: DetailTab) => void
  onBack: () => void
  locale: Locale
  onLocaleChange: (locale: Locale) => void
}) {
  const t = translations[locale]
  const [selectedPath, setSelectedPath] = useState(contract.path)
  const [fileResult, setFileResult] = useState<{
    path: string
    content: string
  } | null>(null)
  const [failedPath, setFailedPath] = useState<string | null>(null)
  const [designResult, setDesignResult] = useState<string | null>(null)
  const [designError, setDesignError] = useState(false)
  const [copiedPath, setCopiedPath] = useState<string | null>(null)
  const editorRef = useRef<HTMLDivElement>(null)
  const content = fileResult?.path === selectedPath ? fileResult.content : ''
  const fileError =
    failedPath === selectedPath && fileResult?.path !== selectedPath
  const fileLoading = fileResult?.path !== selectedPath && !fileError
  useEffect(() => {
    const editor = editorRef.current
    if (!editor) return
    const scrollEditor = (event: WheelEvent) => {
      if (event.ctrlKey || !event.deltaY) return
      const code = editor.querySelector<HTMLElement>('.code-scroll')
      const delta =
        event.deltaY *
        (event.deltaMode === 1
          ? 20
          : event.deltaMode === 2
            ? window.innerHeight
            : 1)
      const remaining = Math.max(0, editor.getBoundingClientRect().top - 60)
      if (delta > 0 && remaining > 0) {
        event.preventDefault()
        const pageDelta = Math.min(delta, remaining)
        window.scrollBy(0, pageDelta)
        if (code?.contains(event.target as Node))
          code.scrollTop += delta - pageDelta
      } else if (
        delta < 0 &&
        code?.contains(event.target as Node) &&
        code.scrollTop === 0
      ) {
        event.preventDefault()
        window.scrollBy(0, delta)
      }
    }
    editor.addEventListener('wheel', scrollEditor, { passive: false })
    return () => editor.removeEventListener('wheel', scrollEditor)
  }, [activeTab])
  useEffect(() => {
    let current = true
    contract
      .loadFile(selectedPath)
      .then((text) => {
        if (current) setFileResult({ path: selectedPath, content: text })
      })
      .catch(() => {
        if (current) setFailedPath(selectedPath)
      })
    return () => {
      current = false
    }
  }, [contract, selectedPath])
  useEffect(() => {
    let current = true
    contract
      .loadDesignNote?.()
      .then((text) => {
        if (current) setDesignResult(text)
      })
      .catch(() => {
        if (current) setDesignError(true)
      })
    return () => {
      current = false
    }
  }, [contract])
  async function copyFile() {
    if (!content) return
    try {
      await navigator.clipboard.writeText(content)
      setCopiedPath(selectedPath)
      window.setTimeout(() => setCopiedPath(null), 1600)
    } catch {
      setCopiedPath(null)
    }
  }
  function markdownHref(href?: string) {
    if (!href) return undefined
    if (/^https?:\/\//.test(href)) return href
    return new URL(
      href,
      githubSource(contract.designPath ?? 'docs/design/index.md'),
    ).toString()
  }
  const copied = copiedPath === selectedPath
  const githubPath =
    activeTab === 'design' && contract.designPath
      ? contract.designPath
      : activeTab === 'source'
        ? selectedPath
        : contract.path
  return (
    <div className="app-shell min-h-screen text-ink">
      <header className="detail-topbar sticky top-0 z-20 flex h-[60px] items-center gap-3 border-b border-line bg-paper/95 px-4 backdrop-blur md:px-7">
        <button
          className="icon-button"
          aria-label={t.back}
          onClick={onBack}
          type="button"
        >
          <ArrowLeft size={17} />
        </button>
        <div className="min-w-0">
          <div className="truncate text-[12px] font-semibold">
            {contract.family}
          </div>
          <div className="hidden truncate font-mono text-[10px] text-faint sm:block">
            {contract.path}
          </div>
        </div>
        <div className="ml-auto">
          <LanguagePicker locale={locale} onChange={onLocaleChange} />
        </div>
      </header>
      <main
        className={`project-main ${activeTab === 'source' ? 'source-view' : ''}`}
      >
        <div className="project-heading">
          <div className="eyebrow mb-2">SOLIDITY / CONTRACT</div>
          <h1 className="break-words font-mono text-[22px] font-semibold">
            {contract.family}
          </h1>
          <p className="mt-2 max-w-[1000px] text-[13px] leading-[1.65] text-muted">
            {contract.summary}
          </p>
        </div>
        <div className="workspace-tools">
          <div className="workspace-tabs">
            <div
              className="tab-strip inline-flex flex-wrap items-center gap-1 rounded-md border border-line bg-white p-1"
              role="tablist"
              aria-label={contract.family}
            >
              <TabButton
                active={activeTab === 'source'}
                icon={<Code2 size={14} />}
                onClick={() => onTabChange('source')}
                label={t.source}
              />
              <TabButton
                active={activeTab === 'design'}
                icon={<BookOpen size={14} />}
                onClick={() => onTabChange('design')}
                label={t.design}
              />
              <TabButton
                active={activeTab === 'overview'}
                icon={<FileText size={14} />}
                onClick={() => onTabChange('overview')}
                label={t.overview}
              />
            </div>
            <a
              className="github-link"
              href={githubSource(githubPath)}
              target="_blank"
              rel="noreferrer"
            >
              {t.github}
              <ExternalLink size={13} />
            </a>
          </div>
        </div>
        {activeTab === 'source' && (
          <div className="editor-shell" ref={editorRef}>
            <ContractExplorer
              contract={contract}
              selectedPath={selectedPath}
              onSelect={setSelectedPath}
              locale={locale}
            />
            <section className="code-panel min-w-0 flex-1">
              <div className="file-toolbar">
                <span className="truncate font-mono" title={selectedPath}>
                  {selectedPath}
                </span>
                <button
                  className="file-copy"
                  type="button"
                  aria-label={copied ? t.copied : t.copy}
                  title={copied ? t.copied : t.copy}
                  disabled={!content}
                  onClick={copyFile}
                >
                  {copied ? <Check size={15} /> : <Copy size={15} />}
                </button>
              </div>
              <div key={selectedPath} className="code-scroll overflow-auto">
                {fileLoading ? (
                  <div
                    className="px-5 py-6 text-xs text-code-muted"
                    role="status"
                  >
                    {t.codeLoading}
                  </div>
                ) : fileError ? (
                  <div className="px-5 py-6 text-xs text-coral">
                    {t.codeError}
                  </div>
                ) : (
                  <Suspense
                    fallback={
                      <div className="px-5 py-6 text-xs text-code-muted">
                        {t.highlightLoading}
                      </div>
                    }
                  >
                    <SolidityCode
                      source={content}
                      language={
                        selectedPath.endsWith('.ts') ? 'typescript' : 'solidity'
                      }
                    />
                  </Suspense>
                )}
              </div>
            </section>
          </div>
        )}
        {activeTab === 'design' && (
          <div className="design-panel min-h-[420px] rounded-md border border-line bg-paper px-5 py-5 md:px-8 md:py-7">
            {designError ? (
              <p className="text-sm text-coral">{t.designError}</p>
            ) : designResult !== null ? (
              <article className="markdown-body">
                <ReactMarkdown
                  components={{
                    a: ({ href, children }) => (
                      <a
                        href={markdownHref(href)}
                        rel="noreferrer"
                        target="_blank"
                      >
                        {children}
                      </a>
                    ),
                  }}
                >
                  {designResult}
                </ReactMarkdown>
              </article>
            ) : (
              <p className="py-4 text-sm text-muted">
                {contract.loadDesignNote ? t.designLoading : t.noDesign}
              </p>
            )}
          </div>
        )}
        {activeTab === 'overview' && (
          <div className="overview-panel min-h-[420px] rounded-md border border-line bg-paper p-5 md:p-7">
            <h2 className="text-[15px] font-semibold">{contract.family}</h2>
            <p className="mt-2 text-[13px] leading-6 text-muted">
              {contract.summary}
            </p>
            <dl className="mt-5 grid gap-5 border-t border-line py-5 sm:grid-cols-2">
              <div>
                <dt className="text-[10px] text-faint">{t.repository}</dt>
                <dd className="mt-1 text-[12px]">
                  <a
                    className="text-green hover:underline"
                    href={repositoryUrl}
                    target="_blank"
                    rel="noreferrer"
                  >
                    AstraeusZhao/evm-patterns
                  </a>
                </dd>
              </div>
              <div>
                <dt className="text-[10px] text-faint">{t.file}</dt>
                <dd className="mt-1 break-words font-mono text-[12px]">
                  {contract.path}
                </dd>
              </div>
            </dl>
            {contract.loadDesignNote && (
              <button
                type="button"
                className="inline-flex items-center gap-2 text-xs text-green hover:underline"
                onClick={() => onTabChange('design')}
              >
                {t.readDesign}
                <BookOpen size={14} />
              </button>
            )}
          </div>
        )}
      </main>
    </div>
  )
}

function TabButton({
  active,
  icon,
  label,
  onClick,
}: {
  active: boolean
  icon: ReactNode
  label: string
  onClick: () => void
}) {
  return (
    <button
      aria-selected={active}
      className={`tab-button inline-flex h-8 items-center gap-1.5 rounded px-2.5 text-[11px] font-medium ${active ? 'bg-green text-white' : 'text-muted hover:bg-mist hover:text-ink'}`}
      onClick={onClick}
      role="tab"
      type="button"
    >
      {icon}
      {label}
    </button>
  )
}
export default App
