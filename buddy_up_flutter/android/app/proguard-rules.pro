# R8 keep rules for the Flutter Android embedding. Without these the release
# minified build strips classes the runtime reflects into.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-dontwarn com.google.android.gms.**
-dontwarn com.android.botto.**
