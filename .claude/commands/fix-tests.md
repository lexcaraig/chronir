# /fix-tests

Run unit tests on all affected platforms, diagnose failures, fix them, and loop until green. Optionally targets a specific platform.

## Usage

```
/fix-tests [platform?]
```

- `/fix-tests` — Run and fix tests on all platforms
- `/fix-tests ios` — iOS only
- `/fix-tests android` — Android only

## Workflow

### Step 1: Identify Scope
Determine which platforms to test:
- If a platform argument is provided, test only that platform
- If no argument, test both iOS and Android
- Check `git diff --name-only` to see which files changed — use this to focus test investigation

### Step 2: Run Tests

**iOS:**
```bash
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO 2>&1
```

**Android:**
```bash
cd Chronir-Android && ./gradlew test 2>&1
```

Capture the full output including any failure details, assertion messages, and stack traces.

### Step 3: Analyze Failures
For each failing test:
1. Read the failing test file to understand what it expects
2. Read the source file being tested to understand the actual behavior
3. Determine root cause — is it:
   - **Test is wrong:** Test expectations don't match intended behavior (e.g., after a deliberate API change)
   - **Source is wrong:** Implementation has a bug that the test correctly caught
   - **Missing dependency:** Test needs a mock, stub, or setup that's missing
   - **Compilation error:** Test file doesn't compile due to API changes

### Step 4: Fix Failures
Apply fixes based on the root cause:
- **Test is wrong:** Update test expectations to match the correct intended behavior. Do NOT weaken tests — update them to test the right thing.
- **Source is wrong:** Fix the bug in the source code. Then verify the test passes.
- **Missing dependency:** Add the required mock/stub/setup.
- **Compilation error:** Update the test to match the current API surface.

### Step 5: Re-run Tests (Loop Until Green)
After applying fixes, re-run the full test suite for the affected platform(s):

**iOS:**
```bash
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO 2>&1
```

**Android:**
```bash
cd Chronir-Android && ./gradlew test 2>&1
```

**If tests still fail:** Go back to Step 3. Repeat until all tests pass.

**IMPORTANT:** Do not delete or skip failing tests to make the suite pass. Every test must either pass or be fixed, not removed.

### Step 6: Run Full Quality Gate
After all tests pass, run the full quality gate to ensure fixes didn't break lint or build:

**iOS:**
```bash
cd chronir && swiftlint --fix     # Auto-format
cd chronir && swiftlint           # Lint
cd chronir && xcodebuild build -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO    # Build
```

**Android:**
```bash
cd Chronir-Android && ./gradlew ktlintFormat    # Auto-format
cd Chronir-Android && ./gradlew ktlintCheck     # Lint
cd Chronir-Android && ./gradlew assembleDebug   # Build
```

**If lint or build fails:** Fix and re-run tests + gate until everything is green.

### Step 7: Simplify
Run `/simplify` on all modified files to clean up any verbosity introduced during test fixes — while preserving exact functionality.

### Step 8: Report
Output a summary:

```
## Test Fix Report

### Platform: iOS / Android / Both

### Test Results
- Total tests: N
- Passed: N
- Previously failing: N
- Fixed: N

### Fixes Applied
- [file:line] — Description of what was wrong and how it was fixed
- ...

### Quality Gate
- Format: PASS
- Lint: PASS (N warnings)
- Tests: PASS (N/N passed)
- Build: PASS

### Status: ALL GREEN
```

## Plugins

Use these installed plugins during test fixing:
- **swift-lsp** / **kotlin-lsp** — Use LSP features (go-to-definition, find-references, hover) to trace failing test code to source implementations and understand type errors
- **context7** — Look up testing framework APIs (XCTest, Swift Testing, JUnit 5, Mockk) when unsure about assertion methods or test setup patterns
- **code-review** — After fixing tests, run `code-reviewer` on changed test files to verify test quality
- **code-simplifier** — Powers the simplification step (Step 7). Run `/simplify` on all modified files

## Notes
- Always prefer fixing the source over weakening tests — tests exist to catch bugs
- If a test is genuinely obsolete (tests removed functionality), it can be deleted, but explain why in the report
- For flaky tests (pass sometimes, fail sometimes), investigate the root cause (race conditions, time-dependent assertions, shared state) rather than just re-running
- Use the `test-writer-fixer` agent for complex test fixes that require deep understanding of the test framework
