import { spacing } from '../tokens'

const maxBar = 300

export default function SpacingSection() {
  const groups = spacing.grouped
  const scaleTokens = groups.scale || []
  const componentKeys = Object.keys(groups).filter(k => k !== 'scale')
  const maxVal = Math.max(...spacing.all.map(t => parseFloat(t.resolvedValue)))

  return (
    <section className="section" id="spacing">
      <h2 className="section-title">
        <span className="section-number">03</span>
        SPACING
      </h2>
      <p className="section-description">
        Spacing scale from xxs (4pt) to xxl (48pt), plus component-specific tokens for cards, lists, touch targets, and the firing screen.
      </p>

      {/* Scale tokens */}
      {scaleTokens.length > 0 && (
        <>
          <h3 className="group-title">Scale</h3>
          {scaleTokens.map(token => {
            const val = parseFloat(token.resolvedValue)
            const width = (val / maxVal) * maxBar
            return (
              <div className="spacing-row" key={token.path}>
                <div className="spacing-label">{token.path}</div>
                <div className="spacing-value">{token.resolvedValue}pt</div>
                <div className="spacing-bar-track">
                  <div className="spacing-bar" style={{ width: `${width}px` }} />
                </div>
              </div>
            )
          })}
        </>
      )}

      {/* Component-specific tokens */}
      {componentKeys.map(key => {
        const tokens = groups[key]
        if (!tokens) return null
        return (
          <div key={key}>
            <h3 className="group-title">{key}</h3>
            {tokens.map(token => {
              const val = parseFloat(token.resolvedValue)
              const width = (val / maxVal) * maxBar
              return (
                <div className="spacing-row" key={token.path}>
                  <div className="spacing-label">{token.path}</div>
                  <div className="spacing-value">{token.resolvedValue}pt</div>
                  <div className="spacing-bar-track">
                    <div className="spacing-bar" style={{ width: `${width}px` }} />
                  </div>
                </div>
              )
            })}
          </div>
        )
      })}
    </section>
  )
}
