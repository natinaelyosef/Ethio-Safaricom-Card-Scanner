# Saricom R8 rules.
# Flutter's own generation covers engine + plugin defaults (written at
# build time into build/app/outputs/); these are the app-specific extras.

# CameraX — used through camera_android_camerax.
-keep class androidx.camera.core.** { *; }
-keep class androidx.camera.view.** { *; }

# Google ML Kit text recognition: the base text package references the
# separate Chinese/Devanagari/Japanese/Korean model AARs, which Saricom
# does not include (Ethiopian vouchers use latin digits). R8 must not
# fail on them; the docs at developers.google.com/ml-kit prescribe this.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep ML Kit itself: R8 must not strip or rename the recognizer's
# classes (reflection + JNI entry points), or every recognition call
# fails silently in the release APK.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
