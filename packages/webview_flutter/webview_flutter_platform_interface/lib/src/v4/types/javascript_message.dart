// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// A message that was sent by JavaScript code running in a [WebView].
@sealed
class JavaScriptMessage {
  /// Constructs a JavaScript message object.
  ///
  /// The `message` parameter must not be null.
  const JavaScriptMessage(this.message) : assert(message != null);

  /// The contents of the message that was sent by the JavaScript code.
  final String message;
}
