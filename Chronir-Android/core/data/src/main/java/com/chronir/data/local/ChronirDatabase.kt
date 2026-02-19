package com.chronir.data.local

import android.content.Context
import androidx.room.ColumnInfo
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Entity(
    tableName = "alarms",
    indices = [
        Index(value = ["nextFireDate"]),
        Index(value = ["isEnabled"])
    ]
)
data class AlarmEntity(
    @PrimaryKey val id: String,
    val title: String,
    val cycleType: String,
    val timeOfDayHour: Int,
    val timeOfDayMinute: Int,
    val scheduleJson: String,
    val nextFireDate: Long,
    val lastFiredDate: Long? = null,
    val timezone: String = java.util.TimeZone.getDefault().id,
    val timezoneMode: String = "FLOATING",
    val isEnabled: Boolean = true,
    val snoozeCount: Int = 0,
    val persistenceLevel: String = "NOTIFICATION_ONLY",
    val dismissMethod: String = "SWIPE",
    val preAlarmMinutes: Int = 0,
    val colorTag: String? = null,
    val iconName: String? = null,
    val syncStatus: String = "LOCAL_ONLY",
    @ColumnInfo(name = "ownerID") val ownerID: String? = null,
    val sharedWithJson: String = "[]",
    val note: String = "",
    val createdAt: Long,
    val updatedAt: Long
)

@Entity(
    tableName = "completions",
    indices = [Index(value = ["alarmId"])]
)
data class CompletionEntity(
    @PrimaryKey val id: String,
    val alarmId: String,
    val action: String,
    val timestamp: Long,
    val snoozeDurationMinutes: Int? = null
)

@Database(
    entities = [AlarmEntity::class, CompletionEntity::class],
    version = 3,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class ChronirDatabase : RoomDatabase() {

    abstract fun alarmDao(): AlarmDao
    abstract fun completionDao(): CompletionDao

    companion object {
        fun create(context: Context): ChronirDatabase {
            return Room.databaseBuilder(
                context.applicationContext,
                ChronirDatabase::class.java,
                "chronir.db"
            )
                .fallbackToDestructiveMigration()
                .build()
        }
    }
}
