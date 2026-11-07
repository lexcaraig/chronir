# Chronir ProGuard Rules

# Keep Hilt generated classes
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }

# Keep Room entities
-keep class com.chronir.data.local.** { *; }

# Keep Firebase model classes
-keep class com.chronir.model.** { *; }

# Hilt keys ViewModels by class name (@LazyClassKey). If R8 merges two ViewModel
# classes, their keys collide ("Multiple entries with same key") and the app
# crashes on the first ViewModel lookup. Keep each ViewModel a distinct class.
-keep,allowobfuscation,allowshrinking class * extends androidx.lifecycle.ViewModel
