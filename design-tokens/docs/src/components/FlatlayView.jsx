import { layers } from '../componentData'
import {
  t, Badge,
  AlarmCardPreview, EmptyStatePreview,
  ButtonVariantsPreview, BadgeVariantsPreview,
  ToggleRowPreview, PermissionRowPreview,
  TextFieldPreview, IntervalPickerPreview,
  CategoryGroupCardPreview,
} from './ComponentPreview'

// ─── Flatlay renderers for each component with live previews ───

const flatlayRenderers = {
  ChronirButton: () => (
    <div className="flatlay-grid">
      {[
        { label: 'Primary Action', bg: t.primary, fg: '#fff' },
        { label: 'Secondary', bg: t.bgTertiary, fg: t.textPrimary },
        { label: 'Delete', bg: t.error, fg: '#fff' },
        { label: 'Ghost Action', bg: 'transparent', fg: t.primary, border: true },
      ].map(v => (
        <div key={v.label} className="flatlay-item">
          <div style={{
            padding: `${t.md}px ${t.lg}px`,
            backgroundColor: v.bg,
            color: v.fg,
            borderRadius: t.radiusSm,
            fontWeight: 600,
            fontSize: 14,
            textAlign: 'center',
            border: v.border ? `1px solid ${t.primary}` : 'none',
            minWidth: 120,
          }}>
            {v.label}
          </div>
          <span className="flatlay-item-label">{v.label.toLowerCase().replace(' ', '-')}</span>
        </div>
      ))}
    </div>
  ),

  ChronirText: () => (
    <div className="flatlay-grid" style={{ flexDirection: 'column', alignItems: 'flex-start' }}>
      {[
        { name: 'displayAlarm', size: 48, weight: 700, sample: '12:00' },
        { name: 'headlineTime', size: 32, weight: 600, sample: '3:45 PM' },
        { name: 'headlineTitle', size: 24, weight: 600, sample: 'Screen Title' },
        { name: 'bodyPrimary', size: 16, weight: 400, sample: 'Primary body text' },
        { name: 'bodySecondary', size: 14, weight: 400, sample: 'Secondary metadata' },
        { name: 'captionCountdown', size: 14, weight: 500, sample: 'Alarm in 6h 32m' },
        { name: 'captionBadge', size: 12, weight: 500, sample: 'Weekly' },
      ].map(v => (
        <div key={v.name} style={{ display: 'flex', alignItems: 'baseline', gap: 12, width: '100%' }}>
          <span style={{
            fontSize: Math.min(v.size, 48), fontWeight: v.weight, color: t.textPrimary, lineHeight: 1.2,
          }}>
            {v.sample}
          </span>
          <span className="flatlay-item-label">.{v.name} — {v.size}px</span>
        </div>
      ))}
    </div>
  ),

  ChronirIcon: () => (
    <div className="flatlay-grid">
      {[
        { name: 'small', size: 16 },
        { name: 'medium', size: 24 },
        { name: 'large', size: 32 },
      ].map(v => (
        <div key={v.name} className="flatlay-item">
          <div style={{
            width: v.size, height: v.size, borderRadius: 4,
            backgroundColor: t.primary,
          }} />
          <span className="flatlay-item-label">.{v.name} ({v.size}pt)</span>
        </div>
      ))}
    </div>
  ),

  ChronirBadge: () => (
    <div className="flatlay-grid">
      {[
        { text: 'Weekly', color: t.badgeWeekly },
        { text: 'Monthly', color: t.badgeMonthly },
        { text: 'Annual', color: t.badgeAnnual },
        { text: 'Custom', color: t.badgeCustom },
        { text: 'Active', color: t.success },
        { text: 'Persistent', color: t.warning },
        { text: 'Snoozed', color: t.warning },
        { text: 'Missed', color: t.error },
      ].map(b => (
        <div key={b.text} className="flatlay-item">
          <Badge text={b.text} color={b.color} />
          <span className="flatlay-item-label">{b.text.toLowerCase()}</span>
        </div>
      ))}
    </div>
  ),

  AlarmCard: () => (
    <div className="flatlay-grid" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr' }}>
      <div>
        <AlarmCardPreview title="Morning Workout" cycleType="weekly" time="6:30 AM" countdown="6h 32m" state="active" persistent />
        <span className="flatlay-item-label" style={{ display: 'block', marginTop: 6, textAlign: 'center' }}>active</span>
      </div>
      <div>
        <AlarmCardPreview title="Pay Rent" cycleType="monthly" time="9:00 AM" state="inactive" />
        <span className="flatlay-item-label" style={{ display: 'block', marginTop: 6, textAlign: 'center' }}>inactive</span>
      </div>
      <div>
        <AlarmCardPreview title="Morning Workout" cycleType="weekly" time="6:30 AM" countdown="1h" state="snoozed" persistent />
        <span className="flatlay-item-label" style={{ display: 'block', marginTop: 6, textAlign: 'center' }}>snoozed</span>
      </div>
      <div>
        <AlarmCardPreview title="Pay Rent" cycleType="monthly" time="9:00 AM" state="overdue" />
        <span className="flatlay-item-label" style={{ display: 'block', marginTop: 6, textAlign: 'center' }}>overdue</span>
      </div>
    </div>
  ),

  AlarmFiringOverlay: () => (
    <div className="flatlay-grid flatlay-preview-full" style={{ padding: 0 }}>
      <div style={{
        width: '100%',
        backgroundColor: 'var(--bg-card)',
        borderRadius: t.radiusMd,
        padding: '32px 24px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 16,
        minHeight: 320,
        justifyContent: 'center',
      }}>
        <div style={{ fontSize: 20, fontWeight: 600, color: 'var(--text)' }}>Morning Workout</div>
        <div style={{ fontSize: 64, fontWeight: 700, color: 'var(--text)', lineHeight: 1 }}>6:30</div>
        <Badge text="Weekly" color={t.badgeWeekly} />
        <div style={{ display: 'flex', gap: t.md, marginTop: 16 }}>
          {[['1', 'hour'], ['1', 'day'], ['1', 'week']].map(([n, u]) => (
            <div key={u} style={{
              width: 72, height: 64,
              backgroundColor: 'var(--bg-surface)',
              borderRadius: t.radiusMd,
              display: 'flex', flexDirection: 'column',
              alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ fontSize: 20, fontWeight: 600, color: 'var(--text)' }}>{n}</span>
              <span style={{ fontSize: 11, color: 'var(--text-secondary)' }}>{u}</span>
            </div>
          ))}
        </div>
        <div style={{
          marginTop: 8,
          padding: `${t.md}px ${t.lg}px`,
          backgroundColor: t.primary,
          color: '#fff',
          borderRadius: t.radiusSm,
          fontWeight: 600,
          fontSize: 14,
          width: '80%',
          textAlign: 'center',
        }}>
          Dismiss
        </div>
      </div>
    </div>
  ),

  EmptyStateView: () => (
    <div className="flatlay-grid flatlay-preview-full" style={{ padding: 0 }}>
      <div style={{ width: '100%', borderRadius: 'var(--radius-sm)', overflow: 'hidden' }}>
        <EmptyStatePreview />
      </div>
    </div>
  ),

  AlarmToggleRow: () => (
    <div className="flatlay-grid flatlay-preview-full">
      <div style={{ width: '100%', borderRadius: 'var(--radius-sm)', overflow: 'hidden' }}>
        <ToggleRowPreview />
      </div>
    </div>
  ),

  PermissionStatusRow: () => (
    <div className="flatlay-grid flatlay-preview-full">
      <div style={{ width: '100%', borderRadius: 'var(--radius-sm)', overflow: 'hidden' }}>
        <PermissionRowPreview />
      </div>
    </div>
  ),

  LabeledTextField: () => (
    <div className="flatlay-grid flatlay-preview-full">
      <div style={{ width: '100%', maxWidth: 320 }}>
        <TextFieldPreview />
      </div>
    </div>
  ),

  IntervalPicker: () => (
    <div className="flatlay-grid flatlay-preview-full">
      <div style={{ width: '100%', maxWidth: 360 }}>
        <IntervalPickerPreview />
      </div>
    </div>
  ),

  CategoryGroupCard: () => (
    <div className="flatlay-grid" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr' }}>
      <CategoryGroupCardPreview
        category="Finance" icon="$" color="#22C55E"
        alarms={[
          { title: 'Pay Rent', date: 'Mar 1', enabled: true },
          { title: 'Credit Card Bill', date: 'Mar 15', enabled: true },
        ]}
        overflowCount={0}
      />
      <CategoryGroupCardPreview
        category="Health" icon="♥" color="#F87171"
        alarms={[
          { title: 'Annual Checkup', date: 'Apr 10', enabled: true },
          { title: 'Dentist', date: 'May 3', enabled: false },
          { title: 'Eye Exam', date: 'Jun 20', enabled: true },
        ]}
        overflowCount={2}
      />
    </div>
  ),
}

// ─── Variant summary for components without live preview ───

function VariantSummary({ component }) {
  if (!component.variants || component.variants.length === 0) {
    return (
      <div className="flatlay-variant-summary">
        <span className="flatlay-variant-chip">No variants — single configuration</span>
      </div>
    )
  }
  return (
    <div className="flatlay-variant-summary">
      {component.variants.map(v => (
        <span key={v.name} className="flatlay-variant-chip">
          {v.name}{v.detail ? `: ${v.detail}` : ''}
        </span>
      ))}
    </div>
  )
}

// ─── Main FlatlayView ───

export default function FlatlayView() {
  return (
    <div>
      {layers.map(layer => (
        <div key={layer.id}>
          <h3 className="flatlay-layer-title">{layer.label}</h3>
          {layer.components.map(component => {
            const Renderer = flatlayRenderers[component.name]
            return (
              <div key={component.name} className="flatlay-group">
                <div className="flatlay-group-header">
                  <div className="flatlay-group-name">{component.name}</div>
                  <div className="flatlay-group-file">{component.file}</div>
                </div>
                {Renderer ? <Renderer /> : <VariantSummary component={component} />}
              </div>
            )
          })}
        </div>
      ))}
    </div>
  )
}
