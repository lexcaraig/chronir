# /design-audit

Audits the app for design token compliance, component styling consistency, and adherence to the Chronir design system spec (`docs/design-system.md`).

## Usage

```
/design-audit [platform]
```

- `/design-audit` — Audit iOS (default)
- `/design-audit ios` — Audit iOS only
- `/design-audit android` — Audit Android only
- `/design-audit all` — Audit both platforms

## Workflow

### Step 0: Load Design System Reference

Read the authoritative sources before auditing:

1. `docs/design-system.md` — Full spec (token values, component hierarchy, platform guidelines)
2. `design-tokens/tokens/*.json` — Source-of-truth token definitions
3. Platform token files:
   - iOS: `chronir/chronir/DesignSystem/Tokens/*.swift`
   - Android: `Chronir-Android/core/designsystem/src/main/java/com/chronir/android/core/designsystem/tokens/`

### Step 1: Hardcoded Value Detection

Search for raw/magic values that should use design tokens instead.

**Colors — find hardcoded hex, RGB, or Color literals:**
```bash
# iOS: Hardcoded colors outside DesignSystem/Tokens/
grep -rn "Color(red:\|Color(hex:\|Color(\"\|#[0-9A-Fa-f]\{6\}\|\.rgb(" chronir/chronir/ --include="*.swift" | grep -v "DesignSystem/Tokens/" | grep -v "Preview" | grep -v "Tests/"

# Android: Hardcoded colors outside tokens/
grep -rn "Color(0x\|Color(0xFF\|colorResource\|#[0-9A-Fa-f]\{6\}" Chronir-Android/ --include="*.kt" | grep -v "/tokens/" | grep -v "Test"
```

**Spacing — find raw numeric padding/spacing:**
```bash
# iOS: Raw CGFloat values in padding/spacing (should use SpacingTokens.*)
grep -rn "\.padding(\.\(all\|horizontal\|vertical\|leading\|trailing\|top\|bottom\)\{0,1\},\{0,1\} [0-9]" chronir/chronir/ --include="*.swift" | grep -v "DesignSystem/Tokens/" | grep -v "Preview" | grep -v "Tests/"

# Android: Raw dp values (should use spacing tokens)
grep -rn "[0-9]\+\.dp" Chronir-Android/ --include="*.kt" | grep -v "/tokens/" | grep -v "Test"
```

**Typography — find raw font sizes:**
```bash
# iOS: Hardcoded .font(.system(size:)) instead of TypographyTokens
grep -rn "\.font(.system(size:" chronir/chronir/ --include="*.swift" | grep -v "DesignSystem/Tokens/" | grep -v "Preview" | grep -v "Tests/"

# Android: Hardcoded .sp values instead of typography tokens
grep -rn "[0-9]\+\.sp" Chronir-Android/ --include="*.kt" | grep -v "/tokens/" | grep -v "Test"
```

**Corner Radius — find raw radius values:**
```bash
# iOS: Hardcoded cornerRadius instead of RadiusTokens
grep -rn "cornerRadius:\|\.cornerRadius(" chronir/chronir/ --include="*.swift" | grep -v "DesignSystem/Tokens/" | grep -v "Preview" | grep -v "Tests/"

# Android: Hardcoded RoundedCornerShape values
grep -rn "RoundedCornerShape(" Chronir-Android/ --include="*.kt" | grep -v "/tokens/" | grep -v "Test"
```

For each finding, classify as:
- **VIOLATION** — Value exists as a design token and must be replaced
- **ACCEPTABLE** — One-off value with no token equivalent (e.g., platform-specific system values, animation keyframes)

### Step 2: Component Naming Convention

Verify all design system components follow the `Chronir` prefix convention.

```bash
# iOS: Check DesignSystem/ for non-prefixed public structs
grep -rn "^struct " chronir/chronir/DesignSystem/ --include="*.swift" | grep -v "Chronir" | grep -v "Preview" | grep -v "_Previews" | grep -v "private"

# Android: Check designsystem/ for non-prefixed composables
grep -rn "@Composable\nfun " Chronir-Android/core/designsystem/ --include="*.kt" | grep -v "Chronir" | grep -v "Preview"
```

Cross-reference against the component inventory in `docs/design-system.md` Section 5:
- Atoms: `ChronirButton`, `ChronirText`, `ChronirBadge`, `ChronirIcon`, `ChronirToggle`
- Molecules: `AlarmTimeDisplay`, `AlarmToggleRow`, etc.
- Organisms: `AlarmCard`, `AlarmListSection`, etc.
- Templates: `FullScreenAlarmTemplate`, `ModalSheetTemplate`, etc.

Flag any components in `Features/` that duplicate design system atoms/molecules (e.g., a custom button that should use `ChronirButton`).

### Step 3: Atomic Design Hierarchy Compliance

Verify that the atomic design layer boundaries are respected:

1. **Atoms** should NOT import or reference other atoms/molecules/organisms
2. **Molecules** should compose atoms, NOT raw SwiftUI/Compose primitives where a Chronir atom exists
3. **Organisms** should compose molecules and atoms
4. **Templates** should define layout structure using organisms/molecules
5. **Feature views (Pages)** should use templates/organisms, NOT raw primitives for things covered by the design system

```bash
# iOS: Check if Feature views use raw Text() instead of ChronirText where appropriate
grep -rn "Text(" chronir/chronir/Features/ --include="*.swift" | grep -v "ChronirText" | grep -v "Preview" | grep -v "Tests/" | head -30

# iOS: Check if Feature views use raw Button() instead of ChronirButton
grep -rn "Button(" chronir/chronir/Features/ --include="*.swift" | grep -v "ChronirButton" | grep -v "Preview" | grep -v "Tests/" | head -30
```

Not every `Text()` or `Button()` is a violation — only flag cases where:
- The raw usage matches a design system component's purpose (primary/secondary/destructive buttons, styled labels)
- There's inconsistent styling between raw usage and design system components

### Step 4: Theme & Dark Mode Compliance

Verify consistent dark mode support:

```bash
# iOS: Check for Color.black/Color.white (should use adaptive tokens)
grep -rn "Color\.black\|Color\.white\|\.black\b\|\.white\b" chronir/chronir/ --include="*.swift" | grep -v "DesignSystem/Tokens/" | grep -v "Preview" | grep -v "Tests/" | grep -v "colorScheme"

# iOS: Check for UIColor references that bypass token system
grep -rn "UIColor(" chronir/chronir/ --include="*.swift" | grep -v "DesignSystem/Tokens/" | grep -v "Tests/"
```

Verify that:
- All screens/components support both light and dark mode
- No hardcoded light-mode-only or dark-mode-only colors in feature code
- Adaptive color tokens from `ColorTokens` are used for all surface/text colors
- The firing screen uses `ColorTokens.firingBackground`/`firingForeground` (always dark)

### Step 5: Token Sync Verification

Ensure generated token files match their JSON sources:

```bash
cd design-tokens && npm run build
```

Then diff the generated files against what's in the project:
```bash
diff design-tokens/build/ios/ chronir/chronir/DesignSystem/Tokens/ 2>/dev/null || echo "Manual token files (expected)"
```

Check that any manually-maintained token files (ColorTokens.swift, SpacingTokens.swift, etc.) have values matching `design-tokens/tokens/*.json`. Flag discrepancies.

### Step 6: Cycle Badge Color Consistency

The design system defines specific colors per cycle type (Section 3.2):
- **Weekly** → Blue (`ColorTokens.blue500`)
- **Monthly** → Amber (`ColorTokens.amber500`)
- **Annual** → Red/Coral (`ColorTokens.red400`)
- **Custom** → Purple (`ColorTokens.purple500`)
- **One-time** → Green (`ColorTokens.green500`)

```bash
# Find all cycle/category color assignments
grep -rn "weekly\|monthly\|annual\|custom\|oneTime\|one_time" chronir/chronir/ --include="*.swift" -i | grep -i "color\|background\|foreground\|badge" | grep -v "Tests/" | grep -v "Preview"
```

Verify that every place rendering cycle-type-specific colors uses the correct token.

### Step 7: Preview Coverage

Check that design system components have preview providers for both light and dark mode:

```bash
# iOS: Components without #Preview or PreviewProvider
for file in $(find chronir/chronir/DesignSystem/ -name "*.swift" ! -name "PreviewHelpers.swift" ! -name "*Tokens*" ! -name "ThemeEnvironment.swift"); do
  if ! grep -q "#Preview\|PreviewProvider" "$file"; then
    echo "MISSING PREVIEW: $file"
  fi
done
```

Flag any design system components (Atoms, Molecules, Organisms, Templates) missing previews.

### Step 8: Glass Effect Usage (iOS)

Verify Liquid Glass is applied consistently per the design system spec:

```bash
# Find all .glassEffect() usage
grep -rn "\.glassEffect\|\.glass\|GlassTokens" chronir/chronir/ --include="*.swift" | grep -v "Tests/"

# Check AdaptiveGlassContainer usage
grep -rn "AdaptiveGlassContainer\|adaptiveGlass" chronir/chronir/ --include="*.swift" | grep -v "Tests/"
```

Verify that:
- Cards use `GlassTokens` for glass level/radius
- Glass is applied through `AdaptiveGlassContainer` or the design system's glass modifier, not ad-hoc
- Fallback behavior exists for non-glass contexts (older iOS, Dark mode without glass)

### Step 9: Touch Target Compliance

Verify minimum touch targets per `SpacingTokens.touchMinTarget` (44pt iOS / 48dp Android):

```bash
# iOS: Look for explicit small frame sizes on interactive elements
grep -rn "\.frame(.*height:\s*[0-9]\|\.frame(.*width:\s*[0-9]" chronir/chronir/ --include="*.swift" | grep -v "Tests/" | grep -v "Preview"
```

Flag any interactive element (button, toggle, tappable row) with a frame smaller than the minimum touch target.

### Step 10: Generate Report

Output a structured audit report:

```
## Design Audit Report — [Platform]

### Summary: X violations, Y warnings, Z passes

### 1. Hardcoded Values
| Category    | Violations | Files Affected | Severity |
|-------------|-----------|----------------|----------|
| Colors      | N         | [list]         | HIGH     |
| Spacing     | N         | [list]         | MEDIUM   |
| Typography  | N         | [list]         | MEDIUM   |
| Radius      | N         | [list]         | LOW      |

### 2. Component Naming
- Missing `Chronir` prefix: [list or "None"]
- Duplicate components in Features: [list or "None"]

### 3. Atomic Design Hierarchy
- Layer violations: [list or "None"]
- Raw primitives where DS component exists: [list or "None"]

### 4. Dark Mode Compliance
- Hardcoded Color.black/white: [list or "None"]
- Non-adaptive colors in features: [list or "None"]

### 5. Token Sync
- Out-of-sync tokens: [list or "All in sync"]

### 6. Cycle Badge Colors
- Incorrect mappings: [list or "All correct"]

### 7. Preview Coverage
- Components missing previews: [list or "Full coverage"]

### 8. Glass Effect (iOS)
- Ad-hoc glass usage: [list or "All via design system"]
- Missing fallbacks: [list or "None"]

### 9. Touch Targets
- Undersized targets: [list or "All compliant"]

### Top Priority Fixes
1. [Most impactful violation with file:line]
2. [Second most impactful]
3. [Third most impactful]
...

### Verdict
[CLEAN: Design system fully compliant]
[NEEDS WORK: N violations to fix (X high, Y medium, Z low)]
```

## Rules

- **Do NOT auto-fix** — this is an audit-only command. Present findings for the user to review.
- Acceptable exceptions (don't flag these):
  - `PreviewHelpers.swift` and `#Preview` blocks can use hardcoded values
  - Test files can use any values
  - `DesignSystem/Tokens/` files define the tokens — they contain raw values by definition
  - System colors like `.clear`, `.primary`, `.secondary` (SwiftUI system colors) are fine
  - One-off animation values that have no token equivalent
- Severity levels:
  - **HIGH**: Hardcoded colors in feature views, wrong cycle badge colors, broken dark mode
  - **MEDIUM**: Hardcoded spacing, missing token usage for typography, raw primitives replacing DS components
  - **LOW**: Missing previews, naming convention issues, minor radius inconsistencies
- Cross-reference `docs/design-system.md` for any edge cases about what constitutes a violation
- If the user wants fixes applied, suggest running Impeccable's `/normalize` command on the affected areas — keep audit and fix as separate steps

## Follow-Up Commands (Impeccable Plugin)

After the audit, recommend these Impeccable plugin commands based on findings:

| Audit Finding | Recommended Command | Purpose |
|---|---|---|
| Hardcoded values, token violations | `/normalize` | Align code with design system tokens and patterns |
| Visual inconsistencies, spacing issues | `/polish` | Final pass on alignment, spacing, consistency |
| General UX/interaction state gaps | `/audit` (Impeccable's) | Broader UX quality checks (a11y, interaction states) |

Example flow:
1. `/design-audit` → Identifies 12 violations (5 hardcoded colors, 4 spacing, 3 naming)
2. `/normalize AlarmList` → Fixes the AlarmList feature to use design system tokens
3. `/polish AlarmList` → Final cleanup pass on the normalized code
