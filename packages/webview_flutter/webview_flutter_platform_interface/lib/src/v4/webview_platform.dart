// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/v4/types/types.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_widget_delegate.dart';

import 'navigation_callback_handler_delegate.dart';
import 'webview_controller_delegate.dart';
import 'webview_cookie_manager_delegate.dart';

export 'types/types.dart';

/// Interface for a platform implementation of a WebView.
abstract class WebViewPlatform extends PlatformInterface {
  /// Creates a new [WebViewPlatform].
  WebViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebViewPlatform? _instance;

  /// The instance of [WebViewPlatform] to use.
  static WebViewPlatform? get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [WebViewPlatform] when they register themselves.
  static set instance(WebViewPlatform? instance) {
    if (instance == null) {
      throw AssertionError(
          'Platform interfaces can only be set to a non-null instance');
    }

    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Creates a new [WebViewCookieManagerDelegate].
  WebViewCookieManagerDelegate createCookieManagerDelegate() {
    throw UnimplementedError(
        'createCookieManagerDelegate is not implemented on the current platform.');
  }

  /// Creates a new [NavigationCallbackHandlerDelegate].
  NavigationCallbackHandlerDelegate createNavigationCallbackHandlerDelegate() {
    throw UnimplementedError(
        'createNavigationCallbackHandlerDelegate is not implemented on the current platform.');
  }

  /// Create a new [JavaScriptMessage].
  JavaScriptMessage createJavaScriptMessage(String message) {
    throw UnimplementedError(
        'createJavaScriptMessage is not implemented on the current platform.');
  }

  /// Create a new [WebSettingsDelegate].
  WebSettingsDelegate createWebSettingsDelegate({
    bool? allowsInlineMediaPlayback,
    bool? debuggingEnabled,
    bool? gestureNavigationEnabled,
    bool? hasNavigationDelegate,
    bool? hasProgressTracking,
    JavaScriptMode? javaScriptMode,
    required WebSetting<String> userAgent,
    bool? zoomEnabled,
  }) {
    throw UnimplementedError(
        'createWebSettingsDelegate is not implemented on the current platform.');
  }

  /// Create a new [WebViewControllerDelegate].
  WebViewControllerDelegate createWebViewControllerDelegate(
      WebViewControllerCreationParams params) {
    throw UnimplementedError(
        'createWebViewControllerDelegate is not implemented on the current platform.');
  }

  /// Create a new [WebViewWidgetDelegate].
  WebViewWidgetDelegate createWebViewWidgetDelegate({
    Key? key,
    required WebViewControllerDelegate controller,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    throw UnimplementedError(
        'createWebViewWidgetDelegate is not implemented on the current platform.');
  }
}
