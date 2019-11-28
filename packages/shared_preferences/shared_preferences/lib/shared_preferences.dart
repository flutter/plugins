// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/shared_preferences');

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class SharedPreferences {
  SharedPreferences._(this._preferenceCache, {@required this.filename});

  /// Default file under which preferences are stored.
  static const String defaultFilename = 'FlutterSharedPreferences';
  static const String _prefix = 'flutter.';
  static final Map<String, Future<SharedPreferences>> _openedInstances =
      <String, Future<SharedPreferences>>{};

  /// Returns an instance of [SharedPreferences] with the default file.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  ///
  /// The values in [SharedPreferences] are cached.
  /// A new instance is actually created only the first time this method is called with the specified [filename].
  static Future<SharedPreferences> getInstance() async => getInstanceForFile();

  /// Returns an instance of [SharedPreferences]
  /// with values corresponding to those stored under the file with the specified [filename].
  ///
  /// If a file with the specified [filename] doesn't already exist, it will automatically be created.
  /// The [filename] cannot be null.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  ///
  /// **WARNING**: this method for now only works on Android.
  /// On iOS, use the [getInstance] method, otherwise an [AssertionError] will be thrown.
  ///
  /// The values in [SharedPreferences] are cached.
  /// A new instance is actually created only the first time this method is called with the specified [filename].
  ///
  /// See https://developer.android.com/training/data-storage/shared-preferences.html for more details on the platform implementation.
  static Future<SharedPreferences> getInstanceForFile(
      {String filename = defaultFilename}) async {
    ArgumentError.checkNotNull(filename);
    assert(filename == defaultFilename || Platform.isAndroid);
    try {
      return await _openedInstances.putIfAbsent(filename, () async {
        final Map<String, Object> preferencesMap =
            await _getSharedPreferencesMap(filename: filename);
        return SharedPreferences._(preferencesMap, filename: filename);
      });
    } on Exception {
      _openedInstances.remove(filename);
      rethrow;
    }
  }

  /// Name of the file under which preferences are stored.
  final String filename;

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
  Future<bool> setBool(String key, bool value) => _setValue('Bool', key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) => _setValue('Int', key, value);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) =>
      _setValue('Double', key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) =>
      _setValue('String', key, value);

  /// Saves a list of strings [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setStringList(String key, List<String> value) =>
      _setValue('StringList', key, value);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => _setValue(null, key, null);

  Future<bool> _setValue(String valueType, String key, Object value) {
    final Map<String, dynamic> params = <String, dynamic>{
      'key': '$_prefix$key',
      'filename': filename
    };
    if (value == null) {
      _preferenceCache.remove(key);
      return _kChannel
          .invokeMethod<bool>('remove', params)
          .then<bool>((dynamic result) => result);
    } else {
      if (value is List<String>) {
        // Make a copy of the list so that later mutations won't propagate
        _preferenceCache[key] = value.toList();
      } else {
        _preferenceCache[key] = value;
      }
      params['value'] = value;
      return _kChannel
          .invokeMethod<bool>('set$valueType', params)
          .then<bool>((dynamic result) => result);
    }
  }

  /// Always returns true.
  /// On iOS, synchronize is marked deprecated. On Android, we commit every set.
  @deprecated
  Future<bool> commit() async => await _kChannel
      .invokeMethod<bool>('commit', <String, dynamic>{'filename': filename});

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() async {
    _preferenceCache.clear();
    return await _kChannel
        .invokeMethod<bool>('clear', <String, dynamic>{'filename': filename});
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    final Map<String, Object> preferences =
        await SharedPreferences._getSharedPreferencesMap(filename: filename);
    _preferenceCache.clear();
    _preferenceCache.addAll(preferences);
  }

  static Future<Map<String, Object>> _getSharedPreferencesMap(
      {@required String filename}) async {
    final Map<String, dynamic> args = <String, dynamic>{'filename': filename};
    final Map<String, Object> fromSystem =
        await _kChannel.invokeMapMethod<String, Object>('getAll', args);
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
  @visibleForTesting
  void setMockInitialValues(Map<String, dynamic> values) {
    final Map<String, dynamic> newValues =
        values.map<String, dynamic>((String key, dynamic value) {
      String newKey = key;
      if (!key.startsWith(_prefix)) {
        newKey = '$_prefix$key';
      }
      return MapEntry<String, dynamic>(newKey, value);
    });
    _kChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return newValues;
      }
      return null;
    });
  }
}
