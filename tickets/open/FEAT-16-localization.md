# FEAT-16: Localization: string extraction + es, pt-BR, de, fr, ja

**Priority:** P2
**Category:** Feature
**Effort:** High
**Platform:** iOS, Android
**Status:** Open
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
The app is fully translated into Spanish, Brazilian Portuguese, German, French and Japanese on both platforms. No hard-coded user-facing text remains, and dates and numbers follow the device locale.

## Acceptance Criteria
- [ ] iOS: `Localizable.xcstrings` string catalog; all user-facing text moved into it (views, intents, widgets, notifications, AlarmKit titles)
- [ ] Android: every string in `strings.xml` and `values-{es,pt-rBR,de,fr,ja}/`
- [ ] Plurals handled (e.g. "in 1 day" / "in 3 days")
- [ ] Dates and times use locale-aware formatters; DateCalculator is untouched
- [ ] Translations written by Claude; App Store metadata flagged for native-speaker review
- [ ] Pseudo-locale / long-string check for truncation; screenshots in de and ja

## Orchestration
`ios-developer` + `android-developer`; run `break-ui` for text truncation.
