import SyntaxHighlighter from 'react-syntax-highlighter/dist/esm/prism-light'
import oneDark from 'react-syntax-highlighter/dist/esm/styles/prism/one-dark'
import solidity from 'react-syntax-highlighter/dist/esm/languages/prism/solidity'

SyntaxHighlighter.registerLanguage('solidity', solidity)

export default function SolidityCode({ source }: { source: string }) {
  return (
    <SyntaxHighlighter
      codeTagProps={{ className: 'solidity-code' }}
      customStyle={{ background: 'transparent', fontSize: '12px', lineHeight: '1.7', margin: 0, minHeight: '100%', padding: '16px 18px' }}
      language="solidity"
      lineNumberStyle={{ color: '#67766d', minWidth: '3.25em', paddingRight: '1.25em', textAlign: 'right' }}
      showLineNumbers
      style={oneDark}
      wrapLongLines={false}
    >
      {source}
    </SyntaxHighlighter>
  )
}
