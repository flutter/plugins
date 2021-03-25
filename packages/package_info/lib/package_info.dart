// Copyright 2013 The Flutter Authors. All rights reserved.
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
  /// Constructs an instance with the given values for testing. [PackageInfo]
  /// instances constructed this way won't actually reflect any real information
  /// from the platform, just whatever was passed in at construction time.
  ///
  /// See [fromPlatform] for the right API to get a [PackageInfo] that's
  /// actually populated with real data.
  PackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  static PackageInfo? _fromPlatform;

  /// Retrieves package information from the platform.
  /// The result is cached.
  static Future<PackageInfo> fromPlatform() async {
    PackageInfo? packageInfo = _fromPlatform;
    if (packageInfo != null) return packageInfo;

    final Map<String, dynamic> map =
        (await _kChannel.invokeMapMethod<String, dynamic>('getAll'))!;

    packageInfo = PackageInfo(
      appName: map["appName"] ?? '',
      packageName: map["packageName"] ?? '',
      version: map["version"] ?? '',
      buildNumber: map["buildNumber"] ?? '',
    );
    _fromPlatform = packageInfo;
    return packageInfo;
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
