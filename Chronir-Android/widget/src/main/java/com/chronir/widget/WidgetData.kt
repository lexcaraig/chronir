package com.chronir.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.text.format.DateFormat
import com.chronir.model.Alarm
import com.chronir.services.WidgetEntryPoint
import dagger.hilt.android.EntryPointAccessors
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

internal fun widgetEntryPoint(context: Context): WidgetEntryPoint =
    EntryPointAccessors.fromApplication(context.applicationContext, WidgetEntryPoint::class.java)

/** Enabled alarms with an upcoming fire date, soonest first. */
internal suspend fun loadUpcomingAlarms(context: Context): List<Alarm> =
    widgetEntryPoint(context).alarmRepository().getEnabledAlarms().upcoming()

internal fun List<Alarm>.upcoming(): List<Alarm> {
    val now = System.currentTimeMillis()
    return filter { it.isEnabled && it.nextFireDate.toEpochMilli() > now }.sortedBy { it.nextFireDate }
}

/** Follows the device locale and its 12/24-hour setting, like the in-app times. */
internal fun Alarm.fireTimeText(context: Context): String {
    val skeleton = if (DateFormat.is24HourFormat(context)) "EEEMMMdHHmm" else "EEEMMMdhmma"
    val pattern = DateFormat.getBestDateTimePattern(Locale.getDefault(), skeleton)
    return nextFireDate.atZone(ZoneId.systemDefault()).format(DateTimeFormatter.ofPattern(pattern))
}

/** Opens the alarm in the app via the validated `chronir://alarm/{id}` deep link. */
internal fun openAlarmIntent(context: Context, alarm: Alarm): Intent =
    Intent(Intent.ACTION_VIEW, Uri.parse("chronir://alarm/${alarm.id}")).setPackage(context.packageName)
