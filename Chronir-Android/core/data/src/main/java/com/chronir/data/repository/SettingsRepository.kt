package com.chronir.data.repository

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.chronir.model.TextSizePreference
import com.chronir.model.ThemePreference
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "chronir_settings")

data class UserSettings(
    val hapticFeedbackEnabled: Boolean = true,
    val alarmSound: String = "default",
    val themePreference: ThemePreference = ThemePreference.DYNAMIC,
    val textSizePreference: TextSizePreference = TextSizePreference.STANDARD,
    val groupByCategory: Boolean = false,
    val notificationsEnabled: Boolean = true,
    val hasCompletedOnboarding: Boolean = false
)

@Singleton
class SettingsRepository
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) {
        private object Keys {
            val HAPTIC_FEEDBACK = booleanPreferencesKey("haptic_feedback")
            val ALARM_SOUND = stringPreferencesKey("alarm_sound")
            val THEME = stringPreferencesKey("theme_preference")
            val TEXT_SIZE = stringPreferencesKey("text_size_preference")
            val GROUP_BY_CATEGORY = booleanPreferencesKey("group_by_category")
            val HAS_COMPLETED_ONBOARDING = booleanPreferencesKey("has_completed_onboarding")
            val LIMIT_DISABLED_ALARM_IDS = stringSetPreferencesKey("limit_disabled_alarm_ids")
        }

        /** IDs of alarms the Free limit turned off, so a later upgrade restores exactly those. */
        val limitDisabledAlarmIds: Flow<Set<String>> = context.dataStore.data.map { prefs ->
            prefs[Keys.LIMIT_DISABLED_ALARM_IDS] ?: emptySet()
        }

        val settings: Flow<UserSettings> = context.dataStore.data.map { prefs ->
            UserSettings(
                hapticFeedbackEnabled = prefs[Keys.HAPTIC_FEEDBACK] ?: true,
                alarmSound = prefs[Keys.ALARM_SOUND] ?: "default",
                themePreference = prefs[Keys.THEME]?.let {
                    runCatching { ThemePreference.valueOf(it) }.getOrDefault(ThemePreference.DYNAMIC)
                } ?: ThemePreference.DYNAMIC,
                textSizePreference = prefs[Keys.TEXT_SIZE]?.let {
                    runCatching { TextSizePreference.valueOf(it) }.getOrDefault(TextSizePreference.STANDARD)
                } ?: TextSizePreference.STANDARD,
                groupByCategory = prefs[Keys.GROUP_BY_CATEGORY] ?: false,
                hasCompletedOnboarding = prefs[Keys.HAS_COMPLETED_ONBOARDING] ?: false
            )
        }

        suspend fun setHapticFeedback(enabled: Boolean) {
            context.dataStore.edit { it[Keys.HAPTIC_FEEDBACK] = enabled }
        }

        suspend fun setAlarmSound(sound: String) {
            context.dataStore.edit { it[Keys.ALARM_SOUND] = sound }
        }

        suspend fun setThemePreference(theme: ThemePreference) {
            context.dataStore.edit { it[Keys.THEME] = theme.name }
        }

        suspend fun setTextSizePreference(size: TextSizePreference) {
            context.dataStore.edit { it[Keys.TEXT_SIZE] = size.name }
        }

        suspend fun setGroupByCategory(enabled: Boolean) {
            context.dataStore.edit { it[Keys.GROUP_BY_CATEGORY] = enabled }
        }

        suspend fun setHasCompletedOnboarding(completed: Boolean) {
            context.dataStore.edit { it[Keys.HAS_COMPLETED_ONBOARDING] = completed }
        }

        suspend fun setLimitDisabledAlarmIds(ids: Set<String>) {
            context.dataStore.edit {
                if (ids.isEmpty()) it.remove(Keys.LIMIT_DISABLED_ALARM_IDS) else it[Keys.LIMIT_DISABLED_ALARM_IDS] = ids
            }
        }
    }
