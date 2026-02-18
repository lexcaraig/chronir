# Sprint: Tier Improvements

**Goal:** Strengthen Free and Plus tier value propositions — fix gating bugs, add high-impact features, improve conversion.
**Branch:** `sprint-tier-improvements`
**Status:** QA Gate Passed

---

## Sprint Scope

### Phase A — Quick Wins (Days 1-2)

| Ticket | Title | Tier | Effort | Status |
|--------|-------|------|--------|--------|
| [TIER-01](../completed/TIER-01-fix-photo-note-gating.md) | Fix photo/note tier gating bug | Free→Plus | Low | **Completed** |
| [TIER-03](../completed/TIER-03-bump-free-alarm-limit.md) | Bump free alarm limit to 3 | Free | Trivial | **Completed** |
| [TIER-07](../completed/TIER-07-last-completed-streak-badge.md) | Last completed date & streak badge | Free/Plus | Low | **QA Passed** |
| [TIER-12](../completed/TIER-12-overdue-visual-state.md) | Overdue visual state | Free | Low | **QA Passed** |

### Phase B — Core Plus Features (Days 3-5)

| Ticket | Title | Tier | Effort | Status |
|--------|-------|------|--------|--------|
| [TIER-05](../completed/TIER-05-extended-pre-alarms.md) | Extended pre-alarms (7d/3d) | Plus | Low | **QA Passed** |
| [TIER-06](../completed/TIER-06-skip-occurrence.md) | Skip this occurrence | Free | Low | **QA Passed** |
| [TIER-08](../completed/TIER-08-lifetime-purchase.md) | Lifetime purchase option | Pricing | Low | **QA Passed** |

### Phase C — High-Value Features (Days 6-10)

| Ticket | Title | Tier | Effort | Status |
|--------|-------|------|--------|--------|
| [TIER-04](../completed/TIER-04-alarm-templates.md) | Alarm templates library | Plus | Medium | **QA Passed** |
| [TIER-09](../completed/TIER-09-custom-alarm-sounds.md) | Custom alarm sounds | Plus | Medium | **QA Passed** |

### Phase D — Cloud Backbone (Days 11-18)

| Ticket | Title | Tier | Effort | Status |
|--------|-------|------|--------|--------|
| [TIER-02](../untested/TIER-02-cloud-backup.md) | Cloud backup | Plus | High | **Untested** |

### Deferred to Next Sprint

| Ticket | Title | Tier | Effort | Reason |
|--------|-------|------|--------|--------|
| [TIER-10](../backlogs/TIER-10-calendar-feed-export.md) | Calendar feed export | Plus | Medium | Depends on TIER-02 for subscription URL |
| [TIER-11](../backlogs/TIER-11-completion-photo-capture.md) | Completion photo capture | Plus | Medium | Nice-to-have, not blocking |
| [TIER-13](../backlogs/TIER-13-natural-language-creation.md) | Natural language creation | Plus | High | R&D effort, defer to post-launch |
| [TIER-14](../backlogs/TIER-14-smart-snooze-suggestions.md) | Smart snooze suggestions | Plus | Medium | Needs completion history data maturity |
| [TIER-15](../backlogs/TIER-15-alarm-dependencies.md) | Alarm dependencies | Plus | Medium | Power feature, defer |
| [TIER-16](../backlogs/TIER-16-free-trial.md) | 7-day free trial | Pricing | Low | Ship with or right after Plus features |
| [TIER-17](../backlogs/TIER-17-contextual-upgrade-triggers.md) | Contextual upgrade triggers | Conversion | Medium | Needs analytics data first |
| [TIER-18](../backlogs/TIER-18-referral-program.md) | Referral program | Growth | Medium | Needs Firebase backend (TIER-02) |

---

## Ticket Lifecycle

```
backlogs/ → open/ → in-progress/ → untested/ → completed/
```

1. **backlogs/** — Tickets not yet prioritized for any sprint
2. **open/** — Tickets scoped for a sprint, ready to be picked up
3. **in-progress/** — Actively being worked on
4. **untested/** — Implementation complete, pending QA/testing
5. **completed/** — Done and verified

When starting a ticket: move the `.md` file from `open/` to `in-progress/`.
When implementation is done: move to `untested/`.
After QA passes: move to `completed/`.

---

## Definition of Done (per ticket)

- [ ] Implementation complete on iOS
- [ ] Implementation complete on Android (if applicable)
- [ ] Tier gating verified (Free vs Plus behavior correct)
- [ ] Build passes on both platforms
- [ ] No regressions in existing functionality
- [ ] Light/dark mode verified
- [ ] Accessibility labels on new interactive elements
