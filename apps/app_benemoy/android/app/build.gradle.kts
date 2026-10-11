import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val housePropertiesDirectory = file("../../config/houses/android")
val houseProfiles = housePropertiesDirectory
    .listFiles { candidate -> candidate.isFile && candidate.extension == "properties" }
    .orEmpty()
    .sortedBy { it.nameWithoutExtension }
    .associate { profileFile ->
        profileFile.nameWithoutExtension to Properties().apply {
            profileFile.inputStream().use(::load)
        }
    }
if (houseProfiles.isEmpty()) {
    throw GradleException("Add broker-house properties under $housePropertiesDirectory")
}
val signingPropertiesFile = rootProject.file("key.properties")
val signingProperties = Properties().apply {
    if (signingPropertiesFile.exists()) {
        signingPropertiesFile.inputStream().use(::load)
    }
}
val releaseStorePath = signingProperties.getProperty("storeFile")
val releaseSigningAvailable = signingPropertiesFile.exists() &&
    !releaseStorePath.isNullOrBlank() &&
    file(releaseStorePath).exists() &&
    listOf("storePassword", "keyPassword", "keyAlias")
        .all { !signingProperties.getProperty(it).isNullOrBlank() }

android {
    namespace = "com.benemoysecurity.app.app_benemoy"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.benemoysecurity.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "house"
    productFlavors {
        houseProfiles.forEach { (houseId, houseProperties) ->
            if (!Regex("^[a-z][a-z0-9_]*$").matches(houseId)) {
                throw GradleException("Invalid Android broker-house flavor name: $houseId")
            }
            val appId = houseProperties.getProperty("applicationId")
                ?: throw GradleException("Missing applicationId in ${houseId}.properties")
            val displayName = houseProperties.getProperty("displayName")
                ?: throw GradleException("Missing displayName in ${houseId}.properties")
            create(houseId) {
                dimension = "house"
                applicationId = appId
                manifestPlaceholders["appLabel"] = displayName
            }
        }
    }

    signingConfigs {
        if (releaseSigningAvailable) {
            create("release") {
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
                storeFile = file(releaseStorePath!!)
                storePassword = signingProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseSigningAvailable) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
