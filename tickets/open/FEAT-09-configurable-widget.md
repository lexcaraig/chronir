# FEAT-09: Configurable widget (pin an alarm or category)

**Priority:** P2
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** iOS
**Status:** Open
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
When editing a widget, a user can pick a specific alarm or category (e.g. "Car registration: 41 days"). The widget keeps tracking that choice instead of always showing the next alarm due.

## Acceptance Criteria
- [ ] Widgets move from `StaticConfiguration` to `AppIntentConfiguration`, with "Next alarm" as the default so existing widgets keep working
- [ ] Options: Next alarm (default) / specific alarm / category
- [ ] A pinned alarm that was deleted falls back to Next alarm and shows a short note
- [ ] Verified on device

## Depends on
FEAT-06

## Orchestration

**Agents:** `ios-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Pre-flight:** read `chronir/ChronirWidgets/`, `chronir/chronir/Core/Intents/`, `AlarmScheduler` (AE-02/AE-03)
**Post-flight:** swiftlint, `xcodebuild test`, on-device check on lexpresswayyy
