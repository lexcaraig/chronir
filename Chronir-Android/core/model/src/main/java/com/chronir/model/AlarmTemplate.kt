package com.chronir.model

import java.time.LocalTime

data class AlarmTemplate(
    val id: String,
    val name: String,
    val category: AlarmCategory,
    val cycleType: CycleType,
    val timeOfDay: LocalTime,
    val schedule: Schedule,
    val persistenceLevel: PersistenceLevel = PersistenceLevel.NOTIFICATION_ONLY,
    val preAlarmMinutes: Int = 0,
    val note: String = "",
    val iconName: String? = null
) {
    companion object {
        val builtInTemplates: List<AlarmTemplate> = listOf(
            AlarmTemplate(
                id = "template_rent",
                name = "Rent Payment",
                category = AlarmCategory.FINANCE,
                cycleType = CycleType.MONTHLY_DATE,
                timeOfDay = LocalTime.of(9, 0),
                schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
                persistenceLevel = PersistenceLevel.FULL,
                preAlarmMinutes = 1440
            ),
            AlarmTemplate(
                id = "template_trash",
                name = "Trash Day",
                category = AlarmCategory.HOME,
                cycleType = CycleType.WEEKLY,
                timeOfDay = LocalTime.of(20, 0),
                schedule = Schedule.Weekly(daysOfWeek = listOf(4), interval = 1),
                preAlarmMinutes = 720
            ),
            AlarmTemplate(
                id = "template_pet_meds",
                name = "Pet Medication",
                category = AlarmCategory.PETS,
                cycleType = CycleType.MONTHLY_DATE,
                timeOfDay = LocalTime.of(8, 0),
                schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 1),
                persistenceLevel = PersistenceLevel.FULL
            ),
            AlarmTemplate(
                id = "template_oil_change",
                name = "Oil Change",
                category = AlarmCategory.VEHICLE,
                cycleType = CycleType.CUSTOM_DAYS,
                timeOfDay = LocalTime.of(9, 0),
                schedule = Schedule.CustomDays(intervalDays = 90, startDate = java.time.Instant.now()),
                preAlarmMinutes = 1440
            ),
            AlarmTemplate(
                id = "template_water_plants",
                name = "Water Plants",
                category = AlarmCategory.HOME,
                cycleType = CycleType.WEEKLY,
                timeOfDay = LocalTime.of(8, 0),
                schedule = Schedule.Weekly(daysOfWeek = listOf(1, 5), interval = 1)
            ),
            AlarmTemplate(
                id = "template_dentist",
                name = "Dentist Appointment",
                category = AlarmCategory.HEALTH,
                cycleType = CycleType.CUSTOM_DAYS,
                timeOfDay = LocalTime.of(9, 0),
                schedule = Schedule.CustomDays(intervalDays = 180, startDate = java.time.Instant.now()),
                preAlarmMinutes = 1440
            ),
            AlarmTemplate(
                id = "template_subscription_review",
                name = "Review Subscriptions",
                category = AlarmCategory.SUBSCRIPTIONS,
                cycleType = CycleType.MONTHLY_DATE,
                timeOfDay = LocalTime.of(10, 0),
                schedule = Schedule.MonthlyDate(dayOfMonth = 1, interval = 3)
            ),
            AlarmTemplate(
                id = "template_workout",
                name = "Workout",
                category = AlarmCategory.HEALTH,
                cycleType = CycleType.WEEKLY,
                timeOfDay = LocalTime.of(7, 0),
                schedule = Schedule.Weekly(daysOfWeek = listOf(2, 4, 6), interval = 1)
            )
        )
    }
}
