package com.chronir.model

enum class AlarmCategory(
    val displayName: String,
    val colorTag: String,
    val iconKey: String
) {
    HOME("Home", "categoryHome", "home"),
    HEALTH("Health", "categoryHealth", "heart"),
    FINANCE("Finance", "categoryFinance", "dollar"),
    VEHICLE("Vehicle", "categoryVehicle", "car"),
    WORK("Work", "categoryWork", "briefcase"),
    PERSONAL("Personal", "categoryPersonal", "person"),
    PETS("Pets", "categoryPets", "pets"),
    SUBSCRIPTIONS("Subscriptions", "categorySubscriptions", "creditcard");

    companion object {
        fun fromColorTag(tag: String?): AlarmCategory? =
            entries.firstOrNull { it.colorTag == tag }
    }
}
