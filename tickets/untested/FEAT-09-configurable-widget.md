# FEAT-09: Configurable widget (pin an alarm or category)

**Priority:** P2
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** iOS
**Status:** Untested
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

## Implementation Notes
- The Next Alarm widget (small, circular, inline) uses `AppIntentConfiguration` with `NextAlarmConfigurationIntent`, offering an optional alarm or category. It keeps the same `kind`, so widgets already placed default to "next alarm".
- Found along the way: `WidgetDataService` always wrote `nil` for the category, so widgets never showed category colors or icons. `AlarmSummary` now carries the category. This was needed for category pinning and also fixes the colors.
- A pinned alarm that was deleted or disabled falls back to the next alarm, with a "Pinned alarm removed" note on the small widget.
- Out of scope: the list widget (medium/rectangular) stays a static configuration.

## Verification
- `xcodebuild build` + `xcodebuild test -only-testing:chronirTests` (iPhone 17 Pro sim, iOS 26.2): BUILD SUCCEEDED, TEST SUCCEEDED; swiftlint clean
- On-device check on lexpresswayyy: still to do (long-press widget → Edit Widget → pick an alarm or category; delete the pinned alarm and check it falls back)
