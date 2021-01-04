// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The possible orientations for the device.
enum DeviceOrientation {
  /// Upright portrait orientation.
  portrait,

  /// Upside down portrait orientation.
  portraitUpsideDown,

  /// Landscape mode, with the bottom of the phone facing right.
  landscapeRight,

  /// Landscape mode, with the bottom of the phone facing left.
  landscapeLeft,
}

/// Returns the device orientation as a String.
String serializeDeviceOrientation(DeviceOrientation orientation) {
  switch (orientation) {
    case DeviceOrientation.portrait:
      return 'portrait';
    case DeviceOrientation.portraitUpsideDown:
      return 'portraitUpsideDown';
    case DeviceOrientation.landscapeRight:
      return 'landscapeRight';
    case DeviceOrientation.landscapeLeft:
      return 'landscapeLeft';
    default:
      throw ArgumentError('Unknown DeviceOrientation value');
  }
}

/// Returns the device orientation for a given String.
DeviceOrientation deserializeDeviceOrientation(String str) {
  switch (str) {
    case "portrait":
      return DeviceOrientation.portrait;
    case "portraitUpsideDown":
      return DeviceOrientation.portraitUpsideDown;
    case "landscapeRight":
      return DeviceOrientation.landscapeRight;
    case "landscapeLeft":
      return DeviceOrientation.landscapeLeft;
    default:
      throw ArgumentError('"$str" is not a valid DeviceOrientation value');
  }
}
