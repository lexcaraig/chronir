package com.chronir.designsystem.atoms

import android.content.res.Configuration.UI_MODE_NIGHT_YES
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
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
import com.chronir.designsystem.tokens.ColorTokens
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

    fun toTextStyle(): TextStyle = when (this) {
        // Spec-aligned
        DisplayAlarm -> TypographyTokens.DisplayAlarm
        HeadlineTime -> TypographyTokens.HeadlineTime
        HeadlineTitle -> TypographyTokens.HeadlineTitle
        BodyPrimary -> TypographyTokens.BodyPrimary
        BodySecondary -> TypographyTokens.BodySecondary
        CaptionCountdown -> TypographyTokens.CaptionCountdown
        CaptionBadge -> TypographyTokens.CaptionBadge
        // Full scale
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
        style = style.toTextStyle(),
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
                color = ColorTokens.TextSecondary
            )
            ChronirText(text = "Alarm in 6h 32m", style = ChronirTextStyle.CaptionCountdown)
            ChronirText(
                text = "Weekly",
                style = ChronirTextStyle.CaptionBadge,
                color = ColorTokens.TextSecondary
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
