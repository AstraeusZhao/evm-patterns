export type CodeLanguage = 'solidity' | 'typescript' | 'javascript' | 'python' | 'json' | 'toml' | 'bash' | 'markdown' | 'text'
export function fileLanguage(path: string): CodeLanguage {
  const extension = path.split('.').at(-1)?.toLowerCase()
  const languages: Record<string, CodeLanguage> = { sol: 'solidity', ts: 'typescript', js: 'javascript', py: 'python', json: 'json', toml: 'toml', sh: 'bash', md: 'markdown' }
  return languages[extension ?? ''] ?? 'text'
}
