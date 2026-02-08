import { useState, useEffect } from 'react'

const sections = [
  { id: 'colors', num: '01', label: 'Color' },
  { id: 'typography', num: '02', label: 'Typography' },
  { id: 'spacing', num: '03', label: 'Spacing' },
  { id: 'radius', num: '04', label: 'Radius' },
  { id: 'animation', num: '05', label: 'Animation' },
  { id: 'components', num: '06', label: 'Components' },
]

export default function TopNav() {
  const [active, setActive] = useState(window.location.hash.slice(1) || 'colors')

  useEffect(() => {
    const onHash = () => setActive(window.location.hash.slice(1) || 'colors')
    window.addEventListener('hashchange', onHash)
    return () => window.removeEventListener('hashchange', onHash)
  }, [])

  return (
    <header className="topnav">
      <div className="topnav-brand">
        <span className="topnav-logo">Chronir</span>
        <span className="topnav-subtitle">Design System</span>
      </div>
      <nav>
        {sections.map(s => (
          <a
            key={s.id}
            href={`#${s.id}`}
            className={active === s.id ? 'active' : ''}
          >
            <span className="topnav-num">{s.num}</span>
            {s.label}
          </a>
        ))}
      </nav>
    </header>
  )
}
