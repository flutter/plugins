// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../webview_platform.dart';

/// A message that was sent by JavaScript code running in a [WebView].
///
/// Platform specific implementations can add additional fields by extending
/// this class and provide a factory method that takes the
/// [JavaScriptMessage] as a parameter.
///
/// {@tool sample}
/// This example demonstrates how to extend the [JavaScriptMessage] to
/// provide additional platform specific parameters.
///
/// Note that the additional parameters should always accept `null` or have a
/// default value to prevent breaking changes.
///
/// ```dart
/// class WKScriptMessage extends JavaScriptMessage {
///   WKScriptMessage._(
///     JavaScriptMessage javaScriptMessage,
///     this.extraData,
///   ) : super(javaScriptMessage.message);
///
///   factory WKScriptMessage.fromJavaScriptMessage(
///     JavaScriptMessage javaScriptMessage,
///     String? extraData,
///   }) {
///     return WKScriptMessage._(
///       javaScriptMessage: javaScriptMessage,
///       extraData: extraData,
///     );
///   }
///
///   final String? extraData;
/// }
/// ```
/// {@end-tool}
@immutable
class JavaScriptMessage extends PlatformInterface {
  /// Creates a new JavaScript message object.
  factory JavaScriptMessage(String message) {
    final JavaScriptMessage javaScriptMessage =
        WebViewPlatform.instance!.createJavaScriptMessage(message);
    PlatformInterface.verify(javaScriptMessage, _token);
    return javaScriptMessage;
  }

  /// Used by the platform implementation to create a new
  /// [JavaScriptMessage].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  JavaScriptMessage.implementation(this.message) : super(token: _token);

  static final Object _token = Object();

  /// The contents of the message that was sent by the JavaScript code.
  final String message;
}
