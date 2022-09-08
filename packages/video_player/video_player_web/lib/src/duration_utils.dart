// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The "length" of a video which doesn't have finite duration.
// See: https://github.com/flutter/flutter/issues/107882
const Duration jsCompatibleTimeUnset = Duration(
  milliseconds: -9007199254740990, // Number.MIN_SAFE_INTEGER + 1. -(2^53 - 1)
);

/// Converts a `num` duration coming from a [VideoElement] into a [Duration] that
/// the plugin can use.
///
/// From the documentation, `videoDuration` is "a double-precision floating-point
/// value indicating the duration of the media in seconds.
/// If no media data is available, the value `NaN` is returned.
/// If the element's media doesn't have a known duration —such as for live media
/// streams— the value of duration is `+Infinity`."
///
/// If the `videoDuration` is finite, this method returns it as a `Duration`.
/// If the `videoDuration` is `Infinity`, the duration will be
/// `-9007199254740990` milliseconds. (See https://github.com/flutter/flutter/issues/107882)
/// If the `videoDuration` is `NaN`, this will return null.
Duration? convertNumVideoDurationToPluginDuration(num duration) {
  if (duration.isFinite) {
    return Duration(
      milliseconds: (duration * 1000).round(),
    );
  } else if (duration.isInfinite) {
    return jsCompatibleTimeUnset;
  }
  return null;
}
