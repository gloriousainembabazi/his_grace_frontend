# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# For ML Kit barcode scanning
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# For Camera
-keep class androidx.camera.** { *; }

# For Glide
-keep class com.bumptech.glide.** { *; }

# For OkHttp
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# For Gson
-keep class com.google.gson.** { *; }

# Keep our app models
-keep class com.hisgrace.drugshop.** { *; }