// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

const MethodChannel _kChannel =
    const MethodChannel('plugins.flutter.io/shared_preferences');

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data. Data is persisted to disk automatically
/// and asynchronously. Use commit() to be notified when a save is successful.
class SharedPreferences {
  SharedPreferences._(this._preferenceCache);

  static const String _prefix = 'flutter.';
  static SharedPreferences _instance;
  static Future<SharedPreferences> getInstance() async {
    if (_instance == null) {
      final Map<String, Object> fromSystem =
          await _kChannel.invokeMethod('getAll');
      assert(fromSystem != null);
      // Strip the flutter. prefix from the returned preferences.
      final Map<String, Object> preferencesMap = <String, Object>{};
      for (String key in fromSystem.keys) {
        assert(key.startsWith(_prefix));
        preferencesMap[key.substring(_prefix.length)] = fromSystem[key];
      }
      _instance = new SharedPreferences._(preferencesMap);
    }
    return _instance;
  }

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.
  final Map<String, Object> _preferenceCache;

  /// Reads all values from cache
  Map<String, Object> getAll() => new Map.from(_preferenceCache);

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool
  bool getBool(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int
  int getInt(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double
  double getDouble(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String
  String getString(String key) => _preferenceCache[key];

  /// Reads a set of string values from persistent storage,
  /// throwing an exception if it's not a string set.
  List<String> getStringList(String key) => _preferenceCache[key];

  /// Saves a boolean [value] to persistent storage in the background.
  void setBool(String key, bool value) => _setValue('Bool', key, value);

  /// Saves an integer [value] to persistent storage in the background.
  void setInt(String key, int value) => _setValue('Int', key, value);

  /// Saves a double [value] to persistent storage in the background.
  /// Android doesn't support storing doubles, so it will be stored as a float.
  void setDouble(String key, double value) => _setValue('Double', key, value);

  /// Saves a string [value] to persistent storage in the background.
  void setString(String key, String value) => _setValue('String', key, value);

  /// Saves a list of strings [value] to persistent storage in the background.
  void setStringList(String key, List<String> value) =>
      _setValue('StringList', key, value);

  void _setValue(String valueType, String key, Object value) {
    _preferenceCache[key] = value;
    // Set the value in the background.
    _kChannel.invokeMethod('set$valueType', <String, dynamic>{
      'key': '$_prefix$key',
      'value': value,
    });
  }

  /// Completes with true once saved values have been persisted to local
  /// storage, or false if the save failed.
  ///
  /// It's usually sufficient to just wait for the set methods to complete which
  /// ensure the preferences have been modified in memory. Commit is necessary
  /// only if you need to be absolutely sure that the data is in persistent
  /// storage before taking some other action.
  Future<bool> commit() async => await _kChannel.invokeMethod('commit');

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() async {
    _preferenceCache.clear();
    return await _kChannel.invokeMethod('clear');
  }

  /// Initializes the shared preferences with mock values for testing.
  @visibleForTesting
  static void setMockInitialValues(Map<String, dynamic> values) {
    _kChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return values;
      }
      return null;
    });
  }
}
