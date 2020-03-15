## 0.3.0+1

* Replace deprecated `getFlutterEngine` call on Android.

## 0.3.0

* Updates documentation to instruct developers not to launch the activity since
  we are doing it for them.
* Renames `FlutterRunner` to `FlutterTestRunner` to avoid conflict with Fuchsia.

## 0.2.4+4

* Fixed a hang that occurred on platforms that don't have a `MethodChannel` listener registered..

## 0.2.4+3

* Fixed code snippet in the readme under the "Using Flutter driver to run tests" section.

## 0.2.4+2

* Make the pedantic dev_dependency explicit.

## 0.2.4+1

* Registering web service extension for using e2e with web.

## 0.2.4

* Fixed problem with XCTest in XCode 11.3 where the testing bundles were getting
  opened multiple times which interfered with the singleton logic for E2EPlugin.

## 0.2.3+1

* Added a driver test for failure behavior.

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
