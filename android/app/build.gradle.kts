import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { inputStream ->
        localProperties.load(inputStream)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "io.scelus.dienstplan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        jvmToolchain(17)
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "io.scelus.dienstplan"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            if (System.getenv()["ANDROID_KEYSTORE_BASE64"] != null) {
                storeFile = file("keystore.jks")
                storePassword = System.getenv()["ANDROID_KEYSTORE_PASSWORD"]
                keyAlias = System.getenv()["ANDROID_KEY_ALIAS"]
                keyPassword = System.getenv()["ANDROID_KEY_PASSWORD"]
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isDebuggable = true
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Dienstplan Dev")
        }
        create("prod") {
            dimension = "default"
            applicationIdSuffix = ""
            resValue("string", "app_name", "Dienstplan")
        }
    }

    // Custom APK naming
    applicationVariants.all {
        outputs.all {
            val versionName = defaultConfig.versionName
            val versionCode = defaultConfig.versionCode
            val buildType = buildType.name
            val flavorName = flavorName
            
            if (buildType == "release") {
                (this as? com.android.build.gradle.internal.api.BaseVariantOutputImpl)?.outputFileName = 
                    "dienstplan-${versionName}-${flavorName}-${versionCode}.apk"
            } else {
                (this as? com.android.build.gradle.internal.api.BaseVariantOutputImpl)?.outputFileName = 
                    "dienstplan-${versionName}-${flavorName}-${versionCode}-${buildType}.apk"
            }
        }
    }

    // Custom AAB naming
    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = false
        }
        abi {
            enableSplit = true
        }
    }
    
    // Set custom AAB filename
    applicationVariants.all {
        if (buildType.name == "release") {
            outputs.all {
                if (name.contains("Bundle")) {
                    val versionName = defaultConfig.versionName
                    val versionCode = defaultConfig.versionCode
                    val flavorName = flavorName
                    (this as? com.android.build.gradle.internal.api.BaseVariantOutputImpl)?.outputFileName = 
                        "dienstplan-${versionName}-${flavorName}-${versionCode}.aab"
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
