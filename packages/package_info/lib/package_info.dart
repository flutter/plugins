// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

const MethodChannel _kChannel =
    const MethodChannel('plugins.flutter.io/package_info');

/// Wrap application Bundle (on iOS) and Package (on Android) information,
/// providing cached verion, build number and package name.
///
/// PackgeInfo implemented in singleton, after first called
/// [PackageInfo.getInstance], cached value never changed.
///
/// ```dart
///     PackageInfo paakcageInfo = await PackageInfo.getInstance()
///     print("Version is: ${packcageInfo.version}");
/// ```
///
class PackageInfo {
  PackageInfo._(
      {@required this.version,
      @required this.buildNumber,
      @required this.packageName})
      : assert(version != null),
        assert(buildNumber != null),
        assert(packageName != null);

  static PackageInfo _instance;

  static Future<PackageInfo> getInstance() async {
    if (_instance == null) {
      final Map<String, String> fromSystem =
          await _kChannel.invokeMethod('getAll');
      print("fromSystem $fromSystem");
      assert(fromSystem != null);
      assert(fromSystem["version"] != null);
      assert(fromSystem["buildNumber"] != null);
      assert(fromSystem["packageName"] != null);

      _instance = new PackageInfo._(
        version: fromSystem["version"],
        buildNumber: fromSystem["buildNumber"],
        packageName: fromSystem["packageName"],
      );
    }
    return _instance;
  }

  /// property of the `CFBundleShortVersionString` on iOS or `versionName` on Android
  final String version;

  /// property of the `CFBundleVersion` on iOS or `versionCode` on Android
  final String buildNumber;

  /// property of the `bundleIdentifier` on iOS or `getPackageName` on Android
  final String packageName;
}
