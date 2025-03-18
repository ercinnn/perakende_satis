buildscript {
    // Kotlin sürümünü belirtin
    val kotlinVersion = "1.9.20"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Android Gradle Plugin sürümü
        classpath("com.android.tools.build:gradle:8.0.0")
        // Kotlin Gradle Plugin sürümü
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build dizinini özelleştirme
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // Her alt proje için build dizinini özelleştirme
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    // Alt projelerin app modülüne bağımlılığını belirtme
    project.evaluationDependsOn(":app")
}

// Temizleme görevi (clean task)
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}