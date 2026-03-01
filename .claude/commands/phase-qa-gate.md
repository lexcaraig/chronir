# /phase-qa-gate

Comprehensive quality gate check for a phase. Runs lint, tests, builds, security review, and generates a structured pass/fail report.

## Usage

```
/phase-qa-gate [phase-number]
```

Example: `/phase-qa-gate 1`

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. Identify which sprints belong to the specified phase, check `tickets/sprints/` for the relevant sprint file, list all tickets in `tickets/untested/` that need QA verification, outline what checks will run, and present the QA scope. Use `ExitPlanMode` to get user approval before running checks.

### Step 1: Format & Lint
Run auto-format first, then lint on both platforms:

**iOS:**
```bash
cd chronir && swiftlint --fix     # Auto-format
cd chronir && swiftlint           # Lint verification
```

**Android:**
```bash
cd Chronir-Android && ./gradlew ktlintFormat    # Auto-format
cd Chronir-Android && ./gradlew ktlintCheck     # Lint verification
```

Record: pass/fail status and issue count for each. If auto-format made changes, stage them.

### Step 2: Unit Tests
Run unit tests on both platforms in parallel:

**iOS:**
```bash
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO
```

**Android:**
```bash
cd Chronir-Android && ./gradlew test
```

Record: pass/fail status, test count, failure details.

### Step 3: Build Verification
Run release builds on both platforms in parallel:

**iOS:**
```bash
cd chronir && xcodebuild build -project chronir.xcodeproj -scheme chronir -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO
```

**Android:**
```bash
cd Chronir-Android && ./gradlew assembleRelease
```

**Design Tokens:**
```bash
cd design-tokens && npm run build
```

Record: pass/fail status, any warnings.

### Step 4: Security Review
Use the `security-reviewer` agent to scan for:
- OWASP Top 10 vulnerabilities
- Hardcoded secrets or API keys
- Insecure data storage
- Improper authentication/authorization
- Injection vulnerabilities

### Step 5: Code Simplification Audit
Run `/simplify` on all files modified during the phase to identify:
- Overly complex code that could be simplified
- Redundant patterns, unnecessary nesting
- Naming inconsistencies

Record: number of files simplified, summary of changes. This is a non-blocking quality improvement step — findings are reported as warnings.

### Step 6: QA Plan Cross-Reference
Read `docs/qa-plan.md` and identify all test IDs associated with the specified phase. For each:
- Check if a corresponding test exists in the codebase
- Verify acceptance criteria coverage
- Flag any missing test coverage

### Step 7: Generate Report
Output a structured report following this format:

```
## QA Gate Report — Phase {N}

### Summary: PASS / FAIL

### Format & Lint
- iOS format (swiftlint --fix): Applied / No changes needed
- iOS swiftlint: PASS/FAIL (N issues)
- Android format (ktlintFormat): Applied / No changes needed
- Android ktlint: PASS/FAIL (N issues)

### Unit Tests
- iOS: PASS/FAIL (N/M passed)
- Android: PASS/FAIL (N/M passed)

### Build Verification
- iOS release: PASS/FAIL
- Android release: PASS/FAIL
- Design tokens: PASS/FAIL

### Security Review
- Critical: [count]
- Warning: [count]
- Details: [list findings]

### Code Simplification
- Files audited: [count]
- Simplifications applied: [count]
- Details: [list or "Code is clean"]

### QA Plan Coverage
- Phase test IDs: [total]
- Covered: [count]
- Missing: [list]

### Blocking Issues (must fix)
- [list or "None"]

### Warnings (should fix)
- [list or "None"]

### Verdict
[PASS: Ready to proceed to Phase {N+1}]
[FAIL: {N} blocking issues must be resolved]
```

## Plugins

Use these installed plugins during QA gate:
- **code-review** — Powers Step 4 indirectly. Use `code-reviewer` agent for automated quality checks
- **security-guidance** — Powers Step 4 (Security Review). Use `security-reviewer` agent for OWASP Top 10, secrets detection, injection checks
- **code-simplifier** — Powers Step 5 (Simplification Audit). Run `/simplify` on all phase-modified files as non-blocking quality step
- **pr-review-toolkit** — Use `pr-test-analyzer` to verify test coverage quality for the phase
- **swift-lsp** / **kotlin-lsp** — Use LSP diagnostics as an additional signal for code health
- **claude-md-management** — After gate passes, run `/revise-claude-md` to capture any lessons learned during the phase

### Step 8: Update Ticket Status
After the gate passes:
- Move all tickets in `tickets/untested/` that were part of this phase to `tickets/completed/`
- Update the sprint file in `tickets/sprints/` with final status

## Gate Criteria
- **PASS:** Zero blocking issues. Lint clean, all tests pass, builds succeed, no critical security findings. All phase tickets move to `completed/`.
- **FAIL:** Any blocking issue present. Must be resolved before phase progression. Tickets remain in `untested/`.
- **Warnings** do not block but should be tracked for resolution.
