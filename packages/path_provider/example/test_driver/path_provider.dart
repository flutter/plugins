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

  test('getApplicationSupportDirectory', () async {
    final Directory result = await getApplicationSupportDirectory();
    final String uuid = Uuid().v1();
    final File file = File('${result.path}/$uuid.txt');
    file.writeAsStringSync('Hello world!');
    expect(file.readAsStringSync(), 'Hello world!');
    expect(result.listSync(), isNotEmpty);
    file.deleteSync();
  });

  test('getLibraryDirectory', () async {
    if (Platform.isIOS) {
      final Directory result = await getLibraryDirectory();
      final String uuid = Uuid().v1();
      final File file = File('${result.path}/$uuid.txt');
      file.writeAsStringSync('Hello world!');
      expect(file.readAsStringSync(), 'Hello world!');
      expect(result.listSync(), isNotEmpty);
      file.deleteSync();
    } else if (Platform.isAndroid) {
      final Future<Directory> result = getLibraryDirectory();
      expect(result, throwsA(isInstanceOf<UnsupportedError>()));
    }
  });

  test('getExternalStorageDirectory', () async {
    if (Platform.isIOS) {
      final Future<Directory> result = getExternalStorageDirectory();
      expect(result, throwsA(isInstanceOf<UnsupportedError>()));
    } else if (Platform.isAndroid) {
      final Directory result = await getExternalStorageDirectory();
      final String uuid = Uuid().v1();
      final File file = File('${result.path}/$uuid.txt');
      file.writeAsStringSync('Hello world!');
      expect(file.readAsStringSync(), 'Hello world!');
      expect(result.listSync(), isNotEmpty);
      file.deleteSync();
    }
  });

  test('getExternalCacheDirectories', () async {
    if (Platform.isIOS) {
      final Future<List<Directory>> result = getExternalCacheDirectories();
      expect(result, throwsA(isInstanceOf<UnsupportedError>()));
    } else if (Platform.isAndroid) {
      final List<Directory> directories = await getExternalCacheDirectories();
      for (Directory result in directories) {
        final String uuid = Uuid().v1();
        final File file = File('${result.path}/$uuid.txt');
        file.writeAsStringSync('Hello world!');
        expect(file.readAsStringSync(), 'Hello world!');
        expect(result.listSync(), isNotEmpty);
        file.deleteSync();
      }
    }
  });

  test('getExternalStorageDirectories', () async {
    if (Platform.isIOS) {
      final Future<List<Directory>> result =
          getExternalStorageDirectories(type: null);
      expect(result, throwsA(isInstanceOf<UnsupportedError>()));
    } else if (Platform.isAndroid) {
      final List<StorageDirectory> allDirs = <StorageDirectory>[
        null,
        StorageDirectory.music,
        StorageDirectory.podcasts,
        StorageDirectory.ringtones,
        StorageDirectory.alarms,
        StorageDirectory.notifications,
        StorageDirectory.pictures,
        StorageDirectory.movies,
      ];
      for (StorageDirectory type in allDirs) {
        final List<Directory> directories =
            await getExternalStorageDirectories(type: type);
        for (Directory result in directories) {
          final String uuid = Uuid().v1();
          final File file = File('${result.path}/$uuid.txt');
          file.writeAsStringSync('Hello world!');
          expect(file.readAsStringSync(), 'Hello world!');
          expect(result.listSync(), isNotEmpty);
          file.deleteSync();
        }
      }
    }
  });
}
