package com.chronir.widget

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ColumnScope
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.semantics.contentDescription
import androidx.glance.semantics.semantics
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import com.chronir.designsystem.tokens.SpacingTokens
import com.chronir.designsystem.tokens.TypographyTokens
import com.chronir.model.Alarm
import kotlinx.coroutines.flow.map

/*
 * Widget colors: GlanceTheme defaults to the system's dynamic (Material You) widget palette on
 * API 31+, our minSdk. That is a deliberate choice: widgets sit on the wallpaper, and every pair used
 * here (onSurface / onSurfaceVariant / primary on widgetBackground) comes from that one coherent
 * system scheme, which the platform tunes for contrast in light and dark.
 */

/**
 * Responsive buckets: below the regular height we drop the header and tighten the padding.
 * Compact height = one AlarmRow (a 48dp Mark Done target) plus the compact frame padding on both
 * sides, so the row and its second line never clip. Keep in sync with minHeight in the widget info XML.
 */
internal val WidgetCompactSize = DpSize(
    110.dp, // token-exempt: launcher 2-cell width floor
    SpacingTokens.TouchMinTarget + SpacingTokens.XSmall * 2
)
internal val WidgetRegularSize = DpSize(180.dp, 110.dp) // token-exempt: launcher 3x2 cell floor

/** Per-instance widget state: the title of an alarm just marked done (cleared after a moment). */
internal val JustCompletedTitleKey = stringPreferencesKey("justCompletedTitle")

/**
 * Upcoming alarms, kept live for the lifetime of the widget session (data loaded once in
 * provideGlance would go stale while a session stays open). [initial] avoids an empty first frame.
 */
@Composable
internal fun rememberUpcomingAlarms(context: Context, initial: List<Alarm>): List<Alarm> {
    val flow = remember {
        widgetEntryPoint(context).alarmRepository().observeAlarms().map { alarms -> alarms.upcoming() }
    }
    val alarms by flow.collectAsState(initial = initial)
    return alarms
}

/**
 * Widget frame: system widget radius, dynamic background, and a tap anywhere outside a row opens the
 * app. The header (or the "Marked done" confirmation) is hidden at the compact size.
 */
@Composable
internal fun WidgetFrame(context: Context, header: String, content: @Composable ColumnScope.() -> Unit) {
    val compact = LocalSize.current.height < WidgetRegularSize.height
    val justCompleted = currentState(JustCompletedTitleKey)
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .appWidgetBackground()
            .background(GlanceTheme.colors.widgetBackground)
            .cornerRadius(android.R.dimen.system_app_widget_background_radius)
            .padding(if (compact) SpacingTokens.XSmall else SpacingTokens.CardPadding)
            .clickable(actionStartActivity(openAppIntent(context)))
    ) {
        if (justCompleted != null) {
            DoneConfirmation(context, justCompleted)
        } else if (!compact) {
            Text(
                text = header,
                maxLines = 1,
                style = TextStyle(
                    color = GlanceTheme.colors.onSurfaceVariant,
                    fontSize = TypographyTokens.LabelMedium.fontSize,
                    fontWeight = FontWeight.Medium
                )
            )
            Spacer(GlanceModifier.height(SpacingTokens.XXSmall))
        }
        content()
    }
}

/** Visible feedback after the check button: shown briefly by [MarkDoneAction]. */
@Composable
private fun DoneConfirmation(context: Context, title: String) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = GlanceModifier.fillMaxWidth()) {
        Image(
            provider = ImageProvider(R.drawable.ic_widget_check),
            contentDescription = null,
            colorFilter = ColorFilter.tint(GlanceTheme.colors.primary),
            modifier = GlanceModifier.size(SpacingTokens.Medium)
        )
        Spacer(GlanceModifier.width(SpacingTokens.XXSmall))
        Text(
            text = context.getString(R.string.widget_marked_done, title),
            maxLines = 1,
            style = TextStyle(
                color = GlanceTheme.colors.onSurface,
                fontSize = TypographyTokens.LabelMedium.fontSize,
                fontWeight = FontWeight.Medium
            )
        )
    }
    Spacer(GlanceModifier.height(SpacingTokens.XXSmall))
}

/** One alarm: tap the text to open it, tap the check to mark the upcoming occurrence done. */
@Composable
internal fun AlarmRow(context: Context, alarm: Alarm, emphasized: Boolean = false) {
    val target: Dp = SpacingTokens.TouchMinTarget
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = GlanceModifier.fillMaxWidth()
    ) {
        Column(
            verticalAlignment = Alignment.CenterVertically,
            modifier = GlanceModifier
                .defaultWeight()
                .fillMaxHeight()
                .clickable(actionStartActivity(openAlarmIntent(context, alarm)))
        ) {
            Text(
                text = alarm.title,
                maxLines = 1,
                style = TextStyle(
                    color = GlanceTheme.colors.onSurface,
                    fontWeight = FontWeight.Bold,
                    fontSize = if (emphasized) {
                        TypographyTokens.TitleMedium.fontSize
                    } else {
                        TypographyTokens.TitleSmall.fontSize
                    }
                )
            )
            Text(
                text = alarm.fireTimeText(context),
                maxLines = 1,
                style = TextStyle(
                    color = GlanceTheme.colors.onSurfaceVariant,
                    fontSize = TypographyTokens.LabelMedium.fontSize
                )
            )
        }
        Box(
            modifier = GlanceModifier
                .size(target)
                .clickable(
                    actionRunCallback<MarkDoneAction>(
                        actionParametersOf(
                            MarkDoneAction.AlarmIdKey to alarm.id,
                            MarkDoneAction.ExpectedFireDateKey to alarm.nextFireDate.toEpochMilli()
                        )
                    )
                )
                .semantics { contentDescription = context.getString(R.string.widget_mark_done, alarm.title) },
            contentAlignment = Alignment.Center
        ) {
            Image(
                provider = ImageProvider(R.drawable.ic_widget_check),
                contentDescription = null,
                colorFilter = ColorFilter.tint(GlanceTheme.colors.primary)
            )
        }
    }
}

/** Empty widget: the whole area opens the app (via [WidgetFrame]); the copy says so. */
@Composable
internal fun EmptyState(context: Context) {
    Column(modifier = GlanceModifier.fillMaxWidth().fillMaxHeight(), verticalAlignment = Alignment.CenterVertically) {
        Text(
            text = context.getString(R.string.widget_no_alarms),
            style = TextStyle(
                color = GlanceTheme.colors.onSurface,
                fontSize = TypographyTokens.TitleSmall.fontSize,
                fontWeight = FontWeight.Medium
            )
        )
        Text(
            text = context.getString(R.string.widget_open_app),
            style = TextStyle(
                color = GlanceTheme.colors.onSurfaceVariant,
                fontSize = TypographyTokens.LabelMedium.fontSize
            )
        )
    }
}

/** Launches the app's main activity (no dependency on the :app module). */
internal fun openAppIntent(context: Context): Intent =
    context.packageManager.getLaunchIntentForPackage(context.packageName)
        ?: Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER).setPackage(context.packageName)

/** Refreshes every Chronir widget instance (called on any alarm change and after Mark Done). */
suspend fun updateAllChronirWidgets(context: Context) {
    NextAlarmWidget().updateAll(context)
    AlarmListWidget().updateAll(context)
}
