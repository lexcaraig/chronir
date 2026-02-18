# TIER-05: Extended Pre-Alarm Warnings (7-day, 3-day)

**Priority:** P1
**Tier Impact:** Plus
**Effort:** Low (1 day)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Extend the pre-alarm system beyond the current 24-hour warning to include 7-day and 3-day notifications. For annual tasks like "File taxes" or "Renew car registration," a 24-hour warning isn't enough — users need a week to gather documents or schedule service appointments. Already specced in US-2.2 but not implemented.

## Acceptance Criteria

- [ ] Multi-select pre-alarm offsets in alarm creation/edit: 7 days, 3 days, 1 day, 1 hour
- [ ] Each selected offset schedules its own `UNNotificationRequest` (iOS) / notification (Android)
- [ ] Notification content includes countdown context:
  - 7 days: "In 1 week: [alarm title]"
  - 3 days: "In 3 days: [alarm title]"
  - 1 day: "Tomorrow: [alarm title] at [time]" (existing)
  - 1 hour: "[alarm title] in 1 hour"
- [ ] Pre-alarm offsets stored on alarm model (array of intervals)
- [ ] Free tier: only 1-day pre-alarm available; 7d/3d/1h options show lock icon with "Plus" badge
- [ ] Tapping a locked option shows paywall
- [ ] Pre-alarms respect system DND (standard priority, not alarm-level)
- [ ] When alarm is rescheduled or deleted, cancel all associated pre-alarm notifications
- [ ] When alarm is snoozed, do NOT fire pre-alarms for the snoozed occurrence

## Technical Notes

- Existing 24h pre-alarm implementation: `preAlarmEnabled` field on `Alarm` model
- Extend to: `preAlarmOffsets: [TimeInterval]` (or equivalent enum array)
- iOS: Schedule multiple `UNNotificationRequest`s with different trigger dates
- Android: Schedule multiple notifications via `AlarmManager` or `WorkManager`
- Edge case: if alarm fires in less than 7 days, skip the 7-day pre-alarm (don't fire pre-alarm after the actual alarm)
- Remember: `UNUserNotificationCenter` requires separate authorization from AlarmKit (see MEMORY.md)

## Orchestration

**Command:** `/implement-task TIER-05`
**Agents:** `ios-developer`, `android-developer`, `alarm-engine-specialist`
**Plugins:**
- `code-reviewer` — Review notification scheduling logic
- `code-simplifier` — Simplify after implementation
- `test-writer-fixer` — Unit tests for pre-alarm scheduling edge cases

**Pre-flight:**
- [ ] Read existing pre-alarm implementation (`preAlarmEnabled`, `NotificationService.swift`)
- [ ] Read MEMORY.md: "AlarmKit and UNUserNotificationCenter have separate authorization"
- [ ] Verify notification permission handling

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Manual test: Set alarm with 7d/3d/1d pre-alarms → verify all fire
- [ ] Manual test: Free user → only 1d option available, rest locked
- [ ] Move ticket to `tickets/untested/`

## References

- Spec: US-2.2 (Extended Pre-Alarm Options)
- Existing implementation: `preAlarmEnabled` field, `NotificationService.swift`
