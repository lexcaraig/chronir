# TIER-10: Calendar Feed Export (iCal Subscription)

**Priority:** P2
**Tier Impact:** Plus
**Effort:** Medium (2 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Generate a subscribable `.ics` calendar feed that shows Chronir alarms as read-only events in Apple Calendar, Google Calendar, or any CalDAV client. The alarm still fires from Chronir — the calendar just provides awareness alongside the user's daily schedule. No competitor offers this for alarm apps, making it a unique differentiator.

## Acceptance Criteria

- [ ] "Add to Calendar" option in Settings (Plus only)
- [ ] Generate `.ics` file containing all active alarms as recurring `VEVENT` entries
- [ ] Calendar events show: alarm title, interval description in notes, time
- [ ] Events marked as read-only / free (not busy) to avoid blocking calendar time
- [ ] Two export modes:
  - **One-time export:** Download `.ics` file, import manually into calendar app
  - **Subscription URL:** If cloud backup is enabled, generate a hosted `.ics` URL that auto-updates (requires TIER-02)
- [ ] When alarms change (create/edit/delete), regenerate the `.ics` file
- [ ] Share via system share sheet or copy URL to clipboard
- [ ] Free tier: option visible but locked behind paywall
- [ ] Calendar events include Chronir deep link in notes: `chronir://alarm/{id}`

## Technical Notes

- `.ics` format: RFC 5545 compliant `VCALENDAR` with `VEVENT` entries
- Recurrence rules: map Chronir intervals to `RRULE` (e.g., monthly → `FREQ=MONTHLY;BYMONTHDAY=1`)
- iOS: Use `EventKit` for direct calendar integration, or generate `.ics` file for export
- Android: Generate `.ics` file, share via intent; or use Calendar Provider for direct integration
- Subscription URL requires a server endpoint — depends on cloud backup (TIER-02) being implemented
- Without cloud backup: only one-time export is available

## Dependencies

- Subscription URL mode depends on TIER-02 (Cloud Backup)
- One-time export can ship independently

## Edge Cases

- Annual alarms: `RRULE=FREQ=YEARLY;BYMONTH=3;BYMONTHDAY=15`
- Custom-day intervals: may not map cleanly to `RRULE` — use individual `VEVENT` entries
- One-time alarms: single `VEVENT` with no `RRULE`
