# Sprint: iOS Launch

**Goal:** Complete all remaining work needed for iOS App Store submission.
**Branch:** `sprint-ios-launch`
**Status:** In Progress

---

## Sprint Scope

### Phase A — Critical Fixes

| Ticket                                              | Title                          | Effort  | Status |
| --------------------------------------------------- | ------------------------------ | ------- | ------ |
| [TIER-01](../open/TIER-01-fix-photo-note-gating.md) | Fix photo/note tier gating bug | Low     | Open   |
| [TIER-03](../open/TIER-03-bump-free-alarm-limit.md) | Bump free alarm limit to 3     | Trivial | Open   |

### Phase B — Test Coverage

| Ticket                                                | Title                              | Effort | Status |
| ----------------------------------------------------- | ---------------------------------- | ------ | ------ |
| [QA-01](../open/QA-01-unit-tests-alarm-scheduling.md) | Unit tests for alarm scheduling    | Medium | Open   |
| [QA-02](../open/QA-02-unit-tests-subscription.md)     | Unit tests for subscription gating | Low    | Open   |

### Phase C — Launch Prep

| Ticket                                            | Title                             | Effort     | Status        |
| ------------------------------------------------- | --------------------------------- | ---------- | ------------- |
| ~~LAUNCH-01~~                                     | ~~App Store listing preparation~~ | ~~Medium~~ | **Completed** |
| [LAUNCH-03](../open/LAUNCH-03-analytics-setup.md) | Analytics & crash reporting       | Medium     | Open          |

### Phase D — Final Gate

| Ticket        | Title                        | Effort     | Status        |
| ------------- | ---------------------------- | ---------- | ------------- |
| ~~LAUNCH-04~~ | ~~Final regression test~~    | ~~Medium~~ | **Completed** |
| ~~LAUNCH-02~~ | ~~iOS App Store submission~~ | ~~Low~~    | **Completed** |

TIER-02: Cloud Backup

1. Go to Settings > Account & Sync (must be Plus user)
2. Sign in with Apple Sign In
3. After sign-in: should show your email, display name, sync status
4. Create a new alarm — check Firebase Console > Firestore > users/{uid}/alarms/ — new doc should appear within
   seconds
5. Edit the alarm — Firestore doc should update
6. Delete the alarm — Firestore doc should disappear
7. Sync status should show "Last synced: just now" or similar
8. Restore test: Sign out, delete app, reinstall, sign in — alarms should restore (this requires the restore/pull flow
   to work)
9. Delete account: Tap "Delete Account" — all cloud data should be removed from Firestore
10. As Free user: "Account & Sync" should NOT appear; instead see "Backup & Sync" info view

---
