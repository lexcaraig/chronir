import { radius } from '../tokens'

export default function RadiusSection() {
  return (
    <section className="section" id="radius">
      <h2 className="section-title">
        <span className="section-number">04</span>
        RADIUS
      </h2>
      <p className="section-description">
        Corner radius scale from sm (8pt) to full (9999pt, fully rounded).
      </p>

      <div className="radius-row">
        {radius.all.map(token => {
          const val = parseFloat(token.resolvedValue)
          const display = val > 100 ? 50 : val
          return (
            <div className="radius-item" key={token.path}>
              <div
                className="radius-box"
                style={{ borderRadius: `${display}px` }}
              />
              <div className="radius-label">{token.name}</div>
              <div className="radius-value">{token.resolvedValue}pt</div>
            </div>
          )
        })}
      </div>
    </section>
  )
}
