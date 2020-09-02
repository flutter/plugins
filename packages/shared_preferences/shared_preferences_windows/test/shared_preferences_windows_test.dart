// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

MemoryFileSystem fs = MemoryFileSystem.test();

void main() {
  const String kTestKey = 'testKey';
  const String kTestValue = 'testValue';

  SharedPreferencesWindows sharedPreferences;

  setUp(() {
    sharedPreferences = SharedPreferencesWindows();
    sharedPreferences.win32Wrapper = MockWin32Wrapper();
    sharedPreferences.fs = fs;
  });

  tearDown(() {
    fs.file(sharedPreferences.getLocalDataFilePath)
      ..deleteSync(recursive: true);
  });

  /// Writes the test file to disk and loads the contents to the
  /// sharedPreferences cache.
  void _writeTestFile() {
    fs.file(sharedPreferences.getLocalDataFilePath)
      ..createSync(recursive: true)
      ..writeAsStringSync('''
        {
          "$kTestKey": "$kTestValue"
        }
      ''');
    // Loads the file contents into the shared preferences store's cache.
    sharedPreferences.getCachedPreferences;
  }

  String _readTestFile() {
    return fs.file(sharedPreferences.getLocalDataFilePath).readAsStringSync();
  }

  group('shared preferences', () {
    test('getAll', () async {
      _writeTestFile();

      final Map<String, Object> allData = await sharedPreferences.getAll();
      expect(allData, hasLength(1));
      expect(allData[kTestKey], kTestValue);
    });

    test('remove', () async {
      _writeTestFile();
      expect(sharedPreferences.getCachedPreferences[kTestKey], isNotNull);
      expect(await sharedPreferences.remove(kTestKey), isTrue);
      expect(sharedPreferences.getCachedPreferences.containsKey(kTestKey),
          isFalse);
      expect(_readTestFile(), '{}');
    });

    test('setValue', () async {
      _writeTestFile();
      const String kNewKey = 'NewKey';
      const String kNewValue = 'NewValue';
      expect(sharedPreferences.getCachedPreferences[kNewKey], isNull);
      expect(await sharedPreferences.setValue('String', kNewKey, kNewValue),
          isTrue);
      expect(sharedPreferences.getCachedPreferences[kNewKey], isNotNull);
      expect(_readTestFile(),
          '{"$kTestKey":"$kTestValue","$kNewKey":"$kNewValue"}');
    });

    test('clear', () async {
      _writeTestFile();
      expect(await sharedPreferences.clear(), isTrue);
      expect(sharedPreferences.getCachedPreferences.isEmpty, isTrue);
      expect(_readTestFile(), '{}');
    });
  });
}

class MockWin32Wrapper extends Win32Wrapper {
  @override
  String getLocalDataPath() {
    return fs.directory('\\data').path;
  }

  @override
  String getModuleFileName() {
    return 'test';
  }
}
