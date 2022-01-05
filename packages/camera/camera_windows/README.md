# Camera Windows Plugin

The windows implementation of [`camera`][camera].

*Note*: This plugin is under development. See [missing implementation](#missing-implementation).

## Usage

### Depend on the package

This package is not [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you need to add `camera_windows` separately to your project dependencies to use it with [`camera`][camera] plugin.

## Example

Find the example in the [`camera windows` package](https://pub.dev/packages/camera_windows#example).

## Limitations on the windows platform

### Device orientation

The device orientation is not detected for cameras yet. See [missing implementation](#missing-implementation)

- `CameraPlatform.onDeviceOrientationChanged` stream returns always one item: `DeviceOrientation.landscapeRight`

### Taking a picture

Captured pictures are saved to default `Pictures` folder.
This folder cannot be changed at the moment.

### Video recording 

Captures videos are saved to default `Videos` folder.
This folder cannot be changed at the moment.

Recording video do not work if preview is not started.

A video is recorded in  following video MIME type: `video/mp4`

Pausing and resuming the video is not supported at the moment.

## Missing implementation

The windows implementation of [`camera`][camera] is missing the following features:
- Exposure mode, point and offset
- Focus mode and point
- Sensor orientation
- Image format group
- Streaming of frames
- Video record pause and resume
- Support for multiple simultanious camera captures.

<!-- Links -->
[camera]: https://pub.dev/packages/camera_windows
