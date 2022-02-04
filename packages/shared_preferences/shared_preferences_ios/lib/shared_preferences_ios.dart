// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'messages.g.dart';

typedef _Setter = Future<bool> Function(String key, Object value);

/// iOS implementation of shared_preferences.
class SharedPreferencesIos extends SharedPreferencesStorePlatform {
  final SharedPreferencesApi _api = SharedPreferencesApi();
  late final Map<String, _Setter> _setters = <String, _Setter>{
    'Bool': (String key, Object value) {
      return _api.setBool(key, value as bool);
    },
    'Double': (String key, Object value) {
      return _api.setDouble(key, value as double);
    },
    'Int': (String key, Object value) {
      return _api.setInt(key, value as int);
    },
    'String': (String key, Object value) {
      return _api.setString(key, value as String);
    },
    'StringList': (String key, Object value) {
      return _api.setStringList(key, value as List<String?>);
    },
  };

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    SharedPreferencesStorePlatform.instance = SharedPreferencesIos();
  }

  @override
  Future<bool> clear() {
    return _api.clear();
  }

  @override
  Future<Map<String, Object>> getAll() async {
    final Map<String?, Object?> result = await _api.getAll();
    return result.cast<String, Object>();
  }

  @override
  Future<bool> remove(String key) {
    return _api.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final _Setter? setter = _setters[valueType];
    if (setter != null) {
      return setter(key, value);
    } else {
      return false;
    }
  }
}
