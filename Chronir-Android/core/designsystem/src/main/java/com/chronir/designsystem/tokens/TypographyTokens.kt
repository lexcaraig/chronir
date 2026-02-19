package com.chronir.designsystem.tokens

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

// Values sourced from design-tokens/tokens/typography.json (Style Dictionary)
// See docs/design-system.md Section 3.3 for full spec

object TypographyTokens {
    // MARK: - Display

    val DisplayLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Bold,
        fontSize = 120.sp,
        lineHeight = 128.sp
    )

    val DisplayMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Bold,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp
    )

    val DisplaySmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Bold,
        fontSize = 36.sp,
        lineHeight = 44.sp
    )

    // MARK: - Headline

    val HeadlineLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.SemiBold,
        fontSize = 32.sp,
        lineHeight = 40.sp
    )

    val HeadlineMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.SemiBold,
        fontSize = 28.sp,
        lineHeight = 36.sp
    )

    val HeadlineSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp,
        lineHeight = 32.sp
    )

    // MARK: - Title

    val TitleLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp
    )

    val TitleMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 18.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp
    )

    val TitleSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 22.sp
    )

    // MARK: - Body

    val BodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    )

    val BodyMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp
    )

    val BodySmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp
    )

    // MARK: - Label

    val LabelLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    )

    val LabelMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp
    )

    val LabelSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp
    )

    // MARK: - Caption

    val Caption = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 10.sp,
        lineHeight = 14.sp
    )

    // MARK: - Spec-Aligned Aliases (design-system.md Section 3.3)

    val DisplayAlarm = DisplayLarge        // 120sp firing screen time
    val HeadlineTime = HeadlineLarge       // 32sp alarm card time
    val HeadlineTitle = HeadlineSmall      // 24sp screen titles
    val BodyPrimary = BodyLarge            // 16sp labels, descriptions
    val BodySecondary = BodyMedium         // 14sp metadata
    val CaptionCountdown = LabelLarge      // 14sp "Alarm in 6h 32m"
    val CaptionBadge = LabelMedium         // 12sp cycle type badges

    // MARK: - Material 3 Typography

    val AppTypography = Typography(
        displayLarge = DisplayMedium,      // M3 displayLarge = 57sp (not our 120sp alarm)
        displayMedium = DisplaySmall,
        headlineLarge = HeadlineLarge,
        headlineMedium = HeadlineMedium,
        headlineSmall = HeadlineSmall,
        titleLarge = TitleLarge,
        titleMedium = TitleMedium,
        titleSmall = TitleSmall,
        bodyLarge = BodyLarge,
        bodyMedium = BodyMedium,
        bodySmall = BodySmall,
        labelLarge = LabelLarge,
        labelMedium = LabelMedium,
        labelSmall = LabelSmall
    )

    fun scaledTypography(scale: Float): Typography {
        fun TextStyle.scaled() = copy(
            fontSize = fontSize * scale,
            lineHeight = lineHeight * scale
        )
        return Typography(
            displayLarge = DisplayMedium.scaled(),
            displayMedium = DisplaySmall.scaled(),
            headlineLarge = HeadlineLarge.scaled(),
            headlineMedium = HeadlineMedium.scaled(),
            headlineSmall = HeadlineSmall.scaled(),
            titleLarge = TitleLarge.scaled(),
            titleMedium = TitleMedium.scaled(),
            titleSmall = TitleSmall.scaled(),
            bodyLarge = BodyLarge.scaled(),
            bodyMedium = BodyMedium.scaled(),
            bodySmall = BodySmall.scaled(),
            labelLarge = LabelLarge.scaled(),
            labelMedium = LabelMedium.scaled(),
            labelSmall = LabelSmall.scaled()
        )
    }
}
