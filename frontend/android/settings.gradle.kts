// Configuracion de plugins/repositorios de Gradle para todo el workspace Android.
pluginManagement {
    // Obtiene la ruta del SDK de Flutter desde local.properties.
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    // Expone las tareas/plugins de flutter_tools al build de Android.
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    // Repositorios donde Gradle busca plugins.
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Versiones de plugins principales del proyecto.
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

// Modulo Android de la app Flutter.
include(":app")
