// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Object specifying creation parameters for creating a [PlatformNavigationCallbackDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [PlatformNavigationCallbackDelegateCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformNavigationCallbackDelegateCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// class AndroidNavigationCallbackDelegateCreationParams extends PlatformNavigationCallbackDelegateCreationParams {
///   AndroidNavigationCallbackDelegateCreationParams._(
///     // This parameter prevents breaking changes later.
///     // ignore: avoid_unused_constructor_parameters
///     PlatformNavigationCallbackDelegateCreationParams params, {
///     this.filter,
///   }) : super();
///
///   factory AndroidNavigationCallbackDelegateCreationParams.fromPlatformNavigationCallbackDelegateCreationParams(
///       PlatformNavigationCallbackDelegateCreationParams params, {
///       String? filter,
///   }) {
///     return AndroidNavigationCallbackDelegateCreationParams._(params, filter: filter);
///   }
///
///   final String? filter;
/// }
/// ```
/// {@end-tool}
@immutable
class PlatformNavigationCallbackDelegateCreationParams {
  /// Used by the platform implementation to create a new [PlatformNavigationCallbackDelegate].
  const PlatformNavigationCallbackDelegateCreationParams();
}
