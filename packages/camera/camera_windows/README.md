# Camera Windows Plugin

The Windows implementation of [`camera`][camera].

*Note*: This plugin is under development.
See [missing implementations and limitations](#missing-features-on-the-windows-platform).

## Usage

### Depend on the package

This package is not an [endorsed][endorsed-federated-plugin]
implementation of the [`camera`][camera] plugin, so in addition to depending
on [`camera`][camera] you'll need to
[add `camera_windows` to your pubspec.yaml explicitly][install].
Once you do, you can use the [`camera`][camera] APIs as you normally would.

## Missing features on the Windows platform

### Device orientation

Device orientation detection
is not yet implemented: [issue #97540][device-orientation-issue].

### Pause and Resume video recording

Pausing and resuming the video recording
is not supported due to Windows API limitations.

### Exposure mode, point and offset

Support for explosure mode and offset
is not yet implemented: [issue #97537][camera-control-issue].

Exposure points are not supported due to
limitations of the Windows API.

### Focus mode and point

Support for explosure mode and offset
is not yet implemented: [issue #97537][camera-control-issue].

### Flash mode

Support for flash mode is not yet implemented: [issue #97537][camera-control-issue].

Focus points are not supported due to
current limitations of the Windows API.

### Streaming of frames

Support for image streaming is not yet implemented: [issue #97542][image-streams-issue].

## Error handling

Camera errors can be listened using the platform's `onCameraError` method.

Listening to errors is important, and in certain situations,
disposing of the camera is the only way to reset the situation.

<!-- Links -->

[camera]: https://pub.dev/packages/camera
[endorsed-federated-plugin]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[install]: https://pub.dev/packages/camera_windows/install
[camera-control-issue]: https://github.com/flutter/flutter/issues/97537
[device-orientation-issue]: https://github.com/flutter/flutter/issues/97540
[image-streams-issue]: https://github.com/flutter/flutter/issues/97542
