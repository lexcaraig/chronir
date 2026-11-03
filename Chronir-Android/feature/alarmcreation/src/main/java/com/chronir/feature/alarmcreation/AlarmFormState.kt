package com.chronir.feature.alarmcreation

import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.model.AlarmTemplate
import com.chronir.model.CycleType
import com.chronir.model.FollowUpInterval
import com.chronir.model.PersistenceLevel
import com.chronir.model.PreAlarmOffset
import com.chronir.model.Schedule
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.Month
import java.time.ZoneId

/**
 * Editable fields shared by the New Alarm and Edit Alarm screens. One state + one reducer
 * means both screens get the same controls, limits and tier gates (COMP-01).
 */
data class AlarmFormState(
    val title: String = "",
    val hour: Int = 8,
    val minute: Int = 0,
    val cycleType: CycleType = CycleType.WEEKLY,
    val persistenceLevel: PersistenceLevel = PersistenceLevel.NOTIFICATION_ONLY,
    val note: String = "",
    val selectedDays: Set<Int> = setOf(2),
    val dayOfMonth: Int = 1,
    val annualMonth: Int = LocalDate.now().monthValue,
    val annualDay: Int = LocalDate.now().dayOfMonth,
    val oneTimeDate: LocalDate = LocalDate.now().plusDays(1),
    val category: AlarmCategory? = null,
    val additionalTimes: List<LocalTime> = emptyList(),
    val preAlarmMinutes: Int = 0,
    val followUpInterval: FollowUpInterval = FollowUpInterval.THIRTY_MINUTES,
    val repeatInterval: Int = 1
) {
    /** Schedule for the selected cycle; shapes not editable in the form keep their defaults. */
    fun buildSchedule(): Schedule = when (cycleType) {
        CycleType.ONE_TIME -> Schedule.OneTime(
            fireDate = oneTimeDate.atTime(hour, minute).atZone(ZoneId.systemDefault()).toInstant()
        )
        CycleType.WEEKLY -> Schedule.Weekly(daysOfWeek = selectedDays.sorted(), interval = repeatInterval)
        CycleType.MONTHLY_DATE -> Schedule.MonthlyDate(dayOfMonth = dayOfMonth, interval = repeatInterval)
        CycleType.MONTHLY_RELATIVE -> Schedule.MonthlyRelative(weekOfMonth = 1, dayOfWeek = 2, interval = repeatInterval)
        CycleType.ANNUAL -> Schedule.Annual(month = annualMonth, dayOfMonth = annualDay, interval = repeatInterval)
        CycleType.CUSTOM_DAYS -> Schedule.CustomDays(intervalDays = 7, startDate = Instant.now())
    }

    /**
     * Applies the form onto [base] (the stored alarm when editing). Fields the form doesn't edit
     * — id, createdAt, timezone, sync state, lastFiredDate — are carried over unchanged.
     */
    fun applyTo(base: Alarm): Alarm = base.copy(
        title = title.trim(),
        cycleType = cycleType,
        timeOfDay = LocalTime.of(hour, minute),
        schedule = buildSchedule(),
        persistenceLevel = persistenceLevel,
        preAlarmMinutes = preAlarmMinutes,
        followUpIntervalMinutes = followUpInterval.minutes,
        additionalTimesOfDay = additionalTimes,
        colorTag = category?.colorTag,
        iconName = category?.iconKey,
        note = note.trim()
    )

    companion object {
        const val TITLE_MAX_LENGTH = 60
        const val NOTE_MAX_LENGTH = 500
        const val MAX_REPEAT_INTERVAL = 52

        /** Free tier may set pre-alarm warnings up to this many minutes; longer offsets need Plus. */
        const val FREE_PRE_ALARM_MAX_MINUTES = 30

        /** Offsets offered in the selector, in display order. */
        val STANDARD_PRE_ALARM_OFFSETS = listOf(
            PreAlarmOffset.NONE,
            PreAlarmOffset.FIFTEEN_MINUTES,
            PreAlarmOffset.THIRTY_MINUTES,
            PreAlarmOffset.ONE_HOUR,
            PreAlarmOffset.TWELVE_HOURS,
            PreAlarmOffset.ONE_DAY,
            PreAlarmOffset.ONE_WEEK
        )

        fun isPreAlarmLocked(minutes: Int, isPlusTier: Boolean): Boolean =
            !isPlusTier && minutes > FREE_PRE_ALARM_MAX_MINUTES

        /** Longest day a month can have (Feb allows 29; DateCalculator clamps in non-leap years). */
        fun maxDayOfMonth(month: Int): Int = Month.of(month).maxLength()

        fun fromAlarm(alarm: Alarm): AlarmFormState {
            val schedule = alarm.schedule
            return AlarmFormState(
                title = alarm.title,
                hour = alarm.timeOfDay.hour,
                minute = alarm.timeOfDay.minute,
                cycleType = alarm.cycleType,
                persistenceLevel = alarm.persistenceLevel,
                note = alarm.note,
                selectedDays = (schedule as? Schedule.Weekly)?.daysOfWeek?.toSet() ?: setOf(2),
                dayOfMonth = (schedule as? Schedule.MonthlyDate)?.dayOfMonth ?: 1,
                annualMonth = (schedule as? Schedule.Annual)?.month ?: 1,
                annualDay = (schedule as? Schedule.Annual)?.dayOfMonth ?: 1,
                oneTimeDate = (schedule as? Schedule.OneTime)?.fireDate
                    ?.atZone(ZoneId.systemDefault())?.toLocalDate()
                    ?: LocalDate.now().plusDays(1),
                category = AlarmCategory.fromColorTag(alarm.colorTag),
                additionalTimes = alarm.additionalTimesOfDay,
                preAlarmMinutes = alarm.preAlarmMinutes,
                followUpInterval = alarm.followUpInterval,
                repeatInterval = when (schedule) {
                    is Schedule.Weekly -> schedule.interval
                    is Schedule.MonthlyDate -> schedule.interval
                    is Schedule.MonthlyRelative -> schedule.interval
                    is Schedule.Annual -> schedule.interval
                    else -> 1
                }
            )
        }
    }
}

/** Every edit the form can make. Reduced by [AlarmFormState.reduce]. */
sealed interface AlarmFormEvent {
    data class TitleChanged(
        val title: String
    ) : AlarmFormEvent

    data class TimeChanged(
        val hour: Int,
        val minute: Int
    ) : AlarmFormEvent

    data class CycleTypeChanged(
        val cycleType: CycleType
    ) : AlarmFormEvent

    data class PersistenceToggled(
        val enabled: Boolean
    ) : AlarmFormEvent

    data class NoteChanged(
        val note: String
    ) : AlarmFormEvent

    data class DayToggled(
        val day: Int
    ) : AlarmFormEvent

    data class DayOfMonthChanged(
        val day: Int
    ) : AlarmFormEvent

    data class AnnualMonthChanged(
        val month: Int
    ) : AlarmFormEvent

    data class AnnualDayChanged(
        val day: Int
    ) : AlarmFormEvent

    data class OneTimeDateChanged(
        val date: LocalDate
    ) : AlarmFormEvent

    data class CategoryChanged(
        val category: AlarmCategory?
    ) : AlarmFormEvent

    data class PreAlarmChanged(
        val minutes: Int
    ) : AlarmFormEvent

    data class FollowUpChanged(
        val interval: FollowUpInterval
    ) : AlarmFormEvent

    data class RepeatIntervalChanged(
        val interval: Int
    ) : AlarmFormEvent

    data class AdditionalTimeAdded(
        val time: LocalTime
    ) : AlarmFormEvent

    data class AdditionalTimeChanged(
        val index: Int,
        val time: LocalTime
    ) : AlarmFormEvent

    data class AdditionalTimeRemoved(
        val index: Int
    ) : AlarmFormEvent

    data class TemplateLoaded(
        val template: AlarmTemplate
    ) : AlarmFormEvent
}

/**
 * Pure reducer with the tier gates applied, so ViewModels enforce them (AND-08) and the
 * rules are unit-testable. Gated edits (note, pre-alarm > 30 min on Free) return the
 * state unchanged; callers check [AlarmFormEvent.requiresPlus] to route to the paywall.
 */
fun AlarmFormState.reduce(event: AlarmFormEvent, isPlusTier: Boolean): AlarmFormState = when (event) {
    is AlarmFormEvent.TitleChanged ->
        if (event.title.length <= AlarmFormState.TITLE_MAX_LENGTH) copy(title = event.title) else this
    is AlarmFormEvent.TimeChanged -> copy(hour = event.hour, minute = event.minute)
    is AlarmFormEvent.CycleTypeChanged -> copy(cycleType = event.cycleType)
    is AlarmFormEvent.PersistenceToggled -> copy(
        persistenceLevel = if (event.enabled) PersistenceLevel.FULL else PersistenceLevel.NOTIFICATION_ONLY
    )
    is AlarmFormEvent.NoteChanged ->
        if (isPlusTier && event.note.length <= AlarmFormState.NOTE_MAX_LENGTH) copy(note = event.note) else this
    is AlarmFormEvent.DayToggled -> copy(
        selectedDays = when {
            event.day !in selectedDays -> selectedDays + event.day
            selectedDays.size > 1 -> selectedDays - event.day
            else -> selectedDays // at least one day stays selected
        }
    )
    is AlarmFormEvent.DayOfMonthChanged -> copy(dayOfMonth = event.day.coerceIn(1, 31))
    is AlarmFormEvent.AnnualMonthChanged -> {
        val month = event.month.coerceIn(1, 12)
        copy(annualMonth = month, annualDay = annualDay.coerceAtMost(AlarmFormState.maxDayOfMonth(month)))
    }
    is AlarmFormEvent.AnnualDayChanged ->
        copy(annualDay = event.day.coerceIn(1, AlarmFormState.maxDayOfMonth(annualMonth)))
    is AlarmFormEvent.OneTimeDateChanged -> copy(oneTimeDate = event.date)
    is AlarmFormEvent.CategoryChanged -> copy(category = event.category)
    is AlarmFormEvent.PreAlarmChanged ->
        if (AlarmFormState.isPreAlarmLocked(event.minutes, isPlusTier)) this else copy(preAlarmMinutes = event.minutes)
    is AlarmFormEvent.FollowUpChanged -> copy(followUpInterval = event.interval)
    is AlarmFormEvent.RepeatIntervalChanged ->
        copy(repeatInterval = event.interval.coerceIn(1, AlarmFormState.MAX_REPEAT_INTERVAL))
    is AlarmFormEvent.AdditionalTimeAdded ->
        if (event.time in additionalTimes) this else copy(additionalTimes = additionalTimes + event.time)
    is AlarmFormEvent.AdditionalTimeChanged ->
        if (event.index !in additionalTimes.indices || event.time in additionalTimes) {
            this
        } else {
            copy(additionalTimes = additionalTimes.toMutableList().apply { set(event.index, event.time) })
        }
    is AlarmFormEvent.AdditionalTimeRemoved ->
        if (event.index in additionalTimes.indices) {
            copy(additionalTimes = additionalTimes.toMutableList().apply { removeAt(event.index) })
        } else {
            this
        }
    is AlarmFormEvent.TemplateLoaded -> loadTemplate(event.template, isPlusTier)
}

/** True when [this] edit is a Plus feature the current tier can't use. */
fun AlarmFormEvent.requiresPlus(isPlusTier: Boolean): Boolean = when (this) {
    is AlarmFormEvent.PreAlarmChanged -> AlarmFormState.isPreAlarmLocked(minutes, isPlusTier)
    is AlarmFormEvent.NoteChanged -> !isPlusTier
    else -> false
}

private fun AlarmFormState.loadTemplate(template: AlarmTemplate, isPlusTier: Boolean): AlarmFormState {
    val schedule = template.schedule
    val annualMonth = (schedule as? Schedule.Annual)?.month ?: annualMonth
    return copy(
        title = template.name,
        cycleType = template.cycleType,
        hour = template.timeOfDay.hour,
        minute = template.timeOfDay.minute,
        persistenceLevel = template.persistenceLevel,
        preAlarmMinutes = if (AlarmFormState.isPreAlarmLocked(template.preAlarmMinutes, isPlusTier)) {
            AlarmFormState.FREE_PRE_ALARM_MAX_MINUTES
        } else {
            template.preAlarmMinutes
        },
        note = if (isPlusTier) template.note else "",
        category = template.category,
        selectedDays = (schedule as? Schedule.Weekly)?.daysOfWeek?.toSet() ?: selectedDays,
        dayOfMonth = (schedule as? Schedule.MonthlyDate)?.dayOfMonth ?: dayOfMonth,
        annualMonth = annualMonth,
        annualDay = ((schedule as? Schedule.Annual)?.dayOfMonth ?: annualDay)
            .coerceAtMost(AlarmFormState.maxDayOfMonth(annualMonth)),
        repeatInterval = when (schedule) {
            is Schedule.Weekly -> schedule.interval
            is Schedule.MonthlyDate -> schedule.interval
            is Schedule.Annual -> schedule.interval
            else -> repeatInterval
        }
    )
}
