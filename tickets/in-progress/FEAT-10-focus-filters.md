# FEAT-10: Focus filters

**Priority:** P3
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** iOS
**Status:** In Progress
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

## Implementation Notes
- `ChronirFocusFilter` (`SetFocusFilterIntent`) saves the chosen categories in App Group UserDefaults (`FocusFilterStore`). When the Focus turns off, the system calls it with nil, which clears the filter.
- The filter only changes what's displayed. It applies in `AlarmListView.filteredAlarms` and `WidgetDataReader.loadAlarms`, never in `activeAlarms`, which `enforceAlarmLimit()` and the paywall count read. Filtering there would have disabled alarms in hidden categories. Scheduling never reads the filter.
- Uncategorized alarms are hidden while a filter is active. The list shows a "Filtered by Focus" row.
- The category App Enum moved to the shared `AlarmCategoryAppEnum.swift` (app and widget), replacing the widget-only copy from FEAT-09.

## Verification
- `xcodebuild build` (iPhone 17 Pro sim, iOS 26.2): BUILD SUCCEEDED
- On-device check on lexpresswayyy: still to do (Settings → Focus → Work → Add Filter → Chronir → pick Work; turn the Focus on, check the list and widgets show only Work alarms, and that an alarm in a hidden category still fires)
