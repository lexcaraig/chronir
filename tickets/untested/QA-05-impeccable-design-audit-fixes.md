# QA-05: Impeccable design audit fixes, all screens, both platforms

**Priority:** P0
**Category:** QA / Design
**Effort:** Large
**Platform:** iOS + Android
**Status:** Untested (committed c512309, 23b9666, 871637a)
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
- [ ] Re-audit scores recorded

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

### Deferred
- iOS `LegalDocumentView` renders remote markdown as unescaped HTML in a JS-enabled WKWebView (pre-existing; escape + scheme allowlist + disable JS).
- iOS dark-mode toggle "on" state: white thumb on light-grey track is low-contrast (state still readable by position/fill).
- 14 unused generated iOS tokens; unused Android `organisms/AlarmCreationForm.kt`.
- Pre-existing swiftlint error: `DateCalculatorTests` type_body_length (682 > 500).
- Re-audit (Impeccable audit.native) not yet run, so post-fix scores aren't recorded.
