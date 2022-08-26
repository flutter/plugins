<?code-excerpt path-base="excerpts/packages/video_player_example"?>

# Video Player plugin for Flutter

[![pub package](https://img.shields.io/pub/v/video_player.svg)](https://pub.dev/packages/video_player)

A Flutter plugin for iOS, Android and Web for playing back video on a Widget surface.

|             | Android | iOS  | Web   |
|-------------|---------|------|-------|
| **Support** | SDK 16+ | 9.0+ | Any\* |

![The example app running in iOS](https://github.com/flutter/plugins/blob/main/packages/video_player/video_player/doc/demo_ipod.gif?raw=true)

## Installation

First, add `video_player` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

### iOS

If you need to access videos using `http` (rather than `https`) URLs, you will need to add
the appropriate `NSAppTransportSecurity` permissions to your app's _Info.plist_ file, located
in `<project root>/ios/Runner/Info.plist`. See
[Apple's documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity)
to determine the right combination of entries for your use case and supported iOS versions.

### Android

If you are using network-based videos, ensure that the following permission is present in your
Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Web

> The Web platform does **not** suppport `dart:io`, so avoid using the `VideoPlayerController.file` constructor for the plugin. Using the constructor attempts to create a `VideoPlayerController.file` that will throw an `UnimplementedError`.

\* Different web browsers may have different video-playback capabilities (supported formats, autoplay...). Check [package:video_player_web](https://pub.dev/packages/video_player_web) for more web-specific information.

The `VideoPlayerOptions.mixWithOthers` option can't be implemented in web, at least at the moment. If you use this option in web it will be silently ignored.

## Supported Formats

- On iOS, the backing player is [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer).
  The supported formats vary depending on the version of iOS, [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset) class
  has [audiovisualTypes](https://developer.apple.com/documentation/avfoundation/avurlasset/1386800-audiovisualtypes?language=objc) that you can query for supported av formats.
- On Android, the backing player is [ExoPlayer](https://google.github.io/ExoPlayer/),
  please refer [here](https://google.github.io/ExoPlayer/supported-formats.html) for list of supported formats.
- On Web, available formats depend on your users' browsers (vendor and version). Check [package:video_player_web](https://pub.dev/packages/video_player_web) for more specific information.

## Example

<?code-excerpt "basic.dart (basic-example)"?>
```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({Key? key}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
```

## Usage

The following section contains usage information that goes beyond what is included in the
documentation in order to give a more elaborate overview of the API.

This is not complete as of now. You can contribute to this section by [opening a pull request](https://github.com/flutter/plugins/pulls).

### Playback speed

You can set the playback speed on your `_controller` (instance of `VideoPlayerController`) by
calling `_controller.setPlaybackSpeed`. `setPlaybackSpeed` takes a `double` speed value indicating
the rate of playback for your video.
For example, when given a value of `2.0`, your video will play at 2x the regular playback speed
and so on.

To learn about playback speed limitations, see the [`setPlaybackSpeed` method documentation](https://pub.dev/documentation/video_player/latest/video_player/VideoPlayerController/setPlaybackSpeed.html).

Furthermore, see the example app for an example playback speed implementation.
