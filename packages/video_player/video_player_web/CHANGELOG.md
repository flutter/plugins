## 0.2.0

* **Breaking change**. VideoPlayerController instance now can be reused for different data sources. 
`VideoPlayerController()` constructor now accepts nothing and immediately instantiates video player on platform side without data source.
`VideoPlayerController.initialize()` removed. To set data source now you should use one of three methods:
`VideoPlayerController.setNetworkDataSource`, `VideoPlayerController.setAssetDataSource` or 
`VideoPlayerController.setFileDataSource`. All this three methods set this data source to video player
 on both Dart and platform side and return Future which completes after the data source is ready to play.

## 0.1.2

* Add a `PlatformException` to the player's `eventController` when there's a `videoElement.onError`. Fixes https://github.com/flutter/flutter/issues/48884.
* Handle DomExceptions on videoElement.play() and turn them into `PlatformException` as well, so we don't end up with unhandled Futures.
* Update setup instructions in the README.

## 0.1.1+1

* Add an android/ folder with no-op implementation to workaround https://github.com/flutter/flutter/issues/46898.

## 0.1.1

* Support videos from assets.

## 0.1.0+1

* Remove the deprecated `author:` field from pubspec.yaml
* Require Flutter SDK 1.10.0 or greater.

## 0.1.0

* Initial release
