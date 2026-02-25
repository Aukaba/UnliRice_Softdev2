plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// parse .env at configuration time and expose maps key as a project property
val dotenvFile = file("${rootProject.rootDir.parentFile.path}/.env")
if (dotenvFile.exists()) {
    dotenvFile.forEachLine { line ->
        val trimmed = line.trim()
        if (!trimmed.startsWith("#") && trimmed.contains("=")) {
            val (key, value) = trimmed.split("=", limit = 2)
            if (key.trim() == "GOOGLE_MAPS_API_KEY") {
                project.extra.set("GOOGLE_MAPS_API_KEY", value.trim())
            }
        }
    }
}

android {
    namespace = "com.example.automate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.automate"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // manifest placeholder for API key, read from project property (set in local.properties or via environment)
        // prefer project property from .env parser, fallback to local.properties if defined
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = (project.extra.properties["GOOGLE_MAPS_API_KEY"]
            ?: project.findProperty("GOOGLE_MAPS_API_KEY"))?.toString() ?: ""
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
