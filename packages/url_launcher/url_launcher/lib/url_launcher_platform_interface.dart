// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// The interface that implementations of url_launcher must implement.
abstract class UrlLauncherPlatform {
  /// Returns `true` if this platform is able to launch [url].
  Future<bool> canLaunch(String url);

  /// Returns `true` if the given [url] was successfully launched.
  ///
  /// For documentation on the other arguments, see the `launch` documentation
  /// in `package:url_launcher/url_launcher.dart`.
  Future<bool> launch(
      String url,
      bool useSafariVC,
      bool useWebView,
      bool enableJavaScript,
      bool enableDomStorage,
      bool universalLinksOnly,
      Map<String, String> headers,
  );


  /// Closes the WebView, if one was opened earlier by `launch`.
  Future<void> closeWebView();
}
