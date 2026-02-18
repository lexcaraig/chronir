# LAUNCH-04: Final Regression Test

**Priority:** P0
**Category:** Launch
**Effort:** Medium (1 day)
**Platform:** iOS
**Original Task:** S16-11

---

## Description

Full end-to-end regression test of all user journeys on physical device before App Store submission. Must cover Free and Plus tiers, all alarm intervals, firing, snooze, completion, settings, onboarding, and widgets.

## Acceptance Criteria

### Free Tier Journeys
- [ ] Onboarding: first launch → permission requests → create first alarm
- [ ] Create 3 alarms (weekly, monthly, annual) → verify all fire correctly
- [ ] 4th alarm creation → paywall shown
- [ ] Edit alarm → save → verify rescheduled
- [ ] Delete alarm → confirm → verify removed
- [ ] Toggle alarm off/on → verify schedule updates
- [ ] Alarm fires on lock screen → slide to stop → auto-reschedule
- [ ] Snooze (9 min default) → verify re-fire
- [ ] Widget shows correct next alarm
- [ ] Pre-alarm notification fires 24h before
- [ ] App kill + alarm fire → verify alarm still fires
- [ ] Device reboot → verify alarms survive

### Plus Tier Journeys
- [ ] Purchase Plus (sandbox) → verify unlimited alarms
- [ ] Custom snooze (1h, 1d, 1w) → verify reschedule
- [ ] Completion history → verify entries
- [ ] Category grouping → verify sections
- [ ] Category filters → verify filtering
- [ ] Subscription expiry → verify 3-alarm limit re-enforced
- [ ] Restore purchases → verify entitlement

### Edge Cases
- [ ] Month-end overflow: alarm on 31st → fires on Feb 28/29
- [ ] Leap year: annual alarm on Feb 29
- [ ] Timezone change: verify alarms adjust
- [ ] DND mode: verify alarm bypasses
- [ ] Low battery: verify alarm fires
- [ ] Siri: "Create an alarm in Chronir" → verify intent works
- [ ] Deep link: `chronir://alarm/{id}` → opens correct alarm

## Test Device

- Physical device "lexpresswayyy" (not simulator)
- Reset UserDefaults by deleting and reinstalling app for onboarding test

## Dependencies

- All blocking tickets resolved
- Build passes (`/build-all`)

## Orchestration

**Commands:** `/build-all`, `/phase-qa-gate`, `/pre-submit-audit`
**Agents:** `qa-engineer`, `alarm-engine-specialist`
**Plugins:**
- `code-reviewer` — Final code quality sweep
- `security-reviewer` — Final security sweep

**Pre-flight:**
- [ ] All open tickets for this sprint are in `untested/` or `completed/`
- [ ] `/build-all` passes
- [ ] Physical device "lexpresswayyy" available

**Post-flight:**
- [ ] All test cases pass on physical device
- [ ] QA checklist signed off
- [ ] Move ticket to `tickets/completed/`

## References

- QA checklists: `docs/ios-free-tier-qa-checklist.md`, `docs/ios-plus-tier-qa-checklist.md`
- Roadmap: S16-11
