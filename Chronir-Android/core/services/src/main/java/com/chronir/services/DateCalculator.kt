package com.chronir.services

import com.chronir.model.Alarm
import com.chronir.model.Schedule
import java.time.DayOfWeek
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.YearMonth
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.temporal.ChronoUnit
import java.time.temporal.TemporalAdjusters
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DateCalculator @Inject constructor() {

    fun calculateNextFireDate(alarm: Alarm, from: Instant): Instant {
        val zoneId = ZoneId.of(alarm.timezone)
        val fromZoned = from.atZone(zoneId)
        val timeOfDay = alarm.timeOfDay

        val result = when (val schedule = alarm.schedule) {
            is Schedule.Weekly -> nextWeekly(
                from = fromZoned,
                daysOfWeek = schedule.daysOfWeek,
                interval = schedule.interval,
                timeOfDay = timeOfDay
            )
            is Schedule.MonthlyDate -> nextMonthlyDate(
                from = fromZoned,
                dayOfMonth = schedule.dayOfMonth,
                interval = schedule.interval,
                timeOfDay = timeOfDay
            )
            is Schedule.MonthlyRelative -> nextMonthlyRelative(
                from = fromZoned,
                weekOfMonth = schedule.weekOfMonth,
                dayOfWeek = schedule.dayOfWeek,
                interval = schedule.interval,
                timeOfDay = timeOfDay
            )
            is Schedule.Annual -> nextAnnual(
                from = fromZoned,
                month = schedule.month,
                dayOfMonth = schedule.dayOfMonth,
                interval = schedule.interval,
                timeOfDay = timeOfDay
            )
            is Schedule.CustomDays -> nextCustomDays(
                from = fromZoned,
                intervalDays = schedule.intervalDays,
                startDate = schedule.startDate,
                timeOfDay = timeOfDay
            )
        }

        return result.toInstant()
    }

    // region Weekly

    private fun nextWeekly(
        from: ZonedDateTime,
        daysOfWeek: List<Int>,
        interval: Int,
        timeOfDay: LocalTime
    ): ZonedDateTime {
        if (daysOfWeek.isEmpty()) return from

        val sortedDays = daysOfWeek.sorted()
        val currentWeekday = from.dayOfWeek.value // Monday=1..Sunday=7
        // Convert daysOfWeek from Sunday=1..Saturday=7 (iOS convention) to Monday=1..Sunday=7
        val javaDays = sortedDays.map { iosWeekdayToJavaDayOfWeek(it) }

        // Try to find a day later this week (or today if time hasn't passed)
        for (javaDow in javaDays.sortedBy { it.value }) {
            val daysUntil = (javaDow.value - currentWeekday + 7) % 7
            if (daysUntil > 0) {
                val candidate = from.toLocalDate().plusDays(daysUntil.toLong())
                    .atTime(timeOfDay)
                    .atZone(from.zone)
                if (candidate.toInstant().isAfter(from.toInstant())) {
                    return candidate
                }
            } else if (daysUntil == 0) {
                val candidate = from.toLocalDate().atTime(timeOfDay).atZone(from.zone)
                if (candidate.toInstant().isAfter(from.toInstant())) {
                    return candidate
                }
            }
        }

        // Next interval week's first matching day
        val startOfWeek = from.toLocalDate()
            .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
        val nextWeekStart = startOfWeek.plusWeeks(interval.toLong())
        val firstDow = javaDays.sortedBy { it.value }.first()
        val daysUntilFirst = (firstDow.value - nextWeekStart.dayOfWeek.value + 7) % 7
        val targetDate = nextWeekStart.plusDays(daysUntilFirst.toLong())

        return targetDate.atTime(timeOfDay).atZone(from.zone)
    }

    // region Monthly (by date)

    private fun nextMonthlyDate(
        from: ZonedDateTime,
        dayOfMonth: Int,
        interval: Int,
        timeOfDay: LocalTime
    ): ZonedDateTime {
        val currentYearMonth = YearMonth.from(from)

        // Try this month
        val clampedDay = clampDay(dayOfMonth, currentYearMonth)
        val candidate = LocalDate.of(currentYearMonth.year, currentYearMonth.month, clampedDay)
            .atTime(timeOfDay)
            .atZone(from.zone)
        if (candidate.toInstant().isAfter(from.toInstant())) {
            return candidate
        }

        // Move forward by interval months
        val nextYearMonth = currentYearMonth.plusMonths(interval.toLong())
        val nextClampedDay = clampDay(dayOfMonth, nextYearMonth)
        return LocalDate.of(nextYearMonth.year, nextYearMonth.month, nextClampedDay)
            .atTime(timeOfDay)
            .atZone(from.zone)
    }

    // region Monthly (relative)

    private fun nextMonthlyRelative(
        from: ZonedDateTime,
        weekOfMonth: Int,
        dayOfWeek: Int,
        interval: Int,
        timeOfDay: LocalTime
    ): ZonedDateTime {
        val javaDow = iosWeekdayToJavaDayOfWeek(dayOfWeek)
        val currentYearMonth = YearMonth.from(from)

        // Try this month
        val candidateDate = nthWeekdayOfMonth(weekOfMonth, javaDow, currentYearMonth)
        if (candidateDate != null) {
            val candidate = candidateDate.atTime(timeOfDay).atZone(from.zone)
            if (candidate.toInstant().isAfter(from.toInstant())) {
                return candidate
            }
        }

        // Move forward by interval months
        val nextYearMonth = currentYearMonth.plusMonths(interval.toLong())
        val nextDate = nthWeekdayOfMonth(weekOfMonth, javaDow, nextYearMonth)
            ?: return from // fallback (should not happen)
        return nextDate.atTime(timeOfDay).atZone(from.zone)
    }

    // region Annual

    private fun nextAnnual(
        from: ZonedDateTime,
        month: Int,
        dayOfMonth: Int,
        interval: Int,
        timeOfDay: LocalTime
    ): ZonedDateTime {
        val currentYear = from.year

        // Try this year
        val yearMonth = YearMonth.of(currentYear, month)
        val clampedDay = clampDay(dayOfMonth, yearMonth)
        val candidate = LocalDate.of(currentYear, month, clampedDay)
            .atTime(timeOfDay)
            .atZone(from.zone)
        if (candidate.toInstant().isAfter(from.toInstant())) {
            return candidate
        }

        // Next occurrence (interval years later)
        val nextYear = currentYear + interval
        val nextYearMonth = YearMonth.of(nextYear, month)
        val nextClampedDay = clampDay(dayOfMonth, nextYearMonth)
        return LocalDate.of(nextYear, month, nextClampedDay)
            .atTime(timeOfDay)
            .atZone(from.zone)
    }

    // region Custom Days

    private fun nextCustomDays(
        from: ZonedDateTime,
        intervalDays: Int,
        startDate: Instant,
        timeOfDay: LocalTime
    ): ZonedDateTime {
        if (intervalDays <= 0) return from

        val startLocal = startDate.atZone(from.zone).toLocalDate()
        val currentLocal = from.toLocalDate()

        val daysSinceStart = ChronoUnit.DAYS.between(startLocal, currentLocal)
        val cyclesPassed = if (daysSinceStart >= 0) daysSinceStart / intervalDays else 0
        val nextCycleDate = startLocal.plusDays((cyclesPassed + 1) * intervalDays)

        val candidate = nextCycleDate.atTime(timeOfDay).atZone(from.zone)
        if (candidate.toInstant().isAfter(from.toInstant())) {
            return candidate
        }
        // One more interval if the candidate already passed
        return nextCycleDate.plusDays(intervalDays.toLong())
            .atTime(timeOfDay)
            .atZone(from.zone)
    }

    // region Helpers

    /**
     * Converts iOS-style weekday (1=Sunday..7=Saturday) to java.time DayOfWeek (Monday=1..Sunday=7).
     */
    private fun iosWeekdayToJavaDayOfWeek(iosWeekday: Int): DayOfWeek {
        return when (iosWeekday) {
            1 -> DayOfWeek.SUNDAY
            2 -> DayOfWeek.MONDAY
            3 -> DayOfWeek.TUESDAY
            4 -> DayOfWeek.WEDNESDAY
            5 -> DayOfWeek.THURSDAY
            6 -> DayOfWeek.FRIDAY
            7 -> DayOfWeek.SATURDAY
            else -> DayOfWeek.MONDAY
        }
    }

    /**
     * Clamps the target day to the maximum number of days in the given month.
     * Handles month-end overflow (e.g., day 31 in February becomes 28/29).
     */
    private fun clampDay(day: Int, yearMonth: YearMonth): Int {
        return day.coerceAtMost(yearMonth.lengthOfMonth())
    }

    /**
     * Finds the Nth occurrence of a given weekday in the specified month.
     * weekOfMonth == -1 means last occurrence.
     */
    private fun nthWeekdayOfMonth(
        weekOfMonth: Int,
        dayOfWeek: DayOfWeek,
        yearMonth: YearMonth
    ): LocalDate? {
        if (weekOfMonth == -1) {
            // Last occurrence of dayOfWeek in the month
            val lastDay = yearMonth.atEndOfMonth()
            return lastDay.with(TemporalAdjusters.previousOrSame(dayOfWeek))
        }

        // Nth occurrence
        val firstOfMonth = yearMonth.atDay(1)
        val firstOccurrence = firstOfMonth.with(TemporalAdjusters.firstInMonth(dayOfWeek))
        val target = firstOccurrence.plusWeeks((weekOfMonth - 1).toLong())

        // Verify still in same month
        return if (YearMonth.from(target) == yearMonth) target else null
    }

    /**
     * Checks whether the given year is a leap year.
     */
    fun isLeapYear(year: Int): Boolean {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    /**
     * Returns the number of days in the given month and year.
     */
    fun daysInMonth(month: Int, year: Int): Int {
        return YearMonth.of(year, month).lengthOfMonth()
    }
}
