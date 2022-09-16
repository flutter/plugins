// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines the parameters of the pending navigation callback.
class NavigationRequest {
  /// Creates a [NavigationRequest].
  const NavigationRequest({
    required this.url,
    required this.isMainFrame,
  });

  /// The URL of the pending navigation request.
  final String url;

  /// Indicates whether to inject the script into the main frame or all frames.
  final bool isMainFrame;
}
