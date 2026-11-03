# QA-05: Impeccable design audit fixes, all screens, both platforms

**Priority:** P0
**Category:** QA / Design
**Effort:** Large
**Platform:** iOS + Android
**Status:** Untested (follow-ups committed 4162154, c41dccf, Android; one by-hand check listed under Evidence)
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
Fix every finding from the Impeccable v4.8.0 native audit (2026-11-03) across all screens, components, widgets and the paywall on iOS and Android. No emojis in UI; use SF Symbols / Material Symbols.

## Baseline scores (audit.native, /20)
| Area | Score |
|---|---|
| iOS core screens | 11 |
| iOS paywall / onboarding / settings / widgets | 11 |
| iOS design system | 11 |
| Android design system + widgets | 9 |
| Android screens | pending |

Reports: `/private/tmp/claude-501/-Users-lexcaraig-development-Chronir/f38bf2b4-1858-4181-ba22-e681083e3068/scratchpad/impeccable-*.md` (session scratchpad; key findings copied below as they're fixed).

## Acceptance Criteria
- [x] Token JSON is the single source; generated files are what the apps compile (DS-01); onPrimary, badge pairs, text-safe error/warning, firing-only, high-contrast roles exist
- [x] Android theme: no dark-only overrides on light dynamic schemes; dark primary/outline pass contrast; every M3 role defined
- [x] iOS text follows Dynamic Type; 11pt floor
- [x] All P0 and P1 findings fixed on both platforms; P2s fixed; P3s fixed or listed with a reason (per-fixer reports; deferred items listed below)
- [x] No emojis in UI (Android paywall feature rows now Material icons)
- [x] Builds, lint and unit tests green on both platforms
- [x] Device check: iOS lexpresswayyy + Android Nothing phone, light/dark/large text, screenshots in tickets/screenshots/QA-05/
- [x] Re-audit scores recorded

## Orchestration
**Agents:** design-system-builder, ios-developer, android-developer (read-and-inject), code-reviewer
**Commands:** /impeccable audit → fix → /precommit-review → commit per area

## Results (2026-11-04)

### Added during device QA
- Android FAQ / Privacy / Terms render natively in-app (Compose markdown renderer, `LegalDocumentScreen` + `MarkdownBlocks`), replacing the raw Gist WebView. Links limited to http/https/mailto.
- New platform-accurate FAQ bundled in each app: `chronir/chronir/Features/Settings/FAQ.md`, `Chronir-Android/feature/settings/src/main/assets/faq.md` (old Gist listed photos/Slide to Stop/cloud backup on Android and wrong snooze lengths).
- Android bottom bar gains a **New** (+) item with the same Free-tier pre-check as the list; the list FAB is removed.
- iOS `LabeledTextField` now exposes its label to VoiceOver (it only announced the placeholder).
- Android widgets follow the device 12/24-hour setting.

### Evidence
- Android (Nothing phone): `tickets/screenshots/QA-05/android/qa-05-01..47-*.png` — 14/14 device checks, settings fixes (40/41), in-app FAQ/Terms (42-44), bottom-bar New (45-47).
- iOS (lexpresswayyy): `tickets/screenshots/QA-05/ios/qa-05-ios-*.png` — dark, light and AX-Large text: alarm list, New Alarm, Settings, FAQ.
- iOS device tests: `CompleteAlarmIntentTests` 9/9, `SystemSurfacesUITests.testDeepLinkCreateAndSiriMarkDone` passed.
- iOS simulator unit suite (all other suites) passed; Android `ktlintCheck test assembleDebug` green.
- /precommit-review: simplify (3 fixed), security (0 critical/high), optimize (0 high-impact, 2 fixed).


## Follow-ups (2026-11-04, second pass)

### Re-audit (Impeccable audit.native, /20)
| Area | Baseline | After |
|---|---|---|
| iOS core screens | 11 | 15 |
| iOS paywall / onboarding / settings / widgets | 11 | 16 |
| iOS design system | 11 | 16 |
| Android design system + widgets | 9 | 17 |
| Android screens | 10 | 15 |
Report: session scratchpad `impeccable-reaudit.md`.

### Fixed
- iOS legal/FAQ renderer: text HTML-escaped before markdown, links limited to http/https/mailto, JavaScript off, tap handler re-checks the scheme.
- iOS switches use a new `toggleOn` token (dark mode no longer puts the white thumb on a light-grey track).
- Unused tokens removed (iOS alarm*, firingForeground, textDisabled/borderFocused/iconPrimary/iconSecondary, GlassTokens.sheetRadius); unused Android `organisms/AlarmCreationForm.kt` deleted.
- `DateCalculatorTests` type_body_length: scoped disable (one suite by design, TEST-01); swiftlint now 0 errors.
- Perf: AlarmSchedulingStatus writes only on real changes; AlarmListViewModel shares one Room flow; editor date formatter remembered.
- iOS: wallpaper scrims use `ColorTokens.scrim`; badge rows wrap at accessibility sizes; "won't ring" warnings persist across relaunch, the card shows "Not scheduled", and `reconcile()` drops warnings for alarms AlarmKit has registered via any path; circular lock-screen widget stays accurate in the last 24 h.
- iOS `LabeledTextField` names the field for VoiceOver.
- Android: stepper labels match behavior; bottom-bar New announces as a "Create alarm" button; editor screens pad for the keyboard (`imePadding` + `adjustResize`); compact widget 64dp so nothing clips; firing screen scrolls when it doesn't fit.

### Skipped, with reason
- iOS swipe-down on an edited sheet still just blocks (Cancel asks to discard). A delegate-proxy hook was tried and reverted: it depends on SwiftUI-owned presentation internals and didn't fire reliably on device.
- Google button official "G" mark: needs Google's brand asset from you.
- Paywall hero symbol, native `Form` rewrite, Android grouped settings plates, extra Glass previews, high-contrast values for onPrimary/surfaces/badges: design choices, not defects; worth a separate design ticket.

### Evidence (second pass)
- iPhone: `SystemSurfacesUITests` passed; leftover "Zeta Test" alarm removed; unedited sheet swipe closes.
- iOS simulator unit tests: 152 passed. Android `ktlintCheck test assembleDebug` green; New item exposes "Create alarm", clickable, not selectable (uiautomator).
- Keyboard over Note: Note is Plus-locked on the Free test account, so verified by build + review only.
- Observed under UI-test launches: AlarmKit refused a 5-day-out alarm and the new warning showed it. Needs a by-hand check in normal use (create an alarm by hand; it should not say "Not scheduled").
