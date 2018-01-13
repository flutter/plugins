// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

/// Provides information about the current application package.
const MethodChannel _kChannel =
    const MethodChannel('plugins.flutter.io/package_info');

/// Returns the `CFBundleShortVersionString` on iOS or `versionName` on Android
Future<String> get version async => await _kChannel.invokeMethod('getVersion');

/// Returns the `CFBundleVersion` on iOS or `versionCode` on Android
Future<String> get buildNumber async =>
    await _kChannel.invokeMethod('getBuildNumber');

/// Returns the `bundleIdentifier` on iOS or `getPackageName` on Android
Future<String> get packageName async =>
    await _kChannel.invokeMethod('getPackageName');
