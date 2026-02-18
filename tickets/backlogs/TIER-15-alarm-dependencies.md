# TIER-15: Simple Alarm Dependencies (Task Chaining)

**Priority:** P3
**Tier Impact:** Plus
**Effort:** Medium (2-3 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Allow one alarm to trigger another after completion. "After I complete 'Buy air filter,' fire 'Change air filter' in 3 days." One level deep — not a project management tool. Just: completing Task A schedules Task B after a configurable delay.

The Homeowner persona buys a filter, then needs a reminder to install it. Two separate alarms miss the relationship; this chains them naturally.

## Acceptance Criteria

- [ ] In alarm creation/edit: "After completion, trigger another alarm" toggle
- [ ] When enabled, select:
  - Target alarm (picker from existing alarms) OR create a new alarm inline
  - Delay: immediately, 1 hour, 1 day, 3 days, 1 week
- [ ] On completion of the source alarm:
  - If target alarm is disabled, enable it and schedule with delay
  - If target alarm is already enabled, schedule an additional one-time occurrence at delay offset
- [ ] Dependency shown on alarm card: small chain icon + "Triggers: [target alarm title]"
- [ ] Target alarm card shows: "Triggered by: [source alarm title]"
- [ ] One level deep only — no chains of chains (A→B is allowed, A→B→C is not)
- [ ] Circular dependency prevention: A cannot trigger B if B already triggers A
- [ ] Plus feature
- [ ] If dependent alarm is deleted, remove the dependency link (don't break the source alarm)

## Technical Notes

- Add to Alarm model: `dependentAlarmId: UUID?` and `dependencyDelay: TimeInterval?`
- On completion handler: check if completed alarm has `dependentAlarmId`, if so, schedule/enable the target
- iOS: Handle in `AlarmCompletionService` or equivalent
- Android: Handle in `AlarmFiringService` completion flow
- UI: Alarm picker in creation form (filtered list of user's alarms, excluding self)
- Consider: what happens if the user skips (TIER-06) instead of completing? Should dependency still fire? Probably not — only on completion.

## Edge Cases

- Source alarm deleted: dependency link becomes orphaned — clean up
- Target alarm deleted: source alarm's `dependentAlarmId` should be nil'd
- Source alarm is recurring: dependency fires on EVERY completion (is this desired? Maybe make it configurable: "every time" vs "once")
