# Camera Plugin

[![pub package](https://img.shields.io/pub/v/camera.svg)](https://pub.dev/packages/camera)

A Flutter plugin for iOS, Android and Web allowing access to the device cameras.

|                | Android | iOS      | Web                    |
|----------------|---------|----------|------------------------|
| **Support**    | SDK 21+ | iOS 10+* | [See `camera_web `][1] |

## Features

* Display live camera preview in a widget.
* Snapshots can be captured and saved to a file.
* Record video.
* Add access to the image stream from Dart.

## Installation

First, add `camera` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

### iOS

\* The camera plugin compiles for any version of iOS, but its functionality
requires iOS 10 or higher. If compiling for iOS 9, make sure to programmatically
check the version of iOS running on the device before using any camera plugin features.
The [device_info_plus](https://pub.dev/packages/device_info_plus) plugin, for example, can be used to check the iOS version.

Add two rows to the `ios/Runner/Info.plist`:

* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
```

### Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```

It's important to note that the `MediaRecorder` class is not working properly on emulators, as stated in the documentation: https://developer.android.com/reference/android/media/MediaRecorder. Specifically, when recording a video with sound enabled and trying to play it back, the duration won't be correct and you will only see the first frame.

### Web integration

For web integration details, see the
[`camera_web` package](https://pub.dev/packages/camera_web).

### Handling Lifecycle states

As of version [0.5.0](https://github.com/flutter/plugins/blob/master/packages/camera/CHANGELOG.md#050) of the camera plugin, lifecycle changes are no longer handled by the plugin. This means developers are now responsible to control camera resources when the lifecycle state is updated. Failure to do so might lead to unexpected behavior (for example as described in issue [#39109](https://github.com/flutter/flutter/issues/39109)). Handling lifecycle changes can be done by overriding the `didChangeAppLifecycleState` method like so:

```dart
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }
```

### Example

Here is a small example flutter app displaying a full screen camera preview.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(controller),
    );
  }
}

```

For a more elaborate usage example see [here](https://github.com/flutter/plugins/tree/main/packages/camera/camera/example).

[1]: https://pub.dev/packages/camera_web#limitations-on-the-web-platform
