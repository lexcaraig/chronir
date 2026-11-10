# ANDROID-05: BootReceiver ignores package update, time and timezone changes

**Priority:** P1
**Category:** Android
**Platform:** Android
**Status:** In progress

## Goal
`BootReceiver` only handles `BOOT_COMPLETED`. Alarms are not re-registered after an app update and not recalculated after `TIME_SET` / `TIMEZONE_CHANGED`. Past-due alarms are passed straight to `setAlarmClock` so they all fire at boot.

## Acceptance Criteria
- [x] Manifest + receiver handle BOOT_COMPLETED, QUICKBOOT_POWERON, MY_PACKAGE_REPLACED, TIME_SET, TIMEZONE_CHANGED. LOCKED_BOOT_COMPLETED dropped (receiver is not directBootAware; Room is credential-encrypted). Receiver is `exported=false`: system broadcasts still arrive and the unprotected QUICKBOOT_POWERON can no longer be spoofed by another app (security review 2026-11-10).
- [x] Next fire dates are recalculated and persisted before scheduling; overdue repeating alarms advance.
- [x] JVM unit test with a fake scheduler; ktlint + tests pass.

## Verification
- Files: `Chronir-Android/core/services/src/main/java/com/chronir/services/AlarmReregistrationPolicy.kt` (new, plain class), `BootReceiver.kt` (handles the six actions, persists changed `nextFireDate` via `AlarmRepository.updateAlarm` before `finish()`), `app/src/main/AndroidManifest.xml` (intent-filter + QUICKBOOT_POWERON).
- Test: `Chronir-Android/tests/src/test/java/com/chronir/AlarmReregistrationPolicyTest.kt` — 7 cases (overdue repeating advances, future kept, pending snooze honored, expired snooze resets, timezone recompute, one-time kept, every alarm scheduled) with a fake `AlarmScheduler`. `./gradlew :tests:testDebugUnitTest --tests com.chronir.AlarmReregistrationPolicyTest` — 7/7 pass.
- Gate: `./gradlew ktlintFormat ktlintCheck test assembleDebug` — pass.
- Not direct-boot aware on purpose: Room lives in credential-encrypted storage, so LOCKED_BOOT_COMPLETED is listed but the receiver runs once the user unlocks (BOOT_COMPLETED follows anyway).
- Still needs device QA (adb): reboot with an overdue repeating alarm, broadcast TIME_SET, change the timezone, then check `dumpsys alarm` for the chronir registrations.

## Security review (2026-11-10)
exported=false; catch around the coroutine body so a Room/scheduler failure logs instead of crashing the process.
