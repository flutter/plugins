// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'messages.g.dart';

/// The Android implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for Android.
class SharedPreferencesAndroid extends SharedPreferencesStorePlatform {
  final SharedPreferencesApi _api = SharedPreferencesApi();

  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith() {
    SharedPreferencesStorePlatform.instance = SharedPreferencesAndroid();
  }

  @override
  Future<bool> remove(String key) async {
    return _api.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    return await _handleSetValue(valueType, key, value) ?? false;
  }

  @override
  Future<bool> clear() async {
    return _api.clear();
  }

  @override
  Future<Map<String, Object>> getAll() async {
    final Map<String?, Object?> data = await _api.getAll();
    final Map<String, Object> preferences = data.cast<String, Object>();
    if (preferences == null) {
      return <String, Object>{};
    }

    return preferences;
  }

  // Call the function according to the type of value provided
  Future<bool?> _handleSetValue(
      String dataType, String key, Object value) async {
    switch (dataType) {
      case 'String':
        return _api.setString(key, value as String);
      case 'Bool':
        return _api.setBool(key, value as bool);
      case 'Int':
        return _api.setInt(key, value as int);
      case 'Double':
        return _api.setDouble(key, value as double);
      case 'StringList':
        return _api.setStringList(key, value as List<String>);
    }

    throw PlatformException(
        code: 'InvalidOperation',
        message: '"$dataType" is not a supported type.');
  }
}
