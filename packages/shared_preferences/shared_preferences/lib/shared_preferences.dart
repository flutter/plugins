// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class SharedPreferences {
  SharedPreferences._(this._preferenceCache, {@required this.filename});

  static const String _prefix = 'flutter.';
  static final Map<String, Future<SharedPreferences>> _openedInstances =
      <String, Future<SharedPreferences>>{};

  static SharedPreferencesStorePlatform get _store =>
      SharedPreferencesStorePlatform.instance;

  /// Returns an instance of [SharedPreferences]
  /// with values corresponding to those stored under the file with the specified [filename].
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  ///
  /// WARNING: [filename] argument for now only works on Android.
  /// On iOs, the default name will always be used, even with different value in parameter.
  ///
  /// The values in [SharedPreferences] are cached.
  /// A new instance is actually created only the first time this method is called with the specified [filename].
  ///
  /// If a file with the specified [filename] doesn't already exist, it will automatically be created.
  /// The [filename] cannot be null ; otherwise an [ArgumentError] will be thrown.
  /// The default value of [filename] is the name of the file used in the previous version of this plugin.
  ///
  /// For Android, see https://developer.android.com/training/data-storage/shared-preferences.html for more details on the platform implementation.
  static Future<SharedPreferences> getInstance(
      {String filename = "FlutterSharedPreferences"}) async {
    ArgumentError.checkNotNull(filename);
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
    final String prefixedKey = '$_prefix$key';
    if (value == null) {
      _preferenceCache.remove(key);
      return _store.remove(prefixedKey); // TODO add the filename
    } else {
      if (value is List<String>) {
        // Make a copy of the list so that later mutations won't propagate
        _preferenceCache[key] = value.toList();
      } else {
        _preferenceCache[key] = value;
      }
      return _store.setValue(
          valueType, prefixedKey, value); // TODO add the filename
    }
  }

  /// Always returns true.
  /// On iOS, synchronize is marked deprecated. On Android, we commit every set.
  @deprecated
  Future<bool> commit() async => true;

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() {
    _preferenceCache.clear();
    return _store.clear(); // TODO add the filename
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

  static Future<Map<String, Object>> _getSharedPreferencesMap({
    @required String filename,
  }) async {
    final Map<String, Object> fromSystem =
        await _store.getAll(); // TODO add the filename
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
    SharedPreferencesStorePlatform.instance =
        InMemorySharedPreferencesStore.withData(newValues);
  }
}
