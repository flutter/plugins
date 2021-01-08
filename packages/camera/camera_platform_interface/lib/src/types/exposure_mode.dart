// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The possible exposure modes that can be set for a camera.
enum ExposureMode {
  /// Automatically determine exposure settings.
  auto,

  /// Lock the currently determined exposure settings.
  locked,
}

/// Returns the exposure mode as a String.
String serializeExposureMode(ExposureMode exposureMode) {
  if (exposureMode == null) return null;
  switch (exposureMode) {
    case ExposureMode.locked:
      return 'locked';
    case ExposureMode.auto:
      return 'auto';
    default:
      throw ArgumentError('Unknown ExposureMode value');
  }
}

/// Returns the exposure mode for a given String.
ExposureMode deserializeExposureMode(String str) {
  if (str == null) return null;
  switch (str) {
    case "locked":
      return ExposureMode.locked;
    case "auto":
      return ExposureMode.auto;
    default:
      throw ArgumentError('"$str" is not a valid ExposureMode value');
  }
}
