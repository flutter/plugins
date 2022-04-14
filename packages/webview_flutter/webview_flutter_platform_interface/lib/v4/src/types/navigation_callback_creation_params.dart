// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Object specifying creation parameters for creating a [NavigationCallbackDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [NavigationCallbackCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [NavigationCallbackCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// class AndroidNavigationCallbackCreationParams extends NavigationCallbackCreationParams {
///   AndroidNavigationCallbackCreationParams._(
///     // ignore: avoid_unused_constructor_parameters
///     NavigationCallbackCreationParams params, {
///     this.filter,
///   }) : super();
///
///   factory AndroidNavigationCallbackCreationParams.fromNavigationCallbackCreationParams(
///       NavigationCallbackCreationParams params, {
///       String? filter,
///   }) {
///     return AndroidNavigationCallbackCreationParams._(params, filter: filter);
///   }
///
///   final String? filter;
/// }
/// ```
/// {@end-tool}
class NavigationCallbackCreationParams {
  /// Used by the platform implementation to create a new [NavigationCallbackDelegate].
  NavigationCallbackCreationParams();
}
