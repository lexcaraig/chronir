import TopNav from './components/Sidebar'
import ColorSection from './components/ColorSection'
import TypographySection from './components/TypographySection'
import SpacingSection from './components/SpacingSection'
import RadiusSection from './components/RadiusSection'
import AnimationSection from './components/AnimationSection'
import ComponentsSection from './components/ComponentsSection'

export default function App() {
  return (
    <div className="app">
      <TopNav />
      <main className="content">
        <ColorSection />
        <TypographySection />
        <SpacingSection />
        <RadiusSection />
        <AnimationSection />
        <ComponentsSection />
      </main>
    </div>
  )
}
