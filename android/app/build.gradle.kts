plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.android.application") version "8.7.0"
    id("org.jetbrains.kotlin.android") version "2.1.0"  // Update to match the Kotlin version
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_project"
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
        applicationId = "com.example.my_project"
        minSdk = 23
        targetSdk = 33
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

dependencies {
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))

    // Firebase Analytics (and other Firebase services if needed)
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase dependencies as needed
    // For example, Firebase Authentication
    // implementation("com.google.firebase:firebase-auth")

    // Firebase SDK
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}

// Apply the Firebase plugin at the bottom
apply(plugin = "com.google.gms.google-services")
