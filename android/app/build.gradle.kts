plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.perakende_satis"
    compileSdk = flutter.compileSdkVersion.toInt() // compileSdkVersion bir String olduğu için .toInt() ekledik

    // NDK sürümünü manuel olarak belirtin
    ndkVersion = "27.0.12077973" // Bu satırı ekleyin

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.perakende_satis"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion.toInt() // minSdkVersion bir String olduğu için .toInt() ekledik
        targetSdk = flutter.targetSdkVersion.toInt() // targetSdkVersion bir String olduğu için .toInt() ekledik
        versionCode = flutter.versionCode.toInt() // versionCode bir String olduğu için .toInt() ekledik
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