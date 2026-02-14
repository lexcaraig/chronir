import { useState, useEffect } from 'react'
import Sidebar from './components/Sidebar'
import ColorSection from './components/ColorSection'
import TypographySection from './components/TypographySection'
import SpacingSection from './components/SpacingSection'
import RadiusSection from './components/RadiusSection'
import AnimationSection from './components/AnimationSection'
import ComponentsSection from './components/ComponentsSection'

const sections = {
  colors: { component: ColorSection, title: 'Color Palette', description: 'A selection of colors that work together to create consistency in apps.' },
  typography: { component: TypographySection, title: 'Typography', description: 'Type scale from display (120pt alarm time) down to captions (12pt badges).' },
  spacing: { component: SpacingSection, title: 'Spacing', description: 'Spacing scale from xxs (4pt) to xxl (48pt), plus component-specific tokens.' },
  radius: { component: RadiusSection, title: 'Radius', description: 'Corner radius scale from sm (8pt) to full (9999pt, fully rounded).' },
  animation: { component: AnimationSection, title: 'Animation', description: 'Duration presets and spring physics parameters for interactive animations.' },
  components: { component: ComponentsSection, title: 'Component Catalog', description: 'Atomic Design components from tokens through organisms.' },
}

export default function App() {
  const [active, setActive] = useState(() => {
    const hash = window.location.hash.slice(1)
    return hash && sections[hash] ? hash : 'colors'
  })

  useEffect(() => {
    const onHash = () => {
      const hash = window.location.hash.slice(1)
      if (hash && sections[hash]) setActive(hash)
    }
    window.addEventListener('hashchange', onHash)
    return () => window.removeEventListener('hashchange', onHash)
  }, [])

  const navigate = (id) => {
    setActive(id)
    window.location.hash = id
    // Scroll content area to top
    document.querySelector('.main-content')?.scrollTo(0, 0)
  }

  const section = sections[active]
  const SectionComponent = section.component

  return (
    <div className="app">
      {/* Toolbar */}
      <header className="toolbar">
        <div className="toolbar-brand">
          <span className="toolbar-logo">Chronir</span>
          <span className="toolbar-divider" />
          <span className="toolbar-subtitle">Design System</span>
        </div>
        <nav className="toolbar-nav">
          <a
            className={active !== 'components' ? 'active' : ''}
            onClick={() => navigate('colors')}
          >
            Foundations
          </a>
          <a
            className={active === 'components' ? 'active' : ''}
            onClick={() => navigate('components')}
          >
            Components
          </a>
        </nav>
      </header>

      {/* Body */}
      <div className="body-layout">
        <Sidebar active={active} onNavigate={navigate} />
        <main className="main-content">
          <div className="content-inner">
            <SectionComponent />
          </div>
        </main>
      </div>
    </div>
  )
}
