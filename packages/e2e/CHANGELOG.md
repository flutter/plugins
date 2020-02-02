## 0.2.3

* Updates `E2EPlugin` and add skeleton iOS test case `E2EIosTest`.
* Adds instructions to README.md about e2e testing on iOS devices.
* Adds iOS e2e testing to example.

## 0.2.2+3

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.2.2+2

* Adds an android dummy project to silence warnings and removes unnecessary
  .gitignore files.

## 0.2.2+1

* Fix pedantic lints. Adds a missing await in the example test and some missing
  documentation.

## 0.2.2

* Added a stub macos implementation
* Added a macos example

## 0.2.1+1

* Updated README.

## 0.2.1

* Support the v2 Android embedder.
* Print a warning if the plugin is not registered.
* Updated method channel name.
* Set a Flutter minimum SDK version.

## 0.2.0+1

* Updated README.

## 0.2.0

* Renamed package from instrumentation_adapter to e2e.
* Refactored example app test.
* **Breaking change**. Renamed `InstrumentationAdapterFlutterBinding` to
  `E2EWidgetsFlutterBinding`.
* Updated README.

## 0.1.4

* Migrate example to AndroidX.
* Define clang module for iOS.

## 0.1.3

* Added example app.
* Added stub iOS implementation.
* Updated README.
* No longer throws errors when running tests on the host.

## 0.1.2

* Added support for running tests using Flutter driver.

## 0.1.1

* Updates about using *androidx* library.

## 0.1.0

* Update boilerplate test to use `@Rule` instead of `FlutterTest`.

## 0.0.2

* Document current usage instructions, which require adding a Java test file.

## 0.0.1

* Initial release
