# Atomic design for native mobile: Building cross-platform design systems

Design tokens and atomic design methodology provide a proven framework for creating consistent, maintainable UI across iOS (SwiftUI) and Android (Jetpack Compose) applications. For Chronir, implementing atomic design means structuring components into five hierarchical levels—atoms, molecules, organisms, templates, and pages—while using design tokens as the sub-atomic foundation that ensures visual consistency across both platforms. Industry leaders like Spotify, Airbnb, and Booking.com have demonstrated that the optimal approach shares component APIs and design tokens while allowing platform-specific rendering that respects iOS and Android conventions.

## Design tokens form the foundation beneath atoms

Design tokens are the smallest functional units in a design system—**named entities storing visual attributes** like colors, typography, and spacing. Salesforce originated the concept, defining tokens as "visual design atoms" that replace hard-coded values with semantic, platform-agnostic definitions. Tokens sit beneath atoms in the atomic hierarchy, providing the raw values that UI components consume.

The recommended architecture uses three tiers. **Primitive tokens** represent raw values without semantic meaning (`blue-500: #3b82f6`). **Semantic tokens** reference primitives with contextual purpose (`color-primary: blue-500`). **Component tokens** apply values to specific UI elements (`button-background: color-primary`). This hierarchy enables global changes through a single source of truth while maintaining meaningful abstractions.

For Chronir, essential token categories include:

| Category         | Examples                              | iOS Format    | Android Format |
| ---------------- | ------------------------------------- | ------------- | -------------- |
| Colors           | `color-primary`, `color-alarm-active` | UIColor/Color | Color XML      |
| Typography       | `font-size-body`, `font-weight-bold`  | Font          | sp values      |
| Spacing          | `spacing-sm (8)`, `spacing-lg (24)`   | CGFloat       | dp values      |
| Border Radius    | `radius-sm (4)`, `radius-lg (16)`     | CGFloat       | dp values      |
| Animation Timing | `duration-fast (150ms)`               | TimeInterval  | ms values      |

**Style Dictionary** (Amazon) has become the industry standard for cross-platform token management. Define tokens once in JSON, then transform them into Swift extensions for iOS and Kotlin objects for Android. This toolchain integrates with Figma through Tokens Studio (formerly Figma Tokens), enabling designers to manage tokens visually while developers consume generated code.

## SwiftUI atomic design adapts web concepts to Apple's declarative framework

Atomic design translates naturally to SwiftUI's composition model, though several patterns differ from the web-based original. **Atoms** in SwiftUI include native primitives (`Text`, `Image`, `Button`) plus custom styled components applying design tokens. ViewModifiers function as "styling atoms"—reusable visual treatments encapsulating token applications.

```swift
struct PrimaryButton: View {
    var title: String
    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(DesignTokens.Typography.body)
                .foregroundColor(.white)
                .padding(DesignTokens.Spacing.medium)
                .background(DesignTokens.Colors.primary)
                .cornerRadius(DesignTokens.Radius.small)
        }
    }
}
```

**Molecules** combine atoms into functional units with single responsibilities—a `LabeledTextField` pairs a `Text` atom with a `TextField` atom. **Organisms** form complex interface sections like login forms or navigation headers, often serving as data injection points. **Templates** leverage SwiftUI's `@ViewBuilder` to create layout blueprints accepting content slots. **Pages** fill templates with real data, connecting to ViewModels.

The key SwiftUI-specific insight: use `@Binding` in atoms and molecules to keep them stateless, with `@State` ownership at the organism or page level. For theming, leverage SwiftUI's Environment system to inject design tokens throughout the view hierarchy.

Recommended folder structure for Chronir's iOS project:

```
Chronir/
├── DesignSystem/
│   ├── Tokens/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   └── Spacing.swift
│   ├── Atoms/
│   │   ├── PrimaryButton.swift
│   │   └── AlarmIcon.swift
│   ├── Molecules/
│   │   ├── TimePickerField.swift
│   │   └── AlarmToggleRow.swift
│   ├── Organisms/
│   │   ├── AlarmCard.swift
│   │   └── AlarmListHeader.swift
│   └── Templates/
│       └── AlarmDetailTemplate.swift
├── Views/Pages/
│   ├── AlarmListPage.swift
│   └── AlarmDetailPage.swift
└── ViewModels/
```

## Jetpack Compose embraces atomic design through Slot APIs and CompositionLocal

Compose's declarative nature aligns exceptionally well with atomic design principles. The **Slot API pattern** is fundamental—composables accept `@Composable` lambdas as parameters, enabling flexible composition where organisms slot in molecules and templates slot in organisms.

Thunderbird's Android app adopted atomic design via an Architecture Decision Record (ADR-0002), organizing components into `atom/`, `molecule/`, `organism/`, and `template/` packages within a `designsystem` module. This encapsulates Material 3 components within custom implementations, enabling app-wide consistency while maintaining platform-native appearance.

```kotlin
@Composable
fun LoginForm(
    email: String,
    password: String,
    onEmailChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onLoginClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.padding(16.dp)) {
        EmailTextField(value = email, onValueChange = onEmailChange)
        Spacer(modifier = Modifier.height(8.dp))
        PasswordTextField(value = password, onValueChange = onPasswordChange)
        Spacer(modifier = Modifier.height(16.dp))
        PrimaryButton(text = "Login", onClick = onLoginClick)
    }
}
```

For design tokens in Compose, use `CompositionLocal` to provide theme values throughout the tree. Create custom data classes for token groups (`ColorSystem`, `SpacingSystem`), expose them via `staticCompositionLocalOf`, and access through a theme object. This pattern extends MaterialTheme while maintaining type safety.

Material 3 components map cleanly to atomic levels: `Text`, `Icon`, and `Checkbox` are atoms; `Button`, `TextField`, and `ListItem` are molecules; `TopAppBar`, `NavigationDrawer`, and `ModalBottomSheet` are organisms; `Scaffold` serves as the primary template.

## Cross-platform strategy: Share APIs, allow platform-specific rendering

The industry consensus, exemplified by Booking.com and Spotify, favors **multi-platform** over cross-platform approaches. The distinction matters: multi-platform means supporting multiple platforms with intentional differences, not forcing identical appearance everywhere.

**Component mapping** between SwiftUI and Compose reveals structural similarities:

| SwiftUI           | Jetpack Compose                 | Purpose            |
| ----------------- | ------------------------------- | ------------------ |
| `VStack`          | `Column`                        | Vertical layout    |
| `HStack`          | `Row`                           | Horizontal layout  |
| `@State`          | `remember { mutableStateOf() }` | Local state        |
| `@Binding`        | Lambda callbacks                | Two-way binding    |
| `@Environment`    | `CompositionLocal`              | Environment values |
| `NavigationStack` | `NavHost`                       | Navigation         |

Lyft's approach uses **neutral naming conventions** that avoid platform-specific terminology. Instead of "navigation bar" (which means different things on iOS vs Android), use "Header." This enables documentation that serves both platforms without confusion.

For Chronir, embrace platform conventions for navigation patterns, system icons, and native controls (date/time pickers especially relevant for an alarm app). Enforce brand consistency for color palette, custom typography, alarm-specific components, and illustration style. **iOS blur effects** and **Android elevation** represent platform-specific tokens that should be documented as intentional variations.

Booking.com's **Design API** model stores foundational data centrally, converting to platform-specific tokens via automation. Their 7-step multi-platform process ensures components aren't announced as ready until complete on all platforms, preventing fragmented implementations.

## Documentation structure for a dual-platform design system

Effective design system documentation serves two audiences: designers and developers. Each component page should include anatomy diagrams, property tables with platform-specific defaults, code examples for both SwiftUI and Compose, accessibility requirements, and explicit do's and don'ts.

**Essential documentation sections for Chronir's design system:**

- **Getting Started**: Platform-specific installation, first component example
- **Foundations**: Design tokens, color system, typography scale, spacing rhythm
- **Component Library**: Organized by atomic level with dual-platform code examples
- **Patterns**: Alarm creation flow, time selection, notification states
- **Accessibility**: Per-component requirements including touch targets (44pt iOS, 48dp Android)

For living documentation, leverage built-in preview systems. SwiftUI's `#Preview` macro and Compose's `@Preview` annotation serve as inline component catalogs. For broader showcase needs, **Katalog** (Compose) and **StorybookKit** (iOS) provide Storybook-inspired catalog apps that can be distributed to stakeholders via TestFlight or Firebase App Distribution.

**Component documentation template:**

```markdown
# AlarmCard

## Overview

Displays a single alarm with time, label, toggle, and status indicator.

## Platform Considerations

| Aspect           | iOS (SwiftUI)     | Android (Compose) |
| ---------------- | ----------------- | ----------------- |
| Time format      | System preference | System preference |
| Toggle style     | Native Switch     | Material Switch   |
| Haptic on toggle | UIImpactFeedback  | HapticFeedback    |

## Properties (Shared API)

| Property   | Type        | Default  | Description     |
| ---------- | ----------- | -------- | --------------- |
| time       | DateTime    | required | Alarm time      |
| label      | String      | ""       | User label      |
| isEnabled  | Boolean     | true     | Toggle state    |
| repeatDays | [DayOfWeek] | []       | Repeat schedule |
```

## Practical recommendations for Chronir implementation

Start implementation by defining design tokens in JSON using Style Dictionary configuration with iOS-Swift and Android-Compose output targets. Establish primitive tokens for your brand colors and spacing scale, then create semantic tokens (`color-alarm-active`, `color-alarm-disabled`) that reference primitives.

Build atoms first—styled buttons, text variants, icons—applying tokens exclusively (never hard-coded values). Extract ViewModifiers (SwiftUI) for reusable styling patterns. Progress through molecules (time picker field, alarm toggle row) and organisms (alarm card, alarm list section) before defining templates.

For folder organization, keep the design system in a dedicated module or package that can be shared across feature modules. Pages live in feature folders, not the design system—they're consumers, not reusable components.

Document alongside implementation using preview annotations generously. Create multi-preview providers testing dark mode, accessibility text sizes, and different states (enabled, disabled, ringing). Build a catalog app target for each platform to distribute internally for design review.

## Conclusion

Atomic design methodology provides Chronir with a scalable architecture for maintaining UI consistency across iOS and Android. The critical insight from industry practice is treating design tokens as the true foundation—sub-atomic values that feed into atoms, enabling systematic theming and platform-appropriate rendering. Style Dictionary automates the token pipeline from Figma to generated code, while SwiftUI and Compose's declarative paradigms naturally accommodate atomic composition through ViewBuilders and Slot APIs respectively.

The multi-platform approach—sharing component APIs and design tokens while respecting platform conventions—balances brand consistency with native user experience. For an alarm app where users interact with time-sensitive controls, embracing platform-native pickers and accessibility patterns directly impacts usability. Document intentional platform differences explicitly, maintain parallel development across both codebases, and leverage built-in preview systems to create living documentation that evolves with the design system.
