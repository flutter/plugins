## 0.1.0+2

* Fixed bug where `Traces` and `HttpMetrics` weren't being passed to Firebase on iOS.

## 0.1.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.1.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.0.8+1

* Bump Android dependencies to latest.

## 0.0.8

* Set http version to be compatible with flutter_test.

## 0.0.7

* Added missing http package dependency.

## 0.0.6

* Bump Android and Firebase dependency versions.

## 0.0.5

Added comments explaining the time it takes to see performance results.

## 0.0.4

* Formatted code, updated comments, and removed unnecessary files.

## 0.0.3

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.0.2

* Added HttpMetric for monitoring for specific network requests.

## 0.0.1

* Initial Release.
