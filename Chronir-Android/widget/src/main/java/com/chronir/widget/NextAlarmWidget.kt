package com.chronir.widget

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent

/** Next upcoming alarm with an open-on-tap row and a Mark Done button. */
class NextAlarmWidget : GlanceAppWidget() {
    override val sizeMode = SizeMode.Responsive(setOf(WidgetCompactSize, WidgetRegularSize))

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val initial = runCatching { loadUpcomingAlarms(context) }.getOrDefault(emptyList())

        provideContent {
            GlanceTheme {
                val next = rememberUpcomingAlarms(context, initial).firstOrNull()
                WidgetFrame(context, header = context.getString(R.string.widget_next_alarm)) {
                    if (next != null) AlarmRow(context, next, emphasized = true) else EmptyState(context)
                }
            }
        }
    }
}
