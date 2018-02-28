## 0.4.6

* Fixed Dart 2 type errors.

## 0.4.5

* Enabled use in Swift projects.

## 0.4.4

* Added support for sendPasswordResetEmail

## 0.4.3

* Moved to the io.flutter.plugins organization.

## 0.4.2

* Added support for changing user data

## 0.4.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.4.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.3.2

* Added FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.3.1

* Change GMS dependency to 11.+

## 0.3.0

* **Breaking Change**: Method FirebaseUser getToken was renamed to getIdToken.

## 0.2.5

* Added support for linkWithCredential with Google credential

## 0.2.4

* Added support for `signInWithCustomToken`
* Added `Stream<FirebaseUser> onAuthStateChanged` event to listen when the user change

## 0.2.3+1

* Aligned author name with rest of repo.

## 0.2.3

* Remove dependency on Google/SignIn

## 0.2.2

* Remove dependency on FirebaseUI

## 0.2.1

* Added support for linkWithEmailAndPassword

## 0.2.0

* **Breaking Change**: Method currentUser is async now.

## 0.1.2

* Added support for signInWithFacebook

## 0.1.1

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.1.0

* Updated to Firebase SDK Version 11.0.1
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

## 0.0.4

* Add method getToken() to FirebaseUser

## 0.0.3+1

* Updated README.md

## 0.0.3

* Added support for createUserWithEmailAndPassword, signInWithEmailAndPassword, and signOut Firebase methods

## 0.0.2+1

* Updated README.md

## 0.0.2

* Bump buildToolsVersion to 25.0.3

## 0.0.1

* Initial Release
