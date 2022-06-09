// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

/// Error returned in `WebView.onWebResourceError` when a web resource loading error has occurred.
class AndroidWebResourceError extends WebResourceError {
  /// Creates a new [AndroidWebResourceError].
  const AndroidWebResourceError({
    required int errorCode,
    required String description,
    WebResourceErrorType? errorType,
    this.failingUrl,
  }) : super(
          errorCode: errorCode,
          description: description,
          errorType: errorType,
        );

  /// Gets the URL for which the failing resource request was made.
  final String? failingUrl;
}
