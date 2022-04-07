// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A message that was sent by JavaScript code running in a [WebView].
class JavascriptMessage {
  /// Constructs a JavaScript message object.
  ///
  /// The `message` parameter must not be null.
  const JavascriptMessage(this.message, {this.reply}) : assert(message != null);

  /// The contents of the message that was sent by the JavaScript code.
  final String message;

  /// A callback for submitting a reply to the JavaScript code.
  ///
  /// For example for the following WebView and JavascriptChannel:
  ///
  /// ```dart
  /// WebView(
  ///   javascriptBridgeName: 'flutter_bridge',
  ///   ...
  ///
  /// JavascriptChannel(name: 'getName', onMessageReceived: (JavascriptMessage message) {
  ///   if (message.reply != null) {
  ///      message.reply!('webview_flutter');
  ///   }
  /// });
  /// ```
  ///
  /// JavaScript code can call:
  ///
  /// ```javascript
  /// flutter_bridge.getName({'arg..': 'value..'}, (info) => {console.log(info)});
  /// ```
  final Function(dynamic info)? reply;
}
