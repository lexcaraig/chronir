# PREMIUM-01: Shared Alarms & Invitations (Premium Tier)

**Priority:** P3
**Category:** Premium
**Effort:** Very High (Sprint 11 scope — 2 weeks)
**Platform:** iOS, Android
**Original Tasks:** S11-01 through S11-09

---

## Description

Premium tier core feature: share alarms with other users via invite links. Shared alarms fire on all participants' devices simultaneously. Includes premium subscription tier, Firestore schema for shared alarms, invite generation/acceptance, and real-time sync.

Deferred to Phase 4 (post V1.0 launch).

## Scope

- S11-01: Premium subscription tier (StoreKit 2 + Play Billing)
- S11-02: Firestore schema for shared alarms
- S11-03: Invite link generation (deep links)
- S11-04: Invite acceptance flow
- S11-05: Receiver-only mode (free users can receive shared alarms)
- S11-06: Real-time sync (Firestore listeners)
- S11-07: Shared badge on AlarmCard
- S11-08: Shared alarm firing on all devices
- S11-09: Shared completion visibility

## Dependencies

- TIER-02 (Cloud backup / Firebase Auth)
- Firebase backend fully operational

## References

- Roadmap: Sprint 11
- User stories: US-10.1 (Shared Alarms)
