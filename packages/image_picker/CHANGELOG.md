## 0.1.1

* Updated Gradle repositories declaration to avoid the need for manual configuration
  in the consuming app.

## 0.1.0+1

* Updated readme and description in pubspec.yaml

## 0.1.0

* Updated dependencies
* **Breaking Change**: You need to add a maven section with the "https://maven.google.com" endpoint to the repository section of your `android/build.gradle`. For example:
```gradle
allprojects {
    repositories {
        jcenter()
        maven {                              // NEW
            url "https://maven.google.com"   // NEW
        }                                    // NEW
    }
}
```

## 0.0.3

* Fix for crash on iPad when showing the Camera/Gallery selection dialog

## 0.0.2+2

* Updated README

## 0.0.2+1

* Updated README

## 0.0.2

* Fix crash when trying to access camera on a device without camera (e.g. the Simulator)

## 0.0.1

* Initial Release
