plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ognitipodiinsegnamento"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = System.getenv("CM_KEY_ALIAS") ?: "key Torla89"
            keyPassword = System.getenv("CM_KEY_PASSWORD") ?: "Max1.2Sic!!"
            storeFile = System.getenv("CM_KEYSTORE_PATH")?.let { file(it) }
                ?: file("C:\\Users\\torla\\OneDrive\\Documenti\\Desktop\\Firma Torlai.jks")
            storePassword = System.getenv("CM_KEYSTORE_PASSWORD") ?: "Max1.2Sic!!"
        }
    }

    defaultConfig {
        applicationId = "com.ognitipodiinsegnamento"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 18
        versionName = "26.03.04"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
