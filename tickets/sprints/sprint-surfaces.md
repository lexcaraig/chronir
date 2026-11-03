# Sprint: Surfaces & Depth

**Goal:** Make Chronir reachable from everywhere on the system (widgets with actions, controls, Spotlight, Siri, Quick Settings, watch) and deepen the long-cycle product (relative schedules, due windows, amounts, checklists, backup, localization, conversion).
**Branch:** `sprint-surfaces` (cut from `develop` = `main` @ 2026-11-03). One commit per ticket, local only — no push until Lex says.
**Status:** In Progress
**Decisions (Lex, 2026-11-03):** full watch apps; Claude translates es/pt-BR/de/fr/ja; tier per council; single branch, no push.

---

## Phase 1 — iOS system surfaces (no council; clear-cut)

| Ticket | Title | Status |
|--------|-------|--------|
| [FEAT-06](../untested/FEAT-06-widget-mark-done-intents.md) | AlarmEntity + Mark Done from widgets/Siri (foundation) | Untested (needs device check) |
| [FEAT-07](../untested/FEAT-07-control-center-controls.md) | Control Center / Lock Screen controls | Untested (needs device check) |
| [FEAT-08](../untested/FEAT-08-spotlight-indexing.md) | Spotlight indexing | Untested (needs device check) |
| [FEAT-09](../untested/FEAT-09-configurable-widget.md) | Configurable widget | Untested (needs device check) |
| [FEAT-10](../untested/FEAT-10-focus-filters.md) | Focus filters | Untested (needs device check) |
| [FEAT-11](../untested/FEAT-11-tipkit-discoverability.md) | TipKit hints | Untested (needs device check) |

## Phase 2 — Android surfaces (no council)

| Ticket | Title | Status |
|--------|-------|--------|
| [ANDROID-02](../open/ANDROID-02-glance-widget-actions.md) | Glance widget tap / Mark Done / list | Open |
| [ANDROID-03](../open/ANDROID-03-qs-tile-shortcuts.md) | Quick Settings tile + shortcuts | Open |

## Phase 3 — Long-cycle scheduling (DateCalculator, TEST-01)

| Ticket | Title | Status |
|--------|-------|--------|
| [FEAT-03](../open/FEAT-03-quarterly-biannual-intervals.md) | Quarterly / bi-annual intervals | Open |
| [FEAT-02](../open/FEAT-02-relative-date-scheduling.md) | Relative date scheduling | Open |

## Phase 4 — Data-model features (council each before build)

| Ticket | Title | Status |
|--------|-------|--------|
| [FEAT-12](../backlogs/FEAT-12-due-windows.md) | Due windows | Needs council |
| [FEAT-13](../backlogs/FEAT-13-bill-amount-spend-summary.md) | Amount + spend summary | Needs council |
| [FEAT-14](../backlogs/FEAT-14-alarm-checklist.md) | Checklist per alarm | Needs council |
| [FEAT-15](../backlogs/FEAT-15-local-backup-export.md) | Local backup export/import | Needs council |

## Phase 5 — Conversion & creation (council for tier)

| Ticket | Title | Status |
|--------|-------|--------|
| [FEAT-01](../backlogs/FEAT-01-live-activity.md) | Live Activity / Dynamic Island | Needs council (tier: Premium vs Plus) |
| [TIER-10](../backlogs/TIER-10-calendar-feed-export.md) | Calendar feed export | Needs council |
| [TIER-13](../backlogs/TIER-13-natural-language-creation.md) | Natural-language creation | Needs council |
| [TIER-16](../backlogs/TIER-16-free-trial.md) | Free trial | Needs council + Lex: ASC intro-offer setup |
| [TIER-17](../backlogs/TIER-17-contextual-upgrade-triggers.md) | Contextual upgrade triggers | Needs council |

## Phase 6 — Localization

| Ticket | Title | Status |
|--------|-------|--------|
| [FEAT-16](../open/FEAT-16-localization.md) | String extraction + 5 languages | Open (after Phases 1–5 so new strings are included) |

## Phase 7 — Watch (council)

| Ticket | Title | Status |
|--------|-------|--------|
| [FEAT-17](../backlogs/FEAT-17-apple-watch-app.md) | Apple Watch app + complications | Needs council |
| [ANDROID-04](../backlogs/ANDROID-04-wear-os-app.md) | Wear OS app + tile | Needs council |
