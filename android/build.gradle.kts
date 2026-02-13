// Build script raiz de Android: repositorios y ubicacion de carpetas de build.
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirige el output de compilacion al build compartido de la raiz del proyecto.
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Fuerza que cada modulo dependa de la evaluacion del modulo app.
    project.evaluationDependsOn(":app")
}

// Tarea global para limpiar artefactos de compilacion.
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
