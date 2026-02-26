# INFRA-01: Design Tokens Web App — Design Review Fixes

**Priority:** P3
**Category:** Infrastructure / Design Quality
**Effort:** Medium (2-3 days)
**Platform:** Web (React — `design-tokens/docs/`)
**Source:** `/design-review design-tokens-web` audit (Phase 1-2)

---

## Description

The design tokens web app (`design-tokens/docs/src/`) has ~100+ design quality issues identified by a `/design-review` audit. Issues span accessibility violations, CSS/token mismatches, excessive inline styles, and anti-patterns. This ticket tracks fixing all findings.

## Issue Summary

| Category                       | Count | Severity |
| ------------------------------ | ----- | -------- |
| Hardcoded colors in components | 14    | HIGH     |
| CSS↔Token JSON mismatches      | 3     | HIGH     |
| `<a>` without href (a11y)      | 6     | HIGH     |
| Inline styles bypassing theme  | ~50+  | HIGH     |
| Inter font (anti-pattern)      | 1     | MEDIUM   |
| Hardcoded spacing              | 8     | MEDIUM   |
| Hardcoded typography           | 6     | MEDIUM   |
| Missing accessible labels      | ~10   | MEDIUM   |
| Hardcoded radius               | 3     | LOW      |
| Undersized touch target        | 1     | LOW      |

## Acceptance Criteria

### HIGH — Must Fix

- [ ] **A11y: Replace `<a onClick>` with `<button>`** in `App.jsx:75-110` — 6 navigation elements use `<a>` tags without `href`, breaking keyboard navigation and screen reader semantics
- [ ] **CSS `--radius-sm` mismatch**: `global.css` defines `--radius-sm: 10px` but `radius.json` defines `radius.sm: 8`. Align to `8px`
- [ ] **CSS `--color-success` mismatch**: `global.css` uses `#8A8B90` (gray) but `color.json` defines `green.500: #22C55E`. Either use the real token value or add a comment documenting the intentional desaturation
- [ ] **CSS `--color-warning` mismatch**: `global.css` uses `#96999E` (gray) but `color.json` defines `amber.500: #FFB800`. Same — align or document
- [ ] **Inline styles in `ScreensSection.jsx`**: Extract 30+ inline style objects to CSS classes. Screen renderers (`AlarmListScreen`, `AlarmFiringScreen`, `AlarmPendingScreen`, `AlarmCreationScreen`, `SettingsScreen`) are almost entirely inline — move to `global.css` or a dedicated `screens.css`
- [ ] **Inline styles in `ComponentPreview.jsx`**: The 74KB preview file has extensive inline styles. Extract to CSS classes
- [ ] **Inline styles in `FlatlayView.jsx`**: Flatlay renderers use inline `style={{ }}` for all layout. Extract to CSS
- [ ] **Hardcoded `#fff`/`#ddd`/`#444` in screen renderers**: Replace with CSS variables (`var(--text)`, `var(--border)`, etc.)

### MEDIUM — Should Fix

- [ ] **Replace Inter font**: `global.css:32` uses `'Inter'` as primary font — Impeccable flags this as an overused AI default. Switch to system font stack only: `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif` (or choose a more distinctive typeface)
- [ ] **Hardcoded spacing values**: Replace inline `gap: '24px'`, `padding: '32px 24px'`, `marginTop: 16` etc. in `ColorSection.jsx`, `FlatlayView.jsx`, `ScreensSection.jsx` with CSS variables (e.g., `var(--space-lg)`)
- [ ] **Hardcoded typography sizes**: Replace inline `fontSize: 12`, `fontSize: 14` etc. with CSS classes or variables
- [ ] **Add `aria-label` to color swatches**: Click-to-copy chips in `ColorSection.jsx` need accessible labels (e.g., `aria-label="Copy amber 500: #FFB800"`)
- [ ] **Add `<label>` to FAQ search input**: `FaqSection.jsx:254` uses placeholder-only labeling — add a visually-hidden `<label>` for WCAG 1.3.1
- [ ] **`ComponentPreview.jsx` `t` object mixes CSS vars and hex**: The token lookup object uses `var(--bg-card)` for some values and `resolvedLookup[...]` hex for others. Standardize on CSS variables for theme-aware values

### LOW — Nice to Have

- [ ] **Hardcoded radius values**: Replace inline `borderRadius: 6` in `ColorSection.jsx:128` and `borderRadius: 16` in screen renderers with `var(--radius)` / `var(--radius-sm)`
- [ ] **Theme toggle touch target**: `global.css` sets `.theme-toggle` to `26x26px` — increase to `44x44px` minimum for touch accessibility
- [ ] **Add skip-to-content link**: `App.jsx` has no skip navigation for keyboard users
- [ ] **Add CSS custom properties for spacing scale**: Define `--space-xxs: 4px` through `--space-xxl: 48px` in `:root` to mirror the token JSON, then use throughout

## Technical Approach

### Recommended Workflow (using `/design-review` Phase 3-4)

1. **Phase 3A — `/normalize`**: Run on the full `design-tokens/docs/src/` scope
    - Replace hardcoded values with CSS variables
    - Fix CSS↔Token JSON mismatches
    - Standardize `ComponentPreview.jsx` token approach
2. **Phase 3B — `/extract`**: Extract inline styles from the 3 worst offenders into CSS classes
    - `ScreensSection.jsx` → `screens.css` or classes in `global.css`
    - `ComponentPreview.jsx` → component preview CSS classes
    - `FlatlayView.jsx` → flatlay CSS classes
3. **Phase 4A — `/polish`**: Final pass on spacing consistency, typography, alignment
4. **Phase 4B — `/harden`**: A11y fixes (buttons, labels, skip nav, touch targets)
5. **Phase 5 — Re-audit**: Run `/design-audit design-tokens-web` to confirm zero violations

### Files to Modify

| File                                  | Changes                                                                                                                 |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `src/App.jsx`                         | Replace `<a>` with `<button>`, add skip nav                                                                             |
| `src/styles/global.css`               | Fix `--radius-sm`, `--color-success`, `--color-warning`, add spacing vars, remove Inter, add screen/preview CSS classes |
| `src/components/ScreensSection.jsx`   | Extract all inline styles to CSS classes                                                                                |
| `src/components/ComponentPreview.jsx` | Extract inline styles, standardize `t` object                                                                           |
| `src/components/FlatlayView.jsx`      | Extract inline styles to CSS classes                                                                                    |
| `src/components/ColorSection.jsx`     | Add `aria-label` to swatches, replace inline spacing                                                                    |
| `src/components/FaqSection.jsx`       | Add `<label>` for search input                                                                                          |

## Pre-Flight

- [ ] `cd design-tokens/docs && npm run dev` — verify app runs
- [ ] Read `docs/design-system.md` Section 3 for token reference
- [ ] Read `design-tokens/tokens/*.json` for source-of-truth values

## Post-Flight

- [ ] `cd design-tokens/docs && npm run build` — verify production build succeeds
- [ ] Visual check: light mode + dark mode both render correctly
- [ ] Run `/design-audit design-tokens-web` — zero HIGH/MEDIUM violations
- [ ] Run `code-simplifier` agent on all modified files

## References

- Audit source: `/design-review design-tokens-web` Phase 1-2 report
- Design system spec: `docs/design-system.md` Section 3 (Token System)
- Token JSON: `design-tokens/tokens/color.json`, `spacing.json`, `radius.json`, `typography.json`
- Impeccable plugin: `/normalize`, `/polish`, `/harden`, `/extract` commands
