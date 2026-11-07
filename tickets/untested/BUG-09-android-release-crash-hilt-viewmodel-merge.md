# BUG-09: Android 1.3.0 release build crashes at the end of onboarding

**Priority:** P0 (every Play install crashes)
**Category:** Bug
**Platform:** Android
**Status:** Untested (fix on Play internal testing, versionCode 5)

---

## Goal
A Play-installed build gets through onboarding to the main screen without crashing.

## What happened
Internal testers installing 1.3.0 (versionCode 4) from Play saw "Chronir closed because this app has a bug." Reproduced on the Galaxian test phone (A001T) with a local release build: the app opens, then crashes on the last onboarding step:

```
java.lang.IllegalArgumentException: Multiple entries with same key: P2.s=true and P2.s=true
  at B2.o.getViewModelKeys
  at dagger.hilt.android.internal.lifecycle.DefaultViewModelFactories.getActivityFactory
  at com.chronir.MainActivity
```

## Root cause
Hilt (2.51.1) keys ViewModels by class name (`@LazyClassKey`). R8 merged `SharedAlarmViewModel` and `WallpaperPickerViewModel` into `CategoryDetailViewModel` (`P2.s`), so the generated key map got the same key three times. The R8 mapping listed 11 of the 13 ViewModels. Debug builds don't run R8, so this only shows up in release.

## Fix
`Chronir-Android/app/proguard-rules.pro`: `-keep,allowobfuscation,allowshrinking class * extends androidx.lifecycle.ViewModel`, which stops R8 from merging ViewModel classes. versionCode bumped 4 → 5.

## Evidence
- After the fix, the R8 mapping lists all 13 ViewModels under distinct names.
- Clean install of the fixed release APK on the Galaxian phone, tapped through onboarding to the New Alarm screen with 0 lines in `logcat -b crash`.
- Uploaded via `fastlane supply` to the internal track, mapping included; `google_play_track_version_codes` reports `[5]`.

## Acceptance Criteria
- [x] Release build passes onboarding with no crash (local, device)
- [ ] A Play-installed build (versionCode 5) passes onboarding with no crash
- [ ] Shared alarm, wallpaper picker and category detail screens open in the release build

## Follow-up
- No crash reporting on Android (no Crashlytics/Sentry), which is why this was invisible. Worth a ticket.
