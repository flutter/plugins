## 3.2.1

* Set http version to be compatible with flutter_test.

## 3.2.0

* Add support for clearing authentication cache for Android.

## 3.1.0

* Add support to recover authentication for Android.

## 3.0.6

* Remove flaky displayName assertion

## 3.0.5

* Added missing http package dependency.

## 3.0.4

* Updated Gradle tooling to match Android Studio 3.1.2.

## 3.0.3+1

* Added documentation on where to find the list of available scopes.

## 3.0.3

* Added support for games sign in on Android.

## 3.0.2

* Updated Google Play Services dependency to version 15.0.0.

## 3.0.1

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 3.0.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 2.1.2

* Added a Delegate interface (IDelegate) that can be implemented by clients in
  order to override the functionality (for testing purposes for example).

## 2.1.1

* Fixed Dart 2 type errors.

## 2.1.0

* Enabled use in Swift projects.

## 2.0.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 2.0.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 1.0.3

* Add FLT prefix to iOS types

## 1.0.2

* Support setting foregroundColor in the avatar.

## 1.0.1

* Change GMS dependency to 11.+

## 1.0.0

* Make GoogleUserCircleAvatar fade profile image over the top of placeholder
* Bump to released version

## 0.3.1

* Updated GMS to always use latest patch version for 11.0.x builds

## 0.3.0

* Add a new `GoogleIdentity` interface, implemented by `GoogleSignInAccount`.
* Move `GoogleUserCircleAvatar` to "widgets" library (exported by
  base library for backwards compatibility) and make it take an instance
  of `GoogleIdentity`, thus allowing it to be used by other packages that
  provide implementations of `GoogleIdentity`.

## 0.2.1

* Plugin can (once again) be used in apps that extend `FlutterActivity`
* `signInSilently` is guaranteed to never throw
* A failed sign-in (caused by a failing `init` step) will no longer block subsequent sign-in attempts

## 0.2.0

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

## 0.1.0

* Update to use `GoogleSignIn` CocoaPod


## 0.0.6

* Fix crash on iOS when signing in caused by nil uiDelegate

## 0.0.5

* Require the use of `support-v4` library on Android. This is an API change in
  that plugin users will need their activity class to be an instance of
  `android.support.v4.app.FragmentActivity`. Flutter framework provides such
  an activity out of the box: `io.flutter.app.FlutterFragmentActivity`
* Ignore "Broken pipe" errors affecting iOS simulator
* Update to non-deprecated `application:openURL:options:` on iOS

## 0.0.4

* Prevent race conditions when GoogleSignIn methods are called concurrently (#94)

## 0.0.3

* Fix signOut and disconnect (they were silently ignored)
* Fix test (#10050)

## 0.0.2

* Don't try to sign in again if user is already signed in

## 0.0.1

* Initial Release
