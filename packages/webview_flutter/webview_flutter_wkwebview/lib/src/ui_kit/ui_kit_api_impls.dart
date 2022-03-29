// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.pigeon.dart';
import 'ui_kit.dart';

/// Host api implementation for [UIScrollView].
class UIScrollViewHostApiImpl extends UIScrollViewHostApi {
  /// Constructs a [UIScrollViewHostApiImpl].
  UIScrollViewHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  late final InstanceManager instanceManager;

  /// Converts objects to instances ids for [createFromWebViewFromInstance].
  Future<void> createFromWebViewFromInstance(
    UIScrollView instance,
    WKWebView webView,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createFromWebView(
        instanceId,
        instanceManager.getInstanceId(webView)!,
      );
    }
  }

  /// Converts objects to instances ids for [getContentOffset].
  Future<Point<double>> getContentOffsetFromInstance(
    UIScrollView instance,
  ) async {
    final List<double?> point = await getContentOffset(
      instanceManager.getInstanceId(instance)!,
    );
    return Point<double>(point[0]!, point[1]!);
  }

  /// Converts objects to instances ids for [scrollByFromInstance].
  Future<void> scrollByFromInstance(
    UIScrollView instance,
    Point<double> offset,
  ) {
    return scrollBy(
      instanceManager.getInstanceId(instance)!,
      offset.x,
      offset.y,
    );
  }

  /// Converts objects to instances ids for [setContentOffset].
  Future<void> setContentOffsetFromInstance(
    UIScrollView instance,
    FutureOr<Point<double>> offset,
  ) async {
    final Point<double> offsetValue = await offset;
    return setContentOffset(
      instanceManager.getInstanceId(instance)!,
      offsetValue.x,
      offsetValue.y,
    );
  }
}
