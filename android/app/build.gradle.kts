import java.util.Locale
plugins {

    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Run patch script before any evaluation happens
val runPatchScript = tasks.register("runPatchScript") {
    doLast {
        println("Running apply-patch script...")
        exec {
            workingDir = file("${rootProject.projectDir}")
            commandLine("cmd", "/c", "apply-patch.bat")
        }
    }
}

// Make sure the patch runs before evaluation
gradle.projectsEvaluated {
    tasks.named("preBuild").configure {
        dependsOn(runPatchScript)
    }
}

android {
    namespace = "com.example.prescription"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.prescription"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
