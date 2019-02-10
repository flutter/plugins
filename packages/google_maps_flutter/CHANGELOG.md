## 0.2.0+2

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.2.0+1

* Fixed a bug which the camera is not positioned correctly at map initialization(temporary workaround)(https://github.com/flutter/flutter/issues/27550).

## 0.2.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.1.0

* Move the map options from the GoogleMapOptions class to GoogleMap widget parameters.

## 0.0.3+3

* Relax Flutter version requirement to 0.11.9.

## 0.0.3+2

* Update README to recommend using the package from pub.

## 0.0.3+1

* Bug fix: custom marker images were not working on iOS as we were not keeping
  a reference to the plugin registrar so couldn't fetch assets.

## 0.0.3

* Don't export `dart:async`.
* Update the minimal required Flutter SDK version to one that supports embedding platform views.

## 0.0.2

* Initial developers preview release.
