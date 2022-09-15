// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_android/file_selector_android.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FileSelectorAndroid plugin;
  late List<MethodCall> log;

  setUp(() {
    plugin = FileSelectorAndroid();
    log = <MethodCall>[];
    plugin.channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });
  });

  test('registers instance', () async {
    FileSelectorAndroid.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorAndroid>());
  });

  group('#getDirectoryPath', () {
    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPath(initialDirectory: '/example/directory');

      expect(
        log,
        <Matcher>[
          isMethodCall('getDirectoryPath', arguments: <String, dynamic>{
            'initialDirectory': '/example/directory'
          }),
        ],
      );
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPath(confirmButtonText: 'Open File');

      expect(
        log,
        <Matcher>[
          isMethodCall('getDirectoryPath', arguments: <String, dynamic>{
            'initialDirectory': null,
          }),
        ],
      );
    });
  });
}
