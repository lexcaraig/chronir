# Chronir Ticket System

## Ticket-First Workflow

**RULE: Nothing gets worked on without a ticket.** Before starting any task, feature, or bug fix:

1. Create a ticket in the appropriate folder
2. Reference it in the active sprint (if applicable)
3. Move it to `in-progress/` when work begins
4. Move it through the lifecycle as work progresses

This applies to all work — features, bug fixes, tier improvements, platform work, QA, and launch tasks.

## Folder Structure

```
tickets/
├── README.md              ← You are here
├── open/                  ← Tickets scoped for a sprint, ready to be picked up
├── in-progress/           ← Actively being worked on
├── untested/              ← Implementation done, pending QA
├── completed/             ← Done and verified
├── backlogs/              ← Not yet prioritized for a sprint
└── sprints/               ← Sprint definitions referencing tickets
```

## Ticket Lifecycle

```
backlogs/ → open/ → in-progress/ → untested/ → completed/
```

Move the `.md` file between folders to track status. Update the sprint file's relative paths when tickets move.

## Ticket Orchestration

Every ticket should include an **Orchestration** section specifying the agents, commands, skills, and hooks to use during implementation. This ensures consistent quality and tooling across all work.

### Standard Orchestration Fields

```markdown
## Orchestration

**Agents:** Which specialized agents to use
  - `ios-developer` — SwiftUI, AlarmKit, SwiftData
  - `android-developer` — Compose, AlarmManager, Room, Hilt
  - `alarm-engine-specialist` — DateCalculator, scheduling edge cases
  - `firebase-architect` — Auth, Firestore, cloud sync
  - `design-system-builder` — Tokens, atomic components
  - `qa-engineer` — Test strategy, QA plan cross-reference

**Commands:** Which slash commands to run
  - `/implement-task {ID}` — Full implementation lifecycle
  - `/build-all` — Cross-platform quality verification
  - `/phase-qa-gate {N}` — Phase-level quality gate
  - `/fix-tests {platform}` — Test failure diagnosis and fix
  - `/pre-submit-audit` — App Store compliance check
  - `/sync-tokens` — Rebuild design tokens

**Plugins:** Which plugins to invoke
  - `code-reviewer` — Post-implementation review
  - `code-simplifier` — Post-review simplification
  - `security-reviewer` — Security-sensitive tasks
  - `test-writer-fixer` — Test creation and fixing

**Hooks:** Relevant hooks
  - `post-commit-orchestrator` — Auto-suggests /build-all after commits
  - `check-component-exists` — Prevents duplicate component files

**Pre-flight checks:** What to verify before starting
**Post-flight checks:** What to verify after completing
```

## Naming Convention

`{PREFIX}-{NUMBER}-{short-description}.md`

| Prefix | Category |
|--------|----------|
| `TIER-XX` | Free/Plus tier improvements |
| `LAUNCH-XX` | iOS App Store launch tasks |
| `QA-XX` | Testing, profiling, accessibility |
| `FEAT-XX` | New features (post-launch) |
| `ANDROID-XX` | Android platform work |
| `PREMIUM-XX` | Premium tier (Phase 4, deferred) |
| `BUG-XX` | Bug fixes |
| `INFRA-XX` | CI/CD, build, tooling |

## Current Tickets

### Open (14)

**Tier Improvements:**
- TIER-01: Fix photo/note tier gating bug
- TIER-02: Cloud backup
- TIER-03: Bump free alarm limit to 3
- TIER-04: Alarm templates library
- TIER-05: Extended pre-alarms (7d/3d)
- TIER-06: Skip this occurrence
- TIER-07: Last completed date & streak badge
- TIER-08: Lifetime purchase option

**Launch:**
- LAUNCH-01: App Store listing preparation
- LAUNCH-02: iOS App Store submission
- LAUNCH-03: Analytics & crash reporting setup
- LAUNCH-04: Final regression test

**QA:**
- QA-01: Unit tests for alarm scheduling
- QA-02: Unit tests for subscription gating

### Backlogs (19)

**Tier Improvements:**
- TIER-09: Custom alarm sounds
- TIER-10: Calendar feed export
- TIER-11: Completion photo capture
- TIER-12: Overdue visual state
- TIER-13: Natural language creation
- TIER-14: Smart snooze suggestions
- TIER-15: Alarm dependencies
- TIER-16: 7-day free trial
- TIER-17: Contextual upgrade triggers
- TIER-18: Referral program

**QA:**
- QA-03: Performance profiling
- QA-04: Color-blind accessibility review

**Features:**
- FEAT-01: iOS Live Activity & Dynamic Island
- FEAT-02: Relative date scheduling
- FEAT-03: Quarterly & bi-annual intervals

**Android:**
- ANDROID-01: Android platform parity (umbrella)

**Premium (Deferred to Phase 4):**
- PREMIUM-01: Shared alarms & invitations
- PREMIUM-02: Groups & assignment
- PREMIUM-03: Cross-device sync & polish
