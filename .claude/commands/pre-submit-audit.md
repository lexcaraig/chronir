# /pre-submit-audit

Runs a comprehensive App Store Review compliance audit before submission. Checks for crash-risk stubs, non-functional UI, misleading feature descriptions, exposed debug tools, and guideline violations.

## Usage

```
/pre-submit-audit
```

No arguments needed. Run this before every App Store submission.

## Workflow

### Step 1: Crash-Risk Code Scan

Search for code that would crash in production:

```bash
# fatalError and preconditionFailure in non-test code
grep -r "fatalError\|preconditionFailure" chronir/chronir/ --include="*.swift" | grep -v "Tests/" | grep -v "ModelContainer"

# Force unwraps that aren't URL literals (URL literals are safe)
grep -rn "!\." chronir/chronir/ --include="*.swift" | grep -v "Tests/" | grep -v "URL(string:" | grep -v "Preview" | head -20
```

Flag any `fatalError("TODO")` or unimplemented stubs. These MUST be replaced with `throw` or removed.

### Step 2: Non-Functional UI Elements

Check that all tappable UI elements actually do something:

- Settings rows with chevrons must be wrapped in `NavigationLink` or `Link`
- Privacy Policy and Terms of Service links must open real URLs
- Any "Coming Soon" or placeholder sections must be removed or hidden
- Buttons must have actions, not empty closures

Search for suspicious patterns:
```bash
# HStack with chevron but no NavigationLink/Link wrapper
grep -B5 "chevron.right\|arrow.up.right" chronir/chronir/Features/Settings/ --include="*.swift"
```

### Step 3: Feature Description Accuracy

Verify that paywalls, subscription descriptions, and feature lists only advertise what's actually built:

- Read `PaywallView.swift` feature list — every feature must be implemented
- Read `SubscriptionManagementView.swift` plan comparison — no unbuilt features
- Read `Chronir.storekit` subscription descriptions — must match reality
- Check App Store Connect metadata matches in-app descriptions

Search for unbuilt feature references:
```bash
grep -rni "cloud backup\|cloud sync\|shared alarm\|live activit\|groups\|premium" chronir/chronir/ --include="*.swift" | grep -v "Tests/" | grep -v "TODO"
```

### Step 4: Debug/Developer UI Hidden

Ensure developer-only sections are not visible in release builds:

```bash
# Component Catalog, Debug sections visible without #if DEBUG
grep -B3 -A3 "ComponentCatalog\|developerSection\|Developer" chronir/chronir/Features/Settings/ --include="*.swift"
```

All debug tools must be wrapped in `#if DEBUG`.

### Step 5: Permission Purpose Strings

Verify all required usage description strings exist in Info.plist:

- `NSAlarmKitUsageDescription` — required for AlarmKit
- `NSPhotoLibraryUsageDescription` — only if using UIImagePickerController (not needed for PhotosPicker)
- `NSCameraUsageDescription` — only if using camera
- `NSUserNotificationsUsageDescription` — not required on iOS, but good practice

```bash
cat chronir/Info.plist
```

### Step 6: Legal Links

Verify privacy policy and terms of service:

- Links exist in Settings (About section)
- Links exist in PaywallView (legal footer)
- URLs are valid and accessible: `https://chronir.app/privacy` and `https://chronir.app/terms`
- App Store Connect has privacy policy URL set

### Step 7: Subscription Compliance (Guideline 3.1.2)

- Restore Purchases button exists in paywall AND subscription management
- Subscription auto-renewal terms are clearly stated before purchase
- Cancel instructions are provided
- Only tiers that are actually available in App Store Connect are shown in-app

### Step 8: App Completeness (Guideline 2.1)

- No placeholder text ("Lorem ipsum", "TODO", "Coming soon")
- No test data visible in release builds
- All navigation paths lead to real screens
- Onboarding flow completes correctly

```bash
# Search for placeholder text
grep -rni "lorem\|placeholder\|coming soon\|test data" chronir/chronir/ --include="*.swift" | grep -v "Tests/" | grep -v "Preview"
```

### Step 9: ITSAppUsesNonExemptEncryption

Verify the encryption compliance key is set:

```bash
grep "ITSAppUsesNonExemptEncryption" chronir/Info.plist
```

Must be `<false/>` unless using custom encryption beyond HTTPS.

### Step 10: Generate Report

Output a pass/fail summary table:

```
## Pre-Submit Audit Report

| Check                        | Status | Notes |
|------------------------------|--------|-------|
| Crash-risk code              | PASS/FAIL | ... |
| Non-functional UI            | PASS/FAIL | ... |
| Feature description accuracy | PASS/FAIL | ... |
| Debug UI hidden              | PASS/FAIL | ... |
| Permission strings           | PASS/FAIL | ... |
| Legal links                  | PASS/FAIL | ... |
| Subscription compliance      | PASS/FAIL | ... |
| App completeness             | PASS/FAIL | ... |
| Encryption compliance        | PASS/FAIL | ... |
```

If ANY check fails, list the specific files and lines that need fixing. Do NOT proceed with submission until all checks pass.

## Rules

- This audit does NOT replace `/build-all` — run both before submission
- Fix all issues found, then re-run the audit to confirm
- Reference Apple's App Store Review Guidelines at `docs/appstoreconnect/Apple_App_Store_Review_Guidelines.md` for any edge cases
- When in doubt about a guideline, flag it for manual review rather than assuming it passes
