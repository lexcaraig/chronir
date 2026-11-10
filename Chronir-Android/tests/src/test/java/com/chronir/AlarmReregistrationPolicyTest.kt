package com.chronir

import com.chronir.model.Alarm
import com.chronir.model.Schedule
import com.chronir.services.AlarmReregistrationPolicy
import com.chronir.services.AlarmScheduler
import com.chronir.services.DateCalculator
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Instant
import java.time.LocalTime
import java.time.ZoneId
import java.time.ZonedDateTime

class AlarmReregistrationPolicyTest {
    private class FakeScheduler : AlarmScheduler {
        val scheduled = mutableListOf<Alarm>()
        val cancelled = mutableListOf<String>()

        override fun schedule(alarm: Alarm) {
            scheduled += alarm
        }

        override fun cancel(alarmId: String) {
            cancelled += alarmId
        }
    }

    private val zone = ZoneId.of("America/New_York")
    private val scheduler = FakeScheduler()
    private val policy = AlarmReregistrationPolicy(DateCalculator(), scheduler)

    // Wednesday 2026-03-04 10:00 local
    private val now: Instant = ZonedDateTime.of(2026, 3, 4, 10, 0, 0, 0, zone).toInstant()

    private fun weekly(nextFireDate: Instant, snoozeCount: Int = 0) = Alarm(
        title = "Rent",
        timeOfDay = LocalTime.of(9, 0),
        schedule = Schedule.Weekly(daysOfWeek = listOf(4)), // iOS weekday 4 = Wednesday
        nextFireDate = nextFireDate,
        timezone = zone.id,
        snoozeCount = snoozeCount
    )

    @Test
    fun `overdue repeating alarm advances to the next occurrence instead of firing at boot`() {
        val missed = ZonedDateTime.of(2026, 3, 4, 9, 0, 0, 0, zone).toInstant()
        val changed = policy.reregister(listOf(weekly(missed)), now)

        val expected = ZonedDateTime.of(2026, 3, 11, 9, 0, 0, 0, zone).toInstant()
        assertEquals(listOf(expected), changed.map { it.nextFireDate })
        assertEquals(listOf(expected), scheduler.scheduled.map { it.nextFireDate })
    }

    @Test
    fun `future repeating alarm is scheduled as stored and not persisted again`() {
        val upcoming = ZonedDateTime.of(2026, 3, 11, 9, 0, 0, 0, zone).toInstant()
        val changed = policy.reregister(listOf(weekly(upcoming)), now)

        assertTrue(changed.isEmpty())
        assertEquals(listOf(upcoming), scheduler.scheduled.map { it.nextFireDate })
    }

    @Test
    fun `pending snooze keeps its fire date`() {
        val snoozeExpiry = now.plusSeconds(5 * 60)
        val changed = policy.reregister(listOf(weekly(snoozeExpiry, snoozeCount = 1)), now)

        assertTrue(changed.isEmpty())
        assertEquals(listOf(snoozeExpiry), scheduler.scheduled.map { it.nextFireDate })
        assertEquals(1, scheduler.scheduled.single().snoozeCount)
    }

    @Test
    fun `expired snooze advances and resets the snooze count`() {
        val expiredSnooze = now.minusSeconds(60)
        val changed = policy.reregister(listOf(weekly(expiredSnooze, snoozeCount = 2)), now)

        val expected = ZonedDateTime.of(2026, 3, 11, 9, 0, 0, 0, zone).toInstant()
        assertEquals(expected, changed.single().nextFireDate)
        assertEquals(0, changed.single().snoozeCount)
    }

    @Test
    fun `timezone change recomputes a stored fire date`() {
        val staleLocal = ZonedDateTime.of(2026, 3, 11, 9, 0, 0, 0, ZoneId.of("Asia/Tokyo")).toInstant()
        val changed = policy.reregister(listOf(weekly(staleLocal)), now)

        val expected = ZonedDateTime.of(2026, 3, 11, 9, 0, 0, 0, zone).toInstant()
        assertEquals(expected, changed.single().nextFireDate)
    }

    @Test
    fun `one-time alarm keeps its fire date even when overdue`() {
        val fireDate = now.minusSeconds(3600)
        val oneTime = Alarm(
            title = "Dentist",
            schedule = Schedule.OneTime(fireDate),
            nextFireDate = fireDate,
            timezone = zone.id
        )
        val changed = policy.reregister(listOf(oneTime), now)

        assertTrue(changed.isEmpty())
        assertEquals(listOf(fireDate), scheduler.scheduled.map { it.nextFireDate })
    }

    @Test
    fun `every enabled alarm is scheduled`() {
        val alarms = listOf(
            weekly(now.minusSeconds(60)),
            weekly(now.plusSeconds(60)),
            weekly(now.plusSeconds(120), snoozeCount = 1)
        )
        policy.reregister(alarms, now)

        assertEquals(alarms.map { it.id }, scheduler.scheduled.map { it.id })
        assertTrue(scheduler.cancelled.isEmpty())
    }
}
