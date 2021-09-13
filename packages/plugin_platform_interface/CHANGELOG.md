## 2.0.1

* Fix `federated flutter plugins` link in the README.md.

## 2.0.0

* Migrate to null safety.

## 1.0.3

* Fix homepage in `pubspec.yaml`.

## 1.0.2

* Make the pedantic dev_dependency explicit.

## 1.0.1

* Fixed a bug that made all platform interfaces appear as mocks in release builds (https://github.com/flutter/flutter/issues/46941).

## 1.0.0 - Initial release.

* Provides `PlatformInterface` with common mechanism for enforcing that a platform interface
  is not implemented with `implements`.
* Provides test only `MockPlatformInterface` to enable using Mockito to mock platform interfaces.
