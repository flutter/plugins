// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';

/// Parses a string into a corresponding CameraLensDirection.
CameraLensDirection parseCameraLensDirection(String string) {
  switch (string) {
    case 'front':
      return CameraLensDirection.front;
    case 'back':
      return CameraLensDirection.back;
    case 'external':
      return CameraLensDirection.external;
  }
  throw ArgumentError('Unknown CameraLensDirection value');
}

/// Returns the device orientation as a String.
String serializeDeviceOrientation(DeviceOrientation orientation) {
  switch (orientation) {
    case DeviceOrientation.portraitUp:
      return 'portraitUp';
    case DeviceOrientation.portraitDown:
      return 'portraitDown';
    case DeviceOrientation.landscapeRight:
      return 'landscapeRight';
    case DeviceOrientation.landscapeLeft:
      return 'landscapeLeft';
  }
  // The enum comes from a different package, which could get a new value at
  // any time, so provide a fallback that ensures this won't break when used
  // with a version that contains new values. This is deliberately outside
  // the switch rather than a `default` so that the linter will flag the
  // switch as needing an update.
  // ignore: dead_code
  return 'portraitUp';
}

/// Returns the device orientation for a given String.
DeviceOrientation deserializeDeviceOrientation(String str) {
  switch (str) {
    case 'portraitUp':
      return DeviceOrientation.portraitUp;
    case 'portraitDown':
      return DeviceOrientation.portraitDown;
    case 'landscapeRight':
      return DeviceOrientation.landscapeRight;
    case 'landscapeLeft':
      return DeviceOrientation.landscapeLeft;
    default:
      throw ArgumentError('"$str" is not a valid DeviceOrientation value');
  }
}
