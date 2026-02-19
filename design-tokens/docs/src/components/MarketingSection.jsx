import { useState } from 'react'

const posts = [
  {
    id: 'reddit',
    platform: 'Reddit',
    subreddits: 'r/iosapps, r/sideproject',
    title: 'I built an app that treats rent day like a wake-up alarm — because notifications weren\'t cutting it',
    body: `I kept missing rent and bill payments. Not because I'm irresponsible — because phone notifications are too easy to dismiss. Calendar reminder pops up? Swiped away in 0.5 seconds while I'm scrolling Twitter. "Oh I'll deal with that later." Later never comes.

The thing is, we already solved this problem for mornings. Wake-up alarms are full-screen, persistent, and loud. You *can't* ignore them. But for some reason, everything else on your phone — rent, insurance renewals, pet vaccinations, annual tax stuff — gets reduced to a little banner that disappears in 3 seconds.

So I built **Chronir**.

It's a real alarm app (uses AlarmKit, not notifications) for long-cycle recurring tasks. Weekly, monthly, annual, one-time — whatever. When it fires, it fires like a morning alarm: full-screen, persistent, cuts through Do Not Disturb. You have to actually deal with it.

**What it does:**

- Real alarms that fire through DND (AlarmKit, not push notifications)
- Full-screen persistent firing view — no silent banner you can swipe away
- Flexible scheduling: weekly, monthly (specific date or relative like "last Friday"), annual, one-time, custom day intervals
- Siri shortcuts — "Hey Siri, create a Chronir alarm" / "What's my next alarm?"
- Categories with filtering to organize everything
- Custom wallpaper for each alarm
- Smart snooze with custom intervals (Plus)
- Pre-alarm warnings so you can prepare ahead of time (Plus)
- Completion history and streaks to track your follow-through (Plus)
- Photo attachments — attach a photo of your insurance card to the renewal alarm (Plus)

**Pricing:**

- Free: 2 alarms, no account needed, no sign-up wall
- Plus: $1.99/mo or $19.99/yr for unlimited alarms + all the extras above

**The way I think about it:** Your calendar tells you what's coming. Chronir makes sure you actually do it.

iOS only right now (requires iOS 26 for AlarmKit). Would love feedback from anyone who also suffers from "I saw the notification but forgot anyway" syndrome.

[App Store link]`,
  },
  {
    id: 'twitter',
    platform: 'Twitter/X',
    format: 'Thread (6 tweets)',
    tweets: [
      {
        label: 'Tweet 1 — Hook',
        text: `I kept missing rent payments — not because I forgot, but because a phone notification is the easiest thing in the world to ignore.

So I built an app that treats monthly bills like a morning wake-up alarm.

Here's why:`,
      },
      {
        label: 'Tweet 2 — Problem',
        text: `Calendar reminders pop up as a banner. You swipe them away in 0.5 seconds. "I'll deal with it later."

For mornings, we solved this decades ago — alarms are full-screen, loud, persistent. You HAVE to engage.

But for rent? Insurance renewals? Annual stuff? You get a tiny notification that disappears in 3 seconds.`,
      },
      {
        label: 'Tweet 3 — Solution',
        text: `Chronir uses real AlarmKit alarms (not notifications) for recurring tasks.

When it fires, it fires like a wake-up alarm: full screen, persistent, cuts through Do Not Disturb. No silent banners.

Weekly, monthly, annual, one-time — whatever schedule you need.`,
      },
      {
        label: 'Tweet 4 — Features',
        text: `What's in the box:

\u2022 Full-screen firing view you can't ignore
\u2022 Fires through DND
\u2022 Relative scheduling ("last Friday of the month")
\u2022 Siri integration
\u2022 Completion streaks
\u2022 Pre-alarm warnings
\u2022 Photo attachments (attach your insurance card to the renewal alarm)`,
      },
      {
        label: 'Tweet 5 — Positioning',
        text: `The way I think about it:

Your calendar tells you what's coming.
Chronir makes sure you actually do it.

It fills the gap between "easily ignored reminder" and "alarm that demands your attention."`,
      },
      {
        label: 'Tweet 6 — CTA',
        text: `Free tier gives you 2 alarms, no account needed.

Plus is $1.99/mo for unlimited alarms + custom snooze, pre-alarm warnings, streaks, and photo attachments.

iOS only (requires iOS 26). Link below.

[App Store link]`,
      },
    ],
  },
  {
    id: 'threads',
    platform: 'Threads',
    format: 'Single post',
    body: `I built an alarm app for people who are great at setting reminders but terrible at actually doing the thing.

The problem: phone notifications are too easy to dismiss. Calendar reminder for rent? Swiped away while scrolling. "I'll handle it later." You will not handle it later.

We already solved this for mornings — wake-up alarms are full-screen, loud, and persistent. You HAVE to deal with them. But somehow everything else important (bills, insurance renewals, annual taxes, pet vaccinations) gets a little banner that vanishes in 3 seconds.

Chronir treats those obligations the same way. Real alarms. Full-screen firing. Cuts through DND. Weekly, monthly, annual, one-time — whatever you need. Siri shortcuts. Completion streaks to keep you honest.

Free tier: 2 alarms, no account. Plus ($1.99/mo): unlimited alarms, custom snooze, pre-alarm warnings, photo attachments.

Your calendar tells you what's coming. This makes sure you actually do it.

iOS only right now. [App Store link]`,
  },
]

const verifiedClaims = [
  { claim: 'AlarmKit (real alarms, not notifications)', source: 'AlarmService.swift' },
  { claim: 'Full-screen persistent firing', source: 'AlarmFiringView.swift' },
  { claim: 'Fires through DND', source: 'AlarmKit system behavior' },
  { claim: 'Weekly/monthly/annual/one-time/custom scheduling', source: 'Schedule.swift (6 types)' },
  { claim: 'Relative dates ("last Friday of month")', source: 'Schedule.monthlyRelative' },
  { claim: 'Siri integration', source: 'Core/Intents/ (Create, GetNext, List)' },
  { claim: 'Categories with filtering', source: 'Alarm.category, AlarmListView' },
  { claim: 'Custom wallpaper', source: 'Alarm.wallpaperName' },
  { claim: 'Smart snooze (Plus)', source: 'Snooze system + SubscriptionService' },
  { claim: 'Pre-alarm warnings (Plus)', source: 'PreAlarmNotificationService' },
  { claim: 'Completion history & streaks (Plus)', source: 'CompletionRecord model' },
  { claim: 'Photo attachments (Plus)', source: 'Alarm.photoAttachmentPaths' },
  { claim: 'Free: 2 alarms, no account', source: 'SubscriptionTier.alarmLimit' },
  { claim: 'Plus: $1.99/mo, $19.99/yr', source: 'SubscriptionService productIDs' },
]

function CopyButton({ text }) {
  const [copied, setCopied] = useState(false)

  const handleCopy = async () => {
    await navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 1500)
  }

  return (
    <button className="marketing-copy-btn" onClick={handleCopy}>
      {copied ? 'Copied!' : 'Copy'}
    </button>
  )
}

function RedditPost({ post }) {
  const fullText = `Title: ${post.title}\n\n${post.body}`
  return (
    <div className="marketing-post-card">
      <div className="marketing-post-header">
        <div>
          <span className="marketing-platform-badge">Reddit</span>
          <span className="marketing-post-meta">{post.subreddits}</span>
        </div>
        <CopyButton text={fullText} />
      </div>
      <div className="marketing-post-title">{post.title}</div>
      <div className="marketing-post-body">{post.body}</div>
    </div>
  )
}

function TwitterThread({ post }) {
  const fullText = post.tweets.map((t, i) => `${i + 1}/${post.tweets.length}\n${t.text}`).join('\n\n---\n\n')
  return (
    <div className="marketing-post-card">
      <div className="marketing-post-header">
        <div>
          <span className="marketing-platform-badge">Twitter/X</span>
          <span className="marketing-post-meta">{post.format}</span>
        </div>
        <CopyButton text={fullText} />
      </div>
      <div className="marketing-tweet-thread">
        {post.tweets.map((tweet, i) => (
          <div key={i} className="marketing-tweet">
            <div className="marketing-tweet-header">
              <span className="marketing-tweet-label">{tweet.label}</span>
              <CopyButton text={tweet.text} />
            </div>
            <div className="marketing-tweet-body">{tweet.text}</div>
          </div>
        ))}
      </div>
    </div>
  )
}

function ThreadsPost({ post }) {
  return (
    <div className="marketing-post-card">
      <div className="marketing-post-header">
        <div>
          <span className="marketing-platform-badge">Threads</span>
          <span className="marketing-post-meta">{post.format}</span>
        </div>
        <CopyButton text={post.body} />
      </div>
      <div className="marketing-post-body">{post.body}</div>
    </div>
  )
}

export default function MarketingSection() {
  const [activeTab, setActiveTab] = useState('posts')

  return (
    <section className="section" id="marketing">
      <h2 className="section-title">
        <span className="section-number">08</span>
        MARKETING
      </h2>
      <p className="section-description">
        Launch copy and promotional content for Chronir. All feature claims verified against shipping code.
      </p>

      <div className="component-tabs" style={{ marginTop: 24 }}>
        <button
          className={`component-tab ${activeTab === 'posts' ? 'active' : ''}`}
          onClick={() => setActiveTab('posts')}
        >Launch Posts</button>
        <button
          className={`component-tab ${activeTab === 'claims' ? 'active' : ''}`}
          onClick={() => setActiveTab('claims')}
        >Verified Claims</button>
      </div>

      {activeTab === 'posts' && (
        <div className="marketing-posts">
          <RedditPost post={posts[0]} />
          <TwitterThread post={posts[1]} />
          <ThreadsPost post={posts[2]} />
        </div>
      )}

      {activeTab === 'claims' && (
        <div className="marketing-claims">
          <div className="marketing-claims-header">
            <p style={{ fontSize: 13, color: 'var(--text-secondary)', marginBottom: 16, lineHeight: 1.7 }}>
              Every feature claim in the launch posts maps to a verified source file.
              <strong style={{ color: 'var(--text)' }}> Not advertised:</strong> Cloud sync, shared alarms, Premium tier, Live Activities, family sharing.
            </p>
          </div>
          <div className="spec-table-wrap">
            <table className="spec-table">
              <thead>
                <tr>
                  <th>Claim</th>
                  <th>Source</th>
                </tr>
              </thead>
              <tbody>
                {verifiedClaims.map((c, i) => (
                  <tr key={i}>
                    <td className="spec-element">{c.claim}</td>
                    <td className="spec-token">{c.source}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </section>
  )
}
