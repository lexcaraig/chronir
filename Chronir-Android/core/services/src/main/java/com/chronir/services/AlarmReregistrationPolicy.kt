package com.chronir.services

import com.chronir.model.Alarm
import com.chronir.model.Schedule
import java.time.Instant

/**
 * Re-registers every enabled alarm with the system after an event that invalidates AlarmManager's
 * registrations (boot, package update) or the stored `nextFireDate` itself (TIME_SET, TIMEZONE_CHANGED).
 *
 * Plain class so a JVM test can drive it with a fake [AlarmScheduler]. The receiver persists what this returns.
 */
class AlarmReregistrationPolicy(
    private val dateCalculator: DateCalculator,
    private val scheduler: AlarmScheduler
) {
    /**
     * Schedules each alarm and returns the alarms whose stored `nextFireDate` moved so the caller can persist them.
     *
     * - Repeating alarms are recomputed from [now], so an occurrence missed while the device was off advances to
     *   the next one instead of firing the moment the receiver runs.
     * - A snoozed alarm whose snooze has not expired keeps its `nextFireDate` (AE-05).
     * - A one-time alarm keeps its fire date; if it was missed it still alerts, which is what the user asked for.
     */
    fun reregister(enabledAlarms: List<Alarm>, now: Instant): List<Alarm> {
        val changed = mutableListOf<Alarm>()
        for (alarm in enabledAlarms) {
            val resolved = resolve(alarm, now)
            if (resolved.nextFireDate != alarm.nextFireDate) changed += resolved
            scheduler.schedule(resolved)
        }
        return changed
    }

    private fun resolve(alarm: Alarm, now: Instant): Alarm {
        if (alarm.schedule is Schedule.OneTime) return alarm
        val snoozeStillPending = alarm.snoozeCount > 0 && alarm.nextFireDate.isAfter(now)
        if (snoozeStillPending) return alarm
        val next = dateCalculator.calculateNextFireDate(alarm, now)
        return if (next == alarm.nextFireDate) alarm else alarm.copy(nextFireDate = next, snoozeCount = 0)
    }
}
