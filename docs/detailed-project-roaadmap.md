# Chronir — Detailed Project Roadmap

**Version:** 1.0  
**Last Updated:** February 6, 2026  
**Methodology:** Atomic Design · Native Dual-Platform · Sprint-Based Agile  
**Sprint Cadence:** 1-week sprints  
**Platforms:** iOS (SwiftUI / Liquid Glass / AlarmKit) · Android (Kotlin / Jetpack Compose / Material 3)

---

## Roadmap Overview

| Phase                           | Sprints      | Focus                                              | Deliverable                            |
| ------------------------------- | ------------ | -------------------------------------------------- | -------------------------------------- |
| **Phase 1 — Foundation**        | Sprint 1–3   | Design tokens, atomic components, project scaffold | Design system + empty shell apps       |
| **Phase 2 — V1.0 Free Tier**    | Sprint 4–7   | Core alarm engine, local storage, 2-alarm limit    | Functional Free tier on both platforms |
| **Phase 3 — V1.0 Plus Tier**    | Sprint 8–10  | Unlimited alarms, attachments, pre-alarms, history | Plus tier IAP on both platforms        |
| **Phase 4 — V1.1 Premium Tier** | Sprint 11–13 | Firebase backend, auth, shared alarms, groups      | Premium tier subscription              |
| **Phase 5 — Polish & Launch**   | Sprint 14–16 | QA, accessibility audit, store submissions         | App Store + Play Store live            |
| **Phase 6 — Post-Launch**       | Sprint 17–20 | Analytics-driven iteration, V2.0 features          | Continuous improvement                 |
| **Phase 7 — Smart Speaker**     | Sprint 21–22 | Alexa integration for pre-alarm speaker announcements | Premium speaker announcements         |

---

## Phase 1 — Foundation (Sprints 1–3)

### Sprint 1: Project Scaffold & Design Token Pipeline

**Goal:** Both platform projects bootstrapped with shared design token architecture.

| ID    | Task                                                                                   | Platform | Priority | Story Points |
| ----- | -------------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S1-01 | Initialize iOS Xcode project (SwiftUI, iOS 26 minimum, SwiftData)                      | iOS      | P0       | 2            |
| S1-02 | Initialize Android project (Kotlin, Jetpack Compose, Room, API 31 min)                 | Android  | P0       | 2            |
| S1-03 | Set up Git repositories with branching strategy (main / develop / feature)             | Both     | P0       | 1            |
| S1-04 | Define primitive design tokens in JSON (colors, typography, spacing, motion, radii)    | Shared   | P0       | 3            |
| S1-05 | Configure Style Dictionary with iOS-Swift and Android-Compose output targets           | Shared   | P0       | 3            |
| S1-06 | Generate iOS token extensions (Color, Font, CGFloat constants)                         | iOS      | P0       | 2            |
| S1-07 | Generate Android token CompositionLocals and theme objects                             | Android  | P0       | 2            |
| S1-08 | Define semantic tokens: `color.alarm.active`, `color.alarm.inactive`, `color.firing.*` | Shared   | P0       | 2            |
| S1-09 | Set up iOS Liquid Glass-specific tokens (glass levels, blur radii)                     | iOS      | P1       | 2            |
| S1-10 | Set up Material 3 dynamic color integration with custom token overrides                | Android  | P1       | 2            |
| S1-11 | Create CI pipeline (build on push, lint checks)                                        | Both     | P1       | 3            |

**Sprint Total:** 24 SP  
**Definition of Done:** Both apps build and run with themed empty screens using generated tokens. CI green.

---

### Sprint 2: Atoms & Molecules

**Goal:** Core atomic components built and previewed on both platforms.

| ID    | Task                                                                                           | Platform | Priority | Story Points |
| ----- | ---------------------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S2-01 | **Atom:** ChronirText — styled text variants (display, headline, body, caption)                  | Both     | P0       | 2            |
| S2-02 | **Atom:** ChronirIcon — icon wrapper with size/color token support (SF Symbols / Material Icons) | Both     | P0       | 2            |
| S2-03 | **Atom:** ChronirToggle — alarm on/off switch with haptic feedback                               | Both     | P0       | 2            |
| S2-04 | **Atom:** ChronirBadge — cycle type indicator (Weekly=green, Monthly=blue, Annual=purple)        | Both     | P0       | 2            |
| S2-05 | **Atom:** ChronirButton — primary, secondary, destructive variants                               | Both     | P0       | 3            |
| S2-06 | **Molecule:** AlarmTimeDisplay — large time + AM/PM + countdown subtext                        | Both     | P0       | 3            |
| S2-07 | **Molecule:** AlarmToggleRow — label + cycle badge + toggle + next fire date                   | Both     | P0       | 3            |
| S2-08 | **Molecule:** IntervalPicker — cycle type selector (weekly / monthly / annual)                 | Both     | P1       | 3            |
| S2-09 | **Molecule:** SnoozeOptionBar — 1 hour / 1 day / 1 week buttons                                | Both     | P1       | 2            |
| S2-10 | Set up SwiftUI multi-preview providers (dark mode, Dynamic Type, states)                       | iOS      | P1       | 2            |
| S2-11 | Set up Compose @Preview with multi-theme and font scale configurations                         | Android  | P1       | 2            |

**Sprint Total:** 26 SP  
**Definition of Done:** All atoms and molecules render correctly in light/dark mode, pass accessibility contrast checks, and have preview coverage.

---

### Sprint 3: Organisms & Templates

**Goal:** Screen-level layouts composed from molecules; app navigation skeleton wired.

| ID    | Task                                                                                                | Platform | Priority | Story Points |
| ----- | --------------------------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S3-01 | **Organism:** AlarmCard — full alarm summary (time, label, badge, toggle, next fire, swipe actions) | Both     | P0       | 5            |
| S3-02 | **Organism:** AlarmListSection — grouped list of AlarmCards with section headers                    | Both     | P0       | 3            |
| S3-03 | **Organism:** EmptyStateView — illustration + "Create your first alarm" CTA                         | Both     | P0       | 2            |
| S3-04 | **Organism:** AlarmFiringOverlay — full-screen firing UI (title, note, Snooze/Dismiss/Done)         | Both     | P0       | 5            |
| S3-05 | **Template:** HomeTemplate — NavigationStack/Scaffold + AlarmListSection + FAB/Add button           | Both     | P0       | 3            |
| S3-06 | **Template:** CreateAlarmTemplate — bottom sheet / full-screen form layout                          | Both     | P0       | 3            |
| S3-07 | **Template:** SettingsTemplate — grouped settings list layout                                       | Both     | P1       | 2            |
| S3-08 | Wire iOS tab bar / navigation (Liquid Glass translucent bottom bar)                                 | iOS      | P0       | 2            |
| S3-09 | Wire Android navigation (Material 3 NavigationBar + NavHost)                                        | Android  | P0       | 2            |
| S3-10 | Create component catalog target/flavor for internal design review                                   | Both     | P1       | 3            |

**Sprint Total:** 30 SP  
**Definition of Done:** App shows complete navigation skeleton with placeholder data. AlarmCard renders with all visual states (active, inactive, firing). Component catalog distributable via TestFlight / Firebase App Distribution.

---

## Phase 2 — V1.0 Free Tier (Sprints 4–7)

### Sprint 4: Core Alarm Engine — Scheduling

**Goal:** Users can create, edit, and schedule alarms that fire on time.

| ID    | Task                                                                                          | Platform | Priority | Story Points |
| ----- | --------------------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S4-01 | Define alarm data model (id, title, time, interval type, repeat config, isEnabled, createdAt) | Both     | P0       | 3            |
| S4-02 | Implement SwiftData schema + CRUD repository                                                  | iOS      | P0       | 3            |
| S4-03 | Implement Room database schema + DAO + CRUD repository                                        | Android  | P0       | 3            |
| S4-04 | Integrate AlarmKit for scheduling exact alarms (iOS 26)                                       | iOS      | P0       | 5            |
| S4-05 | Integrate AlarmManager.setAlarmClock() + SCHEDULE_EXACT_ALARM permission                      | Android  | P0       | 5            |
| S4-06 | Implement weekly interval scheduling logic                                                    | Both     | P0       | 3            |
| S4-07 | Implement monthly interval scheduling logic (handle variable month lengths)                   | Both     | P0       | 3            |
| S4-08 | Implement annual interval scheduling logic (handle leap years)                                | Both     | P0       | 2            |
| S4-09 | Implement alarm toggle (enable/disable cancels or reschedules)                                | Both     | P0       | 2            |
| S4-10 | Wire Create Alarm page — form → data model → schedule → save                                  | Both     | P0       | 3            |

**Sprint Total:** 32 SP  
**Definition of Done:** User can create weekly/monthly/annual alarms and they fire at the correct time. Alarms persist across app restart.

---

### Sprint 5: Alarm Firing & Dismissal

**Goal:** Full-screen alarm fires persistently with proper dismissal flow.

| ID    | Task                                                                                    | Platform | Priority | Story Points |
| ----- | --------------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S5-01 | Implement full-screen alarm intent (iOS foreground scene, Android full-screen Activity) | Both     | P0       | 5            |
| S5-02 | Implement alarm sound playback (system alarm sounds, looping)                           | Both     | P0       | 3            |
| S5-03 | Implement DND bypass (iOS critical alerts permission, Android alarm channel)            | Both     | P0       | 3            |
| S5-04 | Implement snooze logic — 1 hour / 1 day / 1 week reschedule                             | Both     | P0       | 3            |
| S5-05 | Implement "Mark as Done" — dismiss + auto-schedule next occurrence                      | Both     | P0       | 3            |
| S5-06 | Implement deliberate dismissal pattern (swipe-to-stop with haptic confirmation)         | Both     | P0       | 3            |
| S5-07 | Handle alarm firing when app is in background / killed                                  | Both     | P0       | 5            |
| S5-08 | Implement vibration pattern for alarm firing                                            | Both     | P1       | 2            |
| S5-09 | Add alarm notification channel setup (Android high-priority, iOS time-sensitive)        | Both     | P0       | 2            |

**Sprint Total:** 29 SP  
**Definition of Done:** Alarms fire full-screen with sound even when app is backgrounded/killed. Snooze reschedules correctly. DND bypass works with proper permissions.

---

### Sprint 6: Home Screen & Alarm Management

**Goal:** Polished home screen with alarm list, edit, delete, and 2-alarm limit enforcement.

| ID    | Task                                                                        | Platform | Priority | Story Points |
| ----- | --------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S6-01 | Wire Home page with live alarm list sorted by next fire date                | Both     | P0       | 3            |
| S6-02 | Implement "time until alarm" countdown display on each AlarmCard            | Both     | P0       | 3            |
| S6-03 | Implement Edit Alarm flow (tap card → edit sheet → save)                    | Both     | P0       | 3            |
| S6-04 | Implement Delete Alarm with confirmation dialog                             | Both     | P0       | 2            |
| S6-05 | Implement swipe actions on AlarmCard (swipe to delete, swipe to edit)       | Both     | P1       | 3            |
| S6-06 | **Enforce 2-alarm limit** for Free tier with upgrade prompt on 3rd creation | Both     | P0       | 3            |
| S6-07 | Design and implement upgrade prompt bottom sheet / dialog                   | Both     | P0       | 3            |
| S6-08 | Implement empty state ("Create your first alarm" onboarding CTA)            | Both     | P0       | 2            |
| S6-09 | Handle edge case: alarm fires while user is in Create/Edit flow             | Both     | P1       | 2            |
| S6-10 | Implement alarm color coding (Weekly=green, Monthly=blue, Annual=purple)    | Both     | P0       | 1            |

**Sprint Total:** 25 SP  
**Definition of Done:** Users can manage alarms end-to-end. Free tier limit enforced with smooth upgrade prompt. Home screen updates in real-time.

---

### Sprint 7: Settings, Onboarding & Free Tier Polish

**Goal:** Settings screen, first-launch experience, and Free tier feature-complete.

| ID    | Task                                                                              | Platform | Priority | Story Points |
| ----- | --------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S7-01 | Implement Settings page — notification preferences, sound selection               | Both     | P0       | 3            |
| S7-02 | Add battery optimization guide (manufacturer-specific instructions)               | Android  | P0       | 3            |
| S7-03 | Implement permission request flows (notifications, exact alarms, critical alerts) | Both     | P0       | 3            |
| S7-04 | Create first-launch onboarding (2–3 screens explaining value prop)                | Both     | P1       | 3            |
| S7-05 | Implement timezone handling (user preference: adjust or fixed when traveling)     | Both     | P1       | 3            |
| S7-06 | Add app icon design integration                                                   | Both     | P1       | 1            |
| S7-07 | Implement local backup awareness (iCloud / Google auto-backup)                    | Both     | P1       | 2            |
| S7-08 | Build dark mode / OLED firing screen (true black background)                      | Both     | P0       | 2            |
| S7-09 | **Free Tier End-to-End QA** — all user journeys for Free tier                     | Both     | P0       | 5            |
| S7-10 | Performance profiling — alarm scheduling latency, UI jank                         | Both     | P1       | 2            |

**Sprint Total:** 27 SP  
**Definition of Done:** Free tier is fully functional and polished. All Free tier user journeys pass (Skeptical Trier, Forgetful Homeowner, Pet Owner). Internal build distributed for review.

---

## Phase 3 — V1.0 Plus Tier (Sprints 8–10)

### Sprint 8: Unlimited Alarms & Task Attachments

**Goal:** Plus tier unlocks unlimited alarms with photo/note attachment capability.

| ID    | Task                                                                               | Platform | Priority | Story Points |
| ----- | ---------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S8-01 | Implement StoreKit 2 subscription (Plus monthly + annual)                          | iOS      | P0       | 5            |
| S8-02 | Implement Google Play Billing Library subscription (Plus monthly + annual)         | Android  | P0       | 5            |
| S8-03 | Implement subscription status check — gate features based on tier                  | Both     | P0       | 3            |
| S8-04 | Remove 2-alarm limit when Plus is active                                           | Both     | P0       | 1            |
| S8-05 | Implement note attachment on alarms (text field in create/edit)                    | Both     | P0       | 2            |
| S8-06 | Implement photo attachment — camera/gallery picker + local storage                 | Both     | P0       | 3            |
| S8-07 | Display photo/note on alarm firing screen                                          | Both     | P0       | 2            |
| S8-08 | Implement subscription management screen (current plan, upgrade/downgrade, cancel) | Both     | P0       | 3            |
| S8-09 | Handle subscription expiry gracefully (keep alarms but re-enforce limit)           | Both     | P0       | 3            |
| S8-10 | Implement restore purchases flow                                                   | Both     | P0       | 2            |

**Sprint Total:** 29 SP  
**Definition of Done:** Plus subscription purchasable on both platforms. Unlimited alarms unlocked. Photo/note attachments work end-to-end including on firing screen.

---

### Sprint 9: Pre-Alarm Warnings & Completion History

**Goal:** 24-hour pre-alarm notifications and historical completion tracking.

| ID    | Task                                                                                            | Platform | Priority | Story Points |
| ----- | ----------------------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S9-01 | Implement pre-alarm warning system (silent notification 24h before)                             | Both     | P0       | 3            |
| S9-02 | Add pre-alarm toggle per alarm (opt-in on create/edit)                                          | Both     | P0       | 2            |
| S9-03 | Design and build Completion History page (timeline of past completions)                         | Both     | P0       | 5            |
| S9-04 | Extend data model for completion records (alarmId, completedAt, action: done/snoozed/dismissed) | Both     | P0       | 2            |
| S9-05 | Record completion events on every alarm interaction                                             | Both     | P0       | 2            |
| S9-06 | Implement completion streak counter (consecutive on-time completions)                           | Both     | P1       | 3            |
| S9-07 | Gate Completion History page behind Plus tier                                                   | Both     | P0       | 1            |
| S9-08 | Implement custom snooze duration option (Plus feature)                                          | Both     | P1       | 2            |
| S9-09 | Add haptic feedback throughout the app (toggle, dismiss, snooze, done)                          | Both     | P1       | 2            |

**Sprint Total:** 22 SP  
**Definition of Done:** Pre-alarm fires 24h before main alarm. Completion history shows full timeline with completion/snooze/dismiss records. All gated behind Plus.

---

### Sprint 10: Cloud Backup & Plus Tier Polish

**Goal:** Cloud backup for Plus users and full Plus tier QA.

| ID     | Task                                                                         | Platform | Priority | Story Points |
| ------ | ---------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S10-01 | Set up Firebase project (Auth, Firestore, Cloud Storage, Crashlytics)        | Shared   | P0       | 3            |
| S10-02 | Implement Firebase Auth (Email, Google Sign-In, Apple Sign-In)               | Both     | P0       | 5            |
| S10-03 | Implement cloud backup — sync alarm data to Firestore on Plus sign-in        | Both     | P0       | 5            |
| S10-04 | Implement cloud restore — download alarms on new device login                | Both     | P0       | 3            |
| S10-05 | Upload photo attachments to Firebase Cloud Storage                           | Both     | P0       | 3            |
| S10-06 | Implement conflict resolution (local vs cloud, last-write-wins)              | Both     | P1       | 3            |
| S10-07 | Add account creation/login UI in Settings (only shown to Plus/Premium users) | Both     | P0       | 2            |
| S10-08 | **Plus Tier End-to-End QA** — all Plus user journeys                         | Both     | P0       | 5            |
| S10-09 | Subscription edge case testing (expired, refunded, family sharing)           | Both     | P0       | 3            |

**Sprint Total:** 32 SP  
**Definition of Done:** Plus users can sign in, backup/restore alarms across devices. All Plus user journeys pass (Power User, Device Upgrader). Subscription lifecycle validated.

---

## Phase 4 — V1.1 Premium Tier (Sprints 11–13)

### Sprint 11: Shared Alarms & Invitations

**Goal:** Premium users can share alarms with other users.

| ID     | Task                                                                              | Platform | Priority | Story Points |
| ------ | --------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S11-01 | Implement Premium subscription tier (StoreKit 2 + Play Billing)                   | Both     | P0       | 3            |
| S11-02 | Design Firestore schema for shared alarms (owner, members[], sharedAt)            | Shared   | P0       | 3            |
| S11-03 | Implement invite link generation (deep link with alarm reference)                 | Both     | P0       | 3            |
| S11-04 | Implement invite acceptance flow (deep link → app → accept/decline)               | Both     | P0       | 5            |
| S11-05 | Handle "receiver-only" mode (invited user downloads free, can view shared alarms) | Both     | P0       | 3            |
| S11-06 | Implement real-time sync for shared alarm state changes (Firestore listeners)     | Both     | P0       | 5            |
| S11-07 | Display shared badge on AlarmCard for shared alarms                               | Both     | P0       | 1            |
| S11-08 | Implement shared alarm firing — fires on all members' devices simultaneously      | Both     | P0       | 5            |
| S11-09 | Implement shared completion visibility — see when others mark done                | Both     | P0       | 3            |

**Sprint Total:** 31 SP  
**Definition of Done:** Premium user can share alarm via link. Invited user receives alarm and gets fired simultaneously. Completion status syncs in real-time across all shared members.

---

### Sprint 12: Groups & Assignment

**Goal:** Premium users can create groups and assign alarms to specific members.

| ID     | Task                                                                            | Platform | Priority | Story Points |
| ------ | ------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S12-01 | Design Firestore schema for groups (name, owner, members[], alarms[])           | Shared   | P0       | 2            |
| S12-02 | Build Groups page — list of groups with member avatars                          | Both     | P0       | 3            |
| S12-03 | Implement Create Group flow (name, invite members)                              | Both     | P0       | 3            |
| S12-04 | Implement Group member management (add, remove, leave)                          | Both     | P0       | 3            |
| S12-05 | Implement alarm assignment within groups (assign to specific members)           | Both     | P0       | 3            |
| S12-06 | Build group completion dashboard (who completed, when, pending items)           | Both     | P0       | 5            |
| S12-07 | Implement shared notes/photos on group alarms (all members see attachments)     | Both     | P1       | 2            |
| S12-08 | Implement group notifications (member joined, member completed alarm)           | Both     | P1       | 3            |
| S12-09 | Handle group edge cases (member uninstalls app, member downgrades from Premium) | Both     | P1       | 3            |

**Sprint Total:** 27 SP  
**Definition of Done:** Users can create groups (Household, Team, Kids), assign alarms to members, and view group-wide completion dashboard. Group sync works in real-time.

---

### Sprint 13: Premium Polish & Cross-Device Sync

**Goal:** Full real-time sync, Premium tier QA, and edge case coverage.

| ID     | Task                                                                            | Platform | Priority | Story Points |
| ------ | ------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S13-01 | Implement full cross-device real-time sync (alarm CRUD + state changes)         | Both     | P0       | 5            |
| S13-02 | Implement offline mode with sync queue (offline changes sync when reconnected)  | Both     | P0       | 5            |
| S13-03 | Implement push notifications for shared alarm events (Firebase Cloud Messaging) | Both     | P0       | 3            |
| S13-04 | Handle Premium → Plus downgrade (keep personal alarms, remove shared access)    | Both     | P0       | 3            |
| S13-05 | Handle Premium → Free downgrade (enforce 2-alarm limit, remove cloud features)  | Both     | P0       | 2            |
| S13-06 | Implement account deletion with data cleanup (GDPR compliance)                  | Both     | P0       | 3            |
| S13-07 | **Premium Tier End-to-End QA** — all Premium user journeys                      | Both     | P0       | 5            |
| S13-08 | Stress test shared alarms (10+ members, rapid state changes)                    | Both     | P1       | 3            |
| S13-09 | Verify Firebase Security Rules (auth-gated reads/writes, group membership)      | Shared   | P0       | 3            |

**Sprint Total:** 32 SP  
**Definition of Done:** All Premium user journeys pass (Co-Parents, Small Business Owner, Elderly Care, Device Upgrader). Real-time sync reliable across network conditions. Security rules validated.

---

## Phase 5 — Polish & Launch (Sprints 14–16)

### Sprint 14: Accessibility & Platform Polish

**Goal:** WCAG 2.2 AA compliance and platform-native polish.

| ID     | Task                                                                          | Platform | Priority | Story Points |
| ------ | ----------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S14-01 | Accessibility audit — touch targets 44pt+ (iOS) / 48dp+ (Android)             | Both     | P0       | 3            |
| S14-02 | Implement VoiceOver labels for all interactive elements                       | iOS      | P0       | 3            |
| S14-03 | Implement TalkBack contentDescription for all interactive elements            | Android  | P0       | 3            |
| S14-04 | Verify contrast ratios (4.5:1 body, 3:1 large text/UI) across all screens     | Both     | P0       | 2            |
| S14-05 | Implement Dynamic Type / font scale support across all screens                | Both     | P0       | 3            |
| S14-06 | Respect `prefers-reduced-motion` — disable animations where set               | Both     | P0       | 2            |
| S14-07 | Ensure all swipe actions have button alternatives                             | Both     | P0       | 2            |
| S14-08 | iOS Liquid Glass polish pass — translucent bars, morphing sheets, glass cards | iOS      | P1       | 3            |
| S14-09 | Android Material 3 polish pass — dynamic color, tonal elevation, motion       | Android  | P1       | 3            |
| S14-10 | Color-blind mode review (no red/green-only state indicators)                  | Both     | P0       | 1            |

**Sprint Total:** 25 SP  
**Definition of Done:** App passes accessibility audit on both platforms. VoiceOver and TalkBack flows tested for all critical paths (create alarm, fire/dismiss, manage groups).

---

### Sprint 15: Widgets, Testing & Performance

**Goal:** Home screen widgets, comprehensive testing, and performance optimization.

| ID     | Task                                                                           | Platform | Priority | Story Points |
| ------ | ------------------------------------------------------------------------------ | -------- | -------- | ------------ |
| S15-01 | Implement iOS Widget (WidgetKit) — next alarm countdown                        | iOS      | P1       | 5            |
| S15-02 | Implement Android Widget (Glance) — next alarm countdown                       | Android  | P1       | 5            |
| S15-03 | Implement iOS Live Activity — Dynamic Island countdown for imminent alarms     | iOS      | P2       | 3            |
| S15-04 | Write unit tests for alarm scheduling logic (interval calculation, edge cases) | Both     | P0       | 5            |
| S15-05 | Write unit tests for subscription gating logic                                 | Both     | P0       | 2            |
| S15-06 | Write integration tests for Firebase sync (shared alarms, groups)              | Both     | P0       | 3            |
| S15-07 | Performance profiling — app launch time (<2s cold start target)                | Both     | P0       | 2            |
| S15-08 | Memory profiling — alarm firing screen (no leaks during extended ring)         | Both     | P0       | 2            |
| S15-09 | Battery impact analysis — background alarm scheduling efficiency               | Both     | P0       | 2            |

**Sprint Total:** 29 SP  
**Definition of Done:** Widgets render correctly on both platforms. Unit test coverage ≥80% on alarm engine. Cold start <2s. No memory leaks on firing screen.

---

### Sprint 16: Store Submission & Launch

**Goal:** Both apps submitted and approved on App Store and Play Store.

| ID     | Task                                                                               | Platform | Priority | Story Points |
| ------ | ---------------------------------------------------------------------------------- | -------- | -------- | ------------ |
| S16-01 | Prepare App Store listing (screenshots, description, keywords, preview video)      | iOS      | P0       | 3            |
| S16-02 | Prepare Play Store listing (screenshots, description, feature graphic, categories) | Android  | P0       | 3            |
| S16-03 | Prepare privacy policy and terms of service pages                                  | Both     | P0       | 2            |
| S16-04 | Configure App Store subscription products in App Store Connect                     | iOS      | P0       | 2            |
| S16-05 | Configure Play Store subscription products in Play Console                         | Android  | P0       | 2            |
| S16-06 | Submit iOS app for review                                                          | iOS      | P0       | 1            |
| S16-07 | Submit Android app for review (handle SCHEDULE_EXACT_ALARM declaration)            | Android  | P0       | 2            |
| S16-08 | Set up Firebase Crashlytics monitoring + alerting                                  | Both     | P0       | 2            |
| S16-09 | Set up basic analytics (alarm created, tier conversion, retention)                 | Both     | P0       | 3            |
| S16-10 | Create OEM battery optimization knowledge base (Samsung, Xiaomi, Huawei, OnePlus)  | Android  | P0       | 3            |
| S16-11 | Final regression test — all tiers, all platforms                                   | Both     | P0       | 5            |
| S16-12 | Launch day monitoring plan (crash rates, ANRs, alarm reliability)                  | Both     | P0       | 1            |

**Sprint Total:** 29 SP  
**Definition of Done:** Both apps approved and live. Crashlytics active. Analytics tracking key funnel events. OEM battery guide accessible in-app.

---

## Phase 6 — Post-Launch (Sprint 17+)

### Sprint 17–18: V1.2 Iteration (Analytics-Driven)

| ID     | Task                                                              | Priority | Description                             |
| ------ | ----------------------------------------------------------------- | -------- | --------------------------------------- |
| S17-01 | Analyze conversion funnel (Free → Plus → Premium drop-off points) | P0       | Data-driven pricing/feature adjustments |
| S17-02 | Implement A/B testing for upgrade prompt copy and placement       | P1       | Optimize conversion                     |
| S17-03 | Address top crash reports and user feedback                       | P0       | Stability                               |
| S17-04 | Implement alarm sound customization (sound picker)                | P1       | Top user request (anticipated)          |
| S17-05 | Add relative date support ("Last Friday of the month")            | P1       | V2.0 feature, deferred from V1          |
| S17-06 | ~~Implement Siri Shortcuts integration~~                          | DONE     | Completed early in Sprint Siri+OneTime (ccce4d9) |
| S17-07 | Implement Google Assistant App Actions                            | P1       | Android voice equivalent                |
| S17-08 | Add quarterly and bi-annual interval options                      | P1       | User-requested intervals                |

### Sprint 19–20: V2.0 Planning

| ID     | Feature                                                  | Priority | Description                |
| ------ | -------------------------------------------------------- | -------- | -------------------------- |
| S19-01 | Voice control during alarm firing ("Stop" / "Snooze")    | P2       | Competitive differentiator |
| S19-02 | Smart alarm suggestions (ML-based time recommendations)  | P2       | Engagement feature         |
| S19-03 | Calendar integration (import recurring events as alarms) | P2       | Cross-app utility          |
| S19-04 | Apple Watch / Wear OS companion app                      | P2       | Platform extension         |
| S19-05 | Contextual wake-up messages (weather, calendar preview)  | P2       | Delight feature            |

### Sprint 21–22: Alexa Smart Speaker Integration (Premium)

**Goal:** Premium users can receive pre-alarm announcements on Alexa-enabled speakers.

| ID     | Task                                                                                          | Platform | Priority | Description                                                                                      |
| ------ | --------------------------------------------------------------------------------------------- | -------- | -------- | ------------------------------------------------------------------------------------------------ |
| S21-01 | Build Alexa Skill with account linking (OAuth via Firebase Auth)                              | Backend  | P0       | Alexa Skill that pairs a user's Alexa account with their Chronir account                         |
| S21-02 | Implement Cloud Function for pre-alarm → Alexa Proactive Events API                          | Backend  | P0       | When a pre-alarm fires, trigger a server-side call to announce on the user's linked Alexa device |
| S21-03 | Design and build Alexa linking UI in Settings (link/unlink, connection status)                | Both     | P0       | In-app settings for managing Alexa speaker connection                                            |
| S21-04 | Per-alarm speaker announcement toggle (opt-in on create/edit)                                 | Both     | P0       | Users choose which alarms announce on speakers                                                   |
| S21-05 | Implement TTS message templates ("Reminder: [alarm title] is due in [time]")                  | Backend  | P1       | Configurable announcement message format                                                         |
| S21-06 | Handle Alexa edge cases (device offline, skill disabled, token expiry)                        | Both     | P1       | Graceful fallback — phone notification still fires even if speaker fails                         |
| S21-07 | Submit Alexa Skill for Amazon certification                                                   | Backend  | P0       | Amazon reviews and certifies the skill for public availability                                   |
| S21-08 | End-to-end QA — pre-alarm → Cloud Function → Alexa announcement on physical device           | Both     | P0       | Validate full pipeline on real Echo/Alexa hardware                                               |

---

## Sprint Velocity & Capacity Summary

| Phase                     | Sprints        | Total Story Points | Avg SP/Sprint |
| ------------------------- | -------------- | ------------------ | ------------- |
| Phase 1 — Foundation      | 1–3            | 80                 | 27            |
| Phase 2 — Free Tier       | 4–7            | 113                | 28            |
| Phase 3 — Plus Tier       | 8–10           | 83                 | 28            |
| Phase 4 — Premium Tier    | 11–13          | 90                 | 30            |
| Phase 5 — Polish & Launch | 14–16          | 83                 | 28            |
| **Total V1.0 + V1.1**     | **16 sprints** | **449 SP**         | **28 avg**    |

---

## Risk Register

| Risk                                         | Impact | Mitigation                                                                              | Sprint Impact |
| -------------------------------------------- | ------ | --------------------------------------------------------------------------------------- | ------------- |
| AlarmKit API instability (iOS 26 beta)       | High   | Monitor Apple developer forums; fallback to UNNotification with time-sensitive category | Sprint 4–5    |
| OEM battery killers (Android)                | High   | In-app manufacturer-specific whitelisting guide; dontkillmyapp.com integration          | Sprint 7, 16  |
| App Store rejection (exact alarm permission) | Medium | Pre-submission technical review; clear alarm use case justification in review notes     | Sprint 16     |
| Firebase cost overrun (Premium tier)         | Medium | Set budget alerts; implement offline-first with lazy sync; optimize Firestore reads     | Sprint 10–13  |
| Low Free → Plus conversion                   | Medium | A/B test limit (2 vs 3 alarms); optimize upgrade prompt timing                          | Sprint 17–18  |
| Subscription platform compliance changes     | Low    | Abstract billing behind repository pattern; monitor StoreKit/Play Billing changelogs    | Ongoing       |

---

## Dependencies & Assumptions

**Dependencies:**

- iOS 26 SDK and AlarmKit availability (currently in beta)
- Firebase project provisioning and billing setup
- Apple Developer and Google Play Console accounts active
- Design assets (app icon, onboarding illustrations) — can be parallel workstream

**Assumptions:**

- Solo developer working full-time (velocity ~28 SP/sprint)
- 1-week sprint cadence with no extended breaks during 16-sprint window
- Design tokens finalized before Sprint 2 (no mid-build design pivots)
- Both platforms developed in parallel (iOS-first for each feature, Android follows within same sprint)

---

## Definition of Done (Global)

Every sprint deliverable must meet:

1. Feature works in both light and dark mode
2. Accessibility labels present on all interactive elements
3. Touch targets meet minimum size (44pt iOS / 48dp Android)
4. No hard-coded values — all styling through design tokens
5. SwiftUI Preview / Compose @Preview available for all new components
6. No compiler warnings or lint errors
7. Code reviewed (if team expands)
8. Manual QA pass on physical device (not just simulator/emulator)
