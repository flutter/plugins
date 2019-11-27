// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart' show required, visibleForTesting;

import 'method_channel_url_launcher.dart';

/// Base class for platform interfaces.
///
/// Provides helper methods for ensuring that platform interfaces are
/// implemented using `extends` instead of `implements`.
class PlatformInterface {
  PlatformInterface({ Object token }) : _token = token;

  // Pass a `const Object()` here to distinguish
  final Object _token;

  // Mock implementations can return true here using `noSuchMethod`.
  //
  // Mockito mocks are implementing this class with `implements` which is forbidden for anything
  // other than mocks (see class docs). This property provides `MockPlatformInterface`
  // a backdoor for mockito mocks to skip the verification that the class isn't
  // implemented with `implements`.
  bool get _isMock => false;

  /// Return true if the platform instance has a token that matches the
  /// provided token. This is used to ensure that implementers are using
  /// `extends` rather than `implements`.
  static bool isValid(PlatformInterface instance, Object token) {
    return _isMock || identical(token, instance._token);
  }
}

/// A [PlatformInterface] that can be mocked with mockito.
///
/// Throws an `AssertionError` when used in release builds.
@visibleForTesting
class MockPlatformInterface extends PlatformInterface {
  @override
  bool get _isMock {
    bool assertionsEnabled = false;
    assert(() {
      assertionsEnabled = true;
      return true;
    }());
    if (!assertionsEnabled) {
      throw AssertionError(
          '`MockPlatformInterface` is not intended for use in release builds.');
    }
    return true;
  }
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
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(UrlLauncherPlatform instance) {
    assert(PlatformInterface.isValid(instance, _token));
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
