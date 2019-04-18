// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a request made by the [WebView] widget.
///
/// See also:
/// * [WebView.initialRequest] for how this gets used.
class Request {
  /// Constructs a [Request] object with the given [url]
  /// and [headers].
  const Request({
    this.url,
    this.headers,
  });

  /// The URL to load.
  final String url;

  /// The headers  to be passed in when making the request.
  final Map<String, String> headers;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    addIfNonNull('url', url);
    addIfNonNull('headers', headers);

    return optionsMap;
  }
}
