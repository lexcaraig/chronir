package com.chronir.designsystem.organisms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextAlign
import com.chronir.designsystem.atoms.ChronirBadge
import com.chronir.designsystem.atoms.ChronirText
import com.chronir.designsystem.atoms.ChronirTextStyle
import com.chronir.designsystem.molecules.HoldToCompleteButton
import com.chronir.designsystem.molecules.SnoozeInterval
import com.chronir.designsystem.molecules.SnoozeOptionBar
import com.chronir.designsystem.theme.ChronirPreview
import com.chronir.designsystem.theme.ChronirTheme
import com.chronir.designsystem.tokens.ColorTokens
import com.chronir.designsystem.tokens.RadiusTokens
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.tokens.TypographyTokens
import com.chronir.designsystem.util.rememberTimeFormatter
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import java.time.Instant
import java.time.LocalTime

/**
 * Full-screen firing UI. Always dark (ColorTokens.Firing*), independent of the app theme.
 *
 * Layout: the alarm details scroll in the upper area while the action zone (snooze + Dismiss) is
 * pinned to the bottom, so at 200% font the primary action can never be pushed off-screen. The time
 * shrinks to stay on one line.
 */
@Composable
fun AlarmFiringView(
    alarm: Alarm,
    onDismiss: () -> Unit,
    onSnooze: (SnoozeInterval) -> Unit,
    modifier: Modifier = Modifier,
    snoozeCount: Int = 0,
    onCustomSnooze: (() -> Unit)? = null,
    onSkip: (() -> Unit)? = null
) {
    val timeFormatter = rememberTimeFormatter()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(ColorTokens.FiringBackground)
            .safeDrawingPadding()
    ) {
        Column(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = SpacingTokens.Large, vertical = SpacingTokens.XLarge),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            ChronirText(
                text = alarm.title,
                style = ChronirTextStyle.HeadlineLarge,
                color = ColorTokens.FiringTextPrimary,
                textAlign = TextAlign.Center,
                modifier = Modifier.semantics { heading() }
            )

            Spacer(Modifier.height(SpacingTokens.Small))

            SingleLineAutoSizeText(
                text = alarm.timeOfDay.format(timeFormatter),
                style = TypographyTokens.DisplayAlarm,
                color = ColorTokens.FiringTextPrimary
            )

            Spacer(Modifier.height(SpacingTokens.Medium))

            ChronirBadge(
                label = cycleTypeLabel(alarm.cycleType),
                containerColor = cycleTypeBadgeBackground(alarm.cycleType),
                contentColor = cycleTypeBadgeForeground(alarm.cycleType)
            )

            if (alarm.note.isNotEmpty()) {
                Spacer(Modifier.height(SpacingTokens.Medium))
                ChronirText(
                    text = alarm.note,
                    style = ChronirTextStyle.BodySecondary,
                    color = ColorTokens.FiringTextSecondary,
                    textAlign = TextAlign.Center
                )
            }

            if (snoozeCount > 0) {
                Spacer(Modifier.height(SpacingTokens.Small))
                ChronirText(
                    text = "Snoozed $snoozeCount time${if (snoozeCount == 1) "" else "s"}",
                    style = ChronirTextStyle.BodySecondary,
                    color = ColorTokens.FiringWarning
                )
            }
        }

        // Pinned action zone: always on screen, whatever the font scale.
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = SpacingTokens.Large, end = SpacingTokens.Large, bottom = SpacingTokens.Large),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            SnoozeOptionBar(
                onSnooze = onSnooze,
                modifier = Modifier.fillMaxWidth(),
                containerColor = ColorTokens.FiringControlFill,
                contentColor = ColorTokens.FiringOnControl
            )

            if (onCustomSnooze != null) {
                FiringTextAction(text = "Custom snooze", onClick = onCustomSnooze)
            }

            Spacer(Modifier.height(SpacingTokens.Medium))

            if (alarm.isPersistent) {
                HoldToCompleteButton(
                    onComplete = onDismiss,
                    label = "Hold to Dismiss",
                    accessibilityActionLabel = "Dismiss alarm",
                    progressColor = ColorTokens.FiringControlProgress,
                    trackColor = ColorTokens.FiringControlFill,
                    contentColor = ColorTokens.FiringTextPrimary
                )
            } else {
                Button(
                    onClick = onDismiss,
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = SpacingTokens.FiringButtonZone),
                    shape = RoundedCornerShape(RadiusTokens.Lg),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = ColorTokens.FiringPrimaryFill,
                        contentColor = ColorTokens.FiringOnPrimary
                    )
                ) {
                    ChronirText(text = "Dismiss", style = ChronirTextStyle.TitleMedium)
                }
            }

            if (onSkip != null) {
                Spacer(Modifier.height(SpacingTokens.XSmall))
                FiringTextAction(text = "Skip this occurrence", onClick = onSkip)
            }
        }
    }
}

@Composable
private fun FiringTextAction(text: String, onClick: () -> Unit) {
    TextButton(
        onClick = onClick,
        modifier = Modifier.heightIn(min = SpacingTokens.TouchMinTarget),
        colors = ButtonDefaults.textButtonColors(contentColor = ColorTokens.FiringTextSecondary)
    ) {
        ChronirText(text = text, style = ChronirTextStyle.LabelLarge)
    }
}

/**
 * Renders [text] on one line at [style]'s size (including the user's font scale), shrinking only as
 * much as needed to fit the available width. Stand-in for `BasicText(autoSize = …)` (Compose 1.8+).
 */
@Composable
private fun SingleLineAutoSizeText(text: String, style: TextStyle, color: Color, modifier: Modifier = Modifier) {
    val measurer = rememberTextMeasurer()
    BoxWithConstraints(modifier = modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
        val maxWidthPx = constraints.maxWidth
        val fitted = remember(text, style, maxWidthPx, measurer) {
            val natural = measurer.measure(text, style, maxLines = 1, softWrap = false).size.width
            if (natural <= maxWidthPx || natural == 0) {
                style
            } else {
                // 2% headroom for glyph overhang
                style.copy(fontSize = style.fontSize * (maxWidthPx.toFloat() / natural * 0.98f))
            }
        }
        Text(text = text, style = fitted, color = color, maxLines = 1, softWrap = false)
    }
}

private val sampleAlarm = Alarm(
    title = "Morning Workout",
    cycleType = CycleType.WEEKLY,
    timeOfDay = LocalTime.of(10, 30),
    schedule = Schedule.Weekly(daysOfWeek = listOf(1), interval = 1),
    nextFireDate = Instant.now(),
    persistenceLevel = PersistenceLevel.FULL
)

@ChronirPreview
@Composable
private fun AlarmFiringViewPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmFiringView(
            alarm = sampleAlarm,
            onDismiss = {},
            onSnooze = {},
            onCustomSnooze = {},
            onSkip = {}
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmFiringViewWithNotePreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmFiringView(
            alarm = Alarm(
                title = "Pay Rent",
                cycleType = CycleType.MONTHLY_DATE,
                timeOfDay = LocalTime.of(9, 0),
                schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
                nextFireDate = Instant.now(),
                note = "Transfer to landlord account"
            ),
            onDismiss = {},
            onSnooze = {}
        )
    }
}

@ChronirPreview
@Composable
private fun AlarmFiringViewSnoozedPreview() {
    ChronirTheme(dynamicColor = false) {
        AlarmFiringView(
            alarm = sampleAlarm,
            onDismiss = {},
            onSnooze = {},
            snoozeCount = 2
        )
    }
}
