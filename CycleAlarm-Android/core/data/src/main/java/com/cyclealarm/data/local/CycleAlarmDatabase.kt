package com.cyclealarm.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Entity(tableName = "alarms")
data class AlarmEntity(
    @PrimaryKey val id: String,
    val title: String,
    val cycleType: String,
    val scheduledTimeHour: Int,
    val scheduledTimeMinute: Int,
    val next_fire_date: Long,
    val is_enabled: Boolean,
    val isPersistent: Boolean,
    val note: String,
    val createdAt: Long,
    val updatedAt: Long
)

@Database(
    entities = [AlarmEntity::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class CycleAlarmDatabase : RoomDatabase() {

    abstract fun alarmDao(): AlarmDao

    companion object {
        fun create(context: Context): CycleAlarmDatabase {
            return Room.databaseBuilder(
                context.applicationContext,
                CycleAlarmDatabase::class.java,
                "cyclealarm.db"
            ).build()
        }
    }
}
