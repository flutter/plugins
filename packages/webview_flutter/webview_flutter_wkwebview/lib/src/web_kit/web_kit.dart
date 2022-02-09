// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The media types that require a user gesture to begin playing.
///
/// Wraps [WKAudiovisualMediaTypes](https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes?language=objc).
enum WKAudiovisualMediaType {
  /// No media types require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypenone?language=objc.
  none,

  /// Media types that contain audio require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypeaudio?language=objc.
  audio,

  /// Media types that contain video require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypevideo?language=objc.
  video,

  /// All media types require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypeall?language=objc.
  all,
}

/// A collection of properties that you use to initialize a web view.
///
/// Wraps [WKWebViewConfiguration](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration?language=objc)
class WKWebViewConfiguration {
  /// Indicates whether HTML5 videos play inline or use the native full-screen controller.
  set allowsInlineMediaPlayback(bool allow) {
    throw UnimplementedError();
  }

  /// The media types that require a user gesture to begin playing.
  ///
  /// Use [WKAudiovisualMediaType.none] to indicate that no user gestures are
  /// required to begin playing media.
  set mediaTypesRequiringUserActionForPlayback(
    Set<WKAudiovisualMediaType> types,
  ) {
    assert(types.isNotEmpty);
    throw UnimplementedError();
  }
}

/// Object that displays interactive web content, such as for an in-app browser.
///
/// Wraps [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview?language=objc).
class WKWebView {
  /// Construct a [WKWebView].
  ///
  /// [configuration] contains the configuration details for the web view. This
  /// method saves a copy of your configuration object. Changes you make to your
  /// original object after calling this method have no effect on the web view’s
  /// configuration. For a list of configuration options and their default
  /// values, see [WKWebViewConfiguration]. If you didn’t create your web view
  /// using the `configuration` parameter, this value uses a default
  /// configuration object.
  // TODO(bparrishMines): Remove ignore once constructor is implemented.
  // ignore: avoid_unused_constructor_parameters
  WKWebView([WKWebViewConfiguration? configuration]) {
    throw UnimplementedError();
  }
}
