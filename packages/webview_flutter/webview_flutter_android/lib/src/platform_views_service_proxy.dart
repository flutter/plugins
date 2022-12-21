// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Proxy that provides access to the platform views service.
///
/// This service allows creating and controlling platform-specific views.
@immutable
class PlatformViewsServiceProxy {
  /// Constructs a [PlatformViewsServiceProxy].
  const PlatformViewsServiceProxy({
    this.initExpensiveAndroidView =
        PlatformViewsService.initExpensiveAndroidView,
    this.initSurfaceAndroidView = PlatformViewsService.initSurfaceAndroidView,
  });

  /// Proxy method for [PlatformViewsService.initExpensiveAndroidView].
  final ExpensiveAndroidViewController Function({
    required int id,
    required String viewType,
    required TextDirection layoutDirection,
    dynamic creationParams,
    MessageCodec<dynamic>? creationParamsCodec,
    VoidCallback? onFocus,
  }) initExpensiveAndroidView;

  /// Proxy method for [PlatformViewsService.initSurfaceAndroidView].
  final SurfaceAndroidViewController Function({
    required int id,
    required String viewType,
    required TextDirection layoutDirection,
    dynamic creationParams,
    MessageCodec<dynamic>? creationParamsCodec,
    VoidCallback? onFocus,
  }) initSurfaceAndroidView;
}
