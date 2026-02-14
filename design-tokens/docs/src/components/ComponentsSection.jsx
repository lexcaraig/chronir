import { useState } from 'react'
import { layers } from '../componentData'
import { previews } from './ComponentPreview'
import FlatlayView from './FlatlayView'

function PropTable({ props }) {
  if (!props || props.length === 0) return null
  return (
    <table className="prop-table">
      <thead>
        <tr>
          <th>Prop</th>
          <th>Type</th>
          <th>Default</th>
        </tr>
      </thead>
      <tbody>
        {props.map(p => (
          <tr key={p.name}>
            <td className="prop-name">{p.name}</td>
            <td className="prop-type">{p.type}</td>
            <td className="prop-default">{p.default || (p.required ? 'required' : '—')}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}

function TokenList({ tokens }) {
  if (!tokens) return null
  const entries = Object.entries(tokens)
  if (entries.length === 0) return null
  return (
    <div className="token-usage">
      <div className="token-usage-title">Tokens Used</div>
      <div className="token-usage-list">
        {entries.map(([category, value]) => (
          <div key={category} className="token-usage-item">
            <span className="token-usage-category">{category}</span>
            <span className="token-usage-value">{value}</span>
          </div>
        ))}
      </div>
    </div>
  )
}

function VariantPreview({ variants, component }) {
  if (!variants || variants.length === 0) return null

  if (component.name === 'ChronirButton') {
    return (
      <div className="variant-row">
        {variants.map(v => (
          <div key={v.name} className="variant-button-preview">
            <div
              className="variant-button"
              style={{
                backgroundColor: v.bg === 'transparent' ? 'transparent' : v.bg,
                color: v.fg,
                border: v.bg === 'transparent' ? '1px solid var(--border)' : 'none',
              }}
            >
              {v.label}
            </div>
            <span className="variant-label">{v.name}</span>
          </div>
        ))}
      </div>
    )
  }

  if (component.name === 'ChronirText') {
    return (
      <div className="variant-text-list">
        {variants.map(v => (
          <div key={v.name} className="variant-text-row">
            <span
              className="variant-text-sample"
              style={{
                fontSize: `${Math.min(parseInt(v.size), 48)}px`,
                fontWeight: v.weight === 'bold' ? 700 : v.weight === 'semibold' ? 600 : v.weight === 'medium' ? 500 : 400,
              }}
            >
              {v.sample}
            </span>
            <span className="variant-text-meta">.{v.name} — {v.size}, {v.weight}</span>
          </div>
        ))}
      </div>
    )
  }

  if (component.name === 'ChronirBadge') {
    return (
      <div className="variant-row">
        {variants.map(v => (
          <div key={v.name} className="variant-badge-preview">
            <span className="variant-badge" style={{ backgroundColor: v.bg }}>
              {v.name}
            </span>
          </div>
        ))}
      </div>
    )
  }

  if (component.name === 'ChronirIcon') {
    return (
      <div className="variant-row" style={{ gap: 24 }}>
        {variants.map(v => (
          <div key={v.name} className="variant-icon-preview">
            <div
              className="variant-icon-box"
              style={{ width: parseInt(v.size), height: parseInt(v.size) }}
            />
            <span className="variant-label">.{v.name} ({v.size})</span>
          </div>
        ))}
      </div>
    )
  }

  if (component.name === 'AlarmCard') {
    return (
      <div className="variant-card-grid">
        {variants.map(v => (
          <div
            key={v.name}
            className="variant-card-preview"
            style={{
              borderColor: v.borderColor || 'var(--border)',
              borderWidth: v.borderColor ? 2 : 1,
              opacity: v.name === 'inactive' ? 0.5 : 1,
            }}
          >
            <div className="variant-card-title">{v.name}</div>
            <div className="variant-card-detail">{v.detail}</div>
          </div>
        ))}
      </div>
    )
  }

  return (
    <div className="variant-list">
      {variants.map(v => (
        <div key={v.name || v.detail} className="variant-item">
          <span className="variant-name">{v.name}</span>
          {v.detail && <span className="variant-detail">{v.detail}</span>}
        </div>
      ))}
    </div>
  )
}

function ComposedOf({ components }) {
  if (!components || components.length === 0) return null
  return (
    <div className="composed-of">
      <span className="composed-of-label">Composed of:</span>
      {components.map(c => (
        <span key={c} className="composed-of-chip">{c}</span>
      ))}
    </div>
  )
}

function ComponentCard({ component }) {
  const [expanded, setExpanded] = useState(false)
  const PreviewComponent = previews[component.name]

  return (
    <div className="component-card">
      <div className="component-card-header" onClick={() => setExpanded(!expanded)}>
        <div>
          <div className="component-card-name">{component.name}</div>
          <div className="component-card-file">{component.file}</div>
        </div>
        <span className="component-card-toggle">{expanded ? '−' : '+'}</span>
      </div>
      <div className="component-card-desc">{component.description}</div>

      {PreviewComponent ? (
        <div className="component-live-preview">
          <PreviewComponent />
        </div>
      ) : (
        <VariantPreview variants={component.variants} component={component} />
      )}

      {expanded && (
        <div className="component-card-details">
          <PropTable props={component.props} />
          <TokenList tokens={component.tokens} />
          <ComposedOf components={component.composedOf} />
          {component.usage && (
            <div className="component-usage">
              <div className="component-usage-title">Usage</div>
              <pre className="component-usage-code">{component.usage}</pre>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

export default function ComponentsSection() {
  const [tab, setTab] = useState('flatlay')

  return (
    <section className="section" id="components">
      <h2 className="section-title">
        <span className="section-number">06</span>
        COMPONENTS
      </h2>
      <p className="section-description">
        Atomic Design component hierarchy — atoms, molecules, organisms, and templates.
        {tab === 'spec' ? ' Click a card header to expand full details.' : ' Visual gallery of all components and states.'}
      </p>

      <div className="component-tabs">
        <button
          className={`component-tab${tab === 'flatlay' ? ' active' : ''}`}
          onClick={() => setTab('flatlay')}
        >
          Flatlay
        </button>
        <button
          className={`component-tab${tab === 'spec' ? ' active' : ''}`}
          onClick={() => setTab('spec')}
        >
          Spec
        </button>
      </div>

      {tab === 'flatlay' ? (
        <FlatlayView />
      ) : (
        layers.map(layer => (
          <div key={layer.id}>
            <h3 className="group-title">{layer.label}</h3>
            <p className="layer-description">{layer.description}</p>
            <div className="component-list">
              {layer.components.map(c => (
                <ComponentCard key={c.name} component={c} />
              ))}
            </div>
          </div>
        ))
      )}
    </section>
  )
}
