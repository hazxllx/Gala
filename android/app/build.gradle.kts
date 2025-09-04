plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("com.android.application") version "8.7.0"
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_project"
    
    // Set compileSdk and minSdk versions explicitly
    compileSdk = 36  // Set compileSdk to 36

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11  // Set to Java 11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()  // Set to Java 11
    }

    defaultConfig {
        applicationId = "com.example.my_project"
        minSdk = 24  // Set minSdkVersion to 24
        targetSdk = 36  // Update targetSdk to 36
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
    // Firebase BoM (Bill of Materials) only declared once
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))

    // Firebase Analytics (and other Firebase services if needed)
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase dependencies as needed
    // For example, Firebase Authentication
    // implementation("com.google.firebase:firebase-auth")

    // Firebase SDK (already included via BoM)
    // No need to declare this twice
}

flutter {
    source = "../.."  // Ensure this path is correct
}

// Apply the Firebase plugin at the bottom
apply(plugin = "com.google.gms.google-services")
