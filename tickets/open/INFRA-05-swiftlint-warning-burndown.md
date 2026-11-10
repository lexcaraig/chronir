# INFRA-05: Burn down the 59 SwiftLint warnings so CI can run `--strict`

**Priority:** P2
**Category:** Infra
**Platform:** iOS
**Status:** Open

## Goal
`swiftlint lint` in `chronir/` reports 59 warnings (function_body_length, type_body_length, file_length, line_length, identifier_name, legacy_swiftui_aspect_ratio). The iOS CI lint step (INFRA-03) had to drop `--strict` to stay meaningful. Clear the warnings, then restore `--strict` in `.github/workflows/ios.yml`.

## Acceptance Criteria
- [ ] `cd chronir && swiftlint lint --strict` exits 0.
- [ ] `.github/workflows/ios.yml` lint step uses `--strict` again.
- [ ] No behaviour change: `xcodebuild test -only-testing:chronirTests -skip-testing:chronirTests/CompleteAlarmIntentTests` stays green.

## Notes
Split long functions/types rather than raising limits in `.swiftlint.yml`; raising a limit is only acceptable for generated token files.
