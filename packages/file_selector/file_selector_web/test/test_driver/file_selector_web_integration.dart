// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/file_selector_web.dart';

void main() {
  group('FileSelectorWeb', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    FileSelectorWeb plugin;
    Element container;

    setUp(() {
      container = Element.div();
      plugin = FileSelectorWeb(container: container);
    });

    group('openFile', () {
      final mockFile = File(['random content'], 'image.png');

      testWidgets('works', (WidgetTester _) async {
        final typeGroup = XTypeGroup(
          label: 'images',
          extensions: ['jpg', 'jpeg'],
          mimeTypes: ['image/png'],
          webWildCards: ['image/*'],
        );

        final futureFile = plugin.openFile(acceptedTypeGroups: [typeGroup]);

        setFilesAndTriggerChange(container, [mockFile]);

        final file = await futureFile;
        final input = getInput(container);

        expect(input.accept, '.jpg,.jpeg,image/png,image/*');
        expect(input.multiple, false);
        expect(file.name, mockFile.name);
        expect(await file.length(), 14);
        expect(await file.readAsString(), 'random content');
        expect(await file.lastModified(), isNotNull);
      });
    });

    group('openFiles', () {
      final mockFile = File(['123456'], 'log.txt');

      testWidgets('works', (WidgetTester _) async {
        final txts = XTypeGroup(
          label: 'txt',
          mimeTypes: ['file/txt'],
        );

        final jsons = XTypeGroup(
          label: 'JSON',
          extensions: ['json'],
        );

        final futureFiles = plugin.openFiles(acceptedTypeGroups: [txts, jsons]);

        setFilesAndTriggerChange(container, [mockFile]);

        final files = await futureFiles;
        final input = getInput(container);

        expect(input.accept, 'file/txt,.json');
        expect(input.multiple, true);
        expect(files.length, 1);
        expect(files[0].name, 'log.txt');
        expect(await files[0].length(), 6);
        expect(await files[0].readAsString(), '123456');
        expect(await files[0].lastModified(), isNotNull);
      });
    });
  });
}

void setFilesAndTriggerChange(Element container, List<File> files) {
  final input = getInput(container);
  input.files = FileListItems(files);
  input.dispatchEvent(Event('change'));
}

FileUploadInputElement getInput(Element container) {
  final input = container.children.first as FileUploadInputElement;
  assert(input != null);
  return input;
}

FileList FileListItems(List<File> files) {
  final dt = DataTransfer();
  files.forEach((file) => dt.items.add(file));
  return dt.files;
}
