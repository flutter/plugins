// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses dart:html

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final String expectedStringContents = "Hello, world!";
final Uint8List bytes = utf8.encode(expectedStringContents);
final html.File textFile = html.File([bytes], "hello.txt");

void main() {
  // Under test...
  ImagePickerPlugin plugin;

  setUp(() {
    plugin = ImagePickerPlugin();
  });

  test('Can select a file', () async {
    final mockInput = html.FileUploadInputElement();

    final overrides = ImagePickerPluginTestOverrides()
      ..createInputElement = ((_, __) => mockInput)
      ..getFileFromInput = ((_) => textFile);

    final plugin = ImagePickerPlugin(overrides: overrides);

    // Init the pick file dialog...
    final file = plugin.pickFile();

    // Mock the browser behavior of selecting a file...
    mockInput.dispatchEvent(html.Event('change'));

    // Now the file should be available
    expect(file, completes);
    // And readable
    expect((await file).readAsBytes(), completion(isNotEmpty));
  });

  // There's no good way of detecting when the user has "aborted" the selection.

  test('computeCaptureAttribute', () {
    expect(
      plugin.computeCaptureAttribute(ImageSource.gallery, CameraDevice.front),
      isNull,
    );
    expect(
      plugin.computeCaptureAttribute(ImageSource.gallery, CameraDevice.rear),
      isNull,
    );
    expect(
      plugin.computeCaptureAttribute(ImageSource.camera, CameraDevice.front),
      'user',
    );
    expect(
      plugin.computeCaptureAttribute(ImageSource.camera, CameraDevice.rear),
      'environment',
    );
  });

  group('createInputElement', () {
    test('accept: any, capture: null', () {
      html.Element input = plugin.createInputElement('any', null);

      expect(input.attributes, containsPair('accept', 'any'));
      expect(input.attributes, isNot(contains('capture')));
    });

    test('accept: any, capture: something', () {
      html.Element input = plugin.createInputElement('any', 'something');

      expect(input.attributes, containsPair('accept', 'any'));
      expect(input.attributes, containsPair('capture', 'something'));
    });
  });
}
