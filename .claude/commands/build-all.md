# /build-all

Parallel build verification across all three build systems. Outputs a pass/fail summary.

## Usage

```
/build-all
```

No arguments needed.

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. Check the current branch state and present which build systems will be verified. Use `ExitPlanMode` to get user approval before running builds.

### Step 1: Run All Builds in Parallel
Execute all three build systems simultaneously:

**Design Tokens:**
```bash
cd design-tokens && npm run build
```

**iOS:**
```bash
cd Chronir-iOS && swift build
```

**Android:**
```bash
cd Chronir-Android && ./gradlew assembleDebug
```

### Step 2: Report Results
Output a summary:

```
## Build Report

| Platform      | Status    | Time   |
|---------------|-----------|--------|
| Design Tokens | PASS/FAIL | Xs     |
| iOS           | PASS/FAIL | Xs     |
| Android       | PASS/FAIL | Xs     |

### Failures
[details of any failures, or "None"]
```

### Step 3: If Failures
If any build fails:
- Show the relevant error output
- Suggest fixes if the errors are straightforward
- Do NOT automatically fix — wait for user direction

## Notes
- iOS builds compile Firebase SDK from source and can take 5+ minutes on first run
- Android builds require JDK 17
- Design token builds require Node.js and npm dependencies (`cd design-tokens && npm install`)
