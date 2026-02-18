package com.chronir.widget

import android.content.Context
import android.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.chronir.data.local.ChronirDatabase
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

class NextAlarmWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val nextAlarm = loadNextAlarm(context)

        provideContent {
            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Next Alarm",
                    style = TextStyle(
                        color = ColorProvider(Color.WHITE),
                        fontSize = 12.sp
                    )
                )
                Spacer(GlanceModifier.height(4.dp))
                if (nextAlarm != null) {
                    Text(
                        text = nextAlarm.title,
                        style = TextStyle(
                            color = ColorProvider(Color.WHITE),
                            fontWeight = FontWeight.Bold,
                            fontSize = 16.sp
                        )
                    )
                    Spacer(GlanceModifier.height(2.dp))
                    Text(
                        text = nextAlarm.timeText,
                        style = TextStyle(
                            color = ColorProvider(Color.LTGRAY),
                            fontSize = 14.sp
                        )
                    )
                } else {
                    Text(
                        text = "No upcoming alarms",
                        style = TextStyle(
                            color = ColorProvider(Color.LTGRAY),
                            fontSize = 14.sp
                        )
                    )
                }
            }
        }
    }

    private suspend fun loadNextAlarm(context: Context): NextAlarmInfo? {
        return try {
            val db = ChronirDatabase.create(context)
            val enabled = db.alarmDao().getEnabled()

            val now = System.currentTimeMillis()
            val next = enabled
                .filter { it.nextFireDate > now }
                .minByOrNull { it.nextFireDate }
                ?: return null

            val instant = Instant.ofEpochMilli(next.nextFireDate)
            val zoned = instant.atZone(ZoneId.systemDefault())
            val formatter = DateTimeFormatter.ofPattern("EEE h:mm a")

            NextAlarmInfo(
                title = next.title,
                timeText = zoned.format(formatter)
            )
        } catch (_: Exception) {
            null
        }
    }

    private data class NextAlarmInfo(
        val title: String,
        val timeText: String
    )
}
