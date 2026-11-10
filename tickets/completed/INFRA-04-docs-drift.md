# INFRA-04: CHANGELOG and Firestore spec drift

**Priority:** P3
**Category:** Infra
**Platform:** Both
**Status:** Completed (docs only)

## Goal
`docs/CHANGELOG.md` lacks v1.2.2, v1.2.3, v1.2.4, v1.3.0-android. `docs/technical-spec.md` § 6.4 lists shared_alarms/groups/invites rules that are not deployed and has its own bugs; `firestore.rules` is the truth (FB-06).

## Acceptance Criteria
- [x] Four CHANGELOG entries backfilled from git tags.
- [x] § 6.4 quotes the live rules; Premium rules moved to a marked future subsection.

## Verification
Docs-only change, no device. Checked 2026-11-10: `git tag` dates match the four new CHANGELOG
headings; `docs/technical-spec.md` § 6.4 block is a byte-for-byte copy of `firestore.rules`
(generated from the file); Premium draft moved to § 6.4.1 with its three defects listed.
