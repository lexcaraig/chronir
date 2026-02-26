import { useState } from 'react'
import { lightTheme, darkTheme, resolvedLookup } from '../tokens'

const IPHONE_WIDTH = 393
const IPHONE_HEIGHT = 852
const SCALE = 0.55

const screens = [
  { id: 'alarm-list', label: 'Alarm List' },
  { id: 'alarm-firing', label: 'Alarm Firing' },
  { id: 'alarm-pending', label: 'Pending Confirm' },
  { id: 'alarm-creation', label: 'New Alarm' },
  { id: 'settings', label: 'Settings' },
]

// Resolve a token path like "color.theme.dark.background" from the lookup
function tok(path) {
  return resolvedLookup[path] || path
}

// ─── Screen Renderers ───────────────────────────────────────────────

function AlarmListScreen({ mode }) {
  const t = mode === 'dark' ? darkTheme : lightTheme
  const isLight = mode === 'light'
  const cardBg = isLight ? 'rgba(255,255,255,0.7)' : 'rgba(255,255,255,0.08)'
  const cardBorder = isLight ? 'rgba(0,0,0,0.06)' : 'rgba(255,255,255,0.08)'

  const alarms = [
    { title: 'Pay Rent', time: '9:00 AM', badge: 'Monthly · 1st', countdown: 'In 2 weeks', active: true },
    { title: 'Water Plants', time: '8:00 AM', badge: 'Weekly · Mon', countdown: 'Tomorrow', active: true },
    { title: 'Oil Change', time: '10:00 AM', badge: 'Annual · Mar 15', countdown: 'In 28 days', active: false },
  ]

  return (
    <div className="screen-content" style={{ background: t.background, color: t.textPrimary }}>
      {/* Status bar */}
      <StatusBar mode={mode} />
      {/* Nav bar */}
      <div className="screen-nav" style={{ borderBottom: `0.5px solid ${t.borderDefault}` }}>
        <span style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.5 }}>Alarms</span>
        <span style={{ fontSize: 20, opacity: 0.5 }}>&#9881;</span>
      </div>
      {/* Alarm cards */}
      <div style={{ padding: '12px 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {alarms.map((a, i) => (
          <div key={i} className="screen-card" style={{
            background: cardBg,
            border: `0.5px solid ${cardBorder}`,
            backdropFilter: 'blur(20px)',
            borderRadius: 16,
            padding: '14px 16px',
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                <span style={{ fontSize: 13, color: t.textSecondary }}>{a.countdown}</span>
                <span style={{ fontSize: 22, fontWeight: 600 }}>{a.time}</span>
                <span style={{ fontSize: 15, fontWeight: 500 }}>{a.title}</span>
                <span className="screen-badge" style={{
                  fontSize: 11,
                  fontWeight: 600,
                  background: isLight ? t.textPrimary : 'rgba(255,255,255,0.12)',
                  color: isLight ? '#fff' : t.textSecondary,
                  padding: '3px 8px',
                  borderRadius: 6,
                  alignSelf: 'flex-start',
                  marginTop: 4,
                }}>{a.badge}</span>
              </div>
              <div className="screen-toggle" style={{
                width: 48, height: 28, borderRadius: 14,
                background: a.active ? tok('color.primitive.green.500') : (isLight ? '#ddd' : '#444'),
                position: 'relative',
                flexShrink: 0,
              }}>
                <div style={{
                  width: 22, height: 22, borderRadius: 11,
                  background: '#fff',
                  position: 'absolute', top: 3,
                  left: a.active ? 23 : 3,
                  boxShadow: '0 1px 3px rgba(0,0,0,0.2)',
                  transition: 'left 0.2s',
                }} />
              </div>
            </div>
          </div>
        ))}
      </div>
      {/* FAB */}
      <div style={{
        position: 'absolute', bottom: 100, right: 20,
        width: 52, height: 52, borderRadius: 26,
        background: isLight ? t.textPrimary : 'rgba(255,255,255,0.12)',
        backdropFilter: 'blur(20px)',
        border: `0.5px solid ${cardBorder}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: isLight ? '#fff' : t.textPrimary,
        fontSize: 24, fontWeight: 300,
        boxShadow: '0 4px 16px rgba(0,0,0,0.2)',
      }}>+</div>
      {/* Home indicator */}
      <HomeIndicator mode={mode} />
    </div>
  )
}

function AlarmFiringScreen() {
  return (
    <div className="screen-content" style={{
      background: tok('color.firing.background'),
      color: tok('color.firing.foreground'),
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'space-between', padding: '0 24px',
    }}>
      <StatusBar mode="dark" light />
      {/* Top content */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginTop: 80, gap: 4 }}>
        <span style={{ fontSize: 48, fontWeight: 700, letterSpacing: -1 }}>Pay Rent</span>
        <span style={{ fontSize: 64, fontWeight: 700, letterSpacing: -2, opacity: 0.9 }}>9:00 AM</span>
        <span style={{
          fontSize: 11, fontWeight: 600,
          background: 'rgba(255,255,255,0.12)',
          color: 'rgba(255,255,255,0.7)',
          padding: '3px 10px', borderRadius: 6, marginTop: 8,
        }}>Monthly &middot; 1st</span>
        <span style={{
          fontSize: 14, opacity: 0.5, marginTop: 16, textAlign: 'center',
        }}>Don&apos;t forget to transfer from savings</span>
      </div>
      {/* Snooze buttons */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
        {['1h', '1d', '1w'].map(d => (
          <div key={d} style={{
            padding: '10px 20px', borderRadius: 12,
            background: 'rgba(255,255,255,0.08)',
            border: '0.5px solid rgba(255,255,255,0.1)',
            color: 'rgba(255,255,255,0.7)', fontSize: 14, fontWeight: 500,
          }}>{d}</div>
        ))}
      </div>
      {/* Plus tier: Mark as Done (primary) + Stop Alarm (secondary) */}
      <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 36 }}>
        <div style={{
          width: '100%', padding: '16px 0',
          borderRadius: 16,
          background: 'rgba(255,255,255,0.15)',
          border: '0.5px solid rgba(255,255,255,0.2)',
          textAlign: 'center', fontSize: 16, fontWeight: 600,
          color: tok('color.firing.foreground'),
          letterSpacing: 0.3,
        }}>Mark as Done</div>
        <div style={{
          textAlign: 'center', fontSize: 14, fontWeight: 500,
          color: 'rgba(255,255,255,0.5)',
          letterSpacing: 0.2,
        }}>Stop Alarm</div>
        <div style={{
          fontSize: 10, color: 'rgba(255,255,255,0.3)', textAlign: 'center', lineHeight: 1.4,
        }}>
          <em>Mark as Done</em> = immediate completion<br />
          <em>Stop Alarm</em> = silences, enters Pending state
        </div>
      </div>
      <HomeIndicator mode="dark" />
    </div>
  )
}

function AlarmPendingScreen({ mode }) {
  const t = mode === 'dark' ? darkTheme : lightTheme
  const isLight = mode === 'light'
  const cardBg = isLight ? 'rgba(255,255,255,0.7)' : 'rgba(255,255,255,0.08)'
  const cardBorder = isLight ? 'rgba(0,0,0,0.06)' : 'rgba(255,255,255,0.08)'
  const infoBorder = isLight ? '#3B82F6' : '#60A5FA'
  const infoText = isLight ? '#3B82F6' : '#60A5FA'
  const successBg = isLight ? '#22C55E' : '#4ADE80'

  return (
    <div className="screen-content" style={{ background: t.background, color: t.textPrimary }}>
      <StatusBar mode={mode} />
      <div className="screen-nav" style={{ borderBottom: `0.5px solid ${t.borderDefault}` }}>
        <span style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.5 }}>Alarms</span>
      </div>

      {/* Section header */}
      <div style={{ padding: '16px 20px 8px', fontSize: 11, fontWeight: 600, color: t.textSecondary, textTransform: 'uppercase', letterSpacing: 0.8 }}>
        Completion Confirmation (Plus)
      </div>

      {/* Pending alarm card with blue border */}
      <div style={{ padding: '0 16px 8px' }}>
        <div style={{
          background: cardBg,
          border: `2px solid ${infoBorder}`,
          backdropFilter: 'blur(20px)',
          borderRadius: 16,
          padding: '14px 16px',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{ fontSize: 13, color: infoText }}>&#128339;</span>
                <span style={{ fontSize: 12, fontWeight: 600, color: infoText }}>Awaiting Confirmation</span>
              </div>
              <span style={{ fontSize: 22, fontWeight: 600 }}>9:00 AM</span>
              <span style={{ fontSize: 15, fontWeight: 500 }}>Pay Rent</span>
              <span className="screen-badge" style={{
                fontSize: 11, fontWeight: 600,
                background: isLight ? t.textPrimary : 'rgba(255,255,255,0.12)',
                color: isLight ? '#fff' : t.textSecondary,
                padding: '3px 8px', borderRadius: 6, alignSelf: 'flex-start', marginTop: 4,
              }}>Monthly &middot; 1st</span>
            </div>
          </div>
        </div>
      </div>

      {/* How to confirm section */}
      <div style={{ padding: '16px 20px 8px', fontSize: 11, fontWeight: 600, color: t.textSecondary, textTransform: 'uppercase', letterSpacing: 0.8 }}>
        How to Confirm Completion
      </div>

      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {/* Method 1: Swipe */}
        <div style={{
          background: cardBg, border: `0.5px solid ${cardBorder}`,
          borderRadius: 12, padding: '12px 14px',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{
              width: 32, height: 32, borderRadius: 8,
              background: successBg, display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 16, color: '#fff', fontWeight: 700,
            }}>&#10003;</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <span style={{ fontSize: 14, fontWeight: 600 }}>Swipe Right on Card</span>
              <span style={{ fontSize: 12, color: t.textSecondary }}>
                Swipe alarm card right &rarr; tap green &quot;Done&quot; button
              </span>
            </div>
          </div>
        </div>

        {/* Method 2: Notification */}
        <div style={{
          background: cardBg, border: `0.5px solid ${cardBorder}`,
          borderRadius: 12, padding: '12px 14px',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{
              width: 32, height: 32, borderRadius: 8,
              background: infoText, display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 14, color: '#fff', fontWeight: 700,
            }}>&#128276;</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <span style={{ fontSize: 14, fontWeight: 600 }}>Notification Action</span>
              <span style={{ fontSize: 12, color: t.textSecondary }}>
                Long-press notification &rarr; tap &quot;Done&quot; button
              </span>
            </div>
          </div>
        </div>

        {/* Notification timeline */}
        <div style={{
          background: cardBg, border: `0.5px solid ${cardBorder}`,
          borderRadius: 12, padding: '12px 14px',
        }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: t.textSecondary, marginBottom: 8, textTransform: 'uppercase', letterSpacing: 0.5 }}>
            Follow-Up Notifications
          </div>
          {[
            { time: '+30 min', label: '"Did you complete it?"' },
            { time: '+60 min', label: 'Second reminder' },
            { time: '+90 min', label: 'Final reminder' },
          ].map((n, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10, padding: '6px 0',
              borderTop: i > 0 ? `0.5px solid ${t.borderDefault}` : 'none',
            }}>
              <span style={{
                fontSize: 11, fontWeight: 600, color: infoText,
                width: 52, flexShrink: 0,
              }}>{n.time}</span>
              <span style={{ fontSize: 13, color: t.textSecondary }}>{n.label}</span>
              <div style={{ marginLeft: 'auto', display: 'flex', gap: 4 }}>
                <span style={{ fontSize: 10, fontWeight: 600, color: successBg, background: isLight ? '#DCFCE7' : 'rgba(74,222,128,0.15)', padding: '2px 6px', borderRadius: 4 }}>Done</span>
                <span style={{ fontSize: 10, fontWeight: 600, color: t.textSecondary, background: isLight ? '#F3F4F6' : 'rgba(255,255,255,0.08)', padding: '2px 6px', borderRadius: 4 }}>Remind Me</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      <HomeIndicator mode={mode} />
    </div>
  )
}

function AlarmCreationScreen({ mode }) {
  const t = mode === 'dark' ? darkTheme : lightTheme
  const isLight = mode === 'light'
  const fieldBg = isLight ? 'rgba(0,0,0,0.04)' : 'rgba(255,255,255,0.06)'

  return (
    <div className="screen-content" style={{ background: t.background, color: t.textPrimary }}>
      <StatusBar mode={mode} />
      {/* Sheet header */}
      <div className="screen-nav" style={{ borderBottom: `0.5px solid ${t.borderDefault}`, justifyContent: 'space-between' }}>
        <span style={{ fontSize: 15, color: t.textSecondary }}>Cancel</span>
        <span style={{ fontSize: 17, fontWeight: 600 }}>New Alarm</span>
        <span style={{ fontSize: 15, fontWeight: 600, color: t.textSecondary }}>Save</span>
      </div>
      {/* Form */}
      <div style={{ padding: '16px 16px', display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Title field */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: t.textSecondary, textTransform: 'uppercase', letterSpacing: 0.5 }}>Title</span>
          <div style={{
            padding: '12px 14px', borderRadius: 12, background: fieldBg,
            border: `0.5px solid ${t.borderDefault}`, fontSize: 15,
          }}>Pay Rent</div>
        </div>
        {/* Time */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: t.textSecondary, textTransform: 'uppercase', letterSpacing: 0.5 }}>Time</span>
          <div style={{
            padding: '12px 14px', borderRadius: 12, background: fieldBg,
            border: `0.5px solid ${t.borderDefault}`, fontSize: 15,
            display: 'flex', justifyContent: 'space-between',
          }}>
            <span>9:00 AM</span>
            <span style={{ color: t.textTertiary }}>&#9662;</span>
          </div>
        </div>
        {/* Repeat cycle */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: t.textSecondary, textTransform: 'uppercase', letterSpacing: 0.5 }}>Repeat</span>
          <div style={{ display: 'flex', gap: 6 }}>
            {['Weekly', 'Monthly', 'Annual', 'One-Time'].map((c, i) => (
              <div key={c} style={{
                padding: '7px 12px', borderRadius: 8, fontSize: 13, fontWeight: 500,
                background: i === 1 ? (isLight ? t.textPrimary : 'rgba(255,255,255,0.15)') : fieldBg,
                color: i === 1 ? (isLight ? '#fff' : t.textPrimary) : t.textSecondary,
                border: `0.5px solid ${i === 1 ? 'transparent' : t.borderDefault}`,
              }}>{c}</div>
            ))}
          </div>
        </div>
        {/* Day grid preview (monthly) */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: t.textSecondary, textTransform: 'uppercase', letterSpacing: 0.5 }}>Day</span>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4 }}>
            {Array.from({ length: 31 }, (_, i) => i + 1).map(d => (
              <div key={d} style={{
                width: '100%', aspectRatio: '1', borderRadius: 8,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 12, fontWeight: d === 1 ? 600 : 400,
                background: d === 1 ? (isLight ? t.textPrimary : 'rgba(255,255,255,0.15)') : fieldBg,
                color: d === 1 ? (isLight ? '#fff' : t.textPrimary) : t.textSecondary,
              }}>{d}</div>
            ))}
          </div>
        </div>
        {/* Category */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: t.textSecondary, textTransform: 'uppercase', letterSpacing: 0.5 }}>Category</span>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {[['None', ''], ['Home', '\ud83c\udfe0'], ['Finance', '\ud83d\udcb0'], ['Health', '\ud83d\udcaa'], ['Vehicle', '\ud83d\ude97']].map(([label, icon], i) => (
              <div key={label} style={{
                padding: '7px 12px', borderRadius: 8, fontSize: 13, fontWeight: 500,
                background: i === 2 ? (isLight ? t.textPrimary : 'rgba(255,255,255,0.15)') : fieldBg,
                color: i === 2 ? (isLight ? '#fff' : t.textPrimary) : t.textSecondary,
                border: `0.5px solid ${i === 2 ? 'transparent' : t.borderDefault}`,
              }}>{icon} {label}</div>
            ))}
          </div>
        </div>
      </div>
      <HomeIndicator mode={mode} />
    </div>
  )
}

function SettingsScreen({ mode }) {
  const t = mode === 'dark' ? darkTheme : lightTheme
  const isLight = mode === 'light'
  const rowBg = isLight ? 'rgba(0,0,0,0.03)' : 'rgba(255,255,255,0.05)'

  const sections = [
    {
      header: 'ALARM BEHAVIOR',
      rows: [
        { label: 'Snooze Enabled', toggle: true, on: true },
        { label: 'Slide to Stop', toggle: true, on: true },
        { label: 'Haptic Feedback', toggle: true, on: false },
        { label: 'Alarm Sound', value: 'Beacon' },
      ],
    },
    {
      header: 'APPEARANCE',
      rows: [
        { label: 'Theme', value: 'Glass' },
        { label: 'Text Size', value: 'Standard' },
        { label: 'Group by Category', toggle: true, on: false },
      ],
    },
    {
      header: 'DATA',
      rows: [
        { label: 'Subscription', value: 'Plus', badge: true },
        { label: 'Completion History', chevron: true },
      ],
    },
    {
      header: 'ABOUT',
      rows: [
        { label: 'Version', value: '1.0.0' },
        { label: 'Privacy Policy', chevron: true },
        { label: 'Terms of Service', chevron: true },
      ],
    },
  ]

  return (
    <div className="screen-content" style={{ background: t.background, color: t.textPrimary, overflowY: 'auto' }}>
      <StatusBar mode={mode} />
      <div className="screen-nav" style={{ borderBottom: `0.5px solid ${t.borderDefault}` }}>
        <span style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.5 }}>Settings</span>
      </div>
      <div style={{ padding: '8px 16px 40px' }}>
        {sections.map((s, si) => (
          <div key={si} style={{ marginBottom: 24 }}>
            <div style={{
              fontSize: 11, fontWeight: 600, color: t.textSecondary,
              letterSpacing: 0.8, padding: '0 4px 6px', textTransform: 'uppercase',
            }}>{s.header}</div>
            <div style={{ borderRadius: 12, overflow: 'hidden', background: rowBg }}>
              {s.rows.map((r, ri) => (
                <div key={ri} style={{
                  display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                  padding: '13px 14px', fontSize: 15,
                  borderTop: ri > 0 ? `0.5px solid ${t.borderDefault}` : 'none',
                }}>
                  <span>{r.label}</span>
                  {r.toggle ? (
                    <div style={{
                      width: 44, height: 26, borderRadius: 13,
                      background: r.on ? tok('color.primitive.green.500') : (isLight ? '#ddd' : '#444'),
                      position: 'relative', flexShrink: 0,
                    }}>
                      <div style={{
                        width: 20, height: 20, borderRadius: 10,
                        background: '#fff', position: 'absolute', top: 3,
                        left: r.on ? 21 : 3,
                        boxShadow: '0 1px 2px rgba(0,0,0,0.2)',
                      }} />
                    </div>
                  ) : r.badge ? (
                    <span style={{
                      fontSize: 12, fontWeight: 600, padding: '2px 8px',
                      borderRadius: 6, background: isLight ? t.textPrimary : 'rgba(255,255,255,0.12)',
                      color: isLight ? '#fff' : t.textSecondary,
                    }}>{r.value}</span>
                  ) : r.chevron ? (
                    <span style={{ color: t.textTertiary, fontSize: 14 }}>&#8250;</span>
                  ) : (
                    <span style={{ color: t.textSecondary, fontSize: 14 }}>{r.value}</span>
                  )}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
      <HomeIndicator mode={mode} />
    </div>
  )
}

// ─── Shared Chrome ──────────────────────────────────────────────────

function StatusBar({ mode, light }) {
  const color = (mode === 'dark' || light) ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.8)'
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '14px 24px 8px', fontSize: 12, fontWeight: 600, color,
      flexShrink: 0,
    }}>
      <span>9:41</span>
      <div style={{
        width: 120, height: 32, borderRadius: 16,
        background: mode === 'dark' || light ? '#000' : '#1E1F21',
        position: 'absolute', left: '50%', transform: 'translateX(-50%)', top: 8,
      }} />
      <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
        {/* Signal bars */}
        <svg width="16" height="12" viewBox="0 0 16 12">
          <rect x="0" y="8" width="3" height="4" rx="0.5" fill={color} />
          <rect x="4.5" y="5" width="3" height="7" rx="0.5" fill={color} />
          <rect x="9" y="2" width="3" height="10" rx="0.5" fill={color} />
          <rect x="13.5" y="0" width="2.5" height="12" rx="0.5" fill={color} opacity="0.3" />
        </svg>
        {/* Battery */}
        <svg width="24" height="12" viewBox="0 0 24 12">
          <rect x="0.5" y="0.5" width="20" height="11" rx="2" stroke={color} strokeWidth="1" fill="none" />
          <rect x="2" y="2" width="14" height="8" rx="1" fill={color} />
          <rect x="21.5" y="3.5" width="2" height="5" rx="1" fill={color} opacity="0.4" />
        </svg>
      </div>
    </div>
  )
}

function HomeIndicator({ mode }) {
  const color = mode === 'dark' ? 'rgba(255,255,255,0.25)' : 'rgba(0,0,0,0.2)'
  return (
    <div style={{
      position: 'absolute', bottom: 8, left: '50%', transform: 'translateX(-50%)',
      width: 134, height: 5, borderRadius: 3, background: color,
    }} />
  )
}

// ─── iPhone Device Frame ────────────────────────────────────────────

function IPhoneFrame({ children, label }) {
  return (
    <div className="iphone-frame-wrapper">
      <div className="iphone-frame" style={{
        width: IPHONE_WIDTH, height: IPHONE_HEIGHT,
        transform: `scale(${SCALE})`,
        transformOrigin: 'top center',
      }}>
        <div className="iphone-screen">
          {children}
        </div>
      </div>
      {label && <div className="iphone-label">{label}</div>}
    </div>
  )
}

// ─── Main Section ───────────────────────────────────────────────────

export default function ScreensSection({ theme }) {
  const [activeScreen, setActiveScreen] = useState('alarm-list')
  const [previewMode, setPreviewMode] = useState('dark')
  const [viewMode, setViewMode] = useState('single')

  const renderScreen = (screenId, mode) => {
    switch (screenId) {
      case 'alarm-list': return <AlarmListScreen mode={mode} />
      case 'alarm-firing': return <AlarmFiringScreen />
      case 'alarm-pending': return <AlarmPendingScreen mode={mode} />
      case 'alarm-creation': return <AlarmCreationScreen mode={mode} />
      case 'settings': return <SettingsScreen mode={mode} />
      default: return null
    }
  }

  return (
    <section className="section" id="screens">
      <h2 className="section-title">
        <span className="section-number">07</span>
        APP SCREENS
      </h2>
      <p className="section-description">
        Live previews of Chronir's key screens rendered at iPhone 15 Pro resolution (393 &times; 852pt), styled with actual design tokens.
      </p>

      {/* Controls */}
      <div className="screens-controls">
        <div className="screens-control-group">
          <span className="screens-control-label">View</span>
          <div className="screens-toggle-group">
            <button
              className={`screens-toggle ${viewMode === 'single' ? 'active' : ''}`}
              onClick={() => setViewMode('single')}
            >Single</button>
            <button
              className={`screens-toggle ${viewMode === 'gallery' ? 'active' : ''}`}
              onClick={() => setViewMode('gallery')}
            >Gallery</button>
          </div>
        </div>

        {viewMode === 'single' && (
          <div className="screens-control-group">
            <span className="screens-control-label">Screen</span>
            <div className="screens-toggle-group">
              {screens.map(s => (
                <button
                  key={s.id}
                  className={`screens-toggle ${activeScreen === s.id ? 'active' : ''}`}
                  onClick={() => setActiveScreen(s.id)}
                >{s.label}</button>
              ))}
            </div>
          </div>
        )}

        <div className="screens-control-group">
          <span className="screens-control-label">Theme</span>
          <div className="screens-toggle-group">
            <button
              className={`screens-toggle ${previewMode === 'light' ? 'active' : ''}`}
              onClick={() => setPreviewMode('light')}
            >Light</button>
            <button
              className={`screens-toggle ${previewMode === 'dark' ? 'active' : ''}`}
              onClick={() => setPreviewMode('dark')}
            >Dark</button>
          </div>
        </div>
      </div>

      {/* Preview area */}
      {viewMode === 'single' ? (
        <div className="screens-preview-single">
          <IPhoneFrame label={screens.find(s => s.id === activeScreen)?.label}>
            {renderScreen(activeScreen, previewMode)}
          </IPhoneFrame>
        </div>
      ) : (
        <div className="screens-preview-gallery">
          {screens.map(s => (
            <IPhoneFrame key={s.id} label={s.label}>
              {renderScreen(s.id, previewMode)}
            </IPhoneFrame>
          ))}
        </div>
      )}
    </section>
  )
}
