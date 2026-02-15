import { resolvedLookup } from '../tokens'

// Pull actual token values for rendering
// Theme-aware colors use CSS variables; accent/status colors are theme-independent
const t = {
  // Theme-aware colors (CSS variables)
  surfaceCard: 'var(--bg-card)',
  bgPrimary: 'var(--bg)',
  bgTertiary: 'var(--bg-surface)',
  textPrimary: 'var(--text)',
  textSecondary: 'var(--text-secondary)',
  textDisabled: 'var(--text-muted)',
  // Accent color (theme-aware: blue in dark, dark neutral in light)
  primary: 'var(--accent)',
  warning: 'var(--color-warning)',
  error: 'var(--color-error)',
  success: 'var(--color-success)',
  firingBg: resolvedLookup['color.firing.background'] || '#111213',
  firingFg: resolvedLookup['color.firing.foreground'] || '#F5F5F5',
  badgeWeekly: 'var(--accent)',
  badgeMonthly: 'var(--badge-monthly)',
  badgeAnnual: 'var(--badge-annual)',
  badgeCustom: 'var(--badge-custom)',
  // Spacing
  xxs: 4, xs: 8, sm: 12, md: 16, lg: 24,
  // Radius
  radiusSm: 8, radiusMd: 12,
}

// ─── Spec Table ───

function SpecTable({ specs }) {
  return (
    <div className="spec-table-wrap">
      <table className="spec-table">
        <thead>
          <tr>
            <th>Element</th>
            <th>Property</th>
            <th>Token</th>
            <th>Value</th>
            <th>Placement</th>
            <th>Layer</th>
          </tr>
        </thead>
        <tbody>
          {specs.map((row, i) => (
            <tr key={i}>
              <td className="spec-element">{row.element}</td>
              <td className="spec-property">{row.property}</td>
              <td className="spec-token">{row.token}</td>
              <td className="spec-value">{row.value}</td>
              <td className="spec-placement">{row.placement || '—'}</td>
              <td className="spec-layer">{row.layer || '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

// ─── Structure Template ───

function StructureTemplate({ code }) {
  return (
    <div className="structure-template">
      <div className="structure-template-title">Structure Template</div>
      <pre className="structure-template-code">{code}</pre>
    </div>
  )
}

// ─── Shared sub-components ───

function Badge({ text, color }) {
  return (
    <span style={{
      display: 'inline-block',
      padding: `${t.xs}px ${t.sm}px`,
      backgroundColor: color,
      color: '#fff',
      fontSize: 11,
      fontWeight: 600,
      borderRadius: 100,
      lineHeight: 1,
    }}>
      {text}
    </span>
  )
}

function Toggle({ on }) {
  return (
    <div style={{
      width: 44,
      height: 26,
      borderRadius: 13,
      backgroundColor: on ? t.primary : '#555',
      position: 'relative',
      flexShrink: 0,
    }}>
      <div style={{
        width: 22,
        height: 22,
        borderRadius: 11,
        backgroundColor: '#fff',
        position: 'absolute',
        top: 2,
        left: on ? 20 : 2,
        transition: 'left 0.2s',
      }} />
    </div>
  )
}

// ─── AlarmCard ───

function AlarmCardPreview({ title, cycleType, time, countdown, state, persistent }) {
  const isInactive = state === 'inactive'
  const isSnoozed = state === 'snoozed'
  const isOverdue = state === 'overdue'
  const borderColor = isSnoozed ? t.warning : isOverdue ? t.error : 'transparent'
  const badgeColor = {
    weekly: t.badgeWeekly,
    monthly: t.badgeMonthly,
    annual: t.badgeAnnual,
    custom: t.badgeCustom,
  }[cycleType] || t.primary

  const countdownPrefix = isSnoozed ? 'Fires in' : 'Alarm in'

  return (
    <div style={{
      backgroundColor: t.surfaceCard,
      borderRadius: t.radiusMd,
      padding: t.md,
      opacity: isInactive ? 0.5 : 1,
      border: `2px solid ${borderColor}`,
      display: 'flex',
      flexDirection: 'column',
      gap: t.sm,
    }}>
      {/* Row 1: Title + badges (left) | Toggle (right) */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: t.xxs }}>
          <div style={{
            fontSize: 14, fontWeight: 500, lineHeight: 1.3,
            color: isInactive ? t.textDisabled : t.textPrimary,
          }}>
            {title}
          </div>
          <div style={{ display: 'flex', gap: t.xxs, alignItems: 'center' }}>
            <Badge text={cycleType} color={badgeColor} />
            {isSnoozed && <Badge text="Snoozed" color={t.warning} />}
            {isOverdue && <Badge text="Missed" color={t.error} />}
          </div>
        </div>
        <Toggle on={!isInactive} />
      </div>

      {/* Row 2: Time + countdown inline (left) | Persistent badge (right) */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: t.xs }}>
          <div style={{
            fontSize: 24, fontWeight: 600, lineHeight: 1,
            color: isInactive ? t.textDisabled : t.textPrimary,
          }}>
            {time}
          </div>
          {countdown && !isInactive && (
            <div style={{ fontSize: 12, fontWeight: 500, color: t.textSecondary }}>
              {countdownPrefix} {countdown}
            </div>
          )}
        </div>
        {persistent && !isInactive && (
          <Badge text="Persistent" color={t.warning} />
        )}
      </div>
    </div>
  )
}

const alarmCardSpecs = [
  { element: 'Card', property: 'background', token: 'color.surface.card', value: t.surfaceCard, placement: 'Root container', layer: 'Base' },
  { element: 'Card', property: 'border-radius', token: 'radius.md', value: `${t.radiusMd}px` },
  { element: 'Card', property: 'padding', token: 'spacing.cardPadding', value: `${t.md}px` },
  { element: 'Card', property: 'layout', token: '—', value: 'VStack', placement: 'Column, 2 rows', layer: 'Base' },
  { element: 'Card', property: 'row gap', token: 'spacing.sm', value: `${t.sm}px` },
  { element: 'Card (snoozed)', property: 'border', token: 'color.warning', value: `2px solid ${t.warning}` },
  { element: 'Card (overdue)', property: 'border', token: 'color.error', value: `2px solid ${t.error}` },
  { element: 'Card (inactive)', property: 'opacity', token: '—', value: '0.5' },
  { element: 'Row 1', property: 'layout', token: '—', value: 'HStack, space-between', placement: 'Top row', layer: 'Content' },
  { element: 'Title', property: 'font-size', token: 'typography.titleSmall', value: '16px (medium weight)', placement: 'Row 1, left top' },
  { element: 'Title', property: 'font-weight', token: 'typography.titleSmall', value: '500 (medium)' },
  { element: 'Title', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Title', property: 'line-height', token: '—', value: '1.3' },
  { element: 'Title (inactive)', property: 'color', token: 'color.text.disabled', value: t.textDisabled },
  { element: 'Title → Badge gap', property: 'gap', token: 'spacing.xxs', value: `${t.xxs}px` },
  { element: 'Badge row', property: 'layout', token: '—', value: 'HStack', placement: 'Row 1, left bottom (below title)', layer: 'Content' },
  { element: 'Badge row', property: 'gap', token: 'spacing.xxs', value: `${t.xxs}px` },
  { element: 'Badge', property: 'font-size', token: '—', value: '11px' },
  { element: 'Badge', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Badge', property: 'padding', token: 'spacing.xs / spacing.sm', value: `${t.xs}px ${t.sm}px` },
  { element: 'Badge', property: 'border-radius', token: '—', value: '100px (capsule)' },
  { element: 'Badge (weekly)', property: 'background', token: 'color.badge.weekly', value: t.badgeWeekly },
  { element: 'Badge (monthly)', property: 'background', token: 'color.badge.monthly', value: t.badgeMonthly },
  { element: 'Badge (snoozed)', property: 'background', token: 'color.warning', value: t.warning },
  { element: 'Badge (missed)', property: 'background', token: 'color.error', value: t.error },
  { element: 'Toggle', property: 'size', token: '—', value: '44 x 26px', placement: 'Row 1, right (align top)', layer: 'Content' },
  { element: 'Toggle (on)', property: 'background', token: 'color.primary', value: t.primary },
  { element: 'Toggle (off)', property: 'background', token: '—', value: '#555555' },
  { element: 'Toggle thumb', property: 'size', token: '—', value: '22 x 22px' },
  { element: 'Row 2', property: 'layout', token: '—', value: 'HStack, space-between, baseline aligned', placement: 'Bottom row', layer: 'Content' },
  { element: 'Time', property: 'font-size', token: 'typography.headlineTime', value: '24px', placement: 'Row 2, left' },
  { element: 'Time', property: 'font-weight', token: 'typography.headlineTime', value: '600 (semibold)' },
  { element: 'Time', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Time', property: 'line-height', token: '—', value: '1.2' },
  { element: 'Countdown', property: 'font-size', token: 'typography.captionCountdown', value: '14px', placement: 'Row 2, inline after time (baseline aligned)' },
  { element: 'Countdown', property: 'font-weight', token: '—', value: '500 (medium)' },
  { element: 'Countdown', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Badge (persistent)', property: 'background', token: 'color.warning', value: t.warning, placement: 'Row 2, right (align bottom)', layer: 'Content' },
]

const alarmCardTemplate = `VStack(spacing: SpacingTokens.sm) {           // Card
    HStack(alignment: .top) {                   // Row 1
        VStack(alignment: .leading,
               spacing: SpacingTokens.xxs) {
            ChronirText(title, style: .titleSmall)
            HStack(spacing: SpacingTokens.xxs) { // Badge row
                ChronirBadge(cycleType: cycleType)
                if isSnoozed { ChronirBadge("Snoozed") }
                if isOverdue { ChronirBadge("Missed") }
            }
        }
        Spacer()
        Toggle(isOn: $isEnabled)                // Toggle
    }
    HStack(alignment: .firstTextBaseline) {     // Row 2
        AlarmTimeDisplay(                       // Time + countdown inline
            time: alarm.scheduledTime,
            countdownText: countdownText)
        Spacer()
        if persistent {
            ChronirBadge("Persistent")          // Trailing badge
        }
    }
}
.padding(SpacingTokens.cardPadding)
.chronirGlassCard()`

// ─── AlarmFiringOverlay ───

function FiringOverlayPreview() {
  return (
    <div style={{
      backgroundColor: t.firingBg,
      borderRadius: t.radiusMd,
      padding: '32px 24px',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 16,
      minHeight: 320,
      justifyContent: 'center',
    }}>
      <div style={{ fontSize: 20, fontWeight: 600, color: t.firingFg }}>Morning Workout</div>
      <div style={{ fontSize: 64, fontWeight: 700, color: t.firingFg, lineHeight: 1 }}>6:30</div>
      <Badge text="Weekly" color={t.badgeWeekly} />
      <div style={{ display: 'flex', gap: t.md, marginTop: 16 }}>
        {[['1', 'hour'], ['1', 'day'], ['1', 'week']].map(([n, u]) => (
          <div key={u} style={{
            width: 72, height: 64,
            backgroundColor: t.bgTertiary,
            borderRadius: t.radiusMd,
            display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <span style={{ fontSize: 20, fontWeight: 600, color: t.firingFg }}>{n}</span>
            <span style={{ fontSize: 11, color: t.textSecondary }}>{u}</span>
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
  )
}

const firingOverlaySpecs = [
  { element: 'Overlay', property: 'background', token: 'color.firing.background', value: t.firingBg, placement: 'Full-screen, centered column', layer: 'Overlay (top-most)' },
  { element: 'Overlay', property: 'padding', token: '—', value: '32px 24px' },
  { element: 'Overlay', property: 'border-radius', token: 'radius.md', value: `${t.radiusMd}px` },
  { element: 'Overlay', property: 'layout', token: '—', value: 'VStack, center aligned', placement: 'Column, vertically centered' },
  { element: 'Title', property: 'font-size', token: 'typography.titleLarge', value: '20px', placement: 'Center, 1st in stack' },
  { element: 'Title', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Title', property: 'color', token: 'color.firing.foreground', value: t.firingFg },
  { element: 'Time', property: 'font-size', token: 'typography.displayLarge', value: '64px', placement: 'Center, 2nd in stack' },
  { element: 'Time', property: 'font-weight', token: '—', value: '700 (bold)' },
  { element: 'Time', property: 'color', token: 'color.firing.foreground', value: t.firingFg },
  { element: 'Badge', property: 'position', token: '—', value: '—', placement: 'Center, 3rd in stack', layer: 'Content' },
  { element: 'Snooze bar', property: 'layout', token: '—', value: 'HStack, 3 buttons', placement: 'Center, 4th in stack', layer: 'Content' },
  { element: 'Snooze button', property: 'size', token: '—', value: '72 x 64px', placement: 'Within snooze bar, evenly spaced' },
  { element: 'Snooze button', property: 'background', token: 'color.background.tertiary', value: t.bgTertiary },
  { element: 'Snooze button', property: 'border-radius', token: 'radius.md', value: `${t.radiusMd}px` },
  { element: 'Snooze button', property: 'gap (between)', token: 'spacing.md', value: `${t.md}px` },
  { element: 'Snooze number', property: 'font-size', token: '—', value: '20px', placement: 'Button, top center' },
  { element: 'Snooze number', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Snooze label', property: 'font-size', token: '—', value: '11px', placement: 'Button, bottom center' },
  { element: 'Snooze label', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Dismiss button', property: 'background', token: 'color.primary', value: t.primary, placement: 'Center, 5th (bottom of stack)', layer: 'Content' },
  { element: 'Dismiss button', property: 'font-size', token: '—', value: '14px' },
  { element: 'Dismiss button', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Dismiss button', property: 'padding', token: 'spacing.md / spacing.lg', value: `${t.md}px ${t.lg}px` },
  { element: 'Dismiss button', property: 'border-radius', token: 'radius.sm', value: `${t.radiusSm}px` },
  { element: 'Dismiss button', property: 'width', token: '—', value: '80%' },
]

const firingOverlayTemplate = `FullScreenAlarmTemplate {
    VStack(spacing: SpacingTokens.xxxl) {       // Overlay
        Spacer()
        ChronirText(alarm.title,
                    style: .headlineLarge)       // Title
        ChronirText(formattedTime,
                    style: .displayAlarm)        // Time
        ChronirBadge(cycleType: alarm.cycleType) // Badge

        SnoozeOptionBar(onSnooze: onSnooze)     // Snooze bar
            // └─ HStack(spacing: .md) {
            //        SnoozeOptionButton("1", "hour")
            //        SnoozeOptionButton("1", "day")
            //        SnoozeOptionButton("1", "week")
            //    }

        if snoozeCount > 0 {
            ChronirText("Snoozed \\(snoozeCount)x",
                        style: .bodySecondary,
                        color: ColorTokens.warning)
        }
        ChronirButton("Dismiss",                // Dismiss
                      style: .primary,
                      action: onDismiss)
        Spacer()
    }
}
.background(ColorTokens.firingBackground)
.statusBarHidden(true)`

// ─── EmptyStateView ───

function EmptyStatePreview() {
  return (
    <div style={{
      backgroundColor: t.bgPrimary,
      borderRadius: t.radiusMd,
      padding: '48px 32px',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 16,
      textAlign: 'center',
    }}>
      <div style={{ fontSize: 48, opacity: 0.5 }}>🔕</div>
      <div style={{ fontSize: 24, fontWeight: 600, color: t.textPrimary }}>No alarms yet</div>
      <div style={{ fontSize: 14, color: t.textSecondary, maxWidth: 240 }}>
        Set recurring alarms that fire weekly, monthly, or yearly.
      </div>
      <div style={{
        marginTop: 8,
        padding: `${t.md}px ${t.lg}px`,
        backgroundColor: t.primary,
        color: '#fff',
        borderRadius: t.radiusSm,
        fontWeight: 600,
        fontSize: 14,
      }}>
        Create First Alarm
      </div>
    </div>
  )
}

const emptyStateSpecs = [
  { element: 'Container', property: 'background', token: 'color.background.primary', value: t.bgPrimary, placement: 'Full width, centered column', layer: 'Base' },
  { element: 'Container', property: 'border-radius', token: 'radius.md', value: `${t.radiusMd}px` },
  { element: 'Container', property: 'padding', token: '—', value: '48px 32px' },
  { element: 'Container', property: 'layout', token: '—', value: 'VStack, center aligned' },
  { element: 'Container', property: 'gap', token: '—', value: '16px' },
  { element: 'Icon', property: 'font-size', token: '—', value: '48px', placement: 'Center, 1st in stack', layer: 'Content' },
  { element: 'Icon', property: 'opacity', token: '—', value: '0.5' },
  { element: 'Heading', property: 'font-size', token: 'typography.headlineMedium', value: '24px', placement: 'Center, 2nd in stack', layer: 'Content' },
  { element: 'Heading', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Heading', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Body text', property: 'font-size', token: 'typography.bodySmall', value: '14px', placement: 'Center, 3rd in stack', layer: 'Content' },
  { element: 'Body text', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Body text', property: 'max-width', token: '—', value: '240px' },
  { element: 'CTA button', property: 'background', token: 'color.primary', value: t.primary, placement: 'Center, 4th (bottom of stack)', layer: 'Content' },
  { element: 'CTA button', property: 'font-size', token: '—', value: '14px' },
  { element: 'CTA button', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'CTA button', property: 'padding', token: 'spacing.md / spacing.lg', value: `${t.md}px ${t.lg}px` },
  { element: 'CTA button', property: 'border-radius', token: 'radius.sm', value: `${t.radiusSm}px` },
]

const emptyStateTemplate = `VStack(spacing: SpacingTokens.md) {            // Container
    Spacer()
    Image(systemName: "bell.slash")              // Icon
        .font(.system(size: 48))
        .opacity(0.5)
    ChronirText("No alarms yet",
                style: .headlineMedium)          // Heading
    ChronirText("Set recurring alarms...",
                style: .bodySecondary)            // Body
        .multilineTextAlignment(.center)
        .frame(maxWidth: 240)
    ChronirButton("Create First Alarm",          // CTA
                  style: .primary,
                  action: onCreate)
    Spacer()
}
.padding(.horizontal, SpacingTokens.lg)
.padding(.vertical, 48)
.background(ColorTokens.backgroundPrimary)
.clipShape(RoundedRectangle(
    cornerRadius: RadiusTokens.md))`

// ─── ButtonVariants ───

function ButtonVariantsPreview() {
  const variants = [
    { label: 'Primary Action', bg: t.primary, fg: '#fff' },
    { label: 'Secondary', bg: t.bgTertiary, fg: t.textPrimary },
    { label: 'Delete', bg: t.error, fg: '#fff' },
    { label: 'Ghost Action', bg: 'transparent', fg: t.primary, border: true },
  ]
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: t.sm }}>
      {variants.map(v => (
        <div key={v.label} style={{
          padding: `${t.md}px ${t.lg}px`,
          backgroundColor: v.bg,
          color: v.fg,
          borderRadius: t.radiusSm,
          fontWeight: 600,
          fontSize: 14,
          textAlign: 'center',
          border: v.border ? `1px solid ${t.primary}` : 'none',
        }}>
          {v.label}
        </div>
      ))}
    </div>
  )
}

const buttonSpecs = [
  { element: 'Button', property: 'layout', token: '—', value: 'Full-width, center text', placement: 'Inline block, full parent width', layer: 'Content' },
  { element: 'All variants', property: 'padding', token: 'spacing.md / spacing.lg', value: `${t.md}px ${t.lg}px` },
  { element: 'All variants', property: 'border-radius', token: 'radius.sm', value: `${t.radiusSm}px` },
  { element: 'All variants', property: 'font-size', token: '—', value: '14px' },
  { element: 'All variants', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'All variants', property: 'gap (stacked)', token: 'spacing.sm', value: `${t.sm}px` },
  { element: 'Primary', property: 'background', token: 'color.primary', value: t.primary },
  { element: 'Primary', property: 'color', token: '—', value: '#FFFFFF' },
  { element: 'Secondary', property: 'background', token: 'color.background.tertiary', value: t.bgTertiary },
  { element: 'Secondary', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Destructive', property: 'background', token: 'color.error', value: t.error },
  { element: 'Destructive', property: 'color', token: '—', value: '#FFFFFF' },
  { element: 'Ghost', property: 'background', token: '—', value: 'transparent' },
  { element: 'Ghost', property: 'color', token: 'color.primary', value: t.primary },
  { element: 'Ghost', property: 'border', token: 'color.primary', value: `1px solid ${t.primary}` },
]

const buttonTemplate = `ChronirButton(title,                          // Button
              style: variant,                  // .primary | .secondary
              action: onTap)                   // .destructive | .ghost
// Expands to:
Text(title)
    .font(.system(size: 14, weight: .semibold))
    .frame(maxWidth: .infinity)
    .padding(.vertical, SpacingTokens.md)
    .padding(.horizontal, SpacingTokens.lg)
    .background(variantBackground)             // per variant
    .foregroundColor(variantForeground)
    .clipShape(RoundedRectangle(
        cornerRadius: RadiusTokens.sm))`

// ─── Badge variants ───

function BadgeVariantsPreview() {
  return (
    <div style={{ display: 'flex', gap: t.sm, flexWrap: 'wrap' }}>
      <Badge text="Weekly" color={t.badgeWeekly} />
      <Badge text="Monthly" color={t.badgeMonthly} />
      <Badge text="Annual" color={t.badgeAnnual} />
      <Badge text="Custom" color={t.badgeCustom} />
      <Badge text="Active" color={t.success} />
      <Badge text="Persistent" color={t.warning} />
      <Badge text="Snoozed" color={t.warning} />
      <Badge text="Missed" color={t.error} />
    </div>
  )
}

const badgeSpecs = [
  { element: 'Badge', property: 'layout', token: '—', value: 'Inline, self-sizing', placement: 'Inline within parent HStack', layer: 'Content' },
  { element: 'All badges', property: 'padding', token: 'spacing.xs / spacing.sm', value: `${t.xs}px ${t.sm}px` },
  { element: 'All badges', property: 'border-radius', token: '—', value: '100px (capsule)' },
  { element: 'All badges', property: 'font-size', token: '—', value: '11px' },
  { element: 'All badges', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'All badges', property: 'color', token: '—', value: '#FFFFFF' },
  { element: 'All badges', property: 'gap (between)', token: 'spacing.sm', value: `${t.sm}px` },
  { element: 'Weekly', property: 'background', token: 'color.badge.weekly', value: t.badgeWeekly },
  { element: 'Monthly', property: 'background', token: 'color.badge.monthly', value: t.badgeMonthly },
  { element: 'Annual', property: 'background', token: 'color.badge.annual', value: t.badgeAnnual },
  { element: 'Custom', property: 'background', token: 'color.badge.custom', value: t.badgeCustom },
  { element: 'Active', property: 'background', token: 'color.success', value: t.success },
  { element: 'Persistent', property: 'background', token: 'color.warning', value: t.warning },
  { element: 'Snoozed', property: 'background', token: 'color.warning', value: t.warning },
  { element: 'Missed', property: 'background', token: 'color.error', value: t.error },
]

const badgeTemplate = `ChronirBadge(text,                             // Badge
              color: badgeColor)
// Expands to:
Text(text)
    .font(.system(size: 11, weight: .semibold))
    .foregroundColor(.white)
    .padding(.vertical, SpacingTokens.xs)
    .padding(.horizontal, SpacingTokens.sm)
    .background(badgeColor)                    // color.badge.*
    .clipShape(Capsule())`

// ─── AlarmToggleRow ───

function ToggleRowPreview() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
      {[
        { title: 'Morning Workout', sub: 'Every Monday at 6:30 AM', badge: 'Weekly', badgeColor: t.badgeWeekly, on: true },
        { title: 'Pay Rent', sub: '1st of every month', badge: 'Monthly', badgeColor: t.badgeMonthly, on: true },
        { title: 'Annual Checkup', sub: 'March 15 every year', badge: 'Annual', badgeColor: t.badgeAnnual, on: false },
      ].map(row => (
        <div key={row.title} style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: t.md, backgroundColor: t.surfaceCard,
        }}>
          <div>
            <div style={{ fontSize: 16, fontWeight: 600, color: t.textPrimary, marginBottom: t.xxs }}>
              {row.title}
            </div>
            <div style={{ display: 'flex', gap: t.xs, alignItems: 'center' }}>
              <Badge text={row.badge} color={row.badgeColor} />
              <span style={{ fontSize: 14, color: t.textSecondary }}>{row.sub}</span>
            </div>
          </div>
          <Toggle on={row.on} />
        </div>
      ))}
    </div>
  )
}

const toggleRowSpecs = [
  { element: 'Row', property: 'layout', token: '—', value: 'HStack, space-between', placement: 'Full-width row', layer: 'Base' },
  { element: 'Row', property: 'padding', token: 'spacing.md', value: `${t.md}px` },
  { element: 'Row', property: 'background', token: 'color.surface.card', value: t.surfaceCard },
  { element: 'Row', property: 'gap (between rows)', token: '—', value: '1px' },
  { element: 'Left column', property: 'layout', token: '—', value: 'VStack, leading', placement: 'Left side of row', layer: 'Content' },
  { element: 'Title', property: 'font-size', token: 'typography.titleMedium', value: '16px', placement: 'Left, top' },
  { element: 'Title', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Title', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Title → subtitle gap', property: 'gap', token: 'spacing.xxs', value: `${t.xxs}px` },
  { element: 'Subtitle row', property: 'layout', token: '—', value: 'HStack', placement: 'Left, below title', layer: 'Content' },
  { element: 'Subtitle', property: 'font-size', token: 'typography.bodySmall', value: '14px' },
  { element: 'Subtitle', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Badge → subtitle gap', property: 'gap', token: 'spacing.xs', value: `${t.xs}px` },
  { element: 'Toggle', property: 'size', token: '—', value: '44 x 26px', placement: 'Right side, vertically centered', layer: 'Content' },
  { element: 'Toggle (on)', property: 'background', token: 'color.primary', value: t.primary },
]

const toggleRowTemplate = `HStack {                                       // Row
    VStack(alignment: .leading,
           spacing: SpacingTokens.xxs) {         // Left column
        ChronirText(alarm.title,
                    style: .titleMedium)          // Title
        HStack(spacing: SpacingTokens.xs) {       // Subtitle row
            ChronirBadge(cycleType: alarm.cycleType)
            ChronirText(alarm.schedule,
                        style: .bodySmall,
                        color: ColorTokens.textSecondary)
        }
    }
    Spacer()
    Toggle(isOn: $alarm.isEnabled)               // Toggle
}
.padding(SpacingTokens.md)
.background(ColorTokens.surfaceCard)`

// ─── PermissionStatusRow ───

function PermissionRowPreview() {
  const statuses = [
    { label: 'Notifications', badge: 'Enabled', color: t.success },
    { label: 'Notifications', badge: 'Denied', color: t.error },
    { label: 'Notifications', badge: 'Provisional', color: t.warning },
    { label: 'Notifications', badge: 'Not Set', color: t.textSecondary },
  ]
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
      {statuses.map((s, i) => (
        <div key={i} style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: `${t.sm}px ${t.md}px`,
          backgroundColor: t.surfaceCard,
        }}>
          <span style={{ fontSize: 16, color: t.textPrimary }}>{s.label}</span>
          <Badge text={s.badge} color={s.color} />
        </div>
      ))}
    </div>
  )
}

const permissionRowSpecs = [
  { element: 'Row', property: 'layout', token: '—', value: 'HStack, space-between', placement: 'Full-width row', layer: 'Base' },
  { element: 'Row', property: 'padding', token: 'spacing.sm / spacing.md', value: `${t.sm}px ${t.md}px` },
  { element: 'Row', property: 'background', token: 'color.surface.card', value: t.surfaceCard },
  { element: 'Label', property: 'font-size', token: '—', value: '16px', placement: 'Left, vertically centered', layer: 'Content' },
  { element: 'Label', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Status badge', property: 'position', token: '—', value: '—', placement: 'Right, vertically centered', layer: 'Content' },
  { element: 'Enabled badge', property: 'background', token: 'color.success', value: t.success },
  { element: 'Denied badge', property: 'background', token: 'color.error', value: t.error },
  { element: 'Provisional badge', property: 'background', token: 'color.warning', value: t.warning },
  { element: 'Not Set badge', property: 'background', token: 'color.text.secondary', value: t.textSecondary },
]

const permissionRowTemplate = `HStack {                                       // Row
    ChronirText(permission.label,
                style: .body)                    // Label
    Spacer()
    ChronirBadge(permission.status.text,         // Status badge
                 color: permission.status.color)
    // Enabled  → color.success
    // Denied   → color.error
    // Prov.    → color.warning
    // Not Set  → color.text.secondary
}
.padding(.vertical, SpacingTokens.sm)
.padding(.horizontal, SpacingTokens.md)
.background(ColorTokens.surfaceCard)`

// ─── LabeledTextField ───

function TextFieldPreview() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: t.xs }}>
      <span style={{ fontSize: 12, fontWeight: 500, color: t.textSecondary }}>Alarm Name</span>
      <div style={{
        padding: t.md,
        backgroundColor: t.bgTertiary,
        borderRadius: t.radiusSm,
        fontSize: 16,
        color: t.textSecondary,
      }}>
        Enter a name...
      </div>
    </div>
  )
}

const textFieldSpecs = [
  { element: 'Container', property: 'layout', token: '—', value: 'VStack, leading', placement: 'Full-width block', layer: 'Base' },
  { element: 'Label → field gap', property: 'gap', token: 'spacing.xs', value: `${t.xs}px` },
  { element: 'Label', property: 'font-size', token: 'typography.caption', value: '12px', placement: 'Top, leading aligned', layer: 'Content' },
  { element: 'Label', property: 'font-weight', token: '—', value: '500 (medium)' },
  { element: 'Label', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Field', property: 'padding', token: 'spacing.md', value: `${t.md}px`, placement: 'Below label, full width', layer: 'Content' },
  { element: 'Field', property: 'background', token: 'color.background.tertiary', value: t.bgTertiary },
  { element: 'Field', property: 'border-radius', token: 'radius.sm', value: `${t.radiusSm}px` },
  { element: 'Field', property: 'font-size', token: '—', value: '16px' },
  { element: 'Placeholder', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
]

const textFieldTemplate = `VStack(alignment: .leading,
       spacing: SpacingTokens.xs) {              // Container
    Text(label)                                  // Label
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(ColorTokens.textSecondary)
    TextField(placeholder, text: $value)         // Field
        .padding(SpacingTokens.md)
        .background(ColorTokens.backgroundTertiary)
        .clipShape(RoundedRectangle(
            cornerRadius: RadiusTokens.sm))
}`

// ─── IntervalPicker ───

function IntervalPickerPreview() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: t.xs }}>
      <span style={{ fontSize: 12, fontWeight: 500, color: t.textSecondary }}>Repeat</span>
      <div style={{ display: 'flex', gap: t.sm }}>
        {['Weekly', 'Monthly', 'Annual'].map((opt, i) => (
          <div key={opt} style={{
            padding: `${t.sm}px ${t.md}px`,
            backgroundColor: i === 0 ? t.primary : t.bgTertiary,
            color: i === 0 ? '#fff' : t.textSecondary,
            borderRadius: t.radiusSm,
            fontSize: 14,
            fontWeight: 600,
          }}>
            {opt}
          </div>
        ))}
      </div>
    </div>
  )
}

const intervalPickerSpecs = [
  { element: 'Container', property: 'layout', token: '—', value: 'VStack, leading', placement: 'Full-width block', layer: 'Base' },
  { element: 'Label → picker gap', property: 'gap', token: 'spacing.xs', value: `${t.xs}px` },
  { element: 'Label', property: 'font-size', token: 'typography.caption', value: '12px', placement: 'Top, leading aligned', layer: 'Content' },
  { element: 'Label', property: 'font-weight', token: '—', value: '500 (medium)' },
  { element: 'Label', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Segment row', property: 'layout', token: '—', value: 'HStack', placement: 'Below label, full width', layer: 'Content' },
  { element: 'Segment gap', property: 'gap', token: 'spacing.sm', value: `${t.sm}px` },
  { element: 'Segment', property: 'padding', token: 'spacing.sm / spacing.md', value: `${t.sm}px ${t.md}px`, placement: 'Within segment row, equal weight' },
  { element: 'Segment', property: 'border-radius', token: 'radius.sm', value: `${t.radiusSm}px` },
  { element: 'Segment', property: 'font-size', token: '—', value: '14px' },
  { element: 'Segment', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Selected segment', property: 'background', token: 'color.primary', value: t.primary },
  { element: 'Selected segment', property: 'color', token: '—', value: '#FFFFFF' },
  { element: 'Unselected segment', property: 'background', token: 'color.background.tertiary', value: t.bgTertiary },
  { element: 'Unselected segment', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
]

const intervalPickerTemplate = `VStack(alignment: .leading,
       spacing: SpacingTokens.xs) {              // Container
    Text(label)                                  // Label
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(ColorTokens.textSecondary)
    HStack(spacing: SpacingTokens.sm) {          // Segment row
        ForEach(CycleType.allCases) { type in
            Text(type.displayName)               // Segment
                .font(.system(size: 14,
                              weight: .semibold))
                .padding(.vertical, SpacingTokens.sm)
                .padding(.horizontal, SpacingTokens.md)
                .background(selected == type
                    ? ColorTokens.primary        // Selected
                    : ColorTokens.backgroundTertiary)
                .foregroundColor(selected == type
                    ? .white
                    : ColorTokens.textSecondary)
                .clipShape(RoundedRectangle(
                    cornerRadius: RadiusTokens.sm))
                .onTapGesture { selected = type }
        }
    }
}`

// ─── CategoryGroupCard ───

function StatusDot({ enabled }) {
  return (
    <div style={{
      width: 6, height: 6, borderRadius: 3, flexShrink: 0,
      backgroundColor: enabled ? t.success : t.textDisabled,
    }} />
  )
}

function CategoryGroupCardPreview({ category, icon, color, alarms, overflowCount }) {
  return (
    <div style={{
      backgroundColor: t.surfaceCard,
      borderRadius: t.radiusMd,
      padding: t.md,
      display: 'flex',
      flexDirection: 'column',
      gap: t.sm,
      minWidth: 280,
    }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: t.sm }}>
        <span style={{ fontSize: 18, color }}>{icon}</span>
        <span style={{ fontSize: 16, fontWeight: 600, color: t.textPrimary }}>{category}</span>
        <Badge text={String(alarms.length + overflowCount)} color={color} />
        <span style={{ flex: 1 }} />
        <span style={{ fontSize: 12, fontWeight: 600, color: t.textSecondary }}>›</span>
      </div>

      {/* Compact rows */}
      {alarms.map((a, i) => (
        <div key={i} style={{ display: 'flex', alignItems: 'center', gap: t.sm }}>
          <StatusDot enabled={a.enabled} />
          <span style={{
            fontSize: 14, flex: 1,
            color: a.enabled ? t.textPrimary : t.textDisabled,
          }}>
            {a.title}
          </span>
          <span style={{ fontSize: 12, color: t.textSecondary }}>{a.date}</span>
        </div>
      ))}

      {/* Overflow */}
      {overflowCount > 0 && (
        <span style={{ fontSize: 14, fontWeight: 500, color: t.textSecondary }}>
          +{overflowCount} more
        </span>
      )}
    </div>
  )
}

const categoryGroupCardSpecs = [
  { element: 'Card', property: 'background', token: 'color.surface.card', value: t.surfaceCard, placement: 'Root container', layer: 'Base' },
  { element: 'Card', property: 'border-radius', token: 'radius.md', value: `${t.radiusMd}px` },
  { element: 'Card', property: 'padding', token: 'spacing.cardPadding', value: `${t.md}px` },
  { element: 'Card', property: 'row gap', token: 'spacing.sm', value: `${t.sm}px` },
  { element: 'Header', property: 'layout', token: '—', value: 'HStack', placement: 'Top row', layer: 'Content' },
  { element: 'Header', property: 'gap', token: 'spacing.sm', value: `${t.sm}px` },
  { element: 'Category icon', property: 'font-size', token: '—', value: '18px (title3)', placement: 'Header, leading', layer: 'Content' },
  { element: 'Category icon', property: 'color', token: 'AlarmCategory.color', value: 'Per category' },
  { element: 'Category name', property: 'font-size', token: 'typography.titleMedium', value: '16px', placement: 'Header, after icon' },
  { element: 'Category name', property: 'font-weight', token: '—', value: '600 (semibold)' },
  { element: 'Category name', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Count badge', property: 'background', token: 'AlarmCategory.color', value: 'Per category', placement: 'Header, after name' },
  { element: 'Chevron', property: 'font-size', token: '—', value: '12px (caption, semibold)', placement: 'Header, trailing', layer: 'Content' },
  { element: 'Chevron', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Alarm row', property: 'layout', token: '—', value: 'HStack', placement: 'Below header, up to 3 rows', layer: 'Content' },
  { element: 'Alarm row', property: 'gap', token: 'spacing.sm', value: `${t.sm}px` },
  { element: 'Status dot', property: 'size', token: '—', value: '6 x 6px', placement: 'Row, leading' },
  { element: 'Status dot (enabled)', property: 'fill', token: 'color.success', value: t.success },
  { element: 'Status dot (disabled)', property: 'fill', token: 'color.text.disabled', value: t.textDisabled },
  { element: 'Alarm title', property: 'font-size', token: 'typography.bodyMedium', value: '14px', placement: 'Row, after dot' },
  { element: 'Alarm title (enabled)', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Alarm title (disabled)', property: 'color', token: 'color.text.disabled', value: t.textDisabled },
  { element: 'Fire date', property: 'font-size', token: 'typography.labelSmall', value: '12px', placement: 'Row, trailing' },
  { element: 'Fire date', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Overflow text', property: 'font-size', token: 'typography.labelLarge', value: '14px', placement: 'Below alarm rows', layer: 'Content' },
  { element: 'Overflow text', property: 'font-weight', token: '—', value: '500 (medium)' },
  { element: 'Overflow text', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
]

const categoryGroupCardTemplate = `VStack(alignment: .leading,
       spacing: SpacingTokens.sm) {              // Card
    HStack(spacing: SpacingTokens.sm) {          // Header
        Image(systemName: category.iconName)     // Icon
            .foregroundStyle(category.color)
            .font(.title3)
        ChronirText(category.displayName,        // Name
                    style: .titleMedium)
        ChronirBadge("\\(alarms.count)",         // Count
                     color: category.color)
        Spacer()
        Image(systemName: "chevron.right")       // Chevron
            .foregroundStyle(ColorTokens.textSecondary)
            .font(.caption.weight(.semibold))
    }
    ForEach(displayedAlarms) { alarm in          // Rows (max 3)
        HStack(spacing: SpacingTokens.sm) {
            Circle()                             // Status dot
                .fill(isEnabled ? .success : .textDisabled)
                .frame(width: 6, height: 6)
            ChronirText(alarm.title,             // Title
                        style: .bodyMedium)
            Spacer()
            ChronirText(alarm.nextFireDate       // Date
                .formatted(.dateTime
                    .month(.abbreviated).day()),
                style: .labelSmall)
        }
    }
    if overflowCount > 0 {                      // Overflow
        ChronirText("+\\(overflowCount) more",
                    style: .labelLarge,
                    color: ColorTokens.textSecondary)
    }
}
.padding(SpacingTokens.cardPadding)
.chronirGlassCard()`

// ─── FAB (Floating Action Button) ───

function FABPreview() {
  const variants = [
    { icon: '+', label: 'Default (plus)' },
    { icon: '✎', label: 'Custom (pencil)' },
  ]
  return (
    <div style={{ display: 'flex', gap: t.lg, alignItems: 'center' }}>
      {variants.map(v => (
        <div key={v.label} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: t.xs }}>
          <div style={{
            width: 56,
            height: 56,
            borderRadius: '50%',
            backgroundColor: t.primary,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#fff',
            fontSize: 24,
            fontWeight: 600,
            cursor: 'pointer',
          }}>
            {v.icon}
          </div>
          <span style={{ fontSize: 11, color: t.textSecondary }}>{v.label}</span>
        </div>
      ))}
    </div>
  )
}

const fabSpecs = [
  { element: 'FAB', property: 'size', token: '—', value: '56 × 56pt', placement: 'Bottom-center, overlaying content', layer: 'Overlay' },
  { element: 'FAB', property: 'shape', token: '—', value: 'Circle' },
  { element: 'FAB', property: 'background', token: 'color.primary', value: t.primary, placement: '—', layer: '—' },
  { element: 'FAB', property: 'bottom padding', token: 'spacing.lg', value: `${t.lg}px` },
  { element: 'FAB (Liquid Glass)', property: 'modifier', token: '—', value: '.chronirGlassTintedCircle(tint:)' },
  { element: 'FAB (Light/Dark)', property: 'modifier', token: '—', value: 'Solid tint fill + Circle clip' },
  { element: 'Icon', property: 'font', token: '—', value: '.title2.weight(.semibold)', placement: 'Centered in circle', layer: 'Content' },
  { element: 'Icon', property: 'color', token: '—', value: '#FFFFFF (always white)' },
  { element: 'Wrapper', property: 'container', token: '—', value: 'AdaptiveGlassContainer', placement: 'Wraps FAB button', layer: 'Base' },
]

const fabTemplate = `// Bottom of ZStack in AlarmListView
AdaptiveGlassContainer {
    Button {
        requestCreateAlarm()
    } label: {
        Image(systemName: "plus")              // Icon
            .font(.title2.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)      // Size
            .chronirGlassTintedCircle(          // Shape + tint
                tint: ColorTokens.primary)
    }
}
.padding(.bottom, SpacingTokens.lg)            // Safe area offset`

// ─── OnboardingView ───

function OnboardingPagePreview({ icon, iconColor, headline, body, buttonLabel }) {
  return (
    <div style={{
      backgroundColor: t.bgPrimary,
      borderRadius: t.radiusMd,
      padding: '32px 24px',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: t.lg,
      minHeight: 280,
      justifyContent: 'center',
      textAlign: 'center',
    }}>
      <div style={{
        width: 96, height: 96, borderRadius: '50%',
        backgroundColor: iconColor + '1F', // 12% opacity
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 32, color: iconColor,
      }}>
        {icon}
      </div>
      <div style={{ fontSize: 24, fontWeight: 600, color: t.textPrimary, lineHeight: 1.2 }}>{headline}</div>
      <div style={{ fontSize: 14, color: t.textSecondary, lineHeight: 1.5, maxWidth: 280 }}>{body}</div>
      <div style={{
        padding: `${t.md}px ${t.lg}px`,
        backgroundColor: t.primary,
        color: '#fff',
        borderRadius: t.radiusSm,
        fontWeight: 600,
        fontSize: 14,
        width: '80%',
        textAlign: 'center',
      }}>
        {buttonLabel}
      </div>
    </div>
  )
}

function OnboardingPreview() {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
      <OnboardingPagePreview
        icon="🔔" iconColor={t.primary}
        headline="Never Forget What Matters"
        body="High-persistence alarms for the obligations that can't be missed."
        buttonLabel="Continue"
      />
      <OnboardingPagePreview
        icon="📅" iconColor={t.warning}
        headline="Weekly, Monthly, Annually"
        body="Set recurring alarms on any cycle. Rent day, medication refills, insurance renewals — all covered."
        buttonLabel="Continue"
      />
      <OnboardingPagePreview
        icon="🛡" iconColor={t.success}
        headline="Stay Notified"
        body="Chronir needs notification access to fire alarms even when the app is closed."
        buttonLabel="Enable Alarms"
      />
    </div>
  )
}

const onboardingSpecs = [
  { element: 'Page', property: 'background', token: 'color.background.primary', value: t.bgPrimary, placement: 'Full screen, paged TabView', layer: 'Base' },
  { element: 'Page', property: 'layout', token: '—', value: 'VStack, center aligned', placement: 'Vertical stack with Spacer top/bottom' },
  { element: 'Page', property: 'padding', token: 'spacing.xl', value: `${t.lg}px (xl)` },
  { element: 'Icon circle', property: 'size', token: '—', value: '96 × 96pt', placement: 'Center, top of content', layer: 'Content' },
  { element: 'Icon circle', property: 'shape', token: '—', value: 'Circle' },
  { element: 'Icon circle', property: 'background', token: '—', value: 'color.opacity(0.12)' },
  { element: 'Icon', property: 'font-size', token: '—', value: '40pt (system, medium weight)', placement: 'Centered in circle' },
  { element: 'Icon (Welcome)', property: 'color', token: 'color.primary', value: t.primary },
  { element: 'Icon (Schedules)', property: 'color', token: 'color.warning', value: t.warning },
  { element: 'Icon (Permissions)', property: 'color', token: 'color.success', value: t.success },
  { element: 'Icon → headline gap', property: 'gap', token: 'spacing.lg', value: `${t.lg}px` },
  { element: 'Headline', property: 'style', token: 'ChronirTextStyle.headlineTitle', value: '24px semibold', placement: 'Center, below icon', layer: 'Content' },
  { element: 'Headline', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Headline', property: 'alignment', token: '—', value: 'center' },
  { element: 'Body', property: 'style', token: 'ChronirTextStyle.bodySecondary', value: '14px regular', placement: 'Center, below headline', layer: 'Content' },
  { element: 'Body', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Body', property: 'alignment', token: '—', value: 'center' },
  { element: 'CTA button', property: 'component', token: '—', value: 'ChronirButton', placement: 'Bottom of content', layer: 'Content' },
  { element: 'Skip button (page 3)', property: 'style', token: 'ChronirTextStyle.bodySecondary', value: '14px', placement: 'Below CTA, page 3 only' },
  { element: 'Skip button', property: 'color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Page indicator', property: 'style', token: '—', value: 'TabView .page(indexDisplayMode: .always)', placement: 'Bottom edge', layer: 'Chrome' },
]

const onboardingTemplate = `TabView(selection: $currentPage) {
    // Page 1: Welcome
    VStack(spacing: SpacingTokens.lg) {
        Spacer()
        iconCircle(systemName: "bell.fill",      // Icon circle
                   color: ColorTokens.primary)
        ChronirText("Never Forget\\nWhat Matters",
                    style: .headlineTitle,
                    alignment: .center)           // Headline
        ChronirText("High-persistence alarms...",
                    style: .bodySecondary,
                    color: ColorTokens.textSecondary,
                    alignment: .center)           // Body
        Spacer()
        ChronirButton("Continue") {               // CTA
            currentPage += 1
        }
    }
    .padding(SpacingTokens.xl)
    .tag(0)

    // Page 2: Schedules (same layout, warning icon)
    // Page 3: Permissions (Enable Alarms + Skip)
}
.tabViewStyle(.page(indexDisplayMode: .always))
.background { ColorTokens.backgroundPrimary }`

// ─── PaywallView ───

function PaywallPreview() {
  return (
    <div style={{
      backgroundColor: t.bgPrimary,
      borderRadius: t.radiusMd,
      padding: '24px 20px',
      display: 'flex',
      flexDirection: 'column',
      gap: t.lg,
      position: 'relative',
      maxWidth: 360,
    }}>
      {/* Close button */}
      <div style={{
        position: 'absolute', top: 12, right: 12,
        width: 30, height: 30, borderRadius: '50%',
        backgroundColor: t.bgTertiary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 12, fontWeight: 700, color: t.textSecondary,
      }}>✕</div>

      {/* Header */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: t.sm, paddingTop: 16 }}>
        <span style={{ fontSize: 40, color: t.primary }}>🔔</span>
        <span style={{ fontSize: 28, fontWeight: 700, color: t.textPrimary }}>Unlock Plus</span>
      </div>

      {/* Feature list */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: t.md }}>
        {[
          { icon: '∞', label: 'Unlimited alarms' },
          { icon: '⏰', label: 'Custom snooze intervals' },
          { icon: '🔔', label: 'Pre-alarm warnings' },
          { icon: '📷', label: 'Photo attachments' },
          { icon: '📊', label: 'Completion history & streaks' },
        ].map(f => (
          <div key={f.label} style={{ display: 'flex', alignItems: 'center', gap: t.md }}>
            <div style={{
              width: 40, height: 40, borderRadius: '50%',
              backgroundColor: t.primary + '1F',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 16, color: t.primary,
            }}>{f.icon}</div>
            <span style={{ fontSize: 16, color: t.textPrimary }}>{f.label}</span>
          </div>
        ))}
      </div>

      {/* Plan selector */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: t.sm }}>
        {/* Annual — selected */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: t.md,
          padding: t.md,
          backgroundColor: t.primary + '14', // 8% opacity
          borderRadius: t.radiusMd,
          border: `2px solid ${t.primary}`,
        }}>
          <div style={{
            width: 24, height: 24, borderRadius: '50%',
            border: `2px solid ${t.primary}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <div style={{ width: 12, height: 12, borderRadius: '50%', backgroundColor: t.primary }} />
          </div>
          <span style={{ fontSize: 16, fontWeight: 500, color: t.textPrimary }}>Annual</span>
          <Badge text="Best Deal" color={t.primary} />
          <span style={{ flex: 1 }} />
          <span style={{ fontSize: 17, fontWeight: 600, color: t.textPrimary }}>$19.99</span>
        </div>
        {/* Monthly — unselected */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: t.md,
          padding: t.md,
          backgroundColor: t.surfaceCard,
          borderRadius: t.radiusMd,
          border: `0.5px solid ${t.textDisabled}`,
        }}>
          <div style={{
            width: 24, height: 24, borderRadius: '50%',
            border: `2px solid ${t.textDisabled}`,
          }} />
          <span style={{ fontSize: 16, fontWeight: 500, color: t.textPrimary }}>Monthly</span>
          <span style={{ flex: 1 }} />
          <span style={{ fontSize: 17, fontWeight: 600, color: t.textPrimary }}>$1.99</span>
        </div>
      </div>

      {/* CTA */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: t.sm }}>
        <span style={{ fontSize: 12, color: t.textSecondary, textAlign: 'center' }}>
          Auto-renews at $19.99/year. Cancel anytime in Settings.
        </span>
        <div style={{
          padding: `${t.md}px`,
          backgroundColor: t.primary,
          color: '#fff',
          borderRadius: 100,
          fontWeight: 600,
          fontSize: 17,
          width: '100%',
          textAlign: 'center',
          height: 54,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          Subscribe — $19.99/yr
        </div>
      </div>

      {/* Legal footer */}
      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, color: t.textSecondary }}>
        <span>Restore Purchases</span>
        <span>Terms & Privacy</span>
      </div>
    </div>
  )
}

const paywallSpecs = [
  { element: 'Container', property: 'background', token: 'color.background.primary', value: t.bgPrimary, placement: 'Full screen, scrollable', layer: 'Base' },
  { element: 'Container', property: 'padding', token: 'spacing.lg', value: `${t.lg}px horizontal` },
  { element: 'Container', property: 'section gap', token: 'spacing.xl', value: '24px (xl)' },
  { element: 'Close button', property: 'size', token: '—', value: '30 × 30pt', placement: 'Top-right, absolute', layer: 'Overlay' },
  { element: 'Close button', property: 'shape', token: '—', value: 'Circle' },
  { element: 'Close button', property: 'background', token: 'color.background.tertiary', value: t.bgTertiary },
  { element: 'Close button', property: 'icon color', token: 'color.text.secondary', value: t.textSecondary },
  { element: 'Close button', property: 'icon', token: '—', value: 'xmark (14pt, bold)' },
  { element: 'Close button', property: 'top padding', token: '—', value: '60pt' },
  { element: 'Header icon', property: 'font-size', token: '—', value: '48pt (system)', placement: 'Center, top', layer: 'Content' },
  { element: 'Header icon', property: 'color', token: 'color.primary', value: t.primary },
  { element: 'Header title', property: 'font-size', token: '—', value: '36px', placement: 'Center, below icon' },
  { element: 'Header title', property: 'font-weight', token: '—', value: '700 (bold)' },
  { element: 'Header title', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Feature icon circle', property: 'size', token: '—', value: '40 × 40pt', placement: 'Feature row, leading', layer: 'Content' },
  { element: 'Feature icon circle', property: 'background', token: '—', value: 'color.primary.opacity(0.12)' },
  { element: 'Feature icon', property: 'font-size', token: '—', value: '16pt (medium weight)' },
  { element: 'Feature icon', property: 'color', token: 'color.primary', value: t.primary },
  { element: 'Feature text', property: 'style', token: 'ChronirTextStyle.bodyLarge', value: '16px', placement: 'Feature row, after icon' },
  { element: 'Feature text', property: 'color', token: 'color.text.primary', value: t.textPrimary },
  { element: 'Feature row gap', property: 'gap', token: 'spacing.md', value: `${t.md}px` },
  { element: 'Plan card', property: 'padding', token: 'spacing.md', value: `${t.md}px`, placement: 'Plan selector section', layer: 'Content' },
  { element: 'Plan card', property: 'border-radius', token: 'GlassTokens.cardRadius', value: `${t.radiusMd}px` },
  { element: 'Plan card (selected)', property: 'background', token: 'color.primary', value: `${t.primary} @ 8% opacity` },
  { element: 'Plan card (selected)', property: 'border', token: 'color.primary', value: `2px solid ${t.primary}` },
  { element: 'Plan card (unselected)', property: 'background', token: 'color.surface.card', value: t.surfaceCard },
  { element: 'Plan card (unselected)', property: 'border', token: 'color.border.default', value: '0.5px solid' },
  { element: 'Radio (selected)', property: 'fill', token: 'color.primary', value: t.primary },
  { element: 'Radio (unselected)', property: 'stroke', token: 'color.border.default', value: '2px stroke' },
  { element: 'Radio', property: 'size', token: '—', value: '24pt outer, 12pt inner dot' },
  { element: 'Plan label', property: 'style', token: 'ChronirTextStyle.bodyLarge', value: '16px', placement: 'Plan card, after radio' },
  { element: 'Plan price', property: 'font-size', token: '—', value: '17px (semibold)', placement: 'Plan card, trailing' },
  { element: 'Badge (Best Deal)', property: 'component', token: '—', value: 'ChronirBadge', placement: 'Plan card, after label' },
  { element: 'Renewal terms', property: 'style', token: '.caption', value: '12px', placement: 'Above CTA button, center', layer: 'Content' },
  { element: 'Renewal terms', property: 'color', token: 'color.text.tertiary', value: t.textSecondary },
  { element: 'CTA button', property: 'height', token: '—', value: '54pt', placement: 'Below terms', layer: 'Content' },
  { element: 'CTA button', property: 'background', token: 'color.primary', value: t.primary },
  { element: 'CTA button', property: 'shape', token: '—', value: 'Capsule' },
  { element: 'CTA button', property: 'font-size', token: '—', value: '17px (semibold)' },
  { element: 'CTA button', property: 'color', token: '—', value: '#FFFFFF' },
  { element: 'Legal footer', property: 'layout', token: '—', value: 'HStack, space-between', placement: 'Bottom of scroll', layer: 'Content' },
  { element: 'Legal footer', property: 'style', token: '.caption', value: '12px' },
  { element: 'Legal footer', property: 'color', token: 'color.text.tertiary', value: t.textSecondary },
]

const paywallTemplate = `ZStack(alignment: .topTrailing) {
    ScrollView(showsIndicators: false) {
        VStack(spacing: SpacingTokens.xl) {
            // Header
            VStack(spacing: SpacingTokens.sm) {
                Spacer().frame(height: 80)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(ColorTokens.primary)
                Text("Unlock Plus")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(ColorTokens.textPrimary)
            }

            // Feature list
            VStack(spacing: SpacingTokens.md) {
                featureRow(icon: "infinity",
                           title: "Unlimited alarms")
                // ... more features
            }

            // Plan selector
            VStack(spacing: SpacingTokens.sm) {
                planRow(plan: .annual,
                        label: "Annual",
                        price: "$19.99",
                        badge: "Best Deal")       // Selected state
                planRow(plan: .monthly,
                        label: "Monthly",
                        price: "$1.99",
                        badge: nil)                // Unselected state
            }

            // CTA
            VStack(spacing: SpacingTokens.sm) {
                Text(renewalTermsText)
                    .chronirFont(.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
                Button { purchase() } label: {
                    Text("Subscribe — $19.99/yr")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(ColorTokens.primary, in: Capsule())
                }
            }

            // Legal footer
            HStack {
                Button("Restore Purchases") { ... }
                Spacer()
                Link("Terms") + Link("Privacy")
            }
            .chronirFont(.caption)
            .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(.horizontal, SpacingTokens.lg)
    }
    closeButton                                    // Top-right X
}
.background { ColorTokens.backgroundPrimary }`

// ─── Registry ───

// ─── Named exports for FlatlayView ───

export { t, Badge, Toggle }
export { AlarmCardPreview, FiringOverlayPreview, EmptyStatePreview }
export { ButtonVariantsPreview, BadgeVariantsPreview }
export { ToggleRowPreview, PermissionRowPreview }
export { TextFieldPreview, IntervalPickerPreview }
export { CategoryGroupCardPreview }
export { FABPreview }
export { OnboardingPreview, PaywallPreview }

// ─── Registry ───

export const previews = {
  ChronirButton: () => (
    <>
      <ButtonVariantsPreview />
      <SpecTable specs={buttonSpecs} />
      <StructureTemplate code={buttonTemplate} />
    </>
  ),
  ChronirBadge: () => (
    <>
      <BadgeVariantsPreview />
      <SpecTable specs={badgeSpecs} />
      <StructureTemplate code={badgeTemplate} />
    </>
  ),
  AlarmCard: () => (
    <>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        <AlarmCardPreview title="Morning Workout" cycleType="Weekly" time="6:30 AM" countdown="6h 32m" state="active" persistent />
        <AlarmCardPreview title="Pay Rent" cycleType="Monthly" time="9:00 AM" state="inactive" />
        <AlarmCardPreview title="Morning Workout" cycleType="Weekly" time="6:30 AM" countdown="1h" state="snoozed" persistent />
        <AlarmCardPreview title="Pay Rent" cycleType="Monthly" time="9:00 AM" state="overdue" />
      </div>
      <SpecTable specs={alarmCardSpecs} />
      <StructureTemplate code={alarmCardTemplate} />
    </>
  ),
  AlarmFiringOverlay: () => (
    <>
      <FiringOverlayPreview />
      <SpecTable specs={firingOverlaySpecs} />
      <StructureTemplate code={firingOverlayTemplate} />
    </>
  ),
  EmptyStateView: () => (
    <>
      <EmptyStatePreview />
      <SpecTable specs={emptyStateSpecs} />
      <StructureTemplate code={emptyStateTemplate} />
    </>
  ),
  AlarmToggleRow: () => (
    <>
      <ToggleRowPreview />
      <SpecTable specs={toggleRowSpecs} />
      <StructureTemplate code={toggleRowTemplate} />
    </>
  ),
  PermissionStatusRow: () => (
    <>
      <PermissionRowPreview />
      <SpecTable specs={permissionRowSpecs} />
      <StructureTemplate code={permissionRowTemplate} />
    </>
  ),
  LabeledTextField: () => (
    <>
      <TextFieldPreview />
      <SpecTable specs={textFieldSpecs} />
      <StructureTemplate code={textFieldTemplate} />
    </>
  ),
  IntervalPicker: () => (
    <>
      <IntervalPickerPreview />
      <SpecTable specs={intervalPickerSpecs} />
      <StructureTemplate code={intervalPickerTemplate} />
    </>
  ),
  CategoryGroupCard: () => (
    <>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
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
      <SpecTable specs={categoryGroupCardSpecs} />
      <StructureTemplate code={categoryGroupCardTemplate} />
    </>
  ),
  ChronirFAB: () => (
    <>
      <FABPreview />
      <SpecTable specs={fabSpecs} />
      <StructureTemplate code={fabTemplate} />
    </>
  ),
  OnboardingView: () => (
    <>
      <OnboardingPreview />
      <SpecTable specs={onboardingSpecs} />
      <StructureTemplate code={onboardingTemplate} />
    </>
  ),
  PaywallView: () => (
    <>
      <PaywallPreview />
      <SpecTable specs={paywallSpecs} />
      <StructureTemplate code={paywallTemplate} />
    </>
  ),
}
