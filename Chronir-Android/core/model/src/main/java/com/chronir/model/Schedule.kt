package com.chronir.model

import java.time.Instant

sealed class Schedule {
    abstract val cycleType: CycleType

    data class Weekly(
        val daysOfWeek: List<Int>,
        val interval: Int = 1
    ) : Schedule() {
        override val cycleType = CycleType.WEEKLY
    }

    data class MonthlyDate(
        val dayOfMonth: Int,
        val interval: Int = 1
    ) : Schedule() {
        override val cycleType = CycleType.MONTHLY_DATE
    }

    data class MonthlyRelative(
        val weekOfMonth: Int,
        val dayOfWeek: Int,
        val interval: Int = 1
    ) : Schedule() {
        override val cycleType = CycleType.MONTHLY_RELATIVE
    }

    data class Annual(
        val month: Int,
        val dayOfMonth: Int,
        val interval: Int = 1
    ) : Schedule() {
        override val cycleType = CycleType.ANNUAL
    }

    data class CustomDays(
        val intervalDays: Int,
        val startDate: Instant
    ) : Schedule() {
        override val cycleType = CycleType.CUSTOM_DAYS
    }
}
