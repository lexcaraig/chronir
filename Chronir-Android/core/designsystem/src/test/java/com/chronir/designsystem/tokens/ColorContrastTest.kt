package com.chronir.designsystem.tokens

import androidx.compose.material3.ColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import org.junit.Assert.assertTrue
import org.junit.Test

/** WCAG 2.x contrast guards for the generated token roles (text 4.5:1, UI components 3:1). */
class ColorContrastTest {

    private fun contrast(a: Color, b: Color): Double {
        val (hi, lo) = listOf(a.luminance(), b.luminance()).sortedDescending()
        return (hi + 0.05) / (lo + 0.05)
    }

    private fun assertContrast(name: String, fg: Color, bg: Color, min: Double) {
        val ratio = contrast(fg, bg)
        assertTrue("$name is ${"%.2f".format(ratio)}:1, needs $min:1", ratio >= min)
    }

    private fun assertScheme(mode: String, s: ColorScheme) {
        assertContrast("$mode onPrimary/primary", s.onPrimary, s.primary, 4.5)
        assertContrast("$mode onSecondary/secondary", s.onSecondary, s.secondary, 4.5)
        assertContrast("$mode onTertiary/tertiary", s.onTertiary, s.tertiary, 4.5)
        assertContrast("$mode onError/error", s.onError, s.error, 4.5)
        assertContrast("$mode onSurface/surface", s.onSurface, s.surface, 4.5)
        assertContrast("$mode onSurfaceVariant/surfaceVariant", s.onSurfaceVariant, s.surfaceVariant, 4.5)
        assertContrast("$mode onSecondaryContainer/secondaryContainer", s.onSecondaryContainer, s.secondaryContainer, 4.5)
        assertContrast("$mode onPrimaryContainer/primaryContainer", s.onPrimaryContainer, s.primaryContainer, 4.5)
        assertContrast("$mode onErrorContainer/errorContainer", s.onErrorContainer, s.errorContainer, 4.5)
        assertContrast("$mode inverseOnSurface/inverseSurface", s.inverseOnSurface, s.inverseSurface, 4.5)
        assertContrast("$mode error/surface", s.error, s.surface, 4.5)
        assertContrast("$mode primary/surface (UI)", s.primary, s.surface, 3.0)
        assertContrast("$mode outline/surface (UI)", s.outline, s.surface, 3.0)
        assertContrast("$mode outline/surfaceVariant (UI)", s.outline, s.surfaceVariant, 3.0)
        listOf(
            s.surfaceContainerLowest,
            s.surfaceContainerLow,
            s.surfaceContainer,
            s.surfaceContainerHigh,
            s.surfaceContainerHighest
        ).forEach { assertContrast("$mode onSurface/surfaceContainer*", s.onSurface, it, 4.5) }
    }

    @Test
    fun lightSchemePasses() = assertScheme("light", ColorSchemeTokens.Light)

    @Test
    fun darkSchemePasses() = assertScheme("dark", ColorSchemeTokens.Dark)

    @Test
    fun extendedTextRolesPass() {
        listOf(
            "light" to Pair(ExtendedColorTokens.Light, ColorSchemeTokens.Light),
            "dark" to Pair(ExtendedColorTokens.Dark, ColorSchemeTokens.Dark)
        ).forEach { (mode, pair) ->
            val (c, s) = pair
            listOf(s.surface, s.surfaceVariant).forEach { bg ->
                assertContrast("$mode textSecondary", c.textSecondary, bg, 4.5)
                assertContrast("$mode textTertiary", c.textTertiary, bg, 4.5)
                assertContrast("$mode textError", c.textError, bg, 4.5)
                assertContrast("$mode textWarning", c.textWarning, bg, 4.5)
            }
            assertContrast("$mode onPrimary/primary", c.onPrimary, s.primary, 4.5)
        }
    }

    @Test
    fun badgePairsPass() {
        with(ColorTokens) {
            listOf(
                BadgeOneTimeForeground to BadgeOneTimeBackground,
                BadgeWeeklyForeground to BadgeWeeklyBackground,
                BadgeMonthlyForeground to BadgeMonthlyBackground,
                BadgeAnnualForeground to BadgeAnnualBackground,
                BadgeCustomForeground to BadgeCustomBackground,
                BadgeWarningForeground to BadgeWarningBackground,
                BadgeSuccessForeground to BadgeSuccessBackground,
                BadgePendingForeground to BadgePendingBackground,
                BadgeErrorForeground to BadgeErrorBackground,
                BadgeInfoForeground to BadgeInfoBackground,
                BadgeNeutralForeground to BadgeNeutralBackground,
                BadgeHomeForeground to BadgeHomeBackground,
                BadgeHealthForeground to BadgeHealthBackground,
                BadgeFinanceForeground to BadgeFinanceBackground,
                BadgeVehicleForeground to BadgeVehicleBackground,
                BadgeWorkForeground to BadgeWorkBackground,
                BadgePersonalForeground to BadgePersonalBackground,
                BadgePetsForeground to BadgePetsBackground,
                BadgeSubscriptionsForeground to BadgeSubscriptionsBackground
            ).forEachIndexed { i, (fg, bg) -> assertContrast("badge pair #$i", fg, bg, 4.5) }

            assertContrast("firing textPrimary", FiringTextPrimary, FiringBackground, 4.5)
            assertContrast("firing textSecondary", FiringTextSecondary, FiringBackground, 4.5)
            assertContrast("firing onControl", FiringOnControl, FiringControlFill, 4.5)
            assertContrast("firing onPrimary", FiringOnPrimary, FiringPrimaryFill, 4.5)
        }
    }

    @Test
    fun touchTargetIsMaterialMinimum() {
        assertTrue(SpacingTokens.TouchMinTarget.value >= 48f)
    }

    @Test
    fun typographyMapsOneToOneToM3Roles() {
        val t = TypographyTokens.AppTypography
        assertTrue(t.displayLarge == TypographyTokens.DisplayLarge)
        assertTrue(t.displayMedium == TypographyTokens.DisplayMedium)
        assertTrue(t.displaySmall == TypographyTokens.DisplaySmall)
        assertTrue(TypographyTokens.Caption.fontSize.value >= TypographyTokens.MinimumFontSize)
        val compact = TypographyTokens.scaledTypography(0.85f)
        assertTrue(compact.labelSmall.fontSize.value >= TypographyTokens.MinimumFontSize)
    }
}
