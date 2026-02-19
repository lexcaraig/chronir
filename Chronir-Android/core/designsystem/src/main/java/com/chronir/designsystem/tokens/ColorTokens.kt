package com.chronir.designsystem.tokens

import androidx.compose.ui.graphics.Color

// Values sourced from design-tokens/tokens/color.json (Style Dictionary)
// See docs/design-system.md Section 3.2 for full spec

object ColorTokens {
    // MARK: - Primitive — Neutral (Light scale)

    val Neutral0 = Color(0xFFFFFFFF)
    val Neutral100 = Color(0xFFF8F8F8)
    val Neutral200 = Color(0xFFF0F1F2)
    val Neutral300 = Color(0xFFDDDEE1)
    val Neutral400 = Color(0xFFB7B9BE)
    val Neutral500 = Color(0xFF8C8F97)
    val Neutral600 = Color(0xFF7D818A)
    val Neutral700 = Color(0xFF6B6E76)
    val Neutral800 = Color(0xFF505258)
    val Neutral900 = Color(0xFF3B3D42)
    val Neutral1000 = Color(0xFF292A2E)
    val Neutral1100 = Color(0xFF1E1F21)

    // MARK: - Primitive — Dark Neutral (Dark scale)

    val DarkNeutralNeg100 = Color(0xFF111213)
    val DarkNeutral0 = Color(0xFF18191A)
    val DarkNeutral100 = Color(0xFF1F1F21)
    val DarkNeutral200 = Color(0xFF242528)
    val DarkNeutral250 = Color(0xFF2B2C2F)
    val DarkNeutral300 = Color(0xFF303134)
    val DarkNeutral350 = Color(0xFF3D3F43)
    val DarkNeutral400 = Color(0xFF4B4D51)
    val DarkNeutral500 = Color(0xFF63666B)
    val DarkNeutral600 = Color(0xFF7E8188)
    val DarkNeutral700 = Color(0xFF96999E)
    val DarkNeutral800 = Color(0xFFA9ABAF)
    val DarkNeutral900 = Color(0xFFBFC1C4)
    val DarkNeutral1000 = Color(0xFFCECFD2)
    val DarkNeutral1100 = Color(0xFFE2E3E4)

    // MARK: - Primitive — Brand Colors

    val Amber500 = Color(0xFFFFB800)
    val Red400 = Color(0xFFF87171)
    val Red500 = Color(0xFFEF4444)
    val OffWhite = Color(0xFFF5F5F5)

    // MARK: - Accent

    val AccentPrimary = Neutral900           // #3B3D42
    val AccentDestructive = Red400           // #F87171

    // MARK: - Semantic

    val Success = Color(0xFF22C55E)
    val Error = Red500
    val Warning = Amber500

    // MARK: - Light Theme Surface

    val LightBackground = Neutral0                // #FFFFFF
    val LightBackgroundSecondary = Neutral100     // #F8F8F8
    val LightSurfaceCard = Neutral0               // #FFFFFF
    val LightSurfaceElevated = Neutral0           // #FFFFFF
    val LightSurfaceHover = Neutral200            // #F0F1F2
    val LightSurfacePressed = Neutral300          // #DDDEE1
    val LightTextPrimary = Neutral1100            // #1E1F21
    val LightTextSecondary = Neutral700           // #6B6E76
    val LightTextTertiary = Neutral500            // #8C8F97
    val LightTextDisabled = Neutral400            // #B7B9BE
    val LightBorderDefault = Neutral300           // #DDDEE1
    val LightBorderFocused = Neutral900           // #3B3D42
    val LightIconPrimary = Neutral900             // #3B3D42
    val LightIconSecondary = Neutral600           // #7D818A

    // MARK: - Dark Theme Surface

    val DarkBackground = DarkNeutral200           // #242528
    val DarkBackgroundSecondary = DarkNeutral100  // #1F1F21
    val DarkSurfaceCard = DarkNeutral300          // #303134
    val DarkSurfaceElevated = DarkNeutral100      // #1F1F21
    val DarkSurfaceHover = DarkNeutral350         // #3D3F43
    val DarkSurfacePressed = DarkNeutral400       // #4B4D51
    val DarkTextPrimary = DarkNeutral1100         // #E2E3E4
    val DarkTextSecondary = DarkNeutral700        // #96999E
    val DarkTextTertiary = DarkNeutral500         // #63666B
    val DarkTextDisabled = DarkNeutral400         // #4B4D51
    val DarkBorderDefault = DarkNeutral300        // #303134
    val DarkBorderFocused = DarkNeutral700        // #96999E
    val DarkIconPrimary = DarkNeutral900          // #BFC1C4
    val DarkIconSecondary = DarkNeutral600        // #7E8188

    // MARK: - Semantic Surface (non-theme-specific)

    val SurfacePrimary = Neutral100               // #F8F8F8
    val SurfaceElevated = Neutral0                // #FFFFFF

    // MARK: - Runtime aliases (dark-mode defaults for components that don't use MaterialTheme)

    val TextPrimary = DarkTextPrimary
    val TextSecondary = DarkTextSecondary
    val TextTertiary = DarkTextTertiary
    val TextDisabled = DarkTextDisabled
    val BorderDefault = DarkBorderDefault
    val BorderFocused = DarkBorderFocused
    val BackgroundPrimary = DarkBackground
    val BackgroundSecondary = DarkBackgroundSecondary
    val BackgroundTertiary = DarkSurfaceCard
    val SurfaceCard = DarkSurfaceCard

    // MARK: - Alarm State

    val AlarmActiveBackground = Amber500          // #FFB800
    val AlarmActiveForeground = Neutral1100       // #1E1F21
    val AlarmInactiveBackground = Neutral200      // #F0F1F2
    val AlarmInactiveForeground = Neutral500      // #8C8F97

    // MARK: - Firing Screen

    val FiringBackground = DarkNeutralNeg100      // #111213
    val FiringForeground = OffWhite               // #F5F5F5

    // MARK: - Cycle Badges (neutral palette)

    val BadgeOneTime = Neutral900                 // #3B3D42
    val BadgeWeekly = Neutral900                  // #3B3D42
    val BadgeMonthly = Neutral800                 // #505258
    val BadgeAnnual = Neutral800                  // #505258
    val BadgeCustom = Neutral800                  // #505258

    // MARK: - Category Colors (neutral — categories use accent tints)

    val CategoryHome = Neutral900
    val CategoryHealth = Neutral900
    val CategoryFinance = Neutral900
    val CategoryVehicle = Neutral800
    val CategoryWork = Neutral800
    val CategoryPersonal = Neutral800
    val CategoryPets = Neutral800
    val CategorySubscriptions = Neutral800

    // MARK: - Action Buttons (neutral palette)

    val ButtonSnooze = Neutral800                 // #505258
    val ButtonDismiss = Neutral800                // #505258
    val ButtonDestructive = Red500                // #EF4444

    // MARK: - Material 3 Scheme Compat — Dark (used by ChronirTheme.kt)

    val Primary = Neutral900                      // #3B3D42
    val OnPrimary = Color.White
    val PrimaryContainer = Neutral800             // #505258
    val OnPrimaryContainer = DarkNeutral1100      // #E2E3E4
    val Secondary = Neutral800                    // #505258
    val OnSecondary = Color.White
    val SecondaryContainer = DarkNeutral300       // #303134
    val OnSecondaryContainer = DarkNeutral1100    // #E2E3E4
    val Tertiary = Amber500                       // #FFB800
    val OnTertiary = Neutral1100                  // #1E1F21
    val TertiaryContainer = Color(0xFFCC9300)
    val OnTertiaryContainer = Neutral1100
    val OnError = Color.White
    val ErrorContainer = Color(0xFFF9DEDC)
    val OnErrorContainer = Color(0xFF410E0B)
    val Surface = DarkNeutral200                  // #242528
    val OnSurface = DarkNeutral1100               // #E2E3E4
    val SurfaceVariant = DarkNeutral300           // #303134
    val OnSurfaceVariant = DarkNeutral700         // #96999E
    val Background = DarkNeutral200               // #242528
    val OnBackground = DarkNeutral1100            // #E2E3E4
    val Outline = DarkNeutral300                  // #303134
    val OutlineVariant = DarkNeutral400           // #4B4D51

    // Backward compat aliases
    val AlarmActive = AlarmActiveBackground
    val AlarmInactive = AlarmInactiveForeground
    val AlarmFiring = Red500
    val AlarmSnoozed = Amber500
    val CycleWeekly = BadgeWeekly
    val CycleMonthly = BadgeMonthly
    val CycleAnnual = BadgeAnnual
    val CycleCustom = BadgeCustom
}
