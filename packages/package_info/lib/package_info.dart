// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

/// Provides information about the current application package.
const MethodChannel _kChannel = const MethodChannel('plugins.flutter.io/package_info');

class PackageInfo {
  PackageInfo._(this._infoCache);

  static PackageInfo _instance;

  static Future<PackageInfo> getInstance() async {
    if (_instance == null) {
      final Map<String, Object> fromSystem = await _kChannel.invokeMethod('getAll');
      assert(fromSystem != null);
      _instance = new PackageInfo._(fromSystem);
    }
    return _instance;
  }

  String get version => _infoCache["version"];

  String get buildNumber => _infoCache["buildNumber"];
  
  String get packageName => _infoCache["packageName"];

  final Map<String, String> _infoCache;
}

/// Returns the `CFBundleShortVersionString` on iOS or `versionName` on Android
Future<String> get version async => await _kChannel.invokeMethod('getVersion');

/// Returns the `CFBundleVersion` on iOS or `versionCode` on Android
Future<String> get buildNumber async => await _kChannel.invokeMethod('getBuildNumber');

/// Returns the `bundleIdentifier` on iOS or `getPackageName` on Android
Future<String> get packageName async => await _kChannel.invokeMethod('getPackageName');
