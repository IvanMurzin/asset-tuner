import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun readKeystoreProperty(name: String): String? {
    return (keystoreProperties[name] as String?)?.trim()?.takeIf { it.isNotEmpty() }
}

val releaseKeyAlias = readKeystoreProperty("keyAlias")
val releaseKeyPassword = readKeystoreProperty("keyPassword")
val releaseStorePassword = readKeystoreProperty("storePassword")
val releaseStoreFilePath = readKeystoreProperty("storeFile")
val releaseStoreFile = releaseStoreFilePath?.let { rootProject.file(it) }
val hasValidReleaseSigning = keystorePropertiesFile.exists() &&
        releaseKeyAlias != null &&
        releaseKeyPassword != null &&
        releaseStorePassword != null &&
        releaseStoreFile != null &&
        releaseStoreFile.exists()

val isProdReleaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("Prod", ignoreCase = false) && it.contains("release", ignoreCase = true)
}

if (isProdReleaseTaskRequested && !hasValidReleaseSigning) {
    throw GradleException(
        """
        Prod release signing is not configured.
        Provide a valid client/android/key.properties with keyAlias, keyPassword, storePassword and existing storeFile.
        Dev release builds use the debug keystore — only prod release requires production signing.
        """.trimIndent()
    )
}

val debugKeystoreFile = rootProject.file("keystores/debug.keystore")
val useProjectDebugKeystore = debugKeystoreFile.exists()

android {
    namespace = "developer.ivanmurzin.assettuner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        if (useProjectDebugKeystore) {
            create("debugProject") {
                storeFile = debugKeystoreFile
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }
        if (hasValidReleaseSigning) {
            create("release") {
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                storeFile = releaseStoreFile
                storePassword = releaseStorePassword
            }
        }
    }

    defaultConfig {
        applicationId = "developer.ivanmurzin.assettuner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Asset Tuner (dev)")
            manifestPlaceholders["deepLinkScheme"] = "assettunerdev"
            // Dev release сборки подписываются debug-ключом — production keystore не требуется.
            signingConfig = if (useProjectDebugKeystore) {
                signingConfigs.getByName("debugProject")
            } else {
                signingConfigs.getByName("debug")
            }
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Asset Tuner")
            manifestPlaceholders["deepLinkScheme"] = "assettuner"
            if (hasValidReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = if (useProjectDebugKeystore) {
                signingConfigs.getByName("debugProject")
            } else {
                signingConfigs.getByName("debug")
            }
        }
        release {
            // Подпись определяется на уровне productFlavors (dev → debug, prod → release).
        }
    }
}

flutter {
    source = "../.."
}
