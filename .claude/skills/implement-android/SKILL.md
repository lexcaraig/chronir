# /implement-android

Focused Android implementation workflow. Takes a feature description, implements it in Jetpack Compose following project conventions, then lints, tests, and reviews.

## Usage

```
/implement-android [description]
```

Example: `/implement-android Add ChronirButton composable with primary and secondary variants`

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. All research and planning (Steps 1–2) happen inside plan mode. Use `ExitPlanMode` after Step 2 to get user approval before implementing.

### Step 1: Gather Context
Based on the description, read relevant files:
- `docs/technical-spec.md` — Architecture patterns
- `docs/design-system.md` — If UI-related
- `docs/data-schema.md` — If data-related
- Existing files in the target area of `Chronir-Android/`

### Step 2: Plan
Identify the implementation approach:
- Files to create or modify
- Which module: core/designsystem, core/model, core/data, core/services, feature/*, widget
- Dependencies on existing modules
- Preview requirements (Light/Dark, state variations)

Present a brief plan to the user.

### Step 3: Implement
Write code following Android conventions:
- **Architecture:** MVVM + Repository
- **ViewModels:** `@HiltViewModel` with `StateFlow`
- **DI:** Hilt (`@Inject constructor`, `@Provides`/`@Binds` in modules)
- **Design system:** Chronir- prefixed composables, use token values
- **Previews:** `@Preview` with Light + Dark mode, relevant state variations
- **Coroutines:** Structured concurrency with proper scope management

### Step 4: Write Unit Tests
Write new unit tests for the implementation:
- Use the `test-writer-fixer` agent for comprehensive test coverage
- Target 80%+ coverage on new code
- Cover happy path, edge cases, and error states

### Step 5: Quality Gate (MANDATORY — must pass before proceeding)
Run the full quality gate. **Do not skip any step. Do not proceed to review until all pass.**

```bash
cd Chronir-Android && ./gradlew ktlintFormat    # Auto-format
cd Chronir-Android && ./gradlew ktlintCheck     # Lint — must pass
cd Chronir-Android && ./gradlew test            # Unit tests — must all pass
cd Chronir-Android && ./gradlew assembleDebug   # Build — must compile
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
- **kotlin-lsp** — Use LSP features during implementation (Step 3) for go-to-definition, find-references, hover info, and diagnostics on Kotlin files
- **context7** — Look up latest Jetpack Compose/Room/Hilt documentation during planning (Step 1) when unsure about APIs
- **code-review** — Powers the review step (Step 6). Use `code-reviewer` agent on all changed files
- **code-simplifier** — Powers the simplification step (Step 7). Run on all modified files
- **security-guidance** — Consult during review for auth, data storage, and network security

## Notes
- Always use design tokens from `core/designsystem/.../tokens/`, never hardcode values
- Every new composable needs `@Preview` annotations
- Use Hilt for all dependency injection
- For alarm-related work, account for OEM battery killers and BootReceiver
