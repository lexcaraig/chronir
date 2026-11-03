# FEAT-02: Relative Date Scheduling

**Priority:** P2
**Category:** Feature
**Effort:** Medium (2 days)
**Platform:** iOS, Android
**Original Task:** S17-05

---

## Description

Support relative date patterns like "Last Friday of the month," "First Monday," "Third Wednesday." Currently monthly scheduling only supports fixed day-of-month. This enables more natural recurring patterns.

## Acceptance Criteria

- [ ] Monthly interval supports relative day selection:
  - First/Second/Third/Fourth/Last + Day of Week
  - Example: "Last Friday of every month"
- [ ] `DateCalculator` correctly computes next fire date for relative patterns
- [ ] UI: relative date picker in alarm creation (separate from day-of-month picker)
- [ ] Edge cases: "Fifth Monday" in months without one → skip to next month
- [ ] Tests for all combinations (see QA-01)

## References

- Roadmap: S17-05
- Competitor analysis: "Complex patterns like 'every 3rd Friday' require premium tiers in most competitors"
