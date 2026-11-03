# FEAT-08: Spotlight search for alarms

**Priority:** P2
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** iOS
**Status:** Untested
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

## Verification
- `xcodebuild build` (iPhone 17 Pro sim, iOS 26.2): BUILD SUCCEEDED; swiftlint clean
- The index is rebuilt in `WidgetDataService.refresh()`, which runs after every create, edit, complete and delete, so deleted or disabled alarms drop out
- Tapping a Spotlight result runs `OpenAlarmIntent`, which opens `chronir://alarm/{id}` (UUID-validated in `onOpenURL`, and works when the app starts from closed)
- The index stays on device (CoreSpotlight); no alarm content is logged
- On-device check on lexpresswayyy: still to do (search an alarm's title in Spotlight, then tap the result to open its detail screen)
