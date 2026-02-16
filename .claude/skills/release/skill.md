# /release

End-to-end release orchestrator. Handles version bumping, quality gates, platform-specific App Store / Play Store metadata generation, documentation updates, git tagging, and pre-submission verification.

## Usage

```
/release [version] [platform]
```

**Arguments:**
- `version` — The version to release (e.g., `1.1`, `1.2.0`, `2.0`). Required.
- `platform` — Target platform: `ios`, `android`, or `both`. Defaults to `both`.

**Examples:**
- `/release 1.1 ios` — iOS-only release of version 1.1
- `/release 1.2 android` — Android-only release of version 1.2
- `/release 2.0 both` — Full cross-platform release
- `/release 1.1` — Defaults to both platforms

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool. Gather context (Steps 1–2) inside plan mode. Present the release scope for user approval before making any changes.

### Step 1: Gather Release Context

Determine what's being released:

```bash
# Recent commits since last tag (or all commits if no tags)
git log $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD --oneline

# Current version in Xcode project
grep "MARKETING_VERSION" chronir/chronir.xcodeproj/project.pbxproj | head -2

# Current version in Android (if applicable)
grep "versionName" Chronir-Android/app/build.gradle.kts 2>/dev/null | head -1

# Existing tags
git tag --sort=-v:refname | head -10
```

Read `docs/detailed-project-roaadmap.md` to identify which sprints/features are included.

Read `docs/appstoreconnect/listing.md` for current App Store metadata state.

### Step 2: Release Summary

Present a clear summary:
- **Version:** X.Y.Z
- **Platform(s):** iOS / Android / Both
- **Commits included:** count since last tag
- **Features/fixes shipping:** bullet list from commit history + roadmap
- **Current version → New version:** e.g., 1.0 (build 1) → 1.1 (build 1)

Get user approval via `ExitPlanMode` before proceeding.

### Step 3: Version Bump

#### iOS (if platform is `ios` or `both`)

Update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the Xcode project:

```bash
# Bump MARKETING_VERSION to the new version
sed -i '' "s/MARKETING_VERSION = [^;]*/MARKETING_VERSION = {version}/" chronir/chronir.xcodeproj/project.pbxproj

# Reset CURRENT_PROJECT_VERSION to 1 for new marketing version (or increment for patch)
sed -i '' "s/CURRENT_PROJECT_VERSION = [^;]*/CURRENT_PROJECT_VERSION = 1/" chronir/chronir.xcodeproj/project.pbxproj
```

Verify the changes:
```bash
grep "MARKETING_VERSION\|CURRENT_PROJECT_VERSION" chronir/chronir.xcodeproj/project.pbxproj | head -4
```

#### Android (if platform is `android` or `both`)

Update `versionName` and `versionCode` in `Chronir-Android/app/build.gradle.kts`:
- `versionName` → new version string
- `versionCode` → increment by 1

### Step 4: Quality Gates (MANDATORY)

Run platform-specific quality gates. **All must pass before proceeding.**

#### iOS Quality Gate

```bash
cd chronir && swiftlint --fix
cd chronir && swiftlint
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' -skipMacroValidation CODE_SIGNING_ALLOWED=NO CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES
cd chronir && xcodebuild build -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' -skipMacroValidation CODE_SIGNING_ALLOWED=NO CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES
```

#### Android Quality Gate

```bash
cd Chronir-Android && ./gradlew ktlintFormat
cd Chronir-Android && ./gradlew ktlintCheck
cd Chronir-Android && ./gradlew test
cd Chronir-Android && ./gradlew assembleRelease
```

**If any step fails:** Fix immediately and re-run. Do NOT proceed until all pass.

### Step 5: Pre-Submit Audit (iOS)

If platform includes iOS, run the full `/pre-submit-audit` workflow:
- Crash-risk code scan (`fatalError`, `preconditionFailure`, `.first!`, `print()`)
- Non-functional UI elements check
- Feature description accuracy vs paywall
- Debug UI hidden behind `#if DEBUG`
- Permission strings in Info.plist
- Legal links accessible
- Subscription compliance (Guideline 3.1.2)
- App completeness (no placeholder text, TODOs in UI strings)
- Encryption compliance (`ITSAppUsesNonExemptEncryption`)

**All checks must PASS.** Fix any failures before proceeding.

### Step 6: Generate Release Metadata

Generate platform-specific store metadata based on the commits and features in this release.

#### iOS — App Store Connect

Generate and save to `docs/appstoreconnect/releases/v{version}.md`:

```markdown
# Chronir v{version} — App Store Release

## What's New (4000 char max)
{Generated from commits — user-facing language, not technical. Focus on benefits.}

## Promotional Text (170 char max)
{Short, punchy. Updated only if the release has a major new feature.}

## Release Notes (Internal)
{Technical summary for the team — what changed, what to watch for.}
```

**What's New guidelines:**
- Write from the user's perspective, not the developer's
- Lead with the most impactful change
- Use short bullet points
- No technical jargon (no "refactored", "optimized data flow", etc.)
- Include bug fixes as "Fixed an issue where..."
- Max 4000 characters

**Promotional Text guidelines:**
- Max 170 characters (hard limit)
- Can be updated without a new app version
- Focus on the app's value proposition or seasonal relevance
- Only regenerate if the release has a headline feature; otherwise keep existing

#### Android — Play Store

Generate and save to `docs/playstore/releases/v{version}.md`:

```markdown
# Chronir v{version} — Play Store Release

## What's New (500 char max)
{Generated from commits — user-facing language. Shorter than iOS due to limit.}

## Short Description (80 char max)
{Only update if app positioning changes.}

## Release Notes (Internal)
{Technical summary for the team.}
```

**Play Store What's New guidelines:**
- Max 500 characters (much shorter than iOS)
- Be concise — often just 3-5 bullet points
- Same user-facing language rules as iOS

#### Platform-Specific Notes

If the release is platform-specific (e.g., iOS-only):
- Only generate metadata for the target platform
- Note in the release doc which platform this covers
- If features are iOS-exclusive (e.g., AlarmKit, Siri), frame them in platform context

### Step 7: Update Documentation

Run the equivalent of `/update-docs` with the release context:

1. **CHANGELOG.md** — Add release entry with version, date, platform, and all changes
2. **detailed-project-roaadmap.md** — Mark shipped sprints/tasks as DONE
3. **listing.md** — Update the version number and any changed metadata fields
4. **technical-spec.md** — Update if new architecture was introduced
5. **data-schema.md** — Update if models changed
6. **design-system.md** — Update if new components shipped
7. **CLAUDE.md** — Update slash commands table if the release includes workflow changes

Only update docs that are actually affected by this release.

### Step 8: Git Release Workflow

#### Create Release Commit

Stage all changes (version bump, metadata, docs):

```bash
git add -A
git commit -m "release: v{version} ({platform})"
```

#### Tag the Release

```bash
git tag -a v{version} -m "Release v{version}

Platform: {ios/android/both}

Changes:
{bullet list of key changes from Step 6 metadata}
"
```

#### Push

```bash
git push origin main --tags
```

### Step 9: Archive Build (iOS)

If platform includes iOS, provide the archive command (do NOT run automatically — user must run from Xcode or CI):

```bash
# Archive for App Store submission (run in Xcode or CI)
xcodebuild archive \
  -project chronir/chronir.xcodeproj \
  -scheme chronir \
  -archivePath build/Chronir.xcarchive \
  -destination 'generic/platform=iOS'

# Export IPA (requires ExportOptions.plist)
xcodebuild -exportArchive \
  -archivePath build/Chronir.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist ExportOptions.plist
```

**Note:** Production archive builds should be done via Xcode GUI (Product → Archive) or CI/CD pipeline. The commands above are for reference.

### Step 10: Release Checklist

Output a final checklist for the user:

```markdown
## Release v{version} Checklist

### Code & Quality
- [ ] Version bumped: {old} → {new}
- [ ] Quality gate: PASS (lint, test, build)
- [ ] Pre-submit audit: PASS (iOS) / N/A (Android)
- [ ] No debug prints, fatalError stubs, or placeholder text
- [ ] All legal links working

### Git
- [ ] Release commit created
- [ ] Tag v{version} pushed
- [ ] All changes on main/remote

### App Store Connect (iOS)
- [ ] Archive uploaded to ASC (via Xcode or CI)
- [ ] What's New text pasted into version metadata
- [ ] Promotional Text updated (if changed)
- [ ] Screenshots current (if UI changed)
- [ ] Build selected for review
- [ ] Review notes updated (if flow changed)
- [ ] Submit for review

### Play Store Console (Android)
- [ ] AAB uploaded to Play Console
- [ ] What's New text pasted into release notes
- [ ] Short Description updated (if changed)
- [ ] Screenshots current (if UI changed)
- [ ] Submit for review

### Post-Release
- [ ] Monitor Crashlytics for new crashes
- [ ] Monitor App Store Connect / Play Console for review status
- [ ] Announce release (if applicable)
```

Only include platform-relevant items based on the `platform` argument.

## Build Number Strategy

- **`MARKETING_VERSION`** (iOS) / **`versionName`** (Android): User-facing version (e.g., `1.1`, `2.0`)
- **`CURRENT_PROJECT_VERSION`** (iOS) / **`versionCode`** (Android): Internal build number
  - Reset to `1` when `MARKETING_VERSION` changes (new release)
  - Increment for TestFlight/internal builds within the same version
  - Each App Store / Play Store upload must have a unique build number

## Rules

- **Never skip the quality gate or pre-submit audit.** These are blocking.
- **Never auto-run the archive build.** It requires signing and should be done via Xcode or CI.
- **Always confirm version number with the user** before making changes.
- **Metadata is generated, not copied.** Write fresh What's New text from the actual changes — don't reuse boilerplate.
- **Platform-specific releases get platform-specific metadata.** Don't generate Play Store docs for an iOS-only release.
- **The tag is the source of truth** for what shipped in each version.
- **Run `/update-docs` equivalent inline** (Step 7) rather than invoking it separately, to keep context.
- **Promotional Text only changes for major features.** Don't churn it on bug-fix releases.
