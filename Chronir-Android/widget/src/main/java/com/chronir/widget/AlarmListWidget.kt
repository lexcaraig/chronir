package com.chronir.widget

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent

/** Upcoming alarms in a scrolling list, each with open-on-tap and Mark Done. */
class AlarmListWidget : GlanceAppWidget() {
    override val sizeMode = SizeMode.Responsive(setOf(WidgetCompactSize, WidgetRegularSize))

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val initial = runCatching { loadUpcomingAlarms(context) }.getOrDefault(emptyList())

        provideContent {
            GlanceTheme {
                val alarms = rememberUpcomingAlarms(context, initial)
                WidgetFrame(context, header = context.getString(R.string.widget_upcoming_alarms)) {
                    if (alarms.isEmpty()) {
                        EmptyState(context)
                    } else {
                        // Virtualized and scrollable, so no row is silently cut off at any size.
                        LazyColumn {
                            items(alarms, itemId = { it.id.hashCode().toLong() }) { alarm ->
                                AlarmRow(context, alarm)
                            }
                        }
                    }
                }
            }
        }
    }
}

class AlarmListWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = AlarmListWidget()
}
