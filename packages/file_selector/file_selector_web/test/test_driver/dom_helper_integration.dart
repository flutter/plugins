// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_web/src/dom_helper.dart';
import 'package:pedantic/pedantic.dart';

void main() {
  group('FileSelectorWeb', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    DomHelper domHelper;
    FileUploadInputElement input;

    FileList FileListItems(List<File> files) {
      final dataTransfer = DataTransfer();
      files.forEach(dataTransfer.items.add);
      return dataTransfer.files;
    }

    void setFilesAndTriggerChange(List<File> files) {
      input.files = FileListItems(files);
      input.dispatchEvent(Event('change'));
    }

    setUp(() {
      domHelper = DomHelper();
      input = FileUploadInputElement();
    });

    group('getFiles', () {
      final mockFile1 = File([], 'file1.txt');
      final mockFile2 = File([], 'file2.txt');

      testWidgets('works', (_) async {
        final futureFile = domHelper.getFiles(input: input);

        setFilesAndTriggerChange([mockFile1, mockFile2]);

        final files = await futureFile;

        expect(files.length, 2);

        expect(files[0], mockFile1);
        expect(files[1], mockFile2);
      });

      testWidgets('works multiple times', (_) async {
        Future<List<File>> futureFiles;
        List<File> files;

        // It should work the first time
        futureFiles = domHelper.getFiles(input: input);
        setFilesAndTriggerChange([mockFile1]);

        files = await futureFiles;

        expect(files.length, 1);
        expect(files.first, mockFile1);

        // The same input should work more than once
        futureFiles = domHelper.getFiles(input: input);
        setFilesAndTriggerChange([mockFile2]);

        files = await futureFiles;

        expect(files.length, 1);
        expect(files.first, mockFile2);
      });

      testWidgets('sets the <input /> attributes and clicks it', (_) async {
        final accept = '.jpg,.png';
        final multiple = true;
        bool wasClicked = false;

        unawaited(input.onClick.first.then((_) => wasClicked = true));

        final futureFile = domHelper.getFiles(
          accept: accept,
          multiple: multiple,
          input: input,
        );

        expect(input.matchesWithAncestors('body'), true);
        expect(input.accept, accept);
        expect(input.multiple, multiple);
        expect(wasClicked, true);

        setFilesAndTriggerChange([]);
        await futureFile;

        // It should be already removed from the DOM after the file is resolved.
        expect(input.parent, isNull);
      });
    });
  });
}
