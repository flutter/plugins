// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:shared_preferences_linux/shared_preferences_linux.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  late MemoryFileSystem fs;

  SharedPreferencesLinux.registerWith();

  setUp(() {
    fs = MemoryFileSystem.test();
  });

  Future<String> _getFilePath() async {
    final pathProvider = PathProviderLinux();
    final directory = await pathProvider.getApplicationSupportPath();
    return path.join(directory!, 'shared_preferences.json');
  }

  _writeTestFile(String value) async {
    fs.file(await _getFilePath())
      ..createSync(recursive: true)
      ..writeAsStringSync(value);
  }

  Future<String> _readTestFile() async {
    return fs.file(await _getFilePath()).readAsStringSync();
  }

  SharedPreferencesLinux _getPreferences() {
    var prefs = SharedPreferencesLinux();
    prefs.fs = fs;
    return prefs;
  }

  test('registered instance', () {
    expect(
        SharedPreferencesStorePlatform.instance, isA<SharedPreferencesLinux>());
  });

  test('getAll', () async {
    await _writeTestFile('{"key1": "one", "key2": 2}');
    var prefs = _getPreferences();

    var values = await prefs.getAll();
    expect(values, hasLength(2));
    expect(values['key1'], 'one');
    expect(values['key2'], 2);
  });

  test('remove', () async {
    await _writeTestFile('{"key1":"one","key2":2}');
    var prefs = _getPreferences();

    await prefs.remove('key2');

    expect(await _readTestFile(), '{"key1":"one"}');
  });

  test('setValue', () async {
    await _writeTestFile('{}');
    var prefs = _getPreferences();

    await prefs.setValue('', 'key1', 'one');
    await prefs.setValue('', 'key2', 2);

    expect(await _readTestFile(), '{"key1":"one","key2":2}');
  });

  test('clear', () async {
    await _writeTestFile('{"key1":"one","key2":2}');
    var prefs = _getPreferences();

    await prefs.clear();
    expect(await _readTestFile(), '{}');
  });
}
