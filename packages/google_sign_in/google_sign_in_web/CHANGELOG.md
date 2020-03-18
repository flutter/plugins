## 0.8.4

* Remove all `fakeConstructor$` from the generated facade. JS interop classes do not support non-external constructors.

## 0.8.3+2

* Make the pedantic dev_dependency explicit.

## 0.8.3+1

* Updated documentation with more instructions about Google Sign In web setup.

## 0.8.3

* Fix initialization error that causes https://github.com/flutter/flutter/issues/48527
* Throw a PlatformException when there's an initialization problem (like wrong server-side config).
* Throw a StateError when checking .initialized before calling .init()
* Update setup instructions in the README.

## 0.8.2+1

* Add a non-op Android implementation to avoid a flaky Gradle issue.

## 0.8.2

* Require Flutter SDK 1.12.13+hotfix.4 or greater.

## 0.8.1+2

* Remove the deprecated `author:` field from pubspec.yaml
* Require Flutter SDK 1.10.0 or greater.

## 0.8.1+1

* Add missing documentation.

## 0.8.1

* Add podspec to enable compilation on iOS.

## 0.8.0

* Flutter for web initial release
