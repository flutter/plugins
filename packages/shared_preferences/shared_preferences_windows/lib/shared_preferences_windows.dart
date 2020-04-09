// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'src/win32.dart' as win32;

/// Wrapper to the win32 ffi functions for testing.
class Win32Wrapper {
  /// Calls the win32 function for [getLocalDataPath].
  String getLocalDataPath() {
    return win32.getLocalDataPath();
  }

  /// Calls the win32 function for [getModuleFileName].
  String getModuleFileName() {
    return win32.getModuleFileName();
  }
}

/// The Windows implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for Windowds.
class SharedPreferencesWindows extends SharedPreferencesStorePlatform {
  /// The name of the parent directory for [fileName].
  final String fileDirectory = 'Flutter';

  /// File system used to store to disk. Exposed for testing only.
  @visibleForTesting
  FileSystem fs = LocalFileSystem();

  /// Wrapper for win32 ffi calls.
  @visibleForTesting
  Win32Wrapper win32Wrapper = Win32Wrapper();

  String _localDataFilePath;

  /// The path to the file in disk were the preferences are stored.
  @visibleForTesting
  String get getLocalDataFilePath {
    if (_localDataFilePath != null) {
      return _localDataFilePath;
    }
    String appPath = win32Wrapper.getModuleFileName();
    String appName = path.basenameWithoutExtension(appPath);
    String localDataPath = win32Wrapper.getLocalDataPath();
    // Append app-specific identifiers.
    _localDataFilePath =
        path.join(localDataPath, fileDirectory, '$appName.json');
    return _localDataFilePath;
  }

  Map<String, Object> _cachedPreferences;

  /// The in-memory representation of the map saved to a file in disk;
  @visibleForTesting
  Map<String, Object> get getCachedPreferences {
    if (_cachedPreferences == null) {
      File localDataFile = fs.file(getLocalDataFilePath);
      if (!localDataFile.existsSync()) {
        localDataFile.createSync(recursive: true);
      }
      String stringMap = localDataFile.readAsStringSync();
      _cachedPreferences = stringMap.isEmpty
          ? {}
          : json.decode(stringMap) as Map<String, Object>;
    }
    return _cachedPreferences;
  }

  /// Writes the cached preferences to disk. Returns [true] if the operation
  /// succeeded.
  bool _writePreferencesToFile() {
    try {
      File localDataFile = fs.file(getLocalDataFilePath);
      if (!localDataFile.existsSync()) {
        localDataFile.createSync(recursive: true);
      }
      String stringMap = json.encode(getCachedPreferences);
      localDataFile.writeAsStringSync(stringMap);
    } catch (e) {
      print("Error saving preferences to disk: $e");
      return false;
    }
    return true;
  }

  @override
  Future<bool> clear() async {
    getCachedPreferences.clear();
    return _writePreferencesToFile();
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return getCachedPreferences;
  }

  @override
  Future<bool> remove(String key) async {
    getCachedPreferences.remove(key);
    return _writePreferencesToFile();
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    getCachedPreferences[key] = value;
    return _writePreferencesToFile();
  }
}
