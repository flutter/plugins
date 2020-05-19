// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK

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
  MockFileInput mockInput = MockFileInput();
  MockElementStream mockStream = MockElementStream<html.Event>();
  MockElementStream mockErrorStream = MockElementStream<html.Event>();
  MockOnChangeEvent mockEvent = MockOnChangeEvent()..target = mockInput;

  // Under test...
  ImagePickerPlugin plugin =
      ImagePickerPlugin(overrideCreateInput: (_, __) => mockInput);

  setUp(() {
    // Make the mockInput behave like a proper input...
    when(mockInput.onChange).thenAnswer((_) => mockStream);
    when(mockInput.onError).thenAnswer((_) => mockErrorStream);
  });

  tearDown(() {
    reset(mockInput);
  });

  // Pick a file...
  test('Can select a file, happy case', () async {
    // Init the pick file dialog...
    final file = plugin.pickImage(
      source: ImageSource.gallery,
    );

    // Mock the browser behavior of selecting a file...
    when(mockInput.files).thenReturn([textFile]);
    mockStream.controller.add(mockEvent);

    // Now the file should be selected
    expect(file, completes);
    // And readable
    expect((await file).readAsString(), completion(expectedStringContents));
  });

  // Creates the correct DOM for the input...
}
