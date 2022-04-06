// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/painting.dart' show Color;
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.pigeon.dart';
import '../web_kit/web_kit.dart';
import 'ui_kit.dart';

/// Host api implementation for [UIScrollView].
class UIScrollViewHostApiImpl extends UIScrollViewHostApi {
  /// Constructs a [UIScrollViewHostApiImpl].
  UIScrollViewHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

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
    Point<double> offset,
  ) async {
    return setContentOffset(
      instanceManager.getInstanceId(instance)!,
      offset.x,
      offset.y,
    );
  }
}

/// Host api implementation for [UIView].
class UIViewHostApiImpl extends UIViewHostApi {
  /// Constructs a [UIViewHostApiImpl].
  UIViewHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Converts objects to instances ids for [setBackgroundColor].
  Future<void> setBackgroundColorFromInstance(
    UIView instance,
    Color? color,
  ) async {
    return setBackgroundColor(
      instanceManager.getInstanceId(instance)!,
      color?.value,
    );
  }

  /// Converts objects to instances ids for [setOpaqueFromInstance].
  Future<void> setOpaqueFromInstance(
    UIView instance,
    bool opaque,
  ) async {
    return setOpaque(instanceManager.getInstanceId(instance)!, opaque);
  }
}
