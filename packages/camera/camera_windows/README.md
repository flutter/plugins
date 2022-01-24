# Camera Windows Plugin

The windows implementation of [`camera`][camera].

*Note*: This plugin is under development.
See [missing implementations and limitations](#limitations-on-the-windows-platform)

## Usage

### Depend on the package

This package is not an [endorsed][endorsed-federated-plugin] 
implementation of the [`camera`][camera] plugin, so you'll need to
[add it explicitly][install]

## Limitations on the Windows platform

### Device orientation

The device orientation is not detected for cameras.

- `CameraPlatform.onDeviceOrientationChanged` stream always
returns the following value: `DeviceOrientation.landscapeRight`

### Taking a picture

Captured pictures are saved to default `Pictures` folder.
This folder cannot be changed at the moment.

### Video recording

Captures videos are saved to default `Videos` folder.
This folder cannot be changed at the moment.

Video recording does not work if preview is not started.
If preview is not drawn on the screen it is recommended to pause preview
to avoid unnecessary processing of the textures while recording.

Pausing and resuming the video recording is not supported.

### Other limitations

The windows implementation of [`camera`][camera]
is missing the following features:

- Exposure mode, point and offset
- Focus mode and point
- Image format group
- Streaming of frames

<!-- Links -->

[camera]: https://pub.dev/packages/camera
[endorsed-federated-plugin]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[install]: https://pub.dev/packages/camera_windows/install
