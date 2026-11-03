# BUG-06: Plus users' manually disabled alarms are re-enabled on launch (iOS)

**Priority:** P1
**Category:** Bug
**Platform:** iOS
**Status:** Open
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
`AlarmListView.enforceAlarmLimit()` re-enables every disabled active alarm for Plus users each time the subscription status check runs, so an alarm a Plus user turned off comes back on at launch. Found during QA-05 (Impeccable audit fixes); behavior was kept as-is there.

## Acceptance Criteria
- [ ] Limit enforcement only re-enables alarms that the limit itself disabled (e.g. after a downgrade → resubscribe), never alarms the user turned off
- [ ] Unit test for both cases
- [ ] Device check on lexpresswayyy: disable an alarm as Plus, relaunch, still disabled
