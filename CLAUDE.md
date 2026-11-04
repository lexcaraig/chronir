# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow Orchestration

### 1. Plan Node Default

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution
- Always Run `/simplify` after every task

### 3.

Self-Improvement Loop

- After ANY correction from the user: update `tasks/lessons.md`
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project
  with the pattern

### 4. Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself:
  "Would a staff engineer approve this?"
- Run tests, check Logs, demonstrate correctness

### 5. Demand Elegance (Balanced)

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fizing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

All working artifacts live in `tasks/` (gitignored, project-scoped):

- **Plans**: `tasks/plan-{feature-or-ticket}.md` — implementation plans with checkable items
- **Lessons**: `tasks/lessons.md` — debugging rules and lessons learned
- **Notes**: `tasks/notes-{topic}.md` — ad-hoc research or working notes

Workflow:

1. **Plan First**: Write plan to `tasks/plan-{name}.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to the plan file
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes.
  Senior developer standards.
- **Minimat Impact**; Changes should only touch what's necessary. Avoid introducing bugs.

## Project Overview

Chronir is a high-persistence alarm app for long-cycle recurring tasks (weekly, monthly, annually). It treats long-term obligations with the urgency of a morning wake-up alarm — full-screen, persistent, undeniable.

**Status:** Foundation scaffolded. iOS (SwiftUI/SPM), Android (Jetpack Compose/Gradle multi-module), design token pipeline, Firebase project, and CI/CD workflows are in place. Sprint 1 implementation is next.

## Platform Strategy

Two **separate native apps** with no shared codebase. Identical information architecture, data models, and feature sets — but platform-specific UI and system integration.

| Platform | Language    | UI Framework    | Alarm API                    | Local DB  | Min Target |
| -------- | ----------- | --------------- | ---------------------------- | --------- | ---------- |
| iOS      | Swift 6+    | SwiftUI         | AlarmKit (iOS 26+)           | SwiftData | iOS 26     |
| Android  | Kotlin 2.0+ | Jetpack Compose | AlarmManager.setAlarmClock() | Room      | API 31     |

**Backend:** Firebase (Auth, Firestore, Cloud Storage, Crashlytics) — shared across both platforms.

## Architecture

### Pattern: MVVM + Repository

Both platforms use the same layered architecture:

- **View/Composable** → UI layer (stateless atoms/molecules, stateful pages)
- **ViewModel** → business logic, exposes state (iOS: `@Observable`; Android: `StateFlow`)
- **Repository** → abstracts local + remote data sources
- **Local storage** → SwiftData (iOS) / Room (Android) — source of truth for alarm scheduling
- **Remote** → Firestore (Plus/Premium tiers only)

Android uses **Hilt** for dependency injection.

### Design System: Atomic Design + Design Tokens

Three-tier token system (Primitive → Semantic → Component) defined in `design-tokens/tokens/`, processed via **Style Dictionary v5** (`design-tokens/config.js`) to generate platform-specific token files. Build: `cd design-tokens && npm run build`.

Component hierarchy: Tokens → Atoms → Molecules → Organisms → Templates → Pages.

iOS uses Liquid Glass (`.glassEffect()`); Android uses Material 3 + Dynamic Color. All design system components are prefixed with `Chronir` (e.g., `ChronirButton`, `ChronirText`, `ChronirBadge`).

### Project Structure

```
Chronir/
├── chronir/               # Xcode project (chronir.xcodeproj)
│   └── chronir/
│       ├── App/              # ChronirApp entry, Configuration (GoogleService-Info.plist)
│       ├── DesignSystem/     # Tokens, Atoms, Molecules, Organisms, Templates
│       ├── Features/         # AlarmList, AlarmDetail, AlarmCreation, AlarmFiring, Settings, Sharing, Paywall
│       ├── Core/             # Models, Services, Repositories, Utilities, Intents (App Intents/Siri)
│       └── Widgets/          # NextAlarmWidget, CountdownLiveActivity
├── Chronir-Android/       # Gradle multi-module (settings.gradle.kts)
│   ├── app/                  # Main app module (Hilt, Navigation, MainActivity)
│   ├── core/                 # designsystem, model, data, services modules
│   ├── feature/              # alarmlist, alarmdetail, alarmcreation, alarmfiring, settings, sharing, paywall
│   ├── widget/               # NextAlarmWidget (Glance)
│   └── gradle/libs.versions.toml  # Version catalog
├── design-tokens/            # Style Dictionary v5 pipeline
│   ├── tokens/               # Source JSON (color, spacing, radius, typography, animation)
│   ├── build/ios/            # Generated Swift token files
│   └── build/android/        # Generated Kotlin token files
├── tickets/                  # Ticket-first workflow system
│   ├── open/                   # Tickets ready for sprint
│   ├── in-progress/            # Actively being worked on
│   ├── untested/               # Done, pending QA
│   ├── completed/              # Done and verified
│   ├── backlogs/               # Not yet prioritized
│   └── sprints/                # Sprint definitions
├── .github/workflows/        # CI: ios.yml, android.yml, design-tokens.yml
├── firestore.rules           # Firestore security rules
└── docs/                     # Spec documents
```

Features are organized by screen: `AlarmList`, `AlarmDetail`, `AlarmCreation`, `AlarmFiring`, `Settings`, `Sharing`, `Paywall`.

### Data Flow

- **Local-first:** Alarms always fire from on-device storage. Cloud is secondary.
- **Sync:** Last-write-wins with device timestamp. Offline writes queue for Firestore auto-retry.
- **Tier-gated:** Free tier has no cloud entities. Plus unlocks cloud backup. Premium adds shared alarms and groups.

### Monetization Tiers

- **Free:** 3 alarms max (after TIER-03), local-only, basic features
- **Plus ($1.99/mo):** Unlimited alarms, photo attachments, custom snooze, pre-alarm warnings, completion history, streaks
- **Premium ($3.99/mo):** _(Not yet available — Phase 4, Sprint 11+)_ Shared alarms, groups, push notifications, Live Activities

## Test Devices

- **iOS:** Physical device "lexpresswayyy" (not simulator). To reset UserDefaults for re-testing onboarding, delete and reinstall the app on device.

## Build & CI

### iOS (Xcode Project)

```bash
cd chronir

# Lint
swiftlint

# Build (simulator)
xcodebuild build \
  -project chronir.xcodeproj \
  -scheme chronir \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES
```

### Android (Gradle multi-module)

```bash
cd Chronir-Android

# Lint
./gradlew ktlintCheck

# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest

# Build
./gradlew assembleRelease
```

### Design Tokens

```bash
cd design-tokens
npm run build    # Generates iOS Swift + Android Kotlin token files
```

### CI (GitHub Actions)

- `.github/workflows/ios.yml` — SwiftLint → tests → build (macOS 15, Xcode 16)
- `.github/workflows/android.yml` — ktlint → tests → build APK+AAB (JDK 17)
- `.github/workflows/design-tokens.yml` — Token build on `tokens/` changes

PR triggers lint + tests; merge to main triggers release build.

## Firebase

- **Project:** `cyclealarm-app` (ID: 410553847054)
- **iOS App:** `1:410553847054:ios:1d995526fac6a044ec5b5f` (bundle: `com.chronir.ios`)
- **Android App:** `1:410553847054:android:c6ad3cea467ca862ec5b5f` (package: `com.chronir.android`)
- **Firestore:** `(default)` database, region `nam5`
- **Security Rules:** `firestore.rules` (keep in sync with `docs/technical-spec.md` Section 6.4)
- **SDK configs:** `chronir/chronir/App/Configuration/GoogleService-Info.plist`, `Chronir-Android/app/google-services.json` (both gitignored)

## Critical Implementation Notes

- **Alarm scheduling is the #1 priority.** The alarm engine must be 100% reliable. Abstract it behind a protocol/interface for testability and to allow fallback if AlarmKit APIs change.
- **AlarmKit (iOS 26) is new.** Build with standard SwiftUI first, add `.glassEffect()` as progressive enhancement. Fallback to `UNNotificationRequest` if AlarmKit is unavailable.
- **AlarmKit `SecondaryButtonBehavior` only has `.countdown` and `.custom`** — no `.dismiss`. Non-persistent alarms have no secondary button and no countdown/paused presentation: a countdown presentation with nil `countdownDuration` is rejected as `invalidInput` (BUG-07). Always verify AlarmKit enum cases against the compiler before assuming a case exists.
- **Android OEM battery killers** are a known threat (Samsung, Xiaomi, Huawei, OnePlus, Oppo, Vivo). The app must detect manufacturer and surface battery optimization guidance.
- **DateCalculator is the most test-critical module.** Must handle: month-end overflow (e.g., 31st in Feb), leap years, DST transitions, timezone changes, relative schedules ("last Friday of month").
- **BootReceiver (Android)** must re-register all active alarms after device reboot.
- **Firestore security rules** are defined in `technical-spec.md` Section 6.4 — follow them exactly.
- **Deep links:** `chronir://alarm/{id}`, `chronir://invite/{code}`, `https://chronir.app/invite/{code}`
- Preview-driven development: every component needs Light/Dark + relevant state previews.
- **SwiftData new properties MUST have property-level defaults.** `var foo: Bool = false` (not just `init(foo: Bool = false)`). Init defaults are Swift constructs; property-level defaults are schema constructs that CoreData uses for lightweight migration. Without them, existing rows can't migrate and the app crashes on launch.
- **SQLite store is in the App Group container** (`group.com.chronir.shared`), not `URL.applicationSupportDirectory`. Any code that references the store path (recovery, backup, migration) must use the App Group URL.
- **New boolean flags must be cleared by ALL completion paths.** When adding a flag like `isPendingConfirmation` to a model, grep for every method that "completes" or "resets" the entity (`dismiss()`, `performDismiss()`, `completeIfNeeded()`, `handleLockScreenAction()`, etc.) and ensure they clear the new flag. Pre-existing paths won't know about the new flag unless explicitly updated. Also ensure that `autoCompletePending` (or equivalent cleanup) is called from ALL alarm presentation paths — not just the `alarmUpdates` handler which is skipped when `appIsInBackground` is true.

## Lessons Learned

All debugging rules and lessons are maintained in [`tasks/lessons.md`](tasks/lessons.md). These override any conflicting assumptions. Review before starting work on alarm engine, concurrency, or pre-launch tasks.

**IMPORTANT:** When a bug fix requires more than one attempt, or the user confirms a mistake was made that needed correction, automatically run `/learn-from-mistake` to capture the lesson in `tasks/lessons.md`. Do not wait to be asked — proactively trigger it whenever a confirmed mistake scenario is resolved.

## Spec Documents

All planning documents are in `docs/`:

- `docs/technical-spec.md` — **Primary reference.** Architecture, data models, alarm engine, state management, security, testing, build pipeline. Status: LOCKED.
- `docs/data-schema.md` — Entity definitions, Firestore collections, sync/conflict resolution, security rules
- `docs/design-system.md` — Design tokens, atomic components, screen specs, platform guidelines
- `docs/api-documentations.md` — Firebase API usage, auth flows, CRUD operations, error codes
- `docs/user-stories-and-backlogs.md` — Feature requirements and prioritization
- `docs/detailed-project-roaadmap.md` — Release timeline and milestones
- `docs/qa-plan.md` — Test strategy and quality criteria
- `docs/visual-guide.md` — Screen mockups and visual specifications
- `docs/market-and-competitor-analysis.md` — Competitive landscape and positioning
- `docs/user-persona.md` — Target user profiles and scenarios
- `docs/privacy-policy-and-tos.md` — Privacy policy and terms of service

When implementing a feature, cross-reference `docs/technical-spec.md` (architecture), `docs/data-schema.md` (data model), and `docs/design-system.md` (UI components).

## Ticket-First Workflow

**RULE: Nothing gets worked on without a ticket.** Before starting any task, feature, or bug fix:

1. **Check for existing ticket** — Search `tickets/` folders for a matching ticket
2. **Create if missing** — If no ticket exists, create one in `tickets/open/` (or `tickets/backlogs/` if not sprint-scoped)
3. **Move to in-progress** — When starting work, move the `.md` file to `tickets/in-progress/`
4. **Follow orchestration** — Each ticket specifies agents, commands, plugins, and pre/post-flight checks
5. **Move through lifecycle** — `in-progress/` → `untested/` (after commit) → `completed/` (after QA)

### Ticket Naming Convention

| Prefix       | Category                          |
| ------------ | --------------------------------- |
| `TIER-XX`    | Free/Plus tier improvements       |
| `LAUNCH-XX`  | iOS App Store launch tasks        |
| `QA-XX`      | Testing, profiling, accessibility |
| `FEAT-XX`    | New features                      |
| `ANDROID-XX` | Android platform work             |
| `PREMIUM-XX` | Premium tier (Phase 4)            |
| `BUG-XX`     | Bug fixes                         |
| `INFRA-XX`   | CI/CD, build, tooling             |

### Sprint Definitions

Sprint files live in `tickets/sprints/` and reference tickets by path. When a sprint starts:

1. Tickets move from `backlogs/` to `open/`
2. Sprint file tracks scope, phases, and status
3. `/sprint-kickoff` reads from the sprint file

See `tickets/README.md` for full documentation.

## Workflows (Custom Commands & Agents)

### Slash Commands

All commands live in `.claude/commands/`; heuristics in `.claude/skills/<name>/SKILL.md`. Run `/status` to see where you are.

**Core workflow**

| Command | Purpose |
| --- | --- |
| `/implement-task` | Main orchestrator — pick up a Chronir ticket, plan, implement (iOS/Android), test, review, simplify, commit, and… |
| `/implement-ios` | iOS-focused workflow — implement a feature in SwiftUI following Chronir conventions, then lint, test, review, simplify. |
| `/implement-android` | Android-focused workflow — implement a feature in Jetpack Compose following Chronir conventions, then lint, test… |
| `/sprint-kickoff` | Initialize a sprint — read the sprint file or roadmap, create the sprint branch from develop, build the task list… |
| `/phase-qa-gate` | Phase quality gate — lint, tests, release builds, security review, simplify audit, QA-plan cross-reference; moves… |
| `/create-ticket` | Turn a raw ask into a buildable Chronir ticket (TIER/LAUNCH/QA/FEAT/ANDROID/PREMIUM/BUG/INFRA) with Goal, acceptance… |
| `/test-ticket` | QA-verify an untested Chronir ticket — gate, acceptance criteria, on-device drive (iOS "lexpresswayyy" / Android… |
| `/clarify` | Pre-code clarification ritual for M+ tickets. Surfaces assumptions (data shape, tier gating, migration, alarm-engine… |
| `/plan-feature` | Plan a feature with the architect agent — scan both codebases, design per-platform file changes, alarm-engine and… |
| `/council` | Convene a multi-lens scoping council (iOS, Android, alarm engine, data/sync, design system, tier, QA) over a feature… |
| `/create-prd` | Create a Product Requirements Document for a Chronir feature (both platforms, tier placement, alarm-engine and data… |
| `/scaffold-feature` | Scaffold a new feature on iOS (Features/{Name}) and/or Android (feature/{name} module) following Chronir's MVVM +… |
| `/status` | Show the active ticket, sprint progress from tickets/ counts, release state, recent lessons, and a suggested next… |

**Quality gates**

| Command | Purpose |
| --- | --- |
| `/build-all` | Full quality gate across all Chronir build systems — design tokens, iOS (swiftlint + xcodebuild test), Android… |
| `/check-all` | Full pre-push verification — tokens, then iOS + Android gates in parallel, then the serial post-barrier gates… |
| `/lint` | Run swiftlint (iOS) and ktlintCheck (Android), auto-format first, and fix every remaining warning. |
| `/test` | Run the iOS (xcodebuild test) and Android (gradle test) unit suites and report results; device drives are a separate… |
| `/fix-tests` | Run the iOS and/or Android test suites, diagnose failures from the real artifacts, fix the cause (never the… |
| `/simplify` | Review recently changed Swift/Kotlin code for reuse, clarity and scope creep, fix what matters, and write the… |
| `/security-review` | Diff-scoped security review (auth, Firestore rules/sync, StoreKit/Play Billing gating, Keychain, secrets, local… |
| `/optimize-review` | Diff-scoped performance review (alarm scheduling loops, SwiftData/Room queries, main-thread work, list rendering… |
| `/precommit-review` | Run all three pre-commit review gates in one pass — simplify + security-review + optimize-review — and write all… |
| `/review` | Review the current diff with the code-reviewer agent against the active ticket's acceptance criteria, Chronir… |
| `/preflight` | Pre-submit preflight — swiftlint --strict, crash-risk and debug-print greps, placeholder/stub scan, and the… |
| `/pre-submit-audit` | App Store Review compliance audit — crash stubs, non-functional UI, paywall accuracy, debug visibility, permissions… |

**Audits**

| Command | Purpose |
| --- | --- |
| `/audit-all` | Run the 4 core audits in parallel (journeys, security, performance, tier-gating) via the audit-full workflow in core… |
| `/audit-full` | Run the FULL audit across every domain (journeys, security, performance, tier-gating, accessibility, dependencies… |
| `/audit-journeys` | Full user-journey audit with the journey-auditor agent — verify every story in docs/user-stories-and-backlogs.md and… |
| `/audit-security` | Full security audit with the security-auditor agent — Firebase Auth + Firestore rules, tier/entitlement enforcement… |
| `/audit-performance` | Full-codebase performance audit with the performance-auditor agent — alarm scheduling cost, SwiftData/Room queries… |
| `/audit-tier-gating` | Tier-gating audit — code + unit-test based check that Free (3 alarms, local-only) and Plus features are gated via… |
| `/audit-accessibility` | Full accessibility audit with the accessibility-auditor agent — VoiceOver/TalkBack labels, Dynamic Type/font… |
| `/audit-dependencies` | Full dependency and modernness audit with the dependency-auditor agent — SPM packages, Gradle version catalog… |
| `/audit-code-quality` | Full code-quality audit with the code-quality-auditor agent — convention adherence (CLAUDE.md, MVVM, Chronir*… |
| `/audit-animations` | Audit Chronir's motion posture (SwiftUI + Compose) against the motion-skill standards — ad-hoc values… |
| `/audit-methodology` | Print the audit methodology reference card — what each /audit-* checks, who owns it, severity rubric, the lesson… |
| `/adversarial-verify` | Adversarially verify a plan, ticket, doc, or diff with parallel lens attackers and an evidence-checked verifier… |

**Design**

| Command | Purpose |
| --- | --- |
| `/design-audit` | Design-system compliance audit (tokens, Chronir naming, atomic hierarchy, dark mode) for iOS and/or Android.… |
| `/design-review` | Full design pipeline — Chronir token audit + Impeccable critique → user approval → normalize → polish → re-audit. |
| `/design-mockup` | Generate or iterate the claude.ai/design mockup for a council-scoped ticket's Design section so the screen is… |
| `/sync-tokens` | Rebuild design tokens with Style Dictionary and copy the generated Swift/Kotlin files to both platforms, then verify… |

**Release & ops**

| Command | Purpose |
| --- | --- |
| `/release` | End-to-end Chronir release — version bump, gates, pre-submit audit, store metadata, docs, tag, archive + upload, asc… |
| `/deploy` | Deploy Firestore security rules to the cyclealarm-app Firebase project (the only deployable backend surface), with… |
| `/qa` | QA orchestration for Chronir — use-case inventory from docs/qa-plan.md, test matrix (persona × tier × platform)… |
| `/update-docs` | Update docs/, CLAUDE.md and README.md after completed work — CHANGELOG always, then a parallel fan-out over… |
| `/housekeeping` | Scan the repo for drift and stale artifacts — git hygiene, ticket folder/status mismatches, sprint links, orphan… |
| `/learn-from-mistake` | Capture a lesson from a mistake or multi-attempt fix — root cause, prevention rule — into tasks/lessons.md… |
| `/optimize-claude-setup` | Audit .claude/ (commands, skills, agents, workflows, hooks, routines), CLAUDE.md and auto-memory against… |
| `/sessions` | Multi-terminal session blackboard - view peers, update your status/note, clean stale files, or suggest… |
| `/say` | Post a message to the shared session chat channel (delivered to other terminals on their next turn) |

### Custom Agents

Defined in `.claude/agents/`; see `.claude/agents/README.md` for who spawns what. Worker agents (ios-developer, android-developer, alarm-engine-specialist, firebase-architect, design-system-builder) are read-and-inject: load the file into the prompt of a general-purpose agent.

| Agent | Specialty |
| --- | --- |
| `accessibility-auditor` | Accessibility auditor for Chronir — verifies the SwiftUI and Jetpack Compose apps meet WCAG 2.1 AA equivalents for… |
| `alarm-engine-specialist` | Alarm scheduling reliability specialist for Chronir — AlarmKit (iOS 26) + AlarmManager.setAlarmClock() (Android)… |
| `android-developer` | Android developer for Chronir — Jetpack Compose + Material 3, Kotlin 2 coroutines/Flow, Hilt, Room (contiguous… |
| `animation-auditor` | Motion/animation posture auditor for Chronir — holds every animated surface (SwiftUI… |
| `architect` | System architect for Chronir — designs data models (SwiftData + Room mirrored), Firestore collections/rules… |
| `code-quality-auditor` | Code quality auditor for Chronir — verifies convention adherence vs CLAUDE.md, .claude/rules/*, and… |
| `code-reviewer` | Chronir code review — correctness, alarm-reliability, concurrency, SwiftData/Room schema safety, tier gating… |
| `code-simplifier` | Simplifies recently-changed Chronir code (Swift/SwiftUI, Kotlin/Compose, token JSON) for clarity, consistency, and… |
| `dependency-auditor` | Dependency and modernness auditor for Chronir — checks the three dependency trees (iOS SPM Package.resolved, Android… |
| `design-system-builder` | Design-system and token specialist for Chronir — the Style Dictionary v5 pipeline in design-tokens/ (Primitive →… |
| `device-qa-driver` | On-device acceptance-QA driver for Chronir — drives a real installed build like a real user on the iOS physical… |
| `firebase-architect` | Firebase specialist for Chronir — Auth (anonymous → Apple/Google), Firestore schema per docs/data-schema.md… |
| `incident-investigator` | Production incident triage for Chronir. Gathers device-side evidence (Crashlytics, Xcode Console.app / `log stream`… |
| `ios-developer` | iOS developer for Chronir — SwiftUI, Swift 6 strict concurrency, AlarmKit (iOS 26) with UNNotification fallback… |
| `journey-auditor` | User journey auditor for Chronir — verifies the implementation faithfully covers every user story in… |
| `optimizer` | Diff-scoped performance/cost optimizer for Chronir. Reviews ONLY the staged/changed diff for the perf anti-patterns… |
| `performance-auditor` | Full-codebase performance auditor for Chronir — cold/warm start, alarm-list scroll at 60 items, SwiftUI/Compose… |
| `qa-engineer` | QA engineer for Chronir — test design + execution across iOS (XCTest/Swift Testing) and Android… |
| `release-shipper` | Release-pipeline specialist for Chronir — iOS App Store via xcodebuild archive → export/upload → asc release stage →… |
| `security-auditor` | Security auditor for Chronir — Firebase Auth state + Firestore rules vs docs/technical-spec.md § 6.4, tier gating… |
| `security-reviewer` | Diff-scoped Chronir security reviewer backing the /security-review and /precommit-review commit gate. Reviews ONLY… |
| `tier-gating-auditor` | Tier-gating auditor for Chronir — verifies every Free/Plus gate (3-alarm limit, photos, custom snooze, pre-alarm… |

### Hooks, Rules, Workflows

- **Hooks** (`.claude/hooks/`, wired in `.claude/settings.json`): commit gates (format → simplify → security → optimize → secrets), push gate (tests-before-push), ticket gates (untested/completion), design-token and Chronir*-naming nudges, silent-success guard. Bypass vars are `CHRONIR_<GATE>_BYPASS=1`; see `.claude/ARCHITECTURE.md`.
- **Rules** (`.claude/rules/`): the enforceable registry (alarm-engine, ios, android, firebase, design, components, security, testing, release, workflow).
- **Workflows** (`.claude/workflows/`): multi-agent scripts behind `/check-all`, `/preflight`, `/audit-full`, `/council`, `/adversarial-verify`, `/update-docs`, and the post-implement review.

### Plugins

| Plugin            | Purpose                                                                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `code-simplifier` | Runs after ANY code change via `/simplify`; the simplify commit gate requires its stamp (`tasks/.last-simplify-findings.json`).                |
| `impeccable`      | Frontend design quality toolkit (`/normalize`, `/polish`, `/critique`, `/audit`, `/harden`, …). Powers the fix/polish phases of `/design-review`. |

### Typical Sprint Flow

1. **Ticket-first:** Ensure all tasks have tickets in `tickets/open/` (or create them)
2. `/sprint-kickoff {N}` — Read sprint file from `tickets/sprints/`, create branch, build task list
3. `/implement-task {ticket-id}` — Move ticket to in-progress, implement, test, review, commit, move to untested
4. `/build-all` — Verify all platforms build after changes
5. `/phase-qa-gate {N}` — Run quality gate, move passing tickets to completed
6. When done: all sprint tickets should be in `tickets/completed/`

## Self-Learning Protocol

Claude Code maintains a persistent memory at `~/.claude/projects/.../memory/` that survives across conversations. This section defines how mistakes and lessons are captured to prevent recurrence.

### When to Record

Record a learning whenever:

- A build fails due to a preventable mistake
- A wrong assumption leads to wasted work (e.g., branching from the wrong base)
- A pattern or convention is discovered that isn't documented elsewhere
- A platform-specific gotcha is encountered (iOS/Android/Firebase quirks)
- A tool or command behaves unexpectedly
- A file/config is missed during a rename, migration, or refactor

### How to Record

1. **Immediate:** After encountering a mistake, write to `MEMORY.md` (auto-loaded into system prompt) with a concise entry
2. **Categorized:** For detailed notes, create topic-specific files (e.g., `ios-gotchas.md`, `build-issues.md`, `token-pipeline.md`) and link from `MEMORY.md`
3. **Format:** Each entry should include: what happened, why it happened, and how to prevent it

### Memory File Structure

```
~/.claude/projects/.../memory/
├── MEMORY.md              # Index file (auto-loaded, keep under 200 lines)
├── build-issues.md        # Build failures and fixes
├── platform-gotchas.md    # iOS/Android-specific traps
├── token-pipeline.md      # Design token generation lessons
└── conventions.md         # Project patterns and conventions discovered
```

### Rules

- Always check MEMORY.md at the start of a task for relevant prior learnings
- Update or remove entries that turn out to be wrong or outdated
- Keep MEMORY.md concise — detailed notes go in topic files
- Never duplicate information already in CLAUDE.md or spec docs — only record surprises and gotchas

---

Sandbox account:
lexpresswayyy@gmail.com
ABCTest123!

To test the full purchase flow, go to Settings > Subscription > Upgrade to Plus.

Sandbox subscriptions auto-renew every ~3 minutes and expire automatically, so both active and expired states can be observed within one review session.

---
