# TIER-12: Overdue Visual State on Alarm Card

**Priority:** P2
**Tier Impact:** Free
**Effort:** Low (half day)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

When a user exhausts all snooze attempts (3x max) or an alarm's fire time has passed without completion, the alarm should enter a persistent "Overdue" visual state in the alarm list. Red accent, pinned to top, impossible to ignore. This reinforces Chronir's core promise: **it's impossible to forget.** A task you've been avoiding should feel like it's staring you down.

## Acceptance Criteria

- [ ] Alarm enters "Overdue" state when:
  - Fire time has passed AND alarm has not been completed or snoozed
  - Maximum snooze count (3) reached without completion
- [ ] Overdue visual treatment on alarm card:
  - Red accent border or background tint
  - "Overdue" badge/chip in destructive color
  - "Overdue since [date/time]" subtitle replaces countdown
  - Card sorted to TOP of alarm list (above upcoming alarms)
- [ ] Overdue alarms are NOT auto-rescheduled — they stay overdue until manually resolved
- [ ] Resolution options for overdue alarm:
  - "Mark as Done" — records late completion, reschedules next occurrence
  - "Skip" — skips this occurrence (TIER-06), reschedules next
- [ ] Overdue state persists across app launches (stored in model)
- [ ] If alarm was overdue and gets completed, completion record notes it was late
- [ ] Free tier feature — all users deserve to see when they've dropped the ball
- [ ] Overdue count badge on app icon (optional, respects notification settings)

## Technical Notes

- Add `isOverdue: Bool` computed property or `overdueAt: Date?` field to Alarm model
- Check on app launch and periodically: `if nextFireDate < now && completionAction == nil`
- iOS: Update alarm card styling with conditional modifiers
- Android: Update `AlarmCard` composable with conditional styling
- Sorting: overdue alarms sort before all others in the list query
- Consider: should overdue state trigger a local notification? "You have an overdue task: [title]"

## Design Notes

- Use `color.accent.destructive` for overdue accents
- Badge should be visually distinct from the cycle type badge (Weekly/Monthly/Annual)
- Overdue card should feel urgent but not hostile — firm, not punishing
