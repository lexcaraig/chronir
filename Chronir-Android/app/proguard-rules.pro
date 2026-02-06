# Chronir ProGuard Rules

# Keep Hilt generated classes
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }

# Keep Room entities
-keep class com.chronir.data.local.** { *; }

# Keep Firebase model classes
-keep class com.chronir.model.** { *; }
