// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm') // Uses dart:io

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

// Please note that executing this test with command
// `flutter test test/x_file_io_test.dart` will set the directory
// to ./file_selector_platform_interface.
//
// This will cause our hello.txt file to be not be found. Please
// execute this test with `flutter test` or change the path to
// ./test/assets/hello.txt
//
// https://github.com/flutter/flutter/issues/20907

final path = './assets/hello.txt';
final String expectedStringContents = 'Hello, world!';
final Uint8List bytes = utf8.encode(expectedStringContents);
final File textFile = File(path);
final String textFilePath = textFile.path;

void main() {
  group('Create with a path', () {
    final pickedFile = XFile(textFilePath);

    test('Can be read as a string', () async {
      expect(await pickedFile.readAsString(), equals(expectedStringContents));
    });
    test('Can be read as bytes', () async {
      expect(await pickedFile.readAsBytes(), equals(bytes));
    });

    test('Can be read as a stream', () async {
      expect(await pickedFile.openRead().first, equals(bytes));
    });

    test('Stream can be sliced', () async {
      expect(
          await pickedFile.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });
  });
}
