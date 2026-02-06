package com.chronir.designsystem.tokens

import androidx.compose.ui.graphics.Color

// Values sourced from design-tokens/tokens/color.json (Style Dictionary)
// See docs/design-system.md Section 3.2 for full spec

object ColorTokens {
    // MARK: - Primitive

    val Amber500 = Color(0xFFFFB800)
    val Blue500 = Color(0xFF3B82F6)
    val Blue600 = Color(0xFF2563EB)
    val Blue700 = Color(0xFF1D4ED8)
    val Red400 = Color(0xFFF87171)
    val Red500 = Color(0xFFEF4444)
    val Green500 = Color(0xFF22C55E)
    val Purple500 = Color(0xFF8B5CF6)
    val Gray50 = Color(0xFFF8F9FA)
    val Gray100 = Color(0xFFF1F3F5)
    val Gray400 = Color(0xFF9CA3AF)
    val Gray800 = Color(0xFF1C1C1E)
    val Gray900 = Color(0xFF111111)
    val OffWhite = Color(0xFFF5F5F5)

    // MARK: - Accent

    val AccentPrimary = Blue500
    val AccentPrimaryHover = Blue600
    val AccentPrimaryDark = Blue700
    val AccentSecondary = Purple500

    // MARK: - Semantic

    val Success = Green500
    val Warning = Amber500
    val Error = Red500
    val Info = Blue500

    // MARK: - Surface (Dark theme — Chronir is dark-mode-first)

    val SurfacePrimary = Gray50
    val SurfaceElevated = Color.White
    val BackgroundPrimary = Gray800
    val BackgroundSecondary = Gray900
    val BackgroundTertiary = Color(0xFF2C2C2E)
    val SurfaceCard = Color(0xFF2C2C2E)

    // MARK: - Text

    val TextPrimary = Color.White
    val TextSecondary = Gray400
    val TextTertiary = Color(0xFF64748B)
    val TextDisabled = Color(0xFF475569)

    // MARK: - Border

    val BorderDefault = Color(0xFF334155)
    val BorderFocused = Blue500

    // MARK: - Alarm State

    val AlarmActiveBackground = Amber500
    val AlarmActiveForeground = Gray900
    val AlarmInactiveBackground = Gray100
    val AlarmInactiveForeground = Gray400

    // MARK: - Firing Screen

    val FiringBackground = Color.Black
    val FiringForeground = OffWhite

    // MARK: - Cycle Badges

    val BadgeWeekly = Blue500
    val BadgeMonthly = Amber500
    val BadgeAnnual = Red400
    val BadgeCustom = Purple500

    // MARK: - Action Buttons

    val ButtonSnooze = Amber500
    val ButtonDismiss = Green500
    val ButtonDestructive = Red500

    // MARK: - Material 3 Scheme Compat (used by ChronirTheme.kt)

    val Primary = Blue500
    val OnPrimary = Color.White
    val PrimaryContainer = Blue700
    val OnPrimaryContainer = Color.White
    val Secondary = Purple500
    val OnSecondary = Color.White
    val SecondaryContainer = Color(0xFF4A3780)
    val OnSecondaryContainer = Color.White
    val Tertiary = Amber500
    val OnTertiary = Gray900
    val TertiaryContainer = Color(0xFFCC9300)
    val OnTertiaryContainer = Gray900
    val OnError = Color.White
    val ErrorContainer = Color(0xFFF9DEDC)
    val OnErrorContainer = Color(0xFF410E0B)
    val Surface = Gray800
    val OnSurface = Color.White
    val SurfaceVariant = Color(0xFF2C2C2E)
    val OnSurfaceVariant = Gray400
    val Background = Gray900
    val OnBackground = Color.White
    val Outline = Color(0xFF334155)
    val OutlineVariant = Color(0xFF475569)

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
