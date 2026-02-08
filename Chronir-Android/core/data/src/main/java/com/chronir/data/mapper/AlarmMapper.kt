package com.chronir.data.mapper

import com.chronir.data.local.AlarmEntity
import com.chronir.model.Alarm
import com.chronir.model.CycleType
import com.chronir.model.DismissMethod
import com.chronir.model.PersistenceLevel
import com.chronir.model.Schedule
import com.chronir.model.SyncStatus
import com.chronir.model.TimezoneMode
import java.time.Instant
import java.time.LocalTime
import org.json.JSONArray
import org.json.JSONObject

fun AlarmEntity.toDomain(): Alarm {
    return Alarm(
        id = id,
        title = title,
        cycleType = CycleType.valueOf(cycleType),
        timeOfDay = LocalTime.of(timeOfDayHour, timeOfDayMinute),
        schedule = deserializeSchedule(scheduleJson, CycleType.valueOf(cycleType)),
        nextFireDate = Instant.ofEpochMilli(nextFireDate),
        lastFiredDate = lastFiredDate?.let { Instant.ofEpochMilli(it) },
        timezone = timezone,
        timezoneMode = TimezoneMode.valueOf(timezoneMode),
        isEnabled = isEnabled,
        snoozeCount = snoozeCount,
        persistenceLevel = PersistenceLevel.valueOf(persistenceLevel),
        dismissMethod = DismissMethod.valueOf(dismissMethod),
        preAlarmMinutes = preAlarmMinutes,
        colorTag = colorTag,
        iconName = iconName,
        syncStatus = SyncStatus.valueOf(syncStatus),
        ownerID = ownerID,
        sharedWith = deserializeStringList(sharedWithJson),
        note = note,
        createdAt = Instant.ofEpochMilli(createdAt),
        updatedAt = Instant.ofEpochMilli(updatedAt)
    )
}

fun Alarm.toEntity(): AlarmEntity {
    return AlarmEntity(
        id = id,
        title = title,
        cycleType = cycleType.name,
        timeOfDayHour = timeOfDay.hour,
        timeOfDayMinute = timeOfDay.minute,
        scheduleJson = serializeSchedule(schedule),
        nextFireDate = nextFireDate.toEpochMilli(),
        lastFiredDate = lastFiredDate?.toEpochMilli(),
        timezone = timezone,
        timezoneMode = timezoneMode.name,
        isEnabled = isEnabled,
        snoozeCount = snoozeCount,
        persistenceLevel = persistenceLevel.name,
        dismissMethod = dismissMethod.name,
        preAlarmMinutes = preAlarmMinutes,
        colorTag = colorTag,
        iconName = iconName,
        syncStatus = syncStatus.name,
        ownerID = ownerID,
        sharedWithJson = serializeStringList(sharedWith),
        note = note,
        createdAt = createdAt.toEpochMilli(),
        updatedAt = updatedAt.toEpochMilli()
    )
}

// region Schedule serialization

private fun serializeSchedule(schedule: Schedule): String {
    val json = JSONObject()
    when (schedule) {
        is Schedule.Weekly -> {
            json.put("type", "weekly")
            json.put("daysOfWeek", JSONArray(schedule.daysOfWeek))
            json.put("interval", schedule.interval)
        }
        is Schedule.MonthlyDate -> {
            json.put("type", "monthlyDate")
            json.put("dayOfMonth", schedule.dayOfMonth)
            json.put("interval", schedule.interval)
        }
        is Schedule.MonthlyRelative -> {
            json.put("type", "monthlyRelative")
            json.put("weekOfMonth", schedule.weekOfMonth)
            json.put("dayOfWeek", schedule.dayOfWeek)
            json.put("interval", schedule.interval)
        }
        is Schedule.Annual -> {
            json.put("type", "annual")
            json.put("month", schedule.month)
            json.put("dayOfMonth", schedule.dayOfMonth)
            json.put("interval", schedule.interval)
        }
        is Schedule.CustomDays -> {
            json.put("type", "customDays")
            json.put("intervalDays", schedule.intervalDays)
            json.put("startDate", schedule.startDate.toEpochMilli())
        }
    }
    return json.toString()
}

private fun deserializeSchedule(json: String, cycleType: CycleType): Schedule {
    if (json.isBlank()) {
        return defaultScheduleForCycleType(cycleType)
    }
    return try {
        val obj = JSONObject(json)
        when (obj.optString("type", cycleType.name.lowercase())) {
            "weekly" -> Schedule.Weekly(
                daysOfWeek = obj.getJSONArray("daysOfWeek").let { arr ->
                    (0 until arr.length()).map { arr.getInt(it) }
                },
                interval = obj.optInt("interval", 1)
            )
            "monthlyDate" -> Schedule.MonthlyDate(
                dayOfMonth = obj.getInt("dayOfMonth"),
                interval = obj.optInt("interval", 1)
            )
            "monthlyRelative" -> Schedule.MonthlyRelative(
                weekOfMonth = obj.getInt("weekOfMonth"),
                dayOfWeek = obj.getInt("dayOfWeek"),
                interval = obj.optInt("interval", 1)
            )
            "annual" -> Schedule.Annual(
                month = obj.getInt("month"),
                dayOfMonth = obj.getInt("dayOfMonth"),
                interval = obj.optInt("interval", 1)
            )
            "customDays" -> Schedule.CustomDays(
                intervalDays = obj.getInt("intervalDays"),
                startDate = Instant.ofEpochMilli(obj.getLong("startDate"))
            )
            else -> defaultScheduleForCycleType(cycleType)
        }
    } catch (_: Exception) {
        defaultScheduleForCycleType(cycleType)
    }
}

private fun defaultScheduleForCycleType(cycleType: CycleType): Schedule {
    return when (cycleType) {
        CycleType.WEEKLY -> Schedule.Weekly(daysOfWeek = listOf(2), interval = 1)
        CycleType.MONTHLY_DATE -> Schedule.MonthlyDate(dayOfMonth = 1, interval = 1)
        CycleType.MONTHLY_RELATIVE -> Schedule.MonthlyRelative(
            weekOfMonth = 1, dayOfWeek = 2, interval = 1
        )
        CycleType.ANNUAL -> Schedule.Annual(month = 1, dayOfMonth = 1, interval = 1)
        CycleType.CUSTOM_DAYS -> Schedule.CustomDays(
            intervalDays = 7, startDate = Instant.now()
        )
    }
}

// region String list serialization

private fun serializeStringList(list: List<String>): String {
    return JSONArray(list).toString()
}

private fun deserializeStringList(json: String): List<String> {
    if (json.isBlank()) return emptyList()
    return try {
        val arr = JSONArray(json)
        (0 until arr.length()).map { arr.getString(it) }
    } catch (_: Exception) {
        emptyList()
    }
}
