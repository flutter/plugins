## 3.0.0

* **Breaking change**. VideoPlayerController instance now can be reused for different data sources. 
`VideoPlayerPlatform.create()` now accepts nothing and instantiates video player on platform side without data source.
To set data source now you should use `VideoPlayerPlatform.setDataSource(int textureId, DataSource dataSource)`.
This method set data source to video player associated with passed textureId on platform side and return Future which completes after the data source is ready to play.
`VideoEvent` now contains `key` field to match events from platform with concrete data source and avoid raise condition when we changed data source on Dart side and after this receive event from old data source.
So platform implementers should use this key do determine is this `VideoEvent` relate to current data source or not.

## 2.2.0

* Added option to set the video playback speed on the video controller.

## 2.1.1

* Fix mixWithOthers test channel.

## 2.1.0

* Add VideoPlayerOptions with audo mix mode

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
