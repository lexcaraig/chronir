# Chronir — User Stories & Development Backlog

**Version:** 1.0  
**Last Updated:** February 6, 2026  
**Platforms:** iOS (SwiftUI / Liquid Glass) · Android (Kotlin / Jetpack Compose / Material 3)  
**Architecture:** Atomic Design Methodology with Design Tokens

---

## How to Use This Document

This is the **living development task list** for Chronir. Each epic contains user stories written in standard format with acceptance criteria, priority, tier association, and estimated effort. Stories are ordered by dependency and recommended implementation sequence.

**Priority Key:**  
🔴 P0 — Must ship in MVP  
🟠 P1 — Ship in v1.0  
🟡 P2 — Post-launch / v1.1+

**Tier Key:**  
`[FREE]` `[PLUS]` `[PREMIUM]` — Indicates which monetization tier unlocks the feature

**Effort Scale (Story Points):**  
1 = Hours · 2 = Half-day · 3 = 1 day · 5 = 2–3 days · 8 = 1 week · 13 = 2 weeks

**Status Key:**  
`[ ]` Not Started · `[~]` In Progress · `[x]` Complete · `[!]` Blocked

---

## Epic 0: Project Foundation & Design System

> Establishes the atomic design system, design tokens, and project architecture for both platforms. Nothing ships to users — this is scaffolding.

### US-0.1 — Design Token Foundation

`🔴 P0` · `Effort: 8` · `Status: [ ]`

**As a** developer,  
**I want** a shared design token system (colors, typography, spacing, radii, animation durations) defined in a single source of truth,  
**So that** both iOS and Android apps maintain visual consistency without hard-coded values.

**Acceptance Criteria:**

- [ ] Design tokens defined in JSON (Style Dictionary format)
- [ ] Primitive tokens: raw color values, font sizes, spacing scale (4/8/12/16/24/32/48)
- [ ] Semantic tokens: `color-primary`, `color-alarm-active`, `color-alarm-snoozed`, `color-surface`, `color-on-surface`
- [ ] Component tokens: `button-background`, `alarm-card-radius`, `firing-screen-background`
- [ ] iOS output: Swift extensions (`DesignTokens.Colors.primary`, `DesignTokens.Spacing.md`)
- [ ] Android output: Kotlin objects or Compose theme values
- [ ] Dark mode / light mode token variants defined
- [ ] OLED-optimized true black tokens for alarm firing screen

### US-0.2 — Atomic Component Library (Atoms)

`🔴 P0` · `Effort: 8` · `Status: [ ]`

**As a** developer,  
**I want** a library of styled atom-level components consuming design tokens,  
**So that** all UI is built from consistent, reusable building blocks.

**Acceptance Criteria:**

- [ ] **iOS Atoms:** `CAButton` (primary, secondary, destructive), `CAText` (title, body, caption variants), `CAIcon`, `CAToggle`, `CADivider`
- [ ] **Android Atoms:** `CaButton`, `CaText`, `CaIcon`, `CaToggle`, `CaDivider` (Compose)
- [ ] All atoms consume tokens exclusively — zero hard-coded colors, sizes, or spacing
- [ ] SwiftUI `ViewModifier`s for reusable styling patterns
- [ ] Compose `Modifier` extensions for reusable styling
- [ ] SwiftUI Previews for all atoms (light/dark, accessibility sizes)
- [ ] Compose Previews for all atoms (light/dark, font scale)

### US-0.3 — Atomic Component Library (Molecules & Organisms)

`🔴 P0` · `Effort: 8` · `Status: [ ]`

**As a** developer,  
**I want** molecule and organism-level components,  
**So that** screens can be assembled from pre-built, tested UI blocks.

**Acceptance Criteria:**

- [ ] **Molecules:** `AlarmToggleRow`, `IntervalPicker`, `TimePickerField`, `LabeledTextField`, `SnoozeOptionChip`, `AttachmentThumbnail`
- [ ] **Organisms:** `AlarmCard`, `AlarmListSection`, `AlarmCreationForm`, `FiringScreen`, `PreAlarmBanner`, `UpgradePromptCard`
- [ ] Molecules use atoms only; organisms compose molecules + atoms
- [ ] State management follows platform conventions: `@Binding` in SwiftUI atoms/molecules, `@State` at organism/page level; state hoisting in Compose
- [ ] Previews for all components in multiple states (enabled, disabled, ringing, snoozed)

### US-0.4 — Project Architecture & Folder Structure

`🔴 P0` · `Effort: 5` · `Status: [ ]`

**As a** developer,  
**I want** a well-organized project structure following atomic design hierarchy,  
**So that** the codebase scales cleanly as features are added.

**Acceptance Criteria:**

- [ ] iOS folder structure: `DesignSystem/Tokens`, `DesignSystem/Atoms`, `DesignSystem/Molecules`, `DesignSystem/Organisms`, `Features/AlarmList`, `Features/AlarmCreation`, `Features/AlarmFiring`, `Features/Settings`
- [ ] Android folder structure mirrors iOS hierarchy within `ui/designsystem/` and `ui/features/`
- [ ] Shared data layer: `Models/`, `Repositories/`, `Services/`
- [ ] Design system is a separate module/package importable by feature modules
- [ ] README in each directory documenting its purpose

### US-0.5 — Local Data Layer Setup

`🔴 P0` · `Effort: 5` · `Status: [ ]`

**As a** developer,  
**I want** the local persistence layer configured,  
**So that** alarm data can be stored, queried, and observed reactively.

**Acceptance Criteria:**

- [ ] iOS: SwiftData (or Core Data) model for `Alarm`, `CompletionRecord`
- [ ] Android: Room database with `AlarmEntity`, `CompletionEntity`
- [ ] Alarm model fields: `id`, `title`, `interval` (weekly/monthly/annual), `intervalConfig` (day-of-week, day-of-month, month-of-year), `time`, `isEnabled`, `isPersistent`, `preAlarmEnabled`, `preAlarmOffset`, `snoozeConfig`, `noteText`, `photoPath`, `createdAt`, `nextFireDate`
- [ ] Repository pattern abstracting data source from UI
- [ ] Reactive observation (Combine/SwiftData observation on iOS, Flow on Android)

---

## Epic 1: Core Alarm Engine

> The fundamental alarm scheduling, firing, and dismissal system. This is the product's reason to exist.

### US-1.1 — Create a Basic Alarm

`🔴 P0` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** user,  
**I want to** create an alarm with a title, time, and recurrence interval,  
**So that** I get a persistent reminder for my recurring task.

**Acceptance Criteria:**

- [ ] Tap "+" FAB or add button to open alarm creation flow
- [ ] Set alarm title (required, max 100 characters)
- [ ] Select time (hour/minute picker, platform-native)
- [ ] Select interval: Weekly, Monthly, or Annual
- [ ] Weekly: pick day(s) of week
- [ ] Monthly: pick day of month (1–31) or relative ("last Friday", "first Monday")
- [ ] Annual: pick month + day
- [ ] Alarm saved to local database
- [ ] Next fire date calculated and scheduled with OS alarm API
- [ ] Alarm appears in home list with countdown to next fire
- [ ] Free tier: enforce 2-alarm limit with upgrade prompt on 3rd attempt

### US-1.2 — Persistent Alarm Firing Screen

`🔴 P0` · `[FREE]` · `Effort: 8` · `Status: [ ]`

**As a** user,  
**I want** my alarm to fire with a full-screen, persistent UI that demands acknowledgment,  
**So that** I can't accidentally dismiss it like a regular notification.

**Acceptance Criteria:**

- [ ] Full-screen alarm UI renders over lock screen and other apps
- [ ] Displays: alarm title, current time, interval context ("Monthly — Rent Due")
- [ ] Alarm sound plays continuously until dismissed or snoozed
- [ ] Sound escalation: starts at 60% volume, ramps to 100% over 30 seconds
- [ ] Strong haptic feedback on fire
- [ ] **Dismiss:** swipe gesture with deliberate pattern (not a simple tap) + haptic confirmation
- [ ] **Snooze:** single tap to snooze (default: 10 minutes)
- [ ] iOS: Uses AlarmKit (iOS 26+) for true alarm behavior; Time-Sensitive notifications for iOS 15–25
- [ ] Android: Full-screen intent with `CATEGORY_ALARM`, `setAlarmClock()` API
- [ ] DND bypass: alarm fires regardless of Focus/DND mode (where OS permits)
- [ ] OLED-optimized: true black background with high-contrast text

### US-1.3 — Alarm Auto-Rescheduling on Completion

`🔴 P0` · `[FREE]` · `Effort: 3` · `Status: [ ]`

**As a** user,  
**I want** the next occurrence to be automatically scheduled when I dismiss an alarm,  
**So that** I don't have to manually re-create recurring reminders.

**Acceptance Criteria:**

- [ ] On dismiss ("Mark as Done"), calculate next fire date based on interval config
- [ ] Handle edge cases: month with fewer days (alarm set for 31st fires on last day), leap years
- [ ] Update `nextFireDate` in database
- [ ] Schedule next OS alarm/notification
- [ ] Show brief confirmation toast: "Next alarm: March 1, 9:00 AM"

### US-1.4 — Snooze Logic

`🔴 P0` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** user,  
**I want** contextual snooze options when my alarm fires,  
**So that** I can delay the reminder without losing it.

**Acceptance Criteria:**

- [ ] Default quick-snooze: single tap → 10 minutes
- [ ] Long-press snooze reveals options: 10 min, 1 hour, 1 day, 1 week `[PLUS]`
- [ ] Free tier: only 10 min and 1 hour snooze
- [ ] Snoozed alarm shows "Snoozed until [time]" state in home list
- [ ] Snoozed alarm fires again at snooze-end time with same full-screen persistence
- [ ] Maximum 3 consecutive snoozes before alarm requires explicit dismissal or "Mark as Done"
- [ ] Snooze count visible on firing screen ("Snoozed 2/3 times")

### US-1.5 — Edit an Existing Alarm

`🔴 P0` · `[FREE]` · `Effort: 3` · `Status: [ ]`

**As a** user,  
**I want to** edit any property of an existing alarm,  
**So that** I can adjust schedules without deleting and recreating.

**Acceptance Criteria:**

- [ ] Tap alarm card → opens edit view with all fields pre-populated
- [ ] Editable: title, time, interval, interval config, enabled/disabled, pre-alarm, attachments
- [ ] On save: cancel existing OS alarm, recalculate next fire date, reschedule
- [ ] Unsaved changes prompt: "Discard changes?" on back navigation

### US-1.6 — Delete an Alarm

`🔴 P0` · `[FREE]` · `Effort: 2` · `Status: [ ]`

**As a** user,  
**I want to** delete an alarm I no longer need,  
**So that** my alarm list stays clean and relevant.

**Acceptance Criteria:**

- [ ] Swipe-to-delete on alarm card (iOS and Android)
- [ ] Confirmation dialog: "Delete [alarm title]? This cannot be undone."
- [ ] On confirm: cancel OS alarm, remove from database
- [ ] If deleting brings count below free tier limit, no special handling needed
- [ ] Undo option via snackbar/toast for 5 seconds after deletion

### US-1.7 — Enable/Disable Alarm Toggle

`🔴 P0` · `[FREE]` · `Effort: 2` · `Status: [ ]`

**As a** user,  
**I want to** temporarily disable an alarm without deleting it,  
**So that** I can pause seasonal or situational alarms.

**Acceptance Criteria:**

- [ ] Toggle switch on alarm card and in edit view
- [ ] Disabled alarm: cancel OS scheduled alarm, visually dim card (reduced opacity + strikethrough title)
- [ ] Re-enable: recalculate next fire date from today forward, reschedule
- [ ] Disabled alarms do NOT count against free tier limit

---

## Epic 2: Pre-Alarm Warning System

> Gives users advance notice before an alarm fires, preventing surprise.

### US-2.1 — 24-Hour Pre-Alarm Notification

`🔴 P0` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** user,  
**I want** an optional silent notification 24 hours before my alarm fires,  
**So that** I can prepare for the task in advance and not be caught off guard.

**Acceptance Criteria:**

- [ ] Toggle in alarm creation/edit: "Pre-alarm warning" (default: on)
- [ ] Notification sent 24 hours before fire time
- [ ] Notification content: "Tomorrow: [alarm title] at [time]"
- [ ] Tapping notification opens app to alarm detail
- [ ] Notification is standard priority (not alarm-level), respects DND

### US-2.2 — Extended Pre-Alarm Options

`🟠 P1` · `[PLUS]` · `Effort: 3` · `Status: [ ]`

**As a** Plus user,  
**I want** configurable pre-alarm offsets (7 days, 3 days, 24 hours),  
**So that** I get multiple warnings for important tasks that require preparation.

**Acceptance Criteria:**

- [ ] Multi-select pre-alarm offsets: 7 days, 3 days, 1 day, 1 hour
- [ ] Each offset generates its own notification
- [ ] Notification content includes countdown: "In 3 days: [alarm title]"
- [ ] Free tier sees locked options with upgrade prompt

---

## Epic 3: Alarm Home Screen & List

> The primary interface users interact with daily.

### US-3.1 — Alarm Home List

`🔴 P0` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** user,  
**I want** a clean home screen showing all my alarms sorted by next fire date,  
**So that** I can see at a glance what's coming up.

**Acceptance Criteria:**

- [ ] Alarms displayed as cards using `AlarmCard` organism
- [ ] Each card shows: title, next fire date/time, interval badge (Weekly/Monthly/Annual), enabled toggle
- [ ] Countdown display: "In 3 days" / "Tomorrow" / "Today at 9:00 AM"
- [ ] Cards sorted by `nextFireDate` ascending (soonest first)
- [ ] Disabled alarms sorted to bottom with dimmed styling
- [ ] Empty state: illustration + "Create your first alarm" CTA
- [ ] Pull-to-refresh (future-proofing for sync)
- [ ] Free tier: show alarm count "2/2 alarms used" with upgrade prompt

### US-3.2 — Search & Filter Alarms

`🟡 P2` · `[PLUS]` · `Effort: 3` · `Status: [ ]`

**As a** Plus user with many alarms,  
**I want to** search by title and filter by interval type,  
**So that** I can quickly find specific alarms.

**Acceptance Criteria:**

- [ ] Search bar at top of alarm list (expandable)
- [ ] Real-time filtering as user types
- [ ] Filter chips: All, Weekly, Monthly, Annual
- [ ] Results highlight matching text in alarm title

---

## Epic 4: Task Attachments

> Context attached to alarms — notes and photos.

### US-4.1 — Note Attachment

`🟠 P1` · `[PLUS]` · `Effort: 3` · `Status: [ ]`

**As a** Plus user,  
**I want to** add a text note to an alarm,  
**So that** I see context when the alarm fires (e.g., "Filter size: 20x25x1").

**Acceptance Criteria:**

- [ ] Optional "Note" text field in alarm creation/edit (max 500 characters)
- [ ] Note displayed on alarm card (truncated to 2 lines)
- [ ] Note displayed prominently on firing screen
- [ ] Free tier: field visible but locked with upgrade prompt

### US-4.2 — Photo Attachment

`🟠 P1` · `[PLUS]` · `Effort: 5` · `Status: [ ]`

**As a** Plus user,  
**I want to** attach a photo to an alarm,  
**So that** I see a visual reference when the alarm fires (e.g., photo of the correct filter).

**Acceptance Criteria:**

- [ ] "Add Photo" button in alarm creation/edit
- [ ] Source: camera or photo library (platform permissions handled)
- [ ] Photo stored locally (compressed, max 1MB)
- [ ] Thumbnail visible on alarm card
- [ ] Full photo viewable on firing screen (tap to zoom)
- [ ] Option to remove/replace photo
- [ ] Free tier: button visible but locked with upgrade prompt

---

## Epic 5: Completion Tracking

> History of completed tasks for accountability.

### US-5.1 — Basic Completion Marking

`🔴 P0` · `[FREE]` · `Effort: 2` · `Status: [ ]`

**As a** user,  
**I want to** mark an alarm as "Done" when I complete the task,  
**So that** the alarm is dismissed and the next occurrence is scheduled.

**Acceptance Criteria:**

- [ ] "Mark as Done" button on firing screen (primary action)
- [ ] Records completion timestamp in local database
- [ ] Triggers auto-rescheduling (US-1.3)
- [ ] Brief success animation/haptic on completion

### US-5.2 — Completion History Log

`🟠 P1` · `[PLUS]` · `Effort: 5` · `Status: [ ]`

**As a** Plus user,  
**I want to** see a history of when I completed each recurring alarm,  
**So that** I can track my consistency and verify past completions.

**Acceptance Criteria:**

- [ ] "History" tab/section accessible from alarm detail view
- [ ] Chronological list: date, time, status (Completed / Missed / Snoozed then Completed)
- [ ] Visual streak indicator: consecutive on-time completions
- [ ] Export history as CSV (v1.1)
- [ ] Free tier: sees last completion only ("Last completed: Jan 15"), full history locked

---

## Epic 6: Onboarding & First-Run Experience

> Convert first-time users to engaged users within 60 seconds.

### US-6.1 — First-Launch Onboarding

`🔴 P0` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** new user,  
**I want** a brief onboarding that explains Chronir's purpose,  
**So that** I understand why this is different from my calendar.

**Acceptance Criteria:**

- [ ] 3-screen onboarding carousel (skip-able):
    - Screen 1: "Alarms for life's recurring tasks" — value proposition
    - Screen 2: "Persistent. Can't-ignore. On schedule." — key differentiator
    - Screen 3: "Create your first alarm" — CTA
- [ ] Notification permission request after Screen 2 with contextual explanation
- [ ] iOS: Alarm permission request (AlarmKit authorization)
- [ ] On CTA tap, open alarm creation flow directly
- [ ] Onboarding only shown once, flag stored locally

### US-6.2 — Permission Handling & Troubleshooting

`🔴 P0` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** user on a device that restricts background alarms,  
**I want** clear guidance on enabling required permissions,  
**So that** my alarms fire reliably.

**Acceptance Criteria:**

- [ ] Post-onboarding permission check: notifications, alarms (iOS), exact alarms (Android)
- [ ] If denied: inline banner on home screen explaining impact + "Fix" button linking to system settings
- [ ] Android OEM detection: detect Samsung, Xiaomi, Huawei, OPPO and show manufacturer-specific battery optimization whitelisting instructions
- [ ] Troubleshooting screen in settings with step-by-step guides per manufacturer
- [ ] "Test Alarm" button in settings: fires a test alarm in 10 seconds to verify setup works

---

## Epic 7: Settings & Preferences

### US-7.1 — General Settings

`🔴 P0` · `[FREE]` · `Effort: 3` · `Status: [ ]`

**As a** user,  
**I want** a settings screen to configure app-wide preferences,  
**So that** I can customize Chronir to my needs.

**Acceptance Criteria:**

- [ ] Default alarm sound selection (from bundled sounds)
- [ ] Default snooze duration
- [ ] Default pre-alarm toggle
- [ ] Time format: 12h / 24h (default: follow system)
- [ ] Theme: System / Light / Dark
- [ ] "About" section: version, licenses, support link, privacy policy

### US-7.2 — Custom Alarm Sounds

`🟠 P1` · `[PLUS]` · `Effort: 3` · `Status: [ ]`

**As a** Plus user,  
**I want to** choose from multiple alarm sounds or set different sounds per alarm,  
**So that** I can distinguish between alarms by sound alone.

**Acceptance Criteria:**

- [ ] 5–8 bundled alarm sounds with previews
- [ ] Per-alarm sound override in alarm edit view
- [ ] Sound preview plays on selection
- [ ] Free tier: 2 default sounds only, rest locked

### US-7.3 — Timezone Awareness

`🟠 P1` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** user who travels,  
**I want** my alarms to handle timezone changes correctly,  
**So that** I'm not woken up at the wrong time.

**Acceptance Criteria:**

- [ ] Per-alarm setting: "Fixed timezone" (always fires at home time) vs "Floating" (fires at local time)
- [ ] Default: floating (matches standard alarm behavior)
- [ ] On timezone change detection: recalculate fire times for fixed-timezone alarms
- [ ] Settings: set home timezone explicitly

---

## Epic 8: Monetization & Paywalls

### US-8.1 — Free Tier Enforcement

`🔴 P0` · `[FREE]` · `Effort: 3` · `Status: [ ]`

**As the** product,  
**I want** the free tier limited to 2 active alarms,  
**So that** users experience value before hitting the upgrade gate.

**Acceptance Criteria:**

- [ ] Count active (enabled) alarms; disabled alarms don't count
- [ ] At alarm count 2: "+" button shows upgrade prompt instead of creation flow
- [ ] Upgrade prompt: clear comparison of Free vs Plus vs Premium
- [ ] If user downgrades: alarms beyond limit are disabled (not deleted), with in-app explanation

### US-8.2 — In-App Purchase Integration

`🔴 P0` · `Effort: 8` · `Status: [ ]`

**As a** user,  
**I want** seamless upgrade to Plus or Premium via in-app purchase,  
**So that** I can unlock more features without leaving the app.

**Acceptance Criteria:**

- [ ] iOS: StoreKit 2 integration for subscriptions
- [ ] Android: Google Play Billing Library integration
- [ ] Products: Plus Monthly ($1.99), Plus Annual ($14.99), Premium Monthly ($3.99), Premium Annual ($29.99)
- [ ] Subscription status persisted locally + verified via receipt validation
- [ ] Restore purchases functionality
- [ ] Grace period handling for expired subscriptions
- [ ] Upgrade prompt surfaces at natural friction points (3rd alarm, attachment attempt, share attempt)

### US-8.3 — Upgrade Comparison Screen

`🔴 P0` · `Effort: 3` · `Status: [ ]`

**As a** user considering an upgrade,  
**I want** a clear comparison of what each tier offers,  
**So that** I can make an informed purchase decision.

**Acceptance Criteria:**

- [ ] Full-screen comparison view: Free / Plus / Premium columns
- [ ] Feature checkmarks per tier
- [ ] Monthly vs annual pricing toggle with savings callout ("Save 37%")
- [ ] Prominent CTA for recommended tier (Plus for solo, Premium for sharers)
- [ ] Accessible from: settings, locked feature prompts, alarm limit prompt

---

## Epic 9: Cloud Backup & Sync

### US-9.1 — Account Creation & Authentication

`🟠 P1` · `[PLUS]` · `Effort: 8` · `Status: [ ]`

**As a** Plus user,  
**I want to** create an account,  
**So that** my alarms are backed up to the cloud and survive device changes.

**Acceptance Criteria:**

- [ ] Firebase Auth integration (both platforms)
- [ ] Sign in methods: Apple Sign In (iOS required), Google Sign In, Email/Password
- [ ] Account creation optional — only prompted when user accesses Plus/Premium features
- [ ] Profile screen: email, subscription status, sign out, delete account
- [ ] Account deletion removes all cloud data (GDPR/privacy compliance)

### US-9.2 — Cloud Backup

`🟠 P1` · `[PLUS]` · `Effort: 8` · `Status: [ ]`

**As a** Plus user,  
**I want** my alarms automatically backed up to the cloud,  
**So that** I don't lose 10 years of annual reminders when I upgrade my phone.

**Acceptance Criteria:**

- [ ] On account creation: initial full sync of local alarms to Firestore
- [ ] On alarm create/edit/delete: sync change to cloud within 5 seconds
- [ ] On new device login: download all alarms and reschedule with OS
- [ ] Conflict resolution: last-write-wins with timestamp comparison
- [ ] Photo attachments synced to Firebase Storage (compressed, max 1MB each)
- [ ] Offline support: queue changes, sync when connection restored
- [ ] Sync status indicator in settings: "Last synced: 2 minutes ago"

---

## Epic 10: Shared Alarms & Collaboration (Premium)

> The premium tier's core value — shared accountability.

### US-10.1 — Share an Alarm via Invite Link

`🟠 P1` · `[PREMIUM]` · `Effort: 8` · `Status: [ ]`

**As a** Premium user,  
**I want to** share an alarm with another person via invite link,  
**So that** we both receive the alarm and can hold each other accountable.

**Acceptance Criteria:**

- [ ] "Share" button on alarm detail view (Premium only)
- [ ] Generate shareable link (Firebase Dynamic Links or custom deep link)
- [ ] Share via system share sheet (Messages, WhatsApp, Email, etc.)
- [ ] Recipient taps link → app opens (or App Store/Play Store if not installed)
- [ ] Recipient sees shared alarm in "Shared with me" section
- [ ] Recipient can accept or decline the shared alarm
- [ ] Accepted alarm fires on recipient's device with same persistence
- [ ] Sharer and receiver both see the alarm in their lists with "Shared" badge
- [ ] Free-tier receiver: can receive and dismiss shared alarms (receiver-only mode)

### US-10.2 — Alarm Groups

`🟡 P2` · `[PREMIUM]` · `Effort: 8` · `Status: [ ]`

**As a** Premium user,  
**I want to** organize shared alarms into groups (e.g., "Household", "Work Team"),  
**So that** I can manage multiple shared responsibilities clearly.

**Acceptance Criteria:**

- [ ] Create group with name and optional icon/color
- [ ] Invite members to group via link or contact search
- [ ] All alarms within group are shared with all members
- [ ] Group management: add/remove members, rename, delete group
- [ ] Group-level settings: who can create/edit alarms (admin vs member)
- [ ] Home screen: alarms grouped under collapsible group headers

### US-10.3 — Shared Completion Visibility

`🟡 P2` · `[PREMIUM]` · `Effort: 5` · `Status: [ ]`

**As a** Premium group member,  
**I want to** see when other members mark a shared alarm as done,  
**So that** I know tasks are being handled without having to ask.

**Acceptance Criteria:**

- [ ] Completion events synced via Firestore real-time listeners
- [ ] Alarm card shows: "Completed by [name] at [time]" for shared alarms
- [ ] If alarm not marked done within configurable window (e.g., 2 hours after fire), show "Pending" status to all members
- [ ] Completion history shows attribution: who completed, when
- [ ] Push notification option: "Sarah completed 'Rent Payment'"

### US-10.4 — Assign Alarms to Group Members

`🟡 P2` · `[PREMIUM]` · `Effort: 5` · `Status: [ ]`

**As a** Premium group admin,  
**I want to** assign specific alarms to specific group members,  
**So that** responsibilities are clear and the right person gets the reminder.

**Acceptance Criteria:**

- [ ] "Assign to" field in alarm creation/edit within a group
- [ ] Assignee receives the persistent alarm; others see a standard notification
- [ ] Assignee shown on alarm card: "Assigned to: [name]"
- [ ] Reassignment possible without deleting alarm
- [ ] Unassigned alarms fire for all group members (default behavior)

---

## Epic 11: Widgets & Glanceable Information

### US-11.1 — iOS Home Screen Widget

`🟠 P1` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As an** iOS user,  
**I want** a home screen widget showing my next upcoming alarm(s),  
**So that** I can see what's coming without opening the app.

**Acceptance Criteria:**

- [ ] WidgetKit implementation: small (1 alarm), medium (3 alarms), large (5 alarms)
- [ ] Widget shows: alarm title, countdown ("In 2 days"), interval badge
- [ ] Tap widget → opens app to relevant alarm
- [ ] Widget updates every 15 minutes (WidgetKit timeline)
- [ ] Follows system appearance (light/dark)
- [ ] Liquid Glass styling where applicable

### US-11.2 — Android Home Screen Widget

`🟠 P1` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As an** Android user,  
**I want** a home screen widget showing upcoming alarms,  
**So that** I can glance at my schedule without opening the app.

**Acceptance Criteria:**

- [ ] Glance widget (Jetpack Glance): small and medium sizes
- [ ] Shows: alarm title, countdown, interval badge
- [ ] Material 3 / Material You dynamic color theming
- [ ] Tap → opens app to alarm detail
- [ ] Battery-efficient updates

### US-11.3 — iOS Live Activities & Dynamic Island

`🟡 P2` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As an** iOS user,  
**I want** a Live Activity showing countdown to my next alarm,  
**So that** I see it on my lock screen and Dynamic Island without opening the app.

**Acceptance Criteria:**

- [ ] Live Activity starts when next alarm is within 24 hours
- [ ] Lock screen: alarm title + countdown timer
- [ ] Dynamic Island (compact): countdown timer
- [ ] Dynamic Island (expanded): title + countdown + interval
- [ ] Live Activity ends when alarm fires or is dismissed
- [ ] Respects user preference to disable Live Activities

---

## Epic 12: Accessibility & Inclusivity

### US-12.1 — Full Accessibility Support

`🔴 P0` · `[FREE]` · `Effort: 5` · `Status: [ ]`

**As a** user with accessibility needs,  
**I want** the app to be fully usable with assistive technologies,  
**So that** I'm not excluded from reliable alarm management.

**Acceptance Criteria:**

- [ ] All interactive elements: 44pt minimum touch targets
- [ ] VoiceOver (iOS) and TalkBack (Android) full support
- [ ] Meaningful accessibility labels on all components (not "Button 1")
- [ ] Firing screen: accessible dismiss/snooze actions via assistive tech
- [ ] Dynamic Type (iOS) and font scale (Android) support without layout breakage
- [ ] Color contrast: WCAG AA minimum (4.5:1 for text)
- [ ] Reduced Motion: respect system setting, disable animations
- [ ] Screen reader announcement when alarm fires: "[title] alarm is ringing"

### US-12.2 — Voice Control for Alarm Firing

`🟡 P2` · `[FREE]` · `Effort: 8` · `Status: [ ]`

**As a** user,  
**I want to** say "Stop" or "Snooze" to control a firing alarm,  
**So that** I can dismiss it hands-free.

**Acceptance Criteria:**

- [ ] Voice recognition activates when alarm fires
- [ ] Recognized commands: "Stop", "Snooze", "Mark as Done"
- [ ] Voice processing: on-device only (no network required)
- [ ] Visual feedback: voice waveform indicator on firing screen
- [ ] Configurable: can be disabled in settings
- [ ] Works alongside physical dismiss/snooze gestures

---

## Epic 13: Analytics & Monitoring

### US-13.1 — Core Analytics Events

`🟠 P1` · `Effort: 3` · `Status: [ ]`

**As the** product team,  
**I want** key user events tracked,  
**So that** we can measure retention, conversion, and feature usage.

**Acceptance Criteria:**

- [ ] Events: `alarm_created`, `alarm_fired`, `alarm_dismissed`, `alarm_snoozed`, `alarm_completed`, `alarm_deleted`, `upgrade_prompt_shown`, `upgrade_completed`, `share_initiated`, `onboarding_completed`
- [ ] Properties: alarm interval type, tier, snooze count, time-to-dismiss
- [ ] Firebase Analytics or privacy-respecting alternative (TelemetryDeck, Plausible)
- [ ] No PII in analytics payloads
- [ ] Analytics consent prompt (where legally required)

---

## Epic 14: App Store & Launch Readiness

### US-14.1 — App Store Assets & Metadata

`🟠 P1` · `Effort: 5` · `Status: [ ]`

**As the** product,  
**I want** polished App Store and Play Store listings,  
**So that** the app converts store visitors into downloads.

**Acceptance Criteria:**

- [ ] App icon: clean, recognizable at small sizes, distinct from Clock apps
- [ ] Screenshots: 5–8 per platform showing key flows (creation, firing, home list, sharing)
- [ ] App preview video (30 seconds): alarm creation → firing → dismiss cycle
- [ ] Description: keyword-optimized, benefit-led copy
- [ ] Categories: Productivity (primary), Utilities (secondary)
- [ ] Privacy nutrition labels / Data safety section completed accurately

### US-14.2 — Beta Testing Program

`🟠 P1` · `Effort: 3` · `Status: [ ]`

**As the** developer,  
**I want** a structured beta testing phase,  
**So that** critical bugs are caught before public launch.

**Acceptance Criteria:**

- [ ] iOS: TestFlight with 20–50 external testers
- [ ] Android: Play Console closed testing track
- [ ] Feedback mechanism: in-app feedback form or linked Google Form
- [ ] 2-week minimum beta period
- [ ] Critical test scenarios: alarm fires after reboot, alarm fires after app force-close, alarm fires in DND, timezone change, OEM battery optimization

---

## Sprint Planning Recommendation

### Phase 1 — Foundation (Weeks 1–3)

| Stories                      | Points |
| ---------------------------- | ------ |
| US-0.1 Design Tokens         | 8      |
| US-0.2 Atoms                 | 8      |
| US-0.3 Molecules & Organisms | 8      |
| US-0.4 Project Architecture  | 5      |
| US-0.5 Local Data Layer      | 5      |
| **Total**                    | **34** |

### Phase 2 — Core Alarm MVP (Weeks 4–7)

| Stories                      | Points |
| ---------------------------- | ------ |
| US-1.1 Create Alarm          | 5      |
| US-1.2 Firing Screen         | 8      |
| US-1.3 Auto-Rescheduling     | 3      |
| US-1.4 Snooze Logic          | 5      |
| US-1.5 Edit Alarm            | 3      |
| US-1.6 Delete Alarm          | 2      |
| US-1.7 Enable/Disable Toggle | 2      |
| US-2.1 Pre-Alarm Warning     | 5      |
| US-3.1 Alarm Home List       | 5      |
| US-5.1 Completion Marking    | 2      |
| **Total**                    | **40** |

### Phase 3 — Launch Readiness (Weeks 8–10)

| Stories                              | Points |
| ------------------------------------ | ------ |
| US-6.1 Onboarding                    | 5      |
| US-6.2 Permissions & Troubleshooting | 5      |
| US-7.1 General Settings              | 3      |
| US-8.1 Free Tier Enforcement         | 3      |
| US-8.2 IAP Integration               | 8      |
| US-8.3 Upgrade Comparison            | 3      |
| US-12.1 Accessibility                | 5      |
| **Total**                            | **32** |

### Phase 4 — Plus Tier Features (Weeks 11–13)

| Stories                    | Points |
| -------------------------- | ------ |
| US-2.2 Extended Pre-Alarms | 3      |
| US-4.1 Note Attachments    | 3      |
| US-4.2 Photo Attachments   | 5      |
| US-5.2 Completion History  | 5      |
| US-7.2 Custom Sounds       | 3      |
| US-7.3 Timezone Awareness  | 5      |
| US-9.1 Auth                | 8      |
| US-9.2 Cloud Backup        | 8      |
| **Total**                  | **40** |

### Phase 5 — Premium & Polish (Weeks 14–18)

| Stories                       | Points |
| ----------------------------- | ------ |
| US-10.1 Shared Alarms         | 8      |
| US-10.2 Alarm Groups          | 8      |
| US-10.3 Completion Visibility | 5      |
| US-10.4 Assign to Members     | 5      |
| US-11.1 iOS Widget            | 5      |
| US-11.2 Android Widget        | 5      |
| US-13.1 Analytics             | 3      |
| US-14.1 Store Assets          | 5      |
| US-14.2 Beta Testing          | 3      |
| **Total**                     | **47** |

### Phase 6 — Post-Launch (v1.1+)

| Stories                 | Points |
| ----------------------- | ------ |
| US-3.2 Search & Filter  | 3      |
| US-11.3 Live Activities | 5      |
| US-12.2 Voice Control   | 8      |
| **Total**               | **16** |

---

## Dependency Graph

```
US-0.1 (Tokens) ──→ US-0.2 (Atoms) ──→ US-0.3 (Molecules/Organisms)
                                              │
US-0.4 (Architecture) ─┐                     │
US-0.5 (Data Layer) ───┤                     ▼
                        ├──→ US-1.1 (Create Alarm) ──→ US-1.2 (Firing Screen)
                        │         │                         │
                        │         ├──→ US-1.5 (Edit)        ├──→ US-1.3 (Reschedule)
                        │         ├──→ US-1.6 (Delete)      ├──→ US-1.4 (Snooze)
                        │         ├──→ US-1.7 (Toggle)      └──→ US-5.1 (Completion)
                        │         │
                        │         └──→ US-3.1 (Home List)
                        │
                        └──→ US-2.1 (Pre-Alarm)

US-8.2 (IAP) ──→ US-8.1 (Free Tier Limit) ──→ US-8.3 (Upgrade Screen)

US-9.1 (Auth) ──→ US-9.2 (Cloud Backup) ──→ US-10.1 (Shared Alarms)
                                                    │
                                                    ├──→ US-10.2 (Groups)
                                                    ├──→ US-10.3 (Shared Completion)
                                                    └──→ US-10.4 (Assign Members)
```

---

## Changelog

| Date       | Version | Changes                                                    |
| ---------- | ------- | ---------------------------------------------------------- |
| 2026-02-06 | 1.0     | Initial backlog creation — 40 user stories across 14 epics |
