## 0.1.3+2

* Allow users to set the 'muted' attribute on video elements by setting their volume to 0.
* Do not parse URIs on 'network' videos to not break blobs (Safari).

## 0.1.3+1

* Remove Android folder from `video_player_web`.

## 0.1.3

* Updated video_player_platform_interface, bumped minimum Dart version to 2.1.0.

## 0.1.2+3

* Declare API stability and compatibility with `1.0.0` (more details at: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0).

## 0.1.2+2

* Add `analysis_options.yaml` to the package, so we can ignore `undefined_prefixed_name` errors. Works around https://github.com/flutter/flutter/issues/41563.

## 0.1.2+1

* Make the pedantic dev_dependency explicit.

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
