# FEAT-08: Spotlight search for alarms

**Priority:** P2
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** iOS
**Status:** Open
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
Searching for an alarm's title in iOS Spotlight finds it, and tapping the result opens that alarm's detail screen in Chronir.

## Acceptance Criteria
- [ ] `AlarmEntity` conforms to `IndexedEntity`; the index updates on create, edit and delete
- [ ] Deleted alarms leave the index (no stale entries after BUG-03 sync deletes)
- [ ] The Spotlight result opens the alarm's detail screen
- [ ] Index contents stay on device; no alarm content goes to logs (SEC-07)

## Depends on
FEAT-06

## Orchestration

**Agents:** `ios-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Pre-flight:** read `chronir/ChronirWidgets/`, `chronir/chronir/Core/Intents/`, `AlarmScheduler` (AE-02/AE-03)
**Post-flight:** swiftlint, `xcodebuild test`, on-device check on lexpresswayyy
