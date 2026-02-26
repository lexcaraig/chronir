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

- Free: 3 alarms, no account needed, no sign-up wall
- Plus: $1.99/mo or $19.99/yr for unlimited alarms + all the extras above

**The way I think about it:** Your calendar tells you what's coming. Chronir makes sure you actually do it.

iOS only right now (requires iOS 26 for AlarmKit). Would love feedback from anyone who also suffers from "I saw the notification but forgot anyway" syndrome.

https://apps.apple.com/ph/app/chronir/id6758985902`,
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
        text: `Free tier gives you 3 alarms, no account needed.

Plus is $1.99/mo for unlimited alarms + custom snooze, pre-alarm warnings, streaks, and photo attachments.

iOS only (requires iOS 26). Link below.

https://apps.apple.com/ph/app/chronir/id6758985902`,
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

Free tier: 3 alarms, no account. Plus ($1.99/mo): unlimited alarms, custom snooze, pre-alarm warnings, photo attachments.

Your calendar tells you what's coming. This makes sure you actually do it.

iOS only right now. https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
]

const communityPosts = [
  {
    subreddit: 'r/getdisciplined',
    title: 'I stopped relying on willpower for recurring tasks and built a system that literally won\'t let me forget',
    body: `For years I tried the "just remember to do it" approach for things like paying rent, renewing insurance, scheduling doctor appointments. I'd set a calendar reminder, swipe it away, and tell myself I'd handle it later. Spoiler: I rarely did.

The turning point was realizing willpower isn't the problem — the system is. Phone notifications are designed to be dismissed. They're polite little banners that vanish in 3 seconds. That's fine for "your Uber is arriving" but terrible for "your rent is due tomorrow."

So I built an app called **Chronir** that treats these obligations like morning wake-up alarms. Full-screen, persistent, fires through Do Not Disturb. You can't just swipe it away — you have to actually engage with it. Snooze it, mark it done, whatever — but you can't pretend you didn't see it.

It supports weekly, monthly, annual, and custom schedules. Things like "last Friday of every month" or "every 90 days" just work.

The philosophy is simple: systems beat willpower every time. If you build a system that makes forgetting impossible, discipline becomes a lot easier.

Free tier gives you 3 alarms, no account needed. iOS only right now (uses AlarmKit which requires iOS 26). Would love to hear how others here approach recurring obligation management.

https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    subreddit: 'r/selfimprovement',
    title: 'The gap between knowing what to do and actually doing it — and how I\'m trying to close it',
    body: `I think most of us know what we should be doing. Take your meds. Pay your bills on time. Follow up on that appointment. Call your parents every week. The knowledge isn't the problem — the follow-through is.

For me, the breaking point was missing my car insurance renewal for the third time. Not because I didn't know about it. I got the email. I got the calendar reminder. I swiped both away and said "I'll do it after dinner." I did not do it after dinner.

The problem isn't laziness. It's that modern phones treat "your DoorDash is ready" and "your insurance expires tomorrow" with the same level of urgency: a dismissible banner notification.

I built **Chronir** because I needed something that bridges the gap between intention and action. It's an alarm app for recurring tasks — not notifications, actual alarms. When it fires, it takes over your screen like a morning alarm. Full-screen, persistent, cuts through DND. You have to deal with it.

Weekly, monthly, annual, one-time, custom intervals — whatever cadence your life runs on. Each alarm can have categories, photo attachments (I attach my insurance card to the renewal alarm), and completion tracking so you can see your follow-through streak.

I'm not saying an app solves self-improvement. But removing "I forgot" from the equation has been genuinely life-changing for me. The 3 alarms on the free tier cover most people's critical obligations.

iOS only (requires iOS 26). https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    subreddit: 'r/ADHD',
    title: 'I have ADHD and built an alarm app because notifications are useless for my brain',
    body: `If you have ADHD, you probably know the drill: you see a notification, think "I'll handle that in 5 minutes," and then it's gone from your brain forever. Out of sight, out of mind isn't a cliché for us — it's a neurological reality.

I have the same problem. Time blindness makes "I'll do it later" dangerous because "later" doesn't exist in my brain the way it does for neurotypical people. And executive dysfunction means even when I DO remember, the activation energy to start is enormous — so a gentle reminder that I can swipe away? Useless.

I built **Chronir** because I needed reminders that match the urgency my brain requires. It's an alarm app that uses real AlarmKit alarms (not notifications) for recurring tasks. When it fires:

- Full-screen takeover — can't miss it, can't pretend you didn't see it
- Fires through Do Not Disturb — because of course DND is always on
- Persistent until you engage — snooze it, mark it done, but you HAVE to interact
- Smart snooze with custom intervals — because sometimes you genuinely can't do it right now

For scheduling, it handles all the weird cadences: monthly on a specific date, "second Tuesday of every month," every 90 days, annually, etc. You can attach photos (I attach reference docs to each alarm so I don't have to go hunting when it fires) and track completion streaks.

The philosophy is: if my brain won't hold onto the information, the system has to be loud enough that it can't be ignored. Notifications are whispers. This is an alarm.

Free tier: 3 alarms, no sign-up. Plus ($1.99/mo) for unlimited + extras. iOS only right now (requires iOS 26).

Not a miracle cure — but removing "I forgot" from the equation has helped me more than any productivity hack.

https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    subreddit: 'r/Procrastinationism',
    title: '"I\'ll do it later" was costing me money, so I built an app that won\'t let me say that anymore',
    body: `The most expensive sentence in my life has been "I'll do it later."

Late rent fees. Lapsed insurance I had to re-apply for. A dentist appointment I kept "meaning to reschedule" for 8 months. Expired domains. A prescription I forgot to refill until I ran out.

Every single one of these had a reminder set. Calendar events, to-do apps, sticky notes on my monitor. The problem isn't that I didn't know — it's that every reminder system we have is designed to be politely dismissed. A notification pops up, you swipe it away, and the future version of you who was supposed to handle it simply doesn't.

So I built **Chronir**. It's an alarm app for recurring obligations, and it's deliberately obnoxious. When an alarm fires, it takes over your entire screen like a morning wake-up alarm. Full-screen, persistent, fires through Do Not Disturb. You cannot swipe it away. You have to either do the thing, or consciously snooze it (and it'll come back).

I know it sounds aggressive, but that's the point. "I'll do it later" only works when the reminder goes away. If it doesn't go away, you just... do the thing.

Weekly, monthly, annual, custom intervals — set it once and it recurs forever. Free tier gives you 3 alarms. iOS only (requires iOS 26).

Anyone else here find that the "reminder" isn't the problem — it's the "dismissability"?

https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    subreddit: 'r/GetStudying',
    title: 'I built an alarm app for recurring study sessions because calendar reminders weren\'t holding me accountable',
    body: `Anyone else set "study session" reminders that you consistently ignore? I used to have a repeating calendar event for exam prep every evening at 7pm. I'd see the notification, think "yeah, after this episode," and never open a textbook.

The core problem is that study reminders arrive as notifications — the same quiet banners as "someone liked your photo." They're trivially easy to dismiss, especially when the alternative is doing something hard.

I built **Chronir** to fix this for myself. It's an alarm app that uses real device alarms (AlarmKit, not notifications) for recurring tasks. When your study session alarm fires:

- Full-screen takeover — not a banner, not a badge, your entire screen
- Fires through Do Not Disturb — no hiding behind focus modes
- Persistent until you interact — snooze or acknowledge, but you can't pretend you didn't see it
- Completion streaks — see your consecutive study days, which is genuinely motivating

For students specifically, it's useful for:
- Daily/weekly study blocks
- Spaced repetition reminders (custom day intervals)
- Assignment deadline alarms (one-time, set it the day it's assigned)
- Exam countdown with pre-alarm warnings (get a heads-up days before)

The free tier gives you 3 alarms, which is probably enough for most students (daily study + weekly review + one deadline). No account required. Plus ($1.99/mo) unlocks unlimited.

iOS only right now (requires iOS 26). Curious if anyone else has found a way to make study reminders actually stick.

https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    subreddit: 'r/ProductivityApps',
    title: 'Chronir — an alarm app for recurring tasks (not a to-do list, not a reminder app)',
    body: `**What it is:** An alarm app that uses real AlarmKit alarms (not notifications) for recurring obligations. Think of it as your morning alarm clock, but for rent, bills, insurance renewals, medication, and anything else you keep "forgetting" to do.

**Why it exists:** Phone notifications are designed to be dismissed. Calendar reminders pop up as a banner for 3 seconds and vanish. That's fine for low-stakes stuff, but for things that actually matter — rent, prescriptions, annual renewals — you need something that demands your attention.

**How it's different from [Reminders / Due / Alarmed / etc.]:**

- Uses AlarmKit, not UNNotificationRequest — fires like a wake-up alarm, full-screen, through DND
- Persistent firing view — stays on screen until you interact (snooze or complete)
- Built specifically for long-cycle recurring tasks, not daily to-dos
- Relative scheduling — "last Friday of every month," "second Tuesday," etc.
- Siri integration — "Hey Siri, create a Chronir alarm" / "What's my next alarm?"

**Features:**
- 6 schedule types: weekly, monthly (date), monthly (relative), annual, one-time, custom interval
- Categories with filtering
- Custom wallpaper per alarm
- Smart snooze with custom intervals (Plus)
- Pre-alarm warnings — get notified days before (Plus)
- Completion history & streaks (Plus)
- Photo attachments — attach documents to relevant alarms (Plus)

**Pricing:**
- Free: 3 alarms, no account, no sign-up wall
- Plus: $1.99/mo or $19.99/yr — unlimited alarms + all extras

**Platform:** iOS only (requires iOS 26 for AlarmKit). No Android version yet.

https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    subreddit: 'r/productivity',
    title: 'Systems > motivation: I replaced my notification-based reminders with actual alarms and my follow-through rate went from ~60% to near 100%',
    body: `I used to think my problem was motivation. "If I just cared more about paying rent on time, I'd do it." But then I realized I care a LOT about paying rent on time — I just have a system (notifications) that's designed to be ignored.

Think about it: your phone treats "your Uber is 2 min away" and "your rent is due tomorrow" with the same urgency. Both get a dismissible banner that vanishes in seconds. One of those things has a $50 late fee. The system is broken.

The fix, for me, was embarrassingly simple: use actual alarms instead of notifications. I built **Chronir** around this idea. It's an alarm app for recurring tasks that fires like your morning alarm — full-screen, persistent, fires through Do Not Disturb. You have to physically interact with it to make it stop.

Why this works (from a systems-thinking perspective):

1. **Eliminates the dismissal problem** — You can't swipe away a full-screen alarm without making a conscious choice
2. **Matches urgency to importance** — Morning alarms work because they're impossible to ignore. Same principle applies to your obligations
3. **Removes willpower from the equation** — You don't need to "remember" or "be disciplined." The system handles it

It supports weekly, monthly (specific date or relative like "last Friday"), annual, one-time, and custom intervals. Set it once, forget about it, and trust the system to grab your attention when it's time.

I've been using it for my own recurring obligations for months now. Late fees: $0. Missed renewals: 0. Follow-through on weekly commitments: near 100%. Not because I'm more disciplined — because the system won't let me forget.

Free: 3 alarms. Plus ($1.99/mo): unlimited + extras. iOS only (iOS 26). https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    subreddit: 'r/DecidingToBeBetter',
    title: 'I kept breaking promises to myself about recurring commitments, so I built something that holds me accountable',
    body: `Every New Year I'd make the same commitments: call my parents every Sunday. Do a monthly budget review. Schedule that annual physical. Clean the gutters before winter.

And every year, the same thing happened: I'd do it for a few weeks, then a notification would pop up while I was busy, I'd swipe it away, and the streak would break. Not because I stopped caring — because phone notifications are the world's worst accountability system. They're designed to be dismissed in under a second.

The thing is, we already have a reminder system that works: alarm clocks. Nobody "forgets" to wake up because the alarm is impossible to ignore. It's full-screen, it's loud, and it won't stop until you deal with it. So why do we use gentle little notification banners for everything else that matters?

I built **Chronir** because I needed that same level of accountability for my commitments to myself. It's an alarm app for recurring tasks — real alarms (AlarmKit, not push notifications), full-screen, persistent, fires through DND. When your "call Mom" alarm goes off on Sunday, you can't pretend you didn't see it.

It also tracks completion history and streaks, which sounds gimmicky but genuinely helps. Seeing "12 weeks in a row" next to your weekly commitment makes you not want to break the chain.

The way I think about it: keeping promises to yourself is one of the most important things you can do for self-trust. And "I forgot" shouldn't be the reason you break them — especially when the technology to prevent forgetting is this simple.

Free: 3 alarms, no account. Plus ($1.99/mo): unlimited + extras. iOS only (requires iOS 26).

What recurring commitments do you keep breaking? Curious what others here would use this for.

https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
]

const emailTemplates = [
  {
    id: 'influencer-initial',
    label: 'Influencer — Initial Outreach',
    subject: 'Collab opportunity — free Plus access to Chronir (alarm app for recurring tasks)',
    body: `Hey {{name}},

I've been following your content on {{platform}} — your post about {{relevant_post_topic}} really resonated with me.

I'm the developer behind Chronir, an iOS app that turns recurring obligations (rent, bills, renewals, etc.) into real full-screen alarms that you can't swipe away. Think of it as your morning alarm clock, but for everything else that matters.

I'd love to offer you free Plus access ($1.99/mo value — unlimited alarms, custom snooze, pre-alarm warnings, completion streaks, photo attachments) in exchange for an honest mention on your {{platform}} page. No script, no talking points — just your genuine experience using it.

Quick stats:
- iOS only (requires iOS 26)
- Free tier: 3 alarms, no account needed
- Plus: unlimited alarms + all premium features
- Uses real AlarmKit alarms, not notifications — fires through DND

If you're interested, I'll send you a redemption code right away. Happy to answer any questions.

Best,
Lex
Chronir — https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    id: 'influencer-followup',
    label: 'Influencer — Follow-Up (No Response)',
    subject: 'Re: Collab opportunity — Chronir',
    body: `Hey {{name}},

Just bumping this in case it got buried — I know inboxes are brutal.

Quick recap: I built Chronir, an alarm app for recurring tasks (rent, bills, renewals). It fires like a morning alarm — full-screen, persistent, through DND. Not a notification you can swipe away.

I'd love to give you free Plus access if you're open to trying it and sharing your honest experience with your audience. No strings attached — if you try it and it's not for you, no hard feelings.

Here's the App Store link if you want to check it out first: https://apps.apple.com/ph/app/chronir/id6758985902

Let me know either way — appreciate your time.

Lex`,
  },
  {
    id: 'influencer-code-delivery',
    label: 'Influencer — Sending the Code',
    subject: 'Your free Chronir Plus code',
    body: `Hey {{name}},

Awesome — thanks for being down to try Chronir!

Here's your Plus redemption code: {{promo_code}}

To redeem:
1. Download Chronir from the App Store: https://apps.apple.com/ph/app/chronir/id6758985902
2. Go to Settings → Apple ID → Subscriptions → Redeem Code
3. Enter the code above

This gives you full Plus access (unlimited alarms, custom snooze, pre-alarm warnings, completion streaks, photo attachments).

Some ideas for alarms to try:
- Rent/bills on a specific day of the month
- "Last Friday of the month" type schedules
- Annual renewals (insurance, registrations)
- Weekly check-ins (call parents, weekly review)

No rush on the post — take your time using it first. I'd rather you have a genuine experience to share.

If you run into anything or have feedback, just reply here. I read everything.

Lex`,
  },
  {
    id: 'influencer-thankyou',
    label: 'Influencer — Post-Promotion Thank You',
    subject: 'Thanks for the Chronir shoutout!',
    body: `Hey {{name}},

Just saw your {{post_type}} — thank you! Really appreciate the honest take.

{{optional_specific_callout}}

Your code is active for {{duration}}, and I'm happy to extend it if you want to keep using the app. Just let me know.

If any of your followers reach out with questions or feedback, feel free to point them to me or our App Store page. And if you ever want to do another collab down the road, the door's always open.

Thanks again — this means a lot for a solo dev.

Lex`,
  },
  {
    id: 'adhd-creator',
    label: 'ADHD / Productivity Creator Outreach',
    subject: 'Built an alarm app for ADHD brains — would love your take',
    body: `Hey {{name}},

I've been watching your content about {{adhd_or_productivity_topic}} and it hit close to home.

I have ADHD and built Chronir because notifications are useless for our brains. You see it, think "I'll handle that in 5 minutes," and it's gone forever. Out of sight, out of mind isn't a cliché — it's neurological.

Chronir turns recurring tasks into real full-screen alarms (AlarmKit, not notifications). When it fires:
- Full-screen takeover — can't miss it
- Fires through Do Not Disturb
- Persistent until you interact — no silent dismissal
- Completion streaks to track follow-through

I think your audience would genuinely benefit from this, and I'd love to offer you free Plus access to try it. No script — just your honest experience. If it doesn't work for you, that's valid feedback too.

iOS only (requires iOS 26). Happy to send a code if you're interested.

Lex
https://apps.apple.com/ph/app/chronir/id6758985902`,
  },
  {
    id: 'finance-creator',
    label: 'Finance / Budgeting Creator Outreach',
    subject: 'An app that makes sure your audience never misses a bill again',
    body: `Hey {{name}},

Love your content on {{finance_topic}}. One thing I notice across personal finance communities: people know WHAT to pay and WHEN — they just forget to actually do it because phone notifications are too easy to dismiss.

I built Chronir to fix this. It's an alarm app that treats bill due dates, insurance renewals, and financial deadlines like morning wake-up alarms — full-screen, persistent, fires through Do Not Disturb. You can't swipe it away. You have to deal with it.

Scheduling handles the weird stuff: "last Friday of every month," specific dates, annual renewals, custom intervals. Set it once, never miss it again.

I think this would be genuinely useful for your audience, and I'd love to offer you free Plus access (unlimited alarms + all features) if you're open to trying it and sharing your experience.

Free tier: 3 alarms. Plus: $1.99/mo. iOS only (iOS 26).

Happy to send a code if you're interested.

Lex
https://apps.apple.com/ph/app/chronir/id6758985902`,
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
  { claim: 'Free: 3 alarms, no account', source: 'SubscriptionTier.alarmLimit' },
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

function EmailTemplate({ template }) {
  const fullText = `Subject: ${template.subject}\n\n${template.body}`
  return (
    <div className="marketing-post-card">
      <div className="marketing-post-header">
        <div>
          <span className="marketing-platform-badge">Email</span>
          <span className="marketing-post-meta">{template.label}</span>
        </div>
        <CopyButton text={fullText} />
      </div>
      <div className="marketing-post-title" style={{ fontSize: 14 }}>
        Subject: {template.subject}
      </div>
      <div className="marketing-post-body">{template.body}</div>
    </div>
  )
}

function CommunityRedditPost({ post }) {
  const fullText = `Title: ${post.title}\n\n${post.body}`
  return (
    <div className="marketing-post-card">
      <div className="marketing-post-header">
        <div>
          <span className="marketing-platform-badge">{post.subreddit}</span>
        </div>
        <CopyButton text={fullText} />
      </div>
      <div className="marketing-post-title">{post.title}</div>
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
          className={`component-tab ${activeTab === 'community' ? 'active' : ''}`}
          onClick={() => setActiveTab('community')}
        >Community Posts</button>
        <button
          className={`component-tab ${activeTab === 'emails' ? 'active' : ''}`}
          onClick={() => setActiveTab('emails')}
        >Email Templates</button>
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

      {activeTab === 'community' && (
        <div className="marketing-posts">
          {communityPosts.map((post, i) => (
            <CommunityRedditPost key={i} post={post} />
          ))}
        </div>
      )}

      {activeTab === 'emails' && (
        <div className="marketing-posts">
          <div style={{ fontSize: 13, color: 'var(--text-secondary)', marginBottom: 16, lineHeight: 1.7 }}>
            Outreach templates for influencer and creator partnerships. Replace <code style={{ background: 'var(--surface-alt)', padding: '2px 6px', borderRadius: 4, fontSize: 12 }}>{'{{placeholders}}'}</code> with actual values before sending.
          </div>
          {emailTemplates.map(template => (
            <EmailTemplate key={template.id} template={template} />
          ))}
        </div>
      )}

      {activeTab === 'claims' && (
        <div className="marketing-claims">
          <div className="marketing-claims-header">
            <p style={{ fontSize: 13, color: 'var(--text-secondary)', marginBottom: 16, lineHeight: 1.7 }}>
              Every feature claim in the launch posts maps to a verified source file.
              <strong style={{ color: 'var(--text)' }}> Not advertised:</strong> Cloud sync, shared alarms, Premium tier, family sharing.
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
