allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Some Flutter plugins (notably agora_rtc_engine) hardcode a low compileSdk
// in their own module, which fails AAR metadata checks against modern
// androidx libraries that require compileSdk >= 34. Raise any Android
// LIBRARY module compiled below 34 to match the app.
//
// Registered ahead of any evaluationDependsOn below, and scoped to
// com.android.library modules, so it attaches while each plugin module is
// still configurable.
subprojects {
    plugins.withId("com.android.library") {
        afterEvaluate {
            val androidExt = extensions.findByName("android")
            if (androidExt is com.android.build.gradle.LibraryExtension) {
                val current = androidExt.compileSdkVersion?.toString()?.toIntOrNull() ?: 0
                if (current < 34) {
                    androidExt.compileSdkVersion(36)
                }
            }
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
