// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/file_selector_web.dart';
import 'package:file_selector_web/src/dom_helper.dart';

void main() {
  group('FileSelectorWeb', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    late MockDomHelper mockDomHelper;
    late FileSelectorWeb plugin;

    setUp(() {
      mockDomHelper = MockDomHelper();
      plugin = FileSelectorWeb(domHelper: mockDomHelper);
    });

    group('openFile', () {
      final mockFile = createXFile('1001', 'identity.png');

      testWidgets('works', (WidgetTester _) async {
        final typeGroup = XTypeGroup(
          label: 'images',
          extensions: ['jpg', 'jpeg'],
          mimeTypes: ['image/png'],
          webWildCards: ['image/*'],
        );

        when(mockDomHelper.getFiles(
          accept: '.jpg,.jpeg,image/png,image/*',
          multiple: false,
        )).thenAnswer((_) async => [mockFile]);

        final file = await plugin.openFile(acceptedTypeGroups: [typeGroup]);

        expect(file.name, mockFile.name);
        expect(await file.length(), 4);
        expect(await file.readAsString(), '1001');
        expect(await file.lastModified(), isNotNull);
      });
    });

    group('openFiles', () {
      final mockFile1 = createXFile('123456', 'file1.txt');
      final mockFile2 = createXFile('', 'file2.txt');

      testWidgets('works', (WidgetTester _) async {
        final typeGroup = XTypeGroup(
          label: 'files',
          extensions: ['.txt'],
        );

        when(mockDomHelper.getFiles(
          accept: '.txt',
          multiple: true,
        )).thenAnswer((_) async => [mockFile1, mockFile2]);

        final files = await plugin.openFiles(acceptedTypeGroups: [typeGroup]);

        expect(files.length, 2);

        expect(files[0].name, mockFile1.name);
        expect(await files[0].length(), 6);
        expect(await files[0].readAsString(), '123456');
        expect(await files[0].lastModified(), isNotNull);

        expect(files[1].name, mockFile2.name);
        expect(await files[1].length(), 0);
        expect(await files[1].readAsString(), '');
        expect(await files[1].lastModified(), isNotNull);
      });
    });
  });
}

class MockDomHelper extends Mock implements DomHelper {
  @override
  Future<List<XFile>> getFiles({
    String accept = '',
    bool multiple = false,
    FileUploadInputElement? input,
  }) {
    return super
        .noSuchMethod(Invocation.method(#getFiles, [accept, multiple, input]));
  }
}

XFile createXFile(String content, String name) {
  final data = Uint8List.fromList(content.codeUnits);
  return XFile.fromData(data, name: name, lastModified: DateTime.now());
}
