# Video Player plugin for Flutter

[![pub package](https://img.shields.io/pub/v/video_player.svg)](https://pub.dartlang.org/packages/video_player)

A Flutter plugin for iOS, Android and Web for playing back video on a Widget surface.

**Please set your constraint to `video_player: '>=0.10.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.10.y+z`.
Please use `video_player: '>=0.10.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

![The example app running in iOS](https://github.com/flutter/plugins/blob/master/packages/video_player/video_player/doc/demo_ipod.gif?raw=true)

*Note*: This plugin is still under development, and some APIs might not be available yet.
[Feedback welcome](https://github.com/flutter/flutter/issues) and
[Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Installation

First, add `video_player` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### iOS

Warning: The video player is not functional on iOS simulators. An iOS device must be used during development/testing.

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

This entry allows your app to access video files by URL.

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

The Flutter project template adds it, so it may already be there.

### Web

This plugin compiles for the web platform since version `0.10.5`, in recent enough versions of Flutter (`>=1.12.13+hotfix.4`).

> The Web platform does **not** suppport `dart:io`, so avoid using the `VideoPlayerController.file` constructor for the plugin. Using the constructor attempts to create a `VideoPlayerController.file` that will throw an `UnimplementedError`.

Different web browsers may have different video-playback capabilities (supported formats, autoplay...). Check [package:video_player_web](https://pub.dev/packages/video_player_web) for more web-specific information.

## Supported Formats

- On iOS, the backing player is [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer).
  The supported formats vary depending on the version of iOS, [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset) class
  has [audiovisualTypes](https://developer.apple.com/documentation/avfoundation/avurlasset/1386800-audiovisualtypes?language=objc) that you can query for supported av formats.
- On Android, the backing player is [ExoPlayer](https://google.github.io/ExoPlayer/),
  please refer [here](https://google.github.io/ExoPlayer/supported-formats.html) for list of supported formats.
- On Web, available formats depend on your users' browsers (vendor and version). Check [package:video_player_web](https://pub.dev/packages/video_player_web) for more specific information.

## Example

```dart
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4')
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
          child: _controller.value.initialized
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
