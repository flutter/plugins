## 0.2.1

* Throw `PlatformException` if there is an error retrieving dynamic link.

## 0.2.0+4

* Fix crash when receiving `ShortDynamicLink` warnings.

## 0.2.0+3

* Log messages about automatic configuration of the default app are now less confusing.

## 0.2.0+2

* Remove categories.

## 0.2.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.2.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.1.1

* Update example to create a clickable and copyable link.

## 0.1.0+2

* Change android `invites` dependency to `dynamic links` dependency.

## 0.1.0+1

* Bump Android dependencies to latest.

## 0.1.0

* **Breaking Change** Calls to retrieve dynamic links on iOS always returns null after first call.

## 0.0.6

* Bump Android and Firebase dependency versions.

## 0.0.5

* Added capability to receive dynamic links.

## 0.0.4

* Fixed dynamic link dartdoc generation.

## 0.0.3

* Fixed incorrect homepage link in pubspec.

## 0.0.2

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.0.1

* Initial release with api to create long or short dynamic links.
