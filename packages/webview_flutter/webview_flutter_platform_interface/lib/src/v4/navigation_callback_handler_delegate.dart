// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'webview_platform.dart';

/// Interface for callbacks made by [NavigationCallbackHandlerDelegate].
///
/// The webview plugin implements this class, and passes an instance to the
/// [NavigationCallbackHandlerDelegate].
/// [NavigationCallbackHandlerDelegate] is notifying this handler on events that
/// happened on the platform's webview.
abstract class NavigationCallbackHandlerDelegate extends PlatformInterface {
  /// Creates a new [NavigationCallbacksHandlerDelegate]
  factory NavigationCallbackHandlerDelegate() {
    final NavigationCallbackHandlerDelegate callbackHandlerDelegate =
        WebViewPlatform.instance!.createNavigationCallbackHandlerDelegate();
    PlatformInterface.verify(callbackHandlerDelegate, _token);
    return callbackHandlerDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [NavigationCallbackHandlerDelegate].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  NavigationCallbackHandlerDelegate.implementation() : super(token: _token);

  static final Object _token = Object();

  /// Sets the callback method that is invoked by the
  /// [WebViewPlatformControllerDelegate] when a navigation request is pending.
  Future<void> setOnNavigationRequest(
    void Function({required String url, required bool isForMainFrame})
        onNavigationRequest,
  ) {
    throw UnimplementedError(
        'setOnNavigationRequest is not implemented on the current platform.');
  }

  /// Sets the callback method that is invoked by [WebViewControllerDelegate]
  /// when a page has started loading.
  Future<void> setOnPageStarted(
    void Function(String url) onPageStarted,
  ) {
    throw UnimplementedError(
        'setOnPageStarted is not implemented on the current platform.');
  }

  /// Sets the callback method that is invoked by [WebViewControllerDelegate]
  /// when a page has finished loading.
  Future<void> setOnPageFinished(
    void Function(String url) onPageFinished,
  ) {
    throw UnimplementedError(
        'setOnPageFinished is not implemented on the current platform.');
  }

  /// Sets the callback method that is invoked by [WebViewControllerDelegate]
  /// when a page is loading.
  ///
  /// Only works when [WebSettings.hasProgressTracking] is set to `true`.
  Future<void> setOnProgress(
    void Function(int progress) onProgress,
  ) {
    throw UnimplementedError(
        'setOnProgress is not implemented on the current platform.');
  }

  /// Sets the callback that is invoked when a resource loading error occurred..
  Future<void> setOnWebResourceError(
    void Function(WebResourceErrorDelegate error) onWebResourceError,
  ) {
    throw UnimplementedError(
        'setOnWebResourceError is not implemented on the current platform.');
  }
}
