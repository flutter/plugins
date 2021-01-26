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
final Uint8List bytes = utf8.encode(expectedStringContents);
final File textFile = File('./test/assets/hello.txt');
String textFilePath = textFile.path;

void main() {
  group('Create with an objectUrl', () {
    PickedFile pickedFile;
    if (Directory(textFilePath).existsSync()) {
      pickedFile = PickedFile(textFilePath);
    } else {
      // TODO(cyanglaz): remove this alternative file location when https://github.com/flutter/flutter/commit/22f170042746ff253997236f6350ecb7403cf3b1
      // lands on stable.
      pickedFile = PickedFile(File('./assets/hello.txt').path);
    }

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
