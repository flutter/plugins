// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/file_selector_web.dart';
import 'package:file_selector_web/src/dom_helper.dart';

void main() {
  group('FileSelectorWeb', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    MockDomHelper mockDomHelper;
    FileSelectorWeb plugin;

    setUp(() {
      mockDomHelper = MockDomHelper();
      plugin = FileSelectorWeb(domHelper: mockDomHelper);
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

        when(mockDomHelper.getFilesFromInput(
          accept: '.jpg,.jpeg,image/png,image/*',
          multiple: false,
        )).thenAnswer((_) async => [mockFile]);

        final file = await plugin.openFile(acceptedTypeGroups: [typeGroup]);

        expect(file.name, mockFile.name);
        expect(await file.length(), 14);
        expect(await file.readAsString(), 'random content');
        expect(await file.lastModified(), isNotNull);
      });
    });
  });
}

class MockDomHelper extends Mock implements DomHelper {}
