// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// The web implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for the web.
class SharedPreferencesPlugin extends SharedPreferencesStorePlatform {
  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith(Registrar registrar) {
    SharedPreferencesStorePlatform.instance = SharedPreferencesPlugin();
  }

  final Map<String, Object> _data = <String, Object>{};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return Map<String, Object>.from(_data);
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    _data[key] = value;
    return true;
  }
}
