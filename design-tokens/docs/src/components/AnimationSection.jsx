import { animation } from '../tokens'

export default function AnimationSection() {
  const groups = animation.grouped

  return (
    <section className="section" id="animation">
      <h2 className="section-title">
        <span className="section-number">05</span>
        ANIMATION
      </h2>
      <p className="section-description">
        Duration presets (instant to slow) and spring physics parameters for interactive animations.
      </p>

      {Object.entries(groups).map(([group, tokens]) => (
        <div key={group}>
          <h3 className="group-title">{group}</h3>
          <table className="anim-table">
            <thead>
              <tr>
                <th>Token</th>
                <th>Value</th>
              </tr>
            </thead>
            <tbody>
              {tokens.map(token => (
                <tr key={token.path}>
                  <td>{token.path}</td>
                  <td>
                    {token.resolvedValue}
                    {token.type === 'duration' ? 'ms' : ''}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
    </section>
  )
}
