pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "Chronir"

include(":app")
include(":core:designsystem")
include(":core:model")
include(":core:data")
include(":core:services")
include(":feature:alarmlist")
include(":feature:alarmdetail")
include(":feature:alarmcreation")
include(":feature:alarmfiring")
include(":feature:settings")
include(":feature:sharing")
include(":feature:paywall")
include(":widget")
include(":tests")
