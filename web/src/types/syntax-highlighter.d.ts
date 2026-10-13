declare module 'react-syntax-highlighter/dist/esm/prism-light' {
  import type { ComponentType } from 'react'
  import type { SyntaxHighlighterProps } from 'react-syntax-highlighter'

  const SyntaxHighlighter: ComponentType<SyntaxHighlighterProps> & {
    registerLanguage: (name: string, language: unknown) => void
  }

  export default SyntaxHighlighter
}

declare module 'react-syntax-highlighter/dist/esm/styles/prism/one-dark' {
  import type { CSSProperties } from 'react'

  const style: Record<string, CSSProperties>
  export default style
}

declare module 'react-syntax-highlighter/dist/esm/languages/prism/solidity' {
  const grammar: unknown
  export default grammar
}
