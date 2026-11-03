package com.chronir.feature.alarmcreation

import com.chronir.model.Alarm
import com.chronir.model.AlarmCategory
import com.chronir.model.AlarmTemplate
import com.chronir.model.CycleType
import com.chronir.model.Schedule
import com.chronir.model.SyncStatus
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Instant
import java.time.LocalTime

class AlarmFormStateTest {

    private val form = AlarmFormState()

    @Test
    fun freeTierCannotSelectPreAlarmOverThirtyMinutes() {
        val event = AlarmFormEvent.PreAlarmChanged(60)
        assertTrue(event.requiresPlus(isPlusTier = false))
        assertEquals(0, form.reduce(event, isPlusTier = false).preAlarmMinutes)
        assertEquals(30, form.reduce(AlarmFormEvent.PreAlarmChanged(30), isPlusTier = false).preAlarmMinutes)
    }

    @Test
    fun plusTierCanSelectAnyPreAlarmOffset() {
        val event = AlarmFormEvent.PreAlarmChanged(10080)
        assertFalse(event.requiresPlus(isPlusTier = true))
        assertEquals(10080, form.reduce(event, isPlusTier = true).preAlarmMinutes)
    }

    @Test
    fun editingRoundTripsStoredPreAlarmOffsetUnchanged() {
        val stored = Alarm(title = "Rent", preAlarmMinutes = 15)
        val saved = AlarmFormState.fromAlarm(stored).applyTo(stored)
        assertEquals(15, saved.preAlarmMinutes)

        // A Free user editing an alarm that already has a long offset keeps it when not edited.
        val longOffset = Alarm(title = "Insurance", preAlarmMinutes = 1440)
        val edited = AlarmFormState.fromAlarm(longOffset)
            .reduce(AlarmFormEvent.TitleChanged("Car insurance"), isPlusTier = false)
            .applyTo(longOffset)
        assertEquals(1440, edited.preAlarmMinutes)
    }

    @Test
    fun applyToPreservesFieldsTheFormDoesNotEdit() {
        val created = Instant.parse("2025-01-01T00:00:00Z")
        val stored = Alarm(
            title = "Meds",
            additionalTimesOfDay = listOf(LocalTime.of(20, 0)),
            createdAt = created,
            syncStatus = SyncStatus.SYNCED,
            timezone = "Asia/Manila"
        )
        val saved = AlarmFormState.fromAlarm(stored).applyTo(stored)
        assertEquals(stored.id, saved.id)
        assertEquals(created, saved.createdAt)
        assertEquals(SyncStatus.SYNCED, saved.syncStatus)
        assertEquals("Asia/Manila", saved.timezone)
        assertEquals(listOf(LocalTime.of(20, 0)), saved.additionalTimesOfDay)
    }

    @Test
    fun annualDayIsClampedToTheSelectedMonth() {
        val jan31 = form.copy(annualMonth = 1, annualDay = 31)
        assertEquals(29, jan31.reduce(AlarmFormEvent.AnnualMonthChanged(2), isPlusTier = false).annualDay)
        assertEquals(30, jan31.reduce(AlarmFormEvent.AnnualMonthChanged(4), isPlusTier = false).annualDay)
        val feb = form.copy(annualMonth = 2, annualDay = 1)
        assertEquals(29, feb.reduce(AlarmFormEvent.AnnualDayChanged(31), isPlusTier = false).annualDay)
    }

    @Test
    fun lastSelectedWeekdayCannotBeCleared() {
        val onlyMonday = form.copy(selectedDays = setOf(2))
        assertEquals(setOf(2), onlyMonday.reduce(AlarmFormEvent.DayToggled(2), isPlusTier = false).selectedDays)
        assertEquals(setOf(2, 4), onlyMonday.reduce(AlarmFormEvent.DayToggled(4), isPlusTier = false).selectedDays)
    }

    @Test
    fun noteIsPlusOnly() {
        val event = AlarmFormEvent.NoteChanged("Call landlord")
        assertTrue(event.requiresPlus(isPlusTier = false))
        assertEquals("", form.reduce(event, isPlusTier = false).note)
        assertEquals("Call landlord", form.reduce(event, isPlusTier = true).note)
    }

    @Test
    fun additionalTimesCanBeEditedAndRemoved() {
        val withTime = form.reduce(AlarmFormEvent.AdditionalTimeAdded(LocalTime.of(12, 0)), isPlusTier = false)
        val edited = withTime.reduce(AlarmFormEvent.AdditionalTimeChanged(0, LocalTime.of(13, 30)), isPlusTier = false)
        assertEquals(listOf(LocalTime.of(13, 30)), edited.additionalTimes)
        assertEquals(emptyList<LocalTime>(), edited.reduce(AlarmFormEvent.AdditionalTimeRemoved(0), false).additionalTimes)
    }

    @Test
    fun freeTierTemplateWithLongPreAlarmIsCappedAtThirtyMinutes() {
        val template = AlarmTemplate(
            id = "t",
            name = "Rent",
            category = AlarmCategory.FINANCE,
            cycleType = CycleType.MONTHLY_DATE,
            timeOfDay = LocalTime.of(9, 0),
            schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
            preAlarmMinutes = 1440
        )
        assertEquals(30, form.reduce(AlarmFormEvent.TemplateLoaded(template), isPlusTier = false).preAlarmMinutes)
        assertEquals(1440, form.reduce(AlarmFormEvent.TemplateLoaded(template), isPlusTier = true).preAlarmMinutes)
    }
}
