# TIER-02: Cloud Backup for Plus Users

**Priority:** P0
**Tier Impact:** Plus
**Effort:** High (Sprint 10 scope — 5-8 days)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Cloud backup is the single highest-value Plus feature and the #1 conversion driver identified in the tier analysis. Users with 15+ annual alarms spanning years of maintenance schedules will pay to ensure that data survives a phone upgrade or loss. Currently, `AuthService.swift` and `CloudSyncService.swift` are stubs.

This is the headline paywall feature: **"Your alarms, safe forever."**

## Acceptance Criteria

- [ ] Firebase Auth integration: Apple Sign In (iOS), Google Sign In (both), Email/Password (both)
- [ ] Account creation flow in Settings (only visible to Plus users)
- [ ] On sign-in: full initial sync of local alarms to Firestore `users/{uid}/alarms/`
- [ ] On alarm create/edit/delete: sync delta to Firestore within 5 seconds
- [ ] On new device login: download all alarms and reschedule with OS alarm API
- [ ] Photo attachments uploaded to Firebase Storage (compressed, max 1MB)
- [ ] Conflict resolution: last-write-wins with `updatedAt` timestamp comparison
- [ ] Offline queue: changes stored locally and synced when connection restored
- [ ] Sync status indicator in Settings: "Last synced: 2 minutes ago" / "Syncing..." / "Offline — changes will sync when connected"
- [ ] Restore flow: "Sign in on new device → download alarms → reschedule all"
- [ ] Account deletion removes all cloud data (GDPR compliance)
- [ ] Firestore security rules enforced per `docs/technical-spec.md` Section 6.4

## Technical Notes

- Firebase project already configured: `cyclealarm-app` (ID: 410553847054)
- Stubs to replace: `AuthService.swift`, `CloudSyncService.swift`
- Firestore schema defined in `docs/data-schema.md`
- Must handle subscription expiry: stop syncing, keep local data, show "resubscribe to resume backup"
- SDK configs already gitignored: `GoogleService-Info.plist`, `google-services.json`

## Dependencies

- Firebase Auth SDK integrated in both platforms
- Firestore security rules deployed
- Plus subscription verification (already implemented)

## Orchestration

**Command:** `/implement-task TIER-02`
**Agents:** `firebase-architect` (primary), `ios-developer`, `android-developer`
**Plugins:**
- `firebase` MCP — Validate security rules, query Firestore, check project config
- `code-reviewer` — Review auth flows, sync logic, conflict resolution
- `code-simplifier` — Simplify after implementation
- `security-reviewer` — CRITICAL: auth flows, token handling, Firestore rules, data encryption
- `test-writer-fixer` — Unit tests for sync logic, conflict resolution
- `context7` — Look up Firebase Auth / Firestore SDK documentation

**Pre-flight:**
- [ ] Read `docs/technical-spec.md` Section 6.4 (Firestore security rules)
- [ ] Read `docs/data-schema.md` (Firestore schema)
- [ ] Read existing stubs: `AuthService.swift`, `CloudSyncService.swift`
- [ ] Verify Firebase project config in console

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Run `/pre-submit-audit` (no fatalError stubs remaining)
- [ ] Deploy Firestore security rules
- [ ] Manual test: Sign in → create alarm → verify appears in Firestore
- [ ] Manual test: Sign out → sign in on "new device" → alarms restore
- [ ] Move ticket to `tickets/untested/`

## References

- Spec: `docs/technical-spec.md` Section 6.4 (security rules)
- Schema: `docs/data-schema.md` (Firestore collections)
- Roadmap: Sprint 10 (S10-01 through S10-09)
