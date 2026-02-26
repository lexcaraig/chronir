# FEAT-04: Completion Confirmation (Stop ≠ Done)

**Priority:** P1
**Category:** Feature
**Effort:** Large (4-5 days)
**Platform:** iOS (Android later)
**Tier:** Plus

---

## Description

Stopping an alarm only silences it — it does not mark the task as done. After stopping, the alarm enters a **Pending** state and follow-up notifications remind the user to confirm completion. The alarm stays Pending in the list until explicitly marked as done.

This is Chronir's core differentiator: every other alarm app treats "stop" as "done." Chronir doesn't let you forget.

**Core principle:** Stop = silence the noise. Done = "I actually completed the obligation."

## Alarm Lifecycle

```
Scheduled → Firing → [Snooze ↻] → Stopped (Pending) → Marked as Done
```

| Action                                                      | Behavior                                       |
| ----------------------------------------------------------- | ---------------------------------------------- |
| **Snooze**                                                  | "Not yet" — re-fires after delay               |
| **Stop** (any method: lock screen, in-app, hold to dismiss) | Silences sound. Alarm enters Pending state     |
| **Mark as Done** (from firing screen)                       | Confirms immediately. Skips Pending state      |
| **Mark as Done** (from notification or list)                | Confirms from Pending state. Alarm reschedules |

## Acceptance Criteria

- [ ] Stopping an alarm (lock screen, in-app stop) puts it in Pending state instead of completing it
- [ ] "Mark as Done" button on the firing screen still completes immediately (no Pending)
- [ ] Pending alarms show a distinct visual indicator in the alarm list
- [ ] Follow-up notification at +30 min: "Did you [alarm title]?" with Done / Remind Me actions
- [ ] Second notification at +60 min if not confirmed
- [ ] Final notification at +90 min if not confirmed
- [ ] After 3 notifications, no more follow-ups (alarm stays Pending in list until manual action)
- [ ] Tapping a Pending alarm in the list shows a "Mark as Done" action
- [ ] Marking done from notification action button works without opening the app
- [ ] Completion confirmation is Plus-tier only; Free tier retains current behavior (stop = done)
- [ ] Pending state persists across app restarts (stored in model)
- [ ] Pending alarms do NOT block the next scheduled occurrence from firing

## Tier Gating

- **Free:** Stop = Done (current behavior, no change)
- **Plus:** Stop = Pending → follow-up reminders → explicit Done required

## Technical Notes

### Model Changes

- Add `isPendingConfirmation: Bool` field to Alarm model (default `false`)
- Add `pendingSince: Date?` to track when Pending state began
- Pending state must persist in SwiftData (survives app kill/restart)

### Notification Scheduling

- On alarm stop (not "Mark as Done"): schedule 3 local notifications at +30, +60, +90 min
- Notification category with "Done" and "Remind Me" actions
- "Done" action handler: set `isPendingConfirmation = false`, complete alarm, reschedule
- "Remind Me" action: no-op (next scheduled notification will fire)
- Cancel remaining notifications when user marks done from any entry point

### Visual State

- New `AlarmVisualState.pending` case
- Pending accent color and badge (distinct from active/snoozed/disabled)
- Pending indicator in alarm list card

### Firing Screen Changes

- "Mark as Done" button = immediate completion (no Pending, current behavior)
- "Hold to Dismiss" / lock screen stop = enters Pending state
- These are two different code paths in AlarmFiringViewModel

### Edge Cases

- Alarm fires again (next occurrence) while previous is still Pending → complete the Pending one, fire new
- App killed while Pending → state persists in model, notifications already scheduled
- User disables alarm while Pending → clear Pending state
- Downgrade from Plus to Free while Pending → clear Pending, auto-complete

## Persona Impact

| Persona       | Tier    | Benefit                                                  |
| ------------- | ------- | -------------------------------------------------------- |
| Sarah Chen    | Free    | No change — simple stop = done                           |
| David Morales | Plus    | Never forgets household tasks mid-Saturday               |
| Priya Kapoor  | Plus    | Financial deadlines can't slip through                   |
| Tom Nguyen    | Plus    | Pet medication safety net — prevents missed/double doses |
| Maria & Jorge | Premium | Shared accountability with visible confirmation          |

## Dependencies

- None (builds on existing alarm lifecycle)

## Future Enhancements (not in scope)

- Escalation to full-screen re-fire if all 3 notifications ignored
- Photo proof of completion (TIER-11)
- Configurable follow-up intervals per alarm
- "Strict mode" that re-fires the full alarm instead of notifications

## Update QA Checklist

- docs/ios-free-tier-qa-checklist.md
- docs/ios-plus-tier-qa-checklist.md
