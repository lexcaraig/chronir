# INFRA-03: iOS CI can never fail

**Priority:** P1
**Category:** Infra
**Platform:** iOS
**Status:** Untested (needs one green CI run on push)

## Goal
`.github/workflows/ios.yml` selects Xcode 16 and an iPhone 16 simulator (cannot build an iOS 26 AlarmKit app) and ends the build in `| xcpretty || true`, so every push reports green. There is no test job, though CLAUDE.md says lint → tests → build.

## Acceptance Criteria
- [x] Xcode 26 selected on a macOS 26 runner, destination iPhone 17 Pro / OS 26.2 (IOS-10).
- [x] `|| true` removed; pipefail set; a failing build fails the job.
- [x] A test job runs `xcodebuild test` for the unit target.
- [x] CLAUDE.md § CI matches the workflow.
