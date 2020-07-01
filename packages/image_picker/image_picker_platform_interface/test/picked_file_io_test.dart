// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm') // Uses dart:io

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final String expectedStringContents = 'Hello, world!';
final int expectedSize = expectedStringContents.length;
final Uint8List bytes = utf8.encode(expectedStringContents);
final File textFile = File('./assets/hello.txt');
final String textFilePath = textFile.path;

void main() {
  group('Create with an objectUrl', () {
    final pickedFile = PickedFile(textFilePath);

    test('Can get length', () async {
      expect(await pickedFile.length(), equals(expectedSize));
    });

    test('Extracts the filename', () async {
      expect(pickedFile.name, equals('hello.txt'));
    });

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
