// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_web/src/dom_helper.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  group('dom_helper', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    late DomHelper domHelper;
    late FileUploadInputElement input;

    FileList? createFileList(List<File> files) {
      final dataTransfer = DataTransfer();
      files.forEach(dataTransfer.items!.add);
      return dataTransfer.files as FileList?;
    }

    void setFilesAndTriggerChange(List<File> files) {
      input.files = createFileList(files);
      input.dispatchEvent(Event('change'));
    }

    setUp(() {
      domHelper = DomHelper();
      input = FileUploadInputElement();
    });

    group('getFiles', () {
      final mockFile1 = File(['123456'], 'file1.txt');
      final mockFile2 = File([], 'file2.txt');

      testWidgets('works', (_) async {
        final Future<List<XFile>> futureFiles = domHelper.getFiles(
          input: input,
        );

        setFilesAndTriggerChange([mockFile1, mockFile2]);

        final List<XFile> files = await futureFiles;

        expect(files.length, 2);

        expect(files[0].name, 'file1.txt');
        expect(await files[0].length(), 6);
        expect(await files[0].readAsString(), '123456');
        expect(await files[0].lastModified(), isNotNull);

        expect(files[1].name, 'file2.txt');
        expect(await files[1].length(), 0);
        expect(await files[1].readAsString(), '');
        expect(await files[1].lastModified(), isNotNull);
      });

      testWidgets('works multiple times', (_) async {
        Future<List<XFile>> futureFiles;
        List<XFile> files;

        // It should work the first time
        futureFiles = domHelper.getFiles(input: input);
        setFilesAndTriggerChange([mockFile1]);

        files = await futureFiles;

        expect(files.length, 1);
        expect(files.first.name, mockFile1.name);

        // The same input should work more than once
        futureFiles = domHelper.getFiles(input: input);
        setFilesAndTriggerChange([mockFile2]);

        files = await futureFiles;

        expect(files.length, 1);
        expect(files.first.name, mockFile2.name);
      });

      testWidgets('sets the <input /> attributes and clicks it', (_) async {
        final accept = '.jpg,.png';
        final multiple = true;
        bool wasClicked = false;

        //ignore: unawaited_futures
        input.onClick.first.then((_) => wasClicked = true);

        final futureFile = domHelper.getFiles(
          accept: accept,
          multiple: multiple,
          input: input,
        );

        expect(input.matchesWithAncestors('body'), true);
        expect(input.accept, accept);
        expect(input.multiple, multiple);
        expect(
          wasClicked,
          true,
          reason:
              'The <input /> should be clicked otherwise no dialog will be shown',
        );

        setFilesAndTriggerChange([]);
        await futureFile;

        // It should be already removed from the DOM after the file is resolved.
        expect(input.parent, isNull);
      });
    });
  });
}
