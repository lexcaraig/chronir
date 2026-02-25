# QA-03: Performance Profiling (Cold Start & UI)

**Priority:** P2
**Category:** QA
**Effort:** Low (half day)
**Platform:** iOS
**Original Tasks:** S15-07, S15-08, S15-09

---

## Description

Profile app cold start time (target <2s), memory usage on firing screen (no leaks during extended ring), and battery impact from background alarm scheduling.

## Acceptance Criteria

- [ ] Cold start time measured via Instruments: target <2 seconds
- [ ] Firing screen memory profiling: no leaks during 5-minute ring
- [ ] Battery impact: background scheduling uses minimal CPU
- [ ] Report findings with screenshots from Instruments
- [ ] Fix any issues found (memory leaks, slow startup, excessive background activity)
- [ ] Re-profile after fixes

## References

- Roadmap: S15-07, S15-08, S15-09
