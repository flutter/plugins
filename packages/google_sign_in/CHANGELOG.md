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
