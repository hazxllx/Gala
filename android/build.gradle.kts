buildscript {
    // Define Kotlin version directly
    val kotlin_version = "2.1.0"  // Use the Kotlin version for the project

    repositories {
        google()  // Add Google's Maven repository
        mavenCentral()  // Add Maven Central for dependencies
    }

    dependencies {
        // Classpath for the Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.7.1")  // Latest version of Android Gradle Plugin
        // Classpath for Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")  // Kotlin plugin version
    }
}

allprojects {
    repositories {
        google()  // Add Google's Maven repository
        mavenCentral()  // Add Maven Central repository
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)  // Set a new build directory for the project

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)  // Create new build directory for subprojects
    project.layout.buildDirectory.value(newSubprojectBuildDir)  // Set subproject build directory
}

subprojects {
    project.evaluationDependsOn(":app")  // Ensure that subprojects evaluate the ':app' project
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)  // Clean the project build directory
}
