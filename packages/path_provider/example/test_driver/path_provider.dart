// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'dart:io';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);
  tearDownAll(() => allTestsCompleter.complete(null));

  test('getTemporaryDirectory', () async {
    final Directory result = await getTemporaryDirectory();
    final String uuid = Uuid().v1();
    final File file = File('${result.path}/$uuid.txt');
    file.writeAsStringSync('Hello world!');
    expect(file.readAsStringSync(), 'Hello world!');
    expect(result.listSync(), isNotEmpty);
    file.deleteSync();
  });

  test('getApplicationDocumentsDirectory', () async {
    final Directory result = await getApplicationDocumentsDirectory();
    final String uuid = Uuid().v1();
    final File file = File('${result.path}/$uuid.txt');
    file.writeAsStringSync('Hello world!');
    expect(file.readAsStringSync(), 'Hello world!');
    expect(result.listSync(), isNotEmpty);
    file.deleteSync();
  });

  test('getExternalStorageDirectory', () async {
    if (Platform.isIOS) {
      final Future<Directory> result = getExternalStorageDirectory();
      expect(result, throwsA(isInstanceOf<UnsupportedError>()));
    } else if (Platform.isAndroid) {
      final Directory result = await getExternalStorageDirectory();
      // This directory is not accessible in Android emulators.
      // However, it should at least have a fake path returned.
      expect(result.path.length, isNonZero);
    }
  });
}
