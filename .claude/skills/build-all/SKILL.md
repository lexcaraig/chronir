# /build-all

Full quality verification across all build systems: format, lint, test, and build. Outputs a pass/fail summary.

## Usage

```
/build-all
```

No arguments needed.

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. Check the current branch state and present which build systems will be verified. Use `ExitPlanMode` to get user approval before running checks.

### Step 1: Run Full Quality Gate on All Platforms
Execute the full quality gate on each platform. Run format→lint→test→build sequentially per platform, but platforms can run in parallel.

**Design Tokens:**
```bash
cd design-tokens && npm run build
```

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

### Step 2: Report Results
Output a summary:

```
## Quality Gate Report

| Platform      | Format | Lint      | Tests     | Build     | Time   |
|---------------|--------|-----------|-----------|-----------|--------|
| Design Tokens | N/A    | N/A       | N/A       | PASS/FAIL | Xs     |
| iOS           | PASS   | PASS/FAIL | PASS/FAIL | PASS/FAIL | Xs     |
| Android       | PASS   | PASS/FAIL | PASS/FAIL | PASS/FAIL | Xs     |

### Failures
[details of any failures, or "None"]
```

### Step 3: If Failures
If any check fails:
- Show the relevant error output
- Suggest fixes if the errors are straightforward
- Do NOT automatically fix — wait for user direction

## Notes
- iOS builds compile Firebase SDK from source and can take 5+ minutes on first run
- Android builds require JDK 17
- Design token builds require Node.js and npm dependencies (`cd design-tokens && npm install`)
