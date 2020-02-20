// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// An implementation of [PathProviderPlatform] that uses method channels.
class MethodChannelPathProvider extends PathProviderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel =
      MethodChannel('plugins.flutter.io/path_provider');
}
