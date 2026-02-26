import { useState, useMemo } from 'react'

/* ── FAQ Data ── */
const faqData = [
  {
    id: 'general',
    title: 'General',
    questions: [
      {
        id: 'what-is-chronir',
        q: 'What is Chronir?',
        a: 'Chronir is a high-persistence alarm app for long-cycle recurring tasks — weekly, monthly, and annual obligations. It treats long-term commitments with the urgency of a morning wake-up alarm: full-screen, persistent, and undeniable.',
        tags: ['overview', 'purpose'],
      },
      {
        id: 'how-different',
        q: 'How is Chronir different from regular reminders or calendar alerts?',
        a: 'Regular reminders are easy to dismiss and forget. Chronir fires full-screen alarms with sound that persist until you actively acknowledge them. It\'s designed for tasks where "I\'ll do it later" leads to "I forgot for three months." Calendar alerts notify; Chronir demands action.',
        tags: ['comparison', 'reminders'],
      },
      {
        id: 'platforms',
        q: 'What platforms does Chronir support?',
        a: 'Chronir is available on iOS (requires iOS 26 or later). An Android version is planned for a future release.',
        tags: ['ios', 'android', 'platform'],
      },
      {
        id: 'account-required',
        q: 'Do I need an account to use Chronir?',
        a: 'No. Chronir works entirely offline with no account required. All alarms are stored locally on your device. If you upgrade to Chronir Plus, you can optionally enable cloud backup, but it\'s never mandatory.',
        tags: ['account', 'offline', 'privacy'],
      },
      {
        id: 'schedule-types',
        q: 'What schedule types does Chronir support?',
        a: 'Chronir supports daily, weekly, monthly, and annual recurring schedules. You can also create one-time alarms for non-repeating tasks. Monthly alarms handle edge cases like the 31st in shorter months, and annual alarms correctly handle leap years.',
        tags: ['schedule', 'recurring', 'one-time'],
      },
    ],
  },
  {
    id: 'alarm-behavior',
    title: 'Alarm Behavior',
    questions: [
      {
        id: 'what-happens-fire',
        q: 'What happens when an alarm fires?',
        a: 'When an alarm fires, Chronir presents a full-screen alarm view with the alarm title, category color, and scheduled time. A persistent sound plays until you take action. You can stop the alarm, snooze it, or (with Plus) mark it as done directly.',
        tags: ['fire', 'alert', 'full-screen'],
      },
      {
        id: 'persistent-alarm',
        q: 'What is a persistent alarm?',
        a: 'A persistent alarm continues alerting until you explicitly acknowledge it. Unlike standard notifications that disappear after a few seconds, Chronir alarms stay on screen with sound playing. If your phone is locked, the alarm appears on the lock screen. This ensures you never accidentally miss a long-cycle task.',
        tags: ['persistent', 'alerting'],
      },
      {
        id: 'dnd',
        q: 'Does Chronir fire through Do Not Disturb?',
        a: 'Yes. Chronir uses AlarmKit on iOS, which is classified as an alarm and can break through Do Not Disturb and Focus modes, just like your morning alarm clock. This is by design — long-cycle obligations shouldn\'t be silenced.',
        tags: ['dnd', 'focus', 'alarmkit'],
      },
      {
        id: 'lock-screen-stop',
        q: 'What happens if I stop an alarm from the lock screen?',
        a: 'Stopping an alarm from the lock screen marks it as completed and immediately reschedules the next occurrence. The alarm sound stops and the notification is dismissed. This behaves identically to stopping the alarm from within the app.',
        tags: ['lock-screen', 'stop', 'dismiss'],
      },
      {
        id: 'snooze-options',
        q: 'What snooze options are available?',
        a: 'Chronir offers configurable snooze durations: 5, 10, 15, and 30 minutes. When you snooze, a countdown begins. After the snooze period expires, the alarm fires again with full sound. Snooze counts are tracked per alarm occurrence. With Chronir Plus, you can set custom default snooze durations.',
        tags: ['snooze', 'duration', 'countdown'],
      },
    ],
  },
  {
    id: 'completion-confirmation',
    title: 'Completion Confirmation',
    questions: [
      {
        id: 'stop-vs-done',
        q: 'What is the difference between "Stop Alarm" and "Mark as Done"?',
        a: '"Stop Alarm" silences the alarm and schedules the next occurrence — the task is complete. "Mark as Done" (Plus feature) does the same but also records the completion in your history, contributing to your streak. Both actions fully complete the alarm; the difference is whether the completion is tracked for streak purposes.',
        tags: ['stop', 'done', 'completion'],
        plus: true,
      },
      {
        id: 'pending-confirmation',
        q: 'What is Pending Confirmation?',
        a: 'When you stop an alarm but haven\'t explicitly marked it as done, the alarm enters a "Pending Confirmation" state (Plus feature). A badge appears on the alarm in your list, reminding you to confirm whether you actually completed the underlying task. This prevents the common pattern of stopping an alarm just to silence it without doing the work.',
        tags: ['pending', 'badge', 'confirmation'],
        plus: true,
      },
      {
        id: 'follow-up-notifications',
        q: 'Why do I get follow-up notifications after stopping an alarm?',
        a: 'If you stop an alarm without marking it as done, Chronir sends a pre-alarm notification before the next occurrence as a gentle reminder. This is part of the Completion Confirmation system (Plus feature) that helps ensure tasks actually get completed, not just acknowledged.',
        tags: ['notification', 'follow-up', 'pre-alarm'],
        plus: true,
      },
      {
        id: 'streak-impact',
        q: 'How does Completion Confirmation affect my streak?',
        a: 'Your streak increments only when you explicitly "Mark as Done." Simply stopping an alarm does not count toward the streak. If you stop an alarm and later confirm completion from the alarm list, the streak is updated retroactively for that occurrence. Broken streaks reset to zero.',
        tags: ['streak', 'history', 'tracking'],
        plus: true,
      },
    ],
  },
  {
    id: 'tiers',
    title: 'Free vs. Plus Tiers',
    questions: [
      {
        id: 'free-limit',
        q: 'What is the Free tier limit?',
        a: 'The Free tier allows up to 3 active alarms. All core features work: full-screen persistent alarms, snooze, all schedule types (daily, weekly, monthly, annual, one-time), and category organization. The 3-alarm limit is designed to cover the most critical obligations.',
        tags: ['free', 'limit', 'alarms'],
      },
      {
        id: 'plus-features',
        q: 'What does Chronir Plus include?',
        a: 'Chronir Plus ($1.99/month) unlocks: unlimited alarms, photo attachments on alarms, custom snooze durations, pre-alarm warning notifications, completion history tracking, streak counting, and optional cloud backup. All features work offline; cloud is optional.',
        tags: ['plus', 'subscription', 'features'],
      },
      {
        id: 'cloud-required',
        q: 'Is cloud sync required?',
        a: 'No. Cloud backup is an optional Plus feature. All alarms fire from on-device storage and never depend on an internet connection. Cloud backup provides peace of mind for device migration or recovery, but Chronir is designed as a local-first app.',
        tags: ['cloud', 'sync', 'offline'],
      },
      {
        id: 'how-upgrade',
        q: 'How do I upgrade to Plus?',
        a: 'Go to Settings > Subscription > Upgrade to Plus. The subscription is managed through Apple\'s App Store and can be cancelled at any time. If your subscription expires, existing alarms beyond the 3-alarm limit are preserved but disabled until you either re-subscribe or delete alarms to reach the free limit.',
        tags: ['upgrade', 'subscription', 'settings'],
      },
    ],
  },
  {
    id: 'features',
    title: 'Features',
    questions: [
      {
        id: 'streaks',
        q: 'How do streaks work?',
        a: 'Streaks track consecutive on-time completions for each alarm. When you "Mark as Done" for an alarm occurrence, the streak counter increments. Missing an alarm (letting it fire without completion) or explicitly breaking the streak resets it to zero. Streaks are per-alarm, not global. This is a Plus feature.',
        tags: ['streak', 'completion', 'tracking'],
      },
      {
        id: 'cloud-sync',
        q: 'How does cloud sync work?',
        a: 'Cloud sync (Plus feature) backs up your alarms to Firebase Cloud. It uses a local-first, last-write-wins strategy: your device is always the source of truth, and changes sync to the cloud when connectivity is available. Offline changes queue automatically and push when you\'re back online.',
        tags: ['cloud', 'sync', 'firebase', 'backup'],
      },
      {
        id: 'one-time-alarms',
        q: 'What are one-time alarms?',
        a: 'One-time alarms fire once at the scheduled date and time, then automatically disable themselves. They\'re useful for non-recurring deadlines like "Renew passport by March 15" or "Submit tax return." After firing, they remain in your alarm list (disabled) for reference.',
        tags: ['one-time', 'single', 'deadline'],
      },
      {
        id: 'pre-alarm-warnings',
        q: 'What are pre-alarm warnings?',
        a: 'Pre-alarm warnings (Plus feature) send a notification before the alarm fires — for example, 1 hour or 1 day before. This gives you a heads-up to prepare for upcoming obligations without the full alarm experience. Useful for tasks that require preparation, like "Pack for monthly trip."',
        tags: ['pre-alarm', 'notification', 'warning'],
        plus: true,
      },
      {
        id: 'photo-attachments',
        q: 'Can I attach photos to alarms?',
        a: 'Yes, with Chronir Plus. You can attach a photo to any alarm — useful for visual reminders like a photo of a medication label, a receipt to file, or a maintenance checklist. Photos are stored locally and included in cloud backup if enabled.',
        tags: ['photo', 'attachment', 'image'],
        plus: true,
      },
      {
        id: 'siri',
        q: 'Does Chronir work with Siri?',
        a: 'Yes. Chronir integrates with App Intents, allowing you to create and manage alarms via Siri. You can say things like "Create a Chronir alarm" or "Show my Chronir alarms." Siri shortcuts can also be configured for frequently used actions.',
        tags: ['siri', 'voice', 'shortcuts', 'intents'],
      },
    ],
  },
]

/* ── Plus Badge ── */
function PlusBadge() {
  return <span className="faq-plus-badge">PLUS</span>
}

/* ── Main Component ── */
export default function FaqSection() {
  const [query, setQuery] = useState('')
  const [openItems, setOpenItems] = useState(new Set())
  const [openCategories, setOpenCategories] = useState(
    () => new Set(faqData.map(c => c.id))
  )

  const filtered = useMemo(() => {
    if (!query.trim()) return faqData
    const q = query.toLowerCase()
    return faqData
      .map(category => ({
        ...category,
        questions: category.questions.filter(
          item =>
            item.q.toLowerCase().includes(q) ||
            item.a.toLowerCase().includes(q) ||
            item.tags.some(t => t.includes(q))
        ),
      }))
      .filter(category => category.questions.length > 0)
  }, [query])

  const toggleItem = (id) => {
    setOpenItems(prev => {
      const next = new Set(prev)
      next.has(id) ? next.delete(id) : next.add(id)
      return next
    })
  }

  const toggleCategory = (id) => {
    setOpenCategories(prev => {
      const next = new Set(prev)
      next.has(id) ? next.delete(id) : next.add(id)
      return next
    })
  }

  const totalQuestions = faqData.reduce((sum, c) => sum + c.questions.length, 0)
  const matchCount = filtered.reduce((sum, c) => sum + c.questions.length, 0)

  return (
    <div className="section">
      <div className="section-header">
        <h2 className="section-title">
          <span className="section-number">FAQ</span>
          Frequently Asked Questions
        </h2>
        <p className="section-description">
          Everything you need to know about Chronir — alarm behavior, tiers, features, and how it all works together.
        </p>
      </div>

      <div className="section-body">
        {/* Search */}
        <div className="faq-search-wrap">
          <svg className="faq-search-icon" width="16" height="16" viewBox="0 0 16 16" fill="none">
            <circle cx="7" cy="7" r="5.5" stroke="currentColor" strokeWidth="1.5" />
            <path d="M11 11l3.5 3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
          </svg>
          <label htmlFor="faq-search" className="visually-hidden">Search FAQ questions</label>
          <input
            id="faq-search"
            className="faq-search-input"
            type="text"
            placeholder="Search questions..."
            value={query}
            onChange={e => setQuery(e.target.value)}
          />
          {query && (
            <span className="faq-search-count">
              {matchCount} of {totalQuestions}
            </span>
          )}
          {query && (
            <button className="faq-search-clear" onClick={() => setQuery('')}>
              &times;
            </button>
          )}
        </div>

        {/* Categories */}
        {filtered.length === 0 ? (
          <div className="faq-empty">
            No questions match "{query}"
          </div>
        ) : (
          <div className="faq-categories">
            {filtered.map(category => {
              const isOpen = openCategories.has(category.id)
              return (
                <div key={category.id} className="faq-category">
                  <button
                    className="faq-category-header"
                    onClick={() => toggleCategory(category.id)}
                  >
                    <span className={`arch-chevron ${isOpen ? 'open' : ''}`}>&#9656;</span>
                    <span className="faq-category-title">{category.title}</span>
                    <span className="faq-category-count">{category.questions.length}</span>
                  </button>
                  {isOpen && (
                    <div className="faq-category-body">
                      {category.questions.map(item => {
                        const isItemOpen = openItems.has(item.id)
                        return (
                          <div key={item.id} className="faq-item">
                            <button
                              className={`faq-item-header ${isItemOpen ? 'open' : ''}`}
                              onClick={() => toggleItem(item.id)}
                            >
                              <span className="faq-item-question">
                                {item.q}
                                {item.plus && <PlusBadge />}
                              </span>
                              <span className={`faq-item-chevron ${isItemOpen ? 'open' : ''}`}>
                                &#9656;
                              </span>
                            </button>
                            {isItemOpen && (
                              <div className="faq-item-answer">{item.a}</div>
                            )}
                          </div>
                        )
                      })}
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
