import SyntaxHighlighter from 'react-syntax-highlighter/dist/esm/prism-light'
import oneDark from 'react-syntax-highlighter/dist/esm/styles/prism/one-dark'
import solidity from 'react-syntax-highlighter/dist/esm/languages/prism/solidity'
import typescript from 'react-syntax-highlighter/dist/esm/languages/prism/typescript'
import javascript from 'react-syntax-highlighter/dist/esm/languages/prism/javascript'
import python from 'react-syntax-highlighter/dist/esm/languages/prism/python'
import json from 'react-syntax-highlighter/dist/esm/languages/prism/json'
import toml from 'react-syntax-highlighter/dist/esm/languages/prism/toml'
import bash from 'react-syntax-highlighter/dist/esm/languages/prism/bash'
import markdown from 'react-syntax-highlighter/dist/esm/languages/prism/markdown'
import type { CodeLanguage } from './codeLanguages'

SyntaxHighlighter.registerLanguage('solidity', solidity)
SyntaxHighlighter.registerLanguage('typescript', typescript)
SyntaxHighlighter.registerLanguage('javascript', javascript)
SyntaxHighlighter.registerLanguage('python', python)
SyntaxHighlighter.registerLanguage('json', json)
SyntaxHighlighter.registerLanguage('toml', toml)
SyntaxHighlighter.registerLanguage('bash', bash)
SyntaxHighlighter.registerLanguage('markdown', markdown)

export default function SolidityCode({
  source,
  language = 'solidity',
}: {
  source: string
  language?: CodeLanguage
}) {
  return (
    <SyntaxHighlighter
      codeTagProps={{
        className: 'solidity-code',
        style: { whiteSpace: 'pre-wrap', overflowWrap: 'anywhere' },
      }}
      customStyle={{
        background: 'transparent',
        fontSize: '12px',
        lineHeight: '1.7',
        margin: 0,
        minHeight: '100%',
        padding: '16px 18px',
      }}
      language={language}
      lineNumberStyle={{
        color: '#67766d',
        minWidth: '3.25em',
        paddingRight: '1.25em',
        textAlign: 'right',
      }}
      showLineNumbers
      wrapLines
      style={oneDark}
      wrapLongLines
    >
      {source}
    </SyntaxHighlighter>
  )
}
