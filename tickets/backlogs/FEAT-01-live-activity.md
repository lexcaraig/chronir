# FEAT-01: iOS Live Activity & Dynamic Island Countdown

**Priority:** P2
**Category:** Feature
**Effort:** Medium (2-3 days)
**Platform:** iOS
**Original Task:** S15-03

---

## Description

Show a Live Activity on the lock screen and Dynamic Island with countdown to the next imminent alarm. Starts when next alarm is within 24 hours, ends when alarm fires or is dismissed.

## Acceptance Criteria

- [ ] Live Activity starts when next alarm is within 24 hours
- [ ] Lock screen: alarm title + countdown timer (live updating)
- [ ] Dynamic Island (compact): countdown timer
- [ ] Dynamic Island (expanded): title + countdown + interval badge
- [ ] Live Activity ends when alarm fires or is dismissed
- [ ] User preference to disable Live Activities in Settings
- [ ] ActivityKit integration with `ActivityAttributes` and `ContentState`
- [ ] Widget and Live Activity share data via App Group

## Technical Notes

- iOS 16.1+ for Live Activities
- ActivityKit framework
- Shared App Group with WidgetKit extension
- Timer-based countdown using `.timer` date style

## References

- Roadmap: S15-03
- User stories: US-11.3
