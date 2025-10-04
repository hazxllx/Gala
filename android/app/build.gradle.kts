plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("com.android.application") version "8.7.0"
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_project"

    // Set compileSdk and minSdk versions explicitly
    compileSdk = 36

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.my_project"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ==== Add this block to rename your APK! ====
android.applicationVariants.all {
    outputs.all {
        val outputImpl = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
        // Change the APK name format as you like:
        outputImpl.outputFileName = "Gala.apk"
    }
}
// =============================================

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")
    // Add other Firebase dependencies if needed
}

flutter {
    source = "../.."
}

apply(plugin = "com.google.gms.google-services")
