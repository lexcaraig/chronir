# /implement-ios

Focused iOS implementation workflow. Takes a feature description, implements it in SwiftUI following project conventions, then lints, tests, and reviews.

## Usage

```
/implement-ios [description]
```

Example: `/implement-ios Add ChronirButton atom component with primary and secondary variants`

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. All research and planning (Steps 1–2) happen inside plan mode. Use `ExitPlanMode` after Step 2 to get user approval before implementing.

### Step 1: Gather Context
Based on the description, read relevant files:
- `docs/technical-spec.md` — Architecture patterns
- `docs/design-system.md` — If UI-related
- `docs/data-schema.md` — If data-related
- Existing files in the target area of `chronir/chronir/`

### Step 2: Plan
Identify the implementation approach:
- Files to create or modify
- Which layer: DesignSystem, Features, Core, Widgets
- Dependencies on existing code
- Preview requirements (Light/Dark, state variations)

Present a brief plan to the user.

### Step 3: Implement
Write code following iOS conventions:
- **Architecture:** MVVM + Repository
- **ViewModels:** `@Observable` class
- **Design system:** Chronir- prefixed components, use token values
- **Previews:** Light + Dark mode, relevant state variations
- **Concurrency:** Swift 6 strict concurrency
- **Protocols:** Abstract services behind protocols

### Step 4: Write Unit Tests
Write new unit tests for the implementation:
- Use the `test-writer-fixer` agent for comprehensive test coverage
- Target 80%+ coverage on new code
- Cover happy path, edge cases, and error states

### Step 5: Quality Gate (MANDATORY — must pass before proceeding)
Run the full quality gate. **Do not skip any step. Do not proceed to review until all pass.**

```bash
cd chronir && swiftlint --fix     # Auto-format
cd chronir && swiftlint           # Lint — must be zero warnings in changed files
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO     # Unit tests — must all pass
cd chronir && xcodebuild build -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO    # Build — must compile with zero errors
```

**If any step fails:** Fix the issues immediately and re-run the full gate. Loop until all steps pass.

### Step 6: Review
Run the `code-reviewer` agent on all changed files. Address any findings.

### Step 7: Simplify
Run the `code-simplifier` agent on all modified files to clean up implementation verbosity — reduce nesting, improve naming, simplify conditionals — while preserving exact functionality.

### Step 8: Re-run Quality Gate
After review and simplification may have changed code, **re-run the full quality gate from Step 5** to ensure nothing was broken. All checks must still pass.

## Plugins

Use these installed plugins at the appropriate steps:
- **swift-lsp** — Use LSP features during implementation (Step 3) for go-to-definition, find-references, hover info, and diagnostics on Swift files
- **context7** — Look up latest SwiftUI/SwiftData/AlarmKit documentation during planning (Step 1) when unsure about APIs
- **code-review** — Powers the review step (Step 6). Use `code-reviewer` agent on all changed files
- **code-simplifier** — Powers the simplification step (Step 7). Run on all modified files
- **security-guidance** — Consult during review for auth, data storage, and network security

## Notes
- Always use design tokens from `DesignSystem/Tokens/`, never hardcode values
- Every new view needs previews
- Services must be protocol-based for testability
- AlarmKit is iOS 26 only — add availability checks where needed
