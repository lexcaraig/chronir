import { useState } from 'react'
import { colors, lightTheme, darkTheme } from '../tokens'

const tierOrder = ['primitive', 'theme', 'surface', 'accent', 'alarm', 'firing', 'badge', 'button']
const tierLabels = {
  primitive: 'Primitives',
  theme: 'Theme Tokens',
  surface: 'Semantic — Surface',
  accent: 'Semantic — Accent',
  alarm: 'Component — Alarm',
  firing: 'Component — Firing',
  badge: 'Component — Badge',
  button: 'Component — Button',
}

// Families to show as "Neutral Ramps" instead of inline with chromatic primitives
const neutralFamilies = new Set(['neutral', 'neutralAlpha', 'darkNeutral', 'darkNeutralAlpha'])

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

function NeutralRampStrip({ label, tokens, isDark }) {
  const [toast, setToast] = useState(false)

  const copy = (hex) => {
    navigator.clipboard.writeText(hex)
    setToast(true)
    setTimeout(() => setToast(false), 1500)
  }

  // Sort by numeric shade (neg100 → -100 for sorting)
  const sorted = [...tokens].sort((a, b) => {
    const numA = a.name === 'neg100' ? -100 : parseInt(a.name, 10)
    const numB = b.name === 'neg100' ? -100 : parseInt(b.name, 10)
    return numA - numB
  })

  return (
    <div className="color-strip">
      <div className="color-strip-label">{label}</div>
      <div className="color-strip-row">
        {sorted.map(t => (
          <div
            key={t.path}
            className="color-chip"
            onClick={() => copy(t.resolvedValue)}
          >
            <div className="color-tooltip">{t.resolvedValue}</div>
            <div
              className="color-chip-swatch"
              style={{
                backgroundColor: t.resolvedValue,
                border: isDark ? '1px solid rgba(255,255,255,0.06)' : '1px solid rgba(0,0,0,0.08)',
              }}
            />
            <div className="color-chip-shade">{t.name === 'neg100' ? '-100' : t.name}</div>
            <div className="color-chip-hex">{t.resolvedValue}</div>
          </div>
        ))}
      </div>
      <CopyToast visible={toast} />
    </div>
  )
}

function ThemeTokensSection() {
  const [toast, setToast] = useState(false)

  const copy = (hex) => {
    navigator.clipboard.writeText(hex)
    setToast(true)
    setTimeout(() => setToast(false), 1500)
  }

  const roles = Object.keys(lightTheme)

  return (
    <>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
        {/* Light column */}
        <div>
          <div className="color-strip-label">Light Theme</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {roles.map(role => (
              <div
                key={`light-${role}`}
                className="color-token-chip"
                onClick={() => copy(lightTheme[role])}
                style={{ flexDirection: 'row', gap: '10px', minWidth: 0, alignItems: 'center', padding: '4px 0' }}
              >
                <div
                  style={{
                    width: 32, height: 32, borderRadius: 6, flexShrink: 0,
                    backgroundColor: lightTheme[role],
                    border: '1px solid rgba(0,0,0,0.08)',
                  }}
                />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div className="color-token-name" style={{ textAlign: 'left', fontSize: 12 }}>{role}</div>
                  <div className="color-token-value" style={{ textAlign: 'left' }}>{lightTheme[role]}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
        {/* Dark column */}
        <div>
          <div className="color-strip-label">Dark Theme</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {roles.map(role => (
              <div
                key={`dark-${role}`}
                className="color-token-chip"
                onClick={() => copy(darkTheme[role])}
                style={{ flexDirection: 'row', gap: '10px', minWidth: 0, alignItems: 'center', padding: '4px 0' }}
              >
                <div
                  style={{
                    width: 32, height: 32, borderRadius: 6, flexShrink: 0,
                    backgroundColor: darkTheme[role],
                    border: '1px solid rgba(255,255,255,0.06)',
                  }}
                />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div className="color-token-name" style={{ textAlign: 'left', fontSize: 12 }}>{role}</div>
                  <div className="color-token-value" style={{ textAlign: 'left' }}>{darkTheme[role]}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <CopyToast visible={toast} />
    </>
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

  // Split primitives by color family
  const primitiveTokens = groups.primitive || []
  const families = {}
  for (const t of primitiveTokens) {
    const parts = t.path.split('.')
    const family = parts[2] || 'other'
    if (!families[family]) families[family] = []
    families[family].push(t)
  }

  // Separate chromatic primitives from neutral ramps
  const chromaticFamilies = Object.entries(families).filter(([f]) => !neutralFamilies.has(f))
  const lightNeutrals = families.neutral || []
  const lightAlphas = families.neutralAlpha || []
  const darkNeutrals = families.darkNeutral || []
  const darkAlphas = families.darkNeutralAlpha || []

  return (
    <section className="section" id="colors">
      <h2 className="section-title">
        <span className="section-number">01</span>
        COLOR PALETTE
      </h2>
      <p className="section-description">
        Three-tier color system: primitives (raw hex), semantic (surface, accent), and component-level tokens. Hover for hex, click to copy.
      </p>

      {/* Chromatic Primitives */}
      <h3 className="group-title">Primitives</h3>
      {chromaticFamilies.map(([family, tokens]) => (
        <PrimitiveStrip key={family} family={family} tokens={tokens} />
      ))}

      {/* Neutral Ramps — always show both */}
      <h3 className="group-title">Neutral Ramps</h3>
      <NeutralRampStrip label="Light Neutrals" tokens={lightNeutrals} isDark={false} />
      {lightAlphas.length > 0 && (
        <NeutralRampStrip label="Light Neutral Alpha" tokens={lightAlphas} isDark={false} />
      )}
      <NeutralRampStrip label="Dark Neutrals" tokens={darkNeutrals} isDark={true} />
      {darkAlphas.length > 0 && (
        <NeutralRampStrip label="Dark Neutral Alpha" tokens={darkAlphas} isDark={true} />
      )}

      {/* Theme Tokens — side by side light/dark */}
      <h3 className="group-title">Theme Tokens</h3>
      <p className="section-description" style={{ marginBottom: 16 }}>
        Semantic role mappings for Light and Dark themes. "System" theme uses iOS 26 Liquid Glass at runtime — no token representation.
      </p>
      <ThemeTokensSection />

      {/* Semantic + Component tiers */}
      {tierOrder.filter(k => k !== 'primitive' && k !== 'theme').map(key => {
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
