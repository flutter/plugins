## 4.2.0

* Add `contentUri` to `DataSourceType`.

## 4.1.0

* Add `httpHeaders` to `DataSource`

## 4.0.0

* **Breaking Changes**:
  * Migrate to null-safety
  * Update to latest Pigeon. This includes a breaking change to how the test logic is exposed.
* Add note about the `mixWithOthers` option being ignored on the web.
* Make DataSource's `uri` parameter nullable.
* `messages.dart` sets Dart `2.12`.

## 3.0.0

* Version 3 only was published as nullsafety "previews".

## 2.2.1

* Update Flutter SDK constraint.

## 2.2.0

* Added option to set the video playback speed on the video controller.

## 2.1.1

* Fix mixWithOthers test channel.

## 2.1.0

* Add VideoPlayerOptions with audio mix mode

## 2.0.2

* Migrated tests to use pigeon correctly.

## 2.0.1

* Updated minimum Dart version.
* Added class to help testing Pigeon communication.

## 2.0.0

* Migrated to [pigeon](https://pub.dev/packages/pigeon).

## 1.0.5

* Make the pedantic dev_dependency explicit.

## 1.0.4

* Remove the deprecated `author:` field from pubspec.yaml
* Require Flutter SDK 1.10.0 or greater.

## 1.0.3

* Document public API.

## 1.0.2

* Fix unawaited futures in the tests.

## 1.0.1

* Return correct platform event type when buffering

## 1.0.0

* Initial release.
