# LAUNCH-02: iOS App Store Submission

**Priority:** P0
**Category:** Launch
**Effort:** Low (half day)
**Platform:** iOS
**Original Task:** S16-06

---

## Description

Submit the iOS app for App Store review. Requires all quality gates passing, pre-submit audit clean, and listing complete.

## Acceptance Criteria

- [ ] `/pre-submit-audit` passes with zero blockers
- [ ] `/build-all` passes (iOS build green)
- [ ] Archive build uploaded to App Store Connect via Xcode (Product → Archive)
- [ ] Build selected for submission in ASC
- [ ] Review notes filled in (explain AlarmKit usage, DND bypass justification)
- [ ] What's New text pasted from release metadata
- [ ] Screenshots and preview uploaded
- [ ] Submit for review

## Dependencies

- LAUNCH-01 (listing preparation)
- LAUNCH-04 (regression test)
- QA-01 through QA-06 (recommended but not strictly blocking)

## Orchestration

**Commands:** `/pre-submit-audit`, `/build-all`, `/release`
**Agents:** `qa-engineer`
**Plugins:**
- `security-reviewer` — Final security scan before submission
- `code-reviewer` — Final code quality check

**Pre-flight:**
- [ ] All blocking tickets resolved (TIER-01, TIER-03 minimum)
- [ ] LAUNCH-01 complete (listing ready)
- [ ] LAUNCH-04 complete (regression test passed)
- [ ] `/pre-submit-audit` passes with zero blockers
- [ ] `/build-all` passes

**Post-flight:**
- [ ] Archive uploaded to App Store Connect
- [ ] Submitted for review
- [ ] Move ticket to `tickets/untested/` (moves to completed when approved)

## References

- Pre-submit audit: `/pre-submit-audit` command
- Release workflow: `/release` command
