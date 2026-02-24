# LAUNCH-03: Analytics & Crash Reporting Setup

**Priority:** P1
**Category:** Launch
**Effort:** Medium (1-2 days)
**Platform:** iOS (Android deferred)
**Original Tasks:** S16-08, S16-09

---

## Description

Set up basic analytics event tracking and crash reporting. Firebase Crashlytics is already integrated (SDK in project) but may not be fully configured. Analytics events needed to measure retention, conversion, and feature usage.

## Acceptance Criteria

### Crashlytics
- [ ] Firebase Crashlytics SDK initialized in `ChronirApp`
- [ ] Crash reports flowing to Firebase Console
- [ ] dSYM upload configured (manual or automatic via build phase)
- [ ] Non-fatal error logging for critical paths (alarm scheduling failures, subscription errors)
- [ ] User ID set on Crashlytics after Plus sign-in (when cloud backup ships)

### Analytics Events
- [ ] Event tracking for key funnel events:
  - `alarm_created` (properties: interval_type, category, tier)
  - `alarm_fired` (properties: interval_type, snooze_count)
  - `alarm_completed` (properties: time_to_complete, was_snoozed)
  - `alarm_snoozed` (properties: snooze_type)
  - `alarm_skipped` (when TIER-06 ships)
  - `alarm_deleted`
  - `upgrade_prompt_shown` (properties: trigger_point)
  - `upgrade_completed` (properties: plan, price)
  - `onboarding_completed`
- [ ] No PII in analytics payloads (no alarm titles, no notes)
- [ ] Analytics respects user preference / ATT framework on iOS
- [ ] Privacy-respecting: consider TelemetryDeck as alternative to Firebase Analytics

## Technical Notes

- Firebase already configured: project `cyclealarm-app`
- `GoogleService-Info.plist` exists (gitignored)
- Consider using TelemetryDeck for privacy-first analytics (no PII, EU-hosted)
- Analytics events should be centralized in an `AnalyticsService` protocol

## Orchestration

**Command:** `/implement-task LAUNCH-03`
**Agents:** `ios-developer`, `firebase-architect`
**Plugins:**
- `firebase` MCP — Verify Crashlytics config, check Firebase project
- `code-reviewer` — Review analytics implementation for PII leakage
- `code-simplifier` — Simplify after implementation
- `security-reviewer` — Verify no PII in analytics payloads
- `context7` — Look up Firebase Crashlytics / TelemetryDeck SDK docs

**Pre-flight:**
- [ ] Check Firebase project config in console
- [ ] Read existing `GoogleService-Info.plist` integration
- [ ] Decide: Firebase Analytics vs TelemetryDeck

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Verify crash report appears in Firebase Console (trigger test crash)
- [ ] Verify analytics events logged (use debug view)
- [ ] Move ticket to `tickets/untested/`

## References

- Roadmap: S16-08, S16-09
- User stories: US-13.1
