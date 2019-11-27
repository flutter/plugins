// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart' show required, visibleForTesting;

import 'method_channel_url_launcher.dart';

/// Base class for platform interfaces.
///
/// Provides a static helper method for ensuring that platform interfaces are
/// implemented using `extends` instead of `implements`.
// TODO(amirh): Extract common platform interface logic.
// https://github.com/flutter/flutter/issues/43368
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
  /// Subclasses of [MockPlatformInterface] are assumed to be valid in debug
  /// builds.
  ///
  /// This is implemented as a static method so that it cannot be overridden
  /// with `noSuchMethod`.
  static void verifyToken(PlatformInterface instance, Object token) {
    if (identical(instance._instanceToken, MockPlatformInterface._token)) {
      bool assertionsEnabled = false;
      assert(() {
        assertionsEnabled = true;
        return true;
      }());
      if (!assertionsEnabled) {
        throw AssertionError(
            '`MockPlatformInterface` is not intended for use in release builds.');
      }
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
@visibleForTesting
abstract class MockPlatformInterface implements PlatformInterface {
  static const Object _token = const Object();

  @override
  Object get _instanceToken => _token;
}

/// The interface that implementations of url_launcher must implement.
///
/// Platform implementations should extend this class rather than implement it as `url_launcher`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [UrlLauncherPlatform] methods.
abstract class UrlLauncherPlatform extends PlatformInterface {
  UrlLauncherPlatform() : super(token: _token);

  static UrlLauncherPlatform _instance = MethodChannelUrlLauncher();

  static const Object _token = const Object();

  /// The default instance of [UrlLauncherPlatform] to use.
  ///
  /// Defaults to [MethodChannelUrlLauncher].
  static UrlLauncherPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UrlLauncherPlatform] when they register themselves.
  static set instance(UrlLauncherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns `true` if this platform is able to launch [url].
  Future<bool> canLaunch(String url) {
    throw UnimplementedError('canLaunch() has not been implemented.');
  }

  /// Returns `true` if the given [url] was successfully launched.
  ///
  /// For documentation on the other arguments, see the `launch` documentation
  /// in `package:url_launcher/url_launcher.dart`.
  Future<bool> launch(
    String url, {
    @required bool useSafariVC,
    @required bool useWebView,
    @required bool enableJavaScript,
    @required bool enableDomStorage,
    @required bool universalLinksOnly,
    @required Map<String, String> headers,
  }) {
    throw UnimplementedError('launch() has not been implemented.');
  }

  /// Closes the WebView, if one was opened earlier by [launch].
  Future<void> closeWebView() {
    throw UnimplementedError('closeWebView() has not been implemented.');
  }
}
