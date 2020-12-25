// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The possible focus modes that can be set for a camera.
enum FocusMode {
  /// Continuously automatically adjust the focus settings.
  continuous,

  /// Automatically determine the focus settings once upon setting this mode or the focus point.
  auto,
}

/// Returns the focus mode as a String.
String serializeFocusMode(FocusMode focusMode) {
  switch (focusMode) {
    case FocusMode.continuous:
      return 'continuous';
    case FocusMode.auto:
      return 'auto';
    default:
      throw ArgumentError('Unknown FocusMode value');
  }
}

/// Returns the focus mode for a given String.
FocusMode deserializeFocusMode(String str) {
  switch (str) {
    case "continuous":
      return FocusMode.continuous;
    case "auto":
      return FocusMode.auto;
    default:
      throw ArgumentError('"$str" is not a valid FocusMode value');
  }
}
