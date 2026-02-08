# /sync-tokens

Rebuilds the design token pipeline and copies generated files to both platform projects.

## Usage

```
/sync-tokens
```

No arguments needed.

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. Check for pending token changes in `design-tokens/tokens/` and present what will be built and copied. Use `ExitPlanMode` to get user approval before proceeding.

### Step 1: Build Tokens
```bash
cd design-tokens && npm run build
```
This runs Style Dictionary v5 to generate platform-specific token files from `design-tokens/tokens/*.json`.

### Step 2: Copy to iOS
Copy generated Swift files to the iOS design system:
```bash
cp design-tokens/build/ios/*.swift chronir/chronir/DesignSystem/Tokens/
```

### Step 3: Copy to Android
Copy generated Kotlin files to the Android design system:
```bash
cp design-tokens/build/android/*.kt Chronir-Android/core/designsystem/src/main/java/com/chronir/android/core/designsystem/tokens/
```

### Step 4: Quality Gate (MANDATORY)
Run the full quality gate on both platforms to verify the synced tokens don't break anything. **All checks must pass.**

**iOS (run sequentially):**
```bash
cd chronir && swiftlint --fix     # Auto-format
cd chronir && swiftlint           # Lint
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO     # Unit tests
cd chronir && xcodebuild build -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO    # Build
```

**Android (run sequentially):**
```bash
cd Chronir-Android && ./gradlew ktlintFormat    # Auto-format
cd Chronir-Android && ./gradlew ktlintCheck     # Lint
cd Chronir-Android && ./gradlew test            # Unit tests
cd Chronir-Android && ./gradlew assembleDebug   # Build
```

**If any step fails:** Fix the issues immediately and re-run the gate.

### Step 5: Report
Output which token files were generated and whether both platforms pass the full quality gate (format, lint, tests, build).

## Notes
- Run this after ANY change to `design-tokens/tokens/*.json`
- If the Android token destination path doesn't match, check `Chronir-Android/core/designsystem/` for the actual package structure
- Token file names are determined by `design-tokens/config.js`
