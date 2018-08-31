// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef void WebViewCreatedCallback(WebViewController controller);

/// A web view widget for showing html content.
class WebView extends StatefulWidget {
  /// Creates a new web view.
  ///
  /// The web view can be controlled using a `WebViewController` that is passed to the
  /// `onWebViewCreated` callback once the web view is created.
  ///
  /// The `gestureRecognizers` parameter must not be null;
  const WebView({
    Key key,
    this.onWebViewCreated,
    this.gestureRecognizers = const <OneSequenceGestureRecognizer>[],
  })  : assert(gestureRecognizers != null),
        super(key: key);

  /// If not null invoked once the web view is created.
  final WebViewCreatedCallback onWebViewCreated;

  /// Which gestures should be consumed by the web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the webview is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this list is empty, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final List<OneSequenceGestureRecognizer> gestureRecognizers;

  @override
  State<StatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return new GestureDetector(
        // We prevent text selection by intercepting long press event.
        // This is a temporary workaround to prevent a native crash on a second
        // text selection.
        // TODO(amirh): remove this when the selection handles crash is resolved.
        // https://github.com/flutter/flutter/issues/21239
        onLongPress: () {},
        child: AndroidView(
          viewType: 'plugins.flutter.io/webview',
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          // WebView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.rtl,
        ),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the webview_flutter plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onWebViewCreated == null) {
      return;
    }
    widget.onWebViewCreated(new WebViewController._(id));
  }
}

/// Controls a [WebView].
///
/// A [WebViewController] instance can be obtained by setting the [WebView.onWebViewCreated]
/// callback for a [WebView] widget.
class WebViewController {
  WebViewController._(int id)
      : _channel = new MethodChannel('plugins.flutter.io/webview_$id');

  final MethodChannel _channel;

  /// Loads the specified URL.
  ///
  /// `url` must not be null.
  ///
  /// Throws an ArgumentError if `url` is not a valid URL string.
  Future<void> loadUrl(String url) async {
    assert(url != null);
    _validateUrlString(url);
    return _channel.invokeMethod('loadUrl', url);
  }
}

// Throws an ArgumentError if url is not a valid url string.
void _validateUrlString(String url) {
  try {
    final Uri uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      throw new ArgumentError('Missing scheme in URL string: "$url"');
    }
  } on FormatException catch (e) {
    throw new ArgumentError(e);
  }
}
