// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/painting.dart' show Color;
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../foundation/foundation.dart';
import '../web_kit/web_kit.dart';
import 'ui_kit_api_impls.dart';

/// A view that allows the scrolling and zooming of its contained views.
///
/// Wraps [UIScrollView](https://developer.apple.com/documentation/uikit/uiscrollview?language=objc).
class UIScrollView extends UIView {
  /// Constructs a [UIScrollView] that is owned by [webView].
  UIScrollView.fromWebView(
    WKWebView webView, {
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _scrollViewApi = UIScrollViewHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _scrollViewApi.createFromWebViewForInstances(this, webView);
  }

  final UIScrollViewHostApiImpl _scrollViewApi;

  /// Point at which the origin of the content view is offset from the origin of the scroll view.
  ///
  /// Represents [WKWebView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset?language=objc).
  Future<Point<double>> getContentOffset() {
    return _scrollViewApi.getContentOffsetForInstances(this);
  }

  /// Move the scrolled position of this view.
  ///
  /// This method is not a part of UIKit and is only a helper method to make
  /// scrollBy atomic.
  Future<void> scrollBy(Point<double> offset) {
    return _scrollViewApi.scrollByForInstances(this, offset);
  }

  /// Set point at which the origin of the content view is offset from the origin of the scroll view.
  ///
  /// The default value is `Point<double>(0.0, 0.0)`.
  ///
  /// Sets [WKWebView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset?language=objc).
  Future<void> setContentOffset(Point<double> offset) {
    return _scrollViewApi.setContentOffsetForInstances(this, offset);
  }
}

/// Manages the content for a rectangular area on the screen.
///
/// Wraps [UIView](https://developer.apple.com/documentation/uikit/uiview?language=objc).
class UIView extends NSObject {
  /// Constructs an [NSObject].
  UIView({BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : _viewApi = UIViewHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  final UIViewHostApiImpl _viewApi;

  /// The view’s background color.
  ///
  /// The default value is null, which results in a transparent background color.
  ///
  /// Sets [UIView.backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor?language=objc).
  Future<void> setBackgroundColor(Color? color) {
    return _viewApi.setBackgroundColorForInstances(this, color);
  }

  /// Determines whether the view is opaque.
  ///
  /// Sets [UIView.opaque](https://developer.apple.com/documentation/uikit/uiview?language=objc).
  Future<void> setOpaque(bool opaque) {
    return _viewApi.setOpaqueForInstances(this, opaque);
  }
}
