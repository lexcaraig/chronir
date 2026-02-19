package com.chronir.designsystem.atoms

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.TypographyTokens

enum class ChronirTextStyle {
    // Spec-aligned (design-system.md Section 3.3)
    DisplayAlarm,
    HeadlineTime,
    HeadlineTitle,
    BodyPrimary,
    BodySecondary,
    CaptionCountdown,
    CaptionBadge,

    // Full Material-style scale
    DisplayLarge,
    DisplayMedium,
    DisplaySmall,
    HeadlineLarge,
    HeadlineMedium,
    HeadlineSmall,
    TitleLarge,
    TitleMedium,
    TitleSmall,
    BodyLarge,
    BodyMedium,
    BodySmall,
    LabelLarge,
    LabelMedium,
    LabelSmall,
    Caption;

    // Static fallback — only used outside a composable scope
    fun toTextStyle(): TextStyle = when (this) {
        DisplayAlarm -> TypographyTokens.DisplayAlarm
        HeadlineTime -> TypographyTokens.HeadlineTime
        HeadlineTitle -> TypographyTokens.HeadlineTitle
        BodyPrimary -> TypographyTokens.BodyPrimary
        BodySecondary -> TypographyTokens.BodySecondary
        CaptionCountdown -> TypographyTokens.CaptionCountdown
        CaptionBadge -> TypographyTokens.CaptionBadge
        DisplayLarge -> TypographyTokens.DisplayLarge
        DisplayMedium -> TypographyTokens.DisplayMedium
        DisplaySmall -> TypographyTokens.DisplaySmall
        HeadlineLarge -> TypographyTokens.HeadlineLarge
        HeadlineMedium -> TypographyTokens.HeadlineMedium
        HeadlineSmall -> TypographyTokens.HeadlineSmall
        TitleLarge -> TypographyTokens.TitleLarge
        TitleMedium -> TypographyTokens.TitleMedium
        TitleSmall -> TypographyTokens.TitleSmall
        BodyLarge -> TypographyTokens.BodyLarge
        BodyMedium -> TypographyTokens.BodyMedium
        BodySmall -> TypographyTokens.BodySmall
        LabelLarge -> TypographyTokens.LabelLarge
        LabelMedium -> TypographyTokens.LabelMedium
        LabelSmall -> TypographyTokens.LabelSmall
        Caption -> TypographyTokens.Caption
    }
}

/**
 * Resolves the ChronirTextStyle from MaterialTheme.typography so text scaling is applied.
 * DisplayAlarm and Caption fall back to static tokens since they have no M3 equivalent.
 */
@Composable
private fun ChronirTextStyle.resolve(): TextStyle {
    val typography = MaterialTheme.typography
    return when (this) {
        // Spec-aligned aliases resolve through their M3 mapping
        ChronirTextStyle.DisplayAlarm -> TypographyTokens.DisplayAlarm // 120sp — no M3 equivalent, stays unscaled
        ChronirTextStyle.HeadlineTime -> typography.headlineLarge
        ChronirTextStyle.HeadlineTitle -> typography.headlineSmall
        ChronirTextStyle.BodyPrimary -> typography.bodyLarge
        ChronirTextStyle.BodySecondary -> typography.bodyMedium
        ChronirTextStyle.CaptionCountdown -> typography.labelLarge
        ChronirTextStyle.CaptionBadge -> typography.labelMedium
        // Full M3 scale
        ChronirTextStyle.DisplayLarge -> typography.displayLarge
        ChronirTextStyle.DisplayMedium -> typography.displayMedium
        ChronirTextStyle.DisplaySmall -> typography.displayMedium // displaySmall maps to our DisplaySmall via AppTypography
        ChronirTextStyle.HeadlineLarge -> typography.headlineLarge
        ChronirTextStyle.HeadlineMedium -> typography.headlineMedium
        ChronirTextStyle.HeadlineSmall -> typography.headlineSmall
        ChronirTextStyle.TitleLarge -> typography.titleLarge
        ChronirTextStyle.TitleMedium -> typography.titleMedium
        ChronirTextStyle.TitleSmall -> typography.titleSmall
        ChronirTextStyle.BodyLarge -> typography.bodyLarge
        ChronirTextStyle.BodyMedium -> typography.bodyMedium
        ChronirTextStyle.BodySmall -> typography.bodySmall
        ChronirTextStyle.LabelLarge -> typography.labelLarge
        ChronirTextStyle.LabelMedium -> typography.labelMedium
        ChronirTextStyle.LabelSmall -> typography.labelSmall
        ChronirTextStyle.Caption -> TypographyTokens.Caption // 10sp — no M3 equivalent
    }
}

@Composable
fun ChronirText(
    text: String,
    modifier: Modifier = Modifier,
    style: ChronirTextStyle = ChronirTextStyle.BodyPrimary,
    color: Color = Color.Unspecified,
    maxLines: Int = Int.MAX_VALUE,
    overflow: TextOverflow = TextOverflow.Clip,
    textAlign: TextAlign? = null
) {
    Text(
        text = text,
        modifier = modifier,
        style = style.resolve(),
        color = color,
        maxLines = maxLines,
        overflow = overflow,
        textAlign = textAlign
    )
}

@Preview(name = "Spec-Aligned — Light", showBackground = true)
@Preview(name = "Spec-Aligned — Dark", showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Composable
private fun ChronirTextSpecPreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(16.dp)) {
            ChronirText(text = "12:00", style = ChronirTextStyle.DisplayAlarm)
            ChronirText(text = "3:45 PM", style = ChronirTextStyle.HeadlineTime)
            ChronirText(text = "Screen Title", style = ChronirTextStyle.HeadlineTitle)
            ChronirText(text = "Primary body text", style = ChronirTextStyle.BodyPrimary)
            ChronirText(
                text = "Secondary metadata",
                style = ChronirTextStyle.BodySecondary,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            ChronirText(text = "Alarm in 6h 32m", style = ChronirTextStyle.CaptionCountdown)
            ChronirText(
                text = "Weekly",
                style = ChronirTextStyle.CaptionBadge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Preview(name = "Large Font", showBackground = true, fontScale = 2f)
@Composable
private fun ChronirTextLargeFontPreview() {
    ChronirTheme(dynamicColor = false) {
        Column(modifier = Modifier.padding(16.dp)) {
            ChronirText(text = "Screen Title", style = ChronirTextStyle.HeadlineTitle)
            ChronirText(text = "Primary body text", style = ChronirTextStyle.BodyPrimary)
            ChronirText(text = "Caption badge", style = ChronirTextStyle.CaptionBadge)
        }
    }
}
