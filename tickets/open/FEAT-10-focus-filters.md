# FEAT-10: Focus filters

**Priority:** P3
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** iOS
**Status:** Open
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
A user can set a Focus (e.g. Work) so that Chronir's alarm list and widgets show only the categories chosen for it. Alarms in hidden categories still fire. The filter only changes what's displayed.

## Acceptance Criteria
- [ ] `SetFocusFilterIntent` with a category multi-select
- [ ] The alarm list and widgets respect the active filter; a banner notes "Filtered by Focus"
- [ ] Scheduling and firing are unaffected (alarms in hidden categories still fire): FB-01, AE-02
- [ ] Verified on device by switching Focus

## Orchestration

**Agents:** `ios-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Pre-flight:** read `chronir/ChronirWidgets/`, `chronir/chronir/Core/Intents/`, `AlarmScheduler` (AE-02/AE-03)
**Post-flight:** swiftlint, `xcodebuild test`, on-device check on lexpresswayyy
