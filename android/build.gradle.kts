allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    pluginManager.withPlugin("com.android.library") {
        dependencies.constraints.add("testImplementation", "org.robolectric:robolectric:4.18.1") {
            because("Android plugin unit tests need a Robolectric runner that supports Java 25")
        }
        dependencies.constraints.add("testImplementation", "junit:junit:4.13.2") {
            because("Robolectric's runner requires JUnit 4.13's filtered child list")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
