// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// The Windows implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for Windows.
class SharedPreferencesWindows extends SharedPreferencesStorePlatform {
  /// The default instance of [SharedPreferencesWindows] to use.
  static SharedPreferencesWindows instance = SharedPreferencesWindows();

  /// File system used to store to disk. Exposed for testing only.
  @visibleForTesting
  FileSystem? fs = LocalFileSystem();

  /// The path_provider_windows instance used to find the support directory.
  @visibleForTesting
  PathProviderWindows? pathProvider = PathProviderWindows();

  /// Local copy of preferences
  Map<String, Object>? _cachedPreferences;

  /// Cached file for storing preferences.
  File? _localDataFilePath;

  /// Gets the file where the preferences are stored.
  Future<File> _getLocalDataFile() async {
    if (_localDataFilePath == null) {
      final directory = await pathProvider!.getApplicationSupportPath();
      _localDataFilePath =
          fs!.file(path.join(directory!, 'shared_preferences.json'));
    }
    return _localDataFilePath!;
  }

  /// Gets the preferences from the stored file. Once read, the preferences are
  /// maintained in memory.
  Future<Map<String, Object>> _readPreferences() async {
    if (_cachedPreferences == null) {
      _cachedPreferences = {};
      File localDataFile = await _getLocalDataFile();
      if (localDataFile.existsSync()) {
        String stringMap = localDataFile.readAsStringSync();
        if (stringMap.isNotEmpty) {
          _cachedPreferences =
              (json.decode(stringMap) as Map).cast<String, Object>();
        }
      }
    }
    return _cachedPreferences!;
  }

  /// Writes the cached preferences to disk. Returns [true] if the operation
  /// succeeded.
  Future<bool> _writePreferences(Map<String, Object> preferences) async {
    try {
      File localDataFile = await _getLocalDataFile();
      if (!localDataFile.existsSync()) {
        localDataFile.createSync(recursive: true);
      }
      String stringMap = json.encode(preferences);
      localDataFile.writeAsStringSync(stringMap);
    } catch (e) {
      print("Error saving preferences to disk: $e");
      return false;
    }
    return true;
  }

  @override
  Future<bool> clear() async {
    var preferences = await _readPreferences();
    preferences.clear();
    return _writePreferences(preferences);
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return _readPreferences();
  }

  @override
  Future<bool> remove(String key) async {
    var preferences = await _readPreferences();
    preferences.remove(key);
    return _writePreferences(preferences);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    var preferences = await _readPreferences();
    preferences[key] = value;
    return _writePreferences(preferences);
  }
}
