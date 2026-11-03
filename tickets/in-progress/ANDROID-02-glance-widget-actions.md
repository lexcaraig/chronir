# ANDROID-02: Glance widgets: tap, Mark Done, list + lock screen sizes

**Priority:** P1
**Category:** Feature
**Effort:** Medium (2-3 days)
**Platform:** Android
**Status:** In progress (code committed; device test pending: place both widgets)
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
Match the iOS widgets on Android: tapping the widget opens the alarm, a Mark Done button completes it in place, and there is a list widget for 3–5 alarms in addition to the next-alarm widget.

## Acceptance Criteria
- [ ] The existing `NextAlarmWidget` opens the alarm when tapped (deep link `chronir://alarm/{id}`)
- [ ] Mark Done uses `actionRunCallback` and the same completion path as the app; the next occurrence is registered via `setAlarmClock` (AE-12)
- [ ] A new list widget shows the next 3–5 alarms
- [ ] Widgets refresh when an alarm is created, edited, completed or deleted
- [ ] Tested on device via adb: complete from the widget, and the next occurrence still fires

## Orchestration

**Agents:** `android-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Post-flight:** `./gradlew ktlintCheck test assembleDebug`, adb device check
