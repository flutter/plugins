// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'types/types.dart';
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

  /// Invoked by [WebViewPlatformControllerDelegate] when a navigation request
  /// is pending.
  ///
  /// If true is returned the navigation is allowed, otherwise it is blocked.
  FutureOr<bool> onNavigationRequest(
      {required String url, required bool isForMainFrame});

  /// Invoked by [WebViewPlatformControllerDelegate] when a page has started
  /// loading.
  void onPageStarted(String url);

  /// Invoked by [WebViewPlatformControllerDelegate] when a page has finished
  /// loading.
  void onPageFinished(String url);

  /// Invoked by [WebViewPlatformControllerDelegate] when a page is loading.
  ///
  /// Only works when [WebSettings.hasProgressTracking] is set to `true`.
  void onProgress(int progress);

  /// Report web resource loading error to the host application.
  void onWebResourceError(WebResourceError error);
}
