import { useState } from 'react'
import CodeSnippet from './CodeSnippet'

export default function TokenCard({ token, preview }) {
  const [toast, setToast] = useState(null)

  function copyValue() {
    navigator.clipboard.writeText(token.resolvedValue ?? token.rawValue)
    setToast('Copied!')
    setTimeout(() => setToast(null), 1500)
  }

  return (
    <div className="token-card" onClick={copyValue}>
      {preview}
      <div className="token-card-name">{token.path}</div>
      <div className="token-card-value">{token.resolvedValue ?? token.rawValue}</div>
      {token.description && (
        <div className="token-card-description">{token.description}</div>
      )}
      <CodeSnippet tokenPath={token.path} />
      {toast && <div className="copy-toast">{toast}</div>}
    </div>
  )
}
