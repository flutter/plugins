// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'method_channel_shared_preferences.dart';
import 'shared_preferences_platform_interface.dart';

/// Wraps platform-specific user preferences APIs, providing a persistent store
/// for simple data.
///
/// Data is persisted to disk asynchronously.
class SharedPreferences {
  SharedPreferences._(this._preferenceCache);

  static const String _prefix = 'flutter.';
  static Map<String, dynamic> _mockInitialValues;
  static Completer<SharedPreferences> _completer;
  static Future<SharedPreferences> getInstance() async {
    if (_completer == null) {
      _completer = Completer<SharedPreferences>();
      try {
        final Map<String, Object> preferencesMap =
            await _getSharedPreferencesMap();
        _completer.complete(SharedPreferences._(preferencesMap));
      } on Exception catch (e) {
        // If there's an error, explicitly return the future with an error.
        // then set the completer to null so we can retry.
        _completer.completeError(e);
        final Future<SharedPreferences> sharedPrefsFuture = _completer.future;
        _completer = null;
        return sharedPrefsFuture;
      }
    }
    return _completer.future;
  }

  static SharedPreferencesPlatform _platform;

  /// Sets a custom [SharedPreferencesPlatform].
  ///
  /// This property can be set to use a custom platform implementation.
  static set platform(SharedPreferencesPlatform platform) {
    assert(_platform == null);
    _platform = platform;
  }

  /// The SharedPreferences platform that's used by the plugin.
  ///
  /// The default value is [MethodChannelSharedPreferences] on Android or iOS.
  static SharedPreferencesPlatform get platform {
    if (_platform == null) {
          _platform = MethodChannelSharedPreferences();
    }
    return _platform;
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

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() => Set<String>.from(_preferenceCache.keys);

  /// Reads a value of any type from persistent storage.
  dynamic get(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool getBool(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int getInt(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double.
  double getDouble(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String getString(String key) => _preferenceCache[key];

  /// Returns true if persistent storage the contains the given [key].
  bool containsKey(String key) => _preferenceCache.containsKey(key);

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string set.
  List<String> getStringList(String key) {
    List<Object> list = _preferenceCache[key];
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
      _preferenceCache[key] = list;
    }
    // Make a copy of the list so that later mutations won't propagate
    return list?.toList();
  }

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setBool(String key, bool value) =>
      _setValue(key, value, () => platform.setBool('$_prefix$key', value));

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) =>
      _setValue(key, value, () => platform.setInt('$_prefix$key', value));

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) =>
      _setValue(key, value, () => platform.setDouble('$_prefix$key', value));

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) =>
      _setValue(key, value, () => platform.setString('$_prefix$key', value));

  /// Saves a list of strings [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setStringList(String key, List<String> value) => _setValue(
      key, value, () => platform.setStringList('$_prefix$key', value));

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => _setValue(key, null, null);

  Future<bool> _setValue(
    String key,
    Object value,
    Future<bool> Function() platformSet,
  ) {
    if (value == null) {
      _preferenceCache.remove(key);
      return platform.remove('$_prefix$key');
    }

    if (value is List<String>) {
      // Make a copy of the list so that later mutations won't propagate
      _preferenceCache[key] = value.toList();
    } else {
      _preferenceCache[key] = value;
    }

    return platformSet();
  }

  /// Always returns true.
  /// On iOS, synchronize is marked deprecated. On Android, we commit every set.
  @deprecated
  Future<bool> commit() => Future<bool>.value(true);

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() {
    _preferenceCache.clear();
    return platform.clear();
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    final Map<String, Object> preferences =
        await SharedPreferences._getSharedPreferencesMap();
    _preferenceCache.clear();
    _preferenceCache.addAll(preferences);
  }

  static Future<Map<String, Object>> _getSharedPreferencesMap() async {
    final Map<String, Object> fromSystem = _mockInitialValues == null
        ? await platform.getAll()
        : _mockInitialValues;
    assert(fromSystem != null);

    // Strip the flutter. prefix from the returned preferences.
    final Map<String, Object> preferencesMap = <String, Object>{};
    for (String key in fromSystem.keys) {
      assert(key.startsWith(_prefix));
      preferencesMap[key.substring(_prefix.length)] = fromSystem[key];
    }
    return preferencesMap;
  }

  /// Initializes the shared preferences with mock values for testing.
  ///
  /// If the singleton instance has been initialized already, it is nullified.
  @visibleForTesting
  static void setMockInitialValues(Map<String, dynamic> values) {
    _mockInitialValues =
        values == null ? null : Map<String, dynamic>.from(values);
    _completer = null;
  }
}
