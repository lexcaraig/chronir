import { typography } from '../tokens'

const fontWeightMap = {
  regular: 400,
  medium: 500,
  semibold: 600,
  bold: 700,
}

export default function TypographySection() {
  const groups = typography.grouped

  return (
    <section className="section" id="typography">
      <h2 className="section-title">
        <span className="section-number">02</span>
        TYPOGRAPHY
      </h2>
      <p className="section-description">
        Type scale from display (120pt alarm time) down to captions (12pt badges). System font stack with platform-native rendering.
      </p>

      {/* Typeface hero */}
      <div className="typeface-hero">
        <div className="typeface-hero-glyph">Aa</div>
        <div className="typeface-hero-name">System Font Stack</div>
        <div className="typeface-hero-weights">
          <div className="typeface-hero-weight">Regular <span>400</span></div>
          <div className="typeface-hero-weight">Medium <span>500</span></div>
          <div className="typeface-hero-weight">Semibold <span>600</span></div>
          <div className="typeface-hero-weight">Bold <span>700</span></div>
        </div>
      </div>

      {/* Type scale table */}
      {Object.entries(groups).map(([group, tokens]) => (
        <div key={group}>
          <h3 className="group-title">{group}</h3>

          <div className="type-weight-header">
            <div className="type-weight-label">Name</div>
            <div className="type-weight-label">Sample</div>
            <div className="type-weight-label">Size</div>
            <div className="type-weight-label">Line</div>
            <div className="type-weight-label">Weight</div>
          </div>

          {tokens.map(token => {
            const size = parseFloat(token.fontSize)
            const clampedSize = Math.min(size, 64)
            const weight = fontWeightMap[token.fontWeight] || 400

            return (
              <div className="type-scale-row" key={token.path}>
                <div className="type-scale-info">
                  <div className="type-scale-name">{token.name}</div>
                </div>

                <div className="type-sample-cell">
                  <div
                    className="type-sample-text"
                    style={{
                      fontSize: `${clampedSize}px`,
                      lineHeight: `${parseFloat(token.lineHeight) * (clampedSize / size)}px`,
                      fontWeight: weight,
                    }}
                  >
                    {token.name}
                  </div>
                  {size > 64 && (
                    <div className="type-sample-weight">(shown at 64px, actual: {size}px)</div>
                  )}
                </div>

                <div className="type-value-cell">{token.fontSize}px</div>
                <div className="type-value-cell">{token.lineHeight}px</div>
                <div className="type-value-cell">{token.fontWeight}</div>
              </div>
            )
          })}
        </div>
      ))}
    </section>
  )
}
