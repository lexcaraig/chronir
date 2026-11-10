# ANDROID-07: Free 3-alarm limit not re-applied after Plus lapses

**Priority:** P2
**Category:** Android
**Platform:** Android
**Status:** In progress

## Goal
Android checks the limit only at create time. iOS has `AlarmLimitPolicy` (disable beyond-limit alarms on downgrade, restore on re-upgrade). Port it.

## Acceptance Criteria
- [x] Pure Kotlin policy in core/services persisting limit-disabled IDs in DataStore, run on tier change.
- [x] Unit test; ktlint + tests pass.

## Verification
- Files: `Chronir-Android/core/services/src/main/java/com/chronir/services/AlarmLimitPolicy.kt` (pure object, port of iOS `AlarmLimitPolicy`, owns `FREE_TIER_ALARM_LIMIT`), `AlarmLimitEnforcer.kt` (new `@Singleton`; `observe(subscriptionState)` applies on every resolved tier change), `BillingService.kt` (`SubscriptionState.isTierResolved`, set once Play answers so the initial FREE placeholder never disables alarms), `core/data/.../SettingsRepository.kt` (`limitDisabledAlarmIds` in the existing DataStore), `app/.../ChronirApp.kt` (starts the observer), `AlarmListViewModel.kt` + `AlarmCreationViewModel.kt` (constants point at the policy).
- Test: `Chronir-Android/tests/src/test/java/com/chronir/AlarmLimitPolicyTest.kt` — 4 cases. `./gradlew test` — pass.
- Gate: `./gradlew ktlintFormat ktlintCheck test assembleDebug` — pass.
- Still needs device QA with the sandbox account (TEST-06): 5 alarms on Plus, let it expire (~3 min), confirm the 2 newest turn off; re-subscribe, confirm only those come back and a user-paused alarm stays off.

## Review notes (2026-11-10)
- Enforcer persists the remembered IDs before disabling, so a process death between the two steps cannot strand alarms.
- Known risk (security review): Play answering OK with an empty purchase list is treated as a resolved FREE tier. An unsynced Play cache after reinstall could briefly read a Plus user as Free and turn off alarms beyond 3; the restore path turns exactly those back on once PLUS resolves. Revisit if seen in the field.
