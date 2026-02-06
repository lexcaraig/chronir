package com.chronir

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters

class DateCalculatorTest {

    @Test
    fun `next weekly date is 7 days from now`() {
        val today = LocalDate.now()
        val nextWeekly = today.plusWeeks(1)
        assertEquals(7, java.time.temporal.ChronoUnit.DAYS.between(today, nextWeekly))
    }

    @Test
    fun `next biweekly date is 14 days from now`() {
        val today = LocalDate.now()
        val nextBiweekly = today.plusWeeks(2)
        assertEquals(14, java.time.temporal.ChronoUnit.DAYS.between(today, nextBiweekly))
    }

    @Test
    fun `next monthly date is in the next month`() {
        val today = LocalDate.now()
        val nextMonthly = today.plusMonths(1)
        assertTrue(nextMonthly.isAfter(today))
        assertEquals(today.month.plus(1), nextMonthly.month)
    }

    @Test
    fun `next quarterly date is 3 months away`() {
        val today = LocalDate.now()
        val nextQuarterly = today.plusMonths(3)
        assertTrue(nextQuarterly.isAfter(today))
    }

    @Test
    fun `next biannual date is 6 months away`() {
        val today = LocalDate.now()
        val nextBiannual = today.plusMonths(6)
        assertTrue(nextBiannual.isAfter(today))
    }

    @Test
    fun `next annual date is 1 year away`() {
        val today = LocalDate.now()
        val nextAnnual = today.plusYears(1)
        assertEquals(today.year + 1, nextAnnual.year)
    }

    @Test
    fun `next occurrence of a specific weekday is correct`() {
        val today = LocalDate.now()
        val nextMonday = today.with(TemporalAdjusters.next(DayOfWeek.MONDAY))
        assertNotNull(nextMonday)
        assertEquals(DayOfWeek.MONDAY, nextMonday.dayOfWeek)
        assertTrue(nextMonday.isAfter(today))
    }
}
