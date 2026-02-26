import { useState } from 'react'

const navTree = [
  {
    label: 'Foundations',
    children: [
      { id: 'colors', label: 'Color Palette' },
      { id: 'typography', label: 'Typography' },
      { id: 'spacing', label: 'Spacing' },
      { id: 'radius', label: 'Radius' },
      { id: 'animation', label: 'Animation' },
    ],
  },
  {
    label: 'Components',
    children: [
      { id: 'components', label: 'Component Catalog' },
    ],
  },
  {
    label: 'Screens',
    children: [
      { id: 'screens', label: 'App Screens' },
    ],
  },
  {
    label: 'Marketing',
    children: [
      { id: 'marketing', label: 'Launch Posts' },
    ],
  },
  {
    label: 'Architecture',
    children: [
      { id: 'iosArchitecture', label: 'iOS Architecture' },
    ],
  },
  {
    label: 'Support',
    children: [
      { id: 'faq', label: 'FAQ' },
    ],
  },
]

export default function Sidebar({ active, onNavigate }) {
  const [collapsed, setCollapsed] = useState({})

  const toggle = (label) => {
    setCollapsed(prev => ({ ...prev, [label]: !prev[label] }))
  }

  return (
    <aside className="sidebar">
      <nav className="sidebar-nav">
        {navTree.map(group => {
          const isCollapsed = collapsed[group.label]
          const hasActive = group.children.some(c => c.id === active)
          return (
            <div key={group.label} className="sidebar-group">
              <button
                className={`sidebar-group-label ${hasActive ? 'has-active' : ''}`}
                onClick={() => toggle(group.label)}
              >
                <svg
                  className={`sidebar-chevron ${isCollapsed ? '' : 'open'}`}
                  width="16" height="16" viewBox="0 0 16 16" fill="none"
                >
                  <path d="M6 4l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
                {group.label}
              </button>
              {!isCollapsed && (
                <div className="sidebar-children">
                  {group.children.map(item => (
                    <button
                      key={item.id}
                      className={`sidebar-item ${active === item.id ? 'active' : ''}`}
                      onClick={() => onNavigate(item.id)}
                    >
                      {item.label}
                    </button>
                  ))}
                </div>
              )}
            </div>
          )
        })}
      </nav>
    </aside>
  )
}
