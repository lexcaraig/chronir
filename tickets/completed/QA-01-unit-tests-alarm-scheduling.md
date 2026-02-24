# QA-01: Unit Tests for Alarm Scheduling Logic

**Priority:** P1
**Category:** QA
**Effort:** Medium (2 days)
**Platform:** iOS
**Original Task:** S15-04

---

## Description

Write comprehensive unit tests for `DateCalculator` and alarm scheduling logic. This is the most test-critical module per CLAUDE.md — it must handle month-end overflow, leap years, DST transitions, timezone changes, and relative schedules.

## Acceptance Criteria

- [ ] Test suite for `DateCalculator` with 80%+ coverage
- [ ] Weekly interval tests:
  - Next fire date for each day of week
  - Multiple days selected
  - Fire date when today IS the alarm day (should schedule for next week)
- [ ] Monthly interval tests:
  - Day 1-28: straightforward
  - Day 29: February in non-leap year → last day of Feb
  - Day 30: February → last day of Feb
  - Day 31: months with 30 days → fires on 30th
  - Relative: "last Friday of month", "first Monday"
- [ ] Annual interval tests:
  - Feb 29 in leap year → next leap year (or Feb 28)
  - Standard annual recurrence
- [ ] One-time alarm tests:
  - Fires once, no rescheduling
  - Past date handling
- [ ] Custom interval tests:
  - Every N days
  - Edge case: interval of 0 or negative
- [ ] DST transition tests:
  - Spring forward: alarm at 2:30 AM → fires correctly
  - Fall back: alarm at 1:30 AM → fires once, not twice
- [ ] Snooze rescheduling tests:
  - 9 min default
  - 1h, 1d, 1w custom snooze
  - Snooze near midnight boundary
- [ ] Skip occurrence tests (when TIER-06 ships):
  - Skip weekly → next week
  - Skip monthly → next month
  - Skip annual → next year

## Technical Notes

- iOS: XCTest in `chronir/chronirTests/`
- `DateCalculator` is the primary SUT
- Use fixed dates (not `Date()`) for deterministic tests
- Consider using `Calendar(identifier: .gregorian)` with fixed timezone for DST tests

## Orchestration

**Command:** `/implement-task QA-01` or `/fix-tests ios`
**Agents:** `alarm-engine-specialist`, `qa-engineer`, `ios-developer`
**Plugins:**
- `test-writer-fixer` — Primary: write and fix unit tests
- `code-reviewer` — Review test quality and coverage
- `context7` — Look up XCTest best practices if needed

**Pre-flight:**
- [ ] Read `DateCalculator.swift` — full implementation
- [ ] Read existing test files (if any) in `chronir/chronirTests/`
- [ ] Read CLAUDE.md lessons about DateCalculator edge cases

**Post-flight:**
- [ ] Run `/build-all` — tests pass
- [ ] Coverage report: 80%+ on `DateCalculator`
- [ ] Move ticket to `tickets/completed/` (tests are self-verifying)

## References

- CLAUDE.md: "DateCalculator is the most test-critical module"
- Roadmap: S15-04
