import { useState } from 'react'
import { swiftName, kotlinName } from '../utils/platformNames'

export default function CodeSnippet({ tokenPath }) {
  const [tab, setTab] = useState('swift')

  const swift = swiftName(tokenPath)
  const kotlin = kotlinName(tokenPath)

  return (
    <div className="code-snippet">
      <div className="code-tabs">
        <button
          className={`code-tab ${tab === 'swift' ? 'active' : ''}`}
          onClick={() => setTab('swift')}
        >
          Swift
        </button>
        <button
          className={`code-tab ${tab === 'kotlin' ? 'active' : ''}`}
          onClick={() => setTab('kotlin')}
        >
          Kotlin
        </button>
      </div>
      <div className="code-body">
        {tab === 'swift' ? swift : kotlin}
      </div>
    </div>
  )
}
