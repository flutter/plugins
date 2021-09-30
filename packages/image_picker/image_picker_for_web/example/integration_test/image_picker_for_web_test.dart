// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

final String expectedStringContents = 'Hello, world!';
final String otherStringContents = 'Hello again, world!';
final String pngFileBase64Contents =  "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAAcTAAAHEwHOIA8IAAAB0mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIj4KICAgICAgICAgPHBob3Rvc2hvcDpDcmVkaXQ+wqkgR29vZ2xlPC9waG90b3Nob3A6Q3JlZGl0PgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4K43gerQAAAA1JREFUCB1jeOVs+h8ABd8CYkMBAJAAAAAASUVORK5CYII=";

final Uint8List bytes = utf8.encode(expectedStringContents) as Uint8List;
final Uint8List otherBytes = utf8.encode(otherStringContents) as Uint8List;
final Uint8List pngFileBytes = utf8.encode(pngFileBase64Contents) as Uint8List;

final Map<String, dynamic> options = {
  'type': 'text/plain',
  'lastModified': DateTime.utc(2017, 12, 13).millisecondsSinceEpoch,
};
final html.File textFile = html.File([bytes], 'hello.txt', options);
final html.File secondTextFile = html.File([otherBytes], 'secondFile.txt');
final html.File pngImageFile = html.File([pngFileBytes],'testimage.png');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Under test...
  late ImagePickerPlugin plugin;

  setUp(() {
    plugin = ImagePickerPlugin();
  });

  testWidgets('Can select a file (Deprecated)', (WidgetTester tester) async {
    final mockInput = html.FileUploadInputElement();

    final overrides = ImagePickerPluginTestOverrides()
      ..createInputElement = ((_, __) => mockInput)
      ..getMultipleFilesFromInput = ((_) => [textFile]);

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

  testWidgets('Can select a file', (WidgetTester tester) async {
    final mockInput = html.FileUploadInputElement();

    final overrides = ImagePickerPluginTestOverrides()
      ..createInputElement = ((_, __) => mockInput)
      ..getMultipleFilesFromInput = ((_) => [textFile]);

    final plugin = ImagePickerPlugin(overrides: overrides);

    // Init the pick file dialog...
    final image = plugin.getImage(source: ImageSource.camera);

    // Mock the browser behavior of selecting a file...
    mockInput.dispatchEvent(html.Event('change'));

    // Now the file should be available
    expect(image, completes);

    // And readable
    final XFile file = await image;
    expect(file.readAsBytes(), completion(isNotEmpty));
    expect(file.name, textFile.name);
    expect(file.length(), completion(textFile.size));
    expect(file.mimeType, textFile.type);
    expect(
        file.lastModified(),
        completion(
          DateTime.fromMillisecondsSinceEpoch(textFile.lastModified!),
        ));
  });

  testWidgets('Can select multiple files', (WidgetTester tester) async {
    final mockInput = html.FileUploadInputElement();

    final overrides = ImagePickerPluginTestOverrides()
      ..createInputElement = ((_, __) => mockInput)
      ..getMultipleFilesFromInput = ((_) => [textFile, secondTextFile]);

    final plugin = ImagePickerPlugin(overrides: overrides);

    // Init the pick file dialog...
    final files = plugin.getMultiImage();

    // Mock the browser behavior of selecting a file...
    mockInput.dispatchEvent(html.Event('change'));

    // Now the file should be available
    expect(files, completes);

    // And readable
    expect((await files).first.readAsBytes(), completion(isNotEmpty));

    // Peek into the second file...
    final XFile secondFile = (await files).elementAt(1);
    expect(secondFile.readAsBytes(), completion(isNotEmpty));
    expect(secondFile.name, secondTextFile.name);
    expect(secondFile.length(), completion(secondTextFile.size));
  });

  testWidgets('image is not scaled if maxWidth and maxHeight is not set',(WidgetTester  tester) async {
    final mockInput = html.FileUploadInputElement();
    final overrides = ImagePickerPluginTestOverrides()
      ..createInputElement = ((_, __) => mockInput)
      ..getMultipleFilesFromInput = ((_) => [pngImageFile]);

    final plugin = ImagePickerPlugin(overrides: overrides);

    // Init the pick file dialog...
    final image = plugin.getImage(source: ImageSource.gallery,);
    final imageElement = html.ImageElement(src: pngFileBase64Contents);
    final imageloadCompleter = Completer<void>();
    imageElement.onLoad.listen((event) {
      print(event);
      imageloadCompleter.complete();
    });
    mockInput.dispatchEvent(html.Event('change'));

  await imageloadCompleter.future;
    expect(imageElement.width,1);
    expect(imageElement.height,1);
    final XFile xFile  = await image;
    final pickedImageElement = html.ImageElement(src:   html.Url.createObjectUrl(html.Blob(await xFile.readAsBytes())));
    final newCompleter = Completer<void>();
    pickedImageElement.onLoad.listen((event) {
      newCompleter.complete();
    }
    );
    await newCompleter.future;
    expect(pickedImageElement.width,99);

  });

  // There's no good way of detecting when the user has "aborted" the selection.

  testWidgets('computeCaptureAttribute', (WidgetTester tester) async {
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
    testWidgets('accept: any, capture: null', (WidgetTester tester) async {
      html.Element input = plugin.createInputElement('any', null);

      expect(input.attributes, containsPair('accept', 'any'));
      expect(input.attributes, isNot(contains('capture')));
      expect(input.attributes, isNot(contains('multiple')));
    });

    testWidgets('accept: any, capture: something', (WidgetTester tester) async {
      html.Element input = plugin.createInputElement('any', 'something');

      expect(input.attributes, containsPair('accept', 'any'));
      expect(input.attributes, containsPair('capture', 'something'));
      expect(input.attributes, isNot(contains('multiple')));
    });

    testWidgets('accept: any, capture: null, multi: true',
        (WidgetTester tester) async {
      html.Element input =
          plugin.createInputElement('any', null, multiple: true);

      expect(input.attributes, containsPair('accept', 'any'));
      expect(input.attributes, isNot(contains('capture')));
      expect(input.attributes, contains('multiple'));
    });

    testWidgets('accept: any, capture: something, multi: true',
        (WidgetTester tester) async {
      html.Element input =
          plugin.createInputElement('any', 'something', multiple: true);

      expect(input.attributes, containsPair('accept', 'any'));
      expect(input.attributes, containsPair('capture', 'something'));
      expect(input.attributes, contains('multiple'));
    });
  });


}
