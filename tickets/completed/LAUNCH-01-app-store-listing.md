# LAUNCH-01: App Store Listing Preparation

**Priority:** P0
**Category:** Launch
**Effort:** Medium (1-2 days)
**Platform:** iOS
**Original Task:** S16-01

---

## Description

Prepare complete App Store listing with screenshots, description, keywords, and preview video. Current screenshots in `docs/appstoreconnect/screenshots/v1/` may be outdated.

## Acceptance Criteria

- [ ] 5-8 screenshots per device size (6.7", 6.1") showing key flows:
  - Home screen with alarms
  - Alarm creation flow
  - Alarm firing (full screen)
  - Completion history (Plus)
  - Settings
  - Widget on home/lock screen
- [ ] App preview video (30 seconds): alarm creation → firing → dismiss cycle
- [ ] Description: keyword-optimized, benefit-led copy (update `docs/appstoreconnect/listing.md`)
- [ ] Keywords field populated (100 char limit)
- [ ] Categories: Productivity (primary), Utilities (secondary)
- [ ] Privacy nutrition labels completed accurately
- [ ] Support URL: https://github.com/anthropics/claude-code/issues (or project-specific)
- [ ] Age rating configured
- [ ] App preview localized (English initially)

## Orchestration

**Command:** `/release` (Step 6 generates metadata)
**Agents:** None (manual/creative task)
**Plugins:**
- `code-reviewer` — Review listing copy for accuracy vs actual features

**Pre-flight:**
- [ ] Read `docs/appstoreconnect/listing.md` for current state
- [ ] Run app on physical device to capture fresh screenshots
- [ ] Verify all features mentioned in listing actually exist

**Post-flight:**
- [ ] All screenshot sizes captured
- [ ] Listing copy reviewed for accuracy (no promises of unbuilt features — per MEMORY.md)
- [ ] Move ticket to `tickets/untested/`

## References

- Current listing: `docs/appstoreconnect/listing.md`
- Screenshots: `docs/appstoreconnect/screenshots/v1/`
- Roadmap: S16-01
