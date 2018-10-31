// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/package_info');

/// Application metadata. Provides application bundle information on iOS and
/// application package information on Android.
///
/// ```dart
/// PackageInfo packageInfo = await PackageInfo.fromPlatform()
/// print("Version is: ${packageInfo.version}");
/// ```
class PackageInfo {
  PackageInfo({
    this.appName,
    this.packageName,
    this.version,
    this.buildNumber,
  });

  static Future<PackageInfo> _fromPlatform;

  /// Retrieves package information from the platform.
  /// The result is cached.
  static Future<PackageInfo> fromPlatform() async {
    if (_fromPlatform == null) {
      final Completer<PackageInfo> completer = Completer<PackageInfo>();

      _kChannel.invokeMethod('getAll').then((dynamic result) {
        final Map<dynamic, dynamic> map = result;

        completer.complete(PackageInfo(
          appName: map["appName"],
          packageName: map["packageName"],
          version: map["version"],
          buildNumber: map["buildNumber"],
        ));
      }, onError: completer.completeError);

      _fromPlatform = completer.future;
    }
    return _fromPlatform;
  }

  /// The app name. `CFBundleDisplayName` on iOS, `application/label` on Android.
  final String appName;

  /// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
  final String packageName;

  /// The package version. `CFBundleShortVersionString` on iOS, `versionName` on Android.
  final String version;

  /// The build number. `CFBundleVersion` on iOS, `versionCode` on Android.
  final String buildNumber;
}
