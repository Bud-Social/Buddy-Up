import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase requires google-services.json. Apply the plugin only when the
// file exists so local/dev builds without the secret still compile.
val googleServicesFile = project.file("google-services.json")
if (googleServicesFile.exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// ── Signing ────────────────────────────────────────────────────────────────
// Production signing is configured via android/key.properties (gitignored):
//
//   storePassword=...
//   keyPassword=...
//   keyAlias=...
//   storeFile=../keys/buddyup-release.jks
//
// CI can inject the same values via environment variables (SIGNING_*), so the
// keystore never has to live in the repository.
val keystoreProperties = Properties().apply {
    val f = project.file("../key.properties")
    if (f.exists()) {
        load(FileInputStream(f))
    }
    // Environment fallbacks for CI.
    val storeFile = System.getenv("SIGNING_STORE_FILE")
    if (storeFile != null) put("storeFile", storeFile)
    System.getenv("SIGNING_STORE_PASSWORD")?.let { put("storePassword", it) }
    System.getenv("SIGNING_KEY_PASSWORD")?.let { put("keyPassword", it) }
    System.getenv("SIGNING_KEY_ALIAS")?.let { put("keyAlias", it) }
}

fun hasSigningConfig(): Boolean =
    keystoreProperties.containsKey("storeFile") &&
        keystoreProperties.containsKey("storePassword") &&
        keystoreProperties.containsKey("keyPassword") &&
        keystoreProperties.containsKey("keyAlias")

android {
    namespace = "com.buddyup.buddy_up_flutter"
    // Pinned floor: older Flutter SDK caches default to android-31, which fails
    // AAR metadata checks against androidx dependencies requiring 34+.
    val flutterSdk = flutter.compileSdkVersion as? Int ?: 0
    compileSdk = if (flutterSdk > 36) flutterSdk else 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.buddyup.buddy_up_flutter"
        // These values can be overridden from the command line at release time,
        // e.g.  ./gradlew :app:assembleRelease -PversionName=1.2.0 -PversionCode=42
        versionCode = (project.findProperty("versionCode") as String?)?.toIntOrNull()
            ?: flutter.versionCode
        versionName = (project.findProperty("versionName") as String?) ?: flutter.versionName
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Maps API key placeholder, replaced by the value in key.properties or
        // the GOOGLE_MAPS_API_KEY environment variable.
        val mapsKey = System.getenv("GOOGLE_MAPS_API_KEY")
            ?: keystoreProperties.getProperty("googleMapsApiKey", "")
        manifestPlaceholders["googleMapsApiKey"] = mapsKey
    }

    signingConfigs {
        if (hasSigningConfig()) {
            create("release") {
                val storeFileVal = keystoreProperties.getProperty("storeFile")
                storeFile = project.file(storeFileVal)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // If signing material is configured, sign with the release keystore.
            // Otherwise fall back to debug keys so local `flutter run --release`
            // still works; a CI release build SHOULD always have signing set up.
            signingConfig = if (hasSigningConfig()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}