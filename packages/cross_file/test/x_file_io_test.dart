// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm') // Uses dart:io

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file/cross_file.dart';

// Please note that executing this test with command
// `flutter test test/x_file_io_test.dart` will set the directory
// to ./file_selector_platform_interface.
//
// This will cause our hello.txt file to be not be found. Please
// execute this test with `flutter test` or change the path prefix
// to ./test/assets/
//
// https://github.com/flutter/flutter/issues/20907

final pathPrefix = './assets/';
final path = pathPrefix + 'hello.txt';
final String expectedStringContents = 'Hello, world!';
final Uint8List bytes = Uint8List.fromList(utf8.encode(expectedStringContents));
final File textFile = File(path);
final String textFilePath = textFile.path;

void main() {
  group('Create with a path', () {
    final file = XFile(textFilePath);

    test('Can be read as a string', () async {
      expect(await file.readAsString(), equals(expectedStringContents));
    });
    test('Can be read as bytes', () async {
      expect(await file.readAsBytes(), equals(bytes));
    });

    test('Can be read as a stream', () async {
      expect(await file.openRead().first, equals(bytes));
    });

    test('Stream can be sliced', () async {
      expect(await file.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });

    test('saveTo(..) creates file', () async {
      File removeBeforeTest = File(pathPrefix + 'newFilePath.txt');
      if (removeBeforeTest.existsSync()) {
        await removeBeforeTest.delete();
      }

      await file.saveTo(pathPrefix + 'newFilePath.txt');
      File newFile = File(pathPrefix + 'newFilePath.txt');

      expect(newFile.existsSync(), isTrue);
      expect(newFile.readAsStringSync(), 'Hello, world!');

      await newFile.delete();
    });
  });

  group('Create with data', () {
    final file = XFile.fromData(bytes);

    test('Can be read as a string', () async {
      expect(await file.readAsString(), equals(expectedStringContents));
    });
    test('Can be read as bytes', () async {
      expect(await file.readAsBytes(), equals(bytes));
    });

    test('Can be read as a stream', () async {
      expect(await file.openRead().first, equals(bytes));
    });

    test('Stream can be sliced', () async {
      expect(await file.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });

    test('Function saveTo(..) creates file', () async {
      File removeBeforeTest = File(pathPrefix + 'newFileData.txt');
      if (removeBeforeTest.existsSync()) {
        await removeBeforeTest.delete();
      }

      await file.saveTo(pathPrefix + 'newFileData.txt');
      File newFile = File(pathPrefix + 'newFileData.txt');

      expect(newFile.existsSync(), isTrue);
      expect(newFile.readAsStringSync(), 'Hello, world!');

      await newFile.delete();
    });
  });
}
