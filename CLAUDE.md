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

# Build: see IOS-10 in .claude/rules/ios.md for the simulator name and required flags
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

### Commands and Agents

Commands live in `.claude/commands/` (heuristics in `.claude/skills/<name>/SKILL.md`); run `/status` to see where you are. Agents are in `.claude/agents/`; see `.claude/agents/README.md` for who spawns what. Worker agents (ios-developer, android-developer, alarm-engine-specialist, firebase-architect, design-system-builder) are read-and-inject: load the file into the prompt of a general-purpose agent.

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
