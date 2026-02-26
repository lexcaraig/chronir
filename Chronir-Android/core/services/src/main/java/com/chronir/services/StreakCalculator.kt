package com.chronir.services

import com.chronir.model.CompletionAction
import com.chronir.model.CompletionRecord
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import javax.inject.Inject
import javax.inject.Singleton

data class StreakInfo(
    val currentStreak: Int,
    val longestStreak: Int,
    val totalCompletions: Int,
    val completionRate: Float
)

@Singleton
class StreakCalculator
    @Inject
    constructor() {

        fun calculateStreak(records: List<CompletionRecord>, zoneId: ZoneId = ZoneId.systemDefault()): StreakInfo {
            if (records.isEmpty()) {
                return StreakInfo(currentStreak = 0, longestStreak = 0, totalCompletions = 0, completionRate = 0f)
            }

            val completedDates = records
                .filter { it.action == CompletionAction.COMPLETED }
                .map { it.timestamp.atZone(zoneId).toLocalDate() }
                .distinct()
                .sortedDescending()

            val totalActions = records.count {
                it.action in setOf(CompletionAction.COMPLETED, CompletionAction.MISSED, CompletionAction.SKIPPED)
            }
            val totalCompletions = completedDates.size
            val completionRate = if (totalActions > 0) totalCompletions.toFloat() / totalActions else 0f

            if (completedDates.isEmpty()) {
                return StreakInfo(currentStreak = 0, longestStreak = 0, totalCompletions = 0, completionRate = completionRate)
            }

            val currentStreak = calculateCurrentStreak(completedDates, zoneId)
            val longestStreak = calculateLongestStreak(completedDates)

            return StreakInfo(
                currentStreak = currentStreak,
                longestStreak = longestStreak,
                totalCompletions = totalCompletions,
                completionRate = completionRate
            )
        }

        private fun calculateCurrentStreak(sortedDatesDesc: List<LocalDate>, zoneId: ZoneId): Int {
            val today = Instant.now().atZone(zoneId).toLocalDate()
            val mostRecent = sortedDatesDesc.first()

            // Streak is broken if the most recent completion is more than 1 day ago
            val daysSinceLastCompletion = today.toEpochDay() - mostRecent.toEpochDay()
            if (daysSinceLastCompletion > 1) return 0

            var streak = 1
            for (i in 1 until sortedDatesDesc.size) {
                val diff = sortedDatesDesc[i - 1].toEpochDay() - sortedDatesDesc[i].toEpochDay()
                if (diff == 1L) {
                    streak++
                } else {
                    break
                }
            }
            return streak
        }

        private fun calculateLongestStreak(sortedDatesDesc: List<LocalDate>): Int {
            if (sortedDatesDesc.size <= 1) return sortedDatesDesc.size

            var longest = 1
            var current = 1
            for (i in 1 until sortedDatesDesc.size) {
                val diff = sortedDatesDesc[i - 1].toEpochDay() - sortedDatesDesc[i].toEpochDay()
                if (diff == 1L) {
                    current++
                    longest = maxOf(longest, current)
                } else {
                    current = 1
                }
            }
            return longest
        }
    }
