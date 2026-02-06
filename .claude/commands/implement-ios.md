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
- Existing files in the target area of `Chronir-iOS/Sources/`

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

### Step 4: Lint
```bash
cd Chronir-iOS && swiftlint
```
Fix any lint issues before proceeding.

### Step 5: Test
```bash
cd Chronir-iOS && swift test
```
Write new unit tests for the implementation. Fix any test failures.

### Step 6: Review
Run the `code-reviewer` agent on all changed files. Address any findings.

### Step 7: Simplify
Run the `code-simplifier` agent on all modified files to clean up implementation verbosity — reduce nesting, improve naming, simplify conditionals — while preserving exact functionality.

## Notes
- Always use design tokens from `DesignSystem/Tokens/`, never hardcode values
- Every new view needs previews
- Services must be protocol-based for testability
- AlarmKit is iOS 26 only — add availability checks where needed
