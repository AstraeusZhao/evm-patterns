import SyntaxHighlighter from 'react-syntax-highlighter/dist/esm/prism-light'
import oneDark from 'react-syntax-highlighter/dist/esm/styles/prism/one-dark'
import solidity from 'react-syntax-highlighter/dist/esm/languages/prism/solidity'
import typescript from 'react-syntax-highlighter/dist/esm/languages/prism/typescript'

SyntaxHighlighter.registerLanguage('solidity', solidity)
SyntaxHighlighter.registerLanguage('typescript', typescript)

export default function SolidityCode({
  source,
  language = 'solidity',
}: {
  source: string
  language?: 'solidity' | 'typescript'
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
