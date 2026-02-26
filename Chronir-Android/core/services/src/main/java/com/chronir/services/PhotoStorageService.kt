package com.chronir.services

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import dagger.hilt.android.qualifiers.ApplicationContext
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PhotoStorageService
    @Inject
    constructor(
        @ApplicationContext private val context: Context
    ) {
        private val photosDir: File
            get() = File(context.filesDir, "alarm-photos").also { it.mkdirs() }

        private fun sanitizedFileName(alarmId: String): String {
            val sanitized = alarmId.replace(Regex("[^a-zA-Z0-9\\-_]"), "")
            require(sanitized.isNotEmpty()) { "Invalid alarm ID" }
            return "alarm_$sanitized.jpg"
        }

        fun savePhoto(alarmId: String, uri: Uri): String {
            val fileName = sanitizedFileName(alarmId)
            val file = File(photosDir, fileName)
            require(file.canonicalPath.startsWith(photosDir.canonicalPath)) { "Invalid path" }
            context.contentResolver.openInputStream(uri)?.use { input ->
                file.outputStream().use { output ->
                    val bitmap = BitmapFactory.decodeStream(input)
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 80, output)
                    bitmap.recycle()
                }
            }
            return fileName
        }

        fun savePhoto(alarmId: String, bitmap: Bitmap): String {
            val fileName = sanitizedFileName(alarmId)
            val file = File(photosDir, fileName)
            file.outputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 80, output)
            }
            return fileName
        }

        fun loadPhoto(alarmId: String): Bitmap? {
            val file = File(photosDir, sanitizedFileName(alarmId))
            return if (file.exists()) BitmapFactory.decodeFile(file.absolutePath) else null
        }

        fun getPhotoFile(alarmId: String): File? {
            val file = File(photosDir, sanitizedFileName(alarmId))
            return if (file.exists()) file else null
        }

        fun deletePhoto(alarmId: String) {
            val file = File(photosDir, sanitizedFileName(alarmId))
            if (file.exists()) file.delete()
        }

        fun hasPhoto(alarmId: String): Boolean = File(photosDir, sanitizedFileName(alarmId)).exists()
    }
