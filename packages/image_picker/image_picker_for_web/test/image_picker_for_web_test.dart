// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses dart:html

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/mockito.dart';

final String expectedStringContents = "Hello, world!";
final Uint8List bytes = utf8.encode(expectedStringContents);
final html.File textFile = html.File([bytes], "hello.txt");

class MockFileInput extends Mock implements html.FileUploadInputElement {}

class MockOnChangeEvent extends Mock implements html.Event {
  @override
  MockFileInput target;
}

class MockElementStream<T extends html.Event> extends Mock
    implements html.ElementStream<T> {
  final StreamController<T> controller = StreamController<T>();
  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

void main() {
  // Mock the "pick file" browser behavior.
  MockFileInput mockInput;
  MockElementStream mockStream;
  MockElementStream mockErrorStream;
  MockOnChangeEvent mockEvent;

  // Under test...
  ImagePickerPlugin plugin;

  setUp(() {
    mockInput = MockFileInput();
    mockStream = MockElementStream<html.Event>();
    mockErrorStream = MockElementStream<html.Event>();
    mockEvent = MockOnChangeEvent()..target = mockInput;

    // Make the mockInput behave like a proper input...
    when(mockInput.onChange).thenAnswer((_) => mockStream);
    when(mockInput.onError).thenAnswer((_) => mockErrorStream);

    plugin = ImagePickerPlugin(overrideCreateInput: (_, __) => mockInput);
  });

  test('Can select a file', () async {
    // Init the pick file dialog...
    final file = plugin.pickFile();

    // Mock the browser behavior of selecting a file...
    when(mockInput.files).thenReturn([textFile]);
    mockStream.controller.add(mockEvent);

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
    setUp(() {
      plugin = ImagePickerPlugin();
    });
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
