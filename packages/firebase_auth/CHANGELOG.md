## 0.8.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.7.0

* Introduce third-party auth provider classes that generate `AuthCredential`s
* **Breaking Change** Signing in, linking, and reauthenticating now require an `AuthCredential`
* **Breaking Change** Unlinking now uses providerId
* **Breaking Change** Moved reauthentication to FirebaseUser

## 0.6.7

* `FirebaseAuth` and `FirebaseUser` are now fully documented.
* `PlatformExceptions` now report error codes as stated in docs.
* Credentials can now be unlinked from Accounts with new methods on `FirebaseUser`.

## 0.6.6

* Users can now reauthenticate in response to operations that require a recent sign-in.

## 0.6.5

* Fixing async method `verifyPhoneNumber`, that would never return even in a successful call.

## 0.6.4

* Added support for Github signin and linking Github accounts to existing users.

## 0.6.3

* Add multi app support.

## 0.6.2+1

* Bump Android dependencies to latest.

## 0.6.2

* Add access to user metadata.

## 0.6.1

* Adding support for linkWithTwitterCredential in FirebaseAuth.

## 0.6.0

* Added support for `updatePassword` in `FirebaseUser`.
* **Breaking Change** Moved `updateEmail` and `updateProfile` to `FirebaseUser`.
  This brings the `firebase_auth` package inline with other implementations and documentation.

## 0.5.20

* Replaced usages of guava's: ImmutableList and ImmutableMap with platform
Collections.unmodifiableList() and Collections.unmodifiableMap().

## 0.5.19

* Update test package dependency to pick up Dart 2 support.
* Modified dependency on google_sign_in to point to a published
  version instead of a relative path.

## 0.5.18

* Adding support for updateEmail in FirebaseAuth.

## 0.5.17

* Adding support for FirebaseUser.delete.

## 0.5.16

* Adding support for setLanguageCode in FirebaseAuth.

## 0.5.15

* Bump Android and Firebase dependency versions.

## 0.5.14

* Fixed handling of auto phone number verification.

## 0.5.13

* Add support for phone number authentication.

## 0.5.12

* Fixed ArrayIndexOutOfBoundsException in handleStopListeningAuthState

## 0.5.11

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.5.10

* Updated iOS implementation to reflect Firebase API changes.

## 0.5.9

* Added support for signing in with a Twitter account.

## 0.5.8

* Added support to reload firebase user

## 0.5.7

* Added support to sendEmailVerification

## 0.5.6

* Added support for linkWithFacebookCredential

## 0.5.5

* Updated Google Play Services dependencies to version 15.0.0.

## 0.5.4

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.5.3

* Secure fetchProvidersForEmail (no providers)

## 0.5.2

* Fixed Dart 2 type error in fetchProvidersForEmail.

## 0.5.1

* Added support to fetchProvidersForEmail

## 0.5.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.4.7

* Fixed Dart 2 type errors.

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
