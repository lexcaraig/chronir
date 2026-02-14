# Chronir — QA Test Plan

|                |                                                                    |
| -------------- | ------------------------------------------------------------------ |
| **Version**    | 1.0                                                                |
| **Date**       | February 2026                                                      |
| **Status**     | Active                                                             |
| **Document #** | 10 of 11                                                           |
| **Platforms**  | iOS (SwiftUI, iOS 26+) · Android (Kotlin/Jetpack Compose, API 31+) |
| **Backend**    | Firebase Auth · Cloud Firestore · Cloud Storage · Crashlytics      |

---

## 1. Purpose & Scope

This document defines the complete QA strategy for Chronir, a premium native recurring alarm application built separately for iOS (SwiftUI with Liquid Glass) and Android (Kotlin/Jetpack Compose with Material 3). It establishes what "done" means for every feature, the device and OS matrix to cover, test scenarios mapped to user personas, and acceptance criteria for App Store and Play Store submission.

### 1.1 What This Plan Covers

- Functional testing across all three tiers (Free, Plus, Premium)
- Alarm reliability and persistence testing (the core product promise)
- Cross-platform parity validation
- OEM battery optimization / alarm kill scenarios (Android)
- Cloud sync and shared alarm testing (Premium)
- In-app purchase and subscription flow testing
- Accessibility compliance (WCAG 2.1 AA)
- Performance, memory, and battery consumption benchmarks
- Regression testing strategy
- App Store / Play Store submission readiness checklist

### 1.2 Out of Scope (V2+)

- Relative date scheduling ("last Friday of month")
- Google Assistant integration (Android)
- Smart home speaker integration
- Task completion analytics dashboard

### 1.3 Added Post-V1.0 (sprint-siri-onetime)

- **One-Time Obligation Alarms** — non-recurring alarms that auto-archive after completion
- **Siri Integration (iOS)** — App Intents for create, next, and list alarms via voice

---

## 2. Definition of Done

A feature is considered **done** when ALL of the following criteria are met. No feature ships without satisfying every applicable item.

### 2.1 Global Definition of Done (applies to every feature)

| #   | Criterion                                                                                       | Evidence Required                                          |
| --- | ----------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| D1  | Feature works correctly on all devices in the test matrix (Section 5)                           | Test execution report with pass status                     |
| D2  | Feature works in both light mode and dark mode                                                  | Screenshot evidence on both modes                          |
| D3  | Feature supports Dynamic Type (iOS) and font scaling (Android) up to largest accessibility size | Screenshot at default and largest size                     |
| D4  | No crash or ANR (Application Not Responding) during any test scenario                           | Crashlytics zero-crash confirmation over 48-hour soak test |
| D5  | All UI components follow atomic design system — tokens only, no hardcoded values                | Code review checklist signed off                           |
| D6  | Feature is localized-ready (all user-facing strings externalized)                               | String resource audit                                      |
| D7  | Memory usage does not exceed baseline by more than 15% with feature active                      | Instruments (iOS) / Android Profiler report                |
| D8  | Feature degrades gracefully when network is unavailable (if network-dependent)                  | Airplane mode test pass                                    |
| D9  | All edge cases documented and tested (empty states, max values, boundary conditions)            | Edge case matrix signed off                                |
| D10 | Code reviewed by at least one reviewer; no critical or high-severity linting issues             | PR approval record                                         |

### 2.2 Tier-Specific Definition of Done

#### Free Tier — "Done" means:

- [ ] User can create exactly 2 alarms, third creation blocked with upgrade prompt
- [ ] All interval types (weekly, monthly, annual) work within the 2-alarm limit
- [ ] Alarms fire persistently with full-screen UI on both platforms
- [ ] Alarms bypass Do Not Disturb using AlarmKit (iOS) / CATEGORY_ALARM (Android)
- [ ] Pre-alarm 24-hour warning notification fires correctly
- [ ] Invited user can receive and dismiss shared alarms without paying
- [ ] No account creation required; local storage only
- [ ] Mark-as-done auto-schedules next occurrence correctly

#### Plus Tier — "Done" means:

- [ ] All Free tier criteria pass
- [ ] User can create unlimited alarms (tested with 50+ active alarms)
- [ ] Photo and note attachments save, display, and persist across app restarts
- [ ] Cloud backup saves and restores alarm state correctly
- [ ] Completion history shows accurate timestamps and alarm names
- [ ] Custom snooze durations (1 hour, 1 day, 1 week) reschedule correctly
- [ ] Extended pre-alarms (7 day, 3 day, 24 hour) all fire at correct times

#### Premium Tier — "Done" means:

- [ ] All Plus tier criteria pass
- [ ] Shared alarm invitation link generation and acceptance works cross-platform
- [ ] Shared alarm fires on all recipients' devices simultaneously
- [ ] Groups can be created, members added/removed, and alarms assigned
- [ ] Completion visibility: when one user marks done, all group members see update within 5 seconds
- [ ] Cross-device sync restores all alarms, groups, and history on new device within 30 seconds
- [ ] Alarm assignment to specific group members works correctly

### 2.3 Release-Level Definition of Done

A release candidate is approved for App Store / Play Store submission when:

| #   | Release Gate                                                        | Threshold                                      |
| --- | ------------------------------------------------------------------- | ---------------------------------------------- |
| R1  | All P0 (critical) and P1 (high) bugs resolved                       | Zero open                                      |
| R2  | All P2 (medium) bugs triaged and deferred with justification        | Documented                                     |
| R3  | Crash-free rate over 72-hour soak test                              | ≥ 99.5%                                        |
| R4  | Alarm reliability rate (alarms that fire on time)                   | ≥ 99.9% on reference devices                   |
| R5  | Cold start time                                                     | < 2 seconds on all test devices                |
| R6  | Battery consumption during idle (alarm scheduled, app backgrounded) | < 1% per hour                                  |
| R7  | All accessibility audits pass                                       | Xcode Accessibility Inspector + TalkBack audit |
| R8  | All in-app purchase flows validated in sandbox environments         | Apple Sandbox + Google Play test tracks        |
| R9  | Privacy policy and terms of service reviewed and linked in-app      | Legal review sign-off                          |
| R10 | App Store screenshots and metadata finalized                        | Marketing review sign-off                      |

---

## 3. Test Categories & Priority

| Priority | Label    | Description                                                                | SLA                        |
| -------- | -------- | -------------------------------------------------------------------------- | -------------------------- |
| P0       | Critical | Alarm doesn't fire, data loss, crash on launch, payment fails              | Fix before any release     |
| P1       | High     | Alarm fires late (>1 min), sync fails silently, wrong interval calculation | Fix before current release |
| P2       | Medium   | UI glitch, minor animation stutter, non-blocking UX issue                  | Fix within next release    |
| P3       | Low      | Cosmetic, copy improvement, nice-to-have polish                            | Backlog                    |

---

## 4. Persona-Based Test Scenarios

Every test scenario traces back to a defined user persona to ensure real-world coverage.

### 4.1 Sarah Chen — Free Tier Minimalist

> "I just need two reliable reminders that actually work."

| ID    | Scenario                       | Steps                                                          | Expected Result                                                  | Priority |
| ----- | ------------------------------ | -------------------------------------------------------------- | ---------------------------------------------------------------- | -------- |
| SC-01 | Create first alarm             | Open app → Tap + → Set "Pay Rent" monthly on 1st at 9am → Save | Alarm appears in list, next fire date shown correctly            | P0       |
| SC-01a| Multi-day monthly alarm        | Create monthly alarm → Select 1st and 15th in day grid → Save  | Alarm fires on next matching day (1st or 15th), both days shown | P0       |
| SC-01b| Category tagging (free)        | Create alarm → Select "Home" category → Save                   | Category badge shows on alarm card, category persisted on edit  | P1       |
| SC-02 | Create second alarm            | Create "Renew Gym" annually on March 15 → Save                 | Two alarms in list, both showing correct next dates              | P0       |
| SC-03 | Hit free limit                 | Attempt to create third alarm                                  | Upgrade prompt displayed; third alarm NOT created                | P1       |
| SC-04 | Alarm fires while phone locked | Wait for alarm time with screen off                            | Full-screen alarm UI appears with sound, even during DND         | P0       |
| SC-05 | Dismiss alarm                  | Long-press dismiss (annual) or tap dismiss (weekly/monthly)    | Alarm dismissed, next occurrence auto-scheduled                  | P0       |
| SC-06 | Pre-alarm warning              | 24 hours before monthly alarm                                  | Silent notification received with alarm name and tomorrow's time | P1       |
| SC-07 | Delete and recreate            | Delete one alarm → Create a new one                            | New alarm works, count stays at 2                                | P1       |
| SC-08 | Receive shared alarm (invited) | Premium user shares alarm → Sarah opens invite link            | App opens/installs, shared alarm visible in receiver-only mode   | P1       |

### 4.2 David Morales — Free → Plus Upgrader

> "I need photos attached so I remember which filter to buy."

| ID    | Scenario                   | Steps                                                | Expected Result                                          | Priority |
| ----- | -------------------------- | ---------------------------------------------------- | -------------------------------------------------------- | -------- |
| DM-01 | Upgrade to Plus            | Hit alarm limit → Tap upgrade → Complete IAP         | Unlimited alarms unlocked, upgrade reflected immediately | P0       |
| DM-02 | Attach photo to alarm      | Create alarm → Attach camera photo of HVAC filter    | Photo saved, visible on alarm detail and firing screen   | P1       |
| DM-03 | Attach note to alarm       | Add note "20x25x1 from Home Depot"                   | Note displayed on alarm card and firing screen           | P1       |
| DM-04 | Stress: 12 active alarms   | Create 12 alarms with various intervals              | All 12 schedule correctly, no performance degradation    | P1       |
| DM-05 | Cloud backup after upgrade | Enable cloud backup → Kill app → Reinstall → Restore | All 12 alarms restored with photos and notes intact      | P0       |
| DM-06 | Completion history         | Dismiss 3 alarms over multiple days → Open history   | All 3 completions shown with correct timestamps          | P2       |
| DM-07 | Grouped list view (Plus)   | Assign categories to alarms → Tap group toggle       | Alarms grouped by category with section headers          | P1       |
| DM-08 | Category filter (Plus)     | Tap "Home" filter chip in alarm list                 | Only alarms with Home category shown; others hidden      | P1       |
| DM-07 | Custom snooze (1 day)      | Alarm fires → Snooze 1 day                           | Alarm fires again exactly 24 hours later                 | P1       |
| DM-08 | Custom snooze (1 week)     | Alarm fires → Snooze 1 week                          | Alarm fires again exactly 7 days later                   | P1       |

### 4.3 Priya Kapoor — Day-One Plus Subscriber

> "I need notes on everything and cloud sync from day one."

| ID    | Scenario                     | Steps                                     | Expected Result                                              | Priority |
| ----- | ---------------------------- | ----------------------------------------- | ------------------------------------------------------------ | -------- |
| PK-01 | First-launch purchase        | Download → Immediately purchase Plus      | All Plus features available, no free-tier friction           | P0       |
| PK-02 | Extended pre-alarm (7 day)   | Set annual alarm → Wait for 7-day warning | Notification fires exactly 7 days before                     | P1       |
| PK-03 | Extended pre-alarm (3 day)   | Same alarm → Wait for 3-day warning       | Notification fires exactly 3 days before                     | P1       |
| PK-04 | Extended pre-alarm (24 hour) | Same alarm → Wait for 24-hour warning     | Notification fires exactly 24 hours before                   | P1       |
| PK-05 | All pre-alarms for one alarm | Enable all three warnings for one alarm   | 7-day, 3-day, and 24-hour notifications all fire in sequence | P1       |
| PK-06 | Cloud sync on new device     | Log into new device with same account     | All alarms, notes, and history sync within 30 seconds        | P0       |

### 4.4 Maria & Jorge Rivera — Premium Cross-Platform Household

> "We need to both see when the other person handled it."

| ID    | Scenario                     | Steps                                                    | Expected Result                                            | Priority |
| ----- | ---------------------------- | -------------------------------------------------------- | ---------------------------------------------------------- | -------- |
| MR-01 | Create group                 | Maria (iOS) creates "Rivera Household" group             | Group visible in Maria's Premium account                   | P1       |
| MR-02 | Invite member cross-platform | Maria invites Jorge (Android) via link                   | Jorge joins group, sees shared alarm list                  | P0       |
| MR-03 | Shared alarm fires on both   | Create shared alarm → Wait for trigger                   | Both devices fire alarm simultaneously (±30 sec tolerance) | P0       |
| MR-04 | Completion visibility        | Maria marks "Change Water Filter" done                   | Jorge sees green completion badge within 5 seconds         | P0       |
| MR-05 | Assign alarm to member       | Maria assigns "Mow Lawn" to Jorge                        | Only Jorge gets the alarm; Maria sees assignment status    | P1       |
| MR-06 | Shared alarm with photo      | Maria attaches photo → Jorge views alarm                 | Photo synced and visible on Jorge's Android device         | P1       |
| MR-07 | Offline then sync            | Jorge goes offline → Maria marks done → Jorge reconnects | Jorge receives completion update upon reconnection         | P1       |
| MR-08 | Remove member from group     | Maria removes Jorge                                      | Jorge loses access to all shared alarms in that group      | P1       |

### 4.5 Tom Nguyen — Plus Accessibility-Focused User

> "I need big text and photos for my aging eyes."

| ID    | Scenario                          | Steps                                             | Expected Result                                                   | Priority |
| ----- | --------------------------------- | ------------------------------------------------- | ----------------------------------------------------------------- | -------- |
| TN-01 | Largest Dynamic Type              | Set iOS to largest accessibility text size        | All text readable, no truncation, layouts don't break             | P1       |
| TN-02 | Largest font scale (Android)      | Set Android to largest font scale                 | All text readable, no overlap, scroll behavior correct            | P1       |
| TN-03 | VoiceOver full flow               | Navigate entire app with VoiceOver on             | All elements announced, actionable items accessible, no dead ends | P1       |
| TN-04 | TalkBack full flow                | Navigate entire app with TalkBack on              | All elements announced, actionable items accessible, no dead ends | P1       |
| TN-05 | Color contrast                    | Test all text/background combinations             | All meet WCAG 2.1 AA (4.5:1 for normal text, 3:1 for large text)  | P1       |
| TN-06 | Touch target size                 | Measure all interactive elements                  | Minimum 44pt (iOS) / 48dp (Android) on all buttons and controls   | P1       |
| TN-07 | Photo attachment on firing screen | Alarm fires with attached photo of pet medication | Photo clearly visible at arm's length, not cropped or tiny        | P2       |

### 4.6 Rachel Kim — Premium Power User / Team Manager

> "60+ alarms for my cleaning service team."

| ID    | Scenario                 | Steps                                           | Expected Result                                            | Priority |
| ----- | ------------------------ | ----------------------------------------------- | ---------------------------------------------------------- | -------- |
| RK-01 | Stress: 60 active alarms | Create 60 alarms with mixed intervals           | All schedule correctly, list scrolls smoothly (60fps)      | P1       |
| RK-02 | Multiple groups          | Create 3 groups with different members          | Each group isolated, members only see their group's alarms | P1       |
| RK-03 | Assign across team       | Assign alarms to 3 different employees          | Each employee receives only their assigned alarms          | P1       |
| RK-04 | Completion dashboard     | Multiple employees mark alarms done over a week | All completions visible to Rachel with correct attribution | P1       |
| RK-05 | Rapid alarm creation     | Create 10 alarms in quick succession            | All 10 save correctly, no duplicates, no dropped alarms    | P1       |
| RK-06 | Group member capacity    | Add 10 members to one group                     | All 10 receive shared alarms, completion visible to all    | P2       |

### 4.7 James & Lisa Park — Premium Co-Parents

> "We can't afford 'I thought you handled it' anymore."

| ID    | Scenario                 | Steps                                     | Expected Result                                            | Priority |
| ----- | ------------------------ | ----------------------------------------- | ---------------------------------------------------------- | -------- |
| JP-01 | Shared "Kids" group      | Create group, add co-parent               | Both see identical alarm list                              | P1       |
| JP-02 | Either parent marks done | Lisa marks "Emma Piano Payment" done      | James sees completion immediately                          | P0       |
| JP-03 | Simultaneous access      | Both parents open same alarm at same time | No conflict, latest completion wins, UI updates on both    | P1       |
| JP-04 | Annual alarm shared      | "Soccer Registration" annual alarm fires  | Both parents get alarm, first to mark done clears for both | P1       |

---

## 5. Device & OS Test Matrix

### 5.1 iOS Test Devices

| Device              | iOS Version | Screen Size | Purpose                                |
| ------------------- | ----------- | ----------- | -------------------------------------- |
| iPhone 16 Pro Max   | iOS 26      | 6.9"        | Primary reference device, Liquid Glass |
| iPhone 16           | iOS 26      | 6.1"        | Standard screen                        |
| iPhone SE (3rd gen) | iOS 26      | 4.7"        | Small screen, older form factor        |
| iPhone 15           | iOS 26      | 6.1"        | Previous generation compatibility      |
| iPad Pro 13"        | iPadOS 26   | 13"         | Tablet layout (if supported)           |

> **Note:** Chronir targets iOS 26+ minimum (AlarmKit dependency). No older OS testing required.

### 5.2 Android Test Devices

| Device             | Android Version          | OEM     | Purpose                                              |
| ------------------ | ------------------------ | ------- | ---------------------------------------------------- |
| Google Pixel 9     | Android 15 (API 35)      | Google  | Reference device (stock Android)                     |
| Google Pixel 7a    | Android 14 (API 34)      | Google  | Budget Pixel, stock behavior                         |
| Samsung Galaxy S24 | Android 14 (One UI 6)    | Samsung | Market leader, aggressive battery optimization       |
| Samsung Galaxy A54 | Android 14 (One UI 6)    | Samsung | Mid-range Samsung (volume device)                    |
| Xiaomi 14          | Android 14 (HyperOS)     | Xiaomi  | Aggressive battery killer, high SE Asia market share |
| OnePlus 12         | Android 14 (OxygenOS 14) | OnePlus | Aggressive background app management                 |

> **Note:** Chronir targets Android 12 (API 31) minimum for `SCHEDULE_EXACT_ALARM` support.

### 5.3 OEM Battery Kill Test Protocol (Android-Critical)

This is the single highest-risk area for Chronir on Android. OEM battery optimizations can silently kill background alarm processes.

| Test ID | OEM      | Scenario                         | Steps                                                               | Expected Result                                               |
| ------- | -------- | -------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------- |
| BK-01   | Samsung  | App in Sleeping Apps list        | Add Chronir to "Sleeping apps" → Schedule alarm 2 hours out      | Alarm fires on time (MUST FAIL — document for user guidance)  |
| BK-02   | Samsung  | App whitelisted                  | Remove from battery optimization → Schedule alarm 2 hours out       | Alarm fires on time                                           |
| BK-03   | Samsung  | Deep Sleep                       | Battery saver on, phone idle 4 hours → Alarm scheduled              | Alarm fires on time after whitelist                           |
| BK-04   | Xiaomi   | Battery Saver enabled            | Enable battery saver → Schedule alarm 1 hour out                    | Alarm fires on time with proper autostart permissions         |
| BK-05   | Xiaomi   | Autostart disabled               | Disable autostart permission → Schedule alarm                       | Alarm FAILS — validate in-app guidance prompts user to enable |
| BK-06   | Xiaomi   | App lock enabled                 | Enable app lock for Chronir → Kill from recents → Wait for alarm | Alarm fires on time                                           |
| BK-07   | OnePlus  | Battery Optimization ON          | Default settings → Schedule alarm                                   | Document behavior — may or may not fire                       |
| BK-08   | OnePlus  | Battery Optimization OFF for app | Exempt Chronir → Schedule alarm                                  | Alarm fires on time                                           |
| BK-09   | All OEMs | After phone restart              | Schedule alarm → Restart phone → Wait for alarm time                | Alarm fires (requires BOOT_COMPLETED receiver)                |
| BK-10   | All OEMs | After force stop                 | Force stop app → Wait for alarm time                                | Alarm does NOT fire (expected) — document for user guidance   |

**Acceptance Criteria:** On every OEM device, when the user follows our in-app battery optimization guide, alarms must fire with ≥99.9% reliability. The in-app guide must include manufacturer-specific instructions with screenshots.

---

## 6. Core Alarm Engine Tests

These are the most critical tests in the entire plan. If alarms don't fire reliably, nothing else matters.

### 6.1 Alarm Scheduling Accuracy

| Test ID | Interval             | Setup                          | Expected Fire Time                                         | Tolerance   | Priority |
| ------- | -------------------- | ------------------------------ | ---------------------------------------------------------- | ----------- | -------- |
| AE-01   | Weekly               | Every Monday 8:00am            | Next Monday 8:00am                                         | ±30 seconds | P0       |
| AE-02   | Weekly               | Every Friday 6:30pm            | Next Friday 6:30pm                                         | ±30 seconds | P0       |
| AE-03   | Monthly (fixed date) | 1st of every month, 9:00am     | Next 1st, 9:00am                                           | ±30 seconds | P0       |
| AE-04   | Monthly (15th)       | 15th of every month, 10:00am   | Next 15th, 10:00am                                         | ±30 seconds | P0       |
| AE-05   | Monthly (31st)       | 31st of every month, 8:00am    | Fires on 31st in 31-day months; last day in shorter months | ±30 seconds | P0       |
| AE-06   | Monthly (Feb 29)     | 29th of every month, 8:00am    | Fires Feb 28 in non-leap years, Feb 29 in leap years       | ±30 seconds | P0       |
| AE-07   | Annual               | March 15 every year, 7:00am    | Next March 15, 7:00am                                      | ±30 seconds | P0       |
| AE-08   | Annual (Feb 29)      | February 29 every year, 9:00am | Fires Feb 28 in non-leap years, Feb 29 in leap years       | ±30 seconds | P0       |
| AE-09   | Biweekly             | Every 2 weeks, starting Monday | Correct Monday every 2 weeks                               | ±30 seconds | P0       |
| AE-10   | Every 6 months       | Biannual on Jan 15 and Jul 15  | Fires on both dates correctly                              | ±30 seconds | P0       |
| AE-11   | One-Time (future)    | One-time alarm set for tomorrow 9am | Fires at specified date/time                          | ±30 seconds | P0       |
| AE-12   | One-Time (past)      | One-time alarm with date in past    | Does not fire; treated as archived                    | N/A         | P1       |

### 6.2 Alarm Firing Behavior

| Test ID | Scenario                    | Expected Result                                                | Priority |
| ------- | --------------------------- | -------------------------------------------------------------- | -------- |
| AF-01   | Phone locked, screen off    | Full-screen alarm appears with sound and vibration             | P0       |
| AF-02   | Phone in Do Not Disturb     | Alarm bypasses DND, fires normally                             | P0       |
| AF-03   | Phone on silent / vibrate   | Alarm sound plays at alarm volume (not media/ringer)           | P0       |
| AF-04   | App in foreground           | Alarm UI appears as overlay/sheet within the app               | P0       |
| AF-05   | App in background           | Full-screen intent (Android) / AlarmKit alert (iOS) triggers   | P0       |
| AF-06   | App killed / not in memory  | Alarm fires via system alarm manager, app launched if needed   | P0       |
| AF-07   | Phone call active           | Alarm indicator appears; fires fully after call ends           | P1       |
| AF-08   | Multiple alarms same time   | Both alarms queue; second fires after first dismissed          | P1       |
| AF-09   | Alarm with photo attachment | Firing screen shows photo prominently alongside title and note | P1       |
| AF-10   | Alarm auto-timeout          | If not dismissed in 5 minutes, snooze automatically for 10 min | P1       |

### 6.3 Auto-Reschedule After Completion

| Test ID | Scenario                                    | Expected Result                                                   | Priority |
| ------- | ------------------------------------------- | ----------------------------------------------------------------- | -------- |
| AR-01   | Weekly alarm marked done                    | Next occurrence = same weekday, next week                         | P0       |
| AR-02   | Monthly alarm marked done on 1st            | Next occurrence = 1st of next month                               | P0       |
| AR-03   | Monthly alarm (31st) marked done in January | Next fire = Feb 28 (or 29 in leap year)                           | P0       |
| AR-04   | Annual alarm marked done                    | Next occurrence = same date, next year                            | P0       |
| AR-05   | Alarm snoozed 1 hour → then dismissed       | Original recurring schedule unaffected; next regular fire correct | P1       |
| AR-06   | Alarm snoozed 1 week → then dismissed       | Original recurring schedule unaffected                            | P1       |
| AR-07   | One-time alarm marked done                  | Alarm auto-archives (isEnabled = false), no reschedule            | P0       |
| AR-08   | One-time alarm snoozed → then marked done   | Snooze works normally, then auto-archives on completion           | P1       |

---

## 7. In-App Purchase & Subscription Tests

| Test ID | Scenario                            | Steps                                           | Expected Result                                                                                      | Priority |
| ------- | ----------------------------------- | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------- | -------- |
| IAP-01  | Free → Plus upgrade                 | Tap upgrade → Complete Apple/Google IAP sandbox | Plus features unlock immediately, alarm limit removed                                                | P0       |
| IAP-02  | Free → Premium upgrade              | Tap upgrade → Select Premium → Complete IAP     | All features including sharing unlocked                                                              | P0       |
| IAP-03  | Plus → Premium upgrade              | Existing Plus user → Upgrade to Premium         | Price prorated, sharing features unlock, no data loss                                                | P0       |
| IAP-04  | Subscription renewal                | Wait for sandbox renewal cycle                  | Features remain active, no interruption                                                              | P0       |
| IAP-05  | Subscription lapse                  | Let subscription expire in sandbox              | Graceful downgrade: existing alarms preserved, creation limited to 2, shared alarms become read-only | P0       |
| IAP-06  | Restore purchase (new device)       | Install on new device → Restore purchases       | Correct tier restored, features match                                                                | P0       |
| IAP-07  | Cancel and re-subscribe             | Cancel → Features downgrade → Re-subscribe      | Full features restored, no duplicate charges                                                         | P1       |
| IAP-08  | Purchase interrupted                | Kill app mid-purchase → Reopen                  | Transaction either completes or rolls back cleanly, no stuck state                                   | P1       |
| IAP-09  | Network loss during purchase        | Airplane mode during IAP                        | Clear error message, no charge, retry available                                                      | P1       |
| IAP-10  | Subscription status check on launch | Open app → Backend validates subscription       | Correct tier displayed within 3 seconds of launch                                                    | P1       |

---

## 8. Cloud Sync & Data Integrity Tests (Plus/Premium)

| Test ID | Scenario                                               | Expected Result                                               | Priority                                              |
| ------- | ------------------------------------------------------ | ------------------------------------------------------------- | ----------------------------------------------------- | --- |
| CS-01   | First cloud backup                                     | All local alarms uploaded to Firestore within 10 seconds      | P0                                                    |
| CS-02   | Restore to new device                                  | All alarms, photos, notes, history restored within 30 seconds | P0                                                    |
| CS-03   | Conflict resolution (same alarm edited on two devices) | Last-write-wins with timestamp; no data corruption            | P0                                                    |
| CS-04   | Offline alarm creation                                 | Create alarm offline → Reconnect                              | Alarm synced to cloud on reconnection                 | P1  |
| CS-05   | Offline alarm completion                               | Mark alarm done offline → Reconnect                           | Completion synced with correct original timestamp     | P1  |
| CS-06   | Photo sync                                             | Attach photo → Check on second device                         | Photo available within 15 seconds, correct resolution | P1  |
| CS-07   | Large sync (60 alarms + history)                       | Restore account with 60 alarms and 6 months of history        | Complete restore within 60 seconds, no missing data   | P1  |
| CS-08   | Firestore security rules                               | Attempt to read another user's alarms via API                 | Request denied; data isolation confirmed              | P0  |

---

## 9. UI & Design System Compliance Tests

### 9.1 Atomic Design System Verification

| Test ID | Check                         | Method                                                              | Pass Criteria                 |
| ------- | ----------------------------- | ------------------------------------------------------------------- | ----------------------------- |
| DS-01   | No hardcoded colors           | Code grep for hex values outside token files                        | Zero instances                |
| DS-02   | No hardcoded spacing          | Code grep for literal dp/pt outside token files                     | Zero instances                |
| DS-03   | No hardcoded typography       | Code grep for font definitions outside token files                  | Zero instances                |
| DS-04   | Color coding consistency      | Weekly=Green, Monthly=Blue, Annual=Purple across all screens        | Visual audit pass             |
| DS-05   | Component hierarchy           | Atoms used in molecules, molecules in organisms (no layer skipping) | Architecture review pass      |
| DS-06   | iOS Liquid Glass compliance   | `.glassEffect()` applied on alarm cards, navigation elements        | Visual audit on iOS 26 device |
| DS-07   | Android Material 3 compliance | Dynamic color, tonal elevation, correct component selection         | Visual audit on Pixel device  |

### 9.2 Key Screen Tests

| Screen                  | Test Items                                                                                                                                                                                            | Priority |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| **Home (Alarm List)**   | Correct sort by next fire date, color-coded interval badges, empty state for new users, smooth 60fps scroll with 60+ alarms                                                                           | P1       |
| **Create/Edit Alarm**   | All interval pickers work, date/time selection, note/photo attachment, save validates required fields, edit preserves all data                                                                        | P1       |
| **Alarm Firing Screen** | Full-screen, high contrast (no Liquid Glass — urgency over aesthetics), title + note + photo visible, Snooze/Dismiss/Done buttons occupy 60% of screen height, long-press required for annual dismiss | P0       |
| **Completion History**  | Chronological list, correct timestamps, filterable by alarm, attributions for shared alarms (Premium)                                                                                                 | P2       |
| **Groups (Premium)**    | Create/rename/delete group, add/remove members, member list accurate, alarm assignment UI                                                                                                             | P1       |
| **Settings**            | Account management, subscription tier display, notification preferences, battery optimization guide (Android), export/import, about/legal links                                                       | P2       |
| **Upgrade Prompt**      | Appears at correct triggers (3rd alarm, share attempt), clear tier comparison, one-tap purchase                                                                                                       | P1       |

---

## 10. Notification & Permission Tests

### 10.1 iOS

| Test ID | Scenario                          | Expected Result                                                | Priority |
| ------- | --------------------------------- | -------------------------------------------------------------- | -------- |
| NP-01   | Notification permission denied    | App explains why alarms need permission, deep link to Settings | P0       |
| NP-02   | AlarmKit permission (iOS 26)      | Permission granted → Alarms use AlarmKit API                   | P0       |
| NP-03   | Time Sensitive notification level | Pre-alarm warnings delivered as time-sensitive                 | P1       |
| NP-04   | Notification grouping             | Multiple pre-alarms group under "Chronir"                   | P2       |

### 10.2 Android

| Test ID | Scenario                                     | Expected Result                                                    | Priority |
| ------- | -------------------------------------------- | ------------------------------------------------------------------ | -------- |
| NP-05   | SCHEDULE_EXACT_ALARM permission              | Permission request on first alarm creation; explains impact        | P0       |
| NP-06   | POST_NOTIFICATIONS permission (API 33+)      | Permission requested; denied = still schedules but no sound/visual | P0       |
| NP-07   | USE_FULL_SCREEN_INTENT permission            | Granted on install for alarm-category apps                         | P0       |
| NP-08   | Notification channel: Alarm                  | High importance, full-screen intent, bypass DND                    | P0       |
| NP-09   | Notification channel: Pre-Alarm              | Default importance, no sound, collapsible                          | P1       |
| NP-10   | BOOT_COMPLETED receiver                      | Alarms reschedule correctly after device reboot                    | P0       |
| NP-11   | Exact alarm permission revoked (Android 14+) | App detects revocation → Shows warning → Deep link to Settings     | P0       |

---

## 11. Edge Cases & Boundary Tests

| Test ID | Scenario                                    | Expected Result                                                                                        | Priority                             |
| ------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------ | --- |
| EC-01   | Timezone change (travel)                    | Alarm fires at the user's chosen local time in new timezone (or original timezone based on preference) | P1                                   |
| EC-02   | Daylight Saving Time spring forward         | Alarm set for 2:30am (non-existent) → Fires at 3:00am or next valid time                               | P1                                   |
| EC-03   | Daylight Saving Time fall back              | Alarm set for 1:30am (ambiguous) → Fires once, not twice                                               | P1                                   |
| EC-04   | Leap year Feb 29 alarm in non-leap year     | Fires Feb 28 with clear indication it was adjusted                                                     | P1                                   |
| EC-05   | Year rollover                               | Annual alarm set for Dec 31 → Fires Dec 31, then next Dec 31 (not Jan 1)                               | P1                                   |
| EC-06   | Create alarm for today, time already passed | Alarm schedules for next occurrence (next week/month/year), not today                                  | P1                                   |
| EC-07   | Device clock manually changed forward       | Alarm fires if current time surpasses alarm time on next app/system check                              | P2                                   |
| EC-08   | Device clock manually changed backward      | Alarm does not fire again if already dismissed                                                         | P2                                   |
| EC-09   | Device storage full                         | Alarm creation fails gracefully with message; existing alarms unaffected                               | P1                                   |
| EC-10   | 100+ completion history entries             | History screen loads and scrolls without lag                                                           | P2                                   |
| EC-11   | Photo attachment > 10MB                     | Image compressed on save; alarm functions normally                                                     | P2                                   |
| EC-12   | Very long alarm title (100+ chars)          | Title truncated gracefully in list view, full title shown in detail                                    | P2                                   |
| EC-13   | Unicode/emoji in alarm title and notes      | Displayed correctly on all screens, syncs correctly across devices                                     | P2                                   |
| EC-14   | Rapid snooze cycling                        | Snooze → fires → snooze → fires (5 cycles)                                                             | No memory leak, each snooze accurate | P1  |

---

## 12. Performance Benchmarks

| Metric                                         | Target                                          | Measurement Tool                 | Platform |
| ---------------------------------------------- | ----------------------------------------------- | -------------------------------- | -------- |
| Cold start time                                | < 2.0 seconds                                   | Instruments / Android Profiler   | Both     |
| Warm start time                                | < 500ms                                         | Instruments / Android Profiler   | Both     |
| Alarm list scroll (60 items)                   | 60fps, no dropped frames                        | GPU profiling                    | Both     |
| Memory usage (idle, 10 alarms)                 | < 80MB                                          | Instruments / Android Profiler   | Both     |
| Memory usage (idle, 60 alarms)                 | < 150MB                                         | Instruments / Android Profiler   | Both     |
| Battery drain (backgrounded, alarms scheduled) | < 1% per hour                                   | Battery stats over 8-hour test   | Both     |
| Cloud sync (10 alarms)                         | < 5 seconds                                     | Stopwatch from login to complete | Both     |
| Cloud sync (60 alarms + history)               | < 60 seconds                                    | Stopwatch from login to complete | Both     |
| Photo attachment load time                     | < 1 second from cache, < 3 seconds from network | Stopwatch                        | Both     |
| App size (installed)                           | < 30MB without user data                        | App info                         | Both     |

---

## 13. Security & Privacy Tests

| Test ID | Scenario                         | Expected Result                                                                     | Priority |
| ------- | -------------------------------- | ----------------------------------------------------------------------------------- | -------- |
| SP-01   | Firestore security rules audit   | Users can only access their own data and shared group data                          | P0       |
| SP-02   | Auth token expiry                | Expired token triggers silent refresh; no user disruption                           | P1       |
| SP-03   | Photo storage access             | Photos only accessible by alarm owner and shared group members                      | P0       |
| SP-04   | Account deletion                 | All user data (alarms, photos, history, groups) permanently deleted within 48 hours | P0       |
| SP-05   | Shared alarm after group removal | Removed member loses all access to group's alarms and data                          | P1       |
| SP-06   | API abuse prevention             | Rate limiting on Firestore writes (alarm creation, completion marking)              | P1       |
| SP-07   | Data encryption at rest          | Firebase default encryption verified                                                | P1       |
| SP-08   | Sensitive data in logs           | No PII, alarm content, or auth tokens in debug/crash logs                           | P0       |

---

## 14. App Store & Play Store Submission Checklist

### 14.1 iOS App Store

- [ ] App runs on all devices in test matrix without crash
- [ ] AlarmKit usage declared in App Store Connect
- [ ] In-app purchases configured and approved in App Store Connect sandbox
- [ ] Privacy nutrition labels accurate (data collected, linked to identity, tracking)
- [ ] App Privacy Report: no unexpected network calls
- [ ] Screenshots for all required device sizes (6.9", 6.1", iPad if supported)
- [ ] App Review notes explain AlarmKit usage and alarm persistence behavior
- [ ] Rating/age classification appropriate (Utilities, 4+)
- [ ] Privacy policy URL active and accessible
- [ ] Terms of service URL active and accessible
- [ ] No private API usage
- [ ] Passes `xcodebuild test` with zero failures

### 14.2 Google Play Store

- [ ] App runs on all devices in test matrix without crash
- [ ] `SCHEDULE_EXACT_ALARM` usage justified in Play Console declaration
- [ ] `USE_FULL_SCREEN_INTENT` declared for alarm functionality
- [ ] In-app purchases tested on Google Play internal/closed test tracks
- [ ] Data safety section accurate (data types, encryption, deletion, sharing)
- [ ] Target SDK meets current Play Store requirement (API 34+)
- [ ] Battery optimization whitelist guidance does NOT violate Play Store policy
- [ ] Screenshots for phone and tablet (if supported)
- [ ] Content rating questionnaire completed
- [ ] Privacy policy URL active and accessible
- [ ] ProGuard/R8 obfuscation does not break alarm BroadcastReceiver
- [ ] Passes all lint checks with zero errors

---

## 15. Test Execution Schedule

Mapped to the 14-week development roadmap.

| Phase                          | Weeks | Test Activities                                                                                                                                                                                                                                           |
| ------------------------------ | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **V1.0 — Free + Plus**         | 1–6   | Unit tests for alarm scheduling engine (P0). Manual alarm firing tests on all devices (Section 6). IAP sandbox testing (Section 7). Accessibility audit. OEM battery kill tests begin.                                                                    |
| **V1.1 — Premium**             | 7–10  | Cloud sync tests (Section 8). Shared alarm cross-platform tests (Persona MR). Group management tests (Persona RK). Security rules audit (Section 13).                                                                                                     |
| **V1.2 — Polish & Submission** | 11–14 | Full regression across all tiers. 72-hour soak test (release gate R3). Performance benchmark pass (Section 12). Store submission checklists (Section 14). Edge case marathon (Section 11). Final persona walkthrough — every persona scenario end-to-end. |

### 15.1 Regression Triggers

Full regression suite must run when:

- Any change to the alarm scheduling engine
- Any change to notification/permission handling
- Any change to IAP or subscription logic
- Any change to Firestore security rules
- Any OEM-specific workaround is added
- Before every release candidate build

---

## 16. Bug Reporting Template

All bugs must be filed with the following fields:

```
**Title:** [P0/P1/P2/P3] Brief description
**Test ID:** (from this plan, e.g., AE-03, MR-04)
**Platform:** iOS / Android
**Device:** (model + OS version)
**Tier:** Free / Plus / Premium
**Steps to Reproduce:**
1.
2.
3.
**Expected Result:**
**Actual Result:**
**Frequency:** Always / Intermittent (X/Y attempts)
**Screenshots/Video:** (attached)
**Logs:** (Crashlytics link or logcat dump)
```

---

## 17. Revision History

| Date          | Version | Changes                                                                                                                                                | Author       |
| ------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------ |
| February 2026 | 1.0     | Initial QA Test Plan — full coverage across all tiers, personas, device matrix, alarm engine, IAP, sync, accessibility, security, and store submission | Product Team |
