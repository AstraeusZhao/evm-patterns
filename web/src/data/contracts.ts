import summaries from './localisedSummaries.json'
import type { Locale } from '../i18n'

export type ContractGroup = 'core' | 'token' | 'nft' | 'defi' | 'staking' | 'auctionGroup' | 'distribution' | 'payments' | 'access' | 'governance' | 'architecture' | 'cryptography' | 'flashloans' | 'security'

type ContractRecord = {
  id: string
  name: string
  family: string
  path: string
  summary: string
  compiler: string
  group: ContractGroup
  tags: string[]
  lineCoverage: number | null
  dedicatedTests: string[]
  designPath: string | null
}

export type ContractExample = ContractRecord & {
  loadSource: () => Promise<string>
  loadFile: (path: string, framework?: Framework) => Promise<string>
  loadTree: (framework: Framework) => Promise<ProjectNode[]>
  loadDesignNote: ((locale: Locale) => Promise<string>) | null
}

export type Framework = 'foundry' | 'hardhat' | 'truffle' | 'ape'
export type ProjectNode = { name: string; path: string; kind: 'directory' | 'file'; children: ProjectNode[] }

export type CoverageBaseline = {
  revision: string
  date: string
  tests: number
  linePercent: number
}

export type GitStatus = {
  branch: string | null
  revision: string | null
  dirty: boolean
  changedFiles: number
}

export type CatalogResponse = {
  git: GitStatus
  coverageBaseline: CoverageBaseline
  contracts: ContractExample[]
}

export const groups: { id: ContractGroup | 'all' }[] = [
  'all', 'core', 'token', 'nft', 'defi', 'staking', 'auctionGroup', 'distribution', 'payments', 'access', 'governance', 'architecture', 'cryptography', 'flashloans', 'security',
].map((id) => ({ id: id as ContractGroup | 'all' }))

async function readContent(url: string) {
  const response = await fetch(url)
  if (!response.ok)
    throw new Error(`Repository API returned ${response.status}`)
  const payload = (await response.json()) as { content: string }
  return payload.content
}

export async function fetchCatalog(): Promise<CatalogResponse> {
  const response = await fetch('/api/catalog', { cache: 'no-store' })
  if (!response.ok)
    throw new Error(`Repository API returned ${response.status}`)

  const catalog = (await response.json()) as Omit<
    CatalogResponse,
    'contracts'
  > & {
    contracts: ContractRecord[]
  }

  return {
    ...catalog,
    contracts: catalog.contracts.map((contract) => {
      const id = encodeURIComponent(contract.id)
      return {
        ...contract,
        loadSource: () => readContent(`/api/contracts/${id}/source`),
        loadFile: (path: string, framework: Framework = 'foundry') =>
          readContent(
            `/api/contracts/${id}/file?path=${encodeURIComponent(path)}&framework=${framework}`,
          ),
        loadTree: (framework: Framework) =>
          fetch(`/api/contracts/${id}/files?framework=${framework}`, { cache: 'no-store' }).then(async (response) => {
            if (!response.ok) throw new Error(`Repository API returned ${response.status}`)
            return response.json() as Promise<ProjectNode[]>
          }),
        loadDesignNote: contract.designPath
          ? (locale: Locale) => readContent(`/api/contracts/${id}/design?locale=${locale}`)
          : null,
      }
    }),
  }
}

export function localisedSummary(contract: ContractExample, locale: Locale): string {
  const entry = (summaries as Record<string, Partial<Record<Locale, string>>>)[contract.family]
  return entry?.[locale] ?? contract.summary
}

export function extractNotice(source: string) {
  const lines = source.split(/\r?\n/)
  const start = lines.findIndex((line) => line.includes('@notice'))
  if (start < 0) return ''

  const parts: string[] = []
  for (let index = start; index < lines.length; index += 1) {
    const match = lines[index].match(/^\s*\/\/\/\s?(.*)$/)
    if (!match) break

    const content = match[1].trim()
    if (content.startsWith('@notice')) {
      parts.push(content.slice('@notice'.length).trim())
    } else if (content.startsWith('@')) {
      break
    } else if (content) {
      parts.push(content)
    }
  }

  return parts.join(' ').replace(/\s+/g, ' ')
}
