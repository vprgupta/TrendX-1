# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep app class names for crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# OkHttp / Retrofit (if used transitively)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Kotlin serialization
-keep class kotlinx.serialization.** { *; }
-keepclasseswithmembers class ** { @kotlinx.serialization.Serializable *; }

-dontwarn com.google.android.play.core.**
