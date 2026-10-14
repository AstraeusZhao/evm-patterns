export type ContractGroup =
  'core' | 'token' | 'defi' | 'governance' | 'security'

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
  loadFile: (path: string) => Promise<string>
  loadDesignNote: (() => Promise<string>) | null
}

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

export const groups: { id: ContractGroup | 'all'; label: string }[] = [
  { id: 'all', label: '全部示例' },
  { id: 'core', label: '基础模式' },
  { id: 'token', label: '代币与 NFT' },
  { id: 'defi', label: 'DeFi 与市场' },
  { id: 'governance', label: '治理与权限' },
  { id: 'security', label: '安全示例' },
]

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
        loadFile: (path: string) =>
          readContent(
            `/api/contracts/${id}/file?path=${encodeURIComponent(path)}`,
          ),
        loadDesignNote: contract.designPath
          ? () => readContent(`/api/contracts/${id}/design`)
          : null,
      }
    }),
  }
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
