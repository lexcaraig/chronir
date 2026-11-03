package com.chronir

import com.chronir.model.countdownText
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import java.time.Duration
import java.time.Instant

class CountdownTest {
    private val now = Instant.parse("2026-11-03T09:00:00Z")

    private fun text(after: Duration) = countdownText(now.plus(after), now)

    @Test fun daysAndHours() = assertEquals("Alarm in 5d 14h", text(Duration.ofDays(5).plusHours(14).plusMinutes(30)))

    @Test fun hoursAndMinutes() = assertEquals("Alarm in 3h 12m", text(Duration.ofHours(3).plusMinutes(12)))

    @Test fun underAMinuteShowsOne() = assertEquals("Alarm in 1m", text(Duration.ofSeconds(20)))

    @Test fun pastOrNowIsNull() {
        assertNull(text(Duration.ZERO))
        assertNull(text(Duration.ofMinutes(-5)))
    }
}
