package com.chronir

import com.chronir.model.Alarm
import com.chronir.services.AlarmLimitPolicy
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Instant

class AlarmLimitPolicyTest {
    private val base: Instant = Instant.parse("2026-01-01T00:00:00Z")

    private fun alarm(name: String, createdMinutesAfterBase: Long, enabled: Boolean = true) = Alarm(
        id = name,
        title = name,
        isEnabled = enabled,
        createdAt = base.plusSeconds(createdMinutesAfterBase * 60)
    )

    @Test
    fun `nothing to disable at or under the limit`() {
        val enabled = listOf(alarm("a", 0), alarm("b", 1), alarm("c", 2))
        assertTrue(AlarmLimitPolicy.alarmsToDisable(enabled, limit = 3).isEmpty())
        assertTrue(AlarmLimitPolicy.alarmsToDisable(enabled.take(2), limit = 3).isEmpty())
    }

    @Test
    fun `newest alarms beyond the limit are disabled, oldest stay on`() {
        val enabled = listOf(alarm("d", 3), alarm("a", 0), alarm("e", 4), alarm("b", 1), alarm("c", 2))
        val excess = AlarmLimitPolicy.alarmsToDisable(enabled, limit = 3)
        assertEquals(listOf("d", "e"), excess.map { it.id })
    }

    @Test
    fun `only alarms the limit disabled are restored`() {
        val disabled = listOf(alarm("userPaused", 0, enabled = false), alarm("limitOff", 1, enabled = false))
        val restored = AlarmLimitPolicy.alarmsToRestore(disabled, limitDisabled = setOf("limitOff", "deletedSince"))
        assertEquals(listOf("limitOff"), restored.map { it.id })
    }

    @Test
    fun `restore with nothing remembered is empty`() {
        val disabled = listOf(alarm("a", 0, enabled = false))
        assertTrue(AlarmLimitPolicy.alarmsToRestore(disabled, limitDisabled = emptySet()).isEmpty())
    }
}
