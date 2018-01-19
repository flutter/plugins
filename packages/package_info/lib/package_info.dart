// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

const MethodChannel _kChannel =
    const MethodChannel('plugins.flutter.io/package_info');

/// [PackageInfo] wrap application Bundle (on iOS) and Package (on Android) information,
/// providing cached property for package name verion and build number.
///
/// [PackgeInfo] implemented in singleton idiom. After first called
/// [PackageInfo.getInstance], cached properties never changed.
///
/// ```dart
///     PackageInfo packageInfo = await PackageInfo.getInstance()
///     print("Version is: ${packageInfo.version}");
/// ```
/// Or in async mode:
///
/// ```dart
///   PackageInfo.getInstance().then((PackageInfo packageInfo) {
///     String packageName = packageInfo.packageName;
///     String version = packageInfo.version;
///     String buildNumber = packageInfo.buildNumber;
///   });
/// ```
/// All properties are type of [String].
class PackageInfo {
  PackageInfo._({
    @required this.packageName,
    @required this.version,
    @required this.buildNumber,
  })
      : assert(packageName != null),
        assert(version != null),
        assert(buildNumber != null);

  static Future<PackageInfo> _instance;

  /// Singleton instance.
  static Future<PackageInfo> getInstance() async {
    if (_instance == null) {
      final Completer<PackageInfo> completer = new Completer<PackageInfo>();

      _kChannel.invokeMethod('getAll').then((dynamic result) {
        final Map<String, String> fromSystem = result;

        completer.complete(new PackageInfo._(
          packageName: fromSystem["packageName"],
          version: fromSystem["version"],
          buildNumber: fromSystem["buildNumber"],
        ));
      }, onError: completer.completeError);

      _instance = completer.future;
    }
    return _instance;
  }

  /// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
  final String packageName;

  /// The package version. `CFBundleShortVersionString` on iOS, `versionName` on Android.
  final String version;

  /// The build number. `CFBundleVersion` on iOS, `versionCode` on Android.
  final String buildNumber;
}
