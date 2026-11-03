# BUG-06: Plus users' manually disabled alarms are re-enabled on launch (iOS)

**Priority:** P1
**Category:** Bug
**Platform:** iOS
**Status:** Untested (device check with a Plus account pending)
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
`AlarmListView.enforceAlarmLimit()` re-enables every disabled active alarm for Plus users each time the subscription status check runs, so an alarm a Plus user turned off comes back on at launch. Found during QA-05 (Impeccable audit fixes); behavior was kept as-is there.

## Acceptance Criteria
- [x] Limit enforcement only re-enables alarms that the limit itself disabled (e.g. after a downgrade → resubscribe), never alarms the user turned off
- [x] Unit test for both cases
- [ ] Device check on lexpresswayyy: disable an alarm as Plus, relaunch, still disabled

## Fix (2026-11-04)
`AlarmLimitPolicy` records the IDs the Free limit disables (UserDefaults, no SwiftData change); on a paid tier only those are restored, then the record is cleared. `AlarmListView.enforceAlarmLimit()` uses it.

Tests (`SubscriptionGatingTests` / `AlarmLimitEnforcementTests`): `downgradeFreeTierDisablesNewestExcess`, `upgradeRestoresOnlyLimitDisabledAlarms`, `limitDisabledIDsRoundTrip` — all pass on the simulator.

Device check pending: needs a Plus (sandbox) account on lexpresswayyy.
