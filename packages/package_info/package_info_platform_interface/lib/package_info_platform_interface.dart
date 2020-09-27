// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/package_info_method_channel.dart';

/// The interface that implementations of package_info must implement.
///
/// Platform implementations should extend this class rather than implement it as `PackageInfo`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [PackageInfoPlatform] methods.
abstract class PackageInfoPlatform extends PlatformInterface {
  const String appName = "appName";
  const String packageName = "packageName";
  const String version = "version";
  const String buildNumber = "buildNumber";

  /// Constructs a PackageInfoPlatform.
  PackageInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static PackageInfoPlatform _instance = PackageInfoMethodChannel();

  /// The default instance of [PackageInfoPlatform] to use.
  ///
  /// Defaults to [PackageInfoMethodChannel].
  static PackageInfoPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PackageInfoPlatform] when they register themselves.
  static set instance(PackageInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, String>> getAll() {
    throw UnimplementedError('getAll has not been implemented.');
  }
}