import { useState } from 'react'
import { colors } from '../tokens'

const tierOrder = ['primitive', 'surface', 'accent', 'alarm', 'firing', 'badge', 'button']
const tierLabels = {
  primitive: 'Primitives',
  surface: 'Semantic — Surface',
  accent: 'Semantic — Accent',
  alarm: 'Component — Alarm',
  firing: 'Component — Firing',
  badge: 'Component — Badge',
  button: 'Component — Button',
}

function CopyToast({ visible }) {
  if (!visible) return null
  return <div className="copy-toast">Copied!</div>
}

function PrimitiveStrip({ family, tokens }) {
  const [toast, setToast] = useState(false)

  const copy = (hex) => {
    navigator.clipboard.writeText(hex)
    setToast(true)
    setTimeout(() => setToast(false), 1500)
  }

  return (
    <div className="color-strip">
      <div className="color-strip-label">{family}</div>
      <div className="color-strip-row">
        {tokens.map(t => (
          <div
            key={t.path}
            className="color-chip"
            onClick={() => copy(t.resolvedValue)}
          >
            <div className="color-tooltip">{t.resolvedValue}</div>
            <div
              className="color-chip-swatch"
              style={{ backgroundColor: t.resolvedValue }}
            />
            <div className="color-chip-shade">{t.name}</div>
          </div>
        ))}
      </div>
      <CopyToast visible={toast} />
    </div>
  )
}

function SemanticStrip({ label, tokens }) {
  const [toast, setToast] = useState(false)

  const copy = (hex) => {
    navigator.clipboard.writeText(hex)
    setToast(true)
    setTimeout(() => setToast(false), 1500)
  }

  return (
    <div className="color-strip">
      <div className="color-strip-label">{label}</div>
      <div className="color-strip-row">
        {tokens.map(t => {
          const isRef = typeof t.rawValue === 'string' && t.rawValue.startsWith('{')
          const refName = isRef ? t.rawValue.replace(/[{}]/g, '') : null
          return (
            <div
              key={t.path}
              className="color-token-chip"
              onClick={() => copy(t.resolvedValue)}
            >
              <div className="color-tooltip">{t.resolvedValue}</div>
              <div
                className="color-token-swatch"
                style={{ backgroundColor: t.resolvedValue }}
              />
              <div className="color-token-name">{t.name}</div>
              {refName && <div className="color-token-ref">{refName}</div>}
            </div>
          )
        })}
      </div>
      <CopyToast visible={toast} />
    </div>
  )
}

export default function ColorSection() {
  const groups = colors.grouped

  // Split primitives by color family (second segment of path: color.primitive.blue.500 → blue)
  const primitiveTokens = groups.primitive || []
  const families = {}
  for (const t of primitiveTokens) {
    // path is e.g. "color.primitive.blue.500"
    const parts = t.path.split('.')
    const family = parts[2] || 'other'
    if (!families[family]) families[family] = []
    families[family].push(t)
  }

  return (
    <section className="section" id="colors">
      <h2 className="section-title">
        <span className="section-number">01</span>
        COLOR PALETTE
      </h2>
      <p className="section-description">
        Three-tier color system: primitives (raw hex), semantic (surface, accent), and component-level tokens. Hover for hex, click to copy.
      </p>

      {/* Primitives — horizontal strips by family */}
      <h3 className="group-title">Primitives</h3>
      {Object.entries(families).map(([family, tokens]) => (
        <PrimitiveStrip key={family} family={family} tokens={tokens} />
      ))}

      {/* Semantic + Component tiers */}
      {tierOrder.filter(k => k !== 'primitive').map(key => {
        const tokens = groups[key]
        if (!tokens) return null
        return (
          <SemanticStrip
            key={key}
            label={tierLabels[key] || key}
            tokens={tokens}
          />
        )
      })}
    </section>
  )
}
