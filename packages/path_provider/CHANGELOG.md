## 0.5.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.5.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.4.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.4.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.3.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.3.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.2.2

* Add FLT prefix to iOS types

## 0.2.1+1

* Updated README

## 0.2.1

* Add function to determine external storage directory.

## 0.2.0

* Upgrade to new plugin registration. (https://groups.google.com/forum/#!topic/flutter-dev/zba1Ynf2OKM)

## 0.1.3

* Upgrade Android SDK Build Tools to 25.0.3.

## 0.1.2

* Add test.

## 0.1.1

* Change to README.md.

## 0.1.0

* Initial Open Source release.
