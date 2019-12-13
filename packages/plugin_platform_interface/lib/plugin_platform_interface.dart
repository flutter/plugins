// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library plugin_platform_interface;

import 'package:meta/meta.dart';

/// Base class for platform interfaces.
///
/// Provides a static helper method for ensuring that platform interfaces are
/// implemented using `extends` instead of `implements`.
///
/// Platform interface classes are expected to have a private static token object which will be
/// be passed to [verifyToken] along with a platform interface object for verification.
///
/// Sample usage:
///
/// ```dart
/// abstract class UrlLauncherPlatform extends PlatformInterface {
///   UrlLauncherPlatform() : super(token: _token);
///
///   static UrlLauncherPlatform _instance = MethodChannelUrlLauncher();
///
///   static const Object _token = Object();
///
///   static UrlLauncherPlatform get instance => _instance;
///
///   /// Platform-specific plugins should set this with their own platform-specific
///   /// class that extends [UrlLauncherPlatform] when they register themselves.
///   static set instance(UrlLauncherPlatform instance) {
///     PlatformInterface.verifyToken(instance, _token);
///     _instance = instance;
///   }
///
///  }
/// ```
///
/// Mockito mocks of platform interfaces will fail the verification, in test code only it is possible
/// to include the [MockPlatformInterfaceMixin] for the verification to be temporarily disabled. See
/// [MockPlatformInterfaceMixin] for a sample of using Mockito to mock a platform interface.
abstract class PlatformInterface {
  /// Pass a private, class-specific `const Object()` as the `token`.
  PlatformInterface({@required Object token}) : _instanceToken = token;

  final Object _instanceToken;

  /// Ensures that the platform instance has a token that matches the
  /// provided token and throws [AssertionError] if not.
  ///
  /// This is used to ensure that implementers are using `extends` rather than
  /// `implements`.
  ///
  /// Subclasses of [MockPlatformInterfaceMixin] are assumed to be valid in debug
  /// builds.
  ///
  /// This is implemented as a static method so that it cannot be overridden
  /// with `noSuchMethod`.
  static void verifyToken(PlatformInterface instance, Object token) {
    if (instance is MockPlatformInterfaceMixin) {
      bool assertionsEnabled = false;
      assert(() {
        assertionsEnabled = true;
        return true;
      }());
      if (!assertionsEnabled) {
        throw AssertionError(
            '`MockPlatformInterfaceMixin` is not intended for use in release builds.');
      }
      return;
    }
    if (!identical(token, instance._instanceToken)) {
      throw AssertionError(
          'Platform interfaces must not be implemented with `implements`');
    }
  }
}

/// A [PlatformInterface] mixin that can be combined with mockito's `Mock`.
///
/// It passes the [PlatformInterface.verifyToken] check even though it isn't
/// using `extends`.
///
/// This class is intended for use in tests only.
///
/// Sample usage (assuming UrlLauncherPlatform extends [PlatformInterface]:
///
/// ```dart
/// class UrlLauncherPlatformMock extends Mock
///    with MockPlatformInterfaceMixin
///    implements UrlLauncherPlatform {}
/// ```
@visibleForTesting
abstract class MockPlatformInterfaceMixin implements PlatformInterface {}
